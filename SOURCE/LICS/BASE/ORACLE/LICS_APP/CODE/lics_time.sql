create or replace package lics_time as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_time
 Owner   : lics_app
 Author  : Linden Glen

 Description
 -----------
    Contains a set of functions that allow time based conversions for scheduling
    and timezone conversions.

    1. SCHEDULE_NEXT ( <DAY> , <HOUR> , <TO TIMEZONE> , <FROM TIMEZONE>)  RETURN <DATE>

       <DAY>  : Day of week to be executed - can be *MON, *TUE, *WED, *THU, *FRI, *SAT, *SUN
                To execute everyday, specify *ALL

                OR

                Mars day to be executed - can be *MARS01 to *MARS28

       <HOUR> : Hour of day to execute in 24 hour time. 
                e.g. 01:30am = 1.5, 08:00pm = 20, 07:15am = 7.25

       <TO TIMEZONE>   : OPTIONAL - timezone to return next date for (timezone must exist in V$TIMEZONE_NAMES)
                                    default is database timezone

       <FROM TIMEZONE> : OPTIONAL - timezone to convert from (timezone must exist in V$TIMEZONE_NAMES)
                                    default is database timezone

       <DATE> : based on parameters, returns date of next occurance

       Example Use : lics_time.schedule_next('*ALL',7)  -- return date every day of week at 7am for database timezone
                     lics_time.schedule_next('*ALL',7,'Asia/Hong_Kong') -- return date every day of week at 7am for Hong Kong timezone
                     lics_time.schedule_next('*ALL',7,'Asia/Hong_Kong','US/Central') -- return date every day of week at 7am, 
                                                                                        converting from US Central to Hong Kong timezone


    2. GET_TZ_TIME ( <FROM DATE> , <TO TIMEZONE> , <FROM TIMEZONE>) RETURN <DATE>

       <DATE>  : Date in timezone to be converted from

       <TO TIMEZONE>   : OPTIONAL - timezone to return next date for (timezone must exist in V$TIMEZONE_NAMES)
                                    default is database timezone

       <FROM TIMEZONE> : OPTIONAL - timezone to convert from (timezone must exist in V$TIMEZONE_NAMES)
                                    default is database timezone

       <DATE> : based on parameters, returns date at the TO TIMEZONE

       Example Use : lics_time.get_tz_tim(sysdate, 'Asia/Hong_Kong')  -- return date in Hong Kong at sysdate of database timezone
                     lics_time.get_tz_tim(sysdate, 'Asia/Hong_Kong','US/Central')  -- return date in Hong Kong at sysdate of US/Central timezone

 YYYY/MM   Author               Description
 -------   ------               -----------
 2006/07   Linden Glen          Created
 2006/12   Steve Gregan         Added Mars day selection
 2007/09   Steve Gregan         Added week day selection

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   function schedule_next(par_day in varchar2, 
                          par_hour in number, 
                          par_to_timezone in varchar2 default null, 
                          par_from_timezone in varchar2 default null) return date;
   function get_tz_time(par_date in date, 
                        par_to_timezone in varchar2 default null, 
                        par_from_timezone in varchar2 default null) return date;

end lics_time;
/

create or replace package body lics_time as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************************/
   /* SCHEDULE_NEXT Function : Returns date of next occurance */
   /***********************************************************/
   function schedule_next(par_day in varchar2, 
                          par_hour in number, 
                          par_to_timezone in varchar2 default null, 
                          par_from_timezone in varchar2 default null) return date is

      /*-*/
      /* Local definitions
      /*-*/
      var_date_01 date;
      var_date_02 date;
      var_next_exec date;
      var_day varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select t01.calendar_date
           from mars_date t01
          where trunc(t01.calendar_date) >= trunc(sysdate)
            and t01.period_day_num = to_number(var_day)
          order by t01.calendar_date asc;
      rcd_mars_date csr_mars_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate parameters
      /*-*/      
      case par_day
         when '*ALL' then var_day := '*ALL';
         when '*MON' then var_day := 'MONDAY';
         when '*TUE' then var_day := 'TUESDAY';
         when '*WED' then var_day := 'WEDNESDAY';
         when '*THU' then var_day := 'THURSDAY';
         when '*FRI' then var_day := 'FRIDAY';
         when '*SAT' then var_day := 'SATURDAY';
         when '*SUN' then var_day := 'SUNDAY';
         when '*WEEKDAY' then var_day := 'WEEKDAY';
         when '*MARS01' then var_day := '1';
         when '*MARS02' then var_day := '2';
         when '*MARS03' then var_day := '3';
         when '*MARS04' then var_day := '4';
         when '*MARS05' then var_day := '5';
         when '*MARS06' then var_day := '6';
         when '*MARS07' then var_day := '7';
         when '*MARS08' then var_day := '8';
         when '*MARS09' then var_day := '9';
         when '*MARS10' then var_day := '10';
         when '*MARS11' then var_day := '11';
         when '*MARS12' then var_day := '12';
         when '*MARS13' then var_day := '13';
         when '*MARS14' then var_day := '14';
         when '*MARS15' then var_day := '15';
         when '*MARS16' then var_day := '16';
         when '*MARS17' then var_day := '17';
         when '*MARS18' then var_day := '18';
         when '*MARS19' then var_day := '19';
         when '*MARS20' then var_day := '20';
         when '*MARS21' then var_day := '21';
         when '*MARS22' then var_day := '22';
         when '*MARS23' then var_day := '23';
         when '*MARS24' then var_day := '24';
         when '*MARS25' then var_day := '25';
         when '*MARS26' then var_day := '26';
         when '*MARS27' then var_day := '27';
         when '*MARS28' then var_day := '28';
         else raise_application_error(-20000, 'Day parameter (' || par_day || ') not recognised');
      end case;
      /*-*/
      if (par_hour is null or
          par_hour > 24 or par_hour < 0) then
         raise_application_error(-20000, 'Invalid hour parameter specified - must be between 0 and 24');
      end if;

      /*-*/
      /* Determine next date of next execution
      /*-*/    
      if (par_day = '*ALL' or
          par_day = '*MON' or
          par_day = '*TUE' or
          par_day = '*WED' or
          par_day = '*THU' or
          par_day = '*FRI' or
          par_day = '*SAT' or
          par_day = '*SUN') then
         if (par_day = '*ALL') then
            var_date_01 := trunc(sysdate);
            var_date_02 := trunc(sysdate+1);
         else
            if trim(to_char(sysdate,'DAY')) = var_day then
               var_date_01 := trunc(sysdate);
            else
               var_date_01 := trunc(next_day(sysdate,var_day));
            end if;
            var_date_02 := trunc(next_day(sysdate,var_day));
         end if;
      elsif par_day = '*WEEKDAY' then
         var_date_01 := trunc(sysdate);
         var_date_02 := trunc(sysdate+1);
         if (trim(to_char(var_date_01,'D')) = '1' or
             trim(to_char(var_date_01,'D')) = '7') then
            var_date_01 := trunc(next_day(sysdate,'MONDAY'));
         end if;
         if (trim(to_char(var_date_02,'D')) = '1' or
             trim(to_char(var_date_02,'D')) = '7') then
            var_date_02 := trunc(next_day(sysdate,'MONDAY'));
         end if;
      else
         var_date_02 := null;
         var_date_02 := null;
         open csr_mars_date;
         fetch csr_mars_date into rcd_mars_date;
         if csr_mars_date%found then
            var_date_01 := rcd_mars_date.calendar_date;
         end if;
         fetch csr_mars_date into rcd_mars_date;
         if csr_mars_date%found then
            var_date_02 := rcd_mars_date.calendar_date;
         end if;
         close csr_mars_date;
      end if;

      /*-*/
      /* Determine next date of next execution
      /*-*/    
      var_next_exec := get_tz_time(trunc(var_date_01)+numtodsinterval(par_hour,'HOUR'),par_from_timezone);
      if var_next_exec <= sysdate then
         var_next_exec := get_tz_time(trunc(var_date_02)+numtodsinterval(par_hour,'HOUR'),par_from_timezone);
      end if;

      /*-*/
      /* Return the scheduled time
      /*-*/
      return var_next_exec;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end schedule_next;

   /**********************************/
   /* GET_TZ_TIME : Returns the time */
   /**********************************/
   function get_tz_time(par_date in date, 
                        par_to_timezone in varchar2 default null, 
                        par_from_timezone in varchar2 default null) return date is


      /*-*/
      /* Local Cursor
      /*-*/
      cursor csr_timezone(par_tz varchar2) is
         select 'x'
         from V$TIMEZONE_NAMES
         where tzname = par_tz; 
      rec_timezone csr_timezone%rowtype;

      cursor csr_convert_tz is
         select from_tz(cast(par_date AS TIMESTAMP), nvl(par_from_timezone,dbtimezone))
                AT TIME ZONE nvl(par_to_timezone,dbtimezone) as tz_date
         from dual;
      rec_convert_tz csr_convert_tz%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate parameters
      /*-*/      
      if (par_to_timezone is not null) then
         open csr_timezone(par_to_timezone);
         fetch csr_timezone into rec_timezone;
         if (csr_timezone%notfound) then
            raise_application_error(-20000, 'Invalid TO TIMEZONE paramter specified - must exist in V$TIMEZONE_NAMES');
         end if;
         close csr_timezone;
      end if;
      /*-*/
      if (par_from_timezone is not null) then
         open csr_timezone(par_from_timezone);
         fetch csr_timezone into rec_timezone;
         if (csr_timezone%notfound) then
            raise_application_error(-20000, 'Invalid FROM TIMEZONE paramter specified - must exist in V$TIMEZONE_NAMES');
         end if;
         close csr_timezone;
      end if;

      /*-*/
      /* Determine date in timezone specified (converting from timezone if specified)
      /*-*/    
      open csr_convert_tz;
      fetch csr_convert_tz into rec_convert_tz;
      if (csr_convert_tz%notfound) then
         raise_application_error(-20000, 'Error occured retrieving timezone date conversion - ' || SQLERRM);   
      end if;
      close csr_convert_tz;

      /*-*/
      /* Return the converted time
      /*-*/
      return rec_convert_tz.tz_date;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_tz_time;

end lics_time;
/

create or replace public synonym lics_time for lics_app.lics_time;
grant execute on lics_time to public;