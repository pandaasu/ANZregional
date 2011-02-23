/******************/
/* Package Header */
/******************/
create or replace package lics_sap_processor as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_sap_processor
    Owner   : lics_app
    Author  : Steve Gregan

    DESCRIPTION
    -----------
    Local Interface Control System - SAP Processor

    The package implements the SAP processor functionality.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/06   Steve Gregan   Created
    2007/02   Steve Gregan   Added dual inbound execution
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure execute_inbound(par_interface in varchar2,
                             par_config_id in varchar2,
                             par_sap_user in varchar2,
                             par_sap_password in varchar2,
                             par_forward in varchar2);
   procedure execute_dual_inbound(par_interface in varchar2,
                                  par_exe_script in varchar2,
                                  par_config_id in varchar2,
                                  par_sap_user_01 in varchar2,
                                  par_sap_password_01 in varchar2,
                                  par_sap_user_02 in varchar2,
                                  par_sap_password_02 in varchar2);

end lics_sap_processor;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_sap_processor as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*******************************************************/
   /* This procedure performs the execute inbound routine */
   /*******************************************************/
   procedure execute_inbound(par_interface in varchar2,
                             par_config_id in varchar2,
                             par_sap_user in varchar2,
                             par_sap_password in varchar2,
                             par_forward in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'SAP to ICS Inbound Processor';
      var_log_search := upper(par_interface) || '_' || upper(par_config_id);

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_interface is null then
         raise_application_error(-20000, 'Interface parameter must be supplied');
      end if;
      if par_config_id is null then
         raise_application_error(-20000, 'Configuration identifier parameter must be supplied');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SAP to ICS Inbound Processor - Parameters(' || upper(par_interface) || ' + ' || upper(par_config_id) ||')');

      /**/
      /* Execute the inbound SAP script
      /**/
      lics_logging.write_log('Execute SAP data extract started');
      lics_filesystem.execute_external_procedure(lics_parameter.inbound_sap_script
                                                 || ' ' || upper(par_interface)
                                                 || ' ' || upper(par_config_id)
                                                 || ' ' || par_sap_user
                                                 || ' ' || par_sap_password
                                                 || ' ' || upper(par_forward));
      lics_logging.write_log('Execute SAP data extract completed');

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SAP to ICS Inbound Processor');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || substr(SQLERRM, 1, 3900));
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - SAP Processor - ' || substr(SQLERRM, 1, 3900));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_inbound;

   /*******************************************************/
   /* This procedure performs the execute inbound routine */
   /*******************************************************/
   procedure execute_dual_inbound(par_interface in varchar2,
                                  par_exe_script in varchar2,
                                  par_config_id in varchar2,
                                  par_sap_user_01 in varchar2,
                                  par_sap_password_01 in varchar2,
                                  par_sap_user_02 in varchar2,
                                  par_sap_password_02 in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_sap_user_02 varchar2(128);
      var_sap_password_02 varchar2(128);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the local variables
      /*-*/
      var_sap_user_02 := par_sap_user_02;
      if var_sap_user_02 is null then
         var_sap_user_02 := '*NONE';
      end if;
      var_sap_password_02 := par_sap_password_02;
      if var_sap_password_02 is null then
         var_sap_password_02 := '*NONE';
      end if;

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'SAP to ICS Dual Inbound Processor';
      var_log_search := upper(par_interface) || '_' || upper(par_config_id);

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_interface is null then
         raise_application_error(-20000, 'Interface parameter must be supplied');
      end if;
      if par_config_id is null then
         raise_application_error(-20000, 'Configuration identifier parameter must be supplied');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SAP to ICS Dual Inbound Processor - Parameters(' || upper(par_interface) || ' + ' || upper(par_config_id) ||')');

      /**/
      /* Execute the dual inbound SAP script
      /**/
      lics_logging.write_log('Execute SAP data extract started');
      lics_filesystem.execute_external_procedure(lics_parameter.script_directory || par_exe_script
                                                 || ' ' || upper(par_interface)
                                                 || ' ' || upper(par_config_id)
                                                 || ' ' || par_sap_user_01
                                                 || ' ' || par_sap_password_01
                                                 || ' ' || var_sap_user_02
                                                 || ' ' || var_sap_password_02);
      lics_logging.write_log('Execute SAP data extract completed');

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SAP to ICS Dual Inbound Processor');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || substr(SQLERRM, 1, 3900));
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - Interface Control System - SAP Processor - ' || substr(SQLERRM, 1, 3900));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_dual_inbound;

end lics_sap_processor;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_sap_processor for lics_app.lics_sap_processor;
grant execute on lics_sap_processor to public;