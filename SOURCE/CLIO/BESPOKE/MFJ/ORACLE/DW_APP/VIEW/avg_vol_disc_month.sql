/******************************************************************************/
/* View Definition                                                            */
/******************************************************************************/
/**
 Object : avg_vol_disc_month
 Owner  : dw_app

 DESCRIPTION
 -----------
 Data Warehouse - Average Volumn Discount Month View

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2005/11   Steve Gregan   Modified to use SAP_BILLING_YYYYMM

*******************************************************************************/

/*-*/
/* View creation
/*-*/
create or replace force view dw_app.avg_vol_disc_month
   (sap_material_code,
    billing_yyyymm,
    sap_sales_dtl_sales_org_code,
    sap_sales_dtl_distbn_chnl_code,
    avg_vol_disc) as
   select sap_material_code, 
          sap_billing_yyyymm, 
          sap_sales_dtl_sales_org_code, 
          sap_sales_dtl_distbn_chnl_code, 
          case when sum(sales_dtl_price_value_12) = 0 then 0 
               when sum(sales_dtl_price_value_13) = 0 then 0 
               when sum(sales_dtl_price_value_12) <> 0 and sum(sales_dtl_price_value_13) <> 0 then round(sum(sales_dtl_price_value_12)/sum(sales_dtl_price_value_13),2)*-1 
	       else 0 end avg_vol_disc -- vishal marken 3/12/2003 
     from sales_month_04_fact 
    where sales_dtl_price_value_12 <> 0 
      and sap_billing_yyyymm =  to_char(add_months(sysdate,-1),'yyyymm') 
    group by sap_material_code, 
             sap_billing_yyyymm, 
             sap_sales_dtl_sales_org_code, 
             sap_sales_dtl_distbn_chnl_code;

/*-*/
/* Authority
/*-*/
grant select on dw_app.avg_vol_disc_month to mfj_plan;

/*-*/
/* Synonym
/*-*/
create or replace public synonym avg_vol_disc_month for dw_app.avg_vol_disc_month;