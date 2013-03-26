/******************/
/* Package Header */
/******************/
create or replace package ods_app.ods_efex_validation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : ods_efex_validation
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex Validation

    This package contain the efex validation procedures. The package exposes one
    procedure EXECUTE that performs the validation based on the following parameters:

    1. PAR_MARKET (market code) (MANDATORY)

       The market for which the validation is to be performed.

    **notes**
    1. A web log is produced under the search value ODS_EFEX_VALIDATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All tables will attempt to be validated and and errors logged.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/06   Steve Gregan   Created
    2010/09   Steve Gregan   Fixed the validate_efex_matl_matl_subgrp routine to check
                             both valid and unchecked efex_matl_matl_subgrp rows

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number);

end ods_efex_validation; 

/****************/
/* Package Body */
/****************/
create or replace package body ods_app.ods_efex_validation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);
   snapshot_exception exception;
   pragma exception_init(snapshot_exception, -1555);

   /*-*/
   /* Private declarations
   /*-*/
   procedure align_data(par_market in number);
   procedure validate_efex_sgmnt(par_market in number);
   procedure validate_efex_sales_terr(par_market in number);
   procedure validate_efex_matl_grp(par_market in number);
   procedure validate_efex_matl_subgrp(par_market in number);
   procedure validate_efex_matl_matl_subgrp(par_market in number);
   procedure validate_efex_cust(par_market in number);
   procedure validate_efex_route_sched(par_market in number);
   procedure validate_efex_route_plan(par_market in number);
   procedure validate_efex_call(par_market in number);
   procedure validate_efex_timesheet_call(par_market in number);
   procedure validate_efex_timesheet_day(par_market in number);
   procedure validate_efex_assmnt_questn(par_market in number);
   procedure validate_efex_assmnt_assgnmnt(par_market in number);
   procedure validate_efex_assmnt(par_market in number);
   procedure validate_efex_range_matl(par_market in number);
   procedure validate_efex_distbn(par_market in number);
   procedure validate_efex_distbn_tot(par_market in number);
   procedure validate_efex_order(par_market in number);
   procedure validate_efex_order_matl(par_market in number);
   procedure validate_efex_pmt(par_market in number);
   procedure validate_efex_pmt_deal(par_market in number);
   procedure validate_efex_pmt_rtn(par_market in number);
   procedure validate_efex_mrq(par_market in number);
   procedure validate_efex_mrq_task(par_market in number);
   procedure validate_efex_mrq_task_matl(par_market in number);
   procedure validate_efex_target(par_market in number);
   procedure validate_efex_user_sgmnt(par_market in number);
   procedure validate_efex_cust_note(par_market in number);
   procedure send_emails(par_market in number);
   procedure process_emails(par_market in number, par_bus_unit in number, par_job_type in number, par_company in varchar2, par_text in varchar2);
   procedure clear_reasons(par_market in number, par_rea_type in varchar2);
   procedure add_reason(par_rea_start in boolean,
                        par_rea_type in number,
                        par_rea_message in varchar2,
                        par_mkt_id in number,
                        par_bus_id in number,
                        par_rea_code1 in varchar2,
                        par_rea_code2 in varchar2,
                        par_rea_code3 in varchar2,
                        par_rea_code4 in varchar2);

   /*-*/
   /* Private constants
   /*-*/
   pcon_com_count constant number := 10000;

   /*-*/
   /* Private definitions
   /*-*/
   pvar_hdr_seqn number;
   pvar_det_seqn number;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_market in number) is

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
      var_market number;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'ODS EFEX Validation';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'VENUS - ODS_EFEX_VALIDATION';
      var_log_search := 'ODS_EFEX_VALIDATION' || '_' || lics_stream_processor.callback_event;
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
      if par_market is null then
         raise_application_error(-20000, 'Market parameter must be supplied');
      end if;
      var_market := par_market;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Efex Validation - Parameters (Market = ' || var_market || ')');

      /*-*/
      /* Request the lock on the aggregation
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
         /* Execute the validation procedures
         /*-*/
         begin
            align_data(var_market);
            validate_efex_sgmnt(var_market);
            validate_efex_sales_terr(var_market);
            validate_efex_matl_grp(var_market);
            validate_efex_matl_subgrp(var_market);
            validate_efex_matl_matl_subgrp(var_market);
            validate_efex_cust(var_market);
            validate_efex_route_sched(var_market);
            validate_efex_route_plan(var_market);
            validate_efex_call(var_market);
            validate_efex_timesheet_call(var_market);
            validate_efex_timesheet_day(var_market);
            validate_efex_assmnt_questn(var_market);
            validate_efex_assmnt_assgnmnt(var_market);
            validate_efex_assmnt(var_market);
            validate_efex_range_matl(var_market);
            validate_efex_distbn(var_market);
            validate_efex_distbn_tot(var_market);
            validate_efex_order(var_market);
            validate_efex_order_matl(var_market);
            validate_efex_pmt(var_market);
            validate_efex_pmt_deal(var_market);
            validate_efex_pmt_rtn(var_market);
            validate_efex_mrq(var_market);
            validate_efex_mrq_task(var_market);
            validate_efex_mrq_task_matl(var_market);
            validate_efex_target(var_market);
            validate_efex_user_sgmnt(var_market);
            validate_efex_cust_note(var_market);
            send_emails(var_market);
         exception
              when others then
                 var_errors := true;
         end;

         /*-*/
         /* Release the lock on the aggregation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;
      var_locked := false;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Efex Validation');

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
                                         'ODS_EFEX_VALIDATION',
                                         var_email,
                                         'One or more errors occurred during the Efex Validation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

      end if;

      utils.send_short_email('Group_ANZ_Venus_Production_Notification@smtp.ap.mars', 'Efex Validation', 'Efex Validation Completed for: ' || var_market);

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
         raise_application_error(-20000, 'FATAL ERROR - ODS_EFEX_VALIDATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**************************************************/
   /* This procedure performs the align data routine */
   /**************************************************/
   procedure align_data(par_market in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Align Data');

      /*-*/
      /* Update the material subgroup status
      /*-*/
      update efex_matl_subgrp t01
         set status = 'X'
       where status = 'A'
         and exists (select 'x'
                       from efex_matl_grp
                      where matl_grp_id = t01.matl_grp_id
                        and status = 'X');
      commit;

      /*-*/
      /* Update the material material subgroup status
      /*-*/
      update efex_matl_matl_subgrp t01
         set status = 'X'
       where status = 'A'
         and exists (select 'x'
                       from efex_matl
                      where efex_matl_id = t01.efex_matl_id
                        and status = 'X');
      commit;

      update efex_matl_matl_subgrp t01
         set status = 'X'
       where status = 'A'
         and exists (select 'x'
                       from efex_matl_subgrp
                      where matl_subgrp_id = t01.matl_subgrp_id
                        and status = 'X');
      commit;

      /*-*/
      /* Update the range material status
      /*-*/
      update efex_range_matl t01
         set status = 'X'
       where status = 'A'
         and exists (select 'x'
                       from efex_matl
                      where efex_matl_id = t01.efex_matl_id
                        and status = 'X');
      commit;

      /*-*/
      /* Delete the distribution where customer was deleted before initial load
      /*-*/
      delete from efex_distbn t01
       where not exists (select 'x'
                           from efex_cust
                          where efex_cust_id = t01.efex_cust_id);
      commit;

      /*-*/
      /* Update the distribution status
      /*-*/
      update efex_distbn t01
         set status = 'X'
       where status = 'A'
         and exists (select 'x'
                       from efex_cust
                      where efex_cust_id = t01.efex_cust_id
                        and status = 'X');
      commit;

      update efex_distbn t01
         set status = 'X'
       where status = 'A'
         and exists (select 'x'
                       from efex_matl
                      where efex_matl_id = t01.efex_matl_id
                        and status = 'X');
      commit;

      /*-*/
      /* Delete the distribution where status = X and not loaded to DDS at all
      /*-*/
      delete from efex_distbn t01
       where status = 'X'
         and not exists (select 'x'
                           from efex_distbn_dim
                          where efex_cust_id = t01.efex_cust_id
                            and efex_matl_id = t01.efex_matl_id);
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Align Data');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Align Data - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Align Data');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end align_data;

   /*************************************************************/
   /* This procedure performs the validate Efex segment routine */
   /*************************************************************/
   procedure validate_efex_sgmnt(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_sgmnt t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Segment');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_sgmnt);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_sgmnt
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sgmnt,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.sgmnt_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_sgmnt
            set valdtn_status = var_valdtn_status
          where sgmnt_id = rcd_list.sgmnt_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Segment');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Segment - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Segment');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_sgmnt;

   /*********************************************************************/
   /* This procedure performs the validate Efex sales territory routine */
   /*********************************************************************/
   procedure validate_efex_sales_terr(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id,
                (select user_id from efex_user where user_id = t01.sales_terr_user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id
           from efex_sales_terr t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Sales Territory');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_sales_terr);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_sales_terr
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sales_terr,
                       'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.sales_terr_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sales_terr,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.sales_terr_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sales_terr,
                       'Invalid or non-existant Sales Territory User Id - ' || rcd_list.sales_terr_user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.sales_terr_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_sales_terr
            set valdtn_status = var_valdtn_status
          where sales_terr_id = rcd_list.sales_terr_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Sales Territory');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Sales Territory - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Sales Territory');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_sales_terr;

   /********************************************************************/
   /* This procedure performs the validate Efex material group routine */
   /********************************************************************/
   procedure validate_efex_matl_grp(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_matl_grp t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Material Group');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_matl_grp);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_matl_grp
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_grp,
                       'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.matl_grp_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_grp,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.matl_grp_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_matl_grp
            set valdtn_status = var_valdtn_status
          where matl_grp_id = rcd_list.matl_grp_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Material Group');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Material Group - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Material Group');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_matl_grp;

   /************************************************************************/
   /* This procedure performs the validate Efex material sub group routine */
   /************************************************************************/
   procedure validate_efex_matl_subgrp(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select matl_grp_id from efex_matl_grp where matl_grp_id = t01.matl_grp_id and valdtn_status = ods_constants.valdtn_valid) as chk_matl_grp_id
           from efex_matl_subgrp t01,
                efex_matl_grp t02
          where t01.matl_grp_id = t02.matl_grp_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Material Sub Group');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_matl_subgrp);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_matl_subgrp
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the material group
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_matl_grp_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_subgrp,
                       'Invalid or non-existant Material Group Id - ' || rcd_list.matl_grp_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.matl_subgrp_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_matl_subgrp
            set valdtn_status = var_valdtn_status
          where matl_subgrp_id = rcd_list.matl_subgrp_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Material Sub Group');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Material Sub Group - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Material Sub Group');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_matl_subgrp;

   /*********************************************************************************/
   /* This procedure performs the validate Efex material material sub group routine */
   /*********************************************************************************/
   procedure validate_efex_matl_matl_subgrp(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_matl_id from efex_matl where efex_matl_id = t01.efex_matl_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_matl_id,
                (select matl_subgrp_id from efex_matl_subgrp where matl_subgrp_id = t01.matl_subgrp_id and valdtn_status = ods_constants.valdtn_valid) as chk_matl_subgrp_id,
                (select matl_grp_id from efex_matl_grp where matl_grp_id = t01.matl_grp_id and valdtn_status = ods_constants.valdtn_valid) as chk_matl_grp_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id,
                nvl((select count(*) from efex_matl_matl_subgrp where efex_matl_id = t01.efex_matl_id and sgmnt_id = t01.sgmnt_id and matl_subgrp_id != t01.matl_subgrp_id and status = 'A' and (valdtn_status = ods_constants.valdtn_valid or valdtn_status = ods_constants.valdtn_unchecked)),0) as chk_count
           from efex_matl_matl_subgrp t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Material Material Sub Group');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_matl_m_subgrp);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_matl_matl_subgrp
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the material
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_matl_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_m_subgrp,
                       'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant EFEX Material Id - ' || rcd_list.efex_matl_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_matl_id,
                       rcd_list.matl_subgrp_id,
                       rcd_list.sgmnt_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material sub group
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_matl_subgrp_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_m_subgrp,
                       'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Material Sub Group Id - ' || rcd_list.matl_subgrp_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_matl_id,
                       rcd_list.matl_subgrp_id,
                       rcd_list.sgmnt_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material group
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_matl_grp_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_m_subgrp,
                       'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Material Group Id - ' || rcd_list.matl_grp_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_matl_id,
                       rcd_list.matl_subgrp_id,
                       rcd_list.sgmnt_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_m_subgrp,
                       'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_matl_id,
                       rcd_list.matl_subgrp_id,
                       rcd_list.sgmnt_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_m_subgrp,
                       'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_matl_id,
                       rcd_list.matl_subgrp_id,
                       rcd_list.sgmnt_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sub group count
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_count != 0 then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_matl_m_subgrp,
                       'KEY: [matl-subgrp-sgmnt] - Invalid - matl assign to more than one subgrp for same segment.',
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_matl_id,
                       rcd_list.matl_subgrp_id,
                       rcd_list.sgmnt_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_matl_matl_subgrp
            set valdtn_status = var_valdtn_status
          where efex_matl_id = rcd_list.efex_matl_id
            and matl_subgrp_id = rcd_list.matl_subgrp_id
            and sgmnt_id = rcd_list.sgmnt_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Material Material Sub Group');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Material Material Sub Group - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Material Material Sub Group');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_matl_matl_subgrp;

   /**************************************************************/
   /* This procedure performs the validate Efex customer routine */
   /**************************************************************/
   procedure validate_efex_cust(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);
      var_work number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select range_id from efex_range where range_id = t01.range_id and valdtn_status = ods_constants.valdtn_valid) as chk_range_id,
                (select cust_type_id from efex_cust_chnl where cust_type_id = t01.cust_type_id and valdtn_status = ods_constants.valdtn_valid) as chk_cust_type_id,
                (select affltn_id from efex_affltn where affltn_id = t01.affltn_id and valdtn_status = ods_constants.valdtn_valid) as chk_affltn_id,
                (select cust_code from cust_dim where ltrim(cust_code,'0') = t01.cust_code) as chk_cust_code,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.distbr_id and (valdtn_status = ods_constants.valdtn_valid or valdtn_status = ods_constants.valdtn_unchecked)) as chk_distbr_id
           from efex_cust t01,
                efex_sales_terr t02
          where t01.sales_terr_id = t02.sales_terr_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked
          order by decode(t01.distbr_flg,'Y',1,'N',2,3);
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Customer');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_cust);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_cust
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.status = 'A' and rcd_list.sales_terr_id is not null then
            if rcd_list.chk_sales_terr_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          null,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the range
         /*-*/
         if rcd_list.status = 'A' and rcd_list.range_id is not null then
            if rcd_list.chk_range_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Invalid or non-existant Range Id - ' || rcd_list.range_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          null,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the customer type
         /*-*/
         if rcd_list.status = 'A' and rcd_list.cust_type_id is not null then
            if rcd_list.chk_cust_type_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Invalid or non-existant Cust Type Id - ' || rcd_list.cust_type_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          null,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the affiliation type
         /*-*/
         if rcd_list.status = 'A' and rcd_list.affltn_id is not null then
            if rcd_list.chk_affltn_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Invalid or non-existant Affiliation Id - ' || rcd_list.affltn_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          null,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the customer code
         /*-*/
         if rcd_list.status = 'A' and rcd_list.cust_code is not null and rcd_list.outlet_flg = 'N' then
            if rcd_list.chk_cust_code is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Invalid or non-existant Customer Code - ' || rcd_list.cust_code,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          null,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the GRD customer
         /*-*/
         if rcd_list.status = 'A' and rcd_list.outlet_flg = 'N' and rcd_list.distbr_flg = 'N' and rcd_list.cust_code is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust,
                       'Customer can not be outlet_flg = N and distributor_flg = N and customer_code IS NULL',
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the outlet customer
         /*-*/
         if rcd_list.status = 'A' and rcd_list.outlet_flg = 'Y' and rcd_list.cust_code is not null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust,
                       'Outlet customer should not be a Direct customer as well (have customer_code provided)',
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the distributor
         /* **note** Valid and Unchecked are tested as the Distributor may be assigned to itself in which case the validation status would be UNCHECKED.
         /*-*/
         if rcd_list.status = 'A' and rcd_list.distbr_id is not null then
            if rcd_list.chk_distbr_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Invalid or non-existant Distributor Id - ' || rcd_list.distbr_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          null,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the visit frequency
         /*-*/
         if rcd_list.status = 'A' and rcd_list.cust_visit_freq is not null then
            begin
               var_work := to_number(rcd_list.cust_visit_freq);
               if var_work < 0 then
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Customer Visit Frequency must be a positive number.',
                             par_market,
                             nvl(rcd_list.bus_unit_id,-1),
                             rcd_list.efex_cust_id,
                             null,
                             null,
                             null);
                  var_first := false;
               end if;
            exception
               when others then
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Customer Visit Frequency is not a number.',
                             par_market,
                             nvl(rcd_list.bus_unit_id,-1),
                             rcd_list.efex_cust_id,
                             null,
                             null,
                             null);
                  var_first := false;
            end;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_cust
            set valdtn_status = var_valdtn_status
          where efex_cust_id = rcd_list.efex_cust_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Customer');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Customer - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Customer');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_cust;

   /*********************************************************************/
   /* This procedure performs the validate Efex route scheduler routine */
   /*********************************************************************/
   procedure validate_efex_route_sched(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id
           from efex_route_sched t01,
                (select distinct user_id, bus_unit_id from efex_user_sgmnt) t02
          where t01.user_id = t02.user_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Route Scheduler');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_route_sched);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_route_sched
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_route_sched,
                       'KEY: [user-sched_date] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       to_char(rcd_list.route_sched_date,'dd-mon-yyyy hh24:mi:ss'),
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_route_sched
            set valdtn_status = var_valdtn_status
          where user_id = rcd_list.user_id
            and route_sched_date = rcd_list.route_sched_date;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Route Scheduler');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Route Scheduler - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Route Scheduler');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_route_sched;

   /****************************************************************/
   /* This procedure performs the validate Efex route plan routine */
   /****************************************************************/
   procedure validate_efex_route_plan(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_route_plan t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Route Plan');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_route_plan);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_route_plan
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_route_plan,
                       'KEY: [user-plan_date-cust] - Invalid or non-existant EFEX Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       to_char(rcd_list.route_plan_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.efex_cust_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_route_plan,
                       'KEY: [user-plan_date-cust] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       to_char(rcd_list.route_plan_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.efex_cust_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_route_plan,
                       'KEY: [user-plan_date-cust] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       to_char(rcd_list.route_plan_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.efex_cust_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_route_plan,
                       'KEY: [user-plan_date-cust] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       to_char(rcd_list.route_plan_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.efex_cust_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_route_plan,
                       'KEY: [user-plan_date-cust] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       to_char(rcd_list.route_plan_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.efex_cust_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_route_plan
            set valdtn_status = var_valdtn_status
          where user_id = rcd_list.user_id
            and route_plan_date = rcd_list.route_plan_date
            and efex_cust_id = rcd_list.efex_cust_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Route Plan');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Route Plan - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Route Plan');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_route_plan;

   /**********************************************************/
   /* This procedure performs the validate Efex call routine */
   /**********************************************************/
   procedure validate_efex_call(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_call t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Call');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_call);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_call
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_call,
                       'KEY: [cust-call_date-user] - Invalid or non-existant EFEX Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_call,
                       'KEY: [cust-call_date-user] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_call,
                       'KEY: [cust-call_date-user] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_call,
                       'KEY: [cust-call_date-user] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_call,
                       'KEY: [cust-call_date-user] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_call
            set valdtn_status = var_valdtn_status
          where efex_cust_id = rcd_list.efex_cust_id
            and call_date = rcd_list.call_date
            and user_id = rcd_list.user_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Call');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Call - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Call');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_call;

   /********************************************************************/
   /* This procedure performs the validate Efex timesheet call routine */
   /********************************************************************/
   procedure validate_efex_timesheet_call(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_timesheet_call t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Timesheet Call');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_tmesht_call);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_timesheet_call
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_tmesht_call,
                       'KEY: [cust-timesheet_date-user] - Invalid or non-existant EFEX Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_tmesht_call,
                       'KEY: [cust-timesheet_date-user] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_tmesht_call,
                       'KEY: [cust-timesheet_date-user] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_tmesht_call,
                       'KEY: [cust-timesheet_date-user] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_tmesht_call,
                       'KEY: [cust-timesheet_date-user] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
                       rcd_list.user_id,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_timesheet_call
            set valdtn_status = var_valdtn_status
          where efex_cust_id = rcd_list.efex_cust_id
            and timesheet_date = rcd_list.timesheet_date
            and user_id = rcd_list.user_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Timesheet Call');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Timesheet Call - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Timesheet Call');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_timesheet_call;

   /*******************************************************************/
   /* This procedure performs the validate Efex timesheet day routine */
   /*******************************************************************/
   procedure validate_efex_timesheet_day(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id
           from efex_timesheet_day t01,
                (select distinct user_id, bus_unit_id from efex_user_sgmnt) t02
          where t01.user_id = t02.user_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Timesheet Day');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_tmesht_day);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_timesheet_day
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_tmesht_day,
                       'KEY: [user-timesheet_date] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_timesheet_day
            set valdtn_status = var_valdtn_status
          where user_id = rcd_list.user_id
            and timesheet_date = rcd_list.timesheet_date;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Timesheet Day');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Timesheet Day - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Timesheet Day');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_timesheet_day;

   /*************************************************************************/
   /* This procedure performs the validate Efex assessment question routine */
   /*************************************************************************/
   procedure validate_efex_assmnt_questn(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_assmnt_questn t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Assessment Question');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_ass_questn);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_assmnt_questn
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_ass_questn,
                       'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_ass_questn,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_assmnt_questn
            set valdtn_status = var_valdtn_status
          where assmnt_id = rcd_list.assmnt_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Assessment Question');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Assessment Question - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Assessment Question');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_assmnt_questn;

   /***************************************************************************/
   /* This procedure performs the validate Efex assessment assignment routine */
   /***************************************************************************/
   procedure validate_efex_assmnt_assgnmnt(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select assmnt_id from efex_assmnt_questn where assmnt_id = t01.assmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_assmnt_id,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id,
                (select cust_type_id from efex_cust_chnl where cust_type_id = t01.cust_type_id and valdtn_status = ods_constants.valdtn_valid) as chk_cust_type_id,
                (select affltn_id from efex_affltn where affltn_id = t01.affltn_id and valdtn_status = ods_constants.valdtn_valid) as chk_affltn_id
           from efex_assmnt_assgnmnt t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Assessment Assignment');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_ass_assgn);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_assmnt_assgnmnt
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the assessment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_assmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_ass_assgn,
                       'KEY: [assmnt-cust] - Invalid or non-existant Assessment Id - ' || rcd_list.assmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_ass_assgn,
                       'KEY: [assmnt-cust] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.sales_terr_id is not null then
            if rcd_list.chk_sales_terr_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_assgn,
                          'KEY: [assmnt-cust] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.assmnt_id,
                          rcd_list.efex_cust_id,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_ass_assgn,
                       'KEY: [assmnt-cust] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_ass_assgn,
                       'KEY: [assmnt-cust] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the customer type
         /*-*/
         if rcd_list.status = 'A' and rcd_list.cust_type_id is not null then
            if rcd_list.chk_cust_type_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_assgn,
                          'KEY: [assmnt-cust] - Invalid or non-existant Customer Type Id - ' || rcd_list.cust_type_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.assmnt_id,
                          rcd_list.efex_cust_id,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Validate the affiliation
         /*-*/
         if rcd_list.status = 'A' and rcd_list.affltn_id is not null then
            if rcd_list.chk_affltn_id is null then
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_assgn,
                          'KEY: [assmnt-cust] - Invalid or non-existant Affiliation Id - ' || rcd_list.affltn_id,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.assmnt_id,
                          rcd_list.efex_cust_id,
                          null,
                          null);
               var_first := false;
            end if;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_assmnt_assgnmnt
            set valdtn_status = var_valdtn_status
          where assmnt_id = rcd_list.assmnt_id
            and efex_cust_id = rcd_list.efex_cust_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Assessment Assignment');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Assessment Assignment - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Assessment Assignment');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_assmnt_assgnmnt;

   /****************************************************************/
   /* This procedure performs the validate Efex assessment routine */
   /****************************************************************/
   procedure validate_efex_assmnt(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select assmnt_id from efex_assmnt_questn where assmnt_id = t01.assmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_assmnt_id,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id
           from efex_assmnt t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Assessment');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_assmnt);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_assmnt
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the assessment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_assmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_assmnt,
                       'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Assessment Id - ' || rcd_list.assmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_assmnt,
                       'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_assmnt,
                       'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_assmnt,
                       'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_assmnt,
                       'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_assmnt,
                       'KEY: [assmnt-cust-resp_date] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.assmnt_id,
                       rcd_list.efex_cust_id,
                       to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_assmnt
            set valdtn_status = var_valdtn_status
          where assmnt_id = rcd_list.assmnt_id
            and efex_cust_id = rcd_list.efex_cust_id
            and resp_date = rcd_list.resp_date;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Assessment');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Assessment - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Assessment');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_assmnt;

   /********************************************************************/
   /* This procedure performs the validate Efex range material routine */
   /********************************************************************/
   procedure validate_efex_range_matl(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select range_id from efex_range where range_id = t01.range_id and valdtn_status = ods_constants.valdtn_valid) as chk_range_id,
                (select efex_matl_id from efex_matl where efex_matl_id = t01.efex_matl_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_matl_id
           from efex_range_matl t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Range Material');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_range_matl);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_range_matl
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the range
         /*-*/
         if rcd_list.chk_range_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_range_matl,
                       'KEY: [range-matl] - Invalid or non-existant Range Id - ' || rcd_list.range_id,
                       par_market,
                       -1,
                       rcd_list.range_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material
         /*-*/
         if rcd_list.chk_efex_matl_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_range_matl,
                       'KEY: [range-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       par_market,
                       -1,
                       rcd_list.range_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the required flag
         /*-*/
         if rcd_list.rqd_flg is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_range_matl,
                       'KEY: [range-matl] - Required flag has not been provided.',
                       par_market,
                       -1,
                       rcd_list.range_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_range_matl
            set valdtn_status = var_valdtn_status
          where range_id = rcd_list.range_id
            and efex_matl_id = rcd_list.efex_matl_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Range Material');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Range Material - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Range Material');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_range_matl;

   /******************************************************************/
   /* This procedure performs the validate Efex distribution routine */
   /******************************************************************/
   procedure validate_efex_distbn(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id,
                (select range_id from efex_range where range_id = t01.range_id and valdtn_status = ods_constants.valdtn_valid) as chk_range_id,
                (select efex_matl_id from efex_matl where efex_matl_id = t01.efex_matl_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_matl_id,
                (select nvl(count(*),0) from efex_matl_matl_subgrp where efex_matl_id = t01.efex_matl_id and sgmnt_id = t01.sgmnt_id and status = 'A' and valdtn_status = ods_constants.valdtn_valid) as chk_subgrp_count
           from efex_distbn t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Distribution');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_distbn);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_distbn
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the range
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Range Id - ' || rcd_list.range_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_matl_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material material sub group
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_subgrp_count = 0 then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - No subgroup found in efex_distbn',
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_distbn
            set valdtn_status = var_valdtn_status
          where efex_cust_id = rcd_list.efex_cust_id
            and efex_matl_id = rcd_list.efex_matl_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Distribution');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Distribution - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Distribution');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_distbn;

   /************************************************************************/
   /* This procedure performs the validate Efex distribution total routine */
   /************************************************************************/
   procedure validate_efex_distbn_tot(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select matl_grp_id from efex_matl_grp where matl_grp_id = t01.matl_grp_id and valdtn_status = ods_constants.valdtn_valid) as chk_matl_grp_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id
           from efex_distbn_tot t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Distribution Total');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_distbn_tot);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_distbn_tot
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.matl_grp_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material group
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_matl_grp_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.matl_grp_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.matl_grp_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.matl_grp_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.matl_grp_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.matl_grp_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_cust_id,
                       rcd_list.matl_grp_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_distbn_tot
            set valdtn_status = var_valdtn_status
          where efex_cust_id = rcd_list.efex_cust_id
            and matl_grp_id = rcd_list.matl_grp_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Distribution Total');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Distribution Total - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Distribution Total');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_distbn_tot;

   /***********************************************************/
   /* This procedure performs the validate Efex order routine */
   /***********************************************************/
   procedure validate_efex_order(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_order t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Order');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_order);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_order
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_order
            set valdtn_status = var_valdtn_status
          where efex_order_id = rcd_list.efex_order_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Order');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Order - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Order');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_order;

   /********************************************************************/
   /* This procedure performs the validate Efex order material routine */
   /********************************************************************/
   procedure validate_efex_order_matl(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select efex_order_id from efex_order where efex_order_id = t01.efex_order_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_order_id,
                (select efex_matl_id from efex_matl where efex_matl_id = t01.efex_matl_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_matl_id,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.matl_distbr_id and valdtn_status = ods_constants.valdtn_valid) as chk_matl_distbr_id
           from efex_order_matl t01,
                efex_order t02
          where t01.efex_order_id = t02.efex_order_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Order Material');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_order_matl);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_order_matl
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the order
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_order_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order_matl,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Order Id - ' || rcd_list.efex_order_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_matl_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order_matl,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material distributor
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_matl_distbr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order_matl,
                       'KEY: [cust-matl] - Invalid or non-existant Material Distributor Id - ' || rcd_list.matl_distbr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.efex_order_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_order_matl
            set valdtn_status = var_valdtn_status
          where efex_order_id = rcd_list.efex_order_id
            and efex_matl_id = rcd_list.efex_matl_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Order Material');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Order Material - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Order Material');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_order_matl;

   /*************************************************************/
   /* This procedure performs the validate Efex payment routine */
   /*************************************************************/
   procedure validate_efex_pmt(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_pmt t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Payment');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_pmt);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_pmt
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.efex_cust_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_pmt
            set valdtn_status = var_valdtn_status
          where pmt_id = rcd_list.pmt_id
            and efex_cust_id = rcd_list.efex_cust_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Payment');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Payment - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Payment');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_pmt;

   /******************************************************************/
   /* This procedure performs the validate Efex payment deal routine */
   /******************************************************************/
   procedure validate_efex_pmt_deal(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select pmt_id from efex_pmt where pmt_id = t01.pmt_id and valdtn_status = ods_constants.valdtn_valid) as chk_pmt_id,
                (select efex_order_id from efex_order where efex_order_id = t01.efex_order_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_order_id
           from efex_pmt_deal t01,
                efex_pmt t02
          where t01.pmt_id = t02.pmt_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Payment Deal');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_pmt_deal);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_pmt_deal
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the payment
         /*-*/
         if rcd_list.chk_pmt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_deal,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Payment Id - ' || rcd_list.pmt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.seq_num,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the order
         /*-*/
         if not(rcd_list.efex_order_id is null) and rcd_list.chk_efex_order_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_deal,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Efex Order Id - ' || rcd_list.efex_order_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.seq_num,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_pmt_deal
            set valdtn_status = var_valdtn_status
          where pmt_id = rcd_list.pmt_id
            and seq_num = rcd_list.seq_num;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Payment Deal');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Payment Deal - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Payment Deal');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_pmt_deal;

   /********************************************************************/
   /* This procedure performs the validate Efex payment return routine */
   /********************************************************************/
   procedure validate_efex_pmt_rtn(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select pmt_id from efex_pmt where pmt_id = t01.pmt_id and valdtn_status = ods_constants.valdtn_valid) as chk_pmt_id,
                (select efex_matl_id from efex_matl where efex_matl_id = t01.efex_matl_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_matl_id
           from efex_pmt_rtn t01,
                efex_pmt t02
          where t01.pmt_id = t02.pmt_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Payment Return');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_pmt_rtn);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_pmt_rtn
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the payment
         /*-*/
         if rcd_list.chk_pmt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_rtn,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Payment Id - ' || rcd_list.pmt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.seq_num,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material
         /*-*/
         if not(rcd_list.efex_matl_id is null) and rcd_list.chk_efex_matl_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_rtn,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.pmt_id,
                       rcd_list.seq_num,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_pmt_rtn
            set valdtn_status = var_valdtn_status
          where pmt_id = rcd_list.pmt_id
            and seq_num = rcd_list.seq_num;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Payment Return');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Payment Return - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Payment Return');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_pmt_rtn;

   /***************************************************************************/
   /* This procedure performs the validate Efex merchandising request routine */
   /***************************************************************************/
   procedure validate_efex_mrq(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_mrq t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Merchandising Request');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_mrq);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_mrq
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.mrq_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.mrq_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.mrq_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.mrq_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.mrq_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the completed flag
         /*-*/
         if rcd_list.completed_flg is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - ICompleted Flg has not been provided',
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.mrq_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_mrq
            set valdtn_status = var_valdtn_status
          where mrq_id = rcd_list.mrq_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Merchandising Request');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Merchandising Request - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Merchandising Request');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_mrq;

   /********************************************************************************/
   /* This procedure performs the validate Efex merchandising request task routine */
   /********************************************************************************/
   procedure validate_efex_mrq_task(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                t02.bus_unit_id,
                (select mrq_id from efex_mrq where mrq_id = t01.mrq_id and valdtn_status = ods_constants.valdtn_valid) as chk_mrq_id
           from efex_mrq_task t01,
                efex_mrq t02
          where t01.mrq_id = t02.mrq_id(+)
            and t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Merchandising Request Task');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_mrq_task);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_mrq_task
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the merchandising request
         /*-*/
         if not(rcd_list.mrq_id is null) and rcd_list.chk_mrq_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq_task,
                       'KEY: [mrq_task] - Invalid or non-existant MRQ Id - ' || rcd_list.mrq_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.mrq_task_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_mrq_task
            set valdtn_status = var_valdtn_status
          where mrq_task_id = rcd_list.mrq_task_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Merchandising Request Task');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Merchandising Request Task - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Merchandising Request Task');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_mrq_task;

   /*****************************************************************************************/
   /* This procedure performs the validate Efex merchandising request task material routine */
   /*****************************************************************************************/
   procedure validate_efex_mrq_task_matl(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select mrq_task_id from efex_mrq_task where mrq_task_id = t01.mrq_task_id and valdtn_status = ods_constants.valdtn_valid) as chk_mrq_task_id,
                (select efex_matl_id from efex_matl where efex_matl_id = t01.efex_matl_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_matl_id
           from efex_mrq_task_matl t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Merchandising Request Task Material');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_mrq_task_matl);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_mrq_task_matl
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the merchandising request task
         /*-*/
         if rcd_list.chk_mrq_task_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq_task_matl,
                       'KEY: [mrq_task-matl] - Invalid or non-existant MRQ Task Id - ' || rcd_list.mrq_task_id,
                       par_market,
                       2,
                       rcd_list.mrq_task_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the material
         /*-*/
         if rcd_list.chk_efex_matl_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq_task_matl,
                       'KEY: [mrq_task-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       par_market,
                       2,
                       rcd_list.mrq_task_id,
                       rcd_list.efex_matl_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_mrq_task_matl
            set valdtn_status = var_valdtn_status
          where mrq_task_id = rcd_list.mrq_task_id
            and efex_matl_id = rcd_list.efex_matl_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Merchandising Request Task Material');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Merchandising Request Task Material - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Merchandising Request Task Material');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_mrq_task_matl;

   /************************************************************/
   /* This procedure performs the validate Efex target routine */
   /************************************************************/
   procedure validate_efex_target(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_target t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Target');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_target);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_target
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_target,
                       'KEY: [sales_terr-target-mars_period] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.sales_terr_id,
                       rcd_list.target_id,
                       rcd_list.mars_period,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_target,
                       'KEY: [sales_terr-target-mars_period] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.sales_terr_id,
                       rcd_list.target_id,
                       rcd_list.mars_period,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_target
            set valdtn_status = var_valdtn_status
          where sales_terr_id = rcd_list.sales_terr_id
            and target_id = rcd_list.target_id
            and mars_period = rcd_list.mars_period;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Target');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Target - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Target');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_target;

   /******************************************************************/
   /* This procedure performs the validate Efex user segment routine */
   /******************************************************************/
   procedure validate_efex_user_sgmnt(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select user_id from efex_user where user_id = t01.user_id and valdtn_status = ods_constants.valdtn_valid) as chk_user_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_user_sgmnt t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex User Segment');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_user_sgmnt);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_user_sgmnt
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_user_sgmnt,
                       'KEY: [user-segment] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       rcd_list.sgmnt_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_user_sgmnt,
                       'KEY: [user-segment] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       rcd_list.sgmnt_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_user_sgmnt,
                       'KEY: [user-segment] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       rcd_list.sgmnt_id,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_user_sgmnt
            set valdtn_status = var_valdtn_status
          where user_id = rcd_list.user_id
            and sgmnt_id = rcd_list.sgmnt_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex User Segment');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex User Segment - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex User Segment');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_user_sgmnt;

   /*******************************************************************/
   /* This procedure performs the validate Efex customer note routine */
   /*******************************************************************/
   procedure validate_efex_cust_note(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_first boolean;
      var_valdtn_status varchar2(10);
      var_wrk_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*,
                (select efex_cust_id from efex_cust where efex_cust_id = t01.efex_cust_id and valdtn_status = ods_constants.valdtn_valid) as chk_efex_cust_id,
                (select sales_terr_id from efex_sales_terr where sales_terr_id = t01.sales_terr_id and valdtn_status = ods_constants.valdtn_valid) as chk_sales_terr_id,
                (select sgmnt_id from efex_sgmnt where sgmnt_id = t01.sgmnt_id and valdtn_status = ods_constants.valdtn_valid) as chk_sgmnt_id,
                (select bus_unit_id from efex_bus_unit where bus_unit_id = t01.bus_unit_id and valdtn_status = ods_constants.valdtn_valid) as chk_bus_unit_id
           from efex_cust_note t01
          where t01.efex_mkt_id = par_market
            and t01.valdtn_status = ods_constants.valdtn_unchecked;
      rcd_list csr_list%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Validate Efex Customer Note');

      /*-*/
      /* Clear validation reason tables for the validation type
      /*-*/
      clear_reasons(par_market, ods_constants.valdtn_type_efex_cust_note);

      /*-*/
      /* Reset any invalid data to unchecked
      /*-*/
      update efex_cust_note
         set valdtn_status = ods_constants.valdtn_unchecked
       where valdtn_status = ods_constants.valdtn_invalid;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      open csr_list;
      loop
         if var_count >= pcon_com_count then
            if csr_list%isopen then
               close csr_list;
            end if;
            commit;
            open csr_list;
            var_count := 0;
         end if;
         fetch csr_list into rcd_list;
         if csr_list%notfound then
            exit;
         end if;
         var_count := var_count + 1;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.cust_note_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.chk_sales_terr_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.cust_note_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.cust_note_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.cust_note_id,
                       null,
                       null,
                       null);
            var_first := false;
         end if;

         /*-*/
         /* Validate the created date
         /*-*/
         if not(rcd_list.cust_note_created is null) then
            begin
               var_wrk_date := to_date(rcd_list.cust_note_created,'yyyy/mm/dd hh24:mi:ss');
            exception
               when others then
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust_note,
                             'KEY: [cust_note] - Invalid - cust_note_created must be in [YYYY/MM/DD HH24:MI:SS] Date Format - ' || rcd_list.cust_note_created,
                             par_market,
                             nvl(rcd_list.bus_unit_id,-1),
                             rcd_list.cust_note_id,
                             null,
                             null,
                             null);
                  var_first := false;
            end;
         end if;

         /*-*/
         /* Update the validation status
         /*-*/
         if var_first = false then
            var_valdtn_status := ods_constants.valdtn_invalid;
         end if;
         update efex_cust_note
            set valdtn_status = var_valdtn_status
          where cust_note_id = rcd_list.cust_note_id;

      end loop;
      close csr_list;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Validate Efex Customer Note');

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
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Validate Efex Customer Note - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Validate Efex Customer Note');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end validate_efex_cust_note;

   /***************************************************/
   /* This procedure performs the send emails routine */
   /***************************************************/
   procedure send_emails(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_company varchar2(10);
      con_bus_unit_147_pet constant number := 1;
      con_bus_unit_147_snack constant number := 2;
      con_bus_unit_147_food constant number := 4;
      con_bus_unit_149 constant number := 7;
      con_job_type_147_pet constant number := 23;
      con_job_type_147_snack constant number := 22;
      con_job_type_147_food constant number := 24;
      con_job_type_149 constant number := 22;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Send Emails');

      /*-*/
      /* Assign the company code
      /*-*/
      if par_market = 1 then
         var_company := '147';
         process_emails(par_market, con_bus_unit_147_pet, con_job_type_147_pet, var_company, 'Pet');
         process_emails(par_market, con_bus_unit_147_snack, con_job_type_147_snack, var_company, 'Snack');
         process_emails(par_market, con_bus_unit_147_food, con_job_type_147_food, var_company, 'Food');
      elsif par_market = 5 then
         var_company := '149';
         process_emails(par_market, con_bus_unit_149, con_job_type_149, var_company, 'New Zealand');
      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Send Emails');

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
--         rollback;

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - Send Emails - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Send Emails');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
       --  raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_emails;

   /******************************************************/
   /* This procedure performs the process emails routine */
   /******************************************************/
   procedure process_emails(par_market in number, par_bus_unit in number, par_job_type in number, par_company in varchar2, par_text in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_valdtn_type_code number;
      var_row_count number;
      var_prt_count number;
      con_max_row constant number := 32500;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_email is
         select distinct(t01.email_address) as email_address
           from email_list t01
          where t01.company_code = par_company
            and t01.job_type_code = par_job_type
          order by email_address asc;

      cursor csr_data is
         select t01.valdtn_type_code,
                regexp_replace(t03.valdtn_type_desc,' ','_') as valdtn_type_desc,
                key_text as valdtn_key,
                to_char(t02.det_seqn) as valdtn_seq,
                t02.msg_text as valdtn_reasn_dtl_msg
           from efex_mesg_hdr t01,
                efex_mesg_det t02,
                valdtn_type t03
          where t01.hdr_seqn = t02.hdr_seqn
            and t01.valdtn_type_code = t03.valdtn_type_code
            and (t01.valdtn_type_code >= 30 and t01.valdtn_type_code <= 57)
            and t01.efex_mkt_id = par_market
            and t01.efex_bus_id in (-1,par_bus_unit)
          order by t01.valdtn_type_code asc,
                   t01.key_text asc,
                   t02.det_seqn;

      /*-*/
      /* Local arrays
      /*-*/
      type typ_email is table of csr_email%rowtype index by binary_integer;
      tbl_email typ_email;
      type typ_data is table of csr_data%rowtype index by binary_integer;
      tbl_data typ_data;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Retrieve the email address data
      /*-*/
      lics_logging.write_log('===> Retrieve the email address listing - '||par_text);
      tbl_email.delete;
      open csr_email;
      fetch csr_email bulk collect into tbl_email;
      close csr_email;

      /*-*/
      /* Retrieve the validation messages for snack
      /*-*/
      lics_logging.write_log('===> Retrieve the validation messages- '||par_text);
      tbl_data.delete;
      open csr_data;
      fetch csr_data bulk collect into tbl_data;
      close csr_data;

      /*-*/
      /* Email the validation messages for snack
      /*-*/
      if tbl_data.count = 0 then

         /*-*/
         /* No validation messages for snack
         /*-*/
         lics_logging.write_log('===> NO validation messages to send- '||par_text);

      else

         /*-*/
         /* Retrieve the email address data
         /*-*/
         lics_logging.write_log('===> Email the validation messages- '||par_text);
         for idx in 1..tbl_email.count loop

            /*-*/
            /* Create the new email and create the email text header part
            /*-*/
            lics_logging.write_log('======> Email - '||tbl_email(idx).email_address);
            lics_mailer.create_email('EFEX_' || ods_parameter.business_unit_code || '_' || ods_parameter.system_environment,
                                     tbl_email(idx).email_address,
                                     'Efex Validation - Invalid Items Found for '||par_text||' on MFANZ CDW',
                                     null,
                                     null);
            lics_mailer.create_part(null);
            lics_mailer.append_data('Efex Validation - Invalid Items Found for '||par_text||' on MFANZ CDW');
            lics_mailer.append_data(null);
            lics_mailer.append_data('The following spreadsheet(s) contain the validation messages...');
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);

            /*-*/
            /* Retrieve the validation messages
            /*-*/
            var_valdtn_type_code := -1;
            var_prt_count := 1;
            var_row_count := 0;
            for idy in 1..tbl_data.count loop

               /*-*/
               /* Validation type changed
               /*-*/
               if tbl_data(idy).valdtn_type_code != var_valdtn_type_code or var_row_count >= con_max_row then

                  /*-*/
                  /* Output the email file part trailer data when required
                  /*-*/
                  if var_valdtn_type_code != -1 then
                     lics_mailer.append_data('</table>');
                  end if;

                  /*-*/
                  /* Validation type changed
                  /*-*/
                  if tbl_data(idy).valdtn_type_code != var_valdtn_type_code then

                     /*-*/
                     /* Reset the part count
                     /*-*/
                     var_valdtn_type_code := tbl_data(idy).valdtn_type_code;
                     var_prt_count := 1;

                  /*-*/
                  /* Maximum row count reached
                  /*-*/
                  else

                     /*-*/
                     /* Increment the part count
                     /*-*/
                     var_prt_count := var_prt_count + 1;

                  end if;

                  /*-*/
                  /* Create the email file part and output the header data
                  /*-*/
                  if var_prt_count = 1 then
                     lics_mailer.create_part(tbl_data(idy).valdtn_type_desc||'.xls');
                  else
                     lics_mailer.create_part(tbl_data(idy).valdtn_type_desc||'_PART'||to_char(var_prt_count,'fm9999999990')||'.xls');
                  end if;
                  lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
                  lics_mailer.append_data('<tr><td align=left colspan=3 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">'||tbl_data(idy).valdtn_type_desc||'</td></tr>');
                  lics_mailer.append_data('<tr><td align=left colspan=3></td></tr>');
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Validation Key</td>');
                  lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Message Seq</td>');
                  lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Message Data</td>');
                  lics_mailer.append_data('</tr>');

                  /*-*/
                  /* Reset the email file row count
                  /*-*/
                  var_row_count := 1;

               end if;

               /*-*/
               /* Output the message data
               /*-*/
               lics_mailer.append_data('<tr>');
               lics_mailer.append_data('<td align=left>'||tbl_data(idy).valdtn_key||'</td>');
               lics_mailer.append_data('<td align=right>'||tbl_data(idy).valdtn_seq||'</td>');
               lics_mailer.append_data('<td align=left>'||tbl_data(idy).valdtn_reasn_dtl_msg||'</td>');
               lics_mailer.append_data('</tr>');

               /*-*/
               /* Increment the email file row count
               /*-*/
               var_row_count := var_row_count + 1;

            end loop;

            /*-*/
            /* Finalise the email
            /*-*/
            lics_mailer.append_data('</table>');
            lics_mailer.create_part(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data(null);
            lics_mailer.append_data('** Email End **');
            lics_mailer.finalise_email;

         end loop;

      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_emails;

   /*****************************************************/
   /* This procedure performs the clear reasons routine */
   /*****************************************************/
   procedure clear_reasons(par_market in number, par_rea_type in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Remove the reason details for the type and market
      /*-*/
      delete from efex_mesg_det
       where hdr_seqn in (select hdr_seqn
                            from efex_mesg_hdr
                           where valdtn_type_code = par_rea_type
                             and efex_mkt_id = par_market);
      /*-*/
      /* Remove the reason headers for the type and market
      /*-*/
      delete from efex_mesg_hdr
       where valdtn_type_code = par_rea_type
         and efex_mkt_id = par_market;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end clear_reasons;

   /**************************************************/
   /* This procedure performs the add reason routine */
   /**************************************************/
   procedure add_reason(par_rea_start in boolean,
                        par_rea_type in number,
                        par_rea_message in varchar2,
                        par_mkt_id in number,
                        par_bus_id in number,
                        par_rea_code1 in varchar2,
                        par_rea_code2 in varchar2,
                        par_rea_code3 in varchar2,
                        par_rea_code4 in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_key_text varchar2(256);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Start new reason when required
      /*-*/
      if par_rea_start = true then

         /*-*/
         /* Create the reason header
         /*-*/
         var_key_text := '[';
         if not(par_rea_code1 is null) then
            var_key_text := var_key_text||par_rea_code1;
         end if;
         if not(par_rea_code2 is null) then
            var_key_text := var_key_text||' : '||par_rea_code2;
         end if;
         if not(par_rea_code3 is null) then
            var_key_text := var_key_text||' : '||par_rea_code3;
         end if;
         if not(par_rea_code4 is null) then
            var_key_text := var_key_text||' : '||par_rea_code4;
         end if;
         if var_key_text = '[' then
            var_key_text := var_key_text||'*NONE';
         end if;
         var_key_text := var_key_text||']';
         select efex_mesg_sequence.nextval into pvar_hdr_seqn from dual;
         insert into efex_mesg_hdr
            (hdr_seqn,
             valdtn_type_code,
             efex_mkt_id,
             efex_bus_id,
             key_text)
            values(pvar_hdr_seqn,
                   par_rea_type,
                   par_mkt_id,
                   par_bus_id,
                   var_key_text);

         /*-*/
         /* Reset the detail sequence
         /*-*/
         pvar_det_seqn := 1;

      else

         /*-*/
         /* Increment the detail sequence
         /*-*/
         pvar_det_seqn := pvar_det_seqn + 1;

      end if;

      /*-*/
      /* Create the reason detail
      /*-*/
      insert into efex_mesg_det
         (hdr_seqn,
          det_seqn,
          msg_text)
         values(pvar_hdr_seqn,
                pvar_det_seqn,
                substr(par_rea_message,1,256));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end add_reason;

end ods_efex_validation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym ods_efex_validation for ods_app.ods_efex_validation;
grant execute on ods_efex_validation to public;