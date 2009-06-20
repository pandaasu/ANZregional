CREATE OR REPLACE PACKAGE pds_ap_claims_01_int IS

/*******************************************************************************
  NAME:      run_pds_ap_claims_01_int
  PURPOSE:   To Initiate the AP Claims interface process, the first step in the process
             is to run a Postbox job. This is done by creating a Job Control record,
             created via the Create_Promax_Job_Control utility function.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/09/2005 Ann-Marie Ingeme     Created this procedure.
  2.0   20/06/2009 Steve Gregan         Added create log.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_ap_claims_01_int;

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

END pds_ap_claims_01_int;
/


CREATE OR REPLACE PACKAGE BODY pds_ap_claims_01_int IS

  -- PACKAGE VARIABLE DECLARATIONS.
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS.
  pc_alert_level_minor         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_debug                     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_job_type_ap_claims_01_int CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims_01_int','JOB_TYPE');
  pc_data_type_ap_claims       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims','DATA_TYPE');
  pc_pstbx_ap_claims_extract   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims_extract','PSTBX');
  pc_job_status_completed      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');

PROCEDURE run_pds_ap_claims_01_int IS

  -- VARIABLE DECLARATIONS.
  v_count NUMBER; -- Generic counter.

BEGIN

  -- Start run_pds_ap_claims_01_int procedure.
  pds_utils.create_log;
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level,'run_pds_ap_claims_01_int - START.');

  -- Do not initiate the AP Claims interface if any APCLAIM job control
  -- records exist with a status other than COMPLETED.
  SELECT count(*) INTO v_count
  FROM
    pds_pmx_job_cntl
  WHERE
    pmx_job_cnfgn_id in (pc_pstbx_ap_claims_extract)
  AND job_status <> pc_job_status_completed;

  IF v_count > 0 THEN
    -- There is an AP Claims Upload interface running.
    pv_result_msg := 'ERROR: The APCLAIM interface cannot be started. ' ||
      'APCLAIM* Job Control records exist status <> COMPLETED. ' ||
      'This indicates that there is an in progress interface and/or failed interface(s).';
    -- Write error to PDS_LOG table.
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level,pv_result_msg);
    -- Send alert message via e-mail.
	pds_utils.send_email_to_group(pc_job_type_ap_claims_01_int,'MFANZ Promax AP Claims Interface 01',
      pv_result_msg);
  ELSE
    -- There are not any AP Claims postbox jobs running
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'Initiating AP Claims interface by creating APCLAIM_CONFIRM job control record.');
    pds_utils.create_promax_job_control(pc_pstbx_ap_claims_extract);
  END IF;

  -- End run_pds_ap_claims_01_int procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level,'run_pds_ap_claims_01_int - END.');

EXCEPTION
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_INT.RUN_PDS_APCLAIMS_01_INT:',
      'Unexpected Exception - run_pds_ap_claims_01_int aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_int,'MFANZ Promax APClaims Interface 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_int,'N/A');
    END IF;
END run_pds_ap_claims_01_int;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table
  pds_utils.log(pc_job_type_ap_claims_01_int,
                i_data_type,
                i_sort_field,
                i_log_level,
                i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;

END pds_ap_claims_01_int;
/
