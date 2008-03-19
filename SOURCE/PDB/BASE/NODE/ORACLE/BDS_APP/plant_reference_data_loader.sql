/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : plant_reference_data_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound reference data loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  19-Mar-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.plant_reference_data_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end plant_reference_data_loader; 
/

create or replace package body bds_app.plant_reference_data_loader as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  procedure complete_transaction;
  procedure process_record_bom(par_record in varchar2);
  procedure process_record_pdr(par_record in varchar2);
  procedure process_record_rch(par_record in varchar2);
  procedure process_record_rpl(par_record in varchar2);
  procedure process_record_rpr(par_record in varchar2);

  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
  
  rcd_bom bds_refrnc_bom_altrnt%rowtype;
  rcd_pdr bds_prodctn_resrc_en%rowtype;
  rcd_rch bds_refrnc_charistic%rowtype;
  rcd_rpl bds_refrnc_plant%rowtype;
  rcd_rpr bds_refrnc_purchasing_src%rowtype;

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
    lics_inbound_utility.set_definition('BOM','BOM_MATERIAL_CODE', 18);  
    lics_inbound_utility.set_definition('BOM','BOM_ALTERNATIVE', 2);  
    lics_inbound_utility.set_definition('BOM','BOM_PLANT', 4);  
    lics_inbound_utility.set_definition('BOM','BOM_EFF_FROM_DATE', 14);  
    
    /*-*/  
    lics_inbound_utility.set_definition('PDR','RESRC_ID', 8);  
    lics_inbound_utility.set_definition('PDR','RESRC_CODE', 8);  
    lics_inbound_utility.set_definition('PDR','RESRC_TEXT', 40);  
    lics_inbound_utility.set_definition('PDR','RESRC_PLANT_CODE', 4); 
    
    /*-*/  
    lics_inbound_utility.set_definition('RCH','SAP_CHARISTIC_CODE', 30);  
    lics_inbound_utility.set_definition('RCH','SAP_CHARISTIC_VALUE_CODE', 30);  
    lics_inbound_utility.set_definition('RCH','SAP_CHARISTIC_VALUE_SHRT_DESC', 256);  
    lics_inbound_utility.set_definition('RCH','SAP_CHARISTIC_VALUE_LONG_DESC', 256);  
    lics_inbound_utility.set_definition('RCH','SAP_IDOC_NUMBER', 38);  
    lics_inbound_utility.set_definition('RCH','SAP_IDOC_TIMESTAMP', 14);  
    lics_inbound_utility.set_definition('RCH','CHANGE_FLAG', 1);      
    
    /*-*/  
    lics_inbound_utility.set_definition('RPL','PLANT_CODE', 4);  
    lics_inbound_utility.set_definition('RPL','SAP_IDOC_NUMBER', 38);  
    lics_inbound_utility.set_definition('RPL','SAP_IDOC_TIMESTAMP', 14);  
    lics_inbound_utility.set_definition('RPL','CHANGE_FLAG', 1);  
    lics_inbound_utility.set_definition('RPL','PLANT_NAME', 30);  
    lics_inbound_utility.set_definition('RPL','VLTN_AREA', 4);  
    lics_inbound_utility.set_definition('RPL','PLANT_CUSTOMER_NO', 10);  
    lics_inbound_utility.set_definition('RPL','PLANT_VENDOR_NO', 10);  
    lics_inbound_utility.set_definition('RPL','FACTORY_CALENDAR_KEY', 2);  
    lics_inbound_utility.set_definition('RPL','PLANT_NAME_2', 30);  
    lics_inbound_utility.set_definition('RPL','PLANT_STREET', 30);  
    lics_inbound_utility.set_definition('RPL','PLANT_PO_BOX', 10);  
    lics_inbound_utility.set_definition('RPL','PLANT_POST_CODE', 10);  
    lics_inbound_utility.set_definition('RPL','PLANT_CITY', 25);  
    lics_inbound_utility.set_definition('RPL','PLANT_PURCHASING_ORGANISATION', 4);  
    lics_inbound_utility.set_definition('RPL','PLANT_SALES_ORGANISATION', 4);  
    lics_inbound_utility.set_definition('RPL','BATCH_MANAGE_INDCTR', 1);    
    lics_inbound_utility.set_definition('RPL','PLANT_CONDITION_INDCTR', 1);  
    lics_inbound_utility.set_definition('RPL','SOURCE_LIST_INDCTR', 1);  
    lics_inbound_utility.set_definition('RPL','ACTIVATE_REQRMNT_INDCTR', 1);  
    lics_inbound_utility.set_definition('RPL','PLANT_COUNTRY_KEY', 3);  
    lics_inbound_utility.set_definition('RPL','PLANT_REGION', 3);  
    lics_inbound_utility.set_definition('RPL','PLANT_COUNTRY_CODE', 3);  
    lics_inbound_utility.set_definition('RPL','PLANT_CITY_CODE', 4);  
    lics_inbound_utility.set_definition('RPL','PLANT_ADDRESS', 10);  
    lics_inbound_utility.set_definition('RPL','MAINT_PLANNING_PLANT', 4);  
    lics_inbound_utility.set_definition('RPL','TAX_JURISDICTION_CODE', 15);  
    lics_inbound_utility.set_definition('RPL','DSTRBTN_CHANNEL', 2);  
    lics_inbound_utility.set_definition('RPL','DIVISION', 2);  
    lics_inbound_utility.set_definition('RPL','LANGUAGE_KEY', 1);  
    lics_inbound_utility.set_definition('RPL','SOP_PLANT', 1);  
    lics_inbound_utility.set_definition('RPL','VARIANCE_KEY', 6);  
    lics_inbound_utility.set_definition('RPL','BATCH_MANAGE_OLD_INDCTR', 1);  
    lics_inbound_utility.set_definition('RPL','PLANT_CTGRY', 1);  
    lics_inbound_utility.set_definition('RPL','PLANT_SALES_DISTRICT', 6);  
    lics_inbound_utility.set_definition('RPL','PLANT_SUPPLY_REGION', 10);  
    lics_inbound_utility.set_definition('RPL','PLANT_TAX_INDCTR', 1);  
    lics_inbound_utility.set_definition('RPL','REGULAR_VENDOR_INDCTR', 1);  
    lics_inbound_utility.set_definition('RPL','FIRST_REMINDER_DAYS', 3);  
    lics_inbound_utility.set_definition('RPL','SECOND_REMINDER_DAYS', 3); 
    lics_inbound_utility.set_definition('RPL','THIRD_REMINDER_DAYS', 3); 
    lics_inbound_utility.set_definition('RPL','VENDOR_DECLARATION_TEXT_1', 16); 
    lics_inbound_utility.set_definition('RPL','VENDOR_DECLARATION_TEXT_2', 16); 
    lics_inbound_utility.set_definition('RPL','VENDOR_DECLARATION_TEXT_3', 16); 
    lics_inbound_utility.set_definition('RPL','PO_TOLERANCE_DAYS', 3); 
    lics_inbound_utility.set_definition('RPL','PLANT_BUSINESS_PLACE', 4); 
    lics_inbound_utility.set_definition('RPL','STOCK_XFER_RULE', 2); 
    lics_inbound_utility.set_definition('RPL','PLANT_DSTRBTN_PROFILE', 3); 
    lics_inbound_utility.set_definition('RPL','CENTRAL_ARCHIVE_MARKER', 1); 
    lics_inbound_utility.set_definition('RPL','DMS_TYPE_INDCTR', 1); 
    lics_inbound_utility.set_definition('RPL','NODE_TYPE', 3); 
    lics_inbound_utility.set_definition('RPL','NAME_FORMATION_STRUCTURE', 4); 
    lics_inbound_utility.set_definition('RPL','COST_CONTROL_ACTIVE_INDCTR', 1); 
    lics_inbound_utility.set_definition('RPL','MIXED_COSTING_ACTIVE_INDCTR', 1); 
    lics_inbound_utility.set_definition('RPL','ACTUAL_COSTING_ACTIVE_INDCTR', 1); 
    lics_inbound_utility.set_definition('RPL','TRANSPORT_POINT', 4); 
    
    /*-*/  
    lics_inbound_utility.set_definition('RPR','SAP_MATERIAL_CODE', 18);
    lics_inbound_utility.set_definition('RPR','PLANT_CODE', 4);
    lics_inbound_utility.set_definition('RPR','RECORD_NO', 5);
    lics_inbound_utility.set_definition('RPR','CREATN_DATE', 14);
    lics_inbound_utility.set_definition('RPR','CREATN_USER', 12);
    lics_inbound_utility.set_definition('RPR','SRC_LIST_VALID_FROM', 14);
    lics_inbound_utility.set_definition('RPR','SRC_LIST_VALID_TO', 14);
    lics_inbound_utility.set_definition('RPR','VENDOR_CODE', 10);
    lics_inbound_utility.set_definition('RPR','FIXED_VENDOR_INDCTR', 1);
    lics_inbound_utility.set_definition('RPR','AGREEMENT_NO', 10);
    lics_inbound_utility.set_definition('RPR','AGREEMENT_ITEM', 5);
    lics_inbound_utility.set_definition('RPR','FIXED_PURCHASE_AGREEMENT_ITEM', 1);
    lics_inbound_utility.set_definition('RPR','PLANT_PROCURED_FROM', 4);
    lics_inbound_utility.set_definition('RPR','STO_FIXED_ISSUING_PLANT', 1);
    lics_inbound_utility.set_definition('RPR','MANUFCTR_PART_REFRNC_MATERIAL', 18);
    lics_inbound_utility.set_definition('RPR','BLOCKED_SUPPLY_SRC_FLAG', 1);
    lics_inbound_utility.set_definition('RPR','PURCHASING_ORGANISATION', 4);
    lics_inbound_utility.set_definition('RPR','PURCHASING_DOCUMENT_CTGRY', 1);
    lics_inbound_utility.set_definition('RPR','SRC_LIST_CTGRY', 1);
    lics_inbound_utility.set_definition('RPR','SRC_LIST_PLANNING_USAGE', 1);
    lics_inbound_utility.set_definition('RPR','ORDER_UNIT', 3);
    lics_inbound_utility.set_definition('RPR','LOGICAL_SYSTEM', 10);
    lics_inbound_utility.set_definition('RPR','SPECIAL_STOCK_INDCTR', 1);
      
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
      when 'BOM' then process_record_bom(par_record);
      when 'PDR' then process_record_pdr(par_record);
      when 'RCH' then process_record_rch(par_record);
      when 'RPL' then process_record_rpl(par_record);
      when 'RPR' then process_record_rpr(par_record);
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
  
  procedure process_record_bom(par_record in varchar2) is
    
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
    lics_inbound_utility.parse_record('BOM', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/    
    rcd_bom.bom_material_code := lics_inbound_utility.get_variable('BOM_MATERIAL_CODE');
    rcd_bom.bom_alternative := lics_inbound_utility.get_variable('BOM_ALTERNATIVE');
    rcd_bom.bom_plant := lics_inbound_utility.get_variable('BOM_PLANT');
    rcd_bom.bom_eff_from_date := lics_inbound_utility.get_variable('BOM_EFF_FROM_DATE');
    
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
    if ( rcd_bom.bom_material_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - BOM.BOM_MATERIAL_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_bom.bom_alternative is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - BOM.BOM_ALTERNATIVE');
      var_trn_error := true;
    end if;
          
    if ( rcd_bom.bom_plant is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - BOM.BOM_PLANT');
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
    update bds_refrnc_bom_altrnt
    set bom_material_code = rcd_bom.bom_material_code,
      bom_alternative = rcd_bom.bom_alternative,
      bom_plant = rcd_bom.bom_plant,
      bom_eff_to_date = rcd_bom.bom_eff_to_date
    where bom_material_code = rcd_bom.bom_material_code
      and bom_alternative = rcd_bom.bom_alternative
      and bom_plant = rcd_bom.bom_plant;
    
    if ( sql%notfound ) then    
      insert into bds_refrnc_bom_altrnt
      (
        bom_material_code, 
        bom_alternative,
        bom_plant,        
        bom_eff_to_date
      )
      values 
      (
        rcd_bom.bom_material_code, 
        rcd_bom.bom_alternative,
        rcd_bom.bom_plant,
        rcd_bom.bom_eff_to_date
      );
    end if;
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_bom;

  procedure process_record_pdr(par_record in varchar2) is
    
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
    lics_inbound_utility.parse_record('PDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/    
    rcd_pdr.resrc_id := lics_inbound_utility.get_variable('RESRC_ID');
    rcd_pdr.resrc_code := lics_inbound_utility.get_variable('RESRC_CODE');
    rcd_pdr.resrc_text := lics_inbound_utility.get_variable('RESRC_TEXT');
    rcd_pdr.resrc_plant_code := lics_inbound_utility.get_variable('RESRC_PLANT_CODE');
    
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
    if ( rcd_pdr.resrc_id is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - PDR.RESRC_ID');
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
    update bds_prodctn_resrc_en
    set resrc_id = rcd_pdr.resrc_id,
      resrc_code = rcd_pdr.resrc_code,
      resrc_text = rcd_pdr.resrc_text,
      resrc_plant_code = rcd_pdr.resrc_plant_code
    where resrc_id = rcd_pdr.resrc_id;
    
    if ( sql%notfound ) then    
      insert into bds_prodctn_resrc_en
      (
        resrc_id, 
        resrc_code,
        resrc_text,        
        resrc_plant_code
      )
      values 
      (
        rcd_pdr.resrc_id, 
        rcd_pdr.resrc_code,
        rcd_pdr.resrc_text,        
        rcd_pdr.resrc_plant_code
      );
    end if;  
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_pdr;

  procedure process_record_rch(par_record in varchar2) is
    
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
    lics_inbound_utility.parse_record('PDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/    
    rcd_rch.sap_charistic_code := lics_inbound_utility.get_variable('SAP_CHARISTIC_CODE');
    rcd_rch.sap_charistic_value_code := lics_inbound_utility.get_variable('SAP_CHARISTIC_VALUE_CODE');
    rcd_rch.sap_charistic_value_shrt_desc := lics_inbound_utility.get_variable('SAP_CHARISTIC_VALUE_SHRT_DESC');
    rcd_rch.sap_charistic_value_long_desc := lics_inbound_utility.get_variable('SAP_CHARISTIC_VALUE_LONG_DESC');
    rcd_rch.sap_idoc_number := lics_inbound_utility.get_variable('SAP_IDOC_NUMBER');
    rcd_rch.sap_idoc_timestamp := lics_inbound_utility.get_variable('SAP_IDOC_TIMESTAMP');
    rcd_rch.change_flag := lics_inbound_utility.get_variable('CHANGE_FLAG');
    
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
    if ( rcd_rch.sap_charistic_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - PDR.SAP_CHARISTIC_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_rch.sap_charistic_value_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - PDR.SAP_CHARISTIC_VALUE_CODE');
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
    update bds_refrnc_charistic
    set sap_charistic_code = rcd_rch.sap_charistic_code,
      sap_charistic_value_code = rcd_rch.sap_charistic_value_code,
      sap_charistic_value_shrt_desc = rcd_rch.sap_charistic_value_shrt_desc,
      sap_charistic_value_long_desc = rcd_rch.sap_charistic_value_long_desc,
      sap_idoc_number = rcd_rch.sap_idoc_number,
      sap_idoc_timestamp = rcd_rch.sap_idoc_timestamp,
      change_flag = rcd_rch.change_flag
    where sap_charistic_code = rcd_rch.sap_charistic_code
      and sap_charistic_value_code = rcd_rch.sap_charistic_value_code;
    
    if ( sql%notfound ) then    
      insert into bds_refrnc_charistic
      (
        sap_charistic_code,
        sap_charistic_value_code,
        sap_charistic_value_shrt_desc,
        sap_charistic_value_long_desc,
        sap_idoc_number,
        sap_idoc_timestamp,
        change_flag
      )
      values 
      (
        rcd_rch.sap_charistic_code,
        rcd_rch.sap_charistic_value_code,
        rcd_rch.sap_charistic_value_shrt_desc,
        rcd_rch.sap_charistic_value_long_desc,
        rcd_rch.sap_idoc_number,
        rcd_rch.sap_idoc_timestamp,
        rcd_rch.change_flag
      );
    end if;    
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_rch;

  procedure process_record_rpl(par_record in varchar2) is
    
  /*-------------*/
  /* Begin block */
  /*-------------*/    
  begin
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_rpl;

  procedure process_record_rpr(par_record in varchar2) is
   
  /*-------------*/
  /* Begin block */
  /*-------------*/    
  begin
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_rpr;
    
end plant_reference_data_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.plant_reference_data_loader to appsupport;
grant execute on bds_app.plant_reference_data_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_reference_data_loader for bds_app.plant_reference_data_loader;