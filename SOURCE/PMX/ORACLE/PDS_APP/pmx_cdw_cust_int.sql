CREATE OR REPLACE PACKAGE pmx_cdw_cust_int IS

/*******************************************************************************
  NAME:      run_pmx_cdw_cust_int
  PURPOSE:   Interface customer data to the data warehouse.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/01/2007 Cynthia Ennis        Created this procedure.
  2.0   20/10/2009 Steve Gregan         Added create log.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pmx_cdw_cust_int;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the PDS_LOG table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   07/08/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Data Type                            Vendor
  2    IN     VARCHAR2 Sort Field                           Vendor Code
  3    IN     NUMBER   Log Level                            1
  4    IN     VARCHAR2 Log Text                             Inserting into table

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE);

END pmx_cdw_cust_int;
/


CREATE OR REPLACE PACKAGE BODY pmx_cdw_cust_int IS

  -- PACKAGE VARIABLE DECLARATIONS
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_job_type_pmx_cdw_cust_int CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant ('pmx_cdw_cust_int', 'JOB_TYPE');
  pc_data_type_customer        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant ('cust', 'DATA_TYPE');
  pc_debug                     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant ('debug_flag', 'DEBUG_FLAG');
  pc_alert_level_critical      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant ('level_critical', 'ALERT');

  PROCEDURE run_pmx_cdw_cust_int IS

    -- VARIABLE DECLARATIONS
    v_count   NUMBER;

  BEGIN
    -- Start run_pmx_cdw_cust_int procedure.
    pds_utils.create_log;
    write_log (pc_data_type_customer, 'N/A', pv_log_level, 'run_pmx_cdw_cust_int - START.');

    -- Trigger the pmx_cdw_cust_prc procedure.
    write_log (pc_data_type_customer, 'N/A', pv_log_level, 'Trigger the PMX_CDW_CUST_PRC procedure.');
    lics_trigger_loader.EXECUTE ('MFANZ Promax Customer to CDW Process',
                                 'pds_app.pmx_cdw_cust_prc.run_pmx_cdw_cust_prc',
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_ALERT', 'PMX_CDW_CUST_PRC'),
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_EMAIL_GROUP', 'PMX_CDW_CUST_PRC'),
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_GROUP', 'PMX_CDW_CUST_PRC')
                                );

    -- End run_pmx_cdw_cust_int procedure.
    write_log (pc_data_type_customer, 'N/A', pv_log_level, 'run_pmx_cdw_cust_int - END.');
    pds_utils.end_log;
  EXCEPTION
    WHEN OTHERS THEN
      pv_result_msg :=
         utils.create_failure_msg ('PMX_CDW_CUST_INT.RUN_PMX_CDW_CUST_INT:', 'Unexpected Exception - run_pmx_cdw_cust_int aborted.') || utils.create_params_str ()
         || utils.create_sql_err_msg ();
      write_log (pc_data_type_customer, 'N/A', pv_log_level, pv_result_msg);
      pds_utils.send_email_to_group (pc_job_type_pmx_cdw_cust_int, 'MFANZ Promax Customer to CDW Interface', pv_result_msg);

      IF pc_debug != 'TRUE' THEN
        -- Send alert message via Tivoli if running in production.
        pds_utils.send_tivoli_alert (pc_alert_level_critical, pv_result_msg, pc_job_type_pmx_cdw_cust_int, 'N/A');
      END IF;
    pds_utils.end_log;
  END run_pmx_cdw_cust_int;

  PROCEDURE write_log (
    i_data_type IN pds_log.data_type%TYPE,
    i_sort_field IN pds_log.sort_field%TYPE,
    i_log_level IN pds_log.log_level%TYPE,
    i_log_text IN pds_log.log_text%TYPE) IS

  BEGIN
    -- Write the entry into the PDS_LOG table
    pds_utils.LOG (pc_job_type_pmx_cdw_cust_int, i_data_type, i_sort_field, i_log_level, i_log_text);

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END write_log;

END pmx_cdw_cust_int;
/
