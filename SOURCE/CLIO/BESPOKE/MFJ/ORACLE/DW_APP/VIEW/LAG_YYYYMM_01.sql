/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : lag_yyyymm_01
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
create or replace force view lag_yyyymm_01
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_BUG_DESC, MFJ_DIV_DESC, 
 SORT_ORDER, BILLING_YYYYMM, BRAND_FLAG_DESC, LY_M_GSV, CY_M_GSV, 
 GSV_PROGRESS, LY_M_BPS, CY_M_BPS, BPS_PRGRESS)
AS 
SELECT
T1.SAP_SALES_ORG_CODE,
T1.SAP_DIVISION_CODE,
T1.SAP_DISTBN_CHNL_CODE,
DECODE((T1.SAP_SALES_ORG_CODE||T1.SAP_DIVISION_CODE||T1.SAP_DISTBN_CHNL_CODE),
          '1315111', 'Petcare',
          '1315120', 'Petcare',
          '1315110', 'Food',
          '1315710', 'Food',
          '1325110', 'Drinks' ) AS MFJ_BUG_DESC,
DECODE((T1.SAP_SALES_ORG_CODE||T1.SAP_DIVISION_CODE||T1.SAP_DISTBN_CHNL_CODE),
          '1315111', 'Pet Grocery',
          '1315120', 'Pet Specialist',
          '1315110', 'Snackfood',
          '1315710', 'Food',
          '1325110', 'Drinks' ) AS MFJ_DIV_DESC,
DECODE((T1.SAP_SALES_ORG_CODE||T1.SAP_DIVISION_CODE||T1.SAP_DISTBN_CHNL_CODE),
          '1315111', 1,
          '1315120', 2,
          '1315110', 3,
          '1315710', 4,
          '1325110', 5 ) AS SORT_ORDER,
T1.BILLING_YYYYMM,
T1.BRAND_FLAG_DESC,
T1.LY_M_GSV,
T1.CY_M_GSV,
CASE WHEN T1.LY_M_GSV = 0 
      THEN 0
      ELSE ROUND((T1.CY_M_GSV*100/T1.LY_M_GSV),2) 
END "GSV_PROGRESS",
T1.LY_M_BPS,
T1.CY_M_BPS,
CASE WHEN T1.LY_M_BPS = 0
      THEN 0
      ELSE ROUND((T1.CY_M_BPS*100/T1.LY_M_BPS),2)
END "BPS_PRGRESS"
FROM
(
SELECT 
C.SAP_SALES_ORG_CODE,
D.SAP_DIVISION_CODE,
E.SAP_DISTBN_CHNL_CODE,
A.BILLING_YYYYMM,
B.BRAND_FLAG_DESC,
 LAG(SUM(A.SALES_DTL_PRICE_VALUE_13), 12, 0) 
    OVER(PARTITION BY B.BRAND_FLAG_DESC ORDER BY A.BILLING_YYYYMM) AS LY_M_GSV,
SUM(A.SALES_DTL_PRICE_VALUE_13)                                    AS CY_M_GSV,
 LAG(SUM(A.SALES_DTL_PRICE_VALUE_2),  12, 0)
    OVER(PARTITION BY B.BRAND_FLAG_DESC ORDER BY A.BILLING_YYYYMM) AS LY_M_BPS,
SUM(A.SALES_DTL_PRICE_VALUE_2)                                     AS CY_M_BPS
FROM 
DD.SALES_MONTH_01_FACT A,
DD.MATERIAL_DIM B,
DD.SALES_ORG_DIM C,
DD.DIVISION_DIM D,
DD.DISTBN_CHNL_DIM E
WHERE
A.SALES_HDR_SALES_ORG_CODE   = C.SALES_ORG_CODE AND
A.SALES_HDR_DIVISION_CODE    = D.DIVISION_CODE  AND
A.SALES_HDR_DISTBN_CHNL_CODE = E.DISTBN_CHNL_CODE AND
C.SAP_SALES_ORG_CODE IN ('131','132') AND
E.SAP_DISTBN_CHNL_CODE != '99' AND
D.SAP_DIVISION_CODE != '03' AND
TRUNC(A.BILLING_YYYYMM/100) >= TO_NUMBER(TO_CHAR(sysdate-1,'YYYY'))-1 AND
A.MATERIAL_CODE = B.MATERIAL_CODE
GROUP BY
C.SAP_SALES_ORG_CODE,
D.SAP_DIVISION_CODE,
E.SAP_DISTBN_CHNL_CODE,
A.BILLING_YYYYMM,
B.BRAND_FLAG_DESC
ORDER BY
C.SAP_SALES_ORG_CODE,
D.SAP_DIVISION_CODE,
E.SAP_DISTBN_CHNL_CODE,
A.BILLING_YYYYMM,
B.BRAND_FLAG_DESC
) T1
WHERE
TRUNC(T1.BILLING_YYYYMM/100) = TO_NUMBER(TO_CHAR(sysdate-1,'YYYY'));

/*-*/
/* Authority
/*-*/
grant select on dw_app.lag_yyyymm_01 to bo_user;

/*-*/
/* Synonym
/*-*/
create or replace public synonym lag_yyyymm_01 for dw_app.lag_yyyymm_01;
