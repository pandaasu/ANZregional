CREATE OR REPLACE PACKAGE           "SCHEDULED_AGGREGATION" IS

/*******************************************************************************
  NAME:      run_scheduled_aggregation
  PURPOSE:   This procedure is the main routine, which calls the other package
             procedures and functions. TThe scheduled aggregation process is
             initiated by an Oracle job that will run once daily at 12:15am
             (Local time based on the Company).  The scheduled job will call
             the aggregation procedure passing Company Code and Aggregation Date
             as parameters.  Aggregation Date will be set to SYSDATE-1 when called
             via the scheduled job.  However, by passing Aggregation Date as a
             parameter this will allow for re-running of past aggregations when
             required.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this procedure.
  1.1   22/03/2006 Toui Lepkhammany     MOD: Modify forecast_fact_aggregation to
                                        allow for forecast type FCST into FCST_FACT table.
                                        MOD: Modify forecast_fact_aggregation to  allow for
                                        net and gross value entries.
  1.2   01/05/2006 Naresh Sharma        MOD: delivery_fact_aggregation
                                        MOD: purch_order_fact_aggregation
                                        MOD: order_fact_aggregation
                                        The above procedures were modified to cater
                                        to the requirements for CSL reporting.
  1.3   3/06/2007 Kris Lee              MOD: forecast_fact_aggregation()
                                        MOD: dmd_plng_fcst_fact_aggregation()
                                        The above procedures were modified for catering for the
                                        forecast detail type dimensional aggregation
  1.4   3/07/2007  Kris Lee             ADD: dcs_order_fact_aggregation() - fundraising Sales Order
  1.5   27/07/2007 Kris Lee             ADD: csl_process_purch_order()
                                             csl_process_sales_order()
                                             csl_process_dlvry()
                                             created by Irina Saveluc on 05/2007
  1.6   30/08/2007 Kris Lee             Snackfood BR type forecast aggregate casting period - 2
                                        ADD: snack_br_fcst_fact_aggregation()
                                             get_mars_period()
                                        MOD: forecast_fact_aggregation()
                                               - Different logic for MOE 0009 BR type
                                               - Add moe_code to fcst_fact table
                                               - Add moe_code condition to all cursors, delete and insert statements
                                             dmd_plng_fcst_fact_aggregation
                                               - Add moe_code field to demand_plng_fcst_fact table
                                               - Add moe_code condition to all cursors, delete and insert statements
  1.7   31/10/2007 Steve Gregan         MOD: Changed the sales order aggregation table SAP_SAL_ORD_ISC to a grouping
                                             by BELNR and GENSEQ to prevent duplicate ORDER_FACT row exception when
                                             multiple order line schedule rows found. The scheduled quantity (WMENG)
                                             is summed and the max scheduled date is used.
  1.8   11/03/2008 Steve Gregan         MOD: Changed the delivery aggregation to separate select and insert
                                             new procedure delivery_fact_aggregation_v2 added
  1.9   12/03/2008 Jonathan Girling     MOD: Changed the purchase order aggregation to separate select and insert
                                             new procedure purch_order_fact_agg_v2 added
  1.10  12/03/2008 Steve Gregan         MOD: Changed the order aggregation to separate select and insert
                                             new procedure order_fact_aggregation_v2 added
  1.11  28/03/2008 Steve Gregan         MOD: Changed the purchase order aggregation to recode the select statement
                                             new procedure purch_order_fact_agg_v3 added
  1.12  15/04/2008 Kris Lee             MOD: Changed the NZ demand_plng_division_code logic
                                              for order_fact, purch_order_fact and dlvry_fact
  1.13  02/06/2008 Paul Berude          MOD: Removed snack_br_fcst_fact_aggregation procedure as AUS Snack now want to
                                             handle the BR forecast the same as other business units.
  1.14  28/07/2008 Jonathan Girling     MOD: Updated the tables dlvry_fact, order_fact and purch_order_fact to point to
                                             the renamed dlvry_fact_old, order_fact_old and purch_order_fact_old tables
                                             as part of the Venus upgrade
  1.15  24/09/2008 Jonathan Girling     MOD: Commented out the following aggregations, since they will not be required
                                             with the new dw_scheduled_aggregation:
                                              - purch_order_fact_agg_v3
                                              - order_fact_aggregation_v2
                                              - delivery_fact_aggregation_v2
  1.16  08/10/2008 Trevor Keon          MOD: Fixed bug which allowed nulls to be entered for matl_zrep_code in DCS
  1.17  23/11/2009 Steve Gregan         MOD: Removed all references to the old fact tables

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     BOOLEAN  Whether to convert aggregation date  true
                       to the date and time at the company.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_scheduled_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN DATE,
  i_get_company_time IN BOOLEAN DEFAULT FALSE);

/*******************************************************************************
  NAME:      forecast_fact_aggregation
  PURPOSE:   This function aggregates the fcst_fact table based on the following
             forecast tables:
             - fcst_hdr
             - fcst_dtl

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this function.
  1.1   27/01/2005 Paul Berude          Included consolidated currency columns.
  1.2   28/06/2007 Kris Lee             Modify for Snackfood rollout - fcst_dtl now to fcst_dtl_type_code level
                                        Replace mapping ods.fcst_dtl.matl_code to ods.fcst_dtl.matl_zrep_code
                                        Add matl_tdu_code, fcst_dtl_type_code dimensionalised xxx_qty and xxx_value fields
                                        Sum up the ods.fcst_dtl.fcst_value to current level
                                        Sum up the ods.fcst_dtl.fcst_qty to current level
                                        Assign qty and value to dimensionalised xxx_qty and xxx_value fields based on fcst_dtl_type_code
                                        (Don't aggregate to fcst_dtl_type_code level for report performance issue)
  1.3   30/08/2007 Kris Lee             Modify for Snackfood BR forecast aggregate [casting period - 2]
                                        Add moe_code to fcst_fact table becasue sales_org_code, distbn_chnl_code and division_code
                                        is not a unique group eg sales area [147/99/51] can belong to MOE 0009, 0021, 0196
                                        Without providing the moe_code, deletion will delete wrong rows which belong to other moe_code
                                        Add moe_code condition to all cursors, delete and insert statements
  1.4   4/12/2007  Kris Lee             Fix Snackfood BR Type forecast to reload and delete from fcst_yyyypp = casting_period - 2
  1.5   2/06/2008  Paul Berude          MOD: Removed snack_br_fcst_fact_aggregation procedure as AUS Snack now want to
                                             handle the BR forecast the same as other business units.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION forecast_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      dmd_plng_fcst_fact_aggregation
  PURPOSE:   This function aggregates the demand_plng_fcst_fact table based on
             the following forecast tables:
             - fcst_hdr
             - fcst_dtl

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   02/05/2006 Raja Vaidyanathan    Created this function.
  1.1   28/06/2007 Kris Lee             Modify for Snackfood rollout - fcst_dtl now down to fcst_dtl_type_code level
                                        Replace mapping ods.fcst_dtl.matl_code to ods.fcst_dtl.matl_zrep_code
                                        Add matl_tdu_code, fcst_dtl_type_code dimensionalised xxx_qty and xxx_value fields
                                        Sum up the ods.fcst_dtl.fcst_value to current level
                                        Sum up the ods.fcst_dtl.fcst_qty to current level
                                        Assign qty and value to dimensionalised xxx_qty and xxx_value fields based on fcst_dtl_type_code
                                        (Don't aggregate to fcst_dtl_type_code level for report performance issue)
  1.1   30/08/2007 Kris Lee             Add moe_code to fcst_fact table
                                        Add moe_code condition to all cursors, delete and insert statements

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION dmd_plng_fcst_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      dcs_order_fact_aggregation
  PURPOSE:   This function aggregates the dsc_sales_order_fact table based on the following
             fundraising sales order table:
             - ods.dcs_sales_order

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2/07/2007  Kris Lee             Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20070701
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION dcs_order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN dcs_sales_order.load_date%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      fcst_region_fact_aggregation
  PURPOSE:   This function aggregates the Snackfood BR Type forecast to the
             fcst_local_region_fact table on the following conditions:
               Forecast modified on aggregation date and
                 MOE = 0009, forecast type = BR  and min casting period <= current period -2
              or
                First day of a new mars period (based on current date), which triggers the
                MOE = 0009 and BR type to be reloaded.

             Source tables:
             - fcst_fact
             - fcst_local_region_pct

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   06/12/2007 Kris Lee             Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     DATE     Aggregation Date                     20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION fcst_region_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      get_mars_period
  PURPOSE:   This Function get the MARS_PERIOD by the given date and the offset number
             of days in MARS_PERIOD format.
             NOTE: Pass in negative offset days for prior PERIOD from given date
             positive offset days for future PERIOD from given date.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/08/2007 Kris Lee             Created this function

  PARAMETERS:
  Pos  Type   Format   Description                              Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     DATE     Date based on                            20061231
  2    IN     NUMBER   offset number of days on the date given  28
  3    IN     NUMBER   Log Level                                1

  RETURN VALUE: NUMBER IN yyyypp FORMAT
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION get_mars_period (
  i_date        IN DATE,
  i_offset_days IN NUMBER,
  i_log_level   IN ods.log.log_level%TYPE
 ) RETURN NUMBER;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the log table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/06/2004 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Job Type                             Aggregation
  2    IN     VARCHAR2 Data Type                            Generic
  3    IN     VARCHAR2 Sort Field                           Aggregation Date
  4    IN     NUMBER   Log Level                            1
  5    IN     VARCHAR2 Log Text                             Starting Aggregations

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE);

END scheduled_aggregation;

/


CREATE OR REPLACE PACKAGE BODY           "SCHEDULED_AGGREGATION" IS

  pc_fcst_dtl_typ_dfn_adj        CONSTANT VARCHAR2(1) := '0';
  pc_fcst_dtl_typ_base           CONSTANT VARCHAR2(1) := '1';
  pc_fcst_dtl_typ_aggr_mkt_act   CONSTANT VARCHAR2(1) := '2';
  pc_fcst_dtl_typ_lock           CONSTANT VARCHAR2(1) := '3';
  pc_fcst_dtl_typ_rcncl          CONSTANT VARCHAR2(1) := '4';
  pc_fcst_dtl_typ_auto_adj       CONSTANT VARCHAR2(1) := '5';
  pc_fcst_dtl_typ_override       CONSTANT VARCHAR2(1) := '6';
  pc_fcst_dtl_typ_mkt_act        CONSTANT VARCHAR2(1) := '7';
  pc_fcst_dtl_typ_data_driven    CONSTANT VARCHAR2(1) := '8';
  pc_fcst_dtl_typ_tgt_imapct     CONSTANT VARCHAR2(1) := '9';

PROCEDURE reload_fcst_region_fact (
  i_company_code     IN company.company_code%TYPE,
  i_moe_code         IN fcst_fact.moe_code%TYPE,
  i_reload_yyyypp    IN mars_date_dim.mars_period%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  );

PROCEDURE run_scheduled_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN DATE,
  i_get_company_time IN BOOLEAN DEFAULT FALSE) IS

  -- VARIABLE DECLARATIONS
  v_processing_msg   constants.message_string;
  v_company_code     company.company_code%TYPE;
  v_aggregation_date DATE;
  v_log_level        ods.log.log_level%TYPE;
  v_status           NUMBER;
  v_db_name          VARCHAR2(256) := NULL;

  var_process_date varchar2(8);
  var_process_code varchar2(32);

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether the inputted company code exists in the company table.
  CURSOR csr_company_code IS
    SELECT
      company_code,
      company_timezone_code
    FROM
      company A
    WHERE
      company_code = v_company_code;
  rv_company_code csr_company_code%ROWTYPE;

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

  -- Start scheduled aggregation.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Aggregations - Start');

  -- Check the inputted company code.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Checking that the inputted parameter Company' ||
    ' Code [' || i_company_code || '] is correct.');
  BEGIN
    IF i_company_code IS NULL THEN
      RAISE e_processing_error;

    ELSE
      v_company_code := TRIM(i_company_code);

      -- Fetch the record from the csr_company_code cursor.
      OPEN csr_company_code;
      FETCH csr_company_code INTO rv_company_code;

      IF csr_company_code%NOTFOUND THEN
        CLOSE csr_company_code;
        RAISE e_processing_error;
      END IF;

      CLOSE csr_company_code;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      v_processing_msg := 'The inputted parameter Company Code [' || i_company_code || '] failed validation.';
      RAISE e_processing_error;
  END;

  -- Convert the inputted aggregation date to standard date format.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Converting the inputted Aggregation' ||
    ' Date [' || TO_CHAR(i_aggregation_date) || '] to standard date format.');
  BEGIN
    IF i_aggregation_date IS NULL THEN
      RAISE e_processing_error;

    ELSE

      IF (i_get_company_time) THEN

        v_aggregation_date := utils.tz_conv_date_time(i_aggregation_date,
                                                      ods_constants.db_timezone,
                                                      rv_company_code.company_timezone_code);
      ELSE
        v_aggregation_date := i_aggregation_date;
      END IF;

      v_aggregation_date := TO_DATE(TO_CHAR(v_aggregation_date, 'YYYYMMDD'), 'YYYYMMDD');
    END IF;

    write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Will be aggregating for date: ' || v_aggregation_date || '.');

  EXCEPTION
    WHEN OTHERS THEN
      v_processing_msg := 'Unable to convert the inputted Aggregation Date [' || TO_CHAR(i_aggregation_date, 'YYYYMMDD') || '] from string to date format.';
      RAISE e_processing_error;
  END;

  -- Calling the forecast_fact_aggregation function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the forecast_fact_aggregation function.');
  v_status := forecast_fact_aggregation(v_company_code,
                                        v_aggregation_date,
                                        v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the forecast_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- Calling the dmd_plng_fcst_fact_aggregation function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the dmd_plng_fcst_fact_aggregation function.');
  v_status := dmd_plng_fcst_fact_aggregation(v_company_code,
                                             v_aggregation_date,
                                             v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the dmd_plng_fcst_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- Calling the dcs_order_fact_aggregation function. (Fundraising Sales Order)
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the dcs_order_fact_aggregation function.');
  v_status := dcs_order_fact_aggregation(v_company_code,
                                         v_aggregation_date,
                                         v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the dcs_order_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- Calling the fcst_region_fact_aggregation function
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the fcst_region_fact_aggregation function.');
  v_status := fcst_region_fact_aggregation(v_company_code,
                                           v_aggregation_date,
                                           v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the fcst_region_fact_aggregation.';
    RAISE e_processing_error;
  END IF;

  -- End scheduled aggregation processing.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Aggregations - End');


  -- Stream trace
  var_process_date := to_char(v_aggregation_date,'yyyymmdd');
  var_process_code := 'OLD_SCHEDULED_AGGREGATION_'||i_company_code;

  lics_processing.set_trace(var_process_code, var_process_date);



EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || v_processing_msg);

    utils.send_email_to_group(ods_constants.job_type_sched_aggregation,
                              'MFANZ CDW Scheduled Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

    utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                            'Fatal Error occurred during Scheduled Aggregation.',
                            ods_constants.job_type_sched_aggregation,
                            i_company_code);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    utils.send_email_to_group(ods_constants.job_type_sched_aggregation,
                              'MFANZ CDW Scheduled Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_AGGREGATION.RUN_SCHEDULED_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

    utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                            'Fatal Error occurred during Scheduled Aggregation.',
                            ods_constants.job_type_sched_aggregation,
                            i_company_code);

END run_scheduled_aggregation;


FUNCTION forecast_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_fcst_type_code             fcst_hdr.fcst_type_code%TYPE;
  v_sales_org_code             fcst_hdr.sales_org_code%TYPE;
  v_distbn_chnl_code           fcst_hdr.distbn_chnl_code%TYPE;
  v_division_code              fcst_hdr.division_code%TYPE;
  v_moe_code                   fcst_hdr.moe_code%TYPE;
  v_adjust_min_casting_yyyypp  NUMBER(6);
  v_adjust_min_casting_yyyyppw NUMBER(7);

  -- CURSOR DECLARATIONS
  -- Check whether any forecasts are to be aggregated.
  CURSOR csr_forecast IS
    SELECT DISTINCT
      fcst_type_code,
      sales_org_code,
      distbn_chnl_code,
      division_code,
      moe_code
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid;
    rv_forecast csr_forecast%ROWTYPE;

  -- Select the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_min_casting_period IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_period csr_min_casting_period%ROWTYPE;

  -- Select all casting periods starting at the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_casting_period IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      (casting_year || LPAD(casting_period,2,0)) AS casting_yyyypp
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) >= v_adjust_min_casting_yyyypp
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period) ASC;
    rv_casting_period csr_casting_period%ROWTYPE;

  -- Select the minimum casting week for a forecast that is to be aggregated (used for forecast type FCST).
  CURSOR csr_min_casting_week IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0) || casting_week) AS min_casting_yyyyppw,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_week csr_min_casting_week%ROWTYPE;

  -- Select all casting weeks starting at the minimum casting week for a weekly forecast that is to be aggregated.
  CURSOR csr_casting_week IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      casting_week AS casting_w,
      (casting_year || LPAD(casting_period,2,0) || casting_week) AS casting_yyyyppw
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND moe_code = v_moe_code
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) || casting_week >= v_adjust_min_casting_yyyyppw
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period || casting_week) ASC;
  rv_casting_week csr_casting_week%ROWTYPE;

BEGIN

  -- Starting fcst_fact aggregation.
  write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 1, 'Starting FCST_FACT aggregation.');

  -- Loop through all records in the cursor.
  write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 2, 'Check whether any forecasts are' ||
    ' to be aggregated.');

  FOR rv_forecast IN csr_forecast LOOP

    -- Handling the following unique forecast type.
    write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Handling - Forecast Type/MOE/Sales Org/Distribute Channel/Division [' ||
      rv_forecast.fcst_type_code || '/' || rv_forecast.moe_code || '/' || rv_forecast.sales_org_code ||
       '/' || rv_forecast.distbn_chnl_code || '/' || rv_forecast.division_code || '].');

    -- Now pass cursor results into variables.
    v_fcst_type_code :=  rv_forecast.fcst_type_code;
    v_sales_org_code := rv_forecast.sales_org_code;
    v_distbn_chnl_code := rv_forecast.distbn_chnl_code;
    v_division_code := rv_forecast.division_code;
    v_moe_code := rv_forecast.moe_code;

  /* -----------------------------------------------------------------------------------
    Check to see if the forecast type is weekly i.e. FCST. If it is then process
    weekly forecast, if not then bypass this section as the forecast is a period forecast.
  -------------------------------------------------------------------------------------*/

  IF v_fcst_type_code = ods_constants.fcst_type_fcst_weekly THEN

      -- Fetch only the first record from the csr_min_casting_week cursor.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_week cursor.');

      OPEN csr_min_casting_week;
      FETCH csr_min_casting_week INTO rv_min_casting_week;
      CLOSE csr_min_casting_week;

      -- Fetched the minimum casting_yyyyppw for the forecast being aggregated.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'The forecast being aggregated' ||
        ' has the Minimum Casting week of [' || rv_min_casting_week.min_casting_yyyyppw || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_week.current_fcst_flag || '].');

      -- Update the min_casting_yyyyppw variable based on the status of the current_fcst_flag.
      IF rv_min_casting_week.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        /*
        The current_fcst_flag = 'D' (Deleted) therefore set min_casting_yyyyppw to that of the prior
        forecast before the forecast which is to be deleted.
        */
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Updating the min_casting_yyyyppw' ||
          ' as the current_fcst_flag = ''D'' (Deleted).');

        SELECT MAX(casting_year || LPAD(casting_period,2,0) || casting_week) INTO v_adjust_min_casting_yyyyppw
        FROM fcst_hdr
        WHERE (casting_year || LPAD(casting_period,2,0) || casting_week) < rv_min_casting_week.min_casting_yyyyppw
          AND company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND moe_code = v_moe_code
          AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
          AND valdtn_status = ods_constants.valdtn_valid;

        -- If no prior forecast exists then set v_adjust_min_casting_yyyyppw to zero.
        IF v_adjust_min_casting_yyyyppw IS NULL THEN
          v_adjust_min_casting_yyyyppw := 0;
        END IF;

      ELSE
        -- Else the current_fcst_flag = 'Y', therefore use min_casting_yyyyppw.
        v_adjust_min_casting_yyyyppw := rv_min_casting_week.min_casting_yyyyppw;

      END IF;

      /*
      Loop through and aggregate forecast for all casting weeks starting with the minimum
      changed casting week through to the maximum casting week for the forecast.
      */
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
        ' starting with the minimum casting week through to the maximum casting week.');

      FOR rv_casting_week IN csr_casting_week LOOP
        -- Create a savepoint.
        SAVEPOINT forecast_fact_savepoint;

        -- Delete forecasts from the fcst_fact table that are to be rebuilt.
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Deleting from FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');
        DELETE FROM fcst_fact
        WHERE company_code = i_company_code
        AND fcst_type_code = v_fcst_type_code
        AND sales_org_code = v_sales_org_code
        AND distbn_chnl_code = v_distbn_chnl_code
        AND ((division_code = v_division_code) OR
             (division_code IS NULL AND v_division_code IS NULL))
        AND (moe_code = v_moe_code OR moe_code IS NULL)
        AND fcst_yyyyppw > rv_casting_week.casting_yyyyppw;

        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Delete Count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Insert the forecast into the fcst_fact table.
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Inserting into FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');

        INSERT INTO fcst_fact
          (
          company_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          moe_code,
          fcst_type_code,
          fcst_yyyypp,
          fcst_yyyyppw,
          demand_plng_grp_code,
          cntry_code,
          region_code,
          multi_mkt_acct_code,
          banner_code,
          cust_buying_grp_code,
          acct_assgnmnt_grp_code,
          pos_format_grpg_code,
          distbn_route_code,
          cust_code,
          matl_zrep_code,
          matl_tdu_code,
          currcy_code,
          fcst_value,
          fcst_value_aud,
          fcst_value_usd,
          fcst_value_eur,
          fcst_qty,
          fcst_qty_gross_tonnes,
          fcst_qty_net_tonnes,
          base_value,
          base_qty,
          aggreg_mkt_actvty_value,
          aggreg_mkt_actvty_qty,
          lock_value,
          lock_qty,
          rcncl_value,
          rcncl_qty,
          auto_adjmt_value,
          auto_adjmt_qty,
          override_value,
          override_qty,
          mkt_actvty_value,
          mkt_actvty_qty,
          data_driven_event_value,
          data_driven_event_qty,
          tgt_impact_value,
          tgt_impact_qty,
          dfn_adjmt_value,
          dfn_adjmt_qty
          )
          SELECT
            t1.company_code,
            t1.sales_org_code,
            t1.distbn_chnl_code,
            t1.division_code,
            t1.moe_code,
            t1.fcst_type_code,
            t1.fcst_yyyypp,
            t1.fcst_yyyyppw,
            t1.demand_plng_grp_code,
            t1.cntry_code,
            t1.region_code,
            t1.multi_mkt_acct_code,
            t1.banner_code,
            t1.cust_buying_grp_code,
            t1.acct_assgnmnt_grp_code,
            t1.pos_format_grpg_code,
            t1.distbn_route_code,
            t1.cust_code,
            t1.matl_zrep_code,
            t1.matl_tdu_code,
            t1.currcy_code,
            t1.fcst_value,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
            t1.fcst_qty,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
            base_value,
            base_qty,
            aggreg_mkt_actvty_value,
            aggreg_mkt_actvty_qty,
            lock_value,
            lock_qty,
            rcncl_value,
            rcncl_qty,
            auto_adjmt_value,
            auto_adjmt_qty,
            override_value,
            override_qty,
            mkt_actvty_value,
            mkt_actvty_qty,
            data_driven_event_value,
            data_driven_event_qty,
            tgt_impact_value,
            tgt_impact_qty,
            dfn_adjmt_value,
            dfn_adjmt_qty
          FROM  -- Sum up to material level before calling the functions to convert currency and tonnes for performance
            (SELECT /*+ INDEX(B FCST_DTL_PK) */
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week) AS fcst_yyyyppw,
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
               LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
               b.currcy_code,
               SUM(b.fcst_value) as fcst_value,
               SUM(b.fcst_qty) AS fcst_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
             FROM
               fcst_hdr a,
               fcst_dtl b
             WHERE
               a.fcst_hdr_code = b.fcst_hdr_code
               AND (a.casting_year = rv_casting_week.casting_yyyy AND
                    a.casting_period = rv_casting_week.casting_pp AND
                    a.casting_week = rv_casting_week.casting_w)
               AND a.company_code = i_company_code
               AND a.fcst_type_code = v_fcst_type_code
               AND a.sales_org_code = v_sales_org_code
               AND a.distbn_chnl_code = v_distbn_chnl_code
               AND ((a.division_code = v_division_code) OR
                    (a.division_code IS NULL AND v_division_code IS NULL))
               AND a.moe_code = v_moe_code
               AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
               AND a.valdtn_status = ods_constants.valdtn_valid
             GROUP BY
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               (b.fcst_year || LPAD(b.fcst_period,2,0)),
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week),
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               b.matl_zrep_code,
               b.matl_tdu_code,
               b.currcy_code ) t1,
            company t2,
            sap_mat_hdr t3
         WHERE t1.company_code = t2.company_code
         AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Insert Count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Commit.
        COMMIT;

      END LOOP;

  ELSE --Do fact entry for forecast types other than the weekly FCST type.

      -- Fetch only the first record from the csr_min_casting_period cursor.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_period cursor.');

      OPEN csr_min_casting_period;
      FETCH csr_min_casting_period INTO rv_min_casting_period;
      CLOSE csr_min_casting_period;

      -- Fetched the minimum casting_yyyypp for the forecast being aggregated.
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'The forecast being handled' ||
        ' has the Minimum Casting Period of [' || rv_min_casting_period.min_casting_yyyypp || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_period.current_fcst_flag || '].');

      -- Update the min_casting_yyyypp variable based on the status of the current_fcst_flag.
      IF rv_min_casting_period.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        /*
        The current_fcst_flag = 'D' (Deleted) therefore set min_casting_yyyypp to that of the prior
        forecast before the forecast which is to be deleted.
        */
        write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Updating the min_casting_yyyypp' ||
          ' as the current_fcst_flag = ''D'' (Deleted).');

        SELECT MAX(casting_year || LPAD(casting_period,2,0)) INTO v_adjust_min_casting_yyyypp
        FROM fcst_hdr
        WHERE (casting_year || LPAD(casting_period,2,0)) < rv_min_casting_period.min_casting_yyyypp
          AND company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND moe_code = v_moe_code
          AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
          AND valdtn_status = ods_constants.valdtn_valid;

        -- If no prior forecast exists then set v_adjust_min_casting_yyyypp to zero.
        IF v_adjust_min_casting_yyyypp IS NULL THEN
          v_adjust_min_casting_yyyypp := 0;
        END IF;

      ELSE
        -- Else the current_fcst_flag = 'Y', therefore use min_casting_yyyypp.
        v_adjust_min_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;

      END IF;

      /*
      Loop through and aggregate forecast for all casting periods starting with the minimum
      changed casting period through to the maximum casting period for the forecast.
      */
      write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
        ' starting with the minimum casting period through to the maximum casting period.');

      FOR rv_casting_period IN csr_casting_period LOOP

        -- Create a savepoint.
        SAVEPOINT forecast_fact_savepoint;

           -- Delete forecasts from the fcst_fact table that are to be rebuilt.
           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Deleting from FCST_FACT where fcst_yyyypp > [' ||
             rv_casting_period.casting_yyyypp || '].');

           DELETE FROM fcst_fact
           WHERE company_code = i_company_code
           AND fcst_type_code = v_fcst_type_code
           AND sales_org_code = v_sales_org_code
           AND distbn_chnl_code = v_distbn_chnl_code
           AND ((division_code = v_division_code) OR
                (division_code IS NULL AND v_division_code IS NULL))
           AND (moe_code = v_moe_code OR moe_code IS NULL)
           AND fcst_yyyypp > rv_casting_period.casting_yyyypp;

           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Delete count : ' || TO_CHAR(SQL%ROWCOUNT) );

           -- Insert the forecast into the fcst_fact table.
           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Inserting into FCST_FACT where ' ||
             ' Casting Period = [' || rv_casting_period.casting_yyyypp || '] and fcst_yyyypp > [' || rv_casting_period.casting_yyyypp || ']' );

           INSERT INTO fcst_fact
             (
              company_code,
              sales_org_code,
              distbn_chnl_code,
              division_code,
              moe_code,
              fcst_type_code,
              fcst_yyyypp,
              fcst_yyyyppw,
              demand_plng_grp_code,
              cntry_code,
              region_code,
              multi_mkt_acct_code,
              banner_code,
              cust_buying_grp_code,
              acct_assgnmnt_grp_code,
              pos_format_grpg_code,
              distbn_route_code,
              cust_code,
              matl_zrep_code,
              matl_tdu_code,
              currcy_code,
              fcst_value,
              fcst_value_aud,
              fcst_value_usd,
              fcst_value_eur,
              fcst_qty,
              fcst_qty_gross_tonnes,
              fcst_qty_net_tonnes,
              base_value,
              base_qty,
              aggreg_mkt_actvty_value,
              aggreg_mkt_actvty_qty,
              lock_value,
              lock_qty,
              rcncl_value,
              rcncl_qty,
              auto_adjmt_value,
              auto_adjmt_qty,
              override_value,
              override_qty,
              mkt_actvty_value,
              mkt_actvty_qty,
              data_driven_event_value,
              data_driven_event_qty,
              tgt_impact_value,
              tgt_impact_qty,
              dfn_adjmt_value,
              dfn_adjmt_qty
             )
             SELECT
               t1.company_code,
               t1.sales_org_code,
               t1.distbn_chnl_code,
               t1.division_code,
               t1.moe_code,
               t1.fcst_type_code,
               t1.fcst_yyyypp,
               t1.fcst_yyyyppw,
               t1.demand_plng_grp_code,
               t1.cntry_code,
               t1.region_code,
               t1.multi_mkt_acct_code,
               t1.banner_code,
               t1.cust_buying_grp_code,
               t1.acct_assgnmnt_grp_code,
               t1.pos_format_grpg_code,
               t1.distbn_route_code,
               t1.cust_code,
               t1.matl_zrep_code,
               t1.matl_tdu_code,
               t1.currcy_code,
               t1.fcst_value,
               ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
               ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
               ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
               t1.fcst_qty,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
               base_value,
               base_qty,
               aggreg_mkt_actvty_value,
               aggreg_mkt_actvty_qty,
               lock_value,
               lock_qty,
               rcncl_value,
               rcncl_qty,
               auto_adjmt_value,
               auto_adjmt_qty,
               override_value,
               override_qty,
               mkt_actvty_value,
               mkt_actvty_qty,
               data_driven_event_value,
               data_driven_event_qty,
               tgt_impact_value,
               tgt_impact_qty,
               dfn_adjmt_value,
               dfn_adjmt_qty
             FROM
               (SELECT /*+ INDEX(B FCST_DTL_PK) */
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
                  NULL AS fcst_yyyyppw,
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
                  LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
                  b.currcy_code,
                  SUM(b.fcst_value) as fcst_value,
                  SUM(b.fcst_qty) AS fcst_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
                FROM
                  fcst_hdr a,
                  fcst_dtl b
                WHERE
                  a.fcst_hdr_code = b.fcst_hdr_code
                  AND (a.casting_year = rv_casting_period.casting_yyyy AND
                       a.casting_period = rv_casting_period.casting_pp )
                  AND a.company_code = i_company_code
                  AND a.fcst_type_code = v_fcst_type_code
                  AND a.sales_org_code = v_sales_org_code
                  AND a.distbn_chnl_code = v_distbn_chnl_code
                  AND ((a.division_code = v_division_code) OR
                       (a.division_code IS NULL AND v_division_code IS NULL))
                  AND a.moe_code = v_moe_code
                  AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
                  AND a.valdtn_status = ods_constants.valdtn_valid
                  AND (b.fcst_year || LPAD(b.fcst_period,2,0)) > rv_casting_period.casting_yyyypp
                GROUP BY
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)),
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  b.matl_zrep_code,
                  b.matl_tdu_code,
                  b.currcy_code ) t1,
               company t2,
               sap_mat_hdr t3
            WHERE t1.company_code = t2.company_code
            AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

           write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 4, 'Insert count : ' || TO_CHAR(SQL%ROWCOUNT) );

        -- Commit.
        COMMIT;

      END LOOP;

  END IF;

  END LOOP;

  -- Completed fcst_fact aggregation.
  write_log(ods_constants.data_type_forecast, 'N/A', i_log_level + 1, 'Completed FCST_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO forecast_fact_savepoint;
    write_log(ods_constants.data_type_forecast,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.FORECAST_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END forecast_fact_aggregation;

FUNCTION dmd_plng_fcst_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_fcst_type_code fcst_hdr.fcst_type_code%TYPE;
  v_sales_org_code fcst_hdr.sales_org_code%TYPE;
  v_distbn_chnl_code fcst_hdr.distbn_chnl_code%TYPE;
  v_division_code fcst_hdr.division_code%TYPE;
  v_no_insert_flag BOOLEAN := FALSE;
  v_min_casting_yyyyppw VARCHAR2(7);
  v_min_casting_yyyypp VARCHAR2(6);
  v_moe_code fcst_hdr.moe_code%TYPE;

  -- CURSOR DECLARATIONS
  -- Check whether any forecasts are to be aggregated.
  CURSOR csr_forecast IS
    SELECT DISTINCT
      fcst_type_code,
      sales_org_code,
      distbn_chnl_code,
      division_code,
      moe_code
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid;
    rv_forecast csr_forecast%ROWTYPE;

  -- Select the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_min_casting_period IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_period csr_min_casting_period%ROWTYPE;

  -- Select all casting periods starting at the minimum casting period for a forecast that is to be aggregated.
  CURSOR csr_casting_period IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      (casting_year || LPAD(casting_period,2,0)) AS casting_yyyypp
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) >= v_min_casting_yyyypp
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period) ASC;  -- KL (fix bug) convert to number otherwise the order is not as expected
    rv_casting_period csr_casting_period%ROWTYPE;

  -- Select the minimum casting week for a forecast that is to be aggregated (used for forecast type FCST).
  CURSOR csr_min_casting_week IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0) || casting_week) AS min_casting_yyyyppw,
      current_fcst_flag
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY current_fcst_flag
    ORDER BY current_fcst_flag DESC;
    rv_min_casting_week csr_min_casting_week%ROWTYPE;

  -- Select all casting weeks starting at the minimum casting week for a weekly forecast that is to be aggregated.
  CURSOR csr_casting_week IS
    SELECT
      casting_year AS casting_yyyy,
      casting_period AS casting_pp,
      casting_week AS casting_w,
      (casting_year || LPAD(casting_period,2,0) || casting_week) AS casting_yyyyppw
    FROM fcst_hdr
    WHERE company_code = i_company_code
      AND moe_code = v_moe_code
      AND fcst_type_code = v_fcst_type_code
      AND sales_org_code = v_sales_org_code
      AND distbn_chnl_code = v_distbn_chnl_code
      AND ((division_code = v_division_code) OR
           (division_code IS NULL AND v_division_code IS NULL))
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND casting_year || LPAD(casting_period,2,0) || casting_week >= v_min_casting_yyyyppw
      AND valdtn_status = ods_constants.valdtn_valid
    ORDER BY TO_NUMBER(casting_year || casting_period || casting_week) ASC;  -- KL (fix bug) convert to number otherwise the order is not as expected
  rv_casting_week csr_casting_week%ROWTYPE;

BEGIN

  -- Starting dmd_plng_fcst_fact aggregation.
  write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 1, 'Starting DMD_PLNG_FCST_FACT aggregation.');

  -- Loop through all records in the cursor.
  write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 2, 'Check whether any forecasts are' ||
    ' to be aggregated.');

  FOR rv_forecast IN csr_forecast LOOP

    -- The following forecast requires aggregation.
    write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Aggregating: Forecast Type/MOE/Sales Org/Distribute Channel/Division [' ||
      rv_forecast.fcst_type_code || '/' || rv_forecast.moe_code || '/' || rv_forecast.sales_org_code ||
       '/' || rv_forecast.distbn_chnl_code || '/' || rv_forecast.division_code || '].');

    -- Now pass cursor results into variables.
    v_fcst_type_code :=  rv_forecast.fcst_type_code;
    v_sales_org_code := rv_forecast.sales_org_code;
    v_distbn_chnl_code := rv_forecast.distbn_chnl_code;
    v_division_code := rv_forecast.division_code;
    v_moe_code := rv_forecast.moe_code;

  /* -----------------------------------------------------------------------------------
    Check to see if the forecast type is weekly i.e. FCST. If it is then process
    weekly forecast, if not then bypass this section as the forecast is a period forecast.
  -------------------------------------------------------------------------------------*/

  IF v_fcst_type_code = ods_constants.fcst_type_fcst_weekly THEN

      -- Fetch only the first record from the csr_min_casting_week cursor.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_week cursor.');

      OPEN csr_min_casting_week;
      FETCH csr_min_casting_week INTO rv_min_casting_week;
      CLOSE csr_min_casting_week;

      -- Fetched the minimum casting_yyyyppw for the forecast being aggregated.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'The forecast being aggregated' ||
        ' has the Minimum Casting week of [' || rv_min_casting_week.min_casting_yyyyppw || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_week.current_fcst_flag || '].');

      -- Check the status of the current_fcst_flag.
      IF rv_min_casting_week.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        -- If current_fcst_flag = 'D' (deleted) then delete the data from DEMAND_PLNG_FCST_FACT table for that
        -- casting week as it is no longer needed and no insert will be done into DEMAND_PLNG_FCST_FACT table.
        -- if the status is D.
        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT ' ||
          ' as the current_fcst_flag = ''D'' (Deleted) for Casting Week ' || rv_min_casting_week.min_casting_yyyyppw || ' .');

        DELETE FROM demand_plng_fcst_fact
        WHERE company_code = i_company_code
        AND fcst_type_code = v_fcst_type_code
        AND sales_org_code = v_sales_org_code
        AND distbn_chnl_code = v_distbn_chnl_code
        AND ((division_code = v_division_code) OR
             (division_code IS NULL AND v_division_code IS NULL))
        AND (moe_code = v_moe_code OR moe_code IS NULL)
        AND casting_yyyyppw = rv_min_casting_week.min_casting_yyyyppw;

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- The current_fcst_flag = 'D', therefore no insert is required.
        v_no_insert_flag      := TRUE;
        v_min_casting_yyyyppw := NULL;

        -- Commit.
        COMMIT;

      ELSE -- Status of minimum casting week forecast is not 'D'.

        -- The current_fcst_flag = 'Y', therefore use min_casting_yyyyppw.
        v_no_insert_flag       := FALSE;
        v_min_casting_yyyyppw  := rv_min_casting_week.min_casting_yyyyppw;

      END IF;

      /*
       Loop through and aggregate forecast for all casting weeks starting with the minimum changed casting
       week through to the maximum casting week for the forecast.
       Do this only if the minimum casting week selected above is not DELETED.
      */

      -- If the status of minimum forecast week is not 'D', then open the cursor and process.
      IF v_no_insert_flag = FALSE  THEN

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
          ' starting with the minimum casting week through to the maximum casting week.');

        FOR rv_casting_week IN csr_casting_week LOOP
          -- Create a savepoint.
          SAVEPOINT dmd_plng_fcst_fact_savepoint;

          -- Delete forecasts from the demand_plng_fcst_fact table that are to be rebuilt.
          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');
          DELETE FROM demand_plng_fcst_fact
          WHERE company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND (moe_code = v_moe_code OR moe_code IS NULL)
          AND casting_yyyyppw = rv_casting_week.casting_yyyyppw;

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Insert the forecast into the demand_plng_fcast_fact table.
        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Inserting into DEMAND_PLNG_FCST_FACT based' ||
          ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');

        INSERT INTO demand_plng_fcst_fact
          (
          company_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          moe_code,
          fcst_type_code,
          casting_yyyypp,
          casting_yyyyppw,
          fcst_yyyypp,
          fcst_yyyyppw,
          demand_plng_grp_code,
          cntry_code,
          region_code,
          multi_mkt_acct_code,
          banner_code,
          cust_buying_grp_code,
          acct_assgnmnt_grp_code,
          pos_format_grpg_code,
          distbn_route_code,
          cust_code,
          matl_zrep_code,
          matl_tdu_code,
          currcy_code,
          fcst_value,
          fcst_value_aud,
          fcst_value_usd,
          fcst_value_eur,
          fcst_qty,
          fcst_qty_gross_tonnes,
          fcst_qty_net_tonnes,
          base_value,
          base_qty,
          aggreg_mkt_actvty_value,
          aggreg_mkt_actvty_qty,
          lock_value,
          lock_qty,
          rcncl_value,
          rcncl_qty,
          auto_adjmt_value,
          auto_adjmt_qty,
          override_value,
          override_qty,
          mkt_actvty_value,
          mkt_actvty_qty,
          data_driven_event_value,
          data_driven_event_qty,
          tgt_impact_value,
          tgt_impact_qty,
          dfn_adjmt_value,
          dfn_adjmt_qty
          )
          SELECT
            t1.company_code,
            t1.sales_org_code,
            t1.distbn_chnl_code,
            t1.division_code,
            t1.moe_code,
            t1.fcst_type_code,
            t1.casting_yyyypp,
            t1.casting_yyyyppw,
            t1.fcst_yyyypp,
            t1.fcst_yyyyppw,
            t1.demand_plng_grp_code,
            t1.cntry_code,
            t1.region_code,
            t1.multi_mkt_acct_code,
            t1.banner_code,
            t1.cust_buying_grp_code,
            t1.acct_assgnmnt_grp_code,
            t1.pos_format_grpg_code,
            t1.distbn_route_code,
            t1.cust_code,
            t1.matl_zrep_code,
            t1.matl_tdu_code,
            t1.currcy_code,
            t1.fcst_value,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
            t1.fcst_qty,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
            base_value,
            base_qty,
            aggreg_mkt_actvty_value,
            aggreg_mkt_actvty_qty,
            lock_value,
            lock_qty,
            rcncl_value,
            rcncl_qty,
            auto_adjmt_value,
            auto_adjmt_qty,
            override_value,
            override_qty,
            mkt_actvty_value,
            mkt_actvty_qty,
            data_driven_event_value,
            data_driven_event_qty,
            tgt_impact_value,
            tgt_impact_qty,
            dfn_adjmt_value,
            dfn_adjmt_qty
          FROM
            (SELECT /*+ INDEX(B FCST_DTL_PK) */
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0) AS casting_yyyypp,
               a.casting_year || LPAD(a.casting_period,2,0) || a.casting_week AS casting_yyyyppw,
               (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week) AS fcst_yyyyppw,
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
               LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
               b.currcy_code,
               SUM(b.fcst_value) as fcst_value,
               SUM(b.fcst_qty) AS fcst_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
             FROM
               fcst_hdr a,
               fcst_dtl b
             WHERE
               a.fcst_hdr_code = b.fcst_hdr_code
               AND (a.casting_year = rv_casting_week.casting_yyyy AND
                    a.casting_period = rv_casting_week.casting_pp AND
                    a.casting_week = rv_casting_week.casting_w)
               AND a.company_code = i_company_code
               AND a.fcst_type_code = v_fcst_type_code
               AND a.sales_org_code = v_sales_org_code
               AND a.distbn_chnl_code = v_distbn_chnl_code
               AND ((a.division_code = v_division_code) OR
                    (a.division_code IS NULL AND v_division_code IS NULL))
               AND moe_code = v_moe_code
               AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
               AND a.valdtn_status = ods_constants.valdtn_valid
             GROUP BY
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0),
               a.casting_year || LPAD(a.casting_period,2,0) || a.casting_week,
               (b.fcst_year || LPAD(b.fcst_period,2,0)),
               (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week),
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               b.matl_zrep_code,
               b.matl_tdu_code,
               b.currcy_code ) t1,
            company t2,
            sap_mat_hdr t3
         WHERE t1.company_code = t2.company_code
         AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Commit.
        COMMIT;

      END LOOP;   -- End of csr_casting_week cursor.
    END IF;       -- End of v_no_insert_flag = FALSE check.

  --  Forecast type is not weekly 'FCST', therefore process period forecast.
  ELSE

      -- Fetch only the first record from the csr_min_casting_period cursor.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Fetching only the first record' ||
        ' from the csr_min_casting_period cursor.');

      OPEN csr_min_casting_period;
      FETCH csr_min_casting_period INTO rv_min_casting_period;
      CLOSE csr_min_casting_period;

      -- Fetched the minimum casting_yyyypp for the forecast being aggregated.
      write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'The forecast being aggregated' ||
        ' has the Minimum Casting Period of [' || rv_min_casting_period.min_casting_yyyypp || ']' ||
        ' and Current Forecast Flag of [' || rv_min_casting_period.current_fcst_flag || '].');

      -- Check the status of the current_fcst flag.
      IF rv_min_casting_period.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

        -- If current_fcst_flag = 'D' (deleted) then delete the data from DEMAND_PLNG_FCST_FACT table for that
        -- casting period as it is no longer needed and no insert will be done into DEMAND_PLNG_FCST_FACT table
        -- if the status is D.
        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT ' ||
          ' as the current_fcst_flag = ''D'' (Deleted) for Casting Period ' || rv_min_casting_period.min_casting_yyyypp || ' .');

        DELETE FROM demand_plng_fcst_fact
        WHERE company_code = i_company_code
        AND fcst_type_code = v_fcst_type_code
        AND sales_org_code = v_sales_org_code
        AND distbn_chnl_code = v_distbn_chnl_code
        AND ((division_code = v_division_code) OR
             (division_code IS NULL AND v_division_code IS NULL))
        AND (moe_code = v_moe_code OR moe_code IS NULL)
        AND casting_yyyypp = rv_min_casting_period.min_casting_yyyypp;

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- The current_fcst_flag = 'D', therefore no insert is required.
        v_no_insert_flag      := TRUE;
        v_min_casting_yyyypp  := NULL;

        -- Commit.
        COMMIT;

      ELSE -- Status of minimum casting period forecast is not 'D'.

        -- The current_fcst_flag = 'Y', therefore use min_casting_yyyypp.
        v_no_insert_flag     := FALSE;
        v_min_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;

      END IF;

      /*
       Loop through and aggregate forecast for all casting periods starting with the minimum changed casting
       period through to the maximum casting period for the forecast.
       Do this only if the minimum casting period selected above is not DELETED.
      */

      -- If the status of minimum forecast period is not 'D' then open the cursor and process.
      IF  v_no_insert_flag = FALSE  THEN

        write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 3, 'Loop through and aggregate forecast' ||
            ' starting with the minimum casting period through to the maximum casting period.');

        FOR rv_casting_period IN csr_casting_period LOOP

          -- Create a savepoint.
          SAVEPOINT dmd_plng_fcst_fact_savepoint;

          -- Delete forecasts from the demand_plng_fcst_fact table that are to be rebuilt.
          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Deleting from DEMAND_PLNG_FCST_FACT based' ||
            ' on Casting Period [' || rv_casting_period.casting_yyyypp || '].');
          DELETE FROM demand_plng_fcst_fact
          WHERE company_code = i_company_code
          AND fcst_type_code = v_fcst_type_code
          AND sales_org_code = v_sales_org_code
          AND distbn_chnl_code = v_distbn_chnl_code
          AND ((division_code = v_division_code) OR
               (division_code IS NULL AND v_division_code IS NULL))
          AND (moe_code = v_moe_code OR moe_code IS NULL)
          AND casting_yyyypp = rv_casting_period.casting_yyyypp;

          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Delete Count: ' || TO_CHAR(SQL%ROWCOUNT));

          -- Insert the forecast into the demand_plng_fcst_fact table.
          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Inserting into DEMAND_PLNG_FCST_FACT based' ||
            ' on Casting Period [' || rv_casting_period.casting_yyyypp || '].');
          INSERT INTO demand_plng_fcst_fact
          (
          company_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          moe_code,
          fcst_type_code,
          casting_yyyypp,
          casting_yyyyppw,
          fcst_yyyypp,
          fcst_yyyyppw,
          demand_plng_grp_code,
          cntry_code,
          region_code,
          multi_mkt_acct_code,
          banner_code,
          cust_buying_grp_code,
          acct_assgnmnt_grp_code,
          pos_format_grpg_code,
          distbn_route_code,
          cust_code,
          matl_zrep_code,
          matl_tdu_code,
          currcy_code,
          fcst_value,
          fcst_value_aud,
          fcst_value_usd,
          fcst_value_eur,
          fcst_qty,
          fcst_qty_gross_tonnes,
          fcst_qty_net_tonnes,
          base_value,
          base_qty,
          aggreg_mkt_actvty_value,
          aggreg_mkt_actvty_qty,
          lock_value,
          lock_qty,
          rcncl_value,
          rcncl_qty,
          auto_adjmt_value,
          auto_adjmt_qty,
          override_value,
          override_qty,
          mkt_actvty_value,
          mkt_actvty_qty,
          data_driven_event_value,
          data_driven_event_qty,
          tgt_impact_value,
          tgt_impact_qty,
          dfn_adjmt_value,
          dfn_adjmt_qty
          )
          SELECT
            t1.company_code,
            t1.sales_org_code,
            t1.distbn_chnl_code,
            t1.division_code,
            t1.moe_code,
            t1.fcst_type_code,
            t1.casting_yyyypp,
            t1.casting_yyyyppw,
            t1.fcst_yyyypp,
            t1.fcst_yyyyppw,
            t1.demand_plng_grp_code,
            t1.cntry_code,
            t1.region_code,
            t1.multi_mkt_acct_code,
            t1.banner_code,
            t1.cust_buying_grp_code,
            t1.acct_assgnmnt_grp_code,
            t1.pos_format_grpg_code,
            t1.distbn_route_code,
            t1.cust_code,
            t1.matl_zrep_code,
            t1.matl_tdu_code,
            t1.currcy_code,
            t1.fcst_value,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_aud,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_usd,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
            ods_app.currcy_conv(t1.fcst_value,
                                t2.company_currcy,
                                ods_constants.currency_eur,
                                (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                 FROM mars_date
                                 WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
            t1.fcst_qty,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                               0),0) AS fcst_qty_gross_tonnes,
            NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                0),0) AS fcst_qty_net_tonnes,
            base_value,
            base_qty,
            aggreg_mkt_actvty_value,
            aggreg_mkt_actvty_qty,
            lock_value,
            lock_qty,
            rcncl_value,
            rcncl_qty,
            auto_adjmt_value,
            auto_adjmt_qty,
            override_value,
            override_qty,
            mkt_actvty_value,
            mkt_actvty_qty,
            data_driven_event_value,
            data_driven_event_qty,
            tgt_impact_value,
            tgt_impact_qty,
            dfn_adjmt_value,
            dfn_adjmt_qty
          FROM
            (SELECT /*+ INDEX(B FCST_DTL_PK) */
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0) AS casting_yyyypp,
               NULL casting_yyyyppw,        -- casting_yyyyppw is null if fcst_type is not FCST.
               (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
               NULL AS fcst_yyyyppw,        -- forecast_yyyyppw is null if fcst_type is not FCST.
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
               LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
               b.currcy_code,
               SUM(b.fcst_value) as fcst_value,
               SUM(b.fcst_qty) AS fcst_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
               SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
             FROM
               fcst_hdr a,
               fcst_dtl b
             WHERE
               a.fcst_hdr_code = b.fcst_hdr_code
               AND (a.casting_year = rv_casting_period.casting_yyyy AND
                    a.casting_period = rv_casting_period.casting_pp )
               AND a.company_code = i_company_code
               AND a.fcst_type_code = v_fcst_type_code
               AND a.sales_org_code = v_sales_org_code
               AND a.distbn_chnl_code = v_distbn_chnl_code
               AND ((a.division_code = v_division_code) OR
                    (a.division_code IS NULL AND v_division_code IS NULL))
               AND moe_code = v_moe_code
               AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
               AND a.valdtn_status = ods_constants.valdtn_valid
             GROUP BY
               a.company_code,
               a.sales_org_code,
               a.distbn_chnl_code,
               a.division_code,
               a.moe_code,
               a.fcst_type_code,
               a.casting_year || LPAD(a.casting_period,2,0),
               (b.fcst_year || LPAD(b.fcst_period,2,0)),
               b.demand_plng_grp_code,
               b.cntry_code,
               b.region_code,
               b.multi_mkt_acct_code,
               b.banner_code,
               b.cust_buying_grp_code,
               b.acct_assgnmnt_grp_code,
               b.pos_format_grpg_code,
               b.distbn_route_code,
               b.cust_code,
               b.matl_zrep_code,
               b.matl_tdu_code,
               b.currcy_code ) t1,
            company t2,
            sap_mat_hdr t3
         WHERE t1.company_code = t2.company_code
         AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

          write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 4, 'Insert Count: ' || TO_CHAR(SQL%ROWCOUNT));

        -- Commit.
        COMMIT;

      END LOOP;   -- End of csr_casting_period cursor.
    END IF;       -- End of v_no_insert_flag = FALSE check.

  END IF; -- End forecast type check for weekly FCST.

  END LOOP;

  -- Completed dmd_plng_fcst_fact aggregation.
  write_log(ods_constants.data_type_dmd_plng_forecast, 'N/A', i_log_level + 1, 'Completed DMD_PLNG_FCST_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO dmd_plng_fcst_fact_savepoint;
    write_log(ods_constants.data_type_dmd_plng_forecast,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.DMD_PLNG_FCST_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END dmd_plng_fcst_fact_aggregation;

FUNCTION dcs_order_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN dcs_sales_order.load_date%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CURSOR DECLARATIONS
  -- Check whether any fundraising orders were received or updated yesterday.
  CURSOR csr_dcs_order_count IS
    SELECT
      count(*) AS dcs_order_count
    FROM
      dcs_sales_order
    WHERE
      company_code = i_company_code
      AND TRUNC(dcs_sales_order_lupdt) = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid;

    rv_dcs_order_count csr_dcs_order_count%ROWTYPE;

BEGIN

  -- Starting dcs_sales_order_fact aggregation.
  write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Start - DCS_SALES_ORDER_FACT aggregation.');

  -- Fetch the record from the csr_dcs_order_count cursor.
  OPEN csr_dcs_order_count;
  FETCH csr_dcs_order_count INTO rv_dcs_order_count.dcs_order_count;
  CLOSE csr_dcs_order_count;

  -- Create a savepoint.
  SAVEPOINT dcs_order_fact_savepoint;

  -- If any fundraising orders were received or updated then continue the aggregation process.
  write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Checking whether any fundraising orders' ||
    ' were received or updated yesterday.');

  IF rv_dcs_order_count.dcs_order_count > 0 THEN

    -- Delete all existing dsc orders for the company first.
    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Deleting from DCS_SALES_ORDER_FACT based on' ||
      ' Company Code [' || i_company_code || ']');

    -- delete all the existing record first, becasue no history required to be kept in this table
    DELETE FROM dcs_sales_order_fact
    WHERE company_code = i_company_code;

    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

    -- Insert into dcs_sales_order_fact table based on company code.
    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Inserting into the DCS_SALES_ORDER_FACT table.');
    INSERT INTO dcs_sales_order_fact
      (
        company_code,
        order_doc_num,
        order_doc_line_num,
        order_type_code,
        creatn_date,
        order_eff_date,
        sales_org_code,
        distbn_chnl_code,
        division_code,
        doc_currcy_code,
        exch_rate,
        sold_to_cust_code,
        ship_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        base_uom_order_qty,
        order_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        order_gsv,
        matl_zrep_code,
        creatn_yyyyppdd,
        order_eff_yyyyppdd
      )
    SELECT
      company_code,
      order_doc_num,
      order_doc_line_num,
      order_type_code,
      creatn_date,
      order_eff_date,
      sales_org_code,
      distbn_chnl_code,
      division_code,
      doc_currcy_code,
      exch_rate,
      sold_to_cust_code,
      ship_to_cust_code,
      bill_to_cust_code,
      payer_cust_code,
      base_uom_order_qty,
      order_qty_base_uom_code,
      t1.plant_code,
      storage_locn_code,
      order_gsv,
      decode(t2.matl_type_code, 'ZREP', t2.matl_code, t2.rep_item) as matl_zrep_code,
      t3.mars_yyyyppdd as creatn_yyyyppdd,
      t4.mars_yyyyppdd as order_eff_yyyyppdd
    FROM
      dcs_sales_order t1,     -- this list is refreshed every day, no need to check the load date
      matl_dim t2,
      mars_date_dim t3,
      mars_date_dim t4
    WHERE
      t1.company_code = i_company_code
      AND t1.valdtn_status = ods_constants.valdtn_valid
      AND t1.matl_code = t2.matl_code
      AND t1.creatn_date = t3.calendar_date (+)
      AND t1.order_eff_date = t4.calendar_date (+)
      AND (t2.matl_type_code = 'ZREP' or t2.rep_item is not null);

    write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

    -- Commit.
    COMMIT;

  END IF;

  -- Completed DCS_SALES_ORDER_FACT aggregation.
  write_log(ods_constants.data_type_dcs_order, 'N/A', i_log_level + 1, 'Completed DCS_SALES_ORDER_FACT aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO dcs_order_fact_savepoint;
    write_log(ods_constants.data_type_dcs_order,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.DCS_ORDER_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END dcs_order_fact_aggregation;

FUNCTION get_mars_period (
  i_date        IN DATE,
  i_offset_days IN NUMBER,
  i_log_level   IN ods.log.log_level%TYPE
 ) RETURN NUMBER IS

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  CURSOR csr_mars_period IS
    SELECT mars_period as mars_period
    FROM mars_date_dim
    WHERE calendar_date = TRUNC(i_date + i_offset_days,'DD');
  rv_mars_period csr_mars_period%ROWTYPE;

BEGIN

  -- Fetch the record from the csr_mars_week cursor.
  OPEN csr_mars_period;
  FETCH csr_mars_period INTO rv_mars_period;
  IF csr_mars_period%NOTFOUND THEN
        CLOSE csr_mars_period;
        RAISE e_processing_error;
  ELSE
        CLOSE csr_mars_period;
        RETURN rv_mars_period.mars_period;
  END IF;

EXCEPTION
  WHEN e_processing_error THEN
    write_log( ods_constants.data_type_generic,'ERROR',
               i_log_level,'scheduled_aggregation.get_mars_period: ERROR: mars_period not found for [' || to_char(i_date+i_offset_days,'DD-MON-YYYY') || ']' );
    RAISE_APPLICATION_ERROR(-20000, 'mars_period not found');

  WHEN OTHERS THEN
    CLOSE csr_mars_period;
    write_log( ods_constants.data_type_generic,'ERROR',
               i_log_level,'scheduled_aggregation.get_mars_period: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    RAISE_APPLICATION_ERROR(-20000, SUBSTR(SQLERRM, 1, 512));
END get_mars_period;

PROCEDURE reload_fcst_region_fact (
  i_company_code     IN company.company_code%TYPE,
  i_moe_code         IN fcst_fact.moe_code%TYPE,
  i_reload_yyyypp    IN mars_date_dim.mars_period%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) IS

BEGIN
  write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Start - reload_fcst_region_fact.');

      -- Delete given moe_code and fcst_yyyypp > reload_yyyypp.
      DELETE FROM fcst_local_region_fact
      WHERE
        company_code = i_company_code
        AND moe_code = i_moe_code
        AND fcst_type_code = 'BR'
        AND fcst_yyyypp > i_reload_yyyypp;

      write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Delete from fcst_local_region_fact where moe_code [' || i_moe_code ||
                '] and fcst_yyyypp > [' || i_reload_yyyypp || '] with count [ ' || TO_CHAR(SQL%ROWCOUNT) || ']');
      INSERT INTO fcst_local_region_fact
        (
          company_code,
          moe_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          fcst_type_code,
          fcst_yyyypp,
          acct_assgnmnt_grp_code,
          demand_plng_grp_code,
          local_region_code,
          fcst_value
        )
      SELECT
        t1.company_code,
        t1.moe_code,
        t1.sales_org_code,
        t1.distbn_chnl_code,
        t1.division_code,
        t1.fcst_type_code,
        t1.fcst_yyyypp,
        t1.acct_assgnmnt_grp_code,
        t1.demand_plng_grp_code,
        t2.local_region_code,
        (t1.fcst_value * pct) as region_fcst_value
      FROM
        ( -- Sum up the fcst_value to group value.
          SELECT
            company_code,
            moe_code,
            sales_org_code,
            distbn_chnl_code,
            division_code,
            fcst_type_code,
            fcst_yyyypp,
            acct_assgnmnt_grp_code,
            demand_plng_grp_code,
            SUM(fcst_value) as fcst_value  -- Sum up to above grouping before dividing to local region amount.
          FROM
            fcst_fact t1
          WHERE
            fcst_yyyypp > i_reload_yyyypp
            AND company_code = i_company_code
            AND moe_code = i_moe_code
            AND fcst_type_code = 'BR'
            AND EXISTS (SELECT *
                        FROM
                          fcst_local_region_pct t2,
                          fcst_demand_grp_local_region t3
                        WHERE t2.demand_plng_grp_code = t3.demand_plng_grp_code
                          AND t3.moe_code = i_moe_code
                          AND t2.fcst_yyyypp = t1.fcst_yyyypp
                          AND t2.demand_plng_grp_code = t1.demand_plng_grp_code
                          AND t2.fcst_yyyypp > i_reload_yyyypp)  -- Only the demand group and fcst period have been set up.
          GROUP BY
            company_code,
            moe_code,
            sales_org_code,
            distbn_chnl_code,
            division_code,
            fcst_type_code,
            t1.fcst_yyyypp,
            acct_assgnmnt_grp_code,
            t1.demand_plng_grp_code) t1,
        fcst_local_region_pct t2
      WHERE t1.fcst_yyyypp = t2.fcst_yyyypp
        AND t1.demand_plng_grp_code = t2.demand_plng_grp_code
        AND t2.fcst_yyyypp > i_reload_yyyypp;

      write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

      -- Commit.
      COMMIT;

  -- Completed fcst_local_region_fact aggregation.
  write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Completed reload_fcst_region_fact.');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_fcst_local_region,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.reload_fcst_region_fact: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
    raise_application_error(-20000, 'LOG ERROR - ' || SUBSTR(SQLERRM, 1, 512));

END reload_fcst_region_fact;



FUNCTION fcst_region_fact_aggregation (
  i_company_code     IN company.company_code%TYPE,
  i_aggregation_date IN fcst_hdr.fcst_hdr_lupdt%TYPE,
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_casting_yyyypp        mars_date_dim.mars_period%TYPE;
  v_aggregation_date      DATE;
  v_reload_yyyypp         mars_date_dim.mars_period%TYPE;
  v_snack_br_cast_period  mars_date_dim.mars_period%TYPE;
  v_moe_code              fcst_fact.moe_code%TYPE;
  v_snack_reload          BOOLEAN := FALSE;
  v_reload                BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Check the min casting period for the BR forecast type and moe_code exist in fcst_demand_grp_local_region
  -- and changed on the aggregation date.
  CURSOR csr_min_casting_period IS
    SELECT
      MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
      moe_code
    FROM fcst_hdr  t1
    WHERE company_code = i_company_code
      AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
      AND fcst_type_code = 'BR'  -- Period forecast
      AND EXISTS (SELECT * FROM fcst_demand_grp_local_region t2 WHERE t1.moe_code = t2.moe_code) -- only has moe set up
      AND TRUNC(fcst_hdr_lupdt, 'DD') = i_aggregation_date
      AND valdtn_status = ods_constants.valdtn_valid
    GROUP BY
      moe_code;
  rv_min_casting_period csr_min_casting_period%ROWTYPE;

  -- Get the reload period for snack BR which is one period ahead then the other business.
  CURSOR csr_snack_reload_period IS
    SELECT mars_period AS reload_yyyypp
    FROM mars_date_dim
    WHERE calendar_date = (SELECT MAX(calendar_date) + 1
                           FROM mars_date_dim
                           WHERE mars_period = v_casting_yyyypp);

  -- Used to check whether this is the first day of the current period for snack business
  -- becasue this day the moe_code = 0009 will reload to fcst_fact and we need to reload to
  -- fcst_local_region_fact as well.
  CURSOR csr_mars_date IS
    SELECT
      mars_period,
      period_day_num
    FROM mars_date_dim
    WHERE calendar_date = v_aggregation_date;
  rv_mars_date csr_mars_date%ROWTYPE;

BEGIN
   write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Start - fcst_region_fact_aggregation.');

   FOR rv_min_casting_period IN csr_min_casting_period LOOP

     -- Handling the following unique moe_code.
     write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 2, 'Handling - MOE/MIN Casting Period [' ||
               rv_min_casting_period.moe_code || '/' || rv_min_casting_period.min_casting_yyyypp || ']');

     v_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;
     v_moe_code := rv_min_casting_period.moe_code;
     v_reload_yyyypp := rv_min_casting_period.min_casting_yyyypp;
     v_reload := TRUE;

     -- Snack BR type has special reload trigger.
     IF v_moe_code = '0009' THEN

        -- Get the current expected Snackfood BR casting period and compare with the received min casting period
        v_snack_br_cast_period := get_mars_period (i_aggregation_date, -56, i_log_level+1);

        IF v_casting_yyyypp <= v_snack_br_cast_period THEN
           v_snack_reload := TRUE;
           v_reload := TRUE;

           -- Then reload forecast period greater than casting_yyyypp + 1
           OPEN csr_snack_reload_period;
           FETCH csr_snack_reload_period INTO v_reload_yyyypp;
           CLOSE csr_snack_reload_period;

        ELSE
           write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 2, 'No action taken for this snackfood BR type. Reason: this casting period > casting period - 2 [' ||
                       v_casting_yyyypp || ' > ' || v_snack_br_cast_period || '].');

           v_reload :=  FALSE;
        END IF;

     END IF;

     IF v_reload = TRUE THEN
        reload_fcst_region_fact (i_company_code, v_moe_code, v_reload_yyyypp, i_log_level+1);

     END IF;
   END LOOP;

   -- Only checking for first day of period trigger if we have reload for snack today.
   IF v_snack_reload = FALSE THEN

      -- Use current date as the aggregation_date AND check whether today is the first day of the current period
      -- Snackfood, BR type has been reloaded on first day of the period, we need to reload fcst_local_region_fact
      v_aggregation_date := TRUNC(sysdate);

      OPEN csr_mars_date;
      FETCH csr_mars_date INTO rv_mars_date;
      CLOSE csr_mars_date;

      IF rv_mars_date.period_day_num = 1 THEN

         write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level, 'First day of period [' || rv_mars_date.mars_period || ']');

         -- We reload from current period so pass in last period becasue the reload function use greater than
         v_reload_yyyypp := get_mars_period (v_aggregation_date, -20, i_log_level+1);
         v_moe_code := '0009';

         reload_fcst_region_fact (i_company_code, v_moe_code, v_reload_yyyypp, i_log_level+1);
      ELSE
         write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level, 'First day of period [' || rv_mars_date.mars_period || ']');
      END IF;

   END IF;

  -- Completed fcst_local_region_fact aggregation.
  write_log(ods_constants.data_type_fcst_local_region, 'N/A', i_log_level + 1, 'Completed fcst_region_fact_aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_fcst_local_region,
              'ERROR',
              0,
              'SCHEDULED_AGGREGATION.fcst_region_fact_aggregation: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END fcst_region_fact_aggregation;



PROCEDURE write_log (
  i_data_type  IN ods.log.data_type%TYPE,
  i_sort_field IN ods.log.sort_field%TYPE,
  i_log_level  IN ods.log.log_level%TYPE,
  i_log_text   IN ods.log.log_text%TYPE) IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  -- Write the entry into the log table.
  utils.ods_log (ods_constants.job_type_sched_aggregation,
                 i_data_type,
                 i_sort_field,
                 i_log_level,
                 i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              i_log_level,
              'SCHEDULED_AGGREGATION.WRITE_LOG: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
END write_log;

END scheduled_aggregation;
/
