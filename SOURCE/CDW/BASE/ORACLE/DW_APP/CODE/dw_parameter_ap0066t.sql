/******************/
/* Package Header */
/******************/
create or replace package dw_parameter as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_parameter
    Owner   : dw_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Dimensional Data Store - Parameter

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/09   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'CDW';
   system_unit constant varchar2(10) := 'MARS_ANZ';
   system_environment constant varchar2(20) := 'TEST';

end dw_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_parameter for dw_app.dw_parameter;
grant execute on dw_parameter to public;