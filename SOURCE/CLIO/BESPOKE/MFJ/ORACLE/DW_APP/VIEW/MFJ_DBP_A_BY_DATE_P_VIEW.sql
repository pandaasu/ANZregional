CREATE OR REPLACE FORCE VIEW MFJ_DBP_A_BY_DATE_P_VIEW
(

/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mfj_dbp_a_by_date_p_view
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view mfj_dbp_a_by_date_p_view
   (BILLING_DATE_YYYYMMDD, SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, 
 MFJ_BUG_DESC, MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, 
 NIV)
AS 
SELECT
  TO_CHAR(DD.SALES_FACT.BILLING_DATE,'YYYYMMDD') AS BILLING_DATE_YYYYMMDD,
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE     AS SAP_SALES_ORG_CODE,
  DD.DIVISION_DIM.SAP_DIVISION_CODE       AS SAP_DIVISION_CODE,
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE AS SAP_DISTBN_CHNL_CODE,
  (DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE) AS MFJ_DIV_CODE,
  DECODE((DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE),
          '1315111', 'Petcare',
          '1315120', 'Petcare',
          '1315110', 'Food',
          '1315710', 'Food',
          '1325110', 'Drinks' ) AS MFJ_BUG_DESC,
  DECODE((DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE),
          '1315111', 'Pet Grocery',
          '1315120', 'Pet Specialist',
          '1315110', 'Snackfood',
          '1315710', 'Food',
          '1325110', 'Drinks' ) AS MFJ_DIV_DESC,
  DECODE((DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE),
          '1315111', 1,
          '1315120', 2,
          '1315110', 3,
          '1315710', 4,
          '1325110', 5 ) AS SORT_ORDER,
  SUM(DD.SALES_FACT.SALES_DTL_PRICE_VALUE_13) AS GSV,
  SUM(DD.SALES_FACT.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  SUM(DD.SALES_FACT.SALES_DTL_PRICE_VALUE_11) AS NIV
FROM
  DD.SALES_ORG_DIM,
  DD.DIVISION_DIM,
  DD.DISTBN_CHNL_DIM,
  DD.SALES_FACT,
  DW_APP.MAX_MIN_BILLING_DATE
WHERE
--  ( TRUNC(DD.SALES_FACT.BILLING_YYYYPPDD/100) >= DW_APP.MAX_MIN_BILLING_DATE.MIN_YYYYPP_DATE AND
--    TRUNC(DD.SALES_FACT.BILLING_YYYYPPDD/100) <= DW_APP.MAX_MIN_BILLING_DATE.MAX_YYYYPP_DATE )
       ( TRUNC(DD.SALES_FACT.BILLING_YYYYPPDD/100) = DW_APP.MAX_MIN_BILLING_DATE.MIN_YYYYPP_DATE )
  AND  ( DD.SALES_FACT.SALES_DTL_DISTBN_CHNL_CODE=DD.DISTBN_CHNL_DIM.DISTBN_CHNL_CODE  )
  AND  ( DD.SALES_FACT.SALES_DTL_DIVISION_CODE=DD.DIVISION_DIM.DIVISION_CODE  )
  AND  ( DD.SALES_FACT.SALES_DTL_SALES_ORG_CODE=DD.SALES_ORG_DIM.SALES_ORG_CODE  )
  AND  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE  IN ('131','132')
GROUP BY
  TO_CHAR(DD.SALES_FACT.BILLING_DATE,'YYYYMMDD'),
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE,
  DD.DIVISION_DIM.SAP_DIVISION_CODE,
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE
ORDER BY
  SORT_ORDER;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mfj_dbp_a_by_date_p_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mfj_dbp_a_by_date_p_view for dw_app.mfj_dbp_a_by_date_p_view;

