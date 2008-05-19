/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_refrnc_plant_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Plant Reference Data for Plant databases 

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all plant data  
    *PLANT - send plant data matching a given plant code 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *PLANT = plant code 

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 

*******************************************************************************/

create or replace package ics_app.plant_refrnc_plant_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end plant_refrnc_plant_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_refrnc_plant_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_plant_code bds_refrnc_plant.plant_code%type;
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
    var_action    varchar2(10);
    var_data      varchar2(100);
    var_site      varchar2(10);
    var_start     boolean := false;
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    tbl_definition.delete;
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*PLANT' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *PLANT');
    end if;
    
    if ( var_site != '*ALL'
        and var_site != '*MCA'
        and var_site != '*SCO'
        and var_site != '*WOD'
        and var_site != '*MFA'
        and var_site != '*BTH'
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *BTH, *WGI or NULL');
    end if;
    
    if ( var_action = '*PLANT' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *PLANT actions.');
    end if;
    
    var_start := execute_extract(var_action, var_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if (par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB08.1'); 
      end if;    
      if (par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB08.2'); 
      end if;    
      if (par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB08.3'); 
      end if;    
      if (par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB08.4');
      end if;    
      if (par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB08.5');   
      end if;
      if (par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB08.6');   
      end if;
    end if; 
      
  /*-------------------*/
  /* Exception handler */
  /*-------------------*/
  exception

    /**/
    /* Exception trap 
    /**/
    when others then

    /*-*/
    /* Rollback the database 
    /*-*/
    rollback;

    /*-*/
    /* Save the exception 
    /*-*/
    var_exception := substr(sqlerrm, 1, 1024);

    /*-*/
    /* Finalise the outbound loader when required 
    /*-*/
    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.add_exception(var_exception);
      lics_outbound_loader.finalise_interface;
    end if;

    /*-*/
    /* Raise an exception to the calling application 
    /*-*/
    raise_application_error(-20000, 'plant_refrnc_plant_extract - ' || 'plant_code: ' || var_plant_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
  function execute_extract(par_action in varchar2, par_data in varchar2) return boolean is

    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_refrnc_plant is
      select t01.plant_code as plant_code, 
        t01.sap_idoc_number as sap_idoc_number, 
        t01.sap_idoc_timestamp as sap_idoc_timestamp, 
        t01.change_flag as change_flag,
        t01.plant_name as plant_name, 
        t01.vltn_area as vltn_area, 
        t01.plant_customer_no as plant_customer_no, 
        t01.plant_vendor_no as plant_vendor_no,
        t01.factory_calendar_key as factory_calendar_key, 
        t01.plant_name_2 as plant_name_2, 
        t01.plant_street as plant_street, 
        t01.plant_po_box as plant_po_box,
        t01.plant_post_code as plant_post_code, 
        t01.plant_city as plant_city, 
        t01.plant_purchasing_organisation as plant_purchasing_organisation,
        t01.plant_sales_organisation as plant_sales_organisation, 
        t01.batch_manage_indctr as batch_manage_indctr, 
        t01.plant_condition_indctr as plant_condition_indctr,
        t01.source_list_indctr as source_list_indctr, 
        t01.activate_reqrmnt_indctr as activate_reqrmnt_indctr, 
        t01.plant_country_key as plant_country_key,
        t01.plant_region as plant_region, 
        t01.plant_country_code as plant_country_code, 
        t01.plant_city_code as plant_city_code, 
        t01.plant_address as plant_address,
        t01.maint_planning_plant as maint_planning_plant, 
        t01.tax_jurisdiction_code as tax_jurisdiction_code,
        t01.dstrbtn_channel as dstrbtn_channel, 
        t01.division as division,
        t01.language_key as language_key, 
        t01.sop_plant as sop_plant, 
        t01.variance_key as variance_key, 
        t01.batch_manage_old_indctr as batch_manage_old_indctr,
        t01.plant_ctgry as plant_ctgry, 
        t01.plant_sales_district as plant_sales_district, 
        t01.plant_supply_region as plant_supply_region,
        t01.plant_tax_indctr as plant_tax_indctr, 
        t01.regular_vendor_indctr as regular_vendor_indctr, 
        t01.first_reminder_days as first_reminder_days,
        t01.second_reminder_days as second_reminder_days,  
        t01.third_reminder_days as third_reminder_days, 
        t01.vendor_declaration_text_1 as vendor_declaration_text_1,
        t01.vendor_declaration_text_2 as vendor_declaration_text_2, 
        t01.vendor_declaration_text_3 as vendor_declaration_text_3,
        t01.po_tolerance_days as po_tolerance_days, 
        t01.plant_business_place as plant_business_place, 
        t01.stock_xfer_rule as stock_xfer_rule,
        t01.plant_dstrbtn_profile as plant_dstrbtn_profile, 
        t01.central_archive_marker as central_archive_marker, 
        t01.dms_type_indctr as dms_type_indctr,
        t01.node_type as node_type, 
        t01.name_formation_structure as name_formation_structure, 
        t01.cost_control_active_indctr as cost_control_active_indctr,
        t01.mixed_costing_active_indctr as mixed_costing_active_indctr, 
        t01.actual_costing_active_indctr as actual_costing_active_indctr,
        t01.transport_point as transport_point
      from bds_refrnc_plant t01
      where (t01.plant_code like 'AU%' or t01.plant_code like 'NZ%')
        and
        (
          par_action = '*ALL'
          or (par_action = '*PLANT' and t01.plant_code = par_data)
        );
        
    rcd_refrnc_plant csr_refrnc_plant%rowtype;

 /*-------------*/
 /* Begin block */
 /*-------------*/
  begin

    /*-*/
    /* Initialise variables 
    /*-*/
    var_result := false;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_refrnc_plant;
    loop
    
      fetch csr_refrnc_plant into rcd_refrnc_plant;
      exit when csr_refrnc_plant%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;    
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.sap_idoc_number),'0'),38,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.sap_idoc_timestamp),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.change_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_name),' '),30,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.vltn_area),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_customer_no),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_vendor_no),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.factory_calendar_key),' '),2,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_name_2),' '),30,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_street),' '),30,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_po_box),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_post_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_city),' '),25,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_purchasing_organisation),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_sales_organisation),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.batch_manage_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_condition_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.source_list_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.activate_reqrmnt_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_country_key),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_region),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_country_code),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_city_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_address),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.maint_planning_plant),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.tax_jurisdiction_code),' '),15,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.dstrbtn_channel),' '),2,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.division),' '),2,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.language_key),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.sop_plant),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.variance_key),' '),6,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.batch_manage_old_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_ctgry),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_sales_district),' '),6,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_supply_region),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_tax_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.regular_vendor_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.first_reminder_days),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.second_reminder_days),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.third_reminder_days),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.vendor_declaration_text_1),' '),16,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.vendor_declaration_text_2),' '),16,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.vendor_declaration_text_3),' '),16,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.po_tolerance_days),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_business_place),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.stock_xfer_rule),' '),2,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.plant_dstrbtn_profile),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.central_archive_marker),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.dms_type_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.node_type),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.name_formation_structure),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.cost_control_active_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.mixed_costing_active_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.actual_costing_active_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_plant.transport_point),' '),4,' ');

    end loop;
    close csr_refrnc_plant;

    return var_result;
  
  end execute_extract;
  
  procedure execute_send(par_interface in varchar2) is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin

    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
        var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end plant_refrnc_plant_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_refrnc_plant_extract to appsupport;
grant execute on ics_app.plant_refrnc_plant_extract to lads_app;
grant execute on ics_app.plant_refrnc_plant_extract to lics_app;
grant execute on ics_app.plant_refrnc_plant_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_refrnc_plant_extract for ics_app.plant_refrnc_plant_extract;
