/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_daily_processing
 Owner   : dw_app

 Description
 -----------
 Dimensional Data Store - Daily Processing

 This package contain the data warehouse daily processing. The package exposes
 one procedure EXECUTE that performs the load and aggregation based on the following parameters:

 1. PAR_DATE (date in string format YYYYMMDD) (OPTIONAL)

    The date for which the processing is to be performed.

 2. PAR_COMPANY (date in string format YYYYMMDD) (MANDATORY)

    The company for which the processing is to be performed. 

 **notes**
 1. A web log is produced under the search value DW_DAILY_PROCESSING where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package dw_daily_processing as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_date in varchar2, par_company in varchar2);

end dw_daily_processing;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_daily_processing as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_date in varchar2, par_company in varchar2) is

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
      var_date date;
      var_yyyyppdd number(8,0);
      var_yyyypp number(6,0);
      var_yyyymm number(6,0);
      var_aggregation_status varchar2(32);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Daily Processing';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'DAILY_PROCESSING';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'DAILY_PROCESSING';
      con_fil_alt_group constant varchar2(32) := 'DW_ALERT';
      con_fil_alt_code constant varchar2(32) := 'FLAG_FILE_CREATION';
      con_fil_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_fil_ema_code constant varchar2(32) := 'FLAG_FILE_CREATION';
      con_fil_tri_group constant varchar2(32) := 'DW_JOB_GROUP';
      con_fil_tri_code constant varchar2(32) := 'FLAG_FILE_CREATION';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_DAILY_PROCESSING';
      var_log_search := 'DW_DAILY_PROCESSING';
      var_loc_string := 'DW_DAILY_PROCESSING';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_date is null then
         raise_application_error(-20000, 'Date parameter must be supplied');
      else
         begin
            var_date := to_date(par_date,'yyyymmdd');
         exception
            when others then
               raise_application_error(-20000, 'Date parameter (' || par_date || ') - unable to convert to date format YYYYMMDD');
         end;
      end if;
      if upper(par_company) is null then
         raise_application_error(-20000, 'Company parameter must be supplied');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin log
      /*-*/
      lics_logging.write_log('Begin - Daily Processing - Parameters(' || par_date || ' + ' || par_company || ')');

      /*-*/
      /* Request the lock on the daily processing
      /*-*/
      begin
         lics_locking.request(var_loc_string || '-' || par_company);
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
         /* Execute the daily procedures
         /* **note** 1. Dependancy as follows
         /*          2. DW FLAG FILE is global so require all companies to be aggregated
         /*            ==> DW SALES AGGREGATION
         /*                ==> DW RECONCILIATION CHECK AGGREGATION
         /*                    ==> DW FLAG FILE
         /*-*/

         /*-*/
         /* Execute the DW sales aggregation
         /*-*/
         begin
            dw_app.dw_sales_aggregation.execute('*DATE','*ALL',par_date,par_company);
         exception
            when others then
               var_errors := true;
         end;
         if var_errors = false then

            /*-*/
            /* Set the sales aggregation trace for the current company
            /*-*/
            lics_processing.set_trace('SALES_AGGREGATION_' || par_company,par_date);

            /*-*/
            /* Check the BCA Sales Trigger group
            /*-*/
            lics_processing.check_group('BCA_SALES_TRIGGER',
                                        par_date,
                                        'BCA_TRIGGER_FIRED',
                                        'DW Flag File Creation',
                                        'dw_flag_file_creation.execute(''ICSBCA01'')',
                                        lics_setting_configuration.retrieve_setting(con_fil_alt_group, con_fil_alt_code),
                                        lics_setting_configuration.retrieve_setting(con_fil_ema_group, con_fil_ema_code),
                                        lics_setting_configuration.retrieve_setting(con_fil_tri_group, con_fil_tri_code));

         end if;

         /*-*/
         /* Release the lock on the regional dbp
         /*-*/
         lics_locking.release(var_loc_string || '-' || par_company);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Daily Processing');

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
                                         'DW_DAILY_PROCESSING',
                                         var_email,
                                         'One or more errors occurred during the Daily Processing execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Release the lock on the daily processing
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string || '-' || par_company);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_DAILY_PROCESSING - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_daily_processing;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_daily_processing for dw_app.dw_daily_processing;
grant execute on dw_daily_processing to public;
