CREATE OR REPLACE PACKAGE pds_cust_01_rep IS

/*******************************************************************************
  NAME:      run_pds_cust_01_rep
  PURPOSE:   This procedure calls the validate_error_report procedure for each
             Company and Division.

             This procedure is triggered by a pipe message from the
             PDS_CUST_01_PRC procedure.
             .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   26/10/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_pds_cust_01_rep;

/*******************************************************************************
  NAME:      validate_error_report
  PURPOSE:   This procedure generates a report informing whether there are any
             invalid Customer records.  The report is sent as an email and is
             targeted to Functional Experts based on Company and Division using
             the PDS_JOB_TYPE and PDS_EMAIL_LIST tables.
             .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   26/10/2005 Ann-Marie Ingeme     Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Division Code                        02
  3    IN     VARCHAR2 Promax Company Code                  47
  4    IN     VARCHAR2 Promax Division Code                 02
  5    IN     VARCHAR2 Company Description                  Australia
  6    IN     VARCHAR2 Division Description                 Food

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_error_report (
  i_cmpny_code IN pds_div.cmpny_code%TYPE,
  i_div_code IN pds_div.div_code%TYPE,
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  i_cmpny_desc IN pds_div.cmpny_desc%TYPE,
  i_div_desc IN pds_div.div_desc%TYPE);
/*******************************************************************************
  NAME:      validate_new_cust_report
  PURPOSE:   New customers are loaded into Promax via the Postbox table PBCHAIN.
             These new customers are also written to PDS_CUST_NEW to allow reporting.
             This procedure generates a report detailing the new Customers that
             have been written to PDS_CUST_NEW (and PBCHAIN), allowing the FE's
             to easily identify them for completing their setup. The report is
             sent as an email and is targeted to Functional Experts based on
             Company and Division using the PDS_JOB_TYPE and PDS_EMAIL_LIST tables.
             .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   14/03/2006 Craig Ford           Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Division Code                        02
  3    IN     VARCHAR2 Promax Company Code                  47
  4    IN     VARCHAR2 Promax Division Code                 02
  5    IN     VARCHAR2 Company Description                  Australia
  6    IN     VARCHAR2 Division Description                 Food

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE validate_new_cust_report (
  i_cmpny_code IN pds_div.cmpny_code%TYPE,
  i_div_code IN pds_div.div_code%TYPE,
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  i_cmpny_desc IN pds_div.cmpny_desc%TYPE,
  i_div_desc IN pds_div.div_desc%TYPE);
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

END pds_cust_01_rep;
/


CREATE OR REPLACE PACKAGE BODY pds_cust_01_rep IS

  -- PACKAGE VARIABLE DECLARATIONS.
  pv_processing_msg constants.message_string;
  pv_result_msg     constants.message_string;
  pv_log_level      NUMBER := 0;
  pv_status         NUMBER;

  -- PACKAGE CONSTANT DECLARATIONS.
  pc_job_type_cust_01_rep      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_01_rep','JOB_TYPE');
  pc_data_type_cust            CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust','DATA_TYPE');
  pc_data_type_not_applicable  CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('not_applicable','DATA_TYPE');
  pc_valdtn_type_cust          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust','VALDTN_TYPE');
  pc_system_host_name          CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('host_name','SYSTEM');
  pc_job_name_cust_01_prc      CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('cust_01_prc','JOB_NAME');
  pc_url_error_reprocess       CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('error_reprocess','URL');
  pc_system_tier               CONSTANT pds_constants.const_value%TYPE := pds_lookup.lookup_constant('tier','SYSTEM');

PROCEDURE run_pds_cust_01_rep IS

  -- Select all Atlas Company and Division Codes.
  CURSOR csr_cmpny_div_list IS
    SELECT
      cmpny_code,
      div_code,
      pmx_cmpny_code,
      pmx_div_code,
      cmpny_desc,
      div_desc
    FROM
      pds_div
    WHERE
      atlas_flag = 'Y'
    ORDER BY
      cmpny_code,
      div_code;
  rv_cmpny_div_list csr_cmpny_div_list%ROWTYPE;

BEGIN

  -- Start run_pds_cust_01_rep procedure.
  write_log(pc_job_type_cust_01_rep,'N/A',pv_log_level,'run_pds_cust_01_rep - START.');

  -- Read through each of the Company/Division records to be reported.
  write_log(pc_data_type_cust,'N/A',pv_log_level,'Open csr_cmpny_div_list cursor.');
  OPEN csr_cmpny_div_list;
  write_log(pc_data_type_cust,'N/A',pv_log_level,'Looping through the csr_cmpny_div_list cursor.');
  LOOP
    FETCH csr_cmpny_div_list INTO rv_cmpny_div_list;
    EXIT WHEN csr_cmpny_div_list%NOTFOUND;

    -- Produce Validation Error report e-mail.
    validate_error_report(rv_cmpny_div_list.cmpny_code, rv_cmpny_div_list.div_code,rv_cmpny_div_list.pmx_cmpny_code, rv_cmpny_div_list.pmx_div_code,rv_cmpny_div_list.cmpny_desc, rv_cmpny_div_list.div_desc);

    -- Produce New Customer report e-mail.
    write_log(pc_data_type_cust,'N/A',pv_log_level,'Report new customers.');
    validate_new_cust_report(rv_cmpny_div_list.cmpny_code, rv_cmpny_div_list.div_code, rv_cmpny_div_list.pmx_cmpny_code, rv_cmpny_div_list.pmx_div_code, rv_cmpny_div_list.cmpny_desc, rv_cmpny_div_list.div_desc);

  END LOOP;
   write_log(pc_data_type_cust, 'N/A', pv_log_level, 'End of csr_cmpny_div_list cursor loop.');

  -- Close the cursor.
  write_log(pc_data_type_cust, 'N/A', pv_log_level, 'Close csr_cmpny_div_list cursor.');
  CLOSE csr_cmpny_div_list;

  -- End run_pds_cust_01_rep procedure.
  write_log(pc_job_type_cust_01_rep,'N/A',pv_log_level,'run_pds_cust_01_rep - END.');

END;


PROCEDURE validate_error_report (
  i_cmpny_code IN pds_div.cmpny_code%TYPE,
  i_div_code IN pds_div.div_code%TYPE,
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  i_cmpny_desc IN pds_div.cmpny_desc%TYPE,
  i_div_desc IN pds_div.div_desc%TYPE) IS

  -- COLLECTION TYPE DECLARATIONS.
  TYPE rcd_error_line IS RECORD (
    rec_type VARCHAR2(30),
    code     VARCHAR2(500));

  TYPE typ_error IS TABLE OF rcd_error_line INDEX BY PLS_INTEGER;
    tbl_error   typ_error;
    v_count     PLS_INTEGER := 0;

  -- VARIABLE DECLARATIONS.
  v_rpt_count         NUMBER := 0;
  v_output_line_count NUMBER;
  v_valdtn_cmpny_code VARCHAR2(03);
  v_valdtn_div_code   VARCHAR2(03);

  -- CURSOR DECLARATIONS.
  -- Select all invalid Customer records.
  CURSOR csr_valdtn_rec IS
    SELECT
      t1.item_code_1 AS cust_hier_hdr_seq,
      t1.item_code_2 AS cmpny_code,
      t1.item_code_3 AS div_code,
      t1.item_code_4 AS cust_hier_level,
      t1.item_code_5 AS cust_code,
      t2.valdtn_reasn_dtl_msg AS message,
      t2.valdtn_reasn_dtl_svrty AS severity
    FROM
      pds_valdtn_reasn_hdr t1,
      pds_valdtn_reasn_dtl t2
    WHERE
      t1.valdtn_type_code = pc_valdtn_type_cust
      AND t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code
      AND t1.item_code_2 = v_valdtn_cmpny_code
      AND t1.item_code_3 = v_valdtn_div_code
    ORDER BY
      TO_NUMBER(t1.item_code_1),
      t1.item_code_2,
      t1.item_code_3,
      TO_NUMBER(t1.item_code_4),
      t1.item_code_5,
      t1.valdtn_reasn_hdr_code,
      t2.valdtn_reasn_dtl_seq;
  rv_valdtn_rec csr_valdtn_rec%ROWTYPE;

  -- Retrieve email addresses.
  CURSOR csr_email_addresses IS
    SELECT
      t1.email_address
    FROM
      pds_email_list t1
    WHERE
      t1.job_type_code = pc_job_type_cust_01_rep
      AND t1.cmpny_code = i_cmpny_code
      AND t1.div_code = i_div_code;
  rv_email_addresses csr_email_addresses%ROWTYPE;

BEGIN

  -- Start validate_error_report procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'validate_error_report - START.');

  -- Populate the v_valdtn_cmpny_code with either the Grd or Promax Company Code depending
  -- upon which type of value is stored in the Validation table.
  v_valdtn_cmpny_code := i_cmpny_code;
  v_valdtn_div_code := i_div_code;

  -- Read through each of the invalid Customer records to be reported.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Open csr_valdtn_rec cursor.');
  OPEN csr_valdtn_rec;
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Looping through the csr_valdtn_rec cursor.');
  LOOP
    FETCH csr_valdtn_rec INTO rv_valdtn_rec;
    EXIT WHEN csr_valdtn_rec%NOTFOUND;

    IF v_count = 0 THEN
      -- Invalid record found therefore insert header record into array.
      write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'PROMAX: '|| pc_system_tier||' - Invalid Customer records found for '||i_cmpny_desc||' '||i_div_desc||'.');

      -- Insert header record into the array.
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'The following records were found to be invalid. Please review the invalid records and take the appropriate action.';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'For missing Promax data, maintain the master data in Promax, and then reprocess the invalid records. For source';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'system (i.e. SAP,GRD,Logistics) data errors, contact the data owner to correct, then reprocess the invalid records.';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := ' ';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'To view all invalid records, and to reprocess invalid records if required, use the below URL reference.';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := ' ';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'URL Reference:     '||pc_url_error_reprocess;
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'Interface Type:    '||pc_job_name_cust_01_prc;
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := ' ';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := ' ';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'Invalid Customer record(s).';

      -- Insert header detail record into the array.
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := ' ';
      v_count := v_count + 1;
      tbl_error(v_count).rec_type := pc_valdtn_type_cust;
      tbl_error(v_count).code := 'Sequence|' || 'Cmpny|' || 'Div|' || 'Level|' || 'Cust Code|' || 'Severity|'|| 'Message';

    END IF;

    v_count := v_count + 1;

    tbl_error(v_count).rec_type := pc_valdtn_type_cust;
    tbl_error(v_count).code := RPAD(rv_valdtn_rec.cust_hier_hdr_seq,8) || ' '|| -- Customer Hierarchy Header Sequence.
    RPAD(rv_valdtn_rec.cmpny_code, 5) || ' ' || -- Company Code.
    RPAD(rv_valdtn_rec.div_code,3) || ' '|| -- Division Code.
    RPAD(rv_valdtn_rec.cust_hier_level,5) || ' ' || -- Customer Hierarchy Level.
    RPAD(rv_valdtn_rec.cust_code, 9)     || ' ' || -- Customer Code.
    RPAD(rv_valdtn_rec.severity, 8)     || ' ' ||
    TRIM(rv_valdtn_rec.message);

  END LOOP;
  write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'End of csr_valdtn_rec cursor loop.');

  -- Close the cursor.
  write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'Close csr_valdtn_rec cursor.');
  CLOSE csr_valdtn_rec;

  -- Check whether there are any invalid records. If so, then generate the email(s) and send.
  IF v_count > 0 THEN

    -- Only 200 lines of errors are sent in e-mail, therefore if there are more than 200
    -- lines set the v_output_line_count = 214, this ensures we do not keep looping after
    -- we have finished outputting records to e-mail.
    IF tbl_error.COUNT > 213 THEN -- 213 because there are 13 lines of headings.
      v_output_line_count := 214;
    ELSE
      v_output_line_count := tbl_error.COUNT;
    END IF;

    -- Read through each of the e-mail addresses that need error validation reports.
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Open csr_email_addresses cursor.');
    OPEN csr_email_addresses;
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Looping through the csr_email_addresses cursor.');
    LOOP
      FETCH csr_email_addresses INTO rv_email_addresses;
      EXIT WHEN csr_email_addresses%NOTFOUND;

      -- Begin building the email.
      pds_utils.start_long_email(rv_email_addresses.email_address,
        'PROMAX: '|| pc_system_tier||' - Invalid Customer ('||i_cmpny_desc||' '||i_div_desc||').',
        pv_log_level + 2);

      -- Append the list of invalid records to the email.
      FOR i IN 1 ..v_output_line_count LOOP

        -- Continue appending to the email only if the number of invalid records is not greater than 200.
        pds_utils.append_to_long_email(tbl_error(i).code, pv_log_level + 3);
        v_rpt_count := v_rpt_count + 1;

        -- If the number of invalid records is greater than 200 then do not write out to the email.
        IF v_rpt_count > 213 THEN -- 213 because there are 13 lines of headings.
          pds_utils.append_to_long_email(' ', pv_log_level + 3);
          pds_utils.append_to_long_email(' ', pv_log_level + 3);
          pds_utils.append_to_long_email('More than 200 invalid entries for this type found. See database for other items.', pv_log_level + 3);
        END IF;
      END LOOP;

      -- Send the email.
      pds_utils.send_long_email(pv_log_level + 2);

    END LOOP;
    write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'End of csr_email_addresses cursor loop.');

    -- Close the cursor.
    write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'Close csr_email_addresses cursor.');
    CLOSE csr_email_addresses;

  END IF;

  -- End validate_error_report procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'validate_error_report - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_REP.VALIDATE_ERROR_REPORT:',
      'Unexpected Exception - validate_error_report aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_rep,'MFANZ Promax Customer 01 Report',
      pv_result_msg);
END validate_error_report;


PROCEDURE validate_new_cust_report (
  i_cmpny_code IN pds_div.cmpny_code%TYPE,
  i_div_code IN pds_div.div_code%TYPE,
  i_pmx_cmpny_code IN pds_div.pmx_cmpny_code%TYPE,
  i_pmx_div_code IN pds_div.pmx_div_code%TYPE,
  i_cmpny_desc IN pds_div.cmpny_desc%TYPE,
  i_div_desc IN pds_div.div_desc%TYPE) IS

  -- COLLECTION TYPE DECLARATIONS.
  TYPE rcd_newcust_line IS RECORD (
    cust_rec_type VARCHAR2(30),
    cust_rec_code	VARCHAR2(500));

  TYPE typ_newcust IS TABLE OF rcd_newcust_line INDEX BY PLS_INTEGER;
    tbl_newcust   typ_newcust;
    v_cust_count  PLS_INTEGER := 0;

  -- VARIABLE DECLARATIONS.
  v_cust_rpt_count         NUMBER := 0;
  v_cust_output_line_count NUMBER;
  v_valdtn_cmpny_code      VARCHAR2(03);
  v_valdtn_div_code        VARCHAR2(03);

  -- CURSOR DECLARATIONS.
  -- Select all invalid Customer records.
  CURSOR csr_newcus_rec IS
    SELECT
      cmpny_code AS cmpny_code,
      div_code AS div_code,
	    cust_code AS cust_code,
      cust_name AS cust_name
  FROM
      pds_cust_new t2
    WHERE
      cmpny_code = v_valdtn_cmpny_code
      AND div_code = v_valdtn_div_code
    ORDER BY
      cust_code;
  rv_newcus_rec csr_newcus_rec%ROWTYPE;

  -- Retrieve email addresses.
  CURSOR csr_email_addresses IS
    SELECT
      t1.email_address
    FROM
      pds_email_list t1
    WHERE
      t1.job_type_code = pc_job_type_cust_01_rep
      AND t1.cmpny_code = i_cmpny_code
      AND t1.div_code = i_div_code;
  rv_email_addresses csr_email_addresses%ROWTYPE;

BEGIN

  -- Start validate_new_cust_report procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'validate_new_cust_report - START.');

  -- Populate the v_valdtn_cmpny_code with either the Grd or Promax Company Code depending
  -- upon which type of value is stored in the New Customer table.
  v_valdtn_cmpny_code := i_pmx_cmpny_code;
  v_valdtn_div_code := i_pmx_div_code;

  -- Read through each of the new Customer records to be reported.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Open csr_newcus_rec cursor.');
  OPEN csr_newcus_rec;
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Looping through the csr_newcus_rec cursor.');
  LOOP
    FETCH csr_newcus_rec INTO rv_newcus_rec;
    EXIT WHEN csr_newcus_rec%NOTFOUND;

    IF v_cust_count = 0 THEN
      -- New customer record found therefore insert header record into array.
      write_log(pc_data_type_cust,'N/A',pv_log_level + 2,'PROMAX: '|| pc_system_tier||' - New Customer records found for '||i_cmpny_desc||' '||i_div_desc||'.');

      -- Insert header record into the array.
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := 'The following new customers have been loaded into Promax as non-promoted, awaiting final setup. Please review';
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := 'this list to identify the new Customers requiring manual setup completion. This notification will not be re-sent.';
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := ' ';
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := 'Interface Type:    '||pc_job_name_cust_01_prc;
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := ' ';
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := ' ';
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := 'New Customer record(s).';

      -- Insert header detail record into the array.
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := ' ';
      v_cust_count := v_cust_count + 1;
      tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
      tbl_newcust(v_cust_count).cust_rec_code := 'Cmpny|' || 'Div|' || 'Cust Code|' || 'Cust Name';

    END IF;

    v_cust_count := v_cust_count + 1;

    tbl_newcust(v_cust_count).cust_rec_type := pc_valdtn_type_cust;
    tbl_newcust(v_cust_count).cust_rec_code := RPAD(rv_newcus_rec.cmpny_code, 5) || ' ' || -- Company Code.
    RPAD(rv_newcus_rec.div_code,3) || ' '||         -- Division Code.
    RPAD(rv_newcus_rec.cust_code, 9)     || ' ' ||  -- Customer Code.
    RPAD(rv_newcus_rec.cust_name, 30);  	          -- Customer name.

  END LOOP;
  write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'End of csr_newcus_rec cursor loop.');

  -- Close the cursor.
  write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'Close csr_newcus_rec cursor.');
  CLOSE csr_newcus_rec;

  -- Check whether there are any new Customer records. If so, then generate the email(s) and send.
  IF v_cust_count > 0 THEN

    -- Only 2000 lines of new Customers are sent in e-mail, therefore if there are more than 2000
    -- lines set the v_cust_output_line_count = 2010, this ensures we do not keep looping after
    -- we have finished outputting records to e-mail.
    IF tbl_newcust.COUNT > 2009 THEN -- 2009 because there are 9 lines of headings.
      v_cust_output_line_count := 2010;
    ELSE
      v_cust_output_line_count := tbl_newcust.COUNT;
    END IF;

    -- Read through each of the e-mail addresses that need New Customer notification reports.
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Open csr_email_addresses cursor.');
    OPEN csr_email_addresses;
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'Looping through the csr_email_addresses cursor.');
    LOOP
      FETCH csr_email_addresses INTO rv_email_addresses;
      EXIT WHEN csr_email_addresses%NOTFOUND;

      -- Begin building the email.
      pds_utils.start_long_email(rv_email_addresses.email_address,
        'PROMAX: '|| pc_system_tier||' - New Customers ('||i_cmpny_desc||' '||i_div_desc||').',
        pv_log_level + 2);

      -- Append the list of New Customer records to the email.
      FOR i IN 1 ..v_cust_output_line_count LOOP

        -- Continue appending to the email only if the number of new customer records is not greater than 200.
        pds_utils.append_to_long_email(tbl_newcust(i).cust_rec_code, pv_log_level + 3);
        v_cust_rpt_count := v_cust_rpt_count + 1;

        -- If the number of new customer records is greater than 2000 then do not write out to the email.
        IF v_cust_rpt_count > 2009 THEN -- 2009 because there are 9 lines of headings.
          pds_utils.append_to_long_email(' ', pv_log_level + 3);
          pds_utils.append_to_long_email(' ', pv_log_level + 3);
          pds_utils.append_to_long_email('More than 2000 new customers found. See database for other items.', pv_log_level + 3);
          pds_utils.append_to_long_email('Note: This new customer list will be overwritten during the next Customer interface run.', pv_log_level + 3);
        END IF;
      END LOOP;

      -- Send the email.
      pds_utils.send_long_email(pv_log_level + 2);

    END LOOP;
    write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'End of csr_email_addresses cursor loop.');

    -- Close the cursor.
    write_log(pc_data_type_cust, 'N/A', pv_log_level + 1, 'Close csr_email_addresses cursor.');
    CLOSE csr_email_addresses;

  END IF;

  -- End validate_error_report procedure.
  write_log(pc_data_type_cust,'N/A',pv_log_level + 1,'validate_error_report - END.');

EXCEPTION
  -- Send warning message via e-mail and pds_log.
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_failure_msg('PDS_CUST_01_REP.VALIDATE_NEW_CUST_REPORT:',
      'Unexpected Exception - validate_new_cust_report aborted.') ||
      utils.create_params_str() ||
      utils.create_sql_err_msg();
    write_log(pc_data_type_cust,'N/A',pv_log_level + 1,pv_result_msg);
    pds_utils.send_email_to_group(pc_job_type_cust_01_rep,'MFANZ Promax Customer 01 Report',
      pv_result_msg);

END validate_new_cust_report;


PROCEDURE write_log (
  i_data_type IN pds_log.data_type%TYPE,
  i_sort_field IN pds_log.sort_field%TYPE,
  i_log_level IN pds_log.log_level%TYPE,
  i_log_text IN pds_log.log_text%TYPE) IS

BEGIN
  -- Write the entry into the pds_log table.
  pds_utils.log(pc_job_type_cust_01_rep,
                i_data_type,
                i_sort_field,
                i_log_level,
                i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    pv_result_msg :=
      utils.create_error_msg('PDS_CUST_01_REP.WRITE_LOG:',
        'Unable to write to the PDS_LOG table.') ||
      utils.create_sql_err_msg();
    pds_utils.log(pc_job_type_cust_01_rep,pc_data_type_not_applicable,'N/A',i_log_level,
      pv_result_msg);
END write_log;


END pds_cust_01_rep;
/
