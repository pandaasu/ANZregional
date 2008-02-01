/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_ord_ipt_ptd_pg2
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
create or replace force view bo_user.fp_rpt_ord_ipt_ptd_pg2
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT
TT1.SAP_SALES_ORG_CODE,
TT1.SAP_DIVISION_CODE,
TT1.SAP_DISTBN_CHNL_CODE,
TT1.MFJ_DIV_CODE,
TT1.MFJ_BUG_DESC,
TT1.MFJ_DIV_DESC,
TT1.SORT_ORDER,
SUM(TT1.GSV) AS GSV,
SUM(TT1.BPS) AS BPS,
SUM(TT1.NIV) AS NIV
FROM
(
SELECT
  '131' AS SAP_SALES_ORG_CODE,
   '51' AS SAP_DIVISION_CODE,
   '11' AS SAP_DISTBN_CHNL_CODE,
  '1315111'                   AS MFJ_DIV_CODE,
  'Petcare'                   AS MFJ_BUG_DESC,
  'Pedigree Club Professional Model'               AS MFJ_DIV_DESC,
  2 AS SORT_ORDER,
  sum(T4.SALES_DTL_PRICE_VALUE_13) AS GSV,
  sum(T4.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  sum(T4.SALES_DTL_PRICE_VALUE_11) AS NIV
FROM
  SALES_PERIOD_03_FACT T4,
  DW_APP.MAX_MIN_REQD_DLVRY_DATE T5,
  MATERIAL_DIM    T6
WHERE T4.SAP_BILLING_YYYYPP=T5.MARS_PERIOD
  AND T4.SAP_SALES_DTL_SALES_ORG_CODE = '131'
  AND T4.SAP_MATERIAL_CODE = T6.SAP_MATERIAL_CODE
  AND T6.SAP_BRAND_SUB_FLAG_CODE = '459'
GROUP BY
  T4.SAP_SALES_DTL_SALES_ORG_CODE, 
  T4.SAP_SALES_DTL_DIVISION_CODE, 
  T4.SAP_SALES_DTL_DISTBN_CHNL_CODE
UNION ALL
SELECT
  '131' AS SAP_SALES_ORG_CODE,
   '51' AS SAP_DIVISION_CODE,
   '11' AS SAP_DISTBN_CHNL_CODE,
  '1315111'                   AS MFJ_DIV_CODE,
  'Petcare'                   AS MFJ_BUG_DESC,
  'Pedigree Club Professional Model'      AS MFJ_DIV_DESC,
  2 AS SORT_ORDER,
  0 AS GSV,
  0 AS BPS,
  0 AS NIV
FROM
SALES_ORG_DIM  T10            --- Dummy Table
WHERE
T10.SAP_SALES_ORG_CODE = '131' --- Dummy Condition
) TT1
GROUP BY
TT1.SAP_SALES_ORG_CODE,
TT1.SAP_DIVISION_CODE,
TT1.SAP_DISTBN_CHNL_CODE,
TT1.MFJ_DIV_CODE,
TT1.MFJ_BUG_DESC,
TT1.MFJ_DIV_DESC,
TT1.SORT_ORDER;