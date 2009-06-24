CREATE OR REPLACE PACKAGE         pds_ap_claims_01_prc IS

/*********************************************************************************
  NAME:      run_pds_ap_claims_01_prc
  PURPOSE:   This procedure performs three key tasks:

             1. Extracts Postbox AP Claims data and loads into the PDS schema.
             2. Validates the AP Claims data in the PDS schema.
             3. Initiates interface for all Companies and Business Segments.

             The interface is triggered by a pipe message from PDS_CONTROLLER,
             the daemon which manages the Oracle side of the Promax Job Control
             tables (as this interface has three prerequisite Postbox jobs).

             NOTE: v_debug is a debugging constant, defined at the package level.
             If FALSE (ie. we're running in production) then send Alerts, else sends
             emails.
        .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   03/06/2009 Anna Every           Changed call to lics_outbound_loader
  2.0   20/06/2009 Steve Gregan         Added create log.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_ap_claims_01_prc;

/*********************************************************************************
  NAME:      extract_postbox_ap_claims
  PURPOSE:   NOTE: This moves a lot of data around in a single commit cycle. Its either do this,
             or move to breaking up data via Company & Division. At this point, simply ensure that
             there is enough archive log space, and do it using bulk inserts/deletes.

             This procedure extracts Postbox AP Claims data and loads it into the PDS schema.
             The data loaded into the PDS schema is loaded with a validation status of UNCHECKED,
             and a processing status of LOADED.

             As each AP Claim record is loaded into the PDS tables, it is updated in the Postbox tables.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE extract_postbox_ap_claims;

/*********************************************************************************
  NAME:      validate_pds_ap_claims
  PURPOSE:   This procedure validates the AP Claims data.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   25/09/2006 Craig Ford           add ClaimRef to error detail lines.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_ap_claims;

/*********************************************************************************
  NAME:      interface_ap_claims
  PURPOSE:   This procedure creates the AP Claims interfaces, by Company and Division,
             for valid AP Claims data in the PDS AP Claims tables.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE interface_ap_claims;

/*********************************************************************************
  NAME:      interface_ap_claims_atlas
  PURPOSE:   This procedure creates AP Claims interface file that is uploaded into Atlas.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         47
  2    IN     VARCHAR2 Division Code                        01

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE interface_ap_claims_atlas (
  i_pmx_cmpny_code IN VARCHAR2,
  i_pmx_div_code IN VARCHAR2);

/*******************************************************************************
  NAME:      interface_apclaim_file
  PURPOSE:   This procedure is called for each record in the cursor csr_ap_claims and
             is used to calculate the components of the file.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/09/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         47
  2    IN     VARCHAR2 Division Code                        01
  3    IN     NUMBER   Customer Code                        ?
  4    IN     NUMBER   IC Code                              ?
  5    IN     VARCHAR2 Text Field                           ?

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE interface_apclaim_file (
  i_pmx_cmpny_code IN pds_ap_claims.cmpny_code%TYPE,
  i_pmx_div_code IN pds_ap_claims.div_code%TYPE,
  i_cust_code IN pds_ap_claims.cust_code%TYPE,
  i_ic_code IN pds_ap_claims.internal_claim_num%TYPE,
  i_text_field IN pds_ap_claims.text_field%TYPE);

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

END pds_ap_claims_01_prc;
/


CREATE OR REPLACE PACKAGE BODY         pds_ap_claims_01_prc IS

  -- PACKAGE VARIABLE DECLARATIONS.
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS.
  pc_job_type_ap_claims_01_prc  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims_01_prc','JOB_TYPE');
  pc_data_type_ap_claims        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims','DATA_TYPE');
  pc_debug                      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_minor          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_valdtn_severity_critical   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('critical','VALDTN_SEVERITY');
  pc_valdtn_status_unchecked    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unchecked','VALDTN_STATUS');
  pc_valdtn_status_valid        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('valid','VALDTN_STATUS');
  pc_valdtn_status_invalid      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('invalid','VALDTN_STATUS');
  pc_valdtn_type_ap_claims      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims','VALDTN_TYPE');
  pc_procg_status_loaded        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('loaded','PROCG_STATUS');
  pc_procg_status_processed     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('processed','PROCG_STATUS');
  pc_procg_status_completed     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','PROCG_STATUS');
  pc_pmx_cmpny_code_australia   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia','PMX_CMPNY_CODE');
  pc_pmx_cmpny_code_new_zealand CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('new_zealand','PMX_CMPNY_CODE');
  pc_div_code_snack             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('snack','DIV_CODE');
  pc_div_code_food              CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('food','DIV_CODE');
  pc_div_code_pet               CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pet','DIV_CODE');
  pc_ap_claims_pet_plant        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pet_plant','AP_CLAIMS');
  pc_ap_claims_snack_plant      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('snack_plant','AP_CLAIMS');
  pc_ap_claims_affirmative_chq  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('affirmative_chq','AP_CLAIMS');
  pc_ap_claims_export           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('export','AP_CLAIMS');
  pc_ap_claims_datatype_claim   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('datatype_claim','AP_CLAIMS');
  pc_ap_claims_pay_method_claim CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pay_method_claim','AP_CLAIMS');
  pc_interface_ap_claims_01     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims_01','INTERFACE');
  pc_pstbx_ap_claims_extract    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ap_claims_extract','PSTBX');
  pc_job_status_completed       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');

PROCEDURE run_pds_ap_claims_01_prc IS

BEGIN

  -- Start run_pds_ap_claims_01_prc procedure.
  pds_utils.create_log;
  write_log(pc_data_type_ap_claims, 'N/A', pv_log_level, 'run_pds_ap_claims_01_prc - START.');

  -- The 3 key tasks: extract, validate, interface.
  extract_postbox_ap_claims();
  validate_pds_ap_claims ();
  interface_ap_claims ();

  -- End run_pds_ap_claims_01_prc procedure.
  write_log(pc_data_type_ap_claims, 'N/A', pv_log_level, 'run_pds_ap_claims_01_prc - END.');
  pds_utils.end_log;

EXCEPTION
  -- Send warning message via e-mail and PDS_LOG.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.RUN_PDS_APCLAIMS_01_PRC:',
      'Unexpected Exception - run_pds_ap_claims_01_prc aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;
    pds_utils.end_log;

END run_pds_ap_claims_01_prc;


PROCEDURE extract_postbox_ap_claims IS

  -- VARIABLE DECLARARTIONS.
  v_count            NUMBER; -- Generic counter.
  v_intfc_batch_code pds_ap_claims.intfc_batch_code%TYPE; --Batch ID.
  v_ap_claims_seq    NUMBER := 0;

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- CURSOR DECLARATIONS.
  CURSOR csr_ap_claims IS
    SELECT
      t01.cocode,
      t01.divcode,
      t01.kacc,
      t01.pmnum,
      t01.icnumber,
      t01.prodcode,
      t01.promyear,
      t01.fdcustcode,
      t01.paymethod,
      t01.datatype,
      t01.aamount,
      t01.acasedeal,
      t01.linenum,
      t01.acccode,
      t01.paybychq,
      t01.direction,
      t01.additive,
      t01.text25,
      t01.taxamount,
      t01.pbdoctype,
      t01.pbdate,
      t01.pbtime,
      t01.periodno,
      decode(t02.dateenterd,null,t01.trandate,t02.dateenterd) as trandate,
      t01.claimref,
      t01.genvendor,
      t01.chequenum,
      t01.procesdate,
      t02.dateenterd
    FROM
      exaccruals t01,
      (select t01.*
         from (select cocode,
                      divcode,
                      claimref,
                      kacc,
                      dateenterd,
                      rank() over (partition by cocode, divcode, claimref, kacc order by dateenterd desc) as rnkseq
                 from claimdoc) t01
        where t01.rnkseq = 1) t02
    WHERE
      t01.cocode = t02.cocode(+)
      AND t01.divcode = t02.divcode(+)
      AND t01.claimref = t02.claimref(+)
      AND t01.kacc = t02.kacc(+)
      AND t01.paybychq = pc_ap_claims_affirmative_chq
      AND t01.datatype = pc_ap_claims_datatype_claim
      AND t01.paymethod = pc_ap_claims_pay_method_claim
      AND t01.direction = pc_ap_claims_export;
  rv_ap_claims csr_ap_claims%ROWTYPE;

BEGIN

  -- Start extract_postbox_ap_claims procedure.
  write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'extract_postbox_ap_claims - START.');

  -- Check whether there are any AP Claims interface jobs in progress or failed.
  write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Count the Approval records to process.');
  SELECT count(*) INTO v_count
  FROM
    pds_pmx_job_cntl
  WHERE
    pmx_job_cnfgn_id in (pc_pstbx_ap_claims_extract)
    AND job_status <> pc_job_status_completed;

  -- If an AP Claims Approval interface job is in progress or failed, stop and email someone.
  IF v_count > 0 THEN -- There is an AP Claims Approval interface running.
    pv_processing_msg := 'ERROR: extract_postbox_ap_claims aborted.' ||
      'AP_CLAIMS* Job Control records exist status not equal to COMPLETED.' ||
      'This indicates that there is an in progress interface and/or failed interface(s).';
    RAISE e_processing_failure;

  ELSE

    -- Transporting AP Claims from Postbox exaccruals to PDS PDS_AP_CLAIMS table.
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Transporting AP Claims from Postbox exaccruals to PDS PDS_AP_CLAIMS table.');

    -- Update PDS_AP_CLAIMS table to set existing INVALID records to UNCHECKED.
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Update PDS_AP_CLAIMS table to set existing INVALID records to UNCHECKED.');
    UPDATE PDS_AP_CLAIMS
      SET valdtn_status = pc_valdtn_status_unchecked
    WHERE valdtn_status = pc_valdtn_status_invalid;

    -- Commit update to PDS_AP_CLAIMS table.
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Commit update to PDS_AP_CLAIMS table.');
    COMMIT;

    -- Select next sequence number for Interface Batch Code from AP_CLAIMS_BATCH_SEQ.
    SELECT pds_ap_claims_batch_seq.NEXTVAL INTO v_intfc_batch_code
      FROM dual; -- Get next number in sequence for batch.
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Interface Batch Code is:'||v_intfc_batch_code||'.');

    -- Read through each of the records in the csr_ap_claims cursor.
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Open csr_ap_claims cursor.');
    OPEN csr_ap_claims;
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Looping through the csr_ap_claims cursor.');
    LOOP
      FETCH csr_ap_claims INTO rv_ap_claims;
      EXIT WHEN csr_ap_claims%NOTFOUND;

      v_ap_claims_seq := v_ap_claims_seq + 1;

      -- Insert into PDS_AP_CLAIMS table.
      INSERT INTO pds_ap_claims
        (
        intfc_batch_code,
        cmpny_code,
        div_code,
        ap_claims_seq,
        cust_code,
        prom_num,
        internal_claim_num,
        matl_code,
        accrl_amt,
        cust_vndr_code,
        text_field,
        tax_amt,
        doc_type_code,
        pb_date_stamp,
        period_num,
        tran_date,
        procg_status,
        valdtn_status
        )
      VALUES
        (
        v_intfc_batch_code,
        rv_ap_claims.cocode,
        rv_ap_claims.divcode,
        v_ap_claims_seq,
        rv_ap_claims.kacc,
        rv_ap_claims.pmnum,
        rv_ap_claims.icnumber,
        rv_ap_claims.prodcode,
        rv_ap_claims.aamount,
        rv_ap_claims.acccode,
        rv_ap_claims.text25,
        rv_ap_claims.taxamount,
        rv_ap_claims.pbdoctype,
        rv_ap_claims.pbdate,
        rv_ap_claims.periodno,
        rv_ap_claims.trandate,
        pc_procg_status_loaded,
        pc_valdtn_status_unchecked
        );

    END LOOP;
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'End of loop.');

    -- Close csr_ap_claims cursor.
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1, 'Close csr_ap_claims cursor.');
    CLOSE csr_ap_claims;

    -- Delete the AP Claims from Postbox EXACCRUALS table.
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'Delete postbox EXACCRUALS records.');
    DELETE exaccruals
    WHERE paybychq = pc_ap_claims_affirmative_chq
      AND datatype = pc_ap_claims_datatype_claim
      AND paymethod = pc_ap_claims_pay_method_claim
      AND direction = pc_ap_claims_export;

    -- Commit changes to database.
    write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'Commit changes to database.');
    COMMIT;

  END IF;

  -- End extract_postbox_ap_claims procedure.
  write_log(pc_data_type_ap_claims, 'N/A', pv_log_level + 1,'extract_postbox_ap_claims -= END.');

EXCEPTION
  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.EXTRACT_POSTBOX_APCLAIMS:',
        pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',rv_ap_claims.cocode,'Promax Division Code',rv_ap_claims.divcode);
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

  -- Send warning message via E-mail and PDS_LOG.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.EXTRACT_POSTBOX_APCLAIMS:',
      'Unexpected Exception - extract_postbox_ap_claims aborted.') ||
      utils.create_params_str('Promax Company Code',rv_ap_claims.cocode,'Promax Division Code',rv_ap_claims.divcode) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

END extract_postbox_ap_claims;


PROCEDURE validate_pds_ap_claims IS

  -- VARIABLE DECLARATIONS.
  v_valdtn_status pds_ap_claims.valdtn_status%TYPE;
  v_cmpny_code    pds_div.cmpny_code%TYPE;
  v_div_code      pds_div.div_code%TYPE;
  v_matl_code     pds_ap_claims.matl_code%TYPE;
  v_cust_code     pds_ap_claims.cust_code%TYPE;
  v_dist_chan     VARCHAR2(12);
  v_plant         VARCHAR2(12);
  v_cost_centre   VARCHAR2(50);
  v_cost_account  VARCHAR2(50);
  v_profit_centre VARCHAR2(50);
  v_taxable_code  VARCHAR2(2);
  v_taxfree_code  VARCHAR2(2);
  v_currency      VARCHAR2(50);
  v_count         NUMBER := 0;

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error EXCEPTION;

  -- Declare AP Claims cursor.
  CURSOR csr_ap_claims IS
    SELECT
      t1.intfc_batch_code,
      t1.cmpny_code AS pmx_cmpny_code,
      t1.div_code AS pmx_div_code,
      t1.ap_claims_seq,
      t1.cust_code,
      t1.prom_num,
      t1.cust_vndr_code,
      t1.matl_code,
      t1.internal_claim_num,
      t1.accrl_amt,
      t1.text_field,
      t1.tax_amt,
      t1.doc_type_code,
      t1.pb_date_stamp,
      t1.period_num,
      t1.tran_date,
      t1.procg_status,
      t1.valdtn_status,
      t1.ap_claims_lupdp,
      t1.ap_claims_lupdt,
      t2.cmpny_code,
      t2.div_code,
      t2.atlas_flag
    FROM
      pds_ap_claims t1,
      pds_div t2
    WHERE
      t1.cmpny_code = t2.pmx_cmpny_code (+)
      AND t1.div_code = t2.pmx_div_code (+)
      AND t1.valdtn_status = pc_valdtn_status_unchecked
    ORDER BY
      t1.cmpny_code,
      t1.div_code;
  rv_ap_claims csr_ap_claims%ROWTYPE;

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

  -- Start validate_pds_ap_claims procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'validate_pds_ap_claims - START.');

  -- Clear validation table of records it it exists.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'Clear validation table.');
  pds_utils.clear_validation_reason(pc_valdtn_type_ap_claims,NULL,NULL,NULL,NULL,NULL,NULL,pv_log_level + 1);

  -- Read through each of the AP Claims records to be processed.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'Open csr_ap_claims cursor.');
  OPEN csr_ap_claims;

  -- Looping through csr_ap_claims cursor.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'Looping through csr_ap_claims cursor.');
  LOOP
    FETCH csr_ap_claims INTO rv_ap_claims;
    EXIT WHEN csr_ap_claims%NOTFOUND;

    v_valdtn_status := pc_valdtn_status_valid;

    -- Validate Company Code.
    IF rv_ap_claims.cmpny_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Company Code does not exist for legacy Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');
      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant company code for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' || rv_ap_claims.pmx_div_code,
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    IF rv_ap_claims.div_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Division Code does not exist for legacy Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');
      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant Division code for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' || rv_ap_claims.pmx_div_code,
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    -- Only perform the following validations for Atlas Company/Divisions. Non-Atlas
    -- Company/Division records do not require these columns populated in the Extract
    -- file.
    IF rv_ap_claims.atlas_flag = 'Y' THEN

      pv_status := pds_common.format_cust_code(rv_ap_claims.cust_code,v_cust_code,pv_log_level + 2,pv_result_msg);
      check_result_status;

      pv_status := pds_common.format_matl_code(rv_ap_claims.matl_code,v_matl_code, pv_log_level + 2,pv_result_msg);
      check_result_status;

      -- Promax Distribution Channel.
      -- Some Promax extracts require the Distribution Channel to be included in the data
      -- destined for SAP. This isn't held on the Promax DB so this procedure is called
      -- to supply it for the extract. The rules are:
      -- 1. if a Distribution Channel of 10 exists for both Material and Customer then return 10.
      -- 2. if not above then return any value that exists for both the Material and Customer.
      pv_status := pds_lookup.lookup_distn_chnl_code (v_matl_code, v_cust_code, v_dist_chan, pv_log_level + 2, pv_result_msg);
      IF v_dist_chan IS NULL THEN
        v_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'ClaimRef ['|| TRIM(rv_ap_claims.text_field) || ']: Invalid Distribution Channel for Material [' || TRIM(v_matl_code) ||'] and Customer ['|| LTRIM(v_cust_code, '0') || '].');
        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
          'ClaimRef ['|| TRIM(rv_ap_claims.text_field) || ']: Invalid Distribution Channel for Matl['|| LTRIM(v_matl_code,'0') ||'], Cust['|| LTRIM(v_cust_code, '0') || '].',
          pc_valdtn_severity_critical,
          rv_ap_claims.intfc_batch_code,
          rv_ap_claims.pmx_cmpny_code,
          rv_ap_claims.pmx_div_code,
          rv_ap_claims.ap_claims_seq,
          NULL,
          NULL,
          pv_log_level + 2);

      END IF;

      -- Convert Materials from ZREP to TDU.
      pv_status := pds_lookup.lookup_matl_dtrmntn(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, rv_ap_claims.prom_num, rv_ap_claims.cust_code, rv_ap_claims.matl_code, v_matl_code, pv_log_level + 2, pv_result_msg);
      IF v_matl_code IS NULL THEN
        v_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'ClaimRef ['|| TRIM(rv_ap_claims.text_field) || ']: Invalid Material Dtrmntn for Prom/Cust/Matl ['||TRIM(rv_ap_claims.prom_num)||'/'||rv_ap_claims.cust_code ||'/'|| rv_ap_claims.matl_code ||'].');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
         'ClaimRef ['|| TRIM(rv_ap_claims.text_field) || ']: No Matl Dtrmntn for Prom/Cust/Matl ['||TRIM(rv_ap_claims.prom_num)||'/'||rv_ap_claims.cust_code ||'/'|| rv_ap_claims.matl_code ||'].',
          pc_valdtn_severity_critical,
          rv_ap_claims.intfc_batch_code,
          rv_ap_claims.pmx_cmpny_code,
          rv_ap_claims.pmx_div_code,
          rv_ap_claims.ap_claims_seq,
          NULL,
          NULL,
          pv_log_level + 2);

      END IF;

      -- Find Plant Code.
      pv_status := pds_lookup.lookup_matl_plant_code(rv_ap_claims.pmx_cmpny_code, v_matl_code, v_plant, pv_log_level + 2, pv_result_msg);

      IF v_plant IS NULL THEN
        v_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'ClaimRef ['|| TRIM(rv_ap_claims.text_field) || ']: Non-existant Plant Code for TDU Material Code ['|| LTRIM(v_matl_code,'0') ||'].');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
          'ClaimRef ['|| TRIM(rv_ap_claims.text_field) || ']: Non-existant Plant Code for TDU Material ['|| LTRIM(v_matl_code,'0') ||'].',
          pc_valdtn_severity_critical,
          rv_ap_claims.intfc_batch_code,
          rv_ap_claims.pmx_cmpny_code,
          rv_ap_claims.pmx_div_code,
          rv_ap_claims.ap_claims_seq,
          NULL,
          NULL,
          pv_log_level + 2);

      END IF;
    END IF;

    -- Find variables for Cost Centre.
    pv_status := pds_lookup.lookup_cntl_code(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, 'COST_CENTRE_CODE', v_cost_centre, pv_log_level + 2, pv_result_msg);
    IF v_cost_centre IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Non-existant COST CENTRE for Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant COST CENTRE for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' || rv_ap_claims.pmx_div_code,
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    --  Find values of Cost Account.
    pv_status := pds_lookup.lookup_cntl_code(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, 'COST_ACCOUNT_CODE', v_cost_account, pv_log_level + 2, pv_result_msg);
    IF v_cost_account IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Non-existant COST ACCOUNT for Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant COST ACCOUNT for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' || rv_ap_claims.pmx_div_code,
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    -- Find values of Profit Centre.
    pv_status := pds_lookup.lookup_cntl_code(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, 'PROFIT_CENTRE_CODE', v_profit_centre, pv_log_level + 2, pv_result_msg);
    IF v_profit_centre IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Non-existant PROFIT CENTRE for Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant PROFIT CENTRE for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' || rv_ap_claims.pmx_div_code,
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    -- Find values of Taxable Code.
    pv_status := pds_lookup.lookup_cntl_code(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, 'TAX_CODE', v_taxable_code, pv_log_level + 2, pv_result_msg);
    IF v_taxable_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Non-existant TAXABLE CODE for Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant TAXABLE CODE for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' ||  rv_ap_claims.pmx_div_code,
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    -- Find values of Tax-free Code.
    pv_status := pds_lookup.lookup_cntl_code(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, 'NOTAX_CODE', v_taxfree_code, pv_log_level + 2, pv_result_msg);
    IF v_taxfree_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Non-existant NOTAX_CODE for Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant NOTAX_CODE for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' || rv_ap_claims.pmx_div_code ||'.',
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    -- Find values of Currency.
    pv_status := pds_lookup.lookup_cntl_code(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, 'CURRENCY_CODE', v_currency, pv_log_level + 2, pv_result_msg);
    IF v_currency IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Non-existant CURRENCY for Company ' || rv_ap_claims.pmx_cmpny_code || ' with a Division ' || rv_ap_claims.pmx_div_code||'.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ap_claims,
        'Non-existant CURRENCY for Company ' || rv_ap_claims.pmx_cmpny_code || ' and Division ' || rv_ap_claims.pmx_div_code,
        pc_valdtn_severity_critical,
        rv_ap_claims.intfc_batch_code,
        rv_ap_claims.pmx_cmpny_code,
        rv_ap_claims.pmx_div_code,
        rv_ap_claims.ap_claims_seq,
        NULL,
        NULL,
        pv_log_level + 2);

    END IF;

    -- Flag record as PROCESSED and as either INVALID or VALID.
    UPDATE pds_ap_claims
    SET procg_status  = pc_procg_status_processed,
        valdtn_status = v_valdtn_status
    WHERE
      intfc_batch_code = rv_ap_claims.intfc_batch_code
      AND cmpny_code = rv_ap_claims.pmx_cmpny_code
      AND div_code = rv_ap_claims.pmx_div_code
      AND ap_claims_seq = rv_ap_claims.ap_claims_seq;

  END LOOP;
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'End of csr_ap_claims loop for validation.');

  -- Close csr_ap_claims cursor.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'Close csr_ap_claims cursor.');
  CLOSE csr_ap_claims;

  -- Commit changes to PDS_AP_CLAIMS table.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'Commit changes to PDS_AP_CLAIMS table.');
  COMMIT;

  -- Trigger the pds_ap_claims_01_rep procedure.
  write_log(pc_data_type_ap_claims, 'N/A', pv_log_level, 'Trigger the PDS_AP_CLAIMS_01_REP procedure.');
  lics_trigger_loader.execute('MFANZ Promax AP Claims 01 Report',
                              'pds_app.pds_ap_claims_01_rep.run_pds_ap_claims_01_rep',
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_AP_CLAIMS_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_AP_CLAIMS_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_AP_CLAIMS_01_REP'));

  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'validate_pds_ap_claims - END.');

EXCEPTION

 WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.VALIDATE_PDS_APCLAIMS:',
      pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',rv_ap_claims.pmx_cmpny_code,'Promax Division Code',rv_ap_claims.pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

  WHEN e_processing_error THEN
     pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.VALIDATE_PDS_APCLAIMS:',
      pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',rv_ap_claims.pmx_cmpny_code,'Promax Division Code',rv_ap_claims.pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

  -- Send warning message via E-mail and PDS_LOG.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.VALIDATE_PDS_APCLAIMS:',
      'Unexpected Exception - validate_pds_ap_claims aborted.') ||
      utils.create_params_str('Promax Company Code',rv_ap_claims.pmx_cmpny_code,'Promax Division Code',rv_ap_claims.pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

END validate_pds_ap_claims;


PROCEDURE interface_ap_claims IS

BEGIN

  -- Start interface_ap_claims procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'interface_ap_claims - START.');

  -- Generate outgoing AP Claims interface for all Company/Divisions.
  interface_ap_claims_atlas (pc_pmx_cmpny_code_australia,pc_div_code_snack);  -- Australia Snackfood.
  interface_ap_claims_atlas (pc_pmx_cmpny_code_australia,pc_div_code_food);  -- Australia Food.
  interface_ap_claims_atlas (pc_pmx_cmpny_code_australia,pc_div_code_pet); -- Australia Petcare.
  interface_ap_claims_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snack.
  interface_ap_claims_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
  interface_ap_claims_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Petcare.

  -- End interface_ap_claims procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 1,'interface_ap_claims - END.');

END interface_ap_claims;


PROCEDURE interface_ap_claims_atlas (
  i_pmx_cmpny_code VARCHAR2,
  i_pmx_div_code VARCHAR2) IS

  -- VARIABLE DECLARATIONS.
  v_error      BOOLEAN;

  -- Active AP Claims Query.
  CURSOR csr_ap_claims IS
    SELECT DISTINCT
      cmpny_code AS pmx_cmpny_code,
      div_code AS pmx_div_code,
      cust_code,
      internal_claim_num,
      text_field
    FROM
      pds_ap_claims
    WHERE
      cmpny_code  = i_pmx_cmpny_code
      AND div_code = i_pmx_div_code
      AND valdtn_status = pc_valdtn_status_valid
      AND procg_status = pc_procg_status_processed
    ORDER BY
      cmpny_code,
      div_code,
      cust_code,
      internal_claim_num,
      text_field;
    rv_ap_claims csr_ap_claims%ROWTYPE;

  BEGIN

  -- Start interface_ap_claims_atlas procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'interface_ap_claims_atlas - START.');

  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Start AP Claims File Creation Process for Promax Company ' || i_pmx_cmpny_code || ' Promax Division ' || i_pmx_div_code||'.');

  -- Reading through csr_ap_claims cursor.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Open csr_ap_claims cursor.');
  OPEN csr_ap_claims;
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Looping through csr_ap_claims cursor.');
  LOOP
    FETCH csr_ap_claims INTO rv_ap_claims;
    EXIT WHEN csr_ap_claims%NOTFOUND;

    -- Call procedure that will create file.
    interface_apclaim_file(rv_ap_claims.pmx_cmpny_code, rv_ap_claims.pmx_div_code, rv_ap_claims.cust_code, rv_ap_claims.internal_claim_num, rv_ap_claims.text_field);

  END LOOP;
  -- End of loop;
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'End of loop.');

  -- Close csr_ap_claims cursor.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'Close csr_ap_claims cursor.');
  CLOSE csr_ap_claims;

  -- End interface_ap_claims_atlas procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,'interface_ap_claims_atlas - END.');

EXCEPTION

 -- Send warning message via E-mail and PDS_LOG.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.INTERFACE_APCLAIMS_ATLAS:',
      'Unexpected Exception - interface_ap_claims_atlas aborted.') ||
      utils.create_params_str('Promax Company Code',rv_ap_claims.pmx_cmpny_code,'Promax Division Code',rv_ap_claims.pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

END interface_ap_claims_atlas;


PROCEDURE interface_apclaim_file (
  i_pmx_cmpny_code IN pds_ap_claims.cmpny_code%TYPE,
  i_pmx_div_code IN pds_ap_claims.div_code%TYPE,
  i_cust_code IN pds_ap_claims.cust_code%TYPE,
  i_ic_code IN pds_ap_claims.internal_claim_num%TYPE,
  i_text_field IN pds_ap_claims.text_field%TYPE) IS

  -- COLLECTION TYPE DECLARATIONS.
  TYPE tbl_gledger IS TABLE OF VARCHAR2(220)
  INDEX BY BINARY_INTEGER;

  -- COLLECTION DECLARATIONS.
  rcd_gledger tbl_gledger;

  -- VARIABLE DECLARATIONS.
  v_error            BOOLEAN;
  v_line_item        VARCHAR2(2000);
  v_agg_current      BINARY_INTEGER := 1;
  v_agg_maxagg       BINARY_INTEGER := 0;
  v_agg_counter      BINARY_INTEGER := 0;
  v_agg_addagg       BOOLEAN;
  v_item_count       BINARY_INTEGER := 0;
  v_tax_base         NUMBER := 0;
  v_taxfree_base     NUMBER := 0;
  v_tax              NUMBER := 0;
  v_tax_code         VARCHAR2(2);
  v_acct_amt         NUMBER;
  v_tran_date        DATE;
  v_text_field       VARCHAR2(25);
  v_prom_num         VARCHAR2(8);
  v_sales_org        VARCHAR2(4);
  v_ic_code          NUMBER(15,4);
  v_aggregation      BOOLEAN := FALSE;
  v_cust_code        VARCHAR2(10);
  v_dist_chan        VARCHAR2(12);
  v_matl_code        VARCHAR2(18);
  v_plant            VARCHAR2(12);
  v_cost_centre      VARCHAR2(50);
  v_cost_account     VARCHAR2(50);
  v_profit_centre    VARCHAR2(50);
  v_taxable_code     VARCHAR2(2);
  v_taxfree_code     VARCHAR2(2);
  v_tax_found        BOOLEAN := FALSE;
  v_taxfree_found    BOOLEAN := FALSE;
  v_currency         VARCHAR2(50);
  v_pb_date_stamp    DATE;
  v_instance         NUMBER(15,0); -- Local definitions required for ICS interface invocation.
  v_total_accrl_amt  pds_ap_claims.accrl_amt%TYPE := 0;
  v_total_tax_amt    pds_ap_claims.tax_amt%TYPE := 0;
  v_header_line_item VARCHAR2(500);
  v_vendor_line_item VARCHAR2(500);
  v_tax_line_item    VARCHAR2(500);

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error EXCEPTION;

  -- Cursor used to retrieve all the necessary columns from the APClaims table.
  CURSOR csr_claim_det  IS
    SELECT
      t1.intfc_batch_code,
      t1.cmpny_code AS pmx_cmpny_code,
      t1.div_code AS pmx_div_code,
      t1.ap_claims_seq,
      t1.cust_code,
      t1.prom_num,
      t1.cust_vndr_code,
      t1.matl_code,
      t1.internal_claim_num,
      t1.accrl_amt,
      t1.text_field,
      t1.tax_amt,
      t1.doc_type_code,
      t1.pb_date_stamp,
      t1.period_num,
      t1.tran_date,
      t1.procg_status,
      t1.valdtn_status,
      t1.ap_claims_lupdp,
      t1.ap_claims_lupdt,
      t2.cmpny_code,
      t2.div_code,
      t2.atlas_flag
    FROM
      pds_ap_claims t1,
      pds_div t2
    WHERE
      t1.cmpny_code = i_pmx_cmpny_code
      AND t1.div_code = i_pmx_div_code
      AND t1.cust_code = i_cust_code
      AND t1.internal_claim_num  = i_ic_code
      AND t1.text_field = i_text_field
      AND t1.valdtn_status = pc_valdtn_status_valid
      AND t1.procg_status = pc_procg_status_processed
      AND t2.pmx_cmpny_code = t1.cmpny_code
      AND t2.pmx_div_code = t1.div_code;
  rv_claim_det csr_claim_det  %ROWTYPE;

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

  -- Start interface_apclaim_file procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'interface_apclaim_file - START.');

  -- Reading through csr_claim_det cursor to process AP CLAIM records.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level+ 4,'Open csr_claim_det cursor.');
  OPEN csr_claim_det;
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Looping through csr_apclaim_det cursor.');
  LOOP
    FETCH csr_claim_det INTO rv_claim_det;
    EXIT WHEN csr_claim_det%NOTFOUND;

    -- Re-initialise fields.
    v_total_accrl_amt  := v_total_accrl_amt + rv_claim_det.accrl_amt;
    v_total_tax_amt    := v_total_tax_amt + rv_claim_det.tax_amt;

    -- Initialise SAP columns using Atlas Flag.
    -- Atlas Company/Division transactions must use valid values in the SAP columns
    IF rv_claim_det.atlas_flag = 'Y' THEN
      -- Retrieve all necessary variables
      pv_status := pds_common.format_cust_code(rv_claim_det.cust_code, v_cust_code, pv_log_level + 2,pv_result_msg);
      check_result_status;

      pv_status := pds_common.format_matl_code(rv_claim_det.matl_code, v_matl_code, pv_log_level + 2,pv_result_msg);
      check_result_status;

      pv_status := pds_lookup.lookup_distn_chnl_code (v_matl_code, v_cust_code, v_dist_chan, pv_log_level + 5, pv_result_msg);
      check_result_status;
      v_dist_chan := RPAD(NVL(v_dist_chan,' '),2);

      pv_status := pds_lookup.lookup_matl_dtrmntn(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, rv_claim_det.prom_num, rv_claim_det.cust_code, rv_claim_det.matl_code, v_matl_code, pv_log_level + 5, pv_result_msg);
      check_result_status;


      pv_status := pds_lookup.lookup_matl_plant_code(rv_claim_det.pmx_cmpny_code, v_matl_code, v_plant, pv_log_level + 5, pv_result_msg);
      check_result_status;

      v_sales_org := RPAD(rv_claim_det.cmpny_code,4); -- Sales Org.

    END IF;

    -- Retrieve all necessary variables.
    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'COST_CENTRE_CODE', v_cost_centre, pv_log_level + 5, pv_result_msg);
    check_result_status;

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'COST_ACCOUNT_CODE', v_cost_account, pv_log_level + 5, pv_result_msg);
    check_result_status;

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'PROFIT_CENTRE_CODE', v_profit_centre, pv_log_level + 5, pv_result_msg);
    check_result_status;

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'TAX_CODE', v_taxable_code, pv_log_level + 5, pv_result_msg);
    check_result_status;

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'NOTAX_CODE', v_taxfree_code, pv_log_level + 5, pv_result_msg);
    check_result_status;

    pv_status := pds_lookup.lookup_cntl_code(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, 'CURRENCY_CODE', v_currency, pv_log_level + 5, pv_result_msg);
    check_result_status;

    -- Total Tax Payments.
    pv_status := pds_exist.exist_taxable(rv_claim_det.pmx_cmpny_code, rv_claim_det.pmx_div_code, rv_claim_det.doc_type_code,pv_log_level + 5, pv_result_msg);
    IF pv_status = constants.success THEN
      v_tax_base := v_tax_base + rv_claim_det.accrl_amt;
      v_tax := v_tax + rv_claim_det.tax_amt;
      v_tax_code := v_taxable_code;
      v_tax_found := TRUE;
    ELSE
      v_taxfree_base := v_taxfree_base + rv_claim_det.accrl_amt;
      v_tax_code := v_taxfree_code;
      v_taxfree_found := TRUE;
    END IF;

    v_item_count := v_item_count + 1;

    -- Create 'G'/General Ledger List of lines.
    rcd_gledger(v_item_count) :=
      'G' || -- G Line Indicator.
      LPAD(v_cost_account,10,'0') || -- The Cost Account Code.
      LPAD(TO_CHAR(rv_claim_det.accrl_amt, '9999999999999999999.99'),23,'0') || -- The amount.
      -- The Item Text.
      RPAD(LTRIM(rv_claim_det.text_field) || ' ' || RTRIM(rv_claim_det.cust_vndr_code),50) ||
      RPAD(LTRIM(rv_claim_det.internal_claim_num),18) || -- Alloc Num aka Assignment.
      -- Other line details.
      RPAD(v_tax_code,2) || -- Tax code for the current line.
      RPAD(v_cost_centre,10) || -- Cost centre.
      RPAD(' ',12) || -- Order Id always blank.
      RPAD(' ',24) || -- WBS element.
      RPAD(' ',13) || -- Quantity.
      RPAD(' ',3) || -- Base Unit of Measure.
      RPAD(NVL(v_matl_code,' '),18) || -- Product Code.
      RPAD(v_plant,4); -- Plant Code.

    -- Add the account code details.
    IF rv_claim_det.atlas_flag = 'N' THEN
      rcd_gledger(v_item_count) := rcd_gledger(v_item_count) || RPAD(' ',10); -- Customer.
    ELSE
      rcd_gledger(v_item_count) := rcd_gledger(v_item_count) || v_cust_code; -- Customer.
    END IF;

    -- Add Profit Centre Information.
    rcd_gledger(v_item_count)  := rcd_gledger(v_item_count) || RPAD(v_profit_centre,10);

    -- Now update the Sales Order and Distribution Channel.
    rcd_gledger(v_item_count) := rcd_gledger(v_item_count) ||
      RPAD(rv_claim_det.cmpny_code,4) || -- Sales Org.
      RPAD(v_dist_chan,2); -- Distribution Channel.

--    Code removed for PET ATLAS based on assumption that Aggregation only occurs for non-ATLAS segments.
--    IF v_plant = pc_ap_claims_pet_plant THEN
--      v_aggregation := TRUE;
--    ELSIF v_plant = pc_ap_claims_snack_plant THEN
--   20/07/2007 Code removed for Snack ATLAS based on assumption that Aggregation only occurs for non-ATLAS segments.
--    IF v_plant = pc_ap_claims_snack_plant THEN
--      v_aggregation := TRUE;
--    END IF;

    -- These values are the same for each record, therefore they can be set
    -- at this point for later reference.
    v_tran_date     := rv_claim_det.tran_date;
    v_text_field    := rv_claim_det.text_field;
    v_prom_num      := rv_claim_det.prom_num;
    v_ic_code       := rv_claim_det.internal_claim_num;
    v_pb_date_stamp := rv_claim_det.pb_date_stamp;

  END LOOP;
  -- End of loop.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'End of loop for csr_apclaim_det.');

  -- Create the 'H'/Header Line of the IDoc.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'IDoc Header (H) Line formation.');
  v_header_line_item :=
    'HIDOC PX' ||
    TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') ||
    LPAD(TO_CHAR(v_item_count),4,'0') ||
    'RFBUBATCHSCHE   ' ||
    RPAD('Promax '||LTRIM(rv_claim_det.cmpny_code)|| ' ' || LTRIM(rv_claim_det.div_code)||' ' ||LTRIM(v_prom_num),25)|| -- 25 char header text.
    RPAD(rv_claim_det.cmpny_code,4) || -- Company Code.
    RPAD(v_currency,5,' ') || -- Currency.
    TO_CHAR(v_tran_date,'YYYYMMDD') || -- Document Date.
    TO_CHAR(v_pb_date_stamp,'YYYYMMDD') || -- Posting Date.
    TO_CHAR(v_pb_date_stamp,'YYYYMMDD') || -- Trans Date  27/7/04 disappeared from spec
    'KN' || RPAD(v_text_field,16) || RPAD('PROMAX',10);

  -- Create the 'P'/Vendor line in the IDoc.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'IDoc Vendor (P) Line formation.');
  v_vendor_line_item :=
    'P' ||
    LPAD(NVL(LTRIM(rv_claim_det.cust_vndr_code),'0000000000'),10,'0') ||
    TO_CHAR(-(v_taxfree_base + v_tax_base + v_tax),'9999999999999999999.99') ||
    '*   ' ||
    '        ' ||
    'B' ||
    RPAD(LTRIM(v_ic_code),18) ||
    RPAD(LPAD(LTRIM(v_prom_num),8,'0') ||
    ' ' ||
    RTRIM(v_ic_code) ||
    ' ' ||
    RTRIM(v_text_field),50) ||
    '  '; -- W_tax_code.

  -- This variable is set based on the record's Plant Code.
  IF v_aggregation THEN
    /*
    While statement that performs aggregation like a 'bubble sort'. Each value is compared
    with the value next to it and if the identification values are the same, the numerical
    values are aggregated. Thus if record 1 & 2 are the same, record 2's numbers are added
    to record 1 and then record 1 is compared with record 3 and if they are the same 3 values
    are added to record 1. When two records are found that are different, the v_agg_counter
    variable has 1 added to it, to compare the next group of records. While statement used
    to ensure that each record is checked for aggregation.
    */
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Start of outer aggregation loop.');
    WHILE v_agg_current <= v_item_count LOOP
      -- Variables reset at the start of each LOOP.
      v_agg_counter := 1;
      v_agg_addagg := TRUE;

      WHILE v_agg_counter <= v_agg_maxagg LOOP
        IF SUBSTR(rcd_gledger(v_agg_counter),1,11) = SUBSTR(rcd_gledger(v_agg_current),1,11) AND
          SUBSTR(rcd_gledger(v_agg_counter),35) = SUBSTR(rcd_gledger(v_agg_current),35) THEN
          -- Same therefore the values can be aggregated.
          rcd_gledger(v_agg_counter) := SUBSTR(rcd_gledger(v_agg_counter),1,11) ||
            TO_CHAR(
            TO_NUMBER(SUBSTR(rcd_gledger(v_agg_counter),12,23)) +
            TO_NUMBER(SUBSTR(rcd_gledger(v_agg_current),12,23)),
            '9999999999999999999.99') ||
            SUBSTR(rcd_gledger(v_agg_counter),35);

            v_agg_addagg := FALSE;
          -- Breaks out of Loop statement, effective stops v_agg_counter from being added to.
          EXIT;
        END IF;

        v_agg_counter := v_agg_counter + 1;
      END LOOP;

      /*
      If an aggregation of two lines has NOT occurred then add one to the aggregation
      counter, to get the WHILE loop directly above loop through an additional record.
      The 'G' line array is also modified, so that the line that has NOT been aggregated
      is reset to the next line in the array; in effect the array is physically reduced
      in size, at this point.
      */
      IF v_agg_addagg = TRUE THEN
        v_agg_maxagg := v_agg_maxagg + 1;
        rcd_gledger(v_agg_maxagg) := rcd_gledger(v_agg_current);
      END IF;

      -- Increase the current counter (never reset).
      v_agg_current := v_agg_current + 1;

    -- End of top header loop
    END LOOP;
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'End of outer aggregation loop.');

    -- Reset the item count of the number of records in the array to the number we have
    -- now that we have aggregated the array lines to a lesser number (ie probably 1).
    v_item_count := v_agg_maxagg;

  -- End of v_aggregation IF.
  END IF;


  -- Create 'T'/Tax line for the IDOC.
  IF v_tax_found THEN
    v_tax_line_item :=
      'T' || v_tax_code ||
      TO_CHAR(v_tax,'9999999999999999999.99') ||
      TO_CHAR(v_tax_base,'9999999999999999999.99') ||
      '    ' || -- Cond_key.
      '   '; -- Acct_key.
  END IF;

  -- If Tax Free Code is found.
  IF v_taxfree_found THEN
    v_tax_line_item :=
      'T' || v_tax_code ||
      '                    000' || -- No Tax.
      TO_CHAR(v_taxfree_base,'9999999999999999999.99') ||
      '       ' ||
      ' ';
  END IF;

  -- Close csr_apclaim_det cursor.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Close csr_ap_claim_det cursor.');
  CLOSE csr_claim_det;

  -- Open the ICS interface file.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Create an instance of the ICS interface file CISATL03.');
  --v_instance := lics_outbound_loader.create_interface(pc_interface_ap_claims_01);
  v_instance  := lics_outbound_loader.create_interface(pc_interface_ap_claims_01, null, pc_interface_ap_claims_01||'.DAT');


  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Write Header (H) Line formation.');
  lics_outbound_loader.append_data(v_header_line_item);

  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Write Vendor (P) Line formation.');
  lics_outbound_loader.append_data(v_vendor_line_item);

  -- Loop through the array storing the 'G' lines and add them to the file.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Write General (G) Line formation by looping through varray.');
  FOR i IN 1..v_item_count LOOP
    lics_outbound_loader.append_data(rcd_gledger(i));
  END LOOP;
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'End of loop writing General (G) Line formation.');

  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Write Tax (T) Line formation');
  lics_outbound_loader.append_data(v_tax_line_item);

  -- Finalise the interface.
  lics_outbound_loader.finalise_interface;

  -- Update  records processed by interface_apclaim_file procedure from PDS_AP_CLAIMS table.
  UPDATE pds_ap_claims
    SET procg_status = pc_procg_status_completed
  WHERE
    cmpny_code = i_pmx_cmpny_code
    AND div_code = i_pmx_div_code
    AND cust_code = i_cust_code
    AND internal_claim_num  = i_ic_code
    AND text_field = i_text_field
    AND valdtn_status = pc_valdtn_status_valid
    AND procg_status = pc_procg_status_processed;

  -- Commit changes to the database.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'Commit changes to the database.');
  COMMIT;


  -- End inteface_apclaim_file procedure.
  write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,'interface_apclaim_file - END.');

EXCEPTION

  -- Send warning message via E-mail and PDS_LOG.
  -- Exception trap: when any exceptions occur the IS_CREATED method should be tested.
  -- if IS_CREATED return true then the exception should be added to the interface for
  -- logging purposes and the interface finalised.

  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.INTERFACE_APCLAIM_FILE:',
      pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

  WHEN e_processing_error THEN
     pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.INTERFACE_APCLAIM_FILE:',
      pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

  WHEN OTHERS THEN
    ROLLBACK;
    IF lics_outbound_loader.is_created = TRUE THEN
      lics_outbound_loader.add_exception(SUBSTR(SQLERRM,1,1024));
      lics_outbound_loader.finalise_interface;
    END IF;
    pv_result_msg :=
      utils.create_failure_msg('PDS_APCLAIMS_01_PRC.INTERFACE_APCLAIM_FILE:',
      'EXCEPTION: ROLLBACK, check LICS and finalise if required and exit.') ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ap_claims,'N/A',pv_log_level + 4,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_ap_claims_01_prc,'MFANZ Promax AP Claims Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_ap_claims_01_prc,'N/A');
    END IF;

END interface_apclaim_file;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table.
  pds_utils.log (pc_job_type_ap_claims_01_prc,
    i_data_type,
    i_sort_field,
    i_log_level,
    i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;


END pds_ap_claims_01_prc;
/
