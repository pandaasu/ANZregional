/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_ord_ipt_ptd_ps
 Owner  : bo_user

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view bo_user.fp_rpt_ord_ipt_ptd_ps
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT
  '131' AS SAP_SALES_ORG_CODE,
   '51' AS SAP_DIVISION_CODE,
   '20' AS SAP_DISTBN_CHNL_CODE,
  '1315120'                   AS MFJ_DIV_CODE,
  'Petcare'                   AS MFJ_BUG_DESC,
  'Pet Specialist'            AS MFJ_DIV_DESC,
  3 AS SORT_ORDER,
  sum(T4.SALES_DTL_PRICE_VALUE_13) AS GSV,
  sum(T4.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  sum(T4.SALES_DTL_PRICE_VALUE_11) AS NIV
FROM
  SALES_PERIOD_03_FACT T4,
  DW_APP.MAX_MIN_REQD_DLVRY_DATE T5,
  MATERIAL_DIM    T6
WHERE T4.SAP_BILLING_YYYYPP = T5.MARS_PERIOD
  AND T4.SAP_SALES_DTL_SALES_ORG_CODE = '131'
  AND T4.SAP_SALES_DTL_DIVISION_CODE = '51'
  AND T4.SAP_SALES_DTL_DISTBN_CHNL_CODE = '20'
  AND T4.SAP_MATERIAL_CODE = T6.SAP_MATERIAL_CODE
  AND T6.SAP_BRAND_SUB_FLAG_CODE != '459'
GROUP BY
  T4.SAP_SALES_DTL_SALES_ORG_CODE, 
  T4.SAP_SALES_DTL_DIVISION_CODE, 
  T4.SAP_SALES_DTL_DISTBN_CHNL_CODE;