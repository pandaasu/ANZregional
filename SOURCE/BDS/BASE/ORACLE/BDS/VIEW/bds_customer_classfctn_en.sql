 /******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : BDS
 Table   : BDS_CUSTOMER_CLASSFCTN_EN
 Owner   : BDS
 Author  : Linden Glen

 Description
 -----------
 Business Data Store - Customer Characteristic/Classification View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/11   Linden Glen    Created
 2007/09   Linden Glen    Added ZZAUCUST01
 2008/01   Linden Glen    Added Z_APCHAR10 to 13 to process_material
                          Added CLFFERT109, ZZCNCUST01, ZZCNCUST02, ZZCNCUST03, ZZCNCUST04,
                                ZZCNCUST05, ZZAUCUST01, ZZAUCUST02 

*******************************************************************************/


/**/
/* Table creation
/**/
create or replace view bds_customer_classfctn_en as  
CREATE OR REPLACE FORCE VIEW bds.bds_customer_classfctn_en (sap_customer_code,
                                                            sap_pos_frmt_grp_code,
                                                            sap_pos_frmt_grp_desc,
                                                            sap_pos_frmt_code,
                                                            sap_pos_frmt_desc,
                                                            sap_pos_frmt_size_code,
                                                            sap_pos_frmt_size_desc,
                                                            sap_pos_place_code,
                                                            sap_pos_place_desc,
                                                            sap_banner_code,
                                                            sap_banner_desc,
                                                            sap_ultmt_prnt_acct_code,
                                                            sap_ultmt_prnt_acct_desc,
                                                            sap_multi_mrkt_acct_code,
                                                            sap_multi_mrkt_acct_desc,
                                                            sap_cust_buying_grp_code,
                                                            sap_cust_buying_grp_desc,
                                                            sap_dstrbtn_route_code,
                                                            sap_dstrbtn_route_desc,
                                                            sap_prim_route_to_cnsmr_code,
                                                            sap_prim_route_to_cnsmr_desc,
                                                            sap_operation_bus_model_code,
                                                            sap_operation_bus_model_desc,
                                                            sap_fundrsng_sales_trrtry_code,
                                                            sap_fundrsng_sales_trrtry_desc,
                                                            sap_fundrsng_grp_type_code,
                                                            sap_fundrsng_grp_type_desc,
                                                            sap_cn_sales_team_code,
                                                            sap_cn_sales_team_desc,
                                                            sap_petcare_city_tier_code,
                                                            sap_petcare_city_tier_desc,
                                                            sap_snackfood_city_tier_code,
                                                            sap_snackfood_city_tier_desc,
                                                            sap_channel_code,
                                                            sap_channel_desc,
                                                            sap_sub_channel_code,
                                                            sap_sub_channel_desc,
                                                            sap_ap_cust_grp_food_code,
                                                            sap_ap_cust_grp_food_desc,
                                                            sap_th_channel_code,
                                                            sap_th_channel_desc,
                                                            sap_th_sub_channel_code,
                                                            sap_th_sub_channel_desc,
                                                            sap_th_sales_area_neg_code,
                                                            sap_th_sales_area_neg_desc,
                                                            sap_th_sales_area_geo_code,
                                                            sap_th_sales_area_geo_desc
                                                           )
AS
   SELECT t01.sap_customer_code AS sap_customer_code,
          t01.sap_pos_frmt_grp_code AS sap_pos_frmt_grp_code,
          t02.sap_charistic_value_desc AS sap_pos_frmt_grp_desc,
          t01.sap_pos_frmt_code AS sap_pos_frmt_code,
          t03.sap_charistic_value_desc AS sap_pos_frmt_desc,
          t01.sap_pos_frmt_size_code AS sap_pos_frmt_size_code,
          t04.sap_charistic_value_desc AS sap_pos_frmt_size_desc,
          t01.sap_pos_place_code AS sap_pos_place_code,
          t05.sap_charistic_value_desc AS sap_pos_place_desc,
          t01.sap_banner_code AS sap_banner_code,
          t06.sap_charistic_value_desc AS sap_banner_desc,
          t01.sap_ultmt_prnt_acct_code AS sap_ultmt_prnt_acct_code,
          t07.sap_charistic_value_desc AS sap_ultmt_prnt_acct_desc,
          t01.sap_multi_mrkt_acct_code AS sap_multi_mrkt_acct_code,
          t08.sap_charistic_value_desc AS sap_multi_mrkt_acct_desc,
          t01.sap_cust_buying_grp_code AS sap_cust_buying_grp_code,
          t09.sap_charistic_value_desc AS sap_cust_buying_grp_desc,
          t01.sap_dstrbtn_route_code AS sap_dstrbtn_route_code,
          t10.sap_charistic_value_desc AS sap_dstrbtn_route_desc,
          t01.sap_prim_route_to_cnsmr_code AS sap_prim_route_to_cnsmr_code,
          t11.sap_charistic_value_desc AS sap_prim_route_to_cnsmr_desc,
          t01.sap_operation_bus_model_code AS sap_operation_bus_model_code,
          t12.sap_charistic_value_desc AS sap_operation_bus_model_desc,
          t01.sap_fundrsng_sales_trrtry_code
                                            AS sap_fundrsng_sales_trrtry_code,
          t13.sap_charistic_value_desc AS sap_fundrsng_sales_trrtry_desc,
          t01.sap_fundrsng_grp_type_code AS sap_fundrsng_grp_type_code,
          t14.sap_charistic_value_desc AS sap_fundrsng_grp_type_desc,
          t01.sap_cn_sales_team_code AS sap_cn_sales_team_code,
          t15.sap_charistic_value_desc AS sap_cn_sales_team_desc,
          t01.sap_petcare_city_tier_code AS sap_petcare_city_tier_code,
          t16.sap_charistic_value_desc AS sap_petcare_city_tier_desc,
          t01.sap_snackfood_city_tier_code AS sap_snackfood_city_tier_code,
          t17.sap_charistic_value_desc AS sap_snackfood_city_tier_desc,
          t01.sap_channel_code AS sap_channel_code,
          t18.sap_charistic_value_desc AS sap_channel_desc,
          t01.sap_sub_channel_code AS sap_sub_channel_code,
          t19.sap_charistic_value_desc AS sap_sub_channel_desc,
          t01.sap_ap_cust_grp_food_code AS sap_ap_cust_grp_food_code,
          t20.sap_charistic_value_desc AS sap_ap_cust_grp_food_desc,
          t01.sap_th_channel_code AS sap_th_channel_code,
          t21.sap_charistic_value_desc AS sap_th_channel_desc,
          t01.sap_th_sub_channel_code AS sap_th_sub_channel_code,
          t22.sap_charistic_value_desc AS sap_th_sub_channel_desc,
          t01.sap_th_sales_area_neg_code AS sap_th_sales_area_neg_code,
          t23.sap_charistic_value_desc AS sap_th_sales_area_neg_desc,
          t01.sap_th_sales_area_geo_code AS sap_th_sales_area_geo_code,
          t24.sap_charistic_value_desc AS sap_th_sales_area_geo_desc
     FROM bds_customer_classfctn t01,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT41') t02,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT101') t03,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT102') t04,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT103') t05,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT104') t06,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT105') t07,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT37') t08,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT36') t09,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT106') t10,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT107') t11,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT108') t12,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZAUCUST01') t13,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZAUCUST02') t14,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZCNCUST01') t15,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZCNCUST02') t16,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZCNCUST03') t17,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZCNCUST04') t18,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZCNCUST05') t19,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'CLFFERT109') t20,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZTHCUST01') t21,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZTHCUST02') t22,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZTHCUST03') t23,
          (SELECT a.sap_charistic_value_code, a.sap_charistic_value_desc
             FROM bds_charistic_value_en a
            WHERE sap_charistic_code = 'ZZTHCUST04') t24
    WHERE t01.sap_pos_frmt_grp_code = t02.sap_charistic_value_code(+)
      AND t01.sap_pos_frmt_code = t03.sap_charistic_value_code(+)
      AND t01.sap_pos_frmt_size_code = t04.sap_charistic_value_code(+)
      AND t01.sap_pos_place_code = t05.sap_charistic_value_code(+)
      AND t01.sap_banner_code = t06.sap_charistic_value_code(+)
      AND t01.sap_ultmt_prnt_acct_code = t07.sap_charistic_value_code(+)
      AND t01.sap_multi_mrkt_acct_code = t08.sap_charistic_value_code(+)
      AND t01.sap_cust_buying_grp_code = t09.sap_charistic_value_code(+)
      AND t01.sap_dstrbtn_route_code = t10.sap_charistic_value_code(+)
      AND t01.sap_prim_route_to_cnsmr_code = t11.sap_charistic_value_code(+)
      AND t01.sap_operation_bus_model_code = t12.sap_charistic_value_code(+)
      AND t01.sap_fundrsng_sales_trrtry_code = t13.sap_charistic_value_code(+)
      AND t01.sap_fundrsng_grp_type_code = t14.sap_charistic_value_code(+)
      AND t01.sap_cn_sales_team_code = t15.sap_charistic_value_code(+)
      AND t01.sap_petcare_city_tier_code = t16.sap_charistic_value_code(+)
      AND t01.sap_snackfood_city_tier_code = t17.sap_charistic_value_code(+)
      AND t01.sap_channel_code = t18.sap_charistic_value_code(+)
      AND t01.sap_sub_channel_code = t19.sap_charistic_value_code(+)
      AND t01.sap_ap_cust_grp_food_code = t20.sap_charistic_value_code(+)
      AND t01.sap_th_channel_code = t21.sap_charistic_value_code(+)
      AND t01.sap_th_sub_channel_code = t22.sap_charistic_value_code(+)
      AND t01.sap_th_sales_area_neg_code = t23.sap_charistic_value_code(+)
      AND t01.sap_th_sales_area_geo_code = t24.sap_charistic_value_code(+);


/**/
/* Comments
/**/
COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_FUNDRSNG_GRP_TYPE_CODE IS 'ZZAUCUST02';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_FUNDRSNG_GRP_TYPE_DESC IS 'ZZAUCUST02';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_CN_SALES_TEAM_CODE IS 'ZZCNCUST01';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_CN_SALES_TEAM_DESC IS 'ZZCNCUST01';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_PETCARE_CITY_TIER_CODE IS 'ZZCNCUST02';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_PETCARE_CITY_TIER_DESC IS 'ZZCNCUST02';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_SNACKFOOD_CITY_TIER_CODE IS 'ZZCNCUST03';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_SNACKFOOD_CITY_TIER_DESC IS 'ZZCNCUST03';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_CHANNEL_CODE IS 'ZZCNCUST04';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_CHANNEL_DESC IS 'ZZCNCUST04';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_SUB_CHANNEL_CODE IS 'ZZCNCUST05';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_SUB_CHANNEL_DESC IS 'ZZCNCUST05';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_AP_CUST_GRP_FOOD_CODE IS 'CLFFERT109';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_AP_CUST_GRP_FOOD_DESC IS 'CLFFERT109';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_CHANNEL_CODE IS 'ZZTHCUST01';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_CHANNEL_DESC IS 'ZZTHCUST01';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_SUB_CHANNEL_CODE IS 'ZZTHCUST02';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_SUB_CHANNEL_DESC IS 'ZZTHCUST02';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_SALES_AREA_NEG_CODE IS 'ZZTHCUST03';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_SALES_AREA_NEG_DESC IS 'ZZTHCUST03';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_SALES_AREA_GEO_CODE IS 'ZZTHCUST04';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_TH_SALES_AREA_GEO_DESC IS 'ZZTHCUST04';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_FRMT_GRP_CODE IS 'CLFFERT41';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_FRMT_GRP_DESC IS 'CLFFERT41';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_FRMT_CODE IS 'CLFFERT101';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_FRMT_DESC IS 'CLFFERT101';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_FRMT_SIZE_CODE IS 'CLFFERT102';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_FRMT_SIZE_DESC IS 'CLFFERT102';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_PLACE_CODE IS 'CLFFERT103';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_POS_PLACE_DESC IS 'CLFFERT103';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_BANNER_CODE IS 'CLFFERT104';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_BANNER_DESC IS 'CLFFERT104';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_ULTMT_PRNT_ACCT_CODE IS 'CLFFERT105';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_ULTMT_PRNT_ACCT_DESC IS 'CLFFERT105';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_MULTI_MRKT_ACCT_CODE IS 'CLFFERT37';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_MULTI_MRKT_ACCT_DESC IS 'CLFFERT37';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_CUST_BUYING_GRP_CODE IS 'CLFFERT36';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_CUST_BUYING_GRP_DESC IS 'CLFFERT36';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_DSTRBTN_ROUTE_CODE IS 'CLFFERT106';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_DSTRBTN_ROUTE_DESC IS 'CLFFERT106';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_PRIM_ROUTE_TO_CNSMR_CODE IS 'CLFFERT107';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_PRIM_ROUTE_TO_CNSMR_DESC IS 'CLFFERT107';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_OPERATION_BUS_MODEL_CODE IS 'CLFFERT108';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_OPERATION_BUS_MODEL_DESC IS 'CLFFERT108';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_FUNDRSNG_SALES_TRRTRY_CODE IS 'ZZAUCUST01';

COMMENT ON COLUMN BDS.BDS_CUSTOMER_CLASSFCTN_EN.SAP_FUNDRSNG_SALES_TRRTRY_DESC IS 'ZZAUCUST01';


/**/
/* Synonym
/**/
create or replace public synonym bds_customer_classfctn_en for bds.bds_customer_classfctn_en;


/**/
/* Authority
/**/
grant select on bds_customer_classfctn_en to public with grant option;