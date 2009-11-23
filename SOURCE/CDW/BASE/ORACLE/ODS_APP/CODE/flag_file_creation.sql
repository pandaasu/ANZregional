CREATE OR REPLACE PACKAGE           "FLAG_FILE_CREATION" AS

  /*******************************************************************************
    NAME:      triggered_flag_file_creation
    PURPOSE:   Goes and checks to see if any flag files need to be created once
               it's pipe has been woken up

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This procedures pipe is woken by the aggregation package.
           No INV_SUM_ARRIVAL_TIME value (offset value) in the company table may be
           greater than 24 * 60 and MUST be a positive number.
           Any values greater than this will be given the value of zero and
           the Absolute value will be taken.
           Company Timezone Offest must not be greater that 24 * 60. If it is
           it will be given a value of zero.

   ************************************************************************
   * IMPORTANT NOTE                                                       *
   * --------------                                                       *
   * This procedure has been written so that multiple instances of it may *
   * run at the same time and will not try perform the same task at the   *
   * same time, and nor will they try to do a task that has already been  *
   * done by another instance. To do this the cursor used in the outside  *
   * loop is opened and close for every pass through the loop. Be very    *
   * careful when modifying this procedure as you may break this          *
   * behaviour.                                                           *
   ************************************************************************
  ********************************************************************************/
  PROCEDURE triggered_flag_file_creation;



  /*******************************************************************************
    NAME:      scheduled_flag_file_creation
    PURPOSE:   Goes and checks to see if any flag files need to be created when
               it is started by the oracle job.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   07/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This procedures pipe is started by the internal oracle job scheduler.
           No INV_SUM_ARRIVAL_TIME value (offset value) in the company table may be
           greater than 24 * 60 and MUST be a positive number.
           Any values greater than this will be given the value of zero and
           the Absolute value will be taken.
           Company Timezone Offest must not be greater that 24 * 60. If it is
           it will be given a value of zero.

   ************************************************************************
   * IMPORTANT NOTE                                                       *
   * --------------                                                       *
   * This procedure has been written so that multiple instances of it may *
   * run at the same time and will not try perform the same task at the   *
   * same time, and nor will they try to do a task that has already been  *
   * done by another instance. To do this the cursor used in the outside  *
   * loop is opened and close for every pass through the loop. Be very    *
   * careful when modifying this procedure as you may break this          *
   * behaviour.                                                           *
   ************************************************************************
  ********************************************************************************/
  PROCEDURE scheduled_flag_file_creation;



  /*******************************************************************************
    NAME:      create_and_send_flag_file
    PURPOSE:   Creates the flag file in unix and places it on a queue.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   21/06/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1     IN      VARCHAR2 The name of the file to put on the  filename
                          queue.
    2     IN     ods.log.log_level%TYPE
                          The Log level to start logging at.   i_log_level
                          Defaults to zero.

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE create_and_send_flag_file(
    i_filename  IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    );



  /*******************************************************************************
    NAME:      get_company_timezone_offset
    PURPOSE:   Returns the difference in minutes between the time at the comanpy
               and box time.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   20/12/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1     IN     V$TIMEZONE_NAMES.TZNAME%TYPE
                          The company timezone code.          NZ
    2     IN     ods.log.log_level%TYPE
                          The Log level to start logging at.   i_log_level
                          Defaults to zero.

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  FUNCTION get_company_timezone_offset (
    i_company_timezone IN V$TIMEZONE_NAMES.TZNAME%TYPE,
    i_log_level        IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN PLS_INTEGER;

END flag_file_creation;

/


CREATE OR REPLACE PACKAGE BODY           "FLAG_FILE_CREATION" AS

  v_job_type   ods.log.job_type_code%TYPE;
  v_data_type  ods.log.data_type%TYPE;
  v_sort_field ods.log.sort_field%TYPE;
  v_log_level  ods.log.log_level%TYPE;
  v_db_name    VARCHAR2(256) := NULL;



  /*************************************************************************
   * IMPORTANT NOTE                                                       *
   * --------------                                                       *
   * This procedure has been written so that multiple instances of it may *
   * run at the same time and will not try perform the same task at the   *
   * same time, and nor will they try to do a task that has already been  *
   * done by another instance. To do this the cursor used in the outside  *
   * loop is opened and close for every pass through the loop. Be very    *
   * careful when modifying this procedure as you may break this          *
   * behaviour.                                                           *
   ************************************************************************/
  PROCEDURE triggered_flag_file_creation IS

    -- VALARIABLES
    -- The temp variable used for locking
    v_temp         sap_inv_sum_hdr.bukrs%TYPE;
    v_company_time DATE;

    -- CURSORS
    -- Invoice summaries can only get the flag of "ods_constants.inv_sum_unflagged"
    -- if the aggregation process for this summary has finished.
    CURSOR csr_get_unflagged IS
      SELECT
        fkdat AS invoice_creation_date,
        bukrs AS company_code
      FROM
        sap_inv_sum_hdr
      WHERE
        flag_file_status = ods_constants.inv_sum_unflagged;
    rv_get_unflagged csr_get_unflagged%ROWTYPE;


    CURSOR csr_company IS
      SELECT
        company_timezone_code,
        ABS(inv_sum_arrival_time) AS inv_sum_arrival_time
      FROM
        company
      WHERE
        company_code = rv_get_unflagged.company_code;
    rv_company csr_company%ROWTYPE;


  BEGIN
    -- Setup all the logging basics
    v_job_type   := ods_constants.job_type_trig_flag_file;
    v_data_type  := ods_constants.data_type_trig_flag_file;
    v_sort_field := ods_constants.data_type_trig_flag_file;
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
                  'Starting Triggered Flag File Creation.');
    v_log_level := v_log_level + 1;

    WHILE TRUE LOOP
      v_temp := NULL;

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Opening the csr_get_unflagged cursor to get all ' ||
                    'the invoice summaries that have not had flag files ' ||
                    'created for them yet.');
      -- Open the cursor
      OPEN csr_get_unflagged;

      -- Get the next summary row and lock it so no updates on it may be done
      FETCH csr_get_unflagged INTO rv_get_unflagged;

      -- Make sure that there is something to get
      EXIT WHEN csr_get_unflagged%NOTFOUND;

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Locking the row in the sap_inv_sum_hdr table ' ||
                    'that contains the invoice summary being worked on.');
      -- Now lock this row in the Invoice Summary Header table
      v_temp := null;
      BEGIN
        SELECT
          bukrs
        INTO
          v_temp
        FROM
          sap_inv_sum_hdr
        WHERE
          fkdat = rv_get_unflagged.invoice_creation_date
          AND bukrs = rv_get_unflagged.company_code
        FOR UPDATE NOWAIT;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      IF (v_temp IS NOT NULL) THEN
        utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Checking Company Code: ' || rv_get_unflagged.company_code || ' is valid.');

        -- Make sure company exists
        BEGIN
          SELECT
            company_code
          INTO
            v_temp
          FROM
            company
          WHERE
            company_code = rv_get_unflagged.company_code;
        EXCEPTION
          WHEN OTHERS THEN
            v_temp := null;
        END;

        IF (v_temp IS NOT NULL) THEN
          v_log_level := v_log_level + 1;
          utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Checking to see if a flag file needs to be created ' ||
                      'for this invoice summary.');

          v_company_time := utils.get_date_time_at_company(rv_get_unflagged.company_code, v_log_level + 1);

        ELSE
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Invalid Company Code: ' || rv_get_unflagged.company_code || '.');
        END IF;

        IF (v_temp IS NOT NULL) THEN
          -- Using Company Time -1 to cover the possibility of the invoice summary being sent
          -- and processed by the data warehouse before midnight. This is done as we only
          -- create flag file for prior days invoice summary.
          -- ods_constants.boundary_time should equal 1000 (i.e. 10:00 a.m.) Company Time.
          IF (((rv_get_unflagged.invoice_creation_date = TO_CHAR((v_company_time - 1), 'YYYYMMDD'))
               AND (TO_CHAR(v_company_time, 'HH24MI') < ods_constants.boundary_time))
             OR (rv_get_unflagged.invoice_creation_date > TO_CHAR(v_company_time - 1, 'YYYYMMDD'))) THEN

            v_log_level := v_log_level + 1;
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'Creating Flag File.');

            -- Now create and send out the flag file to the BCA server
            create_and_send_flag_file(rv_get_unflagged.company_code || '.txt',
                                      v_log_level + 1);
            v_log_level := v_log_level - 1;

          ELSE
            v_log_level := v_log_level + 1;
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'No Flag File Creation Needed.');

             v_log_level := v_log_level - 1;
          END IF;

        ELSE
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Company Code: ' || rv_get_unflagged.company_code || ' does not exist, skipping.');
        END IF;

        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Setting the status of the rows flag to COMPLETE ' ||
                      'and setting the last run date and time in the '   ||
                      'company table to now.');
        -- Change the status of the header from UNFLAGGED to COMPLETE
        UPDATE
          sap_inv_sum_hdr
        SET
          flag_file_status = ods_constants.inv_sum_complete
        WHERE
          fkdat = rv_get_unflagged.invoice_creation_date
          AND bukrs = rv_get_unflagged.company_code;

      END IF;

      v_log_level := v_log_level - 1;
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Releasing the lock on the sap_inv_sum_hdr row.');
      -- Commit to release the lock
      COMMIT;

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Closing the csr_get_unflagged cursor.');
      CLOSE csr_get_unflagged;

    END LOOP;

    IF (csr_get_unflagged%ISOPEN) THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Closing the csr_get_unflagged cursor.');
      CLOSE csr_get_unflagged;
    END IF;

    -- Now send a message to the data load pipe to check for any replacement
    -- invoice summaries that may have arrived
    lics_pipe.spray(lics_constant.type_daemon,
                    ods_constants.queue_validate,
                    lics_constant.pipe_wake );

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Triggered Flag File Creation.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR TRIGGERED FLAG FILE CREATION.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      utils.send_email_to_group(v_job_type,
                                'Triggered Flag File Creation Error on Database: ' ||
                                v_db_name,
                                'An error occured on the Database: ' ||
                                v_db_name ||
                                ', on the Server: ' ||
                                ods_constants.hostname ||
                                '.' || utl_tcp.crlf ||
                                'A Fatal Error occured during the running of the ' ||
                                'Triggered Flag File Procedure.');

      utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                              'Triggered Flag File Creation Failure.',
                              v_job_type);

  END triggered_flag_file_creation;



  /************************************************************************
   * IMPORTANT NOTE                                                       *
   * --------------                                                       *
   * This procedure has been written so that multiple instances of it may *
   * run at the same time and will not try perform the same task at the   *
   * same time, and nor will they try to do a task that has already been  *
   * done by another instance. To do this the cursor used in the outside  *
   * loop is opened and close for every pass through the loop. Be very    *
   * careful when modifying this procedure as you may break this          *
   * behaviour.                                                           *
   ************************************************************************/
  PROCEDURE scheduled_flag_file_creation IS

    -- LOCAL VARIABELS
    v_company_time             DATE;
    v_new_next_run_time        DATE;
    v_pos_next_run_time        DATE;
    v_inv_sum_count            PLS_INTEGER;
    v_inv_count                PLS_INTEGER;
    v_temp_number              PLS_INTEGER;
    v_create_combine_flag_file BOOLEAN := TRUE;
    v_set_next_run_time        BOOLEAN := TRUE;


    -- CURSORS
    CURSOR csr_mcff_list IS
      SELECT DISTINCT
        A.mcff_code,
        A.next_run_time
      FROM
        mcff A,
        company_mcff B
      WHERE
        A.mcff_code = B.mcff_code
        AND A.next_run_time < sysdate;
    rv_mcff_list csr_mcff_list%ROWTYPE;


    CURSOR csr_company_list IS
      SELECT DISTINCT
        A.company_code,
        A.company_timezone_code,
        ABS(A.inv_sum_arrival_time) AS inv_sum_arrival_time
      FROM
        company      A,
        company_mcff B,
        mcff         C
      WHERE
        A.company_code = B.company_code
        AND B.mcff_code = C.mcff_code
        AND C.mcff_code = rv_mcff_list.mcff_code
      ORDER BY
        A.company_code;
    rv_company_list csr_company_list%ROWTYPE;

  BEGIN
    -- Setup all the logging basics
    v_job_type   := ods_constants.job_type_sched_flag_file;
    v_data_type  := ods_constants.data_type_sched_flag_file;
    v_sort_field := ods_constants.data_type_sched_flag_file;
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
                  'Starting Scheduled Flag File Creation.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Going Through all the MCFF Code that have a Next Run Time < now.');
    v_log_level := v_log_level + 1;
    OPEN csr_mcff_list;
    LOOP
      FETCH csr_mcff_list INTO rv_mcff_list;
      EXIT WHEN csr_mcff_list%NOTFOUND;

      v_create_combine_flag_file := TRUE;
      v_set_next_run_time        := TRUE;
      v_new_next_run_time        := TO_DATE('01-01-1900 00:00:00', 'DD-MM-YYYY HH24:MI:SS');

      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Looking at MCFF Code: ' || rv_mcff_list.mcff_code || '.');

      -- Get all the Companies for the MCFF Code
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Get all the Companies for the MCFF Code: ' || rv_mcff_list.mcff_code);
      OPEN csr_company_list;
      LOOP
        FETCH csr_company_list INTO rv_company_list;
        EXIT WHEN csr_company_list%NOTFOUND;

        -- Checking to see if there are any Invoice Headers for this Company Code
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Looking for invoice summaries for Company Code: ' ||
                      rv_company_list.company_code ||
                      '.');
        v_company_time := utils.get_date_time_at_company(rv_company_list.company_code, v_log_level + 1);

        SELECT
          COUNT(*)
        INTO
          v_inv_sum_count
        FROM
          sap_inv_sum_hdr A
        WHERE
          fkdat = TO_CHAR(v_company_time - 1, 'YYYYMMDD')
          AND bukrs = rv_company_list.company_code
          AND flag_file_status = ods_constants.inv_sum_complete;

        IF (v_inv_sum_count > 0) THEN
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'Have an invoice summary for Company Code: ' ||
                        rv_company_list.company_code ||
                        ' with creation date: ' ||
                        TO_CHAR(v_company_time - 1, 'DD-MON-YYYY') ||
                        '.');

          -- Trying to work out next run time
          v_pos_next_run_time := TO_DATE(TO_CHAR(v_company_time, 'YYYYMMDD') || ' 000000', 'YYYYMMDD HH24MISS');

          -- Set this time to equivilent box time
          -- Making sure that it is valid
          v_temp_number := get_company_timezone_offset(rv_company_list.company_timezone_code);
          IF (ABS(v_temp_number) > ods_constants.minutes_in_day) THEN
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'Offset greater than allowed maximum. Setting to zero.');
            v_temp_number := 0;
          END IF;
          v_pos_next_run_time := v_pos_next_run_time -
                                   numtodsinterval(v_temp_number, 'MINUTE');

          -- Make sure that the Invoice Sum Arrival Time offset is Valid
          v_temp_number := rv_company_list.inv_sum_arrival_time;
          IF (ABS(v_temp_number) > ods_constants.minutes_in_day) THEN
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'Offset greater than allowed maximum. Setting to zero.');
            v_temp_number := 0;
          END IF;
          -- Set this time to what it would be with invoice summary arrival offset applied
          v_pos_next_run_time := v_pos_next_run_time +
                                   numtodsinterval(v_temp_number, 'MINUTE');

          -- See if this is later in the day than the one currently stored
          IF (v_new_next_run_time < v_pos_next_run_time) THEN
            v_new_next_run_time := v_pos_next_run_time;
          END IF;

          -- Now we need to make sure that if this flag file is for 1 company
          -- only that it has not already been created.
          SELECT
            COUNT(A.company_code)
          INTO
            v_temp_number
          FROM
            company_mcff A
          WHERE
            A.mcff_code = rv_mcff_list.mcff_code;

          IF (v_temp_number = 1) THEN
            -- If there is only one company in the MCFF group, and it is the same
            -- as the mcff code, this file has already been created.
            IF (rv_company_list.company_code = rv_mcff_list.mcff_code) THEN
              utils.ods_log(v_job_type,
                            v_data_type,
                            v_sort_field,
                            v_log_level + 1,
                            'The MCFF Code: ' ||
                            rv_mcff_list.mcff_code ||
                            ' matches the Company Code: ' ||
                            rv_company_list.company_code ||
                            ' and only contains 1 Company Code.');
              utils.ods_log(v_job_type,
                            v_data_type,
                            v_sort_field,
                            v_log_level + 1,
                            'Will not create the flag file for this as it should have ' ||
                            'already been created when the summary came in.');
              v_create_combine_flag_file := FALSE;
            END IF;
          END IF;

        ELSE
          utils.ods_log(v_job_type,
                        v_data_type,
                        v_sort_field,
                        v_log_level,
                        'No invoice summary for Company Code: ' ||
                        rv_company_list.company_code ||
                        ' with creation date: ' ||
                        TO_CHAR((v_company_time - 1), 'DD-MON-YYYY') ||
                        ' found. Looking for Invoices.');

          SELECT
            COUNT(C.belnr)
          INTO
            v_inv_count
          FROM
            sap_inv_hdr A,
            sap_inv_dat B, -- Invoice Date
            sap_inv_org C  -- Invoice Sales Org
          WHERE
            A.belnr = B.belnr
            AND A.belnr = C.belnr
            AND DECODE(B.iddat, ods_constants.invoice_document_date, B.datum) = TO_CHAR((v_company_time - 1), 'YYYYMMDD') -- Invoice Creation Date
            AND DECODE(C.qualf, ods_constants.invoice_sales_org, C.orgid) = rv_company_list.company_code; -- Company Code

          IF (v_inv_count > 0) THEN
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'Have an invoices for Company Code: ' ||
                          rv_company_list.company_code ||
                          ' with creation date: ' ||
                          TO_CHAR(v_company_time - 1, 'DD-MON-YYYY') ||
                          '. Something must be wrong. Will let the Monitoring ' ||
                          'Task pick this fact up, and raise alert.');
            v_create_combine_flag_file := FALSE;
            v_set_next_run_time        := FALSE;
            -- Now Exit out of this loop
            EXIT;

          ELSE
            utils.ods_log(v_job_type,
                          v_data_type,
                          v_sort_field,
                          v_log_level,
                          'No invoices for Company Code: ' ||
                          rv_company_list.company_code ||
                          ' with creation date: ' ||
                          TO_CHAR(v_company_time - 1, 'DD-MON-YYYY') ||
                          ' found. Must be either a weekend or a public holiday.');

            -- Trying to work out next run time
            v_pos_next_run_time := TO_DATE(TO_CHAR(v_company_time, 'YYYYMMDD') || ' 000000', 'YYYYMMDD HH24MISS');

            -- Set this time to equivilent box time
            -- Making sure that it is valid
            v_temp_number := get_company_timezone_offset(rv_company_list.company_timezone_code);
            IF (ABS(v_temp_number) > ods_constants.minutes_in_day) THEN
              utils.ods_log(v_job_type,
                            v_data_type,
                            v_sort_field,
                            v_log_level,
                            'Offset greater than allowed maximum. Setting to zero.');
              v_temp_number := 0;
            END IF;
            v_pos_next_run_time := v_pos_next_run_time -
                                     numtodsinterval(v_temp_number, 'MINUTE');

            -- Make sure that the Invoice Sum Arrival Time offset is Valid
            v_temp_number := rv_company_list.inv_sum_arrival_time;
            IF (ABS(v_temp_number) > ods_constants.minutes_in_day) THEN
              utils.ods_log(v_job_type,
                            v_data_type,
                            v_sort_field,
                            v_log_level,
                            'Offset greater than allowed maximum. Setting to zero.');
              v_temp_number := 0;
            END IF;
            -- Set this time to what it would be with invoice summary arrival offset applied
            v_pos_next_run_time := v_pos_next_run_time +
                                     numtodsinterval(v_temp_number, 'MINUTE');

            -- See if this is later in the day than the one currently stored
            IF (v_new_next_run_time < v_pos_next_run_time) THEN
              v_new_next_run_time := v_pos_next_run_time;
            END IF;
          END IF;

        END IF;

      END LOOP;
      CLOSE csr_company_list;

      IF (v_create_combine_flag_file) THEN
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Sending Flag File: ' ||
                      rv_mcff_list.mcff_code ||
                      '.txt for MCFF Code: ' ||
                      rv_mcff_list.mcff_code ||
                      ' to the MFANZ BCA Queue.');
        create_and_send_flag_file(rv_mcff_list.mcff_code || '.txt',
                                  v_log_level + 1);
      END IF;

      IF (v_set_next_run_time) THEN
        -- Now setting the new Next Run Time
        utils.ods_log(v_job_type,
                      v_data_type,
                      v_sort_field,
                      v_log_level,
                      'Setting the Next Run Time for MCFF Code: ' ||
                      rv_mcff_list.mcff_code ||
                      '.');

        -- Make sure that the time has not passed
        IF (v_new_next_run_time < sysdate) THEN
          v_new_next_run_time := v_new_next_run_time + 1;
        END IF;

        -- Now update the Next Run Time in the MCFF table for this MCFF table
        UPDATE
          MCFF
        SET
          next_run_time = v_new_next_run_time
        WHERE
          mcff_code = rv_mcff_list.mcff_code;

        COMMIT;
      END IF;

    END LOOP;

    CLOSE csr_mcff_list;
    v_log_level := v_log_level - 1;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                 'Finished Scheduled Flag File Creation.');

  EXCEPTION
    WHEN others THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR SCHEDULED FLAG FILE CREATION.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      utils.send_email_to_group(v_job_type,
                                'Scheduled Flag File Creation Error on Database: ' ||
                                v_db_name,
                                'An error occured on the Database: ' ||
                                v_db_name ||
                                ', on the Server: ' ||
                                ods_constants.hostname ||
                                '.' || utl_tcp.crlf ||
                                'A Fatal Error occured during the running of the ' ||
                                'Scheduled Flag File Procedure.');

      utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                              'Scheduled Flag File Creation Failure.',
                              v_job_type);

  END scheduled_flag_file_creation;


  PROCEDURE create_and_send_flag_file(
    i_filename  IN VARCHAR2,
    i_log_level IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Delete the combined company flag file if it exists
    v_temp        VARCHAR2(4000);

    -- Setup all the logging basics
    v_job_type2   ods.log.job_type_code%TYPE := v_job_type;
    v_data_type2  ods.log.data_type%TYPE     := ods_constants.data_type_create_flag_file;
    v_sort_field2 ods.log.sort_field%TYPE    := ods_constants.data_type_create_flag_file;
    v_log_level2  ods.log.log_level%TYPE     := 0;

    -- EXCEPTION DECLARATIONS
    e_queue_load_failure EXCEPTION;

  BEGIN
    v_log_level2 := i_log_level;

    -- Get the Database name
    SELECT
      UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
    INTO
      v_db_name
    FROM
      dual;

    utils.ods_log(v_job_type2,
                  v_data_type2,
                  v_sort_field2,
                  v_log_level2,
                  'Starting Create and Send Flag File.');
    utils.ods_log(v_job_type2,
                  v_data_type2,
                  v_sort_field2,
                  v_log_level2,
                  'Removing any old flag files from the unix file system.');
    v_temp := utils.unix_command_wrapper('if [[ -e ' ||
                                         ods_constants.base_unix_directory ||
                                         '/outbound/' ||
                                         i_filename ||
                                         ' ]]; then /usr/bin/rm ' ||
                                         ods_constants.base_unix_directory ||
                                         '/outbound/' ||
                                         i_filename || '; fi',
                                         v_log_level2 + 1);

    IF (v_temp = ods_constants.error) THEN
      utils.send_email_to_group(v_job_type2,
                                'Flag File Creation/Send Error on Database: ' ||
                                v_db_name,
                                'An error occured on the Database: ' ||
                                v_db_name ||
                                ', on the Server: ' ||
                                ods_constants.hostname ||
                                '. The removal of the old BCA Flag File "' ||
                                i_filename ||
                                '" failed.');

      utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                              'Flag File Creation Failure.',
                              v_job_type2);
    END IF;

    utils.ods_log(v_job_type2,
                  v_data_type2,
                  v_sort_field2,
                  v_log_level2,
                  'Creating the new flag file.');
    -- Create the new combined flag file
    v_temp := utils.unix_command_wrapper('/usr/bin/echo > ' ||
                                         ods_constants.base_unix_directory ||
                                         '/outbound/' ||
                                         i_filename,
                                         v_log_level2 + 1);

    IF (v_temp = ods_constants.error) THEN
      utils.send_email_to_group(v_job_type2,
                                'Flag File Creation/Send Error on Database: ' ||
                                v_db_name,
                                'An error occured on the Database: ' ||
                                v_db_name ||
                                ', on the Server: ' ||
                                ods_constants.hostname ||
                                '. The creation of the BCA Flag File "' ||
                                i_filename ||
                                '" failed.');

      utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                              'Flag File Creation Failure.',
                              v_job_type2);
    END IF;

    utils.ods_log(v_job_type2,
                  v_data_type2,
                  v_sort_field2,
                  v_log_level2,
                  'Placing the flag file on the queue.');
    BEGIN
      utils.put_file_on_queue(ods_constants.base_unix_directory ||
                              '/outbound/' || i_filename,
                              ods_constants.source_queue_manager,
                              ods_constants.flag_file_dest_dir ||
                              i_filename,
                              ods_constants.destination_queue_manager,
                              v_log_level2 + 1);
    EXCEPTION
      WHEN OTHERS THEN
        utils.ods_log(v_job_type2,
                      v_data_type2,
                      v_sort_field2,
                      v_log_level2,
                      'Flag File Creation and Send failed. ' ||
                      'Sending out email and tivoli alerts.');

        -- Get the Database name
        SELECT
          UPPER(sys_context('USERENV', 'DB_NAME')) || '.WOD.AP.MARS'
        INTO
          v_db_name
        FROM
          dual;

        utils.send_email_to_group(v_job_type2,
                                  'Flag File Creation/Send Error on Database: ' ||
                                  v_db_name,
                                  'An error occured on the Database: ' ||
                                  v_db_name ||
                                  ', on the Server: ' ||
                                  ods_constants.hostname ||
                                  '. The BCA Flag File "' ||
                                  i_filename ||
                                  '" failed to be created or ' ||
                                  'placed onto the queue. The Business Objects ' ||
                                  'Reports will not start refreshing until this ' ||
                                  'file has been received.');

        utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                                'Flag File Creation Failure.',
                                v_job_type2);

        raise e_queue_load_failure;
    END;

    utils.ods_log(v_job_type2,
                  v_data_type2,
                  v_sort_field2,
                  v_log_level2,
                  'Finished Create and Send Flag File.');

  EXCEPTION
    WHEN e_queue_load_failure THEN
      utils.ods_log(v_job_type2,
                    v_data_type2,
                    v_sort_field2,
                    v_log_level2,
                    '!!!ERROR!!! - The file was not loaded onto the queue properly.');

    WHEN others THEN
      utils.ods_log(v_job_type2,
                    v_data_type2,
                    'ERROR',
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR FLAG FILE CREATE AND SEND.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

  END create_and_send_flag_file;


  FUNCTION get_company_timezone_offset (
    i_company_timezone IN V$TIMEZONE_NAMES.TZNAME%TYPE,
    i_log_level        IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN PLS_INTEGER IS

    -- VARIABLES
    v_converted_date PLS_INTEGER;

  BEGIN
    -- Now work out the time at the destination country
    SELECT
      (DECODE(SUBSTR(TZ_OFFSET(i_company_timezone), 1, 1), '+', 1, -1) *
            ((TO_NUMBER(SUBSTR(TZ_OFFSET(i_company_timezone), 2, 2)) * 60) +
              TO_NUMBER(SUBSTR(TZ_OFFSET(i_company_timezone), 5, 2))))
      - (DECODE(SUBSTR(TZ_OFFSET(ods_constants.db_timezone), 1, 1), '+', 1, -1) *
              ((TO_NUMBER(SUBSTR(TZ_OFFSET(ods_constants.db_timezone), 2, 2)) * 60) +
                TO_NUMBER(SUBSTR(TZ_OFFSET(ods_constants.db_timezone), 5, 2))))
    INTO
      v_converted_date
    FROM
      DUAL;

    RETURN v_converted_date;
  END;

END flag_file_creation;
/
