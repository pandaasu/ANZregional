/******************/
/* Package Header */
/******************/
create or replace package care_bw_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : care_bw_extract
    Owner   : cr_app

    Description
    -----------
    Care - BW Extract

    This package contains the extract procedure for the SAP BW system. The package exposes
    one procedure EXECUTE that performs the extract based on the following parameters:

    1. PAR_ROLLUP (Rollup codes - comma delimited string) (MANDATORY, CODE LENGTH 4)

       *NONE = Extract is performed for planning source codes
       XXXX = Extract is performed for rollup code

       YYYYPP - Period number
       *LAST - Last completed period

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_period in varchar2);

end care_bw_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body care_bw_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure extract(par_rollup in varchar2, par_plng_srce in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2);
   procedure extract_sales(par_rollup in varchar2, par_plng_srce in varchar2, par_company01 in varchar2, par_company02 in varchar2, par_company03 in varchar2, par_segment in varchar2, par_period in number);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'Care Factory Sales Extract';
   con_alt_group constant varchar2(32) := 'CARE_EXTRACT';
   con_alt_code constant varchar2(32) := 'ALERT_STRING';
   con_ema_group constant varchar2(32) := 'CARE_EXTRACT';
   con_ema_code constant varchar2(32) := 'EMAIL_GROUP';

   /*-*/
   /* Private definitions
   /*-*/
   var_hidx number;
   type typ_output is table of varchar2(4000) index by binary_integer;
   tbl_output typ_output;
   type rcd_rollup is record(matl_code varchar2(18 char),
                             cntry_code_en varchar2(20 char),
                             sales_cases number,
                             num_units_case number,
                             num_outers_case number);
   type typ_rollup is table of rcd_rollup index by varchar2(64 char);
   tbl_rollup typ_rollup;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_period in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_file_name varchar2(64);
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_errors boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CARE FACTORY SALES - EXTRACT ALL';
      var_log_search := 'CARE_FACTORY_SALES_EXTRACT_ALL';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Care Factory Sales Extract All - Parameters(' || par_period || ')');

      /*-*/
      /* Perform the extracts
      /*-*/
      begin

         /*-*/
         /* Clear the extract data when required
         /*-*/
         var_hidx := 0;
         tbl_output.delete;



         /*-*/
         /* Create the interface
         /*-*/
         var_file_name := 'CARSBW01.TXT';
         var_instance := lics_outbound_loader.create_interface('CARSBW01',var_file_name);

         /*-*/
         /* Append the interface records
         /*-*/
         for idx in 1..tbl_output.count loop
            lics_outbound_loader.append_data(tbl_output(idx));
         end loop;

         /*-*/
         /* Finalise the interface
         /*-*/
         lics_outbound_loader.finalise_interface;

      exception
         when others then
            if lics_outbound_loader.is_created = true then
               lics_outbound_loader.add_exception(substr(SQLERRM, 1, 2048));
               lics_outbound_loader.finalise_interface;
            end if;
            var_errors := true;
      end;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Care Factory Sales Extract All');

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
            lics_notification.send_email(lics_parameter.system_code,
                                         lics_parameter.system_unit,
                                         lics_parameter.system_environment,
                                         con_function,
                                         'CARE_FACTORY_SALES_EXTRACT_ALL',
                                         var_email,
                                         'One or more errors occurred during the Care factory sales extract all execution - refer to web log - ' || lics_logging.callback_identifier);
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
         var_exception := substr(SQLERRM, 1, 2048);

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
         raise_application_error(-20000, 'FATAL ERROR - CARE FACTORY SALES - EXTRACT ALL - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_all;

end care_bw_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym care_bw_extract for cr_app.care_bw_extract;
grant execute on care_bw_extract to public;
