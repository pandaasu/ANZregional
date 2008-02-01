/*******************/
/* Function Header */
/*******************/
create or replace function dw_app.dw_to_date(par_date in varchar2, par_format in varchar2) return date is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    System  : cdw
    Package : dw_to_date
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Corporate Data Warehouse - To Date Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/09   Steve Gregan   Created

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
   end dw_to_date;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym dw_to_date for dw_app.dw_to_date;
grant execute on dw_to_date to public with grant option;