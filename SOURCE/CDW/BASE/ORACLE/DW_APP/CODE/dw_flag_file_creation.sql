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
    2008/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2);

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
   procedure execute(par_company in varchar2) is

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
      var_instance number(15,0);
      var_filename varchar2(64);
      var_company_code company.company_code%type;
      var_date date;
      var_test date;
      var_next date;
      var_process_date varchar2(8);
      var_process_code varchar2(32);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Flag File Creation';

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
      var_log_prefix := 'DW - FLAG_FILE_CREATION';
      var_log_search := 'DW_FLAG_FILE_CREATION' || '_' || lics_stream_processor.callback_event;
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
      if upper(par_company) is null then
         raise_application_error(-20000, 'Process company must be supplied');
      end if;
      if upper(par_company) != 'CON' then
         open csr_company;
         fetch csr_company into rcd_company;
         if csr_company%notfound then
            raise_application_error(-20000, 'Company ' || par_company || ' not found on the company table');
         end if;
         close csr_company;
      end if;
      var_company_code := rcd_company.company_code;

      /*-*/
      /* Flag file date is always based on the previous day (converted using the company timezone)
      /*-*/
      var_date := trunc(sysdate);
      var_process_date := to_char(var_date-1,'yyyymmdd');
      if upper(par_company) != 'CON' then
         var_process_code := 'FLAGFILE_'||var_company_code;
      else
         var_process_code := 'FLAGFILE_CON';
      end if;
      if upper(par_company) != 'CON' then
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
      end if;

      /*-*/
      /* Flag file name
      /*-*/
      if upper(par_company) = 'CON' then
         var_filename := '4749.txt';
      else
         var_filename := par_company||'.txt';
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Flag File Creation - Parameters(' || par_company || ' + ' || to_char(to_date(var_process_date,'yyyymmdd'),'yyyy/mm/dd') || ')');

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
         /* Create the flag file interface
         /*-*/
         begin
            var_instance := lics_outbound_loader.create_interface('VENBOX01',null,var_filename);
            lics_outbound_loader.append_data('OK');
            lics_outbound_loader.finalise_interface;
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
      lics_logging.write_log('End - Flag File Creation');

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
                                         'DW_FLAG_FILE_CREATION',
                                         var_email,
                                         'One or more errors occurred during the Flag File Creation execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Set the flag file creation process trace
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
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_FLAG_FILE_CREATION - ' || var_exception);

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
