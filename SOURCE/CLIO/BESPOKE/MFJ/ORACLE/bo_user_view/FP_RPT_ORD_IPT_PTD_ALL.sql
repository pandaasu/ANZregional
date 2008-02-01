/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_ord_ipt_ptd_all
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
create or replace force view bo_user.fp_rpt_ord_ipt_ptd_all
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT 
TTT1.SAP_SALES_ORG_CODE,
TTT1.SAP_DIVISION_CODE,
TTT1.SAP_DISTBN_CHNL_CODE,
TTT1.MFJ_DIV_CODE,
TTT1.MFJ_BUG_DESC,
TTT1.MFJ_DIV_DESC,
TTT1.SORT_ORDER,
CASE
   WHEN TTT1.GSV <  1000000 THEN ROUND(TTT1.GSV/1000000,1)
   WHEN TTT1.GSV >= 1000000 THEN ROUND(TTT1.GSV/1000000)
   ELSE NULL
END "GSV",
CASE
   WHEN TTT1.BPS <  1000000 THEN ROUND(TTT1.BPS/1000000,1)
   WHEN TTT1.BPS >= 1000000 THEN ROUND(TTT1.BPS/1000000)
   ELSE NULL
END "BPS",
CASE
   WHEN TTT1.NIV <  1000000 THEN ROUND(TTT1.NIV/1000000,1)
   WHEN TTT1.NIV >= 1000000 THEN ROUND(TTT1.NIV/1000000)
   ELSE NULL
END "NIV"
FROM
(
  SELECT * FROM FP_RPT_ORD_IPT_PTD_FD
  UNION ALL
  SELECT * FROM
  (
    SELECT * FROM FP_RPT_ORD_IPT_PTD_PS
    UNION ALL
    SELECT * FROM 
    (
      SELECT * FROM FP_RPT_ORD_IPT_PTD_PG2
      UNION ALL
      SELECT * FROM FP_RPT_ORD_IPT_PTD_PG1
    ) T1
  ) TT1
) TTT1
ORDER BY
SORT_ORDER;

