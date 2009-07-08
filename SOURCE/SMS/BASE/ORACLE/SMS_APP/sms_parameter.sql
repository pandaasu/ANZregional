/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_parameter as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_parameter
    Owner   : sms_app

    DESCRIPTION
    -----------
    SMS Reporting System - Parameter

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'SMS';
   system_unit constant varchar2(10) := 'CHINA';
   system_environment constant varchar2(20) := 'TEST';

end sms_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_parameter for sms_app.sms_parameter;
grant execute on sms_parameter to public;