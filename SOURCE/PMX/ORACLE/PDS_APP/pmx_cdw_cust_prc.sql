CREATE OR REPLACE PACKAGE pmx_cdw_cust_prc IS

/*********************************************************************************
  NAME:      run_pmx_cdw_cust_prc
  PURPOSE:   Initiates flat file interface to CDW.

             The interface is triggered by a pipe message from PDS_CONTROLLER,
             the daemon which manages the Oracle side of the Promax Job Control
             tables.

             NOTE: v_debug is a debugging constant, defined at the package level.
             If FALSE (ie. we're running in production) then send Alerts, else sends
             emails.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   30/01/2007 Cynthia Ennis        Created this procedure.
  1.1   03/06/2009 Anna Every           Changed call to lics_outbound_loader

********************************************************************************/
PROCEDURE run_pmx_cdw_cust_prc;

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

END pmx_cdw_cust_prc;
/


CREATE OR REPLACE PACKAGE BODY         pmx_cdw_cust_prc IS

  -- PACKAGE VARIABLE DECLARATIONS
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_job_type_pmx_cdw_cust_prc  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pmx_cdw_cust_prc', 'JOB_TYPE');
  pc_data_type_customer         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust', 'DATA_TYPE');
  pc_debug                      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag', 'DEBUG_FLAG');
  pc_alert_level_critical       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_critical', 'ALERT');
  pc_alert_level_minor          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor', 'ALERT');
  pc_interface_customer         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('customer_cdw', 'INTERFACE');
  pc_pmx_cmpny_code_australia   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia', 'PMX_CMPNY_CODE');
  pc_pmx_cmpny_code_new_zealand CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('new_zealand', 'PMX_CMPNY_CODE');
  pc_div_code_snack             CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('snack', 'DIV_CODE');
  pc_div_code_food              CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('food', 'DIV_CODE');
  pc_div_code_pet               CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pet', 'DIV_CODE');
  pc_max_array_rows_in_memory   CONSTANT BINARY_INTEGER                 := 5000;

  PROCEDURE update_control(
    i_pmx_cmpny_code pds_constants.const_value%TYPE,
    i_pmx_div_code pds_constants.const_value%TYPE,
    i_start DATE) IS

  BEGIN
    -- Update control table.
    UPDATE pds_cntl
    SET cntl_value = TO_CHAR(i_start, 'YYYYMMDD HH24MISS')
    WHERE cntl_code = 'PREV_CUST_EXTRACT'
      AND cmpny_code = i_pmx_cmpny_code
      AND div_code = i_pmx_div_code;
  END;




PROCEDURE validate_customer IS

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

END validate_customer;


PROCEDURE validate_customer_cdw(
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

END validate_customer_cdw;







  PROCEDURE interface_customer_cdw(
    i_pmx_cmpny_code VARCHAR2,
    i_pmx_div_code VARCHAR2) IS

    -- COLLECTION TYPE DECLARATIONS
    TYPE tbl_customer IS TABLE OF VARCHAR2(220)
      INDEX BY BINARY_INTEGER;
    rcd_customer tbl_customer;

    -- VARIABLE DECLARATIONS
    v_ctl              VARCHAR2(4000);
    v_instance         VARCHAR2(8) := '0';
    v_item_count       BINARY_INTEGER := 0;
    v_prev_start       pds_cntl.cntl_value%TYPE;
    v_prev_start_date  DATE;
    v_start_date       DATE;
    v_total_item_count BINARY_INTEGER := 0;
    v_sap_cust_code    VARCHAR2(10); -- Customer code to send back to SAP.

    -- EXCEPTION DECLARATIONS
    e_processing_failure   EXCEPTION;
    e_processing_error     EXCEPTION;

    -- Customer cursor.
    CURSOR csr_customer IS
      SELECT
        pd.cmpny_code,
        pd.div_code,
        cocode,
        divcode,
        kacc,
        chain,
        promoted,
        accmgrkey
      FROM
        promax.chain c,
        pds_div pd
      WHERE c.cocode = pd.pmx_cmpny_code
        AND c.divcode = pd.pmx_div_code
        AND cocode = i_pmx_cmpny_code
        AND divcode = i_pmx_div_code
        AND recchg > v_prev_start_date;
      rv_customer csr_customer%ROWTYPE;

    PROCEDURE release_data_from_array(rcd_customer IN OUT tbl_customer) IS
    BEGIN
      rcd_customer.DELETE(rcd_customer.FIRST, rcd_customer.LAST);   -- Release memory.
    END;

    PROCEDURE append_data_to_lics(rcd_customer IN tbl_customer) IS
    BEGIN
      FOR i IN rcd_customer.FIRST .. rcd_customer.LAST
      LOOP
        lics_outbound_loader.append_data(rcd_customer(i));
      END LOOP;
    END;

  BEGIN
    -- Start interface_customer_cdw procedure.
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 2, 'interface_customer_cdw - START (' || i_pmx_cmpny_code || ',' || i_pmx_div_code || ').');

    -- Determine date boundarys.
    pv_status         := pds_lookup.lookup_cntl_code(i_pmx_cmpny_code, i_pmx_div_code, 'PREV_CUST_EXTRACT', v_prev_start, pv_log_level, pv_result_msg);
    v_prev_start_date := TO_DATE(v_prev_start, 'YYYYMMDD HH24MISS');
    v_start_date      := SYSDATE;

    -- Count the number of records.
    SELECT COUNT(*)
    INTO v_total_item_count
    FROM promax.chain
    WHERE cocode = i_pmx_cmpny_code
      AND divcode = i_pmx_div_code
      AND recchg > v_prev_start_date;

    write_log(pc_data_type_customer, 'N/A', pv_log_level + 2, 'Total number of Customer records to be processed: ' || v_total_item_count || '.');
    IF v_total_item_count = 0
    THEN
      RETURN;   -- Do not create empty files.
    END IF;

    -- Creation of the extract file.
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 3, 'Create the customer file.');
    --v_instance := lics_outbound_loader.create_interface(pc_interface_customer);
    v_instance  := lics_outbound_loader.create_interface(pc_interface_customer, null, pc_interface_customer||'.DAT');

    -- Writing Customer Control record.
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 3, 'Processing Customer Control record.');
    v_ctl := 'CTL' || RPAD('PMXODS02 Promax Customer', 30) || LPAD(v_instance, 16, '0') || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    lics_outbound_loader.append_data(v_ctl);

    -- Read through each of the customer records to be interfaced
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 2, 'Looping through csr_customer cursor.');
    FOR rv_customer IN csr_customer
    LOOP

---------------------------
---- DO VALIDATION
---- if fail then wrote error and bypass
---- always send what is currently valid
---------------------------

      v_item_count := v_item_count + 1;
      -- Now perform the output Customer Code conversion.
      -- Customer codes have leading zeroes if they are numeric, otherwise the
      -- field is left justified with spaces padding (on the right). The width returned
      -- is 10 characters, req'd format for SAP (i.e. export).
      pv_status := pds_common.format_cust_code(rv_customer.kacc, v_sap_cust_code, pv_log_level + 3, pv_result_msg);

      rcd_customer(v_item_count) :=
           'DTL'
        || rv_customer.cmpny_code   -- Company Code
        || rv_customer.div_code   -- Division Code
        || RPAD(rv_customer.chain, 30)   -- Name
        || LPAD(v_sap_cust_code, 10, '0')   -- Customer Code
        || rv_customer.promoted   -- Promoted Flag
        || RPAD(rv_customer.accmgrkey, 30);   -- Account Manager Key

      -- Avoid using excessive amounts of memory for the array by flushing to file regularly,
      -- releasing the memory as we go.
      IF v_item_count MOD pc_max_array_rows_in_memory = 0 THEN
        -- Write Accruals records to the file.
        write_log(pc_data_type_customer, 'N/A', pv_log_level + 4, 'Write Customer records to the file.');
        append_data_to_lics(rcd_customer);
        release_data_from_array(rcd_customer);
      END IF;
    END LOOP;

    -- Flush remaining records to file.
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 3, 'Write remaining Customer records to the file.');
    append_data_to_lics(rcd_customer);
    release_data_from_array(rcd_customer);

    -- Finalise the interface.
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 3, 'Finalising ICS interface file.');
    lics_outbound_loader.finalise_interface;

    -- Save start date to control table.
    update_control(i_pmx_cmpny_code, i_pmx_div_code, v_start_date);
    COMMIT;

    -- Log summary details.
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 2, 'Total number of customer records processed: ' || v_item_count || '.');
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 2, 'interface_customer_cdw - END.');
  EXCEPTION
    -- Send warning message via E-mail and pds_log.
    -- Exception trap: when any exceptions occur the IS_CREATED method should be tested.
    -- if IS_CREATED return true then the exception should be added to the interface for
    -- logging purposes and the interface finalised.
    WHEN OTHERS THEN
      ROLLBACK;
      IF lics_outbound_loader.is_created = TRUE THEN
        lics_outbound_loader.add_exception(SUBSTR(SQLERRM, 1, 1024));
        lics_outbound_loader.finalise_interface;
      END IF;
      pv_result_msg  :=
           utils.create_failure_msg('PMX_CDW_CUST_PRC.INTERFACE_CUSTOMER_CDW:', 'EXCEPTION: ROLLBACK, check LICS and finalise if required and exit.')
        || utils.create_params_str('Promax Company Code', i_pmx_cmpny_code, 'Promax Division Code', i_pmx_div_code)
        || utils.create_sql_err_msg();
      write_log(pc_data_type_customer, 'N/A', pv_log_level + 2, pv_result_msg);
      pds_utils.send_email_to_group(pc_job_type_pmx_cdw_cust_prc, 'MFANZ Promax Customer Process', pv_result_msg);

      IF pc_debug != 'TRUE' THEN
        -- Send alert message via Tivoli if running in production.
        pds_utils.send_tivoli_alert(pc_alert_level_minor, pv_result_msg, pc_job_type_pmx_cdw_cust_prc, 'N/A');
      END IF;
  END interface_customer_cdw;

  PROCEDURE interface_customer IS
  BEGIN
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 1, 'interface_customer - START.');
    -- Execute the customer Interface procedure for each CDW company / division.
    -- Australia Snack
    interface_customer_cdw(pc_pmx_cmpny_code_australia, pc_div_code_snack);
    -- Australia Food
    interface_customer_cdw(pc_pmx_cmpny_code_australia, pc_div_code_food);
    -- Australia Petcare
    interface_customer_cdw(pc_pmx_cmpny_code_australia, pc_div_code_pet);
    -- New Zealand Snack
    interface_customer_cdw(pc_pmx_cmpny_code_new_zealand, pc_div_code_snack);
    --  New Zealand Food
    interface_customer_cdw(pc_pmx_cmpny_code_new_zealand, pc_div_code_food);
    -- New Zealand Pet.
    interface_customer_cdw(pc_pmx_cmpny_code_new_zealand, pc_div_code_pet);
    write_log(pc_data_type_customer, 'N/A', pv_log_level + 1, 'interface_customer - END.');
  END interface_customer;

  PROCEDURE run_pmx_cdw_cust_prc IS
  BEGIN
    write_log(pc_data_type_customer, 'N/A', pv_log_level, 'run_pmx_cdw_cust_prc - START.');
    interface_customer();

    -- Trigger the pmx_pds_prom_int procedure.
    write_log (pc_data_type_customer, 'N/A', pv_log_level, 'Trigger the PMX_PDS_PROM_INT procedure.');
    lics_trigger_loader.EXECUTE ('MFANZ Promax Promotion Data to PDS Interface',
                                 'pds_app.pmx_pds_prom_int.run_pmx_pds_prom_int',
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_ALERT', 'PMX_PDS_PROM_INT'),
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_EMAIL_GROUP', 'PMX_PDS_PROM_INT'),
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_GROUP', 'PMX_PDS_PROM_INT')
                                );

    write_log(pc_data_type_customer, 'N/A', pv_log_level, 'run_pmx_cdw_cust_prc - END.');

  EXCEPTION
    -- Send warning message via e-mail and pds_log.
    WHEN OTHERS THEN
      pv_result_msg  :=
           utils.create_failure_msg('RUN_PMX_CDW_CUST_PRC.RUN_RUN_PMX_CDW_CUST_PRC:', 'Unexpected Exception - run_run_pmx_cdw_cust_prc aborted.')
        || utils.create_params_str()
        || utils.create_sql_err_msg();
      write_log(pc_data_type_customer, 'N/A', pv_log_level, pv_result_msg);
      pds_utils.send_email_to_group(pc_job_type_pmx_cdw_cust_prc, 'MFANZ Promax Customer to CDW Process', pv_result_msg);

      IF pc_debug != 'TRUE' THEN
        -- Send alert message via Tivoli if running in production.
        pds_utils.send_tivoli_alert(pc_alert_level_critical, pv_result_msg, pc_job_type_pmx_cdw_cust_prc, 'N/A');
      END IF;
  END run_pmx_cdw_cust_prc;

  PROCEDURE write_log(
    i_data_type IN pds_log.data_type%TYPE,
    i_sort_field IN pds_log.sort_field%TYPE,
    i_log_level IN pds_log.log_level%TYPE,
    i_log_text IN pds_log.log_text%TYPE) IS
  BEGIN
    -- Write the entry into the PDS_LOG table.
    pds_utils.LOG(pc_job_type_pmx_cdw_cust_prc, i_data_type, i_sort_field, i_log_level, i_log_text);
  EXCEPTION
    WHEN OTHERS
    THEN
      NULL;
  END write_log;

END pmx_cdw_cust_prc;
/
