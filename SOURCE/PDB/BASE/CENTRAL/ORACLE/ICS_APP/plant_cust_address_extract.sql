/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_cust_address_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Customer Address Data for Plant databases 

  EXECUTE - 
    Send Customer Address data since last successful send 
    
  EXECUTE - 
    Send Customer Address data based on the specified action.     

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all address data  
    *CUSTOMER - send address data matching a given customer code 
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *CUSTOMER = customer code 

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

create or replace package ics_app.plant_cust_address_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end plant_cust_address_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_cust_address_extract as

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
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
  
  var_customer_code bds_addr_customer.customer_code%type;
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;

  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute is
  begin
    /*-*/
    /* Set global variables  
    /*-*/    
    var_start_date := sysdate;
    var_update_lastrun := true;
    
    /*-*/
    /* Get last run date  
    /*-*/    
    var_lastrun_date := lics_last_run_control.get_last_run('LADPDB03');
  
    execute('*ALL',null,'*ALL');
  end;  

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
        and var_action != '*CUSTOMER' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL or *CUSTOMER');
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
    
    if ( var_action = '*CUSTOMER' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *CUSTOMER actions.');
    end if;
    
    var_start := execute_extract(var_action, var_data);
    
    /*-*/
    /* ensure data was returned in the cursor before creating interfaces 
    /* to send to the specified site(s) 
    /*-*/ 
    if ( var_start = true ) then    
      if ( par_site in ('*ALL','*MFA') ) then
        execute_send('LADPDB03.1'); 
      end if;    
      if ( par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB03.2');
      end if;    
      if ( par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB03.3');
      end if;    
      if ( par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB03.4'); 
      end if;    
      if ( par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB03.5');   
      end if;
      if ( par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB03.6');   
      end if;
    end if; 
    
    if ( var_update_lastrun = true ) then
      lics_last_run_control.set_last_run('LADPDB03',var_start_date);
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
    raise_application_error(-20000, 'plant_cust_address_extract - ' || 'customer_code: ' || var_customer_code || ' - ' || var_exception);

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
    cursor csr_bds_addr_customer is
      select t01.customer_code as customer_code, 
        t01.address_version as address_version, 
        to_char(t01.valid_from_date,'yyyymmdd') as valid_from_date, 
        to_char(t01.valid_to_date,'yyyymmdd') as valid_to_date,
        t01.title as title,
        t01.name as name, 
        t01.name_02 as name_02, 
        t01.name_03 as name_03, 
        t01.name_04 as name_04, 
        t01.city as city, 
        t01.district as district, 
        t01.city_post_code as city_post_code,
        t01.po_box_post_code as po_box_post_code, 
        t01.company_post_code as company_post_code, 
        t01.po_box as po_box, 
        t01.po_box_minus_number as po_box_minus_number,
        t01.po_box_city as po_box_city, 
        t01.po_box_region as po_box_region, 
        t01.po_box_country as po_box_country, 
        t01.po_box_country_iso as po_box_country_iso,
        t01.transportation_zone as transportation_zone, 
        t01.street as street,
        t01.house_number as house_number, 
        t01.location as location, 
        t01.building as building, 
        t01.floor as floor,
        t01.room_number as room_number, 
        t01.country as country, 
        t01.country_iso as country_iso, 
        t01.language as language, 
        t01.language_iso as language_iso, 
        t01.region_code as region_code,
        t01.search_term_01 as search_term_01, 
        t01.search_term_02 as search_term_02, 
        t01.phone_number as phone_number, 
        t01.phone_extension as phone_extension,
        t01.phone_full_number as phone_full_number, 
        t01.fax_number as fax_number, 
        t01.fax_extension as fax_extension, 
        t01.fax_full_number as fax_full_number
      from bds_addr_customer t01,
        bds_addr_header t02
      where t01.customer_code = t02.address_code
        and t02.address_type = 'KNA1'
        and
        (
          (par_action = '*ALL' and (var_lastrun_date is null or t02.bds_lads_date >= var_lastrun_date))
          or (par_action = '*CUSTOMER' and ltrim(t01.customer_code,'0') = ltrim(par_data,'0'))
        );
    rcd_bds_addr_customer csr_bds_addr_customer%rowtype;

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
    open csr_bds_addr_customer;
    loop
    
      fetch csr_bds_addr_customer into rcd_bds_addr_customer;
      exit when csr_bds_addr_customer%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store current customer code for error message purposes 
      /*-*/
      var_customer_code := rcd_bds_addr_customer.customer_code;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_addr_customer.customer_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.address_version),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.valid_from_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.valid_to_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.title),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.name),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.name_02),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.name_03),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.name_04),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.city),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.district),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.city_post_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.po_box_post_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.company_post_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.po_box),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.po_box_minus_number),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.po_box_city),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.po_box_region),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.po_box_country),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.po_box_country_iso),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.transportation_zone),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.street),' '),60,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.house_number),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.location),' '),40,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.building),' '),20,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.floor),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.room_number),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.country),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.country_iso),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.language),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.language_iso),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.region_code),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.search_term_01),' '),20,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.search_term_02),' '),20,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.phone_number),' '),30,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.phone_extension),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.phone_full_number),' '),30,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.fax_number),' '),30,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.fax_extension),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.fax_full_number),' '),30,' ');

    end loop;
    close csr_bds_addr_customer;

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

end plant_cust_address_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_cust_address_extract to appsupport;
grant execute on ics_app.plant_cust_address_extract to lads_app;
grant execute on ics_app.plant_cust_address_extract to lics_app;
grant execute on ics_app.plant_cust_address_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_cust_address_extract for ics_app.plant_cust_address_extract;
