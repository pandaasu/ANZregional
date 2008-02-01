/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_planning_extract
 Owner   : dw_app

 Description
 -----------
 Dimensional Data Store - Planning Extract

 This package contains the procedures for the Planning and Management Reports. The package exposes
 one procedure EXECUTE that performs all extracts.

 **notes**
 1. A web log is produced under the search value DW_PLANNING_EXTRACT where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can
    be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package dw_planning_extract as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end dw_planning_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_planning_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;
      var_return varchar2(4000);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Planning Extract';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'PLANNING_EXTRACT';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'PLANNING_EXTRACT';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_PLANNING_EXTRACT';
      var_log_search := 'DW_PLANNING_EXTRACT';
      var_loc_string := 'DW_PLANNING_EXTRACT';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Planning Extract');

      /*-*/
      /* Request the lock on the planning extracts
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
      /* Execute the extract procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the extract procedures
         /*-*/
         begin
            var_return := mfjpln_inv_format01_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_inv_format01_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_inv_format01_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_inv_format01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_inv_format02_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_inv_format02_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_inv_format02_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_inv_format02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_sal_format01_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_sal_format01_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_sal_format01_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_sal_format01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_sal_format02_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_sal_format02_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_sal_format02_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_sal_format02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_sal_format03_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_sal_format03_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_sal_format03_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_sal_format03_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_sal_format11_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_sal_format11_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_sal_format11_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_sal_format11_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_sal_format12_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_sal_format12_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_sal_format12_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_sal_format12_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_sal_format13_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_sal_format13_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_sal_format13_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_sal_format13_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_for_format01_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_for_format01_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_for_format01_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_for_format01_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;
         /*----*/
         begin
            var_return := mfjpln_for_format02_extract.main;
            if var_return = '*OK' then
               lics_logging.write_log('Planning Extract - mfjpln_for_format02_extract - successful');
            else
               lics_logging.write_log('Planning Extract - mfjpln_for_format02_extract - **ERROR** - ' || var_return);
            end if;
         exception
            when others then
               var_errors := true;
               lics_logging.write_log('Planning Extract - mfjpln_for_format02_extract - **ERROR** - ' || substr(SQLERRM, 1, 1024));
         end;

         /*-*/
         /* Release the lock on the planning extracts
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Planning Extract');

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
                                         'DW_PLANNING_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the Planning Extract execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || substr(SQLERRM, 1, 1024));
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock on the planning extracts
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_PLANNING_EXTRACT - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_planning_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_planning_extract for dw_app.dw_planning_extract;
grant execute on dw_planning_extract to public;
