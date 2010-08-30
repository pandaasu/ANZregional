create or replace function ods_app.ods_from_xml(par_text in varchar2) return varchar2 is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    Function : ods_from_xml
    Owner    : ods_app

    Description
    -----------
    Operational Data Store - From XML Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/08   Steve Gregan   Created

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
      var_return := replace(var_return,'&amp;','&');
      var_return := replace(var_return,'&lt;','<');
      var_return := replace(var_return,'&gt;','>');
      var_return := replace(var_return,'&#34;','"');
      var_return := replace(var_return,'&#39;','''');
      var_return := replace(var_return,'&#43;','+');
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end ods_from_xml;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym ods_from_xml for ods_app.ods_from_xml;
grant execute on ods_from_xml to public with grant option;