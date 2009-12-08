create or replace function psa_app.psa_to_number(par_number in varchar2) return number is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : psa_to_number
    Owner    : psa_app

    Description
    -----------
    Production Scheduling Application - To Number Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

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
   end psa_to_number;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym psa_to_number for psa_app.psa_to_number;
grant execute on psa_to_number to public with grant option;