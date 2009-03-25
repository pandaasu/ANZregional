CREATE OR REPLACE PACKAGE         ods_efex_validation as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : ODS
 Package : ods_efex_validation
 Owner   : ODS_APP
 Author  : ISI


 Description
 -----------
 Controls the validation of the ODS eFEX reference and transaction data validation from EFEX.


 NOTES
   1. This package is NOT intended to be run in parallel.
   2. Package will be executed from schedule at specific points in time (recommended is daily).
   3. Order of validation processing is important - reference data should preceed transactions.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/10   John Cho       Created package.
 2007/10   Kris Lee       Completed procedures.
 2009/03   Steve Gregan   Changed distribution validation tests to include status 'X'

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end ods_efex_validation; 
/


CREATE OR REPLACE PACKAGE BODY         ods_efex_validation AS

   -- PRIVATE EXCEPTIONS
   application_exception exception;
   snapshot_exception exception;
   resource_busy exception;
   pragma exception_init(application_exception, -20000);
   pragma exception_init(snapshot_exception, -1555);
   pragma exception_init(resource_busy, -54);

  -- CONSTANT DECLARATIONS
   c_commit_count         CONSTANT PLS_INTEGER := 100;

   c_cust_ref             CONSTANT VARCHAR2(40) := 'EFEX_CUST';
   c_matl_ref             CONSTANT VARCHAR2(40) := 'EFEX_MATL';
   c_matl_matl_subgrp_ref CONSTANT VARCHAR2(40) := 'EFEX_MATL_MATL_SUBGRP';
   c_matl_grp_ref         CONSTANT VARCHAR2(40) := 'EFEX_MATL_GRP';
   c_assmnt_questn_ref    CONSTANT VARCHAR2(40) := 'EFEX_ASSMNT_QUESTN';
   c_sgmnt_ref            CONSTANT VARCHAR2(40) := 'EFEX_SGMNT';
   c_bus_unit_ref         CONSTANT VARCHAR2(40) := 'EFEX_BUS_UNIT';
   c_sales_terr_ref       CONSTANT VARCHAR2(40) := 'EFEX_SALES_TERR';
   c_range_ref            CONSTANT VARCHAR2(40) := 'EFEX_RANGE';
   c_cust_type_ref        CONSTANT VARCHAR2(40) := 'EFEX_CUST_CHNL';
   c_affltn_ref           CONSTANT VARCHAR2(40) := 'EFEX_AFFLTN';
   c_user_ref             CONSTANT VARCHAR2(40) := 'EFEX_USER';
   c_order_ref            CONSTANT VARCHAR2(40) := 'EFEX_ORDER';
   c_cust_dim_ref         CONSTANT VARCHAR2(40) := 'CUST_DIM';
   c_matl_subgrp_ref      CONSTANT VARCHAR2(40) := 'EFEX_MATL_SUBGRP';
   c_mrq_task_ref         CONSTANT VARCHAR2(40) := 'EFEX_MRQ_TASK';
   c_bulk                 CONSTANT VARCHAR2(40) := 'BULK';

  -- PRIVATE DECLARATIONS
  PROCEDURE write_log(
    i_data_type    IN ods.log.data_type%TYPE,
    i_sort_field   IN ods.log.sort_field%TYPE,
    i_log_level    IN ods.log.log_level%TYPE,
    i_log_text     IN ods.log.log_text%TYPE);

  FUNCTION format_cust_code (
    i_cust_code    IN VARCHAR2) RETURN varchar2;

/******************************************************************/
/* EFEX to ODS validation procedures                              */
/******************************************************************/
  PROCEDURE check_efex_sgmnt(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_sgmnt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_sgmnt_id            IN efex_sgmnt.sgmnt_id%TYPE);

  PROCEDURE check_efex_sales_terr(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_sales_terr(
    i_log_level           IN ods.log.log_level%TYPE,
    i_sales_terr_id        IN efex_sales_terr.sales_terr_id%TYPE);

  PROCEDURE check_efex_cust(
    i_log_level          IN ods.log.log_level%TYPE,
    i_reset_transaction  IN BOOLEAN DEFAULT TRUE);

  PROCEDURE validate_efex_cust(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_cust.efex_cust_id%TYPE);

  PROCEDURE check_cust_distributors(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE check_efex_matl_grp(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_matl_grp(
    i_log_level           IN ods.log.log_level%TYPE,
    i_matl_grp_id         IN efex_matl_grp.matl_grp_id%TYPE);

  PROCEDURE check_efex_matl_subgrp(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_matl_subgrp(
    i_log_level           IN ods.log.log_level%TYPE,
    i_matl_subgrp_id      IN efex_matl_subgrp.matl_subgrp_id%TYPE);

  PROCEDURE check_efex_matl_matl_subgrp(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_matl_matl_subgrp(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_matl_id        IN efex_matl_matl_subgrp.efex_matl_id%TYPE,
    i_matl_subgrp_id      IN efex_matl_matl_subgrp.matl_subgrp_id%TYPE,
    i_sgmnt_id            IN efex_matl_matl_subgrp.sgmnt_id%TYPE);

  PROCEDURE check_efex_route_sched(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_route_sched(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_route_sched.user_id%TYPE,
    i_route_sched_date    IN efex_route_sched.route_sched_date%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE);

  PROCEDURE check_efex_route_plan(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_route_plan(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_route_plan.user_id%TYPE,
    i_route_plan_date     IN efex_route_plan.route_plan_date%TYPE,
    i_efex_cust_id        IN efex_route_plan.efex_cust_id%TYPE);

  PROCEDURE check_efex_call(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_call(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_call.efex_cust_id%TYPE,
    i_call_date           IN efex_call.call_date%TYPE,
    i_user_id             IN efex_call.user_id%TYPE);

  PROCEDURE check_efex_timesheet_call(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_timesheet_call(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_timesheet_call.efex_cust_id%TYPE,
    i_timesheet_date      IN efex_timesheet_call.timesheet_date%TYPE,
    i_user_id             IN efex_timesheet_call.user_id%TYPE);

  PROCEDURE check_efex_timesheet_day(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_timesheet_day(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_timesheet_day.user_id%TYPE,
    i_timesheet_date      IN efex_timesheet_day.timesheet_date%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE);

  PROCEDURE check_efex_assmnt(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_assmnt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_assmnt_id           IN efex_assmnt.assmnt_id%TYPE,
    i_efex_cust_id        IN efex_assmnt.efex_cust_id%TYPE,
    i_resp_date           IN efex_assmnt.resp_date%TYPE);

  PROCEDURE check_efex_assmnt_questn(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_assmnt_questn(
    i_log_level           IN ods.log.log_level%TYPE,
    i_assmnt_id           IN efex_assmnt_questn.assmnt_id%TYPE);

  PROCEDURE check_efex_assmnt_assgnmnt(
    i_log_level IN ods.log.log_level%TYPE);

   PROCEDURE validate_efex_assmnt_assgnmnt(
    i_assmnt_id           IN efex_assmnt_assgnmnt.assmnt_id%TYPE,
    i_efex_cust_id        IN efex_assmnt_assgnmnt.efex_cust_id%TYPE,
    i_log_level           IN ods.log.log_level%TYPE);
/**********************************************************
  PROCEDURE check_efex_range(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_range(
    i_log_level           IN ods.log.log_level%TYPE,
    i_range_id            IN efex_range.range_id%TYPE
   );
***********************************************************/
  PROCEDURE check_efex_range_matl(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_range_matl(
    i_log_level           IN ods.log.log_level%TYPE,
    i_range_id            IN efex_range_matl.range_id%TYPE,
    i_efex_matl_id        IN efex_range_matl.efex_matl_id%TYPE);

  PROCEDURE check_efex_distbn(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_distbn(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_distbn.efex_cust_id%TYPE,
    i_efex_matl_id        IN efex_distbn.efex_matl_id%TYPE);

  PROCEDURE check_efex_distbn_tot(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_distbn_tot(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_distbn_tot.efex_cust_id%TYPE,
    i_matl_grp_id         IN efex_distbn_tot.matl_grp_id%TYPE);

  PROCEDURE check_efex_order(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_order(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_order_id       IN efex_order.efex_order_id%TYPE);

  PROCEDURE check_efex_order_matl(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_order_matl(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_order_id       IN efex_order_matl.efex_order_id%TYPE,
    i_efex_matl_id       IN efex_order_matl.efex_matl_id%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE);

  PROCEDURE check_efex_pmt(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_pmt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_pmt_id              IN efex_pmt.pmt_id%TYPE,
    i_efex_cust_id        IN efex_pmt.efex_cust_id%TYPE);

  PROCEDURE check_efex_pmt_deal(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_pmt_deal(
    i_log_level           IN ods.log.log_level%TYPE,
    i_pmt_id              IN efex_pmt_deal.pmt_id%TYPE,
    i_seq_num             IN efex_pmt_deal.seq_num%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE);

  PROCEDURE check_efex_pmt_rtn(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_pmt_rtn(
    i_log_level           IN ods.log.log_level%TYPE,
    i_pmt_id              IN efex_pmt_rtn.pmt_id%TYPE,
    i_seq_num             IN efex_pmt_rtn.seq_num%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE);

  PROCEDURE check_efex_mrq(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_mrq(
    i_log_level           IN ods.log.log_level%TYPE,
    i_mrq_id              IN efex_mrq.mrq_id%TYPE);

  PROCEDURE check_efex_mrq_task(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_mrq_task(
    i_log_level           IN ods.log.log_level%TYPE,
    i_mrq_task_id         IN efex_mrq_task.mrq_task_id%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE);

  PROCEDURE check_efex_mrq_task_matl(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_mrq_task_matl(
    i_log_level           IN ods.log.log_level%TYPE,
    i_mrq_task_id         IN efex_mrq_task_matl.mrq_task_id%TYPE,
    i_efex_matl_id        IN efex_mrq_task_matl.efex_matl_id%TYPE);

  PROCEDURE check_efex_target(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_target(
    i_log_level           IN ods.log.log_level%TYPE,
    i_sales_terr_id       IN efex_target.sales_terr_id%TYPE,
    i_target_id           IN efex_target.target_id%TYPE,
    i_mars_period         IN efex_target.mars_period%TYPE);

  PROCEDURE reset_new_cust_valdtn_status(
    i_log_level IN ods.log.log_level%TYPE);

   PROCEDURE reset_cust_xactn_valdtn_status(
    i_log_level IN ods.log.log_level%TYPE);

   PROCEDURE reset_matl_xactn_valdtn_status(
    i_log_level IN ods.log.log_level%TYPE);

   PROCEDURE check_efex_user_sgmnt(
    i_log_level IN ods.log.log_level%TYPE);

   PROCEDURE validate_efex_user_sgmnt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_user_sgmnt.user_id%TYPE,
    i_sgmnt_id            IN efex_user_sgmnt.sgmnt_id%TYPE
   );

   PROCEDURE check_efex_cust_note(
    i_log_level IN ods.log.log_level%TYPE);

   PROCEDURE validate_efex_cust_note(
    i_log_level           IN ods.log.log_level%TYPE,
    i_cust_note_id        IN efex_cust_note.cust_note_id%TYPE
   );

  /* ******************************************************
   *  The below validation procedures handle bulk records
   *    check and log the invalid reference data id rather
   *    than log for each invalid record of the source table
   *    to improve the validation performance
   * ******************************************************/
  PROCEDURE clear_validation_reason (
    i_valdtn_type_code valdtn_reasn_hdr.valdtn_type_code%TYPE,
    i_log_level        ods.log.log_level%TYPE DEFAULT 0);

  PROCEDURE validate_efex_route_plan_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_distbn_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_range_matl_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_ass_assgn_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_order_matl_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_call_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_assmnt_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_distbn_tot_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_m_m_subgrp_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_task_matl_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_order_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_cust_note_bulk(
    i_log_level IN ods.log.log_level%TYPE);

  PROCEDURE validate_efex_cust_bulk(
    i_log_level IN ods.log.log_level%TYPE);

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
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;

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
      var_log_search := 'ODS_EFEX_VALIDATION';
      var_loc_string := 'ODS_EFEX_VALIDATION';
      var_email := lics_setting_configuration.retrieve_setting('ODS_EFEX_VALIDATION', 'EMAIL_GROUP');
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - ODS_EFEX_VALIDATION');
      lics_logging.write_log('Alerts/Failures sent to ' || nvl(var_email,'n/a'));

      /*-*/
      /* Request the lock on the ODS EFEX Validation
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the Validation procedures
         /*-*/
          begin
               check_efex_sgmnt(0);
               check_efex_sales_terr(0);
               check_efex_matl_grp(0);
               check_efex_matl_subgrp(0);
               check_efex_matl_matl_subgrp(0);
               check_efex_cust(0);   
               check_efex_route_sched(0);

               --check_efex_route_plan(0);  
               validate_efex_route_plan_bulk(0);

               --check_efex_call(0);
               validate_efex_call_bulk(0);

               check_efex_timesheet_call(0);
               check_efex_timesheet_day(0);
               check_efex_assmnt_questn(0);

               --check_efex_assmnt_assgnmnt(0);
               validate_efex_ass_assgn_bulk(0);

               --check_efex_assmnt(0);
               validate_efex_assmnt_bulk(0);

               check_efex_range_matl(0);
               --validate_efex_range_matl_bulk(0);

               --check_efex_distbn(0);
               validate_efex_distbn_bulk(0);

               --check_efex_distbn_tot(0);
               validate_efex_distbn_tot_bulk(0);

               check_efex_order(0);
               --validate_efex_order_bulk(0);

               --check_efex_order_matl(0);
               validate_efex_order_matl_bulk(0);

               check_efex_pmt(0);
               check_efex_pmt_deal(0);
               check_efex_pmt_rtn(0);
               check_efex_mrq(0);
               check_efex_mrq_task(0);

               check_efex_mrq_task_matl(0);
               --validate_efex_task_matl_bulk(0);

               check_efex_target(0);
               check_efex_user_sgmnt(0);

               check_efex_cust_note(0);
               --validate_efex_cust_note_bulk(0);

               -- NOT set invalid customer to excluded any more even they don't have transaction
               -- reset_new_cust_valdtn_status(0);

          exception
               when others then
                  var_errors := true;
          end;

         /*-*/
         /* Release the lock on the ODS EFEX Validation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - ODS_EFEX_VALIDATION');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/

      if var_errors = true then
        lics_locking.release(var_loc_string);
        lics_notification.send_email(ods_parameter.business_unit_code,
                                      'VENUS',
                                      ods_parameter.system_environment,
                                      con_function,
                                      'ods_efex_validation',
                                      var_email,
                                      'One or more errors occurred during the ODS EFEX Validation execution - refer to web log - ' || lics_logging.callback_identifier);

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
         /* Release the lock on the ODS_EFEX_VALIDATION
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - VENUS - ods_efex_validation - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*************************************************/
   /* This procedure performs the write log routine */
   /*************************************************/
   procedure write_log(i_data_type  in ods.log.data_type%type,
                       i_sort_field in ods.log.sort_field%type,
                       i_log_level  in ods.log.log_level%type,
                       i_log_text   in ods.log.log_text%type) is

   begin

      lics_logging.write_log(i_log_text);

   exception
      when others then
        raise;
   end write_log;

   /**************************************************/
   /* Thie function performs format customer code    */
   /*************************************************/
   function format_cust_code (i_cust_code IN VARCHAR2
   ) return varchar2 is

  -- VARIABLE DECLARATIONS.
  v_cust_code  VARCHAR2(10);
  v_first_char VARCHAR2(1);

  BEGIN
   -- Trim the inputted Customer Code.
   v_cust_code := RTRIM(i_cust_code);

   IF v_cust_code IS NULL OR v_cust_code = '' THEN
     RETURN NULL;
   END IF;

   -- Check whether the first character is a number.  If so, then left pad with zero's to
   -- ten characters.  Otherwise right pad with spaces to ten characters. (SAP format)
   v_first_char := SUBSTR(v_cust_code,1,1);
   IF v_first_char >= '0' AND v_first_char <= '9' THEN
    v_cust_code := LPAD(v_cust_code,10,'0');
   ELSE
    v_cust_code := RPAD(v_cust_code,10,' ');
   END IF;

   RETURN v_cust_code;

   EXCEPTION
   WHEN OTHERS THEN
    raise_application_error
      (-20001, 'Error converting cust_code to GRD cust_code format - ' || SUBSTR(SQLERRM, 1, 512));
  END format_cust_code;

/************************************************************/
/* EFEX to ODS Validation Individual Execution              */
/************************************************************/

/********************************************************************************
    NAME:       check_efex_sgmnt
    PURPOSE:    This procdure reads through all efex segment records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_sgmnt(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_sgmnt IS
      SELECT
        sgmnt_id
      FROM
        efex_sgmnt
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;

    rv_efex_sgmnt csr_efex_sgmnt%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_sgmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_sgmnt: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_sgmnt;
    FETCH csr_efex_sgmnt INTO rv_efex_sgmnt;
    WHILE csr_efex_sgmnt%FOUND LOOP

      -- PROCESS DATA
      validate_efex_sgmnt(i_log_level + 2, rv_efex_sgmnt.sgmnt_id);

      FETCH csr_efex_sgmnt INTO rv_efex_sgmnt;
    END LOOP;
    CLOSE csr_efex_sgmnt;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_sgmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_sgmnt: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_sgmnt, 'n/a', 0, 'ods_efex_validation.check_efex_sgmnt: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_sgmnt;

  /*******************************************************************************
    NAME:       validate_efex_sgmnt
    PURPOSE:    This procedure validates a efex segment record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_sgmnt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_sgmnt_id            IN efex_sgmnt.sgmnt_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_sgmnt.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_sgmnt IS
      SELECT
        NVL(bus_unit_id, -1) AS bus_unit_id
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = i_sgmnt_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;

    rv_efex_sgmnt csr_efex_sgmnt%ROWTYPE;

  BEGIN

    OPEN csr_efex_sgmnt;
    FETCH csr_efex_sgmnt INTO rv_efex_sgmnt;
    IF csr_efex_sgmnt%FOUND THEN

      -- Clear the validation reason tables of this efex segment.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_sgmnt,
                                  rv_efex_sgmnt.bus_unit_id,
                                  i_sgmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

                                        
      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_sgmnt.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_sgmnt, 'n/a', i_log_level + 1,    'efex_sgmnt: ' ||
                                                                          i_sgmnt_id   || 
                                                                          ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_sgmnt,
                                  'Invalid or non-existant Business Unit Id - ' || rv_efex_sgmnt.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_sgmnt.bus_unit_id,
                                  i_sgmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      UPDATE
        efex_sgmnt
      SET
        valdtn_status = v_valdtn_status
      WHERE
        sgmnt_id = i_sgmnt_id;

    END IF;
    CLOSE csr_efex_sgmnt;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_sgmnt;

/********************************************************************************
    NAME:       check_efex_sales_terr
    PURPOSE:    This procedure reads through all efex sales territory records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_sales_terr(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_sales_terr IS
      SELECT
        sales_terr_id
      FROM
        efex_sales_terr
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;

    rv_efex_sales_terr csr_efex_sales_terr%ROWTYPE;

  BEGIN

    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_sales_terr, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_sales_terr: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_sales_terr;
    FETCH csr_efex_sales_terr INTO rv_efex_sales_terr;
    WHILE csr_efex_sales_terr%FOUND LOOP

      -- PROCESS DATA
      validate_efex_sales_terr(i_log_level + 2, rv_efex_sales_terr.sales_terr_id);

      FETCH csr_efex_sales_terr INTO rv_efex_sales_terr;
    END LOOP;
    CLOSE csr_efex_sales_terr;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_sales_terr, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_sales_terr: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_sales_terr, 'n/a', 0, 'ods_efex_validation.check_efex_sales_terr: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_sales_terr;

  /*******************************************************************************
    NAME:       validate_efex_sales_terr
    PURPOSE:    This procedure validates a efex sales territory record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_sales_terr(
    i_log_level           IN ods.log.log_level%TYPE,
    i_sales_terr_id       IN efex_sales_terr.sales_terr_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_sales_terr.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_sales_terr IS
      SELECT
        sgmnt_id,
        NVL(bus_unit_id, -1) AS bus_unit_id,
        sales_terr_user_id
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = i_sales_terr_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;

    rv_efex_sales_terr csr_efex_sales_terr%ROWTYPE;

  BEGIN

    OPEN csr_efex_sales_terr;
    FETCH csr_efex_sales_terr INTO rv_efex_sales_terr;
    IF csr_efex_sales_terr%FOUND THEN

      -- Clear the validation reason tables of this sales territory.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_sales_terr,
                                  rv_efex_sales_terr.bus_unit_id,
                                  i_sales_terr_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_sales_terr.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_sales_terr, 'n/a', i_log_level + 1,    'efex_sales_terr: ' ||
                                                                          i_sales_terr_id   ||
                                                                          ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_sales_terr,
                                  'Invalid or non-existant Segment Id - ' || rv_efex_sales_terr.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_sales_terr.bus_unit_id,
                                  i_sales_terr_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_sales_terr.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_sales_terr, 'n/a', i_log_level + 1,    'efex_sales_terr: ' ||
                                                                          i_sales_terr_id   ||
                                                                          ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_sales_terr,
                                  'Invalid or non-existant Business Unit Id - ' || rv_efex_sales_terr.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_sales_terr.bus_unit_id,
                                  i_sales_terr_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;



      -- Sales territory user exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_sales_terr.sales_terr_user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_sales_terr, 'n/a', i_log_level + 1,    'efex_sales_terr: ' ||
                                                                          i_sales_terr_id   ||
                                                                          ': Invalid or non-existant Sales Territory User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_sales_terr,
                                  'Invalid or non-existant Sales Territory User Id - ' || rv_efex_sales_terr.sales_terr_user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_sales_terr.bus_unit_id,
                                  i_sales_terr_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_sales_terr
      SET
        valdtn_status = v_valdtn_status
      WHERE
        sales_terr_id = i_sales_terr_id;

    END IF;
    CLOSE csr_efex_sales_terr;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_sales_terr;

/********************************************************************************
    NAME:       check_efex_cust
    PURPOSE:    This procedure reads through all efex customer records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_cust(
    i_log_level          IN ods.log.log_level%TYPE,
    i_reset_transaction  IN BOOLEAN DEFAULT TRUE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT
        COUNT(*) as rec_count
      FROM
        efex_cust
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_efex_distbr IS
      SELECT
        efex_cust_id
      FROM
        efex_cust
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked
        AND distbr_flg = 'Y';

    rv_efex_distbr csr_efex_distbr%ROWTYPE;

    CURSOR csr_efex_cust IS
      SELECT
        efex_cust_id
      FROM
        efex_cust
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked
        AND distbr_flg = 'N';
    rv_efex_cust csr_efex_cust%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_cust: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_record_count;
    CLOSE csr_counter;

    IF v_record_count > 0 THEN

       UPDATE efex_cust
       SET valdtn_status = ods_constants.valdtn_unchecked
       WHERE valdtn_status = ods_constants.valdtn_invalid;

       -- Clear validation reason tables for the validation type.
       clear_validation_reason (ods_constants.valdtn_type_efex_cust, i_log_level + 1);

       IF i_reset_transaction = TRUE THEN
          -- Found any changes to customer, then reset all existing invalid customer related transaction record to unchecked.
          reset_cust_xactn_valdtn_status(i_log_level+1);
       END IF;
       v_record_count := 0;

       -- Validate distributor first, so the outlet customer distributor can be validated in the same process.
       OPEN csr_efex_distbr;
       FETCH csr_efex_distbr INTO rv_efex_distbr;
       WHILE csr_efex_distbr%FOUND LOOP

         -- PROCESS DATA
         validate_efex_cust(i_log_level + 2, rv_efex_distbr.efex_cust_id);

         FETCH csr_efex_distbr INTO rv_efex_distbr;
       END LOOP;
       CLOSE csr_efex_distbr;
       COMMIT;

       -- Validate outlet customer now.
       OPEN csr_efex_cust;
       FETCH csr_efex_cust INTO rv_efex_cust;
       IF (csr_efex_cust%FOUND) THEN
          
          LOOP
             EXIT WHEN csr_efex_cust%NOTFOUND;
   
             -- PROCESS DATA
             validate_efex_cust(i_log_level + 2, rv_efex_cust.efex_cust_id);
   
             -- Commit when required.
             v_record_count := v_record_count + 1;
             IF v_record_count >= c_commit_count THEN
               COMMIT;
               v_record_count := 0;
             END IF;
   
             FETCH csr_efex_cust INTO rv_efex_cust;
           END LOOP;
       END IF;
       CLOSE csr_efex_cust;
       COMMIT;
    END IF;

    write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_cust: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', 0, 'ods_efex_validation.check_efex_cust: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_cust;

  /*******************************************************************************
    NAME:       validate_efex_cust
    PURPOSE:    This procedure validates a efex customer record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_cust(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_cust.efex_cust_id%TYPE
   ) IS

      -- VARIABLE DECLARATIONS
   v_valdtn_status efex_cust.valdtn_status%TYPE := ods_constants.valdtn_valid;
   v_count           PLS_INTEGER;
   v_cust_code       VARCHAR2(10);
   v_cust_visit_freq NUMBER;

      -- CURSOR DECLARATIONS
    CURSOR csr_efex_cust IS
      SELECT
        cust_code,
        distbr_flg,
        outlet_flg,
        active_flg,
        t1.sales_terr_id,
        range_id,
        cust_visit_freq,
        cust_visit_freq_id,
        cust_type_id,
        affltn_id,
        corporate_flg,
        cust_grade_id,
        distbr_id,
        NVL(bus_unit_id, -1) AS bus_unit_id,
        t1.status
      FROM
        efex_cust t1,
        efex_sales_terr t2
      WHERE
        efex_cust_id = i_efex_cust_id
        AND t1.sales_terr_id = t2.sales_terr_id (+)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_cust csr_efex_cust%ROWTYPE;

  BEGIN

    OPEN csr_efex_cust;
    FETCH csr_efex_cust INTO rv_efex_cust;
    IF csr_efex_cust%FOUND THEN

      -- Clear the validation reason tables of this efex customer.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  rv_efex_cust.bus_unit_id,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      IF rv_efex_cust.status = 'A' THEN
        -- Sales Territory must exist and be valid.
        IF rv_efex_cust.sales_terr_id IS NOT NULL THEN
           v_count := 0;
           SELECT
             count(*) INTO v_count
           FROM
             efex_sales_terr
           WHERE
             sales_terr_id = rv_efex_cust.sales_terr_id
             AND valdtn_status = ods_constants.valdtn_valid;
  
           IF v_count <> 1 THEN
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Invalid or non-existant Sales Territory Id.');
  
             -- Add an entry into the validation reason tables.
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Invalid or non-existant Sales Territory Id - ' || rv_efex_cust.sales_terr_id,
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
           END IF;
        END IF;
  
        -- Range must exist and be valid.
        IF rv_efex_cust.range_id IS NOT NULL THEN
           v_count := 0;
           SELECT
             count(*) INTO v_count
           FROM
             efex_range
           WHERE
             range_id = rv_efex_cust.range_id
             AND valdtn_status = ods_constants.valdtn_valid;
  
           IF v_count <> 1 THEN
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Invalid or non-existant Range Id.');
  
             -- Add an entry into the validation reason tables.
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Invalid or non-existant Range Id - ' || rv_efex_cust.range_id,
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
           END IF;
        END IF;
  
        -- Customer Type must exist and be valid.
        IF rv_efex_cust.cust_type_id IS NOT NULL THEN
           v_count := 0;
           SELECT
             count(*) INTO v_count
           FROM
             efex_cust_chnl
           WHERE
             cust_type_id = rv_efex_cust.cust_type_id
             AND valdtn_status = ods_constants.valdtn_valid;
  
           IF v_count <> 1 THEN
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Invalid or non-existant Cust Type Id.');
  
             -- Add an entry into the validation reason tables.
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Invalid or non-existant Cust Type Id - ' || rv_efex_cust.cust_type_id,
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
           END IF;
  
        END IF;
  
        -- Affiliation ID must exist and be valid.
        IF rv_efex_cust.affltn_id IS NOT NULL THEN
           v_count := 0;
           SELECT
             count(*) INTO v_count
           FROM
             efex_affltn
           WHERE
             affltn_id = rv_efex_cust.affltn_id
             AND valdtn_status = ods_constants.valdtn_valid;
  
           IF v_count <> 1 THEN
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Invalid or non-existant Affltn Id.');
  
             -- Add an entry into the validation reason tables.
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Invalid or non-existant Affltn Id - ' || rv_efex_cust.affltn_id,
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
           END IF;
        END IF;
  
        -- GRD Customer code must exist and be valid.
        IF rv_efex_cust.cust_code IS NOT NULL AND rv_efex_cust.outlet_flg = 'N' THEN
           -- Format the cust_code to SAP format before checking in cust_dim.
           v_cust_code := FORMAT_CUST_CODE(rv_efex_cust.cust_code);
           v_count := 0;
           SELECT
             count(*) INTO v_count
           FROM
             cust_dim
           WHERE
             cust_code = v_cust_code;
  
           IF v_count <> 1 THEN
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Invalid or non-existant cust_code.');
  
             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Invalid or non-existant cust_code - ' || rv_efex_cust.cust_code,
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
           END IF;
        END IF;
  
        -- GRD customer must provide cust_code.
        IF rv_efex_cust.outlet_flg = 'N' AND rv_efex_cust.distbr_flg = 'N' AND rv_efex_cust.cust_code IS NULL THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Customer must at least be an Outlet, Distributor or Direct customer (with customer_code).');
  
             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Customer can not be outlet_flg = N and distributor_flg = N and customer_code IS NULL',
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
        END IF;

        -- If outlet customer should not have cust_code
        IF rv_efex_cust.outlet_flg = 'Y' AND rv_efex_cust.cust_code IS NOT NULL THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Outlet customer should not have cust_code.');
  
             -- Add an entry into the validation reason tables
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Outlet customer should not be a Direct customer as well (have customer_code provided)',
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
        END IF;

        -- Distributor must exist and be valid.
        IF rv_efex_cust.distbr_id IS NOT NULL THEN
           v_count := 0;
           SELECT
             count(*) INTO v_count
           FROM
             efex_cust
           WHERE
             efex_cust_id = rv_efex_cust.distbr_id
             AND (valdtn_status = ods_constants.valdtn_valid OR valdtn_status = ods_constants.valdtn_unchecked); -- Unchecked is required as the Distributor may be assigned to itself in which case the validation status would be UNCHECKED.
  
           IF v_count <> 1 THEN
             v_valdtn_status := ods_constants.valdtn_invalid;
             write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                               i_efex_cust_id   ||
                                                                               ': Invalid or non-existant Distributor Id.');
  
             -- Add an entry into the validation reason tables.
             utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Invalid or non-existant Distributor Id - ' || rv_efex_cust.distbr_id,
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
           END IF;
        END IF;
  
        -- Customer Visit Frequency must be number.
        IF rv_efex_cust.cust_visit_freq IS NOT NULL THEN
           BEGIN
             -- exception will be raised if the cust_visit_freq is not a number
             v_cust_visit_freq := TO_NUMBER(rv_efex_cust.cust_visit_freq);
  
             -- CUST_VIST_FREQ must be a positive number.
             IF v_cust_visit_freq < 0 THEN
                v_valdtn_status := ods_constants.valdtn_invalid;
                write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                                  i_efex_cust_id   ||
                                                                                  ': Customer Visit Frequency must be a positive number.');
  
                -- Add an entry into the validation reason tables.
                utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Customer Visit Frequency must be a positive number.',
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
  
             END IF;
           EXCEPTION
             WHEN OTHERS THEN
               v_valdtn_status := ods_constants.valdtn_invalid;
               write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1,    'efex_cust: ' ||
                                                                                 i_efex_cust_id   ||
                                                                                 ': Customer Visit Frequency is not a number.');
  
               -- Add an entry into the validation reason tables.
               utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                       'Customer Visit Frequency is not a number.',
                                       ods_constants.valdtn_severity_critical,
                                       rv_efex_cust.bus_unit_id,
                                       i_efex_cust_id,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       i_log_level + 1);
           END;
        END IF;
    
      END IF;  -- status = A 

      UPDATE
        efex_cust
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_cust_id = i_efex_cust_id;

    END IF;
    CLOSE csr_efex_cust;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;


  END validate_efex_cust;

/********************************************************************************
    NAME:       check_efex_matl_grp
    PURPOSE:    This procedure reads through all efex group records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_matl_grp(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_matl_grp IS
      SELECT
        matl_grp_id
      FROM
        efex_matl_grp
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_matl_grp csr_efex_matl_grp%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_matl_grp, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_matl_grp: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_matl_grp;
    FETCH csr_efex_matl_grp INTO rv_efex_matl_grp;
    WHILE csr_efex_matl_grp%FOUND LOOP

      -- PROCESS DATA
      validate_efex_matl_grp(i_log_level + 2, rv_efex_matl_grp.matl_grp_id);

      FETCH csr_efex_matl_grp INTO rv_efex_matl_grp;
    END LOOP;
    CLOSE csr_efex_matl_grp;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_matl_grp, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_matl_grp: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_matl_grp, 'n/a', 0, 'ods_efex_validation.check_efex_matl_grp: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_matl_grp;

  /*******************************************************************************
    NAME:       validate_efex_matl_grp
    PURPOSE:    This procedure validates a efex material group record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_matl_grp(
    i_log_level           IN ods.log.log_level%TYPE,
    i_matl_grp_id         IN efex_matl_grp.matl_grp_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_matl_grp.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_matl_grp IS
      SELECT
        sgmnt_id,
        NVL(bus_unit_id, -1) AS bus_unit_id,
        status
      FROM
        efex_matl_grp
      WHERE
        matl_grp_id = i_matl_grp_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_matl_grp csr_efex_matl_grp%ROWTYPE;

  BEGIN
    OPEN csr_efex_matl_grp;
    FETCH csr_efex_matl_grp INTO rv_efex_matl_grp;
    IF csr_efex_matl_grp%FOUND THEN

      -- Clear the validation reason tables of this efex material group.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_matl_grp,
                                  rv_efex_matl_grp.bus_unit_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      IF rv_efex_matl_grp.status = 'A' THEN
         -- Segment must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_sgmnt
         WHERE
           sgmnt_id = rv_efex_matl_grp.sgmnt_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_grp, 'n/a', i_log_level + 1,    'efex_matl_grp: ' ||
                                                                             i_matl_grp_id   ||
                                                                             ': Invalid or non-existant Segment Id.');
   
           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_grp,
                                     'Invalid or non-existant Segment Id - ' || rv_efex_matl_grp.sgmnt_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_grp.bus_unit_id,
                                     i_matl_grp_id,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
   
         -- Business Unit must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_bus_unit
         WHERE
           bus_unit_id = rv_efex_matl_grp.bus_unit_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_grp, 'n/a', i_log_level + 1,    'efex_matl_grp: ' ||
                                                                             i_matl_grp_id   ||
                                                                             ': Invalid or non-existant Business Unit Id.');
   
           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_grp,
                                     'Invalid or non-existant Business Unit Id - ' || rv_efex_matl_grp.bus_unit_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_grp.bus_unit_id,
                                     i_matl_grp_id,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
      END IF;

      UPDATE
        efex_matl_grp
      SET
        valdtn_status = v_valdtn_status
      WHERE
        matl_grp_id = i_matl_grp_id;

    END IF;
    CLOSE csr_efex_matl_grp;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_matl_grp;

/********************************************************************************
    NAME:       check_efex_matl_subgrp
    PURPOSE:    This procedure reads through all efex material subgroup records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_matl_subgrp(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_matl_subgrp IS
      SELECT
        matl_subgrp_id
      FROM
        efex_matl_subgrp
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_matl_subgrp csr_efex_matl_subgrp%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_matl_subgrp, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_matl_subgrp: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_matl_subgrp;
    FETCH csr_efex_matl_subgrp INTO rv_efex_matl_subgrp;
    WHILE csr_efex_matl_subgrp%FOUND LOOP

      -- PROCESS DATA
      validate_efex_matl_subgrp(i_log_level + 2, rv_efex_matl_subgrp.matl_subgrp_id);

      FETCH csr_efex_matl_subgrp INTO rv_efex_matl_subgrp;
    END LOOP;
    CLOSE csr_efex_matl_subgrp;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_matl_subgrp, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_matl_subgrp: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_matl_subgrp, 'n/a', 0, 'ods_efex_validation.check_efex_matl_subgrp: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_matl_subgrp;

  /*******************************************************************************
    NAME:       validate_efex_matl_subgrp
    PURPOSE:    This procedure validates a efex material subgroup record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_matl_subgrp(
    i_log_level           IN ods.log.log_level%TYPE,
    i_matl_subgrp_id      IN efex_matl_subgrp.matl_subgrp_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_matl_subgrp.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_matl_subgrp IS
      SELECT
        t1.matl_grp_id,
        NVL(bus_unit_id, -1) AS bus_unit_id,
        t1.status
      FROM
        efex_matl_subgrp t1,
        efex_matl_grp t2
      WHERE
        matl_subgrp_id = i_matl_subgrp_id
        AND t1.matl_grp_id = t2.matl_grp_id (+)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_matl_subgrp csr_efex_matl_subgrp%ROWTYPE;

  BEGIN
    OPEN csr_efex_matl_subgrp;
    FETCH csr_efex_matl_subgrp INTO rv_efex_matl_subgrp;
    IF csr_efex_matl_subgrp%FOUND THEN

      -- Clear the validation reason tables of this efex material subgroup.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_matl_subgrp,
                                  rv_efex_matl_subgrp.bus_unit_id,
                                  i_matl_subgrp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      IF rv_efex_matl_subgrp.status = 'A' THEN
         -- Material Group must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_matl_grp
         WHERE
           matl_grp_id = rv_efex_matl_subgrp.matl_grp_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_subgrp, 'n/a', i_log_level + 1,    'efex_matl_subgrp: ' ||
                                                                      i_matl_subgrp_id   ||
                                                                      ': Invalid or non-existant Material Group Id.');
   
           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_subgrp,
                                     'Invalid or non-existant Material Group Id - ' || rv_efex_matl_subgrp.matl_grp_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_subgrp.bus_unit_id,
                                     i_matl_subgrp_id,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
      END IF;

      UPDATE
        efex_matl_subgrp
      SET
        valdtn_status = v_valdtn_status
      WHERE
        matl_subgrp_id = i_matl_subgrp_id;

    END IF;
    CLOSE csr_efex_matl_subgrp;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_matl_subgrp;

/**********************************************************************************************
    NAME:       check_efex_matl_matl_subgrp
    PURPOSE:    This procedure reads through all efex material material subgroup records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  *********************************************************************************************/
  PROCEDURE check_efex_matl_matl_subgrp(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_matl_matl_subgrp IS
      SELECT
        efex_matl_id,
        matl_subgrp_id,
        sgmnt_id
      FROM
        efex_matl_matl_subgrp
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_matl_matl_subgrp csr_efex_matl_matl_subgrp%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_matl_matl_subgrp: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_matl_matl_subgrp;
    FETCH csr_efex_matl_matl_subgrp INTO rv_efex_matl_matl_subgrp;
    WHILE csr_efex_matl_matl_subgrp%FOUND LOOP

      -- PROCESS DATA
      validate_efex_matl_matl_subgrp(i_log_level + 2,
                                     rv_efex_matl_matl_subgrp.efex_matl_id,
                                     rv_efex_matl_matl_subgrp.matl_subgrp_id,
                                     rv_efex_matl_matl_subgrp.sgmnt_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_matl_matl_subgrp INTO rv_efex_matl_matl_subgrp;
    END LOOP;
    CLOSE csr_efex_matl_matl_subgrp;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_matl_matl_subgrp: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', 0, 'ods_efex_validation.check_efex_matl_matl_subgrp: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_matl_matl_subgrp;

  /*******************************************************************************
    NAME:       validate_efex_matl_matl_subgrp
    PURPOSE:    This procedure validates a efex material subgroup record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_matl_matl_subgrp(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_matl_id        IN efex_matl_matl_subgrp.efex_matl_id%TYPE,
    i_matl_subgrp_id      IN efex_matl_matl_subgrp.matl_subgrp_id%TYPE,
    i_sgmnt_id            IN efex_matl_matl_subgrp.sgmnt_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_matl_matl_subgrp.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_matl_matl_subgrp IS
      SELECT
        efex_matl_id,
        matl_subgrp_id,
        sgmnt_id,
        matl_grp_id,
        NVL(bus_unit_id, -1) AS bus_unit_id,
        status
      FROM
        efex_matl_matl_subgrp
      WHERE
        efex_matl_id = i_efex_matl_id
        AND matl_subgrp_id = i_matl_subgrp_id
        AND sgmnt_id = i_sgmnt_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_matl_matl_subgrp csr_efex_matl_matl_subgrp%ROWTYPE;

  BEGIN
    OPEN csr_efex_matl_matl_subgrp;
    FETCH csr_efex_matl_matl_subgrp INTO rv_efex_matl_matl_subgrp;
    IF csr_efex_matl_matl_subgrp%FOUND THEN

      -- Clear the validation reason tables of this efex material material subgroup
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                  rv_efex_matl_matl_subgrp.bus_unit_id,
                                  i_efex_matl_id,
                                  i_matl_subgrp_id,
                                  i_sgmnt_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      IF rv_efex_matl_matl_subgrp.status = 'A' THEN
         -- EFEX Material must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_matl
         WHERE
           efex_matl_id = rv_efex_matl_matl_subgrp.efex_matl_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'n/a', i_log_level + 1,    'efex_matl_matl_subgrp matl/subgrp/sgmnt : ' ||
                                                                      i_efex_matl_id   || '/' ||
                                                                      i_matl_subgrp_id  || '/' ||
                                                                      i_sgmnt_id  ||
                                                                      ': Invalid or non-existant EFEX Material Id.');
   
           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                     'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant EFEX Material Id - ' || rv_efex_matl_matl_subgrp.efex_matl_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_matl_subgrp.bus_unit_id,
                                     i_efex_matl_id,
                                     i_matl_subgrp_id,
                                     i_sgmnt_id,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
   
   
         -- Material Subgroup must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_matl_subgrp
         WHERE
           matl_subgrp_id = rv_efex_matl_matl_subgrp.matl_subgrp_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'n/a', i_log_level + 1,    'efex_matl_matl_subgrp matl/subgrp/sgmnt : ' ||
                                                                      i_efex_matl_id   || '/' ||
                                                                      i_matl_subgrp_id  || '/' ||
                                                                      i_sgmnt_id  ||
                                                                      ': Invalid or non-existant Material Subgrp Id.');
   
           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                     'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant matl_subgrp_id - ' || rv_efex_matl_matl_subgrp.matl_subgrp_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_matl_subgrp.bus_unit_id,
                                     i_efex_matl_id,
                                     i_matl_subgrp_id,
                                     i_sgmnt_id,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
   
         -- Material Group must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_matl_grp
         WHERE
           matl_grp_id = rv_efex_matl_matl_subgrp.matl_grp_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'n/a', i_log_level + 1,    'efex_matl_matl_subgrp matl/subgrp/sgmnt : ' ||
                                                                      i_efex_matl_id   || '/' ||
                                                                      i_matl_subgrp_id  || '/' ||
                                                                      i_sgmnt_id  ||
                                                                      ': Invalid or non-existant Material Group Id.');
   
           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                     'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Material Group Id - ' || rv_efex_matl_matl_subgrp.matl_grp_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_matl_subgrp.bus_unit_id,
                                     i_efex_matl_id,
                                     i_matl_subgrp_id,
                                     i_sgmnt_id,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
   
         -- Segment must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_sgmnt
         WHERE
           sgmnt_id = rv_efex_matl_matl_subgrp.sgmnt_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'n/a', i_log_level + 1,    'efex_matl_matl_subgrp matl/subgrp/sgmnt : ' ||
                                                                      i_efex_matl_id   || '/' ||
                                                                      i_matl_subgrp_id  || '/' ||
                                                                      i_sgmnt_id  ||
                                                                      ': Invalid or non-existant Segment Id.');
   
           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                     'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Segment Id - ' || rv_efex_matl_matl_subgrp.sgmnt_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_matl_subgrp.bus_unit_id,
                                     i_efex_matl_id,
                                     i_matl_subgrp_id,
                                     i_sgmnt_id,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
   
         -- Business Unit must exist and be valid.
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_bus_unit
         WHERE
           bus_unit_id = rv_efex_matl_matl_subgrp.bus_unit_id
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'n/a', i_log_level + 1,    'efex_matl_matl_subgrp: ' ||
                                                                      i_efex_matl_id   || '/' ||
                                                                      i_matl_subgrp_id  || '/' ||
                                                                      i_sgmnt_id  ||
                                                                      ': Invalid or non-existant Business Unit Id.');
   
           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                     'KEY: [matl-subgrp-sgmnt] - Invalid or non-existant Business Unit Id - ' || rv_efex_matl_matl_subgrp.bus_unit_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_matl_subgrp.bus_unit_id,
                                     i_efex_matl_id,
                                     i_matl_subgrp_id,
                                     i_sgmnt_id,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
   
         -- Must only have one subgroup for the same material and segment if it's status is Active
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_matl_matl_subgrp
         WHERE
           efex_matl_id = rv_efex_matl_matl_subgrp.efex_matl_id
           AND sgmnt_id = rv_efex_matl_matl_subgrp.sgmnt_id
           AND matl_subgrp_id <> rv_efex_matl_matl_subgrp.matl_subgrp_id
           AND status = rv_efex_matl_matl_subgrp.status
           AND rv_efex_matl_matl_subgrp.status = 'A'
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 0 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'n/a', i_log_level + 1,    'efex_matl_matl_subgrp matl/subgrp/sgmnt : ' ||
                                                                      i_efex_matl_id   || '/' ||
                                                                      i_matl_subgrp_id  || '/' ||
                                                                      i_sgmnt_id  ||
                                                                      ': Invalid - matl assign to more than one subgrp for same segment.');
   
           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                     'KEY: [matl-subgrp-sgmnt] - Invalid - matl assign to more than one subgrp for same segment.',
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_matl_matl_subgrp.bus_unit_id,
                                     i_efex_matl_id,
                                     i_matl_subgrp_id,
                                     i_sgmnt_id,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
      END IF;

      UPDATE
        efex_matl_matl_subgrp
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_matl_id = i_efex_matl_id
        AND matl_subgrp_id = i_matl_subgrp_id
        AND sgmnt_id = i_sgmnt_id;

    END IF;
    CLOSE csr_efex_matl_matl_subgrp;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_matl_matl_subgrp;


/********************************************************************************
    NAME:       check_efex_route_sched
    PURPOSE:    This procedure reads through all efex route scheduled records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_route_sched(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_route_sched IS
      SELECT DISTINCT
        t1.user_id,
        route_sched_date,
        NVL(t2.bus_unit_id, -1) as bus_unit_id
      FROM
        efex_route_sched t1,
        efex_user_sgmnt  t2
      WHERE
        t1.user_id = t2.user_id (+) 
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_route_sched csr_efex_route_sched%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_route_sched, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_route_sched: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_route_sched;
    FETCH csr_efex_route_sched INTO rv_efex_route_sched;
    WHILE csr_efex_route_sched%FOUND LOOP

      -- PROCESS DATA
      validate_efex_route_sched(i_log_level + 2,
                                rv_efex_route_sched.user_id,
                                rv_efex_route_sched.route_sched_date,
                                rv_efex_route_sched.bus_unit_id);

      FETCH csr_efex_route_sched INTO rv_efex_route_sched;
    END LOOP;
    CLOSE csr_efex_route_sched;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_route_sched, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_route_sched: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_route_sched, 'n/a', 0, 'ods_efex_validation.check_efex_route_sched: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_route_sched;

  /*******************************************************************************
    NAME:       validate_efex_route_sched
    PURPOSE:    This procedure validates a efex route scheduled record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_route_sched(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_route_sched.user_id%TYPE,
    i_route_sched_date    IN efex_route_sched.route_sched_date%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_route_sched.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_route_sched IS
      SELECT 
        user_id
      FROM
        efex_route_sched 
      WHERE
        user_id = i_user_id
        AND route_sched_date = i_route_sched_date
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_route_sched csr_efex_route_sched%ROWTYPE;

  BEGIN
    OPEN csr_efex_route_sched;
    FETCH csr_efex_route_sched INTO rv_efex_route_sched;
    IF csr_efex_route_sched%FOUND THEN

      -- Clear the validation reason tables of this efex route scheduled.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_route_sched,
                                  i_bus_unit_id,
                                  i_user_id,
                                  i_route_sched_date,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);


      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_route_sched.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_route_sched, 'n/a', i_log_level + 1,    'efex_route_sched business/user/sched date : ' ||
                                                                   i_bus_unit_id || '/' ||
                                                                   i_user_id  || '/' ||
                                                                   i_route_sched_date   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_sched,
                                  'KEY: [user-sched_date] - Invalid or non-existant User Id - ' || rv_efex_route_sched.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_user_id,
                                  i_route_sched_date,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_route_sched
      SET
        valdtn_status = v_valdtn_status
      WHERE
        user_id = i_user_id
        AND route_sched_date = i_route_sched_date 
        AND valdtn_status = ods_constants.valdtn_unchecked;
 
    END IF;
    CLOSE csr_efex_route_sched;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_route_sched;

/********************************************************************************
    NAME:       check_efex_route_plan
    PURPOSE:    This procedure reads through all efex route plan records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_route_plan(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_route_plan IS
      SELECT
        user_id,
        route_plan_date,
        efex_cust_id
      FROM
        efex_route_plan
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_route_plan csr_efex_route_plan%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_route_plan: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_route_plan;
    FETCH csr_efex_route_plan INTO rv_efex_route_plan;
    WHILE csr_efex_route_plan%FOUND LOOP

      -- PROCESS DATA
      validate_efex_route_plan(i_log_level + 2,
                                rv_efex_route_plan.user_id,
                                rv_efex_route_plan.route_plan_date,
                                rv_efex_route_plan.efex_cust_id);

      -- Commit when required,
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_route_plan INTO rv_efex_route_plan;
    END LOOP;
    CLOSE csr_efex_route_plan;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_route_plan: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', 0, 'ods_efex_validation.check_efex_route_plan: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_route_plan;

  /*******************************************************************************
    NAME:       validate_efex_route_plan
    PURPOSE:    This procedure validates a efex route plan record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_route_plan(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_route_plan.user_id%TYPE,
    i_route_plan_date     IN efex_route_plan.route_plan_date%TYPE,
    i_efex_cust_id        IN efex_route_plan.efex_cust_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_route_plan.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_route_plan IS
      SELECT
        user_id,
        efex_cust_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_route_plan
      WHERE
        user_id = i_user_id
        AND route_plan_date = i_route_plan_date
        AND efex_cust_id = i_efex_cust_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_route_plan csr_efex_route_plan%ROWTYPE;

  BEGIN
    OPEN csr_efex_route_plan;
    FETCH csr_efex_route_plan INTO rv_efex_route_plan;
    IF csr_efex_route_plan%FOUND THEN

      -- Clear the validation reason tables of this efex route plan.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  rv_efex_route_plan.bus_unit_id,
                                  i_user_id,
                                  i_route_plan_date,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);


      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_route_plan.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_route_plan, 'n/a', i_log_level + 1,    'efex_route_plan user/plan date : ' ||
                                                                   i_user_id  || '/' ||
                                                                   i_route_plan_date  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'KEY: [user-plan_date-cust] - Invalid or non-existant User Id - ' || rv_efex_route_plan.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_route_plan.bus_unit_id,
                                  i_user_id,
                                  i_route_plan_date,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_route_plan.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_route_plan, 'n/a', i_log_level + 1,    'efex_route_plan user/plan date : ' ||
                                                                   i_user_id  || '/' ||
                                                                   i_route_plan_date  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'KEY: [user-plan_date-cust] - Invalid or non-existant Customer Id - ' || rv_efex_route_plan.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_route_plan.bus_unit_id,
                                  i_user_id,
                                  i_route_plan_date,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_route_plan.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_route_plan, 'n/a', i_log_level + 1,    'efex_route_plan user/plan date : ' ||
                                                                   i_user_id  || '/' ||
                                                                   i_route_plan_date  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'KEY: [user-plan_date-cust] - Invalid or non-existant Sales Territory Id - ' || rv_efex_route_plan.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_route_plan.bus_unit_id,
                                  i_user_id,
                                  i_route_plan_date,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_route_plan.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_route_plan, 'n/a', i_log_level + 1,    'efex_route_plan user/plan date : ' ||
                                                                   i_user_id  || '/' ||
                                                                   i_route_plan_date  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'KEY: [user-plan_date-cust] - Invalid or non-existant Segment Id - ' || rv_efex_route_plan.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_route_plan.bus_unit_id,
                                  i_user_id,
                                  i_route_plan_date,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_route_plan.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_route_plan, 'n/a', i_log_level + 1,    'efex_route_plan user/plan date : ' ||
                                                                   i_user_id  || '/' ||
                                                                   i_route_plan_date  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'KEY: [user-plan_date-cust] - Invalid or non-existant Business Unit Id - ' || rv_efex_route_plan.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_route_plan.bus_unit_id,
                                  i_user_id,
                                  i_route_plan_date,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_route_plan
      SET
        valdtn_status = v_valdtn_status
      WHERE
        user_id = i_user_id
        AND route_plan_date = i_route_plan_date
        AND efex_cust_id = i_efex_cust_id;
    END IF;
    CLOSE csr_efex_route_plan;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_route_plan;

  /********************************************************************************
    NAME:       check_efex_call
    PURPOSE:    This procedure reads through all efex call records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_call(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_call IS
      SELECT
        efex_cust_id,
        call_date,
        user_id
      FROM
        efex_call
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_call csr_efex_call%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_call: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_call;
    FETCH csr_efex_call INTO rv_efex_call;
    WHILE csr_efex_call%FOUND LOOP

      -- PROCESS DATA
      validate_efex_call(i_log_level + 2,
                         rv_efex_call.efex_cust_id,
                         rv_efex_call.call_date,
                         rv_efex_call.user_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_call INTO rv_efex_call;
    END LOOP;
    CLOSE csr_efex_call;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_call: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_call, 'n/a', 0, 'ods_efex_validation.check_efex_call: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_call;

  /*******************************************************************************
    NAME:       validate_efex_call
    PURPOSE:    This procedure validates a efex call record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_call(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_call.efex_cust_id%TYPE,
    i_call_date           IN efex_call.call_date%TYPE,
    i_user_id             IN efex_call.user_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_call.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_call IS
      SELECT
        efex_cust_id,
        user_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_call
      WHERE
        efex_cust_id = i_efex_cust_id
        AND call_date = i_call_date
        AND user_id = i_user_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_call csr_efex_call%ROWTYPE;

  BEGIN
    OPEN csr_efex_call;
    FETCH csr_efex_call INTO rv_efex_call;
    IF csr_efex_call%FOUND THEN

      -- Clear the validation reason tables of this efex call
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_call,
                                  rv_efex_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_call.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_call, 'n/a', i_log_level + 1,    'efex_call cust/callDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS')  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'KEY: [cust-call_date-user] - Invalid or non-existant Customer Id - ' || rv_efex_call.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_call.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_call, 'n/a', i_log_level + 1,    'efex_call cust/callDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS')  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'KEY: [cust-call_date-user] - Invalid or non-existant User Id - ' || rv_efex_call.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_call.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_call, 'n/a', i_log_level + 1,    'efex_call cust/callDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS')  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'KEY: [cust-call_date-user] - Invalid or non-existant Sales Territory Id - ' || rv_efex_call.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_call.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_call, 'n/a', i_log_level + 1,    'efex_call cust/callDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS')  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'KEY: [cust-call_date-user] - Invalid or non-existant Segment Id - ' || rv_efex_call.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_call.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_call, 'n/a', i_log_level + 1,    'efex_call cust/callDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_call_date  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'KEY: [cust-call_date-user] - Invalid or non-existant Business Unit Id - ' || rv_efex_call.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_call_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_call
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_cust_id = i_efex_cust_id
        AND call_date = i_call_date
        AND user_id = i_user_id;

    END IF;
    CLOSE csr_efex_call;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_call;

  /********************************************************************************
    NAME:       check_efex_timesheet_call
    PURPOSE:    This procedure reads through all efex timesheet call records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_timesheet_call(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_timesheet_call IS
      SELECT
        efex_cust_id,
        timesheet_date,
        user_id
      FROM
        efex_timesheet_call
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_timesheet_call csr_efex_timesheet_call%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_tmesht_call, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_timesheet_call: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_timesheet_call;
    FETCH csr_efex_timesheet_call INTO rv_efex_timesheet_call;
    WHILE csr_efex_timesheet_call%FOUND LOOP

      -- PROCESS DATA
      validate_efex_timesheet_call(i_log_level + 2,
                                rv_efex_timesheet_call.efex_cust_id,
                                rv_efex_timesheet_call.timesheet_date,
                                rv_efex_timesheet_call.user_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_timesheet_call INTO rv_efex_timesheet_call;
    END LOOP;
    CLOSE csr_efex_timesheet_call;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_tmesht_call, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_timesheet_call: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_tmesht_call, 'n/a', 0, 'ods_efex_validation.check_efex_timesheet_call: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_timesheet_call;

  /*******************************************************************************
    NAME:       validate_efex_timesheet_call
    PURPOSE:    This procedure validates a efex timesheet call record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_timesheet_call(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_timesheet_call.efex_cust_id%TYPE,
    i_timesheet_date      IN efex_timesheet_call.timesheet_date%TYPE,
    i_user_id             IN efex_timesheet_call.user_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_timesheet_call.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_timesheet_call IS
      SELECT
        efex_cust_id,
        user_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_timesheet_call
      WHERE
        efex_cust_id = i_efex_cust_id
        AND timesheet_date = i_timesheet_date
        AND user_id = i_user_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_timesheet_call csr_efex_timesheet_call%ROWTYPE;

  BEGIN
    OPEN csr_efex_timesheet_call;
    FETCH csr_efex_timesheet_call INTO rv_efex_timesheet_call;
    IF csr_efex_timesheet_call%FOUND THEN

      -- Clear the validation reason tables of this efex timesheet call.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_tmesht_call,
                                  rv_efex_timesheet_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_timesheet_call.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_tmesht_call, 'n/a', i_log_level + 1,    'efex_timesheet_call cust/timesheetDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_timesheet_date  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_tmesht_call,
                                  'KEY: [cust-timesheet_date-user] - Invalid or non-existant Customer Id - ' || rv_efex_timesheet_call.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_timesheet_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_timesheet_call.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_tmesht_call, 'n/a', i_log_level + 1,    'efex_timesheet_call cust/timesheetDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_timesheet_date  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_efex_tmesht_call,
                                  'KEY: [cust-timesheet_date-user] - Invalid or non-existant User Id - ' || rv_efex_timesheet_call.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_timesheet_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_timesheet_call.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_tmesht_call, 'n/a', i_log_level + 1,    'efex_timesheet_call cust/timesheetDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_timesheet_date  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables
        utils.add_validation_reason(ods_constants.valdtn_type_efex_tmesht_call,
                                  'KEY: [cust-timesheet_date-user] - Invalid or non-existant Sales Territory Id - ' || rv_efex_timesheet_call.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_timesheet_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_timesheet_call.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_tmesht_call, 'n/a', i_log_level + 1,    'efex_timesheet_call cust/timesheetDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_timesheet_date  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_tmesht_call,
                                  'KEY: [cust-timesheet_date-user] - Invalid or non-existant Segment Id - ' || rv_efex_timesheet_call.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_timesheet_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_timesheet_call.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_tmesht_call, 'n/a', i_log_level + 1,    'efex_timesheet_call cust/timesheetDate/user : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_timesheet_date  || '/' ||
                                                                   i_user_id   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_tmesht_call,
                                  'KEY: [cust-timesheet_date-user] - Invalid or non-existant Business Unit Id - ' || rv_efex_timesheet_call.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_timesheet_call.bus_unit_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  i_user_id,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_timesheet_call
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_cust_id = i_efex_cust_id
        AND timesheet_date = i_timesheet_date
        AND user_id = i_user_id;

    END IF;
    CLOSE csr_efex_timesheet_call;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_timesheet_call;

  /********************************************************************************
    NAME:       check_efex_timesheet_day
    PURPOSE:    This procedure reads through all efex timesheet day records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_timesheet_day(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_timesheet_day IS
      SELECT DISTINCT
        t1.user_id,
        t1.timesheet_date,
        NVL(t2.bus_unit_id, -1) as bus_unit_id
      FROM
        efex_timesheet_day t1,
        efex_user_sgmnt t2
      WHERE
        t1.user_id = t2.user_id(+)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_timesheet_day csr_efex_timesheet_day%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_tmesht_day, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_timesheet_day: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_timesheet_day;
    FETCH csr_efex_timesheet_day INTO rv_efex_timesheet_day;
    WHILE csr_efex_timesheet_day%FOUND LOOP

      -- PROCESS DATA
      validate_efex_timesheet_day(i_log_level + 2,
                                rv_efex_timesheet_day.user_id,
                                rv_efex_timesheet_day.timesheet_date,
                                rv_efex_timesheet_day.bus_unit_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_timesheet_day INTO rv_efex_timesheet_day;
    END LOOP;
    CLOSE csr_efex_timesheet_day;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_tmesht_day, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_timesheet_day: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_tmesht_day, 'n/a', 0, 'ods_efex_validation.check_efex_timesheet_day: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_timesheet_day;

  /*******************************************************************************
    NAME:       validate_efex_timesheet_day
    PURPOSE:    This procedure validates a efex timesheet day record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_timesheet_day(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_timesheet_day.user_id%TYPE,
    i_timesheet_date      IN efex_timesheet_day.timesheet_date%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_timesheet_day.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_timesheet_day IS
      SELECT
        user_id
      FROM
        efex_timesheet_day
      WHERE
        user_id = i_user_id
        AND timesheet_date = i_timesheet_date
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_timesheet_day csr_efex_timesheet_day%ROWTYPE;

  BEGIN
    OPEN csr_efex_timesheet_day;
    FETCH csr_efex_timesheet_day INTO rv_efex_timesheet_day;
    IF csr_efex_timesheet_day%FOUND THEN

      -- Clear the validation reason tables of this efex timesheet day.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_tmesht_day,
                                  i_bus_unit_id,
                                  i_user_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_timesheet_day.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_tmesht_day, 'n/a', i_log_level + 1,    'efex_timesheet_day user/timesheetDate : ' ||
                                                                   i_user_id  || '/' ||
                                                                   i_timesheet_date  ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_tmesht_day,
                                  'KEY: [user-timesheet_date] - Invalid or non-existant User Id - ' || rv_efex_timesheet_day.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_user_id,
                                  TO_CHAR(i_timesheet_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_timesheet_day
      SET
        valdtn_status = v_valdtn_status
      WHERE
        user_id = i_user_id
        AND timesheet_date = i_timesheet_date;

    END IF;
    CLOSE csr_efex_timesheet_day;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_timesheet_day;

  /********************************************************************************
    NAME:       check_efex_assmnt
    PURPOSE:    This procedure reads through all efex assessment records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_assmnt(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_assmnt IS
      SELECT
        assmnt_id,
        efex_cust_id,
        resp_date
      FROM
        efex_assmnt
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_assmnt csr_efex_assmnt%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_assmnt: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_assmnt;
    FETCH csr_efex_assmnt INTO rv_efex_assmnt;
    WHILE csr_efex_assmnt%FOUND LOOP

      -- PROCESS DATA
      validate_efex_assmnt(i_log_level + 2, rv_efex_assmnt.assmnt_id,rv_efex_assmnt.efex_cust_id, rv_efex_assmnt.resp_date);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_assmnt INTO rv_efex_assmnt;
    END LOOP;
    CLOSE csr_efex_assmnt;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_assmnt: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', 0, 'ods_efex_validation.check_efex_assmnt: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_assmnt;

  /*******************************************************************************
    NAME:       validate_efex_assmnt
    PURPOSE:    This procedure validates a efex assessment record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_assmnt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_assmnt_id           IN efex_assmnt.assmnt_id%TYPE,
    i_efex_cust_id        IN efex_assmnt.efex_cust_id%TYPE,
    i_resp_date           IN efex_assmnt.resp_date%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_assmnt.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_assmnt IS
      SELECT
        assmnt_id,
        efex_cust_id,
        user_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_assmnt
      WHERE
        assmnt_id = i_assmnt_id
        AND efex_cust_id = i_efex_cust_id
        AND resp_date = i_resp_date
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_assmnt csr_efex_assmnt%ROWTYPE;

  BEGIN
    OPEN csr_efex_assmnt;
    FETCH csr_efex_assmnt INTO rv_efex_assmnt;
    IF csr_efex_assmnt%FOUND THEN

      -- Clear the validation reason tables of this efex assessment.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  rv_efex_assmnt.bus_unit_id,
                                  i_assmnt_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_resp_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

     -- Assessment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_assmnt_questn
      WHERE
        assmnt_id = rv_efex_assmnt.assmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_assmnt, 'n/a', i_log_level + 1,    'efex_assmnt assmnt/cust/respDate : ' ||
                                                                   i_assmnt_id  || '/' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_resp_date   ||
                                                                   ': Invalid or non-existant Assmnt Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Assmnt Id - ' || rv_efex_assmnt.assmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt.bus_unit_id,
                                  i_assmnt_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_resp_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_assmnt.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_assmnt, 'n/a', i_log_level + 1,    'efex_assmnt assmnt/cust/respDate : ' ||
                                                                   i_assmnt_id  || '/' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_resp_date   ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Customer Id - ' || rv_efex_assmnt.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt.bus_unit_id,
                                  i_assmnt_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_resp_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_assmnt.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_assmnt, 'n/a', i_log_level + 1,    'efex_assmnt assmnt/cust/respDate : ' ||
                                                                   i_assmnt_id  || '/' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_resp_date   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'KEY: [assmnt-cust-resp_date] - Invalid or non-existant User Id - ' || rv_efex_assmnt.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt.bus_unit_id,
                                  i_assmnt_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_resp_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_assmnt.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_assmnt, 'n/a', i_log_level + 1,    'efex_assmnt assmnt/cust/respDate : ' ||
                                                                   i_assmnt_id  || '/' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_resp_date   ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Sales Territory Id - ' || rv_efex_assmnt.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt.bus_unit_id,
                                  i_assmnt_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_resp_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_assmnt.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_assmnt, 'n/a', i_log_level + 1,    'efex_assmnt assmnt/cust/respDate : ' ||
                                                                   i_assmnt_id  || '/' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_resp_date   ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Segment Id - ' || rv_efex_assmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt.bus_unit_id,
                                  i_assmnt_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_resp_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_assmnt.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_assmnt, 'n/a', i_log_level + 1,    'efex_assmnt assmnt/cust/respDate : ' ||
                                                                   i_assmnt_id  || '/' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_resp_date   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'KEY: [assmnt-cust-resp_date] - Invalid or non-existant Business Unit Id - ' || rv_efex_assmnt.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt.bus_unit_id,
                                  i_assmnt_id,
                                  i_efex_cust_id,
                                  TO_CHAR(i_resp_date, 'DD-MON-YYYY HH24:MI:SS'),
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_assmnt
      SET
        valdtn_status = v_valdtn_status
      WHERE
        assmnt_id = i_assmnt_id
        AND efex_cust_id = i_efex_cust_id
        AND resp_date = i_resp_date;

    END IF;
    CLOSE csr_efex_assmnt;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_assmnt;

/********************************************************************************
    NAME:       check_efex_assmnt_questn
    PURPOSE:    This procedure reads through all efex assessment question records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_assmnt_questn(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_assmnt_questn IS
      SELECT
        assmnt_id
      FROM
        efex_assmnt_questn
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_assmnt_questn csr_efex_assmnt_questn%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_ass_questn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_assmnt_questn: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_assmnt_questn;
    FETCH csr_efex_assmnt_questn INTO rv_efex_assmnt_questn;
    WHILE csr_efex_assmnt_questn%FOUND LOOP

      -- PROCESS DATA
      validate_efex_assmnt_questn(i_log_level + 2, rv_efex_assmnt_questn.assmnt_id);

      FETCH csr_efex_assmnt_questn INTO rv_efex_assmnt_questn;
    END LOOP;
    CLOSE csr_efex_assmnt_questn;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_ass_questn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_assmnt_questn: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_ass_questn, 'n/a', 0, 'ods_efex_validation.check_efex_assmnt_questn: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_assmnt_questn;

  /*******************************************************************************
    NAME:       validate_efex_assmnt_questn
    PURPOSE:    This procedure validates a efex assessment question record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_assmnt_questn(
    i_log_level           IN ods.log.log_level%TYPE,
    i_assmnt_id           IN efex_assmnt_questn.assmnt_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_assmnt_questn.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_assmnt_questn IS
      SELECT
        sgmnt_id,
        bus_unit_id
      FROM
        efex_assmnt_questn
      WHERE
        assmnt_id = i_assmnt_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_assmnt_questn csr_efex_assmnt_questn%ROWTYPE;

  BEGIN
    OPEN csr_efex_assmnt_questn;
    FETCH csr_efex_assmnt_questn INTO rv_efex_assmnt_questn;
    IF csr_efex_assmnt_questn%FOUND THEN

      -- Clear the validation reason tables of this efex assessment question.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_ass_questn,
                                  rv_efex_assmnt_questn.bus_unit_id,
                                  i_assmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);


      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_assmnt_questn.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_ass_questn, 'n/a', i_log_level + 1,    'efex_assmnt_questn: ' ||
                                                                          i_assmnt_id   ||
                                                                          ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_questn,
                                  'Invalid or non-existant Segment Id - ' || rv_efex_assmnt_questn.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_questn.bus_unit_id,
                                  i_assmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_assmnt_questn.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_ass_questn, 'n/a', i_log_level + 1,    'efex_assmnt_questn: ' ||
                                                                          i_assmnt_id   ||
                                                                          ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_questn,
                                  'Invalid or non-existant Business Unit Id - ' || rv_efex_assmnt_questn.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_questn.bus_unit_id,
                                  i_assmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_assmnt_questn
      SET
        valdtn_status = v_valdtn_status
      WHERE
        assmnt_id = i_assmnt_id;

    END IF;
    CLOSE csr_efex_assmnt_questn;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_assmnt_questn;


/********************************************************************************
    NAME:       check_efex_assmnt_assgnmnt
    PURPOSE:    This procedure reads through all efex assessment assignment records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.
    NOTE:       This table does not have primary key assigned

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_assmnt_assgnmnt(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_assmnt_assgnmnt IS
      SELECT
        assmnt_id,
        efex_cust_id
      FROM
        efex_assmnt_assgnmnt
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_assmnt_assgnmnt csr_efex_assmnt_assgnmnt%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_assmnt_assgnmnt: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_assmnt_assgnmnt;
    FETCH csr_efex_assmnt_assgnmnt INTO rv_efex_assmnt_assgnmnt;
    WHILE csr_efex_assmnt_assgnmnt%FOUND LOOP

      -- PROCESS DATA
      validate_efex_assmnt_assgnmnt(rv_efex_assmnt_assgnmnt.assmnt_id, rv_efex_assmnt_assgnmnt.efex_cust_id, i_log_level + 2);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_assmnt_assgnmnt INTO rv_efex_assmnt_assgnmnt;
    END LOOP;
    CLOSE csr_efex_assmnt_assgnmnt;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_assmnt_assgnmnt: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', 0, 'ods_efex_validation.check_efex_assmnt_assgnmnt: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_assmnt_assgnmnt;

  /*******************************************************************************
    NAME:       validate_efex_assmnt_assgnmnt
    PURPOSE:    This procedure validates a efex assessment assignment record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_assmnt_assgnmnt(
    i_assmnt_id           IN efex_assmnt_assgnmnt.assmnt_id%TYPE,
    i_efex_cust_id        IN efex_assmnt_assgnmnt.efex_cust_id%TYPE,
    i_log_level           IN ods.log.log_level%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_assmnt_assgnmnt.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_assmnt_assgnmnt IS
      SELECT
        assmnt_id,
        efex_cust_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id,
        cust_type_id,
        affltn_id
      FROM
        efex_assmnt_assgnmnt
      WHERE
        assmnt_id = i_assmnt_id
        AND efex_cust_id = i_efex_cust_id
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_assmnt_assgnmnt csr_efex_assmnt_assgnmnt%ROWTYPE;

  BEGIN
    OPEN csr_efex_assmnt_assgnmnt;
    FETCH csr_efex_assmnt_assgnmnt INTO rv_efex_assmnt_assgnmnt;
    IF csr_efex_assmnt_assgnmnt%FOUND THEN

      -- Clear the validation reason tables of this efex assessment assignment
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);


      -- Assessment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_assmnt_questn
      WHERE
        assmnt_id = rv_efex_assmnt_assgnmnt.assmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_ass_assgn, 'n/a', i_log_level + 1,'efex_assmnt_assgnmnt: assmnt_id/Cust ID [' ||
                                                                            rv_efex_assmnt_assgnmnt.assmnt_id || '/' ||
                                                                            rv_efex_assmnt_assgnmnt.efex_cust_id || ']' ||
                                                                          ': Invalid or non-existant Assessment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'KEY: [assmnt-cust] - Invalid or non-existant Assessment Id - ' || rv_efex_assmnt_assgnmnt.assmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_assmnt_assgnmnt.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_ass_assgn, 'n/a', i_log_level + 1,'efex_assmnt_assgnmnt: assmnt_id/Cust ID [' ||
                                                                            rv_efex_assmnt_assgnmnt.assmnt_id || '/' ||
                                                                            rv_efex_assmnt_assgnmnt.efex_cust_id || ']' ||
                                                                          ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'KEY: [assmnt-cust] - Invalid or non-existant Customer Id - ' || rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_assmnt_assgnmnt.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_ass_assgn, 'n/a', i_log_level + 1,'efex_assmnt_assgnmnt: assmnt_id/Cust ID [' ||
                                                                            rv_efex_assmnt_assgnmnt.assmnt_id || '/' ||
                                                                            rv_efex_assmnt_assgnmnt.efex_cust_id || ']' ||
                                                                          ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'KEY: [assmnt-cust] - Invalid or non-existant Sales Territory Id - ' || rv_efex_assmnt_assgnmnt.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_assmnt_assgnmnt.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_ass_assgn, 'n/a', i_log_level + 1,'efex_assmnt_assgnmnt: assmnt_id/Cust ID [' ||
                                                                            rv_efex_assmnt_assgnmnt.assmnt_id || '/' ||
                                                                            rv_efex_assmnt_assgnmnt.efex_cust_id || ']' ||
                                                                          ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'KEY: [assmnt-cust] - Invalid or non-existant Segment Id - ' || rv_efex_assmnt_assgnmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_assmnt_assgnmnt.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_ass_assgn, 'n/a', i_log_level + 1,'efex_assmnt_assgnmnt: assmnt_id/Cust ID [' ||
                                                                            rv_efex_assmnt_assgnmnt.assmnt_id || '/' ||
                                                                            rv_efex_assmnt_assgnmnt.efex_cust_id || ']' ||
                                                                          ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'KEY: [assmnt-cust] - Invalid or non-existant Business Unit Id - ' || rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      IF rv_efex_assmnt_assgnmnt.cust_type_id IS NOT NULL THEN
        v_count := 0;
        SELECT
          count(*) INTO v_count
        FROM
          efex_cust_chnl
        WHERE
          cust_type_id = rv_efex_assmnt_assgnmnt.cust_type_id
          AND valdtn_status = ods_constants.valdtn_valid;

        IF v_count <> 1 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_efex_ass_assgn, 'n/a', i_log_level + 1,'efex_assmnt_assgnmnt: assmnt_id/Cust ID [' ||
                                                                            rv_efex_assmnt_assgnmnt.assmnt_id || '/' ||
                                                                            rv_efex_assmnt_assgnmnt.efex_cust_id || ']' ||
                                                                            ': Invalid or non-existant Cust Type Id.');

          -- Add an entry into the validation reason tables.
          utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                 'KEY: [assmnt-cust] - Invalid or non-existant Cust Type Id - ' || rv_efex_assmnt_assgnmnt.cust_type_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
        END IF;
      END IF;

      IF rv_efex_assmnt_assgnmnt.affltn_id IS NOT NULL THEN
        v_count := 0;
        SELECT
          count(*) INTO v_count
        FROM
          efex_affltn
        WHERE
          affltn_id = rv_efex_assmnt_assgnmnt.affltn_id
          AND valdtn_status = ods_constants.valdtn_valid;

        IF v_count <> 1 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_efex_ass_assgn, 'n/a', i_log_level + 1,'efex_assmnt_assgnmnt: assmnt_id/Cust ID [' ||
                                                                            rv_efex_assmnt_assgnmnt.assmnt_id || '/' ||
                                                                            rv_efex_assmnt_assgnmnt.efex_cust_id || ']' ||
                                                                            ': Invalid or non-existant Affltn Id.');

          -- Add an entry into the validation reason tables.
          utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'KEY: [assmnt-cust] - Invalid or non-existant Affltn Id - ' || rv_efex_assmnt_assgnmnt.affltn_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_assmnt_assgnmnt.bus_unit_id,
                                  rv_efex_assmnt_assgnmnt.assmnt_id,
                                  rv_efex_assmnt_assgnmnt.efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
        END IF;
      END IF;

      UPDATE
        efex_assmnt_assgnmnt
      SET
        valdtn_status = v_valdtn_status
      WHERE
        assmnt_id = rv_efex_assmnt_assgnmnt.assmnt_id
        AND efex_cust_id = rv_efex_assmnt_assgnmnt.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_unchecked;

    END IF;
    CLOSE csr_efex_assmnt_assgnmnt;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_assmnt_assgnmnt;

  /********************************************************************************
    NAME:       check_efex_range_matl
    PURPOSE:    This procedure reads through all efex range material records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_range_matl(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_range_matl IS
      SELECT
        range_id,
        efex_matl_id
      FROM
        efex_range_matl
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_range_matl csr_efex_range_matl%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_range_matl: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_range_matl;
    FETCH csr_efex_range_matl INTO rv_efex_range_matl;
    WHILE csr_efex_range_matl%FOUND LOOP

      -- PROCESS DATA
      validate_efex_range_matl(i_log_level + 2,
                               rv_efex_range_matl.range_id,
                               rv_efex_range_matl.efex_matl_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_range_matl INTO rv_efex_range_matl;
    END LOOP;
    CLOSE csr_efex_range_matl;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_range_matl: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', 0, 'ods_efex_validation.check_efex_range_matl: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_range_matl;

  /*******************************************************************************
    NAME:       validate_efex_range_matl
    PURPOSE:    This procedure validates a efex range material record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_range_matl(
    i_log_level           IN ods.log.log_level%TYPE,
    i_range_id            IN efex_range_matl.range_id%TYPE,
    i_efex_matl_id        IN efex_range_matl.efex_matl_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_range_matl.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_range_matl IS
      SELECT
        range_id,
        efex_matl_id,
        rqd_flg
      FROM
        efex_range_matl
      WHERE
        range_id = i_range_id
        AND efex_matl_id = i_efex_matl_id
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_range_matl csr_efex_range_matl%ROWTYPE;

  BEGIN
    OPEN csr_efex_range_matl;
    FETCH csr_efex_range_matl INTO rv_efex_range_matl;
    IF csr_efex_range_matl%FOUND THEN

      -- Clear the validation reason tables of this efex range material.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_range_matl,
                                  -1,  -- both business
                                  i_range_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Range must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_range
      WHERE
        range_id = rv_efex_range_matl.range_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_range_matl, 'n/a', i_log_level + 1,    'efex_range_matl range/matl: ' ||
                                                                   i_range_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Range Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_range_matl,
                                  'KEY: [range-matl] - Invalid or non-existant Range Id - ' || rv_efex_range_matl.range_id,
                                  ods_constants.valdtn_severity_critical,
                                  -1,  -- both business
                                  i_range_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_matl
      WHERE
        efex_matl_id = rv_efex_range_matl.efex_matl_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count = 0 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_range_matl, 'n/a', i_log_level + 1,    'efex_range_matl range/matl : ' ||
                                                                   i_range_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Material Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_range_matl,
                                  'KEY: [range-matl] - Invalid or non-existant Material Id - ' || i_efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  -1,  -- both business
                                  i_range_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Required flag can not be null
      IF rv_efex_range_matl.rqd_flg IS NULL THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.data_type_efex_range_matl, 'n/a', i_log_level + 1,    'efex_range_matl range/matl : ' ||
                                                                 i_range_id  || '/' ||
                                                                 i_efex_matl_id   ||
                                                                 ': Required flag can not be null.');

           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_range_matl,
                                  'KEY: [range-matl] - Required flag has not been provided',
                                  ods_constants.valdtn_severity_critical,
                                  -1,  -- both business
                                  i_range_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      UPDATE
        efex_range_matl
      SET
        valdtn_status = v_valdtn_status
      WHERE
        range_id = i_range_id
        AND efex_matl_id = i_efex_matl_id;

    END IF;
    CLOSE csr_efex_range_matl;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_range_matl;


  /********************************************************************************
    NAME:       check_efex_distbn
    PURPOSE:    This procedure reads through all efex distribution records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_distbn(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_distbn IS
      SELECT
        efex_cust_id,
        efex_matl_id
      FROM
        efex_distbn
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_distbn csr_efex_distbn%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_distbn: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_distbn;
    FETCH csr_efex_distbn INTO rv_efex_distbn;
    WHILE csr_efex_distbn%FOUND LOOP

      -- PROCESS DATA
      validate_efex_distbn(i_log_level + 2,
                                rv_efex_distbn.efex_cust_id,
                                rv_efex_distbn.efex_matl_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_distbn INTO rv_efex_distbn;
    END LOOP;
    CLOSE csr_efex_distbn;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_distbn: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', 0, 'ods_efex_validation.check_efex_distbn: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_distbn;

  /*******************************************************************************
    NAME:       validate_efex_distbn
    PURPOSE:    This procedure validates a efex distribution record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_distbn(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_distbn.efex_cust_id%TYPE,
    i_efex_matl_id        IN efex_distbn.efex_matl_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_distbn.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_distbn IS
      SELECT
        efex_cust_id,
        efex_matl_id,
        user_id,
        range_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id,
        out_of_stock_flg,
        out_of_date_flg,
        rqd_flg,
        status
      FROM
        efex_distbn
      WHERE
        efex_cust_id = i_efex_cust_id
        AND efex_matl_id = i_efex_matl_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_distbn csr_efex_distbn%ROWTYPE;

  BEGIN

    OPEN csr_efex_distbn;
    FETCH csr_efex_distbn INTO rv_efex_distbn;
    IF csr_efex_distbn%FOUND THEN

      -- Clear the validation reason tables of this efex distribution.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_distbn.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Invalid or non-existant Customer Id - ' || rv_efex_distbn.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

       -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_matl
      WHERE
        efex_matl_id = rv_efex_distbn.efex_matl_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Material Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Invalid or non-existant Material Id - ' || rv_efex_distbn.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

       -- Material must exist and be valid.
      v_count := 0;
      IF rv_efex_distbn.status = 'A' THEN
         SELECT
           count(*) INTO v_count
         FROM
           efex_matl_matl_subgrp
         WHERE
           efex_matl_id = rv_efex_distbn.efex_matl_id
           AND sgmnt_id = rv_efex_distbn.sgmnt_id
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_valid;
   
         IF v_count <> 1 THEN
           v_valdtn_status := ods_constants.valdtn_invalid;
           write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                      i_efex_cust_id  || '/' ||
                                                                      i_efex_matl_id   ||
                                                                      ': Invalid or non-existant Active subgroup assigment.');
   
           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                     'KEY: [cust-matl] - Invalid or non-existant active subgroup assigned matl id - ' || rv_efex_distbn.efex_matl_id,
                                     ods_constants.valdtn_severity_critical,
                                     rv_efex_distbn.bus_unit_id,
                                     i_efex_cust_id,
                                     i_efex_matl_id,
                                     NULL,
                                     NULL,
                                     NULL,
                                     i_log_level + 1);
         END IF;
      END IF;

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_distbn.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Invalid or non-existant User Id - ' || rv_efex_distbn.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Range must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_range
      WHERE
        range_id = rv_efex_distbn.range_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Range Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Invalid or non-existant Range Id - ' || rv_efex_distbn.range_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_distbn.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Invalid or non-existant Sales Territory Id - ' || rv_efex_distbn.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_distbn.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Invalid or non-existant Segment Id - ' || rv_efex_distbn.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_distbn.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Invalid or non-existant Business Unit Id - ' || rv_efex_distbn.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Out of Stock Flag can not be null.
      IF rv_efex_distbn.out_of_stock_flg IS NULL THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Out of Stock Flg has not been provided.');

           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                     'KEY: [cust-matl] - Out of Stock Flg has not been provided.',
                                     ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Out of Date Flag can not be null.
      IF rv_efex_distbn.out_of_date_flg IS NULL THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Out of Date Flg has not been provided.');

           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'KEY: [cust-matl] - Out of Date Flg has not been provided.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Required Flag can not be null.
      IF rv_efex_distbn.rqd_flg IS NULL THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.data_type_efex_distbn, 'n/a', i_log_level + 1,    'efex_distbn cust/matl : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Required Flg has not been provided.');

           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                 'KEY: [cust-matl] - Required Flg has not been provided.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn.bus_unit_id,
                                  i_efex_cust_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_distbn
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_cust_id = i_efex_cust_id
        AND efex_matl_id = i_efex_matl_id;

    END IF;
    CLOSE csr_efex_distbn;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_distbn;

  /********************************************************************************
    NAME:       check_efex_distbn_tot
    PURPOSE:    This procedure reads through all efex distribution total records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_distbn_tot(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_distbn_tot IS
      SELECT
        efex_cust_id,
        matl_grp_id
      FROM
        efex_distbn_tot
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_distbn_tot csr_efex_distbn_tot%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_distbn_tot: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_distbn_tot;
    FETCH csr_efex_distbn_tot INTO rv_efex_distbn_tot;
    WHILE csr_efex_distbn_tot%FOUND LOOP

      -- PROCESS DATA
      validate_efex_distbn_tot(i_log_level + 2,
                                rv_efex_distbn_tot.efex_cust_id,
                                rv_efex_distbn_tot.matl_grp_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_distbn_tot INTO rv_efex_distbn_tot;
    END LOOP;
    CLOSE csr_efex_distbn_tot;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_distbn_tot: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', 0, 'ods_efex_validation.check_efex_distbn_tot: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_distbn_tot;

  /*******************************************************************************
    NAME:       validate_efex_distbn_tot
    PURPOSE:    This procedure validates a efex distribution total record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_distbn_tot(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_cust_id        IN efex_distbn_tot.efex_cust_id%TYPE,
    i_matl_grp_id         IN efex_distbn_tot.matl_grp_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_distbn_tot.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_distbn_tot IS
      SELECT
        efex_cust_id,
        matl_grp_id,
        user_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_distbn_tot
      WHERE
        efex_cust_id = i_efex_cust_id
        AND matl_grp_id = i_matl_grp_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_distbn_tot csr_efex_distbn_tot%ROWTYPE;

  BEGIN
    OPEN csr_efex_distbn_tot;
    FETCH csr_efex_distbn_tot INTO rv_efex_distbn_tot;
    IF csr_efex_distbn_tot%FOUND THEN

      -- Clear the validation reason tables of this efex distribution total.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  rv_efex_distbn_tot.bus_unit_id,
                                  i_efex_cust_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_distbn_tot.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn_tot, 'n/a', i_log_level + 1,    'efex_distbn_tot cust/matl grp : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_matl_grp_id   ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'KEY: [cust-matl_grp] - Invalid or non-existant Customer Id - ' || rv_efex_distbn_tot.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn_tot.bus_unit_id,
                                  i_efex_cust_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

       -- Material Group must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_matl_grp
      WHERE
        matl_grp_id = rv_efex_distbn_tot.matl_grp_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn_tot, 'n/a', i_log_level + 1,    'efex_distbn_tot cust/matl grp : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_matl_grp_id   ||
                                                                   ': Invalid or non-existant Material Group Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'KEY: [cust-matl_grp] - Invalid or non-existant Material Group Id - ' || rv_efex_distbn_tot.matl_grp_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn_tot.bus_unit_id,
                                  i_efex_cust_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_distbn_tot.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn_tot, 'n/a', i_log_level + 1,    'efex_distbn_tot cust/matl grp : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_matl_grp_id   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'KEY: [cust-matl_grp] - Invalid or non-existant User Id - ' || rv_efex_distbn_tot.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn_tot.bus_unit_id,
                                  i_efex_cust_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_distbn_tot.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn_tot, 'n/a', i_log_level + 1,    'efex_distbn_tot cust/matl grp : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_matl_grp_id   ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'KEY: [cust-matl_grp] - Invalid or non-existant Sales Territory Id - ' || rv_efex_distbn_tot.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn_tot.bus_unit_id,
                                  i_efex_cust_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_distbn_tot.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn_tot, 'n/a', i_log_level + 1,    'efex_distbn_tot cust/matl grp : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_matl_grp_id   ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'KEY: [cust-matl_grp] - Invalid or non-existant Segment Id - ' || rv_efex_distbn_tot.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn_tot.bus_unit_id,
                                  i_efex_cust_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_distbn_tot.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_distbn_tot, 'n/a', i_log_level + 1,    'efex_distbn_tot cust/matl grp : ' ||
                                                                   i_efex_cust_id  || '/' ||
                                                                   i_matl_grp_id   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'KEY: [cust-matl_grp] - Invalid or non-existant Business Unit Id - ' || rv_efex_distbn_tot.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_distbn_tot.bus_unit_id,
                                  i_efex_cust_id,
                                  i_matl_grp_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_distbn_tot
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_cust_id = i_efex_cust_id
        AND matl_grp_id = i_matl_grp_id;

    END IF;
    CLOSE csr_efex_distbn_tot;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_distbn_tot;

  /********************************************************************************
    NAME:       check_efex_order
    PURPOSE:    This procedure reads through all efex order records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_order(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_order IS
      SELECT
        efex_order_id
      FROM
        efex_order
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_order csr_efex_order%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_order: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_order;
    FETCH csr_efex_order INTO rv_efex_order;
    WHILE csr_efex_order%FOUND LOOP

      -- PROCESS DATA
      validate_efex_order(i_log_level + 2,rv_efex_order.efex_order_id);

      FETCH csr_efex_order INTO rv_efex_order;
    END LOOP;
    CLOSE csr_efex_order;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_order: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_order, 'n/a', 0, 'ods_efex_validation.check_efex_order: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_order;

  /*******************************************************************************
    NAME:       validate_efex_order
    PURPOSE:    This procedure validates a efex order record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_order(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_order_id       IN efex_order.efex_order_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_order.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_order IS
      SELECT
        efex_cust_id,
        user_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_order
      WHERE
        efex_order_id = i_efex_order_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_order csr_efex_order%ROWTYPE;

  BEGIN
    OPEN csr_efex_order;
    FETCH csr_efex_order INTO rv_efex_order;
    IF csr_efex_order%FOUND THEN

      -- Clear the validation reason tables of this efex order
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_order,
                                  rv_efex_order.bus_unit_id,
                                  i_efex_order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_order.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_order, 'n/a', i_log_level + 1,    'efex_order: ' ||
                                                                   i_efex_order_id  ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'Invalid or non-existant Customer Id - ' || rv_efex_order.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_order.bus_unit_id,
                                  i_efex_order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_order.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_order, 'n/a', i_log_level + 1,    'efex_order: ' ||
                                                                   i_efex_order_id  ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'Invalid or non-existant User Id - ' || rv_efex_order.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_order.bus_unit_id,
                                  i_efex_order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_order.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_order, 'n/a', i_log_level + 1,    'efex_order: ' ||
                                                                   i_efex_order_id  ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'Invalid or non-existant Sales Territory Id - ' || rv_efex_order.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_order.bus_unit_id,
                                  i_efex_order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_order.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_order, 'n/a', i_log_level + 1,    'efex_order: ' ||
                                                                   i_efex_order_id  ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'Invalid or non-existant Segment Id - ' || rv_efex_order.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_order.bus_unit_id,
                                  i_efex_order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_order.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_order, 'n/a', i_log_level + 1,    'efex_order: ' ||
                                                                   i_efex_order_id  ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'Invalid or non-existant Business Unit Id - ' || rv_efex_order.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_order.bus_unit_id,
                                  i_efex_order_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_order
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_order_id = i_efex_order_id;

    END IF;
    CLOSE csr_efex_order;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_order;

  /********************************************************************************
    NAME:       check_efex_order_matl
    PURPOSE:    This procedure reads through all efex order material records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_order_matl(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_order_matl IS
      SELECT
        t1.efex_order_id,
        t1.efex_matl_id,
        NVL(t2.bus_unit_id, -1) as bus_unit_id
      FROM
        efex_order_matl t1,
        efex_order t2
      WHERE
        t1.efex_order_id = t2.efex_order_id (+) 
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_order_matl csr_efex_order_matl%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_order_matl: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_order_matl;
    FETCH csr_efex_order_matl INTO rv_efex_order_matl;
    WHILE csr_efex_order_matl%FOUND LOOP

      -- PROCESS DATA
      validate_efex_order_matl(i_log_level + 2,
                               rv_efex_order_matl.efex_order_id,
                               rv_efex_order_matl.efex_matl_id,
                               rv_efex_order_matl.bus_unit_id);
      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_order_matl INTO rv_efex_order_matl;
    END LOOP;
    CLOSE csr_efex_order_matl;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_order_matl: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', 0, 'ods_efex_validation.check_efex_order_matl: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_order_matl;

  /*******************************************************************************
    NAME:       validate_efex_order_matl
    PURPOSE:    This procedure validates a efex order material record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_order_matl(
    i_log_level           IN ods.log.log_level%TYPE,
    i_efex_order_id       IN efex_order_matl.efex_order_id%TYPE,
    i_efex_matl_id        IN efex_order_matl.efex_matl_id%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_order_matl.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_order_matl IS
      SELECT
        efex_order_id,
        efex_matl_id,
        matl_distbr_id
      FROM
        efex_order_matl
      WHERE
        efex_order_id = i_efex_order_id
        AND efex_matl_id = i_efex_matl_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_order_matl csr_efex_order_matl%ROWTYPE;

  BEGIN
    OPEN csr_efex_order_matl;
    FETCH csr_efex_order_matl INTO rv_efex_order_matl;
    IF csr_efex_order_matl%FOUND THEN

      -- Clear the validation reason tables of this efex order material.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_order_matl,
                                  i_bus_unit_id,
                                  i_efex_order_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Order must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_order
      WHERE
        efex_order_id = rv_efex_order_matl.efex_order_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_order_matl, 'n/a', i_log_level + 1,    'efex_order_matl order/matl : ' ||
                                                                   i_efex_order_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Order Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order_matl,
                                  'KEY: [order-matl] - Invalid or non-existant Order Id - ' || rv_efex_order_matl.efex_order_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_efex_order_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_matl
      WHERE
        efex_matl_id = rv_efex_order_matl.efex_matl_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_order_matl, 'n/a', i_log_level + 1,    'efex_order_matl order/matl : ' ||
                                                                   i_efex_order_id  || '/' ||
                                                                   i_efex_matl_id   ||
                                                                   ': Invalid or non-existant Material Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order_matl,
                                  'KEY: [order-matl] - Invalid or non-existant Material Id - ' || rv_efex_order_matl.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_efex_order_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Distributor must exist and be valid.
      IF rv_efex_order_matl.matl_distbr_id IS NOT NULL THEN
        v_count := 0;
        SELECT
          count(*) INTO v_count
        FROM
          efex_cust
        WHERE
          efex_cust_id = rv_efex_order_matl.matl_distbr_id
          AND valdtn_status = ods_constants.valdtn_valid;

        IF v_count <> 1 THEN
          v_valdtn_status := ods_constants.valdtn_invalid;
          write_log(ods_constants.data_type_efex_order_matl, 'n/a', i_log_level + 1,    'efex_order_matl order/matl : ' ||
                                                                     i_efex_order_id  || '/' ||
                                                                     i_efex_matl_id   ||
                                                                     ': Invalid or non-existant Matl Distbr Id.');

          -- Add an entry into the validation reason tables.
          utils.add_validation_reason(ods_constants.valdtn_type_efex_order_matl,
                                  'KEY: [order-matl] - Invalid or non-existant Matl Distbr Id - ' || rv_efex_order_matl.matl_distbr_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_efex_order_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
        END IF;
      END IF;

      UPDATE
        efex_order_matl
      SET
        valdtn_status = v_valdtn_status
      WHERE
        efex_order_id = i_efex_order_id
        AND efex_matl_id = i_efex_matl_id;

    END IF;
    CLOSE csr_efex_order_matl;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_order_matl;

  /********************************************************************************
    NAME:       check_efex_pmt
    PURPOSE:    This procedure reads through all efex payment records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_pmt(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_pmt IS
      SELECT
        pmt_id,
        efex_cust_id
      FROM
        efex_pmt
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_pmt csr_efex_pmt%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_pmt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_pmt: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_pmt;
    FETCH csr_efex_pmt INTO rv_efex_pmt;
    WHILE csr_efex_pmt%FOUND LOOP

      -- PROCESS DATA
      validate_efex_pmt(i_log_level + 2,
                        rv_efex_pmt.pmt_id,
                        rv_efex_pmt.efex_cust_id);

      FETCH csr_efex_pmt INTO rv_efex_pmt;
    END LOOP;
    CLOSE csr_efex_pmt;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_pmt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_pmt: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_pmt, 'n/a', 0, 'ods_efex_validation.check_efex_pmt: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_pmt;

  /*******************************************************************************
    NAME:       validate_efex_pmt
    PURPOSE:    This procedure validates a efex payment record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_pmt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_pmt_id              IN efex_pmt.pmt_id%TYPE,
    i_efex_cust_id        IN efex_pmt.efex_cust_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_pmt.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_pmt IS
      SELECT
        efex_cust_id,
        user_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_pmt
      WHERE
        pmt_id = i_pmt_id
        AND efex_cust_id = i_efex_cust_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_pmt csr_efex_pmt%ROWTYPE;

  BEGIN
    OPEN csr_efex_pmt;
    FETCH csr_efex_pmt INTO rv_efex_pmt;
    IF csr_efex_pmt%FOUND THEN

      -- Clear the validation reason tables of this efex payment.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_pmt,
                                  rv_efex_pmt.bus_unit_id,
                                  i_pmt_id,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_pmt.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_pmt, 'n/a', i_log_level + 1,    'efex_pmt: pmt/cust : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt,
                                  'KEY: [pmt-cust] - Invalid or non-existant Customer Id - ' || rv_efex_pmt.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_pmt.bus_unit_id,
                                  i_pmt_id,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_pmt.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_pmt, 'n/a', i_log_level + 1,    'efex_pmt: pmt/cust : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt,
                                  'KEY: [pmt-cust] - Invalid or non-existant User Id - ' || rv_efex_pmt.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_pmt.bus_unit_id,
                                  i_pmt_id,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_pmt.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_pmt, 'n/a', i_log_level + 1,    'efex_pmt: pmt/cust : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt,
                                  'KEY: [pmt-cust] - Invalid or non-existant Sales Territory Id - ' || rv_efex_pmt.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_pmt.bus_unit_id,
                                  i_pmt_id,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_pmt.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_pmt, 'n/a', i_log_level + 1,    'efex_pmt: pmt/cust : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt,
                                  'KEY: [pmt-cust] - Invalid or non-existant Segment Id - ' || rv_efex_pmt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_pmt.bus_unit_id,
                                  i_pmt_id,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_pmt.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_pmt, 'n/a', i_log_level + 1,    'efex_pmt pmt/cust : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_efex_cust_id   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt,
                                  'KEY: [pmt-cust] - Invalid or non-existant Business Unit Id - ' || rv_efex_pmt.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_pmt.bus_unit_id,
                                  i_pmt_id,
                                  i_efex_cust_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_pmt
      SET
        valdtn_status = v_valdtn_status
      WHERE
        pmt_id = i_pmt_id
        AND efex_cust_id = i_efex_cust_id;

    END IF;
    CLOSE csr_efex_pmt;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_pmt;

  /********************************************************************************
    NAME:       check_efex_pmt_deal
    PURPOSE:    This procedure reads through all efex payment deal records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records. T

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_pmt_deal(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_pmt_deal IS
      SELECT
        t1.pmt_id,
        t1.seq_num,
        NVL(t2.bus_unit_id,-1) bus_unit_id
      FROM
        efex_pmt_deal t1,
        efex_pmt t2
      WHERE
        t1.pmt_id = t2.pmt_id (+)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_pmt_deal csr_efex_pmt_deal%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_pmt_deal, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_pmt_deal: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_pmt_deal;
    FETCH csr_efex_pmt_deal INTO rv_efex_pmt_deal;
    WHILE csr_efex_pmt_deal%FOUND LOOP

      -- PROCESS DATA
      validate_efex_pmt_deal(i_log_level + 2,
                        rv_efex_pmt_deal.pmt_id,
                        rv_efex_pmt_deal.seq_num,
                        rv_efex_pmt_deal.bus_unit_id);

      FETCH csr_efex_pmt_deal INTO rv_efex_pmt_deal;
    END LOOP;
    CLOSE csr_efex_pmt_deal;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_pmt_deal, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_pmt_deal: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_pmt_deal, 'n/a', 0, 'ods_efex_validation.check_efex_pmt_deal: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_pmt_deal;

  /*******************************************************************************
    NAME:       validate_efex_pmt_deal
    PURPOSE:    This procedure validates a efex payment deal record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_pmt_deal(
    i_log_level           IN ods.log.log_level%TYPE,
    i_pmt_id              IN efex_pmt_deal.pmt_id%TYPE,
    i_seq_num             IN efex_pmt_deal.seq_num%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_pmt_deal.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_pmt_deal IS
      SELECT
        pmt_id,
        efex_order_id
      FROM
        efex_pmt_deal
      WHERE
        pmt_id = i_pmt_id
        AND seq_num = i_seq_num
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_pmt_deal csr_efex_pmt_deal%ROWTYPE;

  BEGIN
    OPEN csr_efex_pmt_deal;
    FETCH csr_efex_pmt_deal INTO rv_efex_pmt_deal;
    IF csr_efex_pmt_deal%FOUND THEN

      -- Clear the validation reason tables of this efex payment deal.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_pmt_deal,
                                  i_bus_unit_id,
                                  i_pmt_id,
                                  i_seq_num,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Payment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_pmt
      WHERE
        pmt_id = rv_efex_pmt_deal.pmt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_pmt_deal, 'n/a', i_log_level + 1,    'efex_pmt_deal pmt/seq : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_seq_num   ||
                                                                   ': Invalid or non-existant Payment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt_deal,
                                  'KEY: [pmt-seq_num] - Invalid or non-existant Payment Id - ' || rv_efex_pmt_deal.pmt_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_pmt_id,
                                  i_seq_num,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Order id must exist and be valid.
      IF rv_efex_pmt_deal.efex_order_id IS NOT NULL THEN
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_order
         WHERE
           efex_order_id = rv_efex_pmt_deal.efex_order_id
           AND valdtn_status = ods_constants.valdtn_valid;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.data_type_efex_pmt_deal, 'n/a', i_log_level + 1,    'efex_pmt_deal pmt/seq : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_seq_num   ||
                                                                   ': Invalid or non-existant Order Id.');

            -- Add an entry into the validation reason tables.
            utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt_deal,
                                  'KEY: [pmt-seq_num] - Invalid or non-existant order Id - ' || rv_efex_pmt_deal.efex_order_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_pmt_id,
                                  i_seq_num,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
         END IF;
      END IF;

      UPDATE
        efex_pmt_deal
      SET
        valdtn_status = v_valdtn_status
      WHERE
        pmt_id = i_pmt_id
        AND seq_num = i_seq_num;

    END IF;
    CLOSE csr_efex_pmt_deal;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_pmt_deal;

  /********************************************************************************
    NAME:       check_efex_pmt_rtn
    PURPOSE:    This procedure reads through all efex payment return records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_pmt_rtn(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_pmt_rtn IS
      SELECT
        t1.pmt_id,
        t1.seq_num,
        NVL(t2.bus_unit_id,-1) as bus_unit_id
      FROM
        efex_pmt_rtn t1,
        efex_pmt t2
      WHERE
        t1.pmt_id = t2.pmt_id (+)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_pmt_rtn csr_efex_pmt_rtn%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_pmt_rtn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_pmt_rtn: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_pmt_rtn;
    FETCH csr_efex_pmt_rtn INTO rv_efex_pmt_rtn;
    WHILE csr_efex_pmt_rtn%FOUND LOOP

      -- PROCESS DATA
      validate_efex_pmt_rtn(i_log_level + 2,
                        rv_efex_pmt_rtn.pmt_id,
                        rv_efex_pmt_rtn.seq_num,
                        rv_efex_pmt_rtn.bus_unit_id);

      FETCH csr_efex_pmt_rtn INTO rv_efex_pmt_rtn;
    END LOOP;
    CLOSE csr_efex_pmt_rtn;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_pmt_rtn, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_pmt_rtn: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_pmt_rtn, 'n/a', 0, 'ods_efex_validation.check_efex_pmt_rtn: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_pmt_rtn;

  /*******************************************************************************
    NAME:       validate_efex_pmt_rtn
    PURPOSE:    This procedure validates a efex payment return record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_pmt_rtn(
    i_log_level           IN ods.log.log_level%TYPE,
    i_pmt_id              IN efex_pmt_rtn.pmt_id%TYPE,
    i_seq_num             IN efex_pmt_rtn.seq_num%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_pmt_rtn.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_pmt_rtn IS
      SELECT
        pmt_id,
        efex_matl_id
      FROM
        efex_pmt_rtn
      WHERE
        pmt_id = i_pmt_id
        AND seq_num = i_seq_num
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_pmt_rtn csr_efex_pmt_rtn%ROWTYPE;

  BEGIN
    OPEN csr_efex_pmt_rtn;
    FETCH csr_efex_pmt_rtn INTO rv_efex_pmt_rtn;
    IF csr_efex_pmt_rtn%FOUND THEN

      -- Clear the validation reason tables of this efex payment return.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_pmt_rtn,
                                  i_bus_unit_id,
                                  i_pmt_id,
                                  i_seq_num,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- Payment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_pmt
      WHERE
        pmt_id = rv_efex_pmt_rtn.pmt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_pmt_rtn, 'n/a', i_log_level + 1,    'efex_pmt_rtn pmt/seq : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_seq_num   ||
                                                                   ': Invalid or non-existant Payment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt_rtn,
                                  'KEY: [pmt-seq_num] - Invalid or non-existant Payment Id - ' || rv_efex_pmt_rtn.pmt_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_pmt_id,
                                  i_seq_num,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      -- Material must exist and be valid.
      IF rv_efex_pmt_rtn.efex_matl_id IS NOT NULL THEN
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_matl
         WHERE
           efex_matl_id = rv_efex_pmt_rtn.efex_matl_id
           AND valdtn_status = ods_constants.valdtn_valid;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.data_type_efex_pmt_rtn, 'n/a', i_log_level + 1,    'efex_pmt_rtn pmt/seq : ' ||
                                                                   i_pmt_id  || '/' ||
                                                                   i_seq_num   ||
                                                                   ': Invalid or non-existant Material Id.');

           -- Add an entry into the validation reason tables.
            utils.add_validation_reason(ods_constants.valdtn_type_efex_pmt_rtn,
                                  'KEY: [pmt-seq_num] - Invalid or non-existant Material Id - ' || rv_efex_pmt_rtn.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_pmt_id,
                                  i_seq_num,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
         END IF;
      END IF;

      UPDATE
        efex_pmt_rtn
      SET
        valdtn_status = v_valdtn_status
      WHERE
        pmt_id = i_pmt_id
        AND seq_num = i_seq_num;

    END IF;
    CLOSE csr_efex_pmt_rtn;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_pmt_rtn;

/********************************************************************************
    NAME:       check_efex_mrq
    PURPOSE:    This procedure reads through all efex mrq records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_mrq(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_mrq IS
      SELECT
        mrq_id
      FROM
        efex_mrq
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_mrq csr_efex_mrq%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_mrq, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_mrq: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_mrq;
    FETCH csr_efex_mrq INTO rv_efex_mrq;
    WHILE csr_efex_mrq%FOUND LOOP

      -- PROCESS DATA
      validate_efex_mrq(i_log_level + 2, rv_efex_mrq.mrq_id);

      FETCH csr_efex_mrq INTO rv_efex_mrq;
    END LOOP;
    CLOSE csr_efex_mrq;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_mrq, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_mrq: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_mrq, 'n/a', 0, 'ods_efex_validation.check_efex_mrq: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_mrq;

  /*******************************************************************************
    NAME:       validate_efex_mrq
    PURPOSE:    This procedure validates a efex mrq record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_mrq(
    i_log_level           IN ods.log.log_level%TYPE,
    i_mrq_id              IN efex_mrq.mrq_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_mrq.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_mrq IS
      SELECT
        user_id,
        efex_cust_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id,
        completed_flg
      FROM
        efex_mrq
      WHERE
        mrq_id = i_mrq_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_mrq csr_efex_mrq%ROWTYPE;

  BEGIN
    OPEN csr_efex_mrq;
    FETCH csr_efex_mrq INTO rv_efex_mrq;
    IF csr_efex_mrq%FOUND THEN

      -- Clear the validation reason tables of this efex MRQ.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_mrq,
                                  rv_efex_mrq.bus_unit_id,
                                  i_mrq_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);


      -- User must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_mrq.user_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_mrq, 'n/a', i_log_level + 1,    'efex_mrq: ' ||
                                                                          i_mrq_id   ||
                                                                          ': Invalid or non-existant User Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq,
                                  'Invalid or non-existant User Id - ' || rv_efex_mrq.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_mrq.bus_unit_id,
                                  i_mrq_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Customer must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_mrq.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_mrq, 'n/a', i_log_level + 1,    'efex_mrq: ' ||
                                                                          i_mrq_id   ||
                                                                          ': Invalid or non-existant Customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq,
                                  'Invalid or non-existant Customer Id - ' || rv_efex_mrq.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_mrq.bus_unit_id,
                                  i_mrq_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_mrq.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_mrq, 'n/a', i_log_level + 1,    'efex_mrq: ' ||
                                                                          i_mrq_id   ||
                                                                          ': Invalid or non-existant Sales Territory Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq,
                                  'Invalid or non-existant Sales Territory Id - ' || rv_efex_mrq.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_mrq.bus_unit_id,
                                  i_mrq_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Segment must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_mrq.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_mrq, 'n/a', i_log_level + 1,    'efex_mrq: ' ||
                                                                          i_mrq_id   ||
                                                                          ': Invalid or non-existant Segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq,
                                  'Invalid or non-existant Segment Id - ' || rv_efex_mrq.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_mrq.bus_unit_id,
                                  i_mrq_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_mrq.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_mrq, 'n/a', i_log_level + 1,    'efex_mrq: ' ||
                                                                          i_mrq_id   ||
                                                                          ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq,
                                  'Invalid or non-existant Business Unit Id - ' || rv_efex_mrq.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_mrq.bus_unit_id,
                                  i_mrq_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Completed Flag can not be null
      IF rv_efex_mrq.completed_flg IS NULL THEN
         v_valdtn_status := ods_constants.valdtn_invalid;
         write_log(ods_constants.data_type_efex_mrq, 'n/a', i_log_level + 1,    'efex_mrq: ' ||
                                                                    i_mrq_id   ||
                                                                   ': Completed Flg has not been provided.');

           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq,
                                  'Completed Flg has not been provided.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_mrq.bus_unit_id,
                                  i_mrq_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_mrq
      SET
        valdtn_status = v_valdtn_status
      WHERE
        mrq_id = i_mrq_id;

    END IF;
    CLOSE csr_efex_mrq;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_mrq;

/********************************************************************************
    NAME:       check_efex_mrq_task
    PURPOSE:    This procedure reads through all efex mrq task records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_mrq_task(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_mrq_task IS
      SELECT
        mrq_task_id,
        NVL(t2.bus_unit_id, 2) as bus_unit_id
      FROM
        efex_mrq_task t1,
        efex_mrq t2
      WHERE
        t1.mrq_id = t2.mrq_id(+)
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_mrq_task csr_efex_mrq_task%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_mrq_task, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_mrq_task: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_mrq_task;
    FETCH csr_efex_mrq_task INTO rv_efex_mrq_task;
    WHILE csr_efex_mrq_task%FOUND LOOP

      -- PROCESS DATA
      validate_efex_mrq_task(i_log_level + 2, rv_efex_mrq_task.mrq_task_id, rv_efex_mrq_task.bus_unit_id);

      FETCH csr_efex_mrq_task INTO rv_efex_mrq_task;
    END LOOP;
    CLOSE csr_efex_mrq_task;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_mrq_task, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_mrq_task: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_mrq_task, 'n/a', 0, 'ods_efex_validation.check_efex_mrq_task: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_mrq_task;

  /*******************************************************************************
    NAME:       validate_efex_mrq_task
    PURPOSE:    This procedure validates a efex mrq task record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_mrq_task(
    i_log_level           IN ods.log.log_level%TYPE,
    i_mrq_task_id         IN efex_mrq_task.mrq_task_id%TYPE,
    i_bus_unit_id         IN efex_bus_unit.bus_unit_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_mrq_task.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_mrq_task IS
      SELECT
        mrq_id
      FROM
        efex_mrq_task
      WHERE
        mrq_task_id = i_mrq_task_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_mrq_task csr_efex_mrq_task%ROWTYPE;

  BEGIN
    OPEN csr_efex_mrq_task;
    FETCH csr_efex_mrq_task INTO rv_efex_mrq_task;
    IF csr_efex_mrq_task%FOUND THEN

      -- Clear the validation reason tables of this efex mrq task.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_mrq_task,
                                  i_bus_unit_id,
                                  i_mrq_task_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);


      -- MRQ must exist and be valid.
      IF rv_efex_mrq_task.mrq_id IS NOT NULL THEN
         v_count := 0;
         SELECT
           count(*) INTO v_count
         FROM
           efex_mrq
         WHERE
           mrq_id = rv_efex_mrq_task.mrq_id
           AND valdtn_status = ods_constants.valdtn_valid;

         IF v_count <> 1 THEN
            v_valdtn_status := ods_constants.valdtn_invalid;
            write_log(ods_constants.data_type_efex_mrq_task, 'n/a', i_log_level + 1,    'efex_mrq_task: ' ||
                                                                          i_mrq_task_id   ||
                                                                          ': Invalid or non-existant MRQ Id.');

          -- Add an entry into the validation reason tables.
            utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq_task,
                                  'Invalid or non-existant MRQ Id - ' || rv_efex_mrq_task.mrq_id,
                                  ods_constants.valdtn_severity_critical,
                                  i_bus_unit_id,
                                  i_mrq_task_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
         END IF;
      END IF;

      UPDATE
        efex_mrq_task
      SET
        valdtn_status = v_valdtn_status
      WHERE
        mrq_task_id = i_mrq_task_id;

    END IF;
    CLOSE csr_efex_mrq_task;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_mrq_task;

  /********************************************************************************
    NAME:       check_efex_mrq_task_matl
    PURPOSE:    This procedure reads through all efex mrq task material records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_mrq_task_matl(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_mrq_task_matl IS
      SELECT
        mrq_task_id,
        efex_matl_id
      FROM
        efex_mrq_task_matl
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_mrq_task_matl csr_efex_mrq_task_matl%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_mrq_task_matl: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_mrq_task_matl;
    FETCH csr_efex_mrq_task_matl INTO rv_efex_mrq_task_matl;
    WHILE csr_efex_mrq_task_matl%FOUND LOOP

      -- PROCESS DATA
      validate_efex_mrq_task_matl(i_log_level + 2,
                        rv_efex_mrq_task_matl.mrq_task_id,
                        rv_efex_mrq_task_matl.efex_matl_id);

      -- Commit when required.
      v_record_count := v_record_count + 1;
      IF v_record_count >= c_commit_count THEN
        COMMIT;
        v_record_count := 0;
      END IF;

      FETCH csr_efex_mrq_task_matl INTO rv_efex_mrq_task_matl;
    END LOOP;
    CLOSE csr_efex_mrq_task_matl;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_mrq_task_matl: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', 0, 'ods_efex_validation.check_efex_mrq_task_matl: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_mrq_task_matl;

  /*******************************************************************************
    NAME:       validate_efex_mrq_task_matl
    PURPOSE:    This procedure validates a efex mrq task material record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_mrq_task_matl(
    i_log_level           IN ods.log.log_level%TYPE,
    i_mrq_task_id         IN efex_mrq_task_matl.mrq_task_id%TYPE,
    i_efex_matl_id        IN efex_mrq_task_matl.efex_matl_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_mrq_task_matl.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_mrq_task_matl IS
      SELECT
        mrq_task_id,
        efex_matl_id
      FROM
        efex_mrq_task_matl
      WHERE
        mrq_task_id = i_mrq_task_id
        AND efex_matl_id = i_efex_matl_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_mrq_task_matl csr_efex_mrq_task_matl%ROWTYPE;

  BEGIN
    OPEN csr_efex_mrq_task_matl;
    FETCH csr_efex_mrq_task_matl INTO rv_efex_mrq_task_matl;
    IF csr_efex_mrq_task_matl%FOUND THEN

      -- Clear the validation reason tables of this efex mrq task material.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_mrq_task_matl,
                                  2, -- default to snack business 
                                  i_mrq_task_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

       -- MRQ Task must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_mrq_task
      WHERE
        mrq_task_id = rv_efex_mrq_task_matl.mrq_task_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_mrq_task_matl, 'n/a', i_log_level + 1,    'efex_mrq_task_matl task/matl : ' ||
                                                                   i_mrq_task_id  || '/' ||
                                                                   i_efex_matl_id ||
                                                                   ': Invalid or non-existant MRQ Task Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq_task_matl,
                                  'KEY: [mrq_task-matl] - Invalid or non-existant MRQ Task Id - ' || rv_efex_mrq_task_matl.mrq_task_id,
                                  ods_constants.valdtn_severity_critical,
                                  2, -- default to snack business 
                                  i_mrq_task_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Material must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_matl
      WHERE
        efex_matl_id = rv_efex_mrq_task_matl.efex_matl_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_mrq_task_matl, 'n/a', i_log_level + 1,    'efex_mrq_task_matl task/matl : ' ||
                                                                   i_mrq_task_id  || '/' ||
                                                                   i_efex_matl_id ||
                                                                   ': Invalid or non-existant Material Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq_task_matl,
                                  'KEY: [mrq_task-matl] - Invalid or non-existant Material Id - ' || rv_efex_mrq_task_matl.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  2, -- default to snack business 
                                  i_mrq_task_id,
                                  i_efex_matl_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_mrq_task_matl
      SET
        valdtn_status = v_valdtn_status
      WHERE
        mrq_task_id = i_mrq_task_id
        AND efex_matl_id = i_efex_matl_id;

    END IF;
    CLOSE csr_efex_mrq_task_matl;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_mrq_task_matl;

/********************************************************************************
    NAME:       check_efex_target
    PURPOSE:    This procedure reads through all efex target records with
                a validation status of "UNCHECKED", and calls a routine to validate
                the records.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
  PROCEDURE check_efex_target(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_target IS
      SELECT DISTINCT
        t1.sales_terr_id,
        t1.target_id,
        t1.mars_period
      FROM
        efex_target t1
      WHERE
        t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_target csr_efex_target%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_target, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_target: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_target;
    FETCH csr_efex_target INTO rv_efex_target;
    WHILE csr_efex_target%FOUND LOOP

      -- PROCESS DATA
      validate_efex_target(i_log_level + 2,
                        rv_efex_target.sales_terr_id,
                        rv_efex_target.target_id,
                        rv_efex_target.mars_period);

      FETCH csr_efex_target INTO rv_efex_target;
    END LOOP;
    CLOSE csr_efex_target;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_target, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_target: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_target, 'n/a', 0, 'ods_efex_validation.check_efex_target: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_target;

  /*******************************************************************************
    NAME:       validate_efex_target
    PURPOSE:    This procedure validates a efex target record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_target(
    i_log_level           IN ods.log.log_level%TYPE,
    i_sales_terr_id       IN efex_target.sales_terr_id%TYPE,
    i_target_id           IN efex_target.target_id%TYPE,
    i_mars_period         IN efex_target.mars_period%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_target.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_target IS
      SELECT
        sales_terr_id,
        bus_unit_id
      FROM
        efex_target
      WHERE
        sales_terr_id = i_sales_terr_id
        AND target_id = i_target_id
        AND mars_period = i_mars_period
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_target csr_efex_target%ROWTYPE;

  BEGIN
    OPEN csr_efex_target;
    FETCH csr_efex_target INTO rv_efex_target;
    IF csr_efex_target%FOUND THEN

      -- Clear the validation reason tables of this efex target.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_target,
                                  rv_efex_target.bus_unit_id,
                                  i_sales_terr_id,
                                  i_target_id,
                                  i_mars_period,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

      -- Sales territory must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_target.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_target, 'n/a', i_log_level + 1,    'efex_target sales_terr/target/period : ' ||
                                                                   i_sales_terr_id  || '/' ||
                                                                   i_target_id  || '/' ||
                                                                   i_mars_period   ||
                                                                   ': Invalid or non-existant Sales Terr Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_target,
                                  'KEY: [sales_terr-target-mars_period] - Invalid or non-existant Sales Terr Id - ' || rv_efex_target.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_target.bus_unit_id,
                                  i_sales_terr_id,
                                  i_target_id,
                                  i_mars_period,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Business Unit must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_target.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_target, 'n/a', i_log_level + 1,    'efex_target sales_terr/target/period : ' ||
                                                                   i_sales_terr_id  || '/' ||
                                                                   i_target_id  || '/' ||
                                                                   i_mars_period   ||
                                                                   ': Invalid or non-existant Business Unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_target,
                                  'KEY: [user-target-mars_period] - Invalid or non-existant Business Unit Id - ' || rv_efex_target.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_target.bus_unit_id,
                                  i_sales_terr_id,
                                  i_target_id,
                                  i_mars_period,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      UPDATE
        efex_target
      SET
        valdtn_status = v_valdtn_status
      WHERE
        sales_terr_id = i_sales_terr_id
        AND target_id = i_target_id
        AND mars_period = i_mars_period;

    END IF;
    CLOSE csr_efex_target;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_target;

PROCEDURE check_cust_distributors(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_rec_count  PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    -- customer distributor also recorded in efex_cust table,
    -- we need to validation this at the end of the efex_cust validation, in case the customer distributor record
    -- hasn't been validated at the time of validating the customer
    -- customer with invalid distributor
    CURSOR csr_distbr IS
      SELECT
        efex_cust_id, distbr_id, NVL(bus_unit_id, -1) as bus_unit_id
      FROM
        efex_cust t1,
        efex_sales_terr t3
      WHERE t1.sales_terr_id = t3.sales_terr_id (+)
        AND NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.distbr_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND distbr_id IS NOT NULL;
    rv_distbr csr_distbr%ROWTYPE;

    CURSOR csr_counter IS
      SELECT
        COUNT(*) AS rec_count
      FROM
        efex_cust t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.distbr_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND distbr_id IS NOT NULL;

  BEGIN
    -- check the Countries in the address detail records.
    write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1, 'Check for invalid customer distributors.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

        OPEN csr_distbr;
        LOOP
          FETCH csr_distbr INTO rv_distbr;
          EXIT WHEN csr_distbr%NOTFOUND;
            -- Clear the validation reason tables of efex_cust
            utils.clear_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  rv_distbr.bus_unit_id,
                                  c_cust_ref,
                                  rv_distbr.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

              write_log(ods_constants.data_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid distbr_id: ' || rv_distbr.distbr_id || ' found for efex_cust_id : '|| rv_distbr.efex_cust_id);

              -- Add an entry into the validation reason tables.
              utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                         'Invalid or non-existant distbr_id - ' || rv_distbr.distbr_id,
                                         ods_constants.valdtn_severity_critical,
                                         rv_distbr.bus_unit_id,
                                         c_cust_ref,
                                         rv_distbr.efex_cust_id,
                                         NULL,
                                         NULL,
                                         c_bulk,
                                         i_log_level + 1);

          UPDATE efex_cust
          SET valdtn_status = ods_constants.valdtn_invalid
          WHERE distbr_id = rv_distbr.distbr_id;

        END LOOP;
        CLOSE csr_distbr;
        COMMIT;
     END IF;
END check_cust_distributors;


PROCEDURE clear_validation_reason (
  i_valdtn_type_code valdtn_reasn_hdr.valdtn_type_code%TYPE,
  i_log_level        ods.log.log_level%TYPE DEFAULT 0) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  -- Clear the detail table.
  DELETE FROM
    valdtn_reasn_dtl t1
  WHERE EXISTS (SELECT *
                FROM valdtn_reasn_hdr t2
                WHERE t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code
                AND t2.valdtn_type_code = i_valdtn_type_code);

  -- Clear the header table.
  DELETE FROM
    valdtn_reasn_hdr
  WHERE
    valdtn_type_code = i_valdtn_type_code;

  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      write_log(ods_constants.data_type_clear_valdtn_reasn,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR CLEAR_VALIDATION_REASON.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
                              'Failed to clear validation reason(s): ' || sqlerrm);

  END clear_validation_reason;


PROCEDURE validate_efex_route_plan_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;
    v_invalid_cust_flg BOOLEAN := FALSE;
    v_invalid_terr_flg BOOLEAN := FALSE;
    v_invalid_sgmnt_flg BOOLEAN := FALSE;
    v_invalid_bus_flg BOOLEAN := FALSE;
    v_invalid_user_flg BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_route_plan
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_route_plan t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND status = 'A'
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_user IS
      SELECT DISTINCT user_id, bus_unit_id
      FROM efex_route_plan t1
      WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND status = 'A'
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_user csr_user%ROWTYPE;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_route_plan t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND status = 'A'
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id, bus_unit_id
      FROM efex_route_plan t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND status = 'A'
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

    CURSOR csr_bus_unit IS
      SELECT DISTINCT bus_unit_id
      FROM efex_route_plan t1
      WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id)
      AND status = 'A'
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_bus_unit csr_bus_unit%ROWTYPE;

  BEGIN
    -- Validate efex_route_plans.
    write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_route_plan_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_route_plan
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_route_plan, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Check for invalid customers in efex_route_plan.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Invalid efex_cust_id: ' || rv_cust.efex_cust_id || ' found in efex_route_plan.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'One or more efex_route_plan records with Invalid or non-existant Customer Id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Check for invalid users in efex_route_plan.');
      OPEN csr_user;
      LOOP
        FETCH csr_user INTO rv_user;
        EXIT WHEN csr_user%NOTFOUND;
        v_invalid_user_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Invalid user_id: ' || rv_user.user_id || ' found in efex_route_plan.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'One or more efex_route_plan records with Invalid or non-existant user_id - ' || rv_user.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_user.bus_unit_id,
                                  c_user_ref,
                                  rv_user.user_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_user;

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_route_plan.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Invalid sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_route_plan.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'One or more efex_route_plan records with Invalid or non-existant Sales_Terr_Id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_route_plan.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Invalid sgmnt_id: ' || rv_sgmnt.sgmnt_id || ' found in efex_route_plan.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'One or more efex_route_plan records with Invalid or non-existant sgmnt_id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sgmnt.bus_unit_id,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Check for invalid business unit in efex_route_plan.');
      OPEN csr_bus_unit;
      LOOP
        FETCH csr_bus_unit INTO rv_bus_unit;
        EXIT WHEN csr_bus_unit%NOTFOUND;
        v_invalid_bus_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Invalid bus_unit_id: ' || rv_bus_unit.bus_unit_id || ' found in efex_route_plan.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_route_plan,
                                  'One or more efex_route_plan records with Invalid or non-existant bus_unit_id - ' || rv_bus_unit.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_bus_unit.bus_unit_id,
                                  c_bus_unit_ref,
                                  rv_bus_unit.bus_unit_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_bus_unit;

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_route_plan.');

      IF v_invalid_user_flg = TRUE THEN
         UPDATE efex_route_plan t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_route_plan t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_terr_flg = TRUE THEN
         UPDATE efex_route_plan t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sgmnt_flg = TRUE THEN
         UPDATE efex_route_plan t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_bus_flg = TRUE THEN
         UPDATE efex_route_plan t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_route_plan.');

      UPDATE efex_route_plan t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_route_plan_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_route_plan, 'n/a', 0, 'ods_efex_validation.validate_efex_route_plan_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_route_plan_bulk;

  PROCEDURE validate_efex_distbn_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;
    v_invalid_cust_flg BOOLEAN := FALSE;
    v_invalid_matl_flg BOOLEAN := FALSE;
    v_invalid_terr_flg BOOLEAN := FALSE;
    v_invalid_sgmnt_flg BOOLEAN := FALSE;
    v_invalid_bus_flg BOOLEAN := FALSE;
    v_invalid_user_flg BOOLEAN := FALSE;
    v_invalid_range_flg BOOLEAN := FALSE;
    v_invalid_flgs_flg BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_distbn
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_user IS
      SELECT DISTINCT user_id, bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_user csr_user%ROWTYPE;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id, bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

    CURSOR csr_bus_unit IS
      SELECT DISTINCT bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_bus_unit csr_bus_unit%ROWTYPE;

    CURSOR csr_range IS
      SELECT DISTINCT range_id, bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT * FROM efex_range t2 WHERE t1.range_id = t2.range_id AND valdtn_status = ods_constants.valdtn_valid)
    --------REMOVED 2009/03    AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_range csr_range%ROWTYPE;

    CURSOR csr_matl IS
      SELECT DISTINCT efex_matl_id, bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT *
                        FROM efex_matl t2
                        WHERE t1.efex_matl_id = t2.efex_matl_id
                          AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl csr_matl%ROWTYPE;

    CURSOR csr_matl_matl_subgrp IS
      SELECT DISTINCT efex_matl_id, sgmnt_id, bus_unit_id
      FROM efex_distbn t1
      WHERE NOT EXISTS (SELECT *
                        FROM efex_matl_matl_subgrp t2
                        WHERE t1.efex_matl_id = t2.efex_matl_id
                          AND t1.sgmnt_id = t2.sgmnt_id
                          AND t2.status = 'A'
                          AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;

    rv_matl_matl_subgrp csr_matl_matl_subgrp%ROWTYPE;


  BEGIN
    -- Validate efex_distbn.
    write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_distbn_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_distbn
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_distbn, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid customers in efex_distbn.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid efex_cust_id: ' || rv_cust.efex_cust_id || ' found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'One or more efex_distbn records with Invalid or non-existant efex_cust_id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid users in efex_distbn.');
      OPEN csr_user;
      LOOP
        FETCH csr_user INTO rv_user;
        EXIT WHEN csr_user%NOTFOUND;
        v_invalid_user_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid user_id: ' || rv_user.user_id || ' found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'One or more efex_distbn records with Invalid or non-existant user_id - ' || rv_user.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_user.bus_unit_id,
                                  c_user_ref,
                                  rv_user.user_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_user;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_distbn.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'One or more efex_distbn records with Invalid or non-existant sales_terr_id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_distbn.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid sgmnt_id: ' || rv_sgmnt.sgmnt_id || ' found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'One or more efex_distbn records with Invalid or non-existant sgmnt_id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sgmnt.bus_unit_id,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid business unit in efex_distbn.');
      OPEN csr_bus_unit;
      LOOP
        FETCH csr_bus_unit INTO rv_bus_unit;
        EXIT WHEN csr_bus_unit%NOTFOUND;
        v_invalid_bus_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid bus_unit_id: ' || rv_bus_unit.bus_unit_id || ' found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'One or more efex_distbn records with Invalid or non-existant bus_unit_id - ' || rv_bus_unit.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_bus_unit.bus_unit_id,
                                  c_bus_unit_ref,
                                  rv_bus_unit.bus_unit_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_bus_unit;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid Range in efex_distbn.');
      OPEN csr_range;
      LOOP
        FETCH csr_range INTO rv_range;
        EXIT WHEN csr_range%NOTFOUND;
        v_invalid_range_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid range_id: ' || rv_range.range_id || ' found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'One or more efex_distbn records with Invalid or non-existant range_id - ' || rv_range.range_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_range.bus_unit_id,
                                  c_range_ref,
                                  rv_range.range_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_range;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid matl in efex_distbn.');
      OPEN csr_matl;
      LOOP
        FETCH csr_matl INTO rv_matl;
        EXIT WHEN csr_matl%NOTFOUND;
        v_invalid_matl_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid matl_id: ' || rv_matl.efex_matl_id || ' found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'One or more efex_distbn records with Invalid or non-existant efex_matl_id - ' || rv_matl.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_matl.bus_unit_id,
                                  c_matl_ref,
                                  rv_matl.efex_matl_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Check for invalid matl in efex_distbn.');
      OPEN csr_matl_matl_subgrp;
      LOOP
        FETCH csr_matl_matl_subgrp INTO rv_matl_matl_subgrp;
        EXIT WHEN csr_matl_matl_subgrp%NOTFOUND;
        v_invalid_matl_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Invalid matl_id/sgmnt: ' || rv_matl_matl_subgrp.efex_matl_id || '/' || rv_matl_matl_subgrp.sgmnt_id || ' no subgroup found in efex_distbn.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn,
                                  'Distribution record(s) without subgroup assigned for matl/sgmnt- ' || rv_matl_matl_subgrp.efex_matl_id || '/' || rv_matl_matl_subgrp.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_matl_matl_subgrp.bus_unit_id,
                                  c_matl_matl_subgrp_ref,
                                  rv_matl_matl_subgrp.efex_matl_id,
                                  rv_matl_matl_subgrp.sgmnt_id,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl_matl_subgrp;

      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_distbn.');

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_distbn t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_matl_flg = TRUE THEN
         UPDATE efex_distbn t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT *
                           FROM efex_matl t2
                           WHERE t1.efex_matl_id = t2.efex_matl_id
                           AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         UPDATE efex_distbn t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT *
                           FROM efex_matl_matl_subgrp t2
                           WHERE t1.efex_matl_id = t2.efex_matl_id
                             AND t1.sgmnt_id = t2.sgmnt_id
                             AND t2.status = 'A'
                             AND valdtn_status = ods_constants.valdtn_valid)
          AND status = 'A'
          AND valdtn_status = ods_constants.valdtn_unchecked;

     END IF;

     IF v_invalid_user_flg = TRUE THEN
        UPDATE efex_distbn t1
        SET valdtn_status = ods_constants.valdtn_invalid
        WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
          AND status = 'A'
          AND valdtn_status = ods_constants.valdtn_unchecked;
     END IF;

     IF v_invalid_range_flg = TRUE THEN
        UPDATE efex_distbn t1
        SET valdtn_status = ods_constants.valdtn_invalid
        WHERE NOT EXISTS (SELECT * FROM efex_range t2 WHERE t1.range_id = t2.range_id AND t2.valdtn_status = ods_constants.valdtn_valid)
          AND status = 'A'
          AND valdtn_status = ods_constants.valdtn_unchecked;
     END IF;

     IF v_invalid_terr_flg = TRUE THEN
        UPDATE efex_distbn t1
        SET valdtn_status = ods_constants.valdtn_invalid
        WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
          AND status = 'A'
          AND valdtn_status = ods_constants.valdtn_unchecked;
     END IF;

     IF v_invalid_sgmnt_flg = TRUE THEN
        UPDATE efex_distbn t1
        SET valdtn_status = ods_constants.valdtn_invalid
        WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
          AND status = 'A'
          AND valdtn_status = ods_constants.valdtn_unchecked;
     END IF;

     IF v_invalid_bus_flg = TRUE THEN
        UPDATE efex_distbn t1
        SET valdtn_status = ods_constants.valdtn_invalid
        WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id AND t2.valdtn_status = ods_constants.valdtn_valid)
          AND status = 'A'
          AND valdtn_status = ods_constants.valdtn_unchecked;
     END IF;

     COMMIT;

     write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_distbn.');

     UPDATE efex_distbn t1
     SET valdtn_status = ods_constants.valdtn_valid
     WHERE valdtn_status = ods_constants.valdtn_unchecked;
     COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_distbn_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_distbn, 'n/a', 0, 'ods_efex_validation.validate_efex_distbn_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_distbn_bulk;

PROCEDURE validate_efex_range_matl_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;
    v_invalid_matl_flg BOOLEAN := FALSE;
    v_invalid_range_flg BOOLEAN := FALSE;
    v_invalid_flgs_flg BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_range_matl
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_range IS
      SELECT DISTINCT range_id
      FROM efex_range_matl t1
      WHERE NOT EXISTS (SELECT * FROM efex_range t2 WHERE t1.range_id = t2.range_id AND valdtn_status = ods_constants.valdtn_valid)
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_range csr_range%ROWTYPE;

    CURSOR csr_matl IS
      SELECT DISTINCT efex_matl_id
      FROM efex_range_matl t1
      WHERE NOT EXISTS (SELECT * FROM efex_matl t2 WHERE t1.efex_matl_id = t2.efex_matl_id AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl csr_matl%ROWTYPE;

  BEGIN
    -- Validate efex_range_matl.
    write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_range_matl_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_range_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_range_matl, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'Check for invalid Range in efex_range_matl.');
      OPEN csr_range;
      LOOP
        FETCH csr_range INTO rv_range;
        EXIT WHEN csr_range%NOTFOUND;
        v_invalid_range_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'Invalid range_id: ' || rv_range.range_id || ' found in efex_range_matl.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_range_matl,
                                  'One or more efex_range_matl records with Invalid or non-existant range_id - ' || rv_range.range_id,
                                  ods_constants.valdtn_severity_critical,
                                  -1, -- default to both business
                                  c_range_ref,
                                  rv_range.range_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_range;

      write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'Check for invalid matl in efex_range_matl.');
      OPEN csr_matl;
      LOOP
        FETCH csr_matl INTO rv_matl;
        EXIT WHEN csr_matl%NOTFOUND;
        v_invalid_matl_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'Invalid matl_id: ' || rv_matl.efex_matl_id || ' found in efex_range_matl.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_range_matl,
                                  'One or more efex_range_matl records with Invalid or non-existant efex_matl_id - ' || rv_matl.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  -1, -- default to both business
                                  c_matl_ref,
                                  rv_matl.efex_matl_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl;

      write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_range_matl.');

      IF v_invalid_matl_flg = TRUE THEN
         UPDATE efex_range_matl t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_matl t2 WHERE t1.efex_matl_id = t2.efex_matl_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_range_flg = TRUE THEN
         UPDATE efex_range_matl t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_range t2 WHERE t1.range_id = t2.range_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_range_matl.');

      UPDATE efex_range_matl t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_range_matl_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_range_matl, 'n/a', 0, 'ods_efex_validation.validate_efex_range_matl_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_range_matl_bulk;

PROCEDURE validate_efex_ass_assgn_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;
    v_invalid_cust_flg BOOLEAN := FALSE;
    v_invalid_ass_flg BOOLEAN := FALSE;
    v_invalid_terr_flg BOOLEAN := FALSE;
    v_invalid_sgmnt_flg BOOLEAN := FALSE;
    v_invalid_bus_flg BOOLEAN := FALSE;
    v_invalid_affltn_flg BOOLEAN := FALSE;
    v_invalid_cust_type_flg BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_assmnt_assgnmnt
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_assmnt_assgnmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_assmnt_assgnmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND sales_terr_id IS NOT NULL
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id, bus_unit_id
      FROM efex_assmnt_assgnmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

    CURSOR csr_bus_unit IS
      SELECT DISTINCT bus_unit_id
      FROM efex_assmnt_assgnmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_bus_unit csr_bus_unit%ROWTYPE;

    CURSOR csr_assmnt IS
      SELECT DISTINCT assmnt_id, bus_unit_id
      FROM efex_assmnt_assgnmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_assmnt_questn t2 WHERE t1.assmnt_id = t2.assmnt_id AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_assmnt csr_assmnt%ROWTYPE;

    CURSOR csr_affltn IS
      SELECT DISTINCT affltn_id, bus_unit_id
      FROM efex_assmnt_assgnmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_affltn t2 WHERE t1.affltn_id = t2.affltn_id AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND affltn_id IS NOT NULL
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_affltn csr_affltn%ROWTYPE;

    CURSOR csr_cust_type IS
      SELECT DISTINCT cust_type_id, bus_unit_id
      FROM efex_assmnt_assgnmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust_chnl t2 WHERE t1.cust_Type_id = t2.cust_Type_id AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND cust_type_id IS NOT NULL
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust_type csr_cust_type%ROWTYPE;

  BEGIN
    -- Validate efex_assmnt_assgnmnt.
    write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_ass_assgn_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_assmnt_assgnmnt
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type
      clear_validation_reason (ods_constants.valdtn_type_efex_ass_assgn, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid customers in efex_assmnt_assgnmnt.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Invalid efex_cust_id: ' || rv_cust.efex_cust_id || ' found in efex_assmnt_assgnmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'One or more efex_assmnt_assgnmnt records with Invalid or non-existant efex_cust_id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid assmnt in efex_assmnt_assgnmnt.');
      OPEN csr_assmnt;
      LOOP
        FETCH csr_assmnt INTO rv_assmnt;
        EXIT WHEN csr_assmnt%NOTFOUND;
        v_invalid_ass_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Invalid assmnt_id: ' || rv_assmnt.assmnt_id || ' found in efex_assmnt_assgnmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'One or more efex_assmnt_assgnmnt records with Invalid or non-existant assmnt_id - ' || rv_assmnt.assmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_assmnt.bus_unit_id,
                                  c_assmnt_questn_ref,
                                  rv_assmnt.assmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_assmnt;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_assmnt_assgnmnt.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Invalid sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_assmnt_assgnmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'One or more efex_assmnt_assgnmnt records with Invalid or non-existant sales_terr_id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_assmnt_assgnmnt.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Invalid sgmnt_id: ' || rv_sgmnt.sgmnt_id || ' found in efex_assmnt_assgnmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'One or more efex_assmnt_assgnmnt records with Invalid or non-existant sgmnt_id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sgmnt.bus_unit_id,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid business unit in efex_assmnt_assgnmnt.');
      OPEN csr_bus_unit;
      LOOP
        FETCH csr_bus_unit INTO rv_bus_unit;
        EXIT WHEN csr_bus_unit%NOTFOUND;
        v_invalid_bus_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Invalid bus_unit_id: ' || rv_bus_unit.bus_unit_id || ' found in efex_assmnt_assgnmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'One or more efex_assmnt_assgnmnt records with Invalid or non-existant bus_unit_id - ' || rv_bus_unit.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_bus_unit.bus_unit_id,
                                  c_bus_unit_ref,
                                  rv_bus_unit.bus_unit_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_bus_unit;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid affltn in efex_assmnt_assgnmnt.');
      OPEN csr_affltn;
      LOOP
        FETCH csr_affltn INTO rv_affltn;
        EXIT WHEN csr_affltn%NOTFOUND;
        v_invalid_affltn_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Invalid affltn_id: ' || rv_affltn.affltn_id || ' found in efex_assmnt_assgnmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'One or more efex_assmnt_assgnmnt records with Invalid or non-existant affltn_id - ' || rv_affltn.affltn_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_affltn.bus_unit_id,
                                  c_affltn_ref,
                                  rv_affltn.affltn_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_affltn;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid cust_type in efex_assmnt_assgnmnt.');
      OPEN csr_cust_type;
      LOOP
        FETCH csr_cust_type INTO rv_cust_type;
        EXIT WHEN csr_cust_type%NOTFOUND;
        v_invalid_cust_type_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Invalid cust_type_id: ' || rv_cust_type.cust_type_id || ' found in efex_assmnt_assgnmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_ass_assgn,
                                  'One or more efex_assmnt_assgnmnt records with Invalid or non-existant cust_type_id - ' || rv_cust_type.cust_type_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust_type.bus_unit_id,
                                  c_cust_type_ref,
                                  rv_cust_type.cust_type_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust_type;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_assmnt_assgnmnt.');

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_assmnt_assgnmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_affltn_flg = TRUE THEN
         UPDATE efex_assmnt_assgnmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_affltn t2 WHERE t1.affltn_id = t2.affltn_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND t1.affltn_id IS NOT NULL
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_cust_type_flg = TRUE THEN
         UPDATE efex_assmnt_assgnmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust_chnl t2 WHERE t1.cust_type_id = t2.cust_type_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND t1.cust_type_id IS NOT NULL
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_ass_flg = TRUE THEN
         UPDATE efex_assmnt_assgnmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_assmnt_questn t2 WHERE t1.assmnt_id = t2.assmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_terr_flg = TRUE THEN
         UPDATE efex_assmnt_assgnmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sgmnt_flg = TRUE THEN
         UPDATE efex_assmnt_assgnmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_bus_flg = TRUE THEN
         UPDATE efex_assmnt_assgnmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_assmnt_assgnmnt.');

      UPDATE efex_assmnt_assgnmnt t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_ass_assgn_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', 0, 'ods_efex_validation.validate_efex_ass_assgn_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_ass_assgn_bulk;


PROCEDURE validate_efex_order_matl_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;
    v_invalid_cust_flg BOOLEAN := FALSE;
    v_invalid_matl_flg BOOLEAN := FALSE;
    v_invalid_order_flg BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_order_matl
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_order IS
      SELECT DISTINCT t1.efex_order_id, NVL(t2.bus_unit_id, -1) bus_unit_id
      FROM efex_order_matl t1,
           efex_order t2
      WHERE t1.efex_order_id = t2.efex_order_id (+)
        AND NOT EXISTS (SELECT * FROM efex_order t3 WHERE t1.efex_order_id = t3.efex_order_id AND t3.valdtn_status = ods_constants.valdtn_valid)
        AND t1.status = 'A'
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_order csr_order%ROWTYPE;

    CURSOR csr_matl IS
      SELECT DISTINCT t1.efex_matl_id, NVL(t2.bus_unit_id, -1) bus_unit_id
      FROM efex_order_matl t1,
           efex_order t2
      WHERE t1.efex_order_id = t2.efex_order_id (+)
        AND NOT EXISTS (SELECT * FROM efex_matl t3 WHERE t1.efex_matl_id = t3.efex_matl_id AND t3.valdtn_status = ods_constants.valdtn_valid)
        AND t1.status = 'A'
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl csr_matl%ROWTYPE;

    CURSOR csr_cust IS
      SELECT DISTINCT t1.matl_distbr_id, NVL(t2.bus_unit_id, -1) bus_unit_id
      FROM efex_order_matl t1,
           efex_order t2
      WHERE t1.efex_order_id = t2.efex_order_id (+)
        AND NOT EXISTS (SELECT * FROM efex_cust t3 WHERE t1.matl_distbr_id = t3.efex_cust_id AND t3.valdtn_status = ods_constants.valdtn_valid)
        AND t1.status = 'A'
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

  BEGIN
    -- Validate efex_order_matl.
    write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_order_matl_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_order_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_order_matl, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Check for invalid order in efex_order_matl.');
      OPEN csr_order;
      LOOP
        FETCH csr_order INTO rv_order;
        EXIT WHEN csr_order%NOTFOUND;
        v_invalid_order_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Invalid efex_order_id: ' || rv_order.efex_order_id || ' found in efex_order_matl.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order_matl,
                                  'One or more efex_order_matl records with Invalid or non-existant efex_order_id - ' || rv_order.efex_order_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_order.bus_unit_id,
                                  c_order_ref,
                                  rv_order.efex_order_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_order;

      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Check for invalid matl in efex_order_matl.');
      OPEN csr_matl;
      LOOP
        FETCH csr_matl INTO rv_matl;
        EXIT WHEN csr_matl%NOTFOUND;
        v_invalid_matl_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Invalid matl_id: ' || rv_matl.efex_matl_id || ' found in efex_order_matl.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order_matl,
                                  'One or more efex_order_matl records with Invalid or non-existant efex_matl_id - ' || rv_matl.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_matl.bus_unit_id,
                                  c_matl_ref,
                                  rv_matl.efex_matl_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl;

      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Check for invalid distributor in efex_order_matl.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Invalid matl_distbr_id: ' || rv_cust.matl_distbr_id || ' found in efex_order_matl.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order_matl,
                                  'One or more efex_order_matl records with Invalid or non-existant matl_distbr_id - ' || rv_cust.matl_distbr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.matl_distbr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_order_matl.');

      IF v_invalid_matl_flg = TRUE THEN
         UPDATE efex_order_matl t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_matl t2 WHERE t1.efex_matl_id = t2.efex_matl_id AND valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_order_flg = TRUE THEN
         UPDATE efex_order_matl t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_order t2 WHERE t1.efex_order_id = t2.efex_order_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_order_matl t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.matl_distbr_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      UPDATE efex_order_matl t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_order_matl.');


  END IF;

  write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_order_matl_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_order_matl, 'n/a', 0, 'ods_efex_validation.validate_efex_order_matl_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_order_matl_bulk;


PROCEDURE validate_efex_call_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count          PLS_INTEGER := 0;
    v_invalid_cust_flg   BOOLEAN := FALSE;
    v_invalid_user_flg    BOOLEAN := FALSE;
    v_invalid_terr_flg   BOOLEAN := FALSE;
    v_invalid_sgmnt_flg  BOOLEAN := FALSE;
    v_invalid_bus_flg    BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_call
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_call t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_call t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id, bus_unit_id
      FROM efex_call t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

    CURSOR csr_bus_unit IS
      SELECT DISTINCT bus_unit_id
      FROM efex_call t1
      WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_bus_unit csr_bus_unit%ROWTYPE;

    CURSOR csr_user IS
      SELECT DISTINCT user_id, bus_unit_id
      FROM efex_call t1
      WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_user csr_user%ROWTYPE;

  BEGIN
    -- Validate efex_call.
    write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_call_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_call
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_call, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Check for invalid customers in efex_call.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Invalid efex_cust_id: ' || rv_cust.efex_cust_id || ' found in efex_call.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'One or more efex_call records with Invalid or non-existant efex_cust_id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Check for invalid user_id in efex_call.');
      OPEN csr_user;
      LOOP
        FETCH csr_user INTO rv_user;
        EXIT WHEN csr_user%NOTFOUND;
        v_invalid_user_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Invalid user_id: ' || rv_user.user_id || ' found in efex_call.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'One or more efex_call records with Invalid or non-existant user_id - ' || rv_user.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_user.bus_unit_id,
                                  c_user_ref,
                                  rv_user.user_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_user;

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_call.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Invalid sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_call.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'One or more efex_call records with Invalid or non-existant sales_terr_id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_call.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Invalid sgmnt_id: ' || rv_sgmnt.sgmnt_id || ' found in efex_call.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'One or more efex_call records with Invalid or non-existant sgmnt_id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sgmnt.bus_unit_id,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Check for invalid business unit in efex_call.');
      OPEN csr_bus_unit;
      LOOP
        FETCH csr_bus_unit INTO rv_bus_unit;
        EXIT WHEN csr_bus_unit%NOTFOUND;
        v_invalid_bus_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Invalid bus_unit_id: ' || rv_bus_unit.bus_unit_id || ' found in efex_call.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_call,
                                  'One or more efex_call records with Invalid or non-existant bus_unit_id - ' || rv_bus_unit.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_bus_unit.bus_unit_id,
                                  c_bus_unit_ref,
                                  rv_bus_unit.bus_unit_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_bus_unit;

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_call.');

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_call t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_user_flg = TRUE THEN
         UPDATE efex_call t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_terr_flg = TRUE THEN
         UPDATE efex_call t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sgmnt_flg = TRUE THEN
         UPDATE efex_call t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_bus_flg = TRUE THEN
         UPDATE efex_call t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_call.');

      UPDATE efex_call t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_call, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_call_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_call, 'n/a', 0, 'ods_efex_validation.validate_efex_call_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_call_bulk;

PROCEDURE validate_efex_assmnt_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count          PLS_INTEGER := 0;
    v_invalid_cust_flg   BOOLEAN := FALSE;
    v_invalid_user_flg   BOOLEAN := FALSE;
    v_invalid_terr_flg   BOOLEAN := FALSE;
    v_invalid_sgmnt_flg  BOOLEAN := FALSE;
    v_invalid_bus_flg    BOOLEAN := FALSE;
    v_invalid_ass_flg    BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_assmnt
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_assmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_assmnt IS
      SELECT DISTINCT assmnt_id, bus_unit_id
      FROM efex_assmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_assmnt_questn t2 WHERE t1.assmnt_id = t2.assmnt_id AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_assmnt csr_assmnt%ROWTYPE;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_assmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id, bus_unit_id
      FROM efex_assmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

    CURSOR csr_bus_unit IS
      SELECT DISTINCT bus_unit_id
      FROM efex_assmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_bus_unit csr_bus_unit%ROWTYPE;

    CURSOR csr_user IS
      SELECT DISTINCT user_id, bus_unit_id
      FROM efex_assmnt t1
      WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_user csr_user%ROWTYPE;

  BEGIN
    -- Validate efex_assmnt.
    write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_assmnt_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_assmnt
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_assmnt, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Check for invalid customers in efex_assmnt.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Invalid efex_cust_id: ' || rv_cust.efex_cust_id || ' found in efex_assmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'One or more efex_assmnt records with Invalid or non-existant efex_cust_Id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_ass_assgn, 'n/a', i_log_level + 1, 'Check for invalid assmnt in efex_assmnt_assgnmnt.');
      OPEN csr_assmnt;
      LOOP
        FETCH csr_assmnt INTO rv_assmnt;
        EXIT WHEN csr_assmnt%NOTFOUND;
        v_invalid_ass_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Invalid assmnt_id: ' || rv_assmnt.assmnt_id || ' found in efex_assmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'One or more efex_assmnt records with Invalid or non-existant assmnt_id - ' || rv_assmnt.assmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_assmnt.bus_unit_id,
                                  c_assmnt_questn_ref,
                                  rv_assmnt.assmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_assmnt;

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Check for invalid user_id in efex_assmnt.');
      OPEN csr_user;
      LOOP
        FETCH csr_user INTO rv_user;
        EXIT WHEN csr_user%NOTFOUND;
        v_invalid_user_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Invalid user_id: ' || rv_user.user_id || ' found in efex_assmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'One or more efex_assmnt records with Invalid or non-existant user_Id - ' || rv_user.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_user.bus_unit_id,
                                  c_user_ref,
                                  rv_user.user_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_user;

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_assmnt.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Invalid sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_assmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'One or more efex_assmnt records with Invalid or non-existant Sales_terr_id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_assmnt.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Invalid sgmnt_id: ' || rv_sgmnt.sgmnt_id || ' found in efex_assmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'One or more efex_assmnt records with Invalid or non-existant Sgmnt_Id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sgmnt.bus_unit_id,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Check for invalid business unit in efex_assmnt.');
      OPEN csr_bus_unit;
      LOOP
        FETCH csr_bus_unit INTO rv_bus_unit;
        EXIT WHEN csr_bus_unit%NOTFOUND;
        v_invalid_bus_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Invalid bus_unit_id: ' || rv_bus_unit.bus_unit_id || ' found in efex_assmnt.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_assmnt,
                                  'One or more efex_assmnt records with Invalid or non-existant bus_unid_id - ' || rv_bus_unit.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_bus_unit.bus_unit_id,
                                  c_bus_unit_ref,
                                  rv_bus_unit.bus_unit_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_bus_unit;

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_assmnt.');

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_assmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_ass_flg = TRUE THEN
         UPDATE efex_assmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_assmnt_questn t2 WHERE t1.assmnt_id = t2.assmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_user_flg = TRUE THEN
         UPDATE efex_assmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_terr_flg = TRUE THEN
         UPDATE efex_assmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sgmnt_flg = TRUE THEN
         UPDATE efex_assmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_bus_flg = TRUE THEN
         UPDATE efex_assmnt t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_assmnt.');

      UPDATE efex_assmnt t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_assmnt_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_assmnt, 'n/a', 0, 'ods_efex_validation.validate_efex_assmnt_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_assmnt_bulk;

PROCEDURE validate_efex_distbn_tot_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count               PLS_INTEGER := 0;
    v_invalid_cust_flg        BOOLEAN := FALSE;
    v_invalid_user_flg        BOOLEAN := FALSE;
    v_invalid_terr_flg        BOOLEAN := FALSE;
    v_invalid_sgmnt_flg       BOOLEAN := FALSE;
    v_invalid_bus_flg         BOOLEAN := FALSE;
    v_invalid_matl_grp_flg    BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_distbn_tot
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_distbn_tot t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
      AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_matl_grp IS
      SELECT DISTINCT matl_grp_id, bus_unit_id
      FROM efex_distbn_tot t1
      WHERE NOT EXISTS (SELECT * FROM efex_matl_grp t2 WHERE t1.matl_grp_id = t2.matl_grp_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl_grp csr_matl_grp%ROWTYPE;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_distbn_tot t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id, bus_unit_id
      FROM efex_distbn_tot t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

    CURSOR csr_bus_unit IS
      SELECT DISTINCT bus_unit_id
      FROM efex_distbn_tot t1
      WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_bus_unit csr_bus_unit%ROWTYPE;

    CURSOR csr_user IS
      SELECT DISTINCT user_id, bus_unit_id
      FROM efex_distbn_tot t1
      WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_user csr_user%ROWTYPE;

  BEGIN
    -- Validate efex_distbn_tot.
    write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_distbn_tot_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_distbn_tot
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_distbn_tot, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Check for invalid customers in efex_distbn_tot.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Invalid efex_cust_id: ' || rv_cust.efex_cust_id || ' found in efex_distbn_tot.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'One or more efex_distbn_tot records with Invalid or non-existant efex_cust_id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Check for invalid matl group in efex_distbn_tot_assgnmnt.');
      OPEN csr_matl_grp;
      LOOP
        FETCH csr_matl_grp INTO rv_matl_grp;
        EXIT WHEN csr_matl_grp%NOTFOUND;
        v_invalid_matl_grp_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Invalid matl_grp_id: ' || rv_matl_grp.matl_grp_id || ' found in efex_distbn_tot.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'One or more efex_distbn_tot records with Invalid or non-existant matl_grp_Id - ' || rv_matl_grp.matl_grp_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_matl_grp.bus_unit_id,
                                  c_matl_grp_ref,
                                  rv_matl_grp.matl_grp_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl_grp;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Check for invalid user_id in efex_distbn_tot.');
      OPEN csr_user;
      LOOP
        FETCH csr_user INTO rv_user;
        EXIT WHEN csr_user%NOTFOUND;
        v_invalid_user_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Invalid user_id: ' || rv_user.user_id || ' found in efex_distbn_tot.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'One or more efex_distbn_tot records with Invalid or non-existant user_Id - ' || rv_user.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_user.bus_unit_id,
                                  c_user_ref,
                                  rv_user.user_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_user;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_distbn_tot.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Invalid sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_distbn_tot.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'One or more efex_distbn_tot records with Invalid or non-existant Sales_Terr_Id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_distbn_tot.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Invalid sgmnt_id: ' || rv_sgmnt.sgmnt_id || ' found in efex_distbn_tot.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'One or more efex_distbn_tot records with Invalid or non-existant Sgmnt_Id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sgmnt.bus_unit_id,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Check for invalid business unit in efex_distbn_tot.');
      OPEN csr_bus_unit;
      LOOP
        FETCH csr_bus_unit INTO rv_bus_unit;
        EXIT WHEN csr_bus_unit%NOTFOUND;
        v_invalid_bus_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Invalid bus_unit_id: ' || rv_bus_unit.bus_unit_id || ' found in efex_distbn_tot.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_distbn_tot,
                                  'One or more efex_distbn_tot records with Invalid or non-existant bus_unit_id - ' || rv_bus_unit.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_bus_unit.bus_unit_id,
                                  c_bus_unit_ref,
                                  rv_bus_unit.bus_unit_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_bus_unit;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_distbn_tot.');

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_distbn_tot t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_matl_grp_flg = TRUE THEN
         UPDATE efex_distbn_tot t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_matl_grp t2 WHERE t1.matl_grp_id = t2.matl_grp_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_user_flg = TRUE THEN
         UPDATE efex_distbn_tot t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_terr_flg = TRUE THEN
         UPDATE efex_distbn_tot t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sgmnt_flg = TRUE THEN
         UPDATE efex_distbn_tot t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_bus_flg = TRUE THEN
         UPDATE efex_distbn_tot t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_distbn_tot.');

      UPDATE efex_distbn_tot t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_distbn_tot_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_distbn_tot, 'n/a', 0, 'ods_efex_validation.validate_efex_distbn_tot_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_distbn_tot_bulk;

PROCEDURE validate_efex_m_m_subgrp_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count               PLS_INTEGER := 0;
    v_invalid_sgmnt_flg       BOOLEAN := FALSE;
    v_invalid_matl_flg        BOOLEAN := FALSE;
    v_invalid_subgrp_flg      BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_matl_matl_subgrp
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_matl_subgrp IS
      SELECT DISTINCT matl_subgrp_id
      FROM efex_matl_matl_subgrp t1
      WHERE NOT EXISTS (SELECT * FROM efex_matl_subgrp t2 WHERE t1.matl_subgrp_id = t2.matl_subgrp_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl_subgrp csr_matl_subgrp%ROWTYPE;

    CURSOR csr_matl IS
      SELECT DISTINCT efex_matl_id
      FROM efex_matl_matl_subgrp t1
      WHERE NOT EXISTS (SELECT * FROM efex_matl t2 WHERE t1.efex_matl_id = t2.efex_matl_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl csr_matl%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id
      FROM efex_matl_matl_subgrp t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

  BEGIN
    -- Validate efex_matl_matl_subgrp.
    write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_m_m_subgrp_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_matl_matl_subgrp
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_matl_m_subgrp, i_log_level + 1);


      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Check for invalid matl group in efex_matl_matl_subgrp.');
      OPEN csr_matl_subgrp;
      LOOP
        FETCH csr_matl_subgrp INTO rv_matl_subgrp;
        EXIT WHEN csr_matl_subgrp%NOTFOUND;
        v_invalid_subgrp_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Invalid matl_subgrp_id: ' || rv_matl_subgrp.matl_subgrp_id || ' found in efex_matl_matl_subgrp.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                  'One or more efex_matl_matl_subgrp records with Invalid or non-existant matl_subgrp_Id - ' || rv_matl_subgrp.matl_subgrp_id,
                                  ods_constants.valdtn_severity_critical,
                                  -1,
                                  c_matl_subgrp_ref,
                                  rv_matl_subgrp.matl_subgrp_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl_subgrp;


      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_matl_matl_subgrp.');
      OPEN csr_matl;
      LOOP
        FETCH csr_matl INTO rv_matl;
        EXIT WHEN csr_matl%NOTFOUND;
        v_invalid_matl_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Invalid efex_matl_id: ' || rv_matl.efex_matl_id || ' found in efex_matl_matl_subgrp.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                  'One or more efex_matl_matl_subgrp records with Invalid or non-existant efex_matl_id - ' || rv_matl.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  -1,
                                  c_matl_ref,
                                  rv_matl.efex_matl_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl;

      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_matl_matl_subgrp.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Invalid sgmnt_id: ' || rv_sgmnt.sgmnt_id || ' found in efex_matl_matl_subgrp.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_matl_m_subgrp,
                                  'One or more efex_matl_matl_subgrp records with Invalid or non-existant Sgmnt_Id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  -1,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_matl_matl_subgrp.');

      IF v_invalid_subgrp_flg = TRUE THEN
         UPDATE efex_matl_matl_subgrp t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_matl_subgrp t2 WHERE t1.matl_subgrp_id = t2.matl_subgrp_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_matl_flg = TRUE THEN
         UPDATE efex_matl_matl_subgrp t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_matl t2 WHERE t1.efex_matl_id = t2.efex_matl_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sgmnt_flg = TRUE THEN
         UPDATE efex_matl_matl_subgrp t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_matl_matl_subgrp.');

      UPDATE efex_matl_matl_subgrp t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_m_m_subgrp_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_matl_m_subgrp, 'n/a', 0, 'ods_efex_validation.validate_efex_m_m_subgrp_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_m_m_subgrp_bulk;

PROCEDURE validate_efex_task_matl_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count               PLS_INTEGER := 0;
    v_invalid_mrq_task_flg    BOOLEAN := FALSE;
    v_invalid_matl_flg        BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_mrq_task_matl
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_mrq_task IS
      SELECT DISTINCT mrq_task_id
      FROM efex_mrq_task_matl t1
      WHERE NOT EXISTS (SELECT * FROM efex_mrq_task t2 WHERE t1.mrq_task_id = t2.mrq_task_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_mrq_task csr_mrq_task%ROWTYPE;

    CURSOR csr_matl IS
      SELECT DISTINCT efex_matl_id
      FROM efex_mrq_task_matl t1
      WHERE NOT EXISTS (SELECT * FROM efex_matl t2 WHERE t1.efex_matl_id = t2.efex_matl_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_matl csr_matl%ROWTYPE;

  BEGIN
    -- Validate efex_mrq_task_matl.
    write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_task_matl_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_mrq_task_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_mrq_task_matl, i_log_level + 1);


      write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'Check for invalid matl group in efex_mrq_task_matl_assgnmnt.');
      OPEN csr_matl;
      LOOP
        FETCH csr_matl INTO rv_matl;
        EXIT WHEN csr_matl%NOTFOUND;
        v_invalid_matl_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'Invalid efex_matl_id: ' || rv_matl.efex_matl_id || ' found in efex_mrq_task_matl.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq_task_matl,
                                  'One or more efex_mrq_task_matl records with Invalid or non-existant efex_matl_id - ' || rv_matl.efex_matl_id,
                                  ods_constants.valdtn_severity_critical,
                                  2, -- default to Snackfood business
                                  c_matl_ref,
                                  rv_matl.efex_matl_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_matl;


      write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'Check for invalid mrq task in efex_mrq_task_matl.');
      OPEN csr_mrq_task;
      LOOP
        FETCH csr_mrq_task INTO rv_mrq_task;
        EXIT WHEN csr_mrq_task%NOTFOUND;
        v_invalid_mrq_task_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'Invalid mrq_task_id: ' || rv_mrq_task.mrq_task_id || ' found in efex_mrq_task_matl.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_mrq_task_matl,
                                  'One or more efex_mrq_task_matl records with Invalid or non-existant mrq_task_id - ' || rv_mrq_task.mrq_task_id,
                                  ods_constants.valdtn_severity_critical,
                                  2, -- default to Snackfood business
                                  c_mrq_task_ref,
                                  rv_mrq_task.mrq_task_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_mrq_task;


      write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_mrq_task_matl.');

      IF v_invalid_mrq_task_flg = TRUE THEN
         UPDATE efex_mrq_task_matl t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_mrq_task t2 WHERE t1.mrq_task_id = t2.mrq_task_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_matl_flg = TRUE THEN
         UPDATE efex_mrq_task_matl t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_matl t2 WHERE t1.efex_matl_id = t2.efex_matl_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_mrq_task_matl.');

      UPDATE efex_mrq_task_matl t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_task_matl_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_mrq_task_matl, 'n/a', 0, 'ods_efex_validation.validate_efex_task_matl_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_task_matl_bulk;

PROCEDURE reset_cust_xactn_valdtn_status(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;

  BEGIN
      -- Reset all the customer related efex data from INVALID to UNCHECKED.
      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'ods_efex_validation.reset_cust_xactn_valdtn_status: Started.');

      UPDATE efex_route_plan
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_distbn
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_distbn_tot
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_assmnt_assgnmnt
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_assmnt
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_call
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_timesheet_call
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_order
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_order_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_pmt
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_pmt_deal
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;
      IF SQL%ROWCOUNT > 0 THEN
         clear_validation_reason (ods_constants.valdtn_type_efex_pmt_deal, i_log_level + 1);
      END IF;

      UPDATE efex_pmt_rtn
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;
      IF SQL%ROWCOUNT > 0 THEN
         clear_validation_reason (ods_constants.valdtn_type_efex_pmt_rtn, i_log_level + 1);
      END IF;

      UPDATE efex_mrq
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_mrq_task
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_mrq_task_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      UPDATE efex_cust_note
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      COMMIT;

      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'ods_efex_validation.reset_cust_xactn_valdtn_status: Ended with update count [' || v_rec_count || ']');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_generic, 'n/a', 0, 'ods_efex_validation.reset_cust_xactn_valdtn_status: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END reset_cust_xactn_valdtn_status;

PROCEDURE reset_matl_xactn_valdtn_status(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;

  BEGIN
      -- Reset all the material related efex data from INVALID to UNCHECKED.
      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'ods_efex_validation.reset_matl_xactn_valdtn_status: Started.');

      UPDATE efex_matl_matl_subgrp
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_range_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_distbn
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_order_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_pmt_rtn
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      UPDATE efex_mrq_task_matl
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      COMMIT;

      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'ods_efex_validation.reset_matl_xactn_valdtn_status: Ended with update count [' || v_rec_count || ']');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_generic, 'n/a', 0, 'ods_efex_validation.reset_matl_xactn_valdtn_status: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END reset_matl_xactn_valdtn_status;

PROCEDURE validate_efex_order_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count              PLS_INTEGER := 0;
    v_invalid_cust_flg       BOOLEAN := FALSE;
    v_invalid_user_flg       BOOLEAN := FALSE;
    v_invalid_sales_terr_flg BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_order
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_order t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_user IS
      SELECT DISTINCT user_id, bus_unit_id
      FROM efex_order t1
      WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_user csr_user%ROWTYPE;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_order t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

  BEGIN
    -- Validate efex_order.
    write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_order_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_order
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] reset from INVALID to UNCHECKED before starting bulk validation.');

      COMMIT;

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_order, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Check for invalid sales_terr in efex_order.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_sales_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Invalid efex_sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_order.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'One or more efex_order records with Invalid or non-existant efex_sales_terr_id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Check for invalid user in efex_order.');
      OPEN csr_user;
      LOOP
        FETCH csr_user INTO rv_user;
        EXIT WHEN csr_user%NOTFOUND;
        v_invalid_user_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Invalid user_id: ' || rv_user.user_id || ' found in efex_order.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'One or more efex_order records with Invalid or non-existant user_id - ' || rv_user.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_user.bus_unit_id,
                                  c_user_ref,
                                  rv_user.user_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_user;

      write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Check for invalid customer in efex_order.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Invalid efex_cust_id: ' || rv_cust.efex_cust_id || ' found in efex_order.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_order,
                                  'One or more efex_order records with Invalid or non-existant efex_cust_id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_order.');

      IF v_invalid_user_flg = TRUE THEN
         UPDATE efex_order t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_user t2 WHERE t1.user_id = t2.user_id AND valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sales_terr_flg = TRUE THEN
         UPDATE efex_order t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_order t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      UPDATE efex_order t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

      write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_order.');

  END IF;

  write_log(ods_constants.valdtn_type_efex_order, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_order_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_order, 'n/a', 0, 'ods_efex_validation.validate_efex_order_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_order_bulk;

PROCEDURE reset_new_cust_valdtn_status(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count   PLS_INTEGER := 0;

  BEGIN
      -- Reset new customer who hasn't have any transaction record yet from INVALID to EXCLUDED
      -- so we will not re-validation those customer next time.
      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'ods_efex_validation.reset_new_cust_valdtn_status: Started.');

      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'Set valdtn_status to EXCLUDED for customer without fully setup and NO transaction linked.');

      UPDATE efex_cust t1
      SET valdtn_status = ods_constants.valdtn_excluded
      WHERE NOT EXISTS ( 
                        SELECT *
                        FROM 
                          ( 
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ROUTE_PLAN T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_CALL T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_TIMESHEET_CALL T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ASSMNT_ASSGNMNT T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ASSMNT T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_DISTBN T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_DISTBN_TOT T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_PMT T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_MRQ T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_CUST_NOTE T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT MATL_DISTBR_ID AS EFEX_CUST_ID
                           FROM EFEX_ORDER_MATL T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ORDER T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid) t2 WHERE t1.efex_cust_id = t2.efex_cust_id )
      AND t1.valdtn_status = ods_constants.valdtn_invalid
      AND t1.outlet_flg = 'Y' 
      AND t1.distbr_flg = 'N'
      AND (cust_grade_ID IS NULL OR cust_type_id IS NULL OR cust_visit_freq_id IS NULL OR range_id IS NULL);


      v_rec_count := SQL%ROWCOUNT;

      COMMIT;

      IF v_rec_count > 0 THEN
          write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'There were [' || v_rec_count || '] INVALID customer set to EXCLUDED.');

          UPDATE efex_cust t1
          SET valdtn_status = ods_constants.valdtn_unchecked
          WHERE VALDTN_STATUS = ods_constants.valdtn_invalid;

          COMMIT;
      END IF;

      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'Set valdtn_status to UNCHECKED for customer without fully setup and HAVE transaction linked.');

      UPDATE efex_cust t1
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE EXISTS ( 
                        SELECT *
                        FROM 
                          ( 
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ROUTE_PLAN T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_CALL T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_TIMESHEET_CALL T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ASSMNT_ASSGNMNT T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ASSMNT T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_DISTBN T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_DISTBN_TOT T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_PMT T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_MRQ T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_CUST_NOTE T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT MATL_DISTBR_ID AS EFEX_CUST_ID
                           FROM EFEX_ORDER_MATL T1
                           WHERE VALDTN_STATUS =  ods_constants.valdtn_invalid
                           UNION
                           SELECT DISTINCT EFEX_CUST_ID
                           FROM EFEX_ORDER T1
                           WHERE VALDTN_STATUS = ods_constants.valdtn_invalid) t2 WHERE t1.efex_cust_id = t2.efex_cust_id )
      AND t1.valdtn_status = ods_constants.valdtn_excluded
      AND t1.outlet_flg = 'Y' 
      AND t1.distbr_flg = 'N'
      AND (cust_grade_ID IS NULL OR cust_type_id IS NULL OR cust_visit_freq_id IS NULL OR range_id IS NULL);

      v_rec_count := v_rec_count + SQL%ROWCOUNT;

      COMMIT;

      IF v_rec_count > 0 THEN
          write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 're-run customer validation');
          check_efex_cust(i_log_level+1, FALSE);
      END IF;

      write_log(ods_constants.data_type_generic, 'n/a', i_log_level + 1, 'ods_efex_validation.reset_new_cust_valdtn_status: Ended with update count [' || v_rec_count || ']');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.data_type_generic, 'n/a', 0, 'ods_efex_validation.reset_new_cust_valdtn_status: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END reset_new_cust_valdtn_status;

PROCEDURE validate_efex_cust_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count       PLS_INTEGER := 0;
    v_invalid_flg     BOOLEAN     := FALSE;
    v_cust_visit_freq NUMBER;
    v_invalid_count   NUMBER      := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_cust
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT t1.sales_terr_id, NVL(t3.bus_unit_id, -1) as bus_unit_id
      FROM 
        efex_cust t1,
        efex_sales_terr t3
      WHERE t1.sales_terr_id = t3.sales_terr_id (+)
        AND NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND t1.sales_terr_id IS NOT NULL
        AND t1.status = 'A'
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_range IS
      SELECT DISTINCT range_id, NVL(t3.bus_unit_id, -1) as bus_unit_id
      FROM         
        efex_cust t1,
        efex_sales_terr t3
      WHERE t1.sales_terr_id = t3.sales_terr_id (+)
        AND NOT EXISTS (SELECT * FROM efex_range t2 WHERE t1.range_id = t2.range_id AND valdtn_status = ods_constants.valdtn_valid)
        AND t1.status = 'A'
        AND t1.range_id IS NOT NULL
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_range csr_range%ROWTYPE;

    CURSOR csr_cust_type IS
      SELECT DISTINCT cust_type_id,  NVL(t3.bus_unit_id, -1) AS bus_unit_id
      FROM 
        efex_cust t1,
        efex_sales_terr t3
      WHERE t1.sales_terr_id = t3.sales_terr_id (+)
        AND NOT EXISTS (SELECT * FROM efex_cust_chnl t2 WHERE t1.cust_type_id = t2.cust_type_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND t1.status = 'A'
        AND t1.cust_type_id IS NOT NULL
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust_type csr_cust_type%ROWTYPE;

    CURSOR csr_affltn IS
      SELECT DISTINCT affltn_id, NVL(t3.bus_unit_id, -1) AS bus_unit_id
      FROM 
        efex_cust t1,
        efex_sales_terr t3
      WHERE t1.sales_terr_id = t3.sales_terr_id (+)
        AND NOT EXISTS (SELECT * FROM efex_affltn t2 WHERE t1.affltn_id = t2.affltn_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND t1.status = 'A'
        AND t1.affltn_id IS NOT NULL
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_affltn csr_affltn%ROWTYPE;

   CURSOR csr_cust_visit_freq IS
      SELECT 
        cust_visit_freq_id, cust_visit_freq, NVL(t2.bus_unit_id, -1) AS bus_unit_id
      FROM 
        efex_cust t1,
        efex_sales_terr t2
      WHERE t1.sales_terr_id = t2.sales_terr_id (+)
        AND t1.status = 'A'
        AND t1.cust_visit_freq_id IS NOT NULL
        AND t1.valdtn_status = ods_constants.valdtn_unchecked
      GROUP BY cust_visit_freq_id, cust_visit_freq, t2.bus_unit_id;
   rv_cust_visit_freq csr_cust_visit_freq%ROWTYPE;

   -- GRD customer should provide cust_code.
   CURSOR csr_cust_code_null IS
      SELECT NVL(t2.bus_unit_id, -1) AS bus_unit_id, COUNT(*) as rec_count
      FROM 
        efex_cust t1,
        efex_sales_terr t2
      WHERE t1.sales_terr_id = t2.sales_terr_id (+)
        and t1.cust_code IS NULL
        AND t1.distbr_flg = 'N'
        AND t1.outlet_flg = 'N'
        AND t1.status = 'A'
        AND t1.valdtn_status = ods_constants.valdtn_unchecked
      GROUP BY t2.bus_unit_id;

  rv_cust_code_null csr_cust_code_null%ROWTYPE;

   CURSOR csr_cust_code_invalid IS
      SELECT
        t1.efex_cust_id,
        t1.cust_code as efex_cust_code,
        t2.cust_code as grd_cust_code,
        NVL(t3.bus_unit_id, -1) as bus_unit_id
      FROM
        efex_cust t1,
        cust_dim  t2,
        efex_sales_terr t3
      WHERE
        t1.sales_terr_id = t3.sales_terr_id (+)
        AND t1.cust_code IS NOT NULL
        AND t1.outlet_flg = 'N'
        AND LPAD(t1.cust_code,10,'0') = t2.cust_code (+)
        AND t2.cust_code IS NULL
        AND t1.status = 'A'
        AND t1.valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust_code_invalid csr_cust_code_invalid%ROWTYPE;

   -- outlet customer should not provide cust_code
   CURSOR csr_cust_code_outlet IS
      SELECT NVL(t2.bus_unit_id, -1) AS bus_unit_id, COUNT(*) as rec_count
      FROM 
        efex_cust t1,
        efex_sales_terr t2
      WHERE t1.sales_terr_id = t2.sales_terr_id (+)
        AND t1.outlet_flg = 'Y'
        AND t1.cust_code IS NOT NULL
        AND t1.status = 'A'
        AND t1.valdtn_status = ods_constants.valdtn_unchecked
      GROUP BY t2.bus_unit_id;
   rv_cust_code_outlet csr_cust_code_outlet%ROWTYPE;

  BEGIN
    -- Validate efex_cust.
    write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_cust_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      UPDATE efex_cust
      SET valdtn_status = ods_constants.valdtn_unchecked
      WHERE valdtn_status = ods_constants.valdtn_invalid;

      -- Found any changes to customer, then reset all existing invalid customer related transaction record to unchecked
      reset_cust_xactn_valdtn_status(i_log_level+1);

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_cust, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_cust.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid sales_terr_id: ' || rv_sales_terr.sales_terr_id || ' found in efex_cust.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'One or more efex_cust records with Invalid or non-existant sales_terr_id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                   rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for invalid Range in efex_cust.');
      OPEN csr_range;
      LOOP
        FETCH csr_range INTO rv_range;
        EXIT WHEN csr_range%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid range_id: ' || rv_range.range_id || ' found in efex_cust.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'One or more efex_cust records with Invalid or non-existant range_id - ' || rv_range.range_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_range.bus_unit_id,
                                  c_range_ref,
                                  rv_range.range_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_range;

      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for invalid cust type in efex_cust.');
      OPEN csr_cust_type;
      LOOP
        FETCH csr_cust_type INTO rv_cust_type;
        EXIT WHEN csr_cust_type%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid cust_type_id: ' || rv_cust_type.cust_type_id || ' found in efex_cust.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'One or more efex_cust records with Invalid or non-existant cust_type_id - ' || rv_cust_type.cust_type_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust_type.bus_unit_id,
                                  c_cust_type_ref,
                                  rv_cust_type.cust_type_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);
      END LOOP;
      CLOSE csr_cust_type;

      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for invalid affltn id in efex_cust.');
      OPEN csr_affltn;
      LOOP
        FETCH csr_affltn INTO rv_affltn;
        EXIT WHEN csr_affltn%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid affltn_id: ' || rv_affltn.affltn_id || ' found in efex_cust.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'One or more efex_cust records with Invalid or non-existant affltn_id - ' || rv_affltn.affltn_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_affltn.bus_unit_id,
                                  c_affltn_ref,
                                  rv_affltn.affltn_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_affltn;

      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for null cust_grade in efex_cust.');

      v_rec_count := 0;
      OPEN csr_cust_code_null;

      LOOP
        FETCH csr_cust_code_null INTO rv_cust_code_null;
        EXIT WHEN csr_cust_code_null%NOTFOUND;

      
        IF rv_cust_code_null.rec_count > 0 THEN
           v_invalid_flg := TRUE;

           write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'There are [' || v_rec_count || '] customer records outlet_flg and distributor_flg = N and customer_code not provided');

           -- Add an entry into the validation reason tables.
           utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'There are [' || rv_cust_code_null.rec_count || '] efex_cust records with outlet_flg and distributor_flg = N and customer_code not provided.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust_code_null.bus_unit_id,
                                  'Unknown Customer type',
                                  NULL,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

         END IF;
      END LOOP;
      CLOSE csr_cust_code_null;


      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for invalid GRD customer cust_code in efex_cust.');
      OPEN csr_cust_code_invalid;
      LOOP
        FETCH csr_cust_code_invalid INTO rv_cust_code_invalid;
        EXIT WHEN csr_cust_code_invalid%NOTFOUND;
        v_invalid_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid cust_code: ' || rv_cust_code_invalid.efex_cust_code || ' found in efex_cust (not exists in cust_dim).');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'Invalid or non-existant cust_code - ' || rv_cust_code_invalid.efex_cust_code,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust_code_invalid.bus_unit_id,
                                  c_cust_dim_ref,
                                  rv_cust_code_invalid.efex_cust_code,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust_code_invalid;

      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for outlet customer providing cust_code in efex_cust.');

      v_rec_count := 0;
      OPEN csr_cust_code_outlet;
      LOOP
        FETCH csr_cust_code_outlet INTO rv_cust_code_outlet;
        EXIT WHEN csr_cust_code_outlet%NOTFOUND;

        IF rv_cust_code_outlet.rec_count > 0 THEN
           v_invalid_flg := TRUE;
 
           write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'There are [' || rv_cust_code_outlet.rec_count || '] Outlet customer records providing customer code');

           -- Add an entry into the validation reason tables
           utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'There are [' || v_rec_count || '] efex_cust records (outlet customer) with customer_code provided as well.',
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust_code_outlet.bus_unit_id,
                                  'Outlet GRD Customer',
                                  NULL,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

         END IF;
      END LOOP;
      CLOSE csr_cust_code_outlet;

      -- NEED to do this at the end because need to update the record valdtn_status here
      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for cust_visit_freq must be positive number in efex_cust.');
      OPEN csr_cust_visit_freq;
      LOOP
        FETCH csr_cust_visit_freq INTO rv_cust_visit_freq;
        EXIT WHEN csr_cust_visit_freq%NOTFOUND;
             BEGIN
               v_cust_visit_freq := TO_NUMBER(rv_cust_visit_freq.cust_visit_freq);
               IF v_cust_visit_freq < 0 THEN

                  write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid cust_visit_freq: ' || rv_cust_visit_freq.cust_visit_freq || ' found in efex_cust - must be positive number.');

                  -- Add an entry into the validation reason tables.
                  utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'One or more efex_cust records with Invalid cust_visit_freq (not a positive number) - ' || rv_cust_visit_freq.cust_visit_freq,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust_visit_freq.bus_unit_id,
                                  'cust_visit_freq',
                                  rv_cust_visit_freq.cust_visit_freq,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

                  UPDATE efex_cust
                  SET valdtn_status = ods_constants.valdtn_invalid
                  WHERE cust_visit_freq_id = rv_cust_visit_freq.cust_visit_freq_id
                    AND status = 'A'
                    AND valdtn_status = ods_constants.valdtn_unchecked;

                  v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

               END IF;
             EXCEPTION
               WHEN OTHERS THEN
                  -- Data type convertion error.

                  write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Invalid cust_visit_freq: ' || rv_cust_visit_freq.cust_visit_freq || ' found in efex_cust - must be a positive number.');

                  -- Add an entry into the validation reason tables.
                  utils.add_validation_reason(ods_constants.valdtn_type_efex_cust,
                                  'One or more efex_cust records with Invalid cust_visit_freq (not a positive number) - ' || rv_cust_visit_freq.cust_visit_freq,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust_visit_freq.bus_unit_id,
                                  'cust_visit_freq',
                                  rv_cust_visit_freq.cust_visit_freq,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

                  UPDATE efex_cust
                  SET valdtn_status = ods_constants.valdtn_invalid
                  WHERE cust_visit_freq_id = rv_cust_visit_freq.cust_visit_freq_id
                    AND status = 'A'
                    AND valdtn_status = ods_constants.valdtn_unchecked;

                  v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

             END;

      END LOOP;
      CLOSE csr_cust_visit_freq;

      IF v_invalid_flg THEN
         write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_cust.');

         UPDATE efex_cust t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND sales_terr_id IS NOT NULL
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         UPDATE efex_cust t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_range t2 WHERE t1.range_id = t2.range_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND range_id IS NOT NULL
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         UPDATE efex_cust t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust_chnl t2 WHERE t1.cust_type_id = t2.cust_type_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND cust_type_id IS NOT NULL
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         UPDATE efex_cust t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_affltn t2 WHERE t1.affltn_id = t2.affltn_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND affltn_id IS NOT NULL
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         -- GRD customer without cust_code.
         UPDATE efex_cust t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE
           cust_code IS NULL
           AND distbr_flg = 'N'
           AND outlet_flg = 'N'
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         -- Outlet customer with cust_code.
         UPDATE efex_cust t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE
           cust_code IS NOT NULL
           AND outlet_flg = 'Y'
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

         -- GRD customer with invalid cust_code.
         UPDATE efex_cust t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM cust_dim t2 WHERE LPAD(t1.cust_code,10,'0') = t2.cust_code)
           AND t1.cust_code IS NOT NULL
           AND t1.outlet_flg = 'N'
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;

         v_invalid_count := v_invalid_count + SQL%ROWCOUNT;

     END IF;

     IF v_invalid_count > 0 THEN

       COMMIT;
       write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'There were [' || v_invalid_count || '] records update with INVALID status in efex_cust.');

     END IF;

     write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_cust.');

     UPDATE efex_cust t1
     SET valdtn_status = ods_constants.valdtn_valid
     WHERE valdtn_status = ods_constants.valdtn_unchecked;

     write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'There were [' || SQL%ROWCOUNT || '] records update with VALID status in efex_cust.');

     COMMIT;

     write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'Check for invalid distbr_id in efex_cust.');

     -- NEED to be done after complete the customer validation.
     check_cust_distributors(i_log_level);

  END IF;

  write_log(ods_constants.valdtn_type_efex_cust, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_cust_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_cust, 'n/a', 0, 'ods_efex_validation.validate_efex_cust_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_cust_bulk;

PROCEDURE check_efex_user_sgmnt(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_user_sgmnt IS
      SELECT
        user_id,
        sgmnt_id
      FROM
        efex_user_sgmnt
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_user_sgmnt csr_efex_user_sgmnt%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_user_sgmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_user_sgmnt: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_user_sgmnt;
    FETCH csr_efex_user_sgmnt INTO rv_efex_user_sgmnt;
    WHILE csr_efex_user_sgmnt%FOUND LOOP

      -- PROCESS DATA
      validate_efex_user_sgmnt(i_log_level + 2, rv_efex_user_sgmnt.user_id, rv_efex_user_sgmnt.sgmnt_id);

      FETCH csr_efex_user_sgmnt INTO rv_efex_user_sgmnt;
    END LOOP;
    CLOSE csr_efex_user_sgmnt;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_user_sgmnt, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_user_sgmnt: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_user_sgmnt, 'n/a', 0, 'ods_efex_validation.check_efex_user_sgmnt: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_user_sgmnt;

  /*******************************************************************************
    NAME:       validate_efex_user_sgmnt
    PURPOSE:    This procedure validates a efex segment record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_user_sgmnt(
    i_log_level           IN ods.log.log_level%TYPE,
    i_user_id             IN efex_user_sgmnt.user_id%TYPE,
    i_sgmnt_id            IN efex_user_sgmnt.sgmnt_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_user_sgmnt.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count         PLS_INTEGER;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_user_sgmnt IS
      SELECT
        user_id,
        sgmnt_id,
        bus_unit_id
      FROM
        efex_user_sgmnt
      WHERE
        user_id = i_user_id
        AND sgmnt_id = i_sgmnt_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_user_sgmnt csr_efex_user_sgmnt%ROWTYPE;

  BEGIN
    OPEN csr_efex_user_sgmnt;
    FETCH csr_efex_user_sgmnt INTO rv_efex_user_sgmnt;
    IF csr_efex_user_sgmnt%FOUND THEN

      -- Clear the validation reason tables of this efex segment.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_user_sgmnt,
                                  rv_efex_user_sgmnt.bus_unit_id,
                                  i_user_id,
                                  i_sgmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

                      
      -- User id must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_user
      WHERE
        user_id = rv_efex_user_sgmnt.user_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_user_sgmnt, 'n/a', i_log_level + 1,    'efex_user_sgmnt user/sgmnt: [' ||
                                                                          i_user_id || '/' || i_sgmnt_id || ']' || 
                                                                          ': Invalid or non-existant user Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_user_sgmnt,
                                  'KEY [user/segment] - Invalid or non-existant User Id - ' || rv_efex_user_sgmnt.user_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_user_sgmnt.bus_unit_id,
                                  i_user_id,
                                  i_sgmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      -- segment id must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_user_sgmnt.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_user_sgmnt, 'n/a', i_log_level + 1,    'efex_user_sgmnt user/sgmnt: [' ||
                                                                          i_user_id || '/' || i_sgmnt_id || ']' || 
                                                                          ': Invalid or non-existant segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_user_sgmnt,
                                  'KEY [user/segment] - Invalid or non-existant segment Id - ' || rv_efex_user_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_user_sgmnt.bus_unit_id,
                                  i_user_id,
                                  i_sgmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

                  
      -- business id must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_user_sgmnt.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_user_sgmnt, 'n/a', i_log_level + 1,    'efex_user_sgmnt user/sgmnt: [' ||
                                                                          i_user_id || '/' || i_sgmnt_id || ']' || 
                                                                          ': Invalid or non-existant business unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_user_sgmnt,
                                  'KEY [user/segment] - Invalid or non-existant bus_unit_Id - ' || rv_efex_user_sgmnt.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_user_sgmnt.bus_unit_id,
                                  i_user_id,
                                  i_sgmnt_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      UPDATE
        efex_user_sgmnt
      SET
        valdtn_status = v_valdtn_status
      WHERE
        user_id = i_user_id
        AND sgmnt_id = i_sgmnt_id;

    END IF;
    CLOSE csr_efex_user_sgmnt;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_user_sgmnt;

PROCEDURE check_efex_cust_note(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- VARIABLE DECLARATIONS
    v_record_count PLS_INTEGER := 0;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_cust_note IS
      SELECT
        cust_note_id
      FROM
        efex_cust_note
      WHERE
        valdtn_status = ods_constants.valdtn_unchecked;
    rv_efex_cust_note csr_efex_cust_note%ROWTYPE;

  BEGIN
    -- Controlling loop. Process until absolutely no more records are found.
    write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_cust_note: Started.');

    -- Check to see whether there are any records to be processed.
    OPEN csr_efex_cust_note;
    FETCH csr_efex_cust_note INTO rv_efex_cust_note;
    WHILE csr_efex_cust_note%FOUND LOOP

      -- PROCESS DATA
      validate_efex_cust_note(i_log_level + 2, rv_efex_cust_note.cust_note_id);

      FETCH csr_efex_cust_note INTO rv_efex_cust_note;
    END LOOP;
    CLOSE csr_efex_cust_note;
    COMMIT;

    write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'ods_efex_validation.check_efex_cust_note: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', 0, 'ods_efex_validation.check_efex_cust_note: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  END check_efex_cust_note;

  /*******************************************************************************
    NAME:       validate_efex_cust_note
    PURPOSE:    This procedure validates a efex segment record.

    YYYY/MM   Author            Description
    -------   ------            -----------
    2007/10   John Cho          Created

  ********************************************************************************/
   PROCEDURE validate_efex_cust_note(
    i_log_level           IN ods.log.log_level%TYPE,
    i_cust_note_id        IN efex_cust_note.cust_note_id%TYPE
   ) IS

    -- VARIABLE DECLARATIONS
    v_valdtn_status efex_cust_note.valdtn_status%TYPE := ods_constants.valdtn_valid;
    v_count                   PLS_INTEGER;
    v_cust_note_created_date  DATE;

    -- CURSOR DECLARATIONS
    CURSOR csr_efex_cust_note IS
      SELECT
        efex_cust_id,
        sales_terr_id,
        sgmnt_id,
        bus_unit_id,
        cust_note_created
      FROM
        efex_cust_note
      WHERE
        cust_note_id = i_cust_note_id
        AND valdtn_status = ods_constants.valdtn_unchecked
      FOR UPDATE NOWAIT;
    rv_efex_cust_note csr_efex_cust_note%ROWTYPE;

  BEGIN
    OPEN csr_efex_cust_note;
    FETCH csr_efex_cust_note INTO rv_efex_cust_note;
    IF csr_efex_cust_note%FOUND THEN

      -- Clear the validation reason tables of this efex segment.
      utils.clear_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  rv_efex_cust_note.bus_unit_id,
                                  i_cust_note_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

                      
      -- efex_cust_id must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_cust
      WHERE
        efex_cust_id = rv_efex_cust_note.efex_cust_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_cust_note, 'n/a', i_log_level + 1,    'efex_cust_note cust_note_id/cust_id: [' ||
                                                                          i_cust_note_id || '/' || rv_efex_cust_note.efex_cust_id || ']' || 
                                                                          ': Invalid or non-existant customer Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'Invalid or non-existant Customer Id - ' || rv_efex_cust_note.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_cust_note.bus_unit_id,
                                  i_cust_note_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- Sales Terr ID must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sales_terr
      WHERE
        sales_terr_id = rv_efex_cust_note.sales_terr_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_cust_note, 'n/a', i_log_level + 1,    'efex_cust_note cust_note_id/cust_id: [' ||
                                                                          i_cust_note_id || '/' || rv_efex_cust_note.efex_cust_id || ']' || 
                                                                          ': Invalid or non-existant sales terr Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'Invalid or non-existant sales Terr Id - ' || rv_efex_cust_note.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_cust_note.bus_unit_id,
                                  i_cust_note_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;


      -- Segment ID must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_sgmnt
      WHERE
        sgmnt_id = rv_efex_cust_note.sgmnt_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_cust_note, 'n/a', i_log_level + 1,    'efex_cust_note cust_note_id/cust_id: [' ||
                                                                          i_cust_note_id || '/' || rv_efex_cust_note.efex_cust_id || ']' || 
                                                                          ': Invalid or non-existant segment Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'Invalid or non-existant segment Id - ' || rv_efex_cust_note.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_cust_note.bus_unit_id,
                                  i_cust_note_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

                  
      -- Dusiness ID must exist and be valid.
      v_count := 0;
      SELECT
        count(*) INTO v_count
      FROM
        efex_bus_unit
      WHERE
        bus_unit_id = rv_efex_cust_note.bus_unit_id
        AND valdtn_status = ods_constants.valdtn_valid;        

      IF v_count <> 1 THEN
        v_valdtn_status := ods_constants.valdtn_invalid;
        write_log(ods_constants.data_type_efex_cust_note, 'n/a', i_log_level + 1,    'efex_cust_note cust_note_id/cust_id: [' ||
                                                                          i_cust_note_id || '/' || rv_efex_cust_note.efex_cust_id || ']' || 
                                                                          ': Invalid or non-existant business unit Id.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'Invalid or non-existant bus_unit_Id - ' || rv_efex_cust_note.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_cust_note.bus_unit_id,
                                  i_cust_note_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);
      END IF;

      -- cust_note_created must be in a date format
      IF rv_efex_cust_note.cust_note_created IS NOT NULL THEN
         BEGIN
           v_cust_note_created_date := TO_DATE (rv_efex_cust_note.cust_note_created, 'DD/MM/YYYY HH24:MI:SS');
         EXCEPTION
           WHEN OTHERS THEN
              v_valdtn_status := ods_constants.valdtn_invalid;
              write_log(ods_constants.data_type_efex_cust_note, 'n/a', i_log_level + 1,    'efex_cust_note cust_note_id/cust_id: [' ||
                                                                          i_cust_note_id || '/' || rv_efex_cust_note.efex_cust_id || ']' || 
                                                                          ': Invalid - cust_note_created is not a date.');

              -- Add an entry into the validation reason tables.
              utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'Invalid: cust_note_created must be in [DD/MM/YYYY HH24:MI:SS] Date Format - ' || rv_efex_cust_note.cust_note_created,
                                  ods_constants.valdtn_severity_critical,
                                  rv_efex_cust_note.bus_unit_id,
                                  i_cust_note_id,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  i_log_level + 1);

         END;
      END IF;


      UPDATE
        efex_cust_note
      SET
        valdtn_status = v_valdtn_status
      WHERE
        cust_note_id = i_cust_note_id;

    END IF;
    CLOSE csr_efex_cust_note;

  EXCEPTION
    WHEN resource_busy THEN    -- Ignore records locked by competing ODS_EFEX_VALIDATION jobs.
      NULL;

  END validate_efex_cust_note;

PROCEDURE validate_efex_cust_note_bulk(
    i_log_level IN ods.log.log_level%TYPE) IS

    -- AUTONOMOUS TRANSACTION
    PRAGMA AUTONOMOUS_TRANSACTION;

    -- VARIABLE DECLARATIONS
    v_rec_count          PLS_INTEGER := 0;
    v_invalid_cust_flg   BOOLEAN := FALSE;
    v_invalid_terr_flg   BOOLEAN := FALSE;
    v_invalid_sgmnt_flg  BOOLEAN := FALSE;
    v_invalid_bus_flg    BOOLEAN := FALSE;

    -- CURSOR DECLARATIONS
    CURSOR csr_counter IS
      SELECT COUNT(*) AS rec_count
      FROM efex_cust_note
      WHERE valdtn_status = ods_constants.valdtn_unchecked;

    CURSOR csr_cust IS
      SELECT DISTINCT efex_cust_id, bus_unit_id
      FROM efex_cust_note t1
      WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_cust csr_cust%ROWTYPE;

    CURSOR csr_sales_terr IS
      SELECT DISTINCT sales_terr_id, bus_unit_id
      FROM efex_cust_note t1
      WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sales_terr csr_sales_terr%ROWTYPE;

    CURSOR csr_sgmnt IS
      SELECT DISTINCT sgmnt_id, bus_unit_id
      FROM efex_cust_note t1
      WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_sgmnt csr_sgmnt%ROWTYPE;

    CURSOR csr_bus_unit IS
      SELECT DISTINCT bus_unit_id
      FROM efex_cust_note t1
      WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id)
        AND status = 'A'
        AND valdtn_status = ods_constants.valdtn_unchecked;
    rv_bus_unit csr_bus_unit%ROWTYPE;


  BEGIN
    -- Validate efex_cust_notes
    write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_cust_note_bulk: Started.');

    OPEN csr_counter;
    FETCH csr_counter INTO v_rec_count;
    CLOSE csr_counter;

    IF v_rec_count > 0 THEN

      -- Clear validation reason tables for the validation type.
      clear_validation_reason (ods_constants.valdtn_type_efex_cust_note, i_log_level + 1);

      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Check for invalid customers in efex_cust_note.');
      OPEN csr_cust;
      LOOP
        FETCH csr_cust INTO rv_cust;
        EXIT WHEN csr_cust%NOTFOUND;

        v_invalid_cust_flg := TRUE;
        write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Invalid efex_cust_id/bus_unit_id: [' || rv_cust.efex_cust_id || '/' || rv_cust.bus_unit_id || '] found in efex_cust_note.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'One or more efex_cust_note records with Invalid or non-existant efex_cust_id - ' || rv_cust.efex_cust_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_cust.bus_unit_id,
                                  c_cust_ref,
                                  rv_cust.efex_cust_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_cust;

      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Check for invalid sales terr in efex_cust_note.');
      OPEN csr_sales_terr;
      LOOP
        FETCH csr_sales_terr INTO rv_sales_terr;
        EXIT WHEN csr_sales_terr%NOTFOUND;
        v_invalid_terr_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Invalid sales_terr_id/bus_unit_id: [' || rv_sales_terr.sales_terr_id || '/' || rv_sales_terr.bus_unit_id || '] found in efex_cust_note.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'One or more efex_cust_note records with Invalid or non-existant sales_terr_id - ' || rv_sales_terr.sales_terr_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sales_terr.bus_unit_id,
                                  c_sales_terr_ref,
                                  rv_sales_terr.sales_terr_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sales_terr;

      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Check for invalid segment in efex_cust_note.');
      OPEN csr_sgmnt;
      LOOP
        FETCH csr_sgmnt INTO rv_sgmnt;
        EXIT WHEN csr_sgmnt%NOTFOUND;
        v_invalid_sgmnt_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Invalid sgmnt_id/bus_unit_id: [' || rv_sgmnt.sgmnt_id || rv_sgmnt.bus_unit_id || '] found in efex_cust_note.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'One or more efex_cust_note records with Invalid or non-existant sgmnt_id - ' || rv_sgmnt.sgmnt_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_sgmnt.bus_unit_id,
                                  c_sgmnt_ref,
                                  rv_sgmnt.sgmnt_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_sgmnt;

      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Check for invalid business unit in efex_cust_note.');
      OPEN csr_bus_unit;
      LOOP
        FETCH csr_bus_unit INTO rv_bus_unit;
        EXIT WHEN csr_bus_unit%NOTFOUND;
        v_invalid_bus_flg := TRUE;

        write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Invalid bus_unit_id: ' || rv_bus_unit.bus_unit_id || ' found in efex_cust_note.');

        -- Add an entry into the validation reason tables.
        utils.add_validation_reason(ods_constants.valdtn_type_efex_cust_note,
                                  'One or more efex_cust_note records with Invalid or non-existant bus_unit_id - ' || rv_bus_unit.bus_unit_id,
                                  ods_constants.valdtn_severity_critical,
                                  rv_bus_unit.bus_unit_id,
                                  c_bus_unit_ref,
                                  rv_bus_unit.bus_unit_id,
                                  NULL,
                                  NULL,
                                  c_bulk,
                                  i_log_level + 1);

      END LOOP;
      CLOSE csr_bus_unit;

      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Update valdtn_status for the invalid record(s) in efex_cust_note.');

      IF v_invalid_cust_flg = TRUE THEN
         UPDATE efex_cust_note t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_cust t2 WHERE t1.efex_cust_id = t2.efex_cust_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_terr_flg = TRUE THEN
         UPDATE efex_cust_note t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sales_terr t2 WHERE t1.sales_terr_id = t2.sales_terr_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_sgmnt_flg = TRUE THEN
         UPDATE efex_cust_note t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_sgmnt t2 WHERE t1.sgmnt_id = t2.sgmnt_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      IF v_invalid_bus_flg = TRUE THEN
         UPDATE efex_cust_note t1
         SET valdtn_status = ods_constants.valdtn_invalid
         WHERE NOT EXISTS (SELECT * FROM efex_bus_unit t2 WHERE t1.bus_unit_id = t2.bus_unit_id AND t2.valdtn_status = ods_constants.valdtn_valid)
           AND status = 'A'
           AND valdtn_status = ods_constants.valdtn_unchecked;
      END IF;

      COMMIT;

      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'Update valdtn_status for the valid record(s) in efex_cust_note.');

      UPDATE efex_cust_note t1
      SET valdtn_status = ods_constants.valdtn_valid
      WHERE valdtn_status = ods_constants.valdtn_unchecked;
      COMMIT;

  END IF;

  write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', i_log_level + 1, 'ods_efex_validation.validate_efex_cust_note_bulk: Ended.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      write_log(ods_constants.valdtn_type_efex_cust_note, 'n/a', 0, 'ods_efex_validation.validate_efex_cust_note_bulk: FATAL ERROR: ' || SUBSTR(SQLERRM, 1, 512));

END validate_efex_cust_note_bulk;

END ods_efex_validation; 
/
