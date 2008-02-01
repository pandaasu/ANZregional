/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_ytd_pg2
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
create or replace force view bo_user.fp_rpt_ytd_pg2
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT
TT1.SAP_SALES_ORG_CODE,
TT1.SAP_DIVISION_CODE,
TT1.SAP_DISTBN_CHNL_CODE,
TT1.MFJ_DIV_CODE,
TT1.MFJ_BUG_DESC,
TT1.MFJ_DIV_DESC,
TT1.SORT_ORDER,
SUM(TT1.GSV) AS GSV,
SUM(TT1.BPS) AS BPS,
SUM(TT1.NIV) AS NIV
FROM
(
   select '131' as sap_sales_org_code,
          '51' as sap_division_code,
          '11' as sap_distbn_chnl_code,
          '1315111' as mfj_div_code,
          'Petcare' as mfj_bug_desc,
          'Pedigree Club Professional Model' as mfj_div_desc,
          2 as sort_order,
          sum(t1.sales_dtl_price_value_13) as gsv,
          sum(t1.sales_dtl_price_value_2)  as bps,
          sum(t1.sales_dtl_price_value_11) as niv
     from (select *
             from sales_fact t11,
                  (select t121.rowid from sales_fact t121
                    where t121.sap_company_code = '131'
                      and (t121.sap_billing_date >= (select min_reqd_dlvry_date from max_min_reqd_dlvry_date) and
                           t121.sap_billing_date <= (select max_reqd_dlvry_date from max_min_reqd_dlvry_date))) t12
              where t11.rowid = t12.rowid) t1,
          material_dim t2
    where t1.sap_sales_dtl_sales_org_code = '131'
      and t1.sap_material_code = t2.sap_material_code
      and t2.sap_brand_sub_flag_code = '459'
    group by t1.sap_sales_dtl_sales_org_code,
             t1.sap_sales_dtl_division_code,
             t1.sap_sales_dtl_distbn_chnl_code
UNION ALL
SELECT
  '131' AS SAP_SALES_ORG_CODE,
   '51' AS SAP_DIVISION_CODE,
   '11' AS SAP_DISTBN_CHNL_CODE,
  '1315111'                   AS MFJ_DIV_CODE,
  'Petcare'                   AS MFJ_BUG_DESC,
  'Pedigree Club Professional Model'      AS MFJ_DIV_DESC,
  2 AS SORT_ORDER,
  0 AS GSV,
  0 AS BPS,
  0 AS NIV
FROM
SALES_ORG_DIM              --- Dummy Table
WHERE
SAP_SALES_ORG_CODE = '131' --- Dummy Condition
) TT1
GROUP BY
TT1.SAP_SALES_ORG_CODE,
TT1.SAP_DIVISION_CODE,
TT1.SAP_DISTBN_CHNL_CODE,
TT1.MFJ_DIV_CODE,
TT1.MFJ_BUG_DESC,
TT1.MFJ_DIV_DESC,
TT1.SORT_ORDER;
