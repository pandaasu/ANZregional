/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/** 
  System  : Plant Database 
  Package : plant_material_classfctn_loader 
  Owner   : bds_app 
  Author  : Trevor Keon 

  Description 
  ----------- 
  Plant Database - Inbound material classification loader 

  dd-mmm-yyyy  Author           Description 
  -----------  ------           ----------- 
  28-Mar-2008  Trevor Keon      Created 
*******************************************************************************/

create or replace package bds_app.plant_material_classfctn_loader as

  /*-*/
  /* Public declarations 
  /*-*/
  procedure on_start;
  procedure on_data (par_record in varchar2);
  procedure on_end;
   
end plant_material_classfctn_loader; 
/

create or replace package body bds_app.plant_material_classfctn_loader as

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
  
  rcd_hdr bds_material_classfctn%rowtype;

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
    lics_inbound_utility.set_definition('HDR','SAP_MATERIAL_CODE', 18);
    lics_inbound_utility.set_definition('HDR','BDS_LADS_DATE', 14);
    lics_inbound_utility.set_definition('HDR','BDS_LADS_STATUS', 2);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_NAME', 30);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_NUMBER', 38);
    lics_inbound_utility.set_definition('HDR','SAP_IDOC_TIMESTAMP', 14);
    lics_inbound_utility.set_definition('HDR','SAP_BUS_SGMNT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_MRKT_SGMNT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_BRAND_FLAG_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_FUNCL_VRTY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_INGRDNT_VRTY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_BRAND_SUB_FLAG_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_SUPPLY_SGMNT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_TRADE_SECTOR_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_OCCSN_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_MRKTING_CONCPT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_MULTI_PACK_QTY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PRDCT_CTGRY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PACK_TYPE_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_SIZE_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_SIZE_GRP_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PRDCT_TYPE_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_TRAD_UNIT_CONFIG_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_TRAD_UNIT_FRMT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_DSPLY_STORG_CONDTN_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_ONPACK_CNSMR_VALUE_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_ONPACK_CNSMR_OFFER_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_ONPACK_TRADE_OFFER_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_BRAND_ESSNC_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_CNSMR_PACK_FRMT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_CUISINE_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_FPPS_MINOR_PACK_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_FIGHTING_UNIT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_CHINA_BDT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_MRKT_CTGRY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_MRKT_SUB_CTGRY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_MRKT_SUB_CTGRY_GRP_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_SOP_BUS_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PRODCTN_LINE_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PLANNING_SRC_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_SUB_FIGHTING_UNIT_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_RAW_FAMILY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_RAW_SUB_FAMILY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_RAW_GROUP_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_ANIMAL_PARTS_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PHYSICAL_CONDTN_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PACK_FAMILY_CODE', 30);
    lics_inbound_utility.set_definition('HDR','SAP_PACK_SUB_FAMILY_CODE', 30);
      
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
    rcd_hdr.sap_material_code := lics_inbound_utility.get_variable('SAP_MATERIAL_CODE');
    rcd_hdr.bds_lads_date := lics_inbound_utility.get_variable('BDS_LADS_DATE');
    rcd_hdr.bds_lads_status := lics_inbound_utility.get_variable('BDS_LADS_STATUS');
    rcd_hdr.sap_idoc_name := lics_inbound_utility.get_variable('SAP_IDOC_NAME');
    rcd_hdr.sap_idoc_number := lics_inbound_utility.get_variable('SAP_IDOC_NUMBER');
    rcd_hdr.sap_idoc_timestamp := lics_inbound_utility.get_variable('SAP_IDOC_TIMESTAMP');
    rcd_hdr.sap_bus_sgmnt_code := lics_inbound_utility.get_variable('SAP_BUS_SGMNT_CODE');
    rcd_hdr.sap_mrkt_sgmnt_code := lics_inbound_utility.get_variable('SAP_MRKT_SGMNT_CODE');
    rcd_hdr.sap_brand_flag_code := lics_inbound_utility.get_variable('SAP_BRAND_FLAG_CODE');
    rcd_hdr.sap_funcl_vrty_code := lics_inbound_utility.get_variable('SAP_FUNCL_VRTY_CODE');
    rcd_hdr.sap_ingrdnt_vrty_code := lics_inbound_utility.get_variable('SAP_INGRDNT_VRTY_CODE');
    rcd_hdr.sap_brand_sub_flag_code := lics_inbound_utility.get_variable('SAP_BRAND_SUB_FLAG_CODE');
    rcd_hdr.sap_supply_sgmnt_code := lics_inbound_utility.get_variable('SAP_SUPPLY_SGMNT_CODE');
    rcd_hdr.sap_trade_sector_code := lics_inbound_utility.get_variable('SAP_TRADE_SECTOR_CODE');
    rcd_hdr.sap_occsn_code := lics_inbound_utility.get_variable('SAP_OCCSN_CODE');
    rcd_hdr.sap_mrkting_concpt_code := lics_inbound_utility.get_variable('SAP_MRKTING_CONCPT_CODE');
    rcd_hdr.sap_multi_pack_qty_code := lics_inbound_utility.get_variable('SAP_MULTI_PACK_QTY_CODE');
    rcd_hdr.sap_prdct_ctgry_code := lics_inbound_utility.get_variable('SAP_PRDCT_CTGRY_CODE');
    rcd_hdr.sap_pack_type_code := lics_inbound_utility.get_variable('SAP_PACK_TYPE_CODE');
    rcd_hdr.sap_size_code := lics_inbound_utility.get_variable('SAP_SIZE_CODE');
    rcd_hdr.sap_size_grp_code := lics_inbound_utility.get_variable('SAP_SIZE_GRP_CODE');
    rcd_hdr.sap_prdct_type_code := lics_inbound_utility.get_variable('SAP_PRDCT_TYPE_CODE');
    rcd_hdr.sap_trad_unit_config_code := lics_inbound_utility.get_variable('SAP_TRAD_UNIT_CONFIG_CODE');
    rcd_hdr.sap_trad_unit_frmt_code := lics_inbound_utility.get_variable('SAP_TRAD_UNIT_FRMT_CODE');
    rcd_hdr.sap_dsply_storg_condtn_code := lics_inbound_utility.get_variable('SAP_DSPLY_STORG_CONDTN_CODE');
    rcd_hdr.sap_onpack_cnsmr_value_code := lics_inbound_utility.get_variable('SAP_ONPACK_CNSMR_VALUE_CODE');
    rcd_hdr.sap_onpack_cnsmr_offer_code := lics_inbound_utility.get_variable('SAP_ONPACK_CNSMR_OFFER_CODE');
    rcd_hdr.sap_onpack_trade_offer_code := lics_inbound_utility.get_variable('SAP_ONPACK_TRADE_OFFER_CODE');
    rcd_hdr.sap_brand_essnc_code := lics_inbound_utility.get_variable('SAP_BRAND_ESSNC_CODE');
    rcd_hdr.sap_cnsmr_pack_frmt_code := lics_inbound_utility.get_variable('SAP_CNSMR_PACK_FRMT_CODE');
    rcd_hdr.sap_cuisine_code := lics_inbound_utility.get_variable('SAP_CUISINE_CODE');
    rcd_hdr.sap_fpps_minor_pack_code := lics_inbound_utility.get_variable('SAP_FPPS_MINOR_PACK_CODE');
    rcd_hdr.sap_fighting_unit_code := lics_inbound_utility.get_variable('SAP_FIGHTING_UNIT_CODE');
    rcd_hdr.sap_china_bdt_code := lics_inbound_utility.get_variable('SAP_CHINA_BDT_CODE');
    rcd_hdr.sap_mrkt_ctgry_code := lics_inbound_utility.get_variable('SAP_MRKT_CTGRY_CODE');
    rcd_hdr.sap_mrkt_sub_ctgry_code := lics_inbound_utility.get_variable('SAP_MRKT_SUB_CTGRY_CODE');
    rcd_hdr.sap_mrkt_sub_ctgry_grp_code := lics_inbound_utility.get_variable('SAP_MRKT_SUB_CTGRY_GRP_CODE');
    rcd_hdr.sap_sop_bus_code := lics_inbound_utility.get_variable('SAP_SOP_BUS_CODE');
    rcd_hdr.sap_prodctn_line_code := lics_inbound_utility.get_variable('SAP_PRODCTN_LINE_CODE');
    rcd_hdr.sap_planning_src_code := lics_inbound_utility.get_variable('SAP_PLANNING_SRC_CODE');
    rcd_hdr.sap_sub_fighting_unit_code := lics_inbound_utility.get_variable('SAP_SUB_FIGHTING_UNIT_CODE');
    rcd_hdr.sap_raw_family_code := lics_inbound_utility.get_variable('SAP_RAW_FAMILY_CODE');
    rcd_hdr.sap_raw_sub_family_code := lics_inbound_utility.get_variable('SAP_RAW_SUB_FAMILY_CODE');
    rcd_hdr.sap_raw_group_code := lics_inbound_utility.get_variable('SAP_RAW_GROUP_CODE');
    rcd_hdr.sap_animal_parts_code := lics_inbound_utility.get_variable('SAP_ANIMAL_PARTS_CODE');
    rcd_hdr.sap_physical_condtn_code := lics_inbound_utility.get_variable('SAP_PHYSICAL_CONDTN_CODE');
    rcd_hdr.sap_pack_family_code := lics_inbound_utility.get_variable('SAP_PACK_FAMILY_CODE');
    rcd_hdr.sap_pack_sub_family_code := lics_inbound_utility.get_variable('SAP_PACK_SUB_FAMILY_CODE');
    
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
    update bds_refrnc_hdr_altrnt
    set sap_material_code = rcd_hdr.sap_material_code,
      bds_lads_date = rcd_hdr.bds_lads_date,
      bds_lads_status = rcd_hdr.bds_lads_status,
      sap_idoc_name = rcd_hdr.sap_idoc_name,
      sap_idoc_number = rcd_hdr.sap_idoc_number,
      sap_idoc_timestamp = rcd_hdr.sap_idoc_timestamp,
      sap_bus_sgmnt_code = rcd_hdr.sap_bus_sgmnt_code,
      sap_mrkt_sgmnt_code = rcd_hdr.sap_mrkt_sgmnt_code,
      sap_brand_flag_code = rcd_hdr.sap_brand_flag_code,
      sap_funcl_vrty_code = rcd_hdr.sap_funcl_vrty_code,
      sap_ingrdnt_vrty_code = rcd_hdr.sap_ingrdnt_vrty_code,
      sap_brand_sub_flag_code = rcd_hdr.sap_brand_sub_flag_code,
      sap_supply_sgmnt_code = rcd_hdr.sap_supply_sgmnt_code,
      sap_trade_sector_code = rcd_hdr.sap_trade_sector_code,
      sap_occsn_code = rcd_hdr.sap_occsn_code,
      sap_mrkting_concpt_code = rcd_hdr.sap_mrkting_concpt_code,
      sap_multi_pack_qty_code = rcd_hdr.sap_multi_pack_qty_code,
      sap_prdct_ctgry_code = rcd_hdr.sap_prdct_ctgry_code,
      sap_pack_type_code = rcd_hdr.sap_pack_type_code,
      sap_size_code = rcd_hdr.sap_size_code,
      sap_size_grp_code = rcd_hdr.sap_size_grp_code,
      sap_prdct_type_code = rcd_hdr.sap_prdct_type_code,
      sap_trad_unit_config_code = rcd_hdr.sap_trad_unit_config_code,
      sap_trad_unit_frmt_code = rcd_hdr.sap_trad_unit_frmt_code,
      sap_dsply_storg_condtn_code = rcd_hdr.sap_dsply_storg_condtn_code,
      sap_onpack_cnsmr_value_code = rcd_hdr.sap_onpack_cnsmr_value_code,
      sap_onpack_cnsmr_offer_code = rcd_hdr.sap_onpack_cnsmr_offer_code,
      sap_onpack_trade_offer_code = rcd_hdr.sap_onpack_trade_offer_code,
      sap_brand_essnc_code = rcd_hdr.sap_brand_essnc_code,
      sap_cnsmr_pack_frmt_code = rcd_hdr.sap_cnsmr_pack_frmt_code,
      sap_cuisine_code = rcd_hdr.sap_cuisine_code,
      sap_fpps_minor_pack_code = rcd_hdr.sap_fpps_minor_pack_code,
      sap_fighting_unit_code = rcd_hdr.sap_fighting_unit_code,
      sap_china_bdt_code = rcd_hdr.sap_china_bdt_code,
      sap_mrkt_ctgry_code = rcd_hdr.sap_mrkt_ctgry_code,
      sap_mrkt_sub_ctgry_code = rcd_hdr.sap_mrkt_sub_ctgry_code,
      sap_mrkt_sub_ctgry_grp_code = rcd_hdr.sap_mrkt_sub_ctgry_grp_code,
      sap_sop_bus_code = rcd_hdr.sap_sop_bus_code,
      sap_prodctn_line_code = rcd_hdr.sap_prodctn_line_code,
      sap_planning_src_code = rcd_hdr.sap_planning_src_code,
      sap_sub_fighting_unit_code = rcd_hdr.sap_sub_fighting_unit_code,
      sap_raw_family_code = rcd_hdr.sap_raw_family_code,
      sap_raw_sub_family_code = rcd_hdr.sap_raw_sub_family_code,
      sap_raw_group_code = rcd_hdr.sap_raw_group_code,
      sap_animal_parts_code = rcd_hdr.sap_animal_parts_code,
      sap_physical_condtn_code = rcd_hdr.sap_physical_condtn_code,
      sap_pack_family_code = rcd_hdr.sap_pack_family_code,
      sap_pack_sub_family_code = rcd_hdr.sap_pack_sub_family_code
    where bom_material_code = rcd_hdr.bom_material_code
      and bom_alternative = rcd_hdr.bom_alternative
      and bom_plant = rcd_hdr.bom_plant;
    
    if ( sql%notfound ) then    
      insert into bds_refrnc_hdr_altrnt
      (
        sap_material_code, 
        bds_lads_date, 
        bds_lads_status, 
        sap_idoc_name,
        sap_idoc_number, 
        sap_idoc_timestamp, 
        sap_bus_sgmnt_code,
        sap_mrkt_sgmnt_code, 
        sap_brand_flag_code, 
        sap_funcl_vrty_code,
        sap_ingrdnt_vrty_code, 
        sap_brand_sub_flag_code, 
        sap_supply_sgmnt_code,
        sap_trade_sector_code, 
        sap_occsn_code, 
        sap_mrkting_concpt_code,
        sap_multi_pack_qty_code, 
        sap_prdct_ctgry_code, 
        sap_pack_type_code,
        sap_size_code, 
        sap_size_grp_code, 
        sap_prdct_type_code,
        sap_trad_unit_config_code, 
        sap_trad_unit_frmt_code,
        sap_dsply_storg_condtn_code, 
        sap_onpack_cnsmr_value_code,
        sap_onpack_cnsmr_offer_code, 
        sap_onpack_trade_offer_code,
        sap_brand_essnc_code, 
        sap_cnsmr_pack_frmt_code, 
        sap_cuisine_code,
        sap_fpps_minor_pack_code, 
        sap_fighting_unit_code, 
        sap_china_bdt_code,
        sap_mrkt_ctgry_code, 
        sap_mrkt_sub_ctgry_code,
        sap_mrkt_sub_ctgry_grp_code, 
        sap_sop_bus_code, 
        sap_prodctn_line_code,
        sap_planning_src_code, 
        sap_sub_fighting_unit_code, 
        sap_raw_family_code,
        sap_raw_sub_family_code, 
        sap_raw_group_code, 
        sap_animal_parts_code,
        sap_physical_condtn_code, 
        sap_pack_family_code,
        sap_pack_sub_family_code
      )
      values 
      (
        rcd_hdr.sap_material_code, 
        rcd_hdr.bds_lads_date, 
        rcd_hdr.bds_lads_status, 
        rcd_hdr.sap_idoc_name,
        rcd_hdr.sap_idoc_number, 
        rcd_hdr.sap_idoc_timestamp, 
        rcd_hdr.sap_bus_sgmnt_code,
        rcd_hdr.sap_mrkt_sgmnt_code, 
        rcd_hdr.sap_brand_flag_code, 
        rcd_hdr.sap_funcl_vrty_code,
        rcd_hdr.sap_ingrdnt_vrty_code, 
        rcd_hdr.sap_brand_sub_flag_code, 
        rcd_hdr.sap_supply_sgmnt_code,
        rcd_hdr.sap_trade_sector_code, 
        rcd_hdr.sap_occsn_code, 
        rcd_hdr.sap_mrkting_concpt_code,
        rcd_hdr.sap_multi_pack_qty_code, 
        rcd_hdr.sap_prdct_ctgry_code, 
        rcd_hdr.sap_pack_type_code,
        rcd_hdr.sap_size_code, 
        rcd_hdr.sap_size_grp_code, 
        rcd_hdr.sap_prdct_type_code,
        rcd_hdr.sap_trad_unit_config_code, 
        rcd_hdr.sap_trad_unit_frmt_code,
        rcd_hdr.sap_dsply_storg_condtn_code, 
        rcd_hdr.sap_onpack_cnsmr_value_code,
        rcd_hdr.sap_onpack_cnsmr_offer_code, 
        rcd_hdr.sap_onpack_trade_offer_code,
        rcd_hdr.sap_brand_essnc_code, 
        rcd_hdr.sap_cnsmr_pack_frmt_code, 
        rcd_hdr.sap_cuisine_code,
        rcd_hdr.sap_fpps_minor_pack_code, 
        rcd_hdr.sap_fighting_unit_code, 
        rcd_hdr.sap_china_bdt_code,
        rcd_hdr.sap_mrkt_ctgry_code, 
        rcd_hdr.sap_mrkt_sub_ctgry_code,
        rcd_hdr.sap_mrkt_sub_ctgry_grp_code, 
        rcd_hdr.sap_sop_bus_code, 
        rcd_hdr.sap_prodctn_line_code,
        rcd_hdr.sap_planning_src_code, 
        rcd_hdr.sap_sub_fighting_unit_code, 
        rcd_hdr.sap_raw_family_code,
        rcd_hdr.sap_raw_sub_family_code, 
        rcd_hdr.sap_raw_group_code, 
        rcd_hdr.sap_animal_parts_code,
        rcd_hdr.sap_physical_condtn_code, 
        rcd_hdr.sap_pack_family_code,
        rcd_hdr.sap_pack_sub_family_code
      );
    end if;
  
  /*-------------*/
  /* End routine */
  /*-------------*/
  end process_record_hdr;
    
end plant_material_classfctn_loader; 
/

/*-*/
/* Authority 
/*-*/
grant execute on bds_app.plant_material_classfctn_loader to appsupport;
grant execute on bds_app.plant_material_classfctn_loader to lics_app;

/*-*/
/* Synonym 
/*-*/
create or replace public synonym plant_material_classfctn_loader for bds_app.plant_material_classfctn_loader;