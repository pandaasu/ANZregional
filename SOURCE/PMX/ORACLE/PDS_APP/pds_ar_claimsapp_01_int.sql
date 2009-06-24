CREATE OR REPLACE PACKAGE pds_ar_claimsapp_01_int IS

/*******************************************************************************
  NAME:      pds_ar_claimsapp_01_int
  PURPOSE:   Also referred to as "Short Payment" or "Authorised Claims", the
             AR Claims Approval interface transfers approved Promotional Claims
             from Promax and sends to multiple downstream applications; Atlas for
             MFANZ Australia Food and MFANZ New Zealand, and legacy applications
             for MFANZ Australia Petcare and Snack.

             The interface executes a single Promax Postbox job, which processes
             Promax data and loads into the Postbox. The pds_ar_claimsapp_01_prc procedure
             is then executed to extract the data in the right format and send it to the
             target system.

             Specifically, the procedure starts the interface processing by
             triggering the first component of the interface; the execution of the
             Promax job which moves approved claims into the postbox. This is
             achieved by creating record in the Promax Job Control table (via the
             pds_utils.create_promax_job_control procedure).

             Subsequent management of the interface is controlled via the
             pds_controller package.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/10/2005 Ann-Marie Ingeme     Created this procedure.
  2.0   10/06/2009 Steve Gregan         Added create log.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_ar_claimsapp_01_int;

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

END pds_ar_claimsapp_01_int;
/


CREATE OR REPLACE PACKAGE BODY pds_ar_claimsapp_01_int IS

  -- PACKAGE VARIABLE DECLARATIONS
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_job_type_arclaimsapp_01_int CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('arclaimsapp_01_int','JOB_TYPE');
  pc_data_type_ar_claimsapp      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp','DATA_TYPE');
  pc_pstbx_ar_claimsapp_load     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp_load','PSTBX');
  pc_job_status_completed        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');

PROCEDURE run_pds_ar_claimsapp_01_int IS

  -- VARIABLE DECLARATIONS
  v_count NUMBER; -- Generic counter.

BEGIN

  -- Start run_pds_ar_claimsapp_01_int procedure.
  pds_utils.create_log;
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level,'run_pds_ar_claimsapp_01_int - START.');

  -- Do not initiate the AR Claims Approval interface if any AR Claims Approval job control
  -- records exist with a status other than COMPLETED.
  SELECT count(*) INTO v_count
  FROM
    pds_pmx_job_cntl
  WHERE
    pmx_job_cnfgn_id in (pc_pstbx_ar_claimsapp_load)
    AND job_status <> pc_job_status_completed;

  IF v_count > 0 THEN
    -- There is an AR Claims Approval Load interface running.
    pv_result_msg := 'ERROR: An AR Claims ApprovaL Load interface cannot be started. ' ||
      'AR_CLAIMSAPP_LOAD Job Control records exist status <> COMPLETED. ' ||
      'This indicates that there is an in progress intefrace and/or failed interface(s).';
    -- Write error to PDS_LOG table.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level,pv_result_msg);
    -- Send alert message via e-mail.
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_int,'MFANZ Promax AR Claims Approval Load Interface 01',
    pv_result_msg);
  ELSE
    -- There are not any AR Claims Approval Load postbox jobs running
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level,'Initiating AR Claims Load interface by creating AR_CLAIMSAPP_LOAD job control record.');
    pds_utils.create_promax_job_control(pc_pstbx_ar_claimsapp_load);
  END IF;

  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level,'run_pds_ar_claimsapp_01_int - END.');
  pds_utils.end_log;

END run_pds_ar_claimsapp_01_int;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table
  pds_utils.log(pc_job_type_arclaimsapp_01_int,
                i_data_type,
                i_sort_field,
                i_log_level,
                i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;

END pds_ar_claimsapp_01_int;
/
