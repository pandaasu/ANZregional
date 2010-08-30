create or replace function ods_app.ods_to_date(par_date in varchar2, par_format in varchar2) return date is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : ods_to_date
    Owner    : ods_app

    Description
    -----------
    Operational Data Store - To Date Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/08   Steve Gregan   Created

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
   end ods_to_date;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym ods_to_date for ods_app.ods_to_date;
grant execute on ods_to_date to public with grant option;