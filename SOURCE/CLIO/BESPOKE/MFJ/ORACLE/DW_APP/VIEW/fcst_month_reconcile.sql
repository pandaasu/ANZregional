/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : fcst_month_reconcile
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Forecast Month Reconcile

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.fcst_month_reconcile
   (fcst_type_code,
    fcst_price_type_code,
    casting_yyyymm,
    sap_sales_dtl_sales_org_code,
    sap_sales_dtl_division_code, 
    sap_sales_dtl_distbn_chnl_code,
    sap_sales_div_cust_code,
    sap_sales_div_sales_org_code,
    sap_sales_div_division_code,
    sap_sales_div_distbn_chnl_code, 
    sap_material_code,
    m01_qty,
    m02_qty,
    m03_qty,
    m04_qty, 
    m05_qty,
    m06_qty,
    m07_qty,
    m08_qty,
    m09_qty, 
    m10_qty,
    m11_qty,
    m12_qty,
    m01_value,
    m02_value, 
    m03_value,
    m04_value,
    m05_value,
    m06_value,
    m07_value, 
    m08_value,
    m09_value,
    m10_value,
    m11_value,
    m12_value) as
   select fcst_type_code, 
          fcst_price_type_code, 
          casting_yyyymm, 
          sap_sales_dtl_sales_org_code, 
          sap_sales_dtl_division_code, 
          sap_sales_dtl_distbn_chnl_code, 
          sap_sales_div_cust_code, 
          sap_sales_div_sales_org_code, 
          sap_sales_div_division_code, 
          sap_sales_div_distbn_chnl_code, 
          sap_material_code, 
          sum(qm01) as m01_qty, 
          sum(qm02) as m02_qty, 
          sum(qm03) as m03_qty, 
          sum(qm04) as m04_qty, 
          sum(qm05) as m05_qty, 
          sum(qm06) as m06_qty, 
          sum(qm07) as m07_qty, 
          sum(qm08) as m08_qty, 
          sum(qm09) as m09_qty, 
          sum(qm10) as m10_qty, 
          sum(qm11) as m11_qty, 
          sum(qm12) as m12_qty, 
          sum(vm01) as m01_value, 
          sum(vm02) as m02_value, 
          sum(vm03) as m03_value, 
          sum(vm04) as m04_value, 
          sum(vm05) as m05_value, 
          sum(vm06) as m06_value, 
          sum(vm07) as m07_value, 
          sum(vm08) as m08_value, 
          sum(vm09) as m09_value, 
          sum(vm10) as m10_value, 
          sum(vm11) as m11_value, 
          sum(vm12) as m12_value 
     from (select t1.fcst_type_code, 
                  t1.fcst_price_type_code, 
                  t1.casting_yyyymm, 
                  t1.sap_sales_dtl_sales_org_code, 
                  t1.sap_sales_dtl_division_code, 
                  t1.sap_sales_dtl_distbn_chnl_code, 
                  t1.sap_sales_div_cust_code, 
                  t1.sap_sales_div_sales_org_code, 
                  t1.sap_sales_div_division_code, 
                  t1.sap_sales_div_distbn_chnl_code, 
                  t1.sap_material_code, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 1, t1.fcst_qty, 0) as qm01, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 2, t1.fcst_qty, 0) as qm02, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 3, t1.fcst_qty, 0) as qm03, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 4, t1.fcst_qty, 0) as qm04, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 5, t1.fcst_qty, 0) as qm05, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 6, t1.fcst_qty, 0) as qm06, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 7, t1.fcst_qty, 0) as qm07, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 8, t1.fcst_qty, 0) as qm08, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 9, t1.fcst_qty, 0) as qm09, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))),10, t1.fcst_qty, 0) as qm10, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))),11, t1.fcst_qty, 0) as qm11, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))),12, t1.fcst_qty, 0) as qm12, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 1, t1.fcst_value, 0) as vm01, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 2, t1.fcst_value, 0) as vm02, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 3, t1.fcst_value, 0) as vm03, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 4, t1.fcst_value, 0) as vm04, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 5, t1.fcst_value, 0) as vm05, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 6, t1.fcst_value, 0) as vm06, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 7, t1.fcst_value, 0) as vm07, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 8, t1.fcst_value, 0) as vm08, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))), 9, t1.fcst_value, 0) as vm09, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))),10, t1.fcst_value, 0) as vm10, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))),11, t1.fcst_value, 0) as vm11, 
                  decode((mod(t1.fcst_yyyymm,100)-mod(t1.casting_yyyymm,100))+(12*(trunc(t1.fcst_yyyymm/100)-trunc(t1.casting_yyyymm/100))),12, t1.fcst_value, 0) as vm12 
             from fcst_month t1) 
    group by fcst_type_code, 
             fcst_price_type_code, 
             casting_yyyymm, 
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
grant select on dw_app.fcst_month_reconcile to bo_user;
--grant select on dw_app.fcst_month_reconcile to mfj_plan;
--grant select on dw_app.fcst_month_reconcile to pp_app;

/*-*/
/* Synonym
/*-*/
create public synonym fcst_month_reconcile for dw_app.fcst_month_reconcile;
