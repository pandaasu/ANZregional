DROP VIEW MANU.MATL_CLSSFCTN_FG_VW;

/* Formatted on 2008/12/22 11:23 (Formatter Plus v4.8.8) */
CREATE OR REPLACE FORCE VIEW manu.matl_clssfctn_fg_vw (material_code,
                                                       bus_sgmnt_code,
                                                       mkt_sgmnt_code,
                                                       brand_flag_code,
                                                       brand_sub_flag_code,
                                                       spply_sgmnt_code,
                                                       ingrdnt_vrty_code,
                                                       fnctnl_vrty_code,
                                                       trade_sctr_code,
                                                       mrktng_cncpt_code,
                                                       mltpck_qty_code,
                                                       occsn_code,
                                                       prdct_ctgry_code,
                                                       prdct_type_code,
                                                       size_code,
                                                       brand_essnc_code,
                                                       pack_type_code,
                                                       size_group_code,
                                                       dsply_strg_cndtn_code,
                                                       tdu_frmt_code,
                                                       tdu_cnfgrtn_code,
                                                       on_pack_cnsmr_value_code,
                                                       on_pack_cnsmr_offer_code,
                                                       on_pack_trade_offer_code,
                                                       cnsmr_pack_frmt_code
                                                      )
AS
  SELECT fg.material_code, "BUS_SGMNT_CODE", "MKT_SGMNT_CODE",
         "BRAND_FLAG_CODE", "BRAND_SUB_FLAG_CODE", "SPPLY_SGMNT_CODE",
         "INGRDNT_VRTY_CODE", "FNCTNL_VRTY_CODE", "TRADE_SCTR_CODE",
         "MRKTNG_CNCPT_CODE", "MLTPCK_QTY_CODE", "OCCSN_CODE",
         "PRDCT_CTGRY_CODE", "PRDCT_TYPE_CODE", "SIZE_CODE",
         "BRAND_ESSNC_CODE", "PACK_TYPE_CODE", "SIZE_GROUP_CODE",
         "DSPLY_STRG_CNDTN_CODE", "TDU_FRMT_CODE", "TDU_CNFGRTN_CODE",
         "ON_PACK_CNSMR_VALUE_CODE", "ON_PACK_CNSMR_OFFER_CODE",
         "ON_PACK_TRADE_OFFER_CODE", "CNSMR_PACK_FRMT_CODE"
    FROM matl_clssfctn_fg fg, material m
   WHERE m.material_code = fg.material_code;


DROP PUBLIC SYNONYM MATL_CLSSFCTN_FG_VW;

CREATE PUBLIC SYNONYM MATL_CLSSFCTN_FG_VW FOR MANU.MATL_CLSSFCTN_FG_VW;


GRANT SELECT ON MANU.MATL_CLSSFCTN_FG_VW TO MANU_APP WITH GRANT OPTION;

