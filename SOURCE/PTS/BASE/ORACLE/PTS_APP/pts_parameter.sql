/******************/
/* Package Header */
/******************/
create or replace package pts_app.pts_parameter as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : pts_parameter
    Owner   : pts_app

    Description
    -----------
    Product Testing System - Parameter

    This package contain the parameters.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/04   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'PTS';
   system_unit constant varchar2(10) := 'WODONGA';
   system_environment constant varchar2(20) := 'PROD';

end pts_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym pts_parameter for pts_app.pts_parameter;
grant execute on pts_parameter to public;