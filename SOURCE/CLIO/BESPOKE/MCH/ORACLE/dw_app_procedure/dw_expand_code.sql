/*******************/
/* Function Header */
/*******************/
create or replace function dw_app.dw_expand_code(par_code in varchar2) return varchar2 is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Package : dw_expand_code
    Owner   : dw_app

    DESCRIPTION
    -----------
    Dimensional Data Store - Expand Code Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/08   Steve Gregan   Created

   *******************************************************************************/

      /*-*/
      /* Local definitions
      /*-*/
      var_number number;
      var_return varchar2(30);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return expanded numeric codes with leading zeros
      /*-*/
      var_return := par_code;
      begin
         var_number := to_number(par_code);
         var_return := to_char(var_number,'fm000000000000000000');
      exception
         when others then
            null;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dw_expand_code;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym dw_expand_code for dw_app.dw_expand_code;
grant execute on dw_expand_code to public with grant option;