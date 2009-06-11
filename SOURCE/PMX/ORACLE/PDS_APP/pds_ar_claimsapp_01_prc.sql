CREATE OR REPLACE PACKAGE         pds_ar_claimsapp_01_prc IS

/*********************************************************************************
  NAME:      run_pds_ar_claimsapp_01_prc
  PURPOSE:   This procedure performs three key tasks:

             1. Extracts Postbox AR Claims Approval data and loads into the PDS schema.
             2. Validates the AR Claims Approval data in the PDS schema.
             3. Initiates interfaces.

             The interface is triggered by a message from PDS_CONTROLLER,
             the daemon which manages the Oracle side of the Promax Job Control
             tables (as this interface has three prerequisite Postbox jobs).

             NOTE: v_debug is a debugging constant, defined at the package level.
             If FALSE (ie. we're running in production) then send Alerts, else sends
             emails.

        .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/10/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   03/06/2009 Anna Every           Changed call to lics_outbound_loader
  2.0   10/06/2009 Steve Gregan         Added create log.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_ar_claimsapp_01_prc;

/*********************************************************************************
  NAME:      extract_postbox_ar_claimsapp
  PURPOSE:   This procedure extracts Postbox AR Claims Approval data and loads into the PDS
             schema. The data loaded into the PDS schema is loaded with a status of validation
             status of UNCHECKED, and a processing status of LOADED.

             As each AR Claims Approval is loaded into the PDS tables, it is updated in the
             Postbox tables. The inserts (PDS) and updates (Postbox) are performed in a single
             commit cycle to ensure transaction integrity.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/10/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE extract_postbox_ar_claimsapp;

/*********************************************************************************
  NAME:      validate_pds_ar_claimsapp
  PURPOSE:   This procedure validates the AR Claims Approval data in the AR Claims Approval
             table in the PDS schema. No updates of the data itself is performed in PDS.
             This ensures the data remains "as loaded". All formatting is performed 'on the fly'
             as part of the interface itself. This routine updates the Validation Status only.
  .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/10/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   08/02/2006 Craig Ford           Update parameters for PET Atlas processing.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_ar_claimsapp;


/*********************************************************************************
  NAME:      validate_pds_ar_claimsapp_atl
  PURPOSE:   This procedure validates the Atlas AR Claims Approval data in the AR Claims Approval
             table in the PDS schema. No updates of the data itself is performed in PDS.
             This ensures the data remains "as loaded". All formatting is performed 'on the fly'
             as part of the interface itself. This routine updates the Validation Status only.
  .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/10/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   08/02/2006 Craig Ford           Include PET Legacy Company and Division in the check for
                                        original Claim from SAP. This is only required for TESTING and
                                        can be removed once live as PET will be converted to GRD Co & Div.
  1.2   17/07/2006 Craig Ford           Remove PET Legacy Company and Division as part of PET conversion to GRD.
  2.0   10/06/2009 Steve Gregan         Modified approval select logic for performance.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Promax Company Code                  47
  2    IN     VARCHAR2 Promax Division Code                 02


  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_ar_claimsapp_atl (
  i_pmx_cmpny_code IN VARCHAR2,
  i_pmx_div_code IN VARCHAR2);

/*********************************************************************************
  NAME:      interface_ar_claimsapp
  PURPOSE:   This procedure creates the AR Claims Approval interfaces, by Company and Division,
             for valid AR Claims Approval data in the PDS AR Claims Approval tables.
   .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   18/10/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   08/02/2006 Craig Ford           Update parameters for PET Atlas processing.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE interface_ar_claimsapp;

/*********************************************************************************
  NAME:      interface_ar_claimsapp_atlas
  PURPOSE:   This procedure creates the MFANZ Australia Food and NZ interface,
             for use with Atlas.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   05/09/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   08/02/2006 Craig Ford           Include PET Legacy Company and Division in the check for
                                        original Claim from SAP. This is only required for TESTING and
                                        can be removed once live as PET will be converted to GRD Co & Div.
  1.2   17/07/2006 Craig Ford           Remove PET Legacy Company and Division as part of PET conversion to GRD.
  2.0   10/06/2009 Steve Gregan         Modified approval select logic for performance.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Promax Company Code                  47
  2    IN     VARCHAR2 Promax Division Code                 02

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE interface_ar_claimsapp_atlas (
  i_pmx_cmpny_code IN VARCHAR2,
  i_pmx_div_code IN VARCHAR2);

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

END pds_ar_claimsapp_01_prc;
/


CREATE OR REPLACE PACKAGE BODY         pds_ar_claimsapp_01_prc IS

  -- PACKAGE VARIABLE DECLARATIONS.
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS.
  pc_pmx_cmpny_code_australia    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia','PMX_CMPNY_CODE');
  pc_pmx_cmpny_code_new_zealand  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('new_zealand','PMX_CMPNY_CODE');
  pc_div_code_snack              CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('snack','DIV_CODE');
  pc_div_code_food               CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('food','DIV_CODE');
  pc_div_code_pet                CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pet','DIV_CODE');
  pc_job_type_arclaimsapp_01_prc CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('arclaimsapp_01_prc','JOB_TYPE');
  pc_data_type_ar_claimsapp      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp','DATA_TYPE');
  pc_debug                       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_minor           CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_valdtn_severity_critical    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('critical','VALDTN_SEVERITY');
  pc_valdtn_severity_warning     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('warning','VALDTN_SEVERITY');
  pc_valdtn_status_unchecked     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unchecked','VALDTN_STATUS');
  pc_valdtn_status_valid         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('valid','VALDTN_STATUS');
  pc_valdtn_status_invalid       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('invalid','VALDTN_STATUS');
  pc_valdtn_type_ar_claimsapp    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp','VALDTN_TYPE');
  pc_procg_status_loaded         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('loaded','PROCG_STATUS');
  pc_procg_status_processed      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('processed','PROCG_STATUS');
  pc_procg_status_completed      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','PROCG_STATUS');
  pc_pstbx_ar_claimsapp_load     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp_load','PSTBX');
  pc_job_status_completed        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');
  pc_interface_ar_claimsapp_01   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp_01','INTERFACE');
  pc_interface_ar_claimsapp_02   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp_02','INTERFACE');
  pc_interface_ar_claimsapp_03   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ar_claimsapp_03','INTERFACE');
  pc_ar_claimsapp_claim          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('claim','AR_CLAIMSAPP');
  pc_ar_claimsapp_accrl_chng     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('accrl_chng','AR_CLAIMSAPP');
  pc_ar_claimsapp_export         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('export','AR_CLAIMSAPP');
  pc_ar_claimsapp_not_by_chq     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_by_chq','AR_CLAIMSAPP');

PROCEDURE run_pds_ar_claimsapp_01_prc IS

BEGIN

  -- Start run_pds_ar_claimsapp_01_prc procedure.
  pds_utils.create_log;
  write_log(pc_data_type_ar_claimsapp, 'N/A', pv_log_level, 'run_pds_ar_claimsapp_01_prc - START.');

  -- The 3 key tasks: extract, validate, interface.
  extract_postbox_ar_claimsapp();
  validate_pds_ar_claimsapp();
  interface_ar_claimsapp();

  -- End run_pds_ar_claimsapp_01_prc procedure.
  write_log(pc_data_type_ar_claimsapp, 'N/A', pv_log_level, 'run_pds_ar_claimsapp_01_prc - END.');

EXCEPTION
  -- Send warning message via e-mail and PDS_LOG.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.RUN_PDS_AR_CLAIMSAPP_01_PRC:',
      'Unexpected Exception - run_pds_ar_claimsapp_01_prc aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

END run_pds_ar_claimsapp_01_prc;


PROCEDURE extract_postbox_ar_claimsapp IS

  -- VARIABLE DECLARATIONS.
  v_count            NUMBER; -- Generic counter.
  v_seq              NUMBER := 0;
  v_intfc_batch_code pds_ar_claims_apprvl.intfc_batch_code%TYPE; --Batch ID.

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;

  -- CURSOR DECLARATIONS.
  -- Promax Postbox AR Claims Approval Cursor.
  CURSOR csr_approval IS
    SELECT
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
      taxamount,
      pbdoctype,
      pbdate,
      pbtime,
      periodno,
      trandate,
      claimref,
      genvendor,
      chequenum,
      procesdate
    FROM
      exaccruals
    WHERE
      datatype = pc_ar_claimsapp_claim
      AND direction = pc_ar_claimsapp_export
      AND paybychq = pc_ar_claimsapp_not_by_chq;
  rv_approval csr_approval%ROWTYPE;

BEGIN

  -- Start extract_postbox_ar_claimsapp procedure.
  write_log(pc_data_type_ar_claimsapp, 'N/A', pv_log_level + 1,'extract_postbox_ar_claimsapp - START.');

  -- Check whether there are any AR Claims Approval Load interface jobs in progress or failed.
  SELECT count(*) INTO v_count
  FROM
    pds_pmx_job_cntl
  WHERE
    pmx_job_cnfgn_id in (pc_pstbx_ar_claimsapp_load)
    AND job_status <> pc_job_status_completed;

  -- If an AR Claims Approval interface job is in progress or failed, stop and email someone.
  IF v_count > 0 THEN -- There is an AR Claims Approval interface running.
    pv_processing_msg := 'ERROR: Extract_Postbox_AR Claims Approval aborted.' ||
      'AR_CLAIMSSAPP_LOAD* Job Control records exist status not equal to COMPLETED.' ||
      'This indicates that there is an in progress interface and/or failed interface(s).';
    RAISE e_processing_failure;

  ELSE

    /*
    Copy AR Claims Approval Load from Postbox to PDS.
    NOTE: This procedure produces a large amount of data in a single commit cycle. Its either do this,
    or move it one AR Claims Approval at a time. At this point, simply ensure that there is
    enough archive log space, and do it using bulk inserts/deletes. If this
    proves to be an issue, reimplement using a AR Claims Approval by AR Claims Approval approach.
    */

    -- AR Claims Approval Sequence.
    SELECT pds_ar_claims_apprvl_batch_seq.NEXTVAL INTO v_intfc_batch_code
    FROM dual; -- Get next batch nbr.

    -- Read through each of the AR Claims Approval records to be interfaced.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'Open csr_approval cursor.');
    OPEN csr_approval;

    -- Looping through csr_approval cursor.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'Looping through csr_approval cursor.');
    LOOP
      FETCH csr_approval INTO rv_approval;
      EXIT WHEN csr_approval%NOTFOUND;

      -- Increment the ar_claims_apprvl_seq by 1.
      v_seq := v_seq + 1;

      -- Insert into PDS_AR_CLAIMS_APPRVL table.
      INSERT INTO pds_ar_claims_apprvl
        (
        intfc_batch_code,
        cmpny_code,
        div_code,
        ar_claims_apprvl_seq,
        gl_acct_code,
        cust_code,
        prom_num,
        internal_claim_num,
        matl_code,
        prom_year,
        fund_code,
        pay_mthd,
        data_type,
        claim_amt,
        case_deal,
        line_num,
        cust_vndr_code,
        pay_chq,
        directn,
        additive,
        claim_comment,
        tax_amt,
        doc_type,
        pb_date,
        pb_time,
        period_num,
        tran_date,
        claim_ref,
        gen_vndr,
        chq_num,
        proc_date,
        doc_currcy_code,
        ref_doc_num,
        tax_code,
        cost_ctr,
        order_id,
        wbs_element,
        plant_code,
        profit_ctr,
        distbn_chnl_code,
        procg_status,
        valdtn_status
        )
      VALUES
        (
        v_intfc_batch_code,
        rv_approval.cocode,
        rv_approval.divcode,
        v_seq,
        NULL, -- GL Account Code
        rv_approval.kacc,
        rv_approval.pmnum,
        rv_approval.icnumber,
        rv_approval.prodcode,
        rv_approval.promyear,
        rv_approval.fdcustcode,
        rv_approval.paymethod,
        rv_approval.datatype,
        rv_approval.aamount,
        rv_approval.acasedeal,
        rv_approval.linenum,
        rv_approval.acccode,
        rv_approval.paybychq,
        rv_approval.direction,
        rv_approval.additive,
        rv_approval.text25,
        rv_approval.taxamount,
        rv_approval.pbdoctype,
        rv_approval.pbdate,
        rv_approval.pbtime,
        rv_approval.periodno,
        rv_approval.trandate,
        rv_approval.claimref,
        rv_approval.genvendor,
        rv_approval.chequenum,
        rv_approval.procesdate,
        NULL, -- Document Currency Code,
        NULL, -- Ref Document Number.
        NULL, -- Tax Code.
        NULL, -- Cost Centre.
        NULL, -- Order Id.
        NULL, -- Wbs Element.
        NULL, -- Plant Code.
        NULL, -- Profit Centre.
        NULL, -- Distribution Channel Code.
        pc_procg_status_loaded,
        pc_valdtn_status_unchecked
        );

    END LOOP;
    -- End of loop for csr_approval cursor.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'End of loop for csr_approval cursor.');

    -- Commit changes to the PDS_AR_CLAIMS_APPRVL table.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'Commit changes to the database.');
    COMMIT;

    -- Delete the AR Claim Approvals from Postbox EXACCRUALS table.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'Delete postbox EXACCRUALS records.');
    DELETE exaccruals
    WHERE datatype = pc_ar_claimsapp_claim
    AND direction = pc_ar_claimsapp_export
    AND paybychq = pc_ar_claimsapp_not_by_chq;

    -- Commit all changes to the database.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'Commit changes to the database.');
    COMMIT;

    -- The Accrual changes ('W') are not used anywhere and must be removed from the Postbox.
    -- Delete the Accrual changes from Postbox.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'Delete Accrual Change "W" records from postbox EXACCRUALS.');
    DELETE from exaccruals
    WHERE datatype = pc_ar_claimsapp_accrl_chng
    AND direction = pc_ar_claimsapp_export
    AND paybychq = pc_ar_claimsapp_not_by_chq;

    -- Commit all changes to the database.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'Commit changes to the database.');
    COMMIT;

  END IF;

  -- End extract_postbox_ar_claimsapp procedure.
  write_log(pc_data_type_ar_claimsapp, 'N/A', pv_log_level + 1,'extract_postbox_ar_claimsapp - END.');

EXCEPTION
  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.EXTRACT_POSTBOX_AR_CLAIMSAPP:',
        pv_processing_msg) ||
      utils.create_params_str();
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

  -- Send warning message via E-mail and PDS_LOG.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.EXTRACT_POSTBOX_AR_CLAIMSAPP:',
      'Unexpected Exception - extract_postbox_ar_claimsapp aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

END extract_postbox_ar_claimsapp;


PROCEDURE validate_pds_ar_claimsapp IS

BEGIN

  -- Start validate_pds_ar_claimsapp procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'validate_pds_ar_claimsapp - START.');

  -- Perform validations on all outgoing AR Claims Approval by Company/Division for all
  -- Company and Divisions.
 validate_pds_ar_claimsapp_atl (pc_pmx_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood.
 validate_pds_ar_claimsapp_atl (pc_pmx_cmpny_code_australia,pc_div_code_pet); -- Australia Petcare.
 validate_pds_ar_claimsapp_atl (pc_pmx_cmpny_code_australia,pc_div_code_food); -- Australia Food.
 validate_pds_ar_claimsapp_atl (pc_pmx_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snack.
 validate_pds_ar_claimsapp_atl (pc_pmx_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
 validate_pds_ar_claimsapp_atl (pc_pmx_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Petcare.

  -- Trigger the pds_ar_claimsapp_01_rep procedure.
  write_log(pc_data_type_ar_claimsapp, 'N/A', pv_log_level, 'Trigger the PDS_AR_CLAIMSAPP_01_REP procedure.');
  lics_trigger_loader.execute('MFANZ Promax AR Claims Approvals 01 Report',
                              'pds_app.pds_ar_claimsapp_01_rep.run_pds_ar_claimsapp_01_rep',
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_AR_CLAIMSAPP_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_AR_CLAIMSAPP_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_AR_CLAIMSAPP_01_REP'));

  -- End validate_pds_ar_claimsapp procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'validate_pds_ar_claimsapp - END.');

END validate_pds_ar_claimsapp;

PROCEDURE validate_pds_ar_claimsapp_atl (
  i_pmx_cmpny_code IN VARCHAR2,
  i_pmx_div_code IN VARCHAR2) IS

  -- VARIABLE DECLARATIONS.
  v_valdtn_status    pds_ar_claims_apprvl.valdtn_status%TYPE; -- Record status
  v_cmpny_code       pds_ar_claims_apprvl.cmpny_code%TYPE;
  v_div_code         pds_ar_claims_apprvl.div_code%TYPE;
  v_glcode           products.glcode%TYPE;
  v_matl_code        VARCHAR2(18);
  v_fmt_matl_code    VARCHAR2(18);
  v_fmt_cust_code    VARCHAR2(10);
  v_plant_code       pmx_mfanz_matl_by_plant_view.plant%TYPE;
  v_currcy_code      pds_ar_claims_apprvl.doc_currcy_code%TYPE;
  v_profit_ctr       pds_ar_claims_apprvl.profit_ctr%TYPE;
  v_distbn_chnl_code pds_ar_claims_apprvl.distbn_chnl_code%TYPE;
  v_promax_cust_code claimdoc.kacc%TYPE;
  v_claim_cust_code  pds_ar_claims.cust_code%TYPE;
  v_acctg_doc_num    pds_ar_claims.acctg_doc_num%TYPE;
  v_fiscal_year      pds_ar_claims.fiscl_year%TYPE;
  v_line_item_num    pds_ar_claims.line_item_num%TYPE;
  v_taxable_code     pds_cntl.cntl_value%TYPE;
  v_notax_code       pds_cntl.cntl_value%TYPE;

  -- ARRAY DECLARATIONS.
  type typ_work is table of pds_ar_claims_apprvl%rowtype index by binary_integer;
  tbl_work typ_work;

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- CURSOR DECLARATIONS.
  -- Promax Postbox AR Claims Approval Cursor.
  CURSOR csr_approval IS
    SELECT
      *
    FROM
      pds_ar_claims_apprvl
    WHERE
      cmpny_code = i_pmx_cmpny_code
      AND div_code = i_pmx_div_code
      AND valdtn_status = pc_valdtn_status_unchecked;

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

  -- Start validate_pds_ar_claimsapp_atl procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'validate_pds_ar_claimsapp_atl - START.');

   -- Update PDS_AR_CLAIMS_APPRVL table to set existing INVALID records to UNCHECKED.
  write_log(pc_data_type_ar_claimsapp, 'N/A', pv_log_level + 2,'Update PDS_AR_CLAIMS_APPRVL table to set existing INVALID records to UNCHECKED.');
  UPDATE pds_ar_claims_apprvl
    SET valdtn_status = pc_valdtn_status_unchecked
  WHERE cmpny_code = i_pmx_cmpny_code
    AND div_code = i_pmx_div_code
    AND valdtn_status = pc_valdtn_status_invalid;

  -- Commit update to PDS_AR_CLAIMS_APPRVL table.
  write_log(pc_data_type_ar_claimsapp, 'N/A', pv_log_level + 2,'Commit update to PDS_AR_CLAIMS_APPRVL table.');
  COMMIT;

  -- Clear validation table of records if they exist.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Clear validation table of AR Claims Approval records if they exist.');
  pds_utils.clear_validation_reason(pc_valdtn_type_ar_claimsapp,NULL, i_pmx_cmpny_code, i_pmx_div_code,NULL, NULL,NULL, pv_log_level + 2);

  -- Lookup the Company and Division Codes.
  pv_status := pds_lookup.lookup_cmpny_div_code (i_pmx_cmpny_code, i_pmx_div_code, v_cmpny_code, v_div_code, pv_log_level + 2, pv_result_msg);
  check_result_status;

  -- Bulk collect the AR Claims Approval records to be interfaced
  -- **notes** 1. frees the cursor and rollback space
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Open and bulk collect csr_approval cursor.');
  tbl_work.delete;
  open csr_approval;
  fetch csr_approval bulk collect into tbl_work;
  close csr_approval;

  -- Looping through csr_approval cursor array.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Looping through csr_approval cursor array.');
  for idx in 1..tbl_work.count loop

    v_valdtn_status  := pc_valdtn_status_valid;

    -- Lookup the GL Account Code.
    pv_status := pds_lookup.lookup_cntl_code(tbl_work(idx).cmpny_code,tbl_work(idx).div_code,'COST_ACCOUNT_CODE', v_glcode,pv_log_level + 3, pv_result_msg);
    IF v_glcode IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'Missing COST_ACCOUNT_CODE configuration setup for Company and Division.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'Missing COST_ACCOUNT_CODE configuration setup for Company and Division.',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Lookup the Currency Code.
    pv_status := pds_lookup.lookup_cntl_code(tbl_work(idx).cmpny_code, tbl_work(idx).div_code,'CURRENCY_CODE',v_currcy_code, pv_log_level + 3, pv_result_msg);
    IF v_currcy_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'Missing CURRENCY_CODE configuration setup for Company and Division.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'Missing CURRENCY_CODE configuration setup for Company and Division.',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Check that Material Determination exists.
    pv_status := pds_lookup.lookup_matl_dtrmntn(tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).prom_num, tbl_work(idx).cust_code, tbl_work(idx).matl_code, v_matl_code, pv_log_level + 3, pv_result_msg);
    IF pv_status <> constants.success THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'Matl Dtrmntn does not exist Prom [' || TRIM(tbl_work(idx).prom_num) ||'], Matl ['|| tbl_work(idx).matl_code ||'].');
      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'Matl Dtrmntn does not exist Prom [' || TRIM(tbl_work(idx).prom_num) ||'], '||
        'Cust ['|| tbl_work(idx).cust_code ||'], and Matl ['|| tbl_work(idx).matl_code ||'].',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Lookup the Plant Code.
    pv_status := pds_lookup.lookup_matl_plant_code(tbl_work(idx).cmpny_code, v_matl_code, v_plant_code, pv_log_level + 3, pv_result_msg);
    IF v_plant_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      --19/11/2007 CF Include TDU in detail
      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'ClaimRef['|| tbl_work(idx).claim_ref || '] Matl['||tbl_work(idx).matl_code||'] TDU['||v_matl_code||'] Plant Code does not exist or is invalid');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'ClaimRef['|| tbl_work(idx).claim_ref ||'] Matl['||tbl_work(idx).matl_code||'] TDU['||v_matl_code||'] invalid Plant Code',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Lookup the Profit Centre.
    pv_status := pds_lookup.lookup_cntl_code(tbl_work(idx).cmpny_code, tbl_work(idx).div_code,'PROFIT_CENTRE_CODE',v_profit_ctr, pv_log_level + 3, pv_result_msg);
    IF v_profit_ctr IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'Missing PROFIT_CENTRE_CODE configuration setup for Company and Division.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'Missing PROFIT_CENTRE_CODE configuration setup for Company and Division.',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Lookup the Distribution Channel Code.
    pv_status := pds_common.format_matl_code(tbl_work(idx).matl_code,v_fmt_matl_code,pv_log_level + 3,pv_result_msg);
    check_result_status;
    pv_status := pds_common.format_cust_code(tbl_work(idx).cust_code, v_fmt_cust_code, pv_log_level + 3, pv_result_msg);
    check_result_status;
    pv_status := pds_lookup.lookup_distn_chnl_code (v_fmt_matl_code, v_fmt_cust_code,v_distbn_chnl_code, pv_log_level + 3, pv_result_msg);
    IF v_distbn_chnl_code IS NULL THEN

      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'ClaimRef ['|| tbl_work(idx).claim_ref || ']: Missing Distribution Channel for Matl/Cust ['||tbl_work(idx).matl_code||'/'||tbl_work(idx).cust_code||'].');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'ClaimRef ['|| tbl_work(idx).claim_ref || ']: Missing Distribution Channel for Matl/Cust ['||tbl_work(idx).matl_code||'/'||tbl_work(idx).cust_code||'].',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Find the original Customer Code. The Outbound Claim Approval may be for a different
    -- Customer Code than the Original inbound Claim. This is required to use as a key for
    -- looking up the original inbound claim in PDS_AR_CLAIMS. Function returns the
    -- v_promax_cust_code.
    pv_status := pds_lookup.lookup_orig_claimdoc_cust_code (tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).claim_ref, tbl_work(idx).internal_claim_num, v_promax_cust_code, pv_log_level + 3, pv_result_msg);
    IF pv_status <> constants.success THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'ClaimRef ['|| tbl_work(idx).claim_ref || ']: No Claimdoc KACC for Internal Claim Number ['||tbl_work(idx).internal_claim_num||'].');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'ClaimRef ['|| tbl_work(idx).claim_ref || ']: No Claimdoc KACC for Internal Claim Number ['||tbl_work(idx).internal_claim_num||'].',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    /*
    Australia SAP segments (Food, PET & Snack) raise claims in SAP and interface to Promax via the
	staging tables pds_ar_claims.
    To allow a claim to be automatically cleared in SAP, the approved AUS Food, PET and Snack claims
	must be sent back (to SAP) with the original SAP claim document details (ie accounting
    document number, line number, fiscal year). These key fields were written to the staging
    table pds_ar_claims when the claim was originally interfaced to Promax. This process
    looks up these key fields in the staging table (pds_ar_claims), and stores these values
    in variables for use in creating the interface data.
    Note: This needs to be reviewed prior to Snack go-live as it is yet to be determined
    how they will process the claims.
    */
    IF tbl_work(idx).cmpny_code = pc_pmx_cmpny_code_australia THEN
      pv_status := pds_lookup.lookup_orig_claimdoc (v_cmpny_code, v_div_code, v_promax_cust_code, tbl_work(idx).claim_ref, v_acctg_doc_num, v_fiscal_year, v_line_item_num, v_claim_cust_code, pv_log_level + 3, pv_result_msg);
      IF pv_status <> constants.success THEN
        v_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'ClaimRef ['|| tbl_work(idx).claim_ref || ']: No valid SAP AR Claim for ClaimRef and Cust ['||tbl_work(idx).cust_code||'].');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
          'ClaimRef ['|| tbl_work(idx).claim_ref || ']: No valid SAP AR Claim for ClaimRef and Cust ['||tbl_work(idx).cust_code||'].',
          pc_valdtn_severity_critical,
          tbl_work(idx).intfc_batch_code,
          tbl_work(idx).cmpny_code,
          tbl_work(idx).div_code,
          tbl_work(idx).ar_claims_apprvl_seq,
          NULL,
          NULL,
          pv_log_level + 3);

      END IF;
    END IF;

    -- Lookup the Tax Code.
    pv_status := pds_lookup.lookup_cntl_code(tbl_work(idx).cmpny_code, tbl_work(idx).div_code,'TAX_CODE',v_taxable_code, pv_log_level + 3, pv_result_msg);
    IF v_taxable_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'Missing TAX_CODE configuration setup for Company and Division.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'Missing TAX_CODE configuration setup for Company and Division.',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Lookup the No Tax Code.
    pv_status := pds_lookup.lookup_cntl_code(tbl_work(idx).cmpny_code, tbl_work(idx).div_code,'NOTAX_CODE',v_notax_code, pv_log_level + 3, pv_result_msg);
    IF v_notax_code IS NULL THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 3, 'Missing NOTAX_CODE configuration setup for Company and Division.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_ar_claimsapp,
        'Missing NOTAX_CODE configuration setup for Company and Division.',
        pc_valdtn_severity_critical,
        tbl_work(idx).intfc_batch_code,
        tbl_work(idx).cmpny_code,
        tbl_work(idx).div_code,
        tbl_work(idx).ar_claims_apprvl_seq,
        NULL,
        NULL,
        pv_log_level + 3);

    END IF;

    -- Update the Validation Status.
    UPDATE pds_ar_claims_apprvl
      SET valdtn_status = v_valdtn_status,
      procg_status = pc_procg_status_processed
    WHERE intfc_batch_code = tbl_work(idx).intfc_batch_code
      AND cmpny_code = tbl_work(idx).cmpny_code
      AND div_code = tbl_work(idx).div_code
      AND ar_claims_apprvl_seq = tbl_work(idx).ar_claims_apprvl_seq;

    -- Commit changes to PDS_AR_CLAIMS_APPRVL table when limit reached.
    if mod(idx / 1000) = 0 then 
       write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Commit 1000 changes to PDS_AR_CLAIMS_APPRVL table.');
       COMMIT;
    end if;

  -- End of AR Claim Approval header cursor array.
  end loop;
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'End of loop.');

  -- Commit changes to PDS_AR_CLAIMS_APPRVL table.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Commit final changes to PDS_AR_CLAIMS_APPRVL table.');
  COMMIT;

  -- End validate_pds_ar_claimsapp_atl procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'validate_pds_ar_claimsapp_atl - END.');

EXCEPTION
  WHEN e_processing_failure THEN
    ROLLBACK;
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.VALIDATE_PDS_AR_CLAIMSAPP_ATL:',
        pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code);
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

  WHEN e_processing_error THEN
    ROLLBACK;
    pv_result_msg :=
      utils.create_error_msg('PDS_AR_CLAIMSAPP_01_PRC.VALIDATE_PDS_AR_CLAIMSAPP_ATL:',
        pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code);
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    ROLLBACK;
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.VALIDATE_PDS_AR_CLAIMSAPP_ATL:',
      'Unexpected Exception - validate_ar_claimsapp_atls aborted.') ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

END validate_pds_ar_claimsapp_atl;


PROCEDURE interface_ar_claimsapp IS

BEGIN
  -- Start interface_ar_claimsapp procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'interface_ar_claimsapp - START.');

  -- Generate outgoing AR Claims Approval interface for all company/divisions.
  interface_ar_claimsapp_atlas (pc_pmx_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood.
  interface_ar_claimsapp_atlas (pc_pmx_cmpny_code_australia,pc_div_code_pet); -- Australia Petcare.
  interface_ar_claimsapp_atlas (pc_pmx_cmpny_code_australia,pc_div_code_food); -- Australia Food.
  interface_ar_claimsapp_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snack.
  interface_ar_claimsapp_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
  interface_ar_claimsapp_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Petcare.

  -- End interface_ar_claimsapp procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 1,'interface_ar_claimsapp - END.');

END interface_ar_claimsapp;


PROCEDURE interface_ar_claimsapp_atlas (
  i_pmx_cmpny_code VARCHAR2,
  i_pmx_div_code VARCHAR2) IS

  -- COLLECTION TYPE DECLARATIONS.
  TYPE tbl_ar_claimsapp IS TABLE OF VARCHAR2(226)
    INDEX BY BINARY_INTEGER;

  -- COLLECTION DECLARATIONS.
  rcd_approval_detail tbl_ar_claimsapp;

  -- VARIABLE DECLARATIONS.
  v_item_count            BINARY_INTEGER := 0;
  v_counter_approvals     NUMBER;
  v_instance              NUMBER(15,0);
  v_sap_cust_code         VARCHAR2(10); -- Customer code to send back to SAP.
  v_alloc_nmbr            VARCHAR2(18);
  v_matl_code             VARCHAR2(18);
  v_fmt_matl_code         VARCHAR2(18);
  v_plant_code            pmx_mfanz_matl_by_plant_view.plant%TYPE;
  v_currcy_code           pds_ar_claims_apprvl.doc_currcy_code%TYPE;
  v_profit_ctr            pds_ar_claims_apprvl.profit_ctr%TYPE;
  v_distbn_chnl_code      pds_ar_claims_apprvl.distbn_chnl_code%TYPE;
  v_promax_cust_code      claimdoc.kacc%TYPE;
  v_claim_cust_code       pds_ar_claims.cust_code%TYPE;
  v_acctg_doc_num         pds_ar_claims.acctg_doc_num%TYPE;
  v_fiscal_year           pds_ar_claims.fiscl_year%TYPE;
  v_line_item_num         pds_ar_claims.line_item_num%TYPE;
  v_taxable_code          pds_cntl.cntl_value%TYPE;
  v_notax_code            pds_cntl.cntl_value%TYPE;
  v_tax_code              pds_cntl.cntl_value%TYPE;
  v_tax_base              NUMBER := 0;
  v_tax                   NUMBER := 0;
  v_taxfree_base          NUMBER := 0;
  v_tax_found             BOOLEAN := FALSE;
  v_taxfree_found         BOOLEAN := FALSE;
  v_sap_cmpny_code        CHAR(4); -- Company Code in SAP format.
  v_cmpny_code            pds_div.cmpny_code%TYPE;
  v_div_code              pds_div.div_code%TYPE;
  v_glcode                pds_cntl.cntl_value%TYPE;

  -- SAVE DECLARATIONS.
  s_item_count            BINARY_INTEGER;
  s_cmpny_code            pds_ar_claims_apprvl.cmpny_code;
  s_div_code              pds_ar_claims_apprvl.div_code;
  s_internal_claim_num    pds_ar_claims_apprvl.internal_claim_num;
  s_claim_ref             pds_ar_claims_apprvl.claim_ref;
  s_cust_code             pds_ar_claims_apprvl.cust_code;
  s_prom_num              pds_ar_claims_apprvl.prom_num;
  s_doc_type              pds_ar_claims_apprvl.doc_type;
  s_pb_date               pds_ar_claims_apprvl.pb_date;
  s_tran_date             pds_ar_claims_apprvl.tran_date;
  s_claim_amt             pds_ar_claims_apprvl.claim_amt;
  s_tax_amt               pds_ar_claims_apprvl.tax_amt;

  -- ARRAY DECLARATIONS.
  type typ_work is table of pds_ar_claims_apprvl%rowtype index by binary_integer;
  tbl_work typ_work;

  -- EXCEPTION DECLARATIONS.
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- CURSOR DECLARATIONS.
  -- Valid AR Claims Approval cursor
  CURSOR csr_approval IS
    SELECT
      *
    FROM
      pds_ar_claims_apprvl
    WHERE
      cmpny_code = i_pmx_cmpny_code
      AND div_code = i_pmx_div_code
      AND pay_chq = pc_ar_claimsapp_not_by_chq
      AND directn = pc_ar_claimsapp_export
      AND data_type = pc_ar_claimsapp_claim
      AND valdtn_status = pc_valdtn_status_valid
      AND procg_status = pc_procg_status_processed
    ORDER BY
      cmpny_code,
      div_code,
      internal_claim_num,
      claim_ref,
      cust_code,
      prom_num,
      doc_type,
      pb_date,
      tran_date;

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

  -- Start interface_ar_claimsapp_atlas procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'interface_ar_claimsapp_atlas - START.');

  -- Bulk collect the AR Claims Approval records to be interfaced
  -- **notes** 1. frees the cursor and rollback space
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Open and bulk collect csr_approval cursor.');
  tbl_work.delete;
  open csr_approval;
  fetch csr_approval bulk collect into tbl_work;
  close csr_approval;
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Number of AR Claim Approval records: Promax Company:' || i_pmx_cmpny_code ||' Promax Division:' || i_pmx_div_code || ';' || 'Count:' || to_char(tbl_work.count) || '.');

  -- If there are no AR Claim Approval records to process then exit procedure (to avoid sending empty interface files).
  IF tbl_work.count = 0 THEN
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'No AR Claim Approvals to process for Promax Company:' || i_pmx_cmpny_code || ' Promax Division:' || i_pmx_div_code ||'.');
  ELSE
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Processing AR Claim Approvals.');

    -- Lookup the GL Account Code.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'COST_ACCOUNT_CODE', v_glcode,pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the Currency Code.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'CURRENCY_CODE',v_currcy_code, pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the Profit Centre.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'PROFIT_CENTRE_CODE',v_profit_ctr, pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the Tax Code.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'TAX_CODE',v_taxable_code, pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the No Tax Code.
    pv_status := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code,'NOTAX_CODE',v_notax_code, pv_log_level + 2, pv_result_msg);
    check_result_status;

    -- Lookup the Atlas Company and Division Codes.
    pv_status := pds_lookup.lookup_cmpny_div_code (i_pmx_cmpny_code, i_pmx_div_code, v_cmpny_code, v_div_code, pv_log_level + 2, pv_result_msg);
    check_result_status;

    v_sap_cmpny_code := RPAD(v_cmpny_code,4);

    -- Now start processing the approvals.
    v_counter_approvals := 0;

    -- Looping through csr_approval cursor array.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Looping through csr_approval cursor array.');
    s_cmpny_code := null;
    for idx in 1..tbl_work.count loop

      -- Start change in group variables
      if s_cmpny_code is null or
         tbl_work(idx).cmpny_code != s_cmpny_code or
         tbl_work(idx).div_code != s_div_code or
         tbl_work(idx).internal_claim_num != s_internal_claim_num or
         tbl_work(idx).claim_ref != s_claim_ref or
         tbl_work(idx).cust_code != s_cust_code or
         tbl_work(idx).prom_num != s_prom_num or
         tbl_work(idx).doc_type != s_doc_type or
         tbl_work(idx).pb_date != s_pb_date or
         tbl_work(idx).tran_date != s_tran_date then

        -- Finalise the previous header when required
        if not(s_cmpny_code is null) then

          -- Update the previous header "R" claim amd tax totals
          rcd_approval_detail(s_item_count) := substr(rcd_approval_detail(s_item_count),1,11)||
                                               TO_CHAR(-1*(s_claim_amt + s_tax_amt),'9999999999999999999.99'||
                                               substr(rcd_approval_detail(s_item_count),35);

          -- Build the AR Claims Approval Tax output record.
          IF v_taxfree_found THEN
            v_item_count := v_item_count + 1;
            rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
              v_tax_code ||
              RPAD( ' ',20) ||
              '000' ||
              TO_CHAR(v_taxfree_base,'9999999999999999999.99')||
              RPAD( ' ',8);
          END IF;
          IF v_tax_found THEN
            v_item_count := v_item_count + 1;
            rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
              v_tax_code ||
              TO_CHAR(v_tax,'9999999999999999999.99')||
              TO_CHAR(v_tax_base,'9999999999999999999.99')||
              RPAD( ' ',4) ||
              RPAD( ' ',3);
          END IF;

          /*
          Now update the SAP ARClaims record (in pds_ar_claims). -- only for Australia Food, PET & Snack - there
          is no record for NZ. This is to identify that the original AR Claim has now been approved.
          Used in AR Claim when validating the status of a claim (ie has it loaded
          into Promax, has it been approved?).
          CF 01/08/2006 Only update the record which loaded into Promax (ie the VALID Claim).
          Note: Requires reviewing when Snack moves to ATLAS.
          */
          IF rv_approval.cmpny_code = pc_pmx_cmpny_code_australia THEN
            UPDATE pds_ar_claims
              SET promax_ar_apprvl_date = sysdate
            WHERE acctg_doc_num = v_acctg_doc_num
              AND fiscl_year = v_fiscal_year
              AND line_item_num = v_line_item_num
              AND valdtn_status = pc_valdtn_status_valid;
          END IF;

        end if;

        -- Save the group variables
        write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Start csr_approval array header.');
        s_cmpny_code := tbl_work(idx).cmpny_code;
        s_div_code := tbl_work(idx).div_code;
        s_internal_claim_num := tbl_work(idx).internal_claim_num;
        s_claim_ref := tbl_work(idx).claim_ref;
        s_cust_code := tbl_work(idx).cust_code;
        s_prom_num := tbl_work(idx).prom_num;
        s_doc_type := tbl_work(idx).doc_type;
        s_pb_date := tbl_work(idx).pb_date;
        s_tran_date := tbl_work(idx).tran_date;
        s_claim_amt := 0;
        s_tax_amt := 0;

        -- Initialise tax values.
        v_tax_base := 0;
        v_tax := 0;
        v_taxfree_base := 0;
        v_tax_found := FALSE;
        v_taxfree_found := FALSE;

        -- Increment the counter.
        v_counter_approvals := v_counter_approvals + 1;

        -- Find the original Customer Code. The outbound claim approval may be for a different
        -- Customer code than the original inbound Claim. Once retrieved, the original claim
        -- Customer Code is stored in a variable and used as a key to lookup the original
        -- inbound claim in the PDS_AR_CLAIMS table. Lookup only performed for Company '47' and '49'.
        pv_status := pds_lookup.lookup_orig_claimdoc_cust_code (tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).claim_ref, tbl_work(idx).internal_claim_num, v_promax_cust_code, pv_log_level + 3, pv_result_msg);
        check_result_status;

        /*
        Australia SAP segments (Food, PET & Snack) raise claims in SAP and interface to Promax via
	    the PDS_AR_CLAIMS staging tables.
        To allow a claim to be automatically cleared in SAP, the approved AUS Food, PET & Snack claims
        must be sent back (to SAP) with the original SAP claim document details (ie accounting
        document number, line number, fiscal year). These key fields were written to the staging
        table pds_ar_claims when the claim was originally interfaced to Promax. This process
        looks up these key fields in the staging table (pds_ar_claims), and stores these values
        in variables for use in creating the interface data.
        Note: This needs to be reviewed prior to Pet and Snack go-live as it is yet to be determined
        how they will process the claims.
        */
        IF tbl_work(idx).cmpny_code = pc_pmx_cmpny_code_australia THEN
          pv_status := pds_lookup.lookup_orig_claimdoc (v_cmpny_code, v_div_code, v_promax_cust_code, tbl_work(idx).claim_ref, v_acctg_doc_num, v_fiscal_year, v_line_item_num, v_claim_cust_code, pv_log_level + 3, pv_result_msg);
          check_result_status;
          -- Build the variable for storing the SAP required accounting document fields.
          v_alloc_nmbr:= RPAD(LPAD(v_acctg_doc_num,10,'0') || v_fiscal_year || LPAD(v_line_item_num,3,'0'),18);
          -- Now perform the output Customer Code conversion by using the original customer number.
          -- Customer codes have leading zeroes if they are numeric, otherwise the field
          -- is left justified with spaces padding (on the right). The width returned
          -- is 10 characters, req'd format for SAP (i.e. export).
          pv_status := pds_common.format_cust_code(v_claim_cust_code, v_sap_cust_code, pv_log_level + 3, pv_result_msg);
        ELSE
          -- NZ claims are manually created (ie do not exist in SAP) so accounting document details are blank.
          pv_status := pds_common.format_cust_code(tbl_work(idx).cust_code, v_sap_cust_code, pv_log_level + 3, pv_result_msg);
          v_alloc_nmbr:= RPAD(' ',18,' ');
        END IF;

        -- Build the AR Claims Approval Header output record.
        v_item_count := v_item_count + 1;
        rcd_approval_detail(v_item_count) := 'H' || -- Indicator.
          'IDOC ' || -- Obj Type.
          'PX' || -- Obj Key.
          TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') || -- Part of Obj Key.
          LPAD(TO_CHAR(v_counter_approvals),4,'0') ||	-- Obj Key Counter.
          'RFBU'|| -- Bus Act.
          'BATCHSCHE   '|| -- Username.
          RPAD('Pmx Claim '|| v_sap_cmpny_code || tbl_work(idx).div_code || -- Header Text.
          ' ' || -- Header Text con't.
          TO_CHAR(SYSDATE,'YYYYMMDD'),25) || -- Header Text con't.
          v_sap_cmpny_code || -- Company Code.
          RPAD(v_currcy_code,5,' ') || -- Currency.
          TO_CHAR(tbl_work(idx).tran_date,'YYYYMMDD') || -- Doc Date.
          TO_CHAR(tbl_work(idx).pb_date,'YYYYMMDD') || -- Posting Date.
          TO_CHAR(tbl_work(idx).pb_date,'YYYYMMDD') || -- Trans Date.
          'UE' ||
          RPAD(tbl_work(idx).claim_ref,16) || -- Ref Doc No.
          RPAD('PROMAX',10); -- Log Sys (req'd for SAP reporting).

        -- Build the AR Claims Approval Customer output record.
        v_item_count := v_item_count + 1;
        s_item_count := v_item_count;
        rcd_approval_detail(v_item_count) := 'R' || -- Indicator.
          LPAD(v_sap_cust_code,10,'0') || -- Customer.
          TO_CHAR(0,'9999999999999999999.99') || -- Amount.
          RPAD(' ',4) || -- Pmnttrms.
          RPAD(' ',8) || -- Bline Date.
          RPAD(' ',1) || -- Payment Block.
          v_alloc_nmbr || -- Alloc Number.
          RPAD('Claim#' || trim(tbl_work(idx).claim_ref) || ' against Promo#' || trim(tbl_work(idx).prom_num),50); -- Item Text.

      -- End change in group variables
      end if;

      -- Increment the item (and array) counter.
      v_item_count := v_item_count + 1;

      -- Sum the claim and tax amounts.
      s_claim_amt := s_claim_amt + tbl_work(idx).claim_amt;
      s_tax_amt := s_tax_amt + tbl_work(idx).tax_amt;

      -- Perform Distribution Channel lookup.
      pv_status := pds_common.format_matl_code(tbl_work(idx).matl_code,v_fmt_matl_code,pv_log_level + 3,pv_result_msg);
      check_result_status;
      pv_status := pds_lookup.lookup_distn_chnl_code (v_fmt_matl_code, v_sap_cust_code,v_distbn_chnl_code, pv_log_level + 3, pv_result_msg);

      /*
      Perform Material Determination lookups/conversions.
      Performs a material determination lookup to the lads database,  based on the
      selection criteria provided which is the promotion number, customer code, and
      the product code.  Ths promotion number is used to find  the start buy and end
      buy dates.  Using these dates overlap detection is applied. The greatest accuracy
      with regards to output data will be received if the start dates and end dates in
      Promax and the material determination tables are aligned. Otherwise the wrong real
      item may be returned.  The detection checking occurs  in the following order, by
      sold to, by Customer hierarchy, by distribution channel,
      */
      pv_status := pds_lookup.lookup_matl_dtrmntn(tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).prom_num, tbl_work(idx).cust_code, tbl_work(idx).matl_code, v_matl_code, pv_log_level + 4, pv_result_msg);
      check_result_status;

      -- Now check if the product is taxable.
      IF pds_exist.exist_taxable(tbl_work(idx).cmpny_code, tbl_work(idx).div_code, tbl_work(idx).doc_type,pv_log_level + 4, pv_result_msg) = constants.success THEN
        v_tax_base := v_tax_base + tbl_work(idx).claim_amt;
        v_tax := v_tax + tbl_work(idx).tax_amt;
        v_tax_found := TRUE;
        v_tax_code := v_taxable_code;
      ELSE
        v_taxfree_base := v_taxfree_base + tbl_work(idx).claim_amt;
        v_taxfree_found := TRUE;
        v_tax_code := v_notax_code;
      END IF;

      -- Lookup Plant Code.
      pv_status := pds_lookup.lookup_matl_plant_code(tbl_work(idx).cmpny_code, v_matl_code, v_plant_code, pv_log_level + 4, pv_result_msg);
      check_result_status;

      -- Save the item line to the array. Array will be unloaded when all item lines have been retrieved.
      -- CF 01/08/2006 Include the IC Number as unique identifier in Promax.
      rcd_approval_detail(v_item_count) := 'G' || -- Indicator.
        v_glcode ||
        TO_CHAR((tbl_work(idx).claim_amt),'9999999999999999999.99') ||
        RPAD('IC#' || RTRIM(tbl_work(idx).internal_claim_num)||' Mat' || RTRIM(tbl_work(idx).matl_code)||' Promo' || trim(tbl_work(idx).prom_num) ||' Cus'||RTRIM(tbl_work(idx).cust_code),50) ||
        v_alloc_nmbr ||
        v_tax_code ||
        RPAD(' ',10,' ') || -- Cost Centre always blank.
        RPAD(' ',12,' ') || -- Order Id always blank.
        RPAD(' ',24,' ') || -- WBS element.
        RPAD(' ',13,' ') || -- Quantity.
        RPAD(' ', 3,' ') || -- Base Unit of Measure.
        RPAD(NVL(v_matl_code,' '),18) ||
        v_plant_code || -- plant
        v_sap_cust_code ||
        LPAD(v_profit_ctr,10,'0') || -- Profit Centre.
        RPAD(v_sap_cmpny_code,4) || -- Sales Org.
        RPAD(v_distbn_chnl_code,2); -- Distribution Channel.

      -- Update the processing Status.
      UPDATE pds_ar_claims_apprvl
        SET procg_status = pc_procg_status_completed
      WHERE intfc_batch_code = tbl_work(idx).intfc_batch_code
        AND cmpny_code = tbl_work(idx).cmpny_code
        AND div_code = tbl_work(idx).div_code
        AND ar_claims_apprvl_seq = tbl_work(idx).ar_claims_apprvl_seq;

    -- End of AR Claim Approval header cursor array.
    end loop;
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'End of csr_approval cursor array loop.');

    -- Finalise the final header when required
    if not(s_cmpny_code is null) then

      -- Update the previous header "R" claim amd tax totals
      rcd_approval_detail(s_item_count) := substr(rcd_approval_detail(s_item_count),1,11)||
                                           TO_CHAR(-1*(s_claim_amt + s_tax_amt),'9999999999999999999.99'||
                                           substr(rcd_approval_detail(s_item_count),35);

      -- Build the AR Claims Approval Tax output record.
      IF v_taxfree_found THEN
        v_item_count := v_item_count + 1;
        rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
          v_tax_code ||
          RPAD( ' ',20) ||
          '000' ||
          TO_CHAR(v_taxfree_base,'9999999999999999999.99')||
          RPAD( ' ',8);
      END IF;
      IF v_tax_found THEN
        v_item_count := v_item_count + 1;
        rcd_approval_detail(v_item_count) := 'T' || -- Indicator.
          v_tax_code ||
          TO_CHAR(v_tax,'9999999999999999999.99')||
          TO_CHAR(v_tax_base,'9999999999999999999.99')||
          RPAD( ' ',4) ||
          RPAD( ' ',3);
      END IF;

      /*
      Now update the SAP ARClaims record (in pds_ar_claims). -- only for Australia Food, PET & Snack - there
      is no record for NZ. This is to identify that the original AR Claim has now been approved.
      Used in AR Claim when validating the status of a claim (ie has it loaded
      into Promax, has it been approved?).
      CF 01/08/2006 Only update the record which loaded into Promax (ie the VALID Claim).
      Note: Requires reviewing when Snack moves to ATLAS.
      */
      IF rv_approval.cmpny_code = pc_pmx_cmpny_code_australia THEN
        UPDATE pds_ar_claims
          SET promax_ar_apprvl_date = sysdate
        WHERE acctg_doc_num = v_acctg_doc_num
          AND fiscl_year = v_fiscal_year
          AND line_item_num = v_line_item_num
          AND valdtn_status = pc_valdtn_status_valid;
      END IF;

    end if;

    -- Write the number of records processed to the Log.
    IF v_item_count = 0 THEN
      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'No data was found.');
    ELSE
      write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,v_item_count||' records written.');
    END IF;

    -- Open the outbound interface.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Open the outbound interface.');
    v_instance  := lics_outbound_loader.create_interface(pc_interface_ar_claimsapp_01, null, pc_interface_ar_claimsapp_01||'.DAT');

    -- Write data from table to output file.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Looping through table in order to write AR Claims Approval records into the output file.');
    FOR i IN 1..v_item_count LOOP
      lics_outbound_loader.append_data(rcd_approval_detail(i));
    END LOOP;
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'End of loop writing records to output file.');

    -- Finalise the interface.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Finalising ICS interface file.');
    lics_outbound_loader.finalise_interface;

    -- Commit update to PDS_AR_CLAIMS_APPRVL and PDS_AR_CLAIMS tables.
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'Commit update to PDS_AR_CLAIMS_APPRVL and PDS_AR_CLAIMS tables.');
    COMMIT;

  END IF;

  -- End interface_ar_claimsapp_atlas procedure.
  write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,'interface_ar_claimsapp_atlas - END.');

EXCEPTION

  -- Exception trap: when any exceptions occur the IS_CREATED method should be tested.
  -- If IS_CREATED returns true then the exception should be added to
  -- the interface for logging purposes and the interface finalised.

  WHEN e_processing_failure THEN
    ROLLBACK;
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.INTERFACE_AR_CLAIMSAPP_ATLAS:',
        pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code);
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

  WHEN e_processing_error THEN
    ROLLBACK;
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.INTERFACE_AR_CLAIMSAPP_ATLAS:',
        pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code);
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

  -- Send warning message via E-mail and PDS_LOG.
  WHEN OTHERS THEN
    ROLLBACK;
    pv_result_msg :=
      utils.create_failure_msg('PDS_AR_CLAIMSAPP_01_PRC.INTERFACE_AR_CLAIMSAPP_ATLAS:',
      'Unexpected Exception - interface_ar_claimsapp_atlas aborted. ROLLBACK, check LICS and finalise if required and exit.') ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,'Promax Division Code',i_pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_ar_claimsapp,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_arclaimsapp_01_prc,'MFANZ Promax AR Claims Approval Process 01',
      pv_result_msg);
    ROLLBACK;
        IF lics_outbound_loader.is_created = TRUE THEN
      lics_outbound_loader.add_exception(SUBSTR(SQLERRM,1,1024));
      lics_outbound_loader.finalise_interface;
    END IF;
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_arclaimsapp_01_prc,'N/A');
    END IF;

END interface_ar_claimsapp_atlas;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table.
  pds_utils.log (pc_job_type_arclaimsapp_01_prc,
    i_data_type,
    i_sort_field,
    i_log_level,
    i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;

END pds_ar_claimsapp_01_prc;
/