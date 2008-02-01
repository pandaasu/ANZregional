/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Package : hk_sal_format11_extract                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_format11_extract as

/**DESCRIPTION**
 Sales Extract Format 11 - Billing date aggregations.
 This package extracts the sales and forecast data from the data warehouse. This
 information is replaced on a daily basis.

 **PARAMETERS**
 none

 **NOTES**
 none

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/03   Steve Gregan   Created
 2006/06   Steve Gregan   Included sales order and invoice type exclusions.
 2007/04   Steve Gregan   Included company parameter.

**/

   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2) return varchar2;

end hk_sal_format11_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_format11_extract as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure exe_control_data(par_sap_company_code in varchar2);
   procedure exe_sales_data(par_sap_company_code in varchar2);
   procedure exe_forecast_data(par_sap_company_code in varchar2);
   procedure exe_create_material(par_sap_company_code in varchar2,
                                 par_sap_material_code in varchar2);

   /*******************************************/
   /* This function performs the main routine */
   /*******************************************/
   function main(par_sap_company_code in varchar2) return varchar2 is

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
      delete from pld_sal_format1100 where sap_company_code = par_sap_company_code;
      delete from pld_sal_format1101 where sap_company_code = par_sap_company_code;
      commit;

      /**/
      /* Extract the control data */
      /**/
      exe_control_data(par_sap_company_code);
      commit;

      /**/
      /* Extract the sales data */
      /**/
      exe_sales_data(par_sap_company_code);
      commit;

      /**/
      /* Extract the forecast data */
      /**/
      exe_forecast_data(par_sap_company_code);
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
   procedure exe_control_data(par_sap_company_code in varchar2) is

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
      mfjpln_control.main(par_sap_company_code,
                          '*BIL',
                          sysdate-1,
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
      insert into pld_sal_format1100
         (sap_company_code,
          extract_date,
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
         values(par_sap_company_code,
                sysdate,
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
   procedure exe_sales_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_logical_date date;
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_sap_company_code varchar2(6 char);
      var_sap_material_code varchar2(18 char);
      var_billed_qty number;
      var_billed_gsv number;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor sales_fact_c01 is 
         select max(sales_fact.sap_company_code),
                max(sales_fact.sap_material_code),
                sum(nvl(sales_fact.base_uom_billed_qty, 0)),
                sum(sales_fact.sales_dtl_price_value_13)
         from sales_fact
         where sales_fact.sap_company_code = par_sap_company_code
           and sales_fact.sap_billing_date >= var_logical_date
           and sales_fact.sap_billing_date < var_logical_date + 1
           and (nvl(sales_fact.base_uom_billed_qty, 0) <> 0 or
                sales_fact.sales_dtl_price_value_13 <> 0)
           and nvl(sales_fact.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(sales_fact.sap_order_type_code,'*NULL')||'/'||nvl(sales_fact.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
           and sales_fact.sap_invc_type_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','INVOICE_TYPE_EXCLUSION')))
         group by sales_fact.sap_company_code,
                  sales_fact.sap_material_code;

      cursor sales_period_03_fact_c01 is 
         select max(sales_period_03_fact.sap_company_code),
                max(sales_period_03_fact.sap_material_code),
                sum(nvl(sales_period_03_fact.base_uom_billed_qty, 0)),
                sum(sales_period_03_fact.sales_dtl_price_value_13)
         from sales_period_03_fact
         where sales_period_03_fact.sap_company_code = par_sap_company_code
           and sales_period_03_fact.sap_billing_YYYYPP = var_current_YYYYPP
           and (nvl(sales_period_03_fact.base_uom_billed_qty, 0) <> 0 or
                sales_period_03_fact.sales_dtl_price_value_13 <> 0)
           and nvl(sales_period_03_fact.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(sales_period_03_fact.sap_order_type_code,'*NULL')||'/'||nvl(sales_period_03_fact.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
           and sales_period_03_fact.sap_invc_type_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','INVOICE_TYPE_EXCLUSION')))
         group by sales_period_03_fact.sap_company_code,
                  sales_period_03_fact.sap_material_code;

      cursor sales_month_04_fact_c01 is 
         select max(sales_month_04_fact.sap_company_code),
                max(sales_month_04_fact.sap_material_code),
                sum(nvl(sales_month_04_fact.base_uom_billed_qty, 0)),
                sum(sales_month_04_fact.sales_dtl_price_value_13)
         from sales_month_04_fact
         where sales_month_04_fact.sap_company_code = par_sap_company_code
           and sales_month_04_fact.sap_billing_YYYYMM = var_current_YYYYMM
           and (nvl(sales_month_04_fact.base_uom_billed_qty, 0) <> 0 or
                sales_month_04_fact.sales_dtl_price_value_13 <> 0)
           and nvl(sales_month_04_fact.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(sales_month_04_fact.sap_order_type_code,'*NULL')||'/'||nvl(sales_month_04_fact.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
           and sales_month_04_fact.sap_invc_type_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','INVOICE_TYPE_EXCLUSION')))
         group by sales_month_04_fact.sap_company_code,
                  sales_month_04_fact.sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current date, period and month variables */
      /*-*/
      select trunc(logical_date) into var_logical_date from pld_sal_format1100 where sap_company_code = par_sap_company_code;
      select current_YYYYPP into var_current_YYYYPP from pld_sal_format1100 where sap_company_code = par_sap_company_code;
      select current_YYYYMM into var_current_YYYYMM from pld_sal_format1100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the material daily sales value */
      /*-*/
      open sales_fact_c01;
      loop
         fetch sales_fact_c01 into var_sap_company_code,
                                   var_sap_material_code,
                                   var_billed_qty,
                                   var_billed_gsv;
         if sales_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_company_code, var_sap_material_code);
         update pld_sal_format1101
            set day_billed_qty = var_billed_qty,
                day_billed_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close sales_fact_c01;

      /*-*/
      /* Extract the material period sales value */
      /*-*/
      open sales_period_03_fact_c01;
      loop
         fetch sales_period_03_fact_c01 into var_sap_company_code,
                                             var_sap_material_code,
                                             var_billed_qty,
                                             var_billed_gsv;
         if sales_period_03_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_company_code, var_sap_material_code);
         update pld_sal_format1101
            set prd_billed_qty = var_billed_qty,
                prd_billed_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close sales_period_03_fact_c01;

      /*-*/
      /* Extract the material month sales value */
      /*-*/
      open sales_month_04_fact_c01;
      loop
         fetch sales_month_04_fact_c01 into var_sap_company_code,
                                            var_sap_material_code,
                                            var_billed_qty,
                                            var_billed_gsv;
         if sales_month_04_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_company_code, var_sap_material_code);
         update pld_sal_format1101
            set mth_billed_qty = var_billed_qty,
                mth_billed_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close sales_month_04_fact_c01;

      /*-*/
      /* Extract the material same period last year sales value */
      /*-*/
      var_current_YYYYPP := var_current_YYYYPP - 100;
      open sales_period_03_fact_c01;
      loop
         fetch sales_period_03_fact_c01 into var_sap_company_code,
                                             var_sap_material_code,
                                             var_billed_qty,
                                             var_billed_gsv;
         if sales_period_03_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_company_code, var_sap_material_code);
         update pld_sal_format1101
            set prd_sply_qty = var_billed_qty,
                prd_sply_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close sales_period_03_fact_c01;

      /*-*/
      /* Extract the material same month last year sales value */
      /*-*/
      var_current_YYYYMM := var_current_YYYYMM - 100;
      open sales_month_04_fact_c01;
      loop
         fetch sales_month_04_fact_c01 into var_sap_company_code,
                                            var_sap_material_code,
                                            var_billed_qty,
                                            var_billed_gsv;
         if sales_month_04_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_company_code, var_sap_material_code);
         update pld_sal_format1101
            set mth_smly_qty = var_billed_qty,
                mth_smly_gsv = var_billed_gsv
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close sales_month_04_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_sales_data;

   /*****************************************************/
   /* This procedure performs the forecast data routine */
   /*****************************************************/
   procedure exe_forecast_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_sap_sales_org_code varchar2(4 char);
      var_sap_material_code varchar2(18 char);
      var_op_qty number;
      var_br_qty number;
      var_rb_qty number;
      var_op_gsv number;
      var_br_gsv number;
      var_rb_gsv number;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor fcst_period_02_fact_c01 is 
         select max(fcst_period_02_fact.sap_sales_dtl_sales_org_code),
                max(fcst_period_02_fact.sap_material_code),
                sum(fcst_period_02_fact.op_qty),
                sum(fcst_period_02_fact.br_qty),
                sum(fcst_period_02_fact.rb_qty),
                sum(fcst_period_02_fact.op_gsv_value),
                sum(fcst_period_02_fact.br_gsv_value),
                sum(fcst_period_02_fact.rb_gsv_value)
         from fcst_period_02_fact
         where fcst_period_02_fact.sap_sales_dtl_sales_org_code = par_sap_company_code
           and fcst_period_02_fact.billing_YYYYPP = var_current_YYYYPP
           and (fcst_period_02_fact.op_qty <> 0
             or fcst_period_02_fact.br_qty <> 0
             or fcst_period_02_fact.rb_qty <> 0
             or fcst_period_02_fact.op_gsv_value <> 0
             or fcst_period_02_fact.br_gsv_value <> 0
             or fcst_period_02_fact.rb_gsv_value <> 0)
         group by fcst_period_02_fact.sap_sales_dtl_sales_org_code,
                  fcst_period_02_fact.sap_material_code;

      cursor fcst_month_02_fact_c01 is 
         select max(fcst_month_02_fact.sap_sales_dtl_sales_org_code),
                max(fcst_month_02_fact.sap_material_code),
                sum(fcst_month_02_fact.op_qty),
                sum(fcst_month_02_fact.br_qty),
                sum(fcst_month_02_fact.rb_qty),
                sum(fcst_month_02_fact.op_gsv_value),
                sum(fcst_month_02_fact.br_gsv_value),
                sum(fcst_month_02_fact.rb_gsv_value)
         from fcst_month_02_fact
         where fcst_month_02_fact.sap_sales_dtl_sales_org_code = par_sap_company_code
           and fcst_month_02_fact.billing_YYYYMM = var_current_YYYYMM
           and (fcst_month_02_fact.op_qty <> 0
             or fcst_month_02_fact.br_qty <> 0
             or fcst_month_02_fact.rb_qty <> 0
             or fcst_month_02_fact.op_gsv_value <> 0
             or fcst_month_02_fact.br_gsv_value <> 0
             or fcst_month_02_fact.rb_gsv_value <> 0)
         group by fcst_month_02_fact.sap_sales_dtl_sales_org_code,
                  fcst_month_02_fact.sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_sal_format1100 where sap_company_code = par_sap_company_code;
      select current_YYYYMM into var_current_YYYYMM from pld_sal_format1100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the material period forecast values */
      /*-*/
      open fcst_period_02_fact_c01;
      loop
         fetch fcst_period_02_fact_c01 into var_sap_sales_org_code,
                                            var_sap_material_code,
                                            var_op_qty,
                                            var_br_qty,
                                            var_rb_qty,
                                            var_op_gsv,
                                            var_br_gsv,
                                            var_rb_gsv;
         if fcst_period_02_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_sales_org_code, var_sap_material_code);
         update pld_sal_format1101
            set prd_op_qty = var_op_qty,
                prd_br_qty = var_br_qty,
                prd_rb_qty = var_rb_qty,
                prd_op_gsv = var_op_gsv,
                prd_br_gsv = var_br_gsv,
                prd_rb_gsv = var_rb_gsv
            where sap_company_code = var_sap_sales_org_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close fcst_period_02_fact_c01;

      /*-*/
      /* Extract the material month forecast values */
      /*-*/
      open fcst_month_02_fact_c01;
      loop
         fetch fcst_month_02_fact_c01 into var_sap_sales_org_code,
                                           var_sap_material_code,
                                           var_op_qty,
                                           var_br_qty,
                                           var_rb_qty,
                                           var_op_gsv,
                                           var_br_gsv,
                                           var_rb_gsv;
         if fcst_month_02_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_sales_org_code, var_sap_material_code);
         update pld_sal_format1101
            set mth_op_qty = var_op_qty,
                mth_br_qty = var_br_qty,
                mth_rb_qty = var_rb_qty,
                mth_op_gsv = var_op_gsv,
                mth_br_gsv = var_br_gsv,
                mth_rb_gsv = var_rb_gsv
            where sap_company_code = var_sap_sales_org_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close fcst_month_02_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_forecast_data;

   /*******************************************************/
   /* This procedure performs the create material routine */
   /*******************************************************/
   procedure exe_create_material(par_sap_company_code in varchar2,
                                 par_sap_material_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_work varchar2(1 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_sal_format1101_c01 is 
         select 'x'
         from pld_sal_format1101
         where pld_sal_format1101.sap_company_code = par_sap_company_code
           and pld_sal_format1101.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin    

      /*-*/
      /* Create a new material extract row when required */
      /*-*/
      open pld_sal_format1101_c01;
      fetch pld_sal_format1101_c01 into var_work;
      if pld_sal_format1101_c01%notfound then
         insert into pld_sal_format1101
            (sap_company_code,
             sap_material_code,
             day_billed_qty,
             day_billed_gsv,
             prd_billed_qty,
             prd_billed_gsv,
             prd_sply_qty,
             prd_sply_gsv,
             prd_op_qty,
             prd_op_gsv,
             prd_br_qty,
             prd_br_gsv,
             prd_rb_qty,
             prd_rb_gsv,
             mth_billed_qty,
             mth_billed_gsv,
             mth_smly_qty,
             mth_smly_gsv,
             mth_op_qty,
             mth_op_gsv,
             mth_br_qty,
             mth_br_gsv,
             mth_rb_qty,
             mth_rb_gsv)
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
               0);
      end if;
      close pld_sal_format1101_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_create_material;

end hk_sal_format11_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_format11_extract for pld_rep_app.hk_sal_format11_extract;
grant execute on hk_sal_format11_extract to public;