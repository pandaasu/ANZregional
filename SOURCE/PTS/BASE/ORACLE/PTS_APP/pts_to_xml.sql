create or replace function pts_app.pts_to_xml(par_text in varchar2) return varchar2 is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : pts_to_xml
    Owner    : pts_app

    Description
    -----------
    Product Testing System - To XML Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

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
      var_return := replace(var_return,'+','&#43;');
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end pts_to_xml;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym pts_to_xml for pts_app.pts_to_xml;
grant execute on pts_to_xml to public with grant option;