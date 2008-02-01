/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_sal_format04_extract                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2004                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_sal_format04_extract as

   /*-*/
   /* Public declarations */
   /*-*/
   function main return varchar2;

end mfjpln_sal_format04_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_sal_format04_extract as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure exe_control_data;
   procedure exe_sales_data;
   procedure exe_forecast_data;
   procedure createPeriodData(par_sap_company_code in varchar2,
                              par_sap_hier_cust_code in varchar2,
                              par_sap_sales_org_code in varchar2,
                              par_sap_distbn_chnl_code in varchar2,
                              par_sap_division_code in varchar2,
                              par_sap_material_code in varchar2);
   procedure createMonthData(par_sap_company_code in varchar2,
                             par_sap_hier_cust_code in varchar2,
                             par_sap_sales_org_code in varchar2,
                             par_sap_distbn_chnl_code in varchar2,
                             par_sap_division_code in varchar2,
                             par_sap_material_code in varchar2);

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
      mfjpln_truncate.truncate_table('pld_sal_format0400');
      mfjpln_truncate.truncate_table('pld_sal_format0401');
      mfjpln_truncate.truncate_table('pld_sal_format0402');
      commit;

      /**/
      /* Extract the control data */
      /**/
      exe_control_data;
      commit;

      /**/
      /* Extract the sales data */
      /**/
      exe_sales_data;
      commit;

      /**/
      /* Extract the forecast data */
      /**/
      exe_forecast_data;
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
   procedure exe_control_data is

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
      /* **NOTE** based on previous day */
      /*-*/
      mfjpln_control.main(sysdate-1,
                          true,
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
      insert into pld_sal_format0400
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
   end exe_control_data;

   /**************************************************/
   /* This procedure performs the sales data routine */
   /**************************************************/
   procedure exe_sales_data is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_current_YYYYPP number(6,0);
      var_start_YYYYPP number(6,0);
      var_end_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_start_YYYYMM number(6,0);
      var_end_YYYYMM number(6,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor sales_period_01_fact_c01 is 
         select t01.sap_hier_cust_code,
                t01.sap_sales_org_code,
                t01.sap_distbn_chnl_code,
                t01.sap_division_code,
                t02.sap_company_code,
                t02.sap_material_code,
                t02.billing_YYYYPP,
                sum(nvl(t02.base_uom_billed_qty, 0)) as billed_qty,
                sum(t02.sales_dtl_price_value_2) as billed_bps
         from cust_partner_funcn2 t01,
              sales_period_01_fact t02
         where t01.sap_ship_to_cust_code = t02.sap_ship_to_cust_code
           and t01.sap_sold_to_cust_code = t02.sap_sold_to_cust_code
           and t01.sap_distbn_chnl_code = t02.sap_sales_dtl_distbn_chnl_code
           and t01.sap_division_code = t02.sap_sales_dtl_division_code
           and t01.sap_sales_org_code = t02.sap_sales_dtl_sales_org_code
           and t02.billing_YYYYPP >= var_start_YYYYPP
           and t02.billing_YYYYPP <= var_end_YYYYPP
           and (nvl(t02.base_uom_billed_qty, 0) <> 0 or
                t02.sales_dtl_price_value_2 <> 0)
         group by t02.sap_company_code,
                  t01.sap_hier_cust_code,
                  t01.sap_sales_org_code,
                  t01.sap_distbn_chnl_code,
                  t01.sap_division_code,
                  t02.sap_material_code,
                  t02.billing_YYYYPP;
      sales_period_01_fact_r01 sales_period_01_fact_c01%rowtype;

      cursor sales_month_01_fact_c01 is 
         select t01.sap_hier_cust_code,
                t01.sap_sales_org_code,
                t01.sap_distbn_chnl_code,
                t01.sap_division_code,
                t02.sap_company_code,
                t02.sap_material_code,
                t02.billing_YYYYMM,
                sum(nvl(t02.base_uom_billed_qty, 0)) as billed_qty,
                sum(t02.sales_dtl_price_value_2) as billed_bps
         from cust_partner_funcn2 t01,
              sales_month_01_fact t02
         where t01.sap_ship_to_cust_code = t02.sap_ship_to_cust_code
           and t01.sap_sold_to_cust_code = t02.sap_sold_to_cust_code
           and t01.sap_distbn_chnl_code = t02.sap_sales_dtl_distbn_chnl_code
           and t01.sap_division_code = t02.sap_sales_dtl_division_code
           and t01.sap_sales_org_code = t02.sap_sales_dtl_sales_org_code
           and t02.billing_YYYYMM >= var_start_YYYYMM
           and t02.billing_YYYYMM <= var_end_YYYYMM
           and (nvl(t02.base_uom_billed_qty, 0) <> 0 or
                t02.sales_dtl_price_value_2 <> 0)
         group by t02.sap_company_code,
                  t01.sap_hier_cust_code,
                  t01.sap_sales_org_code,
                  t01.sap_distbn_chnl_code,
                  t01.sap_division_code,
                  t02.sap_material_code,
                  t02.billing_YYYYMM;
      sales_month_01_fact_r01 sales_month_01_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current date, period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_sal_format0400;
      select current_YYYYMM into var_current_YYYYMM from pld_sal_format0400;

      /*-*/
      /* Extract the period sales value (Current and YTD) */
      /*-*/
      var_start_YYYYPP := mfjpln_control.previousPeriodStart(var_current_YYYYPP, false);
      var_end_YYYYPP := var_current_YYYYPP;
      open sales_period_01_fact_c01;
      loop
         fetch sales_period_01_fact_c01 into sales_period_01_fact_r01;
         if sales_period_01_fact_c01%notfound then
            exit;
         end if;
         createPeriodData(sales_period_01_fact_r01.sap_company_code,
                          sales_period_01_fact_r01.sap_hier_cust_code,
                          sales_period_01_fact_r01.sap_sales_org_code,
                          sales_period_01_fact_r01.sap_distbn_chnl_code,
                          sales_period_01_fact_r01.sap_division_code,
                          sales_period_01_fact_r01.sap_material_code);
         if sales_period_01_fact_r01.billing_YYYYPP = var_current_YYYYPP then
            update pld_sal_format0401
               set cur_billed_qty = sales_period_01_fact_r01.billed_qty,
                   cur_billed_bps = sales_period_01_fact_r01.billed_bps
               where sap_company_code = sales_period_01_fact_r01.sap_company_code
                 and sap_hier_cust_code = sales_period_01_fact_r01.sap_hier_cust_code
                 and sap_sales_org_code = sales_period_01_fact_r01.sap_sales_org_code
                 and sap_distbn_chnl_code = sales_period_01_fact_r01.sap_distbn_chnl_code
                 and sap_division_code = sales_period_01_fact_r01.sap_division_code
                 and sap_material_code = sales_period_01_fact_r01.sap_material_code;
         else
            update pld_sal_format0401
               set ytd_billed_qty = ytd_billed_qty + sales_period_01_fact_r01.billed_qty,
                   ytd_billed_bps = ytd_billed_bps + sales_period_01_fact_r01.billed_bps
               where sap_company_code = sales_period_01_fact_r01.sap_company_code
                 and sap_hier_cust_code = sales_period_01_fact_r01.sap_hier_cust_code
                 and sap_sales_org_code = sales_period_01_fact_r01.sap_sales_org_code
                 and sap_distbn_chnl_code = sales_period_01_fact_r01.sap_distbn_chnl_code
                 and sap_division_code = sales_period_01_fact_r01.sap_division_code
                 and sap_material_code = sales_period_01_fact_r01.sap_material_code;
         end if;
      end loop;
      close sales_period_01_fact_c01;

      /*-*/
      /* Extract the month sales value (Current and YTD) */
      /*-*/
      var_start_YYYYMM := mfjpln_control.previousMonthStart(var_current_YYYYMM, false);
      var_end_YYYYMM := var_current_YYYYMM;
      open sales_month_01_fact_c01;
      loop
         fetch sales_month_01_fact_c01 into sales_month_01_fact_r01;
         if sales_month_01_fact_c01%notfound then
            exit;
         end if;
         createMonthData(sales_month_01_fact_r01.sap_company_code,
                         sales_month_01_fact_r01.sap_hier_cust_code,
                         sales_month_01_fact_r01.sap_sales_org_code,
                         sales_month_01_fact_r01.sap_distbn_chnl_code,
                         sales_month_01_fact_r01.sap_division_code,
                         sales_month_01_fact_r01.sap_material_code);
         if sales_month_01_fact_r01.billing_YYYYMM = var_current_YYYYMM then
            update pld_sal_format0402
               set cur_billed_qty = sales_month_01_fact_r01.billed_qty,
                   cur_billed_bps = sales_month_01_fact_r01.billed_bps
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_hier_cust_code = sales_month_01_fact_r01.sap_hier_cust_code
                 and sap_sales_org_code = sales_month_01_fact_r01.sap_sales_org_code
                 and sap_distbn_chnl_code = sales_month_01_fact_r01.sap_distbn_chnl_code
                 and sap_division_code = sales_month_01_fact_r01.sap_division_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code;
         else
            update pld_sal_format0402
               set ytd_billed_qty = ytd_billed_qty + sales_month_01_fact_r01.billed_qty,
                   ytd_billed_bps = ytd_billed_bps + sales_month_01_fact_r01.billed_bps
               where sap_company_code = sales_month_01_fact_r01.sap_company_code
                 and sap_hier_cust_code = sales_month_01_fact_r01.sap_hier_cust_code
                 and sap_sales_org_code = sales_month_01_fact_r01.sap_sales_org_code
                 and sap_distbn_chnl_code = sales_month_01_fact_r01.sap_distbn_chnl_code
                 and sap_division_code = sales_month_01_fact_r01.sap_division_code
                 and sap_material_code = sales_month_01_fact_r01.sap_material_code;
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
   procedure exe_forecast_data is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_current_YYYYPP number(6,0);
      var_start_YYYYPP number(6,0);
      var_end_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_start_YYYYMM number(6,0);
      var_end_YYYYMM number(6,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor fcst_period_01_fact_c01 is 
         select t01.sap_sales_div_cust_code,
                t01.sap_sales_div_sales_org_code,
                t01.sap_sales_div_distbn_chnl_code,
                t01.sap_sales_div_division_code,
                t01.sap_sales_dtl_sales_org_code,
                t01.sap_material_code,
                t01.billing_YYYYPP,
                sum(t01.op_qty) as op_qty,
                sum(t01.br_qty) as br_qty,
                sum(t01.le_qty) as le_qty,
                sum(t01.op_base_price_value) as op_bps,
                sum(t01.br_base_price_value) as br_bps,
                sum(t01.le_base_price_value) as le_bps
         from fcst_period_01_fact t01
         where t01.billing_YYYYPP >= var_start_YYYYPP
           and t01.billing_YYYYPP <= var_end_YYYYPP
           and (t01.op_qty <> 0
             or t01.br_qty <> 0
             or t01.le_qty <> 0
             or t01.op_base_price_value <> 0
             or t01.br_base_price_value <> 0
             or t01.le_base_price_value <> 0)
         group by t01.sap_sales_dtl_sales_org_code,
                  t01.sap_sales_div_cust_code,
                  t01.sap_sales_div_sales_org_code,
                  t01.sap_sales_div_distbn_chnl_code,
                  t01.sap_sales_div_division_code,
                  t01.sap_material_code,
                  t01.billing_YYYYPP;
      fcst_period_01_fact_r01 fcst_period_01_fact_c01%rowtype;

      cursor fcst_month_01_fact_c01 is 
         select t01.sap_sales_div_cust_code,
                t01.sap_sales_div_sales_org_code,
                t01.sap_sales_div_distbn_chnl_code,
                t01.sap_sales_div_division_code,
                t01.sap_sales_dtl_sales_org_code,
                t01.sap_material_code,
                t01.billing_YYYYMM,
                sum(t01.op_qty) as op_qty,
                sum(t01.br_qty) as br_qty,
                sum(t01.le_qty) as le_qty,
                sum(t01.op_base_price_value) as op_bps,
                sum(t01.br_base_price_value) as br_bps,
                sum(t01.le_base_price_value) as le_bps
         from fcst_month_01_fact t01
         where t01.billing_YYYYMM >= var_start_YYYYMM
           and t01.billing_YYYYMM <= var_end_YYYYMM
           and (t01.op_qty <> 0
             or t01.br_qty <> 0
             or t01.le_qty <> 0
             or t01.op_base_price_value <> 0
             or t01.br_base_price_value <> 0
             or t01.le_base_price_value <> 0)
         group by t01.sap_sales_dtl_sales_org_code,
                  t01.sap_sales_div_cust_code,
                  t01.sap_sales_div_sales_org_code,
                  t01.sap_sales_div_distbn_chnl_code,
                  t01.sap_sales_div_division_code,
                  t01.sap_material_code,
                  t01.billing_YYYYMM;
      fcst_month_01_fact_r01 fcst_month_01_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_sal_format0400;
      select current_YYYYMM into var_current_YYYYMM from pld_sal_format0400;

      /*-*/
      /* Extract the period forecast values */
      /*-*/
      var_start_YYYYPP := mfjpln_control.previousPeriodStart(var_current_YYYYPP, false);
      var_end_YYYYPP := mfjpln_control.previousPeriodEnd(var_current_YYYYPP, false);
      open fcst_period_01_fact_c01;
      loop
         fetch fcst_period_01_fact_c01 into fcst_period_01_fact_r01;
         if fcst_period_01_fact_c01%notfound then
            exit;
         end if;
         createPeriodData(fcst_period_01_fact_r01.sap_sales_dtl_sales_org_code,
                          fcst_period_01_fact_r01.sap_sales_div_cust_code,
                          fcst_period_01_fact_r01.sap_sales_div_sales_org_code,
                          fcst_period_01_fact_r01.sap_sales_div_distbn_chnl_code,
                          fcst_period_01_fact_r01.sap_sales_div_division_code,
                          fcst_period_01_fact_r01.sap_material_code);
         if fcst_period_01_fact_r01.billing_YYYYPP < var_current_YYYYPP then
            update pld_sal_format0401
               set ytd_op_qty = ytd_op_qty + fcst_period_01_fact_r01.op_qty,
                   ytd_br_qty = ytd_br_qty + fcst_period_01_fact_r01.br_qty,
                   ytd_le_qty = ytd_le_qty + fcst_period_01_fact_r01.le_qty,
                   ytd_op_bps = ytd_op_bps + fcst_period_01_fact_r01.op_bps,
                   ytd_br_bps = ytd_br_bps + fcst_period_01_fact_r01.br_bps,
                   ytd_le_bps = ytd_le_bps + fcst_period_01_fact_r01.le_bps
               where sap_company_code = fcst_period_01_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_hier_cust_code = fcst_period_01_fact_r01.sap_sales_div_cust_code
                 and sap_sales_org_code = fcst_period_01_fact_r01.sap_sales_div_sales_org_code
                 and sap_distbn_chnl_code = fcst_period_01_fact_r01.sap_sales_div_distbn_chnl_code
                 and sap_division_code = fcst_period_01_fact_r01.sap_sales_div_division_code
                 and sap_material_code = fcst_period_01_fact_r01.sap_material_code;
         elsif fcst_period_01_fact_r01.billing_YYYYPP = var_current_YYYYPP then
            update pld_sal_format0401
               set cur_op_qty = fcst_period_01_fact_r01.op_qty,
                   cur_br_qty = fcst_period_01_fact_r01.br_qty,
                   cur_le_qty = fcst_period_01_fact_r01.le_qty,
                   cur_op_bps = fcst_period_01_fact_r01.op_bps,
                   cur_br_bps = fcst_period_01_fact_r01.br_bps,
                   cur_le_bps = fcst_period_01_fact_r01.le_bps,
                   ytg_op_qty = ytg_op_qty + fcst_period_01_fact_r01.op_qty,
                   ytg_br_qty = ytg_br_qty + fcst_period_01_fact_r01.br_qty,
                   ytg_le_qty = ytg_le_qty + fcst_period_01_fact_r01.le_qty,
                   ytg_op_bps = ytg_op_bps + fcst_period_01_fact_r01.op_bps,
                   ytg_br_bps = ytg_br_bps + fcst_period_01_fact_r01.br_bps,
                   ytg_le_bps = ytg_le_bps + fcst_period_01_fact_r01.le_bps
               where sap_company_code = fcst_period_01_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_hier_cust_code = fcst_period_01_fact_r01.sap_sales_div_cust_code
                 and sap_sales_org_code = fcst_period_01_fact_r01.sap_sales_div_sales_org_code
                 and sap_distbn_chnl_code = fcst_period_01_fact_r01.sap_sales_div_distbn_chnl_code
                 and sap_division_code = fcst_period_01_fact_r01.sap_sales_div_division_code
                 and sap_material_code = fcst_period_01_fact_r01.sap_material_code;
         else
            update pld_sal_format0401
               set ytg_op_qty = ytg_op_qty + fcst_period_01_fact_r01.op_qty,
                   ytg_br_qty = ytg_br_qty + fcst_period_01_fact_r01.br_qty,
                   ytg_le_qty = ytg_le_qty + fcst_period_01_fact_r01.le_qty,
                   ytg_op_bps = ytg_op_bps + fcst_period_01_fact_r01.op_bps,
                   ytg_br_bps = ytg_br_bps + fcst_period_01_fact_r01.br_bps,
                   ytg_le_bps = ytg_le_bps + fcst_period_01_fact_r01.le_bps
               where sap_company_code = fcst_period_01_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_hier_cust_code = fcst_period_01_fact_r01.sap_sales_div_cust_code
                 and sap_sales_org_code = fcst_period_01_fact_r01.sap_sales_div_sales_org_code
                 and sap_distbn_chnl_code = fcst_period_01_fact_r01.sap_sales_div_distbn_chnl_code
                 and sap_division_code = fcst_period_01_fact_r01.sap_sales_div_division_code
                 and sap_material_code = fcst_period_01_fact_r01.sap_material_code;
         end if;
      end loop;
      close fcst_period_01_fact_c01;

      /*-*/
      /* Extract the material month forecast values */
      /*-*/
      var_start_YYYYMM := mfjpln_control.previousMonthStart(var_current_YYYYMM, false);
      var_end_YYYYMM := mfjpln_control.previousMonthEnd(var_current_YYYYMM, false);
      open fcst_month_01_fact_c01;
      loop
         fetch fcst_month_01_fact_c01 into fcst_month_01_fact_r01;
         if fcst_month_01_fact_c01%notfound then
            exit;
         end if;
         createMonthData(fcst_month_01_fact_r01.sap_sales_dtl_sales_org_code,
                         fcst_month_01_fact_r01.sap_sales_div_cust_code,
                         fcst_month_01_fact_r01.sap_sales_div_sales_org_code,
                         fcst_month_01_fact_r01.sap_sales_div_distbn_chnl_code,
                         fcst_month_01_fact_r01.sap_sales_div_division_code,
                         fcst_month_01_fact_r01.sap_material_code);
         if fcst_month_01_fact_r01.billing_YYYYMM < var_current_YYYYMM then
            update pld_sal_format0402
               set ytd_op_qty = ytd_op_qty + fcst_month_01_fact_r01.op_qty,
                   ytd_br_qty = ytd_br_qty + fcst_month_01_fact_r01.br_qty,
                   ytd_le_qty = ytd_le_qty + fcst_month_01_fact_r01.le_qty,
                   ytd_op_bps = ytd_op_bps + fcst_month_01_fact_r01.op_bps,
                   ytd_br_bps = ytd_br_bps + fcst_month_01_fact_r01.br_bps,
                   ytd_le_bps = ytd_le_bps + fcst_month_01_fact_r01.le_bps
               where sap_company_code = fcst_month_01_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_hier_cust_code = fcst_month_01_fact_r01.sap_sales_div_cust_code
                 and sap_sales_org_code = fcst_month_01_fact_r01.sap_sales_div_sales_org_code
                 and sap_distbn_chnl_code = fcst_month_01_fact_r01.sap_sales_div_distbn_chnl_code
                 and sap_division_code = fcst_month_01_fact_r01.sap_sales_div_division_code
                 and sap_material_code = fcst_month_01_fact_r01.sap_material_code;
         elsif fcst_month_01_fact_r01.billing_YYYYMM = var_current_YYYYMM then
            update pld_sal_format0402
               set cur_op_qty = fcst_month_01_fact_r01.op_qty,
                   cur_br_qty = fcst_month_01_fact_r01.br_qty,
                   cur_le_qty = fcst_month_01_fact_r01.le_qty,
                   cur_op_bps = fcst_month_01_fact_r01.op_bps,
                   cur_br_bps = fcst_month_01_fact_r01.br_bps,
                   cur_le_bps = fcst_month_01_fact_r01.le_bps,
                   ytg_op_qty = ytg_op_qty + fcst_month_01_fact_r01.op_qty,
                   ytg_br_qty = ytg_br_qty + fcst_month_01_fact_r01.br_qty,
                   ytg_le_qty = ytg_le_qty + fcst_month_01_fact_r01.le_qty,
                   ytg_op_bps = ytg_op_bps + fcst_month_01_fact_r01.op_bps,
                   ytg_br_bps = ytg_br_bps + fcst_month_01_fact_r01.br_bps,
                   ytg_le_bps = ytg_le_bps + fcst_month_01_fact_r01.le_bps
               where sap_company_code = fcst_month_01_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_hier_cust_code = fcst_month_01_fact_r01.sap_sales_div_cust_code
                 and sap_sales_org_code = fcst_month_01_fact_r01.sap_sales_div_sales_org_code
                 and sap_distbn_chnl_code = fcst_month_01_fact_r01.sap_sales_div_distbn_chnl_code
                 and sap_division_code = fcst_month_01_fact_r01.sap_sales_div_division_code
                 and sap_material_code = fcst_month_01_fact_r01.sap_material_code;
         else
            update pld_sal_format0402
               set ytg_op_qty = ytg_op_qty + fcst_month_01_fact_r01.op_qty,
                   ytg_br_qty = ytg_br_qty + fcst_month_01_fact_r01.br_qty,
                   ytg_le_qty = ytg_le_qty + fcst_month_01_fact_r01.le_qty,
                   ytg_op_bps = ytg_op_bps + fcst_month_01_fact_r01.op_bps,
                   ytg_br_bps = ytg_br_bps + fcst_month_01_fact_r01.br_bps,
                   ytg_le_bps = ytg_le_bps + fcst_month_01_fact_r01.le_bps
               where sap_company_code = fcst_month_01_fact_r01.sap_sales_dtl_sales_org_code
                 and sap_hier_cust_code = fcst_month_01_fact_r01.sap_sales_div_cust_code
                 and sap_sales_org_code = fcst_month_01_fact_r01.sap_sales_div_sales_org_code
                 and sap_distbn_chnl_code = fcst_month_01_fact_r01.sap_sales_div_distbn_chnl_code
                 and sap_division_code = fcst_month_01_fact_r01.sap_sales_div_division_code
                 and sap_material_code = fcst_month_01_fact_r01.sap_material_code;
         end if;
      end loop;
      close fcst_month_01_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_forecast_data;

   /**********************************************************/
   /* This procedure performs the create period data routine */
   /**********************************************************/
   procedure createPeriodData(par_sap_company_code in varchar2,
                              par_sap_hier_cust_code in varchar2,
                              par_sap_sales_org_code in varchar2,
                              par_sap_distbn_chnl_code in varchar2,
                              par_sap_division_code in varchar2,
                              par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_sal_format0401_c01 is 
         select 'x'
         from pld_sal_format0401
         where pld_sal_format0401.sap_company_code = par_sap_company_code
           and pld_sal_format0401.sap_hier_cust_code = par_sap_hier_cust_code
           and pld_sal_format0401.sap_sales_org_code = par_sap_sales_org_code
           and pld_sal_format0401.sap_distbn_chnl_code = par_sap_distbn_chnl_code
           and pld_sal_format0401.sap_division_code = par_sap_division_code
           and pld_sal_format0401.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new period data row when required */
      /*-*/
      open pld_sal_format0401_c01;
      fetch pld_sal_format0401_c01 into var_work;
      if pld_sal_format0401_c01%notfound then
         insert into pld_sal_format0401
            (sap_company_code,
             sap_hier_cust_code,
             sap_sales_org_code,
             sap_distbn_chnl_code,
             sap_division_code,
             sap_material_code,
             cur_billed_qty,
             cur_billed_bps,
             cur_op_qty,
             cur_br_qty,
             cur_le_qty,
             cur_op_bps,
             cur_br_bps,
             cur_le_bps,
             ytd_billed_qty,
             ytd_billed_bps,
             ytd_op_qty,
             ytd_br_qty,
             ytd_le_qty,
             ytd_op_bps,
             ytd_br_bps,
             ytd_le_bps,
             ytg_op_qty,
             ytg_br_qty,
             ytg_le_qty,
             ytg_op_bps,
             ytg_br_bps,
             ytg_le_bps)
         values
            (par_sap_company_code,
             par_sap_hier_cust_code,
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
      close pld_sal_format0401_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createPeriodData;

   /*********************************************************/
   /* This procedure performs the create month data routine */
   /*********************************************************/
   procedure createMonthData(par_sap_company_code in varchar2,
                             par_sap_hier_cust_code in varchar2,
                             par_sap_sales_org_code in varchar2,
                             par_sap_distbn_chnl_code in varchar2,
                             par_sap_division_code in varchar2,
                             par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_sal_format0402_c01 is 
         select 'x'
         from pld_sal_format0402
         where pld_sal_format0402.sap_company_code = par_sap_company_code
           and pld_sal_format0402.sap_hier_cust_code = par_sap_hier_cust_code
           and pld_sal_format0402.sap_sales_org_code = par_sap_sales_org_code
           and pld_sal_format0402.sap_distbn_chnl_code = par_sap_distbn_chnl_code
           and pld_sal_format0402.sap_division_code = par_sap_division_code
           and pld_sal_format0402.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new month data row when required */
      /*-*/
      open pld_sal_format0402_c01;
      fetch pld_sal_format0402_c01 into var_work;
      if pld_sal_format0402_c01%notfound then
         insert into pld_sal_format0402
            (sap_company_code,
             sap_hier_cust_code,
             sap_sales_org_code,
             sap_distbn_chnl_code,
             sap_division_code,
             sap_material_code,
             cur_billed_qty,
             cur_billed_bps,
             cur_op_qty,
             cur_br_qty,
             cur_le_qty,
             cur_op_bps,
             cur_br_bps,
             cur_le_bps,
             ytd_billed_qty,
             ytd_billed_bps,
             ytd_op_qty,
             ytd_br_qty,
             ytd_le_qty,
             ytd_op_bps,
             ytd_br_bps,
             ytd_le_bps,
             ytg_op_qty,
             ytg_br_qty,
             ytg_le_qty,
             ytg_op_bps,
             ytg_br_bps,
             ytg_le_bps)
         values
            (par_sap_company_code,
             par_sap_hier_cust_code,
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
      close pld_sal_format0402_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createMonthData;

end mfjpln_sal_format04_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_sal_format04_extract for pld_rep_app.mfjpln_sal_format04_extract;
grant execute on mfjpln_sal_format04_extract to public;