/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lads
 Package : lads_parameter
 Owner   : lads_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Local Atlas Data Store - Parameters

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package lads_parameter as

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'LADS';
   system_unit constant varchar2(10) := 'MFJ';
   system_environment constant varchar2(20) := 'TEST';

end lads_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create public synonym lads_parameter for lads_app.lads_parameter;
grant execute on lads_parameter to public;