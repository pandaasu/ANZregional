/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mfj_dbp2_a_acc
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
create or replace force view mfj_dbp2_a_acc
   (SAP_SALES_ORG_CODE,
    SAP_DIVISION_CODE,
    SAP_DISTBN_CHNL_CODE,
    MFJ_DIV_CODE,
    MFJ_BUG_DESC, 
    MFJ_DIV_DESC,
    SORT_ORDER,
    GSV,
    BPS,
    NIV) AS 
   SELECT T1.SAP_SALES_ORG_CODE,
          T1.SAP_DIVISION_CODE,
          T1.SAP_DISTBN_CHNL_CODE,
          T1.MFJ_DIV_CODE,
          T1.MFJ_BUG_DESC,
          T1.MFJ_DIV_DESC,
          T1.SORT_ORDER,
          CASE
            WHEN T1.GSV <  1000000 THEN ROUND(T1.GSV/1000000,1)
            WHEN T1.GSV >= 1000000 THEN ROUND(T1.GSV/1000000)
            ELSE NULL
          END "GSV",
CASE
   WHEN T1.BPS <  1000000 THEN ROUND(T1.BPS/1000000,1)
   WHEN T1.BPS >= 1000000 THEN ROUND(T1.BPS/1000000)
   ELSE NULL
END "BPS",
CASE
   WHEN T1.NIV <  1000000 THEN ROUND(T1.NIV/1000000,1)
   WHEN T1.NIV >= 1000000 THEN ROUND(T1.NIV/1000000)
   ELSE NULL
END "NIV"
FROM
(
SELECT
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE     AS SAP_SALES_ORG_CODE,
  DD.DIVISION_DIM.SAP_DIVISION_CODE       AS SAP_DIVISION_CODE,
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE AS SAP_DISTBN_CHNL_CODE,
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
  SUM(DD.SALES_FACT.SALES_DTL_PRICE_VALUE_13) AS GSV,
  SUM(DD.SALES_FACT.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  SUM(DD.SALES_FACT.SALES_DTL_PRICE_VALUE_11) AS NIV
FROM
  DD.SALES_ORG_DIM,
  DD.DIVISION_DIM,
  DD.DISTBN_CHNL_DIM,
  DD.SALES_FACT,
  DW_APP.MAX_MIN_REQD_DLVRY_DATE
WHERE
  ( DD.SALES_FACT.SAP_BILLING_DATE >= 
    (SELECT MIN(CALENDAR_DATE) FROM MM.MARS_DATE WHERE MARS_PERIOD IN 
      (SELECT MARS_PERIOD FROM DW_APP.MAX_MIN_REQD_DLVRY_DATE)) 
   AND
    DD.SALES_FACT.SAP_BILLING_DATE <= DW_APP.MAX_MIN_REQD_DLVRY_DATE.MAX_REQD_DLVRY_DATE )
  AND  ( DD.SALES_FACT.SALES_DTL_DISTBN_CHNL_CODE=DD.DISTBN_CHNL_DIM.DISTBN_CHNL_CODE  )
  AND  ( DD.SALES_FACT.SALES_DTL_DIVISION_CODE=DD.DIVISION_DIM.DIVISION_CODE  )
  AND  ( DD.SALES_FACT.SALES_DTL_SALES_ORG_CODE=DD.SALES_ORG_DIM.SALES_ORG_CODE  )
  AND  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE  =  '131'
GROUP BY
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE,
  DD.DIVISION_DIM.SAP_DIVISION_CODE,
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE
ORDER BY
  SORT_ORDER
) T1;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mfj_dbp2_a_acc to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mfj_dbp2_a_acc for dw_app.mfj_dbp2_a_acc;

