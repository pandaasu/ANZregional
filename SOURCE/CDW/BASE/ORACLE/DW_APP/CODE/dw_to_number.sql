/*******************/
/* Function Header */
/*******************/
create or replace function dw_app.dw_to_number(par_number in varchar2) return number is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    System  : cdw
    Package : dw_to_number
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Corporate Data Warehouse - To Number Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/09   Steve Gregan   Created

   *******************************************************************************/

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
   end dw_to_number;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym dw_to_number for dw_app.dw_to_number;
grant execute on dw_to_number to public with grant option;