/*******************/
/* Function Header */
/*******************/
create or replace function dw_app.dw_to_timezone(par_date in date, 
                                                 par_to_timezone in varchar2 default null, 
                                                 par_from_timezone in varchar2 default null) return date is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    System  : dw
    Package : dw_to_timezone
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Data Warehouse - To Timezone Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/09   Steve Gregan   Created

   *******************************************************************************/

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
            raise_application_error(-20000, 'Invalid TO TIMEZONE parameter specified - must exist in V$TIMEZONE_NAMES');
         end if;
         close csr_timezone;
      end if;
      /*-*/
      if (par_from_timezone is not null) then
         open csr_timezone(par_from_timezone);
         fetch csr_timezone into rec_timezone;
         if (csr_timezone%notfound) then
            raise_application_error(-20000, 'Invalid FROM TIMEZONE parameter specified - must exist in V$TIMEZONE_NAMES');
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
   end dw_to_timezone;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym dw_to_timezone for dw_app.dw_to_timezone;
grant execute on dw_to_timezone to public with grant option;