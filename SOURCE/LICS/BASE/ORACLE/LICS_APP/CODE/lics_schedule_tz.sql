
create or replace function lics_schedule_tz(par_day in varchar2, par_hour in number, par_timezone in varchar2) return date is

/******************************************************************************/
/* Function Definition                                                        */
/******************************************************************************/
/**
 System  : lics
 Function: lics_schedule_tz
 Owner   : lics_app
 Author  : Linden Glen

 DESCRIPTION
 -----------
 Determines the next scheduled job execution time, taking into account the
 current day and time. It will then convert this date into the timezone
 passed in.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/05   Linden Glen    Created
 2006/07   Linden Glen    MOD: Check that TZ Date not less than system date.

*******************************************************************************/

   /*-*/
   /* Local definitions
   /*-*/
   var_local_date date;
   var_tz_date date;

   /*-*/
   /* Local Cursor
   /*-*/
   cursor csr_timezone is
      select 'x'
      from V$TIMEZONE_NAMES
      where tzname = par_timezone;
   rec_timezone csr_timezone%rowtype;

   cursor csr_sched_date is
      select (var_local_date+(substr(tz_offset(dbtimezone),1,1)||'1')*to_dsinterval('0 '
                             ||substr(tz_offset(dbtimezone),2, 5)||':00'))
                           -(substr(tz_offset(par_timezone),1,1)||'1')*to_dsinterval('0 '
                             ||substr(tz_offset(par_timezone),2, 5)||':00') as sched_date
      from dual;
   rec_sched_date csr_sched_date%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      open csr_timezone;
      fetch csr_timezone into rec_timezone;
      if (csr_timezone%notfound and
          par_timezone is not null) then
         raise_application_error(-20000, 'Timezone parameter not recognised, must exist in V$TIMEZONE_NAMES or be null');
      end if;
      close csr_timezone;


      /*-*/
      /* Retrieve next execution date
      /*-*/
      var_local_date := lics_schedule_next(par_day, par_hour);

      /*-*/
      /* Return next local execution date if timezone not supplied
      /*-*/
      if(par_timezone is null) then
         return var_local_date;
      end if;

      /*-*/
      /* Convert next execution date to supplied timezone
      /*-*/
      open csr_sched_date;
      fetch csr_sched_date into rec_sched_date;
      if (csr_sched_date%notfound) then
         raise_application_error(-20000, 'Failed to convert date - ' || SQLERRM);
      end if;
      close csr_sched_date;

      var_tz_date := rec_sched_date.sched_date;

      /*-*/
      /* If TZ scheduled date < system date, then move to next date schedule
      /*-*/
      if (var_tz_date < var_local_date) then
         if (par_day = '*ALL') then
            return var_tz_date+1;
         else
            return var_tz_date+7;
         end if;
      else
         return var_tz_date;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lics_schedule_tz;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym lics_schedule_tz for lics_app.lics_schedule_tz;
grant execute on lics_schedule_tz to public with grant option;