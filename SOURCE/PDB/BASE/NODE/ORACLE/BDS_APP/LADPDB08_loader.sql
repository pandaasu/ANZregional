/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : ladpdb08_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound reference data loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  19-Mar-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.ladpdb08_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladpdb08_loader; 
/

create or replace package body bds_app.ladpdb08_loader as

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
  
  rcd_hdr bds_refrnc_plant_ics%rowtype;

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
    lics_inbound_utility.set_definition('HDR','ID', 3);  
    lics_inbound_utility.set_definition('HDR','PLANT_CODE', 4);  
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_NUMBER', 38);  
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_TIMESTAMP', 14);  
    lics_inbound_utility.set_definition('HDR','CHANGE_FLAG', 1);  
    lics_inbound_utility.set_definition('HDR','PLANT_NAME', 30);  
    lics_inbound_utility.set_definition('HDR','VLTN_AREA', 4);  
    lics_inbound_utility.set_definition('HDR','PLANT_CUSTOMER_NO', 10);  
    lics_inbound_utility.set_definition('HDR','PLANT_VENDOR_NO', 10);  
    lics_inbound_utility.set_definition('HDR','FACTORY_CALENDAR_KEY', 2);  
    lics_inbound_utility.set_definition('HDR','PLANT_NAME_2', 30);  
    lics_inbound_utility.set_definition('HDR','PLANT_STREET', 30);  
    lics_inbound_utility.set_definition('HDR','PLANT_PO_BOX', 10);  
    lics_inbound_utility.set_definition('HDR','PLANT_POST_CODE', 10);  
    lics_inbound_utility.set_definition('HDR','PLANT_CITY', 25);  
    lics_inbound_utility.set_definition('HDR','PLANT_PURCHASING_ORGANISATION', 4);  
    lics_inbound_utility.set_definition('HDR','PLANT_SALES_ORGANISATION', 4);  
    lics_inbound_utility.set_definition('HDR','BATCH_MANAGE_INDCTR', 1);    
    lics_inbound_utility.set_definition('HDR','PLANT_CONDITION_INDCTR', 1);  
    lics_inbound_utility.set_definition('HDR','SOURCE_LIST_INDCTR', 1);  
    lics_inbound_utility.set_definition('HDR','ACTIVATE_REQRMNT_INDCTR', 1);  
    lics_inbound_utility.set_definition('HDR','PLANT_COUNTRY_KEY', 3);  
    lics_inbound_utility.set_definition('HDR','PLANT_REGION', 3);  
    lics_inbound_utility.set_definition('HDR','PLANT_COUNTRY_CODE', 3);  
    lics_inbound_utility.set_definition('HDR','PLANT_CITY_CODE', 4);  
    lics_inbound_utility.set_definition('HDR','PLANT_ADDRESS', 10);  
    lics_inbound_utility.set_definition('HDR','MAINT_PLANNING_PLANT', 4);  
    lics_inbound_utility.set_definition('HDR','TAX_JURISDICTION_CODE', 15);  
    lics_inbound_utility.set_definition('HDR','DSTRBTN_CHANNEL', 2);  
    lics_inbound_utility.set_definition('HDR','DIVISION', 2);  
    lics_inbound_utility.set_definition('HDR','LANGUAGE_KEY', 1);  
    lics_inbound_utility.set_definition('HDR','SOP_PLANT', 1);  
    lics_inbound_utility.set_definition('HDR','VARIANCE_KEY', 6);  
    lics_inbound_utility.set_definition('HDR','BATCH_MANAGE_OLD_INDCTR', 1);  
    lics_inbound_utility.set_definition('HDR','PLANT_CTGRY', 1);  
    lics_inbound_utility.set_definition('HDR','PLANT_SALES_DISTRICT', 6);  
    lics_inbound_utility.set_definition('HDR','PLANT_SUPPLY_REGION', 10);  
    lics_inbound_utility.set_definition('HDR','PLANT_TAX_INDCTR', 1);  
    lics_inbound_utility.set_definition('HDR','REGULAR_VENDOR_INDCTR', 1);  
    lics_inbound_utility.set_definition('HDR','FIRST_REMINDER_DAYS', 3);  
    lics_inbound_utility.set_definition('HDR','SECOND_REMINDER_DAYS', 3); 
    lics_inbound_utility.set_definition('HDR','THIRD_REMINDER_DAYS', 3); 
    lics_inbound_utility.set_definition('HDR','VENDOR_DECLARATION_TEXT_1', 16); 
    lics_inbound_utility.set_definition('HDR','VENDOR_DECLARATION_TEXT_2', 16); 
    lics_inbound_utility.set_definition('HDR','VENDOR_DECLARATION_TEXT_3', 16); 
    lics_inbound_utility.set_definition('HDR','PO_TOLERANCE_DAYS', 3); 
    lics_inbound_utility.set_definition('HDR','PLANT_BUSINESS_PLACE', 4); 
    lics_inbound_utility.set_definition('HDR','STOCK_XFER_RULE', 2); 
    lics_inbound_utility.set_definition('HDR','PLANT_DSTRBTN_PROFILE', 3); 
    lics_inbound_utility.set_definition('HDR','CENTRAL_ARCHIVE_MARKER', 1); 
    lics_inbound_utility.set_definition('HDR','DMS_TYPE_INDCTR', 1); 
    lics_inbound_utility.set_definition('HDR','NODE_TYPE', 3); 
    lics_inbound_utility.set_definition('HDR','NAME_FORMATION_STRUCTURE', 4); 
    lics_inbound_utility.set_definition('HDR','COST_CONTROL_ACTIVE_INDCTR', 1); 
    lics_inbound_utility.set_definition('HDR','MIXED_COSTING_ACTIVE_INDCTR', 1); 
    lics_inbound_utility.set_definition('HDR','ACTUAL_COSTING_ACTIVE_INDCTR', 1); 
    lics_inbound_utility.set_definition('HDR','TRANSPORT_POINT', 4); 
      
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
    rcd_hdr.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_hdr.sap_idoc_number := lics_inbound_utility.get_variable('SAP_IDOC_NUMBER');
    rcd_hdr.sap_idoc_timestamp := lics_inbound_utility.get_variable('SAP_IDOC_TIMESTAMP');
    rcd_hdr.change_flag := lics_inbound_utility.get_variable('CHANGE_FLAG');
    rcd_hdr.plant_name := lics_inbound_utility.get_variable('PLANT_NAME');
    rcd_hdr.vltn_area := lics_inbound_utility.get_variable('VLTN_AREA');
    rcd_hdr.plant_customer_no := lics_inbound_utility.get_variable('PLANT_CUSTOMER_NO');
    rcd_hdr.plant_vendor_no := lics_inbound_utility.get_variable('PLANT_VENDOR_NO');
    rcd_hdr.factory_calendar_key := lics_inbound_utility.get_variable('FACTORY_CALENDAR_KEY');
    rcd_hdr.plant_name_2 := lics_inbound_utility.get_variable('PLANT_NAME_2');
    rcd_hdr.plant_street := lics_inbound_utility.get_variable('PLANT_STREET');
    rcd_hdr.plant_po_box := lics_inbound_utility.get_variable('PLANT_PO_BOX');
    rcd_hdr.plant_post_code := lics_inbound_utility.get_variable('PLANT_POST_CODE');
    rcd_hdr.plant_city := lics_inbound_utility.get_variable('PLANT_CITY');
    rcd_hdr.plant_purchasing_organisation := lics_inbound_utility.get_variable('PLANT_PURCHASING_ORGANISATION');
    rcd_hdr.plant_sales_organisation := lics_inbound_utility.get_variable('PLANT_SALES_ORGANISATION');
    rcd_hdr.batch_manage_indctr := lics_inbound_utility.get_variable('BATCH_MANAGE_INDCTR');
    rcd_hdr.plant_condition_indctr := lics_inbound_utility.get_variable('PLANT_CONDITION_INDCTR');
    rcd_hdr.source_list_indctr := lics_inbound_utility.get_variable('SOURCE_LIST_INDCTR');
    rcd_hdr.activate_reqrmnt_indctr := lics_inbound_utility.get_variable('ACTIVATE_REQRMNT_INDCTR');
    rcd_hdr.plant_country_key := lics_inbound_utility.get_variable('PLANT_COUNTRY_KEY');
    rcd_hdr.plant_region := lics_inbound_utility.get_variable('PLANT_REGION');
    rcd_hdr.plant_country_code := lics_inbound_utility.get_variable('PLANT_COUNTRY_CODE');
    rcd_hdr.plant_city_code := lics_inbound_utility.get_variable('PLANT_CITY_CODE');
    rcd_hdr.plant_address := lics_inbound_utility.get_variable('PLANT_ADDRESS');
    rcd_hdr.maint_planning_plant := lics_inbound_utility.get_variable('MAINT_PLANNING_PLANT');
    rcd_hdr.tax_jurisdiction_code := lics_inbound_utility.get_variable('TAX_JURISDICTION_CODE');
    rcd_hdr.dstrbtn_channel := lics_inbound_utility.get_variable('DSTRBTN_CHANNEL');
    rcd_hdr.division := lics_inbound_utility.get_variable('DIVISION');
    rcd_hdr.language_key := lics_inbound_utility.get_variable('LANGUAGE_KEY');
    rcd_hdr.sop_plant := lics_inbound_utility.get_variable('SOP_PLANT');
    rcd_hdr.variance_key := lics_inbound_utility.get_variable('VARIANCE_KEY');
    rcd_hdr.batch_manage_old_indctr := lics_inbound_utility.get_variable('BATCH_MANAGE_OLD_INDCTR');
    rcd_hdr.plant_ctgry := lics_inbound_utility.get_variable('PLANT_CTGRY');
    rcd_hdr.plant_sales_district := lics_inbound_utility.get_variable('PLANT_SALES_DISTRICT');
    rcd_hdr.plant_supply_region := lics_inbound_utility.get_variable('PLANT_SUPPLY_REGION');
    rcd_hdr.plant_tax_indctr := lics_inbound_utility.get_variable('PLANT_TAX_INDCTR');
    rcd_hdr.regular_vendor_indctr := lics_inbound_utility.get_variable('REGULAR_VENDOR_INDCTR');
    rcd_hdr.first_reminder_days := lics_inbound_utility.get_variable('FIRST_REMINDER_DAYS');
    rcd_hdr.second_reminder_days := lics_inbound_utility.get_variable('SECOND_REMINDER_DAYS');
    rcd_hdr.third_reminder_days := lics_inbound_utility.get_variable('THIRD_REMINDER_DAYS');
    rcd_hdr.vendor_declaration_text_1 := lics_inbound_utility.get_variable('VENDOR_DECLARATION_TEXT_1');
    rcd_hdr.vendor_declaration_text_2 := lics_inbound_utility.get_variable('VENDOR_DECLARATION_TEXT_2');
    rcd_hdr.vendor_declaration_text_3 := lics_inbound_utility.get_variable('VENDOR_DECLARATION_TEXT_3');
    rcd_hdr.po_tolerance_days := lics_inbound_utility.get_variable('PO_TOLERANCE_DAYS');
    rcd_hdr.plant_business_place := lics_inbound_utility.get_variable('PLANT_BUSINESS_PLACE');
    rcd_hdr.stock_xfer_rule := lics_inbound_utility.get_variable('STOCK_XFER_RULE');
    rcd_hdr.plant_dstrbtn_profile := lics_inbound_utility.get_variable('PLANT_DSTRBTN_PROFILE');
    rcd_hdr.central_archive_marker := lics_inbound_utility.get_variable('CENTRAL_ARCHIVE_MARKER');
    rcd_hdr.dms_type_indctr := lics_inbound_utility.get_variable('DMS_TYPE_INDCTR');
    rcd_hdr.node_type := lics_inbound_utility.get_variable('NODE_TYPE');
    rcd_hdr.name_formation_structure := lics_inbound_utility.get_variable('NAME_FORMATION_STRUCTURE');
    rcd_hdr.cost_control_active_indctr := lics_inbound_utility.get_variable('COST_CONTROL_ACTIVE_INDCTR');
    rcd_hdr.mixed_costing_active_indctr := lics_inbound_utility.get_variable('MIXED_COSTING_ACTIVE_INDCTR');
    rcd_hdr.actual_costing_active_indctr := lics_inbound_utility.get_variable('ACTUAL_COSTING_ACTIVE_INDCTR');
    rcd_hdr.transport_point := lics_inbound_utility.get_variable('TRANSPORT_POINT');   
    
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
    if ( rcd_hdr.plant_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.PLANT_CODE');
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
    update bds_refrnc_plant_ics
    set plant_code = rcd_hdr.plant_code, 
      sap_idoc_number = rcd_hdr.sap_idoc_number, 
      sap_idoc_timestamp = rcd_hdr.sap_idoc_timestamp, 
      change_flag = rcd_hdr.change_flag,
      plant_name = rcd_hdr.plant_name, 
      vltn_area = rcd_hdr.vltn_area, 
      plant_customer_no = rcd_hdr.plant_customer_no, 
      plant_vendor_no = rcd_hdr.plant_vendor_no,
      factory_calendar_key = rcd_hdr.factory_calendar_key, 
      plant_name_2 = rcd_hdr.plant_name_2, 
      plant_street = rcd_hdr.plant_street, 
      plant_po_box = rcd_hdr.plant_po_box,
      plant_post_code = rcd_hdr.plant_post_code, 
      plant_city = rcd_hdr.plant_city, 
      plant_purchasing_organisation = rcd_hdr.plant_purchasing_organisation,
      plant_sales_organisation = rcd_hdr.plant_sales_organisation, 
      batch_manage_indctr = rcd_hdr.batch_manage_indctr, 
      plant_condition_indctr = rcd_hdr.plant_condition_indctr,
      source_list_indctr = rcd_hdr.source_list_indctr, 
      activate_reqrmnt_indctr = rcd_hdr.activate_reqrmnt_indctr, 
      plant_country_key = rcd_hdr.plant_country_key,
      plant_region = rcd_hdr.plant_region, 
      plant_country_code = rcd_hdr.plant_country_code, 
      plant_city_code = rcd_hdr.plant_city_code, 
      plant_address = rcd_hdr.plant_address,
      maint_planning_plant = rcd_hdr.maint_planning_plant, 
      tax_jurisdiction_code = rcd_hdr.tax_jurisdiction_code,
      dstrbtn_channel = rcd_hdr.dstrbtn_channel, 
      division = rcd_hdr.division,
      language_key = rcd_hdr.language_key, 
      sop_plant = rcd_hdr.sop_plant, 
      variance_key = rcd_hdr.variance_key, 
      batch_manage_old_indctr = rcd_hdr.batch_manage_old_indctr,
      plant_ctgry = rcd_hdr.plant_ctgry, 
      plant_sales_district = rcd_hdr.plant_sales_district, 
      plant_supply_region = rcd_hdr.plant_supply_region,
      plant_tax_indctr = rcd_hdr.plant_tax_indctr, 
      regular_vendor_indctr = rcd_hdr.regular_vendor_indctr, 
      first_reminder_days = rcd_hdr.first_reminder_days,
      second_reminder_days = rcd_hdr.second_reminder_days, 
      third_reminder_days = rcd_hdr.third_reminder_days, 
      vendor_declaration_text_1 = rcd_hdr.vendor_declaration_text_1,
      vendor_declaration_text_2 = rcd_hdr.vendor_declaration_text_2, 
      vendor_declaration_text_3 = rcd_hdr.vendor_declaration_text_3,
      po_tolerance_days = rcd_hdr.po_tolerance_days, 
      plant_business_place = rcd_hdr.plant_business_place, 
      stock_xfer_rule = rcd_hdr.stock_xfer_rule,
      plant_dstrbtn_profile = rcd_hdr.plant_dstrbtn_profile, 
      central_archive_marker = rcd_hdr.central_archive_marker, 
      dms_type_indctr = rcd_hdr.dms_type_indctr,
      node_type = rcd_hdr.node_type, 
      name_formation_structure = rcd_hdr.name_formation_structure, 
      cost_control_active_indctr = rcd_hdr.cost_control_active_indctr,
      mixed_costing_active_indctr = rcd_hdr.mixed_costing_active_indctr, 
      actual_costing_active_indctr = rcd_hdr.actual_costing_active_indctr,
      transport_point = rcd_hdr.transport_point
    where plant_code = rcd_hdr.plant_code;
    
    if ( sql%notfound ) then    
      insert into bds_refrnc_plant_ics
      (
        plant_code, 
        sap_idoc_number, 
        sap_idoc_timestamp, 
        change_flag,
        plant_name, 
        vltn_area, 
        plant_customer_no, 
        plant_vendor_no,
        factory_calendar_key, 
        plant_name_2, 
        plant_street, 
        plant_po_box,
        plant_post_code, 
        plant_city, 
        plant_purchasing_organisation,
        plant_sales_organisation, 
        batch_manage_indctr, 
        plant_condition_indctr,
        source_list_indctr, 
        activate_reqrmnt_indctr, 
        plant_country_key,
        plant_region, 
        plant_country_code, 
        plant_city_code, 
        plant_address,
        maint_planning_plant, 
        tax_jurisdiction_code,
        dstrbtn_channel, 
        division,
        language_key, 
        sop_plant, 
        variance_key, 
        batch_manage_old_indctr,
        plant_ctgry, 
        plant_sales_district, 
        plant_supply_region,
        plant_tax_indctr, 
        regular_vendor_indctr, 
        first_reminder_days,
        second_reminder_days, 
        third_reminder_days, 
        vendor_declaration_text_1,
        vendor_declaration_text_2, 
        vendor_declaration_text_3,
        po_tolerance_days, 
        plant_business_place, 
        stock_xfer_rule,
        plant_dstrbtn_profile, 
        central_archive_marker, 
        dms_type_indctr,
        node_type, 
        name_formation_structure, 
        cost_control_active_indctr,
        mixed_costing_active_indctr, 
        actual_costing_active_indctr,
        transport_point
      )
      values 
      (
        rcd_hdr.plant_code, 
        rcd_hdr.sap_idoc_number, 
        rcd_hdr.sap_idoc_timestamp, 
        rcd_hdr.change_flag,
        rcd_hdr.plant_name, 
        rcd_hdr.vltn_area, 
        rcd_hdr.plant_customer_no, 
        rcd_hdr.plant_vendor_no,
        rcd_hdr.factory_calendar_key, 
        rcd_hdr.plant_name_2, 
        rcd_hdr.plant_street, 
        rcd_hdr.plant_po_box,
        rcd_hdr.plant_post_code, 
        rcd_hdr.plant_city, 
        rcd_hdr.plant_purchasing_organisation,
        rcd_hdr.plant_sales_organisation, 
        rcd_hdr.batch_manage_indctr, 
        rcd_hdr.plant_condition_indctr,
        rcd_hdr.source_list_indctr, 
        rcd_hdr.activate_reqrmnt_indctr, 
        rcd_hdr.plant_country_key,
        rcd_hdr.plant_region, 
        rcd_hdr.plant_country_code, 
        rcd_hdr.plant_city_code, 
        rcd_hdr.plant_address,
        rcd_hdr.maint_planning_plant, 
        rcd_hdr.tax_jurisdiction_code,
        rcd_hdr.dstrbtn_channel, 
        rcd_hdr.division,
        rcd_hdr.language_key, 
        rcd_hdr.sop_plant, 
        rcd_hdr.variance_key, 
        rcd_hdr.batch_manage_old_indctr,
        rcd_hdr.plant_ctgry, 
        rcd_hdr.plant_sales_district, 
        rcd_hdr.plant_supply_region,
        rcd_hdr.plant_tax_indctr, 
        rcd_hdr.regular_vendor_indctr, 
        rcd_hdr.first_reminder_days,
        rcd_hdr.second_reminder_days, 
        rcd_hdr.third_reminder_days, 
        rcd_hdr.vendor_declaration_text_1,
        rcd_hdr.vendor_declaration_text_2, 
        rcd_hdr.vendor_declaration_text_3,
        rcd_hdr.po_tolerance_days, 
        rcd_hdr.plant_business_place, 
        rcd_hdr.stock_xfer_rule,
        rcd_hdr.plant_dstrbtn_profile, 
        rcd_hdr.central_archive_marker, 
        rcd_hdr.dms_type_indctr,
        rcd_hdr.node_type, 
        rcd_hdr.name_formation_structure, 
        rcd_hdr.cost_control_active_indctr,
        rcd_hdr.mixed_costing_active_indctr, 
        rcd_hdr.actual_costing_active_indctr,
        rcd_hdr.transport_point
      );
    end if;
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
    
end ladpdb08_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb08_loader to appsupport;
grant execute on bds_app.ladpdb08_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb08_loader for bds_app.ladpdb08_loader;