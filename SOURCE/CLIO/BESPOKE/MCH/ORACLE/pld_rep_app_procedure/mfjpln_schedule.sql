/****************************************************************/
/* Package Definition                                           */
/****************************************************************/
/* System  : MFJ Planning Reports                               */
/* Package : mfjpln_schedule                                    */
/* Author  : Softstep Pty Ltd                                   */
/* Owner   : pld_rep_app                                        */
/* Date    : June 2003                                          */
/****************************************************************/
/* Description                                                  */
/****************************************************************/
-- Returns the date schedule information
/****************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package mfjpln_schedule as

   /*-*/
   /* Public declarations */
   /*-*/
   procedure getDate(par_date in date,
                     par_day out varchar2,
                     par_period_end out varchar2,
                     par_period_year_end out varchar2,
                     par_month_end out varchar2,
                     par_month_year_end out varchar2);
   procedure getToday(par_day out varchar2,
                      par_period_end out varchar2,
                      par_period_year_end out varchar2,
                      par_month_end out varchar2,
                      par_month_year_end out varchar2);

end mfjpln_schedule;
/

/****************/
/* Package Body */
/****************/
create or replace package body mfjpln_schedule as

   /************************************************/
   /* This procedure performs the get date routine */
   /************************************************/
   procedure getDate(par_date in date,
                     par_day out varchar2,
                     par_period_end out varchar2,
                     par_period_year_end out varchar2,
                     par_month_end out varchar2,
                     par_month_year_end out varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_day varchar2(1 char);
      var_period_end varchar2(1 char);
      var_period_year_end varchar2(1 char);
      var_month_end varchar2(1 char);
      var_month_year_end varchar2(1 char);
      var_mars_yyyyppdd number(8,0);

      /*-*/
      /* Cursor definitions */
      /*-*/
      cursor mars_date_c01 is 
         select mars_yyyyppdd
           from mars_date
          where to_char(calendar_date,'YYYYMMDD') = to_char(par_date,'YYYYMMDD');

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the current day number */
      /* **NOTE** Day 1 = Sunday */
      /*-*/
      var_day := to_char(to_number(to_char(par_date,'d')),'FM0');

      /*-*/
      /* Retrieve the mars period information */
      /*-*/
      open mars_date_c01;
      fetch mars_date_c01 into var_mars_yyyyppdd;
      if mars_date_c01%notfound then
         var_mars_yyyyppdd := 0;
      end if;
      close mars_date_c01;

      /*-*/
      /* Retrieve the period end */
      /* **note** period day one */
      /*-*/
      var_period_end := 'N';
      if substr(to_char(var_mars_yyyyppdd,'FM00000000'),7,2) = '01' then
         var_period_end := 'Y';
      end if;

      /*-*/
      /* Retrieve the period year end */
      /* **note** period one day one */
      /*-*/
      var_period_year_end := 'N';
      if substr(to_char(var_mars_yyyyppdd,'FM00000000'),5,4) = '0101' then
         var_period_year_end := 'Y';
      end if;

      /*-*/
      /* Retrieve the month end */
      /* **note** month day one */
      /*-*/
      var_month_end := 'N';
      if to_number(to_char(par_date,'dd')) = 1 then
         var_month_end := 'Y';
      end if;

      /*-*/
      /* Retrieve the month year end */
      /* **note** year day one */
      /*-*/
      var_month_year_end := 'N';
      if to_number(to_char(par_date,'ddd')) = 1 then
         var_month_year_end := 'Y';
      end if;

      /*-*/
      /*- Set the return parameters */
      /**/
      par_day := var_day;
      par_period_end := var_period_end;
      par_period_year_end := var_period_year_end;
      par_month_end := var_month_end;
      par_month_year_end := var_month_year_end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getDate;

   /*************************************************/
   /* This procedure performs the get today routine */
   /*************************************************/
   procedure getToDay(par_day out varchar2,
                      par_period_end out varchar2,
                      par_period_year_end out varchar2,
                      par_month_end out varchar2,
                      par_month_year_end out varchar2) is

      /*-*/
      /* Variable definitions */
      /*-*/
      var_day varchar2(1 char);
      var_period_end varchar2(1 char);
      var_period_year_end varchar2(1 char);
      var_month_end varchar2(1 char);
      var_month_year_end varchar2(1 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the date information */
      /*-*/
      getDate(sysdate,
              var_day,
              var_period_end,
              var_period_year_end,
              var_month_end,
              var_month_year_end);

      /*-*/
      /*- Set the return parameters */
      /**/
      par_day := var_day;
      par_period_end := var_period_end;
      par_period_year_end := var_period_year_end;
      par_month_end := var_month_end;
      par_month_year_end := var_month_year_end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getToday;

end mfjpln_schedule;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym mfjpln_schedule for pld_rep_app.mfjpln_schedule;
grant execute on mfjpln_schedule to public;