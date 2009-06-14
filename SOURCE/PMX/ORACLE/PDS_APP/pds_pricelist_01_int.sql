CREATE OR REPLACE PACKAGE pds_pricelist_01_int IS

/*******************************************************************************
  NAME:      run_pds_pricelist_01_int
  PURPOSE:   This procedure retrieves Australia and New Zealand data from LADS
             and loads into the pds_price_list table. The procedure is scheduled as
             an ICS job, which runs daily.  This procedure then calls the
             pds_pricelist_01_prc procedure which validates the loaded pricelist
             data.  Valid data is then loaded into the Promax Postbox table.
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
PROCEDURE run_pds_pricelist_01_int;

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

END pds_pricelist_01_int;
/


CREATE OR REPLACE PACKAGE BODY pds_pricelist_01_int IS

  -- PACKAGE VARIABLE DESCLARATION
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;

  -- PACKAGE CONSTANT DECLARATIONS
  pc_job_type_pricelist_01_int CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pricelist_01_int','JOB_TYPE');
  pc_data_type_pricelist       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('pricelist','DATA_TYPE');
  pc_debug                     CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('debug_flag','DEBUG_FLAG');
  pc_alert_level_minor         CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('level_minor','ALERT');
  pc_procg_status_loaded       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('loaded','PROCG_STATUS');
  pc_valdtn_status_unchecked   CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('unchecked','VALDTN_STATUS');

PROCEDURE run_pds_pricelist_01_int IS

  -- VARIABLE DECLARATIONS
  v_pmx_cmpny_code pds_div.pmx_cmpny_code%TYPE;
  v_pmx_div_code   pds_div.pmx_div_code%TYPE;

  -- CURSOR DECLARATIONS
  CURSOR csr_cmpny_div_list IS
    SELECT
      t1.pmx_cmpny_code,
      t1.pmx_div_code
    FROM
      pds_div t1
    WHERE
      t1.atlas_flag = 'Y'
    ORDER BY
      t1.pmx_cmpny_code,
      t1.pmx_div_code;
  rv_cmpny_div_list csr_cmpny_div_list%ROWTYPE;

BEGIN

  -- Start run_pds_pricelist_01_int procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level,'run_pds_pricelist_01_int - START.');

  -- Open csr_cmpny_div_list cursor.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level,'Open csr_cmpny_div_list cursor.');
  OPEN csr_cmpny_div_list;

  -- Read through the csr_cmpny_div_list cursor.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level,'Looping through the csr_cmpny_div_list cursor.');
  LOOP
    FETCH csr_cmpny_div_list INTO rv_cmpny_div_list;
    EXIT WHEN csr_cmpny_div_list%NOTFOUND;

    -- Pass in variable values from the cursor.
    v_pmx_cmpny_code := rv_cmpny_div_list.pmx_cmpny_code;
    v_pmx_div_code := rv_cmpny_div_list.pmx_div_code;

    -- Delete from the PDS_PRICE_LIST table based on Company / Division.
    write_log(pc_data_type_pricelist, 'N/A', pv_log_level + 1, 'Delete from PDS_PRICE_LIST table.');
    DELETE FROM pds_price_list
    WHERE cmpny_code = v_pmx_cmpny_code
    AND div_code = v_pmx_div_code;

    -- Insert into PDS_PRICE_LIST table.
    write_log(pc_data_type_pricelist, 'N/A', pv_log_level + 1, 'Inserting into PDS_PRICE_LIST table.');
    INSERT INTO pds_price_list
      (
      cmpny_code,
      div_code,
      distbn_chnl_code,
      matl_code,
      eff_date,
      list_price,
      mfg_cost,
      rrp,
      procg_status,
      valdtn_status
      )
      SELECT
        cocode,
        divcode,
        channel,
        prodcode,
        startdate,
        price1,
        mnfcost,
        NVL(rrp,0),
        pc_procg_status_loaded,
        pc_valdtn_status_unchecked
      FROM
        pmx_price_ext_view
      WHERE
        cocode = v_pmx_cmpny_code
        AND divcode = v_pmx_div_code;

    -- Commit.
    write_log(pc_data_type_pricelist, 'N/A', pv_log_level + 1, 'Commit changes to PDS_PRICE_LIST table.');
    COMMIT;

  END LOOP;
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level, 'End of loop.');

  -- Close csr_cmpny_div_list cursor.
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level, 'Close cursor csr_cmpny_div_list.');
  CLOSE csr_cmpny_div_list;

  -- Trigger the pds_pricelist_01_prc procedure.
  write_log(pc_data_type_pricelist, 'N/A', pv_log_level, 'Trigger the PDS_PRICELIST_01_PRC procedure.');
  lics_trigger_loader.execute('MFANZ Promax Price List 01 Process',
                              'pds_app.pds_pricelist_01_prc.run_pds_pricelist_01_prc',
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_ALERT','PDS_PRICELIST_01_PRC'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_EMAIL_GROUP','PDS_PRICELIST_01_PRC'),
                              lics_setting_configuration.retrieve_setting('LICS_TRIGGER_GROUP','PDS_PRICELIST_01_PRC'));

  -- End run_pds_pricelist_01_int procedure.
  write_log(pc_data_type_pricelist,'N/A',pv_log_level,'run_pds_pricelist_01_int - END.');

EXCEPTION

  -- Send warning message via E-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_PRICELIST_01_INT.RUN_PDS_PRICELIST_01_INT:',
      pv_processing_msg) ||
      utils.create_params_str('Promax Company Code',rv_cmpny_div_list.pmx_cmpny_code,
      'Promax Division Code',rv_cmpny_div_list.pmx_div_code) ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_pricelist,'N/A',pv_log_level,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_pricelist_01_int,'MFANZ Promax Pricelist 01 Interface',
      pv_result_msg);

END run_pds_pricelist_01_int;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN

  -- Write the entry into the PDS_LOG table.
  pds_utils.log(pc_job_type_pricelist_01_int,i_data_type,i_sort_field,i_log_level,i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END write_log;

END pds_pricelist_01_int;
/
