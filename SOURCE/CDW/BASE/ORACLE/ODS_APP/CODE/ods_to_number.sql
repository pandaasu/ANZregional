create or replace function ods_app.ods_to_number(par_number in varchar2) return number is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : ods_to_number
    Owner    : ods_app

    Description
    -----------
    Operational Data Store - To Number Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/08   Steve Gregan   Created

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
   end ods_to_number;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym ods_to_number for ods_app.ods_to_number;
grant execute on ods_to_number to public with grant option;