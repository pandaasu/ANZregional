/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_sal_format02_extract                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_sal_format02_extract as

/**DESCRIPTION**
 Sales Extract Format 02 - Invoice date aggregations.
 This package extracts the sales and forecast data from the data warehouse. This
 information is replaced on a daily basis, however, the year to date figures always
 reflect the end of the last closed period. Therefore, only the year to go and year
 end estimate figures can change when new forecast data is loaded into the data
 warehouse.

 **PARAMETERS**
 none

 **NOTES**
 1. Tonne calculation - ignore sales tables incorrect column definition (hard-coded)

**/

   /*-*/
   /* Public declarations */
   /*-*/
   function main return varchar2;

end mfjpln_sal_format02_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_sal_format02_extract as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure controlData;
   procedure salesData;
   procedure forecastData;
   procedure createMaterialPeriodHeader(par_sap_company_code in varchar2,
                                        par_sap_material_code in varchar2);
   procedure createMaterialMonthHeader(par_sap_company_code in varchar2,
                                       par_sap_material_code in varchar2);
   procedure createMaterialPeriodDetail(par_sap_company_code in varchar2,
                                        par_sap_material_code in varchar2,
                                        par_billing_YYYYPP in number);
   procedure createMaterialMonthDetail(par_sap_company_code in varchar2,
                                       par_sap_material_code in varchar2,
                                       par_billing_YYYYMM in number);

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main return varchar2 is

      /*-*/
      /* Exception definitions */
      /*-*/
      ApplicationError exception;
      pragma exception_init(ApplicationError, -20000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /**/
      /* Truncate the temporary tables */
      /**/
      mfjpln_truncate.truncate_table('pld_sal_format0200');
      mfjpln_truncate.truncate_table('pld_sal_format0201');
      mfjpln_truncate.truncate_table('pld_sal_format0202');
      mfjpln_truncate.truncate_table('pld_sal_format0203');
      mfjpln_truncate.truncate_table('pld_sal_format0204');
      commit;

      /**/
      /* Extract the control data */
      /**/
      controlData;
      commit;

      /**/
      /* Extract the sales data */
      /**/
      salesData;
      commit;

      /**/
      /* Extract the forecast data */
      /**/
      forecastData;
      commit;

      /*-*/
      /*- Return the status */
      /**/
      return '*OK';

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /*-*/
      /* Application error */
      /*-*/
      when ApplicationError then
         return substr(SQLERRM, 1, 512);

      /*-*/
      /* Error trap */
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
   procedure controlData is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work_date date;
      var_current_YYYYPP number(6,0);
      var_prd_asofdays varchar2(128 char);
      var_prd_percent number(5,2);
      var_current_YYYYMM number(6,0);
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
      /* Retrieve the control information */
      /* **NOTE** based on today */
      /*-*/
      mfjpln_control.main('*INV',
                          sysdate,
                          false,
                          var_work_date,
                          var_current_YYYYPP,
                          var_prd_asofdays,
                          var_prd_percent,
                          var_current_YYYYMM,
                          var_mth_asofdays,
                          var_mth_percent,
                          var_extract_status,
                          var_inventory_date,
                          var_inventory_status,
                          var_sales_date,
                          var_sales_status);

      /*-*/
      /* Insert the control extract data */
      /*-*/
      insert into pld_sal_format0200
         (extract_date,
          logical_date,
          current_YYYYPP,
          current_YYYYMM,
          extract_status,
          sales_date,
          sales_status,
          prd_asofdays,
          prd_percent,
          mth_asofdays,
          mth_percent)
         values(sysdate,
                var_work_date,
                var_current_YYYYPP,
                var_current_YYYYMM,
                var_extract_status,
                var_sales_date,
                var_sales_status,
                var_prd_asofdays,
                var_prd_percent,
                var_mth_asofdays,
                var_mth_percent);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end controlData;

   /**************************************************/
   /* This procedure performs the sales data routine */
   /**************************************************/
   procedure salesData is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_logical_date date;
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_start_YYYYPP number(6,0);
      var_end_YYYYPP number(6,0);
      var_start_YYYYMM number(6,0);
      var_end_YYYYMM number(6,0);
      var_sap_company_code varchar2(6 char);
      var_sap_material_code varchar2(18 char);
      var_billing_YYYYPP number(6,0);
      var_billing_YYYYMM number(6,0);
      var_billed_qty number(13,0);
      var_billed_ton number(13,6);
      var_billed_bps number(18,0);
      var_billed_gsv number(18,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor sales_period_01_fact_c01 is 
         select sales_period_01_fact.sap_company_code,
                sales_period_01_fact.sap_material_code,
                sales_period_01_fact.billing_YYYYPP,
                sum(nvl(sales_period_01_fact.base_uom_billed_qty, 0)),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * nvl(sales_period_01_fact.base_uom_billed_qty, 0)),6),
                sum(sales_period_01_fact.sales_dtl_price_value_2),
                sum(sales_period_01_fact.sales_dtl_price_value_13)
         from sales_period_01_fact, material_dim
         where sales_period_01_fact.sap_material_code = material_dim.sap_material_code(+)
           and sales_period_01_fact.billing_YYYYPP >= var_start_YYYYPP
           and sales_period_01_fact.billing_YYYYPP <= var_end_YYYYPP
           and (nvl(sales_period_01_fact.base_uom_billed_qty, 0) <> 0 or
                sales_period_01_fact.sales_dtl_price_value_2 <> 0 or
                sales_period_01_fact.sales_dtl_price_value_13 <> 0)
         group by sales_period_01_fact.sap_company_code,
                  sales_period_01_fact.sap_material_code,
                  sales_period_01_fact.billing_YYYYPP;

      cursor sales_month_01_fact_c01 is 
         select sales_month_01_fact.sap_company_code,
                sales_month_01_fact.sap_material_code,
                sales_month_01_fact.billing_YYYYMM,
                sum(nvl(sales_month_01_fact.base_uom_billed_qty, 0)),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * nvl(sales_month_01_fact.base_uom_billed_qty, 0)),6),
                sum(sales_month_01_fact.sales_dtl_price_value_2),
                sum(sales_month_01_fact.sales_dtl_price_value_13)
         from sales_month_01_fact, material_dim
         where sales_month_01_fact.sap_material_code = material_dim.sap_material_code(+)
           and sales_month_01_fact.billing_YYYYMM >= var_start_YYYYMM
           and sales_month_01_fact.billing_YYYYMM <= var_end_YYYYMM
           and (nvl(sales_month_01_fact.base_uom_billed_qty, 0) <> 0 or
                sales_month_01_fact.sales_dtl_price_value_2 <> 0 or
                sales_month_01_fact.sales_dtl_price_value_13 <> 0)
         group by sales_month_01_fact.sap_company_code,
                  sales_month_01_fact.sap_material_code,
                  sales_month_01_fact.billing_YYYYMM;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current date, period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_sal_format0200;
      select current_YYYYMM into var_current_YYYYMM from pld_sal_format0200;

      /*-*/
      /* Extract the material period sales value */
      /*-*/
      var_start_YYYYPP := mfjpln_control.previousPeriodStart(var_current_YYYYPP, false);
      var_end_YYYYPP := mfjpln_control.previousPeriod(var_current_YYYYPP, false);
      open sales_period_01_fact_c01;
      loop
         fetch sales_period_01_fact_c01 into var_sap_company_code,
                                             var_sap_material_code,
                                             var_billing_YYYYPP,
                                             var_billed_qty,
                                             var_billed_ton,
                                             var_billed_bps,
                                             var_billed_gsv;
         if sales_period_01_fact_c01%notfound then
            exit;
         end if;
         createMaterialPeriodHeader(var_sap_company_code, var_sap_material_code);
         update pld_sal_format0201
            set ytd_ty_qty = ytd_ty_qty + var_billed_qty,
                ytd_ty_ton = ytd_ty_ton + var_billed_ton,
                ytd_ty_bps = ytd_ty_bps + var_billed_bps,
                ytd_ty_gsv = ytd_ty_gsv + var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
         createMaterialPeriodDetail(var_sap_company_code, var_sap_material_code, var_billing_YYYYPP);
         update pld_sal_format0203
            set ty_qty = var_billed_qty,
                ty_ton = var_billed_ton,
                ty_bps = var_billed_bps,
                ty_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code
              and billing_YYYYPP = var_billing_YYYYPP;
      end loop;
      close sales_period_01_fact_c01;

      /*-*/
      /* Extract the material month sales value */
      /*-*/
      var_start_YYYYMM := mfjpln_control.previousMonthStart(var_current_YYYYMM, false);
      var_end_YYYYMM := mfjpln_control.previousMonth(var_current_YYYYMM, false);
      open sales_month_01_fact_c01;
      loop
         fetch sales_month_01_fact_c01 into var_sap_company_code,
                                            var_sap_material_code,
                                            var_billing_YYYYMM,
                                            var_billed_qty,
                                            var_billed_ton,
                                            var_billed_bps,
                                            var_billed_gsv;
         if sales_month_01_fact_c01%notfound then
            exit;
         end if;
         createMaterialMonthHeader(var_sap_company_code, var_sap_material_code);
         update pld_sal_format0202
            set ytd_ty_qty = ytd_ty_qty + var_billed_qty,
                ytd_ty_ton = ytd_ty_ton + var_billed_ton,
                ytd_ty_bps = ytd_ty_bps + var_billed_bps,
                ytd_ty_gsv = ytd_ty_gsv + var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
         createMaterialMonthDetail(var_sap_company_code, var_sap_material_code, var_billing_YYYYMM);
         update pld_sal_format0204
            set ty_qty = var_billed_qty,
                ty_ton = var_billed_ton,
                ty_bps = var_billed_bps,
                ty_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code
              and billing_YYYYMM = var_billing_YYYYMM;
      end loop;
      close sales_month_01_fact_c01;

      /*-*/
      /* Extract the material period last year sales value */
      /*-*/
      var_start_YYYYPP := mfjpln_control.previousPeriodStart(var_current_YYYYPP - 100, false);
      var_end_YYYYPP := mfjpln_control.previousPeriodEnd(var_current_YYYYPP - 100, false);
      open sales_period_01_fact_c01;
      loop
         fetch sales_period_01_fact_c01 into var_sap_company_code,
                                             var_sap_material_code,
                                             var_billing_YYYYPP,
                                             var_billed_qty,
                                             var_billed_ton,
                                             var_billed_bps,
                                             var_billed_gsv;
         if sales_period_01_fact_c01%notfound then
            exit;
         end if;
         var_billing_YYYYPP := var_billing_YYYYPP + 100;
         createMaterialPeriodHeader(var_sap_company_code, var_sap_material_code);
         if var_billing_YYYYPP < var_current_YYYYPP then
            update pld_sal_format0201
               set ytd_ly_qty = ytd_ly_qty + var_billed_qty,
                   ytd_ly_ton = ytd_ly_ton + var_billed_ton,
                   ytd_ly_bps = ytd_ly_bps + var_billed_bps,
                   ytd_ly_gsv = ytd_ly_gsv + var_billed_gsv
               where sap_company_code = var_sap_company_code
                 and sap_material_code = var_sap_material_code;
         else
            update pld_sal_format0201
               set ytg_ly_qty = ytg_ly_qty + var_billed_qty,
                   ytg_ly_ton = ytg_ly_ton + var_billed_ton,
                   ytg_ly_bps = ytg_ly_bps + var_billed_bps,
                   ytg_ly_gsv = ytg_ly_gsv + var_billed_gsv
               where sap_company_code = var_sap_company_code
                 and sap_material_code = var_sap_material_code;
         end if;
         createMaterialPeriodDetail(var_sap_company_code, var_sap_material_code, var_billing_YYYYPP);
         update pld_sal_format0203
            set ly_qty = var_billed_qty,
                ly_ton = var_billed_ton,
                ly_bps = var_billed_bps,
                ly_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code
              and billing_YYYYPP = var_billing_YYYYPP;
      end loop;
      close sales_period_01_fact_c01;

      /*-*/
      /* Extract the material month last year sales value */
      /*-*/
      var_start_YYYYMM := mfjpln_control.previousMonthStart(var_current_YYYYMM - 100, false);
      var_end_YYYYMM := mfjpln_control.previousMonthEnd(var_current_YYYYMM - 100, false);
      open sales_month_01_fact_c01;
      loop
         fetch sales_month_01_fact_c01 into var_sap_company_code,
                                            var_sap_material_code,
                                            var_billing_YYYYMM,
                                            var_billed_qty,
                                            var_billed_ton,
                                            var_billed_bps,
                                            var_billed_gsv;
         if sales_month_01_fact_c01%notfound then
            exit;
         end if;
         var_billing_YYYYMM := var_billing_YYYYMM + 100;
         createMaterialMonthHeader(var_sap_company_code, var_sap_material_code);
         if var_billing_YYYYMM < var_current_YYYYMM then
            update pld_sal_format0202
               set ytd_ly_qty = ytd_ly_qty + var_billed_qty,
                   ytd_ly_ton = ytd_ly_ton + var_billed_ton,
                   ytd_ly_bps = ytd_ly_bps + var_billed_bps,
                   ytd_ly_gsv = ytd_ly_gsv + var_billed_gsv
               where sap_company_code = var_sap_company_code
                 and sap_material_code = var_sap_material_code;
         else
            update pld_sal_format0202
               set ytg_ly_qty = ytg_ly_qty + var_billed_qty,
                   ytg_ly_ton = ytg_ly_ton + var_billed_ton,
                   ytg_ly_bps = ytg_ly_bps + var_billed_bps,
                   ytg_ly_gsv = ytg_ly_gsv + var_billed_gsv
               where sap_company_code = var_sap_company_code
                 and sap_material_code = var_sap_material_code;
         end if;
         createMaterialMonthDetail(var_sap_company_code, var_sap_material_code, var_billing_YYYYMM);
         update pld_sal_format0204
            set ly_qty = var_billed_qty,
                ly_ton = var_billed_ton,
                ly_bps = var_billed_bps,
                ly_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code
              and billing_YYYYMM = var_billing_YYYYMM;
      end loop;
      close sales_month_01_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end salesData;

   /*****************************************************/
   /* This procedure performs the forecast data routine */
   /*****************************************************/
   procedure forecastData is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_start_YYYYPP number(6,0);
      var_end_YYYYPP number(6,0);
      var_start_YYYYMM number(6,0);
      var_end_YYYYMM number(6,0);
      var_sap_sales_org_code varchar2(4 char);
      var_sap_material_code varchar2(18 char);
      var_billing_YYYYPP number(6,0);
      var_billing_YYYYMM number(6,0);
      var_op_qty number(12,0);
      var_br_qty number(12,0);
      var_le_qty number(12,0);
      var_op_ton number(13,6);
      var_br_ton number(13,6);
      var_le_ton number(13,6);
      var_op_bps number(16,2);
      var_br_bps number(16,2);
      var_le_bps number(16,2);
      var_op_gsv number(16,2);
      var_br_gsv number(16,2);
      var_le_gsv number(16,2);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor fcst_period_02_fact_c01 is 
         select fcst_period_02_fact.sap_sales_dtl_sales_org_code,
                fcst_period_02_fact.sap_material_code,
                fcst_period_02_fact.billing_YYYYPP,
                sum(fcst_period_02_fact.op_qty),
                sum(fcst_period_02_fact.br_qty),
                sum(fcst_period_02_fact.le_qty),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * fcst_period_02_fact.op_qty),6),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * fcst_period_02_fact.br_qty),6),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * fcst_period_02_fact.le_qty),6),
                sum(fcst_period_02_fact.op_base_price_value),
                sum(fcst_period_02_fact.br_base_price_value),
                sum(fcst_period_02_fact.le_base_price_value),
                sum(fcst_period_02_fact.op_gsv_value),
                sum(fcst_period_02_fact.br_gsv_value),
                sum(fcst_period_02_fact.le_gsv_value)
         from fcst_period_02_fact, material_dim
         where fcst_period_02_fact.sap_material_code = material_dim.sap_material_code(+)
           and fcst_period_02_fact.billing_YYYYPP >= var_start_YYYYPP
           and fcst_period_02_fact.billing_YYYYPP <= var_end_YYYYPP
           and (fcst_period_02_fact.op_qty <> 0 or
                fcst_period_02_fact.br_qty <> 0 or
                fcst_period_02_fact.le_qty <> 0 or
                fcst_period_02_fact.op_base_price_value <> 0 or
                fcst_period_02_fact.br_base_price_value <> 0 or
                fcst_period_02_fact.le_base_price_value <> 0 or
                fcst_period_02_fact.op_gsv_value <> 0 or
                fcst_period_02_fact.br_gsv_value <> 0 or
                fcst_period_02_fact.le_gsv_value <> 0)
         group by fcst_period_02_fact.sap_sales_dtl_sales_org_code,
                  fcst_period_02_fact.sap_material_code,
                  fcst_period_02_fact.billing_YYYYPP;

      cursor fcst_month_02_fact_c01 is 
         select fcst_month_02_fact.sap_sales_dtl_sales_org_code,
                fcst_month_02_fact.sap_material_code,
                fcst_month_02_fact.billing_YYYYMM,
                sum(fcst_month_02_fact.op_qty),
                sum(fcst_month_02_fact.br_qty),
                sum(fcst_month_02_fact.le_qty),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * fcst_month_02_fact.op_qty),6),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * fcst_month_02_fact.br_qty),6),
                round(sum(decode(material_dim.sap_wgt_unit_code,
                                 'G', material_dim.net_wgt/1000000,
                                 'GRM', material_dim.net_wgt/1000000,
                                 'KG', material_dim.net_wgt/1000,
                                 'KGM', material_dim.net_wgt/1000,
                                 'TO', material_dim.net_wgt/1,
                                 'TON', material_dim.net_wgt/1,
                                 0) * fcst_month_02_fact.le_qty),6),
                sum(fcst_month_02_fact.op_base_price_value),
                sum(fcst_month_02_fact.br_base_price_value),
                sum(fcst_month_02_fact.le_base_price_value),
                sum(fcst_month_02_fact.op_gsv_value),
                sum(fcst_month_02_fact.br_gsv_value),
                sum(fcst_month_02_fact.le_gsv_value)
         from fcst_month_02_fact, material_dim
         where fcst_month_02_fact.sap_material_code = material_dim.sap_material_code(+)
           and fcst_month_02_fact.billing_YYYYMM >= var_start_YYYYMM
           and fcst_month_02_fact.billing_YYYYMM <= var_end_YYYYMM
           and (fcst_month_02_fact.op_qty <> 0 or
                fcst_month_02_fact.br_qty <> 0 or
                fcst_month_02_fact.le_qty <> 0 or
                fcst_month_02_fact.op_base_price_value <> 0 or
                fcst_month_02_fact.br_base_price_value <> 0 or
                fcst_month_02_fact.le_base_price_value <> 0 or
                fcst_month_02_fact.op_gsv_value <> 0 or
                fcst_month_02_fact.br_gsv_value <> 0 or
                fcst_month_02_fact.le_gsv_value <> 0)
         group by fcst_month_02_fact.sap_sales_dtl_sales_org_code,
                  fcst_month_02_fact.sap_material_code,
                  fcst_month_02_fact.billing_YYYYMM;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_sal_format0200;
      select current_YYYYMM into var_current_YYYYMM from pld_sal_format0200;

      /*-*/
      /* Extract the material period forecast values */
      /*-*/
      var_start_YYYYPP := mfjpln_control.previousPeriodStart(var_current_YYYYPP, false);
      var_end_YYYYPP := mfjpln_control.previousPeriodEnd(var_current_YYYYPP, false);
      open fcst_period_02_fact_c01;
      loop
         fetch fcst_period_02_fact_c01 into var_sap_sales_org_code,
                                            var_sap_material_code,
                                            var_billing_YYYYPP,
                                            var_op_qty,
                                            var_br_qty,
                                            var_le_qty,
                                            var_op_ton,
                                            var_br_ton,
                                            var_le_ton,
                                            var_op_bps,
                                            var_br_bps,
                                            var_le_bps,
                                            var_op_gsv,
                                            var_br_gsv,
                                            var_le_gsv;
         if fcst_period_02_fact_c01%notfound then
            exit;
         end if;
         createMaterialPeriodHeader(var_sap_sales_org_code, var_sap_material_code);
         if var_billing_YYYYPP < var_current_YYYYPP then
            update pld_sal_format0201
               set ytd_op_qty = ytd_op_qty + var_op_qty,
                   ytd_op_ton = ytd_op_ton + var_op_ton,
                   ytd_op_bps = ytd_op_bps + var_op_bps,
                   ytd_op_gsv = ytd_op_gsv + var_op_gsv,
                   ytd_br_qty = ytd_br_qty + var_br_qty,
                   ytd_br_ton = ytd_br_ton + var_br_ton,
                   ytd_br_bps = ytd_br_bps + var_br_bps,
                   ytd_br_gsv = ytd_br_gsv + var_br_gsv,
                   ytd_le_qty = ytd_le_qty + var_le_qty,
                   ytd_le_ton = ytd_le_ton + var_le_ton,
                   ytd_le_bps = ytd_le_bps + var_le_bps,
                   ytd_le_gsv = ytd_le_gsv + var_le_gsv
               where sap_company_code = var_sap_sales_org_code
                 and sap_material_code = var_sap_material_code;
         else
            update pld_sal_format0201
               set ytg_op_qty = ytg_op_qty + var_op_qty,
                   ytg_op_ton = ytg_op_ton + var_op_ton,
                   ytg_op_bps = ytg_op_bps + var_op_bps,
                   ytg_op_gsv = ytg_op_gsv + var_op_gsv,
                   ytg_br_qty = ytg_br_qty + var_br_qty,
                   ytg_br_ton = ytg_br_ton + var_br_ton,
                   ytg_br_bps = ytg_br_bps + var_br_bps,
                   ytg_br_gsv = ytg_br_gsv + var_br_gsv,
                   ytg_le_qty = ytg_le_qty + var_le_qty,
                   ytg_le_ton = ytg_le_ton + var_le_ton,
                   ytg_le_bps = ytg_le_bps + var_le_bps,
                   ytg_le_gsv = ytg_le_gsv + var_le_gsv
               where sap_company_code = var_sap_sales_org_code
                 and sap_material_code = var_sap_material_code;
         end if;
         createMaterialPeriodDetail(var_sap_sales_org_code, var_sap_material_code, var_billing_YYYYPP);
         update pld_sal_format0203
            set op_qty = var_op_qty,
                op_ton = var_op_ton,
                op_bps = var_op_bps,
                op_gsv = var_op_gsv,
                br_qty = var_br_qty,
                br_ton = var_br_ton,
                br_bps = var_br_bps,
                br_gsv = var_br_gsv,
                le_qty = var_le_qty,
                le_ton = var_le_ton,
                le_bps = var_le_bps,
                le_gsv = var_le_gsv
            where sap_company_code = var_sap_sales_org_code
              and sap_material_code = var_sap_material_code
              and billing_YYYYPP = var_billing_YYYYPP;
      end loop;
      close fcst_period_02_fact_c01;

      /*-*/
      /* Extract the material month forecast values */
      /*-*/
      var_start_YYYYMM := mfjpln_control.previousMonthStart(var_current_YYYYMM, false);
      var_end_YYYYMM := mfjpln_control.previousMonthEnd(var_current_YYYYMM, false);
      open fcst_month_02_fact_c01;
      loop
         fetch fcst_month_02_fact_c01 into var_sap_sales_org_code,
                                           var_sap_material_code,
                                           var_billing_YYYYMM,
                                           var_op_qty,
                                           var_br_qty,
                                           var_le_qty,
                                           var_op_ton,
                                           var_br_ton,
                                           var_le_ton,
                                           var_op_bps,
                                           var_br_bps,
                                           var_le_bps,
                                           var_op_gsv,
                                           var_br_gsv,
                                           var_le_gsv;
         if fcst_month_02_fact_c01%notfound then
            exit;
         end if;
         createMaterialMonthHeader(var_sap_sales_org_code, var_sap_material_code);
         if var_billing_YYYYMM < var_current_YYYYMM then
            update pld_sal_format0202
               set ytd_op_qty = ytd_op_qty + var_op_qty,
                   ytd_op_ton = ytd_op_ton + var_op_ton,
                   ytd_op_bps = ytd_op_bps + var_op_bps,
                   ytd_op_gsv = ytd_op_gsv + var_op_gsv,
                   ytd_br_qty = ytd_br_qty + var_br_qty,
                   ytd_br_ton = ytd_br_ton + var_br_ton,
                   ytd_br_bps = ytd_br_bps + var_br_bps,
                   ytd_br_gsv = ytd_br_gsv + var_br_gsv,
                   ytd_le_qty = ytd_le_qty + var_le_qty,
                   ytd_le_ton = ytd_le_ton + var_le_ton,
                   ytd_le_bps = ytd_le_bps + var_le_bps,
                   ytd_le_gsv = ytd_le_gsv + var_le_gsv
               where sap_company_code = var_sap_sales_org_code
                 and sap_material_code = var_sap_material_code;
         else
            update pld_sal_format0202
               set ytg_op_qty = ytg_op_qty + var_op_qty,
                   ytg_op_ton = ytg_op_ton + var_op_ton,
                   ytg_op_bps = ytg_op_bps + var_op_bps,
                   ytg_op_gsv = ytg_op_gsv + var_op_gsv,
                   ytg_br_qty = ytg_br_qty + var_br_qty,
                   ytg_br_ton = ytg_br_ton + var_br_ton,
                   ytg_br_bps = ytg_br_bps + var_br_bps,
                   ytg_br_gsv = ytg_br_gsv + var_br_gsv,
                   ytg_le_qty = ytg_le_qty + var_le_qty,
                   ytg_le_ton = ytg_le_ton + var_le_ton,
                   ytg_le_bps = ytg_le_bps + var_le_bps,
                   ytg_le_gsv = ytg_le_gsv + var_le_gsv
               where sap_company_code = var_sap_sales_org_code
                 and sap_material_code = var_sap_material_code;
         end if;
         createMaterialMonthDetail(var_sap_sales_org_code, var_sap_material_code, var_billing_YYYYMM);
         update pld_sal_format0204
            set op_qty = var_op_qty,
                op_ton = var_op_ton,
                op_bps = var_op_bps,
                op_gsv = var_op_gsv,
                br_qty = var_br_qty,
                br_ton = var_br_ton,
                br_bps = var_br_bps,
                br_gsv = var_br_gsv,
                le_qty = var_le_qty,
                le_ton = var_le_ton,
                le_bps = var_le_bps,
                le_gsv = var_le_gsv
            where sap_company_code = var_sap_sales_org_code
              and sap_material_code = var_sap_material_code
              and billing_YYYYMM = var_billing_YYYYMM;
      end loop;
      close fcst_month_02_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end forecastData;

   /**************************************************************************/
   /* This procedure performs the create material period header data routine */
   /**************************************************************************/
   procedure createMaterialPeriodHeader(par_sap_company_code in varchar2,
                                        par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_sal_format0201_c01 is 
         select 'x'
         from pld_sal_format0201
         where pld_sal_format0201.sap_company_code = par_sap_company_code
           and pld_sal_format0201.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new period header row when required */
      /*-*/
      open pld_sal_format0201_c01;
      fetch pld_sal_format0201_c01 into var_work;
      if pld_sal_format0201_c01%notfound then
         insert into pld_sal_format0201
            (sap_company_code,
             sap_material_code,
             ytd_ty_qty,
             ytd_ty_ton,
             ytd_ty_bps,
             ytd_ty_gsv,
             ytd_ly_qty,
             ytd_ly_ton,
             ytd_ly_bps,
             ytd_ly_gsv,
             ytd_op_qty,
             ytd_op_ton,
             ytd_op_bps,
             ytd_op_gsv,
             ytd_br_qty,
             ytd_br_ton,
             ytd_br_bps,
             ytd_br_gsv,
             ytd_le_qty,
             ytd_le_ton,
             ytd_le_bps,
             ytd_le_gsv,
             ytg_ly_qty,
             ytg_ly_ton,
             ytg_ly_bps,
             ytg_ly_gsv,
             ytg_op_qty,
             ytg_op_ton,
             ytg_op_bps,
             ytg_op_gsv,
             ytg_br_qty,
             ytg_br_ton,
             ytg_br_bps,
             ytg_br_gsv,
             ytg_le_qty,
             ytg_le_ton,
             ytg_le_bps,
             ytg_le_gsv)
            values(
               par_sap_company_code,
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
      end if;
      close pld_sal_format0201_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createMaterialPeriodHeader;

   /*************************************************************************/
   /* This procedure performs the create material month header data routine */
   /*************************************************************************/
   procedure createMaterialMonthHeader(par_sap_company_code in varchar2,
                                       par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_sal_format0202_c01 is 
         select 'x'
         from pld_sal_format0202
         where pld_sal_format0202.sap_company_code = par_sap_company_code
           and pld_sal_format0202.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new month header row when required */
      /*-*/
      open pld_sal_format0202_c01;
      fetch pld_sal_format0202_c01 into var_work;
      if pld_sal_format0202_c01%notfound then
         insert into pld_sal_format0202
            (sap_company_code,
             sap_material_code,
             ytd_ty_qty,
             ytd_ty_ton,
             ytd_ty_bps,
             ytd_ty_gsv,
             ytd_ly_qty,
             ytd_ly_ton,
             ytd_ly_bps,
             ytd_ly_gsv,
             ytd_op_qty,
             ytd_op_ton,
             ytd_op_bps,
             ytd_op_gsv,
             ytd_br_qty,
             ytd_br_ton,
             ytd_br_bps,
             ytd_br_gsv,
             ytd_le_qty,
             ytd_le_ton,
             ytd_le_bps,
             ytd_le_gsv,
             ytg_ly_qty,
             ytg_ly_ton,
             ytg_ly_bps,
             ytg_ly_gsv,
             ytg_op_qty,
             ytg_op_ton,
             ytg_op_bps,
             ytg_op_gsv,
             ytg_br_qty,
             ytg_br_ton,
             ytg_br_bps,
             ytg_br_gsv,
             ytg_le_qty,
             ytg_le_ton,
             ytg_le_bps,
             ytg_le_gsv)
            values(
               par_sap_company_code,
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
      end if;
      close pld_sal_format0202_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createMaterialMonthHeader;

   /**************************************************************************/
   /* This procedure performs the create material period detail data routine */
   /**************************************************************************/
   procedure createMaterialPeriodDetail(par_sap_company_code in varchar2,
                                        par_sap_material_code in varchar2,
                                        par_billing_YYYYPP in number) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_sal_format0203_c01 is 
         select 'x'
         from pld_sal_format0203
         where pld_sal_format0203.sap_company_code = par_sap_company_code
           and pld_sal_format0203.sap_material_code = par_sap_material_code
           and pld_sal_format0203.billing_YYYYPP = par_billing_YYYYPP;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new period detail row when required */
      /*-*/
      open pld_sal_format0203_c01;
      fetch pld_sal_format0203_c01 into var_work;
      if pld_sal_format0203_c01%notfound then
         insert into pld_sal_format0203
            (sap_company_code,
             sap_material_code,
             billing_YYYYPP,
             ty_qty,
             ty_ton,
             ty_bps,
             ty_gsv,
             ly_qty,
             ly_ton,
             ly_bps,
             ly_gsv,
             op_qty,
             op_ton,
             op_bps,
             op_gsv,
             br_qty,
             br_ton,
             br_bps,
             br_gsv,
             le_qty,
             le_ton,
             le_bps,
             le_gsv)
            values(
               par_sap_company_code,
               par_sap_material_code,
               par_billing_YYYYPP,
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
      end if;
      close pld_sal_format0203_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createMaterialPeriodDetail;

   /*************************************************************************/
   /* This procedure performs the create material month detail data routine */
   /*************************************************************************/
   procedure createMaterialMonthDetail(par_sap_company_code in varchar2,
                                       par_sap_material_code in varchar2,
                                       par_billing_YYYYMM in number) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_sal_format0204_c01 is 
         select 'x'
         from pld_sal_format0204
         where pld_sal_format0204.sap_company_code = par_sap_company_code
           and pld_sal_format0204.sap_material_code = par_sap_material_code
           and pld_sal_format0204.billing_YYYYMM = par_billing_YYYYMM;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin 

      /*-*/
      /* Create a new month detail row when required */
      /*-*/
      open pld_sal_format0204_c01;
      fetch pld_sal_format0204_c01 into var_work;
      if pld_sal_format0204_c01%notfound then
         insert into pld_sal_format0204
            (sap_company_code,
             sap_material_code,
             billing_YYYYMM,
             ty_qty,
             ty_ton,
             ty_bps,
             ty_gsv,
             ly_qty,
             ly_ton,
             ly_bps,
             ly_gsv,
             op_qty,
             op_ton,
             op_bps,
             op_gsv,
             br_qty,
             br_ton,
             br_bps,
             br_gsv,
             le_qty,
             le_ton,
             le_bps,
             le_gsv)
            values(
               par_sap_company_code,
               par_sap_material_code,
               par_billing_YYYYMM,
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
      end if;
      close pld_sal_format0204_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createMaterialMonthDetail;

end mfjpln_sal_format02_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_sal_format02_extract for pld_rep_app.mfjpln_sal_format02_extract;
grant execute on mfjpln_sal_format02_extract to public;