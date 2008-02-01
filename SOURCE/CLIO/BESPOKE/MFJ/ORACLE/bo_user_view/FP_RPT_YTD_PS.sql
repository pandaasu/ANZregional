/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_ytd_ps
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
create or replace force view bo_user.fp_rpt_ytd_ps
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT
  '131' AS SAP_SALES_ORG_CODE,
   '51' AS SAP_DIVISION_CODE,
   '20' AS SAP_DISTBN_CHNL_CODE,
  '1315120'                   AS MFJ_DIV_CODE,
  'Petcare'                   AS MFJ_BUG_DESC,
  'Pet Specialist'            AS MFJ_DIV_DESC,
  3 AS SORT_ORDER,
  SUM(T1.SALES_DTL_PRICE_VALUE_13) AS GSV,
  SUM(T1.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  SUM(T1.SALES_DTL_PRICE_VALUE_11) AS NIV
     from (select *
             from sales_fact t11,
                  (select t121.rowid from sales_fact t121
                    where t121.sap_company_code = '131'
                      and (t121.sap_billing_date >= (select min_reqd_dlvry_date from max_min_reqd_dlvry_date) and
                           t121.sap_billing_date <= (select max_reqd_dlvry_date from max_min_reqd_dlvry_date))) t12
              where t11.rowid = t12.rowid) t1,
          material_dim t2
    where t1.sap_sales_dtl_sales_org_code = '131'
      and t1.sap_sales_dtl_division_code = '51'
      and t1.sap_sales_dtl_distbn_chnl_code = '20'
      and t1.sap_material_code = t2.sap_material_code
      and t2.sap_brand_sub_flag_code != '459'
    group by t1.sap_sales_dtl_sales_org_code,
             t1.sap_sales_dtl_division_code,
             t1.sap_sales_dtl_distbn_chnl_code;