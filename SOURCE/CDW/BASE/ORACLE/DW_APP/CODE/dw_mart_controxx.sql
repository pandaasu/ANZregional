/******************/
/* Package Header */
/******************/
create or replace package dw_mart_control as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_mart_control
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Mart Control

    This package contain the data mart control functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/02   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure retrieve(par_date in date,
                      par_yyyypp out number,
                      par_prd_asofdays out varchar2,
                      par_prd_percent out number,
                      par_yyyymm out number,
                      par_mth_asofdays out varchar2,
                      par_mth_percent out number);

end dw_mart_control;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_mart_control as

   /********************************************/
   /* This procedure performs the main routine */
   /********************************************/
   procedure retrieve(par_date in date,
                      par_yyyypp out number,
                      par_prd_asofdays out varchar2,
                      par_prd_percent out number,
                      par_yyyymm out number,
                      par_mth_asofdays out varchar2,
                      par_mth_percent out number) is

      /*-*/
      /* Variable definitions
      /*-*/
      var_current_yyyypp number(6,0);
      var_current_yyyypp number(6,0);
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

      cursor csr_mars_date_dim is
         select t01.mars_year,
                t01.mars_period,
                t01.mars_week,
                t01.period_num,
                t01.mars_week_of_year,
                t01.mars_week_of_period
           from mars_date_dim t01
          where trunc(t01.calendar_date) = trunc(par_date);
      rcd_mars_date_dim csr_mars_date_dim%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current period and month information date
      /*-*/
      var_found := true;
      open csr_mars_date_dim;
      fetch csr_mars_date_dim into rcd_mars_date_dim;
      if csr_mars_date_dim%notfound then
         var_found := false;
      end if;
      close csr_mars_date_dim;
      if var_found = false then
         raise_application_error(-20000, 'No mars date found for ' || to_char(trunc(par_date),'yyyy/mm/dd')');
      end if;

      /*-*/
      /* Retrieve the period percentage
      /* 1. Invoice - use MARS_DATE calendar (20 working days)
      /* 2. Billed - calculate based on 24 working days
      /*-*/
      select max(period_bus_day_num) into var_prd_wrk_days
        from mars_date
       where mars_period = var_current_YYYYPP;
      var_prd_percent := round((var_period_bus_day_num / var_prd_wrk_days) * 100, 2);

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

      var_mth_percent := round((var_mth_day_num / var_mth_wrk_days) * 100, 2);

      /*-*/
      /* Retrieve the as of days literals
      /*-*/
      var_prd_asofdays := 'Current Period: ' || substr(to_char(var_current_YYYYPP,'fm000000'),1,4) || '/' || substr(to_char(var_current_YYYYPP,'fm000000'),5,2) ||
                          ' Current Date: ' || to_char(var_work_date,'DD/MM/YYYY') ||
                          ' Working Day: ' || to_char(var_period_bus_day_num,'fm99') || ' of ' || to_char(var_prd_wrk_days,'fm99') ||
                          ' (' || to_char(var_prd_percent,'fm990.00') || '%)';
      var_mth_asofdays := 'Current Month: ' || substr(to_char(var_current_YYYYMM,'fm000000'),1,4) || '/' || substr(to_char(var_current_YYYYMM,'fm000000'),5,2) ||
                          ' Current Date: ' || to_char(var_work_date,'DD/MM/YYYY') ||
                          ' Working Day: ' || to_char(var_mth_day_num,'fm99') || ' of ' || to_char(var_mth_wrk_days,'fm99') ||
                          ' (' || to_char(var_mth_percent,'fm990.00') || '%)';

      /*-*/
      /* Set the return parameters
      /*-*/
      par_yyyypp := var_current_yyyypp;
      par_prd_asofdays := var_prd_asofdays;
      par_prd_percent := var_prd_percent;
      par_yyyypp := var_current_yyyypp;
      par_mth_asofdays := var_mth_asofdays;
      par_mth_percent := var_mth_percent;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end retrieve;

end dw_mart_control;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_mart_control for dw_app.dw_mart_control;
grant execute on dw_mart_control to public;