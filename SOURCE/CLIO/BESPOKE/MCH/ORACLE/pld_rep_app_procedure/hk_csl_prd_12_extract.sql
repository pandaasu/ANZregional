/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Sales Reporting                                 */
/* Package : hk_csl_prd_12_extract                              */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : May 2006                                           */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_csl_prd_12_extract as

/**DESCRIPTION**
 Customer service level period billing date extract.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/03   Steve Gregan   Created
 2006/08   Steve Gregan   Modified order selection criteria
 2006/08   Steve Gregan   Modified order fill criteria
 2006/08   Steve Gregan   Modified order selection (zero value invoices)
 2006/08   Steve Gregan   Modified POD reason codes
 2006/09   Steve Gregan   Modified order fill criteria (invoice with no POD)
 2006/10   Steve Gregan   Modified order selection criteria (customer exclusion)
 2007/01   Steve Gregan   Included delivery completion rate and on-time rate
 2007/04   Steve Gregan   Included company parameter.

**/

   /*-*/
   /* Public declarations
   /*-*/
   function main(par_sap_company_code in varchar2) return varchar2;

end hk_csl_prd_12_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_csl_prd_12_extract as

   /*-*/
   /* Private global declarations
   /*-*/
   procedure exe_control_data(par_sap_company_code in varchar2);
   procedure exe_case_data(par_sap_company_code in varchar2);
   procedure exe_order_data(par_sap_company_code in varchar2);

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
      delete from pld_csl_prd_1200 where sap_company_code = par_sap_company_code;
      delete from pld_csl_prd_1201 where sap_company_code = par_sap_company_code;
      delete from pld_csl_prd_1202 where sap_company_code = par_sap_company_code;
      commit;

      /**/
      /* Extract the control data
      /**/
      exe_control_data(par_sap_company_code);
      commit;

      /**/
      /* Extract the case data
      /**/
      exe_case_data(par_sap_company_code);
      commit;

      /**/
      /* Extract the order data
      /**/
      exe_order_data(par_sap_company_code);
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
      insert into pld_csl_prd_1200
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

   /*************************************************/
   /* This procedure performs the case data routine */
   /*************************************************/
   procedure exe_case_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_current_yyyypp number(6,0);

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor order_fact_c01 is 
         select t01.sap_company_code as sap_company_code,
                t01.sap_ship_to_cust_code as sap_ship_to_cust_code,
                t01.sap_sales_hdr_sales_org_code as sap_sales_hdr_sales_org_code,
                t01.sap_sales_hdr_distbn_chnl_code as sap_sales_hdr_distbn_chnl_code,
                t01.sap_sales_hdr_division_code as sap_sales_hdr_division_code,
                t01.sap_material_code as sap_material_code,
                sum(t01.ord_qty) as ord_qty,
                sum(t01.del_qty) as del_qty,
                sum(t01.pod_qty) as pod_qty
           from (select t01.sap_company_code as sap_company_code,
                        t01.sap_ship_to_cust_code as sap_ship_to_cust_code,
                        t01.sap_sales_hdr_sales_org_code as sap_sales_hdr_sales_org_code,
                        t01.sap_sales_hdr_distbn_chnl_code as sap_sales_hdr_distbn_chnl_code,
                        t01.sap_sales_hdr_division_code as sap_sales_hdr_division_code,
                        t01.sap_material_code as sap_material_code,
                        nvl(t01.ord_base_uom_qty, 0) as ord_qty,
                        nvl(t01.del_base_uom_qty, 0) as del_qty,
                        nvl(t01.pod_base_uom_qty, 0) as pod_qty
                   from order_fact t01,
                        sales_fact t02
                  where t01.ord_doc_num = t02.sales_doc_num
                    and t01.ord_doc_line_num = t02.sales_doc_line_num
                    and t01.sap_company_code = par_sap_company_code
                    and t01.ord_lin_status in ('*INV')
                    and t01.sap_order_type_code in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_ORDER_TYPE_INVOICE')))
                    and t01.sap_ship_to_cust_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_CUSTOMER_EXCLUSION')))
                    and t02.sap_billing_yyyypp = var_current_yyyypp
                  union all
                 select t01.sap_company_code as sap_company_code,
                        t01.sap_ship_to_cust_code as sap_ship_to_cust_code,
                        t01.sap_sales_hdr_sales_org_code as sap_sales_hdr_sales_org_code,
                        t01.sap_sales_hdr_distbn_chnl_code as sap_sales_hdr_distbn_chnl_code,
                        t01.sap_sales_hdr_division_code as sap_sales_hdr_division_code,
                        t01.sap_material_code as sap_material_code,
                        nvl(t01.ord_base_uom_qty, 0) as ord_qty,
                        nvl(t01.del_base_uom_qty, 0) as del_qty,
                        nvl(t01.pod_base_uom_qty, 0) as pod_qty
                   from order_fact t01
                  where t01.sap_company_code = par_sap_company_code
                    and t01.sap_order_type_code in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_ORDER_TYPE_INVOICE')))
                    and t01.sap_ship_to_cust_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_CUSTOMER_EXCLUSION')))
                    and t01.ord_lin_status in ('*INV')
                    and (not(t01.pod_yyyypp is null) and t01.pod_yyyypp = var_current_yyyypp)
                    and (t01.ord_doc_num, t01.ord_doc_line_num) not in (select sales_doc_num, sales_doc_line_num from sales_fact)
                  union all
                 select t01.sap_company_code as sap_company_code,
                        t01.sap_ship_to_cust_code as sap_ship_to_cust_code,
                        t01.sap_sales_hdr_sales_org_code as sap_sales_hdr_sales_org_code,
                        t01.sap_sales_hdr_distbn_chnl_code as sap_sales_hdr_distbn_chnl_code,
                        t01.sap_sales_hdr_division_code as sap_sales_hdr_division_code,
                        t01.sap_material_code as sap_material_code,
                        nvl(t01.ord_base_uom_qty, 0) as ord_qty,
                        nvl(t01.del_base_uom_qty, 0) as del_qty,
                        nvl(t01.pod_base_uom_qty, 0) as pod_qty
                   from order_fact t01
                  where t01.sap_company_code = par_sap_company_code
                    and t01.sap_order_type_code in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_ORDER_TYPE_POD')))
                    and t01.sap_ship_to_cust_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_CUSTOMER_EXCLUSION')))
                    and (not(t01.pod_yyyypp is null) and t01.pod_yyyypp = var_current_yyyypp)) t01
          group by t01.sap_company_code,
                   t01.sap_ship_to_cust_code,
                   t01.sap_sales_hdr_sales_org_code,
                   t01.sap_sales_hdr_distbn_chnl_code,
                   t01.sap_sales_hdr_division_code,
                   t01.sap_material_code;
      order_fact_r01 order_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period variables
      /*-*/
      select current_yyyypp into var_current_yyyypp from pld_csl_prd_1200 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the order values
      /*-*/
      open order_fact_c01;
      loop
         fetch order_fact_c01 into order_fact_r01;
         if order_fact_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Create the period row
         /*-*/
         insert into pld_csl_prd_1201
            (sap_company_code,
             sap_ship_to_cust_code,
             sap_sales_org_code,
             sap_distbn_chnl_code,
             sap_division_code,
             sap_material_code,
             ord_qty,
             del_qty,
             pod_qty)
         values
            (order_fact_r01.sap_company_code,
             order_fact_r01.sap_ship_to_cust_code,
             order_fact_r01.sap_sales_hdr_sales_org_code,
             order_fact_r01.sap_sales_hdr_distbn_chnl_code,
             order_fact_r01.sap_sales_hdr_division_code,
             order_fact_r01.sap_material_code,
             order_fact_r01.ord_qty,
             order_fact_r01.del_qty,
             order_fact_r01.pod_qty);

      end loop;
      close order_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_case_data;

   /**************************************************/
   /* This procedure performs the order data routine */
   /**************************************************/
   procedure exe_order_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_current_yyyypp number(6,0);
      var_ord_qty number;
      var_del_qty number;
      var_pod_qty number;
      var_ord_fil number;
      var_ord_tim number;
      var_dat_indicator boolean;
      var_tim_indicator boolean;
      var_prm_ord_qty number;
      var_prm_del_qty number;
      var_prm_pod_qty number;
      var_prm_ord_fil number;
      var_prm_ord_tim number;
      var_prm_dat_indicator boolean;
      var_prm_tim_indicator boolean;
      var_fert_indicator number;
      var_zprm_indicator number;
      var_doc_num order_fact.ord_doc_num%type;
      var_company_code order_fact.sap_company_code%type;
      var_ship_to_cust_code order_fact.sap_ship_to_cust_code%type;
      var_sales_org_code order_fact.sap_sales_hdr_sales_org_code%type;
      var_distbn_chnl_code order_fact.sap_sales_hdr_distbn_chnl_code%type;
      var_division_code order_fact.sap_sales_hdr_division_code%type;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor order_fact_c01 is
         select * from
            (select t01.sap_company_code as sap_company_code,
                    t01.sap_ship_to_cust_code as sap_ship_to_cust_code,
                    t01.sap_sales_hdr_sales_org_code as sap_sales_hdr_sales_org_code,
                    t01.sap_sales_hdr_distbn_chnl_code as sap_sales_hdr_distbn_chnl_code,
                    t01.sap_sales_hdr_division_code as sap_sales_hdr_division_code,
                    t01.sap_material_code as sap_material_code,
                    t03.sap_material_type_code as sap_material_type_code,
                    t01.ord_doc_num as ord_doc_num,
                    t01.agr_date as agr_date,
                    t01.del_date as del_date,
                    t01.pod_date as pod_date,
                    t01.pod_refusal as pod_refusal,
                    nvl(t01.ord_base_uom_qty, 0) as ord_qty,
                    nvl(t01.del_base_uom_qty, 0) as del_qty,
                    nvl(t01.pod_base_uom_qty, 0) as pod_qty
               from order_fact t01,
                    sales_fact t02,
                    material_dim t03
              where t01.ord_doc_num = t02.sales_doc_num
                and t01.ord_doc_line_num = t02.sales_doc_line_num
                and t01.sap_material_code = t03.sap_material_code
                and t01.sap_company_code = par_sap_company_code
                and t01.ord_lin_status in ('*INV')
                and t01.sap_order_type_code in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_ORDER_TYPE_INVOICE')))
                and t01.sap_ship_to_cust_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_CUSTOMER_EXCLUSION')))
                and t02.sap_billing_yyyypp = var_current_yyyypp
              union all
             select t01.sap_company_code as sap_company_code,
                    t01.sap_ship_to_cust_code as sap_ship_to_cust_code,
                    t01.sap_sales_hdr_sales_org_code as sap_sales_hdr_sales_org_code,
                    t01.sap_sales_hdr_distbn_chnl_code as sap_sales_hdr_distbn_chnl_code,
                    t01.sap_sales_hdr_division_code as sap_sales_hdr_division_code,
                    t01.sap_material_code as sap_material_code,
                    t02.sap_material_type_code as sap_material_type_code,
                    t01.ord_doc_num as ord_doc_num,
                    t01.agr_date as agr_date,
                    t01.del_date as del_date,
                    t01.pod_date as pod_date,
                    t01.pod_refusal as pod_refusal,
                    nvl(t01.ord_base_uom_qty, 0) as ord_qty,
                    nvl(t01.del_base_uom_qty, 0) as del_qty,
                    nvl(t01.pod_base_uom_qty, 0) as pod_qty
               from order_fact t01,
                    material_dim t02
              where t01.sap_material_code = t02.sap_material_code
                and t01.sap_company_code = par_sap_company_code
                and t01.sap_order_type_code in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_ORDER_TYPE_INVOICE')))
                and t01.sap_ship_to_cust_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_CUSTOMER_EXCLUSION')))
                and t01.ord_lin_status in ('*INV')
                and (not(t01.pod_yyyypp is null) and t01.pod_yyyypp = var_current_yyyypp)
                and (t01.ord_doc_num, t01.ord_doc_line_num) not in (select sales_doc_num, sales_doc_line_num from sales_fact)
              union all
             select t01.sap_company_code as sap_company_code,
                    t01.sap_ship_to_cust_code as sap_ship_to_cust_code,
                    t01.sap_sales_hdr_sales_org_code as sap_sales_hdr_sales_org_code,
                    t01.sap_sales_hdr_distbn_chnl_code as sap_sales_hdr_distbn_chnl_code,
                    t01.sap_sales_hdr_division_code as sap_sales_hdr_division_code,
                    t01.sap_material_code as sap_material_code,
                    t02.sap_material_type_code as sap_material_type_code,
                    t01.ord_doc_num as ord_doc_num,
                    t01.agr_date as agr_date,
                    t01.del_date as del_date,
                    t01.pod_date as pod_date,
                    t01.pod_refusal as pod_refusal,
                    nvl(t01.ord_base_uom_qty, 0) as ord_qty,
                    nvl(t01.del_base_uom_qty, 0) as del_qty,
                    nvl(t01.pod_base_uom_qty, 0) as pod_qty
               from order_fact t01,
                    material_dim t02
              where t01.sap_material_code = t02.sap_material_code
                and t01.sap_company_code = par_sap_company_code
                and t01.sap_order_type_code in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_ORDER_TYPE_POD')))
                and t01.sap_ship_to_cust_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','CSL_CUSTOMER_EXCLUSION')))
                and (not(t01.pod_yyyypp is null) and t01.pod_yyyypp = var_current_yyyypp)) t01
          order by t01.sap_company_code,
                   t01.sap_ship_to_cust_code,
                   t01.sap_sales_hdr_sales_org_code,
                   t01.sap_sales_hdr_distbn_chnl_code,
                   t01.sap_sales_hdr_division_code,
                   t01.ord_doc_num;
      order_fact_r01 order_fact_c01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period variables
      /*-*/
      select current_yyyypp into var_current_yyyypp from pld_csl_prd_1200 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the order values
      /*-*/
      var_doc_num := null;
      open order_fact_c01;
      loop
         fetch order_fact_c01 into order_fact_r01;
         if order_fact_c01%notfound then
            exit;
         end if;

         /*-*/
         /* New order document
         /*-*/
         if var_doc_num is null or var_doc_num != order_fact_r01.ord_doc_num then

            /*-*/
            /* Process previous order document
            /*-*/
            if not(var_doc_num is null) then

               /*-*/
               /* Determine the order fill
               /*-*/
               var_ord_fil := 0;
               if var_fert_indicator = 1 then
                  if var_ord_qty = var_del_qty and 
                     var_del_qty = var_pod_qty and
                     var_dat_indicator = true then
                     var_ord_fil := 1;
                  end if;
               end if;

               /*-*/
               /* Determine the order on-time
               /*-*/
               var_ord_tim := 0;
               if var_fert_indicator = 1 then
                  if var_tim_indicator = true then
                     var_ord_tim := 1;
                  end if;
               end if;

               /*-*/
               /* Determine the promotional order fill
               /*-*/
               var_prm_ord_fil := 0;
               if var_zprm_indicator = 1 then
                  if var_prm_ord_qty = var_prm_del_qty and 
                     var_prm_del_qty = var_prm_pod_qty and
                     var_prm_dat_indicator = true then
                     var_prm_ord_fil := 1;
                  end if;
               end if;

               /*-*/
               /* Determine the promotional order on-time
               /*-*/
               var_prm_ord_tim := 0;
               if var_zprm_indicator = 1 then
                  if var_prm_tim_indicator = true then
                     var_prm_ord_tim := 1;
                  end if;
               end if;
 
               /*-*/
               /* Update/insert the order fill row
               /*-*/
               update pld_csl_prd_1202
                  set ord_tot = ord_tot + var_fert_indicator,
                      ord_fil = ord_fil + var_ord_fil,
                      ord_tim = ord_tim + var_ord_tim,
                      ord_prm_tot = ord_prm_tot + var_zprm_indicator,
                      ord_prm_fil = ord_prm_fil + var_prm_ord_fil,
                      ord_prm_tim = ord_prm_tim + var_prm_ord_tim
                where sap_company_code = var_company_code
                  and sap_ship_to_cust_code = var_ship_to_cust_code
                  and sap_sales_org_code = var_sales_org_code
                  and sap_distbn_chnl_code = var_distbn_chnl_code
                  and sap_division_code = var_division_code;
               if sql%notfound then
                  insert into pld_csl_prd_1202
                     (sap_company_code,
                      sap_ship_to_cust_code,
                      sap_sales_org_code,
                      sap_distbn_chnl_code,
                      sap_division_code,
                      ord_tot,
                      ord_fil,
                      ord_tim,
                      ord_prm_tot,
                      ord_prm_fil,
                      ord_prm_tim)
                  values
                     (var_company_code,
                      var_ship_to_cust_code,
                      var_sales_org_code,
                      var_distbn_chnl_code,
                      var_division_code,
                      var_fert_indicator,
                      var_ord_fil,
                      var_ord_tim,
                      var_zprm_indicator,
                      var_prm_ord_fil,
                      var_prm_ord_tim);
               end if;

            end if;

            /*-*/
            /* Reset the order document
            /*-*/
            var_doc_num := order_fact_r01.ord_doc_num;
            var_company_code := order_fact_r01.sap_company_code;
            var_ship_to_cust_code := order_fact_r01.sap_ship_to_cust_code;
            var_sales_org_code := order_fact_r01.sap_sales_hdr_sales_org_code;
            var_distbn_chnl_code := order_fact_r01.sap_sales_hdr_distbn_chnl_code;
            var_division_code := order_fact_r01.sap_sales_hdr_division_code;
            var_ord_qty := 0;
            var_ord_fil := 0;
            var_ord_tim := 0;
            var_del_qty := 0;
            var_pod_qty := 0;
            var_dat_indicator := true;
            var_tim_indicator := true;
            var_prm_ord_qty := 0;
            var_prm_ord_fil := 0;
            var_prm_ord_tim := 0;
            var_prm_del_qty := 0;
            var_prm_pod_qty := 0;
            var_prm_dat_indicator := true;
            var_prm_tim_indicator := true;
            var_fert_indicator := 0;
            var_zprm_indicator := 0;

         end if;

         /*-*/
         /* Accumulate the order fill statistics
         /*-*/
         if order_fact_r01.sap_material_type_code = 'FERT' then
            var_ord_qty := var_ord_qty + order_fact_r01.ord_qty;
            var_del_qty := var_del_qty + order_fact_r01.del_qty;
            var_fert_indicator := 1;
            if order_fact_r01.pod_date is null or 
               trunc(order_fact_r01.agr_date) < trunc(order_fact_r01.pod_date) then
               var_dat_indicator := false;
               var_tim_indicator := false;
            end if;
         else
            var_prm_ord_qty := var_ord_qty + order_fact_r01.ord_qty;
            var_prm_del_qty := var_del_qty + order_fact_r01.del_qty;
            var_zprm_indicator := 1;
            if order_fact_r01.pod_date is null or 
               trunc(order_fact_r01.agr_date) < trunc(order_fact_r01.pod_date) then
               var_prm_dat_indicator := false;
               var_prm_tim_indicator := false;
            end if;
         end if;
         if (order_fact_r01.pod_refusal = 'A002' or
             order_fact_r01.pod_refusal = 'A003' or
             order_fact_r01.pod_refusal = 'A004' or
             order_fact_r01.pod_refusal = 'A005' or
             order_fact_r01.pod_refusal = 'A006' or
             order_fact_r01.pod_refusal = 'A008' or
             order_fact_r01.pod_refusal = 'A009' or
             order_fact_r01.pod_refusal = 'A010' or
             order_fact_r01.pod_refusal = 'A011' or
             order_fact_r01.pod_refusal = 'A012' or
             order_fact_r01.pod_refusal = 'A013' or
             order_fact_r01.pod_refusal = 'A014' or
             order_fact_r01.pod_refusal = 'A015' or
             order_fact_r01.pod_refusal = 'A017' or
             order_fact_r01.pod_refusal = 'A018' or
             order_fact_r01.pod_refusal = 'A021' or
             order_fact_r01.pod_refusal = 'A022' or
             order_fact_r01.pod_refusal = 'A023' or
             order_fact_r01.pod_refusal = 'A024') then
            if order_fact_r01.sap_material_type_code = 'FERT' then
               var_pod_qty := var_pod_qty + order_fact_r01.pod_qty;
            else
               var_prm_pod_qty := var_prm_pod_qty + order_fact_r01.pod_qty;
            end if;
         else
            if order_fact_r01.sap_material_type_code = 'FERT' then
               var_pod_qty := var_pod_qty + order_fact_r01.del_qty;
            else
               var_prm_pod_qty := var_prm_pod_qty + order_fact_r01.del_qty;
            end if;
         end if;

      end loop;
      close order_fact_c01;

      /*-*/
      /* Process last order document when required
      /*-*/
      if not(var_doc_num is null) then

         /*-*/
         /* Determine the order fill
         /*-*/
         var_ord_fil := 0;
         if var_fert_indicator = 1 then
            if var_ord_qty = var_del_qty and 
               var_del_qty = var_pod_qty and
               var_dat_indicator = true then
               var_ord_fil := 1;
            end if;
         end if;

         /*-*/
         /* Determine the order on-time
         /*-*/
         var_ord_tim := 0;
         if var_fert_indicator = 1 then
            if var_tim_indicator = true then
               var_ord_tim := 1;
            end if;
         end if;

         /*-*/
         /* Determine the promotional order fill
         /*-*/
         var_prm_ord_fil := 0;
         if var_zprm_indicator = 1 then
            if var_prm_ord_qty = var_prm_del_qty and 
               var_prm_del_qty = var_prm_pod_qty and
               var_dat_indicator = true then
               var_prm_ord_fil := 1;
            end if;
         end if;

         /*-*/
         /* Determine the promotional order on-time
         /*-*/
         var_prm_ord_tim := 0;
         if var_zprm_indicator = 1 then
            if var_tim_indicator = true then
               var_prm_ord_tim := 1;
            end if;
         end if;
 
         /*-*/
         /* Update/insert the order fill row
         /*-*/
         update pld_csl_prd_1202
            set ord_tot = ord_tot + var_fert_indicator,
                ord_fil = ord_fil + var_ord_fil,
                ord_tim = ord_tim + var_ord_tim,
                ord_prm_tot = ord_prm_tot + var_zprm_indicator,
                ord_prm_fil = ord_prm_fil + var_prm_ord_fil,
                ord_prm_tim = ord_prm_tim + var_prm_ord_tim
          where sap_company_code = var_company_code
            and sap_ship_to_cust_code = var_ship_to_cust_code
            and sap_sales_org_code = var_sales_org_code
            and sap_distbn_chnl_code = var_distbn_chnl_code
            and sap_division_code = var_division_code;
         if sql%notfound then
            insert into pld_csl_prd_1202
               (sap_company_code,
                sap_ship_to_cust_code,
                sap_sales_org_code,
                sap_distbn_chnl_code,
                sap_division_code,
                ord_tot,
                ord_fil,
                ord_tim,
                ord_prm_tot,
                ord_prm_fil,
                ord_prm_tim)
            values
               (var_company_code,
                var_ship_to_cust_code,
                var_sales_org_code,
                var_distbn_chnl_code,
                var_division_code,
                var_fert_indicator,
                var_ord_fil,
                var_ord_tim,
                var_zprm_indicator,
                var_prm_ord_fil,
                var_prm_ord_tim);
         end if;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_order_data;

end hk_csl_prd_12_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_csl_prd_12_extract for pld_rep_app.hk_csl_prd_12_extract;
grant execute on hk_csl_prd_12_extract to public;