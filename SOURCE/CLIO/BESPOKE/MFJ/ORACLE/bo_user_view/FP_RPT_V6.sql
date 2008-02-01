/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_v6
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
create or replace force view bo_user.fp_rpt_v6
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, R_YTD_GSV, R_YTD_BPS, R_YTD_NIV, 
 R_PTD_GSV, R_PTD_BPS, R_PTD_NIV, I_PTD_GSV, I_PTD_BPS, 
 I_PTD_NIV)
AS 
SELECT 
T.SAP_SALES_ORG_CODE,
T.SAP_DIVISION_CODE,
T.SAP_DISTBN_CHNL_CODE,
T.MFJ_DIV_CODE,
T.MFJ_BUG_DESC,
T.MFJ_DIV_DESC,
T.SORT_ORDER,
SUM(T.R_YTD_GSV) AS R_YTD_GSV,
SUM(T.R_YTD_BPS) AS R_YTD_BPS,
SUM(T.R_YTD_NIV) AS R_YTD_NIV,
SUM(T.R_PTD_GSV) AS R_PTD_GSV,
SUM(T.R_PTD_BPS) AS R_PTD_BPS,
SUM(T.R_PTD_NIV) AS R_PTD_NIV,
SUM(T.I_PTD_GSV) AS I_PTD_GSV,
SUM(T.I_PTD_BPS) AS I_PTD_BPS,
SUM(T.I_PTD_NIV) AS I_PTD_NIV
FROM
(
(SELECT
   SAP_SALES_ORG_CODE,
   SAP_DIVISION_CODE,
   SAP_DISTBN_CHNL_CODE,
   MFJ_DIV_CODE,
   MFJ_BUG_DESC,
   MFJ_DIV_DESC,
   SORT_ORDER,
   GSV AS R_YTD_GSV,
   BPS AS R_YTD_BPS,
   NIV AS R_YTD_NIV,
   0   AS R_PTD_GSV,
   0   AS R_PTD_BPS,
   0   AS R_PTD_NIV,
   0   AS I_PTD_GSV,
   0   AS I_PTD_BPS,
   0   AS I_PTD_NIV
   FROM FP_RPT_YTD_ALL)
UNION ALL
(SELECT
   SAP_SALES_ORG_CODE,
   SAP_DIVISION_CODE,
   SAP_DISTBN_CHNL_CODE,
   MFJ_DIV_CODE,
   MFJ_BUG_DESC,
   MFJ_DIV_DESC,
   SORT_ORDER,
   0   AS R_YTD_GSV,
   0   AS R_YTD_BPS,
   0   AS R_YTD_NIV,
   GSV AS R_PTD_GSV,
   BPS AS R_PTD_BPS,
   NIV AS R_PTD_NIV,
   0   AS I_PTD_GSV,
   0   AS I_PTD_BPS,
   0   AS I_PTD_NIV
   FROM FP_RPT_PTD_ALL)
UNION ALL
(SELECT
   SAP_SALES_ORG_CODE,
   SAP_DIVISION_CODE,
   SAP_DISTBN_CHNL_CODE,
   MFJ_DIV_CODE,
   MFJ_BUG_DESC,
   MFJ_DIV_DESC,
   SORT_ORDER,
   0   AS R_YTD_GSV,
   0   AS R_YTD_BPS,
   0   AS R_YTD_NIV,
   0   AS R_PTD_GSV,
   0   AS R_PTD_BPS,
   0   AS R_PTD_NIV,
   GSV AS I_PTD_GSV,
   BPS AS I_PTD_BPS,
   NIV AS I_PTD_NIV
   FROM FP_RPT_ORD_IPT_PTD_ALL)
) T
GROUP BY
T.SAP_SALES_ORG_CODE,
T.SAP_DIVISION_CODE,
T.SAP_DISTBN_CHNL_CODE,
T.MFJ_DIV_CODE,
T.MFJ_BUG_DESC,
T.MFJ_DIV_DESC,
T.SORT_ORDER
ORDER BY
T.SORT_ORDER;
