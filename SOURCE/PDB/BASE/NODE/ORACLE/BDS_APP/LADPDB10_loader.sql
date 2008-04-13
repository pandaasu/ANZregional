/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : plant_cust_sales_area_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound customer sales area loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  14-Mar-2008  Trevor Keon      Created 
*******************************************************************************/

/* Using bds_cust_sales_area_ics table for SNACK testing only.  Replace for other sites */ 

create or replace package bds_app.plant_cust_sales_area_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end plant_cust_sales_area_loader; 
/

create or replace package body bds_app.plant_cust_sales_area_loader as

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
  
  rcd_hdr bds_cust_sales_area_ics%rowtype;

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
    lics_inbound_utility.set_definition('HDR','SALES_ORG_CODE', 5);
    lics_inbound_utility.set_definition('HDR','DISTBN_CHNL_CODE', 5);
    lics_inbound_utility.set_definition('HDR','DIVISION_CODE', 5);
    lics_inbound_utility.set_definition('HDR','AUTH_GROUP_CODE', 4);
    lics_inbound_utility.set_definition('HDR','DELETION_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','STATISTICS_GROUP', 1);
    lics_inbound_utility.set_definition('HDR','ORDER_BLOCK_FLAG', 2);
    lics_inbound_utility.set_definition('HDR','PRICING_PROCEDURE', 1);
    lics_inbound_utility.set_definition('HDR','GROUP_CODE', 2);
    lics_inbound_utility.set_definition('HDR','SALES_DISTRICT', 6);
    lics_inbound_utility.set_definition('HDR','PRICE_GROUP', 2);
    lics_inbound_utility.set_definition('HDR','PRICE_LIST_TYPE', 2);
    lics_inbound_utility.set_definition('HDR','ORDER_PROBABILITY', 38);
    lics_inbound_utility.set_definition('HDR','INTER_COMPANY_TERMS_01', 3);
    lics_inbound_utility.set_definition('HDR','INTER_COMPANY_TERMS_02', 28);
    lics_inbound_utility.set_definition('HDR','DELIVERY_BLOCK_FLAG', 2);
    lics_inbound_utility.set_definition('HDR','ORDER_COMPLETE_DELIVERY_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','PARTIAL_ITEM_DELIVERY_MAX', 38);
    lics_inbound_utility.set_definition('HDR','PARTIAL_ITEM_DELIVERY_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','ORDER_COMBINATION_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','SPLIT_BATCH_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','DELIVERY_PRIORITY', 38);
    lics_inbound_utility.set_definition('HDR','SHIPPER_ACCOUNT_NUMBER', 12);
    lics_inbound_utility.set_definition('HDR','SHIP_CONDITIONS', 2);
    lics_inbound_utility.set_definition('HDR','BILLING_BLOCK_FLAG', 2);
    lics_inbound_utility.set_definition('HDR','MANUAL_INVOICE_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','INVOICE_DATES', 2);
    lics_inbound_utility.set_definition('HDR','INVOICE_LIST_SCHEDULE', 2);
    lics_inbound_utility.set_definition('HDR','CURRENCY_CODE', 5);
    lics_inbound_utility.set_definition('HDR','ACCOUNT_ASSIGN_GROUP', 2);
    lics_inbound_utility.set_definition('HDR','PAYMENT_TERMS_KEY', 4);
    lics_inbound_utility.set_definition('HDR','DELIVERY_PLANT_CODE', 4);
    lics_inbound_utility.set_definition('HDR','SALES_GROUP_CODE', 3);
    lics_inbound_utility.set_definition('HDR','SALES_OFFICE_CODE', 4);
    lics_inbound_utility.set_definition('HDR','ITEM_PROPOSAL', 10);
    lics_inbound_utility.set_definition('HDR','INVOICE_COMBINATION', 3);
    lics_inbound_utility.set_definition('HDR','PRICE_BAND_EXPECTED', 3);
    lics_inbound_utility.set_definition('HDR','ACCEPT_INT_PALLET', 3);
    lics_inbound_utility.set_definition('HDR','PRICE_BAND_GUARANTEED', 3);
    lics_inbound_utility.set_definition('HDR','BACK_ORDER_FLAG', 3);
    lics_inbound_utility.set_definition('HDR','REBATE_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','EXCHANGE_RATE_TYPE', 4);
    lics_inbound_utility.set_definition('HDR','PRICE_DETERMINATION_ID', 1);
    lics_inbound_utility.set_definition('HDR','ABC_CLASSIFICATION', 2);
    lics_inbound_utility.set_definition('HDR','PAYMENT_GUARANTEE_PROC', 4);
    lics_inbound_utility.set_definition('HDR','CREDIT_CONTROL_AREA', 4);
    lics_inbound_utility.set_definition('HDR','SALES_BLOCK_FLAG', 2);
    lics_inbound_utility.set_definition('HDR','ROUNDING_OFF', 1);
    lics_inbound_utility.set_definition('HDR','AGENCY_BUSINESS_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','UOM_GROUP', 4);
    lics_inbound_utility.set_definition('HDR','OVER_DELIVERY_TOLERANCE', 4);
    lics_inbound_utility.set_definition('HDR','UNDER_DELIVERY_TOLERANCE', 4);
    lics_inbound_utility.set_definition('HDR','UNLIMITED_OVER_DELIVERY', 1);
    lics_inbound_utility.set_definition('HDR','PRODUCT_PROPOSAL_PROC', 2);
    lics_inbound_utility.set_definition('HDR','POD_PROCESSING', 1);
    lics_inbound_utility.set_definition('HDR','POD_CONFIRM_TIMEFRAME', 11);
    lics_inbound_utility.set_definition('HDR','PO_INDEX_COMPILATION', 1);
    lics_inbound_utility.set_definition('HDR','BATCH_SEARCH_STRATEGY', 38);
    lics_inbound_utility.set_definition('HDR','VMI_INPUT_METHOD', 38);
    lics_inbound_utility.set_definition('HDR','CURRENT_PLANNING_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','FUTURE_PLANNING_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARKET_ACCOUNT_FLAG', 1);
      
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
    rcd_hdr.sales_org_code := lics_inbound_utility.get_variable('SALES_ORG_CODE');
    rcd_hdr.distbn_chnl_code := lics_inbound_utility.get_variable('DISTBN_CHNL_CODE');
    rcd_hdr.division_code := lics_inbound_utility.get_variable('DIVISION_CODE');
    rcd_hdr.auth_group_code := lics_inbound_utility.get_variable('AUTH_GROUP_CODE');
    rcd_hdr.deletion_flag := lics_inbound_utility.get_variable('DELETION_FLAG');
    rcd_hdr.statistics_group := lics_inbound_utility.get_variable('STATISTICS_GROUP');
    rcd_hdr.order_block_flag := lics_inbound_utility.get_variable('ORDER_BLOCK_FLAG');
    rcd_hdr.pricing_procedure := lics_inbound_utility.get_variable('PRICING_PROCEDURE');
    rcd_hdr.group_code := lics_inbound_utility.get_variable('GROUP_CODE');
    rcd_hdr.sales_district := lics_inbound_utility.get_variable('SALES_DISTRICT');
    rcd_hdr.price_group := lics_inbound_utility.get_variable('PRICE_GROUP');
    rcd_hdr.price_list_type := lics_inbound_utility.get_variable('PRICE_LIST_TYPE');
    rcd_hdr.order_probability := lics_inbound_utility.get_number('ORDER_PROBABILITY',null);
    rcd_hdr.inter_company_terms_01 := lics_inbound_utility.get_variable('INTER_COMPANY_TERMS_01');
    rcd_hdr.inter_company_terms_02 := lics_inbound_utility.get_variable('INTER_COMPANY_TERMS_02');
    rcd_hdr.delivery_block_flag := lics_inbound_utility.get_variable('DELIVERY_BLOCK_FLAG');
    rcd_hdr.order_complete_delivery_flag := lics_inbound_utility.get_variable('ORDER_COMPLETE_DELIVERY_FLAG');
    rcd_hdr.partial_item_delivery_max := lics_inbound_utility.get_number('PARTIAL_ITEM_DELIVERY_MAX',null);
    rcd_hdr.partial_item_delivery_flag := lics_inbound_utility.get_variable('PARTIAL_ITEM_DELIVERY_FLAG');
    rcd_hdr.order_combination_flag := lics_inbound_utility.get_variable('ORDER_COMBINATION_FLAG');
    rcd_hdr.split_batch_flag := lics_inbound_utility.get_variable('SPLIT_BATCH_FLAG');
    rcd_hdr.delivery_priority := lics_inbound_utility.get_number('DELIVERY_PRIORITY',null);
    rcd_hdr.shipper_account_number := lics_inbound_utility.get_variable('SHIPPER_ACCOUNT_NUMBER');
    rcd_hdr.ship_conditions := lics_inbound_utility.get_variable('SHIP_CONDITIONS');
    rcd_hdr.billing_block_flag := lics_inbound_utility.get_variable('BILLING_BLOCK_FLAG');
    rcd_hdr.manual_invoice_flag := lics_inbound_utility.get_variable('MANUAL_INVOICE_FLAG');
    rcd_hdr.invoice_dates := lics_inbound_utility.get_variable('INVOICE_DATES');
    rcd_hdr.invoice_list_schedule := lics_inbound_utility.get_variable('INVOICE_LIST_SCHEDULE');
    rcd_hdr.currency_code := lics_inbound_utility.get_variable('CURRENCY_CODE');
    rcd_hdr.account_assign_group := lics_inbound_utility.get_variable('ACCOUNT_ASSIGN_GROUP');
    rcd_hdr.payment_terms_key := lics_inbound_utility.get_variable('PAYMENT_TERMS_KEY');
    rcd_hdr.delivery_plant_code := lics_inbound_utility.get_variable('DELIVERY_PLANT_CODE');
    rcd_hdr.sales_group_code := lics_inbound_utility.get_variable('SALES_GROUP_CODE');
    rcd_hdr.sales_office_code := lics_inbound_utility.get_variable('SALES_OFFICE_CODE');
    rcd_hdr.item_proposal := lics_inbound_utility.get_variable('ITEM_PROPOSAL');
    rcd_hdr.invoice_combination := lics_inbound_utility.get_variable('INVOICE_COMBINATION');
    rcd_hdr.price_band_expected := lics_inbound_utility.get_variable('PRICE_BAND_EXPECTED');
    rcd_hdr.accept_int_pallet := lics_inbound_utility.get_variable('ACCEPT_INT_PALLET');
    rcd_hdr.price_band_guaranteed := lics_inbound_utility.get_variable('PRICE_BAND_GUARANTEED');
    rcd_hdr.back_order_flag := lics_inbound_utility.get_variable('BACK_ORDER_FLAG');
    rcd_hdr.rebate_flag := lics_inbound_utility.get_variable('REBATE_FLAG');
    rcd_hdr.exchange_rate_type := lics_inbound_utility.get_variable('EXCHANGE_RATE_TYPE');
    rcd_hdr.price_determination_id := lics_inbound_utility.get_variable('PRICE_DETERMINATION_ID');
    rcd_hdr.abc_classification := lics_inbound_utility.get_variable('ABC_CLASSIFICATION');
    rcd_hdr.payment_guarantee_proc := lics_inbound_utility.get_variable('PAYMENT_GUARANTEE_PROC');
    rcd_hdr.credit_control_area := lics_inbound_utility.get_variable('CREDIT_CONTROL_AREA');
    rcd_hdr.sales_block_flag := lics_inbound_utility.get_variable('SALES_BLOCK_FLAG');
    rcd_hdr.rounding_off := lics_inbound_utility.get_variable('ROUNDING_OFF');
    rcd_hdr.agency_business_flag := lics_inbound_utility.get_variable('AGENCY_BUSINESS_FLAG');
    rcd_hdr.uom_group := lics_inbound_utility.get_variable('UOM_GROUP');
    rcd_hdr.over_delivery_tolerance := lics_inbound_utility.get_variable('OVER_DELIVERY_TOLERANCE');
    rcd_hdr.under_delivery_tolerance := lics_inbound_utility.get_variable('UNDER_DELIVERY_TOLERANCE');
    rcd_hdr.unlimited_over_delivery := lics_inbound_utility.get_variable('UNLIMITED_OVER_DELIVERY');
    rcd_hdr.product_proposal_proc := lics_inbound_utility.get_variable('PRODUCT_PROPOSAL_PROC');
    rcd_hdr.pod_processing := lics_inbound_utility.get_variable('POD_PROCESSING');
    rcd_hdr.pod_confirm_timeframe := lics_inbound_utility.get_variable('POD_CONFIRM_TIMEFRAME');
    rcd_hdr.po_index_compilation := lics_inbound_utility.get_variable('PO_INDEX_COMPILATION');
    rcd_hdr.batch_search_strategy := lics_inbound_utility.get_number('BATCH_SEARCH_STRATEGY',null);
    rcd_hdr.vmi_input_method := lics_inbound_utility.get_number('VMI_INPUT_METHOD',null);
    rcd_hdr.current_planning_flag := lics_inbound_utility.get_variable('CURRENT_PLANNING_FLAG');
    rcd_hdr.future_planning_flag := lics_inbound_utility.get_variable('FUTURE_PLANNING_FLAG');
    rcd_hdr.market_account_flag := lics_inbound_utility.get_variable('MARKET_ACCOUNT_FLAG');
    
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
    
    if ( rcd_hdr.sales_org_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.SALES_ORG_CODE');
      var_trn_error := true;
    end if;
          
    if ( rcd_hdr.distbn_chnl_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.DISTBN_CHNL_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.division_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.DIVISION_CODE');
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
    update bds_cust_sales_area_ics
    set customer_code = rcd_hdr.customer_code, 
      sales_org_code = rcd_hdr.sales_org_code, 
      distbn_chnl_code = rcd_hdr.distbn_chnl_code, 
      division_code = rcd_hdr.division_code,
      auth_group_code = rcd_hdr.auth_group_code, 
      deletion_flag = rcd_hdr.deletion_flag, 
      statistics_group = rcd_hdr.statistics_group, 
      order_block_flag = rcd_hdr.order_block_flag,
      pricing_procedure = rcd_hdr.pricing_procedure, 
      group_code = rcd_hdr.group_code, 
      sales_district = rcd_hdr.sales_district, 
      price_group = rcd_hdr.price_group,
      price_list_type = rcd_hdr.price_list_type, 
      order_probability = rcd_hdr.order_probability, 
      inter_company_terms_01 = rcd_hdr.inter_company_terms_01,
      inter_company_terms_02 = rcd_hdr.inter_company_terms_02, 
      delivery_block_flag = rcd_hdr.delivery_block_flag,
      order_complete_delivery_flag = rcd_hdr.order_complete_delivery_flag, 
      partial_item_delivery_max = rcd_hdr.partial_item_delivery_max,
      partial_item_delivery_flag = rcd_hdr.partial_item_delivery_flag, 
      order_combination_flag = rcd_hdr.order_combination_flag, 
      split_batch_flag = rcd_hdr.split_batch_flag,
      delivery_priority = rcd_hdr.delivery_priority, 
      shipper_account_number = rcd_hdr.shipper_account_number, 
      ship_conditions = rcd_hdr.ship_conditions,
      billing_block_flag = rcd_hdr.billing_block_flag, 
      manual_invoice_flag = rcd_hdr.manual_invoice_flag, 
      invoice_dates = rcd_hdr.invoice_dates,
      invoice_list_schedule = rcd_hdr.invoice_list_schedule, 
      currency_code = rcd_hdr.currency_code, 
      account_assign_group = rcd_hdr.account_assign_group,
      payment_terms_key = rcd_hdr.payment_terms_key, 
      delivery_plant_code = rcd_hdr.delivery_plant_code, 
      sales_group_code = rcd_hdr.sales_group_code,
      sales_office_code = rcd_hdr.sales_office_code, 
      item_proposal = rcd_hdr.item_proposal, 
      invoice_combination = rcd_hdr.invoice_combination,
      price_band_expected = rcd_hdr.price_band_expected, 
      accept_int_pallet = rcd_hdr.accept_int_pallet, 
      price_band_guaranteed = rcd_hdr.price_band_guaranteed,
      back_order_flag = rcd_hdr.back_order_flag, 
      rebate_flag = rcd_hdr.rebate_flag, 
      exchange_rate_type = rcd_hdr.exchange_rate_type,
      price_determination_id = rcd_hdr.price_determination_id, 
      abc_classification = rcd_hdr.abc_classification, 
      payment_guarantee_proc = rcd_hdr.payment_guarantee_proc,
      credit_control_area = rcd_hdr.credit_control_area, 
      sales_block_flag = rcd_hdr.sales_block_flag, 
      rounding_off = rcd_hdr.rounding_off,
      agency_business_flag = rcd_hdr.agency_business_flag, 
      uom_group = rcd_hdr.uom_group, 
      over_delivery_tolerance = rcd_hdr.over_delivery_tolerance,
      under_delivery_tolerance = rcd_hdr.under_delivery_tolerance, 
      unlimited_over_delivery = rcd_hdr.unlimited_over_delivery,
      product_proposal_proc = rcd_hdr.product_proposal_proc, 
      pod_processing = rcd_hdr.pod_processing, 
      pod_confirm_timeframe = rcd_hdr.pod_confirm_timeframe,
      po_index_compilation = rcd_hdr.po_index_compilation, 
      batch_search_strategy = rcd_hdr.batch_search_strategy, 
      vmi_input_method = rcd_hdr.vmi_input_method,
      current_planning_flag = rcd_hdr.current_planning_flag, 
      future_planning_flag = rcd_hdr.future_planning_flag, 
      market_account_flag = rcd_hdr.market_account_flag
    where customer_code = rcd_hdr.customer_code 
      and sales_org_code = rcd_hdr.sales_org_code
      and distbn_chnl_code = rcd_hdr.distbn_chnl_code 
      and division_code = rcd_hdr.division_code;
    
    if ( sql%notfound ) then    
      insert into bds_cust_sales_area_ics
      (
        customer_code, 
        sales_org_code, 
        distbn_chnl_code, 
        division_code,
        auth_group_code, 
        deletion_flag, 
        statistics_group, 
        order_block_flag,
        pricing_procedure, 
        group_code, 
        sales_district, 
        price_group,
        price_list_type, 
        order_probability, 
        inter_company_terms_01,
        inter_company_terms_02, 
        delivery_block_flag,
        order_complete_delivery_flag, 
        partial_item_delivery_max,
        partial_item_delivery_flag, 
        order_combination_flag, 
        split_batch_flag,
        delivery_priority, 
        shipper_account_number, 
        ship_conditions,
        billing_block_flag, 
        manual_invoice_flag, 
        invoice_dates,
        invoice_list_schedule, 
        currency_code, 
        account_assign_group,
        payment_terms_key, 
        delivery_plant_code, 
        sales_group_code,
        sales_office_code, 
        item_proposal, 
        invoice_combination,
        price_band_expected, 
        accept_int_pallet, 
        price_band_guaranteed,
        back_order_flag, 
        rebate_flag, 
        exchange_rate_type,
        price_determination_id, 
        abc_classification, 
        payment_guarantee_proc,
        credit_control_area, 
        sales_block_flag, 
        rounding_off,
        agency_business_flag, 
        uom_group, 
        over_delivery_tolerance,
        under_delivery_tolerance, 
        unlimited_over_delivery,
        product_proposal_proc, 
        pod_processing, 
        pod_confirm_timeframe,
        po_index_compilation, 
        batch_search_strategy, 
        vmi_input_method,
        current_planning_flag, 
        future_planning_flag, 
        market_account_flag
      )
      values 
      (
        rcd_hdr.customer_code, 
        rcd_hdr.sales_org_code, 
        rcd_hdr.distbn_chnl_code, 
        rcd_hdr.division_code,
        rcd_hdr.auth_group_code, 
        rcd_hdr.deletion_flag, 
        rcd_hdr.statistics_group, 
        rcd_hdr.order_block_flag,
        rcd_hdr.pricing_procedure, 
        rcd_hdr.group_code, 
        rcd_hdr.sales_district, 
        rcd_hdr.price_group,
        rcd_hdr.price_list_type, 
        rcd_hdr.order_probability, 
        rcd_hdr.inter_company_terms_01,
        rcd_hdr.inter_company_terms_02, 
        rcd_hdr.delivery_block_flag,
        rcd_hdr.order_complete_delivery_flag, 
        rcd_hdr.partial_item_delivery_max,
        rcd_hdr.partial_item_delivery_flag, 
        rcd_hdr.order_combination_flag, 
        rcd_hdr.split_batch_flag,
        rcd_hdr.delivery_priority, 
        rcd_hdr.shipper_account_number, 
        rcd_hdr.ship_conditions,
        rcd_hdr.billing_block_flag, 
        rcd_hdr.manual_invoice_flag, 
        rcd_hdr.invoice_dates,
        rcd_hdr.invoice_list_schedule, 
        rcd_hdr.currency_code, 
        rcd_hdr.account_assign_group,
        rcd_hdr.payment_terms_key, 
        rcd_hdr.delivery_plant_code, 
        rcd_hdr.sales_group_code,
        rcd_hdr.sales_office_code, 
        rcd_hdr.item_proposal, 
        rcd_hdr.invoice_combination,
        rcd_hdr.price_band_expected, 
        rcd_hdr.accept_int_pallet, 
        rcd_hdr.price_band_guaranteed,
        rcd_hdr.back_order_flag, 
        rcd_hdr.rebate_flag, 
        rcd_hdr.exchange_rate_type,
        rcd_hdr.price_determination_id, 
        rcd_hdr.abc_classification, 
        rcd_hdr.payment_guarantee_proc,
        rcd_hdr.credit_control_area, 
        rcd_hdr.sales_block_flag, 
        rcd_hdr.rounding_off,
        rcd_hdr.agency_business_flag, 
        rcd_hdr.uom_group, 
        rcd_hdr.over_delivery_tolerance,
        rcd_hdr.under_delivery_tolerance, 
        rcd_hdr.unlimited_over_delivery,
        rcd_hdr.product_proposal_proc, 
        rcd_hdr.pod_processing, 
        rcd_hdr.pod_confirm_timeframe,
        rcd_hdr.po_index_compilation, 
        rcd_hdr.batch_search_strategy, 
        rcd_hdr.vmi_input_method,
        rcd_hdr.current_planning_flag, 
        rcd_hdr.future_planning_flag, 
        rcd_hdr.market_account_flag
      );
    end if;
    
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
  
end plant_cust_sales_area_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.plant_cust_sales_area_loader to appsupport;
grant execute on bds_app.plant_cust_sales_area_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_cust_sales_area_loader for bds_app.plant_cust_sales_area_loader;