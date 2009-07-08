create or replace function sms_app.sms_to_xml(par_text in varchar2) return varchar2 is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : sms_to_xml
    Owner    : sms_app

    Description
    -----------
    SMS Reporting System - To XML Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created

   *******************************************************************************/

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(2000 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the converted text value
      /*-*/
      var_return := par_text;
      var_return := replace(var_return,'&','&amp;');
      var_return := replace(var_return,'<','&lt;');
      var_return := replace(var_return,'>','&gt;');
      var_return := replace(var_return,'"','&#34;');
      var_return := replace(var_return,'''','&#39;');
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sms_to_xml;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym sms_to_xml for sms_app.sms_to_xml;
grant execute on sms_to_xml to public with grant option;