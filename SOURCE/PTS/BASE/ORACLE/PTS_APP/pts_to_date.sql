create or replace function pts_app.pts_to_date(par_date in varchar2, par_format in varchar2) return date is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : pts_to_date
    Owner    : pts_app

    Description
    -----------
    Product Testing System - To Date Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

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
   end pts_to_date;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym pts_to_date for pts_app.pts_to_date;
grant execute on pts_to_date to public with grant option;