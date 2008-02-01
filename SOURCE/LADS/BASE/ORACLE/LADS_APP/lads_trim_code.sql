/******************************************************************************/
/* Function Definition                                                        */
/******************************************************************************/
/**
 System  : lads
 Package : lads_trim_code
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - Trim Code Function

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/
create or replace function lads_app.lads_trim_code(par_code in varchar2) return varchar2 is

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
   end lads_trim_code;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym lads_trim_code for lads_app.lads_trim_code;
grant execute on lads_trim_code to public with grant option;