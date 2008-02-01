/******************/
/* Package Header */
/******************/
create or replace package dw_flag_file_creation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_flag_file_creation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Flag File Creation

    This package contain the data warehouse flag file creation. The package exposes one
    procedure EXECUTE that performs the flag file creation based on the following parameters:

    1. PAR_INTERFACE (Interface Identifier) (MANDATORY)

       The interface identifier for the flag file.

    2. PAR_FILE_NAME (Flag file name) (MANDATORY)

       The interface identifier for the flag file.

    **notes**
    1. A web log is produced under the search value DW_FLAG_FILE_CREATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/07   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_interface in varchar2);

end dw_flag_file_creation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_flag_file_creation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_interface in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Flag File Creation';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'FLAG_FILE_CREATION';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'FLAG_FILE_CREATION';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'CLIO - DW_FLAG_FILE_CREATION';
      var_log_search := 'DW_FLAG_FILE_CREATION';
      var_loc_string := 'DW_FLAG_FILE_CREATION-' || par_interface;
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin log
      /*-*/
      lics_logging.write_log('Begin - Flag File Creation - Parameters(' || upper(par_interface) || ')');

      /*-*/
      /* Request the lock on the flag file creation
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Create the flag file interface
         /*-*/
         var_instance := lics_outbound_loader.create_interface(upper(par_interface));
         lics_outbound_loader.append_data('OK');
         lics_outbound_loader.finalise_interface;

         /*-*/
         /* Release the lock on the flag file creation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Flag File Creation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_FLAG_FILE_CREATION',
                                         var_email,
                                         'One or more errors occurred during the Flag File Creation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;
      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock on the flag file creation
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FLAG_FILE_CREATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_flag_file_creation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_flag_file_creation for dw_app.dw_flag_file_creation;
grant execute on dw_flag_file_creation to public;
