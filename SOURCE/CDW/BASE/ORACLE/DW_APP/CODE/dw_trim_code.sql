/*******************/
/* Function Header */
/*******************/
create or replace function dw_app.dw_trim_code(par_code in varchar2) return varchar2 is

   /******************************************************************************/
   /* Function Definition                                                        */
   /******************************************************************************/
   /**
    System  : cdw
    Package : dw_trim_code
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Corporate Data Warehouse - Trim Code Function

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/09   Steve Gregan   Created

   *******************************************************************************/

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the trimmed code
      /*-*/
      return ltrim(par_code,' 0');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dw_trim_code;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym dw_trim_code for dw_app.dw_trim_code;
grant execute on dw_trim_code to public with grant option;