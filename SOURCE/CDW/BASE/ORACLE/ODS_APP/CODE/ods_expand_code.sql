/*******************/
/* Function Header */
/*******************/
create or replace function ods_app.ods_expand_code(par_code in varchar2) return varchar2 is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : ods_expand_code
    Owner    : ods_app

    Description
    -----------
    Operational Data Store - Expand Code Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/08   Steve Gregan   Created

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
   end ods_expand_code;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym ods_expand_code for ods_app.ods_expand_code;
grant execute on ods_expand_code to public with grant option;