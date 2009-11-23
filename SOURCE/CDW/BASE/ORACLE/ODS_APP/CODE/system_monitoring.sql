CREATE OR REPLACE PACKAGE           "SYSTEM_MONITORING" AS

  /*******************************************************************************
    NAME:      run_all_monitoring_checks
    PURPOSE:   This run all check for each company (if needed) and
               also runs through the validation checks.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.
    1.1   24/11/2007 Kris Lee             Add ODS_EFEX_VALIDATION_CHECK call to this
                                          procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE run_all_monitoring_checks;



  /*******************************************************************************
    NAME:      run_all_transaction_checks
    PURPOSE:   This run all the approp check for each company (if needed).

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE run_all_transaction_checks(
    i_log_level ods.log.log_level%TYPE DEFAULT 0);



  /*******************************************************************************
    NAME:      invoice_summary_check
    PURPOSE:   This checks to see if the invoice summary for the specified company
               code should have/has arrived for that day.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Company Code to check for the    i_company_code
                         invoice summary for.
                 company.company_code%TYPE
    2    IN      DATE    The date and time at the company.    i_company_time
    3    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
                 log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE invoice_summary_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      sales_orders_check
    PURPOSE:   This checks to see if any sales orders for the specified company
               code should have/has arrived for that day.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Company Code to check for the    i_company_code
                         Sales Orders for.
                 company.company_code%TYPE
    2    IN      DATE    The date and time at the company.    i_company_time
    3    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
                 log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE sales_orders_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      deliveries_check
    PURPOSE:   This checks to see if any Deliveries for the specified company
               code should have/has arrived for that day.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Company Code to check for the    i_company_code
                         Deliveries for.
                 company.company_code%TYPE
    2    IN      DATE    The date and time at the company.    i_company_time
    3    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
                 log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE deliveries_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      purchase_order_check
    PURPOSE:   This checks to see if any Purchase Order for the specified company
               code should have/has arrived for that day.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN      DATE    The date and time at the company.    i_company_time
    2    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
                 log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purchase_order_check(
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      inventory_check
    PURPOSE:   This checks to see if any Inventory & Intransit data for the
               specified company code should have/has arrived for that day.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   17/01/2005 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN      DATE    The date and time at the company.    i_company_time
    2    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
                 log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE inventory_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
        i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
        );



  /*******************************************************************************
    NAME:      customer_hierarchy_check
    PURPOSE:   This checks to see if any Customer Hierarchy for the specified
               company code should have/has arrived for that day.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Company Code to check for the    i_company_code
                         Customer Hierarchy for.
                 company.company_code%TYPE
    2    IN      DATE    The date and time at the company.    i_company_time
    3    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
                 log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE customer_hierarchy_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      ods_validation_check
    PURPOSE:   This checks the status of the ODS Validation flags.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
                 log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE ods_validation_checks(
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    );

  /*******************************************************************************
    NAME:      ods_efex_validation_check
    PURPOSE:   This checks the status of the ODS EFEX Validation flags.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   24/11/2007 Kris Lee        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN              The Log Level to start loggin at.    i_log_level
                         Defaults to zero.
              log.log_level%TYPE

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE ods_efex_validation_checks(
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    );

END system_monitoring;

/


CREATE OR REPLACE PACKAGE BODY           "SYSTEM_MONITORING" AS

  v_db_name VARCHAR2(256) := NULL;

  PROCEDURE run_all_monitoring_checks IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := 'N/A';
    v_sort_field := 'N/A';
    v_log_level  := 0;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Run All Monitoring Checks.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Calling Run All Transaction Checks.');
    run_all_transaction_checks(v_log_level);


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Calling ODS Validation Checks.');
    ods_validation_checks(v_log_level);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Calling ODS EFEX Validation Checks.');
    ods_efex_validation_checks(v_log_level);

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Run All Monitoring Checks.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR RUN_ALL_CHECKS.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      utils.send_email_to_group(ods_constants.job_type_monitor,
                                'Run All Checks failure on Database: ' ||
                                v_db_name,
                                'On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname || utl_tcp.crlf ||
                                'The system_monitoring.run_all_monitoring_checks failed, ' ||
                                'with the error message: ' || SUBSTR(SQLERRM, 1, 512));
  END run_all_monitoring_checks;



  PROCEDURE run_all_transaction_checks(
    i_log_level ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_company_time      DATE;
    v_new_next_run_time DATE;
    v_temp_number       PLS_INTEGER;

    -- CURSORS
    CURSOR csr_procg_cntl IS
      SELECT
        company_code,
        procg_cntl_type,
        next_run_time
      FROM
        procg_cntl
      ORDER BY
        company_code,
        procg_cntl_type;
    rv_procg_cntl csr_procg_cntl%ROWTYPE;


    CURSOR csr_company IS
      SELECT
        ABS(inv_sum_arrival_time) AS inv_sum_arrival_time,
        ABS(hier_arrival_time) AS hier_arrival_time
      FROM
        company
      WHERE
        company_code = rv_procg_cntl.company_code;
    rv_company csr_company%ROWTYPE;
  BEGIN

    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := 'N/A';
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Run All Transaction Checks.');
    v_log_level := v_log_level + 1;

    OPEN csr_procg_cntl;

    LOOP
      FETCH csr_procg_cntl INTO rv_procg_cntl;
      EXIT WHEN csr_procg_cntl%NOTFOUND;

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Making sure that the Company Code: ' ||
                    rv_procg_cntl.company_code ||
                    ' is valid and exists in the company table.');
      v_temp_number := NULL;
      SELECT
        COUNT(*)
      INTO
        v_temp_number
      FROM
        company
      WHERE
        company_code = rv_procg_cntl.company_code;


      IF (v_temp_number > 0) THEN

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Checking to see if the Invoice Summary, ' ||
                      'Sales Orders, Deliveries or Customer Hierarchies checks ' ||
                      'need to be run for Company Code: ' ||
                       rv_procg_cntl.company_code || '.');

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Getting the Company Time for Company Code: ' ||
                      rv_procg_cntl.company_code || '.');
        v_company_time := utils.get_date_time_at_company(rv_procg_cntl.company_code, v_log_level + 1);

        v_log_level := v_log_level + 1;

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Checking to see if anything needs to be done yet for Company Code: ' ||
                      rv_procg_cntl.company_code || ' at Company Time: ' ||
                      TO_CHAR(v_company_time, 'DD-MON-YYYY HH24:MI:SS') ||
                      ' and Processing Type: ' || rv_procg_cntl.procg_cntl_type || '.');

        -- If the Company Local Time is greater than the Next Run Time, Run.
        IF (rv_procg_cntl.next_run_time < v_company_time) THEN
          IF (rv_procg_cntl.procg_cntl_type = ods_constants.procg_cntl_type_invoice) THEN
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'Need to check for Invoice Summaries, Sales Orders and Deliveries.');
            invoice_summary_check(rv_procg_cntl.company_code, v_company_time, v_log_level + 1);
            sales_orders_check(rv_procg_cntl.company_code, v_company_time, v_log_level + 1);
            deliveries_check(rv_procg_cntl.company_code, v_company_time, v_log_level + 1);
            purchase_order_check(v_company_time, v_log_level + 1);
            inventory_check(rv_procg_cntl.company_code, v_company_time, v_log_level + 1);

          ELSIF (rv_procg_cntl.procg_cntl_type = ods_constants.procg_cntl_type_hierarchy) THEN
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'Need to check for Customer Hierarchies.');
            customer_hierarchy_check(rv_procg_cntl.company_code, v_company_time, v_log_level + 1);
          ELSE
            utils.ods_log(v_job_type,
                          v_data_type,
                          'ERROR',
                          0,
                          '!!!ERROR!!! - THIS IS AN INVALID PROCESSING CONTROL TYPE. NOTHING WILL BE DONE FOR IT.');
          END IF;

          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Now update the PROCG_CNTL table with the next time this should run.');

          OPEN csr_company;
          FETCH csr_company INTO rv_company;
          CLOSE csr_company;

          -- Set the company local time to the current day at midnight
          v_new_next_run_time := TO_DATE(TO_CHAR(v_company_time, 'DDMMYYYY') || ' 000000', 'DDMMYYYY HH24MISS');

          -- Now set the new Next Run Time
          IF (rv_procg_cntl.procg_cntl_type = ods_constants.procg_cntl_type_invoice) THEN
            v_temp_number := rv_company.inv_sum_arrival_time;

          ELSIF (rv_procg_cntl.procg_cntl_type = ods_constants.procg_cntl_type_hierarchy) THEN
            v_temp_number := rv_company.hier_arrival_time;
          END IF;

          IF (ABS(v_temp_number) > ods_constants.minutes_in_day) THEN
            v_temp_number := 0;
          END IF;
          v_new_next_run_time := v_new_next_run_time + numtodsinterval(v_temp_number, 'MINUTE');

          -- Make sure that this is OK
          WHILE (v_new_next_run_time < v_company_time) LOOP
            v_new_next_run_time := v_new_next_run_time + 1;
          END LOOP;

          -- Now Update the PROCG_CNTL Table
          UPDATE
            procg_cntl
          SET
            next_run_time = v_new_next_run_time
          WHERE
            company_code = rv_procg_cntl.company_code
            AND procg_cntl_type = rv_procg_cntl.procg_cntl_type;

          COMMIT;
        ELSE
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Nothing to do yet for Company Code: ' ||
                        rv_procg_cntl.company_code || '.');
        END IF;

        v_log_level := v_log_level - 1;

      ELSE
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Company Code: ' || rv_procg_cntl.company_code ||
                      ' is not valid, skipping.');
      END IF;
    END LOOP;

    CLOSE csr_procg_cntl;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Run All Transaction Checks.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR RUN_ALL_TRANSACTION_CHECKS.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      utils.send_email_to_group(ods_constants.job_type_monitor,
                                'Run All Transaction Checks failure on Database: ' ||
                                v_db_name,
                                'On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname || utl_tcp.crlf ||
                                'The system_monitoring.run_all_transaction_checks failed, ' ||
                                'with the error message: ' || SUBSTR(SQLERRM, 1, 512));
  END run_all_transaction_checks;


  PROCEDURE invoice_summary_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_count      PLS_INTEGER;

  BEGIN

    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := ods_constants.data_type_inv_summ;
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Invoice Summary Arrival Check for Company Code: ' || i_company_code || '.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Making sure the Company Code: ' || i_company_code || ' is valid.');

    SELECT
      COUNT(*)
    INTO
      v_count
    FROM
      company
    WHERE
      company_code = i_company_code;

    IF (v_count > 0) THEN

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Counting the Invoice Summaries for Company Code: ' ||
                    i_company_code ||
                    ' and Company Date: ' ||
                    TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') ||
                    '.');
      -- Find if any invoice summaries have arrived and that it is VALID
      SELECT
        COUNT(*)
      INTO
        v_count
      FROM
        sap_inv_sum_hdr
      WHERE
        fkdat = TO_CHAR(i_company_time - 1, 'YYYYMMDD')
        AND bukrs = i_company_code
        AND valdtn_status = ods_constants.valdtn_valid;


      IF (v_count = 0) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'No Invoice Summary found for Company Code: ' ||
                      i_company_code || ' and Invoice Creation Date ' ||
                      TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') ||
                      '. Checking for Invoices.');

        -- Look for any invoices, even if they are invalid
        SELECT
          COUNT(A.belnr)
        INTO
          v_count
        FROM
          sap_inv_hdr A,
          sap_inv_org B,
          sap_inv_dat C
        WHERE
          A.belnr = B.belnr
          AND A.belnr = C.belnr
          AND B.qualf = ods_constants.invoice_sales_org
          AND B.orgid = i_company_code
          AND C.datum = TO_CHAR(i_company_time - 1, 'YYYYMMDD')
          AND C.iddat = ods_constants.invoice_document_date;

          IF (v_count > 0) THEN
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'Invoices found for Company Code: ' ||
                          i_company_code || '. Missing Summary, raising alert.');

            utils.send_email_to_group(v_job_type,
                                      'ALERT: Missing Invoice Summary for Company Code: ' || i_company_code ||
                                      ', on Database: ' || v_db_name,
                                      'ALERT: On Database: ' || v_db_name ||
                                      ', on the Server: ' || ods_constants.hostname ||
                                      ', The Invoice Summary for Company Code: ' || i_company_code ||
                                      ' and Date: ' || TO_CHAR(i_company_time - 1, 'DD-MON-YYYY')||
                                      ', has not arrived at the Data Warehouse. ' ||
                                      'There are invoices present for this summary in the Data Warehouse.',
                                      i_company_code, v_log_level + 1);
            utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                                    'Invoice Summary Has Not Arrived At Data Warehouse.',
                                    v_job_type,
                                    i_company_code,
                                    v_log_level + 1);
          ELSE
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'No Invoices or Invoice Summaries found for Company Code: ' ||
                          i_company_code || '. Checking the day of the week.');

            IF (TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'SUNDAY' AND
                TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'MONDAY') THEN
              utils.ods_log(v_job_type,
                            v_data_type,
                            v_sort_field,
                            v_log_level,
                            'It''s a week day, so send out a e-mail asking if this is OK.');
              utils.send_email_to_group(v_job_type,
                                        'WARNING: No Invoice/Invoice Summary for Company Code: ' || i_company_code  ||
                                        ', on Database: ' || v_db_name,
                                        'WARNING: On Database: ' || v_db_name ||
                                        ', on the Server: ' || ods_constants.hostname ||
                                        ', no Invoices or Invoice Summaries for Company Code: ' || i_company_code ||
                                        ' and Date: ' || TO_CHAR(i_company_time - 1, 'DD-MON-YYYY')||
                                        ', have arrived at the Data Warehouse. ' ||
                                        'If yesterday was a holiday for this company, ' ||
                                        'then this is probably OK, but you need to check this.',
                                        i_company_code,
                                        v_log_level + 1);
            ELSE
              utils.ods_log(v_job_type,
                            v_data_type,
                            v_sort_field,
                            v_log_level,
                            'It''s a weekend, so do nothing.');
            END IF;
          END IF;
      ELSE
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invoice Summary found for Company Code: ' ||
                      i_company_code || '.');
      END IF;

    ELSE
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Company Code: ' || i_company_code || ' is not a valid company code, skipping.');
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Invoice Summary Arrival Check for Company Code: ' || i_company_code || '.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR INVOICE_SUMMARY_CHECK.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(v_job_type,
                                'ERROR: Invoice Summary Check failure for Company Code: ' || i_company_code  ||
                                ', on Database: ' || v_db_name,
                                '!!!ERROR!!! On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname,
                                i_company_code);

  END invoice_summary_check;



  PROCEDURE sales_orders_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_count      PLS_INTEGER;

  BEGIN

    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := ods_constants.data_type_sales_order;
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Sales Order Arrival Check for Company Code: ' || i_company_code || '.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Making sure the Company Code: ' || i_company_code || ' is valid.');
    SELECT
      COUNT(*)
    INTO
      v_count
    FROM
      company
    WHERE
      company_code = i_company_code;

    IF (v_count > 0) THEN

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Checking to make sure that today: '   ||
                    TO_CHAR(i_company_time, 'DD-MON-YYYY') ||
                    ' is not Sunday or Monday Morning.');
      IF (TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'SUNDAY' AND
          TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'MONDAY') THEN
        v_log_level := v_log_level + 1;

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Counting VALID Orders for Company Code: ' || i_company_code ||
                      ' and Company Date: ' || TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') ||
                      '.');
        SELECT
          COUNT(A.belnr)
        INTO
          v_count
        FROM
          sap_sal_ord_hdr A,
          sap_sal_ord_org B,
          sap_sal_ord_dat C
        WHERE
          A.belnr = B.belnr
          AND A.belnr = C.belnr
          AND B.qualf = ods_constants.sales_order_sales_org
          AND B.orgid = i_company_code
          AND C.iddat = ods_constants.sales_order_creation_date
          AND C.datum = TO_CHAR(i_company_time - 1, 'YYYYMMDD')
          AND A.valdtn_status = ods_constants.valdtn_valid;

        IF (v_count = 0) THEN
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'No VALID Orders for Company Code: ' || i_company_code ||
                        ' found. Sending out warning notification e-mail.');
          utils.send_email_to_group(v_job_type,
                                    'WARNING: No VALID Orders for Company Code: ' || i_company_code ||
                                    ' found on Database: ' || v_db_name,
                                    'WARNING: On Database: ' || v_db_name ||
                                    ', on the Server: ' || ods_constants.hostname ||
                                    ', no VALID Orders for Company Code: ' || i_company_code ||
                                    ' found for the Date: ' || TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') ||
                                    '.' || utl_tcp.crlf ||
                                    'If it was a public holiday for this company, ' ||
                                    'then this is probably OK, but you need to check this.',
                                    v_log_level + 1);
        ELSE
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Orders for Company Code: ' || i_company_code ||
                        ' found, moving on.');
        END IF;

        v_log_level := v_log_level - 1;
      ELSE
        v_log_level := v_log_level + 1;
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'It''s a weekend, doing nothing.');
        v_log_level := v_log_level - 1;
      END IF;

    ELSE
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Company Code: ' || i_company_code || ' is not a valid company code, skipping.');
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Sales Order Arrival Check for Company Code: ' || i_company_code || '.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR SALES_ORDERS_CHECK.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(v_job_type,
                                'ERROR: Sales Orders Check failure for Company Code: ' || i_company_code  ||
                                ', on Database: ' || v_db_name,
                                '!!!ERROR!!! On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname);

  END sales_orders_check;



  PROCEDURE deliveries_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_count      PLS_INTEGER;

  BEGIN

    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := ods_constants.data_type_delivery;
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Deliveries Arrival Check for Company Code: ' || i_company_code || '.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Making sure the Company Code: ' || i_company_code || ' is valid.');

    SELECT
      COUNT(*)
    INTO
      v_count
    FROM
      company
    WHERE
      company_code = i_company_code;

    IF (v_count > 0) THEN

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Checking to make sure that today: ' ||
                    TO_CHAR(i_company_time, 'DD-MON-YYYY') ||
                    ' is not Sunday or Monday morning.');
      IF (TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'SUNDAY' AND
          TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'MONDAY') THEN
        v_log_level := v_log_level + 1;

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Counting VALID Deliveries for for Company Code: ' || i_company_code ||
                      ' and Company Date: ' || TO_CHAR(i_company_time - 1) || '.');
        SELECT
          COUNT(A.vbeln)
        INTO
          v_count
        FROM
          sap_del_hdr A,
          sap_del_tim B
        WHERE
          A.vbeln = B.vbeln
          AND A.vkorg = i_company_code
          AND B.qualf = ods_constants.delivery_document_date
          AND DECODE(B.isdd, NULL, B.ntanf,
                     DECODE(B.isdd, 0, B.ntanf)) = TO_CHAR(i_company_time - 1, 'YYYYMMDD')
          AND A.valdtn_status = ods_constants.valdtn_valid;

        IF (v_count = 0) THEN
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'No VALID Deliveries for Company Code: ' || i_company_code ||
                        ' found. Sending out warning notification e-mail.');
          utils.send_email_to_group(v_job_type,
                                    'WARNING: No VALID Deliveries for Company Code: ' || i_company_code ||
                                    ' found on Database: ' || v_db_name,
                                    'WARNING: On Database: ' || v_db_name ||
                                    ', on the Server: ' || ods_constants.hostname ||
                                    ', no VALID Deliveries for Company Code: ' || i_company_code ||
                                    ' found for the Date: ' ||
                                    TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') ||
                                    '.' ||
                                    utl_tcp.crlf ||
                                    'If it was a public holiday for this company, ' ||
                                    'then this is probably OK, but you need to check this.',
                                    v_log_level + 1);
        ELSE
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Deliveries for Company Code: ' || i_company_code ||
                        ' found, moving on.');
        END IF;

        v_log_level := v_log_level - 1;
      ELSE
        v_log_level := v_log_level + 1;
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'It''s a weekend, doing nothing.');
        v_log_level := v_log_level - 1;
      END IF;
    ELSE
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Company Code: ' || i_company_code || ' is not a valid company code, skipping.');
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Deliveries Arrival Check for Company Code: ' || i_company_code || '.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR DELIVERIES_CHECK.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(v_job_type,
                                'ERROR: Deliveries Check failure for Company Code: ' || i_company_code  ||
                                ', on Database: ' || v_db_name,
                                '!!!ERROR!!! On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname);

  END deliveries_check;



  PROCEDURE purchase_order_check(
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_count      PLS_INTEGER;

  BEGIN

    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := ods_constants.data_type_purch_order;
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Purchase Order Arrival Check.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking to make sure that today: ' ||
                TO_CHAR(i_company_time, 'DD-MON-YYYY') ||
                ' is not Sunday or Monday morning.');
    IF (TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'SUNDAY' AND
        TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'MONDAY') THEN
      v_log_level := v_log_level + 1;

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Counting VALID Purchase Orders for  Date: ' || TO_CHAR(i_company_time - 1) || '.');
      SELECT
        COUNT(A.belnr)
      INTO
        v_count
      FROM
        sap_sto_po_hdr A,
        sap_sto_po_dat B
      WHERE
        A.belnr = B.belnr
        AND B.iddat = ods_constants.purch_order_creation_date
        AND B.datum = TO_CHAR(i_company_time, 'YYYYMMDD')
        AND A.valdtn_status = ods_constants.valdtn_valid;

      IF (v_count = 0) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'No VALID Purchase Orders found. Sending out warning notification e-mail.');
        utils.send_email_to_group(v_job_type,
                                  'WARNING: No VALID Purchase Orders found on Database: ' || v_db_name,
                                  'WARNING: On Database: ' || v_db_name ||
                                  ', on the Server: ' || ods_constants.hostname ||
                                  ', no VALID Purchase Orders found for the Date: ' ||
                                  TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') ||
                                  '.' ||
                                  utl_tcp.crlf ||
                                  'If it was a public holiday, ' ||
                                  'then this is probably OK, but you need to check this.',
                                  v_log_level + 1);
      ELSE
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Purchase Orders for found, moving on.');
      END IF;

      v_log_level := v_log_level - 1;
    ELSE
      v_log_level := v_log_level + 1;
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'It''s a weekend, doing nothing.');
      v_log_level := v_log_level - 1;
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Purchase Order Arrival Check.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR PURCHASE_ORDER_CHECK.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(v_job_type,
                                'ERROR: Purchase Order Check failure' ||
                                ', on Database: ' || v_db_name,
                                '!!!ERROR!!! On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname);

  END purchase_order_check;



  PROCEDURE inventory_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type      ods.log.job_type_code%TYPE;
    v_data_type     ods.log.data_type%TYPE;
    v_sort_field    ods.log.sort_field%TYPE;
    v_log_level     ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_count         PLS_INTEGER;
    v_have_message  BOOLEAN;
    v_email_message VARCHAR2(4000);

  BEGIN

    v_job_type      := ods_constants.job_type_monitor;
    v_data_type     := ods_constants.data_type_inventory;
    v_sort_field    := 'N/A';
    v_log_level     := i_log_level;
    v_have_message  := false;
    v_email_message := '';

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Inventory Arrival Check for Company Code: ' || i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking to make sure that today: ' ||
                TO_CHAR(i_company_time, 'DD-MON-YYYY') ||
                ' is not Sunday or Monday morning.');
    IF (TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'SUNDAY' AND
        TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'MONDAY') THEN
      v_log_level := v_log_level + 1;


     /********************************************************
      *                                                      *
      *                  INVENTORY BALANCE                   *
      *                                                      *
      ********************************************************/
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Counting VALID Inventory Balance Data for Company Code: ' || i_company_code || ' and Date: ' || TO_CHAR(i_company_time) || '.');

      v_count := 0;
      SELECT
        COUNT(*)
      INTO
        v_count
      FROM
        sap_stk_bal_hdr
      WHERE
        bukrs = i_company_code
        AND budat = TO_CHAR(i_company_time, 'YYYYMMDD');

      IF (v_count = 0) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'No VALID Inventory Balance Data for Company Code: ' || i_company_code ||
                      ' found. Adding Text to warning notification e-mail.');
        v_email_message := 'INVENTORY BALANCE' || utl_tcp.crlf ||
                           '-----------------' || utl_tcp.crlf ||
                           'WARNING: On Database: ' || v_db_name ||
                           ', on the Server: ' || ods_constants.hostname ||
                           ', no VALID Inventory Balance Data for Company Code: ' || i_company_code ||
                           ' found for the Date: ' ||
                           TO_CHAR(i_company_time, 'DD-MON-YYYY') || '.' ||
                           utl_tcp.crlf ||
                           'If it was a public holiday for this company, ' ||
                           'then this is probably OK, but you need to check this.' ||
                         utl_tcp.crlf || utl_tcp.crlf || utl_tcp.crlf || utl_tcp.crlf;
        v_have_message := true;

      ELSE
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Inventory Balance Data for Company Code: ' || i_company_code ||
                      ' found, moving on.');
      END IF;


     /********************************************************
      *                                                      *
      *                  INTRANSIT BALANCE                   *
      *                                                      *
      ********************************************************/
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Counting VALID Intransit Balance Data for Company Code: ' || i_company_code || ' and Date: ' || TO_CHAR(i_company_time) || '.');

      v_count := 0;
      SELECT
        COUNT(a.werks)
      INTO
        v_count
      FROM
        sap_int_stk_hdr a,
        sap_int_stk_det b
      WHERE
        a.werks = b.werks
        AND b.burks = i_company_code
        AND TRUNC(a.sap_int_stk_hdr_lupdt, 'DD') = TRUNC(i_company_time - 1, 'DD');

      IF (v_count = 0) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'No VALID Intransit Balance Data for Company Code: ' || i_company_code ||
                      ' found. Adding Text to warning notification e-mail.');
        v_email_message := v_email_message ||
                           'INTRANSIT BALANCE' || utl_tcp.crlf ||
                           '-----------------' || utl_tcp.crlf ||
                           'WARNING: On Database: ' || v_db_name ||
                           ', on the Server: ' || ods_constants.hostname ||
                           ', no VALID Intransit Balance Data for Company Code: ' || i_company_code ||
                           ' found for the Date: ' ||
                           TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') || '.' ||
                           utl_tcp.crlf ||
                           'If it was a public holiday for this company, ' ||
                           'then this is probably OK, but you need to check this.';
        v_have_message := true;

      ELSE
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Intransit Balance Data for Company Code: ' || i_company_code ||
                      ' found, moving on.');
      END IF;



      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Checking to see if an email message needs to be sent out.');
      IF (v_have_message) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Email message found, sending out email containing this message.');
        utils.send_email_to_group(v_job_type,
                                  'WARNING: No Valid Inventory/Intransit Balance Data for Company Code: ' ||
                                  i_company_code || ' found on Database: ' || v_db_name || '.',
                                  v_email_message,
                                  v_log_level + 1);
      END IF;

      v_log_level := v_log_level - 1;

    ELSE
      v_log_level := v_log_level + 1;
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'It''s a weekend, doing nothing.');
      v_log_level := v_log_level - 1;
    END IF;


    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Inventory Arrival Check for Company Code: ' || i_company_code || '.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR INVENTORY_CHECK.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(v_job_type,
                                'ERROR: Inventory Check failure for Company Code: ' ||
                                i_company_code || ', on Database: ' || v_db_name,
                                '!!!ERROR!!! On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname);

  END inventory_check;



  PROCEDURE customer_hierarchy_check(
    i_company_code IN company.company_code%TYPE,
    i_company_time IN DATE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_count      PLS_INTEGER;

  BEGIN

    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := ods_constants.data_type_hierarchy;
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Customer Hierarchy Arrival Check for Company Code: ' || i_company_code || '.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Making sure the Company Code: ' || i_company_code || ' is valid.');

    SELECT
      COUNT(*)
    INTO
      v_count
    FROM
      company
    WHERE
      company_code = i_company_code;

    IF (v_count > 0) THEN

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Checking to make sure that today: ' ||
                    TO_CHAR(i_company_time, 'DD-MON-YYYY') ||
                    ' is not Sunday or Monday morning.');
      IF (TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'SUNDAY' AND
          TRIM(UPPER(TO_CHAR(i_company_time, 'DAY'))) <> 'MONDAY') THEN
        v_log_level := v_log_level + 1;

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Counting Hierarchy Entries for for Company Code: ' || i_company_code ||
                      ' and Company Date: ' || TO_CHAR(i_company_time - 1) || '.');
        SELECT
          COUNT(A.hdrdat)
        INTO
          v_count
        FROM
          sap_hie_cus_det A,
          sap_hie_cus_hdr B
        WHERE
          A.hdrdat = B.hdrdat
          AND A.hdrseq = B.hdrseq
          AND A.vkorg = i_company_code
          AND A.hdrdat = TO_CHAR(i_company_time - 1, 'YYYYMMDD')
          AND B.valdtn_status = ods_constants.valdtn_valid;

        IF (v_count = 0) THEN
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'No Hierarchy Entries for Company Code: ' || i_company_code ||
                        ' found. Sending out warning notification e-mail.');
          utils.send_email_to_group(v_job_type,
                                    'WARNING: No Hierarchy Entries for Company Code: ' || i_company_code ||
                                    ' found on Database: ' || v_db_name,
                                    'WARNING: On Database: ' || v_db_name ||
                                    ', on the Server: ' || ods_constants.hostname ||
                                    ', no Hierarchy Entries for Company Code: ' || i_company_code ||
                                    ' found for the Date: ' ||
                                    TO_CHAR(i_company_time - 1, 'DD-MON-YYYY') || '.' ||
                                    utl_tcp.crlf ||
                                    'If it was a public holiday for this company, ignore this message.',
                                    v_log_level + 1);
        ELSE
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Hierarchy Entries for Company Code: ' || i_company_code ||
                        ' found, moving on.');
        END IF;

        v_log_level := v_log_level - 1;
      ELSE
        v_log_level := v_log_level + 1;
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'It''s a weekend, doing nothing.');
        v_log_level := v_log_level - 1;
      END IF;
    ELSE
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Company Code: ' || i_company_code || ' is not a valid company code, skipping.');
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Customer Hierarchy Arrival Check for Company Code: ' || i_company_code || '.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR CUSTOMER_HIERARCHY_CHECK.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(v_job_type,
                                'ERROR: Hierarchy Check failure for Company Code: ' || i_company_code  ||
                                ', on Database: ' || v_db_name,
                                '!!!ERROR!!! On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname);

  END customer_hierarchy_check;



  PROCEDURE ods_validation_checks(
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_count     PLS_INTEGER  := 1;
    v_last_type VARCHAR2(30) := ' ';
    add_line    BOOLEAN      := true;

    TYPE error_line IS RECORD(rec_type VARCHAR2(30),
                              code     VARCHAR2(500));

    TYPE error_name IS TABLE OF error_line
      INDEX BY PLS_INTEGER;

    error_table error_name;


    -- CURSORS
    -- Invoice Summary
    CURSOR csr_inv_sum_hdr IS
      SELECT
        A.item_code_1, -- Invoice Create Date
        A.item_code_2, -- Company Code
        A.item_code_3, -- Sequence
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_invoice_summary
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_inv_sum_hdr csr_inv_sum_hdr%ROWTYPE;


    -- Invoice Summary UnBalanced
    CURSOR csr_inv_sum_hdr_bal IS
      SELECT
        fkdat, -- Invoice Create Date
        bukrs  -- Company Code
      FROM
        sap_inv_sum_hdr
      WHERE
        balncd_flag = ods_constants.abbrd_no
        AND valdtn_status = ods_constants.valdtn_valid;
    rv_inv_sum_hdr_bal csr_inv_sum_hdr_bal%ROWTYPE;


    -- Invoices
    CURSOR csr_inv_hdr IS
      SELECT
        A.item_code_1, -- Invoice Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_invoice
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_inv_hdr csr_inv_hdr%ROWTYPE;


    -- Sales Order
    CURSOR csr_sal_ord_hdr IS
      SELECT
        A.item_code_1, -- Order Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_sales_order
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_sal_ord_hdr csr_sal_ord_hdr%ROWTYPE;


    -- Purchase Order
    CURSOR csr_sto_po_hdr IS
      SELECT
        A.item_code_1, -- Order Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_purchase_order
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_sto_po_hdr csr_sto_po_hdr%ROWTYPE;


    -- Delivery
    CURSOR csr_del_hdr IS
      SELECT
        A.item_code_1, -- Delivery Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_delivery
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_del_hdr csr_del_hdr%ROWTYPE;


    -- Forecasts
    CURSOR csr_fcst_hdr IS
      SELECT
        A.item_code_1, -- Forecast Header Code
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_forecast
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_fcst_hdr csr_fcst_hdr%ROWTYPE;


    -- Order Usage
    CURSOR csr_order_usage IS
      SELECT
        A.item_code_1,               -- Order Usage Code
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
         A.valdtn_type_code = ods_constants.valdtn_type_order_usage
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_order_usage csr_order_usage%ROWTYPE;

    -- Order Type
    CURSOR csr_order_type IS
      SELECT
        A.item_code_1,               -- Order Type Code
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
         A.valdtn_type_code = ods_constants.valdtn_type_order_type
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_order_type csr_order_type%ROWTYPE;

    -- Check Stock Balance Headers
    CURSOR csr_inv_bal_hdr IS
      SELECT
        A.item_code_1, -- Company Code
        A.item_code_2, -- Plant
        A.item_code_3, -- Storage Location
        A.item_code_4, -- Date of Balance
        A.item_code_5, -- Balance Time
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_inventory_balance
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.item_code_4,
        A.item_code_5,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_inv_bal_hdr csr_inv_bal_hdr%ROWTYPE;


    -- Intransit Balance
    CURSOR csr_inv_trans_hdr IS
      SELECT
        A.item_code_1, -- External Handling Unit ID
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_intransit_balance
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_inv_trans_hdr csr_inv_trans_hdr%ROWTYPE;


    -- Material
    CURSOR csr_mat_hdr IS
      SELECT
        LTRIM(A.item_code_1, '0') AS item_code_1, -- SAP Material Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_material
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_mat_hdr csr_mat_hdr%ROWTYPE;


    -- Classifications
    CURSOR csr_cla_hdr IS
      SELECT
        A.item_code_1, -- Name of database table for object
        A.item_code_2, -- Key of object to be classified
        A.item_code_3, -- Class type
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_sap_class
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_cla_hdr csr_cla_hdr%ROWTYPE;


    -- Classification Master
    CURSOR csr_cla_mas_hdr IS
      SELECT
        A.item_code_1, -- Class Type
        A.item_code_2, -- Class Name
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_class_master
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_cla_mas_hdr csr_cla_mas_hdr%ROWTYPE;


    -- Bill Of Materials
    CURSOR csr_mat_bom_hdr IS
      SELECT
        A.item_code_1, -- Bill of Material
        A.item_code_2, -- Alternate Bill of Material
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_bill_of_materials
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_mat_bom_hdr csr_mat_bom_hdr%ROWTYPE;


    -- Reference Data
    CURSOR csr_ref_hdr IS
      SELECT
        A.item_code_1, -- Table Name
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_sap_ref
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_ref_hdr csr_ref_hdr%ROWTYPE;


    -- CHR MAS Date
    CURSOR csr_chr_mas IS
      SELECT
        A.item_code_1, -- CHR MAS Name
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_chr_mas
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_chr_mas csr_chr_mas%ROWTYPE;


    -- Customer
    CURSOR csr_cus_hdr IS
      SELECT
        A.item_code_1, -- SAP Customer Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_customer
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_cus_hdr csr_cus_hdr%ROWTYPE;


    -- Address
    CURSOR csr_adr_hdr IS
      SELECT
        A.item_code_1, -- Address owner object type
        A.item_code_2, -- Address owner object ID
        A.item_code_3, -- Semantic description of an object address
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_address
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_adr_hdr csr_adr_hdr%ROWTYPE;


    -- Vendor
    CURSOR csr_ven_hdr IS
      SELECT
        A.item_code_1, -- Account Number of Vendor or Creditor
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_vendor
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_ven_hdr csr_ven_hdr%ROWTYPE;


    -- Customer Hierarchy
    CURSOR csr_hie_cus_hdr IS
      SELECT
        A.item_code_1, -- Hierarchy Header Date
        A.item_code_2, -- Hierarchy Header Sequence Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_customer_hier
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_hie_cus_hdr csr_hie_cus_hdr%ROWTYPE;


    -- Exchange Rates
    CURSOR csr_exchange_rates IS
      SELECT
        A.item_code_1, -- Exchange Rate Type
        A.item_code_2, -- From Currency
        A.item_code_3, -- To Currency
        A.item_code_4, -- Valid From Date (in YYYYMMDD format)
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_exchange_rate
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.item_code_4,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_exchange_rates csr_exchange_rates%ROWTYPE;


    -- Accruals
    CURSOR csr_accruals IS
      SELECT
        A.item_code_1, -- Refence Table
        A.item_code_2 || DECODE(A.item_code_3, NULL, '', ' / ' || A.item_code_3) || DECODE(A.item_code_4, NULL, '', ' / ' || NVL(A.item_code_4, '')) as table_key,
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_accrual
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.item_code_4,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_accruals csr_accruals%ROWTYPE;


    -- Promotions
    CURSOR csr_promotions IS
      SELECT
        A.item_code_1, -- Company Code
        A.item_code_2, -- Division Code
        A.item_code_3, -- Promotion Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_prom
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_promotions csr_promotions%ROWTYPE;


    -- Claims
    CURSOR csr_claims IS
      SELECT
        A.item_code_1, -- Company Code
        A.item_code_2, -- Division Code
        A.item_code_3, -- Registry Key
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_claim
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;
    rv_claims csr_claims%ROWTYPE;

    -- DCS Order
    CURSOR csr_dcs_order IS
      SELECT
        A.item_code_1, -- Company Code
        A.item_code_2, -- Order Doc Number
        A.item_code_3, -- Order Doc Line Number
        B.valdtn_reasn_dtl_msg AS message,
        B.valdtn_reasn_dtl_svrty AS severity
      FROM
        valdtn_reasn_hdr A,
        valdtn_reasn_dtl B
      WHERE
        A.valdtn_type_code = ods_constants.valdtn_type_dcs_order
        AND A.valdtn_reasn_hdr_code = B.valdtn_reasn_hdr_code
      ORDER BY
        A.item_code_1,
        A.item_code_2,
        A.item_code_3,
        A.valdtn_reasn_hdr_code,
        B.valdtn_reasn_dtl_seq;

    rv_dcs_order csr_dcs_order%ROWTYPE;


   CURSOR csr_addresses IS
     SELECT DISTINCT email_address
     FROM
       email_list
     WHERE
       job_type_code = ods_constants.job_type_monitor;
    rv_addresses csr_addresses%ROWTYPE;


  BEGIN

    v_job_type   := ods_constants.job_type_monitor;
    v_data_type  := ods_constants.data_type_ods_validation;
    v_sort_field := 'N/A';
    v_log_level  := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Validation Check.');
    v_log_level := v_log_level + 1;





    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Accruals.');
    BEGIN
      OPEN csr_accruals;
      FETCH csr_accruals INTO rv_accruals;
      IF (csr_accruals%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'ACCRUALS';
        error_table(v_count).code     := 'Accrual Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'ACCRUALS';
        error_table(v_count).code     := 'Refence Table || Refence Table Primary Key(s) || Error Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_accruals%NOTFOUND;
          error_table(v_count).rec_type := 'ACCRUALS';
          error_table(v_count).code     := RPAD(rv_accruals.item_code_1, 14)  || ' ' || -- refence table
                                           RPAD(rv_accruals.table_key, 21)  || ' ' || -- table key
                                           TRIM(rv_accruals.message);

          v_count := v_count + 1;
          FETCH csr_accruals INTO rv_accruals;
        END LOOP;
      END IF;
      CLOSE csr_accruals;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR ACCRUALS MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Accrual Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Accrual Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_accruals%ISOPEN) THEN
          CLOSE csr_accruals;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Promotions.');
    BEGIN
      OPEN csr_promotions;
      FETCH csr_promotions INTO rv_promotions;
      IF (csr_promotions%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'PROMOTIONS';
        error_table(v_count).code     := 'Promotions Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'PROMOTIONS';
        error_table(v_count).code     := 'Company | ' ||
                                         'Div Code | ' ||
                                         'Prom Num | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_promotions%NOTFOUND;
          error_table(v_count).rec_type := 'PROMOTIONS';
          error_table(v_count).code     := LPAD(rv_promotions.item_code_1, 4)  || '   ' || -- Company Code
                                           LPAD(rv_promotions.item_code_2, 8)  || '   ' || -- Division Code
                                           LPAD(rv_promotions.item_code_3, 11) || '   ' || -- Promotion Number
                                           LPAD(rv_promotions.severity, 8)     || '   ' ||
                                           TRIM(rv_promotions.message);

          v_count := v_count + 1;
          FETCH csr_promotions INTO rv_promotions;
        END LOOP;
      END IF;
      CLOSE csr_promotions;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR PROMOTIONS MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Promotion Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Promotion Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_promotions%ISOPEN) THEN
          CLOSE csr_promotions;
        END IF;
    END;



    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Claims.');
    BEGIN
      OPEN csr_claims;
      FETCH csr_claims INTO rv_claims;
      IF (csr_claims%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'CLAIMS';
        error_table(v_count).code     := 'Claims Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'CLAIMS';
        error_table(v_count).code     := 'Company | ' ||
                                         'Div Code | ' ||
                                         'Registry | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_claims%NOTFOUND;
          error_table(v_count).rec_type := 'CLAIMS';
          error_table(v_count).code     := LPAD(rv_claims.item_code_1, 4)  || '   ' || -- Company Code
                                           LPAD(rv_claims.item_code_2, 8)  || '   ' || -- Division Code
                                           LPAD(rv_claims.item_code_3, 11) || '   ' || -- Registry Key
                                           LPAD(rv_claims.severity, 8)     || '   ' ||
                                           TRIM(rv_claims.message);

          v_count := v_count + 1;
          FETCH csr_claims INTO rv_claims;
        END LOOP;
      END IF;
      CLOSE csr_claims;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR CLAIMS MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Claims Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Claims Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_claims%ISOPEN) THEN
          CLOSE csr_claims;
        END IF;
    END;



    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Invoice Summaries.');
    BEGIN
      OPEN csr_inv_sum_hdr;
      FETCH csr_inv_sum_hdr INTO rv_inv_sum_hdr;
      IF (csr_inv_sum_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'INV SUM';
        error_table(v_count).code     := 'Invoice Summary Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'INV SUM';
        error_table(v_count).code     := 'Invoice Create Date | ' ||
                                         'Company Code: | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_inv_sum_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'INV SUM';
          error_table(v_count).code     := LPAD(rv_inv_sum_hdr.item_code_1, 19) || '   ' || -- Invoice Create Date
                                           LPAD(rv_inv_sum_hdr.item_code_2, 12) || '   ' || -- Company Code
                                           LPAD(rv_inv_sum_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_inv_sum_hdr.message);

          v_count := v_count + 1;
          FETCH csr_inv_sum_hdr INTO rv_inv_sum_hdr;
        END LOOP;
      END IF;
      CLOSE csr_inv_sum_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR INVOICE SUMMARIES MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Invoice Summary Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Invoice Summaries Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_inv_sum_hdr%ISOPEN) THEN
          CLOSE csr_inv_sum_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking for UnBalanced Invoice Summaries.');
    BEGIN
      OPEN csr_inv_sum_hdr_bal;
      FETCH csr_inv_sum_hdr_bal INTO rv_inv_sum_hdr_bal;
      IF (csr_inv_sum_hdr_bal%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'INV SUM BAL';
        error_table(v_count).code     := 'Unbalanced Invoice Summary Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'INV SUM BAL';
        error_table(v_count).code     := 'Invoice Create Date | ' ||
                                         'Company Code';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_inv_sum_hdr_bal%NOTFOUND;
          error_table(v_count).rec_type := 'INV SUM BAL';
          error_table(v_count).code     := LPAD(rv_inv_sum_hdr_bal.fkdat, 19) || '   ' || -- Invoice Create Date
                                           LPAD(rv_inv_sum_hdr_bal.bukrs, 12);            -- Company Code

          v_count := v_count + 1;
          FETCH csr_inv_sum_hdr_bal INTO rv_inv_sum_hdr_bal;
        END LOOP;
      END IF;
      CLOSE csr_inv_sum_hdr_bal;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR UNBALANCED INVOICE SUMMARIES MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Unbalanced Invoice Summary Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Unbalanced Invoice Summary Data with the error message: ');

        IF (csr_inv_sum_hdr_bal%ISOPEN) THEN
          CLOSE csr_inv_sum_hdr_bal;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Invoices.');
    BEGIN
      OPEN csr_inv_hdr;
      FETCH csr_inv_hdr INTO rv_inv_hdr;
      IF (csr_inv_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'INVOICES';
        error_table(v_count).code     := 'Invoice Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'INVOICES';
        error_table(v_count).code     := 'Document Number | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_inv_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'INVOICES';
          error_table(v_count).code     := LPAD(rv_inv_hdr.item_code_1, 15) || '   ' || -- Document Numnber
                                           LPAD(rv_inv_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_inv_hdr.message);

          v_count := v_count + 1;
          FETCH csr_inv_hdr INTO rv_inv_hdr;
        END LOOP;
      END IF;
      CLOSE csr_inv_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR INVOCES MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Invoice Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Invoice Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_inv_hdr%ISOPEN) THEN
          CLOSE csr_inv_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Sales Orders.');
    BEGIN
      OPEN csr_sal_ord_hdr;
      FETCH csr_sal_ord_hdr INTO rv_sal_ord_hdr;
      IF (csr_sal_ord_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'SALES ORDER';
        error_table(v_count).code     := 'Sales Order Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'SALES ORDER';
        error_table(v_count).code     := 'Document Number                     | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_sal_ord_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'SALES ORDER';
          error_table(v_count).code     := LPAD(rv_sal_ord_hdr.item_code_1, 35) || '   ' || -- Document Number
                                           LPAD(rv_sal_ord_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_sal_ord_hdr.message);

          v_count := v_count + 1;
          FETCH csr_sal_ord_hdr INTO rv_sal_ord_hdr;
        END LOOP;
      END IF;
      CLOSE csr_sal_ord_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR SALES ORDER MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Sales Orders Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Sales Order Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_sal_ord_hdr%ISOPEN) THEN
          CLOSE csr_sal_ord_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Deliveries.');
    BEGIN
      OPEN csr_del_hdr;
      FETCH csr_del_hdr INTO rv_del_hdr;
      IF (csr_del_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'DELIVERY';
        error_table(v_count).code     := 'Delivery Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'DELIVERY';
        error_table(v_count).code     := 'Document Number | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_del_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'DELIVERY';
          error_table(v_count).code     := LPAD(rv_del_hdr.item_code_1, 15) || '   ' || -- Document Numnber
                                           LPAD(rv_del_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_del_hdr.message);

          v_count := v_count + 1;
          FETCH csr_del_hdr INTO rv_del_hdr;
        END LOOP;
      END IF;
      CLOSE csr_del_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR DELIVERY MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Deliveries Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Delivery Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_del_hdr%ISOPEN) THEN
          CLOSE csr_del_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Purchase Orders.');
    BEGIN
      OPEN csr_sto_po_hdr ;
      FETCH csr_sto_po_hdr  INTO rv_sto_po_hdr;
      IF (csr_sto_po_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'PURCH_ORDER';
        error_table(v_count).code     := 'Purchase Order Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'PURCH_ORDER';
        error_table(v_count).code     := 'Document Number | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_sto_po_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'PURCH_ORDER';
          error_table(v_count).code     := LPAD(rv_sto_po_hdr.item_code_1, 15) || '   ' || -- Document Numnber
                                           LPAD(rv_sto_po_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_sto_po_hdr.message);

          v_count := v_count + 1;
          FETCH csr_sto_po_hdr INTO rv_sto_po_hdr;
        END LOOP;
      END IF;
      CLOSE csr_sto_po_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR PURCHASE ORDER MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Purchase Order Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Purchase Order Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_sto_po_hdr%ISOPEN) THEN
          CLOSE csr_sto_po_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Forecasts.');
    BEGIN
      OPEN csr_fcst_hdr;
      FETCH csr_fcst_hdr INTO rv_fcst_hdr;
      IF (csr_fcst_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'FORECAST';
        error_table(v_count).code     := 'Forecast Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'FORECAST';
        error_table(v_count).code     := 'Forecast Header Code | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_fcst_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'FORECAST';
          error_table(v_count).code     := LPAD(rv_fcst_hdr.item_code_1, 20) || '   ' || -- Forecast Header Code
                                           LPAD(rv_fcst_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_fcst_hdr.message);

          v_count := v_count + 1;
          FETCH csr_fcst_hdr INTO rv_fcst_hdr;
        END LOOP;
      END IF;
      CLOSE csr_fcst_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR FORECAST MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Forecast Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Forecast Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_fcst_hdr%ISOPEN) THEN
          CLOSE csr_fcst_hdr;
        END IF;
    END;


    -- Report Order Usage validation errors
    utils.ods_log(v_job_type, v_data_type, v_sort_field, v_log_level, 'Checking Order Usage.');
    BEGIN

      -- Read through all Order Usage validation errors.
      OPEN csr_order_usage;
      FETCH csr_order_usage INTO rv_order_usage;
      IF (csr_order_usage%FOUND) THEN

        -- Write the Error Message Header details
        utils.ods_log(v_job_type, v_data_type, v_sort_field, v_log_level, 'Invalid Data Found.');
        error_table(v_count).rec_type := 'ORDER USAGE';
        error_table(v_count).code     := 'Order Usage Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'ORDER USAGE';
        error_table(v_count).code     := 'Document Number | ' ||
                                           'Severity | ' ||
                                           'Message';

        v_count := v_count + 1;

        -- Now loop through the Order Usage errors, and write out the specific errors.
        LOOP
          EXIT WHEN csr_order_usage%NOTFOUND;
          error_table(v_count).rec_type := 'ORDER USAGE';
          error_table(v_count).code     := LPAD(rv_order_usage.item_code_1, 15) || '   ' ||
                                           LPAD(rv_order_usage.severity, 8) || '   ' ||
                                           TRIM(rv_order_usage.message);

          v_count := v_count + 1;
          FETCH csr_order_usage INTO rv_order_usage;
          END LOOP;
      END IF;
      CLOSE csr_order_usage;

    -- Error management
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR ORDER USAGE MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Order Usage Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed ' ||
                         'during the check for Invalid Order Usage Data with the ' ||
                         'error message: ' || SUBSTR(SQLERRM, 1, 512));
        IF (csr_order_usage%ISOPEN) THEN
            CLOSE csr_order_usage;
          END IF;
    END;


    -- Report Order Type validation errors
    utils.ods_log(v_job_type, v_data_type, v_sort_field, v_log_level, 'Checking Order Type.');
    BEGIN

      -- Read through all Order Type validation errors.
      OPEN csr_order_type;
      FETCH csr_order_type INTO rv_order_type;
      IF (csr_order_type%FOUND) THEN

        -- Write the Error Message Header details
        utils.ods_log(v_job_type, v_data_type, v_sort_field, v_log_level, 'Invalid Data Found.');
        error_table(v_count).rec_type := 'ORDER TYPE';
        error_table(v_count).code     := 'Order Type Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'ORDER TYPE';
        error_table(v_count).code     := 'Document Number | ' ||
                                           'Severity | ' ||
                                           'Message';

        v_count := v_count + 1;

        -- Now loop through the Order Type errors, and write out the specific errors.
        LOOP
          EXIT WHEN csr_order_type%NOTFOUND;
          error_table(v_count).rec_type := 'ORDER TYPE';
          error_table(v_count).code     := LPAD(rv_order_type.item_code_1, 15) || '   ' ||
                                           LPAD(rv_order_type.severity, 8) || '   ' ||
                                           TRIM(rv_order_type.message);

          v_count := v_count + 1;
          FETCH csr_order_type INTO rv_order_type;
          END LOOP;
      END IF;
      CLOSE csr_order_type;

    -- Error management
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR ORDER TYPE MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Order Type Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed ' ||
                         'during the check for Invalid Order Type Data with the ' ||
                         'error message: ' || SUBSTR(SQLERRM, 1, 512));
        IF (csr_order_type%ISOPEN) THEN
            CLOSE csr_order_type;
          END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Inventory Balances.');
    BEGIN
      OPEN csr_inv_bal_hdr;
      FETCH csr_inv_bal_hdr INTO rv_inv_bal_hdr;
      IF (csr_inv_bal_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'INVENTORY BALANCE';
        error_table(v_count).code     := 'Inventory Balance Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'INVENTORY BALANCE';
        error_table(v_count).code     := 'Company Code: | ' ||
                                         'Plant | ' ||
                                         'Storage Location | ' ||
                                         'Date of Balance | ' ||
                                         'Balance Time | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_inv_bal_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'INVENTORY BALANCE';
          error_table(v_count).code     := LPAD(rv_inv_bal_hdr.item_code_1, 12) || '   ' || -- Company Code
                                           LPAD(rv_inv_bal_hdr.item_code_2, 5)  || '   ' || -- Plant
                                           LPAD(rv_inv_bal_hdr.item_code_3, 16) || '   ' || -- Storage Location
                                           LPAD(rv_inv_bal_hdr.item_code_4, 15) || '   ' || -- Date of Balance
                                           LPAD(rv_inv_bal_hdr.item_code_5, 12) || '   ' ||
                                           LPAD(rv_inv_bal_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_inv_bal_hdr.message);
          v_count := v_count + 1;
          FETCH csr_inv_bal_hdr INTO rv_inv_bal_hdr;
        END LOOP;
      END IF;
      CLOSE csr_inv_bal_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR INVENTORY BALANCE MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Inventory Balance Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Inventory Balances with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_inv_bal_hdr%ISOPEN) THEN
          CLOSE csr_inv_bal_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Intransit Balance.');
    BEGIN
      OPEN csr_inv_trans_hdr;
      FETCH csr_inv_trans_hdr INTO rv_inv_trans_hdr;
      IF (csr_inv_trans_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'INTRANS';
        error_table(v_count).code     := 'Intransit Balance Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'INTRANS';
        error_table(v_count).code     := 'External Handling Unit ID | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_inv_trans_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'INTRANS';
          error_table(v_count).code     := LPAD(rv_inv_trans_hdr.item_code_1, 25) || '   ' || -- External Handling Unit ID
                                           LPAD(rv_inv_trans_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_inv_trans_hdr.message);

          v_count := v_count + 1;
          FETCH csr_inv_trans_hdr INTO rv_inv_trans_hdr;
        END LOOP;
      END IF;
      CLOSE csr_inv_trans_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR INTRANSIT BALANCE MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Intransit Balance Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Intransit Balance with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_inv_trans_hdr%ISOPEN) THEN
          CLOSE csr_inv_trans_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Materials.');
    BEGIN
      OPEN csr_mat_hdr;
      FETCH csr_mat_hdr INTO rv_mat_hdr;
      IF (csr_mat_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'MATERIAL';
        error_table(v_count).code     := 'Material Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'MATERIAL';
        error_table(v_count).code     := 'Material Number      | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_mat_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'MATERIAL';
          error_table(v_count).code     := LPAD(rv_mat_hdr.item_code_1, 20) || '   ' || -- SAP Material Number
                                           LPAD(rv_mat_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_mat_hdr.message);

          v_count := v_count + 1;
          FETCH csr_mat_hdr INTO rv_mat_hdr;
        END LOOP;
      END IF;
      CLOSE csr_mat_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR MATERIAL MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Material Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Materials with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_mat_hdr%ISOPEN) THEN
          CLOSE csr_mat_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Classifictions.');
    BEGIN
      OPEN csr_cla_hdr;
      FETCH csr_cla_hdr INTO rv_cla_hdr;
      IF (csr_cla_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'CLASSIFICATION';
        error_table(v_count).code     := 'Classifiction Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'CLASSIFICATION';
        error_table(v_count).code     := 'Table Name  | ' ||
                                         'Key Of Object                                      | ' ||
                                         'Class Type | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_cla_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'CLASSIFICATION';
          error_table(v_count).code     := LPAD(rv_cla_hdr.item_code_1, 11) || '   ' || -- Name of database table for object
                                           LPAD(rv_cla_hdr.item_code_2, 51) || '   ' || -- Key of object to be classified
                                           LPAD(rv_cla_hdr.item_code_3, 10) || '   ' || -- Class type
                                           LPAD(rv_cla_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_cla_hdr.message);

          v_count := v_count + 1;
          FETCH csr_cla_hdr INTO rv_cla_hdr;
        END LOOP;
      END IF;
      CLOSE csr_cla_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR CLASSIFICATION MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Classification Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Classifications with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_cla_hdr%ISOPEN) THEN
          CLOSE csr_cla_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Classification Masters.');
    BEGIN
      OPEN csr_cla_mas_hdr;
      FETCH csr_cla_mas_hdr INTO rv_cla_mas_hdr;
      IF (csr_cla_mas_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'CLASS MASTER';
        error_table(v_count).code     := 'Classifiction Master Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'CLASS MASTER';
        error_table(v_count).code     := 'Class Type  | ' ||
                                         'Class Name          | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_cla_mas_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'CLASS MASTER';
          error_table(v_count).code     := LPAD(rv_cla_mas_hdr.item_code_1, 11) || '   ' || -- Class Type
                                           LPAD(rv_cla_mas_hdr.item_code_2, 19) || '   ' || -- Class Name
                                           LPAD(rv_cla_mas_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_cla_mas_hdr.message);

          v_count := v_count + 1;
          FETCH csr_cla_mas_hdr INTO rv_cla_mas_hdr;
        END LOOP;
      END IF;
      CLOSE csr_cla_mas_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR CLASSIFICATION MASTER MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Classification Master Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Classifications Master with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_cla_mas_hdr%ISOPEN) THEN
          CLOSE csr_cla_mas_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Bill of Materials.');
    BEGIN
      OPEN csr_mat_bom_hdr;
      FETCH csr_mat_bom_hdr INTO rv_mat_bom_hdr;
      IF (csr_mat_bom_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'BOM';
        error_table(v_count).code     := 'BOM Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'BOM';
        error_table(v_count).code     := 'BOM      | ' ||
                                         'Alt BOM  | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_mat_bom_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'BOM';
          error_table(v_count).code     := LPAD(rv_mat_bom_hdr.item_code_1, 8) || '   ' || -- BOM
                                           LPAD(rv_mat_bom_hdr.item_code_2, 7) || '   ' || -- Alternate BOM
                                           LPAD(rv_mat_bom_hdr.severity, 8)    || '   ' ||
                                           TRIM(rv_mat_bom_hdr.message);

          v_count := v_count + 1;
          FETCH csr_mat_bom_hdr INTO rv_mat_bom_hdr;
        END LOOP;
      END IF;
      CLOSE csr_mat_bom_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR BOM MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'BOM Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid BOMs with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_mat_bom_hdr%ISOPEN) THEN
          CLOSE csr_mat_bom_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Reference Data.');
    BEGIN
      OPEN csr_ref_hdr;
      FETCH csr_ref_hdr INTO rv_ref_hdr;
      IF (csr_ref_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'REF DAT';
        error_table(v_count).code     := 'Reference Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'REF DAT';
        error_table(v_count).code     := 'Table Name                     | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_ref_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'REF DAT';
          error_table(v_count).code     := LPAD(rv_ref_hdr.item_code_1, 30) || '   ' || -- Table Name
                                           LPAD(rv_ref_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_ref_hdr.message);

          v_count := v_count + 1;
          FETCH csr_ref_hdr INTO rv_ref_hdr;
        END LOOP;
      END IF;
      CLOSE csr_ref_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR REFERENCE DATA MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Reference Data Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Reference Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_ref_hdr%ISOPEN) THEN
          CLOSE csr_ref_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking CHR MAS Data.');
    BEGIN
      OPEN csr_chr_mas;
      FETCH csr_chr_mas INTO rv_chr_mas;
      IF (csr_chr_mas%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'CHR MAS';
        error_table(v_count).code     := 'CHR MAS Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'CHR MAS';
        error_table(v_count).code     := 'CHR MAS NAME                   | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_chr_mas%NOTFOUND;
          error_table(v_count).rec_type := 'CHR MAS';
          error_table(v_count).code     := LPAD(rv_chr_mas.item_code_1, 30) || '   ' || -- Table Name
                                           LPAD(rv_chr_mas.severity, 8)     || '   ' ||
                                           TRIM(rv_chr_mas.message);

          v_count := v_count + 1;
          FETCH csr_chr_mas INTO rv_chr_mas;
        END LOOP;
      END IF;
      CLOSE csr_chr_mas;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR CHR MAS DATA MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'CHR MAS Data Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid CHR MAS Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_chr_mas%ISOPEN) THEN
          CLOSE csr_chr_mas;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Customer Interface.');
    BEGIN
      OPEN csr_cus_hdr;
      FETCH csr_cus_hdr INTO rv_cus_hdr;
      IF (csr_cus_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'CUSTOMER';
        error_table(v_count).code     := 'Customer Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'CUSTOMER';
        error_table(v_count).code     := 'Customer Number | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_cus_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'CUSTOMER';
          error_table(v_count).code     := LPAD(rv_cus_hdr.item_code_1, 15) || '   ' || -- Table Name
                                           LPAD(rv_cus_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_cus_hdr.message);

          v_count := v_count + 1;
          FETCH csr_cus_hdr INTO rv_cus_hdr;
        END LOOP;
      END IF;
      CLOSE csr_cus_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR CUSTOMER MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Customer Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Customer Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_cus_hdr%ISOPEN) THEN
          CLOSE csr_cus_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Addresses.');
    BEGIN
      OPEN csr_adr_hdr;
      FETCH csr_adr_hdr INTO rv_adr_hdr;
      IF (csr_adr_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'ADDRESS';
        error_table(v_count).code     := 'Address Data Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'ADDRESS';
        error_table(v_count).code     := 'Address Owner Type | ' ||
                                         LPAD('Address Owner ID', 70) || ' | ' ||
                                         LPAD('Description', 70) || ' | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_adr_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'ADDRESS';
          error_table(v_count).code     := LPAD(rv_adr_hdr.item_code_1, 18) || '   ' || -- Address Owner Type
                                           LPAD(rv_adr_hdr.item_code_2, 70) || '   ' || -- Address Owner ID
                                           LPAD(rv_adr_hdr.item_code_3, 70) || '   ' || -- Description
                                           LPAD(rv_adr_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_adr_hdr.message);

          v_count := v_count + 1;
          FETCH csr_adr_hdr INTO rv_adr_hdr;
        END LOOP;
      END IF;
      CLOSE csr_adr_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR ADDRESS MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Address Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Address Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_adr_hdr%ISOPEN) THEN
          CLOSE csr_adr_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Vendors.');
    BEGIN
      OPEN csr_ven_hdr;
      FETCH csr_ven_hdr INTO rv_ven_hdr;
      IF (csr_ven_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'VENDOR';
        error_table(v_count).code     := 'Vendor Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'VENDOR';
        error_table(v_count).code     := 'Account Number | ' ||
                                         RPAD(LPAD('Message', 41), 42) ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_ven_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'VENDOR';
          error_table(v_count).code     := LPAD(rv_ven_hdr.item_code_1, 14) || '   ' || -- Account Numnber
                                           LPAD(rv_ven_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_ven_hdr.message);

          v_count := v_count + 1;
          FETCH csr_ven_hdr INTO rv_ven_hdr;
        END LOOP;
      END IF;
      CLOSE csr_ven_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR VENDOR MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Vendor Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Vendor Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_ven_hdr%ISOPEN) THEN
          CLOSE csr_ven_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Customer Hierarchies.');
    BEGIN
      OPEN csr_hie_cus_hdr;
      FETCH csr_hie_cus_hdr INTO rv_hie_cus_hdr;
      IF (csr_hie_cus_hdr%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'CUST HIER';
        error_table(v_count).code     := 'Customer Hierarchy Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'CUST HIER';
        error_table(v_count).code     := 'Header Date | ' ||
                                         'Header Seq Number | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_hie_cus_hdr%NOTFOUND;
          error_table(v_count).rec_type := 'CUST HIER';
          error_table(v_count).code     := LPAD(rv_hie_cus_hdr.item_code_1, 11) || '   ' || -- Header Date
                                           LPAD(rv_hie_cus_hdr.item_code_2, 17) || '   ' || -- Header Seq Number
                                           LPAD(rv_hie_cus_hdr.severity, 8)     || '   ' ||
                                           TRIM(rv_hie_cus_hdr.message);

          v_count := v_count + 1;
          FETCH csr_hie_cus_hdr INTO rv_hie_cus_hdr;
        END LOOP;
      END IF;
      CLOSE csr_hie_cus_hdr;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR CUSTOMER HIERARCHY MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Customer Hierarchy Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Customer Hierarchy Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_hie_cus_hdr%ISOPEN) THEN
          CLOSE csr_hie_cus_hdr;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking Exchange Rates.');
    BEGIN
      OPEN csr_exchange_rates;
      FETCH csr_exchange_rates INTO rv_exchange_rates;
      IF (csr_exchange_rates%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');
        error_table(v_count).rec_type := 'XCH RATE';
        error_table(v_count).code     := 'Exchange Rate Invalid Information';
        v_count := v_count + 1;
        error_table(v_count).rec_type := 'XCH RATE';
        error_table(v_count).code     := 'Exchange Rate Type | ' ||
                                         'From Currency | ' ||
                                         'To Currency | ' ||
                                         'Valid From Date | ' ||
                                         'Severity | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_exchange_rates%NOTFOUND;
          error_table(v_count).rec_type := 'XCH RATE';
          error_table(v_count).code     := LPAD(rv_exchange_rates.item_code_1, 18) || '   ' || -- Exchange Rate Type
                                           LPAD(rv_exchange_rates.item_code_2, 13) || '   ' || -- From Currency
                                           LPAD(rv_exchange_rates.item_code_3, 11) || '   ' || -- To Currency
                                           LPAD(rv_exchange_rates.item_code_4, 15) || '   ' || -- Valid From Date
                                           LPAD(rv_exchange_rates.severity, 8)     || '   ' ||
                                           TRIM(rv_exchange_rates.message);

          v_count := v_count + 1;
          FETCH csr_exchange_rates INTO rv_exchange_rates;
        END LOOP;
      END IF;
      CLOSE csr_exchange_rates;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR EXCHANGE RATE MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'Exchange Rate Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid Exchange Rate Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_exchange_rates%ISOPEN) THEN
          CLOSE csr_exchange_rates;
        END IF;
    END;

    -- DCS Order
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking DCS Order.');
    BEGIN
      OPEN csr_dcs_order;
      FETCH csr_dcs_order INTO rv_dcs_order;
      IF (csr_dcs_order%FOUND) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Invalid Data Found.');

        error_table(v_count).rec_type := 'DCSOrder';
        error_table(v_count).code     := 'DCS Order Data Invalid Information';
        v_count := v_count + 1;

        error_table(v_count).rec_type := 'DCSOrder';
        error_table(v_count).code     := 'Company | ' ||
                                         'Order Doc Num | ' ||
                                         'Order Line Num | ' ||
                                         'Message';
        v_count := v_count + 1;
        LOOP
          EXIT WHEN csr_dcs_order%NOTFOUND;
          error_table(v_count).rec_type := 'DCSOrder';
          error_table(v_count).code     := LPAD(rv_dcs_order.item_code_1, 10)  || '   ' || -- Company Code
                                           LPAD(rv_dcs_order.item_code_2, 16) || '   ' || -- Order DOC Number
                                           LPAD(rv_dcs_order.item_code_3, 17) || '           ' || -- Order DOC Line Number
                                           TRIM(rv_dcs_order.message);

          v_count := v_count + 1;
          FETCH csr_dcs_order INTO rv_dcs_order;
        END LOOP;
      END IF;
      CLOSE csr_dcs_order;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR DCS ORDER MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'DCS Order Monitoring Check Failed',
                                  'The Procedure system_monitoring.ods_validation_check failed during the ' ||
                                  'check for Invalid DSC Order Data with the error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_dcs_order%ISOPEN) THEN
          CLOSE csr_dcs_order;
        END IF;
    END;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Checking for Invalid Items.');
    IF (error_table.COUNT > 0) THEN
      v_log_level := v_log_level + 1;
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Some Invalid Items were found, sending out an email.');

      OPEN csr_addresses;
      LOOP
        FETCH csr_addresses INTO rv_addresses;
        EXIT WHEN csr_addresses%NOTFOUND;

        utils.start_long_email(rv_addresses.email_address,
                               'Invalid Items Found on MFANZ CDW: ' ||
                               v_db_name,
                               v_log_level + 1);
        utils.append_to_long_email('The Following Items Were Found To Be Invalid:',
                                   v_log_level + 1);

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Appending the list of the invalid Items to the email.');

        v_count := 0;
        FOR i IN 1 ..error_table.COUNT LOOP
          IF (v_last_type <> error_table(i).rec_type) THEN
            v_last_type := error_table(i).rec_type;
            utils.append_to_long_email(' ');
            utils.append_to_long_email(' ');
            v_count  := 0;
            add_line := true;
          END IF;

          IF (add_line) THEN
            utils.append_to_long_email(error_table(i).code);
            v_count := v_count + 1;
          END IF;

          IF (v_count > 200 AND add_line = true) THEN
            utils.append_to_long_email(' ', v_log_level + 1);
            utils.append_to_long_email(' ', v_log_level + 1);
            utils.append_to_long_email('More than 200 invalid entries for this type found. See database for other items.', v_log_level + 1);
            add_line := false;
          END IF;
        END LOOP;
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Sending email.');
        utils.send_long_email(v_log_level + 1);
      END LOOP;
      CLOSE csr_addresses;

      v_log_level := v_log_level - 1;
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Validation Check.');

  EXCEPTION
    WHEN others THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS_VALIDATION_CHECK.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(ods_constants.job_type_monitor,
                                'Monitoring Check Failed on Database: ' ||
                                v_db_name,
                                'On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname || utl_tcp.crlf ||
                                'The system_monitoring.ods_validation_check failed, ' ||
                                'with the error message: ' || SUBSTR(SQLERRM, 1, 512));

  END ods_validation_checks;

  PROCEDURE ods_efex_validation_checks(
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- LOGGING VARIABLES
    v_job_type_snack   ods.log.job_type_code%TYPE;
    v_job_type_pet     ods.log.job_type_code%TYPE;
    v_data_type        ods.log.data_type%TYPE;
    v_sort_field       ods.log.sort_field%TYPE;
    v_log_level        ods.log.log_level%TYPE;
    v_job_type_food    ods.log.job_type_code%TYPE;

    -- LOCAL CONSTANTS
    c_table_desc              CONSTANT   VARCHAR2(100) := 'Ref Table Key or Source Table Primary Key(s) || Error Message';

    -- LOCAL VARIABLES
    v_count_all              PLS_INTEGER  := 1;
    v_last_type              VARCHAR2(30) := ' ';
    add_line                 BOOLEAN      := true;
    v_prev_valdtn_type_code  ods.valdtn_type.valdtn_type_code%TYPE := -1;
    v_efex_start_code        ods.valdtn_type.valdtn_type_code%TYPE := 30;
    v_efex_end_code          ods.valdtn_type.valdtn_type_code%TYPE := 57;
    v_count_pet              PLS_INTEGER  := 1;
    v_count_snack            PLS_INTEGER  := 1;
    v_count_food             PLS_INTEGER  := 1;

    TYPE error_line IS RECORD(rec_type VARCHAR2(30),
                              code     VARCHAR2(500));

    TYPE error_name IS TABLE OF error_line
      INDEX BY PLS_INTEGER;

    error_table_pet   error_name;
    error_table_snack error_name;
    error_table_all   error_name;
    error_table_food  error_name;

    -- CURSOR DECLARATIONS

    CURSOR csr_efex_ref_error_pet IS
     SELECT
       t1.valdtn_type_code,
       t3.valdtn_type_desc,  -- as the error table description
       t1.item_code_2 || DECODE(t1.item_code_3, NULL, '', ' - ' || t1.item_code_3) || DECODE(t1.item_code_4, NULL, '', ' - ' || NVL(t1.item_code_4, '')) as table_key,
       t2.valdtn_reasn_dtl_msg as message,
       t1.item_code_6  -- determine whether validate in bulk
     FROM
       valdtn_reasn_hdr t1,
       valdtn_reasn_dtl t2,
       valdtn_type t3
     WHERE
       t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code
       AND t1.valdtn_type_code = t3.valdtn_type_code
       AND t1.valdtn_type_code BETWEEN 30 AND 57  -- reference data start and end of efex validation type
       AND t1.item_code_1 IN (-1,ods_constants.efex_bus_unit_pet)  -- item_code_1 stores the business unit id
     ORDER BY
       t1.valdtn_type_code,
       item_code_2,
       item_code_3,
       item_code_4;
    rv_efex_ref_error_pet csr_efex_ref_error_pet%ROWTYPE;

    CURSOR csr_efex_ref_error_snack IS
     SELECT
       t1.valdtn_type_code,
       t3.valdtn_type_desc,  -- as the error table description
       t1.item_code_2 || DECODE(t1.item_code_3, NULL, '', ' - ' || t1.item_code_3) || DECODE(t1.item_code_4, NULL, '', ' - ' || NVL(t1.item_code_4, '')) as table_key,
       t2.valdtn_reasn_dtl_msg as message,
       t1.item_code_6  -- determine whether validate in bulk
     FROM
       valdtn_reasn_hdr t1,
       valdtn_reasn_dtl t2,
       valdtn_type t3
     WHERE
       t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code
       AND t1.valdtn_type_code = t3.valdtn_type_code
       AND t1.valdtn_type_code BETWEEN 30 AND 57  -- reference data start and end of efex validation type
       AND t1.item_code_1 IN (-1,ods_constants.efex_bus_unit_snack)  -- item_code_1 stores the business unit id
     ORDER BY
       t1.valdtn_type_code,
       item_code_2,
       item_code_3,
       item_code_4;
    rv_efex_ref_error_snack csr_efex_ref_error_snack%ROWTYPE;

    CURSOR csr_efex_ref_error_food IS
     SELECT
       t1.valdtn_type_code,
       t3.valdtn_type_desc,  -- as the error table description
       t1.item_code_2 || DECODE(t1.item_code_3, NULL, '', ' - ' || t1.item_code_3) || DECODE(t1.item_code_4, NULL, '', ' - ' || NVL(t1.item_code_4, '')) as table_key,
       t2.valdtn_reasn_dtl_msg as message,
       t1.item_code_6  -- determine whether validate in bulk
     FROM
       valdtn_reasn_hdr t1,
       valdtn_reasn_dtl t2,
       valdtn_type t3
     WHERE
       t1.valdtn_reasn_hdr_code = t2.valdtn_reasn_hdr_code
       AND t1.valdtn_type_code = t3.valdtn_type_code
       AND t1.valdtn_type_code BETWEEN 30 AND 57  -- reference data start and end of efex validation type
       AND t1.item_code_1 IN (-1,ods_constants.efex_bus_unit_food)  -- item_code_1 stores the business unit id
     ORDER BY
       t1.valdtn_type_code,
       item_code_2,
       item_code_3,
       item_code_4;
    rv_efex_ref_error_food csr_efex_ref_error_food%ROWTYPE;


   CURSOR csr_addresses_snack IS
     SELECT DISTINCT email_address
     FROM
       email_list
     WHERE
       job_type_code = ods_constants.job_type_efex_monitor_snack;
    rv_addresses_snack csr_addresses_snack%ROWTYPE;

   CURSOR csr_addresses_pet IS
     SELECT DISTINCT email_address
     FROM
       email_list
     WHERE
       job_type_code = ods_constants.job_type_efex_monitor_pet;
    rv_addresses_pet csr_addresses_pet%ROWTYPE;

   CURSOR csr_addresses_food IS
     SELECT DISTINCT email_address
     FROM
       email_list
     WHERE
       job_type_code = ods_constants.job_type_efex_monitor_food;
    rv_addresses_food csr_addresses_food%ROWTYPE;

  BEGIN
    v_job_type_snack   := ods_constants.job_type_efex_monitor_snack;
    v_job_type_pet     := ods_constants.job_type_efex_monitor_pet;
    v_job_type_food     := ods_constants.job_type_efex_monitor_food;
    v_data_type        := ods_constants.data_type_ods_efex_validation;
    v_sort_field       := 'N/A';
    v_log_level        := i_log_level;

    -- Get the Database name.
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level, 'Starting ODS EFEX Validation Check.');
    v_log_level := v_log_level + 1;

    -- Snackfood data.
    BEGIN
      v_prev_valdtn_type_code := -1;
      v_count_snack := 1;
      OPEN csr_efex_ref_error_snack;
      FETCH csr_efex_ref_error_snack INTO rv_efex_ref_error_snack;
      IF (csr_efex_ref_error_snack%FOUND) THEN
        LOOP
          EXIT WHEN csr_efex_ref_error_snack%NOTFOUND;
          -- Different efex table validation error.
          IF v_prev_valdtn_type_code <> rv_efex_ref_error_snack.valdtn_type_code  THEN
             -- Log the validation type.
             utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level, 'Checking Snackfood ' || rv_efex_ref_error_snack.valdtn_type_desc  );

             -- eFEX table name line.
             error_table_snack(v_count_snack).rec_type := rv_efex_ref_error_snack.valdtn_type_code;
             error_table_snack(v_count_snack).code := rv_efex_ref_error_snack.valdtn_type_desc;
             v_count_snack := v_count_snack + 1;

             -- Error table heading line.
             error_table_snack(v_count_snack).rec_type := rv_efex_ref_error_snack.valdtn_type_code;
             IF rv_efex_ref_error_snack.item_code_6 = 'BULK' THEN
                 error_table_snack(v_count_snack).code := 'Ref Table - Key || Error Message';
             ELSE
                 error_table_snack(v_count_snack).code := rv_efex_ref_error_snack.valdtn_type_desc || ' Key(s) || Error Message';
             END IF;
             v_count_snack := v_count_snack + 1;
             v_prev_valdtn_type_code := rv_efex_ref_error_snack.valdtn_type_code;
          END IF;

          -- Each error line.
          error_table_snack(v_count_snack).rec_type := rv_efex_ref_error_snack.valdtn_type_code;
          error_table_snack(v_count_snack).code     := rv_efex_ref_error_snack.table_key || '   ||   ' ||
                                                       TRIM(rv_efex_ref_error_snack.message);

          v_count_snack := v_count_snack + 1;

          FETCH csr_efex_ref_error_snack INTO rv_efex_ref_error_snack;
        END LOOP;
      END IF;
      CLOSE csr_efex_ref_error_snack;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type_snack,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR ODS EFEX VALIDATION MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'ODS EFEX validation Check Failed',
                                  'The Procedure system_monitoring.ods_efex_validation_check failed during ' ||
                                  'checking for Invalid Reference Data for snack with error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_efex_ref_error_snack%ISOPEN) THEN
          CLOSE csr_efex_ref_error_snack;
        END IF;
    END;

    -- Petcare data.
    BEGIN
      v_prev_valdtn_type_code := -1;

      v_count_pet := 1;
      OPEN csr_efex_ref_error_pet;
      FETCH csr_efex_ref_error_pet INTO rv_efex_ref_error_pet;
      IF (csr_efex_ref_error_pet%FOUND) THEN
        LOOP
          EXIT WHEN csr_efex_ref_error_pet%NOTFOUND;
          -- Different efex table validation error
          IF v_prev_valdtn_type_code <> rv_efex_ref_error_pet.valdtn_type_code  THEN
             -- log the validation type
             utils.ods_log(v_job_type_pet, v_data_type, v_sort_field, v_log_level, 'Checking Petcare ' || rv_efex_ref_error_pet.valdtn_type_desc  );

             -- eFEX table name line.
             error_table_pet(v_count_pet).rec_type := rv_efex_ref_error_pet.valdtn_type_code;
             error_table_pet(v_count_pet).code := rv_efex_ref_error_pet.valdtn_type_desc;
             v_count_pet := v_count_pet + 1;

             -- Error table heading line.
             error_table_pet(v_count_pet).rec_type := rv_efex_ref_error_pet.valdtn_type_code;
             IF rv_efex_ref_error_pet.item_code_6 = 'BULK' THEN
                 error_table_pet(v_count_pet).code := 'Ref Table - Key || Error Message';
             ELSE
                 error_table_pet(v_count_pet).code := rv_efex_ref_error_pet.valdtn_type_desc || ' Key(s) || Error Message';
             END IF;

             v_count_pet := v_count_pet + 1;
             v_prev_valdtn_type_code := rv_efex_ref_error_pet.valdtn_type_code;
          END IF;

          -- Each error line.
          error_table_pet(v_count_pet).rec_type := rv_efex_ref_error_pet.valdtn_type_code;
          error_table_pet(v_count_pet).code     := rv_efex_ref_error_pet.table_key || '   ||   ' ||
                                                   TRIM(rv_efex_ref_error_pet.message);

          v_count_pet := v_count_pet + 1;

          FETCH csr_efex_ref_error_pet INTO rv_efex_ref_error_pet;
        END LOOP;
      END IF;
      CLOSE csr_efex_ref_error_pet;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type_pet,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR ODS EFEX VALIDATION MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'ODS EFEX validation Check Failed',
                                  'The Procedure system_monitoring.ods_efex_validation_check failed during ' ||
                                  'checking for Invalid Reference Data for pet with error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_efex_ref_error_pet%ISOPEN) THEN
          CLOSE csr_efex_ref_error_pet;
        END IF;
    END;

    -- Food data.
    BEGIN
      v_prev_valdtn_type_code := -1;

      v_count_food := 1;
      OPEN csr_efex_ref_error_food;
      FETCH csr_efex_ref_error_food INTO rv_efex_ref_error_food;
      IF (csr_efex_ref_error_food%FOUND) THEN
        LOOP
          EXIT WHEN csr_efex_ref_error_food%NOTFOUND;
          -- Different efex table validation error
          IF v_prev_valdtn_type_code <> rv_efex_ref_error_food.valdtn_type_code  THEN
             -- log the validation type
             utils.ods_log(v_job_type_food, v_data_type, v_sort_field, v_log_level, 'Checking food ' || rv_efex_ref_error_food.valdtn_type_desc  );

             -- eFEX table name line.
             error_table_food(v_count_food).rec_type := rv_efex_ref_error_food.valdtn_type_code;
             error_table_food(v_count_food).code := rv_efex_ref_error_food.valdtn_type_desc;
             v_count_food := v_count_food + 1;

             -- Error table heading line.
             error_table_food(v_count_food).rec_type := rv_efex_ref_error_food.valdtn_type_code;
             IF rv_efex_ref_error_food.item_code_6 = 'BULK' THEN
                 error_table_food(v_count_food).code := 'Ref Table - Key || Error Message';
             ELSE
                 error_table_food(v_count_food).code := rv_efex_ref_error_food.valdtn_type_desc || ' Key(s) || Error Message';
             END IF;

             v_count_food := v_count_food + 1;
             v_prev_valdtn_type_code := rv_efex_ref_error_food.valdtn_type_code;
          END IF;

          -- Each error line.
          error_table_food(v_count_food).rec_type := rv_efex_ref_error_food.valdtn_type_code;
          error_table_food(v_count_food).code     := rv_efex_ref_error_food.table_key || '   ||   ' ||
                                                   TRIM(rv_efex_ref_error_food.message);

          v_count_food := v_count_food + 1;

          FETCH csr_efex_ref_error_food INTO rv_efex_ref_error_food;
        END LOOP;
      END IF;
      CLOSE csr_efex_ref_error_food;
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type_food,
                      v_data_type,
                      'ERROR',
                      0,
                      '!!!ERROR!!! - FATAL ERROR FOR ODS EFEX VALIDATION MONITORING CHECK. ' ||
                      'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

        utils.send_email_to_group(ods_constants.job_type_monitor,
                                  'ODS EFEX validation Check Failed',
                                  'The Procedure system_monitoring.ods_efex_validation_check failed during ' ||
                                  'checking for Invalid Reference Data for food with error message: ' || SUBSTR(SQLERRM, 1, 512));

        IF (csr_efex_ref_error_food%ISOPEN) THEN
          CLOSE csr_efex_ref_error_food;
        END IF;
    END;

    -- Handling Petcare email
    utils.ods_log(v_job_type_pet, v_data_type, v_sort_field, v_log_level, 'Checking for Invalid EFEX Petcare Validation error Items.');
    v_count_all := error_table_pet.COUNT;
    IF (v_count_all > 0) THEN
      v_log_level := v_log_level + 1;
      utils.ods_log(v_job_type_pet, v_data_type, v_sort_field, v_log_level+1, 'There were [' || v_count_all || '] Petcare error lines found, sending out an email.');

      OPEN csr_addresses_pet;
      LOOP
        FETCH csr_addresses_pet INTO rv_addresses_pet;
        EXIT WHEN csr_addresses_pet%NOTFOUND;

        utils.start_long_email(rv_addresses_pet.email_address,
                               'Invalid EFEX Validation Items Found for Petcare on MFANZ CDW: ' ||
                               v_db_name,
                               v_log_level + 1);

        utils.append_to_long_email('The Following Items Were Found To Be Invalid:', v_log_level + 1);

        IF error_table_pet.COUNT > 0 THEN
            utils.ods_log(v_job_type_pet, v_data_type, v_sort_field, v_log_level,
                      'Appending the list of the invalid Petcare efex data Items to the email.');

            utils.append_to_long_email(' ');
            utils.append_to_long_email(' ');
            utils.append_to_long_email('PETCARE Data Error List');
            v_last_type := '-1';

            FOR i IN 1 ..error_table_pet.COUNT LOOP
              IF (v_last_type <> error_table_pet(i).rec_type) THEN
                v_last_type := error_table_pet(i).rec_type;
                utils.append_to_long_email(' ');
                utils.append_to_long_email(' ');
                utils.ods_log(v_job_type_pet, v_data_type, v_sort_field, v_log_level,
                      'Appending the list of the Petcare [' || error_table_pet(i).rec_type || '] type Items to the email.');
                v_count_all  := 0;
                add_line := true;
              END IF;

              IF (add_line) THEN
                 utils.append_to_long_email(error_table_pet(i).code);
                 v_count_all := v_count_all + 1;
              END IF;

              IF (v_count_all > 400 AND add_line = true) THEN
                 utils.append_to_long_email(' ', v_log_level + 1);
                 utils.append_to_long_email(' ', v_log_level + 1);
                 utils.append_to_long_email('More than 400 invalid entries for this type found. See database for other items.', v_log_level + 1);
                 add_line := false;
              END IF;

            END LOOP;
        END IF;

        utils.ods_log(v_job_type_pet, v_data_type, v_sort_field, v_log_level, 'Sending Petcare email.');
        utils.send_long_email(v_log_level + 1);

      END LOOP;

      CLOSE csr_addresses_pet;

      v_log_level := v_log_level - 1;
    END IF;

    -- Handling SNACK invalid data email
    utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level, 'Checking for Invalid EFEX Snack Validation error Items.');
    v_count_all := error_table_snack.COUNT;
    IF (v_count_all > 0) THEN
      v_log_level := v_log_level + 1;
      utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level, 'There were [' || v_count_all || '] Snack error lines found, sending out an email.');

      OPEN csr_addresses_snack;
      LOOP
        FETCH csr_addresses_snack INTO rv_addresses_snack;
        EXIT WHEN csr_addresses_snack%NOTFOUND;

        utils.start_long_email(rv_addresses_snack.email_address,
                               'Invalid EFEX Validation Items Found for Snackfood on MFANZ CDW: ' ||
                               v_db_name,
                               v_log_level + 1);

        utils.append_to_long_email('The Following Items Were Found To Be Invalid:', v_log_level + 1);

        IF error_table_snack.COUNT > 0 THEN
            utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level,
                      'Appending the list of the invalid Snackfood efex data Items to the email. Count [' || error_table_snack.COUNT || ']');

            utils.append_to_long_email(' ');
            utils.append_to_long_email(' ');
            utils.append_to_long_email('SNACKFOOD Data Error List');
            v_last_type := '-1';

            FOR i IN 1 ..error_table_snack.COUNT LOOP
              IF (v_last_type <> error_table_snack(i).rec_type) THEN
                v_last_type := error_table_snack(i).rec_type;
                utils.append_to_long_email(' ');
                utils.append_to_long_email(' ');
                utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level,
                      'Appending the list of the Snackfood [' || error_table_snack(i).rec_type || '] type Items to the email.');
                v_count_all  := 0;
                add_line := true;

              END IF;

              IF (add_line) THEN
                utils.append_to_long_email(error_table_snack(i).code);
                v_count_all := v_count_all + 1;
              END IF;

              IF (v_count_all > 400 AND add_line = true) THEN
                utils.append_to_long_email(' ', v_log_level + 1);
                utils.append_to_long_email(' ', v_log_level + 1);
                utils.append_to_long_email('More than 400 invalid entries for this type found. See database for other items.', v_log_level + 1);
                add_line := false;
              END IF;


            END LOOP;
        END IF;

        utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level, 'Sending Snackfood email.');
        utils.send_long_email(v_log_level + 1);

      END LOOP;

      CLOSE csr_addresses_snack;

      v_log_level := v_log_level - 1;
    END IF;

  -- Handling food invalid data email
    utils.ods_log(v_job_type_food, v_data_type, v_sort_field, v_log_level, 'Checking for Invalid EFEX food Validation error Items.');
    v_count_all := error_table_food.COUNT;
    IF (v_count_all > 0) THEN
      v_log_level := v_log_level + 1;
      utils.ods_log(v_job_type_food, v_data_type, v_sort_field, v_log_level, 'There were [' || v_count_all || '] food error lines found, sending out an email.');

      OPEN csr_addresses_food;
      LOOP
        FETCH csr_addresses_food INTO rv_addresses_food;
        EXIT WHEN csr_addresses_food%NOTFOUND;

        utils.start_long_email(rv_addresses_food.email_address,
                               'Invalid EFEX Validation Items Found for food on MFANZ CDW: ' ||
                               v_db_name,
                               v_log_level + 1);

        utils.append_to_long_email('The Following Items Were Found To Be Invalid:', v_log_level + 1);

        IF error_table_food.COUNT > 0 THEN
            utils.ods_log(v_job_type_food, v_data_type, v_sort_field, v_log_level,
                      'Appending the list of the invalid food efex data Items to the email. Count [' || error_table_food.COUNT || ']');

            utils.append_to_long_email(' ');
            utils.append_to_long_email(' ');
            utils.append_to_long_email('FOOD Data Error List');
            v_last_type := '-1';

            FOR i IN 1 ..error_table_food.COUNT LOOP
              IF (v_last_type <> error_table_food(i).rec_type) THEN
                v_last_type := error_table_food(i).rec_type;
                utils.append_to_long_email(' ');
                utils.append_to_long_email(' ');
                utils.ods_log(v_job_type_food, v_data_type, v_sort_field, v_log_level,
                      'Appending the list of the food [' || error_table_food(i).rec_type || '] type Items to the email.');
                v_count_all  := 0;
                add_line := true;

              END IF;

              IF (add_line) THEN
                utils.append_to_long_email(error_table_food(i).code);
                v_count_all := v_count_all + 1;
              END IF;

              IF (v_count_all > 400 AND add_line = true) THEN
                utils.append_to_long_email(' ', v_log_level + 1);
                utils.append_to_long_email(' ', v_log_level + 1);
                utils.append_to_long_email('More than 400 invalid entries for this type found. See database for other items.', v_log_level + 1);
                add_line := false;
              END IF;


            END LOOP;
        END IF;

        utils.ods_log(v_job_type_food, v_data_type, v_sort_field, v_log_level, 'Sending food email.');
        utils.send_long_email(v_log_level + 1);

      END LOOP;

      CLOSE csr_addresses_food;

      v_log_level := v_log_level - 1;
    END IF;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type_snack, v_data_type, v_sort_field, v_log_level, 'Finished ODS EFEX Validation Check.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type_snack,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS_EFEX_VALIDATION_CHECK. Line - ' || v_count_all ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      utils.send_email_to_group(ods_constants.job_type_monitor,
                                'Monitoring Check Failed on Database: ' ||
                                v_db_name,
                                'On Database: ' || v_db_name ||
                                ', on the Server: ' || ods_constants.hostname || utl_tcp.crlf ||
                                'The system_monitoring.ods_efex_validation_check failed, ' ||
                                'with the error message: ' || SUBSTR(SQLERRM, 1, 512));

  END ods_efex_validation_checks;

END system_monitoring;
/
