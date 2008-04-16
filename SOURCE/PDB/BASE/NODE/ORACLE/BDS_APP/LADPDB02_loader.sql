/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : ladpdb02_loader 
  Owner   : BDS_APP 
  Author  : Jeff Phillipson 

  Description 
  ----------- 
  Plant Database - Inbound Material_plant_mfanz Interface 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  18-Nov-2007  Jeff Phillipson  Created 
  04-Mar-2008  Jeff Phillipson  Added pkg instruction table entry 
  06-Mar-2008  Trevor Keon      Altered to support changes to 
                                plant_material_extract 
*******************************************************************************/

create or replace package bds_app.ladpdb02_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end ladpdb02_loader; 
/

create or replace package body bds_app.ladpdb02_loader as

  /*-*/
  /* Private exceptions 
  /*-*/
  application_exception exception;
  pragma exception_init(application_exception, -20000);

  /*-*/
  /* Private declarations 
  /*-*/
  procedure complete_transaction;
  procedure process_record_ctl(par_record in varchar2);
  procedure process_record_hdr(par_record in varchar2);
  procedure process_record_stx(par_record in varchar2);
  procedure process_record_pkg(par_record in varchar2);
  procedure process_record_uom(par_record in varchar2);


  /*-*/
  /* Private definitions 
  /*-*/
  var_trn_start   boolean;
  var_trn_ignore  boolean;
  var_trn_error   boolean;
    
  rcd_hdr bds_material_plant_mfanz_test%rowtype;
  rcd_pkg bds_material_pkg_instr_det_t%rowtype;
  rcd_uom bds_material_uom%rowtype;

  var_material_code rcd_hdr.sap_material_code%type;

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
    lics_inbound_utility.set_definition('CTL','ID',3);
    lics_inbound_utility.set_definition('CTL','SAP_MATERIAL_CODE', 18);
    lics_inbound_utility.set_definition('CTL','MSG_TIMESTAMP', 14);
    
    /*-*/
    lics_inbound_utility.set_definition('HDR','ID',3);
    lics_inbound_utility.set_definition('HDR','PLANT_CODE', 4);
    lics_inbound_utility.set_definition('HDR','BDS_MATERIAL_DESC_EN', 40);
    lics_inbound_utility.set_definition('HDR','MATERIAL_TYPE', 4);
    lics_inbound_utility.set_definition('HDR','MATERIAL_GRP', 9);
    lics_inbound_utility.set_definition('HDR','BASE_UOM', 3);
    lics_inbound_utility.set_definition('HDR','ORDER_UNIT', 3);
    lics_inbound_utility.set_definition('HDR','GROSS_WEIGHT', 38);
    lics_inbound_utility.set_definition('HDR','NET_WEIGHT', 38);
    lics_inbound_utility.set_definition('HDR','GROSS_WEIGHT_UNIT', 3);
    lics_inbound_utility.set_definition('HDR','LENGTH', 38);
    lics_inbound_utility.set_definition('HDR','WIDTH', 38);
    lics_inbound_utility.set_definition('HDR','HEIGHT', 38);
    lics_inbound_utility.set_definition('HDR','DIMENSION_UOM', 3);
    lics_inbound_utility.set_definition('HDR','INTERNTL_ARTICLE_NO', 18);
    lics_inbound_utility.set_definition('HDR','TOTAL_SHELF_LIFE', 38);
    lics_inbound_utility.set_definition('HDR','MARS_PLAN_ITEM_FLAG', 6);
    lics_inbound_utility.set_definition('HDR','MARS_INTRMDT_PRDCT_COMPNT_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARS_MERCHANDISING_UNIT_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARS_PRMOTIONAL_MATERIAL_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARS_RETAIL_SALES_UNIT_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARS_SHPPING_CONTNR_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARS_SEMI_FINISHED_PRDCT_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARS_RPRSNTTV_ITEM_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','MARS_TRADED_UNIT_FLAG', 1);
    lics_inbound_utility.set_definition('HDR','XPLANT_STATUS', 2);
    lics_inbound_utility.set_definition('HDR','XPLANT_STATUS_VALID', 14);
    lics_inbound_utility.set_definition('HDR','BATCH_MNGMNT_REQRMNT_INDCTR', 2);
    lics_inbound_utility.set_definition('HDR','MARS_PLANT_MATERIAL_TYPE', 38);
    lics_inbound_utility.set_definition('HDR','PROCUREMENT_TYPE', 1);
    lics_inbound_utility.set_definition('HDR','SPECIAL_PROCUREMENT_TYPE', 2);
    lics_inbound_utility.set_definition('HDR','ISSUE_STORAGE_LOCATION', 4);
    lics_inbound_utility.set_definition('HDR','MRP_CONTROLLER', 3);
    lics_inbound_utility.set_definition('HDR','PLANT_SPECIFIC_STATUS_VALID', 14);
    lics_inbound_utility.set_definition('HDR','DELETION_INDCTR', 1);
    lics_inbound_utility.set_definition('HDR','PLANT_SPECIFIC_STATUS', 2);
    lics_inbound_utility.set_definition('HDR','ASSEMBLY_SCRAP_PERCNTG', 38);
    lics_inbound_utility.set_definition('HDR','COMPONENT_SCRAP_PERCNTG', 38);
    lics_inbound_utility.set_definition('HDR','BACKFLUSH_INDCTR', 1);
    lics_inbound_utility.set_definition('HDR','MARS_RPRSNTTV_ITEM_CODE', 18);
    lics_inbound_utility.set_definition('HDR','REGIONAL_CODE_10', 18);
    lics_inbound_utility.set_definition('HDR','REGIONAL_CODE_17', 18);
    lics_inbound_utility.set_definition('HDR','REGIONAL_CODE_18', 18);
    lics_inbound_utility.set_definition('HDR','REGIONAL_CODE_19', 18);
    lics_inbound_utility.set_definition('HDR','BDS_UNIT_COST', 38);
    lics_inbound_utility.set_definition('HDR','FUTURE_PLANNED_PRICE_1', 38);
    lics_inbound_utility.set_definition('HDR','VLTN_CLASS', 4);
    lics_inbound_utility.set_definition('HDR','BDS_PCE_FACTOR_FROM_BASE_UOM', 38);
    lics_inbound_utility.set_definition('HDR','MARS_PCE_ITEM_CODE', 18);
    lics_inbound_utility.set_definition('HDR','MARS_PCE_INTERNTL_ARTICLE_NO', 18);
    lics_inbound_utility.set_definition('HDR','BDS_SB_FACTOR_FROM_BASE_UOM', 38);
    lics_inbound_utility.set_definition('HDR','MARS_SB_ITEM_CODE', 18);
    lics_inbound_utility.set_definition('HDR','EFFECTIVE_OUT_DATE',14);
    lics_inbound_utility.set_definition('HDR','DISCONTINUATION_INDCTR', 1);
    lics_inbound_utility.set_definition('HDR','FOLLOWUP_MATERIAL', 18);
    lics_inbound_utility.set_definition('HDR','MATERIAL_DIVISION', 2);
    lics_inbound_utility.set_definition('HDR','MRP_TYPE', 2);
    lics_inbound_utility.set_definition('HDR','MAX_STORAGE_PRD', 38);
    lics_inbound_utility.set_definition('HDR','MAX_STORAGE_PRD_UNIT', 3);
    lics_inbound_utility.set_definition('HDR','ISSUE_UNIT', 3);
    lics_inbound_utility.set_definition('HDR','PLANNED_DELIVERY_DAYS', 38); 
    
    /*-*/
    lics_inbound_utility.set_definition('STX','ID',3);
    lics_inbound_utility.set_definition('STX','COUNTRY_CODE',3);
    lics_inbound_utility.set_definition('STX','SALES_TEXT',2000);
     
    /*-*/
    lics_inbound_utility.set_definition('PKG','ID',3);
    lics_inbound_utility.set_definition('PKG','PKG_INSTR_TABLE_USAGE', 1);
    lics_inbound_utility.set_definition('PKG','PKG_INSTR_TABLE', 64);
    lics_inbound_utility.set_definition('PKG','PKG_INSTR_TYPE', 4);
    lics_inbound_utility.set_definition('PKG','PKG_INSTR_APPLICATION', 2);
    lics_inbound_utility.set_definition('PKG','ITEM_CTGRY', 2);
    lics_inbound_utility.set_definition('PKG','SALES_ORGANISATION', 4);
    lics_inbound_utility.set_definition('PKG','COMPONENT', 20);
    lics_inbound_utility.set_definition('PKG','PKG_INSTR_START_DATE', 14);
    lics_inbound_utility.set_definition('PKG','PKG_INSTR_END_DATE', 14);
    lics_inbound_utility.set_definition('PKG','VARIABLE_KEY', 100);  
    lics_inbound_utility.set_definition('PKG','HEIGHT', 38);
    lics_inbound_utility.set_definition('PKG','WIDTH', 38);
    lics_inbound_utility.set_definition('PKG','LENGTH', 38);
    lics_inbound_utility.set_definition('PKG','HU_TOTAL_WEIGHT', 38);
    lics_inbound_utility.set_definition('PKG','HU_TOTAL_VOLUME', 38);
    lics_inbound_utility.set_definition('PKG','DIMENSION_UOM', 3);
    lics_inbound_utility.set_definition('PKG','WEIGHT_UNIT', 3);
    lics_inbound_utility.set_definition('PKG','VOLUME_UNIT', 3);
    lics_inbound_utility.set_definition('PKG','TARGET_QTY', 38);
    lics_inbound_utility.set_definition('PKG','ROUNDING_QTY', 38);
    lics_inbound_utility.set_definition('PKG','UOM', 3); 
      
    /*-*/
    lics_inbound_utility.set_definition('UOM','ID',3);
    lics_inbound_utility.set_definition('UOM','UOM_CODE',3);
    lics_inbound_utility.set_definition('UOM','SAP_FUNCTION',3);
    lics_inbound_utility.set_definition('UOM','BASE_UOM_NUMERATOR',38);
    lics_inbound_utility.set_definition('UOM','BASE_UOM_DENOMINATOR',38);
    lics_inbound_utility.set_definition('UOM','BDS_FACTOR_TO_BASE_UOM',38);
    lics_inbound_utility.set_definition('UOM','BDS_FACTOR_FROM_BASE_UOM',38);
    lics_inbound_utility.set_definition('UOM','INTERNTL_ARTICLE_NO',18);
    lics_inbound_utility.set_definition('UOM','INTERNTL_ARTICLE_NO_CTGRY',2);
    lics_inbound_utility.set_definition('UOM','LENGTH',38);
    lics_inbound_utility.set_definition('UOM','WIDTH',38);
    lics_inbound_utility.set_definition('UOM','HEIGHT',38);
    lics_inbound_utility.set_definition('UOM','DIMENSION_UOM',3);
    lics_inbound_utility.set_definition('UOM','VOLUME',38);
    lics_inbound_utility.set_definition('UOM','VOLUME_UNIT',3);
    lics_inbound_utility.set_definition('UOM','GROSS_WEIGHT',38);
    lics_inbound_utility.set_definition('UOM','GROSS_WEIGHT_UNIT',3);
    lics_inbound_utility.set_definition('UOM','LOWER_LEVEL_HIERACHY_UOM',3);
    lics_inbound_utility.set_definition('UOM','GLOBAL_TRADE_ITEM_VARIANT',2);
    lics_inbound_utility.set_definition('UOM','MARS_MUTLI_CONVRSN_UOM_INDCTR',1);
    lics_inbound_utility.set_definition('UOM','MARS_PC_ITEM_CODE',18);
    lics_inbound_utility.set_definition('UOM','MARS_PC_LEVEL',38);
    lics_inbound_utility.set_definition('UOM','MARS_ORDER_UOM_PRFRNC_INDCTR',1);
    lics_inbound_utility.set_definition('UOM','MARS_SALES_UOM_PRFRNC_INDCTR',1);
    lics_inbound_utility.set_definition('UOM','MARS_ISSUE_UOM_PRFRNC_INDCTR',1);
    lics_inbound_utility.set_definition('UOM','MARS_WM_UOM_PRFRNC_INDCTR',1);
    lics_inbound_utility.set_definition('UOM','MARS_RPRSNTTV_MATERIAL_CODE',18);
    
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
      when 'CTL' then process_record_ctl(par_record);
      when 'HDR' then process_record_hdr(par_record);
      when 'STX' then process_record_stx(par_record);
      when 'PKG' then process_record_pkg(par_record);
      when 'UOM' then process_record_uom(par_record);
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
      lics_inbound_utility.add_exception(substr(SQLERRM, 1, 512));
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
  /* This procedure performs the record CTL routine */
  /**************************************************/
  procedure process_record_ctl(par_record in varchar2) is              
                       
    /*-*/
    /* Local cursors 
    /*-*/
    cursor csr_bds_material_plant_mfanz is
      select t01.sap_material_code as sap_material_code,
        min(t01.msg_timestamp) as msg_timestamp
      from bds_material_plant_mfanz_test t01
      where t01.sap_material_code = rcd_hdr.sap_material_code
      group by t01.sap_material_code;
      
    rcd_bds_material_plant_mfanz csr_bds_material_plant_mfanz%rowtype;
    
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

    /*-*/
    /* PARSE - Parse the data record 
    /*-*/    
    lics_inbound_utility.parse_record('CTL', par_record);

    /*-*/
    /* RETRIEVE - Retrieve the field values 
    /*-*/
    rcd_hdr.sap_material_code := lics_inbound_utility.get_variable('SAP_MATERIAL_CODE');
    rcd_hdr.msg_timestamp := lics_inbound_utility.get_variable('MSG_TIMESTAMP');
        
    /*-*/
    /* Validate message sequence  
    /*-*/
    open csr_bds_material_plant_mfanz;
    fetch csr_bds_material_plant_mfanz into rcd_bds_material_plant_mfanz;
    
    if ( csr_bds_material_plant_mfanz%found ) then      
      if ( rcd_hdr.msg_timestamp >= rcd_bds_material_plant_mfanz.msg_timestamp ) then
        delete from bds_material_pkg_instr_det_t where sap_material_code = rcd_hdr.sap_material_code;
        delete from bds_material_uom where sap_material_code = rcd_hdr.sap_material_code;
        delete from bds_material_plant_mfanz_test where sap_material_code = rcd_hdr.sap_material_code;        
      else
        var_trn_ignore := true;
      end if;
    end if;   
     
    close csr_bds_material_plant_mfanz;
    
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_ctl;

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
    
    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('HDR', par_record);
    
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/
    rcd_hdr.plant_code := lics_inbound_utility.get_variable('PLANT_CODE');
    rcd_hdr.bds_material_desc_en := lics_inbound_utility.get_variable('BDS_MATERIAL_DESC_EN');
    rcd_hdr.material_type := lics_inbound_utility.get_variable('MATERIAL_TYPE');
    rcd_hdr.material_grp := lics_inbound_utility.get_variable('MATERIAL_GRP');
    rcd_hdr.base_uom := lics_inbound_utility.get_variable('BASE_UOM');
    rcd_hdr.order_unit := lics_inbound_utility.get_variable('ORDER_UNIT');
    rcd_hdr.gross_weight := lics_inbound_utility.get_number('GROSS_WEIGHT',null);
    rcd_hdr.net_weight := lics_inbound_utility.get_number('NET_WEIGHT',null);
    rcd_hdr.gross_weight_unit := lics_inbound_utility.get_variable('GROSS_WEIGHT_UNIT');
    rcd_hdr.length := lics_inbound_utility.get_number('LENGTH',null);
    rcd_hdr.width := lics_inbound_utility.get_number('WIDTH',null);
    rcd_hdr.height := lics_inbound_utility.get_number('HEIGHT',null);
    rcd_hdr.dimension_uom := lics_inbound_utility.get_variable('DIMENSION_UOM');
    rcd_hdr.interntl_article_no := lics_inbound_utility.get_variable('INTERNTL_ARTICLE_NO');
    rcd_hdr.total_shelf_life := lics_inbound_utility.get_number('TOTAL_SHELF_LIFE',null);
    rcd_hdr.mars_plan_item_flag := lics_inbound_utility.get_variable('MARS_PLAN_ITEM_FLAG');
    rcd_hdr.mars_intrmdt_prdct_compnt_flag := lics_inbound_utility.get_variable('MARS_INTRMDT_PRDCT_COMPNT_FLAG');
    rcd_hdr.mars_merchandising_unit_flag := lics_inbound_utility.get_variable('MARS_MERCHANDISING_UNIT_FLAG');
    rcd_hdr.mars_prmotional_material_flag := lics_inbound_utility.get_variable('MARS_PRMOTIONAL_MATERIAL_FLAG');
    rcd_hdr.mars_retail_sales_unit_flag := lics_inbound_utility.get_variable('MARS_RETAIL_SALES_UNIT_FLAG');
    rcd_hdr.mars_shpping_contnr_flag := lics_inbound_utility.get_variable('MARS_SHPPING_CONTNR_FLAG');
    rcd_hdr.mars_semi_finished_prdct_flag := lics_inbound_utility.get_variable('MARS_SEMI_FINISHED_PRDCT_FLAG');
    rcd_hdr.mars_rprsnttv_item_flag := lics_inbound_utility.get_variable('MARS_RPRSNTTV_ITEM_FLAG');
    rcd_hdr.mars_traded_unit_flag := lics_inbound_utility.get_variable('MARS_TRADED_UNIT_FLAG');
    rcd_hdr.xplant_status := lics_inbound_utility.get_variable('XPLANT_STATUS');
    rcd_hdr.xplant_status_valid := lics_inbound_utility.get_date('XPLANT_STATUS_VALID','yyyymmddhh24miss');
    rcd_hdr.batch_mngmnt_reqrmnt_indctr := lics_inbound_utility.get_variable('BATCH_MNGMNT_REQRMNT_INDCTR');
    rcd_hdr.mars_plant_material_type := lics_inbound_utility.get_number('MARS_PLANT_MATERIAL_TYPE',null);
    rcd_hdr.procurement_type := lics_inbound_utility.get_variable('PROCUREMENT_TYPE');
    rcd_hdr.special_procurement_type := lics_inbound_utility.get_variable('SPECIAL_PROCUREMENT_TYPE');
    rcd_hdr.issue_storage_location := lics_inbound_utility.get_variable('ISSUE_STORAGE_LOCATION');
    rcd_hdr.mrp_controller := lics_inbound_utility.get_variable('MRP_CONTROLLER');
    rcd_hdr.plant_specific_status_valid := lics_inbound_utility.get_date('PLANT_SPECIFIC_STATUS_VALID','yyyymmddhh24miss');
    rcd_hdr.deletion_indctr := lics_inbound_utility.get_variable('DELETION_INDCTR');
    rcd_hdr.plant_specific_status := lics_inbound_utility.get_variable('PLANT_SPECIFIC_STATUS');
    rcd_hdr.assembly_scrap_percntg := lics_inbound_utility.get_number('ASSEMBLY_SCRAP_PERCNTG',null);
    rcd_hdr.component_scrap_percntg := lics_inbound_utility.get_number('COMPONENT_SCRAP_PERCNTG',null);
    rcd_hdr.backflush_indctr := lics_inbound_utility.get_variable('BACKFLUSH_INDCTR');
    rcd_hdr.mars_rprsnttv_item_code := lics_inbound_utility.get_variable('MARS_RPRSNTTV_ITEM_CODE');
    rcd_hdr.regional_code_10 := lics_inbound_utility.get_variable('REGIONAL_CODE_10');
    rcd_hdr.regional_code_17 := lics_inbound_utility.get_variable('REGIONAL_CODE_17');
    rcd_hdr.regional_code_18 := lics_inbound_utility.get_variable('REGIONAL_CODE_18');
    rcd_hdr.regional_code_19 := lics_inbound_utility.get_variable('REGIONAL_CODE_19');
    rcd_hdr.bds_unit_cost := lics_inbound_utility.get_number('BDS_UNIT_COST',null);
    rcd_hdr.future_planned_price_1 := lics_inbound_utility.get_number('FUTURE_PLANNED_PRICE_1',null);
    rcd_hdr.vltn_class := lics_inbound_utility.get_variable('VLTN_CLASS');
    rcd_hdr.bds_pce_factor_from_base_uom := lics_inbound_utility.get_number('BDS_PCE_FACTOR_FROM_BASE_UOM',null);
    rcd_hdr.mars_pce_item_code := lics_inbound_utility.get_variable('MARS_PCE_ITEM_CODE');
    rcd_hdr.mars_pce_interntl_article_no := lics_inbound_utility.get_variable('MARS_PCE_INTERNTL_ARTICLE_NO');
    rcd_hdr.bds_sb_factor_from_base_uom := lics_inbound_utility.get_variable('BDS_SB_FACTOR_FROM_BASE_UOM');
    rcd_hdr.mars_sb_item_code := lics_inbound_utility.get_variable('MARS_SB_ITEM_CODE');
    rcd_hdr.discontinuation_indctr := lics_inbound_utility.get_variable('DISCONTINUATION_INDCTR');
    rcd_hdr.followup_material := lics_inbound_utility.get_variable('FOLLOWUP_MATERIAL');
    rcd_hdr.material_division := lics_inbound_utility.get_variable('MATERIAL_DIVISION');
    rcd_hdr.mrp_type := lics_inbound_utility.get_variable('MRP_TYPE');
    rcd_hdr.max_storage_prd := lics_inbound_utility.get_number('MAX_STORAGE_PRD',null);
    rcd_hdr.max_storage_prd_unit := lics_inbound_utility.get_variable('MAX_STORAGE_PRD_UNIT');
    rcd_hdr.issue_unit := lics_inbound_utility.get_variable('ISSUE_UNIT');
    rcd_hdr.planned_delivery_days := lics_inbound_utility.get_number('PLANNED_DELIVERY_DAYS',null);
    rcd_hdr.effective_out_date := lics_inbound_utility.get_date('EFFECTIVE_OUT_DATE','yyyymmddhh24miss'); 

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
    if ( rcd_hdr.sap_material_code is null ) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_MATERIAL_CODE');
      var_trn_error := true;
    end if;
    
    if ( rcd_hdr.plant_code is null) then
      lics_inbound_utility.add_exception('Missing Primary Key - HDR.PLANT_CODE');
      var_trn_error := true;
    end if;
             
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;
    
    insert into bds_material_plant_mfanz_test
    (
      sap_material_code,
      plant_code,
      bds_material_desc_en,
      material_type,
      material_grp,
      base_uom,
      order_unit,
      gross_weight,
      net_weight,
      gross_weight_unit,
      length,
      width,
      height,
      dimension_uom,
      interntl_article_no,
      total_shelf_life,
      mars_plan_item_flag,
      mars_intrmdt_prdct_compnt_flag,
      mars_merchandising_unit_flag,
      mars_prmotional_material_flag,
      mars_retail_sales_unit_flag,
      mars_shpping_contnr_flag,
      mars_semi_finished_prdct_flag,
      mars_rprsnttv_item_flag,
      mars_traded_unit_flag,
      xplant_status,
      xplant_status_valid,
      batch_mngmnt_reqrmnt_indctr,
      mars_plant_material_type,
      procurement_type,
      special_procurement_type,
      issue_storage_location,
      mrp_controller,
      plant_specific_status_valid,
      deletion_indctr,
      plant_specific_status,
      assembly_scrap_percntg,
      component_scrap_percntg,
      backflush_indctr,
      mars_rprsnttv_item_code,
      regional_code_10,
      regional_code_17,
      regional_code_18,
      regional_code_19,
      bds_unit_cost,
      future_planned_price_1,
      vltn_class,
      bds_pce_factor_from_base_uom,
      mars_pce_item_code,
      mars_pce_interntl_article_no,
      bds_sb_factor_from_base_uom,
      mars_sb_item_code,
      discontinuation_indctr,
      followup_material,
      material_division,
      mrp_type,
      max_storage_prd,
      max_storage_prd_unit,
      issue_unit,
      planned_delivery_days,
      effective_out_date,
      msg_timestamp
    )
    values 
    (
      rcd_hdr.sap_material_code,
      rcd_hdr.plant_code,
      rcd_hdr.bds_material_desc_en,
      rcd_hdr.material_type,
      rcd_hdr.material_grp,
      rcd_hdr.base_uom,
      rcd_hdr.order_unit,
      rcd_hdr.gross_weight,
      rcd_hdr.net_weight,
      rcd_hdr.gross_weight_unit,
      rcd_hdr.length,
      rcd_hdr.width,
      rcd_hdr.height,
      rcd_hdr.dimension_uom,
      rcd_hdr.interntl_article_no,
      rcd_hdr.total_shelf_life,
      rcd_hdr.mars_plan_item_flag,
      rcd_hdr.mars_intrmdt_prdct_compnt_flag,
      rcd_hdr.mars_merchandising_unit_flag,
      rcd_hdr.mars_prmotional_material_flag,
      rcd_hdr.mars_retail_sales_unit_flag,
      rcd_hdr.mars_shpping_contnr_flag,
      rcd_hdr.mars_semi_finished_prdct_flag,
      rcd_hdr.mars_rprsnttv_item_flag,
      rcd_hdr.mars_traded_unit_flag,
      rcd_hdr.xplant_status,
      rcd_hdr.xplant_status_valid,
      rcd_hdr.batch_mngmnt_reqrmnt_indctr,
      rcd_hdr.mars_plant_material_type,
      rcd_hdr.procurement_type,
      rcd_hdr.special_procurement_type,
      rcd_hdr.issue_storage_location,
      rcd_hdr.mrp_controller,
      rcd_hdr.plant_specific_status_valid,
      rcd_hdr.deletion_indctr,
      rcd_hdr.plant_specific_status,
      rcd_hdr.assembly_scrap_percntg,
      rcd_hdr.component_scrap_percntg,
      rcd_hdr.backflush_indctr,
      rcd_hdr.mars_rprsnttv_item_code,
      rcd_hdr.regional_code_10,
      rcd_hdr.regional_code_17,
      rcd_hdr.regional_code_18,
      rcd_hdr.regional_code_19,
      rcd_hdr.bds_unit_cost,
      rcd_hdr.future_planned_price_1,
      rcd_hdr.vltn_class,
      rcd_hdr.bds_pce_factor_from_base_uom,
      rcd_hdr.mars_pce_item_code,
      rcd_hdr.mars_pce_interntl_article_no,
      rcd_hdr.bds_sb_factor_from_base_uom,
      rcd_hdr.mars_sb_item_code,
      rcd_hdr.discontinuation_indctr,
      rcd_hdr.followup_material,
      rcd_hdr.material_division,
      rcd_hdr.mrp_type,
      rcd_hdr.max_storage_prd,
      rcd_hdr.max_storage_prd_unit,
      rcd_hdr.issue_unit,
      rcd_hdr.planned_delivery_days,
      rcd_hdr.effective_out_date,
      rcd_hdr.msg_timestamp
    );

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
   
  /**************************************************/
  /* This procedure performs the record STX routine */
  /**************************************************/
  procedure process_record_stx(par_record in varchar2) is

    /*-*/
    /* Local definitions 
    /*-*/
    var_country_code number(5,0);

  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/
    if ( var_trn_ignore = true ) then
      return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('STX', par_record);

    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */
    /*--------------------------------------*/
    
    var_country_code := nvl(lics_inbound_utility.get_number('COUNTRY_CODE', null), 0);
    
    if ( var_country_code = 147 ) then
      rcd_hdr.sales_text_147 := lics_inbound_utility.get_variable('SALES_TEXT');
    elsif ( var_country_code = 149 ) then
      rcd_hdr.sales_text_149 := lics_inbound_utility.get_variable('SALES_TEXT');
    else
      lics_inbound_utility.add_exception('Invalid country code - var_country_code');
      var_trn_error := true;
    end if;
      
    /*-*/
    /* Retrieve exceptions raised 
    /*-*/
    if ( lics_inbound_utility.has_errors = true ) then
      var_trn_error := true;
    end if;

    /*-------------------------------------------*/
    /* ERROR - Ignore the data row when required */
    /*-------------------------------------------*/
    if ( var_trn_error = true ) then
      return;
    end if;

    /*------------------------------*/
    /* UPDATE - Update the database */
    /*------------------------------*/
    if ( var_country_code = 147 ) then    
      update bds_material_plant_mfanz_test
      set sales_text_147 = rcd_hdr.sales_text_147
      where sap_material_code = rcd_hdr.sap_material_code
        and plant_code = rcd_hdr.plant_code;
    elsif ( var_country_code = 149 ) then
      update bds_material_plant_mfanz_test
      set sales_text_149 = rcd_hdr.sales_text_149
      where sap_material_code = rcd_hdr.sap_material_code
        and plant_code = rcd_hdr.plant_code;
    end if;

  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_stx;  

  /**************************************************/
  /* This procedure performs the record PKG routine */
  /**************************************************/
  procedure process_record_pkg(par_record in varchar2) is
                        
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/

    if var_trn_ignore = true then
       return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('PKG', par_record);    
      
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/
    rcd_pkg.pkg_instr_table_usage := lics_inbound_utility.get_variable('PKG_INSTR_TABLE_USAGE');
    rcd_pkg.pkg_instr_table := lics_inbound_utility.get_variable('PKG_INSTR_TABLE');
    rcd_pkg.pkg_instr_type := lics_inbound_utility.get_variable('PKG_INSTR_TYPE');
    rcd_pkg.pkg_instr_application := lics_inbound_utility.get_variable('PKG_INSTR_APPLICATION');
    rcd_pkg.item_ctgry := lics_inbound_utility.get_variable('ITEM_CTGRY');
    rcd_pkg.sales_organisation := lics_inbound_utility.get_variable('SALES_ORGANISATION');
    rcd_pkg.component := lics_inbound_utility.get_variable('COMPONENT');
    rcd_pkg.pkg_instr_start_date := lics_inbound_utility.get_date('PKG_INSTR_START_DATE','yyyymmddhh24miss');
    rcd_pkg.pkg_instr_end_date := lics_inbound_utility.get_date('PKG_INSTR_END_DATE','yyyymmddhh24miss');
    rcd_pkg.variable_key := lics_inbound_utility.get_variable('VARIABLE_KEY');
    rcd_pkg.height := lics_inbound_utility.get_number('HEIGHT',null);
    rcd_pkg.width := lics_inbound_utility.get_number('WIDTH',null);
    rcd_pkg.length := lics_inbound_utility.get_number('LENGTH',null);
    rcd_pkg.hu_total_weight := lics_inbound_utility.get_number('HU_TOTAL_WEIGHT',null);
    rcd_pkg.hu_total_volume := lics_inbound_utility.get_number('HU_TOTAL_VOLUME',null);
    rcd_pkg.dimension_uom := lics_inbound_utility.get_variable('DIMENSION_UOM');
    rcd_pkg.weight_unit := lics_inbound_utility.get_variable('WEIGHT_UNIT');
    rcd_pkg.volume_unit := lics_inbound_utility.get_variable('VOLUME_UNIT');
    rcd_pkg.target_qty := lics_inbound_utility.get_number('TARGET_QTY',null);
    rcd_pkg.rounding_qty := lics_inbound_utility.get_number('ROUNDING_QTY',null);
    rcd_pkg.uom := lics_inbound_utility.get_variable('UOM');     

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
    if ( rcd_pkg.pkg_instr_table_usage is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.PKG_INSTR_TABLE_USAGE');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.pkg_instr_table is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.PKG_INSTR_TABLE');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.pkg_instr_type is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.PKG_INSTR_TYPE');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.pkg_instr_application is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.PKG_INSTR_APPLICATION');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.pkg_instr_start_date is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.PKG_INSTR_START_DATE');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.pkg_instr_end_date is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.PKG_INSTR_END_DATE');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.sales_organisation is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.SALES_ORGANISATION');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.item_ctgry is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.ITEM_CTGRY');
       var_trn_error := true;
    end if;
    if ( rcd_pkg.component is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - PKG.COMPONENT');
       var_trn_error := true;
    end if;    
            
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
       return;
    end if;

    /*----------------------------------------*/
    /* LOCK- Lock the interface transaction   */
    /*----------------------------------------*/

    /*-*/
    /* Lock the transaction 
    /* NOTE - attempt to lock the transaction header row (oracle default wait behaviour) 
    /*          - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index 
    /*          - update/update (exists) - logic goes to update and default wait behaviour 
    /*      - validate the IDOC sequence when locking row exists 
    /*      - lock and commit cycle encompasses transaction child procedure execution 
    /*-*/
    insert into bds_material_pkg_instr_det_t
    (
      sap_material_code,
      pkg_instr_table_usage,
      pkg_instr_table,
      pkg_instr_type,
      pkg_instr_application,
      item_ctgry,
      sales_organisation,
      component,
      pkg_instr_start_date,
      pkg_instr_end_date,
      variable_key,
      height,
      width,
      length,
      hu_total_weight,
      hu_total_volume,
      dimension_uom,
      weight_unit,
      volume_unit,
      target_qty,
      rounding_qty,
      uom
    )
    values 
    (
      rcd_hdr.sap_material_code,
      rcd_pkg.pkg_instr_table_usage,
      rcd_pkg.pkg_instr_table,
      rcd_pkg.pkg_instr_type,
      rcd_pkg.pkg_instr_application,
      rcd_pkg.item_ctgry,
      rcd_pkg.sales_organisation,
      rcd_pkg.component,
      rcd_pkg.pkg_instr_start_date,
      rcd_pkg.pkg_instr_end_date,
      rcd_pkg.variable_key,
      rcd_pkg.height,
      rcd_pkg.width,
      rcd_pkg.length,
      rcd_pkg.hu_total_weight,
      rcd_pkg.hu_total_volume,
      rcd_pkg.dimension_uom,
      rcd_pkg.weight_unit,
      rcd_pkg.volume_unit,
      rcd_pkg.target_qty,
      rcd_pkg.rounding_qty,
      rcd_pkg.uom
    );
     
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_pkg;
  
  /**************************************************/
  /* This procedure performs the record UOM routine */
  /**************************************************/
  procedure process_record_uom(par_record in varchar2) is
                        
  /*-------------*/
  /* Begin block */
  /*-------------*/
  begin

    /*--------------------------------------------*/
    /* IGNORE - Ignore the data row when required */
    /*--------------------------------------------*/

    if var_trn_ignore = true then
       return;
    end if;

    /*-------------------------------*/
    /* PARSE - Parse the data record */
    /*-------------------------------*/
    lics_inbound_utility.parse_record('UOM', par_record);    
      
    /*--------------------------------------*/
    /* RETRIEVE - Retrieve the field values */  
    /*--------------------------------------*/    
    rcd_uom.uom_code := lics_inbound_utility.get_variable('UOM_CODE');  
    rcd_uom.sap_function := lics_inbound_utility.get_variable('SAP_FUNCTION');  
    rcd_uom.base_uom_numerator := lics_inbound_utility.get_number('BASE_UOM_NUMERATOR', null);  
    rcd_uom.base_uom_denominator := lics_inbound_utility.get_number('BASE_UOM_DENOMINATOR', null);  
    rcd_uom.bds_factor_to_base_uom := lics_inbound_utility.get_number('BDS_FACTOR_TO_BASE_UOM', null);  
    rcd_uom.bds_factor_from_base_uom := lics_inbound_utility.get_number('BDS_FACTOR_FROM_BASE_UOM', null);  
    rcd_uom.interntl_article_no := lics_inbound_utility.get_variable('INTERNTL_ARTICLE_NO');  
    rcd_uom.interntl_article_no_ctgry := lics_inbound_utility.get_variable('INTERNTL_ARTICLE_NO_CTGRY');  
    rcd_uom.length := lics_inbound_utility.get_number('LENGTH', null);  
    rcd_uom.width := lics_inbound_utility.get_number('WIDTH', null);  
    rcd_uom.height := lics_inbound_utility.get_number('HEIGHT', null);  
    rcd_uom.dimension_uom := lics_inbound_utility.get_variable('DIMENSION_UOM');  
    rcd_uom.volume := lics_inbound_utility.get_number('VOLUME', null);  
    rcd_uom.volume_unit := lics_inbound_utility.get_variable('VOLUME_UNIT');  
    rcd_uom.gross_weight := lics_inbound_utility.get_number('GROSS_WEIGHT', null);  
    rcd_uom.gross_weight_unit := lics_inbound_utility.get_variable('GROSS_WEIGHT_UNIT');  
    rcd_uom.lower_level_hierachy_uom := lics_inbound_utility.get_variable('LOWER_LEVEL_HIERACHY_UOM');  
    rcd_uom.global_trade_item_variant := lics_inbound_utility.get_variable('GLOBAL_TRADE_ITEM_VARIANT');  
    rcd_uom.mars_mutli_convrsn_uom_indctr := lics_inbound_utility.get_variable('MARS_MUTLI_CONVRSN_UOM_INDCTR');  
    rcd_uom.mars_pc_item_code := lics_inbound_utility.get_variable('MARS_PC_ITEM_CODE');  
    rcd_uom.mars_pc_level := lics_inbound_utility.get_number('MARS_PC_LEVEL', null);  
    rcd_uom.mars_order_uom_prfrnc_indctr := lics_inbound_utility.get_variable('MARS_ORDER_UOM_PRFRNC_INDCTR');  
    rcd_uom.mars_sales_uom_prfrnc_indctr := lics_inbound_utility.get_variable('MARS_SALES_UOM_PRFRNC_INDCTR');  
    rcd_uom.mars_issue_uom_prfrnc_indctr := lics_inbound_utility.get_variable('MARS_ISSUE_UOM_PRFRNC_INDCTR');  
    rcd_uom.mars_wm_uom_prfrnc_indctr := lics_inbound_utility.get_variable('MARS_WM_UOM_PRFRNC_INDCTR');  
    rcd_uom.mars_rprsnttv_material_code := lics_inbound_utility.get_variable('MARS_RPRSNTTV_MATERIAL_CODE');  

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
    if ( rcd_uom.uom_code is null ) then
       lics_inbound_utility.add_exception('Missing Primary Key - UOM.UOM_CODE');
       var_trn_error := TRUE;
    end if;
            
    /*----------------------------------------*/
    /* ERROR- Bypass the update when required */
    /*----------------------------------------*/
    if ( var_trn_error = true ) then
       return;
    end if;

    /*----------------------------------------*/
    /* LOCK- Lock the interface transaction   */
    /*----------------------------------------*/

    /*-*/
    /* Lock the transaction 
    /* NOTE - attempt to lock the transaction header row (oracle default wait behaviour) 
    /*          - insert/insert (not exists) - first holds lock and second fails on first commit with duplicate index 
    /*          - update/update (exists) - logic goes to update and default wait behaviour 
    /*      - validate the IDOC sequence when locking row exists 
    /*      - lock and commit cycle encompasses transaction child procedure execution 
    /*-*/
    insert into bds_material_uom
    (
      sap_material_code,
      uom_code,
      sap_function,
      base_uom_numerator,
      base_uom_denominator,
      bds_factor_to_base_uom,
      bds_factor_from_base_uom,
      interntl_article_no,
      interntl_article_no_ctgry,
      length,
      width,
      height,
      dimension_uom,
      volume,
      volume_unit,
      gross_weight,
      gross_weight_unit,
      lower_level_hierachy_uom,
      global_trade_item_variant,
      mars_mutli_convrsn_uom_indctr,
      mars_pc_item_code,
      mars_pc_level,
      mars_order_uom_prfrnc_indctr,
      mars_sales_uom_prfrnc_indctr,
      mars_issue_uom_prfrnc_indctr,
      mars_wm_uom_prfrnc_indctr,
      mars_rprsnttv_material_code
    )
    values 
    (
      rcd_hdr.sap_material_code,
      rcd_uom.uom_code,
      rcd_uom.sap_function,
      rcd_uom.base_uom_numerator,
      rcd_uom.base_uom_denominator,
      rcd_uom.bds_factor_to_base_uom,
      rcd_uom.bds_factor_from_base_uom,
      rcd_uom.interntl_article_no,
      rcd_uom.interntl_article_no_ctgry,
      rcd_uom.length,
      rcd_uom.width,
      rcd_uom.height,
      rcd_uom.dimension_uom,
      rcd_uom.volume,
      rcd_uom.volume_unit,
      rcd_uom.gross_weight,
      rcd_uom.gross_weight_unit,
      rcd_uom.lower_level_hierachy_uom,
      rcd_uom.global_trade_item_variant,
      rcd_uom.mars_mutli_convrsn_uom_indctr,
      rcd_uom.mars_pc_item_code,
      rcd_uom.mars_pc_level,
      rcd_uom.mars_order_uom_prfrnc_indctr,
      rcd_uom.mars_sales_uom_prfrnc_indctr,
      rcd_uom.mars_issue_uom_prfrnc_indctr,
      rcd_uom.mars_wm_uom_prfrnc_indctr,
      rcd_uom.mars_rprsnttv_material_code
    );
     
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_uom;  
  
end ladpdb02_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.ladpdb02_loader to appsupport;
grant execute on bds_app.ladpdb02_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym ladpdb02_loader for bds_app.ladpdb02_loader;