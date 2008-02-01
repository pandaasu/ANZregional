SELECT
  /*****************************************************************************
  Purpose:    General MATERIAL snapshot with all known columns
     No Plant filtering to allow the snapshot to be generic across
     all plants.
     This view is derived from a Table in BDS structured specifically
     for the Plant Database MATERIAL views.
     Simple filtering will br required to reflect the existing plant MATL views
  Revisions:
  ver        date        author           description
  ---------  ----------  ---------------  -------------------------------------
  1.0        04/01/2007  jeff phillipson created initial view
  1.1        16/05/2007  jeff phillipson added followup, materialdivision 1 fields
  1.2        07/08/2007  jeff phillipson added mrp_type, max_storage_prd, max_storage_prd_unit
  *****************************************************************************/
  SAP_MATERIAL_CODE,
  PLANT_CODE,
  BDS_MATERIAL_DESC_EN,
  MATERIAL_TYPE,
  MATERIAL_GRP,
  BASE_UOM,
  ORDER_UNIT,
  GROSS_WEIGHT,
  NET_WEIGHT,
  GROSS_WEIGHT_UNIT,
  LENGTH,
  WIDTH,
  HEIGHT,
  DIMENSION_UOM,
  INTERNTL_ARTICLE_NO,
  TOTAL_SHELF_LIFE,
  MARS_INTRMDT_PRDCT_COMPNT_FLAG,
  MARS_MERCHANDISING_UNIT_FLAG,
  MARS_PRMOTIONAL_MATERIAL_FLAG,
  MARS_RETAIL_SALES_UNIT_FLAG,
  MARS_SEMI_FINISHED_PRDCT_FLAG,
  MARS_RPRSNTTV_ITEM_FLAG,
  MARS_TRADED_UNIT_FLAG,
  XPLANT_STATUS,
  XPLANT_STATUS_VALID,
  BATCH_MNGMNT_REQRMNT_INDCTR,
  MARS_PLANT_MATERIAL_TYPE,
  PROCUREMENT_TYPE,
  SPECIAL_PROCUREMENT_TYPE,
  ISSUE_STORAGE_LOCATION,
  MRP_CONTROLLER,
  PLANT_SPECIFIC_STATUS_VALID,
  DELETION_INDCTR,
  PLANT_SPECIFIC_STATUS,
  ASSEMBLY_SCRAP_PERCNTG,
  COMPONENT_SCRAP_PERCNTG,
  BACKFLUSH_INDCTR,
  MARS_RPRSNTTV_ITEM_CODE,
  SALES_TEXT_147,
  SALES_TEXT_149,
  REGIONAL_CODE_10,
  REGIONAL_CODE_17,
  REGIONAL_CODE_18,
  REGIONAL_CODE_19,
  BDS_UNIT_COST,
  FUTURE_PLANNED_PRICE_1,
  VLTN_CLASS,
  BDS_PCE_FACTOR_FROM_BASE_UOM,
  MARS_PCE_ITEM_CODE,
  MARS_PCE_INTERNTL_ARTICLE_NO,
  BDS_SB_FACTOR_FROM_BASE_UOM,
  MARS_SB_ITEM_CODE,
  DISCONTINUATION_INDCTR,
  FOLLOWUP_MATERIAL,
  MATERIAL_DIVISION,
  MRP_TYPE,
  MAX_STORAGE_PRD,
  MAX_STORAGE_PRD_UNIT
  FROM BDS_MATERIAL_PLANT_MFANZ@ap0052t
  WHERE (plant_code LIKE 'AU%' OR plant_code LIKE 'NZ%')
  AND material_type IN ('ROH', 'VERP', 'NLAG', 'PIPE','FERT');




         select t01.sap_material_code as sap_material_code, 
                t02.plant_code as plant_code,
                t01.mars_rprsnttv_item_code as mars_rprsnttv_item_code, 
                t01.bds_material_desc_en as bds_material_desc_en,
                t01.material_type as material_type,
                t01.material_grp as material_grp,
                t01.base_uom as base_uom,
                t01.order_unit as order_unit,
                t01.gross_weight as gross_weight,
                t01.net_weight as net_weight,
                t01.gross_weight_unit as gross_weight_unit,
                t01.length as length,
                t01.width as width,
                t01.height as height,
                t01.dimension_uom as dimension_uom,
                t01.interntl_article_no as interntl_article_no,
                t01.total_shelf_life as total_shelf_life,
                t01.mars_intrmdt_prdct_compnt_flag as mars_intrmdt_prdct_compnt_flag,
                t01.mars_merchandising_unit_flag as mars_merchandising_unit_flag,
                t01.mars_prmotional_material_flag as mars_prmotional_material_flag,
                t01.mars_retail_sales_unit_flag as mars_retail_sales_unit_flag,
                t01.mars_semi_finished_prdct_flag as mars_semi_finished_prdct_flag,
                t01.mars_rprsnttv_item_flag as mars_rprsnttv_item_flag,
                t01.mars_traded_unit_flag as mars_traded_unit_flag,
                t01.xplant_status as xplant_status,
                t01.xplant_status_valid as xplant_status_valid,
                t01.batch_mngmnt_reqrmnt_indctr as batch_mngmnt_reqrmnt_indctr,
                t02.mars_plant_material_type as mars_plant_material_type,
                t02.procurement_type as procurement_type,
                t02.special_procurement_type as special_procurement_type,
                t02.issue_storage_location as issue_storage_location,
                t02.mrp_controller as mrp_controller,
                t02.plant_specific_status_valid as plant_specific_status_valid,
                t02.deletion_indctr as deletion_indctr,
                t02.plant_specific_status as plant_specific_status,
                t02.assembly_scrap_percntg as assembly_scrap_percntg,
                t02.component_scrap_percntg as component_scrap_percntg,
                t02.backflush_indctr as backflush_indctr,
                t03.sales_text_147 as sales_text_147,
                t03.sales_text_149 as sales_text_149,
                t04.regional_code_10 as regional_code_10,
                t04.regional_code_18 as regional_code_18,
                t04.regional_code_17 as regional_code_17,
                t04.regional_code_19 as regional_code_19,
                t05.stndrd_price as stndrd_price,
                t05.price_unit as price_unit,
                t05.future_planned_price_1 as future_planned_price_1,
                t05.vltn_class as vltn_class,
                decode(t06.bds_pce_factor_from_base_uom,null,1,t06.bds_pce_factor_from_base_uom) as bds_pce_factor_from_base_uom,
                t06.mars_pce_item_code as mars_pce_item_code,
                t06.mars_pce_interntl_article_no as mars_pce_interntl_article_no,        
                t06.bds_sb_factor_from_base_uom as bds_sb_factor_from_base_uom,  
                t06.mars_sb_item_code as mars_sb_item_code,
                t02.effective_out_date,
                t02.discontinuation_indctr,
                t02.followup_material,
                t01.material_division,
                t02.mrp_type,
                t02.max_storage_prd,
                t02.max_storage_prd_unit
         from bds_material_hdr t01,
              bds_material_plant_hdr t02,
              (select sap_material_code,
                      max(case when sales_organisation = '147' then text end) as sales_text_147,
                      max(case when sales_organisation = '149' then text end) as sales_text_149
	       from bds_material_text_en
               where sales_organisation in ('147','149')
                 and dstrbtn_channel = '99'
               group by sap_material_code) t03,
              (select sap_material_code,
                      max(case when regional_code_id = '10' then regional_code end) as regional_code_10,
                      max(case when regional_code_id = '18' then regional_code end) as regional_code_18,
                      max(case when regional_code_id = '17' then regional_code end) as regional_code_17,
                      max(case when regional_code_id = '19' then regional_code end) as regional_code_19
               from bds_material_regional
               where regional_code_id in ('10', '18', '17', '19')
               group by sap_material_code) t04,
              bds_material_vltn t05,
              (select sap_material_code,
                      max(case when uom_code = 'PCE' then bds_factor_from_base_uom end) as bds_pce_factor_from_base_uom,
                      max(case when uom_code = 'PCE' then mars_pc_item_code end) as mars_pce_item_code,
                      max(case when uom_code = 'PCE' then interntl_article_no end) as mars_pce_interntl_article_no,
                      max(case when uom_code = 'SB' then bds_factor_from_base_uom end) as bds_sb_factor_from_base_uom,
                      max(case when uom_code = 'SB' then mars_pc_item_code end) as mars_sb_item_code
               from bds_material_uom
               where uom_code in ('PCE','SB')
               group by sap_material_code) t06
         where t01.sap_material_code = t02.sap_material_code
           and t01.mars_rprsnttv_item_code = t03.sap_material_code(+)
           and t01.sap_material_code = t04.sap_material_code(+)
           and t02.sap_material_code = t05.sap_material_code(+)
           and t02.plant_code = t05.vltn_area(+)
           and t01.sap_material_code = t06.sap_material_code(+)
           and t01.sap_material_code = rcd_lads_mat_hdr.matnr
           and t01.material_type IN ('ROH', 'VERP', 'NLAG', 'PIPE', 'FERT') -- all interested materials
           and t01.deletion_flag is null
           and (t02.plant_code like 'AU%' or t02.plant_code like 'NZ%') 
           and t02.deletion_indctr is null
           and t05.vltn_type(+) = '*NONE'
           and t05.deletion_indctr(+) is null;


         /*-*/
         /* Calculate Unit Cost
         /*-*/
         case 
            when (rcd_lads_material_plant_mfanz.stndrd_price is null or
                  rcd_lads_material_plant_mfanz.stndrd_price = 0) then
               rcd_bds_material_plant_mfanz.bds_unit_cost := 0;   
            else
               rcd_bds_material_plant_mfanz.bds_unit_cost := rcd_lads_material_plant_mfanz.stndrd_price/rcd_lads_material_plant_mfanz.price_unit;      
         end case;