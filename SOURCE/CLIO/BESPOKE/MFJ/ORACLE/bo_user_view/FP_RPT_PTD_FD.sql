/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fp_rpt_ptd_fd
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
create or replace force view bo_user.fp_rpt_ptd_fd
   (SAP_SALES_ORG_CODE, SAP_DIVISION_CODE, SAP_DISTBN_CHNL_CODE, MFJ_DIV_CODE, MFJ_BUG_DESC, 
 MFJ_DIV_DESC, SORT_ORDER, GSV, BPS, NIV)
AS 
SELECT
  t1.sap_sales_dtl_sales_org_code      AS SAP_SALES_ORG_CODE,
  t1.sap_sales_dtl_division_code       AS SAP_DIVISION_CODE,
  t1.sap_sales_dtl_distbn_chnl_code    AS SAP_DISTBN_CHNL_CODE,
  (t1.sap_sales_dtl_sales_org_code||t1.sap_sales_dtl_division_code||t1.sap_sales_dtl_distbn_chnl_code) AS MFJ_DIV_CODE,
  DECODE((t1.sap_sales_dtl_sales_org_code||t1.sap_sales_dtl_division_code||t1.sap_sales_dtl_distbn_chnl_code),
          '1315111', 'Petcare',
          '1315120', 'Petcare',
          '1315110', 'Food',
          '1315710', 'Food' ) AS MFJ_BUG_DESC,
  DECODE((t1.sap_sales_dtl_sales_org_code||t1.sap_sales_dtl_division_code||t1.sap_sales_dtl_distbn_chnl_code),
          '1315111', 'Pet Grocery',
          '1315120', 'Pet Specialist',
          '1315110', 'Snackfood',
          '1315710', 'Food' ) AS MFJ_DIV_DESC,
  DECODE((t1.sap_sales_dtl_sales_org_code||t1.sap_sales_dtl_division_code||t1.sap_sales_dtl_distbn_chnl_code),
          '1315111', 1,
          '1315120', 3,
          '1315110', 4,
          '1315710', 5 ) AS SORT_ORDER,
  SUM(T1.SALES_DTL_PRICE_VALUE_13) AS GSV,
  SUM(T1.SALES_DTL_PRICE_VALUE_2)  AS BPS,
  SUM(T1.SALES_DTL_PRICE_VALUE_11) AS NIV
     from (select *
             from sales_fact t11,
                  (select t121.rowid from sales_fact t121
                    where t121.sap_company_code = '131'
                      and (t121.sap_billing_date >= (select min(calendar_date) from mars_date where mars_period in (select mars_period from max_min_reqd_dlvry_date)) and
                           t121.sap_billing_date <= (select max_reqd_dlvry_date from max_min_reqd_dlvry_date))) t12
              where t11.rowid = t12.rowid) t1
    where t1.sap_sales_dtl_sales_org_code = '131'
      and t1.sap_sales_dtl_division_code in ('51','57')
      and t1.sap_sales_dtl_distbn_chnl_code = '10'
    group by t1.sap_sales_dtl_sales_org_code,
             t1.sap_sales_dtl_division_code,
             t1.sap_sales_dtl_distbn_chnl_code;

