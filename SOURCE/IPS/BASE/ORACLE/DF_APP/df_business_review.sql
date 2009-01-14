/******************/
/* Package Header */
/******************/
create or replace package df_business_review as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : df_business_review
    Owner   : df_app
    Author  : Steve Gregan

    Description
    -----------
    Integrated Planning Demand Financials - Business Review 

    This package contain the procedures for business reviews.

    **notes**
    1. A web log is produced under the search value DF_BUSINESS_REVIEW where all errors are logged.

    1. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author             Description
    -------   ------             -----------
    2009/01   Steve Gregan       Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure creation(par_fcst_id in number);

end df_business_review; 
/

/****************/
/* Package Body */
/****************/
create or replace package body df_business_review as

   /*-*/
   /* Private exceptions 
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /************************************************/
   /* This procedure performs the creation routine */
   /************************************************/
   procedure creation(par_fcst_id in number) is

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
      var_result_msg varchar2(3900);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DF Business Review Creation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst is
         select t01.*
           from fcst t01
          where t01.fcst_id = par_fcst_id;
      rcd_fcst csr_fcst%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the procedure
      /*-*/
      var_log_prefix := 'DF - BUSINESS_REVIEW CREATION';
      var_log_search := 'DF_BUSINESS_REVIEW_CREATION' || '_' || to_char(par_fcst_id);
      var_loc_string := lics_stream_processor.callback_lock;
      var_alert := lics_stream_processor.callback_alert;
      var_email := lics_stream_processor.callback_email;
      var_errors := false;
      var_locked := false;
      if var_loc_string is null then
         raise_application_error(-20000, 'Stream lock not returned - must be executed from the ICS Stream Processor');
      end if;

      /*-*/
      /* Retrieve the forecast
      /*-*/
      open csr_fcst;
      fetch csr_fcst into rcd_fcst;
      if csr_fcst%notfound then
         raise_application_error(-20000, 'Forecast ' || to_char(par_fcst_id) || ' not found');
      end if;
      close csr_fcst;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Log the event start
      /*-*/
      lics_logging.write_log('Begin - Business Review Creation - Parameters(' || to_char(par_fcst_id) || ')');

      /*-*/
      /* Create the business review
      /*-*/
      begin
         lics_logging.write_log('--> Creating business review forecast');
         if demand_forecast.br_creation_check(rcd_fcst.fcst_id, var_result_msg) != common.gc_success then
            var_errors := true;
            lics_logging.write_log('--> Business review creation failed - '||var_result_msg);
         end if;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('--> Business review creation failed - '||substr(SQLERRM, 1, 2048));
      end;

      /*-*/
      /* Log the event end
      /*-*/
      lics_logging.write_log('End - Business Review Creation');

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
            lics_notification.send_email(df_parameter.system_code,
                                         df_parameter.system_unit,
                                         df_parameter.system_environment,
                                         con_function,
                                         'DF_BUSINESS_REVIEW_CREATION',
                                         var_email,
                                         'One or more errors occurred during the Demand Financials Business Review Creation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DF_BUSINESS_REVIEW - CREATION - ' || var_exception);

   end creation;

end df_business_review; 
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym df_business_review for df_app.df_business_review;
grant execute on df_business_review to public;