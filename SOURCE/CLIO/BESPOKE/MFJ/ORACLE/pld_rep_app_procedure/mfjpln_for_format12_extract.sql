/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_for_format12_extract                        */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : October 2005                                       */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_for_format12_extract as

/**DESCRIPTION**
 Forecast Extract - SAP billing date aggregations.

 Extracts the forecast and sales information at the material level for
 the planning forecast reports. This extract is executed on a daily
 basis to be available for reporting. The data is extract from the
 Data Warehouse database.

 **PARAMETERS**
 None

 **NOTES**
 none

 YYYY/MM   Author         Description
 -------   ------         -----------
 2003/09   Steve Gregan   Created
 2006/12   Steve Gregan   Replaced Mercia references with new CLIO table
 2007/03   Steve Gregan   Changed planning type descriptions
 2007/05   Steve Gregan   Fixed casting period 13 issue

**/

   /*-*/
   /* Public declarations */
   /*-*/
   function main return varchar2;

end mfjpln_for_format12_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_for_format12_extract as

   /*-*/
   /* Private global declarations */
   /*-*/
   procedure extractControl;
   procedure extractMaterials;
   procedure extractForecasts;
   procedure extractSales;

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
      mfjpln_truncate.truncate_table('pld_for_format1200');
      mfjpln_truncate.truncate_table('pld_for_format1201');
      mfjpln_truncate.truncate_table('pld_for_format1202');
      mfjpln_truncate.truncate_table('pld_for_format1203');
      mfjpln_truncate.truncate_table('pld_for_format1204');
      commit;

      /**/
      /* Extract the control data */
      /**/
      extractControl;
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

      /**/
      /* Extract the material data */
      /**/
      extractMaterials;
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
      insert into pld_for_format1200
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
      var_sap_material_code varchar2(18 char);
      var_planning_status varchar2(1 char);
      var_planning_type varchar2(60 char);
      var_planning_cat_old varchar2(1 char);
      var_planning_cat_prv varchar2(1 char);
      var_planning_category varchar2(1 char);
      var_planning_src_unit varchar2(255 char);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor material_c01 is
         select t01.sap_material_code,
                to_char(max(t02.planning_status)),
                decode(max(t01.sap_bus_sgmnt_code),'01',decode(max(t02.planning_type),1,'Snack Teiban', 
                                                                                      2,'Snack Tokubai', 
                                                                                      3,'Snack Chain', 
                                                                                        '**NONE**'),
                                                   '02',decode(max(t02.planning_type),1,'Food Standard', 
                                                                                      2,'Food Co-Pack', 
                                                                                      3,'Food Seasonal', 
                                                                                      4,'Food Bulk',
                                                                                        '**NONE**'),
                                                   '05',decode(max(t02.planning_type),1,'Pet Teiban', 
                                                                                      2,'Pet Tokubai', 
                                                                                        '**NONE**')),
                decode(max(t02.planning_cat_old),1,'A', 
                                                 2,'B', 
                                                 3,'C', 
                                                 4,'N',
                                                   'X'),
                decode(max(t02.planning_cat_prv),1,'A', 
                                                 2,'B', 
                                                 3,'C', 
                                                 4,'N',
                                                   'X'),
                decode(max(t02.planning_category),1,'A', 
                                                  2,'B', 
                                                  3,'C', 
                                                  4,'N',
                                                    'X'),
                nvl(max(t02.planning_src_unit),'**NONE**')
           from material_dim t01,
                fcst_material t02,
                (select distinct(t01.sap_material_code) as sap_material_code
                   from pld_for_format1203 t01
                 union
                 select distinct(t01.sap_material_code) as sap_material_code
                   from pld_for_format1204 t01) t03
          where t01.sap_material_code = t02.sap_material_code
            and t01.sap_material_code = t03.sap_material_code
          group by t01.sap_material_code;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

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
         insert into pld_for_format1201
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
      var_found boolean;
      var_wrk_num01 number(4,0);
      var_wrk_num02 number(2,0);
      var_current_yyyypp number(6,0);
      var_current_yyyymm number(6,0);
      var_rolling_yyyypp number(6,0);
      var_rolling_yyyymm number(6,0);
      var_sap_material_code varchar2(18 char);
      var_casting_yyyynn number(6,0);
      var_fcst_yyyynn number(6,0);
      var_fcst_qty number(22,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor fcst_period_c01 is
         select t01.sap_material_code, 
                decode(mod(t01.casting_yyyypp,100),13,t01.casting_yyyypp+87,t01.casting_yyyypp) as casting_yyyypp,
                t01.fcst_yyyypp,
                sum(t01.fcst_qty)
           from fcst_period t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code
            and t01.fcst_type_code = 3
            and ((t02.sap_bus_sgmnt_code = '05' and
                  ((t01.fcst_price_type_code = 1 and t01.casting_yyyypp <= 200309) or
                   (t01.fcst_price_type_code = 2 and t01.casting_yyyypp > 200309))) or
                 (t02.sap_bus_sgmnt_code <> '05' and
                  t01.fcst_price_type_code = 1)) 
            and t01.fcst_yyyypp >= var_rolling_yyyypp
            and t01.fcst_yyyypp <= var_current_yyyypp
            and t02.sap_material_type_code <> 'ZREP'
            and (t02.sap_bus_sgmnt_code = '01' or
                 t02.sap_bus_sgmnt_code = '02' or
                 t02.sap_bus_sgmnt_code = '05')
          group by t01.sap_material_code,
                   decode(mod(t01.casting_yyyypp,100),13,t01.casting_yyyypp+87,t01.casting_yyyypp),
                   t01.fcst_yyyypp;

      cursor fcst_month_c01 is 
         select t01.sap_material_code, 
                decode(mod(t01.casting_yyyymm,100),12,t01.casting_yyyymm+88,t01.casting_yyyymm) as casting_yyyymm,
                t01.fcst_yyyymm,
                sum(t01.fcst_qty)
           from fcst_month t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code
            and t01.fcst_type_code = 1
            and t01.fcst_price_type_code = 1
            and t01.fcst_yyyymm >= var_rolling_yyyymm
            and t01.fcst_yyyymm <= var_current_yyyymm
            and t02.sap_material_type_code <> 'ZREP'
            and (t02.sap_bus_sgmnt_code = '01' or
                 t02.sap_bus_sgmnt_code = '02' or
                 t02.sap_bus_sgmnt_code = '05')
          group by t01.sap_material_code,
                   decode(mod(t01.casting_yyyymm,100),12,t01.casting_yyyymm+88,t01.casting_yyyymm),
                   t01.fcst_yyyymm;

      cursor mars_date_c01 is 
         select mars_period,
                (year_num * 100) + month_num
           from mars_date
          where to_char(calendar_date,'YYYYMMDD') = to_char(sysdate,'YYYYMMDD');

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
      /* Calculate the rolling period range (rolling 26 periods) */
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
      var_wrk_num01 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),5,2));
      for idx in 1..13 loop
         var_current_yyyypp := (var_wrk_num01 * 100) + var_wrk_num02;
         var_wrk_num02 := var_wrk_num02 + 1;
         if var_wrk_num02 > 13 then
            var_wrk_num01 := var_wrk_num01 + 1;
            var_wrk_num02 := 1;
         end if;
      end loop;

      /*-*/
      /* Calculate the rolling month range (rolling 24 months)*/
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
      var_wrk_num01 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),5,2));
      for idx in 1..12 loop
         var_current_yyyymm := (var_wrk_num01 * 100) + var_wrk_num02;
         var_wrk_num02 := var_wrk_num02 + 1;
         if var_wrk_num02 > 12 then
            var_wrk_num01 := var_wrk_num01 + 1;
            var_wrk_num02 := 1;
         end if;
      end loop;

      /*-*/
      /* Extract the material period forecast values */
      /* **note** the casting_yyyypp is zero based and must be converted to one based */
      /* **note** the GSV price type is used (200310 forwards) */
      /* **note** the BPS price type is used (200309 backwards) */
      /*-*/
      open fcst_period_c01;
      loop
         fetch fcst_period_c01 into var_sap_material_code,
                                    var_casting_yyyynn,
                                    var_fcst_yyyynn,
                                    var_fcst_qty;
         if fcst_period_c01%notfound then
            exit;
         end if;
         insert into pld_for_format1203
            (sap_material_code,
             casting_yyyypp,
             fcst_yyyypp,
             case_qty)
            values(var_sap_material_code,
                   var_casting_yyyynn + 1, 
                   var_fcst_yyyynn,
                   var_fcst_qty);
      end loop;
      close fcst_period_c01;

      /*-*/
      /* Extract the material month forecast values */
      /* **note** the casting_yyyymm is zero based and must be converted to one based */
      /* **note** the BPS price type is used */
      /*-*/
      open fcst_month_c01;
      loop
         fetch fcst_month_c01 into var_sap_material_code,
                                   var_casting_yyyynn,
                                   var_fcst_yyyynn,
                                   var_fcst_qty;
         if fcst_month_c01%notfound then
            exit;
         end if;
         insert into pld_for_format1204
            (sap_material_code,
             casting_yyyymm,
             fcst_yyyymm,
             case_qty)
            values(var_sap_material_code,
                   var_casting_yyyynn + 1, 
                   var_fcst_yyyynn,
                   var_fcst_qty);
      end loop;
      close fcst_month_c01;

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
      var_found boolean;
      var_wrk_num01 number(4,0);
      var_wrk_num02 number(2,0);
      var_current_yyyypp number(6,0);
      var_current_yyyymm number(6,0);
      var_rolling_yyyypp number(6,0);
      var_rolling_yyyymm number(6,0);
      var_sap_material_code varchar2(18 char);
      var_billing_yyyynn number(6,0);
      var_billed_qty number(22,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor sales_period_03_fact_c01 is 
         select t01.sap_material_code,
                t01.sap_billing_yyyypp,
                sum(nvl(t01.base_uom_billed_qty, 0))
           from sales_period_03_fact t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code
            and t01.sap_billing_yyyypp >= var_rolling_yyyypp
            and t01.sap_billing_yyyypp <= var_current_yyyypp
            and t01.base_uom_billed_qty is not null
            and t01.base_uom_billed_qty <> 0
            and t02.sap_material_type_code <> 'ZREP'
            and (t02.sap_bus_sgmnt_code = '01' or
                 t02.sap_bus_sgmnt_code = '02' or
                 t02.sap_bus_sgmnt_code = '05')
          group by t01.sap_material_code,
                   t01.sap_billing_yyyypp;

      cursor sales_month_04_fact_c01 is 
         select t01.sap_material_code,
                t01.sap_billing_yyyymm,
                sum(nvl(t01.base_uom_billed_qty, 0))
           from sales_month_04_fact t01,
                material_dim t02
          where t01.sap_material_code = t02.sap_material_code
            and t01.sap_billing_yyyymm >= var_rolling_yyyymm
            and t01.sap_billing_yyyymm <= var_current_yyyymm
            and t01.base_uom_billed_qty is not null
            and t01.base_uom_billed_qty <> 0
            and t02.sap_material_type_code <> 'ZREP'
            and (t02.sap_bus_sgmnt_code = '01' or
                 t02.sap_bus_sgmnt_code = '02' or
                 t02.sap_bus_sgmnt_code = '05')
          group by t01.sap_material_code,
                   t01.sap_billing_yyyymm;

      cursor mars_date_c01 is 
         select mars_period,
                (year_num * 100) + month_num
           from mars_date
          where to_char(calendar_date,'YYYYMMDD') = to_char(sysdate,'YYYYMMDD');

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
      /* Calculate the rolling period range (rolling 26 periods) */
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
      var_wrk_num01 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_current_yyyypp,'FM000000'),5,2));
      for idx in 1..13 loop
         var_current_yyyypp := (var_wrk_num01 * 100) + var_wrk_num02;
         var_wrk_num02 := var_wrk_num02 + 1;
         if var_wrk_num02 > 13 then
            var_wrk_num01 := var_wrk_num01 + 1;
            var_wrk_num02 := 1;
         end if;
      end loop;

      /*-*/
      /* Calculate the rolling month range (rolling 24 months)*/
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
      var_wrk_num01 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),1,4));
      var_wrk_num02 := to_number(substr(to_char(var_current_yyyymm,'FM000000'),5,2));
      for idx in 1..12 loop
         var_current_yyyymm := (var_wrk_num01 * 100) + var_wrk_num02;
         var_wrk_num02 := var_wrk_num02 + 1;
         if var_wrk_num02 > 12 then
            var_wrk_num01 := var_wrk_num01 + 1;
            var_wrk_num02 := 1;
         end if;
      end loop;

      /*-*/
      /* Extract the material period sales value */
      /*-*/
      open sales_period_03_fact_c01;
      loop
         fetch sales_period_03_fact_c01 into var_sap_material_code,
                                             var_billing_yyyynn,
                                             var_billed_qty;
         if sales_period_03_fact_c01%notfound then
            exit;
         end if;
         insert into pld_for_format1203
            (sap_material_code,
             casting_yyyypp,
             fcst_yyyypp,
             case_qty)
            values(var_sap_material_code,
                   999999, 
                   var_billing_yyyynn,
                   var_billed_qty);
      end loop;
      close sales_period_03_fact_c01;

      /*-*/
      /* Extract the material month sales value */
      /*-*/
      open sales_month_04_fact_c01;
      loop
         fetch sales_month_04_fact_c01 into var_sap_material_code,
                                            var_billing_yyyynn,
                                            var_billed_qty;
         if sales_month_04_fact_c01%notfound then
            exit;
         end if;
         insert into pld_for_format1204
            (sap_material_code,
             casting_yyyymm,
             fcst_yyyymm,
             case_qty)
            values(var_sap_material_code,
                   999999, 
                   var_billing_yyyynn,
                   var_billed_qty);
      end loop;
      close sales_month_04_fact_c01;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extractSales;

end mfjpln_for_format12_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_for_format12_extract for pld_rep_app.mfjpln_for_format12_extract;
grant execute on mfjpln_for_format12_extract to public;