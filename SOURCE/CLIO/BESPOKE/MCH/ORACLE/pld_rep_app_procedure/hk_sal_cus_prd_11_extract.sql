/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Package : hk_sal_cus_prd_11_extract                          */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : March 2006                                         */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_sal_cus_prd_11_extract as

/**DESCRIPTION**
 Customer PTD period billing date extract.

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

end hk_sal_cus_prd_11_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_sal_cus_prd_11_extract as

   /*-*/
   /* Private global declarations
   /*-*/
   procedure exe_control_data(par_sap_company_code in varchar2);
   procedure exe_order_data(par_sap_company_code in varchar2);
   procedure exe_sales_data(par_sap_company_code in varchar2);
   procedure exe_forecast_data(par_sap_company_code in varchar2);
   procedure createPeriodHeader(par_sap_company_code in varchar2,
                                par_sap_ship_to_cust_code in varchar2,
                                par_sap_sales_org_code in varchar2,
                                par_sap_distbn_chnl_code in varchar2,
                                par_sap_division_code in varchar2,
                                par_sap_material_code in varchar2);

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
      delete from pld_sal_cus_prd_1100 where sap_company_code = par_sap_company_code;
      delete from pld_sal_cus_prd_1101 where sap_company_code = par_sap_company_code;
      commit;

      /**/
      /* Extract the control data
      /**/
      exe_control_data(par_sap_company_code);
      commit;

      /**/
      /* Extract the order data
      /**/
      exe_order_data(par_sap_company_code);
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
      /* **NOTE** based on previous day
      /*-*/
      mfjpln_control.main(par_sap_company_code,
                          '*BIL',
                          sysdate-1,
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
      insert into pld_sal_cus_prd_1100
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
   /* This procedure performs the order data routine */
   /**************************************************/
   procedure exe_order_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor order_fact_c01 is 
         select t01.sap_company_code,
                t01.sap_ship_to_cust_code,
                t01.sap_sales_hdr_sales_org_code,
                t01.sap_sales_hdr_distbn_chnl_code,
                t01.sap_sales_hdr_division_code,
                t01.sap_material_code,
                t01.ord_lin_status,
                sum(nvl(t01.ord_base_uom_qty, 0)) as ord_qty,
                sum(nvl(t01.ord_tonnes_qty, 0)) as ord_ton,
                sum(nvl(t01.ord_gsv, 0)) as ord_gsv,
                sum(nvl(t01.ord_niv, 0)) as ord_niv,
                sum(nvl(t01.del_base_uom_qty, 0)) as del_qty,
                sum(nvl(t01.del_tonnes_qty, 0)) as del_ton,
                sum(nvl(t01.del_gsv, 0)) as del_gsv,
                sum(nvl(t01.del_niv, 0)) as del_niv,
                sum(nvl(t01.pod_base_uom_qty, 0)) as pod_qty,
                sum(nvl(t01.pod_tonnes_qty, 0)) as pod_ton,
                sum(nvl(t01.pod_gsv, 0)) as pod_gsv,
                sum(nvl(t01.pod_niv, 0)) as pod_niv
         from order_fact t01
         where t01.sap_company_code = par_sap_company_code
           and t01.ord_lin_status in ('*ORD','*DEL','*POD')
           and (nvl(t01.ord_base_uom_qty, 0) <> 0 or
                nvl(t01.ord_gsv, 0) <> 0 or
                nvl(t01.ord_niv, 0) <> 0 or
                nvl(t01.del_base_uom_qty, 0) <> 0 or
                nvl(t01.del_gsv, 0) <> 0 or
                nvl(t01.del_niv, 0) <> 0 or
                nvl(t01.pod_base_uom_qty, 0) <> 0 or
                nvl(t01.pod_gsv, 0) <> 0 or
                nvl(t01.pod_niv, 0) <> 0)
           and nvl(t01.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(t01.sap_order_type_code,'*NULL')||'/'||nvl(t01.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
         group by t01.sap_company_code,
                  t01.sap_ship_to_cust_code,
                  t01.sap_sales_hdr_sales_org_code,
                  t01.sap_sales_hdr_distbn_chnl_code,
                  t01.sap_sales_hdr_division_code,
                  t01.sap_material_code,
                  t01.ord_lin_status;
      order_fact_r01 order_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Extract the order values
      /*-*/
      open order_fact_c01;
      loop
         fetch order_fact_c01 into order_fact_r01;
         if order_fact_c01%notfound then
            exit;
         end if;

         createPeriodHeader(order_fact_r01.sap_company_code,
                            order_fact_r01.sap_ship_to_cust_code,
                            order_fact_r01.sap_sales_hdr_sales_org_code,
                            order_fact_r01.sap_sales_hdr_distbn_chnl_code,
                            order_fact_r01.sap_sales_hdr_division_code,
                            order_fact_r01.sap_material_code);
         if order_fact_r01.ord_lin_status = '*ORD' then
            update pld_sal_cus_prd_1101
               set ord_uc_qty = ord_uc_qty + order_fact_r01.ord_qty,
                   ord_uc_ton = ord_uc_ton + order_fact_r01.ord_ton,
                   ord_uc_gsv = ord_uc_gsv + order_fact_r01.ord_gsv,
                   ord_uc_niv = ord_uc_niv + order_fact_r01.ord_niv
               where sap_company_code = order_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = order_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = order_fact_r01.sap_sales_hdr_sales_org_code
                 and sap_distbn_chnl_code = order_fact_r01.sap_sales_hdr_distbn_chnl_code
                 and sap_division_code = order_fact_r01.sap_sales_hdr_division_code
                 and sap_material_code = order_fact_r01.sap_material_code;
         elsif order_fact_r01.ord_lin_status = '*DEL' then
            update pld_sal_cus_prd_1101
               set ord_cn_qty = ord_cn_qty + order_fact_r01.del_qty,
                   ord_cn_ton = ord_cn_ton + order_fact_r01.del_ton,
                   ord_cn_gsv = ord_cn_gsv + order_fact_r01.del_gsv,
                   ord_cn_niv = ord_cn_niv + order_fact_r01.del_niv
               where sap_company_code = order_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = order_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = order_fact_r01.sap_sales_hdr_sales_org_code
                 and sap_distbn_chnl_code = order_fact_r01.sap_sales_hdr_distbn_chnl_code
                 and sap_division_code = order_fact_r01.sap_sales_hdr_division_code
                 and sap_material_code = order_fact_r01.sap_material_code;
         elsif order_fact_r01.ord_lin_status = '*POD' then
            update pld_sal_cus_prd_1101
               set ord_cn_qty = ord_cn_qty + order_fact_r01.pod_qty,
                   ord_cn_ton = ord_cn_ton + order_fact_r01.pod_ton,
                   ord_cn_gsv = ord_cn_gsv + order_fact_r01.pod_gsv,
                   ord_cn_niv = ord_cn_niv + order_fact_r01.pod_niv
               where sap_company_code = order_fact_r01.sap_company_code
                 and sap_ship_to_cust_code = order_fact_r01.sap_ship_to_cust_code
                 and sap_sales_org_code = order_fact_r01.sap_sales_hdr_sales_org_code
                 and sap_distbn_chnl_code = order_fact_r01.sap_sales_hdr_distbn_chnl_code
                 and sap_division_code = order_fact_r01.sap_sales_hdr_division_code
                 and sap_material_code = order_fact_r01.sap_material_code;
         end if;

      end loop;
      close order_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_order_data;

   /**************************************************/
   /* This procedure performs the sales data routine */
   /**************************************************/
   procedure exe_sales_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_logical_date date;
      var_current_yyyypp number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor sales_fact_c01 is 
         select t01.sap_company_code,
                t01.sap_ship_to_cust_code,
                t01.sap_sales_dtl_sales_org_code,
                t01.sap_sales_dtl_distbn_chnl_code,
                t01.sap_sales_dtl_division_code,
                t01.sap_material_code,
                sum(nvl(t01.base_uom_billed_qty, 0)) as billed_qty,
                sum(nvl(t01.tonnes_billed_qty, 0)) as billed_ton,
                sum(nvl(t01.sales_dtl_price_value_13, 0)) as billed_gsv,
                sum(nvl(t01.sales_dtl_price_value_17, 0)) as billed_niv
         from sales_fact t01
         where t01.sap_company_code = par_sap_company_code
           and t01.sap_billing_date >= var_logical_date
           and t01.sap_billing_date < var_logical_date + 1
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
                  t01.sap_material_code;
      sales_fact_r01 sales_fact_c01%rowtype;

      cursor sales_period_03_fact_c01 is 
         select t01.sap_company_code,
                t01.sap_ship_to_cust_code,
                t01.sap_sales_dtl_sales_org_code,
                t01.sap_sales_dtl_distbn_chnl_code,
                t01.sap_sales_dtl_division_code,
                t01.sap_material_code,
                sum(nvl(t01.base_uom_billed_qty, 0)) as billed_qty,
                sum(nvl(t01.tonnes_billed_qty, 0)) as billed_ton,
                sum(nvl(t01.sales_dtl_price_value_13, 0)) as billed_gsv,
                sum(nvl(t01.sales_dtl_price_value_17, 0)) as billed_niv
         from sales_period_03_fact t01
         where t01.sap_company_code = par_sap_company_code
           and t01.sap_billing_yyyypp = var_current_yyyypp
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
                  t01.sap_material_code;
      sales_period_03_fact_r01 sales_period_03_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current date and period variables
      /*-*/
      select trunc(logical_date) into var_logical_date from pld_sal_cus_prd_1100 where sap_company_code = par_sap_company_code;
      select current_yyyypp into var_current_yyyypp from pld_sal_cus_prd_1100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the daily sales values
      /*-*/
      open sales_fact_c01;
      loop
         fetch sales_fact_c01 into sales_fact_r01;
         if sales_fact_c01%notfound then
            exit;
         end if;
         createPeriodHeader(sales_fact_r01.sap_company_code,
                            sales_fact_r01.sap_ship_to_cust_code,
                            sales_fact_r01.sap_sales_dtl_sales_org_code,
                            sales_fact_r01.sap_sales_dtl_distbn_chnl_code,
                            sales_fact_r01.sap_sales_dtl_division_code,
                            sales_fact_r01.sap_material_code);
         update pld_sal_cus_prd_1101
            set cur_dy_qty = sales_fact_r01.billed_qty,
                cur_dy_ton = sales_fact_r01.billed_ton,
                cur_dy_gsv = sales_fact_r01.billed_gsv,
                cur_dy_niv = sales_fact_r01.billed_niv
            where sap_company_code = sales_fact_r01.sap_company_code
              and sap_ship_to_cust_code = sales_fact_r01.sap_ship_to_cust_code
              and sap_sales_org_code = sales_fact_r01.sap_sales_dtl_sales_org_code
              and sap_distbn_chnl_code = sales_fact_r01.sap_sales_dtl_distbn_chnl_code
              and sap_division_code = sales_fact_r01.sap_sales_dtl_division_code
              and sap_material_code = sales_fact_r01.sap_material_code;
      end loop;
      close sales_fact_c01;

      /*-*/
      /* Extract the period sales values - current period
      /*-*/
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
         update pld_sal_cus_prd_1101
            set cur_ty_qty = sales_period_03_fact_r01.billed_qty,
                cur_ty_ton = sales_period_03_fact_r01.billed_ton,
                cur_ty_gsv = sales_period_03_fact_r01.billed_gsv,
                cur_ty_niv = sales_period_03_fact_r01.billed_niv
            where sap_company_code = sales_period_03_fact_r01.sap_company_code
              and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
              and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
              and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
              and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
              and sap_material_code = sales_period_03_fact_r01.sap_material_code; 
      end loop;
      close sales_period_03_fact_c01;

      /*-*/
      /* Extract the period sales values - last year
      /*-*/
      var_current_yyyypp := var_current_yyyypp - 100;
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
         update pld_sal_cus_prd_1101
            set cur_ly_qty = sales_period_03_fact_r01.billed_qty,
                cur_ly_ton = sales_period_03_fact_r01.billed_ton,
                cur_ly_gsv = sales_period_03_fact_r01.billed_gsv,
                cur_ly_niv = sales_period_03_fact_r01.billed_niv
            where sap_company_code = sales_period_03_fact_r01.sap_company_code
              and sap_ship_to_cust_code = sales_period_03_fact_r01.sap_ship_to_cust_code
              and sap_sales_org_code = sales_period_03_fact_r01.sap_sales_dtl_sales_org_code
              and sap_distbn_chnl_code = sales_period_03_fact_r01.sap_sales_dtl_distbn_chnl_code
              and sap_division_code = sales_period_03_fact_r01.sap_sales_dtl_division_code
              and sap_material_code = sales_period_03_fact_r01.sap_material_code;
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
                sum(t01.op_qty) as op_qty,
                sum(t01.br_qty) as br_qty,
                sum(t01.rb_qty) as rb_qty,
                round(sum(decode(t02.sap_wgt_unit_code,
                                 'G', t02.net_wgt/1000000,
                                 'GRM', t02.net_wgt/1000000,
                                 'KG', t02.net_wgt/1000,
                                 'KGM', t02.net_wgt/1000,
                                 'TO', t02.net_wgt/1,
                                 'TON', t02.net_wgt/1,
                                 0) * t01.op_qty),6) as op_ton,
                round(sum(decode(t02.sap_wgt_unit_code,
                                 'G', t02.net_wgt/1000000,
                                 'GRM', t02.net_wgt/1000000,
                                 'KG', t02.net_wgt/1000,
                                 'KGM', t02.net_wgt/1000,
                                 'TO', t02.net_wgt/1,
                                 'TON', t02.net_wgt/1,
                                 0) * t01.br_qty),6) as br_ton,
                round(sum(decode(t02.sap_wgt_unit_code,
                                 'G', t02.net_wgt/1000000,
                                 'GRM', t02.net_wgt/1000000,
                                 'KG', t02.net_wgt/1000,
                                 'KGM', t02.net_wgt/1000,
                                 'TO', t02.net_wgt/1,
                                 'TON', t02.net_wgt/1,
                                 0) * t01.rb_qty),6) as rb_ton,
                sum(t01.op_gsv_value) as op_gsv,
                sum(t01.br_gsv_value) as br_gsv,
                sum(t01.rb_gsv_value) as rb_gsv
         from fcst_period_01_fact t01, material_dim t02
         where t01.sap_material_code = t02.sap_material_code(+)
           and t01.sap_sales_dtl_sales_org_code = par_sap_company_code
           and t01.billing_yyyypp = var_current_yyyypp
           and (t01.op_qty <> 0 or
                t01.br_qty <> 0 or
                t01.rb_qty <> 0 or
                t01.op_gsv_value <> 0 or
                t01.br_gsv_value <> 0 or
                t01.rb_gsv_value <> 0)
         group by t01.sap_sales_dtl_sales_org_code,
                  t01.sap_sales_div_cust_code,
                  t01.sap_sales_div_sales_org_code,
                  t01.sap_sales_div_distbn_chnl_code,
                  t01.sap_sales_div_division_code,
                  t01.sap_material_code;
      fcst_period_01_fact_r01 fcst_period_01_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period variable
      /*-*/
      select current_yyyypp into var_current_yyyypp from pld_sal_cus_prd_1100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the period forecast values - this year
      /*-*/
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
         update pld_sal_cus_prd_1101
            set cur_op_qty = fcst_period_01_fact_r01.op_qty,
                cur_op_ton = fcst_period_01_fact_r01.op_ton,
                cur_op_gsv = fcst_period_01_fact_r01.op_gsv,
                cur_op_niv = 0,
                cur_br_qty = fcst_period_01_fact_r01.br_qty,
                cur_br_ton = fcst_period_01_fact_r01.br_ton,
                cur_br_gsv = fcst_period_01_fact_r01.br_gsv,
                cur_br_niv = 0,
                cur_rb_qty = fcst_period_01_fact_r01.rb_qty,
                cur_rb_ton = fcst_period_01_fact_r01.rb_ton,
                cur_rb_gsv = fcst_period_01_fact_r01.rb_gsv,
                cur_rb_niv = 0
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
      cursor pld_sal_cus_prd_1101_c01 is 
         select 'x'
         from pld_sal_cus_prd_1101
         where pld_sal_cus_prd_1101.sap_company_code = par_sap_company_code
           and pld_sal_cus_prd_1101.sap_ship_to_cust_code = par_sap_ship_to_cust_code
           and pld_sal_cus_prd_1101.sap_sales_org_code = par_sap_sales_org_code
           and pld_sal_cus_prd_1101.sap_distbn_chnl_code = par_sap_distbn_chnl_code
           and pld_sal_cus_prd_1101.sap_division_code = par_sap_division_code
           and pld_sal_cus_prd_1101.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new period data row when required
      /*-*/
      open pld_sal_cus_prd_1101_c01;
      fetch pld_sal_cus_prd_1101_c01 into var_work;
      if pld_sal_cus_prd_1101_c01%notfound then
         insert into pld_sal_cus_prd_1101
            (sap_company_code,
             sap_ship_to_cust_code,
             sap_sales_org_code,
             sap_distbn_chnl_code,
             sap_division_code,
             sap_material_code,
             ord_uc_qty,
             ord_uc_ton,
             ord_uc_gsv,
             ord_uc_niv,
             ord_cn_qty,
             ord_cn_ton,
             ord_cn_gsv,
             ord_cn_niv,
             cur_dy_qty,
             cur_dy_ton,
             cur_dy_gsv,
             cur_dy_niv,
             cur_ty_qty,
             cur_ty_ton,
             cur_ty_gsv,
             cur_ty_niv,
             cur_ly_qty,
             cur_ly_ton,
             cur_ly_gsv,
             cur_ly_niv,
             cur_op_qty,
             cur_op_ton,
             cur_op_gsv,
             cur_op_niv,
             cur_br_qty,
             cur_br_ton,
             cur_br_gsv,
             cur_br_niv,
             cur_rb_qty,
             cur_rb_ton,
             cur_rb_gsv,
             cur_rb_niv)
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
      close pld_sal_cus_prd_1101_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end createPeriodHeader;

end hk_sal_cus_prd_11_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_sal_cus_prd_11_extract for pld_rep_app.hk_sal_cus_prd_11_extract;
grant execute on hk_sal_cus_prd_11_extract to public;