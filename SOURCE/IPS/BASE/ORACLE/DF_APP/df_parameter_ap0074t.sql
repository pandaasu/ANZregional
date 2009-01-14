/******************/
/* Package Header */
/******************/
create or replace package df_parameter as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : df_parameter
    Owner   : df_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Dimensional Data Store - Parameter

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/01   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public system parameters
   /*-*/
   system_code constant varchar2(10) := 'IPS';
   system_unit constant varchar2(10) := 'MARS_ANZ';
   system_environment constant varchar2(20) := 'TEST';

end df_parameter;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym df_parameter for df_app.df_parameter;
grant execute on df_parameter to public;