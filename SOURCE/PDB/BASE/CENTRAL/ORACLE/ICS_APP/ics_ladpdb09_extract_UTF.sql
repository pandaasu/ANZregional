--
-- ICS_LADPDB09_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ics_ladpdb09_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ics_ladpdb09_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Purchasing Source Reference Data for Plant databases 
      
  EXECUTE - 
    Send purchasing source reference data.  

  1. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui    
      - *PCH = Pak Chong (Thailand)    
      - *MCH = China Plant DB (China)

  YYYY/MM   Author         Version  Description 
  -------   ------         -------  ----------- 
  2008/03   Trevor Keon    1.0      Created 
  2008/07   Trevor Keon    1.1      Changed package to do full refreshes only
  2010/08   Ben Halicki    1.2      Updated to retrieve valid site codes from 
                                        Lics Data Store
  2011/08   Vivian Huang   1.3      Modified for outbound interface trigger

*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute(par_site in varchar2 default '*ALL');

end ics_ladpdb09_extract;
/


--
-- ICS_LADPDB09_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ics_ladpdb09_extract as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  function execute_extract(par_site in varchar2) return boolean;
  procedure execute_send(par_interface in varchar2, par_trigger in varchar2);
  
  /*-*/
  /* Global variables 
  /*-*/
  var_interface varchar2(32 char);  
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB09';
  
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
          
    commit;
    
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
    raise_application_error(-20000, 'ics_ladpdb09_extract - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
  end execute;
   
  function execute_extract(par_site in varchar2) return boolean is

    /*-*/
    /* Local variables 
    /*-*/
    var_index number(8,0);
    var_result boolean;
    
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_refrnc_purchasing_src is
      select t01.sap_material_code as sap_material_code, 
        t01.plant_code as plant_code, 
        t01.record_no as record_no, 
        to_char(t01.creatn_date, 'yyyymmddhh24miss') as creatn_date, 
        t01.creatn_user as creatn_user,
        to_char(t01.src_list_valid_from, 'yyyymmddhh24miss') as src_list_valid_from, 
        to_char(t01.src_list_valid_to, 'yyyymmddhh24miss') as src_list_valid_to, 
        t01.vendor_code as vendor_code,
        t01.fixed_vendor_indctr as fixed_vendor_indctr, 
        t01.agreement_no as agreement_no, 
        t01.agreement_item as agreement_item,
        t01.fixed_purchase_agreement_item as fixed_purchase_agreement_item, 
        t01.plant_procured_from as plant_procured_from,
        t01.sto_fixed_issuing_plant as sto_fixed_issuing_plant, 
        t01.manufctr_part_refrnc_material as manufctr_part_refrnc_material,
        t01.blocked_supply_src_flag as blocked_supply_src_flag, 
        t01.purchasing_organisation as purchasing_organisation,
        t01.purchasing_document_ctgry as purchasing_document_ctgry,
        t01.src_list_ctgry as src_list_ctgry, 
        t01.src_list_planning_usage as src_list_planning_usage,
        t01.order_unit as order_unit, 
        t01.logical_system as logical_system, 
        t01.special_stock_indctr as special_stock_indctr
      from bds_refrnc_purchasing_src t01
      where t01.plant_code in 
      (
        select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_PLANTS'))
      )
      order by t01.sap_material_code;
        
    rcd_refrnc_purchasing_src csr_refrnc_purchasing_src%rowtype;

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
    open csr_refrnc_purchasing_src;
    loop
        
      fetch csr_refrnc_purchasing_src into rcd_refrnc_purchasing_src;
      exit when csr_refrnc_purchasing_src%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
                   
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.sap_material_code),' '),18,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.plant_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.record_no),' '),5,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.creatn_date),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.creatn_user),' '),12,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_valid_from),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_valid_to),' '),14,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.vendor_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.fixed_vendor_indctr),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.agreement_no),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.agreement_item),' '),5,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.fixed_purchase_agreement_item),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.plant_procured_from),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.sto_fixed_issuing_plant),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.manufctr_part_refrnc_material),' '),18,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.blocked_supply_src_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.purchasing_organisation),' '),4,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.purchasing_document_ctgry),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_ctgry),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.src_list_planning_usage),' '),1,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.order_unit),' '),3,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.logical_system),' '),10,' ')
        || rpad(nvl(to_char(rcd_refrnc_purchasing_src.special_stock_indctr),' '),1,' ');

    end loop;
    close csr_refrnc_purchasing_src;

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

end ics_ladpdb09_extract;
/


--
-- ICS_LADPDB09_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB09_EXTRACT FOR ICS_APP.ICS_LADPDB09_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB09_EXTRACT TO ICS_EXECUTOR;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB09_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB09_EXTRACT TO LICS_APP;

