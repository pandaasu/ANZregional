CREATE OR REPLACE PACKAGE pds_pricelist_01_prc IS

/*********************************************************************************
  NAME:      run_pds_pricelist_01_prc
  PURPOSE:   This procedure performs three key tasks:

             1. Validates the Price List data in the PDS schema.
             2. Transfers validated Price List data into the Postbox schema.
             3. Initiates the transfer from Postbox to Promax schema.

             This procedure is triggered by a pipe message from PDS_PRICELIST_01_INT
             interface procedure, which loads Price List data into the PDS schema.

             NOTE: v_debug is a debugging constant, defined at the package level.
             If FALSE (ie. we're running in production) then send Alerts, else sends
             emails.

        .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   19/08/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   4/7/2007    Anna Every     WASTEPERC,CONTRCOMM Added by Anna Every 04/07/2007 for new release.
  2.0   20/06/2009 Steve Gregan         Added create log.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_pricelist_01_prc;

/*********************************************************************************
  NAME:      validate_pds_pricelist
  PURPOSE:   This procedure executes the validate_pds_pricelist procedure, by
             Company and Division.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   19/08/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   10/03/2006 Craig Ford           Exclude Price Lists with a future Effective Date.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_pricelist;

/*********************************************************************************
  NAME:      validate_pds_pricelist_atlas
  PURPOSE:   This procedure validates the price list data in the PDS_PRICE_LIST
             table in the PDS schema.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   19/08/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   02/02/2006 Craig Ford           Updated to include Aus PETCARE.
  2.0   20/06/2009 Steve Gregan         Commented out future price exclusion

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Promax Company Code                  47
  2    IN     VARCHAR2 Promax Division Code                 01

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_pds_pricelist_atlas (
  i_pmx_cmpny_code IN VARCHAR2,
  i_pmx_div_code IN VARCHAR2);

/*********************************************************************************
  NAME:      transfer_pricelist
  PURPOSE:   This procedure executes the transfer_pricelist procedures, by
             Company and Division, for valid price list data in the PDS_PRICE_LIST
             table.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   19/08/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE transfer_pricelist;

/*********************************************************************************
  NAME:      transfer_pricelist_postbox
  PURPOSE:   This procedure transfers validated price list data from the PDS schema
             into the postbox schema.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   19/08/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   02/02/2006 Craig Ford           Updated to include Aus PETCARE.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Promax Company Code                  47
  2    IN     VARCHAR2 Promax Division Code                 01

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE transfer_pricelist_postbox (
  i_pmx_cmpny_code IN VARCHAR2,
  i_pmx_div_code IN VARCHAR2);

/*********************************************************************************
  NAME:      initiate_postbox_pricelist
  PURPOSE:   Initiate the Promax Postbox Price List process. This moves Price List
             data from the Postbox to the Promax Schema. The Postbox job is initiated
             by adding a Job Control record into the PDS_PMX_JOB_CNTL table
             using the Create_Promax_Job_Control utility function.
      .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   19/08/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE initiate_postbox_pricelist;

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

END pds_pricelist_01_prc;
/


CREATE OR REPLACE PACKAGE BODY pds_pricelist_01_prc IS

  -- PACKAGE VARIABLE DECLARATIONS
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_pmx_cmpny_code_australia   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia','PMX_CMPNY_CODE');
  pc_pmx_cmpny_code_new_zealand CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('new_zealand','PMX_CMPNY_CODE');
  pc_div_code_snack             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('snack','DIV_CODE');
  pc_div_code_food              CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('food','DIV_CODE');
  pc_div_code_pet               CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pet','DIV_CODE');
  pc_job_type_pricelist_01_prc  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pricelist_01_prc','JOB_TYPE');
  pc_data_type_pricelist        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pricelist','DATA_TYPE');
  pc_debug                      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_minor          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_valdtn_severity_critical   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('critical','VALDTN_SEVERITY');
  pc_valdtn_status_unchecked    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unchecked','VALDTN_STATUS');
  pc_valdtn_status_valid        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('valid','VALDTN_STATUS');
  pc_valdtn_status_invalid      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('invalid','VALDTN_STATUS');
  pc_valdtn_type_pricelist      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pricelist','VALDTN_TYPE');
  pc_procg_status_loaded        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('loaded','PROCG_STATUS');
  pc_procg_status_processed     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('processed','PROCG_STATUS');
  pc_procg_status_completed     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','PROCG_STATUS');
  pc_valdtn_status_excluded     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('excluded','VALDTN_STATUS');
  pc_pricelist_mfg_cost_val     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('mfg_cost_val','PRICELIST');
  pc_pricelist_gst_pct          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('gst_pct','PRICELIST');
  pc_pricelist_rsu_pct          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('rsu_pct','PRICELIST');
  pc_pricelist_default_date     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('default_date','PRICELIST');
  pc_job_status_completed       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('completed','JOB_STATUS');
  pc_pstbx_pricelist_load_01    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pricelist_load_01','PSTBX');

PROCEDURE run_pds_pricelist_01_prc IS

BEGIN

  -- Start run_pds_pricelist_01_prc procedure.
  pds_utils.create_log;
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level, 'run_pds_pricelist_01_prc - START.');

  -- The 3 key tasks: validate, transfer and initiate postbox job.
  validate_pds_pricelist();
  transfer_pricelist();
  initiate_postbox_pricelist();

  -- End run_pds_pricelist_01_prc procedure.
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level, 'run_pds_pricelist_01_prc - END.');
  pds_utils.end_log;

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_PRICELIST_01_PRC.RUN_PDS_PRICELIST_01_PRC:',
      'Unexpected Exception - run_pds_pricelist_01_prc aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_pricelist,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_prc,'MFANZ Promax Pricelist Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pricelist_01_prc,'N/A');
    END IF;
    pds_utils.end_log;

END run_pds_pricelist_01_prc;


PROCEDURE validate_pds_pricelist IS

BEGIN

  -- Start validate_pds_pricelist procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,'validate_pds_pricelist - START.');

  -- Execute the validate Price List procedure for all company / divisions.
  -- The procedure validates data within the PDS schema.
  validate_pds_pricelist_atlas (pc_pmx_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood.
  validate_pds_pricelist_atlas (pc_pmx_cmpny_code_australia,pc_div_code_food); -- Australia Food.
  validate_pds_pricelist_atlas (pc_pmx_cmpny_code_australia,pc_div_code_pet); -- Australia Pet.
  validate_pds_pricelist_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snack.
  validate_pds_pricelist_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
  validate_pds_pricelist_atlas (pc_pmx_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Pet.

  -- Trigger the pds_pricelist_01_rep procedure.
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level, 'Trigger the PDS_PRICELIST_01_REP procedure.');
  lics_trigger_loader.execute('MFANZ Promax Price List 01 Report',
                              'pds_app.pds_pricelist_01_rep.run_pds_pricelist_01_rep',
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_PRICELIST_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_PRICELIST_01_REP'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_PRICELIST_01_REP'));

  -- End validate_pds_pricelist procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,'validate_pds_pricelist - END.');

END validate_pds_pricelist;


PROCEDURE validate_pds_pricelist_atlas(
  i_pmx_cmpny_code VARCHAR2,
  i_pmx_div_code VARCHAR2) IS

  -- VARIABLE DECLARATIONS
  v_valdtn_status    pds_price_list.valdtn_status%TYPE; -- Record status.
  v_eff_date         pbprices.price1date%TYPE;
  v_current_date     DATE DEFAULT TRUNC(SYSDATE,'DD');

  -- Retrieve all unchecked Price List records to be validated.
  CURSOR csr_pricelist IS
    SELECT
      t1.cmpny_code,
      t1.div_code,
      t1.distbn_chnl_code,
      t1.matl_code,
      t1.eff_date,
      t1.list_price,
      t1.mfg_cost,
      t1.rrp
    FROM
      pds_price_list t1
    WHERE
      t1.cmpny_code = i_pmx_cmpny_code
      AND t1.div_code = i_pmx_div_code
      AND t1.valdtn_status = pc_valdtn_status_unchecked
      AND t1.procg_status = pc_procg_status_loaded
    FOR UPDATE NOWAIT;
  rv_pricelist csr_pricelist%ROWTYPE;

BEGIN

  -- Start validate_pds_pricelist_atlas procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'validate_pds_pricelist_atlas - START.');

  -- Clear validation table of records if they exist.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'Clear validation table of Pricelist records if they exist.');
  pds_utils.clear_validation_reason(pc_valdtn_type_pricelist,i_pmx_cmpny_code,i_pmx_div_code,NULL,NULL,NULL,NULL,pv_log_level + 2);

  -- Reading through each of the Price List records to be validated.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'Open csr_pricelist cursor.');
  OPEN csr_pricelist;

  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'Looping through the csr_pricelist cursor.');
  LOOP
    FETCH csr_pricelist INTO rv_pricelist;
    EXIT WHEN csr_pricelist%NOTFOUND;

    v_valdtn_status := pc_valdtn_status_valid;

    -- Check that Price List Material Code exists in the Promax PRODUCTS table.
    pv_status := pds_exist.exist_matl_code(i_pmx_cmpny_code,i_pmx_div_code,rv_pricelist.matl_code,
    pv_log_level + 3,pv_result_msg);

    IF pv_status <> constants.success THEN
      v_valdtn_status := pc_valdtn_status_excluded;

      write_log(pc_data_type_pricelist,'N/A',pv_log_level + 3,('Price List Material Code ['
        || rv_pricelist.matl_code || '] does not exist in the Promax PRODUCTS Table, therefore set to EXCLUDED'));

    END IF;

    -- Check that Distribution Channel Code exists in the Promax LISTDESC table.
    pv_status := pds_exist.exist_distbn_chnl_code(i_pmx_cmpny_code,i_pmx_div_code,
    rv_pricelist.distbn_chnl_code,pv_log_level + 3,pv_result_msg);

    IF pv_status <> constants.success THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_pricelist,'N/A',pv_log_level + 3,'Distribution Channel Code ['||rv_pricelist.distbn_chnl_code||'] does not exist in the LISTDESC table and is therefore invalid.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_pricelist,
        'Distbn Chnl ['||rv_pricelist.distbn_chnl_code||'] does not exist in the LISTDESC table.',
        pc_valdtn_severity_critical,
        rv_pricelist.cmpny_code,
        rv_pricelist.div_code,
        rv_pricelist.distbn_chnl_code,
        rv_pricelist.matl_code,
        rv_pricelist.eff_date,
        NULL,
        pv_log_level + 3);
    END IF;

    -- Check that Price List Effective Date is a valid date.
    BEGIN
      v_eff_date := TO_DATE(rv_pricelist.eff_date,'YYYYMMDD');
    EXCEPTION
      WHEN OTHERS THEN
        v_valdtn_status := pc_valdtn_status_invalid;

        write_log(pc_data_type_pricelist,'N/A',pv_log_level + 3,'Price List Effective Date ['||rv_pricelist.eff_date||'] is not a valid date.');

        -- Add an entry into the validation reason tables.
        pds_utils.add_validation_reason(pc_valdtn_type_pricelist,
          'Price List Effective Date is not a valid date.',
          pc_valdtn_severity_critical,
          rv_pricelist.cmpny_code,
          rv_pricelist.div_code,
          rv_pricelist.distbn_chnl_code,
          rv_pricelist.matl_code,
          rv_pricelist.eff_date,
          NULL,
          pv_log_level + 3);
    END;

    -- Check whether List Price is null or zero.
    IF rv_pricelist.list_price IS NULL OR rv_pricelist.list_price = 0 THEN
      v_valdtn_status := pc_valdtn_status_invalid;

      write_log(pc_data_type_pricelist,'N/A',pv_log_level + 3,'List Price does not exist or has a value of zero.');

      -- Add an entry into the validation reason tables.
      pds_utils.add_validation_reason(pc_valdtn_type_pricelist,
        'List Price does not exist or has a value of zero.',
        pc_valdtn_severity_critical,
        rv_pricelist.cmpny_code,
        rv_pricelist.div_code,
        rv_pricelist.distbn_chnl_code,
        rv_pricelist.matl_code,
        rv_pricelist.eff_date,
        NULL,
        pv_log_level + 3);
    END IF;

    -- Update PDS_PRICE_LIST table with the validation status.
    UPDATE pds_price_list
    SET valdtn_status = v_valdtn_status,
      procg_status = pc_procg_status_processed
    WHERE CURRENT OF csr_pricelist;

  END LOOP;
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level + 2, 'End of loop.');

  -- Commit changes to pds_price_list table.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'Commiting changes to table PDS_PRICE_LIST.');
  COMMIT;

  -- Close csr_pricelist cursor.
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level + 2, 'Close csr_pricelist cursor.');
  CLOSE csr_pricelist;

  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'validate_pds_pricelist_atlas - END.');

EXCEPTION

  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_PRICELIST_01_PRC.VALIDATE_PDS_PRICELIST_ATLAS:',
      'Unexpected Exception - validate_pricelist_atlas aborted.') ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,
        'Promax Division Code',i_pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_prc,'MFANZ Promax Pricelist Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pricelist_01_prc,'N/A');
    END IF;

END validate_pds_pricelist_atlas;


PROCEDURE transfer_pricelist IS

BEGIN

  -- Start transfer_pricelist procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,'transfer_pricelist - START.');

  -- Execute the transfer Price List procedure for all company / divisions. The
  -- procedure transfers data from PDS to the Promax schema.
  transfer_pricelist_postbox (pc_pmx_cmpny_code_australia,pc_div_code_snack); -- Australia Snackfood.
  transfer_pricelist_postbox (pc_pmx_cmpny_code_australia,pc_div_code_food); -- Australia Food.
  transfer_pricelist_postbox (pc_pmx_cmpny_code_australia,pc_div_code_pet); -- Australia Pet.
  transfer_pricelist_postbox (pc_pmx_cmpny_code_new_zealand,pc_div_code_snack); -- New Zealand Snack.
  transfer_pricelist_postbox (pc_pmx_cmpny_code_new_zealand,pc_div_code_food); -- New Zealand Food.
  transfer_pricelist_postbox (pc_pmx_cmpny_code_new_zealand,pc_div_code_pet); -- New Zealand Pet.

  -- End transfer_pricelist procedure .
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,'transfer_pricelist - END.');

END transfer_pricelist;


PROCEDURE transfer_pricelist_postbox(
  i_pmx_cmpny_code VARCHAR2,
  i_pmx_div_code VARCHAR2) IS

  -- VARIABLE DECLARATIONS.
  v_matl_code    pds_matl.matl_code%TYPE;
  v_mfg_cost     pds_price_list.mfg_cost%TYPE := 0;
  v_rrprice      pds_price_list.rrp%TYPE := 0;
  v_eff_date     pbprices.price1date%TYPE;
  v_sav_distbn_chnl_code pds_price_list.matl_code%TYPE;
  v_sav_matl_code pds_price_list.matl_code%TYPE;
  v_price1data boolean;
  v_price1 pbprices.price1%TYPE;
  v_price1date pbprices.price1date%TYPE;
  v_price2 pbprices.price2%TYPE;
  v_price2date pbprices.price2date%TYPE;
  v_price3 pbprices.price3%TYPE;
  v_price3date pbprices.price3date%TYPE;

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;
  e_processing_error   EXCEPTION;

  -- Retrieve validated Price Lists to be transferred to Postbox Schema.
  CURSOR csr_pricelist IS
    SELECT
      t1.cmpny_code,
      t1.div_code,
      t1.distbn_chnl_code,
      t1.matl_code,
      t1.eff_date,
      t1.list_price,
      t1.mfg_cost,
      t1.rrp,
      t2.prodcode as pmx_matl_code
    FROM
      pds_price_list t1,
      products t2
    WHERE
      t1. cmpny_code = i_pmx_cmpny_code
      AND t1.div_code = i_pmx_div_code
      AND t1.cmpny_code = t2.cocode(+)
      AND t1.div_code = t2.divcode(+)
      AND LTRIM(t1.matl_code,'0') = t2.prodcode(+)
      AND t1.valdtn_status = pc_valdtn_status_valid
      AND t1.procg_status = pc_procg_status_processed
    ORDER BY
      t1.cmpny_code,
      t1.div_code,
      t1.distbn_chnl_code,
      t1.matl_code,
      t1.eff_date;
  rv_pricelist csr_pricelist%ROWTYPE;

  -- ARRAY VARIABLES
  type typ_work is table of csr_pricelist%ROWTYPE index by binary_integer;
  tbl_work typ_work;

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

  -- Start the transfer_pricelist_postbox procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'transfer_pricelist_postbox - START.');

  -- Read through each of the Price List records to be transferred.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level,'Open csr_pricelist cursor.');
  v_sav_distbn_chnl_code := null;
  v_sav_matl_code := null;
  OPEN csr_pricelist;
  write_log(pc_data_type_pricelist,'N/A',pv_log_level,'Looping through the csr_pricelist cursor.');
  LOOP
    FETCH csr_pricelist INTO rv_pricelist;
    EXIT WHEN csr_pricelist%NOTFOUND;

    -- Format the Material Code by removing leading zeros.
    pv_status := pds_common.format_pmx_matl_code (rv_pricelist.matl_code,v_matl_code,pv_log_level + 2,pv_result_msg);
    check_result_status;

    if v_sav_distbn_chnl_code is null or
       v_sav_distbn_chnl_code != rv_pricelist.distbn_chnl_code or
       v_sav_matl_code != v_matl_code then

       if not(v_sav_distbn_chnl_code is null) then

          v_price1 := 0;
          v_price1date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
          v_price2 := 0;
          v_price2date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
          v_price3 := 0;
          v_price3date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
          v_price1data := false;

          for idx in 1..tbl_work.count loop

             IF tbl_work(idx).eff_date IS NULL THEN
               v_eff_date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
             ELSE
               v_eff_date := TO_DATE(tbl_work(idx).eff_date,'YYYYMMDD');
             END IF;

             if idx = 1 then
                v_price1 := tbl_work(idx).list_price;
                v_price1date := v_eff_date;
                if trunc(v_eff_date) > trunc(sysdate) then
                   v_price1data := true;
                   v_price1 := 0.01;
                   v_price1date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
                   v_price2 := tbl_work(idx).list_price;
                   v_price2date := v_eff_date;
                end if;
                IF tbl_work(idx).mfg_cost IS NULL OR tbl_work(idx).mfg_cost = 0 THEN
                   v_mfg_cost := tbl_work(idx).list_price * pc_pricelist_mfg_cost_val;
                ELSE
                   v_mfg_cost := tbl_work(idx).mfg_cost;
                END IF;
                v_rrprice := tbl_work(idx).rrp;
             end if;
             if idx = 2 then
                if v_price1data = false then
                   v_price2 := tbl_work(idx).list_price;
                   v_price2date := v_eff_date;
                else
                   v_price3 := tbl_work(idx).list_price;
                   v_price3date := v_eff_date;
                end if;
             end if;
             if idx = 3 then
                if v_price1data = false then
                   v_price3 := tbl_work(idx).list_price;
                   v_price3date := v_eff_date;
                end if;
             end if;

          end loop;

          -- Insert into Postbox PBPRICES table.
          INSERT INTO pbprices
            (
            cocode,
            divcode,
            prodcode,
            price1,
            price1date,
            price2,
            price2date,
            price3,
            price3date,
            stdcost,
            list,
            rrprice,
            pbdate,
            pbtime,
            mcperc,
            WASTEPERC,
            CONTRCOMM
            )
          VALUES
            (
            i_pmx_cmpny_code,
            i_pmx_div_code,
            v_sav_matl_code,
            v_price1,
            v_price1date,
            v_price2,
            v_price2date,
            v_price3,
            v_price3date,
            v_mfg_cost,
            NVL(v_sav_distbn_chnl_code,0),
            v_rrprice,
            SYSDATE, -- pbdate
            TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')), -- pbtime
            0, -- mcperc
            0, -- WASTEPERC Added by Anna Every 04/07/2007 for new release
            0 -- CONTRCOMM Added by Anna Every 04/07/2007 for new release
            );

       end if;

       tbl_work.delete;

    end if;

    v_sav_distbn_chnl_code := rv_pricelist.distbn_chnl_code;
    v_sav_matl_code := v_matl_code;

    tbl_work(tbl_work.count+1).cmpny_code := rv_pricelist.cmpny_code;
    tbl_work(tbl_work.count).div_code := rv_pricelist.div_code;
    tbl_work(tbl_work.count).distbn_chnl_code := rv_pricelist.distbn_chnl_code;
    tbl_work(tbl_work.count).matl_code := rv_pricelist.matl_code;
    tbl_work(tbl_work.count).eff_date := rv_pricelist.eff_date;
    tbl_work(tbl_work.count).list_price := rv_pricelist.list_price;
    tbl_work(tbl_work.count).mfg_cost := rv_pricelist.mfg_cost;
    tbl_work(tbl_work.count).rrp := rv_pricelist.rrp;
    tbl_work(tbl_work.count).pmx_matl_code := rv_pricelist.pmx_matl_code;

    -- Update PDS_PRICE_LIST to set procg_status = COMPLETED.
    UPDATE PDS_PRICE_LIST
      SET procg_status = pc_procg_status_completed
    WHERE
      cmpny_code = i_pmx_cmpny_code
      AND div_code = i_pmx_div_code
      AND matl_code = rv_pricelist.matl_code
      AND eff_date = rv_pricelist.eff_date
      AND distbn_chnl_code = rv_pricelist.distbn_chnl_code
      AND valdtn_status = pc_valdtn_status_valid
      AND procg_status = pc_procg_status_processed;

  END LOOP;
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level + 2, 'End of loop.');

  -- Close csr_pricelist cursor.
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level + 2, 'Close csr_pricelist cursor.');
  CLOSE csr_pricelist;

  if not(v_sav_distbn_chnl_code is null) then

     v_price1 := 0;
     v_price1date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
     v_price2 := 0;
     v_price2date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
     v_price3 := 0;
     v_price3date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
     v_price1data := false;

     for idx in 1..tbl_work.count loop

        IF tbl_work(idx).eff_date IS NULL THEN
          v_eff_date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
        ELSE
          v_eff_date := TO_DATE(tbl_work(idx).eff_date,'YYYYMMDD');
        END IF;

        if idx = 1 then
           v_price1 := tbl_work(idx).list_price;
           v_price1date := v_eff_date;
           if trunc(v_eff_date) > trunc(sysdate) then
              v_price1data := true;
              v_price1 := 0.01;
              v_price1date := TO_DATE(pc_pricelist_default_date,'DDMMYYYY');
              v_price2 := tbl_work(idx).list_price;
              v_price2date := v_eff_date;
           end if;
           IF tbl_work(idx).mfg_cost IS NULL OR tbl_work(idx).mfg_cost = 0 THEN
              v_mfg_cost := tbl_work(idx).list_price * pc_pricelist_mfg_cost_val;
           ELSE
              v_mfg_cost := tbl_work(idx).mfg_cost;
           END IF;
           v_rrprice := tbl_work(idx).rrp;
        end if;
        if idx = 2 then
           if v_price1data = false then
              v_price2 := tbl_work(idx).list_price;
              v_price2date := v_eff_date;
           else
              v_price3 := tbl_work(idx).list_price;
              v_price3date := v_eff_date;
           end if;
        end if;
        if idx = 3 then
           if v_price1data = false then
              v_price3 := tbl_work(idx).list_price;
              v_price3date := v_eff_date;
           end if;
        end if;

     end loop;

     -- Insert into Postbox PBPRICES table.
     INSERT INTO pbprices
       (
       cocode,
       divcode,
       prodcode,
       price1,
       price1date,
       price2,
       price2date,
       price3,
       price3date,
       stdcost,
       list,
       rrprice,
       pbdate,
       pbtime,
       mcperc,
       WASTEPERC,
       CONTRCOMM
       )
     VALUES
       (
       i_pmx_cmpny_code,
       i_pmx_div_code,
       v_sav_matl_code,
       v_price1,
       v_price1date,
       v_price2,
       v_price2date,
       v_price3,
       v_price3date,
       v_mfg_cost,
       NVL(v_sav_distbn_chnl_code,0),
       v_rrprice,
       SYSDATE, -- pbdate
       TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')), -- pbtime
       0, -- mcperc
       0, -- WASTEPERC Added by Anna Every 04/07/2007 for new release
       0 -- CONTRCOMM Added by Anna Every 04/07/2007 for new release
       );

  end if;

  -- Commit Delete of PBPRICES and insert of new data into PBPRICES table.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'Commit delete and insert of PBPRICES table.');
  COMMIT;

  -- Update Postbox PBPRICES table.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'Update Postbox PBPRICES table.');
  UPDATE pbprices t1
    SET t1.rrprice = (SELECT (((t1.price1 / t2.numberup) * pc_pricelist_rsu_pct) * pc_pricelist_gst_pct) -- Numberup = Items per case.
                     FROM products t2
                     WHERE  t2.cocode  = i_pmx_cmpny_code
                       AND  t2.divcode = i_pmx_div_code
                       AND  t2.prodcode= t1.prodcode)
  WHERE cocode  = i_pmx_cmpny_code
  AND divcode = i_pmx_div_code;

  -- Commit changes to PBPRICES tables.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'Commiting changes to PBPRICES table.');
  COMMIT;

  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,'transfer_pricelist_postbox - END.');

EXCEPTION
  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_PRICELIST_01_PRC.TRANSFER_PRICELIST_POSTBOX:',
        pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,
        'Promax Division Code',i_pmx_div_code);
    write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_prc,'MFANZ Promax Pricelist Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pricelist_01_prc,'N/A');
    END IF;

  WHEN e_processing_error THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_PRICELIST_01_PRC.TRANSFER_PRICELIST_POSTBOX:',
        pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,
        'Promax Division Code',i_pmx_div_code);
    write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_prc,'MFANZ Promax Pricelist Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pricelist_01_prc,'N/A');
    END IF;

  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_PRICELIST_01_PRC.TRANSFER_PRICELIST_POSTBOX:',
      'Unexpected Exception - validate_pricelist_atlas aborted.') ||
      utils.create_params_str('Promax Company Code',i_pmx_cmpny_code,
        'Promax Division Code',i_pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_prc,'MFANZ Promax Pricelist Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pricelist_01_prc,'N/A');
    END IF;

END transfer_pricelist_postbox;


PROCEDURE initiate_postbox_pricelist IS

  -- VARIABLE DECLARATIONS
  v_count NUMBER; -- Generic counter.

  -- EXCEPTION DECLARATIONS
  e_processing_failure EXCEPTION;

BEGIN

  -- Start initiate_postbox_pricelist procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,'initiate_postbox_pricelist - START.');

  -- Do not initiate the Price List Postbox job if any PRICELIST_LOAD_01 job control
  -- records exist with a status other than COMPLETED.
  SELECT count(*) INTO v_count
  FROM
    pds_pmx_job_cntl
  WHERE
    pmx_job_cnfgn_id in (pc_pstbx_pricelist_load_01)
    AND job_status <> pc_job_status_completed;

  IF v_count > 0 THEN -- There is a PRICELIST_LOAD_01 Postbox job running.
    pv_processing_msg := ('ERROR: Price List Postbox job cannot be started. ' ||
      'PRICELIST_LOAD_01 Job Control records exist status <> COMPLETED.'||
      'This indicates that there is an in progress job and/or failed job(s).');
    RAISE e_processing_failure;
  ELSE
    write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,'Initiating Price List Postbox job by creating PRICELIST_LOAD_01 Job Control record.');
    pds_utils.create_promax_job_control(pc_pstbx_pricelist_load_01);
  END IF;

  -- End initiate_postbox_pricelist procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,'initiate_postbox_pricelist - END.');

EXCEPTION

  WHEN e_processing_failure THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_PRICELIST_01_PRC.INITIATE_POSTBOX_PRICELIST:',pv_processing_msg) ||
      utils.create_params_str();
    write_log(pc_data_type_pricelist,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_prc,'MFANZ Promax Pricelist Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pricelist_01_prc,'N/A');
    END IF;

  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_PRICELIST_01_PRC.INITIATE_POSTBOX_PRICELIST:',
        'Unexpected Exception - initiate_postbox_pricelist aborted.') ||
        utils.create_params_str() ||
        utils.create_sql_err_msg();
    write_log(pc_data_type_pricelist,'N/A',pv_log_level + 2,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_prc,'MFANZ Promax Pricelist Process 01',
      pv_result_msg);
    IF pc_debug != 'TRUE' THEN
      -- Send alert message via Tivoli if running in production.
      pds_utils.send_tivoli_alert(pc_alert_level_minor,pv_result_msg,
        pc_job_type_pricelist_01_prc,'N/A');
    END IF;

END initiate_postbox_pricelist;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table.
  pds_utils.log (pc_job_type_pricelist_01_prc,
    i_data_type,
    i_sort_field,
    i_log_level,
    i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;

END pds_pricelist_01_prc;
/
