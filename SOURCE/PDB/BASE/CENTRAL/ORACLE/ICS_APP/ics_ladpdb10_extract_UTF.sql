--
-- ICS_LADPDB10_EXTRACT  (Package) 
--
CREATE OR REPLACE PACKAGE ICS_APP.ics_ladpdb10_extract as
/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : ics_ladpdb10_extract 
  Owner   : ics_app 

  Description 
  ----------- 
  Customer Sales Area Extract for Plant databases 

  EXECUTE - 
    Send Customer Sales Area data since last successful send 
    
  EXECUTE - 
    Send Customer Sales Area data based on the specified action.     

  1. PAR_ACTION (MANDATORY) 

    *ALL - send all address data  
    *CUSTOMER - send sales area data matching a given customer code 
    *HISTORY - all modified since specified date
    
  2. PAR_DATA (MANDATORY) 
    
    Data related to the action specified:
      - *ALL = null 
      - *CUSTOMER = customer code 
      - *HISTORY = number of days

  3. PAR_SITE (OPTIONAL) 
  
    Specify the site for the data to be sent to.
      - *ALL = All sites (DEFAULT) 
      - *MCA = Ballarat 
      - *SCO = Scoresby 
      - *WOD = Wodonga 
      - *MFA = Wyong 
      - *WGI = Wanganui 
      - *MCH = HUA Plant DB (China)

  YYYY/MM   Author         Description 
  -------   ------         ----------- 
  2008/03   Trevor Keon    Created 
  2010/08   Ben Halicki    Modified for Atlas Thailand
                           Removed hard coded plants, moved to configuration
  2011/08   Vivian Huang   Modified for outbound interface trigger

*******************************************************************************/

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end ics_ladpdb10_extract;
/


--
-- ICS_LADPDB10_EXTRACT  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY ICS_APP.ics_ladpdb10_extract as

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
  var_interface varchar2(32 char);
  var_lastrun_date date;
  var_start_date date;
  var_update_lastrun boolean := false;
    
  var_customer_code bds_addr_customer.customer_code%type;

  /*-*/  
  /* global constants
  /*-*/  
  con_intfc varchar2(20) := 'LADPDB10';
  
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
    
    tbl_definition.delete;
    
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
    raise_application_error(-20000, 'ics_ladpdb10_extract - ' || 'customer_code: ' || var_customer_code || ' - ' || var_exception);

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
    cursor csr_bds_cust_sales_area is
      select t01.customer_code as customer_code, 
        t02.sales_org_code as sales_org_code, 
        t02.distbn_chnl_code as distbn_chnl_code, 
        t02.division_code as division_code,
        t02.auth_group_code as auth_group_code, 
        t01.deletion_flag as deletion_flag, 
        t02.statistics_group as statistics_group, 
        t02.order_block_flag as order_block_flag,
        t02.pricing_procedure as pricing_procedure, 
        t02.group_code as group_code, 
        t02.sales_district as sales_district, 
        t02.price_group as price_group,
        t02.price_list_type as price_list_type, 
        t02.order_probability as order_probability, 
        t02.inter_company_terms_01 as inter_company_terms_01,
        t02.inter_company_terms_02 as inter_company_terms_02, 
        t02.delivery_block_flag as delivery_block_flag,
        t02.order_complete_delivery_flag as order_complete_delivery_flag, 
        t02.partial_item_delivery_max as partial_item_delivery_max,
        t02.partial_item_delivery_flag as partial_item_delivery_flag, 
        t02.order_combination_flag as order_combination_flag, 
        t02.split_batch_flag as split_batch_flag,
        t02.delivery_priority as delivery_priority, 
        t02.shipper_account_number as shipper_account_number, 
        t02.ship_conditions as ship_conditions,
        t02.billing_block_flag as billing_block_flag, 
        t02.manual_invoice_flag as manual_invoice_flag, 
        t02.invoice_dates as invoice_dates,
        t02.invoice_list_schedule as invoice_list_schedule, 
        t02.currency_code as currency_code, 
        t02.account_assign_group as account_assign_group,
        t02.payment_terms_key as payment_terms_key, 
        t02.delivery_plant_code as delivery_plant_code, 
        t02.sales_group_code as sales_group_code,
        t02.sales_office_code as sales_office_code, 
        t02.item_proposal as item_proposal, 
        t02.invoice_combination as invoice_combination,
        t02.price_band_expected as price_band_expected, 
        t02.accept_int_pallet as accept_int_pallet, 
        t02.price_band_guaranteed as price_band_guaranteed,
        t02.back_order_flag as back_order_flag, 
        t02.rebate_flag as rebate_flag, 
        t02.exchange_rate_type as exchange_rate_type,
        t02.price_determination_id as price_determination_id, 
        t02.abc_classification as abc_classification, 
        t02.payment_guarantee_proc as payment_guarantee_proc,
        t02.credit_control_area as credit_control_area, 
        t02.sales_block_flag as sales_block_flag, 
        t02.rounding_off as rounding_off,
        t02.agency_business_flag as agency_business_flag, 
        t02.uom_group as uom_group, 
        t02.over_delivery_tolerance as over_delivery_tolerance,
        t02.under_delivery_tolerance as under_delivery_tolerance, 
        t02.unlimited_over_delivery as unlimited_over_delivery,
        t02.product_proposal_proc as product_proposal_proc, 
        t02.pod_processing as pod_processing, 
        t02.pod_confirm_timeframe as pod_confirm_timeframe,
        t02.po_index_compilation as po_index_compilation, 
        t02.batch_search_strategy as batch_search_strategy, 
        t02.vmi_input_method as vmi_input_method,
        t02.current_planning_flag as current_planning_flag, 
        t02.future_planning_flag as future_planning_flag, 
        t02.market_account_flag as market_account_flag,
        t02.cust_pack_instr_validation as cust_pack_instr_validation,
        t02.cust_pallet_max_height as cust_pallet_max_height,
        t02.cust_pallet_max_height_uom as cust_pallet_max_height_uom,
        t02.layer_homogeneous_pick_pallet as layer_homogeneous_pick_pallet,
        t02.case_homogeneous_pick_pallet as case_homogeneous_pick_pallet,
        t02.transport_modules_flag as transport_modules_flag,
        t02.pick_pallet_pack_material as pick_pallet_pack_material,
        t02.pick_pallet_max_height as pick_pallet_max_height,
        t02.pick_pallet_max_height_uom as pick_pallet_max_height_uom 
      from bds_cust_header t01,
        bds_cust_sales_area t02,
        bds_cust_comp t03        
      where t01.customer_code = t02.customer_code
      and t01.customer_code=t03.customer_code
      and t02.sales_org_code in
      (
        select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_SALES_ORGS'))
      )
      and t03.company_code in 
      (
        select dsv_value from table (lics_datastore.retrieve_value('PDB',par_site,'VALID_COMPANIES'))
      )
      and 
      (
        (par_action = '*ALL' and (var_lastrun_date is null or t01.bds_lads_date >= var_lastrun_date))
        or (par_action = '*CUSTOMER' and ltrim(t01.customer_code,'0') = ltrim(par_data,'0'))
        or (par_action = '*HISTORY' and trunc(t01.bds_lads_date) >= trunc(sysdate-to_number(par_data)))    
      );
      
    rcd_bds_cust_sales_area csr_bds_cust_sales_area%rowtype;

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
    open csr_bds_cust_sales_area;
    loop
    
      fetch csr_bds_cust_sales_area into rcd_bds_cust_sales_area;
      exit when csr_bds_cust_sales_area%notfound;

      var_index := tbl_definition.count + 1;
      var_result := true;
      
      /*-*/
      /* Store current customer code for error message purposes 
      /*-*/
      var_customer_code := rcd_bds_cust_sales_area.customer_code;
              
      tbl_definition(var_index).value := 'HDR'
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.customer_code),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.sales_org_code),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.distbn_chnl_code),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.division_code),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.auth_group_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.deletion_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.statistics_group),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.order_block_flag),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.pricing_procedure),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.group_code),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.sales_district),' '),6,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.price_group),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.price_list_type),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.order_probability),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.inter_company_terms_01),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.inter_company_terms_02),' '),28,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.delivery_block_flag),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.order_complete_delivery_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.partial_item_delivery_max),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.partial_item_delivery_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.order_combination_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.split_batch_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.delivery_priority),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.shipper_account_number),' '),12,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.ship_conditions),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.billing_block_flag),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.manual_invoice_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.invoice_dates),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.invoice_list_schedule),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.currency_code),' '),5,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.account_assign_group),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.payment_terms_key),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.delivery_plant_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.sales_group_code),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.sales_office_code),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.item_proposal),' '),10,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.invoice_combination),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.price_band_expected),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.accept_int_pallet),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.price_band_guaranteed),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.back_order_flag),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.rebate_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.exchange_rate_type),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.price_determination_id),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.abc_classification),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.payment_guarantee_proc),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.credit_control_area),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.sales_block_flag),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.rounding_off),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.agency_business_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.uom_group),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.over_delivery_tolerance),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.under_delivery_tolerance),' '),4,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.unlimited_over_delivery),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.product_proposal_proc),' '),2,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.pod_processing),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.pod_confirm_timeframe),' '),11,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.po_index_compilation),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.batch_search_strategy),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.vmi_input_method),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.current_planning_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.future_planning_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.market_account_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.cust_pack_instr_validation),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.cust_pallet_max_height),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.cust_pallet_max_height_uom),' '),3,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.layer_homogeneous_pick_pallet),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.case_homogeneous_pick_pallet),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.transport_modules_flag),' '),1,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.pick_pallet_pack_material),' '),18,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.pick_pallet_max_height),'0'),38,' ')
        || rpad(nvl(to_char(rcd_bds_cust_sales_area.pick_pallet_max_height_uom),' '),3,' ');

    end loop;
    close csr_bds_cust_sales_area;

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

end ics_ladpdb10_extract;
/


--
-- ICS_LADPDB10_EXTRACT  (Synonym) 
--
CREATE PUBLIC SYNONYM ICS_LADPDB10_EXTRACT FOR ICS_APP.ICS_LADPDB10_EXTRACT;


GRANT EXECUTE ON ICS_APP.ICS_LADPDB10_EXTRACT TO LADS_APP;

GRANT EXECUTE ON ICS_APP.ICS_LADPDB10_EXTRACT TO LICS_APP;

