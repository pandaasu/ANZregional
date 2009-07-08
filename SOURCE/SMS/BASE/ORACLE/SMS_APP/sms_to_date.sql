create or replace function sms_app.sms_to_date(par_date in varchar2, par_format in varchar2) return date is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : sms_to_date
    Owner    : sms_app

    Description
    -----------
    SMS Reporting System - To Date Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created

   *******************************************************************************/

      /*-*/
      /* Local definitions
      /*-*/
      var_return date;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the date value
      /*-*/
      var_return := null;
      begin
         var_return := to_date(par_date,par_format);
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sms_to_date;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym sms_to_date for sms_app.sms_to_date;
grant execute on sms_to_date to public with grant option;