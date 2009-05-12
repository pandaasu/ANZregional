/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : vds
 Package : vds_parameter
 Owner   : vds_app
 Author  : Steve Gregan - January 2004

 DESCRIPTION
 -----------
 Validation Data Store - VDS Parameters

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package vds_parameter as

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'VDS';
   system_unit constant varchar2(10) := 'Canada';
   system_environment constant varchar2(20) := 'TEST';

end vds_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create public synonym vds_parameter for vds_app.vds_parameter;
grant execute on vds_parameter to public;