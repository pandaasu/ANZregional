/******************************************************************************/
/* Function Definition                                                        */
/******************************************************************************/
/**
 System  : lads
 Package : lads_classification_code
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - Get Classification Code

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/
create or replace function lads_app.lads_classification_code(par_obtab in varchar2,
                                                             par_klart in varchar2,
                                                             par_atnam in varchar2,
                                                             par_objek in varchar2) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(50 char);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_lads_cla_chr is
      select t01.atwrt
             from lads_cla_chr t01
            where t01.obtab = par_obtab
              and t01.klart = par_klart
              and t01.atnam = par_atnam
              and t01.objek = par_objek;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the classification code
      /*-*/
      var_return := null;
      open csr_lads_cla_chr;
      fetch csr_lads_cla_chr into var_return;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lads_classification_code;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym lads_classification_code for lads_app.lads_classification_code;
grant execute on lads_classification_code to public with grant option;