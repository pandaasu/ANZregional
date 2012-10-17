create or replace
PACKAGE         scheduled_efex_aggr_stg_1 IS

/*******************************************************************************
  NAME:      run_efex_aggregation_stage_1
  PURPOSE:   This procedure is the main routine, which calls the other package
             procedures and functions to aggregate all market driven efex data 
             from the dim tables to the fact tables.

             The scheduled efex aggregation staage 1 process is initiated by an 
             Oracle job that should be run after efex to scheduled efex 
             flattening has completed for a specific market.

             The scheduled job will call this efex aggregation procedure passing
             Aggregation Date, Market Id and Company Code parameters.  
             Aggregation Date will be set to SYSDATE when called via the 
             scheduled job.

   NOTES:  The sequence of the function call within this procedure should not be
           changed because some of the data load rely on the load sequence.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   14/06/2011 Craig Drew           Created this prackage as a subset of
                                        Efex_scheduled_aggregation to break out 
                                        Flattening from Aggreagation
  1.1   29/08/2012 Mal Chambeyron       Add lics_setting_configuration.retrieve_setting() for email

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     DATE     Aggregation Date                     20071001
  2    IN     NUMBER   Market Id   (must be 1 or 5)         1
  3    IN     NUMBER   Company Code (must be 147 or 149)    147
  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_efex_aggregation_stage_1 (
  i_aggregation_date IN DATE,
  i_market_id IN NUMBER,
  i_company_code IN VARCHAR2);

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the log table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2007 Kris Lee            Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Data Type                            Generic
  2    IN     VARCHAR2 Sort Field                           Aggregation Date
  3    IN     NUMBER   Log Level                            1
  4    IN     VARCHAR2 Log Text                             Starting Efex Aggregations

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE);

/*******************************************************************************
  NAME:      format_cust_code
  PURPOSE:   This function format the GRD cust_code to SAP format.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   9/10/2007 Kris Lee            Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2  customer code                        12345678
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION format_cust_code (
  i_cust_code IN VARCHAR2,
  i_log_level  IN ods.log.log_level%TYPE
  ) RETURN varchar2;

END scheduled_efex_aggr_stg_1; 
/

create or replace
PACKAGE BODY         scheduled_efex_aggr_stg_1 IS

  c_future_date          CONSTANT DATE := TO_DATE('99991231','YYYYMMDD');
  c_tp_budget_target_id  CONSTANT efex_target_fact.efex_target_id%TYPE := 12;
  p_market_id            NUMBER;
  p_company_code         VARCHAR2(10);

  con_ema_group constant varchar2(32) := 'EFEX_CDW_POLLER'; 
  con_ema_code constant varchar2(32) := 'EMAIL_GROUP';
  con_email constant varchar2(256) := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);  
  
FUNCTION efex_route_sched_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_route_plan_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_call_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_timesheet_call_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_timesheet_day_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_assmnt_assgnmnt_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_assmnt_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_range_matl_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_turnin_order_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_pmt_deal_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_pmt_rtn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_mrq_matl_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_assoc_sgmnt_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_cust_note_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_target_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

PROCEDURE run_efex_aggregation_stage_1 (
  i_aggregation_date IN DATE,
  i_market_id IN NUMBER,
  i_company_code IN VARCHAR2) IS

  -- VARIABLE DECLARATIONS
  v_processing_msg   constants.message_string;
  v_company_code     company.company_code%TYPE;
  v_aggregation_date DATE;
  v_log_level        ods.log.log_level%TYPE;
  v_status           NUMBER;
  v_db_name          VARCHAR2(256) := NULL;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

BEGIN
  -- Initialise variables.
  v_log_level := 0;
  p_market_id := i_market_id;
  p_company_code := i_company_code;

  -- Get the Database name
  SELECT
    UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
  INTO
    v_db_name
  FROM
    dual;

  -- Start scheduled efex aggregation.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled EFEX Aggregation Stage 1 - Start');

  -- Market id must be valid.
  IF p_market_id is null OR (p_market_id != 1 AND p_market_id != 5) THEN
      v_processing_msg := 'Invalid market id [' || TO_CHAR(i_market_id) || '].';
      RAISE e_processing_error;
  END IF;

  -- Company code must be valid.
  IF p_company_code is null OR (p_company_code != '147' AND p_company_code != '149') THEN
      v_processing_msg := 'Invalid company code [' || p_company_code || '].';
      RAISE e_processing_error;
  END IF;

  -- Convert the inputted aggregation date to standard date format.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Converting the inputted Aggregation' ||
    ' Date [' || TO_CHAR(i_aggregation_date) || '] to standard date format.');
  BEGIN
    IF i_aggregation_date IS NULL THEN
      RAISE e_processing_error;
    ELSE
      v_aggregation_date := i_aggregation_date;
      v_aggregation_date := TO_DATE(TO_CHAR(v_aggregation_date, 'YYYYMMDD'), 'YYYYMMDD');
    END IF;
    write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Will be flattening and aggregating EFEX data for date: ' || v_aggregation_date || ' and market: ' || p_market_id || '.');
  EXCEPTION
    WHEN OTHERS THEN
      v_processing_msg := 'Unable to convert the inputted Aggregation Date [' || TO_CHAR(i_aggregation_date, 'YYYYMMDD') || '] from string to date format.';
      RAISE e_processing_error;
  END;


  /************************************
   ***   CALLING FACT AGGREGATIONS  ***
   ************************************/

  -- Calling the efex_route_sched_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_route_sched_fact_aggr function.');
  v_status := efex_route_sched_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_route_sched_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_route_plan_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_route_plan_fact_aggr function.');
  v_status := efex_route_plan_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_route_plan_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_call_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_call_fact_aggr function.');
  v_status := efex_call_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_call_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_timesheet_call_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_timesheet_call_fact_aggr function.');
  v_status := efex_timesheet_call_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_timesheet_call_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_timesheet_day_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_timesheet_day_fact_aggr function.');
  v_status := efex_timesheet_day_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_timesheet_day_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_assmnt_assgnmnt_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_assmnt_assgnmnt_fact_aggr function.');
  v_status := efex_assmnt_assgnmnt_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_assmnt_assgnmnt_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_assmnt_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_assmnt_fact_aggr function.');
  v_status := efex_assmnt_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_assmnt_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_range_matl_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_range_matl_fact_aggr function.');
  v_status := efex_range_matl_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_range_matl_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_turnin_order_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_turnin_order_fact_aggr function.');
  v_status := efex_turnin_order_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_turnin_order_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_pmt_deal_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_pmt_deal_fact_aggr function.');
  v_status := efex_pmt_deal_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_pmt_deal_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_pmt_rtn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_pmt_rtn_fact_aggr function.');
  v_status := efex_pmt_rtn_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_pmt_rtn_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_mrq_matl_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_mrq_matl_fact_aggr function.');
  v_status := efex_mrq_matl_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_mrq_matl_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_assoc_sgmnt_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_assoc_sgmnt_fact_aggr function.');
  v_status := efex_assoc_sgmnt_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_assoc_sgmnt_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_cust_note_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_cust_note_fact_aggr function.');
  v_status := efex_cust_note_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_cust_note_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_target_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_target_fact_aggr function.');
  v_status := efex_target_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_target_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- End scheduled efex aggregation processing.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Efex Aggregation Stage 1 - End');
  
  -- utils.send_short_email('Group_ANZ_Venus_Production_Notification@smtp.ap.mars', 'Scheduled Efex Aggregation Stage 1', 'Scheduled Efex Aggregation Stage 1 Completed for date: ' || v_aggregation_date || ' and market: ' || p_market_id);
  utils.send_short_email(con_email, 'Scheduled Efex Aggregation Stage 1', 'Scheduled Efex Aggregation Stage 1 Completed for date: ' || v_aggregation_date || ' and market: ' || p_market_id);

EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_EFEX_AGGR_STG_1.RUN_EFEX_AGGREGATION_STAGE_1: ERROR: ' || v_processing_msg);

    utils.send_email_to_group(ods_constants.job_type_efex_aggregation,
                              'MFANZ CDW Scheduled EFEX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_EFEX_AGGR_STG_1.RUN_EFEX_AGGREGATION_STAGE_1: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_EFEX_AGGR_STG_1.RUN_EFEX_AGGREGATION_STAGE_1: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    utils.send_email_to_group(ods_constants.job_type_efex_aggregation,
                              'MFANZ CDW Scheduled EFEX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_EFEX_AGGR_STG_1.RUN_EFEX_AGGREGATION_STAGE_1: ERROR: ' || SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

END run_efex_aggregation_stage_1;


/****************************
 ***   FACT AGGREGATIONS  ***
 ****************************/
FUNCTION efex_route_sched_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count            NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex route sched modified yesterday.
  CURSOR csr_efex_route_sched_count IS
    SELECT count(*) AS rec_count
    FROM efex_route_sched
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(route_sched_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_route_sched_fact aggregation.
  write_log(ods_constants.data_type_efex_route_sched, 'N/A', i_log_level + 1, 'Start - efex_route_sched_fact aggregation.');

  -- Fetch the record from the csr_efex_route_sched_count cursor.
  OPEN  csr_efex_route_sched_count;
  FETCH csr_efex_route_sched_count INTO v_rec_count;
  CLOSE csr_efex_route_sched_count;

  -- If any efex_route_sched records modified yesterday.
  write_log(ods_constants.data_type_efex_route_sched, 'N/A', i_log_level + 2, 'EFEX route sched received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_route_sched, 'N/A', i_log_level + 2, 'Delete efex_route_sched_fact record with same user id and schedule date as received first.');

     DELETE
     FROM efex_route_sched_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_route_sched t2
                   WHERE
                     t1.efex_assoc_id = t2.user_id
                     AND t1.route_sched_time = t2.route_sched_date
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.route_sched_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_route_sched, 'N/A', i_log_level + 2, 'efex_route_sched_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_route_sched, 'N/A', i_log_level + 2, 'INSERT into efex_route_sched_fact for the records received yesterday.');

     INSERT INTO efex_route_sched_fact
       (
        efex_assoc_id,
        route_sched_time,
        route_sched_date,
        company_code,
        tot_scanned,
        tot_sched,
        tot_skipped,
        tot_errors,
        tot_calls
       )
     SELECT
       user_id,
       route_sched_date,
       TRUNC(route_sched_date),
       p_company_code as company_code,
       tot_scanned,
       tot_sched,
       tot_skipped,
       tot_errors,
       tot_calls
     FROM
       efex_route_sched
     WHERE
       valdtn_status = ods_constants.valdtn_valid
       AND trunc(route_sched_lupdt) = i_aggregation_date
       AND efex_mkt_id = p_market_id
       AND status = 'A';

     write_log(ods_constants.data_type_efex_route_sched, 'N/A', i_log_level + 2, 'Insert count [' || SQL%ROWCOUNT || '] Active only');

     COMMIT;

  END IF;

  write_log(ods_constants.data_type_efex_route_sched, 'N/A', i_log_level + 2, 'Complete - efex_route_sched_fact aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_route_sched,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.EFEX_ROUTE_SCHED_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_route_sched_fact_aggr;


FUNCTION efex_route_plan_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count            NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex order modified yesterday.
  CURSOR csr_efex_route_plan_count IS
    SELECT count(*) AS rec_count
    FROM efex_route_plan
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(route_plan_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_route_plan_fact aggregation.
  write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 1, 'Start - efex_route_plan_fact aggregation.');

  -- Fetch the record from the csr_efex_route_plan_count cursor.
  OPEN  csr_efex_route_plan_count;
  FETCH csr_efex_route_plan_count INTO v_rec_count;
  CLOSE csr_efex_route_plan_count;

  -- If any efex_route_plan records modified yesterday.
  write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 2, 'EFEX route plan received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 2, 'Delete efex_route_plan_fact record with same user id, plan date and cust id as received first.');

     DELETE
     FROM efex_route_plan_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_route_plan t2
                   WHERE
                     t2.user_id = t1.efex_assoc_id
                     AND t2.route_plan_date = t1.route_plan_date
                     AND t2.efex_cust_id = t1.efex_cust_id
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.route_plan_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 2, 'efex_route_plan_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 2, 'INSERT active records into efex_route_plan_fact that received yesterday.');

     INSERT INTO efex_route_plan_fact
       (
        route_plan_date,
        cust_dtl_code,
        efex_assoc_id,
        route_plan_order,
        company_code,
        efex_cust_id,
        sales_terr_code,
        efex_sales_terr_id,
        efex_sgmnt_id,
        efex_bus_unit_id,
        planned_call
       )
     SELECT
        t1.route_plan_date,
        t2.cust_dtl_code,
        t1.user_id,
        t1.route_plan_order,
        p_company_code,
        t1.efex_cust_id,
        t3.sales_terr_code,
        t1.sales_terr_id,
        t1.sgmnt_id,
        t1.bus_unit_id,
        1
     FROM
       efex_route_plan t1,
       efex_cust_dtl_dim t2,
       efex_sales_terr_dim t3
     WHERE
       t1.valdtn_status = ods_constants.valdtn_valid
       AND trunc(t1.route_plan_lupdt) = i_aggregation_date
       AND t1.efex_mkt_id = p_market_id
       AND t1.status = 'A'
       AND t1.efex_cust_id = t2.efex_cust_id
       AND t2.last_rec_flg = 'Y'
       AND t1.sales_terr_id = t3.efex_sales_terr_id
       AND t3.last_rec_flg = 'Y';

     write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 2, 'Insert count [' || SQL%ROWCOUNT || '] Active only');

     COMMIT;

  END IF;

  write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 2, 'Complete - efex_route_plan_fact aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_route_plan,'ERROR',i_log_level+1,
             'planULED_EFEX_AGGREGATION.EFEX_ROUTE_PLAN_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_route_plan_fact_aggr;


FUNCTION efex_call_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count            NUMBER := 0;
  v_callback_flg         VARCHAR2(1) := 'N';
  v_call_count           NUMBER := 0;
  v_next_call_date       DATE;
  v_del_count            NUMBER := 0;
  v_upd_count            NUMBER := 0;
  v_ins_count            NUMBER := 0;
  v_efex_cust_id         efex_cust.efex_cust_id%TYPE;
  v_efex_assoc_caller_id efex_user.user_id%TYPE;
  v_call_yyyyppw         mars_date_dim.mars_week%TYPE;
  v_call_date            DATE;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether any efex call modified yesterday.
  CURSOR csr_efex_call_count IS
    SELECT count(*) AS rec_count
    FROM efex_call
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(call_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  CURSOR csr_efex_call IS
    SELECT
      t1.call_date                 as call_start_time,
      t1.user_id                   as efex_assoc_caller_id,
      t1.sales_terr_user_id        as efex_assoc_id,
      t1.efex_cust_id,
      t1.sales_terr_id             as efex_sales_terr_id,
      t1.sgmnt_id                  as efex_sgmnt_id,
      t1.bus_unit_id               as efex_bus_unit_id,
      TRUNC(t1.call_date)          as call_date,
      t1.end_date                  as call_end_time,
      CASE WHEN (end_date IS NULL) THEN NULL
           WHEN (t1.end_date < call_date) THEN NULL
           ELSE (t1.end_date - t1.call_date)*1440 END as call_duration,  -- in minutes
      t2.mars_week                 as call_yyyyppw,
      t3.call_type_code,
      t1.status
    FROM
      efex_call t1,
      mars_date_dim t2,
      efex_call_type_dim t3
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(call_lupdt) = i_aggregation_date
      AND t1.efex_mkt_id = p_market_id
      AND t1.status = 'A'  -- only the active record
      AND TRUNC(t1.call_date) = t2.calendar_date(+)
      AND t1.call_type = t3.call_type (+)
    ORDER BY
      t1.efex_cust_id,
      t1.call_date;   -- need these ordering to properly determine the callback_flg
  rv_efex_call csr_efex_call%ROWTYPE;

  -- Select the same mars week call count for the customer.
  CURSOR csr_yyyyppw_call_count IS
    SELECT
      COUNT(*) as call_count
    FROM
      efex_call_fact
    WHERE
      efex_cust_id = v_efex_cust_id
      AND call_yyyyppw = v_call_yyyyppw;

  -- Select next planned call date for the customer.
  CURSOR csr_next_call_date IS
    SELECT
      MIN(route_plan_date) as next_call_date
    FROM
      efex_route_plan_fact
    WHERE
      efex_cust_id = v_efex_cust_id
      AND route_plan_date > v_call_date;

BEGIN
  -- Starting efex_call_fact aggregation.
  write_log(ods_constants.data_type_efex_call, 'N/A', i_log_level + 1, 'Start - efex_call_fact aggregation.');

  -- Fetch the record from the csr_efex_call_count cursor.
  OPEN  csr_efex_call_count;
  FETCH csr_efex_call_count INTO v_rec_count;
  CLOSE csr_efex_call_count;

  -- If any efex_call records modified yesterday.
  write_log(ods_constants.data_type_efex_call, 'N/A', i_log_level + 2, 'EFEX call received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_call, 'N/A', i_log_level + 2, 'Delete from efex_call_fact record with status changed to X first.');

     DELETE
     FROM efex_call_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_call t2
                   WHERE
                     t2.efex_cust_id = t1.efex_cust_id
                     AND t2.call_date = t1.call_start_time
                     AND t2.user_id = t1.efex_assoc_caller_id
                     AND t2.status = 'X'
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.call_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_route_plan, 'N/A', i_log_level + 2, 'efex_call_fact delete count [' || SQL%ROWCOUNT || ']');

     FOR rv_efex_call IN csr_efex_call LOOP

       BEGIN
           -- assign variables used by the cursors
           v_efex_cust_id := rv_efex_call.efex_cust_id;
           v_efex_assoc_caller_id := rv_efex_call.efex_assoc_caller_id;
           v_call_yyyyppw := rv_efex_call.call_yyyyppw;
           v_call_date := rv_efex_call.call_start_time;

           -- count number of call for this call_yyyyppw (mars_week)
           OPEN csr_yyyyppw_call_count;
           FETCH csr_yyyyppw_call_count INTO v_call_count;
           CLOSE csr_yyyyppw_call_count;

           -- determine the callback flag based on number of call this week
           IF v_call_count > 0 THEN
              v_callback_flg := 'Y';
           ELSE
              v_callback_flg := 'N';
           END IF;

           -- get the planned next call date
           OPEN csr_next_call_date;
           FETCH csr_next_call_date INTO v_next_call_date;
           CLOSE csr_next_call_date;

           -- try to update first
           UPDATE
             efex_call_fact
           SET
             efex_assoc_id = rv_efex_call.efex_assoc_id,
             call_type_code = rv_efex_call.call_type_code,
             call_end_time = rv_efex_call.call_end_time,
             call_duration = rv_efex_call.call_duration,
             callback_flg_code = (SELECT callback_flg_code from efex_callback_flg where callback_flg = v_callback_flg),
             next_call_date = v_next_call_date
           WHERE
             efex_cust_id = rv_efex_call.efex_cust_id
             AND efex_assoc_caller_id = rv_efex_call.efex_assoc_caller_id
             AND call_start_time = rv_efex_call.call_start_time;

           v_upd_count := v_upd_count + SQL%ROWCOUNT;

           -- no record found to update, then insert
           IF SQL%ROWCOUNT = 0 THEN

              INSERT INTO efex_call_fact
                (
                  call_start_time,
                  cust_dtl_code,
                  call_yyyyppw,
                  efex_assoc_caller_id,
                  company_code,
                  efex_assoc_id,
                  efex_cust_id,
                  sales_terr_code,
                  efex_sales_terr_id,
                  efex_sgmnt_id,
                  efex_bus_unit_id,
                  call_type_code,
                  call_date,
                  call_end_time,
                  call_duration,
                  callback_flg_code,
                  call,
                  next_call_date
                )
              SELECT
                rv_efex_call.call_start_time,
                t1.cust_dtl_code,
                rv_efex_call.call_yyyyppw,
                rv_efex_call.efex_assoc_caller_id,
                p_company_code,
                rv_efex_call.efex_assoc_id,
                rv_efex_call.efex_cust_id,
                t2.sales_terr_code,
                rv_efex_call.efex_sales_terr_id,
                rv_efex_call.efex_sgmnt_id,
                rv_efex_call.efex_bus_unit_id,
                rv_efex_call.call_type_code,
                rv_efex_call.call_date,
                rv_efex_call.call_end_time,
                rv_efex_call.call_duration,
                t3.callback_flg_code,
                1,
                v_next_call_date
              FROM
                efex_cust_dtl_dim t1,
                efex_sales_terr_dim t2,
                efex_callback_flg t3
              WHERE
                t1.efex_cust_id = rv_efex_call.efex_cust_id
                AND t1.last_rec_flg = 'Y'
                AND t2.efex_sales_terr_id = rv_efex_call.efex_sales_terr_id
                AND t2.last_rec_flg = 'Y'
                AND t3.callback_flg = v_callback_flg;

              v_ins_count := v_ins_count + SQL%ROWCOUNT;

              -- update the active efex_cust_dtl_dim last call date
              UPDATE efex_cust_dtl_dim
              SET last_call_date = CASE WHEN (last_call_date IS NULL OR last_call_date < rv_efex_call.call_date)
                                         THEN rv_efex_call.call_date ELSE last_call_date END
              WHERE efex_cust_id = rv_efex_call.efex_cust_id
                AND last_rec_flg = 'Y';

           END IF;
      EXCEPTION
        WHEN OTHERS THEN
           write_log(ods_constants.data_type_efex_call, 'N/A', i_log_level + 2, 'Error cust_id/call_id/call_date [' || rv_efex_call.efex_cust_id ||
             '/' || rv_efex_call.efex_assoc_caller_id || '/' || rv_efex_call.call_date || '] Error:' || SUBSTR(SQLERRM, 1, 512));

           RAISE e_processing_error;

      END;

     END LOOP;

     COMMIT;

  END IF;

  write_log(ods_constants.data_type_efex_call, 'N/A', i_log_level + 2, 'Complete - efex_call_fact aggregation with ins/upd count [' ||
             v_ins_count || '/' || v_upd_count || ']');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN e_processing_error THEN
    ROLLBACK;
    RETURN constants.error;

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_call,'ERROR',i_log_level+1,
             'planULED_EFEX_AGGREGATION.EFEX_CALL_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_call_fact_aggr;


FUNCTION efex_timesheet_call_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex material subgroup modified yesterday.
  CURSOR csr_timesheet_call_count IS
    SELECT count(*) AS rec_count
    FROM efex_timesheet_call
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(timesheet_call_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_timesheet_call_fact aggregation.
  write_log(ods_constants.data_type_efex_tmesht_call, 'N/A', i_log_level + 1, 'Start - efex_timesheet_call_fact aggregation.');

  -- Fetch the record from the csr_timesheet_call_count cursor.
  OPEN  csr_timesheet_call_count;
  FETCH csr_timesheet_call_count INTO v_rec_count;
  CLOSE csr_timesheet_call_count;

  -- If any efex_timesheet_call records modified yesterday.
  write_log(ods_constants.data_type_efex_tmesht_call, 'N/A', i_log_level + 2, 'efex_timesheet_call received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_tmesht_call, 'N/A', i_log_level + 2, 'Delete efex_timesheet_call_fact with status updated to X first.');

     DELETE
     FROM efex_timesheet_call_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_timesheet_call t2
                   WHERE
                     t2.efex_cust_id = t1.efex_cust_id
                     AND t2.timesheet_date = t1.timesheet_date
                     AND t2.user_id = t1.efex_assoc_id
                     AND t2.status = 'X'
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.timesheet_call_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_tmesht_call, 'N/A', i_log_level + 2, 'efex_timesheet_fact delete count [' || SQL%ROWCOUNT || '], now merge chnages to fact table');

     MERGE INTO
       efex_timesheet_call_fact t1
     USING (SELECT
              t1.timesheet_date,
              t2.cust_dtl_code,
              t1.user_id           as efex_assoc_id,
              t1.efex_cust_id,
              t3.sales_terr_code,
              t1.sales_terr_id     as efex_sales_terr_id,
              t1.sgmnt_id          as efex_sgmnt_id,
              t1.bus_unit_id       as efex_bus_unit_id,
              t1.calltime1_1       as time_in_store,
              t1.calltime1_2       as time_prod_training,
              t1.calltime1_3       as time_telesales,
              t1.traveltime1       as time_travel
            FROM
              efex_timesheet_call t1,
              efex_cust_dtl_dim t2,
              efex_sales_terr_dim t3
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(timesheet_call_lupdt) = i_aggregation_date
              AND t1.efex_mkt_id = p_market_id
              AND t1.status = 'A'
              AND t1.efex_cust_id = t2.efex_cust_id
              AND t2.last_rec_flg = 'Y'
              AND t1.sales_terr_id = t3.efex_sales_terr_id
              AND t3.last_rec_flg = 'Y'
            ) t2
        ON (t1.efex_cust_id = t2.efex_cust_id
            AND t1.timesheet_date = t2.timesheet_date
            AND t1.efex_assoc_id = t2.efex_assoc_id)
        WHEN MATCHED THEN
          UPDATE SET
            t1.time_in_store = t2.time_in_store,
            t1.time_prod_training = t2.time_prod_training,
            t1.time_telesales = t2.time_telesales,
            t1.time_travel = t2.time_travel
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.timesheet_date,
              t1.cust_dtl_code,
              t1.efex_assoc_id,
              t1.company_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.time_in_store,
              t1.time_prod_training,
              t1.time_telesales,
              t1.time_travel
            )
          VALUES
            (
              t2.timesheet_date,
              t2.cust_dtl_code,
              t2.efex_assoc_id,
              p_company_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              t2.time_in_store,
              t2.time_prod_training,
              t2.time_telesales,
              t2.time_travel
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_tmesht_call, 'N/A', i_log_level + 2, 'efex_timesheet_call_fact aggregated with merged count: [' || SQL%ROWCOUNT || '] (active only)');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_tmesht_call,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_timesheet_call_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_timesheet_call_fact_aggr;


FUNCTION efex_timesheet_day_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex timesheet day modified yesterday.
  CURSOR csr_timesheet_day_count IS
    SELECT count(*) AS rec_count
    FROM efex_timesheet_day
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(timesheet_day_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_timesheet_day_fact aggregation.
  write_log(ods_constants.data_type_efex_tmesht_day, 'N/A', i_log_level + 1, 'Start - efex_timesheet_day_fact aggregation.');

  -- Fetch the record from the csr_timesheet_day_count cursor.
  OPEN  csr_timesheet_day_count;
  FETCH csr_timesheet_day_count INTO v_rec_count;
  CLOSE csr_timesheet_day_count;

  -- If any efex_timesheet_day records modified yesterday.
  write_log(ods_constants.data_type_efex_tmesht_day, 'N/A', i_log_level + 2, 'efex_timesheet_day received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_tmesht_day, 'N/A', i_log_level + 2, 'Delete matching record from efex_timesheet_day_fact');

     DELETE
     FROM efex_timesheet_day_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_timesheet_day t2
                   WHERE
                     t2.user_id = t1.efex_assoc_id
                     AND t2.timesheet_date = t1.timesheet_time
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.timesheet_day_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_tmesht_day, 'N/A', i_log_level + 2, 'efex_timesheet_fact delete count [' || SQL%ROWCOUNT || '], now merge chnages to fact table');

     -- Only insert the Active records.
     INSERT INTO efex_timesheet_day_fact
       (
        timesheet_time,
        timesheet_date,
        efex_assoc_id,
        company_code,
        time_admin,
        time_meetings,
        time_travel,
        travel_kms
       )
     SELECT
       timesheet_date,
       TRUNC(timesheet_date),
       user_id,
       p_company_code,
       time1,
       time2,
       traveltime,
       travelkms
     FROM
       efex_timesheet_day
     WHERE
       valdtn_status = ods_constants.valdtn_valid
       AND trunc(timesheet_day_lupdt) = i_aggregation_date
       AND efex_mkt_id = p_market_id
       AND status = 'A';

     -- Number of record modified.
     write_log(ods_constants.data_type_efex_tmesht_day, 'N/A', i_log_level + 2, 'efex_timesheet_day_fact aggregated (active only) with insert count: [' || SQL%ROWCOUNT || ']');

     -- Commit.
     COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_tmesht_day,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_timesheet_day_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_timesheet_day_fact_aggr;


FUNCTION efex_assmnt_assgnmnt_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex assessment assignment modified yesterday.
  CURSOR csr_assmnt_assgnmnt_count IS
    SELECT count(*) AS rec_count
    FROM efex_assmnt_assgnmnt
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(assmnt_assgnmnt_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_assmnt_assgnmnt_fact aggregation.
  write_log(ods_constants.data_type_efex_ass_assgn, 'N/A', i_log_level + 1, 'Start - efex_assmnt_assgnmnt_fact aggregation.');

  -- Fetch the record from the csr_assmnt_assgnmnt_count cursor.
  OPEN  csr_assmnt_assgnmnt_count;
  FETCH csr_assmnt_assgnmnt_count INTO v_rec_count;
  CLOSE csr_assmnt_assgnmnt_count;

  -- If any efex_assmnt_assgnmnt records modified yesterday.
  write_log(ods_constants.data_type_efex_ass_assgn, 'N/A', i_log_level + 2, 'efex_assmnt_assgnmnt received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_ass_assgn, 'N/A', i_log_level + 2, 'Delete efex_assmnt_assgnmnt_fact with status updated to X first.');

     DELETE
     FROM efex_assmnt_assgnmnt_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_assmnt_assgnmnt t2
                   WHERE
                     t2.assmnt_id = t1.efex_assmnt_id
                     AND t2.efex_cust_id = t1.efex_cust_id
                     AND t2.status = 'X'
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.assmnt_assgnmnt_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_ass_assgn, 'N/A', i_log_level + 2, 'efex_assmnt_assgnmnt_fact delete count [' || SQL%ROWCOUNT || '], now merge chnages to fact table');

     MERGE INTO
       efex_assmnt_assgnmnt_fact t1
     USING (SELECT
              t1.assmnt_id         as efex_assmnt_id,
              t2.cust_dtl_code,
              t1.efex_cust_id,
              t3.sales_terr_code,
              t1.sales_terr_id     as efex_sales_terr_id,
              t1.sgmnt_id          as efex_sgmnt_id,
              t1.bus_unit_id       as efex_bus_unit_id
            FROM
              efex_assmnt_assgnmnt t1,
              efex_cust_dtl_dim t2,
              efex_sales_terr_dim t3
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(assmnt_assgnmnt_lupdt) = i_aggregation_date
              AND t1.efex_mkt_id = p_market_id
              AND t1.status = 'A'
              AND t1.efex_cust_id = t2.efex_cust_id
              AND t2.last_rec_flg = 'Y'
              AND t1.sales_terr_id = t3.efex_sales_terr_id (+)
              AND t3.last_rec_flg(+) = 'Y'
            ) t2
        ON (t1.efex_assmnt_id = t2.efex_assmnt_id
            AND t1.efex_cust_id = t2.efex_cust_id)
        WHEN MATCHED THEN
          UPDATE SET
            t1.assmnt_target = 1
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.efex_assmnt_id,
              t1.cust_dtl_code,
              t1.company_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.assmnt_target
            )
          VALUES
            (
              t2.efex_assmnt_id,
              t2.cust_dtl_code,
              p_company_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              1
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_ass_assgn, 'N/A', i_log_level + 2, 'efex_assmnt_assgnmnt_fact aggregated with merged count(Active Only): [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_ass_assgn,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_assmnt_assgnmnt_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_assmnt_assgnmnt_fact_aggr;


FUNCTION efex_assmnt_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex assessment modified yesterday.
  CURSOR csr_assmnt_count IS
    SELECT count(*) AS rec_count
    FROM efex_assmnt
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(assmnt_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_assmnt_fact aggregation.
  write_log(ods_constants.data_type_efex_assmnt, 'N/A', i_log_level + 1, 'Start - efex_assmnt_fact aggregation.');

  -- Fetch the record from the csr_assmnt_count cursor.
  OPEN  csr_assmnt_count;
  FETCH csr_assmnt_count INTO v_rec_count;
  CLOSE csr_assmnt_count;

  -- If any efex_assmnt records modified yesterday.
  write_log(ods_constants.data_type_efex_assmnt, 'N/A', i_log_level + 2, 'efex_assmnt received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     -- Delete record with status = 'X'.
     write_log(ods_constants.data_type_efex_assmnt, 'N/A', i_log_level + 2, 'Delete efex_assmnt_fact with status updated to X first.');

     DELETE
     FROM efex_assmnt_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_assmnt t2
                   WHERE
                     t2.assmnt_id = t1.efex_assmnt_id
                     AND t2.efex_cust_id = t1.efex_cust_id
                     AND t2.resp_date = t1.assmnt_date
                     AND t2.status = 'X'
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.assmnt_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_assmnt, 'N/A', i_log_level + 2, 'efex_assmnt_fact delete count [' || SQL%ROWCOUNT || '], now merge chnages to fact table');

     MERGE INTO
       efex_assmnt_fact t1
     USING (SELECT
              t1.resp_date         as assmnt_date,
              t1.assmnt_id         as efex_assmnt_id,
              t2.cust_dtl_code,
              t1.efex_cust_id,
              t3.sales_terr_code,
              t1.sales_terr_id     as efex_sales_terr_id,
              t1.sgmnt_id          as efex_sgmnt_id,
              t1.bus_unit_id       as efex_bus_unit_id,
              t1.assmnt_answer,
              t1.user_id           as efex_assoc_id
            FROM
              efex_assmnt t1,
              efex_cust_dtl_dim t2,
              efex_sales_terr_dim t3
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(assmnt_lupdt) = i_aggregation_date
              AND t1.efex_mkt_id = p_market_id
              AND t1.status = 'A'
              AND t1.efex_cust_id = t2.efex_cust_id
              AND t2.last_rec_flg = 'Y'
              AND t1.sales_terr_id = t3.efex_sales_terr_id
              AND t3.last_rec_flg = 'Y'
            ) t2
        ON (t1.assmnt_date = t2.assmnt_date
            AND t1.efex_assmnt_id = t2.efex_assmnt_id
            AND t1.efex_cust_id = t2.efex_cust_id)
        WHEN MATCHED THEN
          UPDATE SET
            t1.assmnt_answer = t2.assmnt_answer,
            t1.efex_assoc_id = t2.efex_assoc_id
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.assmnt_date,
              t1.efex_assmnt_id,
              t1.cust_dtl_code,
              t1.company_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.assmnt_answer,
              t1.efex_assoc_id
            )
          VALUES
            (
              t2.assmnt_date,
              t2.efex_assmnt_id,
              t2.cust_dtl_code,
              p_company_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              t2.assmnt_answer,
              t2.efex_assoc_id
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_assmnt, 'N/A', i_log_level + 2, 'efex_assmnt_fact aggregated with merged count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_assmnt,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_assmnt_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_assmnt_fact_aggr;


FUNCTION efex_range_matl_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex range material modified yesterday.
  CURSOR csr_range_matl_count IS
    SELECT count(*) AS rec_count
    FROM efex_range_matl
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(range_matl_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_range_matl_fact aggregation.
  write_log(ods_constants.data_type_efex_range_matl, 'N/A', i_log_level + 1, 'Start - efex_range_matl_fact aggregation.');

  -- Fetch the record from the csr_range_matl_count cursor.
  OPEN  csr_range_matl_count;
  FETCH csr_range_matl_count INTO v_rec_count;
  CLOSE csr_range_matl_count;

  -- If any efex_range_matl records modified yesterday
  write_log(ods_constants.data_type_efex_range_matl, 'N/A', i_log_level + 2, 'efex_range_matl received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_range_matl, 'N/A', i_log_level + 2, 'Merge chnages to fact table');

     MERGE INTO
       efex_range_matl_fact t1
     USING (SELECT
              t1.range_id          as efex_range_id,
              t1.efex_matl_id,
              t2.rqd_flg_code,
              TRUNC(t1.start_date) as start_date,
              TRUNC(t1.target_date) as target_date,
              t1.status,
              t1.ref_code
            FROM
              efex_range_matl t1,
              efex_rqd_flg_dim t2
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(range_matl_lupdt) = i_aggregation_date
              AND t1.efex_mkt_id = p_market_id
              AND t1.rqd_flg = t2.rqd_flg
            ) t2
        ON (t1.efex_range_id = t2.efex_range_id
            AND t1.efex_matl_id = t2.efex_matl_id)
        WHEN MATCHED THEN
          UPDATE SET
            t1.rqd_flg_code = rqd_flg_code,
            t1.start_date = t2.start_date,
            t1.target_date = t2.target_date,
            t1.status = t2.status,
            t1.ref_code = t2.ref_code
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.efex_range_id,
              t1.efex_matl_id,
              t1.rqd_flg_code,
              t1.start_date,
              t1.target_date,
              t1.status,
              t1.ref_code,
              t1.target_value
            )
          VALUES
            (
              t2.efex_range_id,
              t2.efex_matl_id,
              t2.rqd_flg_code,
              t2.start_date,
              t2.target_date,
              t2.status,
              t2.ref_code,
              1
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_range_matl, 'N/A', i_log_level + 2, 'efex_range_matl_fact aggregated with merged count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_range_matl,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_range_matl_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_range_matl_fact_aggr;


FUNCTION efex_turnin_order_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex order item modified yesterday.
  CURSOR csr_efex_order_matl_count IS
    SELECT count(*) AS rec_count
    FROM
      efex_order_matl
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(order_matl_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting EFEX_TURNIN_ORDER_FACT aggregation.
  write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 1, 'Start - EFEX_TURNIN_ORDER_FACT aggregation.');

  -- Fetch the record from the csr_efex_order_matl_count cursor.
  OPEN  csr_efex_order_matl_count;
  FETCH csr_efex_order_matl_count INTO v_rec_count;
  CLOSE csr_efex_order_matl_count;

  -- If any efex_order_matl records modified yesterday.
  write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'EFEX order material received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'Delete efex_turnin_order_fact record with status changed to X first.');

     DELETE
     FROM efex_turnin_order_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_order t2,
                     efex_order_matl t3
                   WHERE
                     t2.efex_order_id = t3.efex_order_id
                     AND t1.efex_order_id = t2.efex_order_id
                     AND t1.efex_matl_id = t3.efex_matl_id
                     AND t3.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t3.order_matl_lupdt) = i_aggregation_date
                     AND t3.efex_mkt_id = p_market_id
                     AND t3.status = 'X');

     write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'efex_turnin_order_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'Merge active records INTO efex_turnin_order_fact for the records received yesterday.');

     MERGE INTO
       efex_turnin_order_fact t1
     USING (
             SELECT
               t1.efex_order_id,
               t1.efex_matl_id,
               t1.order_date,
               t2.cust_dtl_code,
               t1.efex_cust_id,
               t3.sales_terr_code,
               t1.efex_sales_terr_id,
               t1.efex_sgmnt_id,
               t1.efex_bus_unit_id,
               t5.efex_matl_subgrp_id,
               t5.efex_matl_grp_id,
               t1.efex_assoc_id,
               t4.cust_dtl_code   as distbr_code,
               t1.efex_distbr_id,
               t1.order_qty,
               t1.alloc_qty,
               t1.uom
             FROM
               (SELECT
                  t1.efex_order_id,
                  t2.efex_matl_id,
                  TRUNC(t1.order_date) AS order_date,
                  t1.efex_cust_id,
                  t1.sales_terr_id    AS efex_sales_terr_id,
                  t1.sgmnt_id         AS efex_sgmnt_id,
                  t1.bus_unit_id      AS efex_bus_unit_id,
                  t1.user_id          AS efex_assoc_id,
                  t2.matl_distbr_id   AS efex_distbr_id,
                  t2.order_qty,
                  t2.alloc_qty,
                  t2.uom
                FROM
                  efex_order t1,
                  efex_order_matl t2
                WHERE
                  t1.efex_order_id = t2.efex_order_id
                  AND t2.status = 'A'
                  AND t2.valdtn_status = ods_constants.valdtn_valid
                  AND trunc(t2.order_matl_lupdt) = i_aggregation_date
                  AND t2.efex_mkt_id = p_market_id
               ) t1,
               efex_cust_dtl_dim t2,
               efex_sales_terr_dim t3,
               efex_cust_dtl_dim t4,
               efex_matl_matl_subgrp_dim t5
             WHERE
               t1.efex_cust_id = t2.efex_cust_id
               AND t2.last_rec_flg = 'Y'
               AND t1.efex_sales_terr_id = t3.efex_sales_terr_id
               AND t3.last_rec_flg = 'Y'
               AND t2.efex_distbr_id = t4.efex_cust_id (+)
               AND t4.last_rec_flg (+) = 'Y'
               AND t1.efex_matl_id = t5.efex_matl_id (+)
               AND t1.efex_sgmnt_id = t5.efex_sgmnt_id (+)
               AND t5.status (+) = 'A'
            ) t2
        ON (t1.efex_order_id = t2.efex_order_id
            AND t1.efex_matl_id = t2.efex_matl_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.order_date = t2.order_date,
            t1.efex_assoc_id = t2.efex_assoc_id,
            t1.order_qty = t2.order_qty,
            t1.alloc_qty = t2.alloc_qty,
            t1.uom = t2.uom
        WHEN NOT MATCHED THEN
          INSERT
            (
             t1.efex_order_id,
             t1.efex_matl_id,
             t1.order_date,
             t1.cust_dtl_code,
             t1.company_code,
             t1.efex_cust_id,
             t1.sales_terr_code,
             t1.efex_sales_terr_id,
             t1.efex_sgmnt_id,
             t1.efex_bus_unit_id,
             t1.efex_matl_subgrp_id,
             t1.efex_matl_grp_id,
             t1.efex_assoc_id,
             t1.distbr_code,
             t1.efex_distbr_id,
             t1.order_qty,
             t1.alloc_qty,
             t1.uom
            )
          VALUES
            (
             t2.efex_order_id,
             t2.efex_matl_id,
             t2.order_date,
             t2.cust_dtl_code,
             p_company_code,
             t2.efex_cust_id,
             t2.sales_terr_code,
             t2.efex_sales_terr_id,
             t2.efex_sgmnt_id,
             t2.efex_bus_unit_id,
             t2.efex_matl_subgrp_id,
             t2.efex_matl_grp_id,
             t2.efex_assoc_id,
             t2.distbr_code,
             t2.efex_distbr_id,
             t2.order_qty,
             t2.alloc_qty,
             t2.uom
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'EFEX_TURNIN_ORDER_FACT aggregated with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_turnin_ord,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.EFEX_TURNIN_ORDER_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_turnin_order_fact_aggr;


FUNCTION efex_pmt_deal_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex pmt deal modified yesterday.
  CURSOR csr_efex_pmt_deal_count IS
    SELECT count(*) AS rec_count
    FROM
      efex_pmt_deal
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(pmt_deal_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting EFEX_PMT_DEAL_FACT aggregation.
  write_log(ods_constants.data_type_efex_pmt_deal, 'N/A', i_log_level + 1, 'Start - EFEX_PMT_DEAL_FACT aggregation.');

  -- Fetch the record from the csr_efex_pmt_deal_count cursor.
  OPEN  csr_efex_pmt_deal_count;
  FETCH csr_efex_pmt_deal_count INTO v_rec_count;
  CLOSE csr_efex_pmt_deal_count;

  -- If any efex_pmt_deal records modified yesterday
  write_log(ods_constants.data_type_efex_pmt_deal, 'N/A', i_log_level + 2, 'EFEX pmt deal received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_pmt_deal, 'N/A', i_log_level + 2, 'Delete efex_pmt_deal_fact record with status changed to X first.');

     DELETE
     FROM efex_pmt_deal_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_pmt_deal t2
                   WHERE
                     t1.efex_pmt_id = t2.pmt_id
                     AND t1.seq_num = t2.seq_num
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.pmt_deal_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id
                     AND t2.status = 'X');

     write_log(ods_constants.data_type_efex_pmt_deal, 'N/A', i_log_level + 2, 'efex_pmt_deal_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_pmt_deal, 'N/A', i_log_level + 2, 'Merge active records INTO efex_pmt_deal_fact for the records received yesterday.');

     MERGE INTO
       efex_pmt_deal_fact t1
     USING (
             SELECT
               t2.pmt_id          as efex_pmt_id,
               t2.seq_num,
               t3.cust_dtl_code,
               t1.efex_cust_id,
               t4.sales_terr_code,
               t1.sales_terr_id   as efex_sales_terr_id,
               t1.sgmnt_id        as efex_sgmnt_id,
               t1.bus_unit_id     as efex_bus_unit_id,
               t1.user_id         as efex_assoc_id,
               TRUNC(t1.pmt_date) as pmt_date,
               t2.efex_order_id,
               t2.deal_value
             FROM
               efex_pmt t1,
               efex_pmt_deal t2,
               efex_cust_dtl_dim t3,
               efex_sales_terr_dim t4
             WHERE
               t2.valdtn_status = ods_constants.valdtn_valid
               AND trunc(t2.pmt_deal_lupdt) = i_aggregation_date
               AND t2.efex_mkt_id = p_market_id
               AND t2.status = 'A'
               AND t1.pmt_id = t2.pmt_id
               AND t1.efex_cust_id = t3.efex_cust_id
               AND t3.last_rec_flg = 'Y'
               AND t1.sales_terr_id = t4.efex_sales_terr_id
               AND t4.last_rec_flg = 'Y'
            ) t2
        ON (t1.efex_pmt_id = t2.efex_pmt_id
            AND t1.seq_num = t2.seq_num )
        WHEN MATCHED THEN
          UPDATE SET
            t1.cust_dtl_code = t2.cust_dtl_code,
            t1.efex_cust_id = t2.efex_cust_id,
            t1.sales_terr_code = t2.sales_terr_code,
            t1.efex_sales_terr_id = t2.efex_sales_terr_id,
            t1.efex_sgmnt_id = t2.efex_sgmnt_id,
            t1.efex_bus_unit_id = t2.efex_bus_unit_id,
            t1.efex_assoc_id = t2.efex_assoc_id,
            t1.pmt_date = t2.pmt_date,
            t1.efex_order_id = t2.efex_order_id,
            t1.deal_value = t2.deal_value
        WHEN NOT MATCHED THEN
          INSERT
            (
             t1.efex_pmt_id,
             t1.seq_num,
             t1.company_code,
             t1.cust_dtl_code,
             t1.efex_cust_id,
             t1.sales_terr_code,
             t1.efex_sales_terr_id,
             t1.efex_sgmnt_id,
             t1.efex_bus_unit_id,
             t1.efex_assoc_id,
             t1.pmt_date,
             t1.efex_order_id,
             t1.deal_value
            )
          VALUES
            (
             t2.efex_pmt_id,
             t2.seq_num,
             p_company_code,
             t2.cust_dtl_code,
             t2.efex_cust_id,
             t2.sales_terr_code,
             t2.efex_sales_terr_id,
             t2.efex_sgmnt_id,
             t2.efex_bus_unit_id,
             t2.efex_assoc_id,
             t2.pmt_date,
             t2.efex_order_id,
             t2.deal_value
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_pmt_deal, 'N/A', i_log_level + 2, 'EFEX_PMT_DEAL_FACT aggregated with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_pmt_deal,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_pmt_deal_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_pmt_deal_fact_aggr;


FUNCTION efex_pmt_rtn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex pmt rtn modified yesterday.
  CURSOR csr_efex_pmt_rtn_count IS
    SELECT count(*) AS rec_count
    FROM
      efex_pmt_rtn
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(pmt_rtn_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting EFEX_PMT_RTN_FACT aggregation.
  write_log(ods_constants.data_type_efex_pmt_rtn, 'N/A', i_log_level + 1, 'Start - EFEX_PMT_RTN_FACT aggregation.');

  -- Fetch the record from the csr_efex_pmt_rtn_count cursor.
  OPEN  csr_efex_pmt_rtn_count;
  FETCH csr_efex_pmt_rtn_count INTO v_rec_count;
  CLOSE csr_efex_pmt_rtn_count;

  -- If any efex_pmt_rtn records modified yesterday.
  write_log(ods_constants.data_type_efex_pmt_rtn, 'N/A', i_log_level + 2, 'EFEX pmt rtn received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_pmt_rtn, 'N/A', i_log_level + 2, 'Delete efex_pmt_rtn_fact record with status changed to X first.');

     DELETE
     FROM efex_pmt_rtn_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_pmt_rtn t2
                   WHERE
                     t1.efex_pmt_id = t2.pmt_id
                     AND t1.seq_num = t2.seq_num
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.pmt_rtn_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id
                     AND t2.status = 'X');

     write_log(ods_constants.data_type_efex_pmt_rtn, 'N/A', i_log_level + 2, 'efex_pmt_rtn_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_pmt_rtn, 'N/A', i_log_level + 2, 'Merge active records INTO efex_pmt_rtn_fact for the records received yesterday.');

     MERGE INTO
       efex_pmt_rtn_fact t1
     USING (
             SELECT
               t1.efex_pmt_id,
               t1.seq_num,
               t2.cust_dtl_code,
               t1.efex_cust_id,
               t3.sales_terr_code,
               t1.efex_sales_terr_id,
               t1.efex_sgmnt_id,
               t1.efex_bus_unit_id,
               t1.efex_assoc_id,
               t1.pmt_date,
               t1.efex_matl_id,
               t4.efex_matl_subgrp_id,
               t4.efex_matl_grp_id,
               t1.rtn_claim_code,
               t1.rtn_reason,
               t1.rtn_qty,
               t1.rtn_value
             FROM
               (
                SELECT
                  t2.pmt_id          as efex_pmt_id,
                  t2.seq_num,
                  t1.efex_cust_id,
                  t1.sales_terr_id   as efex_sales_terr_id,
                  t1.sgmnt_id        as efex_sgmnt_id,
                  t1.bus_unit_id     as efex_bus_unit_id,
                  t1.user_id         as efex_assoc_id,
                  TRUNC(t1.pmt_date) as pmt_date,
                  t2.efex_matl_id,
                  t2.rtn_claim_code,
                  t2.rtn_reason,
                  t2.rtn_qty,
                  t2.rtn_value
                FROM
                  efex_pmt t1,
                  efex_pmt_rtn t2
                WHERE
                  t1.pmt_id = t2.pmt_id
                  AND t2.status = 'A'
                  AND t2.valdtn_status = ods_constants.valdtn_valid
                  AND trunc(t2.pmt_rtn_lupdt) = i_aggregation_date
                  AND t2.efex_mkt_id = p_market_id
                ) t1,
                efex_cust_dtl_dim t2,
                efex_sales_terr_dim t3,
                efex_matl_matl_subgrp_dim t4
              WHERE
                t1.efex_cust_id = t2.efex_cust_id
                AND t2.last_rec_flg = 'Y'
                AND t1.efex_sales_terr_id = t3.efex_sales_terr_id
                AND t3.last_rec_flg = 'Y'
                AND t1.efex_matl_id = t4.efex_matl_id (+)
                AND t1.efex_sgmnt_id = t4.efex_sgmnt_id (+)
                AND t4.status (+) = 'A'
            ) t2
        ON (t1.efex_pmt_id = t2.efex_pmt_id
            AND t1.seq_num = t2.seq_num )
        WHEN MATCHED THEN
          UPDATE SET
            t1.cust_dtl_code = t2.cust_dtl_code,
            t1.efex_cust_id = t2.efex_cust_id,
            t1.sales_terr_code = t2.sales_terr_code,
            t1.efex_sales_terr_id = t2.efex_sales_terr_id,
            t1.efex_sgmnt_id = t2.efex_sgmnt_id,
            t1.efex_bus_unit_id = t2.efex_bus_unit_id,
            t1.efex_assoc_id = t2.efex_assoc_id,
            t1.pmt_date = t2.pmt_date,
            t1.efex_matl_id = t2.efex_matl_id,
            t1.efex_matl_subgrp_id = t2.efex_matl_subgrp_id,
            t1.efex_matl_grp_id = t2.efex_matl_grp_id,
            t1.rtn_claim_code = t2.rtn_claim_code,
            t1.rtn_reason = t1.rtn_reason,
            t1.rtn_qty = t1.rtn_qty,
            t1.rtn_value = t2.rtn_value
        WHEN NOT MATCHED THEN
          INSERT
            (
             t1.efex_pmt_id,
             t1.seq_num,
             t1.company_code,
             t1.cust_dtl_code,
             t1.efex_cust_id,
             t1.sales_terr_code,
             t1.efex_sales_terr_id,
             t1.efex_sgmnt_id,
             t1.efex_bus_unit_id,
             t1.efex_assoc_id,
             t1.pmt_date,
             t1.efex_matl_id,
             t1.efex_matl_subgrp_id,
             t1.efex_matl_grp_id,
             t1.rtn_claim_code,
             t1.rtn_reason,
             t1.rtn_qty,
             t1.rtn_value
            )
          VALUES
            (
             t2.efex_pmt_id,
             t2.seq_num,
             p_company_code,
             t2.cust_dtl_code,
             t2.efex_cust_id,
             t2.sales_terr_code,
             t2.efex_sales_terr_id,
             t2.efex_sgmnt_id,
             t2.efex_bus_unit_id,
             t2.efex_assoc_id,
             t2.pmt_date,
             t2.efex_matl_id,
             t2.efex_matl_subgrp_id,
             t2.efex_matl_grp_id,
             t2.rtn_claim_code,
             t2.rtn_reason,
             t2.rtn_qty,
             t2.rtn_value
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_pmt_rtn, 'N/A', i_log_level + 2, 'EFEX_PMT_RTN_FACT aggregated with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_pmt_rtn,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_pmt_rtn_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_pmt_rtn_fact_aggr;


FUNCTION efex_mrq_matl_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex mrq matl modified yesterday.
  CURSOR csr_efex_mrq_matl_count IS
    SELECT count(*) AS rec_count
    FROM
      efex_mrq_task_matl
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(mrq_task_matl_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting EFEX_mrq_matl_FACT aggregation.
  write_log(ods_constants.data_type_efex_mrq_matl, 'N/A', i_log_level + 1, 'Start - EFEX_MRQ_MATL_FACT aggregation.');

  -- Fetch the record from the csr_efex_mrq_matl_count cursor.
  OPEN  csr_efex_mrq_matl_count;
  FETCH csr_efex_mrq_matl_count INTO v_rec_count;
  CLOSE csr_efex_mrq_matl_count;

  -- If any efex_mrq_matl records modified yesterday.
  write_log(ods_constants.data_type_efex_mrq_matl, 'N/A', i_log_level + 2, 'EFEX mrq matl received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_mrq_matl, 'N/A', i_log_level + 2, 'Delete efex_mrq_matl_fact record with status changed to X first.');

     DELETE
     FROM efex_mrq_matl_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_mrq_task_matl t2
                   WHERE
                     t1.efex_mrq_task_id = t2.mrq_task_id
                     AND t1.efex_matl_id = t2.efex_matl_id
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.mrq_task_matl_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id
                     AND t2.status = 'X');

     write_log(ods_constants.data_type_efex_mrq_matl, 'N/A', i_log_level + 2, 'efex_mrq_matl_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_mrq_matl, 'N/A', i_log_level + 2, 'Merge active records INTO efex_mrq_matl_fact for the records received yesterday.');

     -- Mrq task can exist without mrq.
     MERGE INTO
       efex_mrq_matl_fact t1
     USING (
             SELECT
               t1.efex_mrq_task_id,
               t1.efex_matl_id,
               t1.efex_mrq_id,
               t2.efex_matl_subgrp_id,
               t2.efex_matl_grp_id,
               t1.efex_assoc_id,
               t1.matl_qty,
               t1.supplier
             FROM
               (
                SELECT
                  t1.mrq_task_id     as efex_mrq_task_id,
                  t1.efex_matl_id,
                  t2.mrq_id          as efex_mrq_id,
                  t3.user_id         as efex_assoc_id,
                  t1.matl_qty,
                  t1.supplier,
                  t3.sgmnt_id        as efex_sgmnt_id
                FROM
                  efex_mrq_task_matl t1,
                  efex_mrq_task t2,
                  efex_mrq t3
                WHERE
                  t1.mrq_task_id = t2.mrq_task_id
                  AND t2.mrq_id = t3.mrq_id (+)
                  AND t1.status = 'A'
                  AND t1.valdtn_status = ods_constants.valdtn_valid
                  AND trunc(t1.mrq_task_matl_lupdt) = i_aggregation_date
                  AND t1.efex_mkt_id = p_market_id
               )  t1,
               efex_matl_matl_subgrp_dim t2
             WHERE
               t1.efex_matl_id = t2.efex_matl_id (+)
               AND t1.efex_sgmnt_id  = t2.efex_sgmnt_id (+)
               AND t2.status (+) = 'A'
            ) t2
        ON (t1.efex_mrq_task_id = t2.efex_mrq_task_id
            AND t1.efex_matl_id = t2.efex_matl_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.efex_assoc_id = t2.efex_assoc_id,
            t1.matl_qty = t2.matl_qty,
            t1.supplier = t2.supplier,
            t1.efex_matl_subgrp_id = t2.efex_matl_subgrp_id,
            t1.efex_matl_grp_id = t2.efex_matl_grp_id
        WHEN NOT MATCHED THEN
          INSERT
            (
             t1.efex_mrq_task_id,
             t1.efex_matl_id,
             t1.efex_mrq_id,
             t1.company_code,
             t1.efex_matl_subgrp_id,
             t1.efex_matl_grp_id,
             t1.efex_assoc_id,
             t1.matl_qty,
             t1.supplier
            )
          VALUES
            (
             t2.efex_mrq_task_id,
             t2.efex_matl_id,
             t2.efex_mrq_id,
             p_company_code,
             t2.efex_matl_subgrp_id,
             t2.efex_matl_grp_id,
             t2.efex_assoc_id,
             t2.matl_qty,
             t2.supplier
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_mrq_matl, 'N/A', i_log_level + 2, 'EFEX_MRQ_MATL_FACT aggregated with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_mrq_matl,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_mrq_matl_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_mrq_matl_fact_aggr;

FUNCTION efex_assoc_sgmnt_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex user segment modified yesterday.
  CURSOR csr_efex_user_sgmnt_count IS
    SELECT count(*) AS rec_count
    FROM
      efex_user_sgmnt
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(user_sgmnt_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_assoc_sgmnt_fact aggregation.
  write_log(ods_constants.data_type_efex_user_sgmnt, 'N/A', i_log_level + 1, 'Start - EFEX_ASSOC_SGMNT_FACT aggregation.');

  -- Fetch the record from the csr_efex_assoc_sgmnt_count cursor.
  OPEN  csr_efex_user_sgmnt_count;
  FETCH csr_efex_user_sgmnt_count INTO v_rec_count;
  CLOSE csr_efex_user_sgmnt_count;

  -- If any efex_assoc_sgmnt records modified yesterday.
  write_log(ods_constants.data_type_efex_user_sgmnt, 'N/A', i_log_level + 2, 'EFEX user segment received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_user_sgmnt, 'N/A', i_log_level + 2, 'Delete efex_assoc_sgmnt_fact record with status changed to X first.');

     DELETE
     FROM efex_assoc_sgmnt_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_user_sgmnt t2
                   WHERE
                     t1.efex_assoc_id = t2.user_id
                     AND t1.efex_sgmnt_id = t2.sgmnt_id
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.user_sgmnt_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id
                     AND t2.status = 'X');

     write_log(ods_constants.data_type_efex_user_sgmnt, 'N/A', i_log_level + 2, 'efex_assoc_sgmnt_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_user_sgmnt, 'N/A', i_log_level + 2, 'Merge active records INTO efex_assoc_sgmnt_fact for the records received yesterday.');

     MERGE INTO
       efex_assoc_sgmnt_fact t1
     USING (
             SELECT
               user_id          as efex_assoc_id,
               sgmnt_id         as efex_sgmnt_id,
               bus_unit_id      as efex_bus_unit_id
             FROM
               efex_user_sgmnt
             WHERE
               valdtn_status = ods_constants.valdtn_valid
               AND trunc(user_sgmnt_lupdt) = i_aggregation_date
               AND efex_mkt_id = p_market_id
               AND status = 'A'
            ) t2
        ON (t1.efex_assoc_id = t2.efex_assoc_id
            AND t1.efex_sgmnt_id = t2.efex_sgmnt_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.efex_bus_unit_id = t2.efex_bus_unit_id
        WHEN NOT MATCHED THEN
          INSERT
            (
             t1.efex_assoc_id,
             t1.efex_sgmnt_id,
             t1.efex_bus_unit_id
            )
          VALUES
            (
             t2.efex_assoc_id,
             t2.efex_sgmnt_id,
             t2.efex_bus_unit_id
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_user_sgmnt, 'N/A', i_log_level + 2, 'EFEX_ASSOC_SGMNT_FACT aggregated with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_user_sgmnt,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_assoc_sgmnt_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_assoc_sgmnt_fact_aggr;

FUNCTION efex_cust_note_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex customer note modified yesterday.
  CURSOR csr_cust_note_count IS
    SELECT count(*) AS rec_count
    FROM efex_cust_note
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(cust_note_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_cust_note_fact aggregation.
  write_log(ods_constants.data_type_efex_cust_note, 'N/A', i_log_level + 1, 'Start - efex_cust_note_fact aggregation.');

  -- Fetch the record from the csr_cust_note_count cursor.
  OPEN  csr_cust_note_count;
  FETCH csr_cust_note_count INTO v_rec_count;
  CLOSE csr_cust_note_count;

  -- If any efex_cust_note records modified yesterday
  write_log(ods_constants.data_type_efex_cust_note, 'N/A', i_log_level + 2, 'efex_cust_note received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     -- Delete record with status = 'X'
     write_log(ods_constants.data_type_efex_cust_note, 'N/A', i_log_level + 2, 'Delete efex_cust_note_fact with status updated to X first.');

     DELETE
     FROM efex_cust_note_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_cust_note t2
                   WHERE
                     t2.cust_note_id = t1.efex_cust_note_id
                     AND t2.status = 'X'
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.cust_note_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_cust_note, 'N/A', i_log_level + 2, 'efex_cust_note_fact delete count [' || SQL%ROWCOUNT || '], now merge chnages to fact table');

     MERGE INTO
       efex_cust_note_fact t1
     USING (SELECT
              t1.cust_note_id         as efex_cust_note_id,
              t2.cust_dtl_code,
              t1.efex_cust_id,
              t3.sales_terr_code,
              t1.sales_terr_id        as efex_sales_terr_id,
              t1.sgmnt_id             as efex_sgmnt_id,
              t1.bus_unit_id          as efex_bus_unit_id,
              t1.cust_note_title,
              t1.cust_note_body,
              t1.cust_note_author,
              to_date(t1.cust_note_created,'yyyy/mm/dd hh24:mi:ss') as cust_note_created
            FROM
              efex_cust_note t1,
              efex_cust_dtl_dim t2,
              efex_sales_terr_dim t3
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(cust_note_lupdt) = i_aggregation_date
              AND t1.efex_mkt_id = p_market_id
              AND t1.status = 'A'
              AND t1.efex_cust_id = t2.efex_cust_id
              AND t2.last_rec_flg = 'Y'
              AND t1.sales_terr_id = t3.efex_sales_terr_id
              AND t3.last_rec_flg = 'Y'
            ) t2
        ON (t1.efex_cust_note_id = t2.efex_cust_note_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.cust_note_title = t2.cust_note_title,
            t1.cust_note_body = t2.cust_note_body,
            t1.cust_note_author = t2.cust_note_author,
            t1.cust_note_created = t2.cust_note_created
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.efex_cust_note_id,
              t1.cust_dtl_code,
              t1.company_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.cust_note_title,
              t1.cust_note_body,
              t1.cust_note_author,
              t1.cust_note_created
            )
          VALUES
            (
              t2.efex_cust_note_id,
              t2.cust_dtl_code,
              p_company_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              t2.cust_note_title,
              t2.cust_note_body,
              t2.cust_note_author,
              t2.cust_note_created
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_cust_note, 'N/A', i_log_level + 2, 'efex_cust_note_fact aggregated with merged count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_cust_note,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_cust_note_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_cust_note_fact_aggr;

FUNCTION efex_target_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count               NUMBER := 0;
  v_cur_mars_period         mars_date_dim.mars_period%TYPE;

  -- CURSOR DECLARATIONS
  -- Check whether any efex target modified yesterday.
  CURSOR csr_efex_target_count IS
    SELECT count(*) AS rec_count
    FROM
      efex_target
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(target_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  CURSOR csr_mars_period IS
    SELECT mars_period as cur_mars_period
    FROM mars_date_dim
    WHERE calendar_date = i_aggregation_date;

BEGIN
  -- Starting EFEX_TARGET_FACT aggregation.
  write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 1, 'Start - EFEX_TARGET_FACT aggregation.');

  -- Fetch the record from the csr_efex_target_count cursor.
  OPEN  csr_efex_target_count;
  FETCH csr_efex_target_count INTO v_rec_count;
  CLOSE csr_efex_target_count;

  -- If any efex_target records modified yesterday.
  write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'EFEX target received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'Try to get mars_period from mars_date_dim for aggregation date [' || i_aggregation_date || ']');

     OPEN csr_mars_period;
     FETCH csr_mars_period INTO v_cur_mars_period;

     IF csr_mars_period%NOTFOUND THEN
        write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'Error in getting mars_period for aggregation date [' || i_aggregation_date || ']');
        CLOSE csr_mars_period;
        RETURN constants.error;
     END IF;
     CLOSE csr_mars_period;

     write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'Delete efex_target_fact record with same target, sales territory and mars period first.');

     DELETE
     FROM efex_target_fact t1
     WHERE EXISTS (SELECT *
                   FROM
                     efex_target t2
                   WHERE
                     t1.efex_sales_terr_id = t2.sales_terr_id
                     AND t1.efex_target_id = t2.target_id
                     AND t1.mars_period = t2.mars_period
                     AND t2.valdtn_status = ods_constants.valdtn_valid
                     AND TRUNC(t2.target_lupdt) = i_aggregation_date
                     AND t2.efex_mkt_id = p_market_id);

     write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'efex_target_fact delete count [' || SQL%ROWCOUNT || ']');

     write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'Insert active records INTO efex_target_fact for the records received yesterday.');

     INSERT INTO efex_target_fact
       (
        sales_terr_code,
        efex_sales_terr_id,
        efex_target_id,
        mars_period,
        first_day_mars_period,
        efex_bus_unit_id,
        target_name,
        target_value,
        actual_value
       )
     SELECT
       t3.sales_terr_code,
       t1.sales_terr_id,
       t1.target_id,
       t1.mars_period,
       t2.calendar_date,
       t1.bus_unit_id,
       t1.target_name,
       t1.target_value,
       t1.actual_value
     FROM
       efex_target t1,
       mars_date_dim t2,
       efex_sales_terr_dim t3
     WHERE
       t1.mars_period = t2.mars_period
       AND t2.period_day_num = 1  -- first date of period
       AND t1.valdtn_status = ods_constants.valdtn_valid
       AND TRUNC(t1.target_lupdt) = i_aggregation_date
       AND t1.efex_mkt_id = p_market_id
       AND t1.status = 'A'
       AND t1.sales_terr_id = t3.efex_sales_terr_id
       AND t3.last_rec_flg = 'Y';

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'EFEX_TARGET_FACT aggregated with insert count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;


      -- Update the current period remaining trade promotion amount efex_assoc_dim table.
      write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'Update current period remaining trade promotion amount to efex_assoc_dim table.');

      -- Will reset the remaining_tp_amt to null if an associate doesn't have a target record for the current period.
      UPDATE
        efex_assoc_dim t1
      SET
        remaining_tp_amt = ( SELECT SUM(NVL(t2.target_value,0) - NVL(t2.actual_value, 0))
                               FROM efex_target_fact t2, efex_sales_terr_dim t3
                              WHERE t3.efex_sales_terr_id = t2.efex_sales_terr_id
                                AND t3.sales_terr_mgr_id = t1.efex_assoc_id
                                AND t3.last_rec_flg = 'Y'
                                AND t3.status = 'A'
                                AND t2.efex_target_id = c_tp_budget_target_id
                                AND t2.mars_period = v_cur_mars_period
                            );

      -- Number of customer detail record modified.
      write_log(ods_constants.data_type_efex_target, 'N/A', i_log_level + 2, 'EFEX_ASSOC_DIM modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_target,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.efex_target_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_target_fact_aggr;


FUNCTION format_cust_code (
  i_cust_code IN VARCHAR2,
  i_log_level  IN ods.log.log_level%TYPE
  ) RETURN varchar2 IS

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
    write_log(ods_constants.data_type_generic,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_1.format_cust_code: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    raise_application_error
      (-20001, 'Error converting cust_code to GRD cust_code format');

END format_cust_code;


PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  -- Write the entry into the log table.
  utils.ods_log (ods_constants.job_type_efex_aggregation,
                 i_data_type,
                 i_sort_field,
                 i_log_level,
                 i_log_text);

EXCEPTION
  WHEN OTHERS THEN
     NULL;
END write_log;

END scheduled_efex_aggr_stg_1;
/
