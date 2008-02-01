/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : logi_rpt_001
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
create or replace force view bo_user.logi_rpt_001
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, SAP_SOLD_TO_CUST_CODE, SOLD_TO_CUST_NAME_JA, 
 SHIP_TO_HIER_NAME_JA_L2, C_GSV, C_BPS, C_QTY, C_COUNT_DP, 
 K_GSV, K_BPS, K_QTY, K_COUNT_DP)
AS 
SELECT
T.SAP_SALES_ORG_CODE,
T.SAP_DIVISION_CODE,
T.SAP_DISTBN_CHNL_CODE,
T.SAP_SOLD_TO_CUST_CODE,
T.SOLD_TO_CUST_NAME_JA,
T.SHIP_TO_HIER_NAME_JA_L2,
SUM(T.C_GSV) AS C_GSV,
SUM(T.C_BPS) AS C_BPS,
SUM(T.C_QTY) AS C_QTY,
SUM(T.C_COUNT_DP) AS C_COUNT_DP,
SUM(T.K_GSV) AS K_GSV,
SUM(T.K_BPS) AS K_BPS,
SUM(T.K_QTY) AS K_QTY,
SUM(T.K_COUNT_DP) AS K_COUNT_DP
FROM
(
SELECT
SAP_SALES_ORG_CODE,
SAP_DIVISION_CODE,
SAP_DISTBN_CHNL_CODE,
SAP_SOLD_TO_CUST_CODE,
SOLD_TO_CUST_NAME_JA,
SHIP_TO_HIER_NAME_JA_L2,
GSV                 AS C_GSV,
BPS                 AS C_BPS,
BILLED_QTY_BASE_UOM AS C_QTY,
COUNT_DP            AS C_COUNT_DP,
0                   AS K_GSV,
0                   AS K_BPS,
0                   AS K_QTY,
0                   AS K_COUNT_DP
FROM LOGI_RPT_001_CHOKUSO
UNION ALL
SELECT
SAP_SALES_ORG_CODE,
SAP_DIVISION_CODE,
SAP_DISTBN_CHNL_CODE,
SAP_SOLD_TO_CUST_CODE,
SOLD_TO_CUST_NAME_JA,
SHIP_TO_HIER_NAME_JA_L2,
0                   AS C_GSV,
0                   AS C_BPS,
0                   AS C_QTY,
0                   AS C_COUNT_DP,
GSV                 AS K_GSV,
BPS                 AS K_BPS,
BILLED_QTY_BASE_UOM AS K_QTY,
COUNT_DP            AS K_COUNT_DP
FROM LOGI_RPT_001_KURAIRE
) T
GROUP BY
T.SAP_SALES_ORG_CODE,
T.SAP_DIVISION_CODE,
T.SAP_DISTBN_CHNL_CODE,
T.SAP_SOLD_TO_CUST_CODE,
T.SOLD_TO_CUST_NAME_JA,
T.SHIP_TO_HIER_NAME_JA_L2;
