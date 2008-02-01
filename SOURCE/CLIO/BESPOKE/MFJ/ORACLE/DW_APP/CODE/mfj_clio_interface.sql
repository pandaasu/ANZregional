/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : mfj_clio_interface
 Owner   : care_mig

 Description
 -----------
 Dimensional Data Store - MFJ CLIO Care Interface

 This package executes the MFJ CLIO Care period and average sales extracts

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfj_clio_interface as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end mfj_clio_interface;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfj_clio_interface as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure load_period_sales(par_period in varchar2);
   procedure load_average_sales(par_period in varchar2);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Execute the required procedures
      /*-*/
      load_period_sales('C');
      load_average_sales('C');
      load_period_sales('P');
      load_average_sales('P');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*********************************************************/
   /* This procedure performs the load period sales routine */
   /*********************************************************/
   procedure load_period_sales(par_period in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_yyyypp number(6,0);
      var_yyyy number(4,0);
      var_pp number(2,0);
      var_work01 number;
      var_work02 number;
      var_work03 number;
      var_work04 number;
      var_work05 number;
      var_work06 number;
      var_work07 number;
      var_work08 number;
      var_work09 number;
      var_work10 number;
      var_work11 number;
      var_work12 number;
      var_work13 number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_period is
         select mars_period
           from mars_date t1
          where to_char(t1.calendar_date,'yyyymmdd') = to_char(sysdate-1,'yyyymmdd');
      rcd_period csr_period%rowtype;

      cursor csr_sales is
         select tcx.csm_prdct_id,
                tcx.spl_id,
                nvl(sum(sp1f.base_uom_billed_qty * tcx.inner_count), 0) sum_cnt
          from care_mig.tdu_csm_xref tcx,
               (select t1.sap_material_code as sap_material_code,
                       sum(t1.base_uom_billed_qty) as base_uom_billed_qty
                  from sales_period_01_fact@ap0093p t1
                 where t1.billing_yyyypp = var_yyyypp
                 group by t1.sap_material_code) sp1f
         where tcx.sap_mtr_code = sp1f.sap_material_code
         group by tcx.csm_prdct_id,
                  tcx.spl_id;
      rcd_sales csr_sales%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and calculate the period
      /*-*/
      open csr_period;
      fetch csr_period into rcd_period;
      close csr_period;
      var_yyyypp := rcd_period.mars_period;
      var_yyyy := to_number(substr(to_char(var_yyyypp,'fm000000'),1,4));
      var_pp := to_number(substr(to_char(var_yyyypp,'fm000000'),5,2));
      if upper(par_period) = 'P' then 
         var_pp := var_pp - 1;
         if var_pp < 1 then
            var_yyyy := var_yyyy - 1;
            var_pp := 13;
         end if;
         var_yyyypp := (var_yyyy * 100) + var_pp;
      end if;

      /*-*/
      /* Retrieve the sales values
      /*-*/
      open csr_sales;
      loop
         fetch csr_sales into rcd_sales;
         if csr_sales%notfound then
            exit;
         end if;

         /*-*/
         /* Set the selected period value
         /*-*/
         var_work01 := 0;
         var_work02 := 0;
         var_work03 := 0;
         var_work04 := 0;
         var_work05 := 0;
         var_work06 := 0;
         var_work07 := 0;
         var_work08 := 0;
         var_work09 := 0;
         var_work10 := 0;
         var_work11 := 0;
         var_work12 := 0;
         var_work13 := 0;
         if var_pp = 1 then
            var_work01 := rcd_sales.sum_cnt;
         elsif var_pp = 2 then
            var_work02 := rcd_sales.sum_cnt;
         elsif var_pp = 3 then
            var_work03 := rcd_sales.sum_cnt;
         elsif var_pp = 4 then
            var_work04 := rcd_sales.sum_cnt;
         elsif var_pp = 5 then
            var_work05 := rcd_sales.sum_cnt;
         elsif var_pp = 6 then
            var_work06 := rcd_sales.sum_cnt;
         elsif var_pp = 7 then
            var_work07 := rcd_sales.sum_cnt;
         elsif var_pp = 8 then
            var_work08 := rcd_sales.sum_cnt;
         elsif var_pp = 9 then
            var_work09 := rcd_sales.sum_cnt;
         elsif var_pp = 10 then
            var_work10 := rcd_sales.sum_cnt;
         elsif var_pp = 11 then
            var_work11 := rcd_sales.sum_cnt;
         elsif var_pp = 12 then
            var_work12 := rcd_sales.sum_cnt;
         elsif var_pp = 13 then
            var_work13 := rcd_sales.sum_cnt;
         end if;

         /*-*/
         /* Update the Care the "SALE" sales values
         /*-*/
         update keyprd
            set kepr_period01_production_cnt = kepr_period01_production_cnt + var_work01,
                kepr_period02_production_cnt = kepr_period02_production_cnt + var_work02,
                kepr_period03_production_cnt = kepr_period03_production_cnt + var_work03,
                kepr_period04_production_cnt = kepr_period04_production_cnt + var_work04,
                kepr_period05_production_cnt = kepr_period05_production_cnt + var_work05,
                kepr_period06_production_cnt = kepr_period06_production_cnt + var_work06,
                kepr_period07_production_cnt = kepr_period07_production_cnt + var_work07,
                kepr_period08_production_cnt = kepr_period08_production_cnt + var_work08,
                kepr_period09_production_cnt = kepr_period09_production_cnt + var_work09,
                kepr_period10_production_cnt = kepr_period10_production_cnt + var_work10,
                kepr_period11_production_cnt = kepr_period11_production_cnt + var_work11,
                kepr_period12_production_cnt = kepr_period12_production_cnt + var_work12,
                kepr_period13_production_cnt = kepr_period13_production_cnt + var_work13,
                kepr_maint_date = to_number(to_char(sysdate, 'yyyymmdd')),
                kepr_maint_time = to_number(to_char(sysdate, 'hh24miss'))
          where ltrim(rtrim(kepr_keyword)) = rcd_sales.csm_prdct_id
            and ltrim(rtrim(kepr_plant)) = rcd_sales.spl_id
            and kepr_production_year = var_yyyy
            and kepr_sub_type = 'SALE';
         if sql%notfound then
            insert into keyprd
               (kepr_keyword,
                kepr_type,
                kepr_sub_type,
                kepr_category,
                kepr_production_year,
                kepr_plant,
                kepr_filler,
                kepr_lag_time,
                kepr_units,
                kepr_period01_production_cnt,
                kepr_period02_production_cnt,
                kepr_period03_production_cnt,
                kepr_period04_production_cnt,
                kepr_period05_production_cnt,
                kepr_period06_production_cnt,
                kepr_period07_production_cnt,
                kepr_period08_production_cnt,
                kepr_period09_production_cnt,
                kepr_period10_production_cnt,
                kepr_period11_production_cnt,
                kepr_period12_production_cnt,
                kepr_period13_production_cnt,
                kepr_maint_user,
                kepr_maint_date,
                kepr_maint_time)
               values (rcd_sales.csm_prdct_id,
                      'PROD',
                      'SALE',
                      '          ',
                      var_yyyy,
                      rcd_sales.spl_id,
                      '          ',
                      0,
                      1,
                      var_work01,
                      var_work02,
                      var_work03,
                      var_work04,
                      var_work05,
                      var_work06,
                      var_work07,
                      var_work08,
                      var_work09,
                      var_work10,
                      var_work11,
                      var_work12,
                      var_work13,
                      'CARE_MIG',
                      to_number(to_char(sysdate, 'yyyymmdd')),
                      to_number(to_char(sysdate, 'hh24miss')));
         end if;

      end loop;
      close csr_sales;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_period_sales;

   /**********************************************************/
   /* This procedure performs the load average sales routine */
   /**********************************************************/
   procedure load_average_sales(par_period in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_yyyypp number(6,0);
      var_yyyy number(4,0);
      var_pp number(2,0);
      var_backpp number(2,0);
      var_frompp number(6,0);
      var_work01 number;
      var_work02 number;
      var_work03 number;
      var_work04 number;
      var_work05 number;
      var_work06 number;
      var_work07 number;
      var_work08 number;
      var_work09 number;
      var_work10 number;
      var_work11 number;
      var_work12 number;
      var_work13 number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_period is
         select mars_period
           from mars_date t1
          where to_char(t1.calendar_date,'yyyymmdd') = to_char(sysdate-1,'yyyymmdd');
      rcd_period csr_period%rowtype;

      cursor csr_sales is
         select tcx.csm_prdct_id,
                tcx.spl_id,
                round(nvl(sum(sp1f.base_uom_billed_qty * tcx.inner_count), 0) / 5, 0) sum_cnt
          from care_mig.tdu_csm_xref tcx,
               (select t1.sap_material_code as sap_material_code,
                       sum(t1.base_uom_billed_qty) as base_uom_billed_qty
                  from sales_period_01_fact@ap0093p t1
                 where t1.billing_yyyypp >= var_frompp
                   and t1.billing_yyyypp <= var_yyyypp
                 group by t1.sap_material_code) sp1f
         where tcx.sap_mtr_code = sp1f.sap_material_code
         group by tcx.csm_prdct_id,
                  tcx.spl_id;
      rcd_sales csr_sales%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve and calculate the period
      /*-*/
      open csr_period;
      fetch csr_period into rcd_period;
      close csr_period;
      var_yyyypp := rcd_period.mars_period;
      var_yyyy := to_number(substr(to_char(var_yyyypp,'fm000000'),1,4));
      var_pp := to_number(substr(to_char(var_yyyypp,'fm000000'),5,2));
      if upper(par_period) = 'P' then 
         var_pp := var_pp - 1;
         if var_pp < 1 then
            var_yyyy := var_yyyy - 1;
            var_pp := 13;
         end if;
         var_yyyypp := (var_yyyy * 100) + var_pp;
      end if;

      /*-*/
      /* Calculate the from period (last 5 periods)
      /*-*/
      var_backpp := var_pp - 4;
      if var_backpp < 1 then
         var_yyyy := var_yyyy - 1;
         var_backpp := 13 + var_backpp;
      end if;
      var_frompp := (var_yyyy * 100) + var_backpp;

      /*-*/
      /* Retrieve the sales values
      /*-*/
      open csr_sales;
      loop
         fetch csr_sales into rcd_sales;
         if csr_sales%notfound then
            exit;
         end if;

         /*-*/
         /* Set the selected period value
         /*-*/
         var_work01 := 0;
         var_work02 := 0;
         var_work03 := 0;
         var_work04 := 0;
         var_work05 := 0;
         var_work06 := 0;
         var_work07 := 0;
         var_work08 := 0;
         var_work09 := 0;
         var_work10 := 0;
         var_work11 := 0;
         var_work12 := 0;
         var_work13 := 0;
         if var_pp = 1 then
            var_work01 := rcd_sales.sum_cnt;
         elsif var_pp = 2 then
            var_work02 := rcd_sales.sum_cnt;
         elsif var_pp = 3 then
            var_work03 := rcd_sales.sum_cnt;
         elsif var_pp = 4 then
            var_work04 := rcd_sales.sum_cnt;
         elsif var_pp = 5 then
            var_work05 := rcd_sales.sum_cnt;
         elsif var_pp = 6 then
            var_work06 := rcd_sales.sum_cnt;
         elsif var_pp = 7 then
            var_work07 := rcd_sales.sum_cnt;
         elsif var_pp = 8 then
            var_work08 := rcd_sales.sum_cnt;
         elsif var_pp = 9 then
            var_work09 := rcd_sales.sum_cnt;
         elsif var_pp = 10 then
            var_work10 := rcd_sales.sum_cnt;
         elsif var_pp = 11 then
            var_work11 := rcd_sales.sum_cnt;
         elsif var_pp = 12 then
            var_work12 := rcd_sales.sum_cnt;
         elsif var_pp = 13 then
            var_work13 := rcd_sales.sum_cnt;
         end if;

         /*-*/
         /* Update the Care the "5PAVE" sales values
         /*-*/
         update keyprd
            set kepr_period01_production_cnt = kepr_period01_production_cnt + var_work01,
                kepr_period02_production_cnt = kepr_period02_production_cnt + var_work02,
                kepr_period03_production_cnt = kepr_period03_production_cnt + var_work03,
                kepr_period04_production_cnt = kepr_period04_production_cnt + var_work04,
                kepr_period05_production_cnt = kepr_period05_production_cnt + var_work05,
                kepr_period06_production_cnt = kepr_period06_production_cnt + var_work06,
                kepr_period07_production_cnt = kepr_period07_production_cnt + var_work07,
                kepr_period08_production_cnt = kepr_period08_production_cnt + var_work08,
                kepr_period09_production_cnt = kepr_period09_production_cnt + var_work09,
                kepr_period10_production_cnt = kepr_period10_production_cnt + var_work10,
                kepr_period11_production_cnt = kepr_period11_production_cnt + var_work11,
                kepr_period12_production_cnt = kepr_period12_production_cnt + var_work12,
                kepr_period13_production_cnt = kepr_period13_production_cnt + var_work13,
                kepr_maint_date = to_number(to_char(sysdate, 'yyyymmdd')),
                kepr_maint_time = to_number(to_char(sysdate, 'hh24miss'))
          where ltrim(rtrim(kepr_keyword)) = rcd_sales.csm_prdct_id
            and ltrim(rtrim(kepr_plant)) = rcd_sales.spl_id
            and kepr_production_year = var_yyyy
            and kepr_sub_type = '5PAVE';
         if sql%notfound then
            insert into keyprd
               (kepr_keyword,
                kepr_type,
                kepr_sub_type,
                kepr_category,
                kepr_production_year,
                kepr_plant,
                kepr_filler,
                kepr_lag_time,
                kepr_units,
                kepr_period01_production_cnt,
                kepr_period02_production_cnt,
                kepr_period03_production_cnt,
                kepr_period04_production_cnt,
                kepr_period05_production_cnt,
                kepr_period06_production_cnt,
                kepr_period07_production_cnt,
                kepr_period08_production_cnt,
                kepr_period09_production_cnt,
                kepr_period10_production_cnt,
                kepr_period11_production_cnt,
                kepr_period12_production_cnt,
                kepr_period13_production_cnt,
                kepr_maint_user,
                kepr_maint_date,
                kepr_maint_time)
               values (rcd_sales.csm_prdct_id,
                      'PROD',
                      '5PAVE',
                      '          ',
                      var_yyyy,
                      rcd_sales.spl_id,
                      '          ',
                      0,
                      1,
                      var_work01,
                      var_work02,
                      var_work03,
                      var_work04,
                      var_work05,
                      var_work06,
                      var_work07,
                      var_work08,
                      var_work09,
                      var_work10,
                      var_work11,
                      var_work12,
                      var_work13,
                      'CARE_MIG',
                      to_number(to_char(sysdate, 'yyyymmdd')),
                      to_number(to_char(sysdate, 'hh24miss')));
         end if;

      end loop;
      close csr_sales;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_average_sales;

end mfj_clio_interface;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
grant execute on mfj_clio_interface to public;
