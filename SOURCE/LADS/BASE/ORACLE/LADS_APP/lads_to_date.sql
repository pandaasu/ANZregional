/******************************************************************************/
/* Function Definition                                                        */
/******************************************************************************/
/**
 System  : lads
 Package : lads_to_date
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - To Date Function

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/
create or replace function lads_app.lads_to_date(par_date in varchar2, par_format in varchar2) return date is

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
   end lads_to_date;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym lads_to_date for lads_app.lads_to_date;
grant execute on lads_to_date to public with grant option;