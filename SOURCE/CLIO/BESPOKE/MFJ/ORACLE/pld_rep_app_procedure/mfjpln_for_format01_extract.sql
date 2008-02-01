/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_for_format01_extract                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : September 2003                                     */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_for_format01_extract as

/**DESCRIPTION**
 Forecast Extract - Invoice date aggregations.

 Extracts the forecast and sales information at the material level for
 the planning forecast reports. This extract is executed on a daily
 basis to be available for reporting. The data is extract from the
 Planning database.

 **PARAMETERS**
 None

 **NOTES**
 fcst_plan_period has plant_code
 fcst_plan_month does not have plant_code

**/

   /*-*/
   /* Public declarations */
   /*-*/
   function main return varchar2;

end mfjpln_for_format01_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_for_format01_extract as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure extractControl;
   procedure extractMaterials;
   procedure extractForecasts;
   procedure extractSales;

   /*-*/
   /* Private global variables */
   /*-*/
   var_current_yyyypp number(6,0);
   var_current_yyyymm number(6,0);
   var_rolling_yyyypp number(6,0);
   var_rolling_yyyymm number(6,0);

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
      /* Truncate the extract tables */
      /**/
      mfjpln_truncate.truncate_table('pld_for_format0100');
      mfjpln_truncate.truncate_table('pld_for_format0101');
      mfjpln_truncate.truncate_table('pld_for_format0102');
      mfjpln_truncate.truncate_table('pld_for_format0103');
      mfjpln_truncate.truncate_table('pld_for_format0104');
      commit;

      /**/
      /* Extract the control data */
      /**/
      extractControl;
      commit;

      /**/
      /* Extract the material data */
      /**/
      extractMaterials;
      commit;

      /**/
      /* Extract the forecast data */
      /**/
      extractForecasts;
      commit;

      /**/
      /* Extract the sales data */
      /**/
      extractSales;
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

   /*******************************************************/
   /* This procedure performs the control extract routine */
   /*******************************************************/
   procedure extractControl is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the control extract data */
      /*-*/
      insert into pld_for_format0100
         (extract_date)
         values(sysdate);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extractControl;

   /********************************************************/
   /* This procedure performs the material extract routine */
   /********************************************************/
   procedure extractMaterials is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_found boolean;
      var_wrk_num01 number(4,0);
      var_wrk_num02 number(2,0);
      var_sap_material_code varchar2(18 char);
      var_planning_status varchar2(1 char);
      var_planning_type varchar2(60 char);
      var_planning_cat_old varchar2(1 char);
      var_planning_cat_prv varchar2(1 char);
      var_planning_category varchar2(1 char);
      var_planning_src_unit varchar2(255 char);
      var_channel_id varchar2(20 char);
      var_ld_time number(3,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor mars_date_c01 is 
         select mars_period,
                (year_num * 100) + month_num
           from mars_date
          where to_char(calendar_date,'YYYYMMDD') = to_char(sysdate,'YYYYMMDD');

      cursor material_c01 is
         select t01.sap_material_code,
                to_char(max(t02.status)),
                decode(max(t01.sap_bus_sgmnt_code),'01',decode(max(t02.usernumber_4),1,'Snack Standard', 
                                                                                     2,'Snack Co-Pack', 
                                                                                     3,'Snack Seasonal', 
                                                                                     4,'Snack Bulk',
                                                                                       '**NONE**'),
                                                   '02',decode(max(t02.usernumber_4),1,'Food Standard', 
                                                                                     2,'Food Co-Pack', 
                                                                                     3,'Food Seasonal', 
                                                                                     4,'Food Bulk',
                                                                                       '**NONE**'),
                                                   '05',decode(max(t02.usernumber_4),1,'Pet Import', 
                                                                                     2,'Pet Co-Pack', 
                                                                                     3,'Pet Promotion', 
                                                                                     4,'Pet Bulk',
                                                                                     5,'Kyoritsu',
                                                                                     6,'Kyoritsu Bulk',
                                                                                       '**NONE**')),
                decode(max(t02.usernumber_5),1,'A', 
                                             2,'B', 
                                             3,'C', 
                                             4,'N',
                                               'X'),
                decode(max(t02.usernumber_6),1,'A', 
                                             2,'B', 
                                             3,'C', 
                                             4,'N',
                                               'X'),
                decode(max(t02.usernumber_7),1,'A', 
                                             2,'B', 
                                             3,'C', 
                                             4,'N',
                                               'X'),
                nvl(max(t02.userstring_14),'**NONE**')
           from material_dim t01,
                products_from_mercia t02,
                (select t01.sap_material_code as sap_material_code
                   from material_dim t01,
                        chan_prods_from_mercia t02
                  where t01.sap_material_code = t02.prod_cd
                    and ((t01.sap_bus_sgmnt_code = '01' and
                          t02.chan_id in ('250TL')) or
                         (t01.sap_bus_sgmnt_code = '02' and
                          t02.chan_id in ('JP10')) or
                         (t01.sap_bus_sgmnt_code = '05' and
                          t02.chan_id in ('JP13','JP17','06900')))
                    and t02.ld_time <> 0
                  group by t01.sap_material_code) t03,
                (select t01.sap_material_code as sap_material_code
                   from fcst_plan_period t01,
                        material_dim t02
                  where t01.sap_material_code = t02.sap_material_code
                    and t01.fcst_yyyypp >= var_rolling_yyyypp
                    and t01.fcst_yyyypp <= var_current_yyyypp
                    and t02.sap_material_type_code <> 'ZREP'
                    and ((t02.sap_bus_sgmnt_code = '01' and
                          t01.sap_plant_code <> 'JP13') or
                         t02.sap_bus_sgmnt_code = '02' or
                         (t02.sap_bus_sgmnt_code = '05' and
                          t01.sap_plant_code <> 'JP13'))
                  group by t01.sap_material_code
                 union
                 select t01.sap_material_code as sap_material_code
                   from fcst_plan_month t01,
                        material_dim t02
                  where t01.sap_material_code = t02.sap_material_code
                    and t01.fcst_yyyymm >= var_rolling_yyyymm
                    and t01.fcst_yyyymm <= var_current_yyyymm
                    and t02.sap_material_type_code <> 'ZREP'
                    and (t02.sap_bus_sgmnt_code = '01' or
                         t02.sap_bus_sgmnt_code = '02' or
                         t02.sap_bus_sgmnt_code = '05')
                  group by t01.sap_material_code) t04
          where t01.sap_material_code = t02.prod_cd
            and t01.sap_material_code = t03.sap_material_code
            and t01.sap_material_code = t04.sap_material_code
          group by t01.sap_material_code;

      cursor material_c02 is
         select t01.sap_material_code,
                t03.chan_id,
                max(t03.ld_time)
           from pld_for_format0101 t01,
                material_dim t02,
                chan_prods_from_mercia t03
          where t01.sap_material_code = t02.sap_material_code
            and t02.sap_material_code = t03.prod_cd
            and ((t02.sap_bus_sgmnt_code = '01' and
                  t03.chan_id in ('250TL')) or
                 (t02.sap_bus_sgmnt_code = '02' and
                  t03.chan_id in ('JP10')) or
                 (t02.sap_bus_sgmnt_code = '05' and
                  t03.chan_id in ('JP13','JP17','06900')))
            and t03.ld_time <> 0
          group by t01.sap_material_code,
                   t03.chan_id;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month information date */
      /* **NOTE** based on system date */
      /*-*/
      var_found := true;
      open mars_date_c01;
      fetch mars_date_c01 into var_current_yyyypp,
                               var_current_yyyymm;
      if mars_date_c01%notfound then
         var_found := false;
      end if;
      close mars_date_c01;
      if var_found = false then
         raise_application_error(-20000, 'No mars date found');
      end if;

      /*-*/
      /* Calculate the rolling periods */
      /*-*/
      var_wrk_num01 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),5,2));
      for idx in 1..13 loop
         var_rolling_yyyypp := (var_wrk_num01 * 100) + var_wrk_num02;
         var_wrk_num02 := var_wrk_num02 - 1;
         if var_wrk_num02 <= 0 then
            var_wrk_num01 := var_wrk_num01 - 1;
            var_wrk_num02 := 13;
         end if;
      end loop;

      /*-*/
      /* Calculate the rolling months */
      /*-*/
      var_wrk_num01 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),5,2));
      for idx in 1..12 loop
         var_rolling_yyyymm := (var_wrk_num01 * 100) + var_wrk_num02;
         var_wrk_num02 := var_wrk_num02 - 1;
         if var_wrk_num02 <= 0 then
            var_wrk_num01 := var_wrk_num01 - 1;
            var_wrk_num02 := 12;
         end if;
      end loop;

      /*-*/
      /* Extract the material data */
      /*-*/
      open material_c01;
      loop
         fetch material_c01 into var_sap_material_code,
                                 var_planning_status,
                                 var_planning_type,
                                 var_planning_cat_old,
                                 var_planning_cat_prv,
                                 var_planning_category,
                                 var_planning_src_unit;
         if material_c01%notfound then
            exit;
         end if;
         insert into pld_for_format0101
            (sap_material_code,
             planning_status,
             planning_type,
             planning_cat_old,
             planning_cat_prv,
             planning_category,
             planning_src_unit)
            values(var_sap_material_code,
                   var_planning_status,
                   var_planning_type,
                   var_planning_cat_old,
                   var_planning_cat_prv,
                   var_planning_category,
                   var_planning_src_unit);
      end loop;
      close material_c01;

      /*-*/
      /* Extract the material channel data */
      /*-*/
      open material_c02;
      loop
         fetch material_c02 into var_sap_material_code,
                                 var_channel_id,
                                 var_ld_time;
         if material_c02%notfound then
            exit;
         end if;
         insert into pld_for_format0102
            (sap_material_code,
             channel_id,
             ld_time)
            values(var_sap_material_code,
                   var_channel_id,
                   var_ld_time);
      end loop;
      close material_c02;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extractMaterials;

   /********************************************************/
   /* This procedure performs the forecast extract routine */
   /********************************************************/
   procedure extractForecasts is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_sap_material_code varchar2(18 char);
      var_asof_yyyynn number(6,0);
      var_fcst_yyyynn number(6,0);
      var_fcst_qty number(22,0);
      var_wrk_number number(5,0);
      var_wrk_num01 number(4,0);
      var_wrk_num02 number(2,0);
      var_wrk_yyyynn number(6,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor fcst_prd_c01 is
         select t01.sap_material_code,
                t02.asof_yyyypp,
                t02.fcst_yyyypp,
                t02.fcst_cases,
                t02.wrk_number
           from pld_for_format0101 t01,
                (select t01.sap_material_code as sap_material_code,
                        t01.asof_yyyypp as asof_yyyypp,
                        t01.fcst_yyyypp as fcst_yyyypp,
                        t01.fcst_cases as fcst_cases,
                        ceil((t02.ld_time / 28)) as wrk_number
                   from (select t01.sap_material_code as sap_material_code,
                                t01.asof_yyyypp as asof_yyyypp,
                                t01.fcst_yyyypp as fcst_yyyypp,
                                round(sum(t01.fcst_cases),0) as fcst_cases
                           from fcst_plan_period t01
                          where t01.fcst_yyyypp >= var_rolling_yyyypp
                            and t01.fcst_yyyypp <= var_current_yyyypp
                            and t01.sap_plant_code <> 'JP13'
                          group by t01.sap_material_code,
                                   t01.asof_yyyypp,
                                   t01.fcst_yyyypp
                          order by t01.sap_material_code,
                                   t01.asof_yyyypp,
                                   t01.fcst_yyyypp) t01,
                        (select t01.sap_material_code as sap_material_code,
                                max(t01.ld_time) as ld_time
                           from pld_for_format0102 t01
                          where t01.ld_time <> 0
                          group by t01.sap_material_code
                          order by t01.sap_material_code) t02
                   where t01.sap_material_code = t02.sap_material_code) t02
          where t01.sap_material_code = t02.sap_material_code;

      cursor fcst_mth_c01 is
         select t01.sap_material_code,
                t02.asof_yyyymm,
                t02.fcst_yyyymm,
                t02.fcst_cases,
                t02.wrk_number
           from pld_for_format0101 t01,
                (select t01.sap_material_code as sap_material_code,
                        t01.asof_yyyymm as asof_yyyymm,
                        t01.fcst_yyyymm as fcst_yyyymm,
                        t01.fcst_cases as fcst_cases,
                        ceil((t02.ld_time / 28)) as wrk_number
                   from (select t01.sap_material_code as sap_material_code,
                                t01.asof_yyyymm as asof_yyyymm,
                                t01.fcst_yyyymm as fcst_yyyymm,
                                round(sum(t01.fcst_cases),0) as fcst_cases
                           from fcst_plan_month t01
                          where t01.fcst_yyyymm >= var_rolling_yyyymm
                            and t01.fcst_yyyymm <= var_current_yyyymm
                          group by t01.sap_material_code,
                                   t01.asof_yyyymm,
                                   t01.fcst_yyyymm
                          order by t01.sap_material_code,
                                   t01.asof_yyyymm,
                                   t01.fcst_yyyymm) t01,
                        (select t01.sap_material_code as sap_material_code,
                                max(t01.ld_time) as ld_time
                           from pld_for_format0102 t01
                          where t01.ld_time <> 0
                          group by t01.sap_material_code
                          order by t01.sap_material_code) t02
                   where t01.sap_material_code = t02.sap_material_code) t02
          where t01.sap_material_code = t02.sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the materials period forecasts */
      /*-*/
      open fcst_prd_c01;
      loop
         fetch fcst_prd_c01 into var_sap_material_code,
                                 var_asof_yyyynn,
                                 var_fcst_yyyynn,
                                 var_fcst_qty,
                                 var_wrk_number;
         if fcst_prd_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Calculate the lead time period */
         /*-*/
         var_wrk_yyyynn := var_fcst_yyyynn;
         var_wrk_num01 := to_number(substr(to_char(var_wrk_yyyynn,'FM000000'),1,4));
         var_wrk_num02 := to_number(substr(to_char(var_wrk_yyyynn,'FM000000'),5,2));
         if var_wrk_number <> 0 then
            for idx in 1..var_wrk_number loop
               var_wrk_num02 := var_wrk_num02 - 1;
               if var_wrk_num02 <= 0 then
                  var_wrk_num01 := var_wrk_num01 - 1;
                  var_wrk_num02 := 13;
               end if;
               var_wrk_yyyynn := (var_wrk_num01 * 100) + var_wrk_num02;
            end loop;
         end if;

         /*-*/
         /* Lead time forecast */
         /*-*/
         if var_asof_yyyynn = var_wrk_yyyynn then
            insert into pld_for_format0103
               (sap_material_code,
                asof_yyyypp,
                fcst_yyyypp,
                case_qty)
               values(var_sap_material_code,
                      var_asof_yyyynn, 
                      var_fcst_yyyynn,
                      var_fcst_qty);
         end if;

      end loop;
      close fcst_prd_c01;

      /*-*/
      /* Retrieve the materials month forecasts */
      /*-*/
      open fcst_mth_c01;
      loop
         fetch fcst_mth_c01 into var_sap_material_code,
                                 var_asof_yyyynn,
                                 var_fcst_yyyynn,
                                 var_fcst_qty,
                                 var_wrk_number;
         if fcst_mth_c01%notfound then
            exit;
         end if;

         /*-*/
         /* Calculate the lead time period */
         /*-*/
         var_wrk_yyyynn := var_fcst_yyyynn;
         var_wrk_num01 := to_number(substr(to_char(var_wrk_yyyynn,'FM000000'),1,4));
         var_wrk_num02 := to_number(substr(to_char(var_wrk_yyyynn,'FM000000'),5,2));
         if var_wrk_number <> 0 then
            for idx in 1..var_wrk_number loop
               var_wrk_num02 := var_wrk_num02 - 1;
               if var_wrk_num02 <= 0 then
                  var_wrk_num01 := var_wrk_num01 - 1;
                  var_wrk_num02 := 12;
               end if;
               var_wrk_yyyynn := (var_wrk_num01 * 100) + var_wrk_num02;
            end loop;
         end if;

         /*-*/
         /* Lead time forecast */
         /*-*/
         if var_asof_yyyynn = var_wrk_yyyynn then
            insert into pld_for_format0104
               (sap_material_code,
                asof_yyyymm,
                fcst_yyyymm,
                case_qty)
               values(var_sap_material_code,
                      var_asof_yyyynn, 
                      var_fcst_yyyynn,
                      var_fcst_qty);
         end if;

      end loop;
      close fcst_mth_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extractForecasts;

   /*****************************************************/
   /* This procedure performs the sales extract routine */
   /*****************************************************/
   procedure extractSales is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_str_yyyynn number(6,0);
      var_end_yyyynn number(6,0);
      var_sap_material_code varchar2(18 char);
      var_billing_yyyynn number(6,0);
      var_billed_qty number(22,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor sales_period_01_fact_c01 is 
         select t01.sap_material_code,
                t02.billing_yyyypp,
                sum(nvl(t02.base_uom_billed_qty, 0))
           from pld_for_format0101 t01,
                sales_period_01_fact t02
          where t01.sap_material_code = t02.sap_material_code
            and t02.billing_yyyypp >= var_str_yyyynn
            and t02.billing_yyyypp <= var_end_yyyynn
            and t02.base_uom_billed_qty is not null
            and t02.base_uom_billed_qty <> 0
          group by t01.sap_material_code,
                   t02.billing_yyyypp;

      cursor sales_month_01_fact_c01 is 
         select t01.sap_material_code,
                t02.billing_yyyymm,
                sum(nvl(t02.base_uom_billed_qty, 0))
           from pld_for_format0101 t01,
                sales_month_01_fact t02
          where t01.sap_material_code = t02.sap_material_code
            and t02.billing_yyyymm >= var_str_yyyynn
            and t02.billing_yyyymm <= var_end_yyyynn
            and t02.base_uom_billed_qty is not null
            and t02.base_uom_billed_qty <> 0
          group by t01.sap_material_code,
                   t02.billing_yyyymm;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the start and end forecast periods */
      /*-*/
      select min(fcst_yyyypp) into var_str_yyyynn from pld_for_format0103;
      select max(fcst_yyyypp) into var_end_yyyynn from pld_for_format0103;

      /*-*/
      /* Extract the material period sales value */
      /*-*/
      open sales_period_01_fact_c01;
      loop
         fetch sales_period_01_fact_c01 into var_sap_material_code,
                                             var_billing_yyyynn,
                                             var_billed_qty;
         if sales_period_01_fact_c01%notfound then
            exit;
         end if;
         insert into pld_for_format0103
            (sap_material_code,
             asof_yyyypp,
             fcst_yyyypp,
             case_qty)
            values(var_sap_material_code,
                   999999, 
                   var_billing_yyyynn,
                   var_billed_qty);
      end loop;
      close sales_period_01_fact_c01;

      /*-*/
      /* Retrieve the start and end forecast months */
      /*-*/
      select min(fcst_yyyymm) into var_str_yyyynn from pld_for_format0104;
      select max(fcst_yyyymm) into var_end_yyyynn from pld_for_format0104;
      /*-*/
      /* Extract the material month sales value */
      /*-*/
      open sales_month_01_fact_c01;
      loop
         fetch sales_month_01_fact_c01 into var_sap_material_code,
                                            var_billing_yyyynn,
                                            var_billed_qty;
         if sales_month_01_fact_c01%notfound then
            exit;
         end if;
         insert into pld_for_format0104
            (sap_material_code,
             asof_yyyymm,
             fcst_yyyymm,
             case_qty)
            values(var_sap_material_code,
                   999999, 
                   var_billing_yyyynn,
                   var_billed_qty);
      end loop;
      close sales_month_01_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extractSales;

end mfjpln_for_format01_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_for_format01_extract for pld_rep_app.mfjpln_for_format01_extract;
grant execute on mfjpln_for_format01_extract to public;