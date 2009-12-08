create or replace function psa_app.psa_to_date(par_date in varchar2, par_format in varchar2) return date is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : psa_to_date
    Owner    : psa_app

    Description
    -----------
    Production Scheduling Application - To Date Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

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
   end psa_to_date;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym psa_to_date for psa_app.psa_to_date;
grant execute on psa_to_date to public with grant option;