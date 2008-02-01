/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Package : hk_sal_mat_mth_03_extract                          */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : March 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_mat_mth_03_extract as

/**DESCRIPTION**
 Material MLY month invoice date extract.

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

end hk_sal_mat_mth_03_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_mat_mth_03_extract as

   /*-*/
   /* Private global declarations
   /*-*/
   procedure exe_control_data(par_sap_company_code in varchar2);
   procedure exe_sales_data(par_sap_company_code in varchar2);
   procedure exe_forecast_data(par_sap_company_code in varchar2);
   procedure createMonthHeader(par_sap_company_code in varchar2,
                               par_sap_material_code in varchar2);
   procedure createMonthDetail(par_sap_company_code in varchar2,
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
      delete from pld_sal_mat_mth_0300 where sap_company_code = par_sap_company_code;
      delete from pld_sal_mat_mth_0301 where sap_company_code = par_sap_company_code;
      delete from pld_sal_mat_mth_0302 where sap_company_code = par_sap_company_code;
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
                          '*INV',
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
      insert into pld_sal_mat_mth_0300
         (sap_company_code,
          extract_date,
          logical_date,
          current_yyyymm,
          extract_status,
          sales_date,
          sales_status,
          mth_asofdays,
          mth_percent)
         values(par_sap_company_code,
                sysdate,
                var_work_date,
                var_current_yyyymm,
                var_extract_status,
                var_sales_date,
                var_sales_status,
                var_mth_asofdays,
                var_mth_percent);

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
      var_current_yyyymm number(6,0);
      var_start_yyyymm number(6,0);
      var_end_yyyymm number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor sales_month_01_fact_c01 is 
         select t01.sap_company_code,
                t01.sap_material_code,
                t01.billing_yyyymm,
                sum(nvl(t01.base_uom_billed_qty, 0)) as billed_qty,
                sum(nvl(t01.tonnes_billed_qty, 0)) as billed_ton,
                sum(nvl(t01.sales_dtl_price_value_13, 0)) as billed_gsv,
                sum(nvl(t01.sales_dtl_price_value_17, 0)) as billed_niv
         from sales_month_01_fact t01
         where t01.sap_company_code = par_sap_company_code
           and t01.billing_yyyymm >= var_start_yyyymm
           and t01.billing_yyyymm <= var_end_yyyymm
           and (nvl(t01.base_uom_billed_qty, 0) <> 0 or
                nvl(t01.sales_dtl_price_value_13, 0) <> 0 or
                nvl(t01.sales_dtl_price_value_17, 0) <> 0)
           and nvl(t01.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(t01.sap_order_type_code,'*NULL')||'/'||nvl(t01.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
           and t01.sap_invc_type_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','INVOICE_TYPE_EXCLUSION')))
         group by t01.sap_company_code,
                  t01.sap_material_code,
                  t01.billing_yyyymm;
      sales_month_01_fact_r01 sales_month_01_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current date and month variables
      /*-*/
      select current_yyyymm into var_current_yyyymm from pld_sal_mat_mth_0300 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the month sales values - previous year
      /*-*/
      var_start_yyyymm := mfjpln_control.previousMonthStart(var_current_yyyymm-100, false);
      var_end_yyyymm := mfjpln_control.previousMonthEnd(var_current_yyyymm-100, false);
      open sales_month_01_fact_c01;
      loop
         fetch sales_month_01_fact_c01 into sales_month_01_fact_r01;
         if sales_month_01_fact_c01%notfound then
            exit;
         end if;

         createMonthHeader(sales_month_01_fact_r01.sap_company_code,
                           sales_month_01_fact_r01.sap_material_code);

         update pld_sal_mat_mth_0301
            set tot_ty_qty = tot_ty_qty + sales_month_01_fact_r01.billed_qty,
                tot_ty_ton = tot_ty_ton + sales_month_01_fact_r01.billed_ton,
                tot_ty_gsv = tot_ty_gsv + sales_month_01_fact_r01.billed_gsv,
                tot_ty_niv = tot_ty_niv + sales_month_01_fact_r01.billed_niv
            where sap_company_code = sales_month_01_fact_r01.sap_company_code
              and sap_material_code = sales_month_01_fact_r01.sap_material_code;

         if substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '01' then
            update pld_sal_mat_mth_0302
               set m01_qty = sales_month_01_fact_r01.billed_qty,
                   m01_ton = sales_month_01_fact_r01.billed_ton,
                   m01_gsv = sales_month_01_fact_r01.billed_gsv,
                   m01_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '02' then
            update pld_sal_mat_mth_0302
               set m02_qty = sales_month_01_fact_r01.billed_qty,
                   m02_ton = sales_month_01_fact_r01.billed_ton,
                   m02_gsv = sales_month_01_fact_r01.billed_gsv,
                   m02_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '03' then
            update pld_sal_mat_mth_0302
               set m03_qty = sales_month_01_fact_r01.billed_qty,
                   m03_ton = sales_month_01_fact_r01.billed_ton,
                   m03_gsv = sales_month_01_fact_r01.billed_gsv,
                   m03_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '04' then
            update pld_sal_mat_mth_0302
               set m04_qty = sales_month_01_fact_r01.billed_qty,
                   m04_ton = sales_month_01_fact_r01.billed_ton,
                   m04_gsv = sales_month_01_fact_r01.billed_gsv,
                   m04_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '05' then
            update pld_sal_mat_mth_0302
               set m05_qty = sales_month_01_fact_r01.billed_qty,
                   m05_ton = sales_month_01_fact_r01.billed_ton,
                   m05_gsv = sales_month_01_fact_r01.billed_gsv,
                   m05_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '06' then
            update pld_sal_mat_mth_0302
               set m06_qty = sales_month_01_fact_r01.billed_qty,
                   m06_ton = sales_month_01_fact_r01.billed_ton,
                   m06_gsv = sales_month_01_fact_r01.billed_gsv,
                   m06_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '07' then
            update pld_sal_mat_mth_0302
               set m07_qty = sales_month_01_fact_r01.billed_qty,
                   m07_ton = sales_month_01_fact_r01.billed_ton,
                   m07_gsv = sales_month_01_fact_r01.billed_gsv,
                   m07_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '08' then
            update pld_sal_mat_mth_0302
               set m08_qty = sales_month_01_fact_r01.billed_qty,
                   m08_ton = sales_month_01_fact_r01.billed_ton,
                   m08_gsv = sales_month_01_fact_r01.billed_gsv,
                   m08_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '09' then
            update pld_sal_mat_mth_0302
               set m09_qty = sales_month_01_fact_r01.billed_qty,
                   m09_ton = sales_month_01_fact_r01.billed_ton,
                   m09_gsv = sales_month_01_fact_r01.billed_gsv,
                   m09_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '10' then
            update pld_sal_mat_mth_0302
               set m10_qty = sales_month_01_fact_r01.billed_qty,
                   m10_ton = sales_month_01_fact_r01.billed_ton,
                   m10_gsv = sales_month_01_fact_r01.billed_gsv,
                   m10_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '11' then
            update pld_sal_mat_mth_0302
               set m11_qty = sales_month_01_fact_r01.billed_qty,
                   m11_ton = sales_month_01_fact_r01.billed_ton,
                   m11_gsv = sales_month_01_fact_r01.billed_gsv,
                   m11_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '12' then
            update pld_sal_mat_mth_0302
               set m12_qty = sales_month_01_fact_r01.billed_qty,
                   m12_ton = sales_month_01_fact_r01.billed_ton,
                   m12_gsv = sales_month_01_fact_r01.billed_gsv,
                   m12_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'TYR';
         end if;
            
      end loop;
      close sales_month_01_fact_c01;

      /*-*/
      /* Extract the month sales values - previous year minus one
      /*-*/
      var_start_yyyymm := mfjpln_control.previousMonthStart(var_current_yyyymm-200, false);
      var_end_yyyymm := mfjpln_control.previousMonthEnd(var_current_yyyymm-200, false);
      open sales_month_01_fact_c01;
      loop
         fetch sales_month_01_fact_c01 into sales_month_01_fact_r01;
         if sales_month_01_fact_c01%notfound then
            exit;
         end if;

         createMonthHeader(sales_month_01_fact_r01.sap_company_code,
                           sales_month_01_fact_r01.sap_material_code);

         update pld_sal_mat_mth_0301
            set tot_ly_qty = tot_ly_qty + sales_month_01_fact_r01.billed_qty,
                tot_ly_ton = tot_ly_ton + sales_month_01_fact_r01.billed_ton,
                tot_ly_gsv = tot_ly_gsv + sales_month_01_fact_r01.billed_gsv,
                tot_ly_niv = tot_ly_niv + sales_month_01_fact_r01.billed_niv
            where sap_company_code = sales_month_01_fact_r01.sap_company_code
              and sap_material_code = sales_month_01_fact_r01.sap_material_code;

         if substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '01' then
            update pld_sal_mat_mth_0302
               set m01_qty = sales_month_01_fact_r01.billed_qty,
                   m01_ton = sales_month_01_fact_r01.billed_ton,
                   m01_gsv = sales_month_01_fact_r01.billed_gsv,
                   m01_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '02' then
            update pld_sal_mat_mth_0302
               set m02_qty = sales_month_01_fact_r01.billed_qty,
                   m02_ton = sales_month_01_fact_r01.billed_ton,
                   m02_gsv = sales_month_01_fact_r01.billed_gsv,
                   m02_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '03' then
            update pld_sal_mat_mth_0302
               set m03_qty = sales_month_01_fact_r01.billed_qty,
                   m03_ton = sales_month_01_fact_r01.billed_ton,
                   m03_gsv = sales_month_01_fact_r01.billed_gsv,
                   m03_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '04' then
            update pld_sal_mat_mth_0302
               set m04_qty = sales_month_01_fact_r01.billed_qty,
                   m04_ton = sales_month_01_fact_r01.billed_ton,
                   m04_gsv = sales_month_01_fact_r01.billed_gsv,
                   m04_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '05' then
            update pld_sal_mat_mth_0302
               set m05_qty = sales_month_01_fact_r01.billed_qty,
                   m05_ton = sales_month_01_fact_r01.billed_ton,
                   m05_gsv = sales_month_01_fact_r01.billed_gsv,
                   m05_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '06' then
            update pld_sal_mat_mth_0302
               set m06_qty = sales_month_01_fact_r01.billed_qty,
                   m06_ton = sales_month_01_fact_r01.billed_ton,
                   m06_gsv = sales_month_01_fact_r01.billed_gsv,
                   m06_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '07' then
            update pld_sal_mat_mth_0302
               set m07_qty = sales_month_01_fact_r01.billed_qty,
                   m07_ton = sales_month_01_fact_r01.billed_ton,
                   m07_gsv = sales_month_01_fact_r01.billed_gsv,
                   m07_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '08' then
            update pld_sal_mat_mth_0302
               set m08_qty = sales_month_01_fact_r01.billed_qty,
                   m08_ton = sales_month_01_fact_r01.billed_ton,
                   m08_gsv = sales_month_01_fact_r01.billed_gsv,
                   m08_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '09' then
            update pld_sal_mat_mth_0302
               set m09_qty = sales_month_01_fact_r01.billed_qty,
                   m09_ton = sales_month_01_fact_r01.billed_ton,
                   m09_gsv = sales_month_01_fact_r01.billed_gsv,
                   m09_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '10' then
            update pld_sal_mat_mth_0302
               set m10_qty = sales_month_01_fact_r01.billed_qty,
                   m10_ton = sales_month_01_fact_r01.billed_ton,
                   m10_gsv = sales_month_01_fact_r01.billed_gsv,
                   m10_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '11' then
            update pld_sal_mat_mth_0302
               set m11_qty = sales_month_01_fact_r01.billed_qty,
                   m11_ton = sales_month_01_fact_r01.billed_ton,
                   m11_gsv = sales_month_01_fact_r01.billed_gsv,
                   m11_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         elsif substr(to_char(sales_month_01_fact_r01.billing_yyyymm,'fm000000'),5,2) = '12' then
            update pld_sal_mat_mth_0302
               set m12_qty = sales_month_01_fact_r01.billed_qty,
                   m12_ton = sales_month_01_fact_r01.billed_ton,
                   m12_gsv = sales_month_01_fact_r01.billed_gsv,
                   m12_niv = sales_month_01_fact_r01.billed_niv
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code
                 and dta_type = 'LYR';
         end if;

      end loop;
      close sales_month_01_fact_c01;

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
      var_current_yyyymm number(6,0);
      var_start_yyyymm number(6,0);
      var_end_yyyymm number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor fcst_month_02_fact_c01 is 
         select t01.sap_sales_dtl_sales_org_code,
                t01.sap_material_code,
                t01.billing_yyyymm,
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
         from fcst_month_02_fact t01, material_dim t02
         where t01.sap_material_code = t02.sap_material_code(+)
           and t01.sap_sales_dtl_sales_org_code = par_sap_company_code
           and t01.billing_yyyymm >= var_start_yyyymm
           and t01.billing_yyyymm <= var_end_yyyymm
           and (t01.op_qty <> 0 or
                t01.op_gsv_value <> 0)
         group by t01.sap_sales_dtl_sales_org_code,
                  t01.sap_material_code,
                  t01.billing_yyyymm;
      fcst_month_02_fact_r01 fcst_month_02_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current month variable
      /*-*/
      select current_yyyymm into var_current_yyyymm from pld_sal_mat_mth_0300 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the month forecast values - this year
      /*-*/
      var_start_yyyymm := mfjpln_control.previousMonthStart(var_current_yyyymm-100, false);
      var_end_yyyymm := mfjpln_control.previousMonthEnd(var_current_yyyymm-100, false);
      open fcst_month_02_fact_c01;
      loop
         fetch fcst_month_02_fact_c01 into fcst_month_02_fact_r01;
         if fcst_month_02_fact_c01%notfound then
            exit;
         end if;

         createMonthHeader(fcst_month_02_fact_r01.sap_sales_dtl_sales_org_code,
                           fcst_month_02_fact_r01.sap_material_code);

         update pld_sal_mat_mth_0301
            set tot_op_qty = tot_op_qty + fcst_month_02_fact_r01.op_qty,
                tot_op_ton = tot_op_ton + fcst_month_02_fact_r01.op_ton,
                tot_op_gsv = tot_op_gsv + fcst_month_02_fact_r01.op_gsv,
                tot_op_niv = tot_op_niv + 0
            where sap_company_code = fcst_month_02_fact_r01.sap_sales_dtl_sales_org_code
              and sap_material_code = fcst_month_02_fact_r01.sap_material_code;

      end loop;
      close fcst_month_02_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_forecast_data;

   /***********************************************************/
   /* This procedure performs the create month header routine */
   /***********************************************************/
   procedure createMonthHeader(par_sap_company_code in varchar2,
                               par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor pld_sal_mat_mth_0301_c01 is 
         select 'x'
         from pld_sal_mat_mth_0301
         where pld_sal_mat_mth_0301.sap_company_code = par_sap_company_code
           and pld_sal_mat_mth_0301.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new month data row when required
      /*-*/
      open pld_sal_mat_mth_0301_c01;
      fetch pld_sal_mat_mth_0301_c01 into var_work;
      if pld_sal_mat_mth_0301_c01%notfound then
         insert into pld_sal_mat_mth_0301
            (sap_company_code,
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
         createMonthDetail(par_sap_company_code,
                           par_sap_material_code,
                           'TYR');
         createMonthDetail(par_sap_company_code,
                           par_sap_material_code,
                           'LYR');
      end if;
      close pld_sal_mat_mth_0301_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createMonthHeader;

   /***********************************************************/
   /* This procedure performs the create month detail routine */
   /***********************************************************/
   procedure createMonthDetail(par_sap_company_code in varchar2,
                               par_sap_material_code in varchar2,
                               par_dta_type in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin 

      /*-*/
      /* Create a new month detail row
      /*-*/
      insert into pld_sal_mat_mth_0302
         (sap_company_code,
          sap_material_code,
          dta_type,
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
          m01_ton,
          m02_ton,
          m03_ton,
          m04_ton,
          m05_ton,
          m06_ton,
          m07_ton,
          m08_ton,
          m09_ton,
          m10_ton,
          m11_ton,
          m12_ton,
          m01_gsv,
          m02_gsv,
          m03_gsv,
          m04_gsv,
          m05_gsv,
          m06_gsv,
          m07_gsv,
          m08_gsv,
          m09_gsv,
          m10_gsv,
          m11_gsv,
          m12_gsv,
          m01_niv,
          m02_niv,
          m03_niv,
          m04_niv,
          m05_niv,
          m06_niv,
          m07_niv,
          m08_niv,
          m09_niv,
          m10_niv,
          m11_niv,
          m12_niv)
         values(
            par_sap_company_code,
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
            0);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createMonthDetail;

end hk_sal_mat_mth_03_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_mat_mth_03_extract for pld_rep_app.hk_sal_mat_mth_03_extract;
grant execute on hk_sal_mat_mth_03_extract to public;