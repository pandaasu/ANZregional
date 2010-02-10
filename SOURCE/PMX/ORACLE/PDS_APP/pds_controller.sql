CREATE OR REPLACE PACKAGE pds_controller IS

/*******************************************************************************
  NAME:      process_control
  PURPOSE:   The procedure is run as a DAEMON. Only one instance of Process Control
             should be running at any one time.
          
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.
  1.1   14/07/2006 Craig Ford           Comment out the calls to Petcare Procedures (03)
                                         as these will all be processed as part of the
                                         Atlas procedures (01).
  1.2   17/07/2006 Craig Ford           Petcare Procedures (03) Code removed.
  1.3   19/06/2007 Craig Ford           Refer AP0108T (re: CLAIMS_MANUAL_LOAD_01)
  1.4   19/07/2007  Anna Every          Removed Purge of Snack records.
  1.5   29/11/2007 Craig Ford           Snackfood Procedures (02) Code removed.
  2.0   10/06/2009 Steve Gregan         Added create log.
  2.1   10/12/2009 Steve Ostler         Modified check_prom_divparam_confirm procedure to 
  				   		 				run only if its the third last day of the period.
										previously ran on the 26th day of the period but 
										this did not work for 5 week periods.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE process_control;

/*******************************************************************************
  NAME:      check_accrls_truncate
  PURPOSE:   This procedure updates any ACCRUALS_TRUNCATE job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was SUBMITTED.
             If at least one job_status was SUBMITTED, then it truncates the CLAIMBAK,
             CLMDETBAK, PROMOBAK and PROMDETBAK tables and deletes accrual data from
             the EXACCURALS table, then it checks EXACCRUALS to confirm that it is
             empty, if it isnt an alert is raised and the job stops, otherwise, it
             creates a job control record for ACCRLS_FREEZE.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_accrls_truncate;

/*******************************************************************************
  NAME:      check_accrls_freeze
  PURPOSE:   This procedure updates any ACCRLS_FREEZE job_status's in the
             PDS_PMX_JOB_CNTL table to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, then it creates a Promax
             job control record for ACCRLS_EXPORT.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_accrls_freeze;

/*******************************************************************************
  NAME:      check_accrls_export
  PURPOSE:   This procedure updates any ACCRLS_EXPORT job_status's in the
             PDS_PMX_JOB_CNTL table to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, then it triggers the
             PDS_ACCRUALS_01_PRC and PDS_ACCRUALS_SUMM_REPORT procedures.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.
  1.1   30/01/2006 Craig Ford           Remove the delete of Petcare Accruals
                                         (from the BAK tables) as part of the PET
                                         ATLAS implementation.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_accrls_export;

/*******************************************************************************
  NAME:      check_ap_claims_extract
  PURPOSE:   This procedure updates any AP_CLAIMS_EXTRACT job_status's in the
             PDS_PMX_JOB_CNTL table to COMPLETED where the job_status was SUBMITTED.
             If at least one job_status was SUBMITTED, then it triggers the
             PDS_AP_CLAIMS_01_PRC procedure.

             NOTE: The CHECK_AR_CLAIMSAPP_LOAD procedure inserts the AP_CLAIMS_EXTRACT
             entry into the PDS_PMX_JOB_CNTL table.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_ap_claims_extract;

/*******************************************************************************
  NAME:      check_ar_claims_load_01
  PURPOSE:   This procedure updates any AR_CLAIMS_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_ar_claims_load_01;

/*******************************************************************************
  NAME:      check_ar_claims_load_04
  PURPOSE:   This procedure updates any AR_CLAIMS_LOAD_04 job_status's in the
             PDS_PMX_JOB_CNTL table to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_ar_claims_load_04;

/*******************************************************************************
  NAME:      check_cust_load
  PURPOSE:   This procedure updates any CUST_LOAD job_status's in the
             PDS_PMX_JOB_CNTL table to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_cust_load;

/*******************************************************************************
  NAME:      check_brand_load_01
  PURPOSE:   This procedure updates any BRAND_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, it creates a job control
             record for RANGE_LOAD_01.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_brand_load_01;

/*******************************************************************************
  NAME:      check_range_load_01
  PURPOSE:   This procedure updates any RANGE_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, it creates a job control
             record for CAT_LOAD_01.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_range_load_01;

/*******************************************************************************
  NAME:      check_cat_load_01
  PURPOSE:   This procedure updates any CAT_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, it creates a job control
             record for MATL_LOAD_01.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_cat_load_01;

/*******************************************************************************
  NAME:      check_matl_load_01
  PURPOSE:   This procedure updates any MATL_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_matl_load_01;

/*******************************************************************************
  NAME:      check_pricelist_load_01
  PURPOSE:   This procedure updates any PRICELIST_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_pricelist_load_01;

/*******************************************************************************
  NAME:      check_prom_divparam_confirm
  PURPOSE:   This procedure updates any PROM_DIVPARAM_CONFIRM job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was SUBMITTED.
             If at least one job_status was SUBMITTED, it checks if todays date is
             day 26 of the period (ie Thursday of Week4), if so then it updates the
             DIVPARAM.DIVVALUE to 2 in preperation for end-of-period processing and it
             then create a job control record for PROM_CONFIRM.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_prom_divparam_confirm;

/*******************************************************************************
  NAME:      check_prom_confirm
  PURPOSE:   This procedure updates any PROM_CONFIRM job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, it creates a job control
             record for PROM_ACTIVE.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_prom_confirm;

/*******************************************************************************
  NAME:      check_prom_active
  PURPOSE:   This procedure updates any PROM_ACTIVE job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, it creates a job control
             record for PROM_DIVPARAM_ACTIVE.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_prom_active;

/*******************************************************************************
  NAME:      check_prom_divparam_active
  PURPOSE:   This procedure updates any PROM_DIVPARAM_ACTIVE job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was SUBMITTED.
             If at least one job_status was SUBMITTED, it checks the DIVPARAM.DIVVALUE
             to see it is equal to 2, if it is it updates it to 0, it then creates a
             job control record for PROM_LOAD.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_prom_divparam_active;

/*******************************************************************************
  NAME:      check_prom_load
  PURPOSE:   This procedure updates any PROM_LOAD job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, then it triggers the
             PDS_PROM_01_PRC procedure.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_prom_load;

/*******************************************************************************
  NAME:      check_prom_act_load_01
  PURPOSE:   This procedure updates any PROM_ACT_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_prom_act_load_01;

/*******************************************************************************
  NAME:      check_sales_load_01
  PURPOSE:   This procedure updates any SALES_LOAD_01 job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_sales_load_01;

/*******************************************************************************
  NAME:      check_ar_claimsapp_load
  PURPOSE:   This procedure updates any AR_CLAIMSAPP_LOAD job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.
             If at least one job_status was PROCESSED, then it triggers the
             PDS_AR_CLAIMSAPP_01_PRC and PDS_AP_CLAIMS_01_INT procedures.

             The PDS_AP_CLAIMS_01_INT interface is also triggered, as the AR_CLAIMSAPP_LOAD
             Postbox job extracts both AR Claims Approvals and AP Claims from Promax into
             the EXACCRUALS table. Therefore, the AP Claims interface should always be
             executed immediately following the AR Claims Approval interface.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_ar_claimsapp_load;

/*******************************************************************************
  NAME:      check_scan_qty_update
  PURPOSE:   This procedure updates any SCAN_QTY_UPDATE job_status's in the
             PDS_PMX_JOB_CNTL table, to COMPLETED where the job_status was PROCESSED.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   22/12/2005 Paul Jacobs          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None.

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE check_scan_qty_update;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the PDS_LOG table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/08/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Job Type                             Interface
  2    IN     VARCHAR2 Data Type                            Vendor
  3    IN     VARCHAR2 Sort Field                           Vendor Code
  4    IN     NUMBER   Log Level                            1
  5    IN     VARCHAR2 Log Text                             Inserting into table

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE);

END pds_controller;
/


CREATE OR REPLACE PACKAGE BODY pds_controller IS

  -- PACKAGE VARIABLE DECLARATIONS
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;

  -- PACKAGE CONSTANT DECLARATIONS.
  pc_job_type_pds_controller    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pds_controller','JOB_TYPE');
  pc_data_type_not_applicable   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_applicable','DATA_TYPE');
  pc_pstbx_prom_divparam_confm  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('prom_divparam_confm','PSTBX');
  pc_pstbx_prom_confirm         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('prom_confirm','PSTBX');
  pc_pstbx_prom_active          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('prom_active','PSTBX');
  pc_pstbx_prom_divparam_active CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('prom_divparam_active','PSTBX');
  pc_pstbx_prom_load            CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('prom_load','PSTBX');
  pc_pstbx_accrls_truncate      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('accrls_truncate','PSTBX');
  pc_pstbx_accrls_freeze        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('accrls_freeze','PSTBX');
  pc_pstbx_accrls_export        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('accrls_export','PSTBX');
  pc_pstbx_ar_claimsapp_load    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp_load','PSTBX');
  pc_pstbx_ar_claims_load_01    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claims_load_01','PSTBX');
  pc_pstbx_ar_claims_load_04    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claims_load_04','PSTBX');
  pc_pstbx_ap_claims_extract    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims_extract','PSTBX');
  pc_pstbx_cust_load            CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_load','PSTBX');
  pc_pstbx_brand_load_01        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('brand_load_01','PSTBX');
  pc_pstbx_range_load_01        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('range_load_01','PSTBX');
  pc_pstbx_cat_load_01          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cat_load_01','PSTBX');
  pc_pstbx_matl_load_01         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('matl_load_01','PSTBX');
  pc_pstbx_pricelist_load_01    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pricelist_load_01','PSTBX');
  pc_pstbx_prom_act_load_01     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('prom_act_load_01','PSTBX');
  pc_pstbx_sales_load_01        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('sales_load_01','PSTBX');
  pc_pstbx_scan_qty_update      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('scan_qty_update','PSTBX');
  pc_job_status_submitted       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('submitted','JOB_STATUS');
  pc_job_status_processed       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('processed','JOB_STATUS');
  pc_job_status_completed       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');
  pc_divparam_divvalue_begin    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('divvalue_begin','DIVPARAM');
  pc_divparam_divvalue_end      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('divvalue_end','DIVPARAM');
  pc_divparam_setting_transfer  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('setting_transfer','DIVPARAM');
  pc_accrls_export              CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('export','ACCRLS');
  pc_accrls_accrl_bal           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('accrl_bal','ACCRLS');
  pc_debug                      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_critical       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_critical','ALERT');
  pc_alert_level_minor          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');

PROCEDURE process_control IS

BEGIN
  -- Start Process Control procedure.
  pds_utils.create_log;
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Process Control - Start');

  -- Check for ACCRLS_TRUNCATE job control records with a status of SUBMITTED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for ACCRLS_TRUNCATE job control records with a status of SUBMITTED.');
  check_accrls_truncate();

  -- Check for ACCRLS_FREEZE job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for ACCRLS_FREEZE job control records with a status of PROCESSED.');
  check_accrls_freeze();

  -- Check for ACCRLS_EXPORT job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for ACCRLS_EXPORT job control records with a status of PROCESSED.');
  check_accrls_export();

  -- Check for AP_CLAIMS_EXTRACT job control records with a status of SUBMITTED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for AP_CLAIMS_EXTRACT job control records with a status of SUBMITTED.');
  check_ap_claims_extract();

  -- Check for AR_CLAIMS_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for AR_CLAIMS_LOAD_01 job control records with a status of PROCESSED.');
  check_ar_claims_load_01();

  -- Check for AR_CLAIMS_LOAD_04 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for AR_CLAIMS_LOAD_04 job control records with a status of PROCESSED.');
  check_ar_claims_load_04();

  -- Check for CUST_LOAD job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for CUST_LOAD job control records with a status of PROCESSED.');
  check_cust_load();

  -- Check for BRAND_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for BRAND_LOAD_01 job control records with a status of PROCESSED.');
  check_brand_load_01();

  -- Check for RANGE_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for RANGE_LOAD_01 job control records with a status of PROCESSED.');
  check_range_load_01();

  -- Check for CAT_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for CAT_LOAD_01 job control records with a status of PROCESSED.');
  check_cat_load_01();

  -- Check for MATL_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for MATL_LOAD_01 job control records with a status of PROCESSED.');
  check_matl_load_01();

  -- Check for PRICELIST_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for PRICELIST_LOAD_01 job control records with a status of PROCESSED.');
  check_pricelist_load_01();

  -- Check for PROM_DIVPARAM_CONFIRM job control records with a status of SUBMITTED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for PROM_DIVPARAM_CONFIRM job control records with a status of SUBMITTED.');
  check_prom_divparam_confirm();

  -- Check for PROM_CONFIRM job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for PROM_CONFIRM job control records with a status of PROCESSED.');
  check_prom_confirm();

  -- Check for PROM_ACTIVE job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for PROM_ACTIVE job control records with a status of PROCESSED.');
  check_prom_active();

  -- Check for PROM_DIVPARAM_ACTIVE job control records with a status of SUBMITTED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for PROM_DIVPARAM_ACTIVE job control records with a status of SUBMITTED.');
  check_prom_divparam_active();

  -- Check for PROM_LOAD job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for PROM_LOAD job control records with a status of PROCESSED.');
  check_prom_load();

  -- Check for PROM_ACT_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for PROM_ACT_LOAD_01 job control records with a status of PROCESSED.');
  check_prom_act_load_01();

  -- Check for SALES_LOAD_01 job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for SALES_LOAD_01 job control records with a status of PROCESSED.');
  check_sales_load_01();

  -- Check for AR_CLAIMSAPP_LOAD job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for AR_CLAIMSAPP_LOAD job control records with a status of PROCESSED.');
  check_ar_claimsapp_load();

  -- Check for SCAN_QTY_UPDATE job control records with a status of PROCESSED.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking for SCAN_QTY_UPDATE job control records with a status of PROCESSED.');
  check_scan_qty_update();

  -- End Process Control procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Process Control - End');
  pds_utils.end_log;

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.PROCESS_CONTROL:',
        'Unexpected Exception - process_control aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;
    pds_utils.end_log;

END process_control;


PROCEDURE check_accrls_truncate IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_accrls_truncate
      AND job_status = pc_job_status_submitted
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

  -- Select record count from Exaccruals.
  CURSOR csr_exaccruals IS
    SELECT count(*) as rec_count
    FROM exaccruals;
    rv_exaccruals csr_exaccruals%ROWTYPE;

BEGIN
  -- Start check_accrls_truncate procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_accrls_truncate - START.');

  -- Check to see whether there is one or more ACCRLS_TRUNCATE control records with
  -- a status of SUBMITTED. If there are multiple SUBMITTED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''ACCRLS_TRUNCATE'' Promax Job Control records exist with a status of SUBMITTED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from SUBMITTED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from SUBMITTED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, then truncate the .BAK tables and remove
  all Accruals from the EXACCRUALS table.  Then initiate the next part of the interface
  by creating a ACCRLS_FREEZE job control record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Truncate the Promax .BAK tables.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Truncating CLAIMBAK table.');
    truncate_promax_table.truncate_claimbak;

    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Truncating CLMDETBAK table.');
    truncate_promax_table.truncate_clmdetbak;

    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Truncating PROMOBAK table.');
    truncate_promax_table.truncate_promobak;

    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Truncating PROMDETBAK table.');
    truncate_promax_table.truncate_promdetbak;

    /*
    Delete Accrual data from the EXACCRUALS table. IMPORTANT NOTE: The EXACCRUALS table
    is not truncated as this is used by most Promax transaction based interfaces, both
    incoming and outgoing, so it contains a variety of transaction types (not just Accruals).
    */
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Deleting Accrual data from EXACCRUALS table.');
    DELETE FROM exaccruals
    WHERE direction = pc_accrls_export
    AND datatype = pc_accrls_accrl_bal;

    -- Check that the EXACCRUALS table is now empty. If not, then stop processing and
    -- raise an alert as this means there are unprocessed claims.
    OPEN csr_exaccruals;
    FETCH csr_exaccruals INTO rv_exaccruals;
    -- If there are records in the EXACCRUALS table then raise an alert.
    IF rv_exaccruals.rec_count > 0 THEN
      pv_processing_msg := 'Records exist in the EXACCRUALS table. This means there are unprocessed claims.';
      RAISE e_processing_failure;
    END IF;
    CLOSE csr_exaccruals;

    -- Commit the transaction.
    COMMIT;

    -- Create ACCRLS_FREEZE record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_accrls_freeze, pv_log_level);
  END IF;

  -- End check_accrls_truncate procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_accrls_truncate - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CONTROLLER.CHECK_ACCRLS_TRUNCATE:',
        pv_processing_msg);
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_critical,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_ACCRLS_TRUNCATE:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_critical,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_accrls_truncate;


PROCEDURE check_accrls_freeze IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_accrls_freeze
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_accrls_freeze procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_accrls_freeze - START.');

  -- Check to see whether there is one or more ACCRLS_FREEZE control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''ACCRLS_FREEZE'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by creating a ACCRLS_EXPORT job control record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    /*
    Delete Australia Snackfood data from the BAK tables, as issues have been
    encountered with rollback segment space.  This data is not required in the
    Accruals interface, and therefore can be removed.

    Note: A SIR (System Investigation Request) is outstanding with PAG regarding the
    rollback segment error with the Accruals Export Postbox job.
    */

    -- Delete Australia Snackfood data from the BAK tables.
    -- pr_app.purge_claimdetbak ('01', '002'); -- Removed by Anna Every 19/07/2007 for Promax 1.10.6.8

    -- Create ACCRLS_EXPORT record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_accrls_export, pv_log_level);
  END IF;

  -- End check_accrls_freeze procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_accrls_freeze - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_ACCRLS_FREEZE:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_critical,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_accrls_freeze;


PROCEDURE check_accrls_export IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_accrls_export
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_accrls_export procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_accrls_export - START.');

  -- Check to see whether there is one or more ACCRLS_EXPORT control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''ACCRLS_EXPORT'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by triggering the PDS_ACCRUALS_01_PRC processing daemon.  Also initiate the
  PDS_ACCRUALS_SUMM_REPORT procedure which emails the summary of Accrual totals.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Initiate the next part of the interface by triggering the PDS_ACCRUALS_01_PRC processing daemon.
    write_log(pc_data_type_not_applicable, 'N/A',pv_log_level, 'Trigger the pds_accruals_01_prc procedure.');
    lics_trigger_loader.execute('MFANZ Promax Accruals 01 Process',
                                'pds_app.pds_accruals_01_prc.run_pds_accruals_01_prc',
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_ACCRUALS_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_ACCRUALS_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_ACCRUALS_01_PRC'));

    -- Trigger the PDS_ACCRUALS_SUMM_REPORT procedure.
    write_log(pc_data_type_not_applicable, 'N/A',pv_log_level, 'Trigger the pds_accruals_summ_report procedure.');
    lics_trigger_loader.execute('MFANZ Promax Accruals Summary Report',
                                'pds_app.pds_accruals_summ_report.run_pds_accruals_summ_report',
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_ACCRUALS_SUMM_REPORT'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_ACCRUALS_SUMM_REPORT'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_ACCRUALS_SUMM_REPORT'));
  END IF;

  -- End check_accrls_export procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_accrls_export - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_ACCRLS_EXPORT:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_critical,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_accrls_export;


PROCEDURE check_ap_claims_extract IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_ap_claims_extract
      AND job_status = pc_job_status_submitted
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_ap_claims_extract procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ap_claims_extract - START.');

  -- Check to see whether there is one or more AP_CLAIMS_EXTRACT control records with a
  -- status of SUBMITTED. If there are multiple SUBMITTED records, set them all to
  -- COMPLETED, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''AP_CLAIMS_EXTRACT'' Promax Job Control records exist with a status of SUBMITTED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from SUBMITTED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from SUBMITTED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by triggering the PDS_AP_CLAIMS_01_PRC processing daemon.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Initiate the next part of the interface by triggering the PDS_AP_CLAIMS_01_PRC processing daemon.
    write_log(pc_data_type_not_applicable, 'N/A',pv_log_level, 'Trigger the pds_ap_claims_01_prc procedure.');
    lics_trigger_loader.execute('MFANZ Promax AP Claims 01 Process',
                                'pds_app.pds_ap_claims_01_prc.run_pds_ap_claims_01_prc',
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_AP_CLAIMS_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_AP_CLAIMS_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_AP_CLAIMS_01_PRC'));


  END IF;

  -- End check_ap_claims_extract procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ap_claims_extract - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_AP_CLAIMS_EXTRACT:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_ap_claims_extract;


PROCEDURE check_ar_claims_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_ar_claims_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_ar_claims_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ar_claims_load_01 - START.');

  -- Check to see whether there is one or more AR_CLAIMS_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''AR_CLAIMS_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_ar_claims_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ar_claims_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_AR_CLAIMS_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_ar_claims_load_01;


PROCEDURE check_ar_claims_load_04 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_ar_claims_load_04
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_ar_claims_load_04 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ar_claims_load_04 - START.');

  -- Check to see whether there is one or more AR_CLAIMS_LOAD_04 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''AR_CLAIMS_LOAD_04'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_ar_claims_load_04 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ar_claims_load_04 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_AR_CLAIMS_LOAD_04:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_ar_claims_load_04;


PROCEDURE check_cust_load IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_cust_load
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_cust_load procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_cust_load - START.');

  -- Check to see whether there is one or more CUST_LOAD control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''CUST_LOAD'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_cust_load procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_cust_load - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_CUST_LOAD:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_cust_load;


PROCEDURE check_brand_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_brand_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_brand_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_brand_load_01 - START.');

  -- Check to see whether there is one or more BRAND_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''BRAND_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by creating a RANGE_LOAD_01 job control record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Create RANGE_LOAD_01 record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_range_load_01, pv_log_level);
  END IF;

  -- End check_brand_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_brand_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_BRAND_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_brand_load_01;


PROCEDURE check_range_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_range_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_range_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_range_load_01 - START.');

  -- Check to see whether there is one or more RANGE_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''RANGE_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by creating a CAT_LOAD_01 job control record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Create CAT_LOAD_01 record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_cat_load_01, pv_log_level);
  END IF;

  -- End check_range_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_range_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_RANGE_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_range_load_01;


PROCEDURE check_cat_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_cat_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_cat_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_cat_load_01 - START.');

  -- Check to see whether there is one or more CAT_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''CAT_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by creating a MATL_LOAD_01 job control record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Create MATL_LOAD_01 record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_matl_load_01, pv_log_level);
  END IF;

  -- End check_cat_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_cat_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_CAT_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_cat_load_01;

PROCEDURE check_matl_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_matl_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_matl_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_matl_load_01 - START.');

  -- Check to see whether there is one or more MATL_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''MATL_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_matl_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_matl_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_MATL_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_matl_load_01;



PROCEDURE check_pricelist_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_pricelist_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_pricelist_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_pricelist_load_01 - START.');

  -- Check to see whether there is one or more PRICELIST_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''PRICELIST_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_pricelist_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_pricelist_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_PRICELIST_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_pricelist_load_01;


PROCEDURE check_prom_divparam_confirm IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;


  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_prom_divparam_confm
      AND job_status = pc_job_status_submitted
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

  -- Retrieve Mars Date.
  -- will only return a value on day 26 of a 4 week period or day 33 of a 5 week period 
  CURSOR csr_mars_date IS
  	SELECT *
    FROM mars_date
    WHERE TRUNC(calendar_date) = TRUNC(sysdate)
	and period_day_num = (
							select max(period_day_num-2) 
							from mars_date
							where mars_period=(
												select mars_period 
												from mars_date
												WHERE TRUNC(calendar_date) = TRUNC(sysdate)
											  )
					     );

    rv_mars_date csr_mars_date%ROWTYPE;

BEGIN
  -- Start check_prom_divparam_confirm procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_divparam_confirm - START.');

  -- Check to see whether there is one or more PROM_DIVPARAM_CONFM control records
  -- with a status of SUBMITTED. If there are multiple SUBMITTED records, set them
  -- all to COMPLETE, but only create one control file record for the next part of
  -- the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''PROM_DIVPARAM_CONFM'' Promax Job Control records exist with a status of SUBMITTED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from SUBMITTED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from SUBMITTED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found then check whether today is Thurday Week 4.
  If so, then change the Promax DIVPARAM.SETTING of TRANSFERPERIOD to '2'.  This is
  required for End-of-Period processing.
  */
  IF v_rcd_processed_flag = TRUE THEN

    -- Lookup today's date in the Mars Date table. If today is Day 26 of a 4 week period
    -- (i.e. Thursday Week 4), or day 33 of a 5 week period then update the DIVPARAM.SETTING 
	-- of TRANSFERPERIOD to '2'.
    OPEN csr_mars_date;
    FETCH csr_mars_date INTO rv_mars_date;
	-- will only return a value on day 26 of a 4 week period or day 33 of a 5 week period 
    IF csr_mars_date%FOUND THEN 
      -- Update DIVPARAM table if today is the third last day of the period (i.e. last Thursday of the period).
      write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Promax DIVPARAM setting TRANSFERPERIOD updated to ''2'' in preparation for EOP. This occurs on Thursday, WK4 only.');
      UPDATE divparam
      SET divvalue = pc_divparam_divvalue_begin
      WHERE setting = pc_divparam_setting_transfer;

      -- Set all Promax users to read-only mode.
      write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Setting all Promax users to read-only mode.');
      pds_utils.set_users_read_only(pv_log_level);

    END IF;
    CLOSE csr_mars_date;

    -- Commit the transaction.
    COMMIT;

    -- Create PROM_CONFIRM record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_prom_confirm, pv_log_level);
  END IF;

  -- End check_prom_divparam_confirm procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_divparam_confirm - END.');

EXCEPTION
    WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_PROM_DIVPARAM_CONFIRM:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_prom_divparam_confirm;


PROCEDURE check_prom_confirm IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_prom_confirm
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_prom_confirm procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_confirm - START.');

  -- Check to see whether there is one or more PROM_CONFIRM control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''PROM_CONFIRM'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by creating a PROM_ACTIVE control record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Create PROM_ACTIVE record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_prom_active, pv_log_level);
  END IF;

  -- End check_prom_confirm procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_confirm - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_PROM_CONFIRM:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_prom_confirm;


PROCEDURE check_prom_active IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_prom_active
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_prom_active procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_active - START.');

  -- Check to see whether there is one or more PROM_ACTIVE control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''PROM_ACTIVE'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by creating a PROM_DIVPARAM_ACTIVE control record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Create PROM_DIVPARAM_ACTIVE record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_prom_divparam_active);
  END IF;

  -- End check_prom_active procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_active - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_PROM_ACTIVE:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_prom_active;


PROCEDURE check_prom_divparam_active IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_prom_divparam_active
      AND job_status = pc_job_status_submitted
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_prom_divparam_active procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_divparam_active - START.');

  -- Check to see whether there is one or more PROM_DIVPARAM_ACTIVE control records
  -- with a status of SUBMITTED. If there are multiple SUBMITTED records, set them
  -- all to COMPLETE, but only create one control file record for the next part of
  -- the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''PROM_DIVPARAM_ACTIVE'' Promax Job Control records exist with a status of SUBMITTED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from SUBMITTED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from SUBMITTED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found check whether Promax DIVPARAM.SETTING of
  TRANSFERPERIOD equals '2'. If so, then change the Promax DIVPARAM.SETTING of
  TRANSFERPERIOD to '0' as End-of-Period processing has been completed.
  */
  IF v_rcd_processed_flag = TRUE THEN

    -- If the current value for the divparam setting TRANSFERPERIOD is '2' then change it to '0'.
    -- Update DIVPARAM table, setting TRANSFERPERIOD to '0'.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Promax DIVPARAM setting TRANSFERPERIOD updated to ''0''. This occurs after Period End Postbox processing has completed.');
    UPDATE divparam
    SET divvalue = pc_divparam_divvalue_end
    WHERE setting = pc_divparam_setting_transfer;

    -- Commit the transaction.
    COMMIT;

    -- Create PROM_LOAD record in the promax job control table.
    pds_utils.create_promax_job_control(pc_pstbx_prom_load, pv_log_level);

  END IF;

  -- End check_prom_load procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_load - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CONTROLLER.CHECK_PROM_DIVPARAM_ACTIVE:',
        pv_processing_msg) ||
      utils.create_params_str('DIVPARAM Setting',pc_divparam_setting_transfer);
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_PROM_DIVPARAM_ACTIVE:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_prom_divparam_active;


PROCEDURE check_prom_load IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_prom_load
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_prom_load procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_load - START.');

  -- Check to see whether there is one or more PROM_LOAD control records with a status of
  -- PROCESSED. If there are multiple PROCESSED records, set them all to COMPLETE, but only
  -- create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''PROM_LOAD'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by triggering the PDS_PROM_01_PRC processing daemon.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Initiate the next part of the interface by triggering the PDS_PROM_01_PRC processing daemon.
    write_log(pc_data_type_not_applicable, 'N/A',pv_log_level, 'Trigger the pds_prom_01_prc procedure.');
    lics_trigger_loader.execute('MFANZ Promax Promotion 01 Process',
                                'pds_app.pds_prom_01_prc.run_pds_prom_01_prc',
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_PROM_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_PROM_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_PROM_01_PRC'));
  END IF;

  -- End check_prom_load procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_load - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_PROM_LOAD:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_prom_load;


PROCEDURE check_prom_act_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_prom_act_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_prom_act_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_act_load_01 - START.');

  -- Check to see whether there is one or more PROM_ACT_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''PROM_ACT_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_prom_act_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_prom_act_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_PROM_ACT_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_prom_act_load_01;


PROCEDURE check_sales_load_01 IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_sales_load_01
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_sales_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_sales_load_01 - START.');

  -- Check to see whether there is one or more SALES_LOAD_01 control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''SALES_LOAD_01'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_sales_load_01 procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_sales_load_01 - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_SALES_LOAD_01:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_sales_load_01;


PROCEDURE check_ar_claimsapp_load IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_ar_claimsapp_load
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_ar_claimsapp_load procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ar_claimsapp_load - START.');

  -- Check to see whether there is one or more AR_CLAIMSAPP_LOAD control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''AR_CLAIMSAPP_LOAD'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found, initiate the next part of the interface
  by triggering the PDS_AR_CLAIMSAPP_01_PRC processing daemon.

  The PDS_AP_CLAIMS_01_INT interface is also triggered as the AR_CLAIMSAPP_LOAD Postbox
  job extracts both AR Claims Approvals and AP Claims from Promax into the EXACCRUALS table.
  Therefore, the AP Claims interface should always be executed immediately following the
  AR Claims Approval interface.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;

    -- Initiate the next part of the interface by triggering the PDS_AR_CLAIMSAPP_01_PRC processing daemon.
    write_log(pc_data_type_not_applicable, 'N/A',pv_log_level, 'Trigger the ar_claimsapp_01_prc procedure.');
    lics_trigger_loader.execute('MFANZ Promax AR Claims Approvals 01 Process',
                                'pds_app.pds_ar_claimsapp_01_prc.run_pds_ar_claimsapp_01_prc',
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_AR_CLAIMSAPP_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_AR_CLAIMSAPP_01_PRC'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_AR_CLAIMSAPP_01_PRC'));

    -- Initiate the AP Claims interface by triggering the PDS_AP_CLAIMS_01_INT interface procedure.
    write_log(pc_data_type_not_applicable, 'N/A',pv_log_level, 'Trigger the ap_claims_01_int procedure.');
    lics_trigger_loader.execute('MFANZ Promax AP Claims 01 Interface',
                                'pds_app.pds_ap_claims_01_int.run_pds_ap_claims_01_int',
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_AP_CLAIMS_01_INT'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_AP_CLAIMS_01_INT'),
                                lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_AP_CLAIMS_01_INT'));
  END IF;

  -- End check_ar_claimsapp_load procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_ar_claimsapp_load - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_AR_CLAIMSAPP_LOAD:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_ar_claimsapp_load;


PROCEDURE check_scan_qty_update IS

  -- VARIABLE DECLARATIONS
  v_rcd_processed_flag BOOLEAN := FALSE;

  -- CURSOR DECLARATIONS
  -- Retrieve Promax Job Control record.
  CURSOR csr_pmx_job_cntl IS
    SELECT *
    FROM pds_pmx_job_cntl
    WHERE pmx_job_cnfgn_id = pc_pstbx_scan_qty_update
      AND job_status = pc_job_status_processed
    FOR UPDATE NOWAIT;
    rv_pmx_job_cntl csr_pmx_job_cntl%ROWTYPE;

BEGIN
  -- Start check_scan_qty_update procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_scan_qty_update - START.');

  -- Check to see whether there is one or more SCAN_QTY_UPDATE control records with a
  -- status of PROCESSED. If there are multiple PROCESSED records, set them all to
  -- COMPLETE, but only create one control file record for the next part of the interface.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Checking to see whether any ''SCAN_QTY_UPDATE'' Promax Job Control records exist with a status of PROCESSED.');

  -- Open and fetch records from cursor.
  OPEN csr_pmx_job_cntl;
  LOOP
    FETCH csr_pmx_job_cntl INTO rv_pmx_job_cntl;
    EXIT WHEN csr_pmx_job_cntl%NOTFOUND;

    -- Update promax job control record from PROCESSED to COMPLETED.
    write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'Updating Promax Job Control record [' || rv_pmx_job_cntl.pmx_job_id || '] from PROCESSED to COMPLETED.');
    UPDATE pds_pmx_job_cntl
    SET job_status = pc_job_status_completed
    WHERE
      CURRENT OF csr_pmx_job_cntl;

    -- Set record processed flag.
    v_rcd_processed_flag := TRUE;
  END LOOP;

  -- Close cursor.
  CLOSE csr_pmx_job_cntl;

  /*
  If the promax job control record was found,  commit the updated record.
  */
  IF v_rcd_processed_flag = TRUE THEN
    -- Commit the transaction.
    COMMIT;
  END IF;

  -- End check_scan_qty_update procedure.
  write_log(pc_data_type_not_applicable, 'N/A', pv_log_level, 'check_scan_qty_update - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.CHECK_SCAN_QTY_UPDATE:',
        'Unexpected Exception - run_example aborted.') ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_not_applicable,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pds_controller,'MFANZ Promax PDS Controller',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pds_controller,'N/A');
    END IF;

END check_scan_qty_update;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN
  -- Write the entry into the pds_log table.
  pds_utils.log (pc_job_type_pds_controller,
                 i_data_type,
                 i_sort_field,
                 i_log_level,
                 i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CONTROLLER.WRITE_LOG:',
        'Unable to write to the PDS_LOG table.') ||
      utils.create_sql_err_msg();
    pds_utils.log(pc_job_type_pds_controller,pc_data_type_not_applicable,'N/A',i_log_level,
      pv_result_msg);
END write_log;

END pds_controller;
/
