/******************************************************************************/
/* Function Definition                                                        */
/******************************************************************************/
/**
 System  : lads
 Package : lads_left_pad
 Owner   : lads_app
 Author  : Steve Gregan

 DESCRIPTION
 -----------
 Local Atlas Data Store - Left Pad Function

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/01   Steve Gregan   Created

*******************************************************************************/
create or replace function lads_app.lads_left_pad(par_string in varchar2, par_length in number, par_padding in string) return varchar2 is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Left pad the string
      /*-*/
      return lpad(par_padding,par_length-length(nvl(par_string,par_padding)),par_padding)||nvl(par_string,par_padding);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end lads_left_pad;
/  

/***************************/
/* Function Synonym/Grants */
/***************************/
create or replace public synonym lads_left_pad for lads_app.lads_left_pad;
grant execute on lads_left_pad to public with grant option;