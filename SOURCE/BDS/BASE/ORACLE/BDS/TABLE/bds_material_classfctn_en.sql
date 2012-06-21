DROP VIEW BDS.BDS_MATERIAL_CLASSFCTN_EN;

/* Formatted on 21/06/2012 2:54:02 PM (QP5 v5.163.1008.3004) */
CREATE OR REPLACE FORCE VIEW BDS.BDS_MATERIAL_CLASSFCTN_EN
(
   SAP_MATERIAL_CODE,
   MATERIAL_TYPE,
   SAP_BUS_SGMNT_CODE,
   SAP_BUS_SGMNT_SHT_DSC,
   SAP_BUS_SGMNT_LNG_DSC,
   SAP_MRKT_SGMNT_CODE,
   SAP_MRKT_SGMNT_SHT_DSC,
   SAP_MRKT_SGMNT_LNG_DSC,
   SAP_BRAND_FLAG_CODE,
   SAP_BRAND_FLAG_SHT_DSC,
   SAP_BRAND_FLAG_LNG_DSC,
   SAP_FUNCL_VRTY_CODE,
   SAP_FUNCL_VRTY_SHT_DSC,
   SAP_FUNCL_VRTY_LNG_DSC,
   SAP_INGRDNT_VRTY_CODE,
   SAP_INGRDNT_VRTY_SHT_DSC,
   SAP_INGRDNT_VRTY_LNG_DSC,
   SAP_BRAND_SUB_FLAG_CODE,
   SAP_BRAND_SUB_FLAG_SHT_DSC,
   SAP_BRAND_SUB_FLAG_LNG_DSC,
   SAP_SUPPLY_SGMNT_CODE,
   SAP_SUPPLY_SGMNT_SHT_DSC,
   SAP_SUPPLY_SGMNT_LNG_DSC,
   SAP_TRADE_SECTOR_CODE,
   SAP_TRADE_SECTOR_SHT_DSC,
   SAP_TRADE_SECTOR_LNG_DSC,
   SAP_OCCSN_CODE,
   SAP_OCCSN_SHT_DSC,
   SAP_OCCSN_LNG_DSC,
   SAP_MRKTING_CONCPT_CODE,
   SAP_MRKTING_CONCPT_SHT_DSC,
   SAP_MRKTING_CONCPT_LNG_DSC,
   SAP_MULTI_PACK_QTY_CODE,
   SAP_MULTI_PACK_QTY_SHT_DSC,
   SAP_MULTI_PACK_QTY_LNG_DSC,
   SAP_PRDCT_CTGRY_CODE,
   SAP_PRDCT_CTGRY_SHT_DSC,
   SAP_PRDCT_CTGRY_LNG_DSC,
   SAP_PACK_TYPE_CODE,
   SAP_PACK_TYPE_SHT_DSC,
   SAP_PACK_TYPE_LNG_DSC,
   SAP_SIZE_CODE,
   SAP_SIZE_SHT_DSC,
   SAP_SIZE_LNG_DSC,
   SAP_SIZE_GRP_CODE,
   SAP_SIZE_GRP_SHT_DSC,
   SAP_SIZE_GRP_LNG_DSC,
   SAP_PRDCT_TYPE_CODE,
   SAP_PRDCT_TYPE_SHT_DSC,
   SAP_PRDCT_TYPE_LNG_DSC,
   SAP_TRAD_UNIT_CONFIG_CODE,
   SAP_TRAD_UNIT_CONFIG_SHT_DSC,
   SAP_TRAD_UNIT_CONFIG_LNG_DSC,
   SAP_TRAD_UNIT_FRMT_CODE,
   SAP_TRAD_UNIT_FRMT_SHT_DSC,
   SAP_TRAD_UNIT_FRMT_LNG_DSC,
   SAP_DSPLY_STORG_CONDTN_CODE,
   SAP_DSPLY_STORG_CONDTN_SHT_DSC,
   SAP_DSPLY_STORG_CONDTN_LNG_DSC,
   SAP_ONPACK_CNSMR_VALUE_CODE,
   SAP_ONPACK_CNSMR_VALUE_SHT_DSC,
   SAP_ONPACK_CNSMR_VALUE_LNG_DSC,
   SAP_ONPACK_CNSMR_OFFER_CODE,
   SAP_ONPACK_CNSMR_OFFER_SHT_DSC,
   SAP_ONPACK_CNSMR_OFFER_LNG_DSC,
   SAP_ONPACK_TRADE_OFFER_CODE,
   SAP_ONPACK_TRADE_OFFER_SHT_DSC,
   SAP_ONPACK_TRADE_OFFER_LNG_DSC,
   SAP_BRAND_ESSNC_CODE,
   SAP_BRAND_ESSNC_SHT_DSC,
   SAP_BRAND_ESSNC_LNG_DSC,
   SAP_CNSMR_PACK_FRMT_CODE,
   SAP_CNSMR_PACK_FRMT_SHT_DSC,
   SAP_CNSMR_PACK_FRMT_LNG_DSC,
   SAP_CUISINE_CODE,
   SAP_CUISINE_SHT_DSC,
   SAP_CUISINE_LNG_DSC,
   SAP_FPPS_MINOR_PACK_CODE,
   SAP_FPPS_MINOR_PACK_SHT_DSC,
   SAP_FPPS_MINOR_PACK_LNG_DSC,
   SAP_FIGHTING_UNIT_CODE,
   SAP_FIGHTING_UNIT_DESC,
   SAP_CHINA_BDT_CODE,
   SAP_CHINA_BDT_DESC,
   SAP_MRKT_CTGRY_CODE,
   SAP_MRKT_CTGRY_DESC,
   SAP_MRKT_SUB_CTGRY_CODE,
   SAP_MRKT_SUB_CTGRY_DESC,
   SAP_MRKT_SUB_CTGRY_GRP_CODE,
   SAP_MRKT_SUB_CTGRY_GRP_DESC,
   SAP_SOP_BUS_CODE,
   SAP_SOP_BUS_DESC,
   SAP_PRODCTN_LINE_CODE,
   SAP_PRODCTN_LINE_DESC,
   SAP_PLANNING_SRC_CODE,
   SAP_PLANNING_SRC_DESC,
   SAP_SUB_FIGHTING_UNIT_CODE,
   SAP_SUB_FIGHTING_UNIT_DESC,
   SAP_PACK_FAMILY_CODE,
   SAP_PACK_FAMILY_LNG_DSC,
   SAP_PACK_SUB_FAMILY_CODE,
   SAP_PACK_SUB_FAMILY_LNG_DSC,
   SAP_RAW_FAMILY_CODE,
   SAP_RAW_FAMILY_LNG_DSC,
   SAP_RAW_SUB_FAMILY_CODE,
   SAP_RAW_SUB_FAMILY_LNG_DSC,
   SAP_RAW_GROUP_CODE,
   SAP_RAW_GROUP_LNG_DSC,
   SAP_ANIMAL_PARTS_CODE,
   SAP_ANIMAL_PARTS_LNG_DSC,
   SAP_PHYSICAL_CONDTN_CODE,
   SAP_PHYSICAL_CONDTN_LNG_DSC,
   SAP_CHINA_ABC_INDCTR_CODE,
   SAP_CHINA_ABC_INDCTR_DESC,
   SAP_NZ_PROMOTIONAL_GRP_CODE,
   SAP_NZ_PROMOTIONAL_GRP_DESC,
   SAP_NZ_SOP_BUSINESS_CODE,
   SAP_NZ_SOP_BUSINESS_DESC,
   SAP_NZ_MUST_WIN_CTGRY_CODE,
   SAP_NZ_MUST_WIN_CTGRY_DESC,
   SAP_AU_SNK_ACTIVITY_CODE,
   SAP_AU_SNK_ACTIVITY_DESC,
   SAP_CHINA_FORECAST_GROUP_CODE,
   SAP_CHINA_FORECAST_GROUP_DESC,
   SAP_HK_SUB_CTGRY_CODE,
   SAP_HK_SUB_CTGRY_DESC,
   SAP_HK_LINE_CODE,
   SAP_HK_LINE_DESC,
   SAP_HK_PRODUCT_SGMNT_CODE,
   SAP_HK_PRODUCT_SGMNT_DESC,
   SAP_HK_TYPE_CODE,
   SAP_HK_TYPE_DESC,
   SAP_STRGY_GRP_CODE,
   SAP_STRGY_GRP_DESC,
   SAP_TH_BOI_CODE,
   SAP_TH_BOI_DESC,
   SAP_PACK_DSPSAL_CLASS_CODE,
   SAP_PACK_DSPSAL_CLASS_LNG_DSC,
   SAP_TH_BOI_GRP_CODE,
   SAP_TH_BOI_GRP_LNG_DSC,
   SAP_NZ_LAUNCH_RANKING_CODE,
   SAP_NZ_LAUNCH_RANKING_DESC,
   SAP_NZ_SELECTIVELY_GROW_CODE,
   SAP_NZ_SELECTIVELY_GROW_DESC,
   SAP_RAW_TH_BOI_GRP_CODE,
   SAP_RAW_TH_BOI_GRP_LNG_DSC,
   SAP_RAW_ALLERGEN_CODE,
   SAP_RAW_ALLERGEN_SHT_DSC,
   SAP_RAW_ALLERGEN_LNG_DSC
)
AS
   (SELECT t01.sap_material_code AS sap_material_code,
           NVL (t37.material_type, '*NONE') AS material_type,
           t01.sap_bus_sgmnt_code AS sap_bus_sgmnt_code,
           t02.sap_charistic_value_shrt_desc AS sap_bus_sgmnt_sht_dsc,
           t02.sap_charistic_value_long_desc AS sap_bus_sgmnt_lng_dsc,
           t01.sap_mrkt_sgmnt_code AS sap_mrkt_sgmnt_code,
           t03.sap_charistic_value_shrt_desc AS sap_mrkt_sgmnt_sht_dsc,
           t03.sap_charistic_value_long_desc AS sap_mrkt_sgmnt_lng_dsc,
           t01.sap_brand_flag_code AS sap_brand_flag_code,
           t04.sap_charistic_value_shrt_desc AS sap_brand_flag_sht_dsc,
           t04.sap_charistic_value_long_desc AS sap_brand_flag_lng_dsc,
           t01.sap_funcl_vrty_code AS sap_funcl_vrty_code,
           t05.sap_charistic_value_shrt_desc AS sap_funcl_vrty_sht_dsc,
           t05.sap_charistic_value_long_desc AS sap_funcl_vrty_lng_dsc,
           t01.sap_ingrdnt_vrty_code AS sap_ingrdnt_vrty_code,
           t06.sap_charistic_value_shrt_desc AS sap_ingrdnt_vrty_sht_dsc,
           t06.sap_charistic_value_long_desc AS sap_ingrdnt_vrty_lng_dsc,
           t01.sap_brand_sub_flag_code AS sap_brand_sub_flag_code,
           t07.sap_charistic_value_shrt_desc AS sap_brand_sub_flag_sht_dsc,
           t07.sap_charistic_value_long_desc AS sap_brand_sub_flag_lng_dsc,
           t01.sap_supply_sgmnt_code AS sap_supply_sgmnt_code,
           t08.sap_charistic_value_shrt_desc AS sap_supply_sgmnt_sht_dsc,
           t08.sap_charistic_value_long_desc AS sap_supply_sgmnt_lng_dsc,
           t01.sap_trade_sector_code AS sap_trade_sector_code,
           t09.sap_charistic_value_shrt_desc AS sap_trade_sector_sht_dsc,
           t09.sap_charistic_value_long_desc AS sap_trade_sector_lng_dsc,
           t01.sap_occsn_code AS sap_occsn_code,
           t10.sap_charistic_value_shrt_desc AS sap_occsn_sht_dsc,
           t10.sap_charistic_value_long_desc AS sap_occsn_lng_dsc,
           t01.sap_mrkting_concpt_code AS sap_mrkting_concpt_code,
           t11.sap_charistic_value_shrt_desc AS sap_mrkting_concpt_sht_dsc,
           t11.sap_charistic_value_long_desc AS sap_mrkting_concpt_lng_dsc,
           t01.sap_multi_pack_qty_code AS sap_multi_pack_qty_code,
           t12.sap_charistic_value_shrt_desc AS sap_multi_pack_qty_sht_dsc,
           t12.sap_charistic_value_long_desc AS sap_multi_pack_qty_lng_dsc,
           t01.sap_prdct_ctgry_code AS sap_prdct_ctgry_code,
           t13.sap_charistic_value_shrt_desc AS sap_prdct_ctgry_sht_dsc,
           t13.sap_charistic_value_long_desc AS sap_prdct_ctgry_lng_dsc,
           t01.sap_pack_type_code AS sap_pack_type_code,
           t14.sap_charistic_value_shrt_desc AS sap_pack_type_sht_dsc,
           t14.sap_charistic_value_long_desc AS sap_pack_type_lng_dsc,
           t01.sap_size_code AS sap_size_code,
           t15.sap_charistic_value_shrt_desc AS sap_size_sht_dsc,
           t15.sap_charistic_value_long_desc AS sap_size_lng_dsc,
           t01.sap_size_grp_code AS sap_size_grp_code,
           t16.sap_charistic_value_shrt_desc AS sap_size_grp_sht_dsc,
           t16.sap_charistic_value_long_desc AS sap_size_grp_lng_dsc,
           t01.sap_prdct_type_code AS sap_prdct_type_code,
           t17.sap_charistic_value_shrt_desc AS sap_prdct_type_sht_dsc,
           t17.sap_charistic_value_long_desc AS sap_prdct_type_lng_dsc,
           t01.sap_trad_unit_config_code AS sap_trad_unit_config_code,
           t18.sap_charistic_value_shrt_desc AS sap_trad_unit_config_sht_dsc,
           t18.sap_charistic_value_long_desc AS sap_trad_unit_config_lng_dsc,
           t01.sap_trad_unit_frmt_code AS sap_trad_unit_frmt_code,
           t19.sap_charistic_value_shrt_desc AS sap_trad_unit_frmt_sht_dsc,
           t19.sap_charistic_value_long_desc AS sap_trad_unit_frmt_lng_dsc,
           t01.sap_dsply_storg_condtn_code AS sap_dsply_storg_condtn_code,
           t20.sap_charistic_value_shrt_desc
              AS sap_dsply_storg_condtn_sht_dsc,
           t20.sap_charistic_value_long_desc
              AS sap_dsply_storg_condtn_lng_dsc,
           t01.sap_onpack_cnsmr_value_code AS sap_onpack_cnsmr_value_code,
           t21.sap_charistic_value_shrt_desc
              AS sap_onpack_cnsmr_value_sht_dsc,
           t21.sap_charistic_value_long_desc
              AS sap_onpack_cnsmr_value_lng_dsc,
           t01.sap_onpack_cnsmr_offer_code AS sap_onpack_cnsmr_offer_code,
           t22.sap_charistic_value_shrt_desc
              AS sap_onpack_cnsmr_offer_sht_dsc,
           t22.sap_charistic_value_long_desc
              AS sap_onpack_cnsmr_offer_lng_dsc,
           t01.sap_onpack_trade_offer_code AS sap_onpack_trade_offer_code,
           t23.sap_charistic_value_shrt_desc
              AS sap_onpack_trade_offer_sht_dsc,
           t23.sap_charistic_value_long_desc
              AS sap_onpack_trade_offer_lng_dsc,
           t01.sap_brand_essnc_code AS sap_brand_essnc_code,
           t24.sap_charistic_value_shrt_desc AS sap_brand_essnc_sht_dsc,
           t24.sap_charistic_value_long_desc AS sap_brand_essnc_lng_dsc,
           t01.sap_cnsmr_pack_frmt_code AS sap_cnsmr_pack_frmt_code,
           t25.sap_charistic_value_shrt_desc AS sap_cnsmr_pack_frmt_sht_dsc,
           t25.sap_charistic_value_long_desc AS sap_cnsmr_pack_frmt_lng_dsc,
           t01.sap_cuisine_code AS sap_cuisine_code,
           t26.sap_charistic_value_shrt_desc AS sap_cuisine_sht_dsc,
           t26.sap_charistic_value_long_desc AS sap_cuisine_lng_dsc,
           t01.sap_fpps_minor_pack_code AS sap_fpps_minor_pack_code,
           t27.sap_charistic_value_shrt_desc AS sap_fpps_minor_pack_sht_dsc,
           t27.sap_charistic_value_long_desc AS sap_fpps_minor_pack_lng_dsc,
           t01.sap_fighting_unit_code AS sap_fighting_unit_code,
           t28.sap_charistic_value_desc AS sap_fighting_unit_desc,
           t01.sap_china_bdt_code AS sap_china_bdt_code,
           t29.sap_charistic_value_desc AS sap_china_bdt_desc,
           t01.sap_mrkt_ctgry_code AS sap_mrkt_ctgry_code,
           t30.sap_charistic_value_desc AS sap_mrkt_ctgry_desc,
           t01.sap_mrkt_sub_ctgry_code AS sap_mrkt_sub_ctgry_code,
           t31.sap_charistic_value_desc AS sap_mrkt_sub_ctgry_desc,
           t01.sap_mrkt_sub_ctgry_grp_code AS sap_mrkt_sub_ctgry_grp_code,
           t32.sap_charistic_value_desc AS sap_mrkt_sub_ctgry_grp_desc,
           t01.sap_sop_bus_code AS sap_sop_bus_code,
           t33.sap_charistic_value_desc AS sap_sop_bus_desc,
           t01.sap_prodctn_line_code AS sap_prodctn_line_code,
           t34.sap_charistic_value_desc AS sap_prodctn_line_desc,
           t01.sap_planning_src_code AS sap_planning_src_code,
           t35.sap_charistic_value_desc AS sap_planning_src_desc,
           t01.sap_sub_fighting_unit_code AS sap_sub_fighting_unit_code,
           t36.sap_charistic_value_desc AS sap_sub_fighting_unit_desc,
           t01.sap_pack_family_code AS sap_pack_family_code,
           t38.sap_charistic_value_long_desc AS sap_pack_family_lng_dsc,
           t01.sap_pack_sub_family_code AS sap_pack_sub_family_code,
           t39.sap_charistic_value_long_desc AS sap_pack_sub_family_lng_dsc,
           t01.sap_raw_family_code AS sap_raw_family_code,
           t40.sap_charistic_value_long_desc AS sap_raw_family_lng_dsc,
           t01.sap_raw_sub_family_code AS sap_raw_sub_family_code,
           t41.sap_charistic_value_long_desc AS sap_raw_sub_family_lng_dsc,
           t01.sap_raw_group_code AS sap_raw_group_code,
           t42.sap_charistic_value_long_desc AS sap_raw_group_lng_dsc,
           t01.sap_animal_parts_code AS sap_animal_parts_code,
           t43.sap_charistic_value_long_desc AS sap_animal_parts_lng_dsc,
           t01.sap_physical_condtn_code AS sap_physical_condtn_code,
           t44.sap_charistic_value_long_desc AS sap_physical_condtn_lng_dsc,
           t01.sap_china_abc_indctr_code AS sap_china_abc_indctr_code,
           t45.sap_charistic_value_desc AS sap_china_abc_indctr_desc,
           t01.sap_nz_promotional_grp_code AS sap_nz_promotional_grp_code,
           t46.sap_charistic_value_desc AS sap_nz_promotional_grp_desc,
           t01.sap_nz_sop_business_code AS sap_nz_sop_business_code,
           t47.sap_charistic_value_desc AS sap_nz_sop_business_desc,
           t01.sap_nz_must_win_ctgry_code AS sap_nz_must_win_ctgry_code,
           t48.sap_charistic_value_desc AS sap_nz_must_win_ctgry_desc,
           t01.sap_au_snk_activity_name AS sap_au_snk_activity_code,
           t49.sap_charistic_value_desc AS sap_au_snk_activity_desc,
           t01.sap_china_forecast_group AS sap_china_forecast_group_code,
           t50.sap_charistic_value_desc AS sap_china_forecast_group_desc,
           t01.sap_hk_sub_ctgry_code AS sap_hk_sub_ctgry_code,
           t51.sap_charistic_value_desc AS sap_hk_sub_ctgry_desc,
           t01.sap_hk_line_code AS sap_hk_line_code,
           t52.sap_charistic_value_desc AS sap_hk_line_desc,
           t01.sap_hk_product_sgmnt_code AS sap_hk_product_sgmnt_code,
           t53.sap_charistic_value_desc AS sap_hk_product_sgmnt_desc,
           t01.sap_hk_type_code AS sap_hk_type_code,
           t54.sap_charistic_value_desc AS sap_hk_type_desc,
           t01.sap_strgy_grp_code AS sap_strgy_grp_code,
           t55.sap_charistic_value_desc AS sap_strgy_grp_desc,
           t01.sap_th_boi_code AS sap_th_boi_code,
           t56.sap_charistic_value_desc AS sap_th_boi_desc,
           t01.sap_pack_dspsal_class AS sap_pack_dspsal_class_code,
           t57.sap_charistic_value_desc AS sap_pack_dspsal_class_lng_dsc,
           t01.sap_th_boi_grp_code AS sap_th_boi_grp_code,
           t58.sap_charistic_value_desc AS sap_th_boi_grp_lng_dsc,
           t01.sap_nz_launch_ranking_code AS sap_nz_launch_ranking_code,
           t59.sap_charistic_value_desc AS sap_nz_launch_ranking_desc,
           t01.sap_nz_selectively_grow_code AS sap_nz_selectively_grow_code,
           t60.sap_charistic_value_desc AS sap_nz_selectively_grow_desc,
           t01.sap_raw_th_boi_grp_code AS sap_raw_th_boi_grp_code,
           t61.sap_charistic_value_desc AS sap_raw_th_boi_grp_lng_dsc,
           t01.sap_raw_allergen_code AS sap_raw_allergen_code,
           t62.sap_charistic_value_shrt_desc AS sap_raw_allergen_sht_dsc,
           t62.sap_charistic_value_long_desc AS sap_raw_allergen_lng_dsc
      FROM bds_material_classfctn t01,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC001') t02,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC002') t03,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC003') t04,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC007') t05,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC006') t06,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC004') t07,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC005') t08,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC008') t09,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC011') t10,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC009') t11,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC010') t12,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC012') t13,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC017') t14,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC014') t15,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC018') t16,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC013') t17,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC021') t18,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC020') t19,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC019') t20,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC022') t21,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC023') t22,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC024') t23,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC016') t24,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC025') t25,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC040') t26,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC038') t27,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR6') t28,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR7') t29,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR1') t30,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR2') t31,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR3') t32,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR4') t33,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR5') t34,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR8') t35,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR9') t36,
           bds_material_hdr t37,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_VERP01') t38,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_VERP02') t39,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_ROH01') t40,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_ROH02') t41,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_ROH03') t42,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_ROH04') t43,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_ROH05') t44,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR10') t45,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR11') t46,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR12') t47,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR13') t48,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR14') t49,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR15') t50,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR16') t51,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR17') t52,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR18') t53,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR19') t54,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR20') t55,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR21') t56,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APVERP01') t57,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APVERP02') t58,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR22') t59,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APCHAR23') t60,
           (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
              FROM bds_charistic_value_en a
             WHERE sap_charistic_code = 'Z_APROH01') t61,
           (SELECT a.sap_charistic_value_code,
                   a.sap_charistic_value_shrt_desc,
                   a.sap_charistic_value_long_desc
              FROM bds_refrnc_charistic a
             WHERE sap_charistic_code = '/MARS/MD_CHC066') t62
     WHERE     t01.sap_bus_sgmnt_code = t02.sap_charistic_value_code(+)
           AND t01.sap_mrkt_sgmnt_code = t03.sap_charistic_value_code(+)
           AND t01.sap_brand_flag_code = t04.sap_charistic_value_code(+)
           AND t01.sap_funcl_vrty_code = t05.sap_charistic_value_code(+)
           AND t01.sap_ingrdnt_vrty_code = t06.sap_charistic_value_code(+)
           AND t01.sap_brand_sub_flag_code = t07.sap_charistic_value_code(+)
           AND t01.sap_supply_sgmnt_code = t08.sap_charistic_value_code(+)
           AND t01.sap_trade_sector_code = t09.sap_charistic_value_code(+)
           AND t01.sap_occsn_code = t10.sap_charistic_value_code(+)
           AND t01.sap_mrkting_concpt_code = t11.sap_charistic_value_code(+)
           AND t01.sap_multi_pack_qty_code = t12.sap_charistic_value_code(+)
           AND t01.sap_prdct_ctgry_code = t13.sap_charistic_value_code(+)
           AND t01.sap_pack_type_code = t14.sap_charistic_value_code(+)
           AND t01.sap_size_code = t15.sap_charistic_value_code(+)
           AND t01.sap_size_grp_code = t16.sap_charistic_value_code(+)
           AND t01.sap_prdct_type_code = t17.sap_charistic_value_code(+)
           AND t01.sap_trad_unit_config_code =
                  t18.sap_charistic_value_code(+)
           AND t01.sap_trad_unit_frmt_code = t19.sap_charistic_value_code(+)
           AND t01.sap_dsply_storg_condtn_code =
                  t20.sap_charistic_value_code(+)
           AND t01.sap_onpack_cnsmr_value_code =
                  t21.sap_charistic_value_code(+)
           AND t01.sap_onpack_cnsmr_offer_code =
                  t22.sap_charistic_value_code(+)
           AND t01.sap_onpack_trade_offer_code =
                  t23.sap_charistic_value_code(+)
           AND t01.sap_brand_essnc_code = t24.sap_charistic_value_code(+)
           AND t01.sap_cnsmr_pack_frmt_code = t25.sap_charistic_value_code(+)
           AND t01.sap_cuisine_code = t26.sap_charistic_value_code(+)
           AND t01.sap_fpps_minor_pack_code = t27.sap_charistic_value_code(+)
           AND t01.sap_fighting_unit_code = t28.sap_charistic_value_code(+)
           AND t01.sap_china_bdt_code = t29.sap_charistic_value_code(+)
           AND t01.sap_mrkt_ctgry_code = t30.sap_charistic_value_code(+)
           AND t01.sap_mrkt_sub_ctgry_code = t31.sap_charistic_value_code(+)
           AND t01.sap_mrkt_sub_ctgry_grp_code =
                  t32.sap_charistic_value_code(+)
           AND t01.sap_sop_bus_code = t33.sap_charistic_value_code(+)
           AND t01.sap_prodctn_line_code = t34.sap_charistic_value_code(+)
           AND t01.sap_planning_src_code = t35.sap_charistic_value_code(+)
           AND t01.sap_sub_fighting_unit_code =
                  t36.sap_charistic_value_code(+)
           AND t01.sap_material_code = t37.sap_material_code(+)
           AND t01.sap_pack_family_code = t38.sap_charistic_value_code(+)
           AND t01.sap_pack_sub_family_code = t39.sap_charistic_value_code(+)
           AND t01.sap_raw_family_code = t40.sap_charistic_value_code(+)
           AND t01.sap_raw_sub_family_code = t41.sap_charistic_value_code(+)
           AND t01.sap_raw_group_code = t42.sap_charistic_value_code(+)
           AND t01.sap_animal_parts_code = t43.sap_charistic_value_code(+)
           AND t01.sap_physical_condtn_code = t44.sap_charistic_value_code(+)
           AND t01.sap_china_abc_indctr_code =
                  t45.sap_charistic_value_code(+)
           AND t01.sap_nz_promotional_grp_code =
                  t46.sap_charistic_value_code(+)
           AND t01.sap_nz_sop_business_code = t47.sap_charistic_value_code(+)
           AND t01.sap_nz_must_win_ctgry_code =
                  t48.sap_charistic_value_code(+)
           AND t01.sap_au_snk_activity_name = t49.sap_charistic_value_code(+)
           AND t01.sap_china_forecast_group = t50.sap_charistic_value_code(+)
           AND t01.sap_hk_sub_ctgry_code = t51.sap_charistic_value_code(+)
           AND t01.sap_hk_line_code = t52.sap_charistic_value_code(+)
           AND t01.sap_hk_product_sgmnt_code =
                  t53.sap_charistic_value_code(+)
           AND t01.sap_hk_type_code = t54.sap_charistic_value_code(+)
           AND t01.sap_strgy_grp_code = t55.sap_charistic_value_code(+)
           AND t01.sap_th_boi_code = t56.sap_charistic_value_code(+)
           AND t01.sap_pack_dspsal_class = t57.sap_charistic_value_code(+)
           AND t01.sap_th_boi_grp_code = t58.sap_charistic_value_code(+)
           AND t01.sap_nz_launch_ranking_code =
                  t59.sap_charistic_value_code(+)
           AND t01.sap_nz_selectively_grow_code =
                  t60.sap_charistic_value_code(+)
           AND t01.sap_raw_th_boi_grp_code = t61.sap_charistic_value_code(+)
           AND t01.sap_raw_allergen_code = t62.sap_charistic_value_code(+));
COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BUS_SGMNT_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT01 Path:/MARS/MD_CHC001';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BUS_SGMNT_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT01 Path:/MARS/MD_CHC001';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BUS_SGMNT_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT01 Path:/MARS/MD_CHC001';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_SGMNT_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT02 Path:/MARS/MD_CHC002';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_SGMNT_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT02 Path:/MARS/MD_CHC002';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_SGMNT_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT02 Path:/MARS/MD_CHC002';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_FLAG_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT03 Path:/MARS/MD_CHC003';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_FLAG_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT03 Path:/MARS/MD_CHC003';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_FLAG_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT03 Path:/MARS/MD_CHC003';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FUNCL_VRTY_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT07 Path:/MARS/MD_CHC007';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FUNCL_VRTY_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT07 Path:/MARS/MD_CHC007';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FUNCL_VRTY_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT07 Path:/MARS/MD_CHC007';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_INGRDNT_VRTY_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT06 Path:/MARS/MD_CHC006';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_INGRDNT_VRTY_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT06 Path:/MARS/MD_CHC006';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_INGRDNT_VRTY_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT06 Path:/MARS/MD_CHC006';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_SUB_FLAG_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT04 Path:/MARS/MD_CHC004';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_SUB_FLAG_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT04 Path:/MARS/MD_CHC004';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_SUB_FLAG_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT04 Path:/MARS/MD_CHC004';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SUPPLY_SGMNT_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT05 Path:/MARS/MD_CHC005';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SUPPLY_SGMNT_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT05 Path:/MARS/MD_CHC005';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SUPPLY_SGMNT_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT05 Path:/MARS/MD_CHC005';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRADE_SECTOR_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT08 Path:/MARS/MD_CHC008';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRADE_SECTOR_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT08 Path:/MARS/MD_CHC008';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRADE_SECTOR_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT08 Path:/MARS/MD_CHC008';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_OCCSN_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT11 Path:/MARS/MD_CHC011';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_OCCSN_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT11 Path:/MARS/MD_CHC011';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_OCCSN_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT11 Path:/MARS/MD_CHC011';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKTING_CONCPT_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT09 Path:/MARS/MD_CHC009';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKTING_CONCPT_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT09 Path:/MARS/MD_CHC009';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKTING_CONCPT_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT09 Path:/MARS/MD_CHC009';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MULTI_PACK_QTY_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT10 Path:/MARS/MD_CHC010';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MULTI_PACK_QTY_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT10 Path:/MARS/MD_CHC010';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MULTI_PACK_QTY_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT10 Path:/MARS/MD_CHC010';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRDCT_CTGRY_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT12 Path:/MARS/MD_CHC012';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRDCT_CTGRY_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT12 Path:/MARS/MD_CHC012';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRDCT_CTGRY_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT12 Path:/MARS/MD_CHC012';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_TYPE_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT17 Path:/MARS/MD_CHC017';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_TYPE_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT17 Path:/MARS/MD_CHC017';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_TYPE_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT17 Path:/MARS/MD_CHC017';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SIZE_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT14 Path:/MARS/MD_CHC014';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SIZE_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT14 Path:/MARS/MD_CHC014';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SIZE_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT14 Path:/MARS/MD_CHC014';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SIZE_GRP_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT18 Path:/MARS/MD_CHC018';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SIZE_GRP_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT18 Path:/MARS/MD_CHC018';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SIZE_GRP_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT18 Path:/MARS/MD_CHC018';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRDCT_TYPE_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT13 Path:/MARS/MD_CHC013';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRDCT_TYPE_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT13 Path:/MARS/MD_CHC013';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRDCT_TYPE_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT13 Path:/MARS/MD_CHC013';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRAD_UNIT_CONFIG_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT21 Path:/MARS/MD_CHC021';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRAD_UNIT_CONFIG_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT21 Path:/MARS/MD_CHC021';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRAD_UNIT_CONFIG_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT21 Path:/MARS/MD_CHC021';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRAD_UNIT_FRMT_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT20 Path:/MARS/MD_CHC020';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRAD_UNIT_FRMT_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT20 Path:/MARS/MD_CHC020';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TRAD_UNIT_FRMT_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT20 Path:/MARS/MD_CHC020';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_DSPLY_STORG_CONDTN_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT19 Path:/MARS/MD_CHC019';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_DSPLY_STORG_CONDTN_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT19 Path:/MARS/MD_CHC019';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_DSPLY_STORG_CONDTN_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT19 Path:/MARS/MD_CHC019';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_CNSMR_VALUE_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT22 Path:/MARS/MD_CHC022';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_CNSMR_VALUE_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT22 Path:/MARS/MD_CHC022';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_CNSMR_VALUE_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT22 Path:/MARS/MD_CHC022';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_CNSMR_OFFER_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT23 Path:/MARS/MD_CHC023';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_CNSMR_OFFER_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT23 Path:/MARS/MD_CHC023';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_CNSMR_OFFER_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT23 Path:/MARS/MD_CHC023';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_TRADE_OFFER_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT24 Path:/MARS/MD_CHC024';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_TRADE_OFFER_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT24 Path:/MARS/MD_CHC024';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ONPACK_TRADE_OFFER_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT24 Path:/MARS/MD_CHC024';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_ESSNC_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT16 Path:/MARS/MD_CHC016';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_ESSNC_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT16 Path:/MARS/MD_CHC016';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_BRAND_ESSNC_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT16 Path:/MARS/MD_CHC016';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CNSMR_PACK_FRMT_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT25 Path:/MARS/MD_CHC025';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CNSMR_PACK_FRMT_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT25 Path:/MARS/MD_CHC025';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CNSMR_PACK_FRMT_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT25 Path:/MARS/MD_CHC025';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CUISINE_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT40 Path:/MARS/MD_CHC040';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CUISINE_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT40 Path:/MARS/MD_CHC040';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CUISINE_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT40 Path:/MARS/MD_CHC040';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FPPS_MINOR_PACK_CODE IS 'Class:ZZGLOBAL Characteristic:CLFFERT38 Path:/MARS/MD_CHC038';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FPPS_MINOR_PACK_SHT_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT38 Path:/MARS/MD_CHC038';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FPPS_MINOR_PACK_LNG_DSC IS 'Class:ZZGLOBAL Characteristic:CLFFERT38 Path:/MARS/MD_CHC038';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FIGHTING_UNIT_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR6';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_FIGHTING_UNIT_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR6';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CHINA_BDT_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR7';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CHINA_BDT_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR7';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_CTGRY_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR1';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_CTGRY_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR1';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_SUB_CTGRY_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR2';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_SUB_CTGRY_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR2';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_SUB_CTGRY_GRP_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR3';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_MRKT_SUB_CTGRY_GRP_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR3';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SOP_BUS_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR4';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SOP_BUS_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR4';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRODCTN_LINE_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR5';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PRODCTN_LINE_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR5';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PLANNING_SRC_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR8';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PLANNING_SRC_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR8';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SUB_FIGHTING_UNIT_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR9';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_SUB_FIGHTING_UNIT_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR9';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_FAMILY_CODE IS 'Class:ZZPACK Characteristic:CLFVERP01 Path:/MARS/MD_VERP01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_FAMILY_LNG_DSC IS 'Class:ZZPACK Characteristic:CLFVERP01 Path:/MARS/MD_VERP01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_SUB_FAMILY_CODE IS 'Class:ZZPACK Characteristic:CLFVERP02 Path:/MARS/MD_VERP02';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_SUB_FAMILY_LNG_DSC IS 'Class:ZZPACK Characteristic:CLFVERP02 Path:/MARS/MD_VERP02';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_FAMILY_CODE IS 'Class:ZZRAWS Characteristic:CLFROH01 Path:/MARS/MD_ROH01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_FAMILY_LNG_DSC IS 'Class:ZZRAWS Characteristic:CLFROH01 Path:/MARS/MD_ROH01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_SUB_FAMILY_CODE IS 'Class:ZZRAWS Characteristic:CLFROH02 Path:/MARS/MD_ROH02';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_SUB_FAMILY_LNG_DSC IS 'Class:ZZRAWS Characteristic:CLFROH02 Path:/MARS/MD_ROH02';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_GROUP_CODE IS 'Class:ZZRAWS Characteristic:CLFROH03 Path:/MARS/MD_ROH03';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_GROUP_LNG_DSC IS 'Class:ZZRAWS Characteristic:CLFROH03 Path:/MARS/MD_ROH03';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ANIMAL_PARTS_CODE IS 'Class:ZZRAWS Characteristic:CLFROH04 Path:/MARS/MD_ROH04';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_ANIMAL_PARTS_LNG_DSC IS 'Class:ZZRAWS Characteristic:CLFROH04 Path:/MARS/MD_ROH04';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PHYSICAL_CONDTN_CODE IS 'Class:ZZRAWS Characteristic:CLFROH05 Path:/MARS/MD_ROH05';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PHYSICAL_CONDTN_LNG_DSC IS 'Class:ZZRAWS Characteristic:CLFROH05 Path:/MARS/MD_ROH05';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CHINA_ABC_INDCTR_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR10';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CHINA_ABC_INDCTR_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR10';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_PROMOTIONAL_GRP_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR11';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_PROMOTIONAL_GRP_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR11';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_SOP_BUSINESS_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR12';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_SOP_BUSINESS_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR12';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_MUST_WIN_CTGRY_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR13';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_MUST_WIN_CTGRY_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR13';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_AU_SNK_ACTIVITY_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR14';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_AU_SNK_ACTIVITY_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR14';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CHINA_FORECAST_GROUP_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR15';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_CHINA_FORECAST_GROUP_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR15';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_SUB_CTGRY_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR16';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_SUB_CTGRY_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR16';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_LINE_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR17';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_LINE_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR17';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_PRODUCT_SGMNT_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR18';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_PRODUCT_SGMNT_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR18';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_TYPE_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR19';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_HK_TYPE_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR19';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_STRGY_GRP_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR20';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_STRGY_GRP_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR20';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TH_BOI_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR21';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TH_BOI_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR21';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_DSPSAL_CLASS_CODE IS 'Class:ZZAPVERP Characteristic:Z_APVERP01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_PACK_DSPSAL_CLASS_LNG_DSC IS 'Class:ZZAPVERP Characteristic:Z_APVERP01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TH_BOI_GRP_CODE IS 'Class:ZZAPVERP Characteristic:Z_APVERP02';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_TH_BOI_GRP_LNG_DSC IS 'Class:ZZAPVERP Characteristic:Z_APVERP02';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_LAUNCH_RANKING_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR22';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_LAUNCH_RANKING_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR22';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_SELECTIVELY_GROW_CODE IS 'Class:ZZAPMATL Characteristic:Z_APCHAR23';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_NZ_SELECTIVELY_GROW_DESC IS 'Class:ZZAPMATL Characteristic:Z_APCHAR23';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_TH_BOI_GRP_CODE IS 'Class:ZZAPROH Characteristic:Z_APROH01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_TH_BOI_GRP_LNG_DSC IS 'Class:ZZAPROH Characteristic:Z_APROH01';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_ALLERGEN_CODE IS 'Class:ZZRAWS Characteristic:CLFFERT66 Path:/MARS/MD_CHC066';

COMMENT ON COLUMN BDS.BDS_MATERIAL_CLASSFCTN_EN.SAP_RAW_ALLERGEN_LNG_DSC IS 'Class:ZZRAWS Characteristic:CLFFERT66 Path:/MARS/MD_CHC066';


DROP PUBLIC SYNONYM BDS_MATERIAL_CLASSFCTN_EN;

CREATE OR REPLACE PUBLIC SYNONYM BDS_MATERIAL_CLASSFCTN_EN FOR BDS.BDS_MATERIAL_CLASSFCTN_EN;

grant select on bds_material_classfctn_en to public;
