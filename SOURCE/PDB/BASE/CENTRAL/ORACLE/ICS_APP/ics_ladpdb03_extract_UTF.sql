--
-- ICS_LADPDB03_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ICS_LADPDB03_EXTRACT as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ICS_LADPDB03_EXTRACT 
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
    *HISTORY - all modified since specified date
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *CUSTOMER = customer code 
      - *HISTORY = number of days

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to 
        (configured using VALID_PLANTS directive in ICS Data Store Configuration)
        
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *PCH = Pak Chong Thailand

  YYYY/MM    Author       Version    Description 
  -------    ------       -------    ----------- 
  2008/03   Trevor Keon   1;0        Created 
  2010/08   Ben Halicki   1.1        Updated for Atlas Thailand implementation.  
                                     Removed hard-coded plant codes, modified last send logic
                                     to be specific to individual interface
  2011/08   Vivian Huang  1.2        Modified for outbound interface trigger
  
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end ICS_LADPDB03_EXTRACT;
/


--
-- ICS_LADPDB03_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ICS_LADPDB03_EXTRACT as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);
      
  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
  
  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB03';
      
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
    var_update_lastrun := true;
          
    execute('*ALL',null,'*ALL');
  
  end execute; 

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
    var_intfc     varchar2(20);
     
    /*-*/
    /* Local cursors
    /*-*/
    cursor csr_intfc is
        select 
            dsv_group as site, 
            dsv_value as intfc_extn 
        from 
            table (lics_datastore.retrieve_group('PDB','INTFC_EXTN',NULL)) t01
        where 
            (var_site = '*ALL' or '*' || t01.dsv_group = var_site);
  
    rcd_intfc csr_intfc%rowtype;

    cursor csr_trigger is
        select dsv_value as intfc_trigger 
          from table (lics_datastore.retrieve_value('PDB',rcd_intfc.site,'INTFC_TRIGGER')) t01;
    rcd_trigger csr_trigger%rowtype;   
         
  begin
  
    var_action := upper(nvl(trim(par_action), '*NULL'));
    var_data := trim(par_data);
    var_site := upper(nvl(trim(par_site), '*ALL'));
    
    /*-*/
    /* validate parameters 
    /*-*/
    if ( var_action != '*ALL'
        and var_action != '*CUSTOMER'
        and var_action != '*HISTORY' ) then
      raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *ALL, *CUSTOMER or *HISTORY');
    end if;
    
    if ( var_action = '*CUSTOMER' and var_data is null ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null for *CUSTOMER actions.');
    elsif ( var_action = '*HISTORY' and (var_data is null or to_number(var_data) <= 0) ) then
      raise_application_error(-20000, 'Data parameter (' || par_data || ') must not be null and must be greater than 1 for *HISTORY actions.');
    end if;
    
    open csr_intfc;
    loop
        fetch csr_intfc into rcd_intfc;
        exit when csr_intfc%notfound;
       
        tbl_definition.delete;
        
        var_intfc := con_intfc || rcd_intfc.intfc_extn; 
        
        /*-*/
        /* Get last run date  
        /*-*/    
        if ( var_update_lastrun = true ) then
            var_lastrun_date := lics_last_run_control.get_last_run(var_intfc);
        end if;
        
        var_start_date := sysdate;
        var_start := execute_extract(var_action, var_data, rcd_intfc.site);      

        /*-*/
        /* ensure data was returned in the cursor before creating interfaces 
        /* to send to the specified site(s) 
        /*-*/           
        if ( var_start = true ) then
           open csr_trigger;
           	fetch csr_trigger into rcd_trigger;
           	if csr_trigger%notfound then
              	rcd_trigger.intfc_trigger := 'Y';
           	end if;
           close csr_trigger;
           execute_send(var_intfc, rcd_trigger.intfc_trigger);
        end if;
        
        if ( var_update_lastrun = true ) then
            lics_last_run_control.set_last_run(var_intfc,var_start_date);
        end if;  
        
    end loop;
    
    /*-*/
    /* if no valid sites were found, raise exception
    /*-*/
    if (csr_intfc%rowcount=0 and var_site='*ALL') then
        raise_application_error(-20000, 'No valid plant databases have been configured via Data Store Configuration.');
    end if;
    
    if (csr_intfc%rowcount=0 and var_site!='*ALL') then
        raise_application_error(-20000, 'Site parameter (' || par_site || ') has not been configured via Data Store Configuration.');
    end if;
    
    close csr_intfc;
    
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
    raise_application_error(-20000, 'ics_ladpdb03_extract - ' || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
   
  function execute_extract(par_action in varchar2, par_data in varchar2, par_site in varchar2) return boolean is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_addr_customer is
      select t01.address_code as customer_code, 
        t02.address_version as address_version, 
        to_char(t02.valid_from_date,'yyyymmdd') as valid_from_date, 
        to_char(t02.valid_to_date,'yyyymmdd') as valid_to_date,
        t02.title as title,
        t02.name as name, 
        t02.name_02 as name_02, 
        t02.name_03 as name_03, 
        t02.name_04 as name_04, 
        t02.city as city, 
        t02.district as district, 
        t02.city_post_code as city_post_code,
        t02.po_box_post_code as po_box_post_code, 
        t02.company_post_code as company_post_code, 
        t02.po_box as po_box, 
        t02.po_box_minus_number as po_box_minus_number,
        t02.po_box_city as po_box_city, 
        t02.po_box_region as po_box_region, 
        t02.po_box_country as po_box_country, 
        t02.po_box_country_iso as po_box_country_iso,
        t02.transportation_zone as transportation_zone, 
        t02.street as street,
        t02.house_number as house_number, 
        t02.location as location, 
        t02.building as building, 
        t02.floor as floor,
        t02.room_number as room_number, 
        t02.country as country, 
        t02.country_iso as country_iso, 
        t02.language as language, 
        t02.language_iso as language_iso, 
        t02.region_code as region_code,
        t02.search_term_01 as search_term_01, 
        t02.search_term_02 as search_term_02, 
        t02.phone_number as phone_number, 
        t02.phone_extension as phone_extension,
        t02.phone_full_number as phone_full_number, 
        t02.fax_number as fax_number, 
        t02.fax_extension as fax_extension, 
        t02.fax_full_number as fax_full_number
      from bds_addr_header t01,
        bds_addr_customer t02,
        bds_cust_comp t03,
        bds_cust_sales_area t04    
      where t01.address_code = t02.customer_code
        and t01.address_code=t03.customer_code
        and t01.address_code=t04.customer_code
        and t01.address_type = 'KNA1'
        and t03.company_code in 
        (
            select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_COMPANIES'))
        )
        and t04.sales_org_code in
        (
            select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_SALES_ORGS'))
        )
        and
        (
            (par_action = '*ALL' and (var_lastrun_date is null or t01.bds_lads_date >= var_lastrun_date))
            or (par_action = '*CUSTOMER' and ltrim(t01.address_code,'0') = ltrim(par_data,'0'))
            or (par_action = '*HISTORY' and trunc(t01.bds_lads_date) >= trunc(sysdate-to_number(par_data)))          
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
    tbl_definition.delete;

    /*-*/
    /* Open Cursor for output 
    /*-*/
    open csr_bds_addr_customer;
    loop
    
      fetch csr_bds_addr_customer into rcd_bds_addr_customer;
      exit when csr_bds_addr_customer%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_addr_customer.customer_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.address_version),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.valid_from_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.valid_to_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_bds_addr_customer.title),' '),4,' ')
        || nvl(rcd_bds_addr_customer.name,' ') || rpad(' ',40-length(nvl(rcd_bds_addr_customer.name,' ')),' ')
        || nvl(rcd_bds_addr_customer.name_02,' ') || rpad(' ',40-length(nvl(rcd_bds_addr_customer.name_02,' ')),' ')
        || nvl(rcd_bds_addr_customer.name_03,' ') || rpad(' ',40-length(nvl(rcd_bds_addr_customer.name_03,' ')),' ')
        || nvl(rcd_bds_addr_customer.name_04,' ') || rpad(' ',40-length(nvl(rcd_bds_addr_customer.name_04,' ')),' ')
        || nvl(rcd_bds_addr_customer.city,' ') || rpad(' ',40-length(nvl(rcd_bds_addr_customer.city,' ')),' ')
        || nvl(rcd_bds_addr_customer.district,' ') || rpad(' ',40-length(nvl(rcd_bds_addr_customer.district,' ')),' ')
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
        || nvl(rcd_bds_addr_customer.street,' ') || rpad(' ',60-length(nvl(rcd_bds_addr_customer.street,' ')),' ')        
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
        || nvl(rcd_bds_addr_customer.search_term_01,' ') || rpad(' ',20-length(nvl(rcd_bds_addr_customer.search_term_01,' ')),' ')
        || nvl(rcd_bds_addr_customer.search_term_02,' ') || rpad(' ',20-length(nvl(rcd_bds_addr_customer.search_term_02,' ')),' ')                
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
  
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2) is
  
    /*-*/
    /* Local variables 
    /*-*/
    var_instance number(15,0);
    
  begin

    for idx in 1..tbl_definition.count loop
      if ( lics_outbound_loader.is_created = false ) then
        if upper(par_trigger) = 'Y' then
             var_instance := lics_outbound_loader.create_interface(par_interface, null, par_interface);
        else
             var_instance := lics_outbound_loader.create_interface(par_interface);
	end if;
      end if;
      
      lics_outbound_loader.append_data(tbl_definition(idx).value);
    end loop;

    if ( lics_outbound_loader.is_created = true ) then
      lics_outbound_loader.finalise_interface;
    end if;

    commit;
  end execute_send;

end ICS_LADPDB03_EXTRACT;
/


--
-- ICS_LADPDB03_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB03_EXTRACT FOR ICS_APP.ICS_LADPDB03_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB03_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB03_EXTRACT TO LICS_APP;

