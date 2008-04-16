/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : ladpdb03_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound customer address loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  14-Mar-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.ladpdb03_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladpdb03_loader; 
/

create or replace package body bds_app.ladpdb03_loader as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  procedure complete_transaction;
  procedure process_record_hdr(par_record in varchar2);


  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
  
  rcd_hdr bds_addr_customer_det%rowtype;
  var_customer_code rcd_hdr.customer_code%type;

  /************************************************/
  /* This procedure performs the on start routine */
  /************************************************/
  procedure on_start is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Initialise the transaction variables 
    /*-*/
    var_trn_start := false;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-*/
    /* Initialise the inbound definitions 
    /*-*/ 
    lics_inbound_utility.clear_definition;
    
    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','CUSTOMER_CODE', 10);
    lics_inbound_utility.set_definition('HDR','ADDRESS_VERSION', 5);
    lics_inbound_utility.set_definition('HDR','VALID_FROM_DATE', 14);
    lics_inbound_utility.set_definition('HDR','VALID_TO_DATE', 14);
    lics_inbound_utility.set_definition('HDR','TITLE', 4);
    lics_inbound_utility.set_definition('HDR','NAME', 40);
    lics_inbound_utility.set_definition('HDR','NAME_02', 40);
    lics_inbound_utility.set_definition('HDR','NAME_03', 40);
    lics_inbound_utility.set_definition('HDR','NAME_04', 40);
    lics_inbound_utility.set_definition('HDR','CITY', 40);
    lics_inbound_utility.set_definition('HDR','DISTRICT', 40);
    lics_inbound_utility.set_definition('HDR','CITY_POST_CODE', 10);
    lics_inbound_utility.set_definition('HDR','PO_BOX_POST_CODE', 10);
    lics_inbound_utility.set_definition('HDR','COMPANY_POST_CODE', 10);
    lics_inbound_utility.set_definition('HDR','PO_BOX', 10);
    lics_inbound_utility.set_definition('HDR','PO_BOX_MINUS_NUMBER', 1);
    lics_inbound_utility.set_definition('HDR','PO_BOX_CITY', 40);
    lics_inbound_utility.set_definition('HDR','PO_BOX_REGION', 3);
    lics_inbound_utility.set_definition('HDR','PO_BOX_COUNTRY', 3);
    lics_inbound_utility.set_definition('HDR','PO_BOX_COUNTRY_ISO', 2);
    lics_inbound_utility.set_definition('HDR','TRANSPORTATION_ZONE', 10);
    lics_inbound_utility.set_definition('HDR','STREET', 60);
    lics_inbound_utility.set_definition('HDR','HOUSE_NUMBER', 10);
    lics_inbound_utility.set_definition('HDR','LOCATION', 40);
    lics_inbound_utility.set_definition('HDR','BUILDING', 20);
    lics_inbound_utility.set_definition('HDR','FLOOR', 10);
    lics_inbound_utility.set_definition('HDR','ROOM_NUMBER', 10);
    lics_inbound_utility.set_definition('HDR','COUNTRY', 3);
    lics_inbound_utility.set_definition('HDR','COUNTRY_ISO', 2);
    lics_inbound_utility.set_definition('HDR','LANGUAGE', 1);
    lics_inbound_utility.set_definition('HDR','LANGUAGE_ISO', 2);
    lics_inbound_utility.set_definition('HDR','REGION_CODE', 3);
    lics_inbound_utility.set_definition('HDR','SEARCH_TERM_01', 20);
    lics_inbound_utility.set_definition('HDR','SEARCH_TERM_02', 20);
    lics_inbound_utility.set_definition('HDR','PHONE_NUMBER', 30);
    lics_inbound_utility.set_definition('HDR','PHONE_EXTENSION', 10);
    lics_inbound_utility.set_definition('HDR','PHONE_FULL_NUMBER', 30);
    lics_inbound_utility.set_definition('HDR','FAX_NUMBER', 30);
    lics_inbound_utility.set_definition('HDR','FAX_EXTENSION', 10);
    lics_inbound_utility.set_definition('HDR','FAX_FULL_NUMBER', 30);
      
   /*-------------*/
   /* End routine */
   /*-------------*/
  end on_start;

  /***********************************************/
  /* This procedure performs the on data routine */
  /***********************************************/
  procedure on_data(par_record in varchar2) is

    /*-*/
    /* Local definitions 
    /*-*/
    var_record_identifier varchar2(3);

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin
    /*-*/
    /* Process the data based on record identifier  
    /*-*/
    var_record_identifier := substr(par_record,1,3);
    
    case var_record_identifier
      when 'HDR' then process_record_hdr(par_record);
      else lics_inbound_utility.add_exception('Record identifier (' || var_record_identifier || ') not recognised');
    end case;

  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

  /*-*/
  /* Exception trap 
  /*-*/
    when others then
      lics_inbound_utility.add_exception(substr(sqlerrm, 1, 512));
      var_trn_error := true;
      
  /*-------------*/
  /* End routine */
  /*-------------*/
  end on_data;

   /**********************************************/
   /* This procedure performs the on end routine */
   /**********************************************/
  procedure on_end is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Complete the Transaction 
    /*-*/
    complete_transaction;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end on_end;


   /************************************************************/
   /* This procedure performs the complete transaction routine */
   /************************************************************/
  procedure complete_transaction is

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* No data processed 
    /*-*/
    if ( var_trn_start = false ) then
      rollback;
      return;
    end if;

    /*-*/
    /* Commit/rollback the transaction as required 
    /*-*/
    if ( var_trn_ignore = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    elsif ( var_trn_error = true ) then
      /*-*/
      /* Rollback the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      rollback;
    else
      /*-*/
      /* Commit the transaction 
      /* NOTE - releases transaction lock 
      /*-*/
      commit;
    end if;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end complete_transaction;


  /**************************************************/
  /* This procedure performs the record HDR routine */
  /**************************************************/
  procedure process_record_hdr(par_record in varchar2) is
                           
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*-*/
    /* Complete the previous transactions 
    /*-*/
    complete_transaction;

    /*-*/
    /* Reset transaction variables 
    /*-*/
    var_trn_start := true;
    var_trn_ignore := false;
    var_trn_error := false;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/
    
    rcd_hdr.customer_code := lics_inbound_utility.get_variable('CUSTOMER_CODE');
    rcd_hdr.address_version := lics_inbound_utility.get_variable('ADDRESS_VERSION');
    rcd_hdr.valid_from_date := lics_inbound_utility.get_date('VALID_FROM_DATE','yyyymmddhh24miss');
    rcd_hdr.valid_to_date := lics_inbound_utility.get_date('VALID_TO_DATE','yyyymmddhh24miss');
    rcd_hdr.title := lics_inbound_utility.get_variable('TITLE');
    rcd_hdr.name := lics_inbound_utility.get_variable('NAME');
    rcd_hdr.name_02 := lics_inbound_utility.get_variable('NAME_02');
    rcd_hdr.name_03 := lics_inbound_utility.get_variable('NAME_03');
    rcd_hdr.name_04 := lics_inbound_utility.get_variable('NAME_04');
    rcd_hdr.city := lics_inbound_utility.get_variable('CITY');
    rcd_hdr.district := lics_inbound_utility.get_variable('DISTRICT');
    rcd_hdr.city_post_code := lics_inbound_utility.get_variable('CITY_POST_CODE');
    rcd_hdr.po_box_post_code := lics_inbound_utility.get_variable('PO_BOX_POST_CODE');
    rcd_hdr.company_post_code := lics_inbound_utility.get_variable('COMPANY_POST_CODE');
    rcd_hdr.po_box := lics_inbound_utility.get_variable('PO_BOX');
    rcd_hdr.po_box_minus_number := lics_inbound_utility.get_variable('PO_BOX_MINUS_NUMBER');
    rcd_hdr.po_box_city := lics_inbound_utility.get_variable('PO_BOX_CITY');
    rcd_hdr.po_box_region := lics_inbound_utility.get_variable('PO_BOX_REGION');
    rcd_hdr.po_box_country := lics_inbound_utility.get_variable('PO_BOX_COUNTRY');
    rcd_hdr.po_box_country_iso := lics_inbound_utility.get_variable('PO_BOX_COUNTRY_ISO');
    rcd_hdr.transportation_zone := lics_inbound_utility.get_variable('TRANSPORTATION_ZONE');
    rcd_hdr.street := lics_inbound_utility.get_variable('STREET');
    rcd_hdr.house_number := lics_inbound_utility.get_variable('HOUSE_NUMBER');
    rcd_hdr.location := lics_inbound_utility.get_variable('LOCATION');
    rcd_hdr.building := lics_inbound_utility.get_variable('BUILDING');
    rcd_hdr.floor := lics_inbound_utility.get_variable('FLOOR');
    rcd_hdr.room_number := lics_inbound_utility.get_variable('ROOM_NUMBER');
    rcd_hdr.country := lics_inbound_utility.get_variable('COUNTRY');
    rcd_hdr.country_iso := lics_inbound_utility.get_variable('COUNTRY_ISO');
    rcd_hdr.language := lics_inbound_utility.get_variable('LANGUAGE');
    rcd_hdr.language_iso := lics_inbound_utility.get_variable('LANGUAGE_ISO');
    rcd_hdr.region_code := lics_inbound_utility.get_variable('REGION_CODE');
    rcd_hdr.search_term_01 := lics_inbound_utility.get_variable('SEARCH_TERM_01');
    rcd_hdr.search_term_02 := lics_inbound_utility.get_variable('SEARCH_TERM_02');
    rcd_hdr.phone_number := lics_inbound_utility.get_variable('PHONE_NUMBER');
    rcd_hdr.phone_extension := lics_inbound_utility.get_variable('PHONE_EXTENSION');
    rcd_hdr.phone_full_number := lics_inbound_utility.get_variable('PHONE_FULL_NUMBER');
    rcd_hdr.fax_number := lics_inbound_utility.get_variable('FAX_NUMBER');
    rcd_hdr.fax_extension := lics_inbound_utility.get_variable('FAX_EXTENSION');
    rcd_hdr.fax_full_number := lics_inbound_utility.get_variable('FAX_FULL_NUMBER');
    
    /*-*/
    /* Retrieve exceptions raised 
    /*-*/
    if ( lics_inbound_utility.has_errors = true ) then
      var_trn_error := true;
    end if;

    /*----------------------------------------*/
    /* VALIDATION - Validate the field values */
    /*----------------------------------------*/

    /*-*/
    /* Validate the primary keys 
    /*-*/
    if ( rcd_hdr.customer_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.CUSTOMER_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.address_version is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.ADDRESS_VERSION');
      var_trn_error := true;
    end if;
          
    if ( rcd_hdr.valid_from_date is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.VALID_FROM_DATE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.valid_to_date is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.VALID_TO_DATE');
      var_trn_error := true;
    end if;
    
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;
    
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    /*------------------------------*/
    /* UPDATE - Update the database */
    /*------------------------------*/        
    update bds_addr_customer_det
    set customer_code = rcd_hdr.customer_code, 
      address_version = rcd_hdr.address_version, 
      valid_from_date = rcd_hdr.valid_from_date, 
      valid_to_date = rcd_hdr.valid_to_date,
      title = rcd_hdr.title,
      name = rcd_hdr.name, 
      name_02 = rcd_hdr.name_02, 
      name_03 = rcd_hdr.name_03, 
      name_04 = rcd_hdr.name_04, 
      city = rcd_hdr.city, 
      district = rcd_hdr.district, 
      city_post_code = rcd_hdr.city_post_code,
      po_box_post_code = rcd_hdr.po_box_post_code, 
      company_post_code = rcd_hdr.company_post_code, 
      po_box = rcd_hdr.po_box, 
      po_box_minus_number = rcd_hdr.po_box_minus_number,
      po_box_city = rcd_hdr.po_box_city, 
      po_box_region = rcd_hdr.po_box_region, 
      po_box_country = rcd_hdr.po_box_country, 
      po_box_country_iso = rcd_hdr.po_box_country_iso,
      transportation_zone = rcd_hdr.transportation_zone, 
      street = rcd_hdr.street,
      house_number = rcd_hdr.house_number, 
      location = rcd_hdr.location, 
      building = rcd_hdr.building, 
      floor = rcd_hdr.floor,
      room_number = rcd_hdr.room_number, 
      country = rcd_hdr.country, 
      country_iso = rcd_hdr.country_iso, 
      language = rcd_hdr.language, 
      language_iso = rcd_hdr.language_iso, 
      region_code = rcd_hdr.region_code,
      search_term_01 = rcd_hdr.search_term_01, 
      search_term_02 = rcd_hdr.search_term_02, 
      phone_number = rcd_hdr.phone_number, 
      phone_extension = rcd_hdr.phone_extension,
      phone_full_number = rcd_hdr.phone_full_number, 
      fax_number = rcd_hdr.fax_number, 
      fax_extension = rcd_hdr.fax_extension, 
      fax_full_number = rcd_hdr.fax_full_number
    where customer_code = rcd_hdr.customer_code;
    
    if ( sql%notfound ) then  
      insert into bds_addr_customer_det
      (
        customer_code, 
        address_version, 
        valid_from_date, 
        valid_to_date,
        title,
        name, 
        name_02, 
        name_03, 
        name_04, 
        city, 
        district, 
        city_post_code,
        po_box_post_code, 
        company_post_code, 
        po_box, 
        po_box_minus_number,
        po_box_city, 
        po_box_region, 
        po_box_country, 
        po_box_country_iso,
        transportation_zone, 
        street,
        house_number, 
        location, 
        building, 
        floor,
        room_number, 
        country, 
        country_iso, 
        language, 
        language_iso, 
        region_code,
        search_term_01, 
        search_term_02, 
        phone_number, 
        phone_extension,
        phone_full_number, 
        fax_number, 
        fax_extension, 
        fax_full_number
      )
      values 
      (
        rcd_hdr.customer_code, 
        rcd_hdr.address_version, 
        rcd_hdr.valid_from_date, 
        rcd_hdr.valid_to_date,
        rcd_hdr.title,
        rcd_hdr.name, 
        rcd_hdr.name_02, 
        rcd_hdr.name_03, 
        rcd_hdr.name_04, 
        rcd_hdr.city, 
        rcd_hdr.district, 
        rcd_hdr.city_post_code,
        rcd_hdr.po_box_post_code, 
        rcd_hdr.company_post_code, 
        rcd_hdr.po_box, 
        rcd_hdr.po_box_minus_number,
        rcd_hdr.po_box_city, 
        rcd_hdr.po_box_region, 
        rcd_hdr.po_box_country, 
        rcd_hdr.po_box_country_iso,
        rcd_hdr.transportation_zone, 
        rcd_hdr.street,
        rcd_hdr.house_number, 
        rcd_hdr.location, 
        rcd_hdr.building, 
        rcd_hdr.floor,
        rcd_hdr.room_number, 
        rcd_hdr.country, 
        rcd_hdr.country_iso, 
        rcd_hdr.language, 
        rcd_hdr.language_iso, 
        rcd_hdr.region_code,
        rcd_hdr.search_term_01, 
        rcd_hdr.search_term_02, 
        rcd_hdr.phone_number, 
        rcd_hdr.phone_extension,
        rcd_hdr.phone_full_number, 
        rcd_hdr.fax_number, 
        rcd_hdr.fax_extension, 
        rcd_hdr.fax_full_number
      );
    end if;
    
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
  
end ladpdb03_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb03_loader to appsupport;
grant execute on bds_app.ladpdb03_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb03_loader for bds_app.ladpdb03_loader;