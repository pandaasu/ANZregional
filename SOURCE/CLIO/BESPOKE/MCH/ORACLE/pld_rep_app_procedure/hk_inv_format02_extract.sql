/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : HK Planning Reports                                */
/* Package : hk_inv_format02_extract                            */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package hk_inv_format02_extract as

/**DESCRIPTION**
 Inventory Extract Format 02 - Invoice date aggregations.
 This package extracts the inventory information from the data warehouse as at
 the previous day (ie. sysdate - 1).

 **PARAMETERS**
 none

 **NOTES**
 none

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/03   Steve Gregan   Created
 2007/04   Steve Gregan   Included company parameter.

**/

   /*-*/
   /* Public declarations */
   /*-*/
   function main(par_sap_company_code in varchar2) return varchar2;

end hk_inv_format02_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body hk_inv_format02_extract as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure exe_control_data(par_sap_company_code in varchar2);
   procedure exe_forecast_data(par_sap_company_code in varchar2);
   procedure exe_inventory_data(par_sap_company_code in varchar2);

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
      delete from pld_inv_format0200 where sap_company_code = par_sap_company_code;
      delete from pld_inv_format0201 where sap_company_code = par_sap_company_code;
      delete from pld_inv_format0202 where sap_company_code = par_sap_company_code;
      commit;

      /**/
      /* Extract the control data */
      /**/
      exe_control_data(par_sap_company_code);
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
      insert into pld_inv_format0200
         (sap_company_code,
          extract_date,
          current_YYYYPP,
          current_YYYYMM,
          extract_status,
          inventory_date,
          inventory_status)
         values(par_sap_company_code,
                sysdate,
                var_current_YYYYPP,
                var_current_YYYYMM,
                var_extract_status,
                var_inventory_date,
                var_inventory_status);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_control_data;

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
      var_sap_material_code varchar2(8 char);
      var_op_qty number;
      var_br_qty number;
      var_rb_qty number;

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor fcst_period_02_fact_c01 is
         select fcst_period_02_fact.sap_sales_dtl_sales_org_code,
                fcst_period_02_fact.sap_material_code, 
                sum(fcst_period_02_fact.op_qty),
                sum(fcst_period_02_fact.br_qty),
                sum(fcst_period_02_fact.rb_qty)
         from fcst_period_02_fact
         where fcst_period_02_fact.sap_sales_dtl_sales_org_code = par_sap_company_code
           and fcst_period_02_fact.billing_YYYYPP >= var_current_YYYYPP
         group by fcst_period_02_fact.sap_sales_dtl_sales_org_code,
                  fcst_period_02_fact.sap_material_code;

      cursor fcst_month_02_fact_c01 is 
         select fcst_month_02_fact.sap_sales_dtl_sales_org_code,
                fcst_month_02_fact.sap_material_code,
                sum(fcst_month_02_fact.op_qty),
                sum(fcst_month_02_fact.br_qty),
                sum(fcst_month_02_fact.rb_qty)
         from fcst_month_02_fact
         where fcst_month_02_fact.sap_sales_dtl_sales_org_code = par_sap_company_code
           and fcst_month_02_fact.billing_YYYYMM >= var_current_YYYYMM
         group by fcst_month_02_fact.sap_sales_dtl_sales_org_code,
                  fcst_month_02_fact.sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month variables */
      /*-*/
      select current_YYYYPP into var_current_YYYYPP from pld_inv_format0200 where sap_company_code = par_sap_company_code;
      select current_YYYYMM into var_current_YYYYMM from pld_inv_format0200 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Extract the material period forecast values */
      /*-*/
      open fcst_period_02_fact_c01;
      loop
         fetch fcst_period_02_fact_c01 into var_sap_sales_org_code,
                                            var_sap_material_code,
                                            var_op_qty,
                                            var_br_qty,
                                            var_rb_qty;
         if fcst_period_02_fact_c01%notfound then
            exit;
         end if;
         update pld_inv_format0201
            set prd_op_qty = var_op_qty,
                prd_br_qty = var_br_qty,
                prd_rb_qty = var_rb_qty
            where sap_company_code = var_sap_sales_org_code
              and sap_material_code = var_sap_material_code;
         if sql%notfound then
            insert into pld_inv_format0201
               (sap_company_code,
                sap_material_code,
                prd_op_qty,
                prd_br_qty,
                prd_rb_qty,
                mth_op_qty,
                mth_br_qty,
                mth_rb_qty)
               values(var_sap_sales_org_code,
                      var_sap_material_code,
                      var_op_qty,
                      var_br_qty,
                      var_rb_qty,
                      0,
                      0,
                      0);
         end if;
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
                                           var_rb_qty;
         if fcst_month_02_fact_c01%notfound then
            exit;
         end if;
         update pld_inv_format0201
            set mth_op_qty = var_op_qty,
                mth_br_qty = var_br_qty,
                mth_rb_qty = var_rb_qty
            where sap_company_code = var_sap_sales_org_code
              and sap_material_code = var_sap_material_code;
         if sql%notfound then
            insert into pld_inv_format0201
               (sap_company_code,
                sap_material_code,
                prd_op_qty,
                prd_br_qty,
                prd_rb_qty,
                mth_op_qty,
                mth_br_qty,
                mth_rb_qty)
               values(var_sap_sales_org_code,
                      var_sap_material_code,
                      0,
                      0,
                      0,
                      var_op_qty,
                      var_br_qty,
                      var_rb_qty);
         end if;
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
      var_age_date date;
      var_war_date date;
      var_old_date date;
      var_stock_ageing number(2,0);
      var_stock_warning number(2,0);
      var_sap_plant_code varchar2(4 char);
      var_sap_company_code varchar2(6 char);
      var_sap_material_code varchar2(18 char);
      var_inv_level number;
      var_sap_stock_type_code varchar2(2 char);
      var_material_batch_desc varchar2(8 char);
      var_sap_bus_sgmnt_code varchar2(10 char);
      var_price_unit number;
      var_std_price number;
      var_inv_exp_date date;
      var_inv_unr_qty number;
      var_inv_unr_val number;
      var_inv_res_qty number;
      var_inv_res_val number;
      var_inv_class01 varchar2(3 char);
      var_inv_class02 varchar2(3 char);
      var_found boolean;

      /*-*/
      /* Cursor definitions */
      /*-*/         
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
                  inv_blnc_dtl.sap_material_code asc,
                  inv_blnc_hdr.sap_plant_code asc,
                  inv_blnc_dtl.material_batch_desc asc;

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

      cursor pld_rep_parameter_c02 is 
         select to_number(par_value)
           from pld_rep_parameter
          where par_group = 'STOCK_WARNING'
            and par_code = var_sap_bus_sgmnt_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the inventory variables */
      /*-*/
      select inventory_date into var_blnc_date from pld_inv_format0200 where sap_company_code = par_sap_company_code;

      /*-*/
      /* Retrieve the warehouse inventory balances */
      /*-*/
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
         /* Clear the work variables */
         /*-*/
         var_inv_exp_date := null;
         var_inv_unr_qty := 0;
         var_inv_unr_val := 0;
         var_inv_res_qty := 0;
         var_inv_res_val := 0;
         var_inv_class01 := 'C03';
         var_inv_class02 := 'C02';

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
         /* Retrieve the stock warning parameter */
         /*-*/
         open pld_rep_parameter_c02;
         fetch pld_rep_parameter_c02 into var_stock_warning;
         if pld_rep_parameter_c02%notfound then
            var_sap_bus_sgmnt_code := 'DEFAULT';
         end if;
         close pld_rep_parameter_c02;
         if var_sap_bus_sgmnt_code = 'DEFAULT' then
            open pld_rep_parameter_c02;
            fetch pld_rep_parameter_c02 into var_stock_warning;
            if pld_rep_parameter_c02%notfound then
               var_stock_warning := 9;
            end if;
            close pld_rep_parameter_c02;
         end if;

         /*-*/
         /* Retrieve the aging dates */
         /*-*/
         select add_months(sysdate,var_stock_ageing) into var_age_date from dual;
         select add_months(sysdate,var_stock_warning) into var_war_date from dual;
         select add_months(sysdate,120) into var_old_date from dual;

         /*-*/
         /* Retrieve the inventory date and calculate the age */
         /*-*/
         if var_material_batch_desc is not null then
            begin
               var_inv_exp_date := to_date(var_material_batch_desc, 'DDMMYYYY');
            exception
               when others then
                  var_inv_exp_date := null;
            end;
            if var_inv_exp_date is not null then
               if var_inv_exp_date > var_old_date then
                  var_inv_exp_date := to_date('02011900', 'DDMMYYYY');
               end if;
            end if;
         end if;
         if var_inv_exp_date is null then
            var_inv_exp_date := to_date('01011900', 'DDMMYYYY');
         end if;

         /*-*/
         /* Set the inventory classification 01 */
         /*-*/
         if var_inv_exp_date <= var_age_date then
            var_inv_class01 := 'C03';
         elsif var_inv_exp_date <= var_war_date then
            var_inv_class01 := 'C02';
         else
            var_inv_class01 := 'C01';
         end if;

         /*-*/
         /* Set the inventory classification 02 */
         /*-*/
         if var_inv_exp_date <= var_age_date then
            var_inv_class02 := 'C02';
         else
            var_inv_class02 := 'C01';
         end if;

         /*-*/
         /* Set the restricted quantity and value */
         /* **WARNING** this is hard coding that must be monitored */
         /*-*/
         if var_sap_stock_type_code = 'X'
         or var_sap_stock_type_code = 'S'
         or var_sap_stock_type_code = '2'
         or var_sap_stock_type_code = '3' then
            var_inv_res_qty := var_inv_level;
            var_inv_res_val := (var_inv_level / var_price_unit) * var_std_price;
         end if;

         /*-*/
         /* Set the unrestricted quantity and value */
         /* **WARNING** this is hard coding that must be monitored */
         /*-*/
         if var_sap_stock_type_code = 'F'
         or var_sap_stock_type_code = '1' then
            var_inv_unr_qty := var_inv_level;
            var_inv_unr_val := (var_inv_level / var_price_unit) * var_std_price;
         end if;

         /*-*/
         /* Update/insert the detail extract data */
         /*-*/
         update pld_inv_format0202
            set inv_unr_qty = inv_unr_qty + var_inv_unr_qty,
                inv_unr_val = inv_unr_val + var_inv_unr_val,
                inv_res_qty = inv_res_qty + var_inv_res_qty,
                inv_res_val = inv_res_val + var_inv_res_val
            where sap_company_code = var_sap_company_code
              and sap_material_code = var_sap_material_code
              and sap_plant_code = var_sap_plant_code
              and inv_exp_date = var_inv_exp_date;
         if sql%notfound then
            insert into pld_inv_format0202
               (sap_company_code,
                sap_material_code,
                sap_plant_code,
                inv_exp_date,
                inv_unr_qty,
                inv_unr_val,
                inv_res_qty,
                inv_res_val,
                inv_class01,
                inv_class02)
               values(var_sap_company_code,
                      var_sap_material_code,
                      var_sap_plant_code,
                      var_inv_exp_date,
                      var_inv_unr_qty,
                      var_inv_unr_val,
                      var_inv_res_qty,
                      var_inv_res_val,
                      var_inv_class01,
                      var_inv_class02);
         end if;
         
      end loop;
      close inv_blnc_dtl_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end exe_inventory_data;

end hk_inv_format02_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym hk_inv_format02_extract for pld_rep_app.hk_inv_format02_extract;
grant execute on hk_inv_format02_extract to public;