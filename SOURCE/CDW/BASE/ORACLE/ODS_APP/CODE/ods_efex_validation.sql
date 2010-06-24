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

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_market in number);

end ods_efex_validation;
/

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
   procedure validate_efex_sgmnt(par_market in number);
   procedure validate_efex_sales_terr(par_market in number);
   procedure validate_efex_matl_grp(par_market in number);
   procedure validate_efex_matl_subgrp(par_market in number);
   procedure validate_efex_matl_matl_subgrp(par_market in number);
   procedure validate_efex_cust(par_market in number, par_reset in boolean);
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
   procedure clear_reasons(par_market in number, par_rea_type in varchar2);
   procedure add_reason(par_rea_start in boolean,
                        par_rea_type in number,
                        par_rea_message in varchar2,
                        par_rea_severity in varchar2,
                        par_rea_code1 in varchar2,
                        par_rea_code2 in varchar2,
                        par_rea_code3 in varchar2,
                        par_rea_code4 in varchar2,
                        par_rea_code5 in varchar2,
                        par_rea_code6 in varchar2);

   /*-*/
   /* Private constants
   /*-*/
   pcon_com_count constant number := 500;

   /*-*/
   /* Private definitions
   /*-*/
   pvar_rea_code number;
   pvar_rea_seqn number;

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


--doesn't make sense - how can lupdt be greater than sysdate
--  UPDATE efex_matl_subgrp t1
--  SET status = 'X'
--  WHERE EXISTS (SELECT *
--                FROM efex_matl_grp t2
--                WHERE t1.matl_grp_id = t2.matl_grp_id
--                  AND t2.status = 'X'
--                  AND t2.matl_grp_lupdt    > trunc(sysdate))
--    AND status = 'A';


-- ???? surely this is done in EFEX - if not then it should be ????

--  UPDATE efex_matl_matl_subgrp t1
--  SET status = 'X',
--      efex_lupdt = trunc(sysdate)
-- WHERE exists (SELECT *
--                FROM efex_matl t2
--                WHERE t1.efex_matl_id = t2.efex_matl_id
--                AND t2.status = 'X'
--                AND t2.matl_lupdt >= TRUNC(SYSDATE))
--    AND status = 'A';


  -- efex_matl_grp extract has already change the efex_matl_subgrp.status to X when group.status changed to X
--  UPDATE efex_matl_matl_subgrp t1
--  SET status = 'X',
--      efex_lupdt = trunc(sysdate)
--  WHERE exists (SELECT *
--                FROM efex_matl_subgrp t2
--                WHERE t1.matl_subgrp_id = t2.matl_subgrp_id
--                AND t2.status = 'X'
--                AND t2.matl_subgrp_lupdt >= TRUNC(SYSDATE))
--    AND status = 'A';


--???????  surely done in efex ???????
 -- UPDATE efex_range_matl t1
 -- SET status = 'X'
 -- WHERE exists (SELECT *
 --               FROM efex_matl t2
 --               WHERE t1.efex_matl_id = t2.efex_matl_id
 --               AND t2.status = 'X'
 --               AND TRUNC(t2.matl_lupdt) = TRUNC(SYSDATE));


--- how to do this
---
--  CURSOR csr_removed_distbn IS  -- Distribution removed from efex but exists in Venus.
--     SELECT
--       t1.customer_id   efex_cust_id,
--       t1.item_id       efex_matl_id,
--       t1.out_of_stock_flg,
--       t1.out_of_date_flg,
--       t1.sell_price,
--       t1.in_store_date,
--       t1.modified_date efex_lupdt,
--       t1.status
--     FROM
--       venus_distribution@ap0085p.world t1
--     WHERE
--       EXISTS (SELECT * FROM efex_distbn t2 WHERE t1.customer_id = t2.efex_cust_id AND t1.item_id = t2.efex_matl_id)
--       AND (t1.facing_qty = 0 AND t1.display_qty = 0 AND t1.inventory_qty = 0 AND t1.required_flg = 'N') -- become dummy distribution
--       AND (t1.modified_date > i_last_process_time AND t1.modified_date <= i_cur_time);
--  rv_removed_distbn csr_removed_distbn%ROWTYPE;


 -- FOR rv_removed_distbn IN csr_removed_distbn LOOP
 --     UPDATE efex_distbn
 --     SET
 --       display_qty = 0,
 --       facing_qty = 0,
 --       inv_qty = 0,
 --       rqd_flg = 'N',
 --       efex_lupdt = rv_removed_distbn.efex_lupdt,
 --       out_of_stock_flg = rv_removed_distbn.out_of_stock_flg,
 --       out_of_date_flg = rv_removed_distbn.out_of_date_flg,
 --       sell_price = rv_removed_distbn.sell_price,
 --       in_store_date = rv_removed_distbn.in_store_date,
 --       status = rv_removed_distbn.status
 --     WHERE
 --       efex_cust_id = rv_removed_distbn.efex_cust_id
 --       AND efex_matl_id = rv_removed_distbn.efex_matl_id;
--
 --     v_removed_count := v_removed_count + SQL%ROWCOUNT;
 -- END LOOP;



            validate_efex_sgmnt(var_market);
            validate_efex_sales_terr(var_market);
            validate_efex_matl_grp(var_market);
            validate_efex_matl_subgrp(var_market);
            validate_efex_matl_matl_subgrp(var_market);
            validate_efex_cust(var_market, false);
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

   /*************************************************************/
   /* This procedure performs the validate Efex segment routine */
   /*************************************************************/
   procedure validate_efex_sgmnt(par_market in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the business unit
         /*-*/
         if rcd_list.chk_bus_unit_id is null then
            lics_logging.write_log('efex_sgmnt: '||rcd_list.sgmnt_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sgmnt,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the segment
         /*-*/
         if rcd_list.chk_sgmnt_id is null then
            lics_logging.write_log('efex_sales_terr: '||rcd_list.sales_terr_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sales_terr,
                       'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_sales_terr: '||rcd_list.sales_terr_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sales_terr,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_sales_terr: '||rcd_list.sales_terr_id||': Invalid or non-existant Sales Territory User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_sales_terr,
                       'Invalid or non-existant Sales Territory User Id - ' || rcd_list.sales_terr_user_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the segment
            /*-*/
            if rcd_list.chk_sgmnt_id is null then
               lics_logging.write_log('efex_matl_grp: '||rcd_list.matl_grp_id||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_grp,
                          'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_bus_unit_id is null then
               lics_logging.write_log('efex_matl_grp: '||rcd_list.matl_grp_id||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_grp,
                          'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.matl_grp_id,
                          null,
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
         update efex_matl_grp
            set valdtn_status = var_valdtn_status
          where matl_grp_id = rcd_list.matl_grp_id;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the material group
            /*-*/
            if rcd_list.chk_matl_grp_id is null then
               lics_logging.write_log('efex_matl_subgrp: '||rcd_list.matl_subgrp_id||': Invalid or non-existant Material Group Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_subgrp,
                          'Invalid or non-existant Material Group Id - ' || rcd_list.matl_grp_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.matl_subgrp_id,
                          null,
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
         update efex_matl_subgrp
            set valdtn_status = var_valdtn_status
          where matl_subgrp_id = rcd_list.matl_subgrp_id;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
                nvl((select count(*) from efex_matl_matl_subgrp where efex_matl_id = t01.efex_matl_id and sgmnt_id = t01.sgmnt_id and matl_subgrp_id != t01.matl_subgrp_id and status = 'A' and valdtn_status = ods_constants.valdtn_valid),0) as chk_count
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the material
            /*-*/
            if rcd_list.chk_efex_matl_id is null then
               lics_logging.write_log('efex_matl_matl_subgrp matl/subgrp/sgmnt: '||rcd_list.efex_matl_id||'/'||rcd_list.matl_subgrp_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant EFEX Material Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_m_subgrp,
                          'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant EFEX Material Id - ' || rcd_list.efex_matl_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_matl_subgrp_id is null then
               lics_logging.write_log('efex_matl_matl_subgrp matl/subgrp/sgmnt: '||rcd_list.efex_matl_id||'/'||rcd_list.matl_subgrp_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant Material Sub Group Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_m_subgrp,
                          'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Material Sub Group Id - ' || rcd_list.matl_subgrp_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_matl_grp_id is null then
               lics_logging.write_log('efex_matl_matl_subgrp matl/subgrp/sgmnt: '||rcd_list.efex_matl_id||'/'||rcd_list.matl_subgrp_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant Material Group Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_m_subgrp,
                          'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Material Group Id - ' || rcd_list.matl_grp_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_sgmnt_id is null then
               lics_logging.write_log('efex_matl_matl_subgrp matl/subgrp/sgmnt: '||rcd_list.efex_matl_id||'/'||rcd_list.matl_subgrp_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_m_subgrp,
                          'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_bus_unit_id is null then
               lics_logging.write_log('efex_matl_matl_subgrp matl/subgrp/sgmnt: '||rcd_list.efex_matl_id||'/'||rcd_list.matl_subgrp_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_m_subgrp,
                          'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_count != 0 then
               lics_logging.write_log('efex_matl_matl_subgrp matl/subgrp/sgmnt: '||rcd_list.efex_matl_id||'/'||rcd_list.matl_subgrp_id||'/'||rcd_list.sgmnt_id||': Invalid - matl assigned to more than one subgrp for same segment.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_matl_m_subgrp,
                          'KEY: [matl-subgrp-sgmnt] - Invalid - matl assign to more than one subgrp for same segment.',
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_matl_id,
                          rcd_list.matl_subgrp_id,
                          rcd_list.sgmnt_id,
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
         update efex_matl_matl_subgrp
            set valdtn_status = var_valdtn_status
          where efex_matl_id = rcd_list.efex_matl_id
            and matl_subgrp_id = rcd_list.matl_subgrp_id
            and sgmnt_id = rcd_list.sgmnt_id;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
   procedure validate_efex_cust(par_market in number, par_reset in boolean) is

      /*-*/
      /* Local variables
      /*-*/
      var_count number;
      var_open boolean;
      var_exit boolean;
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
                (select distbr_id from efex_affltn where distbr_id = t01.distbr_id and (valdtn_status = ods_constants.valdtn_valid or valdtn_status = ods_constants.valdtn_unchecked)) as chk_distbr_id
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
      /* Reset all existing invalid customer related transaction record to unchecked when required
      /*-*/
    --  if par_reset = true then
    --      -- Found any changes to customer, then reset all existing invalid customer related transaction record to unchecked.
    --      reset_cust_xactn_valdtn_status(i_log_level+1);
    --  end if;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* Retrieve unchecked data and validate
      /*-*/
      var_count := 0;
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the sales territory
            /*-*/
            if rcd_list.sales_terr_id is not null then
               if rcd_list.chk_sales_terr_id is null then
                  lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Invalid or non-existant Sales Territory Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                             ods_constants.valdtn_severity_critical,
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
            if rcd_list.range_id is not null then
               if rcd_list.chk_range_id is null then
                  lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Invalid or non-existant Range Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Invalid or non-existant Range Id - ' || rcd_list.range_id,
                             ods_constants.valdtn_severity_critical,
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
            if rcd_list.cust_type_id is not null then
               if rcd_list.chk_cust_type_id is null then
                  lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Invalid or non-existant Cust Type Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Invalid or non-existant Cust Type Id - ' || rcd_list.cust_type_id,
                             ods_constants.valdtn_severity_critical,
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
            if rcd_list.affltn_id is not null then
               if rcd_list.chk_affltn_id is null then
                  lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Invalid or non-existant Affiliation Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Invalid or non-existant Affiliation Id - ' || rcd_list.affltn_id,
                             ods_constants.valdtn_severity_critical,
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
            if rcd_list.cust_code is not null and rcd_list.outlet_flg = 'N' then
               if rcd_list.chk_cust_code is null then
                  lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Invalid or non-existant Customer Code.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Invalid or non-existant Customer Code - ' || rcd_list.cust_code,
                             ods_constants.valdtn_severity_critical,
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
            if rcd_list.outlet_flg = 'N' and rcd_list.distbr_flg = 'N' and rcd_list.cust_code is null then
               lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Customer must at least be an Outlet, Distributor or Direct customer (with customer_code).');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Customer can not be outlet_flg = N and distributor_flg = N and customer_code IS NULL',
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.outlet_flg = 'Y' and rcd_list.cust_code is null then
               lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Outlet customer should not have cust_code.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_cust,
                          'Outlet customer should not be a Direct customer as well (have customer_code provided)',
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.distbr_id is not null then
               if rcd_list.chk_distbr_id is null then
                  lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Invalid or non-existant Distributor Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust,
                             'Invalid or non-existant Distributor Id - ' || rcd_list.distbr_id,
                             ods_constants.valdtn_severity_critical,
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
            /* **note** Valid and Unchecked are tested as the Distributor may be assigned to itself in which case the validation status would be UNCHECKED.
            /*-*/
            if rcd_list.cust_visit_freq is not null then
               begin
                  var_work := to_number(rcd_list.cust_visit_freq);
                  if var_work < 0 then
                     lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Customer Visit Frequency must be a positive number.');
                     add_reason(var_first,
                                ods_constants.valdtn_type_efex_cust,
                                'Customer Visit Frequency must be a positive number.',
                                ods_constants.valdtn_severity_critical,
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
                     lics_logging.write_log('efex_cust: '||rcd_list.efex_cust_id||': Customer Visit Frequency is not a number.');
                     add_reason(var_first,
                                ods_constants.valdtn_type_efex_cust,
                                'Customer Visit Frequency is not a number.',
                                ods_constants.valdtn_severity_critical,
                                par_market,
                                nvl(rcd_list.bus_unit_id,-1),
                                rcd_list.efex_cust_id,
                                null,
                                null,
                                null);
                     var_first := false;
               end;
            end if;

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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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


-------------THIS IS BULLSHIT - route scheduler is validated mutiple times

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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            lics_logging.write_log('efex_route_sched business/user/sched date: '||rcd_list.bus_unit_id||'/'||rcd_list.user_id||'/'||rcd_list.route_sched_date||': Invalid or non-existant User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_route_sched,
                       'KEY: [user-sched_date] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       ods_constants.valdtn_severity_critical,
                       par_market,
                       nvl(rcd_list.bus_unit_id,-1),
                       rcd_list.user_id,
                       rcd_list.route_sched_date,
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

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the customer
            /*-*/
            if rcd_list.chk_efex_cust_id is null then
               lics_logging.write_log('efex_route_plan user/plan date/cust: '||rcd_list.user_id||'/'||rcd_list.route_plan_date||'/'||rcd_list.efex_cust_id||': Invalid or non-existant EFEX Customer Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_route_plan,
                          'KEY: [user-plan_date-cust] - Invalid or non-existant EFEX Customer Id - ' || rcd_list.efex_cust_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.user_id,
                          rcd_list.route_plan_date,
                          rcd_list.efex_cust_id,
                          null);
               var_first := false;
            end if;

            /*-*/
            /* Validate the user
            /*-*/
            if rcd_list.chk_user_id is null then
               lics_logging.write_log('efex_route_plan user/plan date/cust: '||rcd_list.user_id||'/'||rcd_list.route_plan_date||'/'||rcd_list.efex_cust_id||': Invalid or non-existant User Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_route_plan,
                          'KEY: [user-plan_date-cust] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.user_id,
                          rcd_list.route_plan_date,
                          rcd_list.efex_cust_id,
                          null);
               var_first := false;
            end if;

            /*-*/
            /* Validate the sales territory
            /*-*/
            if rcd_list.chk_sales_terr_id is null then
               lics_logging.write_log('efex_route_plan user/plan date/cust: '||rcd_list.user_id||'/'||rcd_list.route_plan_date||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Sales Territory Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_route_plan,
                          'KEY: [user-plan_date-cust] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.user_id,
                          rcd_list.route_plan_date,
                          rcd_list.efex_cust_id,
                          null);
               var_first := false;
            end if;

            /*-*/
            /* Validate the segment
            /*-*/
            if rcd_list.chk_sgmnt_id is null then
               lics_logging.write_log('efex_route_plan user/plan date/cust: '||rcd_list.user_id||'/'||rcd_list.route_plan_date||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_route_plan,
                          'KEY: [user-plan_date-cust] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.user_id,
                          rcd_list.route_plan_date,
                          rcd_list.efex_cust_id,
                          null);
               var_first := false;
            end if;

            /*-*/
            /* Validate the business unit
            /*-*/
            if rcd_list.chk_bus_unit_id is null then
               lics_logging.write_log('efex_route_plan user/plan date/cust: '||rcd_list.user_id||'/'||rcd_list.route_plan_date||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_route_plan,
                          'KEY: [user-plan_date-cust] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.user_id,
                          rcd_list.route_plan_date,
                          rcd_list.efex_cust_id,
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
         update efex_route_plan
            set valdtn_status = var_valdtn_status
          where user_id = rcd_list.user_id
            and route_plan_date = rcd_list.route_plan_date
            and efex_cust_id = rcd_list.efex_cust_id;

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the customer
            /*-*/
            if rcd_list.chk_efex_cust_id is null then
               lics_logging.write_log('efex_call cust/call date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant EFEX Customer Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_call,
                          'KEY: [cust-call_date-user] - Invalid or non-existant EFEX Customer Id - ' || rcd_list.efex_cust_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_user_id is null then
               lics_logging.write_log('efex_call cust/call date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant User Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_call,
                          'KEY: [cust-call_date-user] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_sales_terr_id is null then
               lics_logging.write_log('efex_call cust/call date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant Sales Territory Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_call,
                          'KEY: [cust-call_date-user] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_sgmnt_id is null then
               lics_logging.write_log('efex_call cust/call date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_call,
                          'KEY: [cust-call_date-user] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_bus_unit_id is null then
               lics_logging.write_log('efex_call cust/call date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_call,
                          'KEY: [cust-call_date-user] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          to_char(rcd_list.call_date,'dd-mon-yyyy hh24:mi:ss'),
                          rcd_list.user_id,
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
         update efex_call
            set valdtn_status = var_valdtn_status
          where efex_cust_id = rcd_list.efex_cust_id
            and call_date = rcd_list.call_date
            and user_id = rcd_list.user_id;

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the customer
            /*-*/
            if rcd_list.chk_efex_cust_id is null then
               lics_logging.write_log('efex_timesheet_call cust/timesheet_date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant EFEX Customer Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_tmesht_call,
                          'KEY: [cust-timesheet_date-user] - Invalid or non-existant EFEX Customer Id - ' || rcd_list.efex_cust_id,
                          ods_constants.valdtn_severity_critical,
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
               lics_logging.write_log('efex_timesheet_call cust/timesheet_date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant User Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_tmesht_call,
                          'KEY: [cust-timesheet_date-user] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                          ods_constants.valdtn_severity_critical,
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
               lics_logging.write_log('efex_timesheet_call cust/timesheet_date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant Sales Territory Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_tmesht_call,
                          'KEY: [cust-timesheet_date-user] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                          ods_constants.valdtn_severity_critical,
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
               lics_logging.write_log('efex_timesheet_call cust/timesheet_date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_tmesht_call,
                          'KEY: [cust-timesheet_date-user] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
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
               lics_logging.write_log('efex_timesheet_call cust/timesheet_date/user: '||rcd_list.efex_cust_id||'/'||to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss')||'/'||rcd_list.user_id||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_tmesht_call,
                          'KEY: [cust-timesheet_date-user] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.efex_cust_id,
                          to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
                          rcd_list.user_id,
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
         update efex_timesheet_call
            set valdtn_status = var_valdtn_status
          where efex_cust_id = rcd_list.efex_cust_id
            and timesheet_date = rcd_list.timesheet_date
            and user_id = rcd_list.user_id;

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the user
            /*-*/
            if rcd_list.chk_user_id is null then
               lics_logging.write_log('efex_timesheet_day user/timesheet_date: '||rcd_list.user_id||'/'||to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss')||': Invalid or non-existant User Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_tmesht_day,
                          'KEY: [user-timesheet_date] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.user_id,
                          to_char(rcd_list.timesheet_date,'dd-mon-yyyy hh24:mi:ss'),
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
         update efex_timesheet_day
            set valdtn_status = var_valdtn_status
          where user_id = rcd_list.user_id
            and timesheet_date = rcd_list.timesheet_date;

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the segment
            /*-*/
            if rcd_list.chk_sgmnt_id is null then
               lics_logging.write_log('efex_assmnt_questn: '||rcd_list.assmnt_id||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_questn,
                          'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
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
               lics_logging.write_log('efex_assmnt_questn: '||rcd_list.assmnt_id||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_questn,
                          'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.assmnt_id,
                          null,
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
         update efex_assmnt_questn
            set valdtn_status = var_valdtn_status
          where assmnt_id = rcd_list.assmnt_id;

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the assessment
            /*-*/
            if rcd_list.chk_assmnt_id is null then
               lics_logging.write_log('efex_assmnt_assgnmnt assmnt/cust: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Assessment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_assgn,
                          'KEY: [assmnt-cust] - Invalid or non-existant Assessment Id - ' || rcd_list.assmnt_id,
                          ods_constants.valdtn_severity_critical,
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
               lics_logging.write_log('efex_assmnt_assgnmnt assmnt/cust: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Efex Customer Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_assgn,
                          'KEY: [assmnt-cust] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                          ods_constants.valdtn_severity_critical,
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
                  lics_logging.write_log('efex_assmnt_assgnmnt assmnt/cust: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Sales Territory Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_ass_assgn,
                             'KEY: [assmnt-cust] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                             ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_sgmnt_id is null then
               lics_logging.write_log('efex_assmnt_assgnmnt assmnt/cust: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_assgn,
                          'KEY: [assmnt-cust] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_bus_unit_id is null then
               lics_logging.write_log('efex_assmnt_assgnmnt assmnt/cust: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_ass_assgn,
                          'KEY: [assmnt-cust] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.cust_type_id is not null then
               if rcd_list.chk_cust_type_id is null then
                  lics_logging.write_log('efex_assmnt_assgnmnt assmnt/cust: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Customer Type Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_ass_assgn,
                             'KEY: [assmnt-cust] - Invalid or non-existant Customer Type Id - ' || rcd_list.cust_type_id,
                             ods_constants.valdtn_severity_critical,
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
            if rcd_list.affltn_id is not null then
               if rcd_list.chk_affltn_id is null then
                  lics_logging.write_log('efex_assmnt_assgnmnt assmnt/cust: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Affiliation Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_ass_assgn,
                             'KEY: [assmnt-cust] - Invalid or non-existant Affiliation Id - ' || rcd_list.affltn_id,
                             ods_constants.valdtn_severity_critical,
                             par_market,
                             nvl(rcd_list.bus_unit_id,-1),
                             rcd_list.assmnt_id,
                             rcd_list.efex_cust_id,
                             null,
                             null);
                  var_first := false;
               end if;
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Only validate active data
         /*-*/
         if rcd_list.status = 'A' then

            /*-*/
            /* Validate the assessment
            /*-*/
            if rcd_list.chk_assmnt_id is null then
               lics_logging.write_log('efex_assmnt assmnt/cust/resp_date: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||'/'||to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss')||': Invalid or non-existant Assessment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_assmnt,
                          'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Assessment Id - ' || rcd_list.assmnt_id,
                          ods_constants.valdtn_severity_critical,
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
               lics_logging.write_log('efex_assmnt assmnt/cust/resp_date: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||'/'||to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss')||': Invalid or non-existant Efex Customer Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_assmnt,
                          'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.sales_terr_id is not null then
               if rcd_list.chk_sales_terr_id is null then
                  lics_logging.write_log('efex_assmnt assmnt/cust/resp_date: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||'/'||to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss')||': Invalid or non-existant Sales Territory Id.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_assmnt,
                             'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                             ods_constants.valdtn_severity_critical,
                             par_market,
                             nvl(rcd_list.bus_unit_id,-1),
                             rcd_list.assmnt_id,
                             rcd_list.efex_cust_id,
                             to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
                             null);
                  var_first := false;
               end if;
            end if;

            /*-*/
            /* Validate the segment
            /*-*/
            if rcd_list.chk_sgmnt_id is null then
               lics_logging.write_log('efex_assmnt assmnt/cust/resp_date: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||'/'||to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss')||': Invalid or non-existant Segment Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_assmnt,
                          'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_bus_unit_id is null then
               lics_logging.write_log('efex_assmnt assmnt/cust/resp_date: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||'/'||to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss')||': Invalid or non-existant Business Unit Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_assmnt,
                          'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                          ods_constants.valdtn_severity_critical,
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
            if rcd_list.chk_user_id is null then
               lics_logging.write_log('efex_assmnt assmnt/cust/resp_date: '||rcd_list.assmnt_id||'/'||rcd_list.efex_cust_id||'/'||to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss')||': Invalid or non-existant User Id.');
               add_reason(var_first,
                          ods_constants.valdtn_type_efex_assmnt,
                          'KEY: [assmnt-cust-resp_date] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                          ods_constants.valdtn_severity_critical,
                          par_market,
                          nvl(rcd_list.bus_unit_id,-1),
                          rcd_list.assmnt_id,
                          rcd_list.efex_cust_id,
                          to_char(rcd_list.resp_date,'dd-mon-yyyy hh24:mi:ss'),
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
         update efex_assmnt
            set valdtn_status = var_valdtn_status
          where assmnt_id = rcd_list.assmnt_id
            and efex_cust_id = rcd_list.efex_cust_id
            and resp_date = rcd_list.resp_date;

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the range
         /*-*/
         if rcd_list.chk_range_id is null then
            lics_logging.write_log('efex_range_matl range/matl: '||rcd_list.range_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Range Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_range_matl,
                       'KEY: [range-matl] - Invalid or non-existant Range Id - ' || rcd_list.range_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_range_matl range/matl: '||rcd_list.range_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Efex Material Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_range_matl,
                       'KEY: [range-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_range_matl range/matl: '||rcd_list.range_id||'/'||rcd_list.efex_matl_id||': Required flag can not be null.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_range_matl,
                       'KEY: [range-matl] - Required flag has not been provided.',
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_cust_id is null then
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Efex Customer Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Sales Territory Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Range Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Range Id - ' || rcd_list.range_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Efex Material Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn cust/matl: '||rcd_list.efex_cust_id||'/'||rcd_list.efex_matl_id||': No subgroup found in efex_distbn.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn,
                       'KEY: [cust-matl] - No subgroup found in efex_distbn',
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            lics_logging.write_log('efex_distbn_tot cust/matl-group: '||rcd_list.efex_cust_id||'/'||rcd_list.matl_grp_id||': Invalid or non-existant Efex Customer Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn_tot cust/matl-group: '||rcd_list.efex_cust_id||'/'||rcd_list.matl_grp_id||': Invalid or non-existant Material Group Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.matl_grp_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn_tot cust/matl-group: '||rcd_list.efex_cust_id||'/'||rcd_list.matl_grp_id||': Invalid or non-existant Sales Territory Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn_tot cust/matl-group: '||rcd_list.efex_cust_id||'/'||rcd_list.matl_grp_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn_tot cust/matl-group: '||rcd_list.efex_cust_id||'/'||rcd_list.matl_grp_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_distbn_tot cust/matl-group: '||rcd_list.efex_cust_id||'/'||rcd_list.matl_grp_id||': Invalid or non-existant User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_distbn_tot,
                       'KEY: [cust-matl] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            lics_logging.write_log('efex_order order: '||rcd_list.efex_order_id||': Invalid or non-existant Efex Customer Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_order order: '||rcd_list.efex_order_id||': Invalid or non-existant User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant User Id - ' || rcd_list.user_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_order order: '||rcd_list.efex_order_id||': Invalid or non-existant Sales Territory Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_order order: '||rcd_list.efex_order_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_order order: '||rcd_list.efex_order_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order,
                       'Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the order
         /*-*/
         if rcd_list.status = 'A' and rcd_list.chk_efex_order_id is null then
            lics_logging.write_log('efex_order_matl order/matl: '||rcd_list.efex_order_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Efex Order Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order_matl,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Order Id - ' || rcd_list.efex_order_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_order_matl order/matl: '||rcd_list.efex_order_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Efex Material Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order_matl,
                       'KEY: [cust-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_order_matl order/matl: '||rcd_list.efex_order_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Material Distributor Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_order_matl,
                       'KEY: [cust-matl] - Invalid or non-existant Material Distributor Id - ' || rcd_list.matl_distbr_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            lics_logging.write_log('efex_pmt pmt/cust: '||rcd_list.pmt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Efex Customer Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_pmt pmt/cust: '||rcd_list.pmt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_pmt pmt/cust: '||rcd_list.pmt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Sales Territory Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_pmt pmt/cust: '||rcd_list.pmt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_pmt pmt/cust: '||rcd_list.pmt_id||'/'||rcd_list.efex_cust_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt,
                       'KEY: [pmt-cust] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the payment
         /*-*/
         if rcd_list.chk_pmt_id is null then
            lics_logging.write_log('efex_pmt_deal pmt/seq_num: '||rcd_list.pmt_id||'/'||rcd_list.seq_num||': Invalid or non-existant Payment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_deal,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Payment Id - ' || rcd_list.pmt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_pmt_deal pmt/seq_num: '||rcd_list.pmt_id||'/'||rcd_list.seq_num||': Invalid or non-existant Efex Order Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_deal,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Efex Order Id - ' || rcd_list.efex_order_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the payment
         /*-*/
         if rcd_list.chk_pmt_id is null then
            lics_logging.write_log('efex_pmt_rtn pmt/seq_num: '||rcd_list.pmt_id||'/'||rcd_list.seq_num||': Invalid or non-existant Payment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_rtn,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Payment Id - ' || rcd_list.pmt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_pmt_rtn pmt/seq_num: '||rcd_list.pmt_id||'/'||rcd_list.seq_num||': Invalid or non-existant Efex Material Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_pmt_rtn,
                       'KEY: [pmt-seq_num] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            lics_logging.write_log('efex_mrq mrq: '||rcd_list.mrq_id||': Invalid or non-existant User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_mrq mrq: '||rcd_list.mrq_id||': Invalid or non-existant Efex Customer Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_mrq mrq: '||rcd_list.mrq_id||': Invalid or non-existant Sales Territory Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_mrq mrq: '||rcd_list.mrq_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_mrq mrq: '||rcd_list.mrq_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_mrq mrq: '||rcd_list.mrq_id||': Completed Flg has not been provided.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq,
                       'KEY: [mrq] - ICompleted Flg has not been provided',
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the merchandising request
         /*-*/
         if not(rcd_list.mrq_id is null) and rcd_list.chk_mrq_id is null then
            lics_logging.write_log('efex_mrq_task mrq_task: '||rcd_list.mrq_task_id||': Invalid or non-existant MRQ Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq_task,
                       'KEY: [mrq_task] - Invalid or non-existant MRQ Id - ' || rcd_list.mrq_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the merchandising request task
         /*-*/
         if rcd_list.chk_mrq_task_id is null then
            lics_logging.write_log('efex_mrq_task_matl mrq_task/matl: '||rcd_list.mrq_task_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant MRQ Task Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq_task_matl,
                       'KEY: [mrq_task-matl] - Invalid or non-existant MRQ Task Id - ' || rcd_list.mrq_task_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_mrq_task_matl mrq_task/matl: '||rcd_list.mrq_task_id||'/'||rcd_list.efex_matl_id||': Invalid or non-existant Efex Material Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_mrq_task_matl,
                       'KEY: [mrq_task-matl] - Invalid or non-existant Efex Material Id - ' || rcd_list.efex_matl_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the sales territory
         /*-*/
         if rcd_list.chk_sales_terr_id is null then
            lics_logging.write_log('efex_target sales_terr/target/period: '||rcd_list.sales_terr_id||'/'||rcd_list.target_id||'/'||rcd_list.mars_period||': Invalid or non-existant Sales Territory Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_target,
                       'KEY: [sales_terr-target-mars_period] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_target sales_terr/target/period: '||rcd_list.sales_terr_id||'/'||rcd_list.target_id||'/'||rcd_list.mars_period||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_target,
                       'KEY: [sales_terr-target-mars_period] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the user
         /*-*/
         if rcd_list.chk_user_id is null then
            lics_logging.write_log('efex_user_sgmnt user/segment: '||rcd_list.user_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant User Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_user_sgmnt,
                       'KEY: [user-segment] - Invalid or non-existant User Id - ' || rcd_list.user_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_user_sgmnt user/segment: '||rcd_list.user_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_user_sgmnt,
                       'KEY: [user-segment] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_user_sgmnt user/segment: '||rcd_list.user_id||'/'||rcd_list.sgmnt_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_user_sgmnt,
                       'KEY: [user-segment] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      var_open boolean;
      var_exit boolean;
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
      var_open := true;
      var_exit := false;
      loop

         /*-*/
         /* Retrieve the next list item
         /*-*/
         loop
            if var_open = true then
               if csr_list%isopen then
                  close csr_list;
               end if;
               open csr_list;
               var_open := false;
            end if;
            begin
               fetch csr_list into rcd_list;
               if csr_list%notfound then
                  var_exit := true;
               end if;
            exception
               when snapshot_exception then
                  var_open := true;
            end;
            if var_open = false then
               exit;
            end if;
         end loop;
         if var_exit = true then
            exit;
         end if;

         /*-*/
         /* Reset validation data
         /*-*/
         var_count := var_count + 1;
         var_first := true;
         var_valdtn_status := ods_constants.valdtn_valid;

         /*-*/
         /* Validate the customer
         /*-*/
         if rcd_list.chk_efex_cust_id is null then
            lics_logging.write_log('efex_cust_note cust_note: '||rcd_list.cust_note_id||': Invalid or non-existant Efex Customer Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Efex Customer Id - ' || rcd_list.efex_cust_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_cust_note cust_note: '||rcd_list.cust_note_id||': Invalid or non-existant Sales Territory Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Sales Territory Id - ' || rcd_list.sales_terr_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_cust_note cust_note: '||rcd_list.cust_note_id||': Invalid or non-existant Segment Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Segment Id - ' || rcd_list.sgmnt_id,
                       ods_constants.valdtn_severity_critical,
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
            lics_logging.write_log('efex_cust_note cust_note: '||rcd_list.cust_note_id||': Invalid or non-existant Business Unit Id.');
            add_reason(var_first,
                       ods_constants.valdtn_type_efex_cust_note,
                       'KEY: [cust_note] - Invalid or non-existant Business Unit Id - ' || rcd_list.bus_unit_id,
                       ods_constants.valdtn_severity_critical,
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
               var_wrk_date := to_date(rcd_list.cust_note_created,'dd/mm/yyyy hh24:mi:ss');
            exception
               when others then

                  lics_logging.write_log('efex_cust_note cust_note: '||rcd_list.cust_note_id||': Invalid - cust_note_created is not a date.');
                  add_reason(var_first,
                             ods_constants.valdtn_type_efex_cust_note,
                             'KEY: [cust_note] - Invalid - cust_note_created must be in [DD/MM/YYYY HH24:MI:SS] Date Format - ' || rcd_list.cust_note_created,
                             ods_constants.valdtn_severity_critical,
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

         /*-*/
         /* Commit the database when required
         /*-*/
         if var_count >= pcon_com_count then
            var_count := 0;
            commit;
         end if;

      end loop;
      if csr_list%isopen then
         close csr_list;
      end if;

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
      delete from valdtn_reasn_dtl
       where valdtn_reasn_hdr_code in (select valdtn_reasn_hdr_code
                                         from valdtn_reasn_hdr
                                        where valdtn_type_code = par_rea_type
                                          and item_code_1 = par_market);
      /*-*/
      /* Remove the reason headers for the type and market
      /*-*/
      delete from valdtn_reasn_hdr
       where valdtn_type_code = par_rea_type
         and item_code_1 = par_market;

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
                        par_rea_severity in varchar2,
                        par_rea_code1 in varchar2,
                        par_rea_code2 in varchar2,
                        par_rea_code3 in varchar2,
                        par_rea_code4 in varchar2,
                        par_rea_code5 in varchar2,
                        par_rea_code6 in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      var_newid boolean;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_reason is
         select t01.valdtn_reasn_hdr_code
           from valdtn_reasn_hdr t01
          where valdtn_type_code = par_rea_type
            and item_code_1 = par_rea_code1
            and decode(item_code_2, par_rea_code2, 1, 0) = 1
            and decode(item_code_3, par_rea_code3, 1, 0) = 1
            and decode(item_code_4, par_rea_code4, 1, 0) = 1
            and decode(item_code_5, par_rea_code5, 1, 0) = 1
            and decode(item_code_6, par_rea_code6, 1, 0) = 1;

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
         insert into valdtn_reasn_hdr
            (valdtn_type_code,
             item_code_1,
             item_code_2,
             item_code_3,
             item_code_4,
             item_code_5,
             item_code_6)
            values (par_rea_type,
                    par_rea_code1,
                    par_rea_code2,
                    par_rea_code3,
                    par_rea_code4,
                    par_rea_code5,
                    par_rea_code6);

         /*-*/
         /* Retrieve the surrogate key
         /*-*/
         open csr_reason;
         fetch csr_reason into pvar_rea_code;
         if csr_reason%notfound then
            raise_application_error(-20000, 'Validation reason header not found');
         end if;
         close csr_reason;

         /*-*/
         /* Reset the detail sequence
         /*-*/
         pvar_rea_seqn := 1;

      else

         /*-*/
         /* Increment the detail sequence
         /*-*/
         pvar_rea_seqn := pvar_rea_seqn + 1;

      end if;

      /*-*/
      /* Create the reason detail
      /*-*/
      insert into valdtn_reasn_dtl
         (valdtn_reasn_hdr_code,
          valdtn_reasn_dtl_seq,
          valdtn_reasn_dtl_msg,
          valdtn_reasn_dtl_svrty)
         values(pvar_rea_code,
                pvar_rea_seqn,
                par_rea_message,
                par_rea_severity);

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
