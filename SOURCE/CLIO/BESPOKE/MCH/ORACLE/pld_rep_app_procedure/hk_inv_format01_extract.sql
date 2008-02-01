/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Package : hk_inv_format01_extract                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_inv_format01_extract as

/**DESCRIPTION**
 Inventory Extract Format 01 - Invoice date aggregations.
 This package extracts the inventory information from the data warehouse as at
 the previous day (ie. sysdate - 1).

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

end hk_inv_format01_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_inv_format01_extract as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure exe_control_data(par_sap_company_code in varchar2);
   procedure exe_sales_data(par_sap_company_code in varchar2);
   procedure exe_forecast_data(par_sap_company_code in varchar2);
   procedure exe_inventory_data(par_sap_company_code in varchar2);
   procedure exe_calculate_cover(par_sap_company_code in varchar2);
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
      delete from pld_inv_format0100 where sap_company_code = par_sap_company_code;
      delete from pld_inv_format0101 where sap_company_code = par_sap_company_code;
      delete from pld_inv_format0102 where sap_company_code = par_sap_company_code;
      delete from pld_inv_format0103 where sap_company_code = par_sap_company_code;
      delete from pld_inv_format0104 where sap_company_code = par_sap_company_code;
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

      /**/
      /* Extract the inventory data */
      /**/
      exe_inventory_data(par_sap_company_code);
      commit;

      /**/
      /* Calculate the cover data */
      /**/
      exe_calculate_cover(par_sap_company_code);
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
	 rollback;
         return substr(SQLERRM, 1, 512);

      /*-*/
      /* Error trap */
      /*-*/
      when others then
	 rollback;
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
                          '*INV',
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
      insert into pld_inv_format0100
         (sap_company_code,
          extract_date,
          logical_date,
          current_YYYYPP,
          current_YYYYMM,
          extract_status,
          inventory_date,
          inventory_status,
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
                var_inventory_date,
                var_inventory_status,
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
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_sap_company_code varchar2(6 char);
      var_sap_material_code varchar2(18 char);
      var_billed_qty number;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor sales_period_01_fact_c01 is 
         select sales_period_01_fact.sap_company_code,
                sales_period_01_fact.sap_material_code,
                sum(nvl(sales_period_01_fact.base_uom_billed_qty, 0))
         from sales_period_01_fact
         where sales_period_01_fact.sap_company_code = par_sap_company_code
           and sales_period_01_fact.billing_YYYYPP = var_current_YYYYPP
           and sales_period_01_fact.base_uom_billed_qty is not null
           and sales_period_01_fact.base_uom_billed_qty <> 0
           and nvl(sales_period_01_fact.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(sales_period_01_fact.sap_order_type_code,'*NULL')||'/'||nvl(sales_period_01_fact.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
           and sales_period_01_fact.sap_invc_type_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','INVOICE_TYPE_EXCLUSION')))
         group by sales_period_01_fact.sap_company_code,
                  sales_period_01_fact.sap_material_code;

      cursor sales_month_01_fact_c01 is 
         select sales_month_01_fact.sap_company_code,
                sales_month_01_fact.sap_material_code,
                sum(nvl(sales_month_01_fact.base_uom_billed_qty, 0))
         from sales_month_01_fact
         where sales_month_01_fact.sap_company_code = par_sap_company_code
           and sales_month_01_fact.billing_YYYYMM = var_current_YYYYMM
           and sales_month_01_fact.base_uom_billed_qty is not null
           and sales_month_01_fact.base_uom_billed_qty <> 0
           and nvl(sales_month_01_fact.sap_order_type_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_EXCLUSION')))
           and nvl(sales_month_01_fact.sap_order_type_code,'*NULL')||'/'||nvl(sales_month_01_fact.sap_order_usage_code,'*NULL') not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','ORDER_TYPE_USAGE_EXCLUSION')))
           and sales_month_01_fact.sap_invc_type_code not in (select dsv_value from table(lics_datastore.retrieve_value('CLIO','DATAMART_EXTRACT','INVOICE_TYPE_EXCLUSION')))
         group by sales_month_01_fact.sap_company_code,
                  sales_month_01_fact.sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_inv_format0100 where sap_company_code = par_sap_company_code;
      select current_YYYYMM into var_current_YYYYMM from pld_inv_format0100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the material period sales value */
      /*-*/
      open sales_period_01_fact_c01;
      loop
         fetch sales_period_01_fact_c01 into var_sap_company_code,
                                             var_sap_material_code,
                                             var_billed_qty;
         if sales_period_01_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_company_code, var_sap_material_code);
         update pld_inv_format0101
            set prd_billed_qty = var_billed_qty
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
      end loop;
      close sales_period_01_fact_c01;

      /*-*/
      /* Extract the material month sales value */
      /*-*/
      open sales_month_01_fact_c01;
      loop
         fetch sales_month_01_fact_c01 into var_sap_company_code,
                                            var_sap_material_code,
                                            var_billed_qty;
         if sales_month_01_fact_c01%notfound then
            exit;
         end if;
         exe_create_material(var_sap_company_code, var_sap_material_code);
         update pld_inv_format0101
            set mth_billed_qty = var_billed_qty
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;
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
      /* Variable definitions */
      /*-*/
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_sap_sales_org_code varchar2(4 char);
      var_sap_material_code varchar2(18 char);
      var_billing_YYYYPP number(6,0);
      var_billing_YYYYMM number(6,0);
      var_br_qty number;
      var_rb_qty number;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor fcst_period_02_fact_c01 is
         select fcst_period_02_fact.sap_sales_dtl_sales_org_code,
                fcst_period_02_fact.sap_material_code, 
                fcst_period_02_fact.billing_YYYYPP,
                sum(fcst_period_02_fact.br_qty),
                sum(fcst_period_02_fact.rb_qty)
         from fcst_period_02_fact
         where fcst_period_02_fact.sap_sales_dtl_sales_org_code = par_sap_company_code
           and fcst_period_02_fact.billing_YYYYPP >= var_current_YYYYPP
         group by fcst_period_02_fact.sap_sales_dtl_sales_org_code,
                  fcst_period_02_fact.sap_material_code,
                  fcst_period_02_fact.billing_YYYYPP;

      cursor fcst_month_02_fact_c01 is 
         select fcst_month_02_fact.sap_sales_dtl_sales_org_code,
                fcst_month_02_fact.sap_material_code,
                fcst_month_02_fact.billing_YYYYMM,
                sum(fcst_month_02_fact.br_qty),
                sum(fcst_month_02_fact.rb_qty)
         from fcst_month_02_fact
         where fcst_month_02_fact.sap_sales_dtl_sales_org_code = par_sap_company_code
           and fcst_month_02_fact.billing_YYYYMM >= var_current_YYYYMM
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
      select current_YYYYPP into var_current_YYYYPP from pld_inv_format0100 where sap_company_code = par_sap_company_code;
      select current_YYYYMM into var_current_YYYYMM from pld_inv_format0100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the material period forecast values */
      /*-*/
      open fcst_period_02_fact_c01;
      loop
         fetch fcst_period_02_fact_c01 into var_sap_sales_org_code,
                                            var_sap_material_code,
                                            var_billing_YYYYPP,
                                            var_br_qty,
                                            var_rb_qty;
         if fcst_period_02_fact_c01%notfound then
            exit;
         end if;
         if var_billing_YYYYPP = var_current_YYYYPP then
            exe_create_material(var_sap_sales_org_code, var_sap_material_code);
            update pld_inv_format0101
               set prd_br_qty = var_br_qty,
                   prd_rb_qty = var_rb_qty
               where sap_company_code = var_sap_sales_org_code
                 and sap_material_code = var_sap_material_code;
         end if;
         insert into pld_inv_format0103
            (sap_company_code,
             sap_material_code,
             billing_YYYYPP,
             br_qty,
             rb_qty)
            values(var_sap_sales_org_code,
                   var_sap_material_code,
                   var_billing_YYYYPP, 
                   var_br_qty,
                   var_rb_qty);
      end loop;
      close fcst_period_02_fact_c01;

      /*-*/
      /* Extract the material month forecast values */
      /*-*/
      open fcst_month_02_fact_c01;
      loop
         fetch fcst_month_02_fact_c01 into var_sap_sales_org_code,
                                           var_sap_material_code,
                                           var_billing_YYYYMM,
                                           var_br_qty,
                                           var_rb_qty;
         if fcst_month_02_fact_c01%notfound then
            exit;
         end if;
         if var_billing_YYYYMM = var_current_YYYYMM then
            exe_create_material(var_sap_sales_org_code, var_sap_material_code);
            update pld_inv_format0101
               set mth_br_qty = var_br_qty,
                   mth_rb_qty = var_rb_qty
               where sap_company_code = var_sap_sales_org_code
                 and sap_material_code = var_sap_material_code;
         end if;
         insert into pld_inv_format0104
            (sap_company_code,
             sap_material_code,
             billing_YYYYMM,
             br_qty,
             rb_qty)
            values(var_sap_sales_org_code,
                   var_sap_material_code,
                   var_billing_YYYYMM, 
                   var_br_qty,
                   var_rb_qty);
      end loop;
      close fcst_month_02_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_forecast_data;

   /******************************************************/
   /* This procedure performs the inventory data routine */
   /******************************************************/
   procedure exe_inventory_data(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_blnc_date date;
      var_prd_percent number(5,2);
      var_mth_percent number(5,2);
      var_stock_ageing number(2,0);
      var_age_date date;
      var_old_date date;
      var_inv_date date;
      var_sap_plant_code varchar2(4 char);
      var_sap_company_code varchar2(6 char);
      sav_sap_company_code varchar2(6 char);
      var_sap_material_code varchar2(18 char);
      sav_sap_material_code varchar2(18 char);
      var_inv_level number;
      var_sap_stock_type_code varchar2(2 char);
      var_material_batch_desc varchar2(8 char);
      var_sap_bus_sgmnt_code varchar2(10 char);
      var_price_unit number;
      var_std_price number;
      var_inv_tot_value number;
      var_inv_tot_qty number;
      var_inv_int_qty number;
      var_inv_war_value number;
      var_inv_war_qty number;
      var_inv_hld_qty number;
      var_inv_unk_qty number;
      var_inv_age_qty number;
      var_inv_sal_qty number;
      var_found boolean;
      var_count binary_integer;

      /*-*/
      /* Array definitions */
      /*-*/
      type rcdWarehouse is record(sap_plant_code varchar2(4), inv_sal_qty number(22,3));
      type typWarehouse is table of rcdWarehouse index by binary_integer;
      tblWarehouse typWarehouse;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor inv_blnc_hdr_c01 is 
         select nvl(plant_dim.sap_plant_code,'XXXX')
         from inv_blnc_hdr, plant_dim
         where inv_blnc_hdr.sap_plant_code = plant_dim.sap_plant_code(+)
           and inv_blnc_hdr.sap_company_code = par_sap_company_code
           and inv_blnc_hdr.blnc_date = var_blnc_date
           and plant_dim.sap_plant_code <> 'HK00'
         group by plant_dim.sap_plant_code
         order by plant_dim.sap_plant_code asc;
         
      cursor inv_blnc_dtl_c01 is 
         select inv_blnc_hdr.sap_company_code,
                inv_blnc_dtl.sap_material_code,
                nvl(plant_dim.sap_plant_code,'XXXX'),
                inv_blnc_dtl.inv_level,
                inv_blnc_dtl.sap_stock_type_code,
                inv_blnc_dtl.material_batch_desc,
                nvl(material_dim.sap_bus_sgmnt_code,'XXXX')
         from inv_blnc_hdr,
              inv_blnc_dtl,
              plant_dim,
              material_dim
         where inv_blnc_hdr.sap_company_code = inv_blnc_dtl.sap_company_code
           and inv_blnc_hdr.sap_plant_code = inv_blnc_dtl.sap_plant_code
           and inv_blnc_hdr.sap_storage_locn_code = inv_blnc_dtl.sap_storage_locn_code
           and inv_blnc_hdr.blnc_date = inv_blnc_dtl.blnc_date
           and inv_blnc_hdr.blnc_time = inv_blnc_dtl.blnc_time
           and inv_blnc_hdr.sap_plant_code = plant_dim.sap_plant_code(+)
           and inv_blnc_hdr.sap_company_code = par_sap_company_code
           and inv_blnc_hdr.blnc_date = var_blnc_date
           and inv_blnc_dtl.sap_material_code = material_dim.sap_material_code(+)
         order by inv_blnc_hdr.sap_company_code asc,
                  inv_blnc_dtl.sap_material_code asc;

      cursor material_std_price_c01 is 
         select nvl(material_std_price.price_unit, 1),
                nvl(material_std_price.std_price, 0)
         from material_std_price
         where material_std_price.sap_material_code = var_sap_material_code
           and material_std_price.sap_plant_code = var_sap_plant_code;

      cursor pld_rep_parameter_c01 is 
         select to_number(par_value)
           from pld_rep_parameter
          where par_group = 'STOCK_AGEING'
            and par_code = var_sap_bus_sgmnt_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the inventory variables */
      /*-*/
      select inventory_date into var_blnc_date from pld_inv_format0100 where sap_company_code = par_sap_company_code;
      select prd_percent into var_prd_percent from pld_inv_format0100 where sap_company_code = par_sap_company_code;
      select mth_percent into var_mth_percent from pld_inv_format0100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Clear the work variables */
      /*-*/
      var_inv_tot_value := 0;
      var_inv_tot_qty := 0;
      var_inv_int_qty := 0;
      var_inv_war_value := 0;
      var_inv_war_qty := 0;
      var_inv_hld_qty := 0;
      var_inv_unk_qty := 0;
      var_inv_age_qty := 0;
      var_inv_sal_qty := 0;

      /*-*/
      /* Retrieve the inventory warehouses and initialise the internal table */
      /* **note** this does not include warehouse HK00 (intransit) */
      /*-*/
      tblWarehouse.Delete;
      open inv_blnc_hdr_c01;
      loop
         fetch inv_blnc_hdr_c01 into var_sap_plant_code;
         if inv_blnc_hdr_c01%notfound then
            exit;
         end if;
         var_count := tblWarehouse.count + 1;
         tblWarehouse(var_count).sap_plant_code := var_sap_plant_code;
         tblWarehouse(var_count).inv_sal_qty := 0;
      end loop;
      close inv_blnc_hdr_c01;

      /*-*/
      /* Retrieve the SAP inventory balances */
      /*-*/
      sav_sap_company_code := '******';
      sav_sap_material_code := '******************';
      open inv_blnc_dtl_c01;
      loop
         fetch inv_blnc_dtl_c01 into var_sap_company_code,
                                     var_sap_material_code,
                                     var_sap_plant_code,
                                     var_inv_level,
                                     var_sap_stock_type_code,
                                     var_material_batch_desc,
                                     var_sap_bus_sgmnt_code;
         if inv_blnc_dtl_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Change of company or material create the warehouse breakdown row */
         /*-*/
         if var_sap_company_code <> sav_sap_company_code
         or var_sap_material_code <> sav_sap_material_code then

            /*-*/
            /* Valid material found */
            /*-*/
            if sav_sap_company_code <> '******'
            and sav_sap_material_code <> '******************' then

               /*-*/
               /* Update/insert the material extract data */
               /*-*/
               exe_create_material(sav_sap_company_code, sav_sap_material_code);
               update pld_inv_format0101
                  set inv_tot_value = var_inv_tot_value,
                      inv_tot_qty = var_inv_tot_qty,
                      inv_int_qty = var_inv_int_qty,
                      inv_war_value = var_inv_war_value,
                      inv_war_qty = var_inv_war_qty,
                      inv_hld_qty = var_inv_hld_qty,
                      inv_unk_qty = var_inv_unk_qty,
                      inv_age_qty = var_inv_age_qty,
                      inv_sal_qty = var_inv_sal_qty
                  where sap_company_code = sav_sap_company_code
                    and sap_material_code = sav_sap_material_code;

               /*-*/
               /* Insert the warehouse extract data */
               /*-*/
               for idx in 1..tblWarehouse.count loop
                  insert into pld_inv_format0102
                     (sap_company_code,
                      sap_material_code,
                      sap_plant_code,
                      inv_sal_qty)
                     values(sav_sap_company_code,
                            sav_sap_material_code,
                            tblWarehouse(idx).sap_plant_code,
                            tblWarehouse(idx).inv_sal_qty);
                     tblWarehouse(idx).inv_sal_qty := 0;
               end loop;

               /*-*/
               /* Initialise the new material variables */
               /*-*/
               var_inv_tot_value := 0;
               var_inv_tot_qty := 0;
               var_inv_int_qty := 0;
               var_inv_war_value := 0;
               var_inv_war_qty := 0;
               var_inv_hld_qty := 0;
               var_inv_unk_qty := 0;
               var_inv_age_qty := 0;
               var_inv_sal_qty := 0;

            end if;

            /*-*/
            /* Save the new material codes */
            /*-*/
            sav_sap_company_code := var_sap_company_code;
            sav_sap_material_code := var_sap_material_code;

         end if;

         /*-*/
         /* Retrieve the material standard price information */
         /*-*/
         open material_std_price_c01;
         fetch material_std_price_c01 into var_price_unit,
                                           var_std_price;
         if material_std_price_c01%notfound then
            var_price_unit := 1;
            var_std_price := 0;
         end if;
         close material_std_price_c01;

         /*-*/
         /* Retrieve the stock ageing parameter */
         /*-*/
         open pld_rep_parameter_c01;
         fetch pld_rep_parameter_c01 into var_stock_ageing;
         if pld_rep_parameter_c01%notfound then
            var_sap_bus_sgmnt_code := 'DEFAULT';
         end if;
         close pld_rep_parameter_c01;
         if var_sap_bus_sgmnt_code = 'DEFAULT' then
            open pld_rep_parameter_c01;
            fetch pld_rep_parameter_c01 into var_stock_ageing;
            if pld_rep_parameter_c01%notfound then
               var_stock_ageing := 6;
            end if;
            close pld_rep_parameter_c01;
         end if;

         /*-*/
         /* Retrieve the aging dates */
         /*-*/
         select add_months(sysdate,var_stock_ageing) into var_age_date from dual;
         select add_months(sysdate,120) into var_old_date from dual;

         /*-*/
         /* Retrieve the inventory date and calculate the age */
         /*-*/
         var_inv_date := null;
         if var_material_batch_desc is not null then
            begin
               var_inv_date := to_date(var_material_batch_desc, 'DDMMYYYY');
            exception
               when others then
                  var_inv_date := null;
            end;
            if var_inv_date is not null then
               if var_inv_date > var_old_date then
                  var_inv_date := null;
               end if;
            end if;
         end if;

         /*-*/
         /* Accumulate the material total value and quantity */
         /*-*/
         var_inv_tot_value := var_inv_tot_value + ((var_inv_level / var_price_unit) * var_std_price);
         var_inv_tot_qty := var_inv_tot_qty + var_inv_level;

         /*-*/
         /* Accumulate the intransit quantity */
         /* **note** this is hard-coded to HK00 */
         /*-*/
         if var_sap_plant_code = 'HK00' then
            var_inv_int_qty := var_inv_int_qty + var_inv_level;
         end if;

         /*-*/
         /* Accumulate the warehoused values */
         /* **note** this is hard-coded to HK00 */
         /*-*/
         if var_sap_plant_code <> 'HK00' then

            /*-*/
            /* Accumulate the material warehoused value and quantity */
            /*-*/
            var_inv_war_value := var_inv_war_value + ((var_inv_level / var_price_unit) * var_std_price);
            var_inv_war_qty := var_inv_war_qty + var_inv_level;

            /*-*/
            /* Accumulate the material held quantity */
            /* **WARNING** this is hard coding that must be monitored */
            /*-*/
            if var_sap_stock_type_code = 'X'
            or var_sap_stock_type_code = 'S'
            or var_sap_stock_type_code = '2'
            or var_sap_stock_type_code = '3' then
               var_inv_hld_qty := var_inv_hld_qty + var_inv_level;
            end if;

            /*-*/
            /* Accumulate the unrestricted quantity */
            /* **WARNING** this is hard coding that must be monitored */
            /*-*/
            if var_sap_stock_type_code = 'F'
            or var_sap_stock_type_code = '1' then

               /*-*/
               /* Accumulate the material unknown quantity */
               /*-*/
               if var_inv_date is null then
                  var_inv_unk_qty := var_inv_unk_qty + var_inv_level;
               end if;

               /*-*/
               /* Accumulate the material aging quantity */
               /* Accumulate the material saleable quantity and warehouse distribution */
               /*-*/
               if var_inv_date is not null then
                  if var_inv_date <= var_age_date then
                     var_inv_age_qty := var_inv_age_qty + var_inv_level;
                  else
                     var_inv_sal_qty := var_inv_sal_qty + var_inv_level;
                     for idx in 1..tblWarehouse.count loop
                        if tblWarehouse(idx).sap_plant_code = var_sap_plant_code then
                           tblWarehouse(idx).inv_sal_qty := tblWarehouse(idx).inv_sal_qty + var_inv_level;
                           exit;
                        end if;
                     end loop;
                  end if;
               end if;

            end if;

         end if;
         
      end loop;
      close inv_blnc_dtl_c01;

      /*-*/
      /* Process the final material */
      /*-*/
      if sav_sap_company_code <> '******'
      and sav_sap_material_code <> '******************' then

         /*-*/
         /* Update/insert the material extract data */
         /*-*/
         exe_create_material(sav_sap_company_code, sav_sap_material_code);
         update pld_inv_format0101
            set inv_tot_value = var_inv_tot_value,
                inv_tot_qty = var_inv_tot_qty,
                inv_int_qty = var_inv_int_qty,
                inv_war_value = var_inv_war_value,
                inv_war_qty = var_inv_war_qty,
                inv_hld_qty = var_inv_hld_qty,
                inv_unk_qty = var_inv_unk_qty,
                inv_age_qty = var_inv_age_qty,
                inv_sal_qty = var_inv_sal_qty
            where sap_company_code = sav_sap_company_code
              and sap_material_code = sav_sap_material_code;

         /*-*/
         /* Insert the warehouse extract data */
         /*-*/
         for idx in 1..tblWarehouse.count loop
            insert into pld_inv_format0102
               (sap_company_code,
                sap_material_code,
                sap_plant_code,
                inv_sal_qty)
               values(sav_sap_company_code,
                      sav_sap_material_code,
                      tblWarehouse(idx).sap_plant_code,
                      tblWarehouse(idx).inv_sal_qty);
         end loop;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_inventory_data;

   /*******************************************************/
   /* This procedure performs the calculate cover routine */
   /*******************************************************/
   procedure exe_calculate_cover(par_sap_company_code in varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_prd_percent number(5,2);
      var_mth_percent number(5,2);
      var_sap_company_code varchar2(6 char);
      var_sap_material_code varchar2(18 char);
      var_inv_tot_qty number;
      var_inv_sal_qty number;
      var_prd_fut_br_qty number;
      var_prd_fut_rb_qty number;
      var_mth_fut_br_qty number;
      var_mth_fut_rb_qty number;
      var_inv_prd_br_ons_cover number;
      var_inv_prd_rb_ons_cover number;
      var_inv_mth_br_ons_cover number;
      var_inv_mth_rb_ons_cover number;
      var_inv_prd_br_sal_cover number;
      var_inv_prd_rb_sal_cover number;
      var_inv_mth_br_sal_cover number;
      var_inv_mth_rb_sal_cover number;
      var_br_ons_qty number;
      var_br_sal_qty number;
      var_rb_ons_qty number;
      var_rb_sal_qty number;
      var_br_ons_start boolean;
      var_br_sal_start boolean;
      var_rb_ons_start boolean;
      var_rb_sal_start boolean;
      var_YYYYPP number(6,0);
      var_YYYYMM number(6,0);
      var_br_qty number;
      var_rb_qty number;
      var_wrk_pct number;
      var_for_pct number;
      var_for_qty number;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor pld_inv_format0101_c01 is 
         select pld_inv_format0101.sap_company_code,
                pld_inv_format0101.sap_material_code,
                pld_inv_format0101.inv_tot_qty,
                pld_inv_format0101.inv_sal_qty
         from pld_inv_format0101
         where pld_inv_format0101.sap_company_code = par_sap_company_code
           and pld_inv_format0101.inv_tot_qty <> 0 or
               pld_inv_format0101.inv_sal_qty <> 0;

      cursor pld_inv_format0103_c01 is 
         select pld_inv_format0103.billing_YYYYPP,
                pld_inv_format0103.br_qty,
                pld_inv_format0103.rb_qty
         from pld_inv_format0103
         where pld_inv_format0103.sap_company_code = var_sap_company_code
           and pld_inv_format0103.sap_material_code = var_sap_material_code
         order by pld_inv_format0103.billing_YYYYPP asc;

      cursor pld_inv_format0104_c01 is 
         select pld_inv_format0104.billing_YYYYMM,
                pld_inv_format0104.br_qty,
                pld_inv_format0104.rb_qty
         from pld_inv_format0104
         where pld_inv_format0104.sap_company_code = var_sap_company_code
           and pld_inv_format0104.sap_material_code = var_sap_material_code
         order by pld_inv_format0104.billing_YYYYMM asc;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_inv_format0100 where sap_company_code = par_sap_company_code;
      select current_YYYYMM into var_current_YYYYMM from pld_inv_format0100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Retrieve the period and month progress percentage variables */
      /*-*/
      select prd_percent into var_prd_percent from pld_inv_format0100 where sap_company_code = par_sap_company_code;
      select mth_percent into var_mth_percent from pld_inv_format0100 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Process the material with saleable quantities */
      /*-*/
      open pld_inv_format0101_c01;
      loop
         fetch pld_inv_format0101_c01 into var_sap_company_code,
                                           var_sap_material_code,
                                           var_inv_tot_qty,
                                           var_inv_sal_qty;
         if pld_inv_format0101_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Initialise the future forecast quantities */
         /*-*/
         var_prd_fut_br_qty := 0;
         var_prd_fut_rb_qty := 0;
         var_mth_fut_br_qty := 0;
         var_mth_fut_rb_qty := 0;

         /*-*/
         /* Initialise the weeks cover */
         /*-*/
         var_inv_prd_br_ons_cover := 0;
         var_inv_prd_rb_ons_cover := 0;
         var_inv_mth_br_ons_cover := 0;
         var_inv_mth_rb_ons_cover := 0;
         var_inv_prd_br_sal_cover := 0;
         var_inv_prd_rb_sal_cover := 0;
         var_inv_mth_br_sal_cover := 0;
         var_inv_mth_rb_sal_cover := 0;

         /*-*/
         /* Process the material period forecast values */
         /*-*/
         var_br_ons_start := false;
         var_br_sal_start := false;
         var_rb_ons_start := false;
         var_rb_sal_start := false;
         var_br_ons_qty := var_inv_tot_qty;
         var_br_sal_qty := var_inv_sal_qty;
         var_rb_ons_qty := var_inv_tot_qty;
         var_rb_sal_qty := var_inv_sal_qty;
         open pld_inv_format0103_c01;
         loop
            fetch pld_inv_format0103_c01 into var_YYYYPP,
                                              var_br_qty,
                                              var_rb_qty;
            if pld_inv_format0103_c01%notfound then
               exit;
            end if;

            /*-*/
            /* Exit when no cover stock remaining */
            /*-*/
            if var_br_ons_qty <= 0
            and var_br_sal_qty <= 0
            and var_rb_ons_qty <= 0
            and var_rb_sal_qty <= 0 then
               exit;
            end if;

            /*-*/
            /* Accumulate the future forecast quantities */
            /*-*/
            if var_YYYYPP > var_current_YYYYPP then
               var_prd_fut_br_qty := var_prd_fut_br_qty + var_br_qty;
               var_prd_fut_rb_qty := var_prd_fut_rb_qty + var_rb_qty;
            end if;

            /*-*/
            /* BR onshore weeks cover */
            /*-*/
            if var_br_ons_qty > 0 then
               if var_br_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYPP = var_current_YYYYPP then
                     var_for_pct := 1 - (var_prd_percent / 100);
                  end if;
                  var_for_qty := var_br_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_br_ons_qty - var_for_qty < 0 then
                     var_wrk_pct := var_br_ons_qty / var_for_qty;
                  end if;
                  var_br_ons_qty := var_br_ons_qty - var_for_qty;
                  var_inv_prd_br_ons_cover := var_inv_prd_br_ons_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_br_ons_start := true;
               else
                  if var_br_ons_start = true then
                     var_inv_prd_br_ons_cover := var_inv_prd_br_ons_cover + 4;
                  end if;
               end if;
            end if;

            /*-*/
            /* BR saleable weeks cover */
            /*-*/
            if var_br_sal_qty > 0 then
               if var_br_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYPP = var_current_YYYYPP then
                     var_for_pct := 1 - (var_prd_percent / 100);
                  end if;
                  var_for_qty := var_br_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_br_sal_qty - var_for_qty < 0 then
                     var_wrk_pct := var_br_sal_qty / var_for_qty;
                  end if;
                  var_br_sal_qty := var_br_sal_qty - var_for_qty;
                  var_inv_prd_br_sal_cover := var_inv_prd_br_sal_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_br_sal_start := true;
               else
                  if var_br_sal_start = true then
                     var_inv_prd_br_sal_cover := var_inv_prd_br_sal_cover + 4;
                  end if;
               end if;
            end if;

            /*-*/
            /* LE onshore weeks cover */
            /*-*/
            if var_rb_ons_qty > 0 then
               if var_rb_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYPP = var_current_YYYYPP then
                     var_for_pct := 1 - (var_prd_percent / 100);
                  end if;
                  var_for_qty := var_rb_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_rb_ons_qty - var_for_qty < 0 then
                     var_wrk_pct := var_rb_ons_qty / var_for_qty;
                  end if;
                  var_rb_ons_qty := var_rb_ons_qty - var_for_qty;
                  var_inv_prd_rb_ons_cover := var_inv_prd_rb_ons_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_rb_ons_start := true;
               else
                  if var_rb_ons_start = true then
                     var_inv_prd_rb_ons_cover := var_inv_prd_rb_ons_cover + 4;
                  end if;
               end if;
            end if;

            /*-*/
            /* LE saleable weeks cover */
            /*-*/
            if var_rb_sal_qty > 0 then
               if var_rb_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYPP = var_current_YYYYPP then
                     var_for_pct := 1 - (var_prd_percent / 100);
                  end if;
                  var_for_qty := var_rb_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_rb_sal_qty - var_for_qty < 0 then
                     var_wrk_pct := var_rb_sal_qty / var_for_qty;
                  end if;
                  var_rb_sal_qty := var_rb_sal_qty - var_for_qty;
                  var_inv_prd_rb_sal_cover := var_inv_prd_rb_sal_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_rb_sal_start := true;
               else
                  if var_rb_sal_start = true then
                     var_inv_prd_rb_sal_cover := var_inv_prd_rb_sal_cover + 4;
                  end if;
               end if;
            end if;

         end loop;
         close pld_inv_format0103_c01;

         /*-*/
         /* Process the material month forecast values */
         /*-*/
         var_br_ons_start := false;
         var_br_sal_start := false;
         var_rb_ons_start := false;
         var_rb_sal_start := false;
         var_br_ons_qty := var_inv_tot_qty;
         var_br_sal_qty := var_inv_sal_qty;
         var_rb_ons_qty := var_inv_tot_qty;
         var_rb_sal_qty := var_inv_sal_qty;
         open pld_inv_format0104_c01;
         loop
            fetch pld_inv_format0104_c01 into var_YYYYMM,
                                              var_br_qty,
                                              var_rb_qty;
            if pld_inv_format0104_c01%notfound then
               exit;
            end if;

            /*-*/
            /* Exit when no cover stock remaining */
            /*-*/
            if var_br_ons_qty <= 0
            and var_br_sal_qty <= 0
            and var_rb_ons_qty <= 0
            and var_rb_sal_qty <= 0 then
               exit;
            end if;

            /*-*/
            /* Accumulate the future forecast quantities */
            /*-*/
            if var_YYYYMM > var_current_YYYYMM then
               var_mth_fut_br_qty := var_mth_fut_br_qty + var_br_qty;
               var_mth_fut_rb_qty := var_mth_fut_rb_qty + var_rb_qty;
            end if;

            /*-*/
            /* BR onshore weeks cover */
            /*-*/
            if var_br_ons_qty > 0 then
               if var_br_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYMM = var_current_YYYYMM then
                     var_for_pct := 1 - (var_mth_percent / 100);
                  end if;
                  var_for_qty := var_br_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_br_ons_qty - var_for_qty < 0 then
                     var_wrk_pct := var_br_ons_qty / var_for_qty;
                  end if;
                  var_br_ons_qty := var_br_ons_qty - var_for_qty;
                  var_inv_mth_br_ons_cover := var_inv_mth_br_ons_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_br_ons_start := true;
               else
                  if var_br_ons_start = true then
                     var_inv_mth_br_ons_cover := var_inv_mth_br_ons_cover + 4;
                  end if;
               end if;
            end if;

            /*-*/
            /* BR saleable weeks cover */
            /*-*/
            if var_br_sal_qty > 0 then
               if var_br_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYMM = var_current_YYYYMM then
                     var_for_pct := 1 - (var_mth_percent / 100);
                  end if;
                  var_for_qty := var_br_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_br_sal_qty - var_for_qty < 0 then
                     var_wrk_pct := var_br_sal_qty / var_for_qty;
                  end if;
                  var_br_sal_qty := var_br_sal_qty - var_for_qty;
                  var_inv_mth_br_sal_cover := var_inv_mth_br_sal_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_br_sal_start := true;
               else
                  if var_br_sal_start = true then
                     var_inv_mth_br_sal_cover := var_inv_mth_br_sal_cover + 4;
                  end if;
               end if;
            end if;

            /*-*/
            /* LE onshore weeks cover */
            /*-*/
            if var_rb_ons_qty > 0 then
               if var_rb_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYMM = var_current_YYYYMM then
                     var_for_pct := 1 - (var_mth_percent / 100);
                  end if;
                  var_for_qty := var_rb_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_rb_ons_qty - var_for_qty < 0 then
                     var_wrk_pct := var_rb_ons_qty / var_for_qty;
                  end if;
                  var_rb_ons_qty := var_rb_ons_qty - var_for_qty;
                  var_inv_mth_rb_ons_cover := var_inv_mth_rb_ons_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_rb_ons_start := true;
               else
                  if var_rb_ons_start = true then
                     var_inv_mth_rb_ons_cover := var_inv_mth_rb_ons_cover + 4;
                  end if;
               end if;
            end if;

            /*-*/
            /* LE saleable weeks cover */
            /*-*/
            if var_rb_sal_qty > 0 then
               if var_rb_qty <> 0 then
                  var_for_pct := 1;
                  if var_YYYYMM = var_current_YYYYMM then
                     var_for_pct := 1 - (var_mth_percent / 100);
                  end if;
                  var_for_qty := var_rb_qty * var_for_pct;
                  var_wrk_pct := 1;
                  if var_rb_sal_qty - var_for_qty < 0 then
                     var_wrk_pct := var_rb_sal_qty / var_for_qty;
                  end if;
                  var_rb_sal_qty := var_rb_sal_qty - var_for_qty;
                  var_inv_mth_rb_sal_cover := var_inv_mth_rb_sal_cover + round((4 * var_for_pct) * var_wrk_pct, 2);
                  var_rb_sal_start := true;
               else
                  if var_rb_sal_start = true then
                     var_inv_mth_rb_sal_cover := var_inv_mth_rb_sal_cover + 4;
                  end if;
               end if;
            end if;

         end loop;
         close pld_inv_format0104_c01;

         /*-*/
         /* Update the weeks cover percentages */
         /*-*/
         update pld_inv_format0101
            set prd_fut_br_qty = var_prd_fut_br_qty,
                prd_fut_rb_qty = var_prd_fut_rb_qty,
                mth_fut_br_qty = var_mth_fut_br_qty,
                mth_fut_rb_qty = var_mth_fut_rb_qty,
                inv_prd_br_ons_cover = var_inv_prd_br_ons_cover,
                inv_prd_rb_ons_cover = var_inv_prd_rb_ons_cover,
                inv_mth_br_ons_cover = var_inv_mth_br_ons_cover,
                inv_mth_rb_ons_cover = var_inv_mth_rb_ons_cover,
                inv_prd_br_sal_cover = var_inv_prd_br_sal_cover,
                inv_prd_rb_sal_cover = var_inv_prd_rb_sal_cover,
                inv_mth_br_sal_cover = var_inv_mth_br_sal_cover,
                inv_mth_rb_sal_cover = var_inv_mth_rb_sal_cover
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code;

      end loop;
      close pld_inv_format0101_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_calculate_cover;

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
      cursor pld_inv_format0101_c01 is 
         select 'x'
         from pld_inv_format0101
         where pld_inv_format0101.sap_company_code = par_sap_company_code
           and pld_inv_format0101.sap_material_code = par_sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create a new material extract row when required */
      /*-*/
      open pld_inv_format0101_c01;
      fetch pld_inv_format0101_c01 into var_work;
      if pld_inv_format0101_c01%notfound then
         insert into pld_inv_format0101
            (sap_company_code,
             sap_material_code,
             prd_billed_qty,
             prd_br_qty,
             prd_rb_qty,
             prd_fut_br_qty,
             prd_fut_rb_qty,
             mth_billed_qty,
             mth_br_qty,
             mth_rb_qty,
             mth_fut_br_qty,
             mth_fut_rb_qty,
             inv_tot_value,
             inv_tot_qty,
             inv_int_qty,
             inv_war_value,
             inv_war_qty,
             inv_hld_qty,
             inv_unk_qty,
             inv_age_qty,
             inv_sal_qty,
             inv_prd_br_ons_cover,
             inv_prd_rb_ons_cover,
             inv_mth_br_ons_cover,
             inv_mth_rb_ons_cover,
             inv_prd_br_sal_cover,
             inv_prd_rb_sal_cover,
             inv_mth_br_sal_cover,
             inv_mth_rb_sal_cover)
            values(par_sap_company_code,
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
                   0);
      end if;
      close pld_inv_format0101_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_create_material;

end hk_inv_format01_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_inv_format01_extract for pld_rep_app.hk_inv_format01_extract;
grant execute on hk_inv_format01_extract to public;