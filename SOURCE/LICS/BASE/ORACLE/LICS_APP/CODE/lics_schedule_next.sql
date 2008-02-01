/******************************************************************************/
/* Function Definition                                                        */
/******************************************************************************/
/**
 System  : lics
 Function: lics_schedule_next
 Owner   : lics_app
 Author  : Linden Glen

 DESCRIPTION
 -----------
 Determines the next scheduled job execution time, taking into account the 
 current day and time. This allows jobs next execution to be scheduled on
 the same day.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/05   Linden Glen    Created

*******************************************************************************/
create or replace function lics_app.lics_schedule_next(par_day in varchar2, par_hour in number) return date is

   /*-*/
   /* Local definitions
   /*-*/
   var_day varchar2(9);
   var_next_exec date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      case par_day
         when '*ALL' then var_day := '*ALL';
         when '*MON' then var_day := 'MONDAY';
         when '*TUE' then var_day := 'TUESDAY';
         when '*WED' then var_day := 'WEDNESDAY';
         when '*THU' then var_day := 'THURSDAY';
         when '*FRI' then var_day := 'FRIDAY';
         when '*SAT' then var_day := 'SATURDAY';
         when '*SUN' then var_day := 'SUNDAY';
         else raise_application_error(-20000, 'Day parameter (' || par_day || ') not recognised');
      end case;


      /*-*/
      /* Initialise next execution variable
      /*-*/      
      var_next_exec := null;

      IF (var_day = '*ALL') THEN
         IF (to_number(to_char(sysdate,'hh24'))+(to_number(to_char(sysdate,'MI'))/60) < par_hour) THEN
            var_next_exec := trunc(sysdate);
         ELSE
            var_next_exec := trunc(sysdate+1);
         END IF;
      ELSE
         IF (to_number(to_char(sysdate,'hh24'))+(to_number(to_char(sysdate,'MI'))/60) < par_hour AND 
             trim(to_char(sysdate,'DAY')) = var_day) THEN
            var_next_exec := trunc(sysdate);
         ELSE
            var_next_exec := trunc(next_day(sysdate,var_day));
         END IF;
      END IF;


      /*-*/
      /* Include execution time 
      /*-*/      
      var_next_exec := var_next_exec + numtodsinterval(par_hour,'HOUR'); 

      return var_next_exec;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lics_schedule_next;
/  


/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym lics_schedule_next for lics_app.lics_schedule_next;
grant execute on lics_schedule_next to public with grant option;
