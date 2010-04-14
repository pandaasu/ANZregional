CREATE OR REPLACE PACKAGE pmx_cdw_ref_prc IS

/*********************************************************************************
  NAME:      run_pmx_cdw_ref_prc
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
  1.0   05/02/2007 Cynthia Ennis        Created this procedure.
  1.1   03/06/2009 Anna Every           Changed call to lics_outbound_loader

********************************************************************************/
PROCEDURE run_pmx_cdw_ref_prc;

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

END pmx_cdw_ref_prc;
/


CREATE OR REPLACE PACKAGE BODY pmx_cdw_ref_prc IS

  -- PACKAGE COLLECTION TYPE DECLARATIONS
  TYPE tbl_reference IS TABLE OF VARCHAR2(220)
  INDEX BY BINARY_INTEGER;

  -- PACKAGE VARIABLE DECLARATIONS
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_job_type_pmx_cdw_ref_prc CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pmx_cdw_ref_prc', 'JOB_TYPE');
  pc_data_type_reference      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('ref', 'DATA_TYPE');
  pc_debug                    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag', 'DEBUG_FLAG');
  pc_alert_level_critical     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_critical', 'ALERT');
  pc_alert_level_minor        CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor', 'ALERT');
  pc_interface_reference      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('reference_cdw', 'INTERFACE');

  PROCEDURE get_acctmgr(
    i_rcd_data IN OUT tbl_reference) IS

    -- VARIABLE DECLARATIONS
    v_index BINARY_INTEGER := 0;

    -- Account Manager cursor
    CURSOR csr_acctmgr IS
      SELECT 
        pd.cmpny_code,
        pd.div_code,
        notactive,
        accmgrkey,
        mgrcode,
        desctext
      FROM 
        promax.accman a,
        pds_div pd
      WHERE a.cocode = pd.pmx_cmpny_code AND
        a.divcode = pd.pmx_div_code;
    rv_acctmgr csr_acctmgr%ROWTYPE;

  BEGIN
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Looping through csr_acctmgr cursor.');
    FOR rv_acctmgr IN csr_acctmgr
    LOOP
      v_index := NVL(i_rcd_data.LAST + 1, 1);
      i_rcd_data(v_index) :=
           'ACCTMGR   '
        || rv_acctmgr.cmpny_code   -- Company Code
        || rv_acctmgr.div_code   -- Division Code   
        || RPAD(rv_acctmgr.accmgrkey, 38)   -- Account Manager Key
        || RPAD(rv_acctmgr.mgrcode, 8)   -- Account Manger Code
        || RPAD(rv_acctmgr.desctext, 30)   -- Account Manager Description
        || rv_acctmgr.notactive; -- Not Active Flag
    END LOOP;
  END get_acctmgr;

  PROCEDURE get_claimtype(
    i_rcd_data IN OUT tbl_reference) IS

    -- VARIABLE DECLARATIONS
    v_index BINARY_INTEGER := 0;

    -- Claim Type cursor
    CURSOR csr_claimtype IS
      SELECT 
        claimtype,
        text12
      FROM 
        promax.claimtype;
    rv_claimtype csr_claimtype%ROWTYPE;

  BEGIN
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Looping through csr_claimtype cursor.');
    FOR rv_claimtype IN csr_claimtype
    LOOP
      v_index := NVL(i_rcd_data.LAST, 0) + 1;
      i_rcd_data(v_index) :=
                           'CLAIMTYPE ' || RPAD(rv_claimtype.claimtype, 2)   -- Claim Code                                              .
                           || RPAD(rv_claimtype.text12, 12);   -- Claim Description
    END LOOP;
  END get_claimtype;

  PROCEDURE get_fundtype(
    i_rcd_data IN OUT tbl_reference) IS

    -- VARIABLE DECLARATIONS
    v_index BINARY_INTEGER := 0;

    -- Fund Type cursor
    CURSOR csr_fundtype IS
      SELECT 
        pd.cmpny_code,
        pd.div_code,
        fdkey,
        fdcode,
        text12,
        text30,
        fdcustcode,
        offinv
      FROM 
        promax.funddesc f,
        pds_div pd
      WHERE f.cocode = pd.pmx_cmpny_code AND
        f.divcode = pd.pmx_div_code;
    rv_fundtype csr_fundtype%ROWTYPE;

  BEGIN
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Looping through csr_fundtype cursor.');
    FOR rv_fundtype IN csr_fundtype
    LOOP
      v_index := NVL(i_rcd_data.LAST, 0) + 1;
      i_rcd_data(v_index) :=
           'FUNDTYPE  '
        || rv_fundtype.cmpny_code   -- Company Code
        || rv_fundtype.div_code   -- Division Code
        || RPAD(rv_fundtype.fdkey, 38)   -- Funding Type Key
        || RPAD(rv_fundtype.fdcode, 3)   -- Funding Type Code
        || RPAD(rv_fundtype.text12, 12)   -- Funding Type Description
        || RPAD(rv_fundtype.text30, 30)   -- Funding Type Extended Description
        || RPAD(rv_fundtype.fdcustcode, 2)   -- Mars funding code
        || RPAD(rv_fundtype.offinv, 1);   -- Off Invoice Flag
    END LOOP;
  END get_fundtype;

  PROCEDURE get_promattrb(
    i_rcd_data IN OUT tbl_reference) IS

    -- VARIABLE DECLARATIONS
    v_index BINARY_INTEGER := 0;

    -- Promotion Attribute cursor
    CURSOR csr_promattrb IS
      SELECT 
        pd.cmpny_code,
        pd.div_code,
        attrkey,
        attrcode,
        text20
      FROM 
        promax.promatrb pa,
        pds_div pd
      WHERE pa.cocode = pd.pmx_cmpny_code AND
        pa.divcode = pd.pmx_div_code;
    rv_promattrb csr_promattrb%ROWTYPE;

  BEGIN
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Looping through csr_promattrb cursor.');
    FOR rv_promattrb IN csr_promattrb
    LOOP
      v_index := NVL(i_rcd_data.LAST, 0) + 1;
      i_rcd_data(v_index) :=
           'PROMATTRB '
        || rv_promattrb.cmpny_code   -- Company Code
        || rv_promattrb.div_code   -- Division Code
        || RPAD(rv_promattrb.attrkey, 38)   -- Promotion Attribute Key
        || RPAD(rv_promattrb.attrcode, 8)   -- Promotion Attribute Code
        || RPAD(rv_promattrb.text20, 20);   -- Promotion Attribute Description
    END LOOP;
  END get_promattrb;

  PROCEDURE get_promstatus(
    i_rcd_data IN OUT tbl_reference) IS

    -- VARIABLE DECLARATIONS
    v_index BINARY_INTEGER := 0;

    -- Promotion Status cursor
    CURSOR csr_promstatus IS
      SELECT 
        pstatcode,
        desctext
      FROM 
        promax.promstat;
    rv_promstatus csr_promstatus%ROWTYPE;

  BEGIN
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Looping through csr_promstatus cursor.');
    FOR rv_promstatus IN csr_promstatus
    LOOP
      v_index := NVL(i_rcd_data.LAST, 0) + 1;
      i_rcd_data(v_index) :=
           'PROMSTATUS'
        || RPAD(rv_promstatus.pstatcode, 2)   -- Promotion Status Code                                                                                         .
        || RPAD(rv_promstatus.desctext, 30);   -- Promotion Status Description
    END LOOP;
  END get_promstatus;

  PROCEDURE get_promtype(
    i_rcd_data IN OUT tbl_reference) IS

    -- VARIABLE DECLARATIONS
    v_index BINARY_INTEGER := 0;

    -- Promotion Type cursor
    CURSOR csr_promtype IS
      SELECT 
        pd.cmpny_code,
        pd.div_code,
        ptypekey,
        ptypecode,
        ptype,
        ptclass
      FROM 
        promax.promtype pt,
        pds_div pd
      WHERE pt.cocode = pd.pmx_cmpny_code AND
        pt.divcode = pd.pmx_div_code;
    rv_promtype csr_promtype%ROWTYPE;

  BEGIN
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Looping through csr_promtype cursor.');
    FOR rv_promtype IN csr_promtype
    LOOP
      v_index := NVL(i_rcd_data.LAST, 0) + 1;
      i_rcd_data(v_index) :=
           'PROMTYPE  '
        || rv_promtype.cmpny_code   -- Company Code
        || rv_promtype.div_code   -- Division Code
        || RPAD(rv_promtype.ptypekey, 38)   -- Promotion Type Key
        || RPAD(rv_promtype.ptypecode, 2)   -- Promotion Type Code
        || RPAD(rv_promtype.ptype, 15)   -- Promotion Type Description
        || RPAD(rv_promtype.ptclass, 2); -- Promotion Type Class
    END LOOP;
  END get_promtype;

  PROCEDURE interface_reference_data_cdw IS

    -- COLLECTION DECLARATIONS
    rcd_reference tbl_reference;

    -- VARIABLE  DECLARATIONS
    v_instance         VARCHAR2(8) := '0';
    v_item_count       BINARY_INTEGER := 0;
    v_ctl              VARCHAR2(4000);
    v_start_date       DATE := SYSDATE;
    v_total_item_count BINARY_INTEGER := 0;

    -- EXCEPTION DECLARATIONS
    e_processing_failure EXCEPTION;
    e_processing_error   EXCEPTION;

  BEGIN
    -- Start interface_reference_cdw procedure.
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'interface_reference_cdw - START (' || TO_CHAR(v_start_date, 'YYYYMMDD HH24MISS') || ').');

    -- Count the number of records.
    SELECT SUM(element_count) record_count
    INTO v_total_item_count
    FROM (SELECT COUNT(*) element_count
          FROM promax.accman a,
            pds_div pd
          WHERE a.cocode = pd.pmx_cmpny_code AND
            a.divcode = pd.pmx_div_code
          UNION
          SELECT COUNT(*) element_count
          FROM promax.claimtype
          UNION
          SELECT COUNT(*) element_count
          FROM promax.funddesc f,
            pds_div pd
          WHERE f.cocode = pd.pmx_cmpny_code AND
            f.divcode = pd.pmx_div_code
          UNION
          SELECT COUNT(*) element_count
          FROM promax.promatrb pa,
            pds_div pd
          WHERE pa.cocode = pd.pmx_cmpny_code AND
            pa.divcode = pd.pmx_div_code
          UNION
          SELECT COUNT(*) element_count
          FROM promax.promstat
          UNION
          SELECT COUNT(*) element_count
          FROM promax.promtype pt,
            pds_div pd
          WHERE pt.cocode = pd.pmx_cmpny_code AND
            pt.divcode = pd.pmx_div_code);

    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Total number of Reference data records to be processed: ' || v_total_item_count || '.');
    IF v_total_item_count = 0
    THEN
      RETURN;   -- Do not create empty files.
    END IF;

    -- Read through each of the reference data element types to be interfaced.
    get_acctmgr(rcd_reference);   -- Account Manager
    get_claimtype(rcd_reference);   -- Claim Type
    get_fundtype(rcd_reference);   -- Funding Type
    get_promattrb(rcd_reference);   -- Promotion Attribute
    get_promstatus(rcd_reference);   -- Promotion Status
    get_promtype(rcd_reference);   -- Promotion Type

    -- Creation of the extract file.
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 3, 'Create the reference data file.');
--    v_instance := lics_outbound_loader.create_interface(pc_interface_reference);
    v_instance  := lics_outbound_loader.create_interface(pc_interface_reference, null, pc_interface_reference||'.DAT');


    -- Writing Reference Data Control record.
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 3, 'Processing Reference Data Control record.');
    v_ctl  := 'CTL' || RPAD('PMXODS01', 30) || LPAD(v_instance, 16, '0') || LPAD(v_item_count, 16, '0') || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    lics_outbound_loader.append_data( v_ctl );

    -- Write Reference Data records to the file.
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 3, 'Write Reference Data records to the file.');
    FOR i IN rcd_reference.FIRST .. rcd_reference.LAST
    LOOP
      lics_outbound_loader.append_data(rcd_reference(i));
    END LOOP;

    -- Finalise the interface.
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 3, 'Finalising ICS interface file.');
    lics_outbound_loader.finalise_interface;
    COMMIT;

    -- Log summary details.
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'Total number of reference records processed: ' || rcd_reference.LAST || '.');
    write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, 'interface_reference_cdw - END.');
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
           utils.create_failure_msg('pmx_cdw_ref_prc.INTERFACE_REFERENCE_CDW:', 'EXCEPTION: ROLLBACK, check LICS and finalise if required and exit.')
        || utils.create_sql_err_msg();
      write_log(pc_data_type_reference, 'N/A', pv_log_level + 2, pv_result_msg);

      pds_utils.send_email_to_group(pc_job_type_pmx_cdw_ref_prc, 'MFANZ Promax Reference Process', pv_result_msg);
      IF pc_debug != 'TRUE' THEN
        -- Send alert message via Tivoli if running in production.
        pds_utils.send_tivoli_alert(pc_alert_level_minor, pv_result_msg, pc_job_type_pmx_cdw_ref_prc, 'N/A');
      END IF;
  END interface_reference_data_cdw;

  PROCEDURE run_pmx_cdw_ref_prc IS

  BEGIN
    write_log(pc_data_type_reference, 'N/A', pv_log_level, 'run_pmx_cdw_ref_prc - START.');
    -- Execute the reference data Interface procedure for all CDW company / divisions.
    interface_reference_data_cdw();
    
     -- Trigger the pmx_cdw_cust_int procedure.
    write_log (pc_data_type_reference, 'N/A', pv_log_level, 'Trigger the PMX_CDW_CUST_INT procedure.');
    lics_trigger_loader.EXECUTE ('MFANZ Promax Customer Data to CDW Interface',
                                 'pds_app.pmx_cdw_cust_int.run_pmx_cdw_cust_int',
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_ALERT', 'PMX_CDW_CUST_INT'),
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_EMAIL_GROUP', 'PMX_CDW_CUST_INT'),
                                 lics_setting_configuration.retrieve_setting ('LICS_TRIGGER_GROUP', 'PMX_CDW_CUST_INT')
                                );
    write_log(pc_data_type_reference, 'N/A', pv_log_level, 'run_pmx_cdw_ref_prc - END.');
  EXCEPTION
    -- Send warning message via e-mail and pds_log.
    WHEN OTHERS THEN
      pv_result_msg  :=
           utils.create_failure_msg('RUN_pmx_cdw_ref_prc.RUN_RUN_pmx_cdw_ref_prc:', 'Unexpected Exception - run_pmx_cdw_ref_prc aborted.')
        || utils.create_params_str()
        || utils.create_sql_err_msg();
      write_log(pc_data_type_reference, 'N/A', pv_log_level, pv_result_msg);

      pds_utils.send_email_to_group(pc_job_type_pmx_cdw_ref_prc, 'MFANZ Promax Reference Data to CDW Process', pv_result_msg);
      IF pc_debug != 'TRUE' THEN
        -- Send alert message via Tivoli if running in production.
        pds_utils.send_tivoli_alert(pc_alert_level_critical, pv_result_msg, pc_job_type_pmx_cdw_ref_prc, 'N/A');
      END IF;
  END run_pmx_cdw_ref_prc;

  PROCEDURE write_log(
    i_data_type IN pds_log.data_type%TYPE,
    i_sort_field IN pds_log.sort_field%TYPE,
    i_log_level IN pds_log.log_level%TYPE,
    i_log_text IN pds_log.log_text%TYPE) IS

  BEGIN
    -- Write the entry into the PDS_LOG table.
    pds_utils.LOG(pc_job_type_pmx_cdw_ref_prc, i_data_type, i_sort_field, i_log_level, i_log_text);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END write_log;

END pmx_cdw_ref_prc;
/
