/******************/
/* Package Header */
/******************/
create or replace package dw_daily_sales_checker as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_daily_sales_checker
 Owner   : dw_app

 Description
 -----------
 Dimensional Data Store - Daily Sales Checker

 This package contain the data warehouse daily sales checker. The package exposes
 one procedure EXECUTE that performs the invoice summary arrival check.

 **notes**
 1. A web log is produced under the search value DW_DAILY_SALES_CHECKER where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created
 2007/01   Steve Gregan   Added summary and invoices not received warning email

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end dw_daily_sales_checker;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_daily_sales_checker as

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
      var_alert varchar2(256);
      var_email varchar2(256);
      var_check_status varchar2(32);
      var_today_status varchar2(32);
      var_message varchar2(4000);
      var_warning varchar2(4000);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Daily Sales Checker';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'DAILY_SALES_CHECKER';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'DAILY_SALES_CHECKER';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'CLIO - DW_DAILY_SALES_CHECKER';
      var_log_search := 'DW_DAILY_SALES_CHECKER';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin log
      /*-*/
      lics_logging.write_log('Begin - Daily Sales Checker');

      /*-*/
      /* Execute the DW reconciliation check sales
      /*-*/
      var_check_status := dw_app.dw_reconciliation.check_sales(var_message, var_warning, var_today_status);
      if var_check_status = '*NR' then
         lics_logging.write_log('Daily Sales Check - Status - Not Requested');
      elsif var_check_status = '*OK' then
         lics_logging.write_log('Daily Sales Check - Status - ' || var_check_status);
      else
         if not(var_message is null) then
            lics_logging.write_log('Daily Sales Check - Status - *ERROR - ' || var_message);
         end if;
         if not(var_warning is null) then
            lics_logging.write_log('Daily Sales Check - Status - *WARNING - ' || var_warning);
         end if;
      end if;
     -- if var_today_status = '*NR' then
     --    -- FIRE NO SALES EVENT
     -- end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Daily Sales Checker');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Error/Warning
      /*-*/
      if var_check_status != '*NR' and var_check_status != '*OK' then
         if not(var_message is null) then
            if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
               lics_notification.send_alert(var_alert);
            end if;
            if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
               lics_notification.send_email(lads_parameter.system_code,
                                            lads_parameter.system_unit,
                                            lads_parameter.system_environment,
                                            con_function,
                                            'DW_DAILY_SALES_CHECKER',
                                            var_email,
                                            'One or more errors occurred during the Daily Sales Checker execution - refer to web log - ' || lics_logging.callback_identifier);
            end if;
         end if;
         if not(var_warning is null) then
            if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
               lics_notification.send_email(lads_parameter.system_code,
                                            lads_parameter.system_unit,
                                            lads_parameter.system_environment,
                                            con_function || ' - WARNING ONLY',
                                            'DW_DAILY_SALES_CHECKER',
                                            var_email,
                                            'One or more warnings occurred during the Daily Sales Checker execution - refer to web log - ' || lics_logging.callback_identifier);
            end if;
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_DAILY_SALES_CHECKER - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_daily_sales_checker;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_daily_sales_checker for dw_app.dw_daily_sales_checker;
grant execute on dw_daily_sales_checker to public;
