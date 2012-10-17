create or replace
PACKAGE         scheduled_efex_aggr_stg_2 IS

/*******************************************************************************
  NAME:      run_efex_aggregation_stage_2
  PURPOSE:   This procedure is the main routine, which calls the other package
             procedures and functions to aggregate all market driven efex data 
             from the dim tables to the fact tables.

             The scheduled efex aggregation staage 2 process is initiated by an 
             Oracle job that should be run after scheduled efex aggregation 
             stage 2 for both markets.

             The scheduled job will call this efex aggregation stage 2 package
             passing Aggregation Date.  
             Aggregation Date will be set to SYSDATE when called via the 
             scheduled job.

   NOTES:  The sequence of the function call within this procedure should not be
           changed because some of the data load rely on the load sequence.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   14/06/2011 Craig Drew           Created this prackage as a subset of
                                        Efex_scheduled_aggregation to break out 
                                        market driven aggreagtion from non 
                                        market aggregation
  1.1   29/08/2012 Mal Chambeyron     - Add lics_setting_configuration.retrieve_setting() for email

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     DATE     Aggregation Date                     20071001
  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_efex_aggregation_stage_2 (
  i_aggregation_date IN DATE
   );

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

END scheduled_efex_aggr_stg_2; 
/

create or replace
PACKAGE BODY         scheduled_efex_aggr_stg_2 IS

  c_future_date          CONSTANT DATE := TO_DATE('99991231','YYYYMMDD');
  c_tp_budget_target_id  CONSTANT efex_target_fact.efex_target_id%TYPE := 12;
  p_market_id            NUMBER;
  p_company_code         VARCHAR2(10);

  con_ema_group constant varchar2(32) := 'EFEX_CDW_POLLER'; 
  con_ema_code constant varchar2(32) := 'EMAIL_GROUP';
  con_email constant varchar2(256) := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);  

FUNCTION efex_distbn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_tot_distbn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_distbn_fact_wkly_snapshot (
  i_aggregation_date IN DATE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_cust_fact_aggr (
  i_aggregation_date IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_cust_opp_distbn_fact_aggr (
  i_aggregation_date IN DATE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_matl_opp_distbn_fact_aggr (
  i_aggregation_date IN DATE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;



PROCEDURE run_efex_aggregation_stage_2 (
  i_aggregation_date IN DATE
) IS

  -- VARIABLE DECLARATIONS
  v_processing_msg   constants.message_string;
  v_aggregation_date DATE;
  v_log_level        ods.log.log_level%TYPE;
  v_status           NUMBER;
  v_db_name          VARCHAR2(256) := NULL;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

BEGIN
  -- Initialise variables.
  v_log_level := 0;

  -- Get the Database name
  SELECT
    UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
  INTO
    v_db_name
  FROM
    dual;

  -- Start scheduled efex aggregation.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled EFEX Aggregation Stage 2 - Start');

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
    write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Will be aggregating EFEX data for date: ' || v_aggregation_date || '.');
  EXCEPTION
    WHEN OTHERS THEN
      v_processing_msg := 'Unable to convert the inputted Aggregation Date [' || TO_CHAR(i_aggregation_date, 'YYYYMMDD') || '] from string to date format.';
      RAISE e_processing_error;
  END;


  /************************************
   ***   CALLING FACT AGGREGATIONS  ***
   ************************************/

  -- Calling the efex_distbn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_distbn_fact_aggr function.');
  v_status := efex_distbn_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_distbn_fact_aggr.';
    RAISE e_processing_error;
  END IF;

 -- Calling the efex_distbn_fact_wkly_snapshot function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_distbn_fact_wkly_snapshot function.');
  v_status := efex_distbn_fact_wkly_snapshot(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_distbn_fact_wkly_snapshot.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_tot_distbn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_tot_distbn_fact_aggr function.');
  v_status := efex_tot_distbn_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_tot_distbn_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_cust_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_cust_fact_aggr function.');
  v_status := efex_cust_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_cust_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_cust_opp_distbn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_cust_opp_distbn_fact_aggr function.');
  v_status := efex_cust_opp_distbn_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_cust_opp_distbn_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_matl_opp_distbn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_matl_opp_distbn_fact_aggr function.');
  v_status := efex_matl_opp_distbn_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_matl_opp_distbn_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- End scheduled efex aggregation processing.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Efex Aggregation Stage 2 - End');

  -- utils.send_short_email('Group_ANZ_Venus_Production_Notification@smtp.ap.mars', 'Scheduled Efex Aggregation Stage 2', 'Scheduled Efex Aggregation Stage 2 Completed for: ' || v_aggregation_date);
  utils.send_short_email(con_email, 'Scheduled Efex Aggregation Stage 2', 'Scheduled Efex Aggregation Stage 2 Completed for: ' || v_aggregation_date);
  
EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_EFEX_AGGR_STG_2.RUN_EFEX_AGGREGATION_STAGE_2: ERROR: ' || v_processing_msg);

    utils.send_email_to_group(ods_constants.job_type_efex_aggregation,
                              'MFANZ CDW Scheduled EFEX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_EFEX_AGGR_STG_2.RUN_EFEX_AGGREGATION_STAGE_2: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_EFEX_AGGR_STG_2.RUN_EFEX_AGGREGATION_STAGE_2: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    utils.send_email_to_group(ods_constants.job_type_efex_aggregation,
                              'MFANZ CDW Scheduled EFEX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_EFEX_AGGR_STG_2.RUN_EFEX_AGGREGATION_STAGE_2: ERROR: ' || SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

END run_efex_aggregation_stage_2;


/****************************
 ***   FACT AGGREGATIONS  ***
 ****************************/
FUNCTION efex_distbn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count            NUMBER := 0;
  v_del_count            NUMBER := 0;
  v_ins_count            NUMBER := 0;
  v_upd_count            NUMBER := 0;
  v_efex_cust_id         efex_cust.efex_cust_id%TYPE;
  v_efex_matl_id         efex_matl_dim.efex_matl_id%TYPE;
  v_distbn_yyyyppw       mars_date_dim.mars_week%TYPE;
  v_mars_week_end_date   DATE;
  v_start_yyyyppw        mars_date_dim.mars_week%TYPE;

  v_first_row            BOOLEAN := TRUE;

  v_tot_new_gaps         NUMBER := 0;
  v_tot_closed_gaps      NUMBER := 0;

  v_commit_count         NUMBER;
  c_commit_block         constant NUMBER := 10000;
  v_rows_updated         number(1) := 0;
/* INSERTED FOR TESTING */
  
/*************************/

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether any original source for efex_distbn_xactn_dim record modified yesterday.
  CURSOR csr_distbn_count IS
    SELECT count(*) AS rec_count
    FROM efex_distbn
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(distbn_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  CURSOR csr_mars_week IS
    SELECT mars_week
    FROM mars_date_dim
    WHERE calendar_date = i_aggregation_date;

  CURSOR csr_efex_distbn_xactn IS
    SELECT
      t1.gap,  -- take the latest gap as the weekly tot_gaps
      t2.calendar_date as mars_week_end_date,
      t1.distbn_yyyyppw,
      t1.distbn_yyyypp,
      t1.cust_dtl_code,
      t1.efex_matl_id,
      t1.company_code,
      t1.distbn_xactn_code,
      t1.distbn_code,
      t1.efex_cust_id,
      t1.sales_terr_code,
      t1.efex_sales_terr_id,
      t1.efex_sgmnt_id,
      t1.efex_bus_unit_id,
      t4.efex_matl_subgrp_id,
      t4.efex_matl_grp_id,
      t1.efex_assoc_id,
      t1.efex_range_id,
      t1.rqd_flg_code,
      t1.facing_qty,
      t1.display_qty,
      t1.rqd,
      t1.ranged,
      t1.gap_new,
      t1.gap_closed,
      CASE WHEN (t2.mars_week_of_period = t3.period_end_week) THEN 'Y' ELSE 'N' END as eop_flg
    FROM
      efex_distbn_xactn_dim t1,
      mars_date_dim t2,
      (SELECT mars_period, max(mars_week_of_period) as period_end_week
       FROM mars_date_dim
       GROUP BY mars_period) t3,
      efex_matl_matl_subgrp_dim t4
    WHERE
 --     t1.last_rec_flg = 'Y'   AND 
        t1.status = 'A'    -- only pick the active transaction
      AND t1.distbn_yyyyppw = v_start_yyyyppw
      AND t1.distbn_yyyyppw = t2.mars_week
      AND t2.mars_day_of_week = 7
      AND t1.distbn_yyyypp = t3.mars_period
      AND t1.efex_matl_id = t4.efex_matl_id
      AND t1.efex_sgmnt_id = t4.efex_sgmnt_id
      AND t4.status = 'A'
    ORDER BY t1.distbn_yyyyppw,t1.efex_cust_id,t1.efex_matl_id,t1.distbn_xactn_code;

  rv_efex_distbn_xactn csr_efex_distbn_xactn%ROWTYPE;
  prev_efex_distbn_xactn csr_efex_distbn_xactn%ROWTYPE;

BEGIN
  v_commit_count := 0;

  -- Starting efex_distbn_fact aggregation.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Start - EFEX_DISTBN_FACT aggregation.');

  -- Pick the mars_week that will re-process the weekly distribution (start from last week only)
  OPEN csr_mars_week;
  FETCH csr_mars_week INTO v_start_yyyyppw;
  CLOSE csr_mars_week;

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 're-process weekly distribution start from [' || v_start_yyyyppw || ']');

  -- Need to re-run this even if no distribution received yesterday because some
  -- efex_distbn_xactn_dim records created from efex_sales_terr and efex_cust process.
  FOR rv_efex_distbn_xactn IN csr_efex_distbn_xactn LOOP
    BEGIN
       IF v_first_row THEN
         prev_efex_distbn_xactn := rv_efex_distbn_xactn;
         v_first_row := FALSE;
       END IF;

       IF (   rv_efex_distbn_xactn.efex_cust_id   = prev_efex_distbn_xactn.efex_cust_id 
          AND rv_efex_distbn_xactn.efex_matl_id   = prev_efex_distbn_xactn.efex_matl_id
          AND rv_efex_distbn_xactn.distbn_yyyyppw = prev_efex_distbn_xactn.distbn_yyyyppw )  
       THEN
         v_tot_new_gaps  := v_tot_new_gaps + nvl(rv_efex_distbn_xactn.gap_new,0);
         v_tot_closed_gaps := v_tot_closed_gaps + nvl(rv_efex_distbn_xactn.gap_closed,0);
         prev_efex_distbn_xactn := rv_efex_distbn_xactn;
       ELSE       
         BEGIN
            -- First try to update the distribution fact record as snapshot should have created it.
           UPDATE efex_distbn_fact
             SET
               sales_terr_code = prev_efex_distbn_xactn.sales_terr_code,
               efex_sales_terr_id = prev_efex_distbn_xactn.efex_sales_terr_id,
               efex_sgmnt_id = prev_efex_distbn_xactn.efex_sgmnt_id,
               efex_assoc_id = prev_efex_distbn_xactn.efex_assoc_id,
               distbn_xactn_code = prev_efex_distbn_xactn.distbn_xactn_code,
               efex_matl_subgrp_id = prev_efex_distbn_xactn.efex_matl_subgrp_id,
               efex_matl_grp_id = prev_efex_distbn_xactn.efex_matl_grp_id,
               tot_gaps = prev_efex_distbn_xactn.gap,
               tot_gaps_new = v_tot_new_gaps,
               tot_gaps_closed = v_tot_closed_gaps,
               rqd_flg_code = prev_efex_distbn_xactn.rqd_flg_code,
               facing_qty = prev_efex_distbn_xactn.facing_qty,
               display_qty = prev_efex_distbn_xactn.display_qty,
               rqd = prev_efex_distbn_xactn.rqd,
               ranged = prev_efex_distbn_xactn.ranged,
               gap = prev_efex_distbn_xactn.gap,
               gap_new = prev_efex_distbn_xactn.gap_new,
               gap_closed = prev_efex_distbn_xactn.gap_closed
             WHERE mars_week_end_date = prev_efex_distbn_xactn.mars_week_end_date
               AND cust_dtl_code = prev_efex_distbn_xactn.cust_dtl_code
               AND efex_matl_id = prev_efex_distbn_xactn.efex_matl_id;
           v_rows_updated := SQL%ROWCOUNT;
           v_upd_count := v_upd_count + v_rows_updated;
           IF v_rows_updated = 0 THEN
             -- Should the update have updated no rows then in Insert a new distribution fact record
             INSERT INTO efex_distbn_fact
               (
                mars_week_end_date,
                cust_dtl_code,
                efex_matl_id,
                distbn_yyyyppw,
                distbn_yyyypp,
                company_code,
                distbn_xactn_code,
                distbn_code,
                efex_cust_id,
                sales_terr_code,
                efex_sales_terr_id,
                efex_sgmnt_id,
                efex_bus_unit_id,
                efex_matl_subgrp_id,
                efex_matl_grp_id,
                efex_assoc_id,
                efex_range_id,
                tot_gaps,
                tot_gaps_new,
                tot_gaps_closed,
                rqd_flg_code,
                facing_qty,
                display_qty,
                rqd,
                ranged,
                gap,
                gap_new,
                gap_closed,
                eop_flg
               )
             VALUES
               (
                prev_efex_distbn_xactn.mars_week_end_date,
                prev_efex_distbn_xactn.cust_dtl_code,
                prev_efex_distbn_xactn.efex_matl_id,
                prev_efex_distbn_xactn.distbn_yyyyppw,
                prev_efex_distbn_xactn.distbn_yyyypp,
                prev_efex_distbn_xactn.company_code,
                prev_efex_distbn_xactn.distbn_xactn_code,
                prev_efex_distbn_xactn.distbn_code,
                prev_efex_distbn_xactn.efex_cust_id,
                prev_efex_distbn_xactn.sales_terr_code,
                prev_efex_distbn_xactn.efex_sales_terr_id,
                prev_efex_distbn_xactn.efex_sgmnt_id,
                prev_efex_distbn_xactn.efex_bus_unit_id,
                prev_efex_distbn_xactn.efex_matl_subgrp_id,
                prev_efex_distbn_xactn.efex_matl_grp_id,
                prev_efex_distbn_xactn.efex_assoc_id,
                prev_efex_distbn_xactn.efex_range_id,
                prev_efex_distbn_xactn.gap,  -- take the latest gap as the weekly tot_gaps
                v_tot_new_gaps,
                v_tot_closed_gaps,               
                prev_efex_distbn_xactn.rqd_flg_code,
                prev_efex_distbn_xactn.facing_qty,
                prev_efex_distbn_xactn.display_qty,
                prev_efex_distbn_xactn.rqd,
                prev_efex_distbn_xactn.ranged,
                prev_efex_distbn_xactn.gap,
                prev_efex_distbn_xactn.gap_new,
                prev_efex_distbn_xactn.gap_closed,
                prev_efex_distbn_xactn.eop_flg
               );
              v_ins_count := v_ins_count + SQL%ROWCOUNT;
           END IF;  
         EXCEPTION
            WHEN OTHERS then
              write_log(ods_constants.data_type_efex_distbn, 'ERROR', i_log_level + 2, 'Error from Update/Insert for date/cust code/matl [' || rv_efex_distbn_xactn.mars_week_end_date ||
                          '/' ||  rv_efex_distbn_xactn.cust_dtl_code || '/' || rv_efex_distbn_xactn.efex_matl_id || '] ERROR - ' || SUBSTR(SQLERRM, 1, 512));
              RAISE e_processing_error;
         END;
         
         v_commit_count := v_commit_count + 1;
         IF ( v_commit_count >= c_commit_block ) THEN
           COMMIT;
           v_commit_count := 0;
         END IF;
         
         v_tot_new_gaps    := 0;
         v_tot_closed_gaps := 0;
         prev_efex_distbn_xactn := rv_efex_distbn_xactn;
       END IF;

    EXCEPTION
          WHEN OTHERS THEN
               write_log(ods_constants.data_type_efex_distbn, 'ERROR', i_log_level + 2, 'Error Record date/cust code/matl [' || rv_efex_distbn_xactn.mars_week_end_date ||
                          '/' ||  rv_efex_distbn_xactn.cust_dtl_code || '/' || rv_efex_distbn_xactn.efex_matl_id || '] ERROR - ' || SUBSTR(SQLERRM, 1, 512));
          RAISE e_processing_error;

    END;
  END LOOP;
  -- Update / Insert the final row.

  IF v_first_row = FALSE THEN
    BEGIN
      -- First try to update the distribution fact record as snapshot should have created it.
      UPDATE efex_distbn_fact
        SET
          sales_terr_code = prev_efex_distbn_xactn.sales_terr_code,
          efex_sales_terr_id = prev_efex_distbn_xactn.efex_sales_terr_id,
          efex_sgmnt_id = prev_efex_distbn_xactn.efex_sgmnt_id,
          efex_assoc_id = prev_efex_distbn_xactn.efex_assoc_id,
          distbn_xactn_code = prev_efex_distbn_xactn.distbn_xactn_code,
          efex_matl_subgrp_id = prev_efex_distbn_xactn.efex_matl_subgrp_id,
          efex_matl_grp_id = prev_efex_distbn_xactn.efex_matl_grp_id,
          tot_gaps = prev_efex_distbn_xactn.gap,
          tot_gaps_new = v_tot_new_gaps,
          tot_gaps_closed = v_tot_closed_gaps,
          rqd_flg_code = prev_efex_distbn_xactn.rqd_flg_code,
          facing_qty = prev_efex_distbn_xactn.facing_qty,
          display_qty = prev_efex_distbn_xactn.display_qty,
          rqd = prev_efex_distbn_xactn.rqd,
          ranged = prev_efex_distbn_xactn.ranged,
          gap = prev_efex_distbn_xactn.gap,
          gap_new = prev_efex_distbn_xactn.gap_new,
          gap_closed = prev_efex_distbn_xactn.gap_closed
        WHERE mars_week_end_date = prev_efex_distbn_xactn.mars_week_end_date
          AND cust_dtl_code = prev_efex_distbn_xactn.cust_dtl_code
          AND efex_matl_id = prev_efex_distbn_xactn.efex_matl_id;
      v_rows_updated := SQL%ROWCOUNT;
      v_upd_count := v_upd_count + v_rows_updated;
      IF v_rows_updated = 0 THEN
        -- Should the update have updated no rows then in Insert a new distribution fact record
        INSERT INTO efex_distbn_fact
          (
           mars_week_end_date,
           cust_dtl_code,
           efex_matl_id,
           distbn_yyyyppw,
           distbn_yyyypp,
           company_code,
           distbn_xactn_code,
           distbn_code,
           efex_cust_id,
           sales_terr_code,
           efex_sales_terr_id,
           efex_sgmnt_id,
           efex_bus_unit_id,
           efex_matl_subgrp_id,
           efex_matl_grp_id,
           efex_assoc_id,
           efex_range_id,
           tot_gaps,
           tot_gaps_new,
           tot_gaps_closed,
           rqd_flg_code,
           facing_qty,
           display_qty,
           rqd,
           ranged,
           gap,
           gap_new,
           gap_closed,
           eop_flg
          )
        VALUES
          (
           prev_efex_distbn_xactn.mars_week_end_date,
           prev_efex_distbn_xactn.cust_dtl_code,
           prev_efex_distbn_xactn.efex_matl_id,
           prev_efex_distbn_xactn.distbn_yyyyppw,
           prev_efex_distbn_xactn.distbn_yyyypp,
           prev_efex_distbn_xactn.company_code,
           prev_efex_distbn_xactn.distbn_xactn_code,
           prev_efex_distbn_xactn.distbn_code,
           prev_efex_distbn_xactn.efex_cust_id,
           prev_efex_distbn_xactn.sales_terr_code,
           prev_efex_distbn_xactn.efex_sales_terr_id,
           prev_efex_distbn_xactn.efex_sgmnt_id,
           prev_efex_distbn_xactn.efex_bus_unit_id,
           prev_efex_distbn_xactn.efex_matl_subgrp_id,
           prev_efex_distbn_xactn.efex_matl_grp_id,
           prev_efex_distbn_xactn.efex_assoc_id,
           prev_efex_distbn_xactn.efex_range_id,
           prev_efex_distbn_xactn.gap,  -- take the latest gap as the weekly tot_gaps
           v_tot_new_gaps,
           v_tot_closed_gaps,               
           prev_efex_distbn_xactn.rqd_flg_code,
           prev_efex_distbn_xactn.facing_qty,
           prev_efex_distbn_xactn.display_qty,
           prev_efex_distbn_xactn.rqd,
           prev_efex_distbn_xactn.ranged,
           prev_efex_distbn_xactn.gap,
           prev_efex_distbn_xactn.gap_new,
           prev_efex_distbn_xactn.gap_closed,
           prev_efex_distbn_xactn.eop_flg
          );
         v_ins_count := v_ins_count + SQL%ROWCOUNT;
      END IF;  
    EXCEPTION
       WHEN OTHERS then
        write_log(ods_constants.data_type_efex_distbn, 'ERROR', i_log_level + 2, 'Error from Update/Insert for date/cust code/matl [' || rv_efex_distbn_xactn.mars_week_end_date ||
                    '/' ||  rv_efex_distbn_xactn.cust_dtl_code || '/' || rv_efex_distbn_xactn.efex_matl_id || '] ERROR - ' || SUBSTR(SQLERRM, 1, 512));
        RAISE e_processing_error;
    END;
  END IF;  
  COMMIT;
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 2, 'Complete - EFEX_DISBTN_FACT aggregation with insert count [' ||
            v_ins_count || '] and delete count [' || v_del_count || '] and upd count [' || v_upd_count || ']');
  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_distbn,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.efex_distbn_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    IF csr_efex_distbn_xactn%ISOPEN THEN
        CLOSE csr_efex_distbn_xactn;
    END IF;
    RETURN constants.error;
END efex_distbn_fact_aggr;

FUNCTION efex_tot_distbn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_ins_count            NUMBER := 0;
  v_mars_week_end_date   DATE;

  -- CURSOR DECLARATIONS
  -- Select the mars_week stard and end date.
  CURSOR csr_mars_week_dates IS
    SELECT
      calendar_date     as mars_week_end_date
    FROM
      mars_date_dim
    WHERE mars_week = (SELECT mars_week
                       FROM mars_date_dim
                       WHERE calendar_date = i_aggregation_date)
      AND mars_day_of_week = 7;

BEGIN
  -- Starting efex_tot_distbn_fact aggregation.
  write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 1, 'Start - EFEX_TOT_DISTBN_FACT aggregation.');

  write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 1, 'Find the current mars week end date.');

  OPEN csr_mars_week_dates;
  FETCH csr_mars_week_dates INTO v_mars_week_end_date;
  IF csr_mars_week_dates%NOTFOUND THEN
      write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 2, 'Error in finding the mars_week_end_date');
      CLOSE csr_mars_week_dates;
      RETURN constants.error;
  END IF;
  CLOSE csr_mars_week_dates;

  write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 1, 'Delete from fact table with mars_week_end_date [' || v_mars_week_end_date || ']' );

  DELETE
    efex_tot_distbn_fact
  WHERE
    mars_week_end_date = v_mars_week_end_date;

  write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 1, 'Delete count [' || SQL%ROWCOUNT || ']. Now Insert current total distbn into fact table.' );

  -- Insert into current total distribution from dim to fact for this mars_week.
  INSERT INTO efex_tot_distbn_fact
    (
     mars_week_end_date,
     cust_dtl_code,
     efex_matl_grp_id,
     company_code,
     distbn_xactn_code,
     distbn_code,
     efex_cust_id,
     sales_terr_code,
     efex_sales_terr_id,
     efex_sgmnt_id,
     efex_bus_unit_id,
     efex_assoc_id,
     tot_facings
    )
  SELECT
    v_mars_week_end_date,
    cust_dtl_code,
    efex_matl_grp_id,
    company_code,
    distbn_xactn_code,
    distbn_code,
    efex_cust_id,
    sales_terr_code,
    efex_sales_terr_id,
    efex_sgmnt_id,
    efex_bus_unit_id,
    efex_assoc_id,
    tot_facings
  FROM
    efex_tot_distbn_xactn_dim
  WHERE
    last_rec_flg = 'Y';

  v_ins_count := SQL%ROWCOUNT;

  COMMIT;

  write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 2, 'Complete - EFEX_TOT_DISBTN_FACT aggregation with insert count [' ||
            v_ins_count || ']');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_tot_distbn,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGR_STG_2.efex_tot_distbn_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_tot_distbn_fact_aggr;


FUNCTION efex_distbn_fact_wkly_snapshot (
  i_aggregation_date IN DATE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_aggregation_date   DATE;
  v_this_mars_week_end_date DATE;

  -- CURSOR DECLARATIONS
  CURSOR csr_mars_date IS
    SELECT
      calendar_date,
      t1.mars_period,
      mars_week,
      mars_day_of_week,
      mars_week_of_period,
      t2.period_end_week
    FROM mars_date_dim  t1 ,
         (SELECT mars_period, max(mars_week_of_period) as period_end_week
          FROM mars_date_dim
          GROUP BY mars_period) t2
    WHERE mars_week = (SELECT mars_week
                       FROM mars_date_dim
                       WHERE calendar_date = i_aggregation_date)
      AND mars_day_of_week = 7
      AND t1.mars_period = t2.mars_period;

    rv_mars_date csr_mars_date%ROWTYPE;

BEGIN

  -- Starting create snapshot for a week if it is the first date of a mars_week.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Start - Create Weekly EFEX_DISTBN_FACT snapshot');

  -- Use current date as the aggregation_date we need to check the first day of the current week
  --v_aggregation_date := TRUNC(sysdate);

  OPEN csr_mars_date;
  FETCH csr_mars_date INTO rv_mars_date;
  CLOSE csr_mars_date;

    v_this_mars_week_end_date := rv_mars_date.calendar_date;

    write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'Create weekly distribution snapshot for this week end date [' || v_this_mars_week_end_date || '] ' ||
                  ' and those customer material has not been created yet');

        INSERT /*+ APPEND */ INTO efex_distbn_fact
          (
            mars_week_end_date,
            cust_dtl_code,
            efex_matl_id,
            distbn_yyyyppw,
            distbn_yyyypp,
            company_code,
            distbn_xactn_code,
            distbn_code,
            efex_cust_id,
            sales_terr_code,
            efex_sales_terr_id,
            efex_sgmnt_id,
            efex_bus_unit_id,
            efex_matl_subgrp_id,
            efex_matl_grp_id,
            efex_assoc_id,
            efex_range_id,
            tot_gaps,
            tot_gaps_new,
            tot_gaps_closed,
            rqd_flg_code,
            facing_qty,
            display_qty,
            rqd,
            ranged,
            gap,
            gap_new,
            gap_closed,
            eop_flg
          )
        SELECT
          v_this_mars_week_end_date,
          cust_dtl_code,
          t1.efex_matl_id,
          rv_mars_date.mars_week,
          rv_mars_date.mars_period,
          company_code,
          distbn_xactn_code,
          distbn_code,
          efex_cust_id,
          sales_terr_code,
          t1.efex_sales_terr_id,
          t1.efex_sgmnt_id,
          t1.efex_bus_unit_id,
          t3.efex_matl_subgrp_id, -- pick the latest subgroup for the material and segment
          t3.efex_matl_grp_id,
          efex_assoc_id,
          efex_range_id,
          gap,
          0,
          0,
          rqd_flg_code,
          facing_qty,
          display_qty,
          rqd,
          ranged,
          gap,
          0,
          0,
          CASE WHEN ( rv_mars_date.mars_week_of_period = rv_mars_date.period_end_week) THEN 'Y' ELSE 'N' END
        FROM
          efex_distbn_xactn_dim t1,
          efex_matl_matl_subgrp_dim t3
        WHERE
          t1.efex_matl_id = t3.efex_matl_id
          AND t1.efex_sgmnt_id = t3.efex_sgmnt_id
          AND t3.status = 'A'
          AND NOT EXISTS (SELECT *
                      FROM efex_distbn_fact t2
                      WHERE t2.efex_cust_id = t1.efex_cust_id
                        AND t2.efex_matl_id = t1.efex_matl_id
                        AND t2.mars_week_end_date = v_this_mars_week_end_date)
          AND t1.status = 'A'
          AND t1.last_rec_flg = 'Y'
          AND t1.eff_end_date = c_future_date;  -- only the one hasn't been closed

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'Snapshot record created count [' || SQL%ROWCOUNT || ']');

  commit;

  -- Completed efex_distbn_fact_wkly_snapshot
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Completed efex_distbn_fact_wkly_snapshot.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_distbn,
              'ERROR',
              0,
              'SCHEDULED_EFEX_AGGR_STG_2.efex_distbn_fact_wkly_snapshot: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END efex_distbn_fact_wkly_snapshot;

FUNCTION efex_cust_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_upd_count            NUMBER := 0;
  v_curr_period          mars_date_dim.mars_period%TYPE;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  CURSOR csr_mars_period IS
    SELECT mars_period
    FROM mars_date_dim
    WHERE
      --calendar_date = trunc(sysdate);
      calendar_date = i_aggregation_date;

BEGIN

  -- Starting current period snapshot of efex customer to efex_cust_fact
  utils.ods_log (ods_constants.job_type_efex_aggregation, ods_constants.data_type_efex_cust, 'N/A', i_log_level + 1, 'Starting efex_cust_fact_aggr.');

  -- Fetch the record from the csr_mars_period cursor.
  OPEN csr_mars_period;
  FETCH csr_mars_period INTO  v_curr_period;
  CLOSE  csr_mars_period;

  utils.ods_log (ods_constants.job_type_efex_aggregation, ods_constants.data_type_efex_cust, 'N/A', i_log_level + 2, 'Merge into EFEX_CUST_FACT for Period - ' || v_curr_period);

  -- Insert or update the efex_cust_fact table based on efex_cust_dtl_dim table.
  MERGE INTO efex_cust_fact t1
  USING (SELECT
           v_curr_period as cust_yyyypp,
           efex_cust_id,
           cust_dtl_code
         FROM
           efex_cust_dtl_dim
         WHERE
           last_rec_flg = 'Y'
           AND status = 'A'
         MINUS
         SELECT
           cust_yyyypp,
           efex_cust_id,
           cust_dtl_code
         FROM
           efex_cust_fact
         WHERE
           cust_yyyypp = v_curr_period
       ) t2
      ON (t1.cust_yyyypp = t2.cust_yyyypp AND t1.efex_cust_id = t2.efex_cust_id)
      WHEN MATCHED THEN
        UPDATE SET
             t1.cust_dtl_code = t2.cust_dtl_code
      WHEN NOT MATCHED THEN
        INSERT
              (
               t1.cust_yyyypp,
               t1.efex_cust_id,
               t1.cust_dtl_code
              )
              VALUES
              (
               t2.cust_yyyypp,
               t2.efex_cust_id,
               t2.cust_dtl_code
              );

  -- Number of records inserted.
  utils.ods_log (ods_constants.job_type_efex_aggregation, ods_constants.data_type_efex_cust, 'N/A', i_log_level + 2, 'Inserted count for Period/Count - ' || v_curr_period || '/' || SQL%ROWCOUNT);

  -- Commit.
  COMMIT;

  -- Completed procedure.
  utils.ods_log (ods_constants.job_type_efex_aggregation, ods_constants.data_type_efex_cust, 'N/A', i_log_level+1, 'Completed efex_cust_fact_aggr');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    utils.ods_log (ods_constants.job_type_efex_aggregation, ods_constants.data_type_efex_cust,'ERROR',i_log_level,
             'efex_cust_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RETURN constants.error;
END efex_cust_fact_aggr;

FUNCTION efex_cust_opp_distbn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_aggregation_date   DATE;
  v_eop_flg            efex_matl_opprtnty_distbn_fact.eop_flg%TYPE := 'N';

  -- CURSOR DECLARATIONS
  CURSOR csr_mars_date IS
    SELECT
      t1.mars_period,
      mars_week,
      mars_week_of_period,
      t2.period_end_week
    FROM mars_date_dim  t1 ,
         (SELECT mars_period, max(mars_week_of_period) as period_end_week
          FROM mars_date_dim
          GROUP BY mars_period) t2
    WHERE t1.calendar_date = i_aggregation_date
      AND t1.mars_period = t2.mars_period;
  rv_mars_date csr_mars_date%ROWTYPE;

BEGIN
  -- Starting create weekly customer level opportunity distribution gap counts.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Start - Create Weekly EFEX_CUST_opprtnty_DISTBN_FACT snapshot');

  -- Use current date as the aggregation_date we need to do snapshot for this mars week
  --v_aggregation_date := TRUNC(sysdate);

  OPEN csr_mars_date;
  FETCH csr_mars_date INTO rv_mars_date;
  CLOSE csr_mars_date;

  IF rv_mars_date.mars_week_of_period = rv_mars_date.period_end_week THEN
     v_eop_flg := 'Y';
  ELSE
     v_eop_flg := 'N';
  END IF;

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'Current week [' || rv_mars_date.mars_week || '] ' ||
                  ' and end of period week num [' || rv_mars_date.period_end_week || '] eop_flg is [' || v_eop_flg || ']');

  DELETE FROM efex_cust_opprtnty_distbn_fact
  WHERE distbn_yyyyppw = rv_mars_date.mars_week;

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'Delete count [' || SQL%ROWCOUNT || ']');

  INSERT INTO efex_cust_opprtnty_distbn_fact
    (efex_cust_id,
     cust_dtl_code,
     distbn_yyyyppw,
     distbn_yyyypp,
     tot_gaps,
     eop_flg
    )
  SELECT
    t2.efex_cust_id,
    t2.cust_dtl_code,
    rv_mars_date.mars_week as distbn_yyyyppw,
    rv_mars_date.mars_period as distbn_yyyypp,
    count(t1.efex_matl_id) as tot_gaps,
    v_eop_flg as eop_flg
  FROM
    efex_range_matl_fact t1,  -- Generate the dummy distribution from DDS rather than loading from EFEX
    efex_cust_dtl_dim t2,
    efex_matl_matl_subgrp_dim t3,
    efex_sales_terr_dim t4
  WHERE
    t1.efex_range_id = t2.efex_range_id
    AND t1.efex_matl_id = t3.efex_matl_id
    AND t4.efex_sales_terr_id = t2.efex_sales_terr_id
       AND t4.efex_sgmnt_id = t3.efex_sgmnt_id
    AND NOT EXISTS (SELECT *
                    FROM efex_distbn_dim t3         -- Never be a real distribution item
                    WHERE t3.efex_cust_id = t2.efex_cust_id
                      AND t3.efex_matl_id = t1.efex_matl_id )
    AND t1.status = 'A'
    AND t2.status = 'A'
    AND t3.status = 'A'
    AND t2.active_flg = 'Y'
    AND t2.last_rec_flg = 'Y'
    AND t4.last_rec_flg = 'Y'
  GROUP BY t2.efex_cust_id, cust_dtl_code;

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'efex_cust_opprtnty_distbn_fact insert count [' || SQL%ROWCOUNT || ']');

  COMMIT;

  -- Completed efex_cust_opp_distbn_fact_aggr
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Completed efex_cust_opp_distbn_fact_aggr.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_distbn,
              'ERROR',
              0,
              'SCHEDULED_EFEX_AGGR_STG_2.EFEX_CUST_OPP_DISTBN_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END efex_cust_opp_distbn_fact_aggr;

FUNCTION efex_matl_opp_distbn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_aggregation_date   DATE;
  v_eop_flg            efex_matl_opprtnty_distbn_fact.eop_flg%TYPE := 'N';

  -- CURSOR DECLARATIONS
  CURSOR csr_mars_date IS
    SELECT
      t1.mars_period,
      mars_week,
      mars_week_of_period,
      t2.period_end_week
    FROM mars_date_dim  t1 ,
         (SELECT mars_period, max(mars_week_of_period) as period_end_week
          FROM mars_date_dim
          GROUP BY mars_period) t2
    WHERE t1.calendar_date = i_aggregation_date
      AND t1.mars_period = t2.mars_period;
  rv_mars_date csr_mars_date%ROWTYPE;

BEGIN
  -- Starting create weekly material level opportunity distribution gap counts.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Start - Create Weekly EFEX_MATL_opprtnty_DISTBN_FACT snapshot');

  -- Use current date as the aggregation_date, we do snapshot for current mars week.
  --v_aggregation_date := TRUNC(sysdate);

  OPEN csr_mars_date;
  FETCH csr_mars_date INTO rv_mars_date;
  CLOSE csr_mars_date;

  IF rv_mars_date.mars_week_of_period = rv_mars_date.period_end_week THEN
     v_eop_flg := 'Y';
  ELSE
     v_eop_flg := 'N';
  END IF;

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'Current week [' || rv_mars_date.mars_week || '] ' ||
                  ' and end of period week num [' || rv_mars_date.period_end_week || '] eop_flg is [' || v_eop_flg || ']');

  DELETE FROM efex_matl_opprtnty_distbn_fact
  WHERE distbn_yyyyppw = rv_mars_date.mars_week;

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'efex_matl_opprtnty_distbn_fact delete count [' || SQL%ROWCOUNT || ']');

  INSERT INTO efex_matl_opprtnty_distbn_fact
    (efex_matl_id,
     distbn_yyyyppw,
     distbn_yyyypp,
     tot_gaps,
     eop_flg
    )
  SELECT
    t1.efex_matl_id,
    rv_mars_date.mars_week as distbn_yyyyppw,
    rv_mars_date.mars_period as distbn_yyyypp,
    count(t1.efex_matl_id) as tot_gaps,
    v_eop_flg as eop_flg
  FROM
    efex_range_matl_fact t1,  -- Generate the dummy distribution from DDS rather than loading from EFEX
    efex_cust_dtl_dim t2,
    efex_matl_matl_subgrp_dim t3,
    efex_sales_terr_dim t4
  WHERE
    t1.efex_range_id = t2.efex_range_id
    AND t1.efex_matl_id = t3.efex_matl_id
    AND t4.efex_sales_terr_id = t2.efex_sales_terr_id
       AND t4.efex_sgmnt_id = t3.efex_sgmnt_id
    AND NOT EXISTS (SELECT *
                    FROM efex_distbn_xactn_dim t3         -- No current active transaction in distribution
                    WHERE t3.efex_cust_id = t2.efex_cust_id
                      AND t3.efex_matl_id = t1.efex_matl_id
                      AND t3.last_rec_flg = 'Y'
                      AND t3.status = 'A' )
    AND t1.status = 'A'
    AND t2.status = 'A'
    AND t3.status = 'A'
    AND t2.active_flg = 'Y'
    AND t2.last_rec_flg = 'Y'
    AND t4.last_rec_flg = 'Y'
  GROUP BY t1.efex_matl_id;

  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'efex_matl_opprtnty_distbn_fact modified count [' || SQL%ROWCOUNT || ']');

  COMMIT;

  -- Completed efex_matl_opp_distbn_fact_aggr
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Completed efex_matl_opp_distbn_fact_aggr.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_distbn,
              'ERROR',
              0,
              'SCHEDULED_EFEX_AGGR_STG_2.efex_matl_opp_distbn_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END efex_matl_opp_distbn_fact_aggr;


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
             'SCHEDULED_EFEX_AGGR_STG_2.format_cust_code: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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

END scheduled_efex_aggr_stg_2;
/
