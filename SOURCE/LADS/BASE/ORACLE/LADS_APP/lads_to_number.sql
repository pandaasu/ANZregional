/******************************************************************************/
/* Function Definition                                                        */
/******************************************************************************/
/**
 System  : lads
 Package : lads_to_number
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - To Number Function

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/
create or replace function lads_app.lads_to_number(par_number in varchar2) return number is

      /*-*/
      /* Local definitions
      /*-*/
      var_return number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the number value
      /*-*/
      var_return := null;
      begin
         if substr(par_number,length(par_number),1) = '-' then
            var_return := to_number('-' || substr(par_number,1,length(par_number) - 1));
         else
            var_return := to_number(par_number);
         end if;
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lads_to_number;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym lads_to_number for lads_app.lads_to_number;
grant execute on lads_to_number to public with grant option;