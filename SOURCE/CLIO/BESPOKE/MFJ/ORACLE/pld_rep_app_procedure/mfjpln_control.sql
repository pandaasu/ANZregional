/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_control                                     */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_control as

/**DESCRIPTION**
 Planning Reports - Control Information

 This package retrieves the control information for the Planning Reports.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2003/06   Steve Gregan   Created
 2005/10   Steve Gregan   Added dimension parameter for time selection

**/

   /*-*/
   /* Public declarations
   /*-*/
   procedure main(par_dimension in varchar2,
                  par_date in date,
                  par_work_day in boolean,
                  par_work_date out date,
                  par_YYYYPP out number,
                  par_prd_asofdays out varchar2,
                  par_prd_percent out number,
                  par_YYYYMM out number,
                  par_mth_asofdays out varchar2,
                  par_mth_percent out number,
                  par_extract_status out varchar2,
                  par_inventory_date out date,
                  par_inventory_status out varchar2,
                  par_sales_date out date,
                  par_sales_status out varchar2);
   function previousPeriod(par_YYYYPP in number, par_roll_year boolean) return number;
   function previousPeriodStart(par_YYYYPP in number, par_roll_year boolean) return number;
   function previousPeriodEnd(par_YYYYPP in number, par_roll_year boolean) return number;
   function previousMonth(par_YYYYMM in number, par_roll_year boolean) return number;
   function previousMonthStart(par_YYYYMM in number, par_roll_year boolean) return number;
   function previousMonthEnd(par_YYYYMM in number, par_roll_year boolean) return number;

end mfjpln_control;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_control as

   /********************************************/
   /* This procedure performs the main routine */
   /********************************************/
   procedure main(par_dimension in varchar2,
                  par_date in date,
                  par_work_day in boolean,
                  par_work_date out date,
                  par_YYYYPP out number,
                  par_prd_asofdays out varchar2,
                  par_prd_percent out number,
                  par_YYYYMM out number,
                  par_mth_asofdays out varchar2,
                  par_mth_percent out number,
                  par_extract_status out varchar2,
                  par_inventory_date out date,
                  par_inventory_status out varchar2,
                  par_sales_date out date,
                  par_sales_status out varchar2) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_work_date date;
      var_current_YYYYPP number(6,0);
      var_current_YYYYMM number(6,0);
      var_period_bus_day_num number(2,0);
      var_prd_wrk_days number(5,0);
      var_prd_hol_days number(5,0);
      var_mth_day_num number(5,0);
      var_mth_wrk_days number(5,0);
      var_mth_hol_days number(5,0);
      var_prd_asofdays varchar2(128);
      var_prd_percent number(5,2);
      var_mth_asofdays varchar2(128 char);
      var_mth_percent number(5,2);
      var_extract_status varchar2(256 char);
      var_inventory_date date;
      var_inventory_status varchar2(1024 char);
      var_sales_date date;
      var_sales_status varchar2(1024 char);
      var_found boolean;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor mars_date_c01 is 
         select mars_period,
                (year_num * 100) + month_num,
                period_bus_day_num
           from mars_date
          where to_char(calendar_date,'YYYYMMDD') = to_char(var_work_date,'YYYYMMDD');

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Adjust the date for last working day when required
      /* 1. Invoice - move the date back to Friday when Saturday or Sunday
      /* 2. Billed - move the date back to Saturday when Sunday
      /* **NOTE** Day 1 = Sunday
      /*-*/
      var_work_date := par_date;
      if par_work_day = true then
         if upper(par_dimension) = '*INV' then
            if to_number(to_char(par_date,'d')) = 1 then
               var_work_date := var_work_date - 2;
            end if;
            if to_number(to_char(par_date,'d')) = 7 then
               var_work_date := var_work_date - 1;
            end if;
         else
            if to_number(to_char(par_date,'d')) = 1 then
               var_work_date := var_work_date - 1;
            end if;
         end if;
      end if;

      /*-*/
      /* Retrieve the current period and month information date
      /* **NOTE** based on adjusted parameter date
      /*-*/
      var_found := true;
      open mars_date_c01;
      fetch mars_date_c01 into var_current_YYYYPP,
                               var_current_YYYYMM,
                               var_period_bus_day_num;
      if mars_date_c01%notfound then
         var_found := false;
      end if;
      close mars_date_c01;
      if var_found = false then
         raise_application_error(-20000, 'No mars date found');
      end if;

      /*-*/
      /* Retrieve the period percentage
      /* 1. Invoice - use MARS_DATE calendar (20 working days)
      /* 2. Billed - calculate based on 24 working days
      /*-*/
      if upper(par_dimension) = '*INV' then
         select max(period_bus_day_num) into var_prd_wrk_days
            from mars_date
            where mars_period = var_current_YYYYPP;
      else
         select count(*) into var_period_bus_day_num 
            from mars_date
            where mars_period = var_current_YYYYPP
              and to_char(calendar_date,'YYYYMMDD') <= to_char(var_work_date,'YYYYMMDD')
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6,7);
         select count(*) into var_prd_wrk_days
            from mars_date
            where mars_period = var_current_YYYYPP
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6,7);
      end if;
      select count(*) into var_prd_hol_days
         from mars_holiday
         where moe_code = 'MFJ'
           and calendar_date in 
            (select calendar_date from mars_date
                where mars_period = var_current_YYYYPP);
      var_prd_percent := round((var_period_bus_day_num / (var_prd_wrk_days - var_prd_hol_days)) * 100, 2);

      /*-*/
      /* Retrieve the month percentage
      /* 1. Invoice - calculate based on 20 working days
      /* 2. Billed - calculate based on 24 working days
      /*-*/
      if upper(par_dimension) = '*INV' then
         select count(*) into var_mth_day_num 
            from mars_date
            where to_char(calendar_date,'YYYYMM') = var_current_YYYYMM
              and to_char(calendar_date,'YYYYMMDD') <= to_char(var_work_date,'YYYYMMDD')
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6);
         select count(*) into var_mth_wrk_days
            from mars_date
            where to_char(calendar_date,'YYYYMM') = var_current_YYYYMM
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6);
      else
         select count(*) into var_mth_day_num 
            from mars_date
            where to_char(calendar_date,'YYYYMM') = var_current_YYYYMM
              and to_char(calendar_date,'YYYYMMDD') <= to_char(var_work_date,'YYYYMMDD')
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6,7);
         select count(*) into var_mth_wrk_days
            from mars_date
            where to_char(calendar_date,'YYYYMM') = var_current_YYYYMM
              and to_number(to_char(calendar_date,'d')) in (2,3,4,5,6,7);
      end if;
      select count(*) into var_mth_hol_days
         from mars_holiday
         where moe_code = 'MFJ'
           and calendar_date in 
            (select calendar_date from mars_date
                where (year_num * 100) + month_num = var_current_YYYYMM);
      var_mth_percent := round((var_mth_day_num / (var_mth_wrk_days - var_mth_hol_days)) * 100, 2);

      /*-*/
      /* Retrieve the as of days literals
      /*-*/
      var_prd_asofdays := 'Current Period: ' || substr(to_char(var_current_YYYYPP,'FM099999'),1,4) || '/' || substr(to_char(var_current_YYYYPP,'FM099999'),5,2) ||
                          ' Current Date: ' || to_char(var_work_date,'DD/MM/YYYY') ||
                          ' Working Day: ' || to_char(var_period_bus_day_num,'FM99') || ' of ' || to_char(var_prd_wrk_days,'FM99') ||
                          ' (' || to_char(var_prd_percent,'FM990.00') || '%)';
      var_mth_asofdays := 'Current Month: ' || substr(to_char(var_current_YYYYMM,'FM099999'),1,4) || '/' || substr(to_char(var_current_YYYYMM,'FM099999'),5,2) ||
                          ' Current Date: ' || to_char(var_work_date,'DD/MM/YYYY') ||
                          ' Working Day: ' || to_char(var_mth_day_num,'FM99') || ' of ' || to_char(var_mth_wrk_days,'FM99') ||
                          ' (' || to_char(var_mth_percent,'FM990.00') || '%)';

      /*-*/
      /* Set the extract status
      /*-*/
      var_extract_status := 'Creation Date: ' || to_char(sysdate,'YYYY/MM/DD') || ' As Of Date: ' || to_char(var_work_date,'YYYY/MM/DD');

      /*-*/
      /* Retrieve the inventory status
      /*-*/
      dw_reconciliation.inventory_status(var_inventory_date, var_inventory_status);

      /*-*/
      /* Retrieve the sales status
      /*-*/
      dw_reconciliation.sales_status(var_sales_date, var_sales_status);

      /*-*/
      /* Set the return parameters
      /*-*/
      par_work_date := var_work_date;
      par_YYYYPP := var_current_YYYYPP;
      par_prd_asofdays := var_prd_asofdays;
      par_prd_percent := var_prd_percent;
      par_YYYYMM := var_current_YYYYMM;
      par_mth_asofdays := var_mth_asofdays;
      par_mth_percent := var_mth_percent;
      par_extract_status := var_extract_status;
      par_inventory_date := var_inventory_date;
      par_inventory_status := substr(var_inventory_status,1,256);
      par_sales_date := var_sales_date;
      par_sales_status := substr(var_sales_status,1,256);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end main;

   /*******************************************************/
   /* This procedure performs the previous period routine */
   /*******************************************************/
   function previousPeriod(par_YYYYPP in number, par_roll_year boolean) return number is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_YYYYPP number(6,0);
      var_YYYY number(4,0);
      var_PP number(2,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate and return the previous period */
      /**/
      var_YYYY := to_number(substr(to_char(par_YYYYPP,'FM000000'),1,4));
      var_PP := to_number(substr(to_char(par_YYYYPP,'FM000000'),5,2)) - 1;
      if var_PP < 1 and par_roll_year = true then
         var_YYYY := var_YYYY - 1;
         var_PP := 13;
      end if;
      var_YYYYPP := (var_YYYY * 100) + var_PP;
      return var_YYYYPP;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end previousPeriod;

   /*************************************************************/
   /* This procedure performs the previous period start routine */
   /*************************************************************/
   function previousPeriodStart(par_YYYYPP in number, par_roll_year boolean) return number is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_YYYYPP number(6,0);
      var_YYYY number(4,0);
      var_PP number(2,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate and return the previous period start of year*/
      /**/
      var_YYYY := to_number(substr(to_char(par_YYYYPP,'FM000000'),1,4));
      var_PP := to_number(substr(to_char(par_YYYYPP,'FM000000'),5,2)) - 1;
      if var_PP < 1 and par_roll_year = true then
         var_YYYY := var_YYYY - 1;
      end if;
      var_YYYYPP := (var_YYYY * 100) + 1;
      return var_YYYYPP;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end previousPeriodStart;

   /***********************************************************/
   /* This procedure performs the previous period end routine */
   /***********************************************************/
   function previousPeriodEnd(par_YYYYPP in number, par_roll_year boolean) return number is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_YYYYPP number(6,0);
      var_YYYY number(4,0);
      var_PP number(2,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate and return the previous period end of year*/
      /**/
      var_YYYY := to_number(substr(to_char(par_YYYYPP,'FM000000'),1,4));
      var_PP := to_number(substr(to_char(par_YYYYPP,'FM000000'),5,2)) - 1;
      if var_PP < 1 and par_roll_year = true then
         var_YYYY := var_YYYY - 1;
      end if;
      var_YYYYPP := (var_YYYY * 100) + 13;
      return var_YYYYPP;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end previousPeriodEnd;

   /******************************************************/
   /* This procedure performs the previous month routine */
   /******************************************************/
   function previousMonth(par_YYYYMM in number, par_roll_year boolean) return number is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_YYYYMM number(6,0);
      var_YYYY number(4,0);
      var_MM number(2,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate and return the previous month */
      /**/
      var_YYYY := to_number(substr(to_char(par_YYYYMM,'FM000000'),1,4));
      var_MM := to_number(substr(to_char(par_YYYYMM,'FM000000'),5,2)) - 1;
      if var_MM < 1 and par_roll_year = true then
         var_YYYY := var_YYYY - 1;
         var_MM := 12;
      end if;
      var_YYYYMM := (var_YYYY * 100) + var_MM;
      return var_YYYYMM;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end previousMonth;

   /************************************************************/
   /* This procedure performs the previous month start routine */
   /************************************************************/
   function previousMonthStart(par_YYYYMM in number, par_roll_year boolean) return number is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_YYYYMM number(6,0);
      var_YYYY number(4,0);
      var_MM number(2,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate and return the previous month start of year*/
      /**/
      var_YYYY := to_number(substr(to_char(par_YYYYMM,'FM000000'),1,4));
      var_MM := to_number(substr(to_char(par_YYYYMM,'FM000000'),5,2)) - 1;
      if var_MM < 1 and par_roll_year = true then
         var_YYYY := var_YYYY - 1;
      end if;
      var_YYYYMM := (var_YYYY * 100) + 1;
      return var_YYYYMM;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end previousMonthStart;

   /**********************************************************/
   /* This procedure performs the previous month end routine */
   /**********************************************************/
   function previousMonthEnd(par_YYYYMM in number, par_roll_year boolean) return number is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_YYYYMM number(6,0);
      var_YYYY number(4,0);
      var_MM number(2,0);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /*- Calculate and return the previous month end of year*/
      /**/
      var_YYYY := to_number(substr(to_char(par_YYYYMM,'FM000000'),1,4));
      var_MM := to_number(substr(to_char(par_YYYYMM,'FM000000'),5,2)) - 1;
      if var_MM < 1 and par_roll_year = true then
         var_YYYY := var_YYYY - 1;
      end if;
      var_YYYYMM := (var_YYYY * 100) + 12;
      return var_YYYYMM;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end previousMonthEnd;

end mfjpln_control;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_control for pld_rep_app.mfjpln_control;
grant execute on mfjpln_control to public;