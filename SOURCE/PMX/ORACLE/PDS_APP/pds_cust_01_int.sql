CREATE OR REPLACE PACKAGE pds_cust_01_int IS

/*******************************************************************************
  NAME:      run_pds_cust_01_int
  PURPOSE:   This procedure retrieves customer data from LADS and loads into the
             pds_cust_hier_load table. The procedure is scheduled as an ICS job, which runs
             daily.  This procedure then calls the pds_cust_01_prc procedure
             which validates the loaded customer data.  Valid data is then loaded
             into the Promax Postbox table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   10/08/2005 Ann-Marie Ingeme     Created this procedure.
  1.1   14/03/2006 Craig Ford           Add processing to identify new Customers.
                                         Delete from new (temp) customer table in
					 preparation for reloading with new customers.
  2.0   06/08/2009 Steve Gregan         Added create log.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_cust_01_int;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the pds_log table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   07/08/2005 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Data Type                            Customer
  2    IN     VARCHAR2 Sort Field                           Customer Code
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

END pds_cust_01_int;
/


CREATE OR REPLACE PACKAGE BODY         pds_cust_01_int IS

  -- PACKAGE VARIABLE DESCLARATION
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_cmpny_code_australia    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('australia','CMPNY_CODE');
  pc_job_type_cust_01_int    CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_01_int','JOB_TYPE');
  pc_data_type_cust          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust','DATA_TYPE');
  pc_debug                   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_minor       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_procg_status_loaded     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('loaded','PROCG_STATUS');
  pc_valdtn_status_unchecked CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unchecked','VALDTN_STATUS');

PROCEDURE run_pds_cust_01_int IS

  -- VARIABLE DECLARATIONS
  v_cmpny_code     pds_div.cmpny_code%TYPE;
  v_pmx_cmpny_code pds_div.pmx_cmpny_code%TYPE;
  v_div_code       pds_div.div_code%TYPE;
  v_pmx_div_code   pds_div.pmx_div_code%TYPE;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Select all Atlas Company Codes.
  CURSOR csr_cmpny_div_list IS
    SELECT
      t1.cmpny_code,
      t1.pmx_cmpny_code,
      t1.div_code,
      t1.pmx_div_code
    FROM
      pds_div t1
    WHERE
      t1.atlas_flag = 'Y'
    ORDER BY
      t1.cmpny_code,
      t1.div_code;
  rv_cmpny_div_list csr_cmpny_div_list%ROWTYPE;

BEGIN
  -- Start run_pds_cust_01_int procedure.
  pds_utils.create_log;
  write_log(pc_data_type_cust, 'N/A',pv_log_level, 'run_pds_cust_01_int - START.');

  -- Open csr_cmpny_div_list cursor.
  write_log(pc_data_type_cust, 'N/A',pv_log_level, 'Open csr_cmpny_div_list cursor.');
  OPEN csr_cmpny_div_list;
  -- Read through the csr_cmpny_div_list cursor.
  write_log(pc_data_type_cust, 'N/A',pv_log_level, 'Looping through the csr_cmpny_div_list cursor.');
  LOOP
    -- Fetch record from csr_cmpny_div_list cursor.
    FETCH csr_cmpny_div_list INTO rv_cmpny_div_list;
    EXIT WHEN csr_cmpny_div_list%NOTFOUND;

    -- Pass into variables values from cursor.
    v_cmpny_code := rv_cmpny_div_list.cmpny_code;
    v_pmx_cmpny_code := rv_cmpny_div_list.pmx_cmpny_code;
    v_div_code := rv_cmpny_div_list.div_code;
    v_pmx_div_code := rv_cmpny_div_list.pmx_div_code;

    -- Delete from PDS_CUST_HIER_LOAD table based on Company / Division.
    write_log(pc_data_type_cust, 'N/A',pv_log_level + 1, 'Delete from PDS_CUST_HIER_LOAD table ['||v_cmpny_code||','||v_div_code||'].');
    DELETE FROM pds_cust_hier_load
    WHERE cmpny_code = rv_cmpny_div_list.cmpny_code
    AND div_code = rv_cmpny_div_list.div_code;

    -- Delete from (temp) New Customer table PDS_CUST_NEW,
    -- based on Company / Division, in preparation for reload.
    write_log(pc_data_type_cust, 'N/A',pv_log_level + 1, 'Delete from PDS_CUST_NEW table ['||rv_cmpny_div_list.pmx_cmpny_code||','||rv_cmpny_div_list.pmx_div_code||'].');
    DELETE FROM pds_cust_new
    WHERE cmpny_code = rv_cmpny_div_list.pmx_cmpny_code
    AND div_code = rv_cmpny_div_list.pmx_div_code;

    -- Insert into PDS_CUST_HIER_LOAD table.
    write_log(pc_data_type_cust, 'N/A',pv_log_level + 1, 'Insert into PDS_CUST_HIER_LOAD table.');
    INSERT INTO pds_cust_hier_load
      (
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
      levels_to_load,
      procg_status,
      valdtn_status
      )
    SELECT
      t1.hdrseq,
      t1.cocode,
      t2.div_code,
      t3.distbn_chnl_code,
      t1.region,
      t1.custlevel,
      t1.custno,
      t1.posformat,
      t1.chain,
      t1.eff_from,
      t1.hdrdat,
      t3.price_list_code,
      t3.levels_to_load,
      pc_procg_status_loaded,
      pc_valdtn_status_unchecked
    FROM
      pmx_cust_hier_view t1,
      pds_div t2,
      pds_pos_format_grpg t3
    WHERE
      t1.cocode = v_cmpny_code AND
      ((var_div_code = '01' and t1.divcode in ('51,'55')) or
       (var_div_code = '02' and t1.divcode in ('51,'57')) or
       (var_div_code = '05' and t1.divcode in ('51,'56'))) AND
      t2.cmpny_code = v_cmpny_code AND
      t2.div_code = v_div_code AND
      t1.posformat = t3.pos_format_grpg_code (+) AND
      t3.cmpny_code (+) = v_pmx_cmpny_code AND
      t3.div_code (+) = v_pmx_div_code;

    -- Commit.
    write_log(pc_data_type_cust, 'N/A',pv_log_level + 1, 'Commit changes to PDS_CUST_HIER_LOAD table.');
    COMMIT;

  END LOOP;

  -- Close csr_cmpny_div_list cursor.
  write_log(pc_data_type_cust, 'N/A',pv_log_level, 'Close csr_cmpny_div_list cursor.');
  CLOSE csr_cmpny_div_list;

  -- Initiate the next part of the interface by triggering the PDS_CUST_01_PRC processing daemon.
  write_log(pc_data_type_cust, 'N/A', pv_log_level, 'Trigger the PDS_CUST_01_PRC procedure.');
  lics_trigger_loader.execute('MFANZ Promax Customer 01 Process',
                              'pds_app.pds_cust_01_prc.run_pds_cust_01_prc',
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_CUST_01_PRC'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_CUST_01_PRC'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_CUST_01_PRC'));

  -- End run_pds_cust_01_int procedure.
  write_log(pc_data_type_cust, 'N/A',pv_log_level, 'run_pds_cust_01_int - END.');
  pds_utils.end_log;

EXCEPTION

  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_INT.RUN_PDS_CUST_01_INT:',
      pv_processing_msg) ||
      utils.create_params_str('Company Code',rv_cmpny_div_list.cmpny_code,
      'Division Code',rv_cmpny_div_list.div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_cust,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_int,'MFANZ Promax Customer Interface 01.',
      pv_result_msg);
  pds_utils.end_log;

END run_pds_cust_01_int;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table.
  pds_utils.log(pc_job_type_cust_01_int,
                i_data_type,
                i_sort_field,
                i_log_level,
                i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;

END pds_cust_01_int;
/
