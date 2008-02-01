/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_ord_ipt_ptd_fd
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
create or replace force view bo_user.fp_rpt_ord_ipt_ptd_fd
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT
  T4.SAP_SALES_DTL_SALES_ORG_CODE,
  T4.SAP_SALES_DTL_DIVISION_CODE,
  T4.SAP_SALES_DTL_DISTBN_CHNL_CODE,
  (T4.SAP_SALES_DTL_SALES_ORG_CODE||T4.SAP_SALES_DTL_DIVISION_CODE||T4.SAP_SALES_DTL_DISTBN_CHNL_CODE) AS MFJ_DIV_CODE,
  DECODE((T4.SAP_SALES_DTL_SALES_ORG_CODE||T4.SAP_SALES_DTL_DIVISION_CODE||T4.SAP_SALES_DTL_DISTBN_CHNL_CODE),
          '1315111', 'Petcare',
          '1315120', 'Petcare',
          '1315110', 'Food',
          '1315710', 'Food' ) AS MFJ_BUG_DESC,
  DECODE((T4.SAP_SALES_DTL_SALES_ORG_CODE||T4.SAP_SALES_DTL_DIVISION_CODE||T4.SAP_SALES_DTL_DISTBN_CHNL_CODE),
          '1315111', 'Pet Grocery',
          '1315120', 'Pet Specialist',
          '1315110', 'Snackfood',
          '1315710', 'Food' ) AS MFJ_DIV_DESC,
  DECODE((T4.SAP_SALES_DTL_SALES_ORG_CODE||T4.SAP_SALES_DTL_DIVISION_CODE||T4.SAP_SALES_DTL_DISTBN_CHNL_CODE),
          '1315111', 1,
          '1315120', 2,
          '1315110', 4,
          '1315710', 5 ) AS SORT_ORDER,
  sum(T4.SALES_DTL_PRICE_VALUE_13) AS GSV,
  sum(T4.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  sum(T4.SALES_DTL_PRICE_VALUE_11) AS NIV
FROM
  SALES_PERIOD_03_FACT T4,
  DW_APP.MAX_MIN_REQD_DLVRY_DATE T5
WHERE  T4.SAP_BILLING_YYYYPP=T5.MARS_PERIOD
  AND  T4.SAP_SALES_DTL_SALES_ORG_CODE = '131'
  AND  T4.SAP_SALES_DTL_DIVISION_CODE IN ('51','57')
  AND  T4.SAP_SALES_DTL_DISTBN_CHNL_CODE = '10'
GROUP BY
  T4.SAP_SALES_DTL_SALES_ORG_CODE, 
  T4.SAP_SALES_DTL_DIVISION_CODE, 
  T4.SAP_SALES_DTL_DISTBN_CHNL_CODE;
