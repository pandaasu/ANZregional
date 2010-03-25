CREATE OR REPLACE PACKAGE pds_cust_01_prc IS

/*******************************************************************************
  NAME:      run_pds_cust_01_prc
  PURPOSE:   This procedure performs three key tasks:

             1. Validates the Customer data in the PDS schema.
             2. Transfers validated Customer data into the Postbox schema.
             3  Initiates the transfer from Postbox to Promax schema

             This procedure is triggered by a pipe message from PDS_CUST_01_INT
             interface procedure, which loads Customer data into the PDS schema.

             NOTE: v_debug is a debugging constant, defined at the package level.
             If FALSE (ie. we're running in production) then send Alerts, else
             sends emails.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/08/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_cust_01_prc;

/*******************************************************************************
  NAME:      validate_pds_customer
  PURPOSE:   This procedure executes the validate_pds_customer_atlas procedure, by
             Company and Division.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/08/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_customer;

/*********************************************************************************
  NAME:      validate_pds_customer_atlas
  PURPOSE:   This procedure validates the Customer data in the PDS_CUST_HIER_LOAD table
             in the PDS schema.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   29/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   07/02/2006 Craig Ford           Include processing for AUS PETCARE.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Division Code                        01

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_customer_atlas (
  i_cmpny_code IN pds_cust_hier_load.cmpny_code%TYPE,
  i_div_code IN pds_cust_hier_load.div_code%TYPE);

/*******************************************************************************
  NAME:      transfer_customer
  PURPOSE:   This procedure executes the Transfer Customer procedures by company
             and division, for valid Customer data in the PDS Customer Hierarchy
             Load table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- -----------------------------------------
  1.0   10/08/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ ---------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE transfer_customer;

/*******************************************************************************
  NAME:      transfer_customer_postbox
  PURPOSE:   This procedure transfers validated Customer data from the PDS Schema
             into the Postbox Schema.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/08/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   07/02/2006 Craig Ford           Include processing for AUS PETCARE.
  1.2   14/03/2006 Craig Ford           Add processing to identify new Customers.
                                         Insert new customers into (temp) customer table for reporting.
  1.3   05/10/2009 Steve Gregan         Modified processing to fix hierarchy loading bug.
  1.4   10/02/2010 Rob Bishop           Merged Snack data mapping section from Dev package
                                          into this one and added more comments.
  1.5   26/02/2010 Rob Bishop           Modified logic from Steve so it didn't do work or generate
                                          error messages for Customers not being inserted.
                                          (Relocated an IF statement).
                                        Also replaced hardcoding with constants.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Division Code                        01

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
*******************************************************************************/
PROCEDURE transfer_customer_postbox (
  i_cmpny_code IN VARCHAR2,
  i_div_code IN VARCHAR2);

/*******************************************************************************
  NAME:      initiate_postbox_customer
  PURPOSE:   Initiate the Promax Postbox Customer process. This moves Customer
             data from the Postbox to the Promax Schema. The Postbox job is
             initiated by adding a Job Control record into the PDS_PMX_JOB_CNTL
             table using the create_promax_job_control utility function.
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/08/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE initiate_postbox_customer;

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

END pds_cust_01_prc;

/


CREATE OR REPLACE PACKAGE BODY         pds_cust_01_prc IS

  -- PACKAGE VARIABLE DECLARATIONS
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_cmpny_code_australia     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia','CMPNY_CODE');
  pc_cmpny_code_new_zealand   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('new_zealand','CMPNY_CODE');
  pc_div_code_snack           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('snack','DIV_CODE');
  pc_div_code_food            CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('food','DIV_CODE');
  pc_div_code_pet             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pet','DIV_CODE');
  pc_regn_code_australia      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia','REGN_CODE');
  pc_regn_code_new_zealand    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('new_zealand','REGN_CODE');
  pc_job_type_cust_01_prc     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_01_prc','JOB_TYPE');
  pc_data_type_cust           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust','DATA_TYPE');
  pc_data_type_not_applicable CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_applicable','DATA_TYPE');
  pc_debug                    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_minor        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_valdtn_severity_critical CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('critical','VALDTN_SEVERITY');
  pc_valdtn_status_unchecked  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unchecked','VALDTN_STATUS');
  pc_valdtn_status_valid      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('valid','VALDTN_STATUS');
  pc_valdtn_status_invalid    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('invalid','VALDTN_STATUS');
  pc_valdtn_status_excluded   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('excluded','VALDTN_STATUS');
  pc_valdtn_type_cust         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust','VALDTN_TYPE');
  pc_procg_status_loaded      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('loaded','PROCG_STATUS');
  pc_procg_status_processed   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('processed','PROCG_STATUS');
  pc_procg_status_completed   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','PROCG_STATUS');
  pc_cust_mid_ref             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('mid_ref','CUST');
  pc_cust_maj_ref             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('maj_ref','CUST');
  pc_cust_invc                CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('invc','CUST');
  pc_cust_cust_family         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_family','CUST');
  pc_cust_funding             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_funding','CUST');
  pc_cust_gl_level_1          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('gl_level_1','CUST');
  pc_cust_gl_level_2          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('gl_level_2','CUST');
  pc_cust_gl_level_3          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('gl_level_3','CUST');
  pc_cust_gl_level_4          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('gl_level_4','CUST');
  pc_cust_gl_level_5          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('gl_level_5','CUST');
  pc_cust_gl_level_6          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('gl_level_6','CUST');
  pc_cust_not_prom            CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_prom','CUST');
  pc_cust_not_active          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_active','CUST');
  pc_cust_not_extax           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_extax','CUST');
  pc_cust_level_1             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_1','CUST');
  pc_cust_level_2             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_2','CUST');
  pc_cust_level_3             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_3','CUST');
  pc_cust_level_4             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_4','CUST');
  pc_cust_level_5             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_5','CUST');
  pc_cust_level_6             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_6','CUST');
  pc_pstbx_cust_load          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_load','PSTBX');
  pc_job_status_completed     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');

PROCEDURE run_pds_cust_01_prc IS

BEGIN

  -- Start run_pds_cust_01_prc procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level,'run_pds_cust_01_prc - START.');

  -- The 3 key tasks: validate, transfer and initiate postbox job.
  validate_pds_customer();
  transfer_customer();
  initiate_postbox_customer();

  -- End run_pds_cust_01_prc procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level,'run_pds_cust_01_prc - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_PRC.RUN_PDS_CUST_01_PRC:',
      'Unexpected Exception - run_pds_cust_01_prc aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_cust,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_prc,'MFANZ Promax Customer Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,'N/A');
    END IF;

END run_pds_cust_01_prc;

PROCEDURE validate_pds_customer IS

BEGIN

  -- Start validate_pds_customer procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'validate_pds_customer - START.');

  -- Execute the Validate PDS Customer procedures for all ATLAS Company / Divisions.
  -- The procedure validates data within the PDS schema.
  validate_pds_customer_atlas (pc_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood.
  validate_pds_customer_atlas (pc_cmpny_code_australia,pc_div_code_food); -- Australia Food.
  validate_pds_customer_atlas (pc_cmpny_code_australia,pc_div_code_pet); -- Australia Pet.
  validate_pds_customer_atlas (pc_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snack.
  validate_pds_customer_atlas (pc_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
  validate_pds_customer_atlas (pc_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Pet.

  -- Trigger the pds_cust_01_rep procedure.
  write_log(pc_data_type_cust, 'N/A', pv_log_level, 'Trigger the PDS_CUST_01_REP procedure.');
  lics_trigger_loader.execute('MFANZ Promax Customer 01 Report',
                              'pds_app.pds_cust_01_rep.run_pds_cust_01_rep',
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_CUST_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_CUST_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_CUST_01_REP'));

  -- End validate_pds_customer procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'validate_pds_customer - END.');

END validate_pds_customer;


PROCEDURE validate_pds_customer_atlas (
  i_cmpny_code IN pds_cust_hier_load.cmpny_code%TYPE,
  i_div_code IN pds_cust_hier_load.div_code%TYPE) IS

  -- VARIABLE DECLARATIONS
  v_valdtn_status         pds_cust_hier_load.valdtn_status%TYPE; -- Record status.
  v_last_cmpny_code       pds_cust_hier_load.cmpny_code%TYPE := ' ';
  v_last_div_code         pds_cust_hier_load.div_code%TYPE := ' ';
  v_last_cust_hier_level  pds_cust_hier.cust_hier_level%TYPE := 99; -- Note: 99 is used to initialize the variable as it does not exist as a hierarchy level.
  v_last_parent_cust_code pbchain.kacc%TYPE;
  v_last_valdtn_status    pds_cust_hier_load.valdtn_status%TYPE;
  v_pmx_cmpny_code        pds_div.pmx_cmpny_code%TYPE;
  v_pmx_div_code          pds_div.pmx_div_code%TYPE;
  v_regn_code             regname.regcode%TYPE;
  v_count                 PLS_INTEGER;
  v_valid_number          NUMBER;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Retrieve all unchecked Customers to be validated.
  CURSOR csr_customer IS
    SELECT
      cust_hier_hdr_seq,
      cmpny_code,
      div_code,
      distbn_chnl_code,
      regn_code,
      cust_hier_level,
      cust_code,
      pos_format_grpg_code,
      cust_name,
      eff_from_date,
      cust_hier_hdr_date,
      price_list_code,
      levels_to_load
    FROM
      pds_cust_hier_load
    WHERE
      cmpny_code = i_cmpny_code
      AND div_code = i_div_code
      AND valdtn_status = pc_valdtn_status_unchecked
      AND procg_status = pc_procg_status_loaded
    ORDER BY
      cust_hier_hdr_seq,
      cmpny_code,
      div_code,
      cust_hier_level
    FOR UPDATE NOWAIT;
  rv_customer csr_customer%ROWTYPE;

  -- RESULT CHECKING PROCEDURE
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

  -- Start validate_pds_customer_atlas procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'validate_pds_customer_atlas - START.');

  -- Clear validation table of records if they exist.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Clear validation table of Customer record if they exist.');
  pds_utils.clear_validation_reason(pc_valdtn_type_cust,NULL, i_cmpny_code,i_div_code,NULL,NULL,NULL,pv_log_level + 2);

  -- Lookup the Promax Company and Division Codes.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Retrieving Promax Company Code.');
  pv_status := pds_lookup.lookup_pmx_cmpny_div_code(i_cmpny_code,i_div_code,v_pmx_cmpny_code,v_pmx_div_code, pv_log_level + 2,pv_result_msg);
  check_result_status;

  -- Read through each of the Customer records to be validated.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Open csr_customer cursor.');
  -- Open csr_customer cursor.
  OPEN csr_customer;
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Looping through the csr_customer cursor.');
  LOOP
    FETCH csr_customer INTO rv_customer;
    EXIT WHEN csr_customer%NOTFOUND;

    v_valdtn_status := pc_valdtn_status_valid;

    -- Check that Price List Code exists and is valid.
    IF rv_customer.price_list_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Price List Code does not exist.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_cust,
        'Price List Code does not exist.',
        pc_valdtn_severity_critical,
        rv_customer.cust_hier_hdr_seq,
        rv_customer.cmpny_code,
        rv_customer.div_code,
        rv_customer.cust_hier_level,
        rv_customer.cust_code,
        NULL,
        pv_log_level + 3);

    -- Check that Price List Code is valid.  Does it exist in the PROMAX.LISTDESC table.
    ELSE
      v_count := 0;

      SELECT count(*) INTO v_count
      FROM listdesc
      WHERE cocode = v_pmx_cmpny_code
        AND divcode = v_pmx_div_code
        AND list = rv_customer.price_list_code;

      IF v_count = 0 THEN
        v_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Price List Code does not exist in the Promax LISTDESC table.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_cust,
          'Price List Code [' || rv_customer.price_list_code || '] does not exist in the Promax LISTDESC table.',
          pc_valdtn_severity_critical,
          rv_customer.cust_hier_hdr_seq,
          rv_customer.cmpny_code,
          rv_customer.div_code,
          rv_customer.cust_hier_level,
          rv_customer.cust_code,
          NULL,
          pv_log_level + 3);
      END IF;
    END IF;

    -- Check that Customer Hierarchy Level is a valid number.
    BEGIN
      v_valid_number := TO_NUMBER(rv_customer.cust_hier_level);

    EXCEPTION
      WHEN OTHERS THEN
        v_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Customer Hierarchy Level ['||rv_customer.cust_hier_level||'] is not a valid number.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_cust,
          'Customer Hierarchy Level ['||rv_customer.cust_hier_level||'] is not a valid number.',
          pc_valdtn_severity_critical,
          rv_customer.cust_hier_hdr_seq,
          rv_customer.cmpny_code,
          rv_customer.div_code,
          rv_customer.cust_hier_level,
          rv_customer.cust_code,
          NULL,
          pv_log_level + 3);
    END;

    -- Check whether Customer Name exists.
    IF rv_customer.cust_name IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Customer Name does not exist.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_cust,
        'Customer Name does not exist.',
        pc_valdtn_severity_critical,
        rv_customer.cust_hier_hdr_seq,
        rv_customer.cmpny_code,
        rv_customer.div_code,
        rv_customer.cust_hier_level,
        rv_customer.cust_code,
        NULL,
        pv_log_level + 3);
    END IF;

    -- Check whether Region exists for Level 6 (Leaf node) Customers.
    IF rv_customer.cust_hier_level = pc_cust_level_6 AND rv_customer.regn_code IS NULL THEN
      -- Note: Original source code was using Level 7.  Confirm that Level 6 is correct.
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Region Code does not exist for Level 6 (Leaf node).');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_cust,
        'Region Code does not exist for Level 6 (Leaf node).',
        pc_valdtn_severity_critical,
        rv_customer.cust_hier_hdr_seq,
        rv_customer.cmpny_code,
        rv_customer.div_code,
        rv_customer.cust_hier_level,
        rv_customer.cust_code,
        NULL,
        pv_log_level + 3);
    END IF;

    -- Check that Region Code exists in the PROMAX.REGNAME table.
    IF rv_customer.regn_code IS NOT NULL THEN

      BEGIN
        SELECT regcode INTO v_regn_code
        FROM regname
        WHERE cocode = v_pmx_cmpny_code
          AND divcode = v_pmx_div_code
          AND region = TRIM(rv_customer.regn_code);
      EXCEPTION
        WHEN OTHERS THEN
          v_valdtn_status := pc_valdtn_status_invalid;

          write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Region Code ['||TRIM(rv_customer.regn_code)||'] does not exist in the Promax REGNAME table.');

          -- Add an entry into the validation reason tables.
          pds_utils.add_validation_reason(pc_valdtn_type_cust,
            'Region Code ['||TRIM(rv_customer.regn_code)||'] does not exist in the Promax REGNAME table.',
            pc_valdtn_severity_critical,
            rv_customer.cust_hier_hdr_seq,
            rv_customer.cmpny_code,
            rv_customer.div_code,
            rv_customer.cust_hier_level,
            rv_customer.cust_code,
            NULL,
            pv_log_level + 3);
      END;
    END IF;

    -- Check whether Customers are correct for the Hierarchy Level.
    IF (rv_customer.cust_hier_level = pc_cust_level_6 AND SUBSTR(rv_customer.cust_code,1,1) <> '1')
      OR (rv_customer.cust_hier_level <> pc_cust_level_6 AND SUBSTR(rv_customer.cust_code,1,1) <> '4') THEN

      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Customer Code does not conform to the Hierarchy Level standard.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_cust,
        'Customer Code does not conform to the Hierarchy Level standard.',
        pc_valdtn_severity_critical,
        rv_customer.cust_hier_hdr_seq,
        rv_customer.cmpny_code,
        rv_customer.div_code,
        rv_customer.cust_hier_level,
        rv_customer.cust_code,
        NULL,
        pv_log_level + 3);
    END IF;

    -- Retrieve the next node down in the customer hierarchy branch.  If it is a
    -- new branch then the Customer Hierarchy Level should be 1.  If not, then
    -- flag the entire branch as pc_valdtn_status_excluded.
    IF v_last_cmpny_code <> rv_customer.cmpny_code OR
      v_last_div_code <> rv_customer.div_code OR
      (v_last_cust_hier_level + 1) <> rv_customer.cust_hier_level THEN

      -- If the Customer Hierarchy level is not equal to '1' then flag the record
      -- as pc_valdtn_status_excluded.
      IF rv_customer.cust_hier_level <> 1 THEN
        v_valdtn_status := pc_valdtn_status_excluded;

        write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Customer Hierarchy node is not Level 1 as expected.');
      END IF;

    -- This is the next level down in the Customer Hierarchy branch, therefore check whether the
    -- prior level was excluded. If so, then flag this Customer record as pc_valdtn_status_excluded.
    ELSIF v_last_valdtn_status = pc_valdtn_status_excluded THEN
      v_valdtn_status := pc_valdtn_status_excluded;

      write_log(pc_data_type_cust,'N/A',pv_log_level + 3,'Prior Hierarchy branch node excluded, so flag next Cust node as EXCLUDED.');
    END IF;

    -- Store the values of the last processed record.
    v_last_cmpny_code := rv_customer.cmpny_code;
    v_last_div_code := rv_customer.div_code;
    v_last_parent_cust_code := rv_customer.cust_code;
    v_last_cust_hier_level := TO_NUMBER(rv_customer.cust_hier_level);
    v_last_valdtn_status := v_valdtn_status;

    -- Update the valdtn_status in the PDS_CUST_HIER_LOAD table.
    UPDATE pds_cust_hier_load
    SET valdtn_status = v_valdtn_status,
      procg_status = pc_procg_status_processed
    WHERE CURRENT OF csr_customer;

  END LOOP;
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'End of loop.');

  -- Close csr_customer cursor.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Close csr_customer cursor.');
  CLOSE csr_customer;

  -- Commit any changes.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Commit any changes.');
  COMMIT;

  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'validate_pds_customer_atlas - END.');

EXCEPTION

  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_PRC.VALIDATE_PDS_CUSTOMER_ATLAS:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,
        'Division Code',i_div_code);
    write_log(pc_data_type_cust,'N/A',pv_log_level + 2,pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,rv_customer.cmpny_code);
    END IF;

  WHEN e_processing_error THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CUST_01_PRC.VALIDATE_PDS_CUSTOMER_ATLAS:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,
        'Division Code',i_div_code);
    write_log(pc_data_type_cust,'N/A',pv_log_level + 2,pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,rv_customer.cmpny_code);
    END IF;

  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_PRC.VALIDATE_PDS_CUSTOMER_ATLAS:',
        'Unexpected Exception - validate_pds_customer_atlas aborted.') ||
        utils.create_params_str('Company Code',i_cmpny_code,
        'Division Code',i_div_code) ||
        utils.create_sql_err_msg();
    write_log(pc_data_type_cust,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_prc,'MFANZ Promax Customer Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,rv_customer.cmpny_code);
    END IF;

    -- If csr_customer cursor is still open, close it.
    IF (csr_customer%ISOPEN) THEN
      write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Close csr_customer cursor in exception.');
      CLOSE csr_customer;
    END IF;

END validate_pds_customer_atlas;


PROCEDURE transfer_customer IS

BEGIN

  -- Start transfer_customer procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'transfer_customer - START.');

  transfer_customer_postbox (pc_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood
  transfer_customer_postbox (pc_cmpny_code_australia,pc_div_code_food); -- Australia Food
  transfer_customer_postbox (pc_cmpny_code_australia,pc_div_code_pet); -- Australia Pet
  transfer_customer_postbox (pc_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snack
  transfer_customer_postbox (pc_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food
  transfer_customer_postbox (pc_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Petcare

  -- End transfer_customer procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'transfer_customer - END.');

END transfer_customer;


PROCEDURE transfer_customer_postbox (
  i_cmpny_code IN VARCHAR2,
  i_div_code IN VARCHAR2) IS

  -- COLLECTION TYPE DECLARATIONS
  TYPE tbl_customer IS VARRAY (6) OF VARCHAR2(8);
  rcd_customer tbl_customer := tbl_customer(' ',' ',' ',' ',' ',' ');

  -- VARIABLE DECLARATIONS
  v_pmx_cmpny_code        pds_div.pmx_cmpny_code%TYPE;
  v_pmx_div_code          pds_div.pmx_div_code%TYPE;
  v_last_hdr_seq          pds_cust_hier_load.cust_hier_hdr_seq%TYPE := 0;
  v_last_cmpny_code       pds_cust_hier_load.cmpny_code%TYPE := ' ';
  v_last_div_code         pds_cust_hier_load.div_code%TYPE := ' ';
  v_last_cust_hier_level  pds_cust_hier.cust_hier_level%TYPE := 99; -- Note: 99 is used to initialize the variable as it does not exist as a hierarchy level.
  v_last_parent_cust_code pbchain.kacc%TYPE;
  v_cust_hier_level       pds_cust_hier.cust_hier_level%TYPE;
  v_parent_cust_code      pbchain.kacc%TYPE;
  v_regn_code             regname.regcode%TYPE;
  v_maincode              pbchain.maincode%TYPE;
  v_majorref              pbchain.majorref%TYPE;
  v_minorref              pbchain.minorref%TYPE;
  v_custlevel             pbchain.custlevel%TYPE;
  v_glcode                pbchain.glcode%TYPE;
  v_midref                pbchain.midref%TYPE;
  v_parentkacc            pbchain.parentkacc%TYPE;
  v_parentperc            pbchain.parentperc%TYPE;
  v_kaccxref              pbchain.kaccxref%TYPE;
  v_new_customer_flag     BOOLEAN;
  v_load_into_promax      BOOLEAN;
  v_count                 INTEGER;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Retrieve validated Customers to be transferred to Postbox Schema.
  -- Must be processed by hierarchy sequence and level as each sequence
  -- defines a unique branch of the hierarchy tree
  CURSOR csr_customer IS
    SELECT
      cust_hier_hdr_seq,
      cmpny_code,
      div_code,
      distbn_chnl_code,
      regn_code,
      cust_hier_level,
      cust_code,
      pos_format_grpg_code,
      cust_name,
      eff_from_date,
      cust_hier_hdr_date,
      price_list_code,
      levels_to_load
    FROM
      pds_cust_hier_load
    WHERE
      cmpny_code = i_cmpny_code
      AND div_code = i_div_code
      AND valdtn_status = pc_valdtn_status_valid
      AND procg_status = pc_procg_status_processed
    ORDER BY
      cust_hier_hdr_seq,
      cust_hier_level
    FOR UPDATE NOWAIT;
  rv_customer csr_customer%ROWTYPE;

  -- Check whether Customer already exists in Promax.
  CURSOR csr_exist_customer IS
    SELECT
      parent_cust_code,
      cust_hier_level,
      distbn_chnl_code,
      eff_from_date
    FROM
      pds_cust_hier
    WHERE
      cmpny_code = v_pmx_cmpny_code
      AND div_code = v_pmx_div_code
      AND cust_code = TO_CHAR(rv_customer.cust_code);
  rv_exist_customer csr_exist_customer%ROWTYPE;

  -- Check whether existing Customers name has changed.
  CURSOR csr_check_customer_name IS
    SELECT DISTINCT
      chain
    FROM
      chain
    WHERE
      cocode = v_pmx_cmpny_code
      AND divcode = v_pmx_div_code
      AND kacc = TO_CHAR(rv_customer.cust_code);
  rv_check_customer_name csr_check_customer_name%ROWTYPE;

  -- RESULT CHECKING PROCEDURE
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

  -- Start transfer_customer_postbox procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'transfer_customer_postbox - START.');

  -- Get Promax Company and Division Code.
  pv_status := pds_lookup.lookup_pmx_cmpny_div_code(i_cmpny_code,i_div_code,v_pmx_cmpny_code,v_pmx_div_code, pv_log_level,pv_result_msg);
  check_result_status;

  -- Read through each of the Customer records to be transferred.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Open csr_customer cursor. [i_cmpny_code='||i_cmpny_code||',i_div_code='||i_div_code||',v_pmx_cmpny_code='||v_pmx_cmpny_code||',v_pmx_div_code='||v_pmx_div_code||']');
  OPEN csr_customer;
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Looping through the csr_customer cursor.');
  LOOP
    FETCH csr_customer INTO rv_customer;
    EXIT WHEN csr_customer%NOTFOUND;

    -- Convert to number format.
    v_cust_hier_level := TO_NUMBER(rv_customer.cust_hier_level);

    -- Check whether Customer is to be loaded based on the hierarchy level.
    v_load_into_promax := (INSTR(rv_customer.levels_to_load, TO_CHAR(v_cust_hier_level)) > 0);

    -- Check whether we have already inserted this Customer into the PBCHAIN table,
    -- which only occurs for new Customers.  If so, then skip the record.
    -- The row must still be processed so that the customer array is populated with
    -- the correct hierarchy information
    IF (v_load_into_promax) THEN
      SELECT COUNT(*) INTO v_count
      FROM pbchain
      WHERE cocode = v_pmx_cmpny_code
        AND divcode = v_pmx_div_code
        AND kacc = TO_CHAR(rv_customer.cust_code);
      IF v_count > 0 THEN
         v_load_into_promax := false;
      END IF;
    END IF;

    -- Retrieve the next node from the Customer Hierarchy Branch.
    IF v_last_hdr_seq = rv_customer.cust_hier_hdr_seq THEN

      IF (v_last_cust_hier_level + 1) != v_cust_hier_level THEN
        -- Node is not next logical level, therefore send an e-mail and pds_log message to inform of
        -- possible data error.
        pv_result_msg := 'Customer Hierarchy node is not next level ' ||(v_last_cust_hier_level + 1) || ' as expected. '||
          'Customer Hierarchy Sequence [' || rv_customer.cust_hier_hdr_seq || '],'||
          'Company Code [' || rv_customer.cmpny_code || '],'||
          'Division Code [' || rv_customer.div_code || '],'||
          'Customer Hierarchy Level [' || rv_customer.cust_hier_level || '],'||
          'Customer Code [' || rv_customer.cust_code || '].';
        write_log(pc_data_type_cust,'N/A',pv_log_level + 3,pv_result_msg);
        pds_utils.send_email_to_group(pc_job_type_cust_01_prc,'MFANZ Promax Customer Process 01',pv_result_msg);
      END IF;

      v_parent_cust_code := v_last_parent_cust_code;
      rcd_customer(v_cust_hier_level) := rv_customer.cust_code;

    ELSE

      v_parent_cust_code := ' ';

      -- Reset the array as we have started a new Customer Hierarchy Branch.
      FOR i IN 1..6 LOOP
        rcd_customer(i) := ' ';
      END LOOP;

      -- Check that the node is level 1 (it should be as this has been validated),
      -- otherwise raise an error.
      IF v_cust_hier_level = pc_cust_level_1 THEN
        rcd_customer(v_cust_hier_level) := rv_customer.cust_code;
      ELSE
        -- Node is not Level 1, therefore send an e-mail and pds_log message to inform of
        -- possible data error.
        pv_result_msg := 'Customer Hierarchy node is not Level 1 as expected. '||
          'Customer Hierarchy Sequence [' || rv_customer.cust_hier_hdr_seq || '],'||
          'Company Code [' || rv_customer.cmpny_code || '],'||
          'Division Code [' || rv_customer.div_code || '],'||
          'Customer Hierarchy Level [' || rv_customer.cust_hier_level || '],'||
          'Customer Code [' || rv_customer.cust_code || '].';
        write_log(pc_data_type_cust,'N/A',pv_log_level + 3,pv_result_msg);
        pds_utils.send_email_to_group(pc_job_type_cust_01_prc,'MFANZ Promax Customer Process 01',pv_result_msg);
      END IF;

    END IF;

    -- Only do this section if customer is to be loaded into Promax
    -- Relocated by RB 26/2/10 so that error messages (and work) are not generated for customers 
    --  not being inserted.
    IF v_load_into_promax = TRUE THEN
      
      -- Now assign the Region Code to the Level 1 to 5 Customers.  Level 6 Customers
      -- will have Region assigned.
      IF v_cust_hier_level <> pc_cust_level_6 AND TRIM(rv_customer.regn_code) IS NULL THEN
        IF rv_customer.cmpny_code = pc_cmpny_code_australia THEN
          v_regn_code := pc_regn_code_australia;
        ELSIF rv_customer.cmpny_code = pc_cmpny_code_new_zealand THEN
          v_regn_code := pc_regn_code_new_zealand;
        END IF;
      ELSE
        v_regn_code := TRIM(rv_customer.regn_code);
      END IF;
  
      -- Now retrieve the Region Code from the PROMAX.REGNAME table.
      SELECT regcode INTO v_regn_code
      FROM regname
      WHERE cocode = v_pmx_cmpny_code
        AND divcode = v_pmx_div_code
        AND region = v_regn_code;
  
      -- Reset the New Customer Flag variable.
      v_new_customer_flag := FALSE;
  
      /*
      Check whether Customer already exists in the PDS_CUST_HIER table. If the
      Customer does exist then check whether the Effective Date is greater, if so
      then an update is required. If the Customer does not exist then insert the
      Customer into the PDS_CUST_HIER table.
      */
      OPEN csr_exist_customer;
      FETCH csr_exist_customer INTO rv_exist_customer;
      IF csr_exist_customer%FOUND THEN
  
        -- Check whether the received Customer is more recent than that in the
        -- PDS_CUST_HIER table.  If so, then update the Customer.
        IF rv_customer.eff_from_date > rv_exist_customer.eff_from_date THEN
  
          /*
          Log (and potentially send an alert) when the Parent Customer has changed.
          A re-calculation of sales history is required if the Customer has changed
          Hierarchy branches.  The re-calculation functionality has not been
          implemented within this procedure.  This functionality will need to be
          investigated as a future activity.
          */
          IF rv_exist_customer.parent_cust_code != v_parent_cust_code THEN
            pv_result_msg := 'Parent Customer has changed. Parent Customer used to be [' ||
              rv_exist_customer.parent_cust_code || '] and is now [ ' || v_parent_cust_code || '].'||
              'Customer Hierarchy details are as follows: ' ||
              'Customer Hierarchy Sequence [' || rv_customer.cust_hier_hdr_seq || '],'||
              'Company Code [' || rv_customer.cmpny_code || '],'||
              'Division Code [' || rv_customer.div_code || '],'||
              'Customer Hierarchy Level [' || rv_customer.cust_hier_level || '],'||
              'Customer Code [' || rv_customer.cust_code || '].';
            write_log(pc_data_type_cust,'N/A',pv_log_level + 3,pv_result_msg);
  
            --Added by Anna Every 30th May, 2006, Ticket 581874 to email if this is a problem.
            pds_utils.add_validation_reason(pc_valdtn_type_cust,
                  'ACTION: Parent has changed WAS [' ||rv_exist_customer.parent_cust_code || 
                    '] now [ '|| v_parent_cust_code ||'].''CoCode [' || rv_customer.cmpny_code || '],'||'DivCode [' || rv_customer.div_code || ']',
                  pc_valdtn_severity_critical,
                  rv_customer.cust_hier_hdr_seq,
                  rv_customer.cmpny_code,
                  rv_customer.div_code,
                  rv_customer.cust_hier_level,
                  rv_customer.cust_code,
                  NULL,
                  pv_log_level + 3);
  
          END IF;
  
          /*
          Log (and potentially send an alert) when the Distribution Channel has changed.
          A re-calculation of sales history is required if the Customer has changed
          Hierarchy branches.  The re-calculation functionality has not been
          implemented within this procedure.  This functionality will need to be
          investigated as a future activity.
          */
          IF rv_exist_customer.distbn_chnl_code != rv_customer.distbn_chnl_code THEN
            pv_result_msg := 'Distribution Channel has changed. Distribution Channel used to be [' ||
              rv_exist_customer.distbn_chnl_code || '] and is now [ ' || rv_customer.distbn_chnl_code || '].' ||
              'Customer Hierarchy details are as follows: ' ||
              'Customer Hierarchy Sequence [' || rv_customer.cust_hier_hdr_seq || '],'||
              'Company Code [' || rv_customer.cmpny_code || '],'||
              'Division Code [' || rv_customer.div_code || '],'||
              'Customer Hierarchy Level [' || rv_customer.cust_hier_level || '],'||
              'Customer Code [' || rv_customer.cust_code || '].';
            write_log(pc_data_type_cust,'N/A',pv_log_level + 3,pv_result_msg);
          END IF;
  
          /*
          Log (and potentially send an alert) when the Customer Hierarchy Level
          has changed. A re-calculation of sales history is required if the Customer
          has changed Hierarchy branches.  The re-calculation functionality has not
          been implemented within this procedure.  This functionality will
          need to be investigated as a future activity.
          */
          IF rv_exist_customer.cust_hier_level != v_cust_hier_level THEN
            pv_result_msg := 'Customer Hierarchy Level has changed. Customer Hierarchy Level used to be [' ||
              rv_exist_customer.cust_hier_level || '] and is now [ ' || v_cust_hier_level || '].'||
              'Customer Hierarchy details are as follows: ' ||
              'Customer Hierarchy Sequence [' || rv_customer.cust_hier_hdr_seq || '],'||
              'Company Code [' || rv_customer.cmpny_code || '],'||
              'Division Code [' || rv_customer.div_code || '],'||
              'Customer Hierarchy Level [' || rv_customer.cust_hier_level || '],'||
              'Customer Code [' || rv_customer.cust_code || '].';
            write_log(pc_data_type_cust,'N/A',pv_log_level + 3,pv_result_msg);
          END IF;
  
          -- Update the existing Customer in the PDS_CUST_HIER table.
          UPDATE pds_cust_hier
          SET parent_cust_code = v_parent_cust_code,
            cust_hier_level = v_cust_hier_level,
            distbn_chnl_code = rv_customer.distbn_chnl_code,
            eff_from_date = rv_customer.eff_from_date
          WHERE  cmpny_code = v_pmx_cmpny_code
            AND div_code = v_pmx_div_code
            AND cust_code = TO_CHAR(rv_customer.cust_code);
  
          -- Customer is not more recent than that in the PDS_CUST_HIER table.
          -- Therefore do not load into Promax.
        ELSE
          v_load_into_promax := FALSE;
  
        END IF;
  
      -- Customer does not exist in the PDS_CUST_HIER table, therefore insert the Customer.
      ELSE
  
        -- Insert into PDS_CUST_HIER table.
        INSERT INTO pds_cust_hier
          (
          cmpny_code,
          div_code,
          distbn_chnl_code,
          cust_code,
          parent_cust_code,
          cust_hier_level,
          eff_from_date
          )
        VALUES
          (
          v_pmx_cmpny_code,
          v_pmx_div_code,
          rv_customer.distbn_chnl_code,
          rv_customer.cust_code,
          v_parent_cust_code,
          v_cust_hier_level,
          rv_customer.eff_from_date
          );
  
        -- Set the New Customer Flag variable to pc_boolean_true as this Customer will need
        -- to be inserted into the PBCHAIN table.
        v_new_customer_flag := TRUE;
  
      END IF;
  
      CLOSE csr_exist_customer;

    -- Statement below relocated by RB 26/2/10 so that error messages (and work) are not generated 
    --  for customers not being inserted.
    --IF v_load_into_promax = TRUE THEN
    
      -- Assign all variables for the new Customer to be inserted into the PBCHAIN table.
      -- If Division is Snack, then do this specific mapping
      IF i_cmpny_code = pc_cmpny_code_australia AND i_div_code = pc_div_code_snack THEN
        IF v_cust_hier_level = pc_cust_level_1 THEN
          v_majorref := rv_customer.cust_code;
          v_midref := ' ';
          v_minorref := rv_customer.cust_code;
          v_maincode := ' ';
          v_custlevel := pc_cust_maj_ref;
          v_glcode := pc_cust_gl_level_1;
          v_parentkacc := ' ';
          v_parentperc := 0;
          v_kaccxref := ' ';
        ELSIF v_cust_hier_level = pc_cust_level_2 THEN
          v_majorref := ' ';
          v_midref := rv_customer.cust_code;
          v_minorref := rv_customer.cust_code;
          v_maincode := ' ';
          v_custlevel := pc_cust_mid_ref;
          v_glcode := pc_cust_gl_level_2;
          v_parentkacc := ' ';
          v_parentperc := 0;
          v_kaccxref := ' ';
        ELSIF v_cust_hier_level = pc_cust_level_3 THEN
          v_majorref := rcd_customer(1);
          v_midref :=  rcd_customer(2);
          v_minorref := rv_customer.cust_code;
          v_maincode := ' ';
          v_custlevel := pc_cust_funding;
          v_glcode := 'Level' || TO_CHAR(v_cust_hier_level,'9');
          v_parentkacc := ' ';
          v_parentperc := 0;
          v_kaccxref := ' ';
        ELSIF v_cust_hier_level = pc_cust_level_4 THEN
          v_majorref := rcd_customer(1);
          v_midref := rcd_customer(2);
          v_minorref := rcd_customer(3);
          v_maincode := ' ';
          v_custlevel := pc_cust_invc;
          v_glcode := 'Level' || TO_CHAR(v_cust_hier_level,'9');
          v_parentkacc := ' ';
          v_parentperc := 0;
          v_kaccxref := ' ';
        ELSIF v_cust_hier_level = pc_cust_level_5 THEN
          v_majorref := rcd_customer(1);
          v_midref := rcd_customer(2);
          v_minorref := rcd_customer(3);
          v_maincode := ' ';
          v_custlevel := pc_cust_invc;
          v_glcode := 'Level' || TO_CHAR(v_cust_hier_level,'9');
          v_parentkacc := ' ';
          v_parentperc := 0;
          v_kaccxref := ' ';
        ELSIF v_cust_hier_level = pc_cust_level_6 THEN
          v_majorref := rcd_customer(1);
          v_midref := rcd_customer(2);
          v_minorref := rcd_customer(3);
          v_maincode := ' ';
          v_custlevel := pc_cust_invc;
          v_glcode := pc_cust_gl_level_6;
          v_parentkacc := ' ';
          v_parentperc := 0;
          v_kaccxref := ' ';
        ELSE
          v_minorref := rcd_customer(3);
          v_maincode := ' ';
          v_majorref := rcd_customer(1);
          v_custlevel := pc_cust_cust_family;
          v_glcode := 'Level' || TO_CHAR(v_cust_hier_level,'9');
          v_midref := rcd_customer(2);
          v_parentkacc := rcd_customer(1);
          v_parentperc := 99;
          v_kaccxref := rv_customer.cust_code;
        END IF;
    ELSE
      -- For Non-Snack Divisiona, do this general mapping
      IF v_cust_hier_level = pc_cust_level_1 THEN
        v_minorref := rv_customer.cust_code;
        v_maincode := ' ';
        v_majorref := ' ';
        v_custlevel := pc_cust_mid_ref;
        v_glcode := pc_cust_gl_level_1;
        v_midref := rv_customer.cust_code;
        v_parentkacc := ' ';
        v_parentperc := 0;
        v_kaccxref := rv_customer.cust_code;
      ELSIF v_cust_hier_level = pc_cust_level_2 THEN
        v_minorref := rv_customer.cust_code;
        v_maincode := ' ';
        v_majorref := rv_customer.cust_code;
        v_custlevel := pc_cust_maj_ref;
        v_glcode := pc_cust_gl_level_2;
        v_midref := ' ';
        v_parentkacc := ' ';
        v_parentperc := 0;
        v_kaccxref := ' ';
      ELSIF v_cust_hier_level = pc_cust_level_6 THEN
        v_minorref := ' ';
        v_maincode := ' ';
        v_majorref := rcd_customer(2);
        v_custlevel := pc_cust_invc;
        v_glcode := pc_cust_gl_level_6;
        v_midref := ' ';
        v_parentkacc := ' ';
        v_parentperc := 0;
        v_kaccxref := rv_customer.cust_code;
      ELSE
        v_minorref := ' ';
        v_maincode := ' ';
        v_majorref := ' ';
        v_custlevel := pc_cust_cust_family;
        v_glcode := 'Level' || TO_CHAR(v_cust_hier_level,'9');
        v_midref := ' ';
        v_parentkacc := rcd_customer(1);
        v_parentperc := 99;
        v_kaccxref := rv_customer.cust_code;
      END IF;
    END IF;

      -- Check whether the existing Customer in the CHAIN table has had a name change.
      -- If so, then update the existing name of the Customer using the new name.
      -- The CHAIN table is being updated directly due to PROMAX Postbox issues.
      IF v_new_customer_flag = FALSE THEN

        OPEN csr_check_customer_name;
        FETCH csr_check_customer_name INTO rv_check_customer_name;
        IF csr_check_customer_name%FOUND THEN

          -- Update CHAIN directly rather than rely on the Postbox to correctly
          -- update just the name field.
          IF rv_check_customer_name.chain != SUBSTR(rv_customer.cust_name,1,30) THEN

            -- Update CHAIN table as the Customers name has changed.
            UPDATE chain
            SET chain = SUBSTR(rv_customer.cust_name,1,30)
            WHERE cocode = v_pmx_cmpny_code
              AND divcode = v_pmx_div_code
              AND kacc = TO_CHAR(rv_customer.cust_code);
          END IF;

          -- Close csr_check_customer_name cursor.
          CLOSE csr_check_customer_name;

        -- If the Customer was not found in the CHAIN table then raise a warning message.
        ELSE

          pv_result_msg := 'The following Customer that exists in the PDS_CUST_HIER table did not exist in the CHAIN '||
            'table as expected.  Promax Company Code [ '|| v_pmx_cmpny_code || '],' ||
            'Promax Division Code [ '|| v_pmx_div_code || '], '||
            'and Customer Code [' ||  rv_customer.cust_code ||' ].';
          write_log(pc_data_type_cust,'N/A',pv_log_level + 3,pv_result_msg);

          -- Close csr_check_customer_name cursor.
          CLOSE csr_check_customer_name;

        END IF;

      END IF;

      /*
      Check that we haven't already inserted a row for the Customer, so that
      duplicate records are not inserted.

      Note: v_count is the number of rows in PBCHAIN table for the
      Company / Division / Customer. If it's zero we want to insert, otherwise
      do nothing as it already exists.
      */
      IF v_count = 0 AND v_new_customer_flag = TRUE THEN

        -- Insert the new Customer into the PBCHAIN table.
        INSERT INTO PBCHAIN
          (
          cocode,
          divcode,
          kacc,
          regcode,
          channel,
          minorref,
          chain,
          maincode,
          majorref,
          promoted,
          notactive,
          buyextax,
          termsdisc,
          specdiscnt,
          buyperiod,
          endperiod,
          custlevel,
          parentkacc,
          parentperc,
          pricelist,
          scanacc,
          kaccxref,
          dirsale,
          glcode,
          pbdate,
          pbtime,
          midref,
          mgrcode
          )
        VALUES
          (
          v_pmx_cmpny_code,
          v_pmx_div_code,
          rv_customer.cust_code,
          v_regn_code,
          rv_customer.distbn_chnl_code,
          v_minorref,
          SUBSTR(rv_customer.cust_name,1,30),
          v_maincode,
          v_majorref,
          pc_cust_not_prom, -- Promoted.
          pc_cust_not_active, -- NotActive.
          pc_cust_not_extax, -- BuyExTax.
          0, -- TermsDisc.
          0, -- SpecDiscnt.
          0, -- BuyPeriod.
          0, -- EndPeriod.
          v_custlevel,
          v_parentkacc,
          v_parentperc,
          rv_customer.price_list_code,
          ' ', -- ScanAcc.
          v_kaccxref, -- KaccXref.
          ' ', -- DirSale.
          v_glcode, -- GLCode.
          TRUNC(SYSDATE,'DD'), -- Pbdate.
          TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')), -- Pbtime.
          v_midref, -- Midref.
          ' ' -- Mgrcode.
          );

        -- Insert new Customers into the PDS_CUST_NEW table.
        INSERT INTO pds_cust_new
          (
          cmpny_code,
          div_code,
          cust_code,
          cust_name
          )
        VALUES
          (
          v_pmx_cmpny_code,
          v_pmx_div_code,
          rv_customer.cust_code,
          SUBSTR(rv_customer.cust_name, 1,30)
          );

      END IF;

    END IF;

    v_last_hdr_seq := rv_customer.cust_hier_hdr_seq;
    v_last_parent_cust_code := rv_customer.cust_code;
    v_last_cmpny_code := rv_customer.cmpny_code;
    v_last_div_code := rv_customer.div_code;
    v_last_cust_hier_level := v_cust_hier_level;

    -- Update pds_cust_hier_load to set procg_status = COMPLETED.
    UPDATE pds_cust_hier_load
      SET procg_status = pc_procg_status_completed
    WHERE CURRENT OF csr_customer;

  END LOOP;
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'End of loop.');

  -- Close csr_customer cursor.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Close csr_customer cursor.');
  CLOSE csr_customer;

  -- Commit changes to tables.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 3, 'Commit changes to tables.');
  COMMIT;

  write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'transfer_customer_postbox - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.

  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_PRC.TRANSFER_CUSTOMER_POSTBOX:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,
        'Division Code',i_div_code);
    write_log(pc_data_type_cust,'N/A',pv_log_level + 2,pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,rv_customer.cmpny_code);
    END IF;

  WHEN e_processing_error THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CUST_01_PRC.TRANSFER_CUSTOMER_POSTBOX:',
        pv_processing_msg) ||
      utils.create_params_str('Company Code',i_cmpny_code,
        'Division Code',i_div_code);
    write_log(pc_data_type_cust,'N/A',pv_log_level + 2,pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,rv_customer.cmpny_code);
    END IF;

  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_PRC.TRANSFER_CUSTOMER_POSTBOX:',
        'Unexpected Exception - transfer_customer_postbox aborted.') ||
        utils.create_params_str('Company Code',i_cmpny_code,
        'Division Code',i_div_code) ||
        utils.create_sql_err_msg();
    write_log(pc_data_type_cust,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_prc,'MFANZ Promax Customer Process 01',
      pv_result_msg);
    IF pc_debug = 'FALSE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,rv_customer.cmpny_code);
    END IF;
    IF (csr_customer%ISOPEN) THEN
      write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'Close csr_customer cursor in exception.');
      CLOSE csr_customer;
    END IF;

END transfer_customer_postbox;


PROCEDURE initiate_postbox_customer IS

  -- VARIABLE DECLARATIONS
  v_count NUMBER; -- Generic counter

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;

BEGIN

  -- Start initiate_postbox_customer procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'initiate_postbox_customer - START.');

  -- Do not initiate the Customer Postbox job if any CUST_LOAD job control
  -- records exist with a status other than COMPLETED.
  SELECT count(*) INTO v_count
  FROM
    pds_pmx_job_cntl
  WHERE
    pmx_job_cnfgn_id in (pc_pstbx_cust_load)
  AND job_status <> pc_job_status_completed;

  IF v_count > 0 THEN
    -- There is a Customer Postbox job running.
    pv_processing_msg := 'ERROR: Customer Postbox job cannot be started. ' ||
      'CUST_LOAD Job Control records exist status <> COMPLETED. ' ||
      'This indicates that there is an in progress job and/or failed job(s).';
    RAISE e_processing_failure;
  ELSE
    -- There are not any customer postbox jobs running
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Initiating customer_postbox job by creating CUST_LOAD job control record');
    pds_utils.create_promax_job_control(pc_pstbx_cust_load);
  END IF;

  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'initiate_postbox_customer - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.

  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_PRC.INITIATE_POSTBOX_CUSTOMER:',pv_processing_msg) ||
      utils.create_params_str();
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_prc,'MFANZ Promax Customer Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,'N/A');
    END IF;

  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_PRC.INITIATE_POSTBOX_CUSTOMER:',
        'Unexpected Exception - initiate_postbox_customer aborted.') ||
        utils.create_params_str() ||
        utils.create_sql_err_msg();
    write_log(pc_data_type_cust,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_prc,'MFANZ Promax Customer Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_cust_01_prc,'N/A');
    END IF;

END initiate_postbox_customer;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

  -- VARIABLE DECLARATIONS
  v_result_msg constants.message_string;

BEGIN

  -- Write the entry into the pds_log table.
  pds_utils.log(pc_job_type_cust_01_prc,
                i_data_type,
                i_sort_field,
                i_log_level,
                i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    v_result_msg :=
      utils.create_error_msg('PDS_CUST_01_PRC.WRITE_LOG:',
        'Unable to write to the PDS_LOG table.') ||
      utils.create_sql_err_msg();
    pds_utils.log(pc_job_type_cust_01_prc,pc_data_type_not_applicable,'N/A',i_log_level,
      v_result_msg);
END write_log;

END pds_cust_01_prc; 

/
