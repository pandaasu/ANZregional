/******************/
/* Package Header */
/******************/
create or replace package psa_app.psa_parameter as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : psa_parameter
    Owner   : psa_app

    DESCRIPTION
    -----------
    Production Scheduling Application - Parameter

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'PSA';
   system_unit constant varchar2(10) := 'WANGANUI';
   system_environment constant varchar2(20) := 'PROD';

end psa_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_parameter for psa_app.psa_parameter;
grant execute on psa_parameter to public;