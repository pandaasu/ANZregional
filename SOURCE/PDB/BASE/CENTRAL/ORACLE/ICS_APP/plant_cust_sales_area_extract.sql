/******************************************************************************/ 
/* Package Definition                                                         */ 
/******************************************************************************/ 
/** 
  Package : plant_cust_sales_area_extract 
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

create or replace package ics_app.plant_cust_sales_area_extract as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure execute;
  procedure execute(par_action in varchar2, par_data in varchar2, par_site in varchar2 default '*ALL');

end plant_cust_sales_area_extract;
/

/****************/ 
/* Package Body */ 
/****************/ 
create or replace package body ics_app.plant_cust_sales_area_extract as

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
    var_lastrun_date := lics_last_run_control.get_last_run('LADPDB10');
  
    execute('*ALL',null,'*MCA');
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
        and var_site != '*WGI' ) then
      raise_application_error(-20000, 'Site parameter (' || par_site || ') must be *ALL, *MCA, *SCO, *WOD, *MFA, *WGI or NULL');
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
        execute_send('LADPDB10.1');   
      end if;    
      if ( par_site in ('*ALL','*WGI') ) then
        execute_send('LADPDB10.2');   
      end if;    
      if ( par_site in ('*ALL','*WOD') ) then
        execute_send('LADPDB10.3');   
      end if;    
      if ( par_site in ('*ALL','*BTH') ) then
        execute_send('LADPDB10.4');   
      end if;    
      if ( par_site in ('*ALL','*MCA') ) then
        execute_send('LADPDB10.5');   
      end if;
      if ( par_site in ('*ALL','*SCO') ) then
        execute_send('LADPDB10.6');   
      end if;
    end if; 
    
    if ( var_update_lastrun = true ) then
      lics_last_run_control.set_last_run('LADPDB10',var_start_date);
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
    raise_application_error(-20000, 'plant_cust_sales_area_extract - ' || 'customer_code: ' || var_customer_code || ' - ' || var_exception);

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
    cursor csr_bds_cust_sales_area is
      select t01.customer_code as customer_code, 
        t01.sales_org_code as sales_org_code, 
        t01.distbn_chnl_code as distbn_chnl_code, 
        t01.division_code as division_code,
        t01.auth_group_code as auth_group_code, 
        t01.deletion_flag as deletion_flag, 
        t01.statistics_group as statistics_group, 
        t01.order_block_flag as order_block_flag,
        t01.pricing_procedure as pricing_procedure, 
        t01.group_code as group_code, 
        t01.sales_district as sales_district, 
        t01.price_group as price_group,
        t01.price_list_type as price_list_type, 
        t01.order_probability as order_probability, 
        t01.inter_company_terms_01 as inter_company_terms_01,
        t01.inter_company_terms_02 as inter_company_terms_02, 
        t01.delivery_block_flag as delivery_block_flag,
        t01.order_complete_delivery_flag as order_complete_delivery_flag, 
        t01.partial_item_delivery_max as partial_item_delivery_max,
        t01.partial_item_delivery_flag as partial_item_delivery_flag, 
        t01.order_combination_flag as order_combination_flag, 
        t01.split_batch_flag as split_batch_flag,
        t01.delivery_priority as delivery_priority, 
        t01.shipper_account_number as shipper_account_number, 
        t01.ship_conditions as ship_conditions,
        t01.billing_block_flag as billing_block_flag, 
        t01.manual_invoice_flag as manual_invoice_flag, 
        t01.invoice_dates as invoice_dates,
        t01.invoice_list_schedule as invoice_list_schedule, 
        t01.currency_code as currency_code, 
        t01.account_assign_group as account_assign_group,
        t01.payment_terms_key as payment_terms_key, 
        t01.delivery_plant_code as delivery_plant_code, 
        t01.sales_group_code as sales_group_code,
        t01.sales_office_code as sales_office_code, 
        t01.item_proposal as item_proposal, 
        t01.invoice_combination as invoice_combination,
        t01.price_band_expected as price_band_expected, 
        t01.accept_int_pallet as accept_int_pallet, 
        t01.price_band_guaranteed as price_band_guaranteed,
        t01.back_order_flag as back_order_flag, 
        t01.rebate_flag as rebate_flag, 
        t01.exchange_rate_type as exchange_rate_type,
        t01.price_determination_id as price_determination_id, 
        t01.abc_classification as abc_classification, 
        t01.payment_guarantee_proc as payment_guarantee_proc,
        t01.credit_control_area as credit_control_area, 
        t01.sales_block_flag as sales_block_flag, 
        t01.rounding_off as rounding_off,
        t01.agency_business_flag as agency_business_flag, 
        t01.uom_group as uom_group, 
        t01.over_delivery_tolerance as over_delivery_tolerance,
        t01.under_delivery_tolerance as under_delivery_tolerance, 
        t01.unlimited_over_delivery as unlimited_over_delivery,
        t01.product_proposal_proc as product_proposal_proc, 
        t01.pod_processing as pod_processing, 
        t01.pod_confirm_timeframe as pod_confirm_timeframe,
        t01.po_index_compilation as po_index_compilation, 
        t01.batch_search_strategy as batch_search_strategy, 
        t01.vmi_input_method as vmi_input_method,
        t01.current_planning_flag as current_planning_flag, 
        t01.future_planning_flag as future_planning_flag, 
        t01.market_account_flag as market_account_flag
      from bds_cust_sales_area t01,
        bds_cust_header t02
      where t01.customer_code = t02.customer_code
        and t01.deletion_flag is null
        and 
        (
          (par_action = '*ALL' and (var_lastrun_date is null or t02.bds_lads_date >= var_lastrun_date))
          or (par_action = '*CUSTOMER' and ltrim(t01.customer_code,'0') = ltrim(par_data,'0'))
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
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.customer_code,' ')),10,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.sales_org_code,' ')),5,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.distbn_chnl_code,' ')),5,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.division_code,' ')),5,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.auth_group_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.deletion_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.statistics_group,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.order_block_flag,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.pricing_procedure,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.group_code,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.sales_district,' ')),6,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.price_group,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.price_list_type,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.order_probability,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.inter_company_terms_01,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.inter_company_terms_02,' ')),28,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.delivery_block_flag,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.order_complete_delivery_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.partial_item_delivery_max,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.partial_item_delivery_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.order_combination_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.split_batch_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.delivery_priority,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.shipper_account_number,' ')),12,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.ship_conditions,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.billing_block_flag,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.manual_invoice_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.invoice_dates,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.invoice_list_schedule,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.currency_code,' ')),5,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.account_assign_group,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.payment_terms_key,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.delivery_plant_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.sales_group_code,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.sales_office_code,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.item_proposal,' ')),10,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.invoice_combination,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.price_band_expected,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.accept_int_pallet,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.price_band_guaranteed,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.back_order_flag,' ')),3,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.rebate_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.exchange_rate_type,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.price_determination_id,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.abc_classification,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.payment_guarantee_proc,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.credit_control_area,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.sales_block_flag,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.rounding_off,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.agency_business_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.uom_group,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.over_delivery_tolerance,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.under_delivery_tolerance,' ')),4,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.unlimited_over_delivery,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.product_proposal_proc,' ')),2,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.pod_processing,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.pod_confirm_timeframe,' ')),11,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.po_index_compilation,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.batch_search_strategy,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.vmi_input_method,'0')),38,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.current_planning_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.future_planning_flag,' ')),1,' ')
        || rpad(to_char(nvl(rcd_bds_cust_sales_area.market_account_flag,' ')),1,' ');

    end loop;
    close csr_bds_cust_sales_area;

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

end plant_cust_sales_area_extract;
/

/*-*/
/* Authority 
/*-*/
grant execute on ics_app.plant_cust_sales_area_extract to appsupport;
grant execute on ics_app.plant_cust_sales_area_extract to lads_app;
grant execute on ics_app.plant_cust_sales_area_extract to lics_app;
grant execute on ics_app.plant_cust_sales_area_extract to ics_executor;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_cust_sales_area_extract for ics_app.plant_cust_sales_area_extract;
