/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : logi_rpt_001_kuraire
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
create or replace force view bo_user.logi_rpt_001_kuraire
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, SAP_SOLD_TO_CUST_CODE, SOLD_TO_CUST_NAME_JA, 
 SHIP_TO_HIER_NAME_JA_L2, GSV, BPS, BILLED_QTY_BASE_UOM, COUNT_DP)
AS 
SELECT
SAP_SALES_ORG_CODE,
SAP_DIVISION_CODE,
SAP_DISTBN_CHNL_CODE,
SAP_SOLD_TO_CUST_CODE,
SOLD_TO_CUST_NAME_JA,
--BILLING_YYYYMM,
SHIP_TO_HIER_NAME_JA_L2,
SUM(GSV)                          AS GSV,
SUM(BPS)                          AS BPS,
SUM(BILLED_QTY_BASE_UOM)          AS BILLED_QTY_BASE_UOM,
COUNT(DISTINCT SAP_SHIP_TO_CUST_CODE) AS COUNT_DP
FROM LOGI_RPT_PRE_001_KURAIRE
GROUP BY
SAP_SALES_ORG_CODE,
SAP_DIVISION_CODE,
SAP_DISTBN_CHNL_CODE,
SAP_SOLD_TO_CUST_CODE,
SOLD_TO_CUST_NAME_JA,
--BILLING_YYYYMM,
SHIP_TO_HIER_NAME_JA_L2;