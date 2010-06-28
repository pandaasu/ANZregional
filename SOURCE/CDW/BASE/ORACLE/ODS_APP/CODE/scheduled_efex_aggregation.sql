CREATE OR REPLACE PACKAGE         scheduled_efex_aggregation IS

/*******************************************************************************
  NAME:      run_efex_aggregation
  PURPOSE:   This procedure is the main routine, which calls the other package
             procedures and functions to flatten and aggregate all the efex data
             from the ODS schema.

             The scheduled efex aggregation process is initiated by an Oracle job that
             should be run once daily after the efex to ods extraction has completed.

             The scheduled job will call this efex aggregation procedure passing
             Aggregation Date as parameters.  Aggregation Date will be set to SYSDATE
             when called via the scheduled job.

   NOTES:  The sequence of the function call within this procedure should not be changed
             because some of the data load rely on the load sequence.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   28/09/2007 Kris Lee            Created this procedure.
  1.1   16/01/2008 Kris Lee            Add new functions to aggregate:
                                         efex_assoc_sgmnt_fact
                                         efex_cust_note_fact
                                       Update the efex_cust.sales_terr_code when
                                       a new code is created for the same Sales
                                       Territory.
  1.2   21/01/2008 Kris Lee           Create new distribution and total distribution
                                      with new code when new code created for sales
                                      territory or customer.
                                      Fix efex_distbn_xactn_dim, efex_distbn_fact,
                                      efex_tot_distn_xactn_dim with new codes from
                                      latest customer and sales territory.
  1.3   19/02/2008 Kris Lee           - Create efx_cust_distbn_oppotn_fact_aggr
                                               efx_matl_distbn_oppotn_fact_aggr
                                        for the opportunity distribution total gaps.
                                      - Eff_end_date should be updated when customer or
                                        sales territory status changed to X.
                                      - Create new customer detail record when customer
                                        record re-opened from efex (change status from X to A).
                                      - Change efex_distbn_xactn_dim gap logic
                                      - Add new fields to efex_distbn_fact.
                                      - Add new fields to efex_range_matl_fact.
                                      - Change efex_cust_note.cust_note_created data type to
                                        date and truncate to date part only.
                                      - Set default values for efex_cust_dtl_dim nullable fields.
  1.4   30/05/2008 Paul Berude        - Create efx_cust_fact_aggr
  1.5   08/08/2008 Paul Berude        Change efex_target column user_id to sales_terr_id due to
                                      change in efex application
  1.6   06/07/2009 Trevor Keon        - Added batch commits to the efex_distbn_fact_aggr function
  1.7   28/06/2010 Steve Gregan       - Added market id to the flattening/aggregation process
                                        This process is now performed by market id

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     DATE     Aggregation Date                     20071001
  2    IN     NUMBER   Market Id                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_efex_aggregation (
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

END scheduled_efex_aggregation;
/


CREATE OR REPLACE PACKAGE BODY         scheduled_efex_aggregation IS

  c_future_date          CONSTANT DATE := TO_DATE('99991231','YYYYMMDD');
  c_tp_budget_target_id  CONSTANT efex_target_fact.efex_target_id%TYPE := 12;
  p_market_id            NUMBER;
  p_company_code         VARCHAR2(10);

FUNCTION efex_ref_data_flattening (
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_bus_unit_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_sgmnt_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_assoc_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_banner_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_chnl_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_sales_terr_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_cust_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_matl_grp_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_matl_subgrp_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_matl_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_matl_matlsbgrp_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_assmnt_questn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_range_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_distbn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_distbn_xactn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_tot_distbn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_tot_distn_tx_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_turnin_order_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_pmt_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_mrq_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_mrq_task_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

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

FUNCTION efex_distbn_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_tot_distbn_fact_aggr (
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

FUNCTION efex_distbn_fact_wkly_snapshot (
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_assoc_sgmnt_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_cust_fact_aggr (
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_cust_note_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_cust_opp_distbn_fact_aggr (
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_matl_opp_distbn_fact_aggr (
  i_log_level        IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

FUNCTION efex_target_fact_aggr (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER;

PROCEDURE run_efex_aggregation (
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
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled EFEX Flattening and Aggregation - Start');

  -- Market id must be valid.
  IF p_market_id is null OR (p_market_is != 1 AND p_market_id != 5) THEN
      v_processing_msg := 'Invalid market id [' || TO_CHAR(i_market_id) || '].';
      RAISE e_processing_error;
  END IF:

  -- Company code must be valid.
  IF p_company_code is null OR (p_company_code != '147' AND p_company_code != '149') THEN
      v_processing_msg := 'Invalid company code [' || p_company_code || '].';
      RAISE e_processing_error;
  END IF:

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
   ***   CALLING DIM FLATTENINGS    ***
   ************************************/

  -- Calling the efex_ref_data_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_ref_data_flattening function.');
  v_status := efex_ref_data_flattening(v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_ref_data_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_bus_unit_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_bus_unit_flattening function.');
  v_status := efex_bus_unit_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_bus_unit_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_sgmnt_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_sgmnt_flattening function.');
  v_status := efex_sgmnt_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_sgmnt_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_assoc_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_assoc_flattening function.');
  v_status := efex_assoc_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_assoc_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_banner_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_banner_flattening function.');
  v_status := efex_banner_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_banner_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_chnl_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_chnl_flattening function.');
  v_status := efex_chnl_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_chnl_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_matl_grp_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_matl_grp_flattening function.');
  v_status := efex_matl_grp_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_matl_grp_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_matl_subgrp_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_matl_subgrp_flattening function.');
  v_status := efex_matl_subgrp_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_matl_subgrp_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_matl_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_matl_flattening function.');
  v_status := efex_matl_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_matl_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_matl_matlsbgrp_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_matl_matlsbgrp_flattening function.');
  v_status := efex_matl_matlsbgrp_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_matl_matlsbgrp_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_sales_terr_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_sales_terr_flattening function.');
  v_status := efex_sales_terr_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_sales_terr_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_cust_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_cust_flattening function.');
  v_status := efex_cust_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_cust_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_assmnt_questn_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_assmnt_questn_flattening function.');
  v_status := efex_assmnt_questn_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_assmnt_questn_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_range_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_range_flattening function.');
  v_status := efex_range_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_range_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_distbn_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_distbn_flattening function.');
  v_status := efex_distbn_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_distbn_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_distbn_xactn_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_distbn_xactn_flattening function.');
  v_status := efex_distbn_xactn_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_distbn_xactn_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_tot_distbn_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_tot_distbn_flattening function.');
  v_status := efex_tot_distbn_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_tot_distbn_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_tot_distn_tx_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_tot_distn_tx_flattening function.');
  v_status := efex_tot_distn_tx_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_tot_distn_tx_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_turnin_order_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_turnin_order_flattening function.');
  v_status := efex_turnin_order_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_turnin_order_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_pmt_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_pmt_flattening function.');
  v_status := efex_pmt_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_pmt_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_mrq_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_mrq_flattening function.');
  v_status := efex_mrq_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_mrq_flattening.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_mrq_task_flattening function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_mrq_task_flattening function.');
  v_status := efex_mrq_task_flattening(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_mrq_task_flattening.';
    RAISE e_processing_error;
  END IF;

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

  -- Calling the efex_distbn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_distbn_fact_aggr function.');
  v_status := efex_distbn_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_distbn_fact_aggr.';
    RAISE e_processing_error;
  END IF;

 -- Calling the efex_distbn_fact_wkly_snapshot function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_distbn_fact_wkly_snapshot function.');
  v_status := efex_distbn_fact_wkly_snapshot(v_log_level + 1);
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

  -- Calling the efex_cust_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_cust_fact_aggr function.');
  v_status := efex_cust_fact_aggr(v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_cust_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_cust_note_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_cust_note_fact_aggr function.');
  v_status := efex_cust_note_fact_aggr(v_aggregation_date, v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_cust_note_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_cust_opp_distbn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_cust_opp_distbn_fact_aggr function.');
  v_status := efex_cust_opp_distbn_fact_aggr(v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_cust_opp_distbn_fact_aggr.';
    RAISE e_processing_error;
  END IF;

  -- Calling the efex_matl_opp_distbn_fact_aggr function.
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level + 1, 'Calling the efex_matl_opp_distbn_fact_aggr function.');
  v_status := efex_matl_opp_distbn_fact_aggr(v_log_level + 1);
  IF v_status <> constants.success THEN
    v_processing_msg := 'Unable to successfully complete the efex_matl_opp_distbn_fact_aggr.';
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
  write_log(ods_constants.data_type_generic, 'N/A', v_log_level, 'Scheduled Efex Flattening and Aggregation - End');

EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_EFEX_AGGREGATION.RUN_EFEX_AGGREGATION: ERROR: ' || v_processing_msg);

    utils.send_email_to_group(ods_constants.job_type_efex_aggregation,
                              'MFANZ CDW Scheduled EFEX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_EFEX_AGGREGATION.RUN_EFEX_AGGREGATION: ERROR: ' || v_processing_msg ||
                              utl_tcp.crlf);

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_generic,
              'ERROR',
              v_log_level,
              'SCHEDULED_EFEX_AGGREGATION.RUN_EFEX_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    utils.send_email_to_group(ods_constants.job_type_efex_aggregation,
                              'MFANZ CDW Scheduled EFEX Aggregation',
                              'The below error occurred on the Database ' ||
                              v_db_name ||
                              ', which resides on the server ' ||
                              ods_constants.hostname || '.' ||
                              utl_tcp.crlf ||
                              utl_tcp.crlf ||
                              'SCHEDULED_EFEX_AGGREGATION.RUN_EFEX_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512) ||
                              utl_tcp.crlf);

END run_efex_aggregation;

/**************************
 ***   DIM FLATTENINGS  ***
 **************************/
FUNCTION efex_ref_data_flattening (
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

BEGIN
  -- Starting merging efex_call_type to efex_call_type_dim.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Start merging EFEX_CALL_TYPE to EFEX_CALL_TYPE_DIM.');

     MERGE INTO
       efex_call_type_dim t1
     USING (SELECT
              call_type_code,
              call_type
            FROM
              ods.efex_call_type
            WHERE efex_mkt_id = p_market_id
            MINUS
            SELECT
              call_type_code,
              call_type
            FROM
              efex_call_type_dim
            ) t2
        ON (t1.call_type_code = t2.call_type_code )
        WHEN MATCHED THEN
          UPDATE SET
            t1.call_type = t2.call_type
        WHEN NOT MATCHED THEN
          INSERT
            (t1.call_type_code,
             t1.call_type)
          VALUES
            (t2.call_type_code,
             t2.call_type);

  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'EFEX_CALL_TYPE_DIM updated count [' || SQL%ROWCOUNT || '].');

  -- Commit.
  COMMIT;

  -- Starting merging efex_callback_flg to efex_callback_flg_dim.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Start merging efex_callback_flg to efex_callback_flg_dim.');

     MERGE INTO
       efex_callback_flg_dim t1
     USING (SELECT
              callback_flg_code,
              callback_flg
            FROM
              ods.efex_callback_flg
            MINUS
            SELECT
              callback_flg_code,
              callback_flg
            FROM
              efex_callback_flg_dim
            ) t2
        ON (t1.callback_flg_code = t2.callback_flg_code )
        WHEN MATCHED THEN
          UPDATE SET
            t1.callback_flg = t2.callback_flg
        WHEN NOT MATCHED THEN
          INSERT
            (t1.callback_flg_code,
             t1.callback_flg)
          VALUES
            (t2.callback_flg_code,
             t2.callback_flg);

  -- Commit.
  COMMIT;

  -- Starting merging efex_rqd_flg to efex_rqd_flg_dim.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Start merging efex_rqd_flg to efex_rqd_flg_dim.');

     MERGE INTO
       efex_rqd_flg_dim t1
     USING (SELECT
              rqd_flg_code,
              rqd_flg
            FROM
              efex_rqd_flg
            MINUS
            SELECT
              rqd_flg_code,
              rqd_flg
            FROM
              efex_rqd_flg_dim
            ) t2
        ON (t1.rqd_flg_code = t2.rqd_flg_code )
        WHEN MATCHED THEN
          UPDATE SET
            t1.rqd_flg = t2.rqd_flg
        WHEN NOT MATCHED THEN
          INSERT
            (t1.rqd_flg_code,
             t1.rqd_flg)
          VALUES
            (t2.rqd_flg_code,
             t2.rqd_flg);

  -- Commit.
  COMMIT;

  -- Starting merging efex_callback_flg to efex_callback_flg_dim.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Start merging efex_ranged_flg to efex_ranged_flg_dim.');

     MERGE INTO
       efex_ranged_flg_dim t1
     USING (SELECT
              ranged_flg_code,
              ranged_flg
            FROM
              ods.efex_ranged_flg
            MINUS
            SELECT
              ranged_flg_code,
              ranged_flg
            FROM
              efex_ranged_flg_dim
            ) t2
        ON (t1.ranged_flg_code = t2.ranged_flg_code )
        WHEN MATCHED THEN
          UPDATE SET
            t1.ranged_flg = t2.ranged_flg
        WHEN NOT MATCHED THEN
          INSERT
            (t1.ranged_flg_code,
             t1.ranged_flg)
          VALUES
            (t2.ranged_flg_code,
             t2.ranged_flg);

  -- Commit.
  COMMIT;

  -- Starting merging efex_outofdate_stock_flg to efex_outofdate_stock_flg_dim.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Start merging efex_outofdate_stock_flg to efex_outofdate_stock_flg_dim.');

     MERGE INTO
       efex_outofdate_stock_flg_dim t1
     USING (SELECT
              outofdate_stock_flg_code,
              outofdate_flg,
              outofstock_flg
            FROM
              ods.efex_outofdate_stock_flg
            MINUS
            SELECT
              outofdate_stock_flg_code,
              outofdate_flg,
              outofstock_flg
            FROM
              efex_outofdate_stock_flg_dim
            ) t2
        ON (t1.outofdate_stock_flg_code = t2.outofdate_stock_flg_code )
        WHEN MATCHED THEN
          UPDATE SET
            t1.outofdate_flg = t2.outofdate_flg,
            t1.outofstock_flg = t2.outofstock_flg
        WHEN NOT MATCHED THEN
          INSERT
            (t1.outofdate_stock_flg_code,
             t1.outofdate_flg,
             t1.outofstock_flg)
          VALUES
            (t2.outofdate_stock_flg_code,
             t2.outofdate_flg,
             t2.outofstock_flg);

  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'EFEX_OUTOFDATE_STOCK_FLG_DIM updated count [' || SQL%ROWCOUNT || '].');

  -- Commit.
  COMMIT;

  -- Starting merging efex_gap_flg to efex_gap_flg_dim.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Start merging efex_gap_flg to efex_gap_flg_dim.');

     MERGE INTO
       efex_gap_flg_dim t1
     USING (SELECT
              gap_flg_code,
              gap_flg,
              new_gap_flg,
              closed_gap_flg
            FROM
              ods.efex_gap_flg
            MINUS
            SELECT
              gap_flg_code,
              gap_flg,
              new_gap_flg,
              closed_gap_flg
            FROM
              efex_gap_flg_dim
            ) t2
        ON (t1.gap_flg_code = t2.gap_flg_code )
        WHEN MATCHED THEN
          UPDATE SET
            t1.gap_flg = t2.gap_flg,
            t1.new_gap_flg = t2.new_gap_flg,
            t1.closed_gap_flg = t2.closed_gap_flg
        WHEN NOT MATCHED THEN
          INSERT
            (t1.gap_flg_code,
             t1.gap_flg,
             t1.new_gap_flg,
             t1.closed_gap_flg)
          VALUES
            (t2.gap_flg_code,
             t2.gap_flg,
             t2.new_gap_flg,
             t2.closed_gap_flg);

  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'EFEX_GAP_FLG_DIM updated count [' || SQL%ROWCOUNT || '].');

  -- Commit.
  COMMIT;

  -- Starting merging efex_mrq_status_flg to efex_mrq_status_flg_dim.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Start merging efex_mrq_status_flg to efex_mrq_status_flg_dim.');

     MERGE INTO
       efex_mrq_status_flg_dim t1
     USING (SELECT
              mrq_status_flg_code,
              completed_flg,
              mrq_status
            FROM
              ods.efex_mrq_status_flg
            MINUS
            SELECT
              mrq_status_flg_code,
              completed_flg,
              mrq_status
            FROM
              efex_mrq_status_flg_dim
            ) t2
        ON (t1.mrq_status_flg_code = t2.mrq_status_flg_code )
        WHEN MATCHED THEN
          UPDATE SET
            t1.completed_flg = t2.completed_flg,
            t1.mrq_status = t2.mrq_status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.mrq_status_flg_code,
             t1.completed_flg,
             t1.mrq_status)
          VALUES
            (t2.mrq_status_flg_code,
             t2.completed_flg,
             t2.mrq_status);

  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'EFEX_MRQ_STATUS_FLG_DIM updated count [' || SQL%ROWCOUNT || '].');

  -- Commit.
  COMMIT;

  -- Complete efex_ref_data_flattening.
  write_log(ods_constants.data_type_efex_refs, 'N/A', i_log_level + 1, 'Complete efex_ref_data_flattening.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_extraction,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_SCHEDULE.EFEX_REF_DATA_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_ref_data_flattening;


FUNCTION efex_bus_unit_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex business unit modified yesterday.
  CURSOR csr_bus_unit_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_bus_unit
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(bus_unit_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_bus_unit flattening.
  write_log(ods_constants.data_type_efex_bus_unit, 'N/A', i_log_level + 1, 'Starting EFEX_BUS_UNIT_DIM flattening.');

  -- Fetch the record from the csr_bus_unit_count cursor.
  OPEN  csr_bus_unit_count;
  FETCH csr_bus_unit_count INTO v_rec_count;
  CLOSE csr_bus_unit_count;

  -- If any efex business unit records modified yesterday.
  write_log(ods_constants.data_type_efex_bus_unit, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] Business Unit received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_bus_unit_dim t1
     USING (SELECT
              bus_unit_id    efex_bus_unit_id,
              bus_unit_name,
              status
            FROM
              ods.efex_bus_unit
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(bus_unit_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_bus_unit_id = t2.efex_bus_unit_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.bus_unit_name = t2.bus_unit_name,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_bus_unit_id,
             t1.bus_unit_name,
             t1.status)
          VALUES
            (t2.efex_bus_unit_id,
             t2.bus_unit_name,
             t2.status);

      -- number of record modified.
      write_log(ods_constants.data_type_efex_bus_unit, 'N/A', i_log_level + 2, 'EFEX_BUS_UNIT_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_bus_unit,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_BUS_UNIT_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_bus_unit_flattening;


FUNCTION efex_sgmnt_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex segment modified yesterday
  CURSOR csr_sgmnt_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_sgmnt
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(sgmnt_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_sgmnt flattening.
  write_log(ods_constants.data_type_efex_sgmnt, 'N/A', i_log_level + 1, 'Starting EFEX_SGMNT_DIM flattening.');

  -- Fetch the record from the csr_sgmnt_count cursor.
  OPEN  csr_sgmnt_count;
  FETCH csr_sgmnt_count INTO v_rec_count;
  CLOSE csr_sgmnt_count;

  -- If any efex segment records modified yesterday
  write_log(ods_constants.data_type_efex_sgmnt, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex segment received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_sgmnt_dim t1
     USING (SELECT
              sgmnt_id     efex_sgmnt_id,
              sgmnt_name,
              bus_unit_id  efex_bus_unit_id,
              status
            FROM
              ods.efex_sgmnt
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(sgmnt_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_sgmnt_id = t2.efex_sgmnt_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.sgmnt_name = t2.sgmnt_name,
            t1.status = t2.status,
            t1.efex_bus_unit_id = t2.efex_bus_unit_id
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_sgmnt_id,
             t1.sgmnt_name,
             t1.efex_bus_unit_id,
             t1.status)
          VALUES
            (t2.efex_sgmnt_id,
             t2.sgmnt_name,
             t2.efex_bus_unit_id,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_sgmnt, 'N/A', i_log_level + 2, 'EFEX_SGMNT_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_sgmnt,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_SGMNT_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_sgmnt_flattening;


FUNCTION efex_assoc_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex user modified yesterday.
  CURSOR csr_assoc_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_user
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(user_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_assoc flattening.
  write_log(ods_constants.data_type_efex_assoc, 'N/A', i_log_level + 1, 'Starting EFEX_ASSOC_DIM flattening.');

  -- Fetch the record from the csr_assoc_count cursor.
  OPEN  csr_assoc_count;
  FETCH csr_assoc_count INTO v_rec_count;
  CLOSE csr_assoc_count;

  -- If any efex user records modified yesterday
  write_log(ods_constants.data_type_efex_assoc, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex user received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_assoc_dim t1
     USING (SELECT
              user_id     as efex_assoc_id,
              firstname,
              lastname,
              firstname || ' ' || lastname as fullname,
              email_addr,
              phone_num,
              status
            FROM
              ods.efex_user
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(user_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_assoc_id = t2.efex_assoc_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.firstname = t2.firstname,
            t1.lastname = t2.lastname,
            t1.fullname = t2.fullname,
            t1.email_addr = t2.email_addr,
            t1.phone_num = t2.phone_num,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_assoc_id,
             t1.firstname,
             t1.lastname,
             t1.fullname,
             t1.email_addr,
             t1.phone_num,
             t1.status)
          VALUES
            (t2.efex_assoc_id,
             t2.firstname,
             t2.lastname,
             t2.fullname,
             t2.email_addr,
             t2.phone_num,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_assoc, 'N/A', i_log_level + 2, 'EFEX_assoc_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_assoc,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_ASSOC_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_assoc_flattening;


FUNCTION efex_banner_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex banner modified yesterday.
  CURSOR csr_banner_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_affltn
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(affltn_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_banner flattening.
  write_log(ods_constants.data_type_efex_banner, 'N/A', i_log_level + 1, 'Starting EFEX_BANNER_DIM flattening.');

  -- Fetch the record from the csr_banner_count cursor.
  OPEN  csr_banner_count;
  FETCH csr_banner_count INTO v_rec_count;
  CLOSE csr_banner_count;

  -- If any efex banner records modified yesterday.
  write_log(ods_constants.data_type_efex_banner, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex banner received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_banner_dim t1
     USING (SELECT
              affltn_id       as efex_banner_id,
              affltn_name     as banner_name,
              affltn_grp_id   as efex_banner_grp_id,
              affltn_grp_name as banner_grp_name,
              status
            FROM
              ods.efex_affltn
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(affltn_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_banner_id = t2.efex_banner_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.banner_name = t2.banner_name,
            t1.efex_banner_grp_id = t2.efex_banner_grp_id,
            t1.banner_grp_name = t2.banner_grp_name,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_banner_id,
             t1.banner_name,
             t1.efex_banner_grp_id,
             t1.banner_grp_name,
             t1.status)
          VALUES
            (t2.efex_banner_id,
             t2.banner_name,
             t2.efex_banner_grp_id,
             t2.banner_grp_name,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_banner, 'N/A', i_log_level + 2, 'EFEX_BANNER_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_banner,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_BANNER_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_banner_flattening;


FUNCTION efex_chnl_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex customer channel modified yesterday.
  CURSOR csr_chnl_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_cust_chnl
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(cust_chnl_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_chnl flattening.
  write_log(ods_constants.data_type_efex_chnl, 'N/A', i_log_level + 1, 'Starting EFEX_CHNL_DIM flattening.');

  -- Fetch the record from the csr_chnl_count cursor.
  OPEN  csr_chnl_count;
  FETCH csr_chnl_count INTO v_rec_count;
  CLOSE csr_chnl_count;

  -- If any efex customer channel records modified yesterday.
  write_log(ods_constants.data_type_efex_chnl, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex customer channel received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_chnl_dim t1
     USING (SELECT
              cust_type_id       as efex_cust_type_id,
              cust_type_name,
              cust_trad_chnl_id  as efex_cust_trad_chnl_id,
              cust_trad_chnl_name,
              cust_chnl_id       as efex_cust_chnl_id,
              cust_chnl_name,
              status
            FROM
              ods.efex_cust_chnl
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(cust_chnl_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_cust_type_id = t2.efex_cust_type_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.cust_type_name = t2.cust_type_name,
            t1.efex_cust_trad_chnl_id = t2.efex_cust_trad_chnl_id,
            t1.cust_trad_chnl_name = t2.cust_trad_chnl_name,
            t1.efex_cust_chnl_id = t2.efex_cust_chnl_id,
            t1.cust_chnl_name = t2.cust_chnl_name,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_cust_type_id,
             t1.cust_type_name,
             t1.efex_cust_trad_chnl_id,
             t1.cust_trad_chnl_name,
             t1.efex_cust_chnl_id,
             t1.cust_chnl_name,
             t1.status)
          VALUES
            (t2.efex_cust_type_id,
             t2.cust_type_name,
             t2.efex_cust_trad_chnl_id,
             t2.cust_trad_chnl_name,
             t2.efex_cust_chnl_id,
             t2.cust_chnl_name,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_chnl, 'N/A', i_log_level + 2, 'EFEX_CHNL_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_chnl,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_CHNL_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_chnl_flattening;


FUNCTION efex_sales_terr_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count            NUMBER := 0;
  v_efex_sales_terr_id   efex_sales_terr.sales_terr_id%TYPE;
  v_update_flg           BOOLEAN := FALSE;
  v_insert_flg           BOOLEAN := FALSE;
  v_update_count         PLS_INTEGER := 0;
  v_insert_count         PLS_INTEGER := 0;
  v_new_sales_terr_code  efex_sales_terr_dim.sales_terr_code%TYPE;
  v_old_sales_terr_code  efex_sales_terr_dim.sales_terr_code%TYPE;
  v_cust_update_count    NUMBER := 0;
  v_target_update_count  NUMBER := 0;
  v_old_efex_sgmnt_id    efex_sales_terr.sgmnt_id%TYPE;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether any efex sales territerory modified yesterday.
  CURSOR csr_sales_terr_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_sales_terr
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(sales_terr_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  -- efex_sales_terr cursor from ODS table.
  CURSOR csr_sales_terr IS
    SELECT
      sales_terr_id       efex_sales_terr_id,
      sales_terr_name,
      sales_terr_user_id  sales_terr_mgr_id,
      sales_area_id       efex_sales_area_id,
      sales_area_name,
      sales_area_user_id  efex_area_mgr_id,
      area_mgr_name,
      sales_regn_id       efex_sales_regn_id,
      sales_regn_name,
      sales_regn_user_id  efex_regn_mgr_id,
      regn_mgr_name,
      sgmnt_id            efex_sgmnt_id,
      bus_unit_id         efex_bus_unit_id,
      TRUNC(efex_lupdt)   efex_lupdt,
      status
    FROM
      ods.efex_sales_terr
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(sales_terr_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  rv_sales_terr csr_sales_terr%ROWTYPE;

  -- Select the latest record from dim for the same sales_terr_id.
  CURSOR csr_last_sales_terr IS
    SELECT
      sales_terr_code,
      efex_sales_terr_id,
      sales_terr_mgr_id,
      efex_sales_area_id,
      efex_sales_regn_id,
      efex_sgmnt_id
    FROM
      efex_sales_terr_dim
    WHERE
      efex_sales_terr_id = v_efex_sales_terr_id
      AND last_rec_flg = 'Y';

    rv_last_sales_terr csr_last_sales_terr%ROWTYPE;

  -- Select the new sales_terr_code here so we can
  -- use it to update the efex_cust_dtl_dim.sales_terr_code
  -- when a new code is created for slowly changed process.
  CURSOR csr_sales_terr_code IS
    SELECT
      efex_sales_terr_dim_seq.nextval as sales_terr_code
    FROM
      dual;

BEGIN

  -- Starting efex_sales_terr flattening.
  write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 1, 'Starting EFEX_SALES_TERR_DIM flattening (apply slowly change).');

  -- Fetch the record from the csr_sales_terr_count cursor.
  OPEN  csr_sales_terr_count;
  FETCH csr_sales_terr_count INTO v_rec_count;
  CLOSE csr_sales_terr_count;

  -- If any efex sales territory records modified yesterday
  write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex sales territory received yesterday.');

  IF v_rec_count > 0 THEN

    FOR rv_sales_terr IN csr_sales_terr LOOP

     BEGIN
      -- Now pass cursor results into variables.
      v_efex_sales_terr_id :=  rv_sales_terr.efex_sales_terr_id;
      v_update_flg := FALSE;
      v_insert_flg := FALSE;
      v_old_sales_terr_code := NULL;
      v_old_efex_sgmnt_id := NULL;

      -- Get the latest record for the same sales_terr_id.
      OPEN csr_last_sales_terr;
      FETCH csr_last_sales_terr INTO rv_last_sales_terr;
      IF csr_last_sales_terr%NOTFOUND THEN
         v_insert_flg := TRUE;
      ELSE
         -- Find existing record, check whether slowly change process required.
         IF rv_sales_terr.sales_terr_mgr_id <> rv_last_sales_terr.sales_terr_mgr_id OR
            rv_sales_terr.efex_sales_area_id <> rv_last_sales_terr.efex_sales_area_id OR
            rv_sales_terr.efex_sales_regn_id <> rv_last_sales_terr.efex_sales_regn_id THEN
            v_update_flg := TRUE;
            v_insert_flg := TRUE;

            v_old_sales_terr_code := rv_last_sales_terr.sales_terr_code;
            v_old_efex_sgmnt_id := rv_last_sales_terr.efex_sgmnt_id;

            -- The following sales territory requires slowly change.
            write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 3, 'The following sales terr' ||
                     ' requires slowly changes sales terr id/mgr id/sales area id/sales regn id [' ||
                     rv_sales_terr.efex_sales_terr_id || '/' || rv_sales_terr.sales_terr_mgr_id || '/' ||
                     rv_sales_terr.efex_sales_area_id || '/' || rv_sales_terr.efex_sales_regn_id || '].');

         ELSE
            -- Only update latest record.
            v_update_flg := TRUE;
         END IF;

      END IF;
      CLOSE csr_last_sales_terr;

      IF v_insert_flg = TRUE THEN
         -- If slowly change occurs, close the last sales territory record first.
         IF v_update_flg = TRUE THEN
            UPDATE
              efex_sales_terr_dim
            SET
              eff_end_date = rv_sales_terr.efex_lupdt,
              last_rec_flg = 'N'
            WHERE
              efex_sales_terr_id = rv_sales_terr.efex_sales_terr_id
              AND last_rec_flg = 'Y';

            v_update_count := v_update_count + SQL%ROWCOUNT;
         END IF;

         -- Get the new sales_terr_code here, so we can use it to update
         -- the efex_cust_dtl_dim.sales_terr_code as well.
         OPEN csr_sales_terr_code;
         FETCH csr_sales_terr_code INTO v_new_sales_terr_code;
         CLOSE csr_sales_terr_code;

         INSERT INTO efex_sales_terr_dim
           (
            sales_terr_code,
            sales_terr_mgr_id,
            efex_sales_terr_id,
            sales_terr_name,
            efex_sales_area_id,
            sales_area_name,
            efex_area_mgr_id,
            area_mgr_name,
            efex_sales_regn_id,
            sales_regn_name,
            efex_regn_mgr_id,
            regn_mgr_name,
            efex_sgmnt_id,
            efex_bus_unit_id,
            eff_start_date,
            eff_end_date,
            last_rec_flg,
            status
           )
         VALUES
          (
           v_new_sales_terr_code,
           rv_sales_terr.sales_terr_mgr_id,
           rv_sales_terr.efex_sales_terr_id,
           rv_sales_terr.sales_terr_name,
           rv_sales_terr.efex_sales_area_id,
           rv_sales_terr.sales_area_name,
           rv_sales_terr.efex_area_mgr_id,
           rv_sales_terr.area_mgr_name,
           rv_sales_terr.efex_sales_regn_id,
           rv_sales_terr.sales_regn_name,
           rv_sales_terr.efex_regn_mgr_id,
           rv_sales_terr.regn_mgr_name,
           rv_sales_terr.efex_sgmnt_id,
           rv_sales_terr.efex_bus_unit_id,
           rv_sales_terr.efex_lupdt,
           DECODE(rv_sales_terr.status, 'A', c_future_date, rv_sales_terr.efex_lupdt),
           'Y',
           rv_sales_terr.status
          );

        v_insert_count := v_insert_count + SQL%ROWCOUNT;

        -- Not a new sales territory.
        IF v_old_sales_terr_code IS NOT NULL THEN

           -- Update the sales_terr_code in efex_cust_dtl_dim table to reflex the changes.
           UPDATE efex_cust_dtl_dim
           SET
             sales_terr_code = v_new_sales_terr_code
           WHERE
             efex_sales_terr_id = rv_sales_terr.efex_sales_terr_id
             AND last_rec_flg = 'Y';

           v_cust_update_count := v_cust_update_count + SQL%ROWCOUNT;

           write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 3, 'Number of efex_cust_dtl_dim updated [' || v_cust_update_count ||
                     '] for efex_sales_terr_id [' || rv_sales_terr.efex_sales_terr_id || '].');

           -- Update the lupdt column in efex_target table to aggregate using the new sales territory record.
           UPDATE efex_target
           SET
             target_lupdt = sysdate
           WHERE
             sales_terr_id = rv_sales_terr.efex_sales_terr_id;

           v_target_update_count := v_target_update_count + SQL%ROWCOUNT;

           write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 3, 'Number of efex_target updated [' || v_target_update_count ||
                     '] for efex_sales_terr_id [' || rv_sales_terr.efex_sales_terr_id || '].');

           -- Only create new distribution transaction if the sales territory still active
           IF rv_sales_terr.status = 'A' THEN
               -- Insert a new distribution transaction record.
              INSERT INTO efex_distbn_xactn_dim
                (
                  distbn_xactn_code,
                  company_code,
                  distbn_date,
                  distbn_yyyyppw,
                  distbn_yyyypp,
                  distbn_code,
                  cust_dtl_code,
                  efex_cust_id,
                  sales_terr_code,
                  efex_sales_terr_id,
                  efex_sgmnt_id,
                  efex_bus_unit_id,
                  efex_matl_id,
                  efex_matl_subgrp_id,
                  efex_matl_grp_id,
                  efex_assoc_id,
                  efex_range_id,
                  rqd_flg_code,
                  ranged_flg_code,
                  outofdate_stock_flg_code,
                  gap_flg_code,
                  facing_qty,
                  display_qty,
                  inv_qty,
                  matl_price,
                  gap,
                  gap_new,
                  gap_closed,
                  rqd,
                  ranged,
                  outofstock,
                  eff_start_date,
                  eff_end_date,
                  last_rec_flg,
                  status
                 )
               SELECT
                 EFEX_DISTBN_XACTN_DIM_SEQ.nextval,
                 t1.company_code,
                 rv_sales_terr.efex_lupdt,
                 t2.mars_week,
                 t2.mars_period,
                 t1.distbn_code,
                 t1.cust_dtl_code,
                 t1.efex_cust_id,
                 v_new_sales_terr_code,
                 t1.efex_sales_terr_id,
                 rv_sales_terr.efex_sgmnt_id,
                 t1.efex_bus_unit_id,
                 t1.efex_matl_id,
                 t3.efex_matl_subgrp_id,
                 t3.efex_matl_grp_id,
                 rv_sales_terr.sales_terr_mgr_id,
                 t1.efex_range_id,
                 t1.rqd_flg_code,
                 t1.ranged_flg_code,
                 t1.outofdate_stock_flg_code,
                 t1.gap_flg_code,
                 t1.facing_qty,
                 t1.display_qty,
                 t1.inv_qty,
                 t1.matl_price,
                 t1.gap,
                 t1.gap_new,
                 t1.gap_closed,
                 t1.rqd,
                 t1.ranged,
                 t1.outofstock,
                 rv_sales_terr.efex_lupdt,
                 c_future_date,
                 'Y',
                 t1.status
               FROM
                 efex_distbn_xactn_dim t1,
                 mars_date_dim t2,
                 efex_matl_matl_subgrp_dim t3
               WHERE
                 t1.efex_sales_terr_id = rv_sales_terr.efex_sales_terr_id
                 AND sales_terr_code = v_old_sales_terr_code
                 AND t1.last_rec_flg = 'Y'    -- for all active distribution
                 AND t1.status = 'A'
                 AND t1.efex_matl_id = t3.efex_matl_id   -- with active subgroup assigment
                 AND t3.efex_sgmnt_id = rv_sales_terr.efex_sgmnt_id
                 AND t3.status = 'A'
                 AND NOT EXISTS (SELECT *
                                FROM efex_distbn t3
                                WHERE t1.efex_cust_id = t3.efex_cust_id
                                  AND t1.efex_matl_id = t3.efex_matl_id
                                  AND TRUNC(t3.distbn_lupdt) = i_aggregation_date)
                 AND EXISTS (SELECT *                 -- for active customer only
                             FROM efex_cust t4
                             WHERE t1.efex_cust_id = t4.efex_cust_id
                               AND t4.status = 'A'
                               AND t4.valdtn_status = ods_constants.valdtn_valid )
                 AND rv_sales_terr.efex_lupdt = t2.calendar_date;

               v_rec_count := SQL%ROWCOUNT;

              write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 3, 'Number of efex_distbn_xactn_dim INSERTED [' || v_rec_count ||
                        '] for sales_terr_id/new sales_terr_code [' || rv_sales_terr.efex_sales_terr_id || '/' || v_new_sales_terr_code || '].');

              -- Now close the records that we have created a new one.
              UPDATE
                efex_distbn_xactn_dim t1
              SET
                last_rec_flg = 'N',
                eff_end_date = rv_sales_terr.efex_lupdt
              WHERE
                efex_sales_terr_id = rv_sales_terr.efex_sales_terr_id
                AND sales_terr_code = v_old_sales_terr_code
                AND last_rec_flg = 'Y'
                AND t1.status = 'A'
                AND EXISTS (SELECT *
                            FROM efex_distbn_xactn_dim t3
                            WHERE t1.efex_cust_id = t3.efex_cust_id
                              AND t1.efex_matl_id = t3.efex_matl_id
                              AND t1.efex_sales_terr_id = t3.efex_sales_terr_id
                              AND t3.sales_terr_code = v_new_sales_terr_code);


              v_rec_count := SQL%ROWCOUNT;

              write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 3, 'Number of efex_distbn_xactn_dim UPDATED [' || v_rec_count ||
                        '] for sales_terr_id [' || rv_sales_terr.efex_sales_terr_id || '].');

              -- sales territory assign to different sgmnt then
              IF v_old_efex_sgmnt_id <> rv_sales_terr.efex_sgmnt_id THEN
                 -- Trigger the ODS efex_distbn if any item segment doesn't have active subgroup assignment.
                 UPDATE
                   efex_distbn t1
                 SET
                   valdtn_status = ods_constants.valdtn_unchecked,
                   efex_lupdt = rv_sales_terr.efex_lupdt,
                   sgmnt_id = rv_sales_terr.efex_sgmnt_id
                 WHERE
                   sales_terr_id = rv_sales_terr.efex_sales_terr_id
                   AND sgmnt_id = v_old_efex_sgmnt_id
                   AND status = 'A'
                   AND NOT EXISTS (SELECT *
                                   FROM
                                     efex_matl_matl_subgrp t2
                                   WHERE
                                     t2.efex_matl_id = t1.efex_matl_id
                                     AND t2.sgmnt_id = rv_sales_terr.efex_sgmnt_id
                                     AND t2.status = 'A'
                                     AND t2.valdtn_status = ods_constants.valdtn_valid);
              END IF;


             -- Insert a new distribution transaction record.
             INSERT INTO efex_tot_distbn_xactn_dim
               (
               distbn_xactn_code,
               distbn_xactn_date,
               cust_dtl_code,
               efex_matl_grp_id,
               company_code,
               distbn_code,
               efex_cust_id,
               sales_terr_code,
               efex_sales_terr_id,
               efex_sgmnt_id,
               efex_bus_unit_id,
               efex_assoc_id,
               tot_facings,
               eff_start_date,
               eff_end_date,
               last_rec_flg,
               status
               )
             SELECT
               EFEX_TOT_DISTBN_XACTN_DIM_SEQ.nextval,
               rv_sales_terr.efex_lupdt,
               t1.cust_dtl_code,
               t1.efex_matl_grp_id,
               t1.company_code,
               t1.distbn_code,
               t1.efex_cust_id,
               v_new_sales_terr_code,
               t1.efex_sales_terr_id,
               rv_sales_terr.efex_sgmnt_id,
               t1.efex_bus_unit_id,
               rv_sales_terr.sales_terr_mgr_id,
               t1.tot_facings,
               rv_sales_terr.efex_lupdt,
               c_future_date,
               'Y',
               t1.status
             FROM
               efex_tot_distbn_xactn_dim t1
             WHERE
               t1.efex_sales_terr_id = rv_sales_terr.efex_sales_terr_id
               AND t1.last_rec_flg = 'Y'
               AND NOT EXISTS (SELECT *
                               FROM efex_distbn_tot t3
                               WHERE t1.efex_cust_id = t3.efex_cust_id
                                 AND t1.efex_matl_grp_id = t3.matl_grp_id
                                 AND    t1.efex_sales_terr_id = t3.sales_terr_id
                                 AND TRUNC(t3.distbn_tot_lupdt) = i_aggregation_date)
               AND EXISTS (SELECT *
                           FROM efex_cust t4
                           WHERE t1.efex_cust_id = t4.efex_cust_id
                             AND t4.status = 'A' );

             v_rec_count := SQL%ROWCOUNT;

             write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 3, 'Number of efex_tot_distbn_xactn_dim INSERTED [' || v_rec_count ||
                        '] for sales_terr_id/new sales_terr_code [' || rv_sales_terr.efex_sales_terr_id || '/' || v_new_sales_terr_code || '].');

             UPDATE
               efex_tot_distbn_xactn_dim t1
             SET
               last_rec_flg = 'N',
               eff_end_date = rv_sales_terr.efex_lupdt
             WHERE
               efex_sales_terr_id = rv_sales_terr.efex_sales_terr_id
               AND sales_terr_code <> v_new_sales_terr_code
               AND last_rec_flg = 'Y'
               AND NOT EXISTS (SELECT *
                               FROM efex_distbn_tot t3
                               WHERE t1.efex_cust_id = t3.efex_cust_id
                                 AND t1.efex_matl_grp_id = t3.matl_grp_id
                                 AND    t1.efex_sales_terr_id = t3.sales_terr_id
                                 AND TRUNC(t3.distbn_tot_lupdt) = i_aggregation_date)
               AND EXISTS (SELECT *
                           FROM efex_cust t4
                           WHERE t1.efex_cust_id = t4.efex_cust_id
                             AND t4.status = 'A' );

             v_rec_count := SQL%ROWCOUNT;

             COMMIT;

             write_log(ods_constants.data_type_efex_sales_terr, 'N/A', i_log_level + 3, 'Number of efex_tot_distbn_xactn_dim UPDATED [' || v_rec_count ||
                        '] for sales_terr_id [' || rv_sales_terr.efex_sales_terr_id || '].');
          END IF; -- active sales territory
        END IF;  -- new sales_terr_code created for existing sales territory
      END IF;

      -- Update the latest record only.
      IF v_insert_flg = FALSE AND v_update_flg = TRUE THEN
         UPDATE
           efex_sales_terr_dim
         SET
           sales_terr_name = rv_sales_terr.sales_terr_name,
           sales_area_name = rv_sales_terr.sales_area_name,
           area_mgr_name = rv_sales_terr.area_mgr_name,
           sales_regn_name = rv_sales_terr.sales_regn_name,
           regn_mgr_name = rv_sales_terr.regn_mgr_name,
           status = rv_sales_terr.status,
           eff_end_date = CASE WHEN (rv_sales_terr.status = 'X' AND eff_end_date = c_future_date) THEN rv_sales_terr.efex_lupdt
                               WHEN (rv_sales_terr.status = 'A') THEN c_future_date ELSE eff_end_date END
         WHERE
           efex_sales_terr_id = rv_sales_terr.efex_sales_terr_id
           AND last_rec_flg = 'Y';

         v_update_count := v_update_count + SQL%ROWCOUNT;

      END IF;
     EXCEPTION

        WHEN OTHERS THEN
         ROLLBACK;
         write_log(ods_constants.data_type_efex_cust,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_SALES_TERR_FLATTENING: sales_terr_id [' || rv_sales_terr.efex_sales_terr_id ||
             '], Error: ' || SUBSTR(SQLERRM, 1, 512));
         RAISE e_processing_error;

     END;

    END LOOP;

    COMMIT;

    write_log(ods_constants.data_type_efex_sales_terr,'N/A',i_log_level+1,
             'ins/upd/cust_upd/target_upd counts [' || v_insert_count || '/' || v_update_count || '/'  || v_cust_update_count || '/'  || v_target_update_count || ']');
  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN e_processing_error THEN
    ROLLBACK;
    RETURN constants.error;

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_sales_terr,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_SALES_TERRL_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_sales_terr_flattening;

FUNCTION efex_cust_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count             PLS_INTEGER := 0;
  v_efex_cust_id          efex_cust.efex_cust_id%TYPE;
  v_cust_code             cust_dim.cust_code%TYPE;
  v_update_flg            BOOLEAN := FALSE;
  v_insert_flg            BOOLEAN := FALSE;
  v_skip_flg              BOOLEAN := FALSE;

  v_update_count          PLS_INTEGER := 0;
  v_insert_count          PLS_INTEGER := 0;
  v_cust_dim_insert_count PLS_INTEGER := 0;
  v_cust_dim_update_count PLS_INTEGER := 0;

  v_last_call_date        efex_cust_dtl_dim.last_call_date%TYPE;
  v_last_order_date       efex_cust_dtl_dim.last_order_date%TYPE;
  v_last_order_id         efex_cust_dtl_dim.last_order_id%TYPE;
  v_last_status           efex_cust_dtl_dim.status%TYPE;
  v_last_active_flg       efex_cust_dtl_dim.active_flg%TYPE;

  v_old_cust_dtl_code     efex_cust_dtl_dim.cust_dtl_code%TYPE;
  v_new_cust_dtl_code     efex_cust_dtl_dim.cust_dtl_code%TYPE;


  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether any efex customer modified yesterday.
  CURSOR csr_cust_count IS
    SELECT count(*) AS rec_count
    FROM efex_cust
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(cust_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  CURSOR csr_efex_cust IS
    SELECT
      t1.efex_cust_id,
      t1.cust_code,
      t1.cust_name,
      t1.addr_1,
      t1.addr_2,
      t1.postal_addr,
      t1.city,
      t1.state,
      t1.postcode,
      t1.phone,
      t1.distbr_flg,
      t1.outlet_flg,
      t1.active_flg,
      NVL(t1.sales_terr_id, -1)                                             AS efex_sales_terr_id,
      NVL(t1.range_id, ods_constants.efex_def_range_id)                     AS range_id,
      NVL(t1.cust_visit_freq_id, ods_constants.efex_def_cust_visit_freq_id) AS cust_visit_freq_id,
      NVL(t1.cust_visit_freq, 0)                                            AS cust_visit_freq,
      NVL(t1.cust_type_id, ods_constants.efex_def_cust_type_id)             AS cust_type_id,
      NVL(t1.affltn_id, ods_constants.efex_def_affltn_id)                   AS affltn_id,
      t1.distbr_id,
      NVL(t1.cust_grade_id, ods_constants.efex_def_cust_grade_id)           AS cust_grade_id,
      NVL(t1.cust_grade, ods_constants.efex_def_cust_grade)                 AS cust_grade,
      t1.payee_name,
      t1.merch_name,
      t1.merch_code,
      t1.vendor_code,
      t1.abn,
      t1.meals_day,
      t1.lead_time,
      t1.disc_pct,
      t1.corporate_flg,
      TRUNC(t1.efex_lupdt) AS efex_lupdt,
      t1.status,
      t2.sales_terr_code,
      t2.sales_terr_mgr_id,
      t2.efex_sgmnt_id
    FROM
      efex_cust t1,
      efex_sales_terr_dim t2
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(cust_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id
      AND t1.sales_terr_id = t2.efex_sales_terr_id (+) -- Distributor doesn't has assigned sales territory
      AND t2.last_rec_flg (+) = 'Y';
  rv_efex_cust csr_efex_cust%ROWTYPE;

  -- Select the latest slowly changed fields record from dim for the same efex_cust_id
  CURSOR csr_last_cust_dtl IS
    SELECT
      cust_dtl_code,
      efex_cust_id,
      NVL(t1.efex_sales_terr_id, -1)                                          AS efex_sales_terr_id,
      NVL(efex_range_id, ods_constants.efex_def_range_id)                     AS efex_range_id,
      NVL(grade, ods_constants.efex_def_cust_grade)                           AS grade,
      last_call_date, -- carry this information to new slowly change record
      last_order_date,
      last_order_id,
      t1.status AS last_status, -- pick the last ststus
      active_flg AS last_active_flg,
      t2.efex_sgmnt_id
    FROM
      efex_cust_dtl_dim t1,
      efex_sales_terr_dim t2
    WHERE
      t2.sales_terr_code = t1.sales_terr_code
      AND efex_cust_id = v_efex_cust_id
      AND t1.last_rec_flg = 'Y';
  rv_last_cust_dtl csr_last_cust_dtl%ROWTYPE;

  CURSOR csr_cust_dim IS
    SELECT
      cust_code
    FROM
      cust_dim
    WHERE
      cust_code = v_cust_code;
  rv_cust_dim csr_cust_dim%ROWTYPE;

  CURSOR csr_cust_dtl_code IS
    SELECT
      efex_cust_dtl_dim_seq.nextval as cust_dtl_code
    FROM
      dual;

BEGIN

  -- Starting efex_cust flattening.
  write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 1, 'Starting EFEX_CUST_DTL_DIM flattening (apply slowly change).');

  -- Fetch the record from the csr_cust_count cursor.
  OPEN  csr_cust_count;
  FETCH csr_cust_count INTO v_rec_count;
  CLOSE csr_cust_count;

  -- If any efex sales territory records modified yesterday
  write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex customer received yesterday.');

  IF v_rec_count > 0 THEN

    FOR rv_efex_cust IN csr_efex_cust LOOP

     BEGIN
      -- Now pass cursor results into variables.
      v_efex_cust_id :=  rv_efex_cust.efex_cust_id;
      v_cust_code := rv_efex_cust.cust_code;
      v_last_call_date := NULL;
      v_last_order_date := NULL;
      v_last_order_id := NULL;
      v_skip_flg := FALSE;
      v_update_flg := FALSE;
      v_insert_flg := FALSE;

      v_old_cust_dtl_code := NULL;
      v_last_status := NULL;
      v_last_active_flg := NULL;

      IF rv_efex_cust.cust_code IS NULL THEN
        v_cust_code := 'EFX' || TO_CHAR(rv_efex_cust.efex_cust_id);
      ELSE  -- GRD customer
        -- Format cust_code to SAP format
        v_cust_code := format_cust_code(rv_efex_cust.cust_code,2);
      END IF;

      OPEN csr_cust_dim;
      FETCH csr_cust_dim INTO rv_cust_dim;

      BEGIN

        -- New outlet or distributor customer, then add to cust_dim
        IF csr_cust_dim%NOTFOUND AND  rv_efex_cust.cust_code IS NULL THEN

            INSERT INTO cust_dim
              (
               cust_code,
               outlet_flg,
               cust_name_en,
               addr_city_en,
               addr_postl_code_en,
               addr_regn_code_en,
               cntry_code_en,
               pos_place_code,
               pos_place_desc,
               pos_format_code,
               pos_format_desc,
               pos_format_grpg_code,
               multi_mkt_acct_code,
               banner_code,
               cust_buying_grp_code,
               cntry_regn_code,
               cntry_regn_desc,
               distbn_route_code,
               prim_route_to_cnsmr_code,
               prim_route_to_cnsmr_desc,
               fundr_sales_terr_code,
               fundr_sales_terr_desc,
               fundr_grp_type_code,
               fundr_grp_type_desc
              )
            VALUES
              (
                v_cust_code,                   -- cust_code
                rv_efex_cust.outlet_flg,       -- outlet_flg
                rv_efex_cust.cust_name,        -- cust_name_en
                rv_efex_cust.city,             -- addr_city_en
                rv_efex_cust.postcode,         -- addr_postl_code_en
                TRIM(rv_efex_cust.state),      -- addr_regn_code_en
                'AU',                          -- cntry_code_en
                '000',                         -- pos_place_code
                'Not Applicable',              -- pos_place_desc
                '00',                          -- pos_format_code
                'Not Applicable',              -- pos_format_desc
                '00',                          -- pos_format_grpg_code
                '00000',                       -- multi_mkt_acct_code
                '00000',                       -- banner_code
                '00000',                       -- cust_buying_grp_code
                '001',                         -- cntry_regn_code
                'Asia',                        -- cntry_regn_desc
                '000',                         -- distbn_route_code
                '000',                         -- prim_route_to_cnsmr_code
                'Not Applicable',              -- prim_route_to_cnsmr_desc
                '00',                          -- fundr_sales_terr_code
                'Not Applicable',              -- fundr_sales_terr_desc
                '000',                         -- fundr_grp_type_code
                'Not Applicable'               -- fundr_grp_type_desc
               );

             v_cust_dim_insert_count := v_cust_dim_insert_count + SQL%ROWCOUNT;

          -- Found outlet or distributor customer from cust_dim
          ELSIF csr_cust_dim%FOUND AND rv_efex_cust.cust_code IS NULL THEN

            UPDATE cust_dim
            SET
              cust_name_en = rv_efex_cust.cust_name,
              addr_city_en = rv_efex_cust.city,
              addr_postl_code_en = rv_efex_cust.postcode,
              addr_regn_code_en = TRIM(rv_efex_cust.state)
            WHERE
              cust_code = v_cust_code;

            v_cust_dim_update_count := v_cust_dim_update_count + SQL%ROWCOUNT;

          END IF;
          CLOSE csr_cust_dim;

          EXCEPTION
           WHEN OTHERS THEN
             write_log(ods_constants.data_type_efex_cust,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_CUST_FLATTENING(CUST_DIM): cust_id [' || rv_efex_cust.efex_cust_id ||
             '], Error: ' || SUBSTR(SQLERRM, 1, 512));
           RAISE e_processing_error;

          END;

          -- Check any efex customer detail record for this customer
          OPEN csr_last_cust_dtl;
          FETCH csr_last_cust_dtl INTO rv_last_cust_dtl;

          IF csr_last_cust_dtl%NOTFOUND THEN

             v_insert_flg := TRUE;
             v_update_flg := FALSE;
          ELSE
             -- Find the existing record, check whether slowly change process required
             IF rv_efex_cust.cust_grade <> rv_last_cust_dtl.grade OR
                rv_efex_cust.efex_sales_terr_id <> rv_last_cust_dtl.efex_sales_terr_id OR
                rv_efex_cust.range_id <> rv_last_cust_dtl.efex_range_id OR
                (rv_last_cust_dtl.last_status = 'X' AND rv_efex_cust.status = 'A')  THEN  -- reopen deleted customer
                v_update_flg := TRUE;
                v_insert_flg := TRUE;
                -- Carry this values to the new record
                v_last_call_date := rv_last_cust_dtl.last_call_date;
                v_last_order_date := rv_last_cust_dtl.last_order_date;
                v_last_order_id := rv_last_cust_dtl.last_order_id;
                v_old_cust_dtl_code := rv_last_cust_dtl.cust_dtl_code;
                v_last_status := rv_last_cust_dtl.last_status;
                v_last_active_flg := rv_last_cust_dtl.last_active_flg;
             ELSE
                v_update_flg := TRUE;
                v_insert_flg := FALSE;
             END IF;

          END IF;
          CLOSE csr_last_cust_dtl;

          IF v_insert_flg = TRUE THEN
             -- Put the new cust_dtl_code in a variable so we can use it to update the distribution
             OPEN csr_cust_dtl_code;
             FETCH csr_cust_dtl_code INTO v_new_cust_dtl_code;
             CLOSE csr_cust_dtl_code;

             -- Try to update the last record for the customer
             IF v_update_flg = TRUE THEN
                UPDATE efex_cust_dtl_dim
                SET
                   eff_end_date = CASE WHEN (eff_end_date = c_future_date) THEN rv_efex_cust.efex_lupdt ELSE eff_end_date END,  -- don't overwritten closed date
                   last_rec_flg = 'N'
                WHERE
                   efex_cust_id = rv_efex_cust.efex_cust_id
                   AND last_rec_flg = 'Y';

                v_update_count := v_update_count + SQL%ROWCOUNT;
             END IF;

             INSERT INTO efex_cust_dtl_dim
               (
                cust_dtl_code,
                efex_cust_id,
                cust_code,
                addr_1,
                addr_2,
                postal_addr,
                phone,
                vendor_code,
                merch_code,
                merch_name,
                payee_name,
                abn,
                meals_day,
                lead_time,
                grade,
                efex_banner_id,
                efex_cust_type_id,
                efex_sales_terr_id,
                sales_terr_code,
                efex_range_id,
                week_visit_freq,
                prd_visit_freq,
                year_visit_freq,
                visit_freq,
                disc_pct,
                corporate_flg,
                distbr_flg,
                efex_distbr_id,
                active_flg,
                eff_start_date,
                eff_end_date,
                last_rec_flg,
                status,
                last_call_date,
                last_order_date,
                last_order_id
               )
             VALUES
              (
               v_new_cust_dtl_code,
               rv_efex_cust.efex_cust_id,
               v_cust_code,
               rv_efex_cust.addr_1,
               rv_efex_cust.addr_2,
               rv_efex_cust.postal_addr,
               rv_efex_cust.phone,
               rv_efex_cust.vendor_code,
               rv_efex_cust.merch_code,
               rv_efex_cust.merch_name,
               rv_efex_cust.payee_name,
               rv_efex_cust.abn,
               rv_efex_cust.meals_day,
               rv_efex_cust.lead_time,
               rv_efex_cust.cust_grade,
               rv_efex_cust.affltn_id,
               rv_efex_cust.cust_type_id,
               DECODE(rv_efex_cust.efex_sales_terr_id, -1, NULL, rv_efex_cust.efex_sales_terr_id),
               rv_efex_cust.sales_terr_code,
               rv_efex_cust.range_id,
               DECODE(rv_efex_cust.cust_visit_freq, 0, 0, 1/rv_efex_cust.cust_visit_freq),
               DECODE(rv_efex_cust.cust_visit_freq, 0, 0, 4/rv_efex_cust.cust_visit_freq),
               DECODE(rv_efex_cust.cust_visit_freq, 0, 0, 52/rv_efex_cust.cust_visit_freq),
               rv_efex_cust.cust_visit_freq,
               rv_efex_cust.disc_pct,
               rv_efex_cust.corporate_flg,
               rv_efex_cust.distbr_flg,
               rv_efex_cust.distbr_id,
               rv_efex_cust.active_flg,
               rv_efex_cust.efex_lupdt,
               DECODE(rv_efex_cust.status, 'A', c_future_date, rv_efex_cust.efex_lupdt),
               'Y',
               rv_efex_cust.status,
               v_last_call_date,
               v_last_order_date,
               v_last_order_id
              );

             v_insert_count := v_insert_count + SQL%ROWCOUNT;

             -- Only create new distribution transaction for active and not deleted customer
             IF v_old_cust_dtl_code IS NOT NULL AND
                rv_efex_cust.status = 'A'  AND  v_last_status = 'A'  THEN      -- don't do it if re-open deleted customer
                -- Insert a new distribution transaction record.
               INSERT INTO efex_distbn_xactn_dim
                 (
                   distbn_xactn_code,
                   company_code,
                   distbn_date,
                   distbn_yyyyppw,
                   distbn_yyyypp,
                   distbn_code,
                   cust_dtl_code,
                   efex_cust_id,
                   sales_terr_code,
                   efex_sales_terr_id,
                   efex_sgmnt_id,
                   efex_bus_unit_id,
                   efex_matl_id,
                   efex_matl_subgrp_id,
                   efex_matl_grp_id,
                   efex_assoc_id,
                   efex_range_id,
                   rqd_flg_code,
                   ranged_flg_code,
                   outofdate_stock_flg_code,
                   gap_flg_code,
                   facing_qty,
                   display_qty,
                   inv_qty,
                   matl_price,
                   gap,
                   gap_new,
                   gap_closed,
                   rqd,
                   ranged,
                   outofstock,
                   eff_start_date,
                   eff_end_date,
                   last_rec_flg,
                   status
                  )
                SELECT
                  EFEX_DISTBN_XACTN_DIM_SEQ.nextval,
                  t1.company_code,
                  rv_efex_cust.efex_lupdt,
                  t2.mars_week,
                  t2.mars_period,
                  t1.distbn_code,
                  v_new_cust_dtl_code,
                  t1.efex_cust_id,
                  rv_efex_cust.sales_terr_code,
                  rv_efex_cust.efex_sales_terr_id,
                  rv_efex_cust.efex_sgmnt_id,
                  t1.efex_bus_unit_id,
                  t1.efex_matl_id,
                  t4.efex_matl_subgrp_id,
                  t4.efex_matl_grp_id,
                  rv_efex_cust.sales_terr_mgr_id,
                  t1.efex_range_id,
                  t1.rqd_flg_code,
                  t1.ranged_flg_code,
                  t1.outofdate_stock_flg_code,
                  t1.gap_flg_code,
                  t1.facing_qty,
                  t1.display_qty,
                  t1.inv_qty,
                  t1.matl_price,
                  t1.gap,
                  t1.gap_new,
                  t1.gap_closed,
                  t1.rqd,
                  t1.ranged,
                  t1.outofstock,
                  rv_efex_cust.efex_lupdt,
                  c_future_date,
                  'Y',
                  t1.status
                FROM
                  efex_distbn_xactn_dim t1,
                  mars_date_dim t2,
                  efex_matl_matl_subgrp_dim t4
                WHERE
                  t1.efex_cust_id = rv_efex_cust.efex_cust_id
                  AND t1.last_rec_flg = 'Y'    -- for all active distribution
                  AND t1.status = 'A'
                  AND t4.efex_matl_id = t1.efex_matl_id
                  AND t4.efex_sgmnt_id = rv_efex_cust.efex_sgmnt_id
                  AND t4.status = 'A'
                  AND NOT EXISTS (SELECT *
                                  FROM efex_distbn t3
                                  WHERE t1.efex_cust_id = t3.efex_cust_id
                                    AND t1.efex_matl_id = t3.efex_matl_id
                                    AND TRUNC(t3.distbn_lupdt) = i_aggregation_date)
                  AND rv_efex_cust.efex_lupdt = t2.calendar_date;

               v_rec_count := SQL%ROWCOUNT;

               write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_distbn_xactn_dim INSERTED [' || v_rec_count ||
                         '] for efex_cust_id/cust_dtl_code [' || rv_efex_cust.efex_cust_id || '/' || v_new_cust_dtl_code || '].');

               -- update previous xactn where new xactn created with new cust_dtl_code
               UPDATE
                 efex_distbn_xactn_dim t1
               SET
                 last_rec_flg = 'N',
                 eff_end_date = rv_efex_cust.efex_lupdt
               WHERE
                 efex_cust_id = rv_efex_cust.efex_cust_id
                 AND cust_dtl_code = v_old_cust_dtl_code
                 AND last_rec_flg = 'Y'
                 AND status = 'A'
                 AND EXISTS (SELECT *
                                 FROM efex_distbn_xactn_dim t3
                                 WHERE t1.efex_cust_id = t3.efex_cust_id
                                   AND t1.efex_matl_id = t3.efex_matl_id
                                   AND t3.cust_dtl_code = v_new_cust_dtl_code);

               v_rec_count := SQL%ROWCOUNT;

               write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_distbn_xactn_dim UPDATED [' || v_rec_count ||
                         '] for efex_cust_id [' || rv_efex_cust.efex_cust_id || '].');

               -- Delete those duplicated creation from efex_sales_terr_dim process for the same
               -- effective date.
               DELETE FROM
                 efex_distbn_xactn_dim
               WHERE
                 efex_cust_id = rv_efex_cust.efex_cust_id
                 AND eff_start_date = eff_end_date
                 AND eff_end_date = rv_efex_cust.efex_lupdt
                 AND last_rec_flg = 'N';

               v_rec_count := SQL%ROWCOUNT;

               write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of duplicate efex_distbn_xactn_dim DELETED [' || v_rec_count ||
                         '] for efex_cust_id [' || rv_efex_cust.efex_cust_id || '].');

               -- Trigger the ODS efex_distbn if any item segment doesn't have active subgroup assignment.
               IF rv_efex_cust.efex_sgmnt_id <> rv_last_cust_dtl.efex_sgmnt_id THEN
                  write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Customer change segment old/new [' || rv_last_cust_dtl.efex_sgmnt_id ||
                         '/' || rv_efex_cust.efex_sgmnt_id || '].');

                  UPDATE
                    efex_distbn t1
                  SET
                    valdtn_status = ods_constants.valdtn_unchecked,
                    efex_lupdt = rv_efex_cust.efex_lupdt,
                    sgmnt_id = rv_efex_cust.efex_sgmnt_id,
                    sales_terr_id = rv_efex_cust.efex_sales_terr_id
                  WHERE
                    efex_cust_id = rv_efex_cust.efex_cust_id
                    AND status = 'A'
                    AND NOT EXISTS (SELECT *
                                    FROM
                                      efex_matl_matl_subgrp t2
                                    WHERE
                                      t2.efex_matl_id = t1.efex_matl_id
                                      AND t2.sgmnt_id = rv_efex_cust.efex_sgmnt_id
                                      AND t2.status = 'A'
                                      AND t2.valdtn_status = ods_constants.valdtn_valid);

                  v_rec_count := SQL%ROWCOUNT;

                  IF v_rec_count > 0 THEN
                     write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_distbn triggered [' || v_rec_count ||
                                  '] for efex_cust_id [' || rv_efex_cust.efex_cust_id || '].');
                  END IF;

                  -- close xactn where no active subgroup assignment
                  UPDATE
                    efex_distbn_xactn_dim t1
                  SET
                    eff_end_date = rv_efex_cust.efex_lupdt,
                    status = 'X'
                  WHERE
                    efex_cust_id = rv_efex_cust.efex_cust_id
                    AND last_rec_flg = 'Y'
                    AND status = 'A'
                    AND NOT EXISTS (SELECT *
                                    FROM
                                      efex_matl_matl_subgrp t2
                                    WHERE
                                      t2.efex_matl_id = t1.efex_matl_id
                                      AND t2.sgmnt_id = rv_efex_cust.efex_sgmnt_id
                                      AND t2.status = 'A'
                                      AND t2.valdtn_status = ods_constants.valdtn_valid);

                  v_rec_count := SQL%ROWCOUNT;

                  IF v_rec_count > 0 THEN
                     write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_distbn_xactn_dim closed - NO active subgroup [' || v_rec_count ||
                                  '] for efex_cust_id [' || rv_efex_cust.efex_cust_id || '].');
                  END IF;

                  -- activative those distribution with status = A in ODS and X in DDS and has active subgroup
                  -- change sgmnt back to the segment with active item subgroup
                  UPDATE
                    efex_distbn t1
                  SET
                    efex_lupdt = rv_efex_cust.efex_lupdt,
                    sgmnt_id = rv_efex_cust.efex_sgmnt_id,
                    sales_terr_id = rv_efex_cust.efex_sales_terr_id,
                    valdtn_status = 'VALID'
                  WHERE
                    efex_cust_id = rv_efex_cust.efex_cust_id
                    AND status = 'A'
                    AND EXISTS (SELECT *
                                    FROM
                                      efex_matl_matl_subgrp t2
                                    WHERE
                                      t2.efex_matl_id = t1.efex_matl_id
                                      AND t2.sgmnt_id = rv_efex_cust.efex_sgmnt_id
                                      AND t2.status = 'A'
                                      AND t2.valdtn_status = ods_constants.valdtn_valid)
                    AND EXISTS (SELECT *
                                FROM efex_distbn_xactn_dim t3
                                WHERE t3.efex_cust_id = rv_efex_cust.efex_cust_id
                                  AND t1.efex_matl_id = t3.efex_matl_id
                                  AND status = 'X'
                                  AND last_rec_flg = 'Y');

                  v_rec_count := SQL%ROWCOUNT;

                  IF v_rec_count > 0 THEN
                     write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_distbn updated - with active subgroup and xactn closed [' || v_rec_count ||
                                  '] for efex_cust_id [' || rv_efex_cust.efex_cust_id || '].');
                  END IF;

               END IF;

               -- Insert new total distribution transaction record.
               INSERT INTO efex_tot_distbn_xactn_dim
                 (
                 distbn_xactn_code,
                 distbn_xactn_date,
                 cust_dtl_code,
                 efex_matl_grp_id,
                 company_code,
                 distbn_code,
                 efex_cust_id,
                 sales_terr_code,
                 efex_sales_terr_id,
                 efex_sgmnt_id,
                 efex_bus_unit_id,
                 efex_assoc_id,
                 tot_facings,
                 eff_start_date,
                 eff_end_date,
                 last_rec_flg,
                 status
                 )
               SELECT
                 EFEX_TOT_DISTBN_XACTN_DIM_SEQ.nextval,
                 rv_efex_cust.efex_lupdt,
                 v_new_cust_dtl_code,
                 t1.efex_matl_grp_id,
                 t1.company_code,
                 t1.distbn_code,
                 t1.efex_cust_id,
                 rv_efex_cust.sales_terr_code,
                 rv_efex_cust.efex_sales_terr_id,
                 rv_efex_cust.efex_sgmnt_id,
                 t1.efex_bus_unit_id,
                 rv_efex_cust.sales_terr_mgr_id,
                 t1.tot_facings,
                 rv_efex_cust.efex_lupdt,
                 c_future_date,
                 'Y',
                 t1.status
               FROM
                 efex_tot_distbn_xactn_dim t1
               WHERE
                 t1.efex_cust_id = rv_efex_cust.efex_cust_id
                 AND t1.last_rec_flg = 'Y'   -- for latest distribution total
                 AND NOT EXISTS (SELECT *
                                  FROM efex_distbn_tot t3
                                  WHERE t1.efex_cust_id = t3.efex_cust_id
                                    AND t1.efex_matl_grp_id = t3.matl_grp_id
                                    AND TRUNC(t3.distbn_tot_lupdt) = i_aggregation_date);


               v_rec_count := SQL%ROWCOUNT;

               write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_tot_distbn_xactn_dim INSERTED [' || v_rec_count ||
                         '] for efex_cust_id/cust_dtl_code [' || rv_efex_cust.efex_cust_id || '/' || v_new_cust_dtl_code || '].');

               UPDATE
                 efex_tot_distbn_xactn_dim t1
               SET
                 last_rec_flg = 'N',
                 eff_end_date = rv_efex_cust.efex_lupdt
               WHERE
                 efex_cust_id = rv_efex_cust.efex_cust_id
                 AND cust_dtl_code <> v_new_cust_dtl_code
                 AND last_rec_flg = 'Y'
                 AND NOT EXISTS (SELECT *
                                  FROM efex_distbn_tot t3
                                  WHERE t1.efex_cust_id = t3.efex_cust_id
                                    AND t1.efex_matl_grp_id = t3.matl_grp_id
                                    AND TRUNC(t3.distbn_tot_lupdt) = i_aggregation_date);


               v_rec_count := SQL%ROWCOUNT;

               write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_tot_distbn_xactn_dim UPDATED [' || v_rec_count ||
                         '] for efex_cust_id [' || rv_efex_cust.efex_cust_id || '].');

               -- Delete those duplicated creation from efex_sales_terr_dim process for the same
               -- effective date.
               DELETE FROM
                 efex_tot_distbn_xactn_dim
               WHERE
                 efex_cust_id = rv_efex_cust.efex_cust_id
                 AND eff_start_date = eff_end_date
                 AND eff_end_date = rv_efex_cust.efex_lupdt
                 AND last_rec_flg = 'N';

               v_rec_count := SQL%ROWCOUNT;

               COMMIT;

               write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of duplicate efex_tot_distbn_xactn_dim DELETED [' || v_rec_count ||
                         '] for efex_cust_id [' || rv_efex_cust.efex_cust_id || '].');

             END IF;  -- not a new customer

          END IF;

          -- Update the latest record without create new record.
          IF v_insert_flg = FALSE AND v_update_flg = TRUE THEN
              UPDATE
                efex_cust_dtl_dim
              SET
                cust_code = v_cust_code,
                addr_1 = rv_efex_cust.addr_1,
                addr_2 = rv_efex_cust.addr_2,
                postal_addr = rv_efex_cust.postal_addr,
                phone = rv_efex_cust.phone,
                vendor_code = rv_efex_cust.vendor_code,
                merch_code = rv_efex_cust.merch_code,
                merch_name = rv_efex_cust.merch_name,
                payee_name = rv_efex_cust.payee_name,
                abn = rv_efex_cust.abn,
                meals_day = rv_efex_cust.meals_day,
                lead_time = rv_efex_cust.lead_time,
                efex_banner_id = rv_efex_cust.affltn_id,
                efex_cust_type_id = rv_efex_cust.cust_type_id,
                week_visit_freq = CASE WHEN (rv_efex_cust.cust_visit_freq IS NULL OR rv_efex_cust.cust_visit_freq = 0) THEN 0 ELSE 1/rv_efex_cust.cust_visit_freq END,
                prd_visit_freq = CASE WHEN (rv_efex_cust.cust_visit_freq IS NULL OR rv_efex_cust.cust_visit_freq = 0) THEN 0 ELSE 4/rv_efex_cust.cust_visit_freq END,
                year_visit_freq = CASE WHEN (rv_efex_cust.cust_visit_freq IS NULL OR rv_efex_cust.cust_visit_freq = 0) THEN 0 ELSE 52/rv_efex_cust.cust_visit_freq END,
                visit_freq = rv_efex_cust.cust_visit_freq,
                disc_pct  = rv_efex_cust.disc_pct,
                corporate_flg = rv_efex_cust.corporate_flg,
                distbr_flg  = rv_efex_cust.distbr_flg,
                efex_distbr_id = rv_efex_cust.distbr_id,
                active_flg = rv_efex_cust.active_flg,
                status = rv_efex_cust.status,
                eff_end_date = CASE WHEN (rv_efex_cust.status = 'X' AND eff_end_date = c_future_date) THEN rv_efex_cust.efex_lupdt
                                    WHEN (rv_efex_cust.status = 'A') THEN c_future_date ELSE eff_end_date END
             WHERE
               efex_cust_id = rv_efex_cust.efex_cust_id
               AND last_rec_flg = 'Y';

             v_update_count := v_update_count + SQL%ROWCOUNT;

          END IF;

          -- When customer delete, close and delete the distribution and distribution total
          IF rv_efex_cust.status = 'X' AND  v_last_status = 'A' THEN  -- change from A to X only
             UPDATE efex_distbn_dim
             SET status = 'X'
             WHERE efex_cust_id = rv_efex_cust.efex_cust_id
               AND status = 'A';

             v_rec_count := SQL%ROWCOUNT;

             write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_distbn_dim status set to X [' || v_rec_count ||
                         '] for deleted customer id [' || rv_efex_cust.efex_cust_id || '].');

             UPDATE efex_distbn_xactn_dim
             SET
               status = 'X',
               eff_end_date = rv_efex_cust.efex_lupdt
             WHERE
               efex_cust_id = rv_efex_cust.efex_cust_id
               AND last_rec_flg = 'Y'
               AND status = 'A';

             v_rec_count := SQL%ROWCOUNT;

             write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_distbn_xactn_dim closed [' || v_rec_count ||
                         '] for deleted customer id [' || rv_efex_cust.efex_cust_id || '].');

             UPDATE efex_tot_distbn_dim
             SET status = 'X'
             WHERE efex_cust_id = rv_efex_cust.efex_cust_id
               AND status = 'A';

             v_rec_count := SQL%ROWCOUNT;

             write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_tot_distbn_dim status set to X [' || v_rec_count ||
                         '] for deleted customer id [' || rv_efex_cust.efex_cust_id || '].');

             UPDATE efex_tot_distbn_xactn_dim
             SET
               status = 'X',
               eff_end_date = rv_efex_cust.efex_lupdt
             WHERE
               efex_cust_id = rv_efex_cust.efex_cust_id
               AND last_rec_flg = 'Y'
               AND status = 'A';

             v_rec_count := SQL%ROWCOUNT;

             write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 3, 'Number of efex_tot_distbn_xactn_dim closed [' || v_rec_count ||
                         '] for deleted customer id [' || rv_efex_cust.efex_cust_id || '].');

          END IF;

          -- customer re-open then activate the distribution
          IF (rv_last_cust_dtl.last_status = 'X' AND rv_efex_cust.status = 'A') THEN
             UPDATE efex_distbn
             SET efex_lupdt = rv_efex_cust.efex_lupdt
             WHERE
               efex_cust_id = rv_efex_cust.efex_cust_id
               AND status = 'A';
          END IF;

          COMMIT;
     EXCEPTION

       WHEN OTHERS THEN
         write_log(ods_constants.data_type_efex_cust,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_CUST_FLATTENING(EFEX_CUST_DTL_DIM): cust_id [' || rv_efex_cust.efex_cust_id ||
             '], Error: ' || SUBSTR(SQLERRM, 1, 512));
         RAISE e_processing_error;

     END;

    END LOOP;

    COMMIT;

    write_log(ods_constants.data_type_efex_cust,'N/A',i_log_level+1,
             'efex_cust_ins/efex_cust_upd/cust_dim_ins/cust_dim_upd counts [' || v_insert_count || '/' ||
             v_update_count || '/' || v_cust_dim_insert_count || '/' || v_cust_dim_update_count || ']');

    -- Update the distributor code now because when a customer record process, the parent customer record may not been process yet
    write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 2, 'Update the distbr_code where efex_distbr_id is not null.');

    UPDATE efex_cust_dtl_dim t1
    SET distbr_code = (SELECT cust_dtl_code
                       FROM efex_cust_dtl_dim t2
                       WHERE t1.efex_distbr_id = t2.efex_cust_id
                         AND t2.last_rec_flg = 'Y')
    WHERE
      efex_distbr_id IS NOT NULL;

    -- Update the distributor code now because when a customer record process, the parent customer record may not been process yet
    write_log(ods_constants.data_type_efex_cust, 'N/A', i_log_level + 2, 'Modified distbr_code count [' || SQL%ROWCOUNT || ']');

    COMMIT;

  END IF;
  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN e_processing_error THEN
    ROLLBACK;
    RETURN constants.error;

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_cust,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.efex_CUST_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_cust_flattening;


FUNCTION efex_matl_grp_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex material group modified yesterday.
  CURSOR csr_matl_grp_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_matl_grp
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(matl_grp_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_matl_grp flattening.
  write_log(ods_constants.data_type_efex_matl_grp, 'N/A', i_log_level + 1, 'Starting EFEX_MATL_GRP_DIM flattening.');

  -- Fetch the record from the csr_matl_grp_count cursor.
  OPEN  csr_matl_grp_count;
  FETCH csr_matl_grp_count INTO v_rec_count;
  CLOSE csr_matl_grp_count;

  -- If any efex matl group records modified yesterday.
  write_log(ods_constants.data_type_efex_matl_grp, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex material group received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_matl_grp_dim t1
     USING (SELECT
              matl_grp_id       as efex_matl_grp_id,
              matl_grp_name,
              sgmnt_id          as efex_sgmnt_id,
              bus_unit_id       as efex_bus_unit_id,
              status
            FROM
              ods.efex_matl_grp
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(matl_grp_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_matl_grp_id = t2.efex_matl_grp_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.matl_grp_name = t2.matl_grp_name,
            t1.efex_sgmnt_id = t2.efex_sgmnt_id,
            t1.efex_bus_unit_id = t2.efex_bus_unit_id,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_matl_grp_id,
             t1.matl_grp_name,
             t1.efex_sgmnt_id,
             t1.efex_bus_unit_id,
             t1.status)
          VALUES
            (t2.efex_matl_grp_id,
             t2.matl_grp_name,
             t2.efex_sgmnt_id,
             t2.efex_bus_unit_id,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_matl_grp, 'N/A', i_log_level + 2, 'EFEX_MATL_GRP_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_matl_grp,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_MATL_GRP_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_matl_grp_flattening;


FUNCTION efex_matl_subgrp_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex material subgroup modified yesterday.
  CURSOR csr_matl_subgrp_count IS
    SELECT count(*) AS rec_count
    FROM ods.efex_matl_subgrp
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(matl_subgrp_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_matl_subgrp flattening.
  write_log(ods_constants.data_type_efex_matl_subgrp, 'N/A', i_log_level + 1, 'Starting EFEX_MATL_SUBGRP_DIM flattening.');

  -- Fetch the record from the csr_matl_subgrp_count cursor.
  OPEN  csr_matl_subgrp_count;
  FETCH csr_matl_subgrp_count INTO v_rec_count;
  CLOSE csr_matl_subgrp_count;

  -- If any efex matl group records modified yesterday.
  write_log(ods_constants.data_type_efex_matl_subgrp, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex material subgroup received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_matl_subgrp_dim t1
     USING (SELECT
              matl_subgrp_id       as efex_matl_subgrp_id,
              matl_subgrp_name,
              matl_grp_id          as efex_matl_grp_id,
              status
            FROM
              ods.efex_matl_subgrp
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(matl_subgrp_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_matl_subgrp_id = t2.efex_matl_subgrp_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.matl_subgrp_name = t2.matl_subgrp_name,
            t1.efex_matl_grp_id = t2.efex_matl_grp_id,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_matl_subgrp_id,
             t1.matl_subgrp_name,
             t1.efex_matl_grp_id,
             t1.status)
          VALUES
            (t2.efex_matl_subgrp_id,
             t2.matl_subgrp_name,
             t2.efex_matl_grp_id,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_matl_subgrp, 'N/A', i_log_level + 2, 'EFEX_MATL_SUBGRP_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_matl_subgrp,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_MATL_SUBGRP_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_matl_subgrp_flattening;


FUNCTION efex_matl_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex material subgroup modified yesterday.
  CURSOR csr_matl_count IS
    SELECT count(*) AS rec_count
    FROM efex_matl
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(matl_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_matl flattening.
  write_log(ods_constants.data_type_efex_matl, 'N/A', i_log_level + 1, 'Starting EFEX_MATL_DIM flattening.');

  -- Fetch the record from the csr_matl_count cursor.
  OPEN  csr_matl_count;
  FETCH csr_matl_count INTO v_rec_count;
  CLOSE csr_matl_count;

  -- If any efex matl records modified yesterday.
  write_log(ods_constants.data_type_efex_matl, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex material received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_matl_dim t1
     USING (SELECT
              t1.efex_matl_id,
              t1.efex_matl_code,
              DECODE(t1.pos_matl_flg, 'N',t1.efex_matl_code, NULL) as matl_code,
              t1.matl_name as efex_matl_name,
              t1.rank,
              t1.cases_layer,
              t1.layers_pallet,
              t1.units_case,
              t1.unit_measure,
              t1.tdu_price,
              t1.rrp_price,
              t1.mcu_price,
              t1.rsu_price,
              t1.min_order_qty,
              t1.order_multiples,
              t1.topseller_flg,
              t1.import_flg,
              t1.pos_matl_flg  as pos_matl_flg,
              t1.status
            FROM
              efex_matl t1
            WHERE
              t1.valdtn_status = ods_constants.valdtn_valid
              AND trunc(t1.matl_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_matl_id = t2.efex_matl_id )
        WHEN MATCHED THEN
          UPDATE SET
              t1.efex_matl_code = t2.efex_matl_code,
              t1.matl_code = t2.matl_code,
              t1.efex_matl_name = t2.efex_matl_name,
              t1.rank = t2.rank,
              t1.cases_layer = t2.cases_layer,
              t1.layers_pallet = t2.layers_pallet,
              t1.units_case = t2.units_case,
              t1.unit_measure = t2.unit_measure,
              t1.tdu_price = t2.tdu_price,
              t1.rrp_price = t2.rrp_price,
              t1.mcu_price = t2.mcu_price,
              t1.rsu_price = t2.rsu_price,
              t1.min_order_qty = t2.min_order_qty,
              t1.order_multiples = t2.order_multiples,
              t1.topseller_flg = t2.topseller_flg,
              t1.import_flg = t2.import_flg,
              t1.pos_matl_flg = t2.pos_matl_flg,
              t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_matl_id,
             t1.efex_matl_code,
             t1.matl_code,
             t1.efex_matl_name,
             t1.rank,
             t1.cases_layer,
             t1.layers_pallet,
             t1.units_case,
             t1.unit_measure,
             t1.tdu_price,
             t1.rrp_price,
             t1.mcu_price,
             t1.rsu_price,
             t1.min_order_qty,
             t1.order_multiples,
             t1.topseller_flg,
             t1.import_flg,
             t1.pos_matl_flg,
             t1.status)
          VALUES
            (t2.efex_matl_id,
             t2.efex_matl_code,
             t2.matl_code,
             t2.efex_matl_name,
             t2.rank,
             t2.cases_layer,
             t2.layers_pallet,
             t2.units_case,
             t2.unit_measure,
             t2.tdu_price,
             t2.rrp_price,
             t2.mcu_price,
             t2.rsu_price,
             t2.min_order_qty,
             t2.order_multiples,
             t2.topseller_flg,
             t2.import_flg,
             t2.pos_matl_flg,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_matl, 'N/A', i_log_level + 2, 'EFEX_MATL_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_matl,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_MATL_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_matl_flattening;


FUNCTION efex_assmnt_questn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex assessment question modified yesterday.
  CURSOR csr_assmnt_questn_count IS
    SELECT count(*) AS rec_count
    FROM efex_assmnt_questn
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(assmnt_questn_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_assmnt_questn flattening.
  write_log(ods_constants.data_type_efex_ass_questn, 'N/A', i_log_level + 1, 'Starting EFEX_ASSMNT_QUESTN_DIM flattening.');

  -- Fetch the record from the csr_assmnt_questn_count cursor.
  OPEN  csr_assmnt_questn_count;
  FETCH csr_assmnt_questn_count INTO v_rec_count;
  CLOSE csr_assmnt_questn_count;

  -- If any efex assmnt_questn records modified yesterday.
  write_log(ods_constants.data_type_efex_ass_questn, 'N/A', i_log_level + 2, 'There were ['|| v_rec_count || '] efex assessment question received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_assmnt_questn_dim t1
     USING (SELECT
              t1.assmnt_id as efex_assmnt_id,
              t1.assmnt_questn,
              t1.questn_grp,
              t1.sgmnt_id      as efex_sgmnt_id,
              t1.bus_unit_id   as efex_bus_unit_id,
              t1.active_date   as eff_start_date,
              t1.inactive_date as eff_end_date,
              t1.due_date,
              t1.status
            FROM
              efex_assmnt_questn t1
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(assmnt_questn_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_assmnt_id = t2.efex_assmnt_id )
        WHEN MATCHED THEN
          UPDATE SET
              t1.assmnt_questn = t2.assmnt_questn,
              t1.questn_grp = t2.questn_grp,
              t1.efex_sgmnt_id = t2.efex_sgmnt_id,
              t1.efex_bus_unit_id = t2.efex_bus_unit_id,
              t1.eff_start_date = t2.eff_start_date,
              t1.eff_end_date = t2.eff_end_date,
              t1.due_date = t2.due_date,
              t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_assmnt_id,
             t1.assmnt_questn,
             t1.questn_grp,
             t1.efex_sgmnt_id,
             t1.efex_bus_unit_id,
             t1.eff_start_date,
             t1.eff_end_date,
             t1.due_date,
             t1.status)
          VALUES
            (t2.efex_assmnt_id,
             t2.assmnt_questn,
             t2.questn_grp,
             t2.efex_sgmnt_id,
             t2.efex_bus_unit_id,
             t2.eff_start_date,
             t2.eff_end_date,
             t2.due_date,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_ass_questn, 'N/A', i_log_level + 2, 'EFEX_ASSMNT_QUESTN_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_ass_questn,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_ASSMNT_QUESTN_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_assmnt_questn_flattening;


FUNCTION efex_range_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex range modified yesterday.
  CURSOR csr_range_count IS
    SELECT count(*) AS rec_count
    FROM efex_range
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(range_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_range flattening.
  write_log(ods_constants.data_type_efex_range, 'N/A', i_log_level + 1, 'Starting EFEX_RANGE_DIM flattening.');

  -- Fetch the record from the csr_range_count cursor.
  OPEN  csr_range_count;
  FETCH csr_range_count INTO v_rec_count;
  CLOSE csr_range_count;

  -- If any efex range records modified yesterday.
  write_log(ods_constants.data_type_efex_range, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex range received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_range_dim t1
     USING (SELECT
              range_id      as efex_range_id,
              range_name,
              status
            FROM
              efex_range
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(range_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_range_id = t2.efex_range_id )
        WHEN MATCHED THEN
          UPDATE SET
              t1.range_name = t2.range_name,
              t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_range_id,
             t1.range_name,
             t1.status)
          VALUES
            (t2.efex_range_id,
             t2.range_name,
             t2.status);

      -- number of record modified.
      write_log(ods_constants.data_type_efex_range, 'N/A', i_log_level + 2, 'EFEX_RANGE_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_range,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_RANGE_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_range_flattening;


FUNCTION efex_distbn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex distbn modified yesterday.
  CURSOR csr_distbn_count IS
    SELECT count(*) AS rec_count
    FROM efex_distbn
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(distbn_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;


BEGIN

  -- Starting efex_distbn flattening.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Starting EFEX_DISTBN_DIM flattening.');

  -- Fetch the record from the csr_distbn_count cursor.
  OPEN  csr_distbn_count;
  FETCH csr_distbn_count INTO v_rec_count;
  CLOSE csr_distbn_count;

  -- If any efex distbn records modified yesterday
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex distbribute received yesterday.');

  IF v_rec_count > 0 THEN
     -- Change the create_date to use the timestamp of the table rather than efex_lupdt, to avoid the weekly distribution
     -- gap for the invalid efex_distbn sitting in ODS for weeks
     MERGE INTO
       efex_distbn_dim t1
     USING (SELECT
              TRUNC(t1.distbn_lupdt) as create_date,
              t2.cust_dtl_code,
              t1.efex_cust_id,
              t3.sales_terr_code,
              t1.sales_terr_id   as efex_sales_terr_id,
              t1.sgmnt_id        as efex_sgmnt_id,
              t1.bus_unit_id     as efex_bus_unit_id,
              t1.efex_matl_id,
              t11.efex_matl_subgrp_id,
              t11.efex_matl_grp_id,
              t5.rqd_flg_code,
              t1.range_id               as efex_range_id,
              TRUNC(t7.target_date)     as rqd_date_instore,
              TRUNC(t1.in_store_date)   as actual_date_instore,
              t1.status
            FROM
              efex_distbn t1,
              efex_cust_dtl_dim t2,
              efex_sales_terr_dim t3,
              efex_rqd_flg_dim t5,
              efex_range_matl t7,
              efex_matl_matl_subgrp_dim t11
            WHERE
              t1.valdtn_status = ods_constants.valdtn_valid
              AND trunc(distbn_lupdt) = i_aggregation_date
              AND t1.efex_mkt_id = p_market_id
              AND t1.efex_cust_id = t2.efex_cust_id
              AND t2.last_rec_flg = 'Y'
              AND t1.sales_terr_id = t3.efex_sales_terr_id
              AND t3.last_rec_flg = 'Y'
              AND t1.rqd_flg = t5.rqd_flg
              AND t1.efex_matl_id = t7.efex_matl_id(+)
              AND t1.range_id = t7.range_id(+)
              AND t1.efex_matl_id = t11.efex_matl_id (+)
              AND t1.sgmnt_id = t11.efex_sgmnt_id (+)
              AND t11.status (+) = 'A'
            ) t2
        ON (t1.efex_cust_id = t2.efex_cust_id
            AND t1.efex_matl_id = t2.efex_matl_id )
        WHEN MATCHED THEN
          UPDATE SET
              t1.efex_matl_subgrp_id = (CASE WHEN (t2.efex_matl_subgrp_id IS NULL) THEN t1.efex_matl_subgrp_id ELSE t2.efex_matl_subgrp_id END),
              t1.efex_matl_grp_id = (CASE WHEN (t2.efex_matl_grp_id IS NULL) THEN t1.efex_matl_grp_id ELSE t2.efex_matl_grp_id END),
              t1.rqd_flg_code = t2.rqd_flg_code,
              t1.efex_range_id = t2.efex_range_id,
              t1.rqd_date_instore = t2.rqd_date_instore,
              t1.actual_date_instore = t2.actual_date_instore,
              t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.distbn_code,
              t1.company_code,
              t1.create_date,
              t1.cust_dtl_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.efex_matl_id,
              t1.efex_matl_subgrp_id,
              t1.efex_matl_grp_id,
              t1.rqd_flg_code,
              t1.efex_range_id,
              t1.rqd_date_instore,
              t1.actual_date_instore,
              t1.status
            )
          VALUES
            (
              efex_distbn_dim_seq.nextval,
              p_company_code,
              t2.create_date,
              t2.cust_dtl_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              t2.efex_matl_id,
              t2.efex_matl_subgrp_id,
              t2.efex_matl_grp_id,
              t2.rqd_flg_code,
              t2.efex_range_id,
              t2.rqd_date_instore,
              t2.actual_date_instore,
              t2.status
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 2, 'EFEX_DISTBN_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_distbn,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_DISTBN_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_distbn_flattening;

FUNCTION efex_distbn_xactn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count            NUMBER := 0;
  v_efex_cust_id         efex_distbn.efex_cust_id%TYPE;
  v_efex_matl_id         efex_distbn.efex_matl_id%TYPE;
  v_distbn_date          efex_distbn.efex_lupdt%TYPE;

  v_gap_new              efex_distbn_xactn_dim.gap_new%TYPE;
  v_gap_closed           efex_distbn_xactn_dim.gap_closed%TYPE;
  v_gap_flg              efex_gap_flg_dim.gap_flg%TYPE := 'N';
  v_new_gap_flg          efex_gap_flg_dim.new_gap_flg%TYPE := 'N';
  v_closed_gap_flg       efex_gap_flg_dim.closed_gap_flg%TYPE := 'N';

  v_upd_count            NUMBER := 0;
  v_ins_count            NUMBER := 0;
  v_del_count            PLS_INTEGER := 0;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Check whether any efex customer modified yesterday.
  CURSOR csr_distbn_count IS
    SELECT count(*) AS rec_count
    FROM efex_distbn
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(distbn_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  CURSOR csr_efex_distbn IS
    SELECT
      TRUNC(t1.distbn_lupdt) as distbn_date,  -- use the ODS timestamp to avoid the weekly gaps caused by invalid data sitting in ODS for weeks
      t2.distbn_code,
      t3.cust_dtl_code,
      t1.efex_cust_id,
      t3.sales_terr_code, -- pick from efex_cust_dtl_dim in case it was updated
      t3.efex_sales_terr_id as efex_sales_terr_id,
      t4.efex_sgmnt_id as efex_sgmnt_id,
      t1.bus_unit_id as efex_bus_unit_id,
      t1.efex_matl_id,
      t6.efex_matl_subgrp_id,
      t6.efex_matl_grp_id,
      t4.sales_terr_mgr_id as efex_assoc_id,
      t3.efex_range_id,
      t2.rqd_flg_code,
      CASE WHEN (NVL(t1.facing_qty,0) <> 0 OR NVL(t1.display_qty,0) <> 0) THEN 'Y' ELSE 'N' END as ranged_flg,
      t5.outofdate_stock_flg_code,
      -- gap_flg_code need to be retrieve later after determine the gap_new, gap_closed
      t1.facing_qty,
      t1.display_qty,
      inv_qty,
      sell_price as matl_price,
      -- NOTE: only handle petcare and snackfood
      CASE WHEN (t1.facing_qty = 0 AND t1.bus_unit_id = ods_constants.efex_bus_unit_pet AND t2.rqd_date_instore IS NULL) THEN 1
           WHEN (t1.display_qty = 0 AND t1.bus_unit_id = ods_constants.efex_bus_unit_snack AND t2.rqd_date_instore IS NULL) THEN 1
           WHEN (t1.facing_qty = 0 AND t1.bus_unit_id = ods_constants.efex_bus_unit_pet AND t2.rqd_date_instore < t1.efex_lupdt) THEN 1
           WHEN (t1.display_qty = 0 AND t1.bus_unit_id = ods_constants.efex_bus_unit_snack AND t2.rqd_date_instore < t1.efex_lupdt) THEN 1
           ELSE 0 END as gap,
      DECODE(t1.rqd_flg, 'Y', 1, 0) as rqd,
      DECODE(t1.out_of_stock_flg, 'Y', 1, 0) as outofstock,
      TRUNC(t1.efex_lupdt) as eff_start_date,
      t1.status
    FROM
      efex_distbn t1,
      efex_distbn_dim t2,
      efex_cust_dtl_dim t3,
      efex_sales_terr_dim t4,
      efex_outofdate_stock_flg_dim t5,
      efex_matl_matl_subgrp_dim t6
    WHERE
      t1.valdtn_status = ods_constants.valdtn_valid
      AND trunc(t1.distbn_lupdt) = i_aggregation_date
      AND t1.efex_mkt_id = p_market_id
      AND t1.status = 'A'
      AND t1.efex_cust_id = t2.efex_cust_id
      AND t1.efex_matl_id = t2.efex_matl_id
      AND t1.efex_cust_id = t3.efex_cust_id
      AND t3.last_rec_flg = 'Y'
      AND t3.efex_sales_terr_id = t4.efex_sales_terr_id
      AND t4.last_rec_flg = 'Y'
      AND t1.out_of_stock_flg = t5.outofstock_flg
      AND t1.out_of_date_flg = t5.outofdate_flg
      AND t1.efex_matl_id = t6.efex_matl_id
      AND t4.efex_sgmnt_id = t6.efex_sgmnt_id
      AND t6.status = 'A'
   ORDER BY
     t1.efex_cust_id,
     t1.efex_matl_id,
     t1.efex_lupdt;
  rv_efex_distbn csr_efex_distbn%ROWTYPE;

  -- Select the latest transaction gap which is used to determine the new record gap_new and gap_closed
  CURSOR csr_last_distbn_tx IS
    SELECT
      NVL(gap, 0) as gap
    FROM
      efex_distbn_xactn_dim
    WHERE
      efex_cust_id = v_efex_cust_id
      AND efex_matl_id = v_efex_matl_id
      AND distbn_date = (SELECT MAX(distbn_date)
                         FROM efex_distbn_xactn_dim
                         WHERE efex_cust_id = v_efex_cust_id
                           AND efex_matl_id = v_efex_matl_id
                           AND distbn_date < v_distbn_date);
  rv_last_distbn_tx csr_last_distbn_tx%ROWTYPE;

BEGIN
  -- Starting efex_distbn flattening.
  write_log(ods_constants.data_type_efex_distbn_tx, 'N/A', i_log_level + 1, 'Starting EFEX_DISTBN_XACTN_DIM flattening.');

  -- Fetch the record from the csr_distbn_count cursor.
  OPEN  csr_distbn_count;
  FETCH csr_distbn_count INTO v_rec_count;
  CLOSE csr_distbn_count;

  -- If any efex_distbn records modified yesterday
  write_log(ods_constants.data_type_efex_distbn_tx, 'N/A', i_log_level + 2, 'EFEX distribution received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN
    UPDATE efex_distbn_xactn_dim t1
    SET eff_end_date = (SELECT efex_lupdt
                        FROM efex_distbn t2
                        WHERE
                          t1.efex_cust_id = t2.efex_cust_id
                          AND t1.efex_matl_id = t2.efex_matl_id),
        status = 'X'
    WHERE
      EXISTS (SELECT *
              FROM efex_distbn t3
              WHERE t1.efex_cust_id = t3.efex_cust_id
                AND t1.efex_matl_id = t3.efex_matl_id
                AND t3.valdtn_status = ods_constants.valdtn_valid
                AND trunc(t3.distbn_lupdt) = i_aggregation_date
                AND t3.status = 'X')
      AND status = 'A'
      AND last_rec_flg = 'Y';


    write_log(ods_constants.data_type_efex_distbn_tx, 'N/A', i_log_level + 2, 'EFEX distribution deleted yesterday were [' || SQL%ROWCOUNT || ']');

    FOR rv_efex_distbn IN csr_efex_distbn LOOP

         v_rec_count := 0;

         -- Check whether this transaction has already been loaded into DDS or not
         SELECT COUNT(*) INTO v_rec_count
         FROM
           efex_distbn_xactn_dim
         WHERE
           efex_cust_id = rv_efex_distbn.efex_cust_id
           AND efex_matl_id = rv_efex_distbn.efex_matl_id
           AND eff_start_date = rv_efex_distbn.eff_start_date; -- compare with efex_lupdt date to avoid ODS distribution updated after aggregated to DDS

         -- Only process this record if it hasn't been loaded before
         IF v_rec_count = 0 THEN

          BEGIN
            -- Now pass cursor results into variables and set default values to variables
            v_efex_cust_id :=  rv_efex_distbn.efex_cust_id;
            v_efex_matl_id := rv_efex_distbn.efex_matl_id;
            v_distbn_date := rv_efex_distbn.distbn_date;

            v_gap_new := 0;
            v_gap_closed := 0;
            v_gap_flg := 'N';
            v_new_gap_flg := 'N';
            v_closed_gap_flg := 'N';

            -- Get the previous distribution transaction for the customer and material
            OPEN csr_last_distbn_tx;
            FETCH csr_last_distbn_tx INTO rv_last_distbn_tx;

            -- Distribution transaction found
            IF csr_last_distbn_tx%FOUND THEN

              IF rv_efex_distbn.gap = 1  AND  rv_last_distbn_tx.gap = 1 THEN
                 v_gap_new := 0;
                 v_gap_closed := 0;
              ELSIF rv_efex_distbn.gap = 1  AND  rv_last_distbn_tx.gap = 0 THEN
                 v_gap_new := 1;
                 v_gap_closed := 0;
              ELSIF rv_efex_distbn.gap = 0  AND  rv_last_distbn_tx.gap = 0 THEN
                 v_gap_new := 0;
                 v_gap_closed := 0;
              ELSIF rv_efex_distbn.gap = 0  AND  rv_last_distbn_tx.gap = 1 THEN
                 v_gap_new := 0;
                 v_gap_closed := 1;
              END IF;
            ELSE -- not exist
              IF rv_efex_distbn.gap = 1 THEN
                 v_gap_new := 1;
                 v_gap_closed := 0;
              ELSIF rv_efex_distbn.gap = 0 THEN
                 IF rv_efex_distbn.facing_qty = 1 AND rv_efex_distbn.efex_bus_unit_id = ods_constants.efex_bus_unit_pet THEN
                       v_gap_closed := 1;
                 ELSIF rv_efex_distbn.display_qty = 1 AND rv_efex_distbn.efex_bus_unit_id = ods_constants.efex_bus_unit_snack THEN
                       v_gap_closed := 1;
                 END IF;
              END IF;
            END IF;
            CLOSE csr_last_distbn_tx;

            IF rv_efex_distbn.gap = 1 THEN
               v_gap_flg := 'Y';
            END IF;
            IF v_gap_new = 1 THEN
               v_new_gap_flg := 'Y';
            END IF;
            IF v_gap_closed = 1 THEN
               v_closed_gap_flg := 'Y';
            END IF;

            -- Close the last distribution transaction record for the same customer and material
            UPDATE efex_distbn_xactn_dim
            SET
              last_rec_flg = 'N',
              eff_end_date = (CASE WHEN (eff_end_date = c_future_date) THEN rv_efex_distbn.distbn_date ELSE eff_end_date END) -- don't overwritten the eff_end_date was updated by Delete action
            WHERE
              efex_cust_id = v_efex_cust_id
              AND efex_matl_id = v_efex_matl_id
              AND last_rec_flg = 'Y';

            v_upd_count := v_upd_count + SQL%ROWCOUNT;

            -- Insert a new distribution transaction record
            INSERT INTO efex_distbn_xactn_dim
              (
               distbn_xactn_code,
               company_code,
               distbn_date,
               distbn_yyyyppw,
               distbn_yyyypp,
               distbn_code,
               cust_dtl_code,
               efex_cust_id,
               sales_terr_code,
               efex_sales_terr_id,
               efex_sgmnt_id,
               efex_bus_unit_id,
               efex_matl_id,
               efex_matl_subgrp_id,
               efex_matl_grp_id,
               efex_assoc_id,
               efex_range_id,
               rqd_flg_code,
               ranged_flg_code,
               outofdate_stock_flg_code,
               gap_flg_code,
               facing_qty,
               display_qty,
               inv_qty,
               matl_price,
               gap,
               gap_new,
               gap_closed,
               rqd,
               ranged,
               outofstock,
               eff_start_date,
               eff_end_date,
               last_rec_flg,
               status
              )
            SELECT
              EFEX_DISTBN_XACTN_DIM_SEQ.nextval,
              p_company_code,
              rv_efex_distbn.distbn_date,
              t3.mars_week,
              t3.mars_period,
              rv_efex_distbn.distbn_code,
              rv_efex_distbn.cust_dtl_code,
              rv_efex_distbn.efex_cust_id,
              rv_efex_distbn.sales_terr_code,
              rv_efex_distbn.efex_sales_terr_id,
              rv_efex_distbn.efex_sgmnt_id,
              rv_efex_distbn.efex_bus_unit_id,
              rv_efex_distbn.efex_matl_id,
              rv_efex_distbn.efex_matl_subgrp_id,
              rv_efex_distbn.efex_matl_grp_id,
              rv_efex_distbn.efex_assoc_id,
              rv_efex_distbn.efex_range_id,
              rv_efex_distbn.rqd_flg_code,
              t2.ranged_flg_code,
              rv_efex_distbn.outofdate_stock_flg_code,
              t1.gap_flg_code,
              rv_efex_distbn.facing_qty,
              rv_efex_distbn.display_qty,
              rv_efex_distbn.inv_qty,
              rv_efex_distbn.matl_price,
              rv_efex_distbn.gap,
              v_gap_new,
              v_gap_closed,
              rv_efex_distbn.rqd,
              DECODE(rv_efex_distbn.ranged_flg, 'Y', 1,0),
              rv_efex_distbn.outofstock,
              rv_efex_distbn.eff_start_date,
              c_future_date,
              'Y',
              rv_efex_distbn.status
            FROM
              efex_gap_flg_dim t1,
              efex_ranged_flg_dim t2,
              mars_date_dim t3
            WHERE
              t1.gap_flg = v_gap_flg
              AND t1.new_gap_flg = v_new_gap_flg
              AND t1.closed_gap_flg = v_closed_gap_flg
              AND t2.ranged_flg = rv_efex_distbn.ranged_flg
              AND rv_efex_distbn.distbn_date = t3.calendar_date;

            v_ins_count := v_ins_count + SQL%ROWCOUNT;
          EXCEPTION
            WHEN OTHERS THEN
              write_log(ods_constants.data_type_efex_distbn_tx, 'N/A', i_log_level + 2,
                      'SCHEDULED_EFEX_AGGREGATION.EFEX_DISTBN_XACTN_FLATTENING: cust/matl [' || rv_efex_distbn.efex_cust_id ||
                      '/'|| rv_efex_distbn.efex_matl_id || ']. Reason : ' || SUBSTR(SQLERRM, 1, 512));
              RAISE e_processing_error;

          END;
         END IF; -- Not processed yet condition

    END LOOP;

    COMMIT;
  END IF;

  write_log(ods_constants.data_type_efex_distbn_tx, 'N/A', i_log_level + 2, 'Complete EFEX_DISBTN_XACTN_DIM flattening with insert count [' ||
            v_ins_count || '], update count [' || v_upd_count || '], delete count [' || v_del_count || ']');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN e_processing_error THEN
    ROLLBACK;
    RETURN constants.error;

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_distbn_tx,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_DISTBN_XACTN_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_distbn_xactn_flattening;


FUNCTION efex_tot_distbn_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex tot distbn modified yesterday.
  CURSOR csr_tot_distbn_count IS
    SELECT count(*) AS rec_count
    FROM efex_distbn_tot
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(distbn_tot_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting efex_tot_distbn_dim flattening.
  write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 1, 'Starting EFEX_TOT_DISTBN_DIM flattening.');

  -- Fetch the record from the csr_tot_distbn_count cursor.
  OPEN  csr_tot_distbn_count;
  FETCH csr_tot_distbn_count INTO v_rec_count;
  CLOSE csr_tot_distbn_count;

  -- If any efex distbn records modified yesterday.
  write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 2, 'There were [' || v_rec_count || '] efex total distbribute received yesterday.');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_tot_distbn_dim t1
     USING (SELECT
              t2.cust_dtl_code,
              t1.matl_grp_id     as efex_matl_grp_id,
              t1.efex_cust_id,
              t3.sales_terr_code,
              t1.sales_terr_id   as efex_sales_terr_id,
              t1.sgmnt_id        as efex_sgmnt_id,
              t1.bus_unit_id     as efex_bus_unit_id,
              t1.status
            FROM
              efex_distbn_tot t1,
              efex_cust_dtl_dim t2,
              efex_sales_terr_dim t3
            WHERE
              t1.valdtn_status = ods_constants.valdtn_valid
              AND trunc(distbn_tot_lupdt) = i_aggregation_date
              AND t1.efex_mkt_id = p_market_id
              AND t1.efex_cust_id = t2.efex_cust_id
              AND t2.last_rec_flg = 'Y'
              AND t1.sales_terr_id = t3.efex_sales_terr_id
              AND t3.last_rec_flg = 'Y'
            ) t2
        ON (t1.efex_cust_id = t2.efex_cust_id
            AND t1.efex_matl_grp_id = t2.efex_matl_grp_id )
        WHEN MATCHED THEN
          UPDATE SET
              t1.status = t2.status  -- Only update the status
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.distbn_code,
              t1.cust_dtl_code,
              t1.efex_matl_grp_id,
              t1.company_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.status
            )
          VALUES
            (
              efex_tot_distbn_dim_seq.nextval,
              t2.cust_dtl_code,
              t2.efex_matl_grp_id,
              p_company_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              t2.status
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_tot_distbn, 'N/A', i_log_level + 2, 'Complete - EFEX_TOT_DISTBN_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_tot_distbn,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_TOTAL_DISTBN_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_tot_distbn_flattening;


FUNCTION efex_tot_distn_tx_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count            NUMBER := 0;
  v_efex_cust_id         efex_distbn_tot.efex_cust_id%TYPE;
  v_efex_matl_grp_id     efex_distbn_tot.matl_grp_id%TYPE;

  v_upd_count            NUMBER := 0;
  v_ins_count            NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex customer modified yesterday.
  CURSOR csr_tot_distbn_count IS
    SELECT count(*) AS rec_count
    FROM efex_distbn_tot
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(distbn_tot_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  CURSOR csr_efex_distbn_tot IS
    SELECT
      TRUNC(t1.efex_lupdt) as distbn_xactn_date,
      t3.cust_dtl_code,
      t1.matl_grp_id as efex_matl_grp_id,
      t2.distbn_code,
      t1.efex_cust_id,
      t4.sales_terr_code,
      t3.efex_sales_terr_id as efex_sales_terr_id,
      t4.efex_sgmnt_id as efex_sgmnt_id,
      t1.bus_unit_id as efex_bus_unit_id,
      t4.sales_terr_mgr_id as efex_assoc_id,
      t1.tot_qty as tot_facings,
      TRUNC(t1.efex_lupdt) as eff_start_date,
      t1.status,
      t3.status as cust_status
    FROM
      efex_distbn_tot t1,
      efex_tot_distbn_dim t2,
      efex_cust_dtl_dim t3,
      efex_sales_terr_dim t4
    WHERE
      t1.valdtn_status = ods_constants.valdtn_valid
      AND trunc(t1.distbn_tot_lupdt) = i_aggregation_date
      AND t1.efex_mkt_id = p_market_id
      AND t1.efex_cust_id = t2.efex_cust_id
      AND t1.matl_grp_id = t2.efex_matl_grp_id
      AND t1.efex_cust_id = t3.efex_cust_id
      AND t3.last_rec_flg = 'Y'
      AND t3.efex_sales_terr_id = t4.efex_sales_terr_id
      AND t4.last_rec_flg = 'Y';
  rv_efex_distbn_tot csr_efex_distbn_tot%ROWTYPE;


BEGIN

  -- Starting efex_tot_distbn_dim flattening.
  write_log(ods_constants.data_type_efex_tot_distbn_tx, 'N/A', i_log_level + 1, 'Starting EFEX_DISTBN_TOT_XACTN_DIM flattening.');

  -- Fetch the record from the csr_tot_distbn_count cursor.
  OPEN  csr_tot_distbn_count;
  FETCH csr_tot_distbn_count INTO v_rec_count;
  CLOSE csr_tot_distbn_count;

  -- If any efex_distbn_tot records modified yesterday
  write_log(ods_constants.data_type_efex_tot_distbn_tx, 'N/A', i_log_level + 2, 'EFEX distribution tot received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

    FOR rv_efex_distbn_tot IN csr_efex_distbn_tot LOOP

      -- Check whether this transaction total has already been loaded into DDS
      SELECT COUNT(*) INTO v_rec_count
      FROM
        efex_tot_distbn_xactn_dim
      WHERE
        efex_cust_id = rv_efex_distbn_tot.efex_cust_id
        AND efex_matl_grp_id = rv_efex_distbn_tot.efex_matl_grp_id
        AND distbn_xactn_date = rv_efex_distbn_tot.distbn_xactn_date;

      -- Only process this record if it hasn't been loaded yet
      IF v_rec_count = 0 THEN

         -- Now pass cursor results into variables and set default values to variables
         v_efex_cust_id :=  rv_efex_distbn_tot.efex_cust_id;
         v_efex_matl_grp_id := rv_efex_distbn_tot.efex_matl_grp_id;

         -- Close the last distribution transaction record for the same customer and material group
         UPDATE efex_tot_distbn_xactn_dim
         SET
           last_rec_flg = 'N',
           eff_end_date = rv_efex_distbn_tot.distbn_xactn_date
         WHERE
           efex_cust_id = rv_efex_distbn_tot.efex_cust_id
           AND efex_matl_grp_id = rv_efex_distbn_tot.efex_matl_grp_id
           AND last_rec_flg = 'Y';

         v_upd_count := v_upd_count + SQL%ROWCOUNT;

         -- Insert a new distribution transaction record
         INSERT INTO efex_tot_distbn_xactn_dim
           (
            distbn_xactn_code,
            distbn_xactn_date,
            cust_dtl_code,
            efex_matl_grp_id,
            company_code,
            distbn_code,
            efex_cust_id,
            sales_terr_code,
            efex_sales_terr_id,
            efex_sgmnt_id,
            efex_bus_unit_id,
            efex_assoc_id,
            tot_facings,
            eff_start_date,
            eff_end_date,
            last_rec_flg,
            status
           )
         VALUES
           (
            EFEX_TOT_DISTBN_XACTN_DIM_SEQ.nextval,
            rv_efex_distbn_tot.distbn_xactn_date,
            rv_efex_distbn_tot.cust_dtl_code,
            rv_efex_distbn_tot.efex_matl_grp_id,
            p_company_code,
            rv_efex_distbn_tot.distbn_code,
            rv_efex_distbn_tot.efex_cust_id,
            rv_efex_distbn_tot.sales_terr_code,
            rv_efex_distbn_tot.efex_sales_terr_id,
            rv_efex_distbn_tot.efex_sgmnt_id,
            rv_efex_distbn_tot.efex_bus_unit_id,
            rv_efex_distbn_tot.efex_assoc_id,
            rv_efex_distbn_tot.tot_facings,
            rv_efex_distbn_tot.eff_start_date,
            DECODE(rv_efex_distbn_tot.cust_status, 'A', c_future_date, rv_efex_distbn_tot.distbn_xactn_date),
            'Y',
            rv_efex_distbn_tot.status
           );

         v_ins_count := v_ins_count + SQL%ROWCOUNT;
      END IF;

    END LOOP;

    COMMIT;
  END IF;

  write_log(ods_constants.data_type_efex_tot_distbn_tx, 'N/A', i_log_level + 2, 'Complete EFEX_TOT_DISBTN_XACTN_DIM flattening with insert count [' ||
            v_ins_count || '] and update count [' || v_upd_count || ']');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_tot_distbn_tx,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_TOT_DISTBN_XACTN_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_tot_distn_tx_flattening;


FUNCTION efex_turnin_order_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;
  v_upd_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex order modified yesterday.
  CURSOR csr_efex_order_count IS
    SELECT count(*) AS rec_count
    FROM efex_order
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(order_lupdt) = i_aggregation_date;

  -- Select the latest active order for each customer received yesterday - used to update efex_cust_dtl_dim.
  CURSOR csr_cust_latest_order IS
    SELECT t1.efex_cust_id, t1.efex_order_id, t1.order_date
    FROM
      efex_order t1,
      (
        SELECT MAX(order_date) as order_date, efex_cust_id
        FROM efex_order t1
        WHERE valdtn_status = 'VALID'
          AND EXISTS (SELECT *
                      FROM efex_order t2
                      WHERE t1.efex_cust_id = t2.efex_cust_id
                        AND t2.valdtn_status = 'VALID'
                        AND TRUNC(t2.order_lupdt) = i_aggregation_date
                        AND t2.efex_mkt_id = p_market_id
                        AND t1.status = 'A'
                     )
          AND t1.status = 'A'
        GROUP BY efex_cust_id
      ) t2
    WHERE
      t1.efex_cust_id = t2.efex_cust_id
      AND t1.order_date = t2.order_date;
  rv_cust_latest_order  csr_cust_latest_order%ROWTYPE;

BEGIN
  -- Starting EFEX_TURNIN_ORDER_DIM flattening.
  write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 1, 'Starting EFEX_TURNIN_ORDER_DIM flattening.');

  -- Fetch the record from the csr_efex_order_count cursor.
  OPEN  csr_efex_order_count;
  FETCH csr_efex_order_count INTO v_rec_count;
  CLOSE csr_efex_order_count;

  -- If any efex_order records modified yesterday.
  write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'EFEX order received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_turnin_order_dim t1
     USING (
             SELECT
               t1.efex_order_id,
               TRUNC(t1.order_date) as order_date,
               t1.order_code,
               t2.cust_dtl_code,
               t1.efex_cust_id,
               t3.sales_terr_code,
               t1.sales_terr_id   as efex_sales_terr_id,
               t1.sgmnt_id        as efex_sgmnt_id,
               t1.bus_unit_id     as efex_bus_unit_id,
               t1.user_id         as efex_assoc_id,
               t1.cust_contact,
               t1.dlvry_date,
               t1.purch_order_num,
               t1.order_status,
               t1.tot_matls       as tot_items,
               t1.tot_price,
               t1.tp_amt,
               t1.tp_paid_flg,
               t1.dlvrd_flg,
               t1.status
             FROM
               efex_order t1,
               efex_cust_dtl_dim t2,
               efex_sales_terr_dim t3
             WHERE
               t1.valdtn_status = ods_constants.valdtn_valid
               AND trunc(t1.order_lupdt) = i_aggregation_date
               AND t1.efex_mkt_id = p_market_id
               AND t1.efex_cust_id = t2.efex_cust_id
               AND t2.last_rec_flg = 'Y'
               AND t1.sales_terr_id = t3.efex_sales_terr_id
               AND t3.last_rec_flg = 'Y'
            ) t2
        ON (t1.efex_order_id = t2.efex_order_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.order_code = t2.order_code,
            t1.efex_assoc_id = t2.efex_assoc_id,
            t1.cust_contact = t2.cust_contact,
            t1.dlvry_date = t2.dlvry_date,
            t1.purch_order_num = t2.purch_order_num,
            t1.order_status = t2.order_status,
            t1.tot_items = t2.tot_items,
            t1.tot_price = t2.tot_price,
            t1.tp_amt = t2.tp_amt,
            t1.tp_paid_flg = t2.tp_paid_flg,
            t1.dlvrd_flg = t1.dlvrd_flg,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.efex_order_id,
              t1.order_date,
              t1.order_code,
              t1.cust_dtl_code,
              t1.company_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.efex_assoc_id,
              t1.cust_contact,
              t1.dlvry_date,
              t1.purch_order_num,
              t1.order_status,
              t1.tot_items,
              t1.tot_price,
              t1.tp_amt,
              t1.tp_paid_flg,
              t1.dlvrd_flg,
              t1.status
            )
          VALUES
            (
              t2.efex_order_id,
              t2.order_date,
              t2.order_code,
              t2.cust_dtl_code,
              p_company_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              t2.efex_assoc_id,
              t2.cust_contact,
              t2.dlvry_date,
              t2.purch_order_num,
              t2.order_status,
              t2.tot_items,
              t2.tot_price,
              t2.tp_amt,
              t2.tp_paid_flg,
              t2.dlvrd_flg,
              t2.status
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'EFEX_TURNIN_ORDER_DIM flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Update the last order id and date to efex_cust_dtl table for the order received yesterday.
      write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'Update latest order and date to EFEX_CUST_DTL_DIM table.');

      FOR rv_cust_latest_order IN csr_cust_latest_order LOOP
          UPDATE
            efex_cust_dtl_dim
          SET
            last_order_date = TRUNC(rv_cust_latest_order.order_date),
            last_order_id = rv_cust_latest_order.efex_order_id
          WHERE
            efex_cust_id = rv_cust_latest_order.efex_cust_id
            AND last_rec_flg = 'Y';

          v_upd_count := v_upd_count + 1;
      END LOOP;

      -- Number of customer detail record modified.
      write_log(ods_constants.data_type_efex_turnin_ord, 'N/A', i_log_level + 2, 'EFEX_CUST_DTL_DIM modified count: [' || v_upd_count || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_turnin_ord,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_TURNIN_ORDER_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_turnin_order_flattening;


FUNCTION efex_pmt_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex pmt modified yesterday.
  CURSOR csr_efex_pmt_count IS
    SELECT count(*) AS rec_count
    FROM efex_pmt
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(pmt_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;


BEGIN

  -- Starting efex_pmt_dim flattening.
  write_log(ods_constants.data_type_efex_pmt, 'N/A', i_log_level + 1, 'Starting EFEX_PMT_DIM flattening.');

  -- Fetch the record from the csr_efex_pmt_count cursor.
  OPEN  csr_efex_pmt_count;
  FETCH csr_efex_pmt_count INTO v_rec_count;
  CLOSE csr_efex_pmt_count;

  -- If any efex_pmt records modified yesterday
  write_log(ods_constants.data_type_efex_pmt, 'N/A', i_log_level + 2, 'EFEX PMT received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_pmt_dim t1
     USING (
             SELECT
               t1.pmt_id          as efex_pmt_id,
               TRUNC(t1.pmt_date) as pmt_date,
               t2.cust_dtl_code,
               t1.efex_cust_id,
               t1.user_id         as efex_assoc_id,
               t1.pmt_method,
               t1.procd_flg,
               t1.contra_pmt_ref,
               t1.pmt_notes,
               t1.contra_pmt_status,
               t1.contra_procd_date,
               t1.contra_replicated_date,
               t1.contra_deducted,
               t1.status
             FROM
               efex_pmt t1,
               efex_cust_dtl_dim t2
             WHERE
               t1.valdtn_status = ods_constants.valdtn_valid
               AND trunc(t1.pmt_lupdt) = i_aggregation_date
               AND t1.efex_mkt_id = p_market_id
               AND t1.efex_cust_id = t2.efex_cust_id
               AND t2.last_rec_flg = 'Y'
            ) t2
        ON (t1.efex_pmt_id = t2.efex_pmt_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.pmt_date = t2.pmt_date,
            t1.cust_dtl_code = t2.cust_dtl_code,
            t1.efex_cust_id = t2.efex_cust_id,
            t1.efex_assoc_id = t2.efex_assoc_id,
            t1.pmt_method = t2.pmt_method,
            t1.procd_flg = t2.procd_flg,
            t1.contra_pmt_ref = t2.contra_pmt_ref,
            t1.pmt_notes = t2.pmt_notes,
            t1.contra_pmt_status = t2.contra_pmt_status,
            t1.contra_procd_date = t2.contra_procd_date,
            t1.contra_replicated_date = t2.contra_replicated_date,
            t1.contra_deducted = t2.contra_deducted,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.efex_pmt_id,
              t1.pmt_date,
              t1.cust_dtl_code,
              t1.efex_cust_id,
              t1.efex_assoc_id,
              t1.pmt_method,
              t1.procd_flg,
              t1.contra_pmt_ref,
              t1.pmt_notes,
              t1.contra_pmt_status,
              t1.contra_procd_date,
              t1.contra_replicated_date,
              t1.contra_deducted,
              t1.status
            )
          VALUES
            (
              t2.efex_pmt_id,
              t2.pmt_date,
              t2.cust_dtl_code,
              t2.efex_cust_id,
              t2.efex_assoc_id,
              t2.pmt_method,
              t2.procd_flg,
              t2.contra_pmt_ref,
              t2.pmt_notes,
              t2.contra_pmt_status,
              t2.contra_procd_date,
              t2.contra_replicated_date,
              t2.contra_deducted,
              t2.status
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_pmt, 'N/A', i_log_level + 2, 'efex_pmt_dim flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION

  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_pmt,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_PMT_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_pmt_flattening;


FUNCTION efex_mrq_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- CONSTANT DECLARATIONS
  c_time_format           VARCHAR2(10) := 'HH:MM AM';

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex mrq modified yesterday.
  CURSOR csr_efex_mrq_count IS
    SELECT count(*) AS rec_count
    FROM efex_mrq
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(mrq_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting EFEX_MRQ_DIM flattening.
  write_log(ods_constants.data_type_efex_mrq, 'N/A', i_log_level + 1, 'Starting EFEX_MRQ_DIM flattening.');

  -- Fetch the record from the csr_efex_mrq_count cursor.
  OPEN  csr_efex_mrq_count;
  FETCH csr_efex_mrq_count INTO v_rec_count;
  CLOSE csr_efex_mrq_count;

  -- If any efex_mrq records modified yesterday.
  write_log(ods_constants.data_type_efex_mrq, 'N/A', i_log_level + 2, 'EFEX mrq received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_mrq_dim t1
     USING (
             SELECT
               t1.mrq_id                      as efex_mrq_id,
               TRUNC(t1.creatn_date)          as creatn_date,
               t2.cust_dtl_code,
               t1.efex_cust_id,
               t3.sales_terr_code,
               t1.sales_terr_id               as efex_sales_terr_id,
               t1.sgmnt_id                    as efex_sgmnt_id,
               t1.bus_unit_id                 as efex_bus_unit_id,
               t1.user_id                     as efex_assoc_id,
               TRUNC(t1.mrq_date)             as mrq_date,
               TO_CHAR(t1.mrq_date,c_time_format)  as mrq_time,
               TRUNC(t1.alt_date)                  as mrq_alt_date,
               DECODE(t1.alt_date, NULL, TO_CHAR(t1.alt_date,c_time_format))  as mrq_alt_time,
               t1.cust_contact_name,
               t1.completed_flg,
               t1.satisfactory_flg,
               t4.mrq_status,
               t1.date_completed              as completed_date,
               t1.merch_name,
               t1.merch_comnt,
               t1.merch_travel_time,
               t1.merch_travel_kms,
               t1.status
             FROM
               efex_mrq t1,
               efex_cust_dtl_dim t2,
               efex_sales_terr_dim t3,
               efex_mrq_status_flg_dim t4
             WHERE
               t1.valdtn_status = ods_constants.valdtn_valid
               AND trunc(t1.mrq_lupdt) = i_aggregation_date
               AND t1.efex_mkt_id = p_market_id
               AND t1.efex_cust_id = t2.efex_cust_id
               AND t2.last_rec_flg = 'Y'
               AND t1.sales_terr_id = t3.efex_sales_terr_id
               AND t3.last_rec_flg = 'Y'
               AND t1.completed_flg = t4.completed_flg(+)
            ) t2
        ON (t1.efex_mrq_id = t2.efex_mrq_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.creatn_date = t2.creatn_date,
            t1.efex_assoc_id = t2.efex_assoc_id,
            t1.mrq_date = t2.mrq_date,
            t1.mrq_time = t2.mrq_time,
            t1.mrq_alt_date = t2.mrq_alt_date,
            t1.mrq_alt_time = t2.mrq_alt_time,
            t1.cust_contact_name = t2.cust_contact_name,
            t1.completed_flg = t2.completed_flg,
            t1.satisfactory_flg = t2.satisfactory_flg,
            t1.mrq_status = t2.mrq_status,
            t1.completed_date = t2.completed_date,
            t1.merch_name = t2.merch_name,
            t1.merch_comnt = t2.merch_comnt,
            t1.merch_travel_time = t2.merch_travel_time,
            t1.merch_travel_kms = t2.merch_travel_kms,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.efex_mrq_id,
              t1.company_code,
              t1.creatn_date,
              t1.cust_dtl_code,
              t1.efex_cust_id,
              t1.sales_terr_code,
              t1.efex_sales_terr_id,
              t1.efex_sgmnt_id,
              t1.efex_bus_unit_id,
              t1.efex_assoc_id,
              t1.mrq_date,
              t1.mrq_time,
              t1.mrq_alt_date,
              t1.mrq_alt_time,
              t1.cust_contact_name,
              t1.completed_flg,
              t1.satisfactory_flg,
              t1.mrq_status,
              t1.completed_date,
              t1.merch_name,
              t1.merch_comnt,
              t1.merch_travel_time,
              t1.merch_travel_kms,
              t1.status
            )
          VALUES
            (
              t2.efex_mrq_id,
              p_company_code,
              t2.creatn_date,
              t2.cust_dtl_code,
              t2.efex_cust_id,
              t2.sales_terr_code,
              t2.efex_sales_terr_id,
              t2.efex_sgmnt_id,
              t2.efex_bus_unit_id,
              t2.efex_assoc_id,
              t2.mrq_date,
              t2.mrq_time,
              t2.mrq_alt_date,
              t2.mrq_alt_time,
              t2.cust_contact_name,
              t2.completed_flg,
              t2.satisfactory_flg,
              t2.mrq_status,
              t2.completed_date,
              t2.merch_name,
              t2.merch_comnt,
              t2.merch_travel_time,
              t2.merch_travel_kms,
              t2.status
            );

      -- number of record modified.
      write_log(ods_constants.data_type_efex_mrq, 'N/A', i_log_level + 2, 'efex_mrq_dim flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_mrq,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_MRQ_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_mrq_flattening;


FUNCTION efex_mrq_task_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex mrq modified yesterday.
  CURSOR csr_efex_mrq_task_count IS
    SELECT count(*) AS rec_count
    FROM efex_mrq_task
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(mrq_task_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

BEGIN
  -- Starting EFEX_MRQ_TASK_DIM flattening.
  write_log(ods_constants.data_type_efex_mrq_task, 'N/A', i_log_level + 1, 'Starting EFEX_MRQ_TASK_DIM flattening.');

  -- Fetch the record from the csr_efex_mrq_task_count cursor.
  OPEN  csr_efex_mrq_task_count;
  FETCH csr_efex_mrq_task_count INTO v_rec_count;
  CLOSE csr_efex_mrq_task_count;

  -- If any efex_mrq_task records modified yesterday.
  write_log(ods_constants.data_type_efex_mrq_task, 'N/A', i_log_level + 2, 'EFEX mrq task received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

     MERGE INTO
       efex_mrq_task_dim t1
     USING (
             SELECT
               t1.mrq_task_id     as efex_mrq_task_id,
               t1.mrq_task_name,
               t1.mrq_id          as efex_mrq_id,
               t1.job_type,
               t1.display_type,
               t1.setup_mins,
               t1.actual_mins,
               t1.hr_rate,
               t1.actual_cases,
               t1.compliance_rslt,
               t1.status
             FROM
               efex_mrq_task t1
             WHERE
               t1.valdtn_status = ods_constants.valdtn_valid
               AND trunc(t1.mrq_task_lupdt) = i_aggregation_date
               AND t1.efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_mrq_task_id = t2.efex_mrq_task_id )
        WHEN MATCHED THEN
          UPDATE SET
            t1.mrq_task_name = t2.mrq_task_name,
            t1.efex_mrq_id = t2.efex_mrq_id,
            t1.job_type = t2.job_type,
            t1.display_type = t2.display_type,
            t1.setup_mins = t2.setup_mins,
            t1.actual_mins = t2.actual_mins,
            t1.hr_rate = t2.hr_rate,
            t1.actual_cases = t2.actual_cases,
            t1.compliance_rslt = t2.compliance_rslt,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (
              t1.efex_mrq_task_id,
              t1.company_code,
              t1.mrq_task_name,
              t1.efex_mrq_id,
              t1.job_type,
              t1.display_type,
              t1.setup_mins,
              t1.actual_mins,
              t1.hr_rate,
              t1.actual_cases,
              t1.compliance_rslt,
              t1.status
            )
          VALUES
            (
              t2.efex_mrq_task_id,
              p_company_code,
              t2.mrq_task_name,
              t2.efex_mrq_id,
              t2.job_type,
              t2.display_type,
              t2.setup_mins,
              t2.actual_mins,
              t2.hr_rate,
              t2.actual_cases,
              t2.compliance_rslt,
              t2.status
            );

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_mrq_task, 'N/A', i_log_level + 2, 'efex_mrq_task_dim flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_mrq_task,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_MRQ_TASK_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_mrq_task_flattening;


FUNCTION efex_matl_matlsbgrp_flattening (
  i_aggregation_date      IN DATE,
  i_log_level             IN ods.log.log_level%TYPE
  ) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_rec_count        NUMBER := 0;
  v_upd_count    NUMBER := 0;
  v_xactn_upd_count  NUMBER := 0;
  v_ins_count        NUMBER := 0;

  -- CURSOR DECLARATIONS
  -- Check whether any efex material subgroup modified yesterday.
  CURSOR csr_matl_matl_subgrp_count IS
    SELECT count(*) AS rec_count
    FROM efex_matl_matl_subgrp
    WHERE
      valdtn_status = ods_constants.valdtn_valid
      AND trunc(matl_matl_subgrp_lupdt) = i_aggregation_date
      AND efex_mkt_id = p_market_id;

  CURSOR csr_no_new_assgnmnt IS
    SELECT  -- no more active item subgroup assignment for the same item and segment
      efex_matl_id,
      sgmnt_id,
      max(efex_lupdt) as efex_lupdt
    FROM efex_matl_matl_subgrp t1
    WHERE status = 'X'
      AND NOT EXISTS (SELECT *
                      FROM efex_matl_matl_subgrp t2
                      WHERE t1.efex_matl_id = t2.efex_matl_id
                        AND t1.sgmnt_id = t2.sgmnt_id
                        AND t2.status = 'A')
      AND EXISTS (SELECT * FROM efex_distbn_xactn_dim t4
                  WHERE t1.efex_matl_id = t4.efex_matl_id
                    AND t1.sgmnt_id = t4.efex_sgmnt_id
                    AND t4.status = 'A'
                    AND t4.last_rec_flg = 'Y'
                    AND eff_end_date = c_future_date)
      AND valdtn_status = ods_constants.valdtn_valid
      AND trunc(matl_matl_subgrp_lupdt) = i_aggregation_date
    GROUP BY efex_matl_id, sgmnt_id;

    rv_no_new_assgnmnt csr_no_new_assgnmnt%ROWTYPE;

  -- distribution transaction have old subgroup assignment
  CURSOR csr_new_assgnmnt IS
    SELECT
      t1.efex_matl_id,
      t1.efex_lupdt,
      t5.efex_cust_id
    FROM
      efex_matl_matl_subgrp t1,
      efex_distbn_xactn_dim t5
    WHERE
      t1.valdtn_status = ods_constants.valdtn_valid
      AND t1.status = 'A'
      AND trunc(matl_matl_subgrp_lupdt) = i_aggregation_date
      AND t1.efex_matl_id = t5.efex_matl_id
      AND t1.sgmnt_id = t5.efex_sgmnt_id
      AND t1.matl_subgrp_id <> t5.efex_matl_subgrp_id  -- not the active subgroup
      AND t5.status = 'A'
      AND t5.last_rec_flg = 'Y'
      AND EXISTS (SELECT *
                  FROM efex_matl_matl_subgrp t2
                  WHERE t1.efex_matl_id = t2.efex_matl_id
                    AND t1.sgmnt_id = t2.sgmnt_id
                    AND t1.matl_subgrp_id <> t2.matl_subgrp_id
                    AND t2.status = 'X'
                    AND valdtn_status = ods_constants.valdtn_valid
                    AND trunc(matl_matl_subgrp_lupdt) = i_aggregation_date);

    rv_new_assgnmnt csr_new_assgnmnt%ROWTYPE;

  CURSOR csr_reopen_distbn IS
    SELECT t3.efex_cust_id, t3.efex_matl_id, t3.efex_sgmnt_id, t1.efex_lupdt
    FROM
      efex_matl_matl_subgrp t1,
      efex_distbn_xactn_dim t3,
      efex_cust t4
    WHERE
      t1.efex_matl_id = t3.efex_matl_id
      AND t1.sgmnt_id = t3.efex_sgmnt_id
      AND t1.matl_subgrp_id <> t3.efex_matl_subgrp_id
      AND t1.status = 'A'
      AND t1.valdtn_status = ods_constants.valdtn_valid
      AND TRUNC(t1.matl_matl_subgrp_lupdt) = i_aggregation_date
      AND t3.last_rec_flg = 'Y'
      AND t3.status = 'X'     -- distribution transaction closed
      AND t4.efex_cust_id = t3.efex_cust_id   -- active customer
      AND t4.status = 'A'
      AND EXISTS (SELECT *    -- new subgroup assignment have closed subgroup assignment before this date
                  FROM efex_matl_matl_subgrp t2
                  WHERE t1.efex_matl_id = t2.efex_matl_id
                    AND t1.sgmnt_id = t2.sgmnt_id
                    AND t1.matl_subgrp_id <> t2.matl_subgrp_id
                    AND t2.status = 'X'
                    AND valdtn_status = ods_constants.valdtn_valid
                    AND matl_matl_subgrp_lupdt < i_aggregation_date
                  )
      AND EXISTS (SELECT *   -- distribution in ods and active
                  FROM efex_distbn t5
                  WHERE t3.efex_cust_id = t5.efex_cust_id
                    AND t3.efex_matl_id = t5.efex_matl_id
                    AND t3.efex_sgmnt_id = t5.sgmnt_id
                    AND t5.status = 'A');

   rv_reopen_distbn  csr_reopen_distbn%ROWTYPE;

  -- new assigment for the item and segment
  CURSOR csr_new_matl_subgrp IS
    SELECT t1.efex_matl_id, t1.sgmnt_id, t1.efex_lupdt, t6.efex_cust_id
    FROM
      efex_matl_matl_subgrp t1,
      efex_distbn t6
    WHERE
      t1.status = 'A'
      AND t1.valdtn_status = ods_constants.valdtn_valid
      AND TRUNC(t1.matl_matl_subgrp_lupdt) = i_aggregation_date
      AND t1.efex_matl_id = t6.efex_matl_id
      AND t1.sgmnt_id = t6.sgmnt_id
      AND t6.status = 'A'
      AND t6.distbn_lupdt < i_aggregation_date
      AND NOT EXISTS (SELECT *        -- not aggregated to DDS yet
                      FROM efex_matl_matl_subgrp_dim t2
                      WHERE
                        t1.efex_matl_id = t2.efex_matl_id
                        AND t1.matl_subgrp_id = t2.efex_matl_subgrp_id
                        AND t1.sgmnt_id = t2.efex_sgmnt_id)
      AND NOT EXISTS (SELECT *        -- no closed assigment
                      FROM efex_matl_matl_subgrp t3
                      WHERE
                        t1.efex_matl_id = t3.efex_matl_id
                        AND t1.sgmnt_id = t3.sgmnt_id
                        AND t3.status = 'X')
      AND NOT EXISTS (SELECT *   -- distribution not in DDS yet
                      FROM efex_distbn_dim t4
                      WHERE
                        t1.efex_matl_id = t4.efex_matl_id
                        AND t1.sgmnt_id = t4.efex_sgmnt_id);

   rv_new_matl_subgrp  csr_new_matl_subgrp%ROWTYPE;

BEGIN
  -- Starting efex_matl_subgrp flattening.
  write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'N/A', i_log_level + 1, 'Starting efex_matl_matl_subgrp_dim flattening.');

  -- Fetch the record from the csr_matl_matl_subgrp_count cursor.
  OPEN  csr_matl_matl_subgrp_count;
  FETCH csr_matl_matl_subgrp_count INTO v_rec_count;
  CLOSE csr_matl_matl_subgrp_count;

  -- If any efex matl matl subgroup records modified yesterday.
  write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'N/A', i_log_level + 2, 'efex_matl_matl_subgrp received yesterday were [' || v_rec_count || ']');

  IF v_rec_count > 0 THEN

      v_upd_count := 0;
      FOR rv_no_new_assgnmnt IN csr_no_new_assgnmnt LOOP
         UPDATE efex_distbn_xactn_dim
         SET
           eff_end_date = trunc(rv_no_new_assgnmnt.efex_lupdt),
           status = 'X'
         WHERE
           last_rec_flg = 'Y'
           AND status = 'A'
           AND efex_matl_id = rv_no_new_assgnmnt.efex_matl_id
           AND efex_sgmnt_id = rv_no_new_assgnmnt.sgmnt_id;

         v_upd_count := v_upd_count + SQL%ROWCOUNT;

         UPDATE efex_distbn_dim
         SET
           status = 'X'
         WHERE
           status = 'A'
           AND efex_matl_id = rv_no_new_assgnmnt.efex_matl_id
           AND efex_sgmnt_id = rv_no_new_assgnmnt.sgmnt_id;

         COMMIT;

      END LOOP;

      IF v_upd_count > 0 THEN
         COMMIT;
         write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'N/A', i_log_level + 2, 'efex_distbn_xactn_dim closed count (matl subgrp closed): [' || v_upd_count || ']');
      END IF;

      v_upd_count := 0;
      -- activate the ods distribution to aviid duplicated efex_distbn_xactn_dim created by
      -- customer/sales terr/true distribution
      FOR rv_new_assgnmnt IN csr_new_assgnmnt LOOP

         -- close the transaction and create a new transaction
         UPDATE efex_distbn
         SET efex_lupdt = rv_new_assgnmnt.efex_lupdt
         WHERE
           efex_cust_id =  rv_new_assgnmnt.efex_cust_id
           AND efex_matl_id = rv_new_assgnmnt.efex_matl_id;

         v_upd_count := v_upd_count + SQL%ROWCOUNT;

      END LOOP;

      IF v_upd_count > 0 THEN
         COMMIT;
         write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'N/A', i_log_level + 2, 'efex_distbn upd counts (matl re-assign to new subgroup): [' || v_upd_count || ']');
      END IF;

      v_upd_count := 0;
      FOR rv_reopen_distbn IN csr_reopen_distbn LOOP
         UPDATE efex_distbn
         SET efex_lupdt = rv_reopen_distbn.efex_lupdt
         WHERE
           efex_cust_id = rv_reopen_distbn.efex_cust_id
           AND efex_matl_id = rv_reopen_distbn.efex_matl_id;

         v_upd_count := v_upd_count + SQL%ROWCOUNT;

      END LOOP;

      IF v_upd_count > 0 THEN
         COMMIT;
         write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'N/A', i_log_level + 2, 'efex_distbn upd counts (matl re-assign to new subgroup in different date): [' || v_upd_count || ']');
      END IF;

      v_upd_count := 0;

      FOR rv_new_matl_subgrp IN csr_new_matl_subgrp LOOP
         UPDATE efex_distbn
         SET efex_lupdt = rv_new_matl_subgrp.efex_lupdt
         WHERE
           efex_cust_id = rv_new_matl_subgrp.efex_cust_id
           AND efex_matl_id = rv_new_matl_subgrp.efex_matl_id;

        v_upd_count := v_upd_count + SQL%ROWCOUNT;

      END LOOP;

      IF v_upd_count > 0 THEN
         COMMIT;
         write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'N/A', i_log_level + 2, 'Trigger efex_distbn (new subgroup assigned not in DDS yet): [' || v_upd_count || ']');
      END IF;

     -- normal process
     MERGE INTO
       efex_matl_matl_subgrp_dim t1
     USING (SELECT
              efex_matl_id,
              matl_subgrp_id       as efex_matl_subgrp_id,
              sgmnt_id             as efex_sgmnt_id,
              matl_grp_id          as efex_matl_grp_id,
              bus_unit_id          as efex_bus_unit_id,
              status
            FROM
              efex_matl_matl_subgrp
            WHERE
              valdtn_status = ods_constants.valdtn_valid
              AND trunc(matl_matl_subgrp_lupdt) = i_aggregation_date
              AND efex_mkt_id = p_market_id
            ) t2
        ON (t1.efex_matl_id = t2.efex_matl_id
            AND t1.efex_matl_subgrp_id = t2.efex_matl_subgrp_id)
        WHEN MATCHED THEN
          UPDATE SET
            t1.efex_sgmnt_id = t2.efex_sgmnt_id,
            t1.efex_matl_grp_id = t2.efex_matl_grp_id,
            t1.efex_bus_unit_id = t2.efex_bus_unit_id,
            t1.status = t2.status
        WHEN NOT MATCHED THEN
          INSERT
            (t1.efex_matl_id,
             t1.efex_matl_subgrp_id,
             t1.efex_sgmnt_id,
             t1.efex_matl_grp_id,
             t1.efex_bus_unit_id,
             t1.status)
          VALUES
            (t2.efex_matl_id,
             t2.efex_matl_subgrp_id,
             t2.efex_sgmnt_id,
             t2.efex_matl_grp_id,
             t2.efex_bus_unit_id,
             t2.status);

      -- Number of record modified.
      write_log(ods_constants.data_type_efex_matl_matlsubgrp, 'N/A', i_log_level + 2, 'efex_matl_matl_subgrp_dim flattening with modified count: [' || SQL%ROWCOUNT || ']');

      -- Commit.
      COMMIT;
  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    write_log(ods_constants.data_type_efex_matl_matlsubgrp,'ERROR',i_log_level+1,
             'SCHEDULED_EFEX_AGGREGATION.EFEX_MATL_MATLSBGRP_FLATTENING: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_matl_matlsbgrp_flattening;


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
             'SCHEDULED_EFEX_AGGREGATION.EFEX_ROUTE_SCHED_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_timesheet_call_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_timesheet_day_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_assmnt_assgnmnt_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_assmnt_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_range_matl_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_range_matl_fact_aggr;


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

  v_tot_new_gaps         NUMBER;
  v_tot_closed_gaps      NUMBER;

  v_commit_count         NUMBER;
  c_commit_block         constant NUMBER := 10000;

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
    WHERE calendar_date = i_aggregation_date - 7;

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
      t1.last_rec_flg = 'Y'
      AND t1.status = 'A'    -- only pick the active transaction
      AND t1.distbn_yyyyppw >= v_start_yyyyppw -- and start from last week
      AND t1.distbn_yyyyppw = t2.mars_week
      AND t2.mars_day_of_week = 7
      AND t1.distbn_yyyypp = t3.mars_period
      AND t1.efex_matl_id = t4.efex_matl_id
      AND t1.efex_sgmnt_id = t4.efex_sgmnt_id
      AND t4.status = 'A';

  rv_efex_distbn_xactn csr_efex_distbn_xactn%ROWTYPE;

  CURSOR csr_calc_distbn_gaps IS
    SELECT
      SUM(gap_new) as tot_gaps_new,
      SUM(gap_closed) as tot_gaps_closed
    FROM
      efex_distbn_xactn_dim
    WHERE
      efex_cust_id = v_efex_cust_id
      AND efex_matl_id = v_efex_matl_id
      AND distbn_yyyyppw = v_distbn_yyyyppw;
  rv_calc_distbn_gaps csr_calc_distbn_gaps%ROWTYPE;

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
       -- Assign to variable used by the cursor
       v_efex_cust_id := rv_efex_distbn_xactn.efex_cust_id;
       v_efex_matl_id := rv_efex_distbn_xactn.efex_matl_id;
       v_distbn_yyyyppw := rv_efex_distbn_xactn.distbn_yyyyppw;
       v_mars_week_end_date := rv_efex_distbn_xactn.mars_week_end_date;

       v_tot_new_gaps  := 0;
       v_tot_closed_gaps := 0;

       -- Delete existing record for the disbtn week
       DELETE efex_distbn_fact
       WHERE
         efex_cust_id = v_efex_cust_id
         AND efex_matl_id = v_efex_matl_id
         AND mars_week_end_date = v_mars_week_end_date;

       v_del_count := v_del_count + SQL%ROWCOUNT;

       OPEN csr_calc_distbn_gaps;
       FETCH csr_calc_distbn_gaps INTO rv_calc_distbn_gaps;
       IF csr_calc_distbn_gaps%FOUND THEN
          IF rv_calc_distbn_gaps.tot_gaps_new > 0 THEN
             v_tot_new_gaps  := 1;
          END IF;

          IF rv_calc_distbn_gaps.tot_gaps_closed > 0 THEN
             v_tot_closed_gaps  := 1;
          END IF;
       END IF;
       CLOSE csr_calc_distbn_gaps;

       BEGIN

          -- Insert a new distribution fact record
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
               rv_efex_distbn_xactn.mars_week_end_date,
               rv_efex_distbn_xactn.cust_dtl_code,
               rv_efex_distbn_xactn.efex_matl_id,
               rv_efex_distbn_xactn.distbn_yyyyppw,
               rv_efex_distbn_xactn.distbn_yyyypp,
               rv_efex_distbn_xactn.company_code,
               rv_efex_distbn_xactn.distbn_xactn_code,
               rv_efex_distbn_xactn.distbn_code,
               rv_efex_distbn_xactn.efex_cust_id,
               rv_efex_distbn_xactn.sales_terr_code,
               rv_efex_distbn_xactn.efex_sales_terr_id,
               rv_efex_distbn_xactn.efex_sgmnt_id,
               rv_efex_distbn_xactn.efex_bus_unit_id,
               rv_efex_distbn_xactn.efex_matl_subgrp_id,
               rv_efex_distbn_xactn.efex_matl_grp_id,
               rv_efex_distbn_xactn.efex_assoc_id,
               rv_efex_distbn_xactn.efex_range_id,
               rv_efex_distbn_xactn.gap,  -- take the latest gap as the weekly tot_gaps
               v_tot_new_gaps,
               v_tot_closed_gaps,
               rv_efex_distbn_xactn.rqd_flg_code,
               rv_efex_distbn_xactn.facing_qty,
               rv_efex_distbn_xactn.display_qty,
               rv_efex_distbn_xactn.rqd,
               rv_efex_distbn_xactn.ranged,
               rv_efex_distbn_xactn.gap,
               rv_efex_distbn_xactn.gap_new,
               rv_efex_distbn_xactn.gap_closed,
               rv_efex_distbn_xactn.eop_flg
            );

            v_ins_count := v_ins_count + SQL%ROWCOUNT;
       EXCEPTION
          WHEN DUP_VAL_ON_INDEX then
             BEGIN
               UPDATE efex_distbn_fact
               SET
                 sales_terr_code = rv_efex_distbn_xactn.sales_terr_code,
                 efex_sales_terr_id = rv_efex_distbn_xactn.efex_sales_terr_id,
                 efex_sgmnt_id = rv_efex_distbn_xactn.efex_sgmnt_id,
                 efex_assoc_id = rv_efex_distbn_xactn.efex_assoc_id,
                 distbn_xactn_code = rv_efex_distbn_xactn.distbn_xactn_code,
                 efex_matl_subgrp_id = rv_efex_distbn_xactn.efex_matl_subgrp_id,
                 efex_matl_grp_id = rv_efex_distbn_xactn.efex_matl_grp_id,
                 tot_gaps = rv_efex_distbn_xactn.gap,
                 tot_gaps_new = v_tot_new_gaps,
                 tot_gaps_closed = v_tot_closed_gaps,
                 rqd_flg_code = rv_efex_distbn_xactn.rqd_flg_code,
                 facing_qty = rv_efex_distbn_xactn.facing_qty,
                 display_qty = rv_efex_distbn_xactn.display_qty,
                 rqd = rv_efex_distbn_xactn.rqd,
                 ranged = rv_efex_distbn_xactn.ranged,
                 gap = rv_efex_distbn_xactn.gap,
                 gap_new = rv_efex_distbn_xactn.gap_new,
                 gap_closed = rv_efex_distbn_xactn.gap_closed
               WHERE
                 mars_week_end_date = rv_efex_distbn_xactn.mars_week_end_date
                 AND cust_dtl_code = rv_efex_distbn_xactn.cust_dtl_code
                 AND efex_matl_id = rv_efex_distbn_xactn.efex_matl_id;

               write_log(ods_constants.data_type_efex_distbn, 'ERROR', i_log_level + 2, 'Duplicated Insert for date/cust code/matl [' || rv_efex_distbn_xactn.mars_week_end_date ||
                          '/' ||  rv_efex_distbn_xactn.cust_dtl_code || '/' || rv_efex_distbn_xactn.efex_matl_id || '] ERROR - ' || SUBSTR(SQLERRM, 1, 512));
             END;

          WHEN OTHERS then

              write_log(ods_constants.data_type_efex_distbn, 'ERROR', i_log_level + 2, 'Error from Other Insert for date/cust code/matl [' || rv_efex_distbn_xactn.mars_week_end_date ||
                          '/' ||  rv_efex_distbn_xactn.cust_dtl_code || '/' || rv_efex_distbn_xactn.efex_matl_id || '] ERROR - ' || SUBSTR(SQLERRM, 1, 512));

              RAISE e_processing_error;

       END;

       -- Update any weekly snapshot has already been created in case any changes
       -- made to sales territory or customer.
       UPDATE
         efex_distbn_fact
       SET
         cust_dtl_code = rv_efex_distbn_xactn.cust_dtl_code,
         sales_terr_code = rv_efex_distbn_xactn.sales_terr_code,
         efex_sales_terr_id = rv_efex_distbn_xactn.efex_sales_terr_id,
         efex_sgmnt_id = rv_efex_distbn_xactn.efex_sgmnt_id,
         efex_assoc_id = rv_efex_distbn_xactn.efex_assoc_id
       WHERE
         efex_cust_id = rv_efex_distbn_xactn.efex_cust_id
         AND efex_matl_id = rv_efex_distbn_xactn.efex_matl_id
         AND mars_week_end_date > rv_efex_distbn_xactn.mars_week_end_date;

       v_upd_count := v_upd_count + SQL%ROWCOUNT;
       v_commit_count := v_commit_count + 1;

       if ( v_commit_count >= c_commit_block ) then
         commit;
         v_commit_count := 0;
       end if;

    EXCEPTION
          WHEN OTHERS THEN
               write_log(ods_constants.data_type_efex_distbn, 'ERROR', i_log_level + 2, 'Error Record date/cust code/matl [' || rv_efex_distbn_xactn.mars_week_end_date ||
                          '/' ||  rv_efex_distbn_xactn.cust_dtl_code || '/' || rv_efex_distbn_xactn.efex_matl_id || '] ERROR - ' || SUBSTR(SQLERRM, 1, 512));
          RAISE e_processing_error;

    END;
  END LOOP;

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
             'SCHEDULED_EFEX_AGGREGATION.efex_tot_distbn_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_tot_distbn_fact_aggr;


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
             'SCHEDULED_EFEX_AGGREGATION.EFEX_TURNIN_ORDER_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_pmt_deal_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_pmt_rtn_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.efex_mrq_matl_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_mrq_matl_fact_aggr;


FUNCTION efex_distbn_fact_wkly_snapshot (
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
                       WHERE calendar_date = v_aggregation_date)
      AND mars_day_of_week = 7
      AND t1.mars_period = t2.mars_period;

    rv_mars_date csr_mars_date%ROWTYPE;

BEGIN

  -- Starting create snapshot for a week if it is the first date of a mars_week.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Start - Create Weekly EFEX_DISTBN_FACT snapshot');

  -- Use current date as the aggregation_date we need to check the first day of the current week
  v_aggregation_date := TRUNC(sysdate);

  OPEN csr_mars_date;
  FETCH csr_mars_date INTO rv_mars_date;
  CLOSE csr_mars_date;

    v_this_mars_week_end_date := rv_mars_date.calendar_date;

    write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level, 'Create weekly distribution snapshot for this week end date [' || v_this_mars_week_end_date || '] ' ||
                  ' and those customer material has not been created yet');

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
              'SCHEDULED_EFEX_AGGREGATION.efex_distbn_fact_wkly_snapshot: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END efex_distbn_fact_wkly_snapshot;


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
             'SCHEDULED_EFEX_AGGREGATION.efex_assoc_sgmnt_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_assoc_sgmnt_fact_aggr;


FUNCTION efex_cust_fact_aggr (
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
      calendar_date = trunc(sysdate);

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
              to_date(t1.cust_note_created) as cust_note_created
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
             'SCHEDULED_EFEX_AGGREGATION.efex_cust_note_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

    RETURN constants.error;
END efex_cust_note_fact_aggr;

FUNCTION efex_cust_opp_distbn_fact_aggr (
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
    WHERE t1.calendar_date = v_aggregation_date
      AND t1.mars_period = t2.mars_period;
  rv_mars_date csr_mars_date%ROWTYPE;

BEGIN
  -- Starting create weekly customer level opportunity distribution gap counts.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Start - Create Weekly EFEX_CUST_opprtnty_DISTBN_FACT snapshot');

  -- Use current date as the aggregation_date we need to do snapshot for this mars week
  v_aggregation_date := TRUNC(sysdate);

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
              'SCHEDULED_EFEX_AGGREGATION.EFEX_CUST_OPP_DISTBN_FACT_AGGR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END efex_cust_opp_distbn_fact_aggr;

FUNCTION efex_matl_opp_distbn_fact_aggr (
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
    WHERE t1.calendar_date = v_aggregation_date
      AND t1.mars_period = t2.mars_period;
  rv_mars_date csr_mars_date%ROWTYPE;

BEGIN
  -- Starting create weekly material level opportunity distribution gap counts.
  write_log(ods_constants.data_type_efex_distbn, 'N/A', i_log_level + 1, 'Start - Create Weekly EFEX_MATL_opprtnty_DISTBN_FACT snapshot');

  -- Use current date as the aggregation_date, we do snapshot for current mars week.
  v_aggregation_date := TRUNC(sysdate);

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
              'SCHEDULED_EFEX_AGGREGATION.efex_matl_opp_distbn_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END efex_matl_opp_distbn_fact_aggr;


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
             'SCHEDULED_EFEX_AGGREGATION.efex_target_fact_aggr: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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
             'SCHEDULED_EFEX_AGGREGATION.format_cust_code: ERROR: ' || SUBSTR(SQLERRM, 1, 512));

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

END scheduled_efex_aggregation;
/
