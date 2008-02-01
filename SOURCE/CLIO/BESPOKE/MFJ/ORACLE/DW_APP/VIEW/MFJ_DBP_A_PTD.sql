/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mfj_dbp_a_ptd
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
create or replace force view mfj_dbp_a_ptd
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE,
  DD.DIVISION_DIM.SAP_DIVISION_CODE,
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE,
  (DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE) AS MFJ_DIV_CODE,
  DECODE((DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE),
          '1315111', 'Petcare',
          '1315120', 'Petcare',
          '1315110', 'Food',
          '1315710', 'Food' ) AS MFJ_BUG_DESC,
  DECODE((DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE),
          '1315111', 'Pet Grocery',
          '1315120', 'Pet Specialist',
          '1315110', 'Snackfood',
          '1315710', 'Food' ) AS MFJ_DIV_DESC,
  DECODE((DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE||DD.DIVISION_DIM.SAP_DIVISION_CODE||DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE),
          '1315111', 1,
          '1315120', 2,
          '1315110', 3,
          '1315710', 4 ) AS SORT_ORDER,
  sum(DD.SALES_PERIOD_01_FACT.SALES_DTL_PRICE_VALUE_13) AS GSV,
  sum(DD.SALES_PERIOD_01_FACT.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  sum(DD.SALES_PERIOD_01_FACT.SALES_DTL_PRICE_VALUE_11) AS NIV
FROM
  DD.SALES_ORG_DIM,
  DD.DIVISION_DIM,
  DD.DISTBN_CHNL_DIM,
  DD.SALES_PERIOD_01_FACT,
  DD.MARS_DATE_PERIOD_DIM
WHERE
  ( DD.MARS_DATE_PERIOD_DIM.MARS_PERIOD=DD.SALES_PERIOD_01_FACT.BILLING_YYYYPP  )
  AND  ( DD.DISTBN_CHNL_DIM.DISTBN_CHNL_CODE=DD.SALES_PERIOD_01_FACT.SALES_DTL_DISTBN_CHNL_CODE  )
  AND  ( DD.DIVISION_DIM.DIVISION_CODE=DD.SALES_PERIOD_01_FACT.SALES_DTL_DIVISION_CODE  )
  AND  ( DD.SALES_ORG_DIM.SALES_ORG_CODE=DD.SALES_PERIOD_01_FACT.SALES_DTL_SALES_ORG_CODE  )
  AND  (
  DD.MARS_DATE_PERIOD_DIM.MARS_PERIOD  =  ANY (SELECT
  TRUNC((max(DD.SALES_FACT.BILLING_YYYYPPDD)/100))
FROM
  DD.SALES_FACT
)
  AND  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE  =  '131'
  )
GROUP BY
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE, 
  DD.DIVISION_DIM.SAP_DIVISION_CODE, 
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE
ORDER BY
  SORT_ORDER;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mfj_dbp_a_ptd to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mfj_dbp_a_ptd for dw_app.mfj_dbp_a_ptd;

