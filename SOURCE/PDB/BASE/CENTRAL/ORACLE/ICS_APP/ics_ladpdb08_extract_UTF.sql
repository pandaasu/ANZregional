--
-- ICS_LADPDB08_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ICS_LADPDB08_EXTRACT as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ICS_LADPDB08_EXTRACT 
  Owner   : ics_app 

  Description 
  ----------- 
  Plant Reference Data for Plant databases 

  1. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *PCH = Pak Chong Thailand
      - *MCH = HUA Plant DB (China)

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 
  2008/07   Trevor Keon    Changed package to do full refreshes only
  2010/06   Ben Halicki    Modified for use with Atlas Thailand implementation
  2010/10   Ben Halicki    Updated to remove hard coded plants and move to configuration
                            via data store configuration
  2011/08   Vivian Huang   Modified for outbound interface trigger
                            
*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end ICS_LADPDB08_EXTRACT;
/


--
-- ICS_LADPDB08_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ICS_LADPDB08_EXTRACT as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
--  function execute_extract return boolean;
  function execute_extract(par_site in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
  var_plant_code bds_refrnc_plant.plant_code%type;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB08';
  
  /*-*/
  /* Private declarations 
  /*-*/
  type rcd_definition is record(value varchar2(4000 char));
  type typ_definition is table of rcd_definition index by binary_integer;
     
  tbl_definition typ_definition;
  
  /***********************************************/
  /* This procedure performs the execute routine */
  /***********************************************/
  procedure execute(par_site in varchar2 default '*ALL') is
    
    /*-*/
    /* Local variables 
    /*-*/
    var_exception varchar2(4000);
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

    var_site := upper(nvl(trim(par_site), '*ALL'));

    open csr_intfc;
    loop
    
        fetch csr_intfc into rcd_intfc;
        exit when csr_intfc%notfound;
       
        tbl_definition.delete;
        
        var_intfc := con_intfc || rcd_intfc.intfc_extn; 
       
        var_start := execute_extract(rcd_intfc.site);      

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
    raise_application_error(-20000, 'ICS_LADPDB08_EXTRACT - ' || 'plant_code: ' || var_plant_code || ' - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
  
--  function execute_extract return boolean is
  function execute_extract(par_site in varchar2) return boolean is

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
      where t01.plant_code  in
      (
          select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_PLANTS'))
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
      
      var_plant_code := rcd_refrnc_plant.plant_code;
              
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

end ICS_LADPDB08_EXTRACT;
/


--
-- ICS_LADPDB08_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB08_EXTRACT FOR ICS_APP.ICS_LADPDB08_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB08_EXTRACT TO APPSUPPORT;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB08_EXTRACT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB08_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB08_EXTRACT TO LICS_APP;

