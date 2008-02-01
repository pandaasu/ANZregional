/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Package : hk_sal_cus_prd_13_extract                          */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : March 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_cus_prd_13_extract as

/**DESCRIPTION**
 Customer PLY period billing date extract.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/03   Steve Gregan   Created
 2006/06   Steve Gregan   Included sales order and invoice type exclusions.
 2007/04   Steve Gregan   Included company parameter.

**/

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_sap_company_code in varchar2) return varchar2;

end hk_sal_cus_prd_13_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_cus_prd_13_extract as

   /*-*/
   /* Private global declarations
   /*-*/
   procedure exe_control_data(par_sap_company_code in varchar2);
   procedure exe_sales_data(par_sap_company_code in varchar2);
   procedure exe_forecast_data(par_sap_company_code in varchar2);
   procedure createPeriodHeader(par_sap_company_code in varchar2,
                                par_sap_ship_to_cust_code in varchar2,
                                par_sap_sales_org_code in varchar2,
                                par_sap_distbn_chnl_code in varchar2,
                                par_sap_division_code in varchar2,
                                par_sap_material_code in varchar2);
   procedure createPeriodDetail(par_sap_company_code in varchar2,
                                par_sap_ship_to_cust_code in varchar2,
                                par_sap_sales_org_code in varchar2,
                                par_sap_distbn_chnl_code in varchar2,
                                par_sap_division_code in varchar2,
                                par_sap_material_code in varchar2,
                                par_dta_type in varchar2);

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2) return varchar2 is

      /*-*/
      /* Exception definitions
      /*-*/
      ApplicationError exception;
      pragma exception_init(ApplicationError, -20000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Truncate the data mart tables
      /**/
      delete from pld_sal_cus_prd_1300 where sap_company_code = par_sap_company_code;
      delete from pld_sal_cus_prd_1301 where sap_company_code = par_sap_company_code;
      delete from pld_sal_cus_prd_1302 where sap_company_code = par_sap_company_code;
      commit;

      /**/
      /* Extract the control data
      /**/
      exe_control_data(par_sap_company_code);
      commit;

      /**/
      /* Extract the sales data
      /**/
      exe_sales_data(par_sap_company_code);
      commit;

      /**/
      /* Extract the forecast data
      /**/
      exe_forecast_data(par_sap_company_code);
      commit;

      /*-*/
      /*- Return the status
      /**/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Application error
      /*-*/
      when ApplicationError then
         return substr(SQLERRM, 1, 512);

      /*-*/
      /* Error trap
      /*-*/
      when others then
         return substr(SQLERRM, 1, 512);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /****************************************************/
   /* This procedure performs the control data routine */
   /****************************************************/
   procedure exe_control_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_work_date date;
      var_current_yyyypp number(6,0);
      var_prd_asofdays varchar2(128 char);
      var_prd_percent number(5,2);
      var_current_yyyymm number(6,0);
      var_mth_asofdays varchar2(128 char);
      var_mth_percent number(5,2);
      var_extract_status varchar2(256 char);
      var_inventory_date date;
      var_inventory_status varchar2(256 char);
      var_sales_date date;
      var_sales_status varchar2(256 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the control information
      /* **NOTE** based on current day
      /*-*/
      mfjpln_control.main(par_sap_company_code,
                          '*BIL',
                          sysdate,
                          false,
                          var_work_date,
                          var_current_yyyypp,
                          var_prd_asofdays,
                          var_prd_percent,
                          var_current_yyyymm,
                          var_mth_asofdays,
                          var_mth_percent,
                          var_extract_status,
                          var_inventory_date,
                          var_inventory_status,
                          var_sales_date,
                          var_sales_status);

      /*-*/
      /* Insert the control extract data
      /*-*/
      insert into pld_sal_cus_prd_1300
         (sap_company_code,
          extract_date,
          logical_date,
          current_yyyypp,
          extract_status,
          sales_date,
          sales_status,
          prd_asofdays,
          prd_percent)
         values(par_sap_company_code,
                sysdate,
                var_work_date,
                var_current_yyyypp,
                var_extract_status,
                var_sales_date,
                var_sales_status,
                var_prd_asofdays,
                var_prd_percent);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_control_data;

   /**************************************************/
   /* This procedure performs the sales data routine */
   /**************************************************/
   procedure exe_sales_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_current_yyyypp number(6,0);
      var_start_yyyypp number(6,0);
      var_end_yyyypp number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor sales_period_03_fact_c01 is 
         select t01.sap_company_code,
                t01.sap_ship_to_cust_code,
                t01.sap_sales_dtl_sales_org_code,
                t01.sap_sales_dtl_distbn_chnl_code,
                t01.sap_sales_dtl_division_code,
                t01.sap_material_code,
                t01.sap_billing_yyyypp,
                sum(nvl(t01.base_uom_billed_qty, 0)) as billed_qty,
                sum(nvl(t01.tonnes_billed_qty, 0)) as billed_ton,
                sum(nvl(t01.sales_dtl_price_value_13, 0)) as billed_gsv,
                sum(nvl(t01.sales_dtl_price_value_17, 0)) as billed_niv
         from sales_period_03_fact t01
         where t01.sap_company_code = par_sap_company_code
           and t01.sap_billing_yyyypp >= var_start_yyyypp
           and t01.sap_billing_yyyypp <= var_end_yyyypp
           and (nvl(t01.base_uom_billed_qty, 0) <> 0 or
                nvl(t01.sales_dtl_price_value_13, 0) <> 0 or
                nvl(t01.sales_dtl_price_value_17, 0) <> 0)
           and nvl(t01.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(t01.sap_order_type_code,'*NULL')||'/'||nvl(t01.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
           and t01.sap_invc_type_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','INVOICE_TYPE_EXCLUSION')))
         group by t01.sap_company_code,
                  t01.sap_ship_to_cust_code,
                  t01.sap_sales_dtl_sales_org_code,
                  t01.sap_sales_dtl_distbn_chnl_code,
                  t01.sap_sales_dtl_division_code,
                  t01.sap_material_code,
                  t01.sap_billing_yyyypp;
      sales_period_03_fact_r01 sales_period_03_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current date and period variables
      /*-*/
      select current_yyyypp into var_current_yyyypp from pld_sal_cus_prd_1300 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the period sales values - previous year
      /*-*/
      var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp-100, false);
      var_end_yyyypp := mfjpln_control.previousPeriodEnd(var_current_yyyypp-100, false);
      open sales_period_03_fact_c01;
      loop
         fetch sales_period_03_fact_c01 into sales_period_03_fact_r01;
         if sales_period_03_fact_c01%notfound then
            exit;
         end if;

         createPeriodHeader(sales_period_03_fact_r01.sap_company_code,
                            sales_period_03_fact_r01.sap_ship_to_cust_code,
                            sales_period_03_fact_r01.sap_sales_dtl_sales_org_code,
                            sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code,
                            sales_period_03_fact_r01.sap_sales_dtl_division_code,
                            sales_period_03_fact_r01.sap_material_code);

         update pld_sal_cus_prd_1301
            set tot_ty_qty = tot_ty_qty + sales_period_03_fact_r01.billed_qty,
                tot_ty_ton = tot_ty_ton + sales_period_03_fact_r01.billed_ton,
                tot_ty_gsv = tot_ty_gsv + sales_period_03_fact_r01.billed_gsv,
                tot_ty_niv = tot_ty_niv + sales_period_03_fact_r01.billed_niv
            where sap_company_code = sales_period_03_fact_r01.sap_company_code
              and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
              and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
              and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
              and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
              and sap_material_code = sales_period_03_fact_r01.sap_material_code;

         if substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '01' then
            update pld_sal_cus_prd_1302
               set p01_qty = sales_period_03_fact_r01.billed_qty,
                   p01_ton = sales_period_03_fact_r01.billed_ton,
                   p01_gsv = sales_period_03_fact_r01.billed_gsv,
                   p01_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '02' then
            update pld_sal_cus_prd_1302
               set p02_qty = sales_period_03_fact_r01.billed_qty,
                   p02_ton = sales_period_03_fact_r01.billed_ton,
                   p02_gsv = sales_period_03_fact_r01.billed_gsv,
                   p02_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '03' then
            update pld_sal_cus_prd_1302
               set p03_qty = sales_period_03_fact_r01.billed_qty,
                   p03_ton = sales_period_03_fact_r01.billed_ton,
                   p03_gsv = sales_period_03_fact_r01.billed_gsv,
                   p03_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '04' then
            update pld_sal_cus_prd_1302
               set p04_qty = sales_period_03_fact_r01.billed_qty,
                   p04_ton = sales_period_03_fact_r01.billed_ton,
                   p04_gsv = sales_period_03_fact_r01.billed_gsv,
                   p04_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '05' then
            update pld_sal_cus_prd_1302
               set p05_qty = sales_period_03_fact_r01.billed_qty,
                   p05_ton = sales_period_03_fact_r01.billed_ton,
                   p05_gsv = sales_period_03_fact_r01.billed_gsv,
                   p05_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '06' then
            update pld_sal_cus_prd_1302
               set p06_qty = sales_period_03_fact_r01.billed_qty,
                   p06_ton = sales_period_03_fact_r01.billed_ton,
                   p06_gsv = sales_period_03_fact_r01.billed_gsv,
                   p06_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '07' then
            update pld_sal_cus_prd_1302
               set p07_qty = sales_period_03_fact_r01.billed_qty,
                   p07_ton = sales_period_03_fact_r01.billed_ton,
                   p07_gsv = sales_period_03_fact_r01.billed_gsv,
                   p07_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '08' then
            update pld_sal_cus_prd_1302
               set p08_qty = sales_period_03_fact_r01.billed_qty,
                   p08_ton = sales_period_03_fact_r01.billed_ton,
                   p08_gsv = sales_period_03_fact_r01.billed_gsv,
                   p08_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '09' then
            update pld_sal_cus_prd_1302
               set p09_qty = sales_period_03_fact_r01.billed_qty,
                   p09_ton = sales_period_03_fact_r01.billed_ton,
                   p09_gsv = sales_period_03_fact_r01.billed_gsv,
                   p09_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '10' then
            update pld_sal_cus_prd_1302
               set p10_qty = sales_period_03_fact_r01.billed_qty,
                   p10_ton = sales_period_03_fact_r01.billed_ton,
                   p10_gsv = sales_period_03_fact_r01.billed_gsv,
                   p10_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '11' then
            update pld_sal_cus_prd_1302
               set p11_qty = sales_period_03_fact_r01.billed_qty,
                   p11_ton = sales_period_03_fact_r01.billed_ton,
                   p11_gsv = sales_period_03_fact_r01.billed_gsv,
                   p11_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '12' then
            update pld_sal_cus_prd_1302
               set p12_qty = sales_period_03_fact_r01.billed_qty,
                   p12_ton = sales_period_03_fact_r01.billed_ton,
                   p12_gsv = sales_period_03_fact_r01.billed_gsv,
                   p12_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '13' then
            update pld_sal_cus_prd_1302
               set p13_qty = sales_period_03_fact_r01.billed_qty,
                   p13_ton = sales_period_03_fact_r01.billed_ton,
                   p13_gsv = sales_period_03_fact_r01.billed_gsv,
                   p13_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         end if;
            
      end loop;
      close sales_period_03_fact_c01;

      /*-*/
      /* Extract the period sales values - previous year minus one
      /*-*/
      var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp-200, false);
      var_end_yyyypp := mfjpln_control.previousPeriodEnd(var_current_yyyypp-200, false);
      open sales_period_03_fact_c01;
      loop
         fetch sales_period_03_fact_c01 into sales_period_03_fact_r01;
         if sales_period_03_fact_c01%notfound then
            exit;
         end if;

         createPeriodHeader(sales_period_03_fact_r01.sap_company_code,
                            sales_period_03_fact_r01.sap_ship_to_cust_code,
                            sales_period_03_fact_r01.sap_sales_dtl_sales_org_code,
                            sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code,
                            sales_period_03_fact_r01.sap_sales_dtl_division_code,
                            sales_period_03_fact_r01.sap_material_code);

         update pld_sal_cus_prd_1301
            set tot_ly_qty = tot_ly_qty + sales_period_03_fact_r01.billed_qty,
                tot_ly_ton = tot_ly_ton + sales_period_03_fact_r01.billed_ton,
                tot_ly_gsv = tot_ly_gsv + sales_period_03_fact_r01.billed_gsv,
                tot_ly_niv = tot_ly_niv + sales_period_03_fact_r01.billed_niv
            where sap_company_code = sales_period_03_fact_r01.sap_company_code
              and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
              and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
              and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
              and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
              and sap_material_code = sales_period_03_fact_r01.sap_material_code;

         if substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '01' then
            update pld_sal_cus_prd_1302
               set p01_qty = sales_period_03_fact_r01.billed_qty,
                   p01_ton = sales_period_03_fact_r01.billed_ton,
                   p01_gsv = sales_period_03_fact_r01.billed_gsv,
                   p01_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '02' then
            update pld_sal_cus_prd_1302
               set p02_qty = sales_period_03_fact_r01.billed_qty,
                   p02_ton = sales_period_03_fact_r01.billed_ton,
                   p02_gsv = sales_period_03_fact_r01.billed_gsv,
                   p02_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '03' then
            update pld_sal_cus_prd_1302
               set p03_qty = sales_period_03_fact_r01.billed_qty,
                   p03_ton = sales_period_03_fact_r01.billed_ton,
                   p03_gsv = sales_period_03_fact_r01.billed_gsv,
                   p03_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '04' then
            update pld_sal_cus_prd_1302
               set p04_qty = sales_period_03_fact_r01.billed_qty,
                   p04_ton = sales_period_03_fact_r01.billed_ton,
                   p04_gsv = sales_period_03_fact_r01.billed_gsv,
                   p04_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '05' then
            update pld_sal_cus_prd_1302
               set p05_qty = sales_period_03_fact_r01.billed_qty,
                   p05_ton = sales_period_03_fact_r01.billed_ton,
                   p05_gsv = sales_period_03_fact_r01.billed_gsv,
                   p05_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '06' then
            update pld_sal_cus_prd_1302
               set p06_qty = sales_period_03_fact_r01.billed_qty,
                   p06_ton = sales_period_03_fact_r01.billed_ton,
                   p06_gsv = sales_period_03_fact_r01.billed_gsv,
                   p06_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '07' then
            update pld_sal_cus_prd_1302
               set p07_qty = sales_period_03_fact_r01.billed_qty,
                   p07_ton = sales_period_03_fact_r01.billed_ton,
                   p07_gsv = sales_period_03_fact_r01.billed_gsv,
                   p07_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '08' then
            update pld_sal_cus_prd_1302
               set p08_qty = sales_period_03_fact_r01.billed_qty,
                   p08_ton = sales_period_03_fact_r01.billed_ton,
                   p08_gsv = sales_period_03_fact_r01.billed_gsv,
                   p08_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '09' then
            update pld_sal_cus_prd_1302
               set p09_qty = sales_period_03_fact_r01.billed_qty,
                   p09_ton = sales_period_03_fact_r01.billed_ton,
                   p09_gsv = sales_period_03_fact_r01.billed_gsv,
                   p09_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '10' then
            update pld_sal_cus_prd_1302
               set p10_qty = sales_period_03_fact_r01.billed_qty,
                   p10_ton = sales_period_03_fact_r01.billed_ton,
                   p10_gsv = sales_period_03_fact_r01.billed_gsv,
                   p10_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '11' then
            update pld_sal_cus_prd_1302
               set p11_qty = sales_period_03_fact_r01.billed_qty,
                   p11_ton = sales_period_03_fact_r01.billed_ton,
                   p11_gsv = sales_period_03_fact_r01.billed_gsv,
                   p11_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '12' then
            update pld_sal_cus_prd_1302
               set p12_qty = sales_period_03_fact_r01.billed_qty,
                   p12_ton = sales_period_03_fact_r01.billed_ton,
                   p12_gsv = sales_period_03_fact_r01.billed_gsv,
                   p12_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_period_03_fact_r01.sap_billing_yyyypp,'fm000000'),5,2) = '13' then
            update pld_sal_cus_prd_1302
               set p13_qty = sales_period_03_fact_r01.billed_qty,
                   p13_ton = sales_period_03_fact_r01.billed_ton,
                   p13_gsv = sales_period_03_fact_r01.billed_gsv,
                   p13_niv = sales_period_03_fact_r01.billed_niv
               where sap_company_code = sales_period_03_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
                 and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
                 and sap_material_code = sales_period_03_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         end if;

      end loop;
      close sales_period_03_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_sales_data;

   /*****************************************************/
   /* This procedure performs the forecast data routine */
   /*****************************************************/
   procedure exe_forecast_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_current_yyyypp number(6,0);
      var_start_yyyypp number(6,0);
      var_end_yyyypp number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor fcst_period_01_fact_c01 is 
         select t01.sap_sales_dtl_sales_org_code,
                t01.sap_sales_div_cust_code,
                t01.sap_sales_div_sales_org_code,
                t01.sap_sales_div_distbn_chnl_code,
                t01.sap_sales_div_division_code,
                t01.sap_material_code,
                t01.billing_yyyypp,
                sum(t01.op_qty) as op_qty,
                round(sum(decode(t02.sap_wgt_unit_code,
                                 'G', t02.net_wgt/1000000,
                                 'GRM', t02.net_wgt/1000000,
                                 'KG', t02.net_wgt/1000,
                                 'KGM', t02.net_wgt/1000,
                                 'TO', t02.net_wgt/1,
                                 'TON', t02.net_wgt/1,
                                 0) * t01.op_qty),6) as op_ton,
                sum(t01.op_gsv_value) as op_gsv
         from fcst_period_01_fact t01, material_dim t02
         where t01.sap_material_code = t02.sap_material_code(+)
           and t01.sap_sales_dtl_sales_org_code = par_sap_company_code
           and t01.billing_yyyypp >= var_start_yyyypp
           and t01.billing_yyyypp <= var_end_yyyypp
           and (t01.op_qty <> 0 or
                t01.op_gsv_value <> 0)
         group by t01.sap_sales_dtl_sales_org_code,
                  t01.sap_sales_div_cust_code,
                  t01.sap_sales_div_sales_org_code,
                  t01.sap_sales_div_distbn_chnl_code,
                  t01.sap_sales_div_division_code,
                  t01.sap_material_code,
                  t01.billing_yyyypp;
      fcst_period_01_fact_r01 fcst_period_01_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period variable
      /*-*/
      select current_yyyypp into var_current_yyyypp from pld_sal_cus_prd_1300 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the period forecast values - this year
      /*-*/
      var_start_yyyypp := mfjpln_control.previousPeriodStart(var_current_yyyypp-100, false);
      var_end_yyyypp := mfjpln_control.previousPeriodEnd(var_current_yyyypp-100, false);
      open fcst_period_01_fact_c01;
      loop
         fetch fcst_period_01_fact_c01 into fcst_period_01_fact_r01;
         if fcst_period_01_fact_c01%notfound then
            exit;
         end if;

         createPeriodHeader(fcst_period_01_fact_r01.sap_sales_dtl_sales_org_code,
                            fcst_period_01_fact_r01.sap_sales_div_cust_code,
                            fcst_period_01_fact_r01.sap_sales_div_sales_org_code,
                            fcst_period_01_fact_r01.sap_sales_div_distbn_chnl_code,
                            fcst_period_01_fact_r01.sap_sales_div_division_code,
                            fcst_period_01_fact_r01.sap_material_code);

         update pld_sal_cus_prd_1301
            set tot_op_qty = tot_op_qty + fcst_period_01_fact_r01.op_qty,
                tot_op_ton = tot_op_ton + fcst_period_01_fact_r01.op_ton,
                tot_op_gsv = tot_op_gsv + fcst_period_01_fact_r01.op_gsv,
                tot_op_niv = tot_op_niv + 0
            where sap_company_code = fcst_period_01_fact_r01.sap_sales_dtl_sales_org_code
              and sap_ship_to_cust_code = fcst_period_01_fact_r01.sap_sales_div_cust_code
              and sap_sales_org_code = fcst_period_01_fact_r01.sap_sales_div_sales_org_code
              and sap_distbn_chnl_code = fcst_period_01_fact_r01.sap_sales_div_distbn_chnl_code
              and sap_division_code = fcst_period_01_fact_r01.sap_sales_div_division_code
              and sap_material_code = fcst_period_01_fact_r01.sap_material_code;

      end loop;
      close fcst_period_01_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_forecast_data;

   /************************************************************/
   /* This procedure performs the create period header routine */
   /************************************************************/
   procedure createPeriodHeader(par_sap_company_code in varchar2,
                                par_sap_ship_to_cust_code in varchar2,
                                par_sap_sales_org_code in varchar2,
                                par_sap_distbn_chnl_code in varchar2,
                                par_sap_division_code in varchar2,
                                par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor pld_sal_cus_prd_1301_c01 is 
         select 'x'
         from pld_sal_cus_prd_1301
         where pld_sal_cus_prd_1301.sap_company_code = par_sap_company_code
           and pld_sal_cus_prd_1301.sap_ship_to_cust_code = par_sap_ship_to_cust_code
           and pld_sal_cus_prd_1301.sap_sales_org_code = par_sap_sales_org_code
           and pld_sal_cus_prd_1301.sap_distbn_chnl_code = par_sap_distbn_chnl_code
           and pld_sal_cus_prd_1301.sap_division_code = par_sap_division_code
           and pld_sal_cus_prd_1301.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new period data row when required
      /*-*/
      open pld_sal_cus_prd_1301_c01;
      fetch pld_sal_cus_prd_1301_c01 into var_work;
      if pld_sal_cus_prd_1301_c01%notfound then
         insert into pld_sal_cus_prd_1301
            (sap_company_code,
             sap_ship_to_cust_code,
             sap_sales_org_code,
             sap_distbn_chnl_code,
             sap_division_code,
             sap_material_code,
             tot_ty_qty,
             tot_ty_ton,
             tot_ty_gsv,
             tot_ty_niv,
             tot_ly_qty,
             tot_ly_ton,
             tot_ly_gsv,
             tot_ly_niv,
             tot_op_qty,
             tot_op_ton,
             tot_op_gsv,
             tot_op_niv)
         values
            (par_sap_company_code,
             par_sap_ship_to_cust_code,
             par_sap_sales_org_code,
             par_sap_distbn_chnl_code,
             par_sap_division_code,
             par_sap_material_code,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0);
         createPeriodDetail(par_sap_company_code,
                            par_sap_ship_to_cust_code,
                            par_sap_sales_org_code,
                            par_sap_distbn_chnl_code,
                            par_sap_division_code,
                            par_sap_material_code,
                            'TYR');
         createPeriodDetail(par_sap_company_code,
                            par_sap_ship_to_cust_code,
                            par_sap_sales_org_code,
                            par_sap_distbn_chnl_code,
                            par_sap_division_code,
                            par_sap_material_code,
                            'LYR');
      end if;
      close pld_sal_cus_prd_1301_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createPeriodHeader;

   /************************************************************/
   /* This procedure performs the create period detail routine */
   /************************************************************/
   procedure createPeriodDetail(par_sap_company_code in varchar2,
                                par_sap_ship_to_cust_code in varchar2,
                                par_sap_sales_org_code in varchar2,
                                par_sap_distbn_chnl_code in varchar2,
                                par_sap_division_code in varchar2,
                                par_sap_material_code in varchar2,
                                par_dta_type in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin 

      /*-*/
      /* Create a new period detail row
      /*-*/
      insert into pld_sal_cus_prd_1302
         (sap_company_code,
          sap_ship_to_cust_code,
          sap_sales_org_code,
          sap_distbn_chnl_code,
          sap_division_code,
          sap_material_code,
          dta_type,
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
          p01_ton,
          p02_ton,
          p03_ton,
          p04_ton,
          p05_ton,
          p06_ton,
          p07_ton,
          p08_ton,
          p09_ton,
          p10_ton,
          p11_ton,
          p12_ton,
          p13_ton,
          p01_gsv,
          p02_gsv,
          p03_gsv,
          p04_gsv,
          p05_gsv,
          p06_gsv,
          p07_gsv,
          p08_gsv,
          p09_gsv,
          p10_gsv,
          p11_gsv,
          p12_gsv,
          p13_gsv,
          p01_niv,
          p02_niv,
          p03_niv,
          p04_niv,
          p05_niv,
          p06_niv,
          p07_niv,
          p08_niv,
          p09_niv,
          p10_niv,
          p11_niv,
          p12_niv,
          p13_niv)
         values(
            par_sap_company_code,
            par_sap_ship_to_cust_code,
            par_sap_sales_org_code,
            par_sap_distbn_chnl_code,
            par_sap_division_code,
            par_sap_material_code,
            par_dta_type,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createPeriodDetail;

end hk_sal_cus_prd_13_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_cus_prd_13_extract for pld_rep_app.hk_sal_cus_prd_13_extract;
grant execute on hk_sal_cus_prd_13_extract to public;