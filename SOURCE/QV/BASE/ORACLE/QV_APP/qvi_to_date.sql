create or replace function qvi_app.qvi_to_date(par_date in varchar2, par_format in varchar2) return date is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : qvi_to_date
    Owner    : qvi_app

    Description
    -----------
    QlikView Interfacing - To Date Function

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
   end qvi_to_date;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym qvi_to_date for qvi_app.qvi_to_date;
grant execute on qvi_to_date to public with grant option;