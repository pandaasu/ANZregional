/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fcst_period_reconcile
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Forecast Period Reconcile

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.fcst_period_reconcile
   (fcst_type_code,
    fcst_price_type_code,
    casting_yyyypp,
    sap_sales_dtl_sales_org_code,
    sap_sales_dtl_division_code, 
    sap_sales_dtl_distbn_chnl_code,
    sap_sales_div_cust_code,
    sap_sales_div_sales_org_code,
    sap_sales_div_division_code,
    sap_sales_div_distbn_chnl_code, 
    sap_material_code,
    p01_qty,
    p02_qty,
    p03_qty,
    p04_qty, 
    p05_qty,
    p06_qty,
    p07_qty,
    p08_qty,
    p09_qty, 
    p10_qty,
    p11_qty,
    p12_qty,
    p13_qty,
    p01_value, 
    p02_value,
    p03_value,
    p04_value,
    p05_value,
    p06_value, 
    p07_value,
    p08_value,
    p09_value,
    p10_value,
    p11_value, 
    p12_value,
    p13_value) as
   select fcst_type_code, 
          fcst_price_type_code, 
          casting_yyyypp, 
          sap_sales_dtl_sales_org_code, 
          sap_sales_dtl_division_code, 
          sap_sales_dtl_distbn_chnl_code, 
          sap_sales_div_cust_code, 
          sap_sales_div_sales_org_code, 
          sap_sales_div_division_code, 
          sap_sales_div_distbn_chnl_code, 
          sap_material_code, 
          sum(qp01) as p01_qty, 
          sum(qp02) as p02_qty, 
          sum(qp03) as p03_qty, 
          sum(qp04) as p04_qty, 
          sum(qp05) as p05_qty, 
          sum(qp06) as p06_qty, 
          sum(qp07) as p07_qty, 
          sum(qp08) as p08_qty, 
          sum(qp09) as p09_qty, 
          sum(qp10) as p10_qty, 
          sum(qp11) as p11_qty, 
          sum(qp12) as p12_qty, 
          sum(qp13) as p13_qty, 
          sum(vp01) as p01_value, 
          sum(vp02) as p02_value, 
          sum(vp03) as p03_value, 
          sum(vp04) as p04_value, 
          sum(vp05) as p05_value, 
          sum(vp06) as p06_value, 
          sum(vp07) as p07_value, 
          sum(vp08) as p08_value, 
          sum(vp09) as p09_value, 
          sum(vp10) as p10_value, 
          sum(vp11) as p11_value, 
          sum(vp12) as p12_value, 
          sum(vp13) as p13_value 
     from (select t1.fcst_type_code, 
                  t1.fcst_price_type_code, 
                  t1.casting_yyyypp, 
                  t1.sap_sales_dtl_sales_org_code, 
                  t1.sap_sales_dtl_division_code, 
                  t1.sap_sales_dtl_distbn_chnl_code, 
                  t1.sap_sales_div_cust_code, 
                  t1.sap_sales_div_sales_org_code, 
                  t1.sap_sales_div_division_code, 
                  t1.sap_sales_div_distbn_chnl_code, 
                  t1.sap_material_code, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 1, t1.fcst_qty, 0) as qp01, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 2, t1.fcst_qty, 0) as qp02, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 3, t1.fcst_qty, 0) as qp03, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 4, t1.fcst_qty, 0) as qp04, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 5, t1.fcst_qty, 0) as qp05, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 6, t1.fcst_qty, 0) as qp06, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 7, t1.fcst_qty, 0) as qp07, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 8, t1.fcst_qty, 0) as qp08, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 9, t1.fcst_qty, 0) as qp09, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),10, t1.fcst_qty, 0) as qp10, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),11, t1.fcst_qty, 0) as qp11, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),12, t1.fcst_qty, 0) as qp12, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),13, t1.fcst_qty, 0) as qp13, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 1, t1.fcst_value, 0) as vp01, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 2, t1.fcst_value, 0) as vp02, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 3, t1.fcst_value, 0) as vp03, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 4, t1.fcst_value, 0) as vp04, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 5, t1.fcst_value, 0) as vp05, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 6, t1.fcst_value, 0) as vp06, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 7, t1.fcst_value, 0) as vp07, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 8, t1.fcst_value, 0) as vp08, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))), 9, t1.fcst_value, 0) as vp09, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),10, t1.fcst_value, 0) as vp10, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),11, t1.fcst_value, 0) as vp11, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),12, t1.fcst_value, 0) as vp12, 
                  decode((mod(t1.fcst_yyyypp,100)-mod(t1.casting_yyyypp,100))+(13*(trunc(t1.fcst_yyyypp/100)-trunc(t1.casting_yyyypp/100))),13, t1.fcst_value, 0) as vp13, 
                  t1.fcst_qty, 
                  t1.fcst_value 
             from fcst_period t1) 
    group by fcst_type_code, 
             fcst_price_type_code, 
             casting_yyyypp, 
             sap_sales_dtl_sales_org_code, 
             sap_sales_dtl_division_code, 
             sap_sales_dtl_distbn_chnl_code, 
             sap_sales_div_cust_code, 
             sap_sales_div_sales_org_code, 
             sap_sales_div_division_code, 
             sap_sales_div_distbn_chnl_code, 
             sap_material_code;

/*-*/
/* Authority
/*-*/
grant select on dw_app.fcst_period_reconcile to bo_user;
--grant select on dw_app.fcst_period_reconcile to mfj_plan;
--grant select on dw_app.fcst_period_reconcile to pp_app;

/*-*/
/* Synonym
/*-*/
create public synonym fcst_period_reconcile for dw_app.fcst_period_reconcile;


