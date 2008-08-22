/******************/
/* Package Header */
/******************/
create or replace package dw_mart_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_mart_aggregation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Mart Aggregation

    This package contain the mart aggregation functionality. The package exposes
    one procedure EXECUTE that performs the aggregation based on the following parameters:

    1. PAR_PROCEDURE (procedure string) (MANDATORY)

       The mart aggregation procedure.

    2. PAR_PROCESS (process string) (MANDATORY)

       The mart aggregation process code used by process polling.

    3. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed.

    **notes**
    1. A web log is produced under the search value DW_MART_AGGREGATION where all errors are logged.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_procedure in varchar2, par_process in varchar2, par_company in varchar2);

end dw_mart_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_mart_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_procedure in varchar2, par_process in varchar2, par_company in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;
      var_company_code company.company_code%type;
      var_date date;
      var_test date;
      var_next date;
      var_process_date varchar2(8);
      var_process_code varchar2(32);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Mart Aggregation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = par_company;
      rcd_company csr_company%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'DW - MART_AGGREGATION';
      var_log_search := 'DW_MART_AGGREGATION' || '_' || lics_stream_processor.callback_event;
      var_loc_string := lics_stream_processor.callback_lock;
      var_alert := lics_stream_processor.callback_alert;
      var_email := lics_stream_processor.callback_email;
      var_errors := false;
      var_locked := false;
      if var_loc_string is null then
         raise_application_error(-20000, 'Stream lock not returned - must be executed from the ICS Stream Processor');
      end if;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_procedure is null then
         raise_application_error(-20000, 'Mart procedure must be supplied');
      end if;
      if par_process is null then
         raise_application_error(-20000, 'Process code must be supplied');
      end if;
      if upper(par_company) is null then
         raise_application_error(-20000, 'Process company must be supplied');
      end if;
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%notfound then
         raise_application_error(-20000, 'Company ' || par_company || ' not found on the company table');
      end if;
      close csr_company;
      var_company_code := rcd_company.company_code;

      /*-*/
      /* Aggregation date is always based on the previous day (converted using the company timezone)
      /*-*/
      var_date := trunc(sysdate);
      var_process_date := to_char(var_date-1,'yyyymmdd');
      var_process_code := par_process;
      if rcd_company.company_timezone_code != 'Australia/NSW' then
         var_test := sysdate;
         var_next := dw_to_timezone(trunc(sysdate)-3,'Australia/NSW',rcd_company.company_timezone_code);
         loop
            var_date := var_next;
            var_next := var_next + 1;
            if var_next > var_test then
               exit;
            end if;
         end loop;
         var_process_date := to_char(var_date,'yyyymmdd');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Mart Aggregation - Parameters(' || par_procedure || ' + ' || par_process || ' + ' || par_company || ' + ' || to_char(to_date(var_process_date,'yyyymmdd'),'yyyy/mm/dd') || ')');

      /*-*/
      /* Request the lock on the event
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 3000));
      end;

      /*-*/
      /* Execute the requested procedure
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the mart aggregation procedure
         /*-*/
         begin
            execute immediate 'begin ' || par_procedure || '; end;';
         exception
            when others then
               var_errors := true;
               lics_logging.write_log(substr(SQLERRM, 1, 3000));
         end;

         /*-*/
         /* Release the lock on the order extract
         /*-*/
         lics_locking.release(var_loc_string);

      end if;
      var_locked := false;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Mart Aggregation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(dw_parameter.system_code,
                                         dw_parameter.system_unit,
                                         dw_parameter.system_environment,
                                         con_function,
                                         'DW_MART_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Mart Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

      /*-*/
      /* Set processing trace when required
      /*-*/
      else

         /*-*/
         /* Set the data mart aggregation process trace
         /*-*/
         lics_processing.set_trace(var_process_code, var_process_date);

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
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Release the lock when required
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_MART_AGGREGATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end dw_mart_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_mart_aggregation for dw_app.dw_mart_aggregation;
grant execute on dw_mart_aggregation to public;
