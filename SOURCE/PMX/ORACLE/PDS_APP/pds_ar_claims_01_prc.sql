CREATE OR REPLACE PACKAGE         pds_ar_claims_01_prc IS

/*********************************************************************************
  NAME:      run_pds_ar_claims_01_prc
  PURPOSE:   This procedure performs three key tasks:

             1. Validates the AR Claims (FOOD & PET) data in the PDS schema.
             2. Transfers validated AR Claims (FOOD & PET) data into the Postbox schema.
             3. Initiates the transfer from Postbox to Promax schema.

             This procedure is scheduled to run.

             NOTE: v_debug is a debugging constant, defined at the package level.
             If FALSE (ie. we're running in production) THEN send Alerts, else sends
             emails.
        .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   04/07/2007 Anna Every           new release for autoproces field added to exaccruals for promax release

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_ar_claims_01_prc;

/*********************************************************************************
  NAME:      validate_pds_ar_claims
  PURPOSE:   This procedure executes the validate_pds_ar_claims_food procedure, by
             Company and Division.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   03/02/2006 Craig Ford           Include Aus PET Validation.
  1.2   03/02/2010 Paul Berude          Included New Zealand AR Claims to be processed
                                        via Atlas (instead of via spreadsheet).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_ar_claims;

/*********************************************************************************
  NAME:      validate_pds_ar_claims_atlas
  PURPOSE:   This procedure validates the AR Claims data in the PDS_AR_CLAIMS table
             in the PDS schema.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   06/04/2006 Craig Ford           For AR Claims with more than one instance, change
                                        the 'MAX' code to return a NUMBER so it sorts
                                        correctly.
  1.2   21/09/2006 Craig Ford           Include ClaimRef on all error logging.
  1.3   03/02/2010 Paul Berude          Included New Zealand AR Claims to be processed
                                        via Atlas (instead of via spreadsheet).


  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Division Code                        02

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_ar_claims_atlas (
  i_cmpny_code IN VARCHAR2,
  i_div_code IN VARCHAR2);

/*********************************************************************************
  NAME:      transfer_ar_claims
  PURPOSE:   This procedure executes the transfer_ar_claims_postbox procedures, by
             company and division, for valid AR Claims data in the
             PDS_AR_CLAIMS table.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   03/02/2006 Craig Ford           Remove Reason Code conversion (from 40, 41) to 08. Change
                                        Reason Code constant (pc_ar_claims_prom_claim) from '08'
                                        with Reason Codes (40, 41, 44, 45).
  1.2   03/02/2010 Paul Berude          Included New Zealand AR Claims to be processed
                                        via Atlas (instead of via spreadsheet).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE transfer_ar_claims;

/*********************************************************************************
  NAME:      transfer_ar_claims_postbox
  PURPOSE:   This procedure transfers validated AR Claims (FOOD & PET) data from the
             PDS schema into the Postbox schema. Valid transactions in the
             PDS_AR_CLAIMS table are loaded into the Postbox table (EXACCRUALS).
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   03/02/2006 Craig Ford           Include Aus PET Transfer.
  1.2   03/02/2010 Paul Berude          Included New Zealand AR Claims to be processed
                                        via Atlas (instead of via spreadsheet).

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Division Code                        02

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE transfer_ar_claims_postbox (
  i_cmpny_code IN VARCHAR2,
  i_div_code IN VARCHAR2);

/*********************************************************************************
  NAME:      initiate_postbox_ar_claims
  PURPOSE:   Initiate the Promax Postbox AR Claims process. This moves Claim data
             from the Postbox to the Promax Schema. The Postbox job is initiated by
             adding a Job Control record into the PDS_PMX_JOB_CNTL table using the
             create_promax_job_control utility function.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE initiate_postbox_ar_claims;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the PDS_LOG table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   07/08/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ -------------------
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

/*******************************************************************************
  NAME:      validate_claim_record
  PURPOSE:   Validates the current Claim and Updates the validation and processing
             status.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   23/03/2006 Craig Ford           Include Cust & Claimref in "AR Claims Alternate
                                         Payee is invalid" error.
  1.2   22/06/2006 Craig Ford           Alternate Customer number validation expects 8 chars only.
                                         If length is > 8 chars, use the last 8 chars only.
  1.3   27/07/2006 Craig Ford           Add an extra check to ensure that the calculated Business Segment (DIV)
                                         is valid for the Reason Code (ie Food='40' & '41'; Pet='44' & '45')
                                        AR Claims are sent from SAP with no Business Segment (ie Div). ICS
                                         attempts to determine the Business Segment using the Reason Code
                                         based on the following:
                                         -> if an idoc contains either '40' or '41' in position 90 of any detail line
	                                            If any other lines on that document contain either '42','43','44','45',
	                                            then flag as error
	                                            else the entire document is Food, so update all detail lines
                                                (in that idoc) with Food Segment ('02').
                                         -> if an idoc contains either '44' or '45' in position 90 of any detail line
                                            	If any other lines on that document contain either '40','41','42','43'
                                            	then flag as error
                                              else the entire document is Pet, so update all detail lines
                                                (in that idoc) with Pet Segment ('05').
                                         -> if an idoc contains either '42' or '43' in position 90 of any detail line
                                              If any other lines on that document contain either '41','42','44','45',
                                            	then flag as error
                                            	else the entire document is Snack, so update all detail lines
                                                (in that idoc) with Snack Segment ('01').
                                        Although it is not business process, the system does not prevent users
                                        from entering claims for mutiple segments on the one Accounting Document.
  1.4   21/09/2006 Craig Ford           Include ClaimRef on all error logging.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   Interface Batch Code                 1
  2    IN     VARCHAR2 Company Code                         147
  3    IN     VARCHAR2 Division Code                        02
  4    IN     NUMBER   PDS AR Claims Seq                    1
  5    OUT    VARCHAR2 Validation Status                    VALID
  6    OUT    VARCHAR2 Promax Customer Code                 1234
  7    OUT    VARCHAR2 Promax Customer/                     1234
  8    IN     NUMBER   Log Level                            1
  9   OUT    VARCHAR2 Error Message

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION validate_claim_record (
  i_intfc_batch_code IN pds_ar_claims.intfc_batch_code%TYPE,
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_ar_claims_seq IN pds_ar_claims.ar_claims_seq%TYPE,
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  o_valdtn_status OUT VARCHAR2,
  o_promax_cust_code OUT VARCHAR2,
  o_promax_cust_vndr_code OUT VARCHAR2,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER;

/*******************************************************************************
  NAME:      cust_num_has_hierarchy_node
  PURPOSE:   This function is used to check if the customer payee has a link to
             a customer sales hierarchy node.  A lookup here takes place to the
             LADS database. There can only be a one to one setup, so detection of
             duplicates results in an error.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Customer Code                        1234
  3    OUT    VARCHAR2 Customer Code to use                 1475
  4    IN     NUMBER   Log Level                            1
  5    OUT    VARCHAR2 Error Message

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION cust_num_has_hierarchy_node (
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_cust_code IN pds_ar_claims.cust_code%TYPE,
  o_cust_to_use OUT pds_ar_claims.cust_code%TYPE,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER;

/*******************************************************************************
  NAME:      cust_num_is_also_del_to
  PURPOSE:   This function is used to see if the Payee supplied is also a Del To Customer,
             which Promax should know about.  This check is done by looking up the
             MFANZ Customer Partner function table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Company Code to use                  1475
  3    IN     NUMBER   Log Level                            1
  4    OUT    VARCHAR2 Error message

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION cust_num_is_also_del_to (
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_cust_to_use IN pds_ar_claims.cust_code%TYPE,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER;

/*******************************************************************************
  NAME:      find_unused_claimref
  PURPOSE:   This function is used when a record is received with a Claim Ref that
             has already been used before. This function will suggest a new Claim Ref
             that hasn't been used with this customer before. This suggestion takes
             place by adding /n where n is a next consective un-used number.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Promax Company Code                  47
  2    IN     VARCHAR2 Promax Division Code                 02
  3    IN     VARCHAR2 Company Code                         147
  4    IN     VARCHAR2 Division Code                        02
  5    IN     VARCHAR2 Promax Customer Code                 1234
  6    IN     VARCHAR2 Claim Reference                      1475
  7    OUT    VARCHAR2 Unused Claimref
  8    IN     NUMBER   Log Level                            2

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION find_unused_claimref (
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_pmx_cust_code IN pds_ar_claims.cust_code%TYPE,
  i_claim_ref IN claimdoc.claimref%TYPE,
  o_unused_claimref OUT claimdoc.claimref%TYPE,
  i_log_level NUMBER)
  RETURN NUMBER;

/*******************************************************************************
  NAME:      find_valid_acctg_doc
  PURPOSE:   This function is used to identify the existing valid/loaded Atlas
             accounting document details from PDS.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   17/10/2008 G.Brooder            Added this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Division Code                        02
  3    IN     VARCHAR2 Customer Code                        1234
  4    IN     VARCHAR2 Claim Reference                      1475
  5    OUT    VARCHAR2 Altas Accounting Doc Number          0011223344
  6    OUT    VARCHAR2 Altas Accounting Doc Fiscal Year     2008
  7    OUT    VARCHAR2 Altas Accounting Doc Line Item       001
  8    IN     NUMBER   Log Level                            1
  9    OUT    VARCHAR2 Error message

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION find_valid_acctg_doc (
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_cust_code IN pds_ar_claims.cust_code%TYPE,
  i_claim_ref IN claimdoc.claimref%TYPE,
  o_match_acctg_doc_num OUT pds_ar_claims.acctg_doc_num%TYPE,
  o_match_fiscl_year OUT pds_ar_claims.fiscl_year%TYPE,
  o_match_line_item_num OUT pds_ar_claims.line_item_num%TYPE,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER;

/*******************************************************************************
  NAME:      check_for_differences
  PURPOSE:   This function is used to check for differences between an existing
             VALID Claim and the same Claim received again.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     NUMBER   Interface Batch Code                 1
  2    IN     VARCHAR2 Company Code                         147
  3    IN     VARCHAR2 Division Code                        02
  4    IN     NUMBER   PDS AR Claims Seq                    1
  5    OUT    NUMBER   Difference Count                     2
  6    IN     NUMBER   Log Level                            1
  7    OUT    VARCHAR2 Error message

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION check_for_differences (
  i_intfc_batch_code IN pds_ar_claims.intfc_batch_code%TYPE,
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_ar_claims_seq IN pds_ar_claims.ar_claims_seq%TYPE,
  o_diff_count OUT NUMBER,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER;

END pds_ar_claims_01_prc; 
/


CREATE OR REPLACE PACKAGE BODY         pds_ar_claims_01_prc IS

  -- PACKAGE VARIABLE DECLARATIONS.
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS.
  pc_job_type_ar_claims_01_prc   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claims_01_prc','JOB_TYPE');
  pc_data_type_ar_claims         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claims','DATA_TYPE');
  pc_debug                       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_minor           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_valdtn_severity_critical    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('critical','VALDTN_SEVERITY');
  pc_valdtn_status_unchecked     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unchecked','VALDTN_STATUS');
  pc_valdtn_status_excluded      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('excluded','VALDTN_STATUS');
  pc_valdtn_status_duplicate     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('duplicate','VALDTN_STATUS');
  pc_valdtn_status_deleted       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('deleted','VALDTN_STATUS');
  pc_valdtn_status_omitted       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('omitted','VALDTN_STATUS');
  pc_valdtn_status_valid         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('valid','VALDTN_STATUS');
  pc_valdtn_status_invalid       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('invalid','VALDTN_STATUS');
  pc_valdtn_type_ar_claims       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claims','VALDTN_TYPE');
  pc_procg_status_loaded         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('loaded','PROCG_STATUS');
  pc_procg_status_processed      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('processed','PROCG_STATUS');
  pc_procg_status_completed      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','PROCG_STATUS');
  pc_job_status_completed        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');
  pc_pstbx_ar_claims_load_01     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claims_load_01','PSTBX');
  pc_ar_claims_generic_vndr_code CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('generic_vndr_code','AR_CLAIMS');
  pc_ar_claims_payer             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('payer','AR_CLAIMS');
  pc_ar_claims_sold_to           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('sold_to','AR_CLAIMS');
  pc_ar_claims_rep               CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('rep','AR_CLAIMS');
  pc_ar_claims_div_non_specific  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('div_non_specific','AR_CLAIMS');
  pc_ar_claims_reasn_food_notax  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('reason_code_food_notax','AR_CLAIMS');
  pc_ar_claims_reasn_pet_notax   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('reason_code_pet_notax','AR_CLAIMS');
  pc_ar_claims_reasn_snack_notax CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('reason_code_snack_notax','AR_CLAIMS');
  pc_ar_claims_reasn_food_tax    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('reason_code_food_tax','AR_CLAIMS');
  pc_ar_claims_reasn_pet_tax     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('reason_code_pet_tax','AR_CLAIMS');
  pc_ar_claims_reasn_snack_tax   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('reason_code_snack_tax','AR_CLAIMS');
  pc_cmpny_code_australia        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia','CMPNY_CODE');
  pc_cmpny_code_new_zealand      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('new_zealand','CMPNY_CODE');
  pc_div_code_food               CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('food','DIV_CODE');
  pc_div_code_pet                CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pet','DIV_CODE');
  pc_div_code_snack              CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('snack','DIV_CODE');
  pc_distbn_chnl_non_specific    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('non_specific','DISTBN_CHNL');


PROCEDURE run_pds_ar_claims_01_prc IS

BEGIN

  -- Start run_pds_ar_claims_01_prc procedure.
  write_log(pc_data_type_ar_claims, 'N/A', pv_log_level, 'run_pds_ar_claims_01_prc - START.');

  -- The 3 key tasks: validate, transfer and initiate postbox job.
  validate_pds_ar_claims();
  transfer_ar_claims ();
  initiate_postbox_ar_claims ();

  -- End run_pds_ar_claims_01_prc procedure.
  write_log(pc_data_type_ar_claims, 'N/A', pv_log_level, 'run_pds_ar_claims_01_prc - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.RUN_PDS_AR_CLAIMS_01_PRC:',
      'Unexpected Exception - run_pds_ar_claims_01_prc aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

END run_pds_ar_claims_01_prc;


PROCEDURE validate_pds_ar_claims IS

BEGIN

  -- Start validate_pds_ar_claims procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,'validate_pds_ar_claims - START.');

  -- Execute the validate AR Claims Atlas procedure for all AUS Company/Divisions.
  -- The procedure validates data within the PDS schema.
  validate_pds_ar_claims_atlas (pc_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood.
  validate_pds_ar_claims_atlas (pc_cmpny_code_australia,pc_div_code_food); -- Australia Food.
  validate_pds_ar_claims_atlas (pc_cmpny_code_australia,pc_div_code_pet); -- Australia Pet.
  validate_pds_ar_claims_atlas (pc_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snackfood.
  validate_pds_ar_claims_atlas (pc_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
  validate_pds_ar_claims_atlas (pc_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Pet.

  -- Trigger the pds_ar_claims_01_rep procedure.
  write_log(pc_data_type_ar_claims, 'N/A', pv_log_level, 'Trigger the PDS_AR_CLAIMS_01_REP procedure.');
  lics_trigger_loader.execute('MFANZ Promax AR Claims 01 Report',
                              'pds_app.pds_ar_claims_01_rep.run_pds_ar_claims_01_rep',
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_AR_CLAIMS_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_AR_CLAIMS_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_AR_CLAIMS_01_REP'));

  -- End validate_pds_ar_claims procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,'validate_pds_ar_claims - END.');

END validate_pds_ar_claims;


PROCEDURE validate_pds_ar_claims_atlas (
  i_cmpny_code VARCHAR2,
  i_div_code VARCHAR2) IS

  -- VARIABLE DECLARATIONS.
  v_valdtn_status         pds_ar_claims.valdtn_status%TYPE := 'VALID'; -- Record validation status new claim
  v_pmx_cmpny_code        pds_div.pmx_cmpny_code%TYPE;
  v_pmx_cust_code         pds_ar_claims.cust_code%TYPE;
  v_promax_cust_vndr_code pds_ar_claims.promax_cust_vndr_code%TYPE;
  v_promax_cust_code      pds_ar_claims.promax_cust_code%TYPE;
  v_pmx_div_code          pds_div.pmx_div_code%TYPE;
  v_max_postng_date       pds_ar_claims.postng_date%TYPE;
  v_postng_date           pds_ar_claims.postng_date%TYPE;
  v_count                 NUMBER;
  v_diff_count            NUMBER;
  v_claims_seq            NUMBER;
  v_batch_code            NUMBER;


  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- Retrieve all unchecked AR Claimss to be validated.
  CURSOR csr_ar_claims IS
    SELECT
      intfc_batch_code,
      cmpny_code,
      div_code,
      ar_claims_seq,
      cust_code,
      claim_amt,
      claim_ref,
      assignmnt_num,
      tax_amt,
      postng_date,
      period_num,
      reasn_code,
      acctg_doc_num,
      fiscl_year,
      line_item_num,
      bus_prtnr_ref2,
      tax_code,
      idoc_type,
      idoc_num,
      idoc_date,
      promax_cust_code,
      promax_cust_vndr_code,
      promax_ar_load_date,
      promax_ar_apprvl_date,
      procg_status,
      valdtn_status
    FROM
      pds_ar_claims
    WHERE
      cmpny_code = i_cmpny_code
      AND div_code = i_div_code
      AND valdtn_status = pc_valdtn_status_unchecked
    FOR UPDATE NOWAIT;
  rv_ar_claims csr_ar_claims%ROWTYPE;

  -- This function looks up the SAP ARClaim table to see if there is an existing
  -- record with the same key information that has already been loaded into Promax.
  CURSOR csr_ar_claims_old IS
    SELECT
      intfc_batch_code,
      ar_claims_seq,
      postng_date,
      valdtn_status
    FROM
      pds_ar_claims
    WHERE
      cmpny_code = i_cmpny_code
      AND acctg_doc_num = rv_ar_claims.acctg_doc_num
      AND fiscl_year = rv_ar_claims.fiscl_year
      AND line_item_num = rv_ar_claims.line_item_num
      AND valdtn_status = pc_valdtn_status_valid;
  rv_ar_claims_old csr_ar_claims_old%ROWTYPE;

  -- RESULT CHECKING PROCEDURE.
  PROCEDURE check_result_status IS
  BEGIN
    IF pv_status = constants.success THEN
      NULL;
    ELSIF pv_status = constants.failure THEN
      pv_processing_msg := utils.nest_err_msg(pv_result_msg);
      RAISE e_processing_failure;
    ELSIF pv_status = constants.error THEN
      pv_processing_msg := utils.nest_err_msg(pv_result_msg);
      RAISE e_processing_error;
    END IF;
  END check_result_status;

BEGIN

  -- Start validate_pds_ar_claims_atlas procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'validate_pds_ar_claims_atlas - START.');
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Process Company '||i_cmpny_code||' Division '||i_div_code||'.');

  -- Update PDS_AR_CLAIMS table to set INVALID records to UNCHECKED.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Update PDS_AR_CLAIMS table to set INVALID records to UNCHECKED.');
  UPDATE pds_ar_claims
    SET valdtn_status = pc_valdtn_status_unchecked
  WHERE cmpny_code = i_cmpny_code
    AND div_code = i_div_code
    AND valdtn_status = pc_valdtn_status_invalid;

  -- Commit update to PDS_AR_CLAIMS table.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Commit update to PDS_AR_CLAIMS table.');
  COMMIT;

  -- Clear validation table of records if they exist.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Clear validation table of AR Claims record if it exists.');
  pds_utils.clear_validation_reason(pc_valdtn_type_ar_claims,NULL, i_cmpny_code, i_div_code, NULL, NULL, NULL, pv_log_level + 2);

  -- Lookup Promax Company Code and Division Code.
  pv_status := pds_lookup.lookup_pmx_cmpny_div_code(i_cmpny_code, i_div_code, v_pmx_cmpny_code, v_pmx_div_code, pv_log_level + 2, pv_result_msg);
  check_result_status;

  -- Where there are multiple (duplicate) claims, ensure there is only one "UNCHECKED" instance
  -- of each claim.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Open csr_ar_claims cursor.');
  OPEN csr_ar_claims;
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Looping through the csr_ar_claims cursor to identify Claims with more than one instance.');
  LOOP
    FETCH csr_ar_claims INTO rv_ar_claims;
    EXIT WHEN csr_ar_claims%NOTFOUND;

    -- Identify the claims with more than one instance.
    SELECT COUNT(*) INTO v_count
    FROM pds_ar_claims
    WHERE acctg_doc_num = rv_ar_claims.acctg_doc_num
    AND fiscl_year = rv_ar_claims.fiscl_year
    AND line_item_num = rv_ar_claims.line_item_num
    AND valdtn_status = pc_valdtn_status_unchecked;

    -- For all claims with more than one instance, find the latest transaction.
    -- It is possible that 2 records for the one transaction may come in on the same day
    -- in that instance they will have the same Posting Data and perhaps they may even
    -- have the same Interface Batch Code, but they will have different Sequence numbers,
    -- The following Query selects the record with the most recent Posting Date, the
    -- latest Batch Code and the highest Sequence number in the Batch if the Batch Codes
    -- are the same.
    IF v_count > 1 THEN
      SELECT
        postng_date,
        intfc_batch_code,
        ar_claims_seq
      INTO
        v_postng_date,
        v_batch_code,
        v_claims_seq
      FROM
        pds_ar_claims
      WHERE
        (TO_NUMBER(postng_date||LPAD(intfc_batch_code,15,0)||LPAD(ar_claims_seq,5,0))) IN
        (SELECT
          MAX(TO_NUMBER(postng_date||LPAD(intfc_batch_code,15,0)||LPAD(ar_claims_seq,5,0)))
        FROM
          pds_ar_claims
        WHERE
          acctg_doc_num = rv_ar_claims.acctg_doc_num
          AND fiscl_year = rv_ar_claims.fiscl_year
          AND line_item_num = rv_ar_claims.line_item_num
          AND valdtn_status = pc_valdtn_status_unchecked);

      -- Flag the old repeat claims as "EXCLUDED", ensuring the latest claim remains "UNCHECKED".
      write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 3,'Update PDS_AR_CLAIMS table to flag old repeated Claims as EXCLUDED.');
      UPDATE pds_ar_claims
        SET valdtn_status = pc_valdtn_status_excluded
      WHERE acctg_doc_num = rv_ar_claims.acctg_doc_num
        AND fiscl_year = rv_ar_claims.fiscl_year
        AND line_item_num = rv_ar_claims.line_item_num
        AND NOT (intfc_batch_code = v_batch_code
                 AND ar_claims_seq = v_claims_seq
                 AND postng_date = v_postng_date)
        AND valdtn_status = pc_valdtn_status_unchecked;

    END IF;
  END LOOP;
  write_log(pc_data_type_ar_claims, 'N/A',pv_log_level + 2,'End of csr_ar_claims cursor loop to identify Claims with more than one instance.');

  -- Close csr_ar_claims cursor.
  write_log(pc_data_type_ar_claims, 'N/A', pv_log_level + 2, 'Close csr_ar_claims cursor.');
  CLOSE csr_ar_claims;

  -- Commit changes to PDS_AR_CLAIMS table.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Commit changes to PDS_AR_CLAIMS table.');
  COMMIT;

  -- The assumption of this processing is that pre-processing has assured:
  -- -> the outer loop only returns one "UNCHECKED" record (per Company, Division,
  -- -> Accounting Document Line Item & Year).
  -- -> the inner loop returns a maximum of one "VALID" row (per Company, Division,
  -- -> Accounting Document Line Item & Year).

  -- Read through each of the AR Claim records to be validated. The above multiple claim check
  -- ensures there is only one "UNCHECKED" instance for each claim.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Open csr_ar_claims cursor.');
  OPEN csr_ar_claims;
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Looping through the csr_ar_claims cursor.');
  LOOP
    FETCH csr_ar_claims INTO rv_ar_claims;
    EXIT WHEN csr_ar_claims%NOTFOUND;

    -- Initialize variables.
    v_promax_cust_code := NULL;
    v_diff_count := 0;
    v_promax_cust_vndr_code := NULL;
    v_max_postng_date := NULL;
    v_valdtn_status := pc_valdtn_status_unchecked;

    -- Check if this Claim (document) has been received before (PDS_AR_CLAIMS).
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 3,'Open csr_ar_claims_old cursor.');
    OPEN csr_ar_claims_old;
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 3,'Looping through the csr_ar_claims_old cursor.');
    LOOP
      -- Check if the current record already exists in the AR Claim table.
      FETCH csr_ar_claims_old INTO rv_ar_claims_old;
      EXIT WHEN csr_ar_claims_old%NOTFOUND;

      -- Flag this new Claim to EXCLUDED if it's Posting date is earlier than the old Claims
      -- Posting date. Check also where 2 records have the same Posting Date But different batches,
      -- the latest batch is assumed to be the most recent, or if they came in on the same day
      -- and in the same batch, then the one with the highest sequence number will be the more recent one.
      IF rv_ar_claims.postng_date < rv_ar_claims_old.postng_date OR
        (rv_ar_claims.postng_date = rv_ar_claims_old.postng_date AND
         rv_ar_claims.intfc_batch_code < rv_ar_claims_old.intfc_batch_code) OR
        (rv_ar_claims.postng_date = rv_ar_claims_old.postng_date AND
         rv_ar_claims.intfc_batch_code = rv_ar_claims_old.intfc_batch_code AND
         rv_ar_claims.ar_claims_seq < rv_ar_claims_old.ar_claims_seq) THEN

        v_valdtn_status := pc_valdtn_status_excluded;

      ELSE
        -- This claim has been received previously and processed into Promax therefore
        -- identify and report any differences (between the new claim and the original).
        -- Log an error to indicate the current Claim has already been processed into Promax but now differs.
        write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 3,'Claimref ['|| rv_ar_claims.claim_ref || ']: Trans has been received before and has been loaded into Promax previously.');
        write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 3,'Atlas key is Accounting Document Number ['||rv_ar_claims.acctg_doc_num||'], Fiscal Year ['||rv_ar_claims.fiscl_year||'], Line Item Number ['||rv_ar_claims.line_item_num||'].');

        pv_status := check_for_differences (rv_ar_claims.intfc_batch_code, rv_ar_claims.cmpny_code, rv_ar_claims.div_code, rv_ar_claims.ar_claims_seq, v_diff_count, pv_log_level + 4, pv_result_msg);
        check_result_status;

        -- Check the differences  counter.
        IF v_diff_count <> 0 THEN
          -- If there are differences, set valdn_status to "INVALID", to indicate another
          -- claim has been received which differs from an already loaded claim.
          v_valdtn_status := pc_valdtn_status_invalid;

          -- Add an entry into the validation reason tables.
          pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
            'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Trans has previously been loaded into Promax.',
            pc_valdtn_severity_critical,
            rv_ar_claims.intfc_batch_code,
            rv_ar_claims.cmpny_code,
            rv_ar_claims.div_code,
            rv_ar_claims.ar_claims_seq,
            NULL,
            NULL,
            pv_log_level + 3);

          -- Add an entry into the validation reason tables.
          pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
            'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Atlas Acctg Doc. ['||rv_ar_claims.acctg_doc_num||'] Yr ['||rv_ar_claims.fiscl_year||'] Line ['||rv_ar_claims.line_item_num||'].',
            pc_valdtn_severity_critical,
            rv_ar_claims.intfc_batch_code,
            rv_ar_claims.cmpny_code,
            rv_ar_claims.div_code,
            rv_ar_claims.ar_claims_seq,
            NULL,
            NULL,
            pv_log_level + 3);

        ELSE
          -- If no differences, set valdn_status to "DUPLICATE", to omitted this transaction.
          v_valdtn_status := pc_valdtn_status_duplicate;
        END IF;

      END IF;

    END LOOP; -- Inner loop.
    write_log(pc_data_type_ar_claims, 'N/A',pv_log_level + 3,'End of csr_ar_claims_old cursor loop to identify Claims with more than one instance.');

    -- Close csr_ar_claims_old cursor.
    write_log(pc_data_type_ar_claims, 'N/A', pv_log_level + 3, 'Close csr_ar_claims_old cursor.');
    CLOSE csr_ar_claims_old;

    -- If the new claim is valid (ie has not been flagged as 'EXCLUDED','INVALID' or
    -- 'DUPLICATE') and a TP Claim then validate it.
    IF rv_ar_claims.reasn_code IN (pc_ar_claims_reasn_food_notax, pc_ar_claims_reasn_food_tax, pc_ar_claims_reasn_pet_notax, pc_ar_claims_reasn_pet_tax, pc_ar_claims_reasn_snack_notax, pc_ar_claims_reasn_snack_tax) AND
       v_valdtn_status = pc_valdtn_status_unchecked THEN
      pv_status := validate_claim_record (rv_ar_claims.intfc_batch_code, rv_ar_claims.cmpny_code, rv_ar_claims.div_code,
        rv_ar_claims.ar_claims_seq, v_pmx_cmpny_code, v_pmx_div_code, v_valdtn_status, v_promax_cust_code, v_promax_cust_vndr_code, pv_log_level + 3, pv_result_msg);
      check_result_status;
    ELSIF NVL(rv_ar_claims.reasn_code,' ') NOT IN (pc_ar_claims_reasn_food_notax, pc_ar_claims_reasn_food_tax, pc_ar_claims_reasn_pet_notax, pc_ar_claims_reasn_pet_tax, pc_ar_claims_reasn_snack_notax, pc_ar_claims_reasn_snack_tax) THEN
      v_valdtn_status := pc_valdtn_status_omitted;
    END IF;
    UPDATE pds_ar_claims
      SET valdtn_status = v_valdtn_status,
      procg_status = pc_procg_status_processed,
      promax_cust_code = v_promax_cust_code,
      promax_cust_vndr_code = v_promax_cust_vndr_code
    WHERE CURRENT OF csr_ar_claims;
											-- LOOP csr_ar_claims
  END LOOP;
  write_log(pc_data_type_ar_claims, 'N/A',pv_log_level + 2,'End of csr_ar_claims cursor loop.');

  -- Commit changes to PDS_AR_CLAIMS table.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Commit changes to PDS_AR_CLAIMS table.');
  COMMIT;

  -- Close csr_ar_claims cursor.
  write_log(pc_data_type_ar_claims, 'N/A', pv_log_level + 2, 'Close csr_ar_claims cursor.');
  CLOSE csr_ar_claims;

  -- End validate_pds_ar_claims procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'End of process Company '||i_cmpny_code||' Division '||i_div_code||'.');
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'validate_pds_ar_claims_atlas - END.');

EXCEPTION
  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.VALIDATE_PDS_ar_claims_atlas:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code);
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

  WHEN e_processing_error THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_AR_CLAIMS_01_PRC.VALIDATE_PDS_AR_CLAIMS_ATLAS:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code);
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.VALIDATE_PDS_AR_CLAIMS_ATLAS:',
      'Unexpected Exception - validate_ar_claims_atlas aborted.') ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

END validate_pds_ar_claims_atlas;


PROCEDURE transfer_ar_claims IS

BEGIN

  -- Start transfer_ar_claims procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,'transfer_ar_claims - START.');

  -- Execute the transfer AR Claims Postbox procedure for all AUS ATLAS Company / Divisions. The
  -- procedure transfers data from PDS to the Promax schema.
  transfer_ar_claims_postbox (pc_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood.
  transfer_ar_claims_postbox (pc_cmpny_code_australia,pc_div_code_food); -- Australia Food.
  transfer_ar_claims_postbox (pc_cmpny_code_australia,pc_div_code_pet); -- Australia Pet.
  transfer_ar_claims_postbox (pc_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snackfood.
  transfer_ar_claims_postbox (pc_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
  transfer_ar_claims_postbox (pc_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Pet.

  -- End transfer_ar_claims procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,'transfer_ar_claims - END.');

END transfer_ar_claims;


PROCEDURE transfer_ar_claims_postbox(
  i_cmpny_code VARCHAR2,
  i_div_code VARCHAR2) IS

  -- VARIABLE DECLARATIONS.
  v_claim_amt             pds_ar_claims.claim_amt%TYPE;
  v_tax_amt               pds_ar_claims.tax_amt%TYPE;
  v_pbdoctype             exaccruals.pbdoctype%TYPE;
  v_postng_date           exaccruals.pbdate%TYPE;
  v_pmx_cmpny_code        pds_div.pmx_cmpny_code%TYPE;
  v_pmx_div_code          pds_div.pmx_div_code%TYPE;

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- Retrieve all validated AR Claims to be transferred to Postbox schema.
  CURSOR csr_ar_claims IS
    SELECT
      cmpny_code,
      div_code,
      cust_code,
      claim_amt,
      claim_ref,
      assignmnt_num,
      tax_amt,
      postng_date,
      period_num,
      reasn_code,
      acctg_doc_num,
      fiscl_year,
      line_item_num,
      bus_prtnr_ref2,
      tax_code,
      idoc_type,
      idoc_num,
      idoc_date,
      promax_cust_code,
      promax_cust_vndr_code,
      promax_ar_load_date,
      promax_ar_apprvl_date
    FROM
      pds_ar_claims
    WHERE
      cmpny_code = i_cmpny_code
      AND div_code = i_div_code
      AND valdtn_status = pc_valdtn_status_valid
      AND procg_status = pc_procg_status_processed
    FOR UPDATE NOWAIT;
  rv_ar_claims csr_ar_claims%ROWTYPE;

  -- RESULT CHECKING PROCEDURE.
  PROCEDURE check_result_status IS
  BEGIN
    IF pv_status = constants.success THEN
      NULL;
    ELSIF pv_status = constants.failure THEN
      pv_processing_msg := utils.nest_err_msg(pv_result_msg);
      RAISE e_processing_failure;
    ELSIF pv_status = constants.error THEN
      pv_processing_msg := utils.nest_err_msg(pv_result_msg);
      RAISE e_processing_error;
    END IF;
  END check_result_status;

BEGIN

  -- Start transfer_ar_claims_postbox procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'transfer_ar_claims_postbox - START.');

  -- Lookup Promax Company Code and Division Code.
  pv_status := pds_lookup.lookup_pmx_cmpny_div_code(i_cmpny_code, i_div_code, v_pmx_cmpny_code, v_pmx_div_code, pv_log_level + 2, pv_result_msg);
  check_result_status;

  -- Read through each of the AR Claims records to be transferred.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Open csr_ar_claims cursor.');
  OPEN csr_ar_claims;
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'Looping through the csr_ar_claims cursor to insert data into EXACCRUALS table.');
  LOOP
    FETCH csr_ar_claims INTO rv_ar_claims;
    EXIT WHEN csr_ar_claims%NOTFOUND;

    -- Tax Code Conversions.
    IF rv_ar_claims.tax_code IN ('S0','S2','S3','S5') THEN
      v_claim_amt := TO_NUMBER(rv_ar_claims.claim_amt);
      v_tax_amt := 0.00;
      v_pbdoctype := 'E';
    ELSIF i_cmpny_code = pc_cmpny_code_australia THEN
      v_claim_amt := ROUND(rv_ar_claims.claim_amt/1.1,2);
      v_tax_amt := ROUND(rv_ar_claims.claim_amt/11,2); -- Note: 11 equals 1 plus tax rate (10%) divided tax rate, e.g. 1.1 / .1 = 11
      v_pbdoctype := 'A';
    ELSIF i_cmpny_code = pc_cmpny_code_new_zealand THEN
      v_claim_amt := ROUND(rv_ar_claims.claim_amt/1.125,2);
      v_tax_amt := ROUND(rv_ar_claims.claim_amt/9,2); -- Note: 9 equals 1 plus tax rate (12.5%) divided tax rate, e.g. 1.125 / .125 = 9
      v_pbdoctype := 'A';
    END IF;

    -- Convert to date format.
    v_postng_date := TO_DATE(rv_ar_claims.postng_date,'YYYYMMDD');

    -- Insert into the Postbox EXACCRUALS table.
    INSERT INTO exaccruals
      (
      cocode,
      divcode,
      kacc,
      pmnum,
      icnumber,
      prodcode,
      promyear,
      fdcustcode,
      paymethod,
      datatype,
      aamount,
      acasedeal,
      linenum,
      acccode,
      paybychq,
      direction,
      additive,
      text25,
      pbdoctype,
      taxamount,
      periodno,
      trandate,
      claimref,
      genvendor,
      chequenum,
      pbtime,
      pbdate,
      procesdate,
      autoproces
      )
    VALUES
      (
      v_pmx_cmpny_code,
      v_pmx_div_code,
      TRIM(rv_ar_claims.promax_cust_code),
      ' ', -- Promotion num
      0, -- Internal Claim Num
      ' ', -- Product Code.
      ' ', -- Prom year
      ' ', -- Fund Code
      ' ', -- Pay mthd
      'E', -- Data type
      v_claim_amt,
      0, -- Case Deal
      rv_ar_claims.line_item_num, -- Line num
      pc_ar_claims_generic_vndr_code,
      'F', -- Pay by cheque
      'I', -- Direction
      ' ', -- Additive
      'Orig. Payee:'||rv_ar_claims.cust_code,
      v_pbdoctype, -- Doc type
      v_tax_amt,
      rv_ar_claims.period_num,
      v_postng_date,
      rv_ar_claims.claim_ref,
      'T', -- Generic Vendor
      ' ', -- Cheque Number
      0,
      v_postng_date,
      SYSDATE,
        ' ' -- Added by Anna Every 04/07/2007 for new release for autoproces
      );

    -- Update the status of the current Claim record to indicate it has been loaded into the Postbox.
    UPDATE pds_ar_claims
      SET promax_ar_load_date = SYSDATE,
      procg_status = pc_procg_status_completed
    WHERE CURRENT OF csr_ar_claims;

  END LOOP;
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'End of csr_ar_claims cursor loop.');

  -- Commit the changes to EXACCRUALS and PDS_AR_CLAIMS tables.
  COMMIT;

  -- Close csr_ar_claims cursor.
  write_log(pc_data_type_ar_claims, 'N/A', pv_log_level + 2, 'Close csr_ar_claims cursor.');
  CLOSE csr_ar_claims;

  -- End transfer_ar_claims_postbox procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,'transfer_ar_claims_postbox - END.');

EXCEPTION
  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.TRANSFER_AR_CLAIMS_POSTBOX::',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code);
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

  WHEN e_processing_error THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_AR_CLAIMS_01_PRC.TRANSFER_AR_CLAIMS_POSTBOX::',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code);
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.TRANSFER_AR_CLAIMS_POSTBOX:',
      'Unexpected Exception - transfer_ar_claims_postbox aborted.') ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

END transfer_ar_claims_postbox;


PROCEDURE initiate_postbox_ar_claims IS

  -- VARIABLE DECLARATIONS.
  v_count NUMBER; -- Generic counter.

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;

BEGIN

  -- Start initiate_postbox_ar_claims procedure.
  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,'initiate_postbox_ar_claims - START.');

  -- Do not initiate the AR Claimss Postbox job if any AR_CLAIMS_LOAD_01 job control
  -- records exist with a status other than COMPLETED.
  SELECT count(*) INTO v_count
  FROM
    pds_pmx_job_cntl
  WHERE
    pmx_job_cnfgn_id in (pc_pstbx_ar_claims_load_01)
    AND job_status <> pc_job_status_completed;

  IF v_count > 0 THEN -- There is a AR_CLAIMS_LOAD_01 Postbox job running.
    pv_processing_msg := ('ERROR: AR Claims 01 Interface cannot be started. ' ||
      'AR_CLAIMS_LOAD_01* Job Control records exist status <> COMPLETED.'||
      'This indicates that there is an in progress job and/or failed job(s).');
    RAISE e_processing_failure;
  ELSE
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,'Initiating AR_CLAIMS_LOAD_01 Job Control record.');
    pds_utils.create_promax_job_control(pc_pstbx_ar_claims_load_01);
  END IF;

  write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,'initiate_postbox_ar_claims - END.');

EXCEPTION

  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.INITIATE_POSTBOX_AR_CLAIMS:',pv_processing_msg) ||
      utils.create_params_str();
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.INITIATE_POSTBOX_AR_CLAIMS:',
      'Unexpected Exception - initiate_postbox_ar_claims aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ar_claims_01_prc,'N/A');
    END IF;

END initiate_postbox_ar_claims;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table.
  pds_utils.log (pc_job_type_ar_claims_01_prc,
    i_data_type,
    i_sort_field,
    i_log_level,
    i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;


FUNCTION validate_claim_record (
  i_intfc_batch_code IN pds_ar_claims.intfc_batch_code%TYPE,
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_ar_claims_seq IN pds_ar_claims.ar_claims_seq%TYPE,
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  o_valdtn_status OUT VARCHAR2,
  o_promax_cust_code OUT VARCHAR2,
  o_promax_cust_vndr_code OUT VARCHAR2,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
RETURN NUMBER IS

  -- VARIABLE DECLARATIONS.
  v_promax_cust_code     pds_ar_claims.promax_cust_code%TYPE;
  v_cust_code            pds_ar_claims.cust_code%TYPE;
  v_unused_claimref      claimdoc.claimref%TYPE;
  v_match_acctg_doc_num  pds_ar_claims.acctg_doc_num%TYPE;
  v_match_fiscl_year     pds_ar_claims.fiscl_year%TYPE;
  v_match_line_item_num  pds_ar_claims.line_item_num%TYPE;
  v_tmp_date             DATE;

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- CURSOR DECLARATIONS.
  -- Retrieve all unchecked AR Claim records to be validated.
  CURSOR csr_validate_ar_claims IS
    SELECT
      intfc_batch_code,
      cmpny_code,
      div_code,
      ar_claims_seq,
      cust_code,
      claim_amt,
      claim_ref,
      assignmnt_num,
      tax_amt,
      postng_date,
      period_num,
      reasn_code,
      acctg_doc_num,
      fiscl_year,
      line_item_num,
      bus_prtnr_ref2,
      tax_code,
      idoc_type,
      idoc_num,
      idoc_date,
      promax_cust_code,
      promax_cust_vndr_code,
      promax_ar_load_date,
      promax_ar_apprvl_date,
      valdtn_status,
      procg_status
    FROM
      pds_ar_claims
    WHERE
      cmpny_code = i_cmpny_code
      AND div_code = i_div_code
      AND intfc_batch_code = i_intfc_batch_code
      AND ar_claims_seq = i_ar_claims_seq;
  rv_validate_ar_claims csr_validate_ar_claims%ROWTYPE;

   -- RESULT CHECKING PROCEDURE.
  PROCEDURE check_result_status IS
  BEGIN
    IF pv_status = constants.success THEN
      NULL;
    ELSIF pv_status = constants.failure THEN
      pv_processing_msg := utils.nest_err_msg(pv_result_msg);
      RAISE e_processing_failure;
    ELSIF pv_status = constants.error THEN
      pv_processing_msg := utils.nest_err_msg(pv_result_msg);
      RAISE e_processing_error;
    END IF;
  END check_result_status;

BEGIN

  -- Start validate_claim_record procedure.
  write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,'validate_claim_record - START.');

  -- Read through each of the AR Claims records to be validated.
  write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,'Open csr_validate_ar_claims cursor.');
  OPEN csr_validate_ar_claims;
  write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,'Fetch record from the csr_validate_ar_claims cursor in to validate record for Batch ['||i_intfc_batch_code||'] and Sequence ['||i_ar_claims_seq||'].');
  FETCH csr_validate_ar_claims INTO rv_validate_ar_claims;
  o_valdtn_status := pc_valdtn_status_valid;

  -- Validate the Accounting Document Number (Part of the SAP Key).
  IF rv_validate_ar_claims.acctg_doc_num IS NULL THEN
    o_valdtn_status := pc_valdtn_status_invalid;

    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2, 'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Accounting Document Number is null.');

    -- Add an entry into the validation reason tables.
    pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
      'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Accounting Document Number is null.',
      pc_valdtn_severity_critical,
      rv_validate_ar_claims.intfc_batch_code,
      rv_validate_ar_claims.cmpny_code,
      rv_validate_ar_claims.div_code,
      rv_validate_ar_claims.ar_claims_seq,
      NULL,
      NULL,
      i_log_level + 2);

  END IF;

  -- Validate the Fiscal Year (Part of the SAP key).
  IF rv_validate_ar_claims.fiscl_year IS NULL OR rv_validate_ar_claims.fiscl_year = 0 THEN
    o_valdtn_status := pc_valdtn_status_invalid;

    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Fiscal Year [' || rv_validate_ar_claims.fiscl_year || '] is invalid.');

    -- Add an entry into the validation reason tables.
    pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
      'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Fiscal Year [' || rv_validate_ar_claims.fiscl_year || '] is invalid.',
      pc_valdtn_severity_critical,
      rv_validate_ar_claims.intfc_batch_code,
      rv_validate_ar_claims.cmpny_code,
      rv_validate_ar_claims.div_code,
      rv_validate_ar_claims.ar_claims_seq,
      NULL,
      NULL,
      i_log_level + 2);

  END IF;

  -- Validate the Line Item Number (Part of SAP Key).
  IF rv_validate_ar_claims.line_item_num IS NULL OR rv_validate_ar_claims.line_item_num = 0 THEN
    o_valdtn_status := pc_valdtn_status_invalid;

    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Line Item Number [' || rv_validate_ar_claims.line_item_num || '] is invalid.');

    -- Add an entry into the validation reason tables.
    pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
      'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Line Item Number [' || rv_validate_ar_claims.line_item_num || '] is invalid.',
      pc_valdtn_severity_critical,
      rv_validate_ar_claims.intfc_batch_code,
      rv_validate_ar_claims.cmpny_code,
      rv_validate_ar_claims.div_code,
      rv_validate_ar_claims.ar_claims_seq,
      NULL,
      NULL,
      i_log_level + 2);

  END IF;

  -- Validate the Period Number.
  DECLARE
    v_number_field NUMBER;
  BEGIN
    v_number_field := NVL(rv_validate_ar_claims.period_num,0); -- Test to see if value is a number.
    IF rv_validate_ar_claims.period_num IS NULL THEN
      o_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Period Number [' || rv_validate_ar_claims.period_num || '] is invalid.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Period Number [' || rv_validate_ar_claims.period_num || '] is invalid.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Period Number [' || rv_validate_ar_claims.period_num || '] to a number.');

      o_valdtn_status := pc_valdtn_status_invalid;

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Period Number [' || rv_validate_ar_claims.period_num || '] to a number.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

  END;

  -- Validate the Posting Date.
  IF rv_validate_ar_claims.postng_date IS NULL THEN
    o_valdtn_status := pc_valdtn_status_invalid;
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Posting Date [' || rv_validate_ar_claims.postng_date || '] is invalid.');

    -- Add an entry into the validation reason tables.
    pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
      'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Posting Date [' || rv_validate_ar_claims.postng_date || '] is invalid.',
      pc_valdtn_severity_critical,
      rv_validate_ar_claims.intfc_batch_code,
      rv_validate_ar_claims.cmpny_code,
      rv_validate_ar_claims.div_code,
      rv_validate_ar_claims.ar_claims_seq,
      NULL,
      NULL,
      i_log_level + 2);

  END IF;

  -- Check that Posting date is a valid date.
  BEGIN
    v_tmp_date := TO_DATE(rv_validate_ar_claims.postng_date,'YYYYMMDD');

  EXCEPTION
    WHEN OTHERS THEN
      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Posting Date [' || rv_validate_ar_claims.postng_date || '] to a date.');

      o_valdtn_status := pc_valdtn_status_invalid;

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Posting Date [' || rv_validate_ar_claims.postng_date || '] to a date.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

  END;

  -- Validate the Claim Amount.
  DECLARE
    v_number_field NUMBER;
  BEGIN
    v_number_field := NVL(rv_validate_ar_claims.claim_amt,0); -- Test to see if value is a number.
    IF rv_validate_ar_claims.claim_amt IS NULL THEN
      o_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Claim Amount [' || rv_validate_ar_claims.claim_amt || '] is invalid.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Claim amount [' || rv_validate_ar_claims.claim_amt || '] is invalid.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Claim Amount [' || rv_validate_ar_claims.claim_amt || '] to a number.');

      o_valdtn_status := pc_valdtn_status_invalid;

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Claim Amount [' || rv_validate_ar_claims.claim_amt || '] to a number.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

  END;

  -- Validate the Tax Amount.
  DECLARE
    v_number_field NUMBER;
  BEGIN
    v_number_field := NVL(rv_validate_ar_claims.tax_amt,0); -- Test to see if value is a number.
    IF rv_validate_ar_claims.tax_amt IS NULL THEN
      o_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Tax Amount [' || rv_validate_ar_claims.tax_amt || '] is invalid.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Tax amount [' || rv_validate_ar_claims.tax_amt || '] is invalid.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Tax Amount [' || rv_validate_ar_claims.tax_amt || '] to a number.');

      o_valdtn_status := pc_valdtn_status_invalid;

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Failed to convert Tax Amount [' || rv_validate_ar_claims.tax_amt || '] to a number.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

  END;

  -- Check the Tax Code is not Null.

  IF NVL(rv_validate_ar_claims.tax_code,' ') NOT IN ('S0','S1','S2','S3','S5') THEN
    o_valdtn_status := pc_valdtn_status_invalid;

    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Tax Code ['||rv_validate_ar_claims.tax_code||'] not equal one of S0,S1,S2,S3,S5.');

    -- Add an entry into the validation reason tables.
    pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
      'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Tax Code [' ||rv_validate_ar_claims.tax_code|| '] not equal one of S0,S1,S2,S3,S5.',
      pc_valdtn_severity_critical,
      rv_validate_ar_claims.intfc_batch_code,
      rv_validate_ar_claims.cmpny_code,
      rv_validate_ar_claims.div_code,
      rv_validate_ar_claims.ar_claims_seq,
      NULL,
      NULL,
      i_log_level + 2);

    o_promax_cust_code := NULL;

  END IF;

 -- CF 27/07/2006 Check the Business Segment (DIV), as derived in ICS, is valid for the Reason Code.
 -- Food Claims are Reason Codes ('40' & '41');
 -- Snack Claims are Reason Codes ('42' & '43');
 -- Pet Claims are Reason Codes ('44' & '45').
    IF (rv_validate_ar_claims.div_code = pc_div_code_food and rv_validate_ar_claims.reasn_code NOT IN (pc_ar_claims_reasn_food_tax, pc_ar_claims_reasn_food_notax) OR
      rv_validate_ar_claims.div_code = pc_div_code_snack and rv_validate_ar_claims.reasn_code NOT IN (pc_ar_claims_reasn_snack_tax, pc_ar_claims_reasn_snack_notax) OR
      rv_validate_ar_claims.div_code = pc_div_code_pet and rv_validate_ar_claims.reasn_code NOT IN (pc_ar_claims_reasn_pet_tax, pc_ar_claims_reasn_pet_notax)) THEN
    o_valdtn_status := pc_valdtn_status_invalid;

    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Reason Code [' ||rv_validate_ar_claims.reasn_code|| '] not in this Division [' ||rv_validate_ar_claims.div_code|| '].');

    -- Add an entry into the validation reason tables.
    pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
      'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims reason Code [' ||rv_validate_ar_claims.reasn_code|| '] not in this Division [' ||rv_validate_ar_claims.div_code|| '].',
      pc_valdtn_severity_critical,
      rv_validate_ar_claims.intfc_batch_code,
      rv_validate_ar_claims.cmpny_code,
      rv_validate_ar_claims.div_code,
      rv_validate_ar_claims.ar_claims_seq,
      NULL,
      NULL,
      i_log_level + 2);

  END IF;

  -- Validate the Generic Vendor used for loading AR Claims.
  pv_status := pds_exist.exist_pmx_generic_vndr_code (i_pmx_cmpny_code, i_pmx_div_code, pc_ar_claims_generic_vndr_code, i_log_level + 2, pv_result_msg);

  IF pv_status <> constants.success THEN
    o_valdtn_status := pc_valdtn_status_invalid;

    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Generic Vendor [' || pc_ar_claims_generic_vndr_code || '] is invalid.');

    -- Add an entry into the validation reason tables.
    pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
      'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Generic Vendor [' || pc_ar_claims_generic_vndr_code || '] is invalid.',
      pc_valdtn_severity_critical,
      rv_validate_ar_claims.intfc_batch_code,
      rv_validate_ar_claims.cmpny_code,
      rv_validate_ar_claims.div_code,
      rv_validate_ar_claims.ar_claims_seq,
      NULL,
      NULL,
      i_log_level + 2);

  END IF;

  /*
  AR Claims are created in SAP for the required Customer. Sometimes these claims
  are created at a customer (hierarchy) level which may not be a customer in Promax
  (ie Head Office). To allow these claims to interface and load into Promax the
  Customer must be valid in Promax. In these circumstances, an alternative Customer
  is entered (in addition to the Head Office customer) on the SAP claim. If an
  Alternate Customer is entered, the interface assumes it to be the customer to use.
  Basically:
    1. Claims will load into Promax at Alternate Payee (if entered), else the original customer level
    2. Claims are returned to SAP at the Customer level at which they were originally entered

  Note: The field (REFKEY2) used to store the Alternate Customer is a free format text
  field in SAP. There is no data validation on this field.
  */

  -- Validate the Alternate Customer Hierarchy.
  IF rv_validate_ar_claims.bus_prtnr_ref2 IS NOT NULL THEN

    -- The Promax Customer codes are 8 chars in length. If Alternate Customer number
    -- value is > 8 chars, only use the last 8 chars.
    IF LENGTH(rv_validate_ar_claims.bus_prtnr_ref2) > 8 THEN
      o_promax_cust_code := SUBSTR(rv_validate_ar_claims.bus_prtnr_ref2,3,8);
    ELSE
      o_promax_cust_code := rv_validate_ar_claims.bus_prtnr_ref2;
    END IF;

    -- Check that the Alternate Customer exists in Promax.
    pv_status := pds_exist.exist_cust_code(i_pmx_cmpny_code, i_pmx_div_code, o_promax_cust_code, i_log_level + 2, pv_result_msg);
    IF pv_status != constants.success THEN

      -- Flag this record as invalid as the Alternate Payee is invalid.
      o_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Alternate Payee [' || rv_validate_ar_claims.bus_prtnr_ref2 || '] is invalid. Cust [' || rv_validate_ar_claims.cust_code || '].');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Alt Payee [' || rv_validate_ar_claims.bus_prtnr_ref2 || '] is invalid. Cust [' || rv_validate_ar_claims.cust_code || '].',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

        o_promax_cust_code := NULL;

    END IF;

  ELSE -- IF rv_ar_claims.bus_prtnr_ref2 IS NULL.

    -- Since the Alternate Customer is not used, use the Customer Code.
    -- Perform a lookup to check to see if the Customer Code is a Del-To and a Payee.
    -- Check if the Customer Code is also a Del-To Customer.
    pv_status := cust_num_is_also_del_to(rv_validate_ar_claims.cmpny_code, rv_validate_ar_claims.cust_code, i_log_level + 2, pv_result_msg);
    IF pv_status = constants.success THEN

      o_promax_cust_code := SUBSTR(rv_validate_ar_claims.cust_code,3,8);

      -- Check the Del-To/Payer Customer is in Promax.
      pv_status := pds_exist.exist_cust_code(i_pmx_cmpny_code, i_pmx_div_code, o_promax_cust_code, i_log_level + 2, pv_result_msg);
      IF pv_status != constants.success THEN

        -- Flag as invalid as the customer payee / del to is not in Promax and therefore is invalid.
        o_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Cust Del-To/Payee is not a valid Promax cust point: [' ||rv_validate_ar_claims.cust_code ||'] is invalid.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Cust Del-To/Payee [' || rv_validate_ar_claims.cust_code || '] is invalid.',
          pc_valdtn_severity_critical,
          rv_validate_ar_claims.intfc_batch_code,
          rv_validate_ar_claims.cmpny_code,
          rv_validate_ar_claims.div_code,
          rv_validate_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 2);

        o_promax_cust_code := NULL;

      END IF;

    ELSE

        -- Now perform a lookup to see if there is a Sales Hierarchy Node that is
        -- represented by this Payee.
        pv_status := cust_num_has_hierarchy_node(rv_validate_ar_claims.cmpny_code, rv_validate_ar_claims.cust_code,v_cust_code, i_log_level + 2, pv_result_msg);
        IF pv_status != constants.success THEN

          o_valdtn_status := pc_valdtn_status_invalid;

          write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Customer Payee Number: [' || rv_validate_ar_claims.cust_code ||'] not be resolved to a Del-To or a Hierarchy Node.');

          -- Add an entry into the validation reason tables.
          pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
            'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Cust Payee[' || rv_validate_ar_claims.cust_code|| '] not resolved to a Del-To or Hier node.',
            pc_valdtn_severity_critical,
            rv_validate_ar_claims.intfc_batch_code,
            rv_validate_ar_claims.cmpny_code,
            rv_validate_ar_claims.div_code,
            rv_validate_ar_claims.ar_claims_seq,
            NULL,
            NULL,
            i_log_level + 2);

          o_promax_cust_code := NULL;

        ELSE -- pv_status = constants.success.`

          o_promax_cust_code := SUBSTR(v_cust_code,3,8);

          -- Check the Hierarchy Node is in Promax.
          pv_status := pds_exist.exist_cust_code(i_pmx_cmpny_code, i_pmx_div_code, o_promax_cust_code, i_log_level + 2, pv_result_msg);
          IF pv_status != constants.success THEN

            -- Flag this record as invalid as the Alternate Payee is invalid.
            o_valdtn_status := pc_valdtn_status_invalid;

            write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Identified Del-To/Hierarchy Node is not a valid Promax Customer point: [' || o_promax_cust_code ||'] is invalid.');

            -- Add an entry into the validation reason tables.
            pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
              'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Cust Del-To/Hierarchy Node [' || o_promax_cust_code || '] not Promax Cust.',
              pc_valdtn_severity_critical,
              rv_validate_ar_claims.intfc_batch_code,
              rv_validate_ar_claims.cmpny_code,
              rv_validate_ar_claims.div_code,
              rv_validate_ar_claims.ar_claims_seq,
              NULL,
              NULL,
              i_log_level + 2);

            o_promax_cust_code := NULL;

          END IF; -- pds_exist.exist_pmx_cust_code_atlas.
        END IF; -- cust_num_has_hier_node.
    END IF;
  END IF;

  -- Test the Claim Ref field if a Promax Cust was able to be defined.
  IF o_promax_cust_code IS NOT NULL THEN
    IF rv_validate_ar_claims.claim_ref IS NULL THEN

      -- Flag this record as invalid as the Claim Ref cannot be null.
      o_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'AR Claims Claim reference is null.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
        'AR Claims Claim Ref is null.',
        pc_valdtn_severity_critical,
        rv_validate_ar_claims.intfc_batch_code,
        rv_validate_ar_claims.cmpny_code,
        rv_validate_ar_claims.div_code,
        rv_validate_ar_claims.ar_claims_seq,
        NULL,
        NULL,
        i_log_level + 2);

      o_promax_cust_code := NULL;
    ELSE

      -- Customer must have a valid Account Manager associated with it.
      pv_status := pds_exist.exist_acct_mgr(i_pmx_cmpny_code, i_pmx_div_code, o_promax_cust_code, i_log_level + 2, pv_result_msg);
      IF pv_status != constants.success THEN

        -- Flag this record as invalid as the there is not a valid Account Manager
        -- linked to this Customer.
        o_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: AR Claims Customer [' || o_promax_cust_code || '] has no valid Account Manager linked to it.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Cust [' || o_promax_cust_code || '] has no valid Account Manager linked to it.',
          pc_valdtn_severity_critical,
          rv_validate_ar_claims.intfc_batch_code,
          rv_validate_ar_claims.cmpny_code,
          rv_validate_ar_claims.div_code,
          rv_validate_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 2);

        o_promax_cust_code := NULL;

      ELSE -- o_promax_cust_code IS NOT NULL and claim_ref IS NOT NULL and there is a valid Account Manager linked to customer.
        -- Customer & Claim Reference must not already exist in Promax.

        IF pds_exist.exist_claim_doc(i_pmx_cmpny_code, i_pmx_div_code, o_promax_cust_code,rv_validate_ar_claims.claim_ref, i_log_level + 2, pv_result_msg) = constants.success
        OR pds_exist.exist_sap_ar_claim(rv_validate_ar_claims.cmpny_code, rv_validate_ar_claims.div_code, o_promax_cust_code, rv_validate_ar_claims.claim_ref, pv_log_level + 2, pv_result_msg) = constants.success THEN
          -- Flag this record as invalid as the Claim reference already exists for this Customer.
          o_valdtn_status := pc_valdtn_status_invalid;

          -- Identify/suggest an alternative Claim reference to use.
          pv_status := find_unused_claimref(i_pmx_cmpny_code, i_pmx_div_code, rv_validate_ar_claims.cmpny_code, rv_validate_ar_claims.div_code, o_promax_cust_code, rv_validate_ar_claims.claim_ref, v_unused_claimref, pv_log_level + 2);

          write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Exists for AR Claims Cust [' || o_promax_cust_code || '], try ['||v_unused_claimref||'].');
          -- CC39530 GB 17/10/08 - Include the Atlas accounting document information.
          pv_status := find_valid_acctg_doc(rv_validate_ar_claims.cmpny_code, rv_validate_ar_claims.div_code, rv_validate_ar_claims.cust_code, rv_validate_ar_claims.claim_ref, v_match_acctg_doc_num, v_match_fiscl_year, v_match_line_item_num, pv_log_level + 2, pv_result_msg);
          write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Existing claim Atlas key is Accounting Document Number ['||v_match_acctg_doc_num||'], Fiscal Year ['||v_match_fiscl_year||'], Line Item Number ['||v_match_line_item_num||'].');
          write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Invalid claim Atlas key is Accounting Document Number ['||rv_validate_ar_claims.acctg_doc_num||'], Fiscal Year ['||rv_validate_ar_claims.fiscl_year||'], Line Item Number ['||rv_validate_ar_claims.line_item_num||'].');

          -- Add an entry into the validation reason tables.
          pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
            'ClaimRef [' || rv_validate_ar_claims.claim_ref || ']: Exists for AR Claims Cust [' || o_promax_cust_code || '], try ['||v_unused_claimref||'].',
            pc_valdtn_severity_critical,
            rv_validate_ar_claims.intfc_batch_code,
            rv_validate_ar_claims.cmpny_code,
            rv_validate_ar_claims.div_code,
            rv_validate_ar_claims.ar_claims_seq,
            NULL,
            NULL,
            pv_log_level + 2);

          -- CC39530 GB 17/10/08 - Include the Atlas accounting document information.
          pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
            'ClaimRef ['|| rv_validate_ar_claims.claim_ref || ']: Existing claim Atlas Acctg Doc ['||v_match_acctg_doc_num||'] Yr ['||v_match_fiscl_year||'] Line ['||v_match_line_item_num||'].',
            pc_valdtn_severity_critical,
            rv_validate_ar_claims.intfc_batch_code,
            rv_validate_ar_claims.cmpny_code,
            rv_validate_ar_claims.div_code,
            rv_validate_ar_claims.ar_claims_seq,
            NULL,
            NULL,
            pv_log_level + 2);

          -- CC39530 GB 17/10/08 - Include the Atlas accounting document information.
          pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
            'ClaimRef ['|| rv_validate_ar_claims.claim_ref || ']: Invalid claim Atlas Acctg Doc ['||rv_validate_ar_claims.acctg_doc_num||'] Yr ['||rv_validate_ar_claims.fiscl_year||'] Line ['||rv_validate_ar_claims.line_item_num||'].',
            pc_valdtn_severity_critical,
            rv_validate_ar_claims.intfc_batch_code,
            rv_validate_ar_claims.cmpny_code,
            rv_validate_ar_claims.div_code,
            rv_validate_ar_claims.ar_claims_seq,
            NULL,
            NULL,
            pv_log_level + 2);

          o_promax_cust_code := NULL;

        END IF; -- IF Promax_Common.Claimdoc_exists.
      END IF; -- rv_ar_claims.claim_ref IS NULL.
    END IF; -- IF o_promax_cust_code IS NOT NULL.
  END IF;

  write_log(pc_data_type_ar_claims, 'N/A',i_log_level + 1,'End of csr_validate_ar_claims cursor loop.');

  -- Close csr_validate_ar_claims cursor.
  write_log(pc_data_type_ar_claims, 'N/A', i_log_level + 1, 'Close csr_validate_ar_claims cursor.');
  CLOSE csr_validate_ar_claims;

  RETURN constants.success;

  -- End validate_claims_record procedure.
  write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,'validate_claim_record - END.');

EXCEPTION
  WHEN e_processing_failure THEN
    o_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.VALIDATE_CLAIM_RECORD:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code,'Interface Batch Code',i_intfc_batch_code,'Ar Claims Seq',i_ar_claims_seq);
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,o_result_msg);

    RETURN constants.failure;

  WHEN e_processing_error THEN
    o_result_msg :=
      utils.create_error_msg('PDS_AR_CLAIMS_01_PRC.VALIDATE_CLAIM_RECORD:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code,'Interface Batch Code',i_intfc_batch_code,'Ar Claims Seq',i_ar_claims_seq);
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,o_result_msg);

    RETURN constants.failure;

  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.VALIDATE_CLAIM_RECORD:',
      'Unexpected Exception - validate_claim_record aborted.') ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code,'Interface Batch Code',i_intfc_batch_code,'Ar Claims Seq',i_ar_claims_seq) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,o_result_msg);

    RETURN constants.failure;

END validate_claim_record;


FUNCTION cust_num_has_hierarchy_node (
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_cust_code IN pds_ar_claims.cust_code%TYPE,
  o_cust_to_use OUT pds_ar_claims.cust_code%TYPE,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER IS

  CURSOR csr_cust_prtnr_roles IS
    SELECT
      t1.cust_code
    FROM
      pmx_cust_prtnr_roles_view t1
    WHERE
      t1.sales_org = i_cmpny_code
      AND t1.dstrbtn_chnl = pc_distbn_chnl_non_specific  -- 10.
      AND t1.cust_dvsn = pc_ar_claims_div_non_specific -- 51.
      AND t1.prtnr_fnctn = pc_ar_claims_rep -- "ZR" (Represented by).
      AND t1.cust_code_bus_prtnr = i_cust_code;
  rv_cust_prtnr_roles csr_cust_prtnr_roles%ROWTYPE;

  o_constant_value pds_constants.const_value%TYPE;

BEGIN

  -- Initialize the indicator variable.
  o_cust_to_use := NULL;
  o_constant_value := constants.failure;

  OPEN csr_cust_prtnr_roles;
  FETCH csr_cust_prtnr_roles INTO rv_cust_prtnr_roles;
  IF csr_cust_prtnr_roles%FOUND THEN
    o_cust_to_use := rv_cust_prtnr_roles.cust_code;
    o_constant_value:= constants.success;

    -- Do another fetch to see if another record is returned.
    FETCH csr_cust_prtnr_roles INTO rv_cust_prtnr_roles;
    -- Customer Payee should only have a one-to-one link to a Customer sales hierarchy node.
    -- Duplicates indicate an error (ie another record should not be returned here).
    IF csr_cust_prtnr_roles%FOUND THEN -- Duplicate found.
      o_cust_to_use := NULL;
      o_constant_value:= constants.failure;
    END IF;
  END IF;

  -- Close the curser.
  CLOSE csr_cust_prtnr_roles;

  -- Set the return variable value.
  RETURN o_constant_value;

EXCEPTION
  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.CUST_NUM_HAS_HIERARCHY_NODE:',
      'Unexpected Exception - cust_num_has_hierarchy_node aborted.') ||
      utils.create_params_str('Company Code',i_cmpny_code,'Customer Code',i_cust_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,o_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    RETURN constants.failure;

END cust_num_has_hierarchy_node;


FUNCTION cust_num_is_also_del_to (
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_cust_to_use IN pds_ar_claims.cust_code%TYPE,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER IS

  -- Define the cursor for retrieving the Del-To and Payee Customer codes.
  CURSOR csr_rec_count IS
    SELECT
      COUNT(*) AS rec_count
    FROM
      (SELECT DISTINCT
         t1.cust_code,
         t1.prtnr_fnctn
       FROM
         pmx_cust_prtnr_roles_view t1
       WHERE
         t1.cust_code = i_cust_to_use
         AND t1.sales_org = i_cmpny_code
         AND t1.prtnr_fnctn IN (pc_ar_claims_payer,pc_ar_claims_sold_to) -- "RG" (Payer), "AG" (Sold-To).
         AND t1.cust_code_bus_prtnr = i_cust_to_use);
  rv_rec_count csr_rec_count%ROWTYPE;

  o_constant_value pds_constants.const_value%TYPE;

BEGIN

  -- Initialize the variables.
  o_constant_value := constants.failure;

  -- Count the number of returned rows.
  -- If the number of rows returned is 2, assumption is they are a Del-To and a Payee.
  OPEN csr_rec_count;
  FETCH csr_rec_count INTO rv_rec_count;

  IF csr_rec_count%FOUND THEN
    IF rv_rec_count.rec_count = 2 THEN
      o_constant_value:= constants.success;
    END IF;
  END IF;

  -- Close the curser.
  CLOSE csr_rec_count;

  -- Return the return variable value.
  RETURN o_constant_value;

EXCEPTION
  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.CUST_NUM_IS_ALSO_DEL_TO:',
      'Unexpected Exception - cust_num_is_also_del_to.') ||
      utils.create_params_str('Company Code',i_cmpny_code,'Customer Code To Use',i_cust_to_use) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,o_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ar_claims_01_prc,'MFANZ Promax AR Claims Process 01',
      pv_result_msg);
    RETURN constants.failure;

END cust_num_is_also_del_to;


FUNCTION find_unused_claimref (
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_pmx_cust_code IN pds_ar_claims.cust_code%TYPE,
  i_claim_ref IN claimdoc.claimref%TYPE,
  o_unused_claimref OUT claimdoc.claimref%TYPE,
  i_log_level NUMBER)
  RETURN NUMBER IS

  -- VARIABLE DECLARATION.
  v_registrkey      claimdoc.registrkey%TYPE;
  v_unused_claimref claimdoc.claimref%TYPE;
  v_count          INTEGER;
  v_found          BOOLEAN;

BEGIN

  -- Initialise the variables.
  v_found := FALSE;
  v_count := 0;

  WHILE v_found = FALSE
  LOOP
    v_count := v_count + 1;
    o_unused_claimref := SUBSTR(i_claim_ref,1,12-(LENGTH(TO_CHAR(v_count))+1)) || '/' ||TO_CHAR(v_count);

    IF pds_exist.exist_claim_doc(i_pmx_cmpny_code, i_pmx_div_code, i_pmx_cust_code, o_unused_claimref, i_log_level + 2, pv_result_msg) <> constants.success
    AND pds_exist.exist_sap_ar_claim(i_cmpny_code, i_div_code, i_pmx_cust_code, o_unused_claimref, i_log_level + 2, pv_result_msg) <> constants.success THEN
       v_found := TRUE;
    END IF;

  END LOOP;

  RETURN constants.success;

END find_unused_claimref;

FUNCTION find_valid_acctg_doc (
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_cust_code IN pds_ar_claims.cust_code%TYPE,
  i_claim_ref IN claimdoc.claimref%TYPE,
  o_match_acctg_doc_num OUT pds_ar_claims.acctg_doc_num%TYPE,
  o_match_fiscl_year OUT pds_ar_claims.fiscl_year%TYPE,
  o_match_line_item_num OUT pds_ar_claims.line_item_num%TYPE,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER IS

  -- CURSOR DECLARATION.
  -- This cursor looks up the PDS_AR_CLAIMS table to locate the matching "VALID" Claim
  -- which has already been loaded into Promax, and returns Atlas Accounting doc info.
  CURSOR csr_ar_claims_acctg IS
    SELECT
      acctg_doc_num,
      fiscl_year,
      line_item_num
    FROM
      pds_ar_claims
    WHERE
      cmpny_code = i_cmpny_code
      AND div_code = i_div_code
      AND cust_code = i_cust_code
      AND claim_ref = i_claim_ref
      AND valdtn_status = pc_valdtn_status_valid;
  rv_ar_claims_acctg csr_ar_claims_acctg%ROWTYPE;

BEGIN

  OPEN csr_ar_claims_acctg;
  LOOP
    FETCH csr_ar_claims_acctg INTO rv_ar_claims_acctg;
    EXIT WHEN csr_ar_claims_acctg %NOTFOUND;
  END LOOP;

  o_match_acctg_doc_num := rv_ar_claims_acctg.acctg_doc_num ;
  o_match_fiscl_year    := rv_ar_claims_acctg.fiscl_year ;
  o_match_line_item_num := rv_ar_claims_acctg.line_item_num ;

  CLOSE csr_ar_claims_acctg;

  RETURN constants.success;

EXCEPTION
  -- Send warning message via pds_log.
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.FIND_VALID_ACCTG_DOC:',
      'Unexpected Exception - find_valid_acctg_doc.') || utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,o_result_msg);

END find_valid_acctg_doc;

FUNCTION check_for_differences (
  i_intfc_batch_code IN pds_ar_claims.intfc_batch_code%TYPE,
  i_cmpny_code IN pds_ar_claims.cmpny_code%TYPE,
  i_div_code IN pds_ar_claims.div_code%TYPE,
  i_ar_claims_seq IN pds_ar_claims.ar_claims_seq%TYPE,
  o_diff_count OUT NUMBER,
  i_log_level IN NUMBER,
  o_result_msg OUT VARCHAR2)
  RETURN NUMBER IS

  -- VARIABLE DECLARATION.
  v_claim_stat VARCHAR2(70);

  -- CURSOR DECLARATION.
  -- Retrieve all unchecked AR Claim records to be validated.
  CURSOR csr_ar_claims IS
    SELECT
      intfc_batch_code,
      cmpny_code,
      div_code,
      ar_claims_seq,
      cust_code,
      claim_amt,
      claim_ref,
      assignmnt_num,
      tax_amt,
      postng_date,
      period_num,
      reasn_code,
      acctg_doc_num,
      fiscl_year,
      line_item_num,
      bus_prtnr_ref2,
      tax_code,
      idoc_type,
      idoc_num,
      idoc_date,
      promax_cust_code,
      promax_cust_vndr_code,
      promax_ar_load_date,
      promax_ar_apprvl_date,
      valdtn_status,
      procg_status
    FROM
      pds_ar_claims
    WHERE
      cmpny_code = i_cmpny_code
      AND div_code = i_div_code
      AND intfc_batch_code = i_intfc_batch_code
      AND ar_claims_seq = i_ar_claims_seq
    FOR UPDATE NOWAIT;
  rv_ar_claims csr_ar_claims%ROWTYPE;

  -- This cursor looks up the PDS_AR_CLAIMS table to locate the matching "VALID" Claim
  -- which has already been loaded into Promax.
  CURSOR csr_ar_claims_old IS
    SELECT
      intfc_batch_code,
      cmpny_code,
      div_code,
      ar_claims_seq,
      cust_code,
      claim_amt,
      claim_ref,
      assignmnt_num,
      tax_amt,
      postng_date,
      period_num,
      reasn_code,
      acctg_doc_num,
      fiscl_year,
      line_item_num,
      bus_prtnr_ref2,
      tax_code,
      idoc_type,
      idoc_num,
      idoc_date,
      promax_cust_code,
      promax_cust_vndr_code,
      promax_ar_load_date,
      promax_ar_apprvl_date,
      valdtn_status,
      procg_status
    FROM
      pds_ar_claims
    WHERE
      acctg_doc_num = rv_ar_claims.acctg_doc_num
      AND fiscl_year = rv_ar_claims.fiscl_year
      AND line_item_num = rv_ar_claims.line_item_num
      AND valdtn_status  = pc_valdtn_status_valid;
  rv_ar_claims_old csr_ar_claims_old%ROWTYPE;

BEGIN

  -- Read through each of the new AR Claim records to be validated.
  OPEN csr_ar_claims;
  LOOP
    FETCH csr_ar_claims INTO rv_ar_claims;
    EXIT WHEN csr_ar_claims %NOTFOUND;

    -- Process each of the old ("VALID") AR Claim records matching this current claim.
    -- There should only be one matching "VALID" claim.
    OPEN csr_ar_claims_old;
    LOOP
      FETCH csr_ar_claims_old INTO rv_ar_claims_old;
      EXIT WHEN csr_ar_claims_old %NOTFOUND;

      -- Now compare all the fields.
      o_diff_count := 0;

      -- Check whether the Period Number is different to the original.
      IF utils.are_not_equal(rv_ar_claims.period_num,rv_ar_claims_old.period_num) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Period Number was : ' || rv_ar_claims_old.period_num || ' received : ' || rv_ar_claims.period_num || '.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Period Number ['|| rv_ar_claims.period_num || '], original was [' || rv_ar_claims_old.period_num||'].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Posting Date is different to the original.
      IF utils.are_not_equal(rv_ar_claims.postng_date,rv_ar_claims_old.postng_date) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Posting Date was : ' || rv_ar_claims_old.postng_date || ' received : ' || rv_ar_claims.postng_date||'.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Posting Date ['||rv_ar_claims.postng_date ||'], original was ['|| rv_ar_claims_old.postng_date ||'].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Company Code is different to the original.
      IF utils.are_not_equal(rv_ar_claims.cmpny_code,rv_ar_claims_old.cmpny_code) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Company Code was : ' || rv_ar_claims_old.cmpny_code || ' received : ' || rv_ar_claims.cmpny_code|| '.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Company Code ['|| rv_ar_claims.cmpny_code || '], original was ['|| rv_ar_claims_old.cmpny_code||'].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Customer Number is different to the original.
      IF utils.are_not_equal(rv_ar_claims.cust_code,rv_ar_claims_old.cust_code) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Customer Number was : ' || rv_ar_claims_old.cust_code || ' received : ' ||rv_ar_claims.cust_code||'.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Cust ['|| rv_ar_claims.cust_code || '], original was [' || rv_ar_claims_old.cust_code || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Claim Amount is different to the original.
      IF utils.are_not_equal(rv_ar_claims.claim_amt,rv_ar_claims_old.claim_amt ) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Amount was : ' || rv_ar_claims_old.claim_amt || ' received : ' || rv_ar_claims.claim_amt||'.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Amount ['|| rv_ar_claims.claim_amt || '], original was [' || rv_ar_claims_old.claim_amt || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Tax Amount is different to the original.
      IF utils.are_not_equal(rv_ar_claims.tax_amt,rv_ar_claims_old.tax_amt) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Tax Amount was : ' || rv_ar_claims_old.tax_amt || ' received : ' || rv_ar_claims.tax_amt||'.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: New Claim Tax Amount ['|| rv_ar_claims.tax_amt || '], original was [' || rv_ar_claims_old.tax_amt || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Tax Code is different to the original.
      IF utils.are_not_equal(rv_ar_claims.tax_code,rv_ar_claims_old.tax_code) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Tax Code was : ' || rv_ar_claims_old.tax_code || ' received : ' ||rv_ar_claims.tax_code||'.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Tax Code ['|| rv_ar_claims.tax_code || '], original was [' || rv_ar_claims_old.tax_code || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Reason Code is different to the original.
      IF utils.are_not_equal(NVL(rv_ar_claims.reasn_code,' '),NVL(rv_ar_claims_old.reasn_code,' ')) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Reason Code was : ' || rv_ar_claims_old.reasn_code || ' received : ' || rv_ar_claims.reasn_code || '.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Reason Code ['|| rv_ar_claims.reasn_code || '], original was [' ||rv_ar_claims_old.reasn_code || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Claim Ref is different to the original.
      IF utils.are_not_equal(rv_ar_claims.claim_ref,rv_ar_claims_old.claim_ref) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Claim_ref was : ' || rv_ar_claims_old.claim_ref || '.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Original Claim Ref was ['||rv_ar_claims_old.claim_ref || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Alternate Payee is different to the original.
      IF utils.are_not_equal(rv_ar_claims.bus_prtnr_ref2,rv_ar_claims_old.bus_prtnr_ref2) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Alternate Payee was : ' || rv_ar_claims_old.bus_prtnr_ref2 || ' received : ' || rv_ar_claims.bus_prtnr_ref2||'.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Alternate Payee ['|| rv_ar_claims.bus_prtnr_ref2 || '], original was [' || rv_ar_claims_old.bus_prtnr_ref2 || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check whether the Assignment Number is different to the original.
      IF utils.are_not_equal(rv_ar_claims.assignmnt_num,rv_ar_claims_old.assignmnt_num) THEN
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Assignment Number was : ' || rv_ar_claims_old.assignmnt_num || ' received : ' || rv_ar_claims.assignmnt_num||'.');

        -- Add an entry into the validation reason tables
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Assignment Number ['|| rv_ar_claims.assignmnt_num || '], original was [' || rv_ar_claims_old.assignmnt_num || '].',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        o_diff_count := o_diff_count + 1;
      END IF;

      -- Check the differences Counter.
      IF o_diff_count <> 0 THEN

        -- Determine the status (in Promax) of the original claim.
        IF rv_ar_claims_old.promax_ar_apprvl_date IS NOT NULL THEN
          v_claim_stat := 'HAS already been approved in Promax.';
        ELSE
          v_claim_stat := 'HAS NOT yet been approved.';
        END IF;

        -- Log an error to indicate the current Claim has already been processed into Promax but now differs.
        write_log(pc_data_type_ar_claims,'N/A',i_log_level + 3,'ClaimRef ['|| rv_ar_claims.claim_ref || ']: This transaction is now out of sync between SAP and Promax. This requires manual intervention in either SAP or Promax to rectify.' || v_claim_stat || '.' || o_diff_count || ' differences detected.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
          'ClaimRef ['|| rv_ar_claims.claim_ref || ']: ' || v_claim_stat || ' ' || o_diff_count || ' differences.',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claims,
         'ClaimRef ['|| rv_ar_claims.claim_ref || ']: Trans out of sync (SAP vs Promax). Fix manually.',
          pc_valdtn_severity_critical,
          rv_ar_claims.intfc_batch_code,
          rv_ar_claims.cmpny_code,
          rv_ar_claims.div_code,
          rv_ar_claims.ar_claims_seq,
          NULL,
          NULL,
          i_log_level + 3);

      END IF;

    END LOOP; -- Inner (old) LOOP.

    -- Close the csr_ar_claims_old cursor.
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 2,'Close the cursor - csr_ar_claims_old.');
    CLOSE csr_ar_claims_old;

  END LOOP; -- Inner (new) LOOP.

  -- Close the csr_ar_claims cursor.
  write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,'Close the cursor - csr_ar_claims.');
  CLOSE csr_ar_claims;

  RETURN constants.success;

  write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,'check_for_differences - END.');

EXCEPTION
  -- Send warning message via pds_log.
  WHEN OTHERS THEN
    o_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMS_01_PRC.CHECK_FOR_DIFFERENCES:',
      'Unexpected Exception - check_for_differences.') ||
      utils.create_params_str('Company Code',i_cmpny_code,'Division Code',i_div_code,'Interface Batch Code',i_intfc_batch_code,'AR Claims Sequence',i_ar_claims_seq) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claims,'N/A',i_log_level + 1,o_result_msg);

    RETURN constants.failure;

END check_for_differences;

END pds_ar_claims_01_prc; 
/
