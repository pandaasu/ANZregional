/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : mfj_dbp_f_p_view
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
create or replace force view mfj_dbp_f_p_view
   (BILLING_YYYYPP, SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, 
 MFJ_BUG_DESC, MFJ_DIV_DESC, SORT_ORDER, OP_GSV, BR_GSV)
AS 
SELECT
  DD.FCST_PERIOD_02_FACT.BILLING_YYYYPP,
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE,
  DD.DIVISION_DIM.SAP_DIVISION_CODE,
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE,
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
  sum(DD.FCST_PERIOD_02_FACT.OP_GSV_VALUE) AS OP_GSV,
  sum(DD.FCST_PERIOD_02_FACT.BR_GSV_VALUE) AS BR_GSV
FROM
  DD.SALES_ORG_DIM,
  DD.DIVISION_DIM,
  DD.DISTBN_CHNL_DIM,
  DD.FCST_PERIOD_02_FACT,
  DW_APP.MAX_MIN_BILLING_DATE
WHERE
       ( DD.FCST_PERIOD_02_FACT.BILLING_YYYYPP >= DW_APP.MAX_MIN_BILLING_DATE.MIN_YYYYPP_DATE AND
         DD.FCST_PERIOD_02_FACT.BILLING_YYYYPP <= DW_APP.MAX_MIN_BILLING_DATE.MAX_YYYYPP_DATE )
  AND  ( DD.DISTBN_CHNL_DIM.DISTBN_CHNL_CODE=DD.FCST_PERIOD_02_FACT.SALES_DTL_DISTBN_CHNL_CODE )
  AND  ( DD.DIVISION_DIM.DIVISION_CODE=DD.FCST_PERIOD_02_FACT.SALES_DTL_DIVISION_CODE )
  AND  ( DD.SALES_ORG_DIM.SALES_ORG_CODE=DD.FCST_PERIOD_02_FACT.SALES_DTL_SALES_ORG_CODE )
GROUP BY
  DD.FCST_PERIOD_02_FACT.BILLING_YYYYPP,
  DD.SALES_ORG_DIM.SAP_SALES_ORG_CODE,
  DD.DIVISION_DIM.SAP_DIVISION_CODE,
  DD.DISTBN_CHNL_DIM.SAP_DISTBN_CHNL_CODE;

/*-*/
/* Authority
/*-*/
grant select on dw_app.mfj_dbp_f_p_view to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym mfj_dbp_f_p_view for dw_app.mfj_dbp_f_p_view;

