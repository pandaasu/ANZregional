create or replace package ladcad01_material as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : CAD
 Package : ladcad01_material
 Owner   : CAD_APP
 Author  : Linden Glen

 Description
 -----------
 China Applications Data - CADLAD01 - Material Master

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Linden Glen    Created
 2008/03   Linden Glen    Added zrep English and Chinese descriptions
                          Added SELL and MAKE MOE identifier for 0168
                          Added Intermediate Component identifier
 2008/05   Linden Glen    Added dstrbtn_chain_status
                          Added lads_change_date (LADS Last Updated timestamp)
                          Added sap_change_date (SAP Last Updated timestamp)

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure on_start;
   procedure on_data(par_record in varchar2);
   procedure on_end;

end ladcad01_material;
/

/****************/
/* Package Body */
/****************/
create or replace package body ladcad01_material as

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
   procedure process_record_inv(par_record in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   var_trn_start boolean;
   var_trn_ignore boolean;
   var_trn_error boolean;
   rcd_cad_material_master cad_material_master%rowtype;
   rcd_cad_material_invntry cad_material_invntry%rowtype;

   /************************************************/
   /* This procedure performs the on start routine */
   /************************************************/
   procedure on_start is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Set the transaction variables
      /*-*/
      var_trn_start := true;
      var_trn_ignore := false;
      var_trn_error := false;

      /*-*/
      /* Delete Material master and inventory entries
      /*-*/
      delete cad_material_invntry;
      delete cad_material_master;

      /*-*/
      /* Initialise the inbound definitions
      /*-*/
      lics_inbound_utility.clear_definition;
      /*-*/
      lics_inbound_utility.set_definition('HDR','IDOC_HDR',3);
      lics_inbound_utility.set_definition('HDR','SAP_MATERIAL_CODE',18);
      lics_inbound_utility.set_definition('HDR','MATERIAL_DESC_CH',40);
      lics_inbound_utility.set_definition('HDR','MATERIAL_DESC_EN',40);
      lics_inbound_utility.set_definition('HDR','MATERIAL_ZREP_CODE',18);
      lics_inbound_utility.set_definition('HDR','MATERIAL_ZREP_DESC_CH',40);
      lics_inbound_utility.set_definition('HDR','MATERIAL_ZREP_DESC_EN',40);
      lics_inbound_utility.set_definition('HDR','NET_WEIGHT',16);
      lics_inbound_utility.set_definition('HDR','GROSS_WEIGHT',16);
      lics_inbound_utility.set_definition('HDR','MATL_LENGTH',16);
      lics_inbound_utility.set_definition('HDR','WIDTH',16);
      lics_inbound_utility.set_definition('HDR','HEIGHT',16);
      lics_inbound_utility.set_definition('HDR','PCS_PER_CASE',16);
      lics_inbound_utility.set_definition('HDR','OUTERS_PER_CASE',16);
      lics_inbound_utility.set_definition('HDR','CASES_PER_PALLET',16);
      lics_inbound_utility.set_definition('HDR','BRAND_ESSNC_CODE',4);
      lics_inbound_utility.set_definition('HDR','BRAND_ESSNC_DESC',30);
      lics_inbound_utility.set_definition('HDR','BRAND_ESSNC_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','BRAND_FLAG_CODE',4);
      lics_inbound_utility.set_definition('HDR','BRAND_FLAG_DESC',30);
      lics_inbound_utility.set_definition('HDR','BRAND_FLAG_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','BRAND_SUB_FLAG_CODE',4);
      lics_inbound_utility.set_definition('HDR','BRAND_SUB_FLAG_DESC',30);
      lics_inbound_utility.set_definition('HDR','BRAND_SUB_FLAG_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','BUS_SGMNT_CODE',4);
      lics_inbound_utility.set_definition('HDR','BUS_SGMNT_DESC',30);
      lics_inbound_utility.set_definition('HDR','BUS_SGMNT_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','MKT_SGMNT_CODE',4);
      lics_inbound_utility.set_definition('HDR','MKT_SGMNT_DESC',30);
      lics_inbound_utility.set_definition('HDR','MKT_SGMNT_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','PRDCT_CTGRY_CODE',4);
      lics_inbound_utility.set_definition('HDR','PRDCT_CTGRY_DESC',30);
      lics_inbound_utility.set_definition('HDR','PRDCT_CTGRY_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','PRDCT_TYPE_CODE',4);
      lics_inbound_utility.set_definition('HDR','PRDCT_TYPE_DESC',30);
      lics_inbound_utility.set_definition('HDR','PRDCT_TYPE_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','CNSMR_PACK_FRMT_CODE',4);
      lics_inbound_utility.set_definition('HDR','CNSMR_PACK_FRMT_DESC',30);
      lics_inbound_utility.set_definition('HDR','CNSMR_PACK_FRMT_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','INGRED_VRTY_CODE',4);
      lics_inbound_utility.set_definition('HDR','INGRED_VRTY_DESC',30);
      lics_inbound_utility.set_definition('HDR','INGRED_VRTY_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','PRDCT_SIZE_GRP_CODE',4);
      lics_inbound_utility.set_definition('HDR','PRDCT_SIZE_GRP_DESC',30);
      lics_inbound_utility.set_definition('HDR','PRDCT_SIZE_GRP_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','PRDCT_PACK_SIZE_CODE',4);
      lics_inbound_utility.set_definition('HDR','PRDCT_PACK_SIZE_DESC',30);
      lics_inbound_utility.set_definition('HDR','PRDCT_PACK_SIZE_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','SALES_ORGANISATION_135',4);
      lics_inbound_utility.set_definition('HDR','SALES_ORGANISATION_234',4);
      lics_inbound_utility.set_definition('HDR','BASE_UOM_CODE',3);
      lics_inbound_utility.set_definition('HDR','MATERIAL_TYPE_CODE',4);
      lics_inbound_utility.set_definition('HDR','MATERIAL_TYPE_DESC',40);
      lics_inbound_utility.set_definition('HDR','MATERIAL_STS_CODE',8);
      lics_inbound_utility.set_definition('HDR','BDT_CODE',2);
      lics_inbound_utility.set_definition('HDR','BDT_DESC',30);
      lics_inbound_utility.set_definition('HDR','BDT_ABBRD_DESC',12);
      lics_inbound_utility.set_definition('HDR','TAX_CLASSIFICATION',1);
      lics_inbound_utility.set_definition('HDR','SELL_MOE_0168',1);
      lics_inbound_utility.set_definition('HDR','MAKE_MOE_0168',1);
      lics_inbound_utility.set_definition('HDR','INTRMDT_PRDCT_COMPNT',1);
      lics_inbound_utility.set_definition('HDR','DSTRBTN_CHAIN_STATUS',2);
      lics_inbound_utility.set_definition('HDR','LADS_UPDATE_DATE',14);
      lics_inbound_utility.set_definition('HDR','SAP_UPDATE_DATE',14);
      /*-*/
      lics_inbound_utility.set_definition('INV','IDOC_INV',3);
      lics_inbound_utility.set_definition('INV','SAP_COMPANY_CODE',6);
      lics_inbound_utility.set_definition('INV','SAP_PLANT_CODE',4);
      lics_inbound_utility.set_definition('INV','INV_EXP_DATE',8);
      lics_inbound_utility.set_definition('INV','INV_UNRELEASED_QTY',16);
      lics_inbound_utility.set_definition('INV','INV_RESERVED_QTY',16);
      lics_inbound_utility.set_definition('INV','INV_CLASS01',3);
      lics_inbound_utility.set_definition('INV','INV_CLASS02',3);

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
         when 'INV' then process_record_inv(par_record);
         else raise_application_error(-20000, 'Record identifier (' || var_record_identifier || ') not recognised');
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
      /* Complete the transaction
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

      /*-*/
      /* Local definitions
      /*-*/
      var_accepted boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* No data processed
      /*-*/
      if var_trn_start = false then
         rollback;
         return;
      end if;

      /*-*/
      /* Commit/rollback the IDOC as required
      /* Execute the interface monitor when required
      /*-*/
      if var_trn_ignore = true then
         var_accepted := true;
         rollback;
      elsif var_trn_error = true then
         var_accepted := false;
         rollback;
      else
         var_accepted := true;
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

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('HDR', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/      
      rcd_cad_material_master.sap_material_code := lics_inbound_utility.get_variable('SAP_MATERIAL_CODE');
      rcd_cad_material_master.material_desc_ch := lics_inbound_utility.get_variable('MATERIAL_DESC_CH');
      rcd_cad_material_master.material_desc_en := lics_inbound_utility.get_variable('MATERIAL_DESC_EN');
      rcd_cad_material_master.material_zrep_code := lics_inbound_utility.get_variable('MATERIAL_ZREP_CODE');
      rcd_cad_material_master.material_zrep_desc_ch := lics_inbound_utility.get_variable('MATERIAL_ZREP_DESC_CH');
      rcd_cad_material_master.material_zrep_desc_en := lics_inbound_utility.get_variable('MATERIAL_ZREP_DESC_EN');
      rcd_cad_material_master.net_weight := lics_inbound_utility.get_number('NET_WEIGHT',null);
      rcd_cad_material_master.gross_weight := lics_inbound_utility.get_number('GROSS_WEIGHT',null);
      rcd_cad_material_master.matl_length := lics_inbound_utility.get_number('MATL_LENGTH',null);
      rcd_cad_material_master.width := lics_inbound_utility.get_number('WIDTH',null);
      rcd_cad_material_master.height := lics_inbound_utility.get_number('HEIGHT',null);
      rcd_cad_material_master.pcs_per_case := lics_inbound_utility.get_number('PCS_PER_CASE',null);
      rcd_cad_material_master.outers_per_case := lics_inbound_utility.get_number('OUTERS_PER_CASE',null);
      rcd_cad_material_master.cases_per_pallet := lics_inbound_utility.get_number('CASES_PER_PALLET',null);
      rcd_cad_material_master.brand_essnc_code := lics_inbound_utility.get_variable('BRAND_ESSNC_CODE');
      rcd_cad_material_master.brand_essnc_desc := lics_inbound_utility.get_variable('BRAND_ESSNC_DESC');
      rcd_cad_material_master.brand_essnc_abbrd_desc := lics_inbound_utility.get_variable('BRAND_ESSNC_ABBRD_DESC');
      rcd_cad_material_master.brand_flag_code := lics_inbound_utility.get_variable('BRAND_FLAG_CODE');
      rcd_cad_material_master.brand_flag_desc := lics_inbound_utility.get_variable('BRAND_FLAG_DESC');
      rcd_cad_material_master.brand_flag_abbrd_desc := lics_inbound_utility.get_variable('BRAND_FLAG_ABBRD_DESC');
      rcd_cad_material_master.brand_sub_flag_code := lics_inbound_utility.get_variable('BRAND_SUB_FLAG_CODE');
      rcd_cad_material_master.brand_sub_flag_desc := lics_inbound_utility.get_variable('BRAND_SUB_FLAG_DESC');
      rcd_cad_material_master.brand_sub_flag_abbrd_desc := lics_inbound_utility.get_variable('BRAND_SUB_FLAG_ABBRD_DESC');
      rcd_cad_material_master.bus_sgmnt_code := lics_inbound_utility.get_variable('BUS_SGMNT_CODE');
      rcd_cad_material_master.bus_sgmnt_desc := lics_inbound_utility.get_variable('BUS_SGMNT_DESC');
      rcd_cad_material_master.bus_sgmnt_abbrd_desc := lics_inbound_utility.get_variable('BUS_SGMNT_ABBRD_DESC');
      rcd_cad_material_master.mkt_sgmnt_code := lics_inbound_utility.get_variable('MKT_SGMNT_CODE');
      rcd_cad_material_master.mkt_sgmnt_desc := lics_inbound_utility.get_variable('MKT_SGMNT_DESC');
      rcd_cad_material_master.mkt_sgmnt_abbrd_desc := lics_inbound_utility.get_variable('MKT_SGMNT_ABBRD_DESC');
      rcd_cad_material_master.prdct_ctgry_code := lics_inbound_utility.get_variable('PRDCT_CTGRY_CODE');
      rcd_cad_material_master.prdct_ctgry_desc := lics_inbound_utility.get_variable('PRDCT_CTGRY_DESC');
      rcd_cad_material_master.prdct_ctgry_abbrd_desc := lics_inbound_utility.get_variable('PRDCT_CTGRY_ABBRD_DESC');
      rcd_cad_material_master.prdct_type_code := lics_inbound_utility.get_variable('PRDCT_TYPE_CODE');
      rcd_cad_material_master.prdct_type_desc := lics_inbound_utility.get_variable('PRDCT_TYPE_DESC');
      rcd_cad_material_master.prdct_type_abbrd_desc := lics_inbound_utility.get_variable('PRDCT_TYPE_ABBRD_DESC');
      rcd_cad_material_master.cnsmr_pack_frmt_code := lics_inbound_utility.get_variable('CNSMR_PACK_FRMT_CODE');
      rcd_cad_material_master.cnsmr_pack_frmt_desc := lics_inbound_utility.get_variable('CNSMR_PACK_FRMT_DESC');
      rcd_cad_material_master.cnsmr_pack_frmt_abbrd_desc := lics_inbound_utility.get_variable('CNSMR_PACK_FRMT_ABBRD_DESC');
      rcd_cad_material_master.ingred_vrty_code := lics_inbound_utility.get_variable('INGRED_VRTY_CODE');
      rcd_cad_material_master.ingred_vrty_desc := lics_inbound_utility.get_variable('INGRED_VRTY_DESC');
      rcd_cad_material_master.ingred_vrty_abbrd_desc := lics_inbound_utility.get_variable('INGRED_VRTY_ABBRD_DESC');
      rcd_cad_material_master.prdct_size_grp_code := lics_inbound_utility.get_variable('PRDCT_SIZE_GRP_CODE');
      rcd_cad_material_master.prdct_size_grp_desc := lics_inbound_utility.get_variable('PRDCT_SIZE_GRP_DESC');
      rcd_cad_material_master.prdct_size_grp_abbrd_desc := lics_inbound_utility.get_variable('PRDCT_SIZE_GRP_ABBRD_DESC');
      rcd_cad_material_master.prdct_pack_size_code := lics_inbound_utility.get_variable('PRDCT_PACK_SIZE_CODE');
      rcd_cad_material_master.prdct_pack_size_desc := lics_inbound_utility.get_variable('PRDCT_PACK_SIZE_DESC');
      rcd_cad_material_master.prdct_pack_size_abbrd_desc := lics_inbound_utility.get_variable('PRDCT_PACK_SIZE_ABBRD_DESC');
      rcd_cad_material_master.sales_organisation_135 := lics_inbound_utility.get_variable('SALES_ORGANISATION_135');
      rcd_cad_material_master.sales_organisation_234 := lics_inbound_utility.get_variable('SALES_ORGANISATION_234');
      rcd_cad_material_master.base_uom_code := lics_inbound_utility.get_variable('BASE_UOM_CODE');
      rcd_cad_material_master.material_type_code := lics_inbound_utility.get_variable('MATERIAL_TYPE_CODE');
      rcd_cad_material_master.material_type_desc := lics_inbound_utility.get_variable('MATERIAL_TYPE_DESC');
      rcd_cad_material_master.material_sts_code := lics_inbound_utility.get_variable('MATERIAL_STS_CODE');
      rcd_cad_material_master.bdt_code := lics_inbound_utility.get_variable('BDT_CODE');
      rcd_cad_material_master.bdt_desc := lics_inbound_utility.get_variable('BDT_DESC');
      rcd_cad_material_master.bdt_abbrd_desc := lics_inbound_utility.get_variable('BDT_ABBRD_DESC');
      rcd_cad_material_master.tax_classification := lics_inbound_utility.get_variable('TAX_CLASSIFICATION');
      rcd_cad_material_master.sell_moe_0168 := lics_inbound_utility.get_variable('SELL_MOE_0168');
      rcd_cad_material_master.make_moe_0168 := lics_inbound_utility.get_variable('MAKE_MOE_0168');
      rcd_cad_material_master.intrmdt_prdct_compnt := lics_inbound_utility.get_variable('INTRMDT_PRDCT_COMPNT');
      rcd_cad_material_master.dstrbtn_chain_status := lics_inbound_utility.get_variable('DSTRBTN_CHAIN_STATUS');
      rcd_cad_material_master.lads_change_date := lics_inbound_utility.get_variable('LADS_UPDATE_DATE');
      rcd_cad_material_master.sap_change_date := lics_inbound_utility.get_variable('SAP_UPDATE_DATE');
      rcd_cad_material_master.cad_load_date := sysdate;

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_cad_material_master.sap_material_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - HDR.SAP_MATERIAL_CODE');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      insert into cad_material_master
         (sap_material_code,
          material_desc_ch,
          material_desc_en,
          material_zrep_code,
          material_zrep_desc_ch,
          material_zrep_desc_en,
          net_weight,
          gross_weight,
          matl_length,
          width,
          height,
          pcs_per_case,
          outers_per_case,
          cases_per_pallet,
          brand_essnc_code,
          brand_essnc_desc,
          brand_essnc_abbrd_desc,
          brand_flag_code,
          brand_flag_desc,
          brand_flag_abbrd_desc,
          brand_sub_flag_code,
          brand_sub_flag_desc,
          brand_sub_flag_abbrd_desc,
          bus_sgmnt_code,
          bus_sgmnt_desc,
          bus_sgmnt_abbrd_desc,
          mkt_sgmnt_code,
          mkt_sgmnt_desc,
          mkt_sgmnt_abbrd_desc,
          prdct_ctgry_code,
          prdct_ctgry_desc,
          prdct_ctgry_abbrd_desc,
          prdct_type_code,
          prdct_type_desc,
          prdct_type_abbrd_desc,
          cnsmr_pack_frmt_code,
          cnsmr_pack_frmt_desc,
          cnsmr_pack_frmt_abbrd_desc,
          ingred_vrty_code,
          ingred_vrty_desc,
          ingred_vrty_abbrd_desc,
          prdct_size_grp_code,
          prdct_size_grp_desc,
          prdct_size_grp_abbrd_desc,
          prdct_pack_size_code,
          prdct_pack_size_desc,
          prdct_pack_size_abbrd_desc,
          sales_organisation_135,
          sales_organisation_234,
          base_uom_code,
          material_type_code,
          material_type_desc,
          material_sts_code,
          bdt_code,
          bdt_desc,
          bdt_abbrd_desc,
          tax_classification,
          sell_moe_0168,
          make_moe_0168,
          intrmdt_prdct_compnt,
          dstrbtn_chain_status,
          lads_change_date,
          sap_change_date,
          cad_load_date)
      values
         (rcd_cad_material_master.sap_material_code,
          rcd_cad_material_master.material_desc_ch,
          rcd_cad_material_master.material_desc_en,
          rcd_cad_material_master.material_zrep_code,
          rcd_cad_material_master.material_zrep_desc_ch,
          rcd_cad_material_master.material_zrep_desc_en,
          rcd_cad_material_master.net_weight,
          rcd_cad_material_master.gross_weight,
          rcd_cad_material_master.matl_length,
          rcd_cad_material_master.width,
          rcd_cad_material_master.height,
          rcd_cad_material_master.pcs_per_case,
          rcd_cad_material_master.outers_per_case,
          rcd_cad_material_master.cases_per_pallet,
          rcd_cad_material_master.brand_essnc_code,
          rcd_cad_material_master.brand_essnc_desc,
          rcd_cad_material_master.brand_essnc_abbrd_desc,
          rcd_cad_material_master.brand_flag_code,
          rcd_cad_material_master.brand_flag_desc,
          rcd_cad_material_master.brand_flag_abbrd_desc,
          rcd_cad_material_master.brand_sub_flag_code,
          rcd_cad_material_master.brand_sub_flag_desc,
          rcd_cad_material_master.brand_sub_flag_abbrd_desc,
          rcd_cad_material_master.bus_sgmnt_code,
          rcd_cad_material_master.bus_sgmnt_desc,
          rcd_cad_material_master.bus_sgmnt_abbrd_desc,
          rcd_cad_material_master.mkt_sgmnt_code,
          rcd_cad_material_master.mkt_sgmnt_desc,
          rcd_cad_material_master.mkt_sgmnt_abbrd_desc,
          rcd_cad_material_master.prdct_ctgry_code,
          rcd_cad_material_master.prdct_ctgry_desc,
          rcd_cad_material_master.prdct_ctgry_abbrd_desc,
          rcd_cad_material_master.prdct_type_code,
          rcd_cad_material_master.prdct_type_desc,
          rcd_cad_material_master.prdct_type_abbrd_desc,
          rcd_cad_material_master.cnsmr_pack_frmt_code,
          rcd_cad_material_master.cnsmr_pack_frmt_desc,
          rcd_cad_material_master.cnsmr_pack_frmt_abbrd_desc,
          rcd_cad_material_master.ingred_vrty_code,
          rcd_cad_material_master.ingred_vrty_desc,
          rcd_cad_material_master.ingred_vrty_abbrd_desc,
          rcd_cad_material_master.prdct_size_grp_code,
          rcd_cad_material_master.prdct_size_grp_desc,
          rcd_cad_material_master.prdct_size_grp_abbrd_desc,
          rcd_cad_material_master.prdct_pack_size_code,
          rcd_cad_material_master.prdct_pack_size_desc,
          rcd_cad_material_master.prdct_pack_size_abbrd_desc,
          rcd_cad_material_master.sales_organisation_135,
          rcd_cad_material_master.sales_organisation_234,
          rcd_cad_material_master.base_uom_code,
          rcd_cad_material_master.material_type_code,
          rcd_cad_material_master.material_type_desc,
          rcd_cad_material_master.material_sts_code,
          rcd_cad_material_master.bdt_code,
          rcd_cad_material_master.bdt_desc,
          rcd_cad_material_master.bdt_abbrd_desc,
          rcd_cad_material_master.tax_classification,
          rcd_cad_material_master.sell_moe_0168,
          rcd_cad_material_master.make_moe_0168,
          rcd_cad_material_master.intrmdt_prdct_compnt,
          rcd_cad_material_master.dstrbtn_chain_status,
          rcd_cad_material_master.lads_change_date,
          rcd_cad_material_master.sap_change_date,
          rcd_cad_material_master.cad_load_date);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_hdr;

   /**************************************************/
   /* This procedure performs the record INV routine */
   /**************************************************/
   procedure process_record_inv(par_record in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/


      /*-*/
      /* Local cursors
      /*-*/

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-------------------------------*/
      /* PARSE - Parse the data record */
      /*-------------------------------*/
      lics_inbound_utility.parse_record('INV', par_record);

      /*--------------------------------------*/
      /* RETRIEVE - Retrieve the field values */
      /*--------------------------------------*/

      /*-*/
      /* Retrieve field values
      /*-*/    
      rcd_cad_material_invntry.sap_material_code := rcd_cad_material_master.sap_material_code;
      rcd_cad_material_invntry.sap_company_code := lics_inbound_utility.get_variable('SAP_COMPANY_CODE');
      rcd_cad_material_invntry.sap_plant_code := lics_inbound_utility.get_variable('SAP_PLANT_CODE');
      rcd_cad_material_invntry.inv_exp_date := lics_inbound_utility.get_variable('INV_EXP_DATE');
      rcd_cad_material_invntry.inv_unreleased_qty := lics_inbound_utility.get_number('INV_UNRELEASED_QTY', null);
      rcd_cad_material_invntry.inv_reserved_qty := lics_inbound_utility.get_number('INV_RESERVED_QTY', null);
      rcd_cad_material_invntry.inv_class01 := lics_inbound_utility.get_variable('INV_CLASS01');
      rcd_cad_material_invntry.inv_class02 := lics_inbound_utility.get_variable('INV_CLASS02');

      /*-*/
      /* Retrieve exceptions raised
      /*-*/
      if lics_inbound_utility.has_errors = true then
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* VALIDATION - Validate the field values */
      /*----------------------------------------*/

      /*-*/
      /* Validate the primary keys
      /*-*/
      if rcd_cad_material_invntry.sap_material_code is null then
         lics_inbound_utility.add_exception('Missing Primary Key - INV.SAP_MATERIAL_CODE');
         var_trn_error := true;
      end if;

      /*----------------------------------------*/
      /* ERROR- Bypass the update when required */
      /*----------------------------------------*/
      if var_trn_error = true then
         return;
      end if;

      insert into cad_material_invntry
         (sap_material_code,
          sap_company_code,
          sap_plant_code,
          inv_exp_date,
          inv_unreleased_qty,
          inv_reserved_qty,
          inv_class01,
          inv_class02)
      values
         (rcd_cad_material_invntry.sap_material_code,
          rcd_cad_material_invntry.sap_company_code,
          rcd_cad_material_invntry.sap_plant_code,
          rcd_cad_material_invntry.inv_exp_date,
          rcd_cad_material_invntry.inv_unreleased_qty,
          rcd_cad_material_invntry.inv_reserved_qty,
          rcd_cad_material_invntry.inv_class01,
          rcd_cad_material_invntry.inv_class02);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_record_inv;

end ladcad01_material;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ladcad01_material for cad_app.ladcad01_material;
grant execute on ladcad01_material to lics_app;
