/******************/
/* Package Header */
/******************/
create or replace package dw_daily_hierarchy_checker as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_daily_hierarchy_checker
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Daily Hierarchy Checker

    This package contain the data warehouse daily hierarchy checker. The package exposes
    one procedure EXECUTE that performs the customer hierarchy arrival check.

    **notes**
    1. A web log is produced under the search value DW_DAILY_HIERARCHY_CHECKER where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can be raised.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/07   Steve Gregan   Created
    2006/07   Linden Glen    Changed date check to adjust for ICS_TIMEZONE setting
    2008/11   Steve Gregan   Changed to handle company code

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company_code in varchar2);

end dw_daily_hierarchy_checker;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_daily_hierarchy_checker as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_company_code in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_status varchar2(32);
      var_date varchar2(8);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Daily Hierarchy Checker';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'DAILY_HIERARCHY_CHECKER';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'DAILY_HIERARCHY_CHECKER';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_hierarchy is
         select count(*) as leaf_count
           from lads_hie_cus_det t01
          where t01.hdrdat = var_date
            and t01.vkorg = par_company_code;
      rcd_hierarchy csr_hierarchy%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log variables
      /*-*/
      var_log_prefix := 'CLIO - DW_DAILY_HIERARCHY_CHECKER -' || par_company_code;
      var_log_search := 'DW_DAILY_HIERARCHY_CHECKER_' || par_company_code;
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin log
      /*-*/
      lics_logging.write_log('Begin - Daily Hierarchy Checker - Parameters(' || par_company_code || ')');

      /*-*/
      /* Retrieve date to check
      /*-*/
      var_date := to_char(lics_time.get_tz_time(sysdate,'Asia/Hong_Kong'),'YYYYMMDD');

      /*-*/
      /* Retrieve the hierachy count for today
      /*-*/
      open csr_hierarchy;
      fetch csr_hierarchy into rcd_hierarchy;
      if csr_hierarchy%notfound then
         rcd_hierarchy.leaf_count := 0;
      end if;
      close csr_hierarchy;
      if rcd_hierarchy.leaf_count = 0 then
         var_status := '*ERROR';
         lics_logging.write_log('Daily Hierarchy Checker - Hierarchy NOT RECEIVED for - ' || par_company_code || ' + ' || var_date);
      else
         var_status := '*OK';
         lics_logging.write_log('Daily Hierarchy Checker - Hierarchy received for - ' || par_company_code || ' + ' || var_date);
      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Daily Hierarchy Checker');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_status != '*OK' then
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_DAILY_HIERARCHY_CHECKER_' || par_company_code,
                                         var_email,
                                         'One or more errors occurred during the Daily Hierarchy Checker execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_DAILY_HIERARCHY_CHECKER - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_daily_hierarchy_checker;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_daily_hierarchy_checker for dw_app.dw_daily_hierarchy_checker;
grant execute on dw_daily_hierarchy_checker to public;
