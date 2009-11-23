CREATE OR REPLACE PACKAGE ODS_APP.triggered_aggregation IS

/*******************************************************************************
  NAME:      run_triggered_aggregation
  PURPOSE:   This procedure is the main routine, which calls the other package
             procedures and functions. The procedure is triggered by the completion
             of the invoice summary data load. A message is sent to the aggregation
             pipe to wake-up, which in turn initiates the aggregation process.
             .
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this procedure.
  1.1   12/03/2008 Steve Gregan         MOD: Changed the sales fact aggregation to separate select and insert
                                             new procedure sales_fact_aggregation_v2 added
                                        MOD: Changed the sales month fact aggregation to separate select and insert
                                             new procedure sales_month_01_fact_aggregation_v2 added
                                        MOD: Changed the sales period fact aggregation to separate select and insert
                                             new procedure sales_period_01_fact_aggregation_v2 added
  1.2  15/04/2008 Kris Lee              MOD: Changed the NZ demand_plng_division_code logic 
                                              for sales_fact


  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  None

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE run_triggered_aggregation;

/*******************************************************************************
  NAME:      perform_reconciliation
  PURPOSE:   This function reconciles the invoice summary to the invoices. The
             reconciliation status is returned by this function, which is used
             to update the sap_inv_sum_hdr table, as well as the aggregtn_cntrl
             table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Creation Date                        20040101
  3    IN OUT VARCHAR2 Reconciliation Status                SUCCESS
  4    IN     NUMBER   Log Level                            1

  RETURN VALUE: ods_constants.rcncln_status_success,
                ods_constants.rcncln_status_error,
                ods_constants.rcncln_status_failed
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION perform_reconciliation (
  i_company_code IN company.company_code%TYPE,
  i_creation_date IN sap_inv_sum_hdr.fkdat%TYPE,
  io_rcncln_status IN OUT VARCHAR2,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      update_inv_sum_hdr
  PURPOSE:   This function sets previously failed records for the company code
             being aggregated to 'ERROR'.

             Note: This is an overloaded function, which just has company code
             passed into the function.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION update_inv_sum_hdr (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      update_inv_sum_hdr
  PURPOSE:   This function sets the invoice summary header rows being aggregated
             to 'INPROGRESS'.

             Note: This is an overloaded function, which has company code and
             creation date passed into the function.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Creation Date                        20040101
  3    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION update_inv_sum_hdr (
  i_company_code IN company.company_code%TYPE,
  i_creation_date IN sap_inv_sum_hdr.fkdat%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      update_inv_sum_hdr
  PURPOSE:   This function updates the invoice summary header balanced flag.
             Where there was any difference in the reconciliation the balncd_status
             will be set to 'N', else the invoice summary header balanced flag is'Y'.

             Note: This is an overloaded function, which has company code,
             creation date reconciliation status and passed into the function.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this function.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     VARCHAR2 Creation Date                        20040101
  3    IN OUT VARCHAR2 Reconciliation Status                SUCCESS
  4    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION update_inv_sum_hdr (
  i_company_code IN company.company_code%TYPE,
  i_creation_date IN sap_inv_sum_hdr.fkdat%TYPE,
  i_rcncln_status IN VARCHAR2,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      sales_fact_aggregation
  PURPOSE:   This function aggregates the sales_fact table based on the following
             invoice tables:
               - sap_inv_hdr
               - sap_inv_org
               - sap_inv_dat
               - sap_inv_gen
               - sap_inv_ipn
               - sap_inv_iob
               - sap_inv_icn

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this function.
  2.0   30/05/2006 Linden Glen          MOD: change to billed/ordered qty columns.
  3.0   19/01/2007 Paul Jacobs          Added DEMAND_PLNG_GRP_DIVISION_CODE column, due to
                                        Demand Planning Group mapping changes for DTS transactions.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION sales_fact_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      sales_fact_aggregation_v2
  PURPOSE:   This function aggregates the sales_fact table based on the following
             invoice tables:
               - sap_inv_hdr
               - sap_inv_org
               - sap_inv_dat
               - sap_inv_gen
               - sap_inv_ipn
               - sap_inv_iob
               - sap_inv_icn

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/03/2008 Steve Gregan         Created this function from the existing sales_fact_aggregation.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION sales_fact_aggregation_v2 (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      sales_month_01_aggregation
  PURPOSE:   This function aggregates the sales_month_01_fact table based on the
             sales_fact table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this function.
  1.1   19/01/2007 Paul Jacobs          Added DEMAND_PLNG_GRP_DIVISION_CODE column, due to
                                        Demand Planning Group mapping changes for DTS transactions.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION sales_month_01_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      sales_month_01_aggregation_v2
  PURPOSE:   This function aggregates the sales_month_01_fact table based on the
             sales_fact table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/03/2008 Steve Gregan         Created this function from the existing sales_month_01_aggregation.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION sales_month_01_aggregation_v2 (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      sales_period_01_aggregation
  PURPOSE:   This function aggregates the sales_period_01_fact table based on the
               sales_fact table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this function.
  1.1   19/01/2007 Paul Jacobs          Added DEMAND_PLNG_GRP_DIVISION_CODE column, due to
                                        Demand Planning Group mapping changes for DTS transactions.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION sales_period_01_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      sales_period_01_aggregation_v2
  PURPOSE:   This function aggregates the sales_period_01_fact table based on the
               sales_fact table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   12/03/2008 Steve Gregan         Created this function from the existing sales_period_01_aggregation.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Company Code                         147
  2    IN     NUMBER   Log Level                            1

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
FUNCTION sales_period_01_aggregation_v2 (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER;

/*******************************************************************************
  NAME:      write_log
  PURPOSE:   This procedure writes log entries into the log table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   23/06/2004 Paul Berude          Created this procedure.

  PARAMETERS:
  Pos  Type   Format   Description                          Example
  ---- ------ -------- ------------------------------------ --------------------
  1    IN     VARCHAR2 Job Type                             Aggregation
  2    IN     VARCHAR2 Data Type                            Invoice
  3    IN     VARCHAR2 Sort Field                           Billing Date
  4    IN     NUMBER   Log Level                            1
  5    IN     VARCHAR2 Log Text                             Starting Aggregations

  RETURN VALUE:
  ASSUMPTIONS:
  NOTES:
********************************************************************************/
PROCEDURE write_log (
  i_data_type IN VARCHAR2,
  i_sort_field IN VARCHAR2,
  i_log_level IN NUMBER,
  i_log_text IN VARCHAR2);

END triggered_aggregation;
/


/*** Package Body ***/

CREATE OR REPLACE PACKAGE BODY ODS_APP.triggered_aggregation IS

  -- COLLECTION TYPE DECLARATIONS
  TYPE rcd_creation_date IS RECORD (
    creation_date VARCHAR2(8),
    rcncln_status VARCHAR2(10));

  TYPE typ_creation_date IS TABLE OF rcd_creation_date INDEX BY VARCHAR2(8);
  tbl_creation_date typ_creation_date;
  v_index NUMBER(5);

PROCEDURE run_triggered_aggregation IS

  -- VARIABLE DECLARATIONS
  v_processing_msg constants.message_string;
  v_rcncln_status VARCHAR2(10);
  v_company_locked_flag BOOLEAN;
  v_log_level NUMBER;
  v_status NUMBER;

  v_fact_status NUMBER;
  v_month_status NUMBER;
  v_period_status NUMBER;

  -- EXCEPTION DECLARATIONS
  e_processing_error EXCEPTION;

  -- CURSOR DECLARATIONS
  -- Select company code for each invoice summary to be aggregated.
  CURSOR csr_company_code IS
    SELECT DISTINCT bukrs
    FROM sap_inv_sum_hdr
    WHERE procg_status IN
      (ods_constants.inv_sum_process, ods_constants.inv_sum_reprocess)
      AND valdtn_status = ods_constants.valdtn_valid;
    rv_company_code csr_company_code%ROWTYPE;

  -- Lock the company code row in the company table.
  CURSOR csr_lock_company IS
    SELECT company_code
    FROM company
    WHERE company_code = rv_company_code.bukrs
    FOR UPDATE NOWAIT;
    rv_lock_company csr_lock_company%ROWTYPE;

  -- Select creation dates for the company being aggregated.
  CURSOR csr_creation_date IS
    SELECT fkdat
    FROM sap_inv_sum_hdr
    WHERE bukrs = rv_company_code.bukrs
      AND procg_status IN
      (ods_constants.inv_sum_process, ods_constants.inv_sum_reprocess)
      AND valdtn_status = ods_constants.valdtn_valid;
    rv_creation_date csr_creation_date%ROWTYPE;

BEGIN

  -- Initialise variables.
  v_rcncln_status := ods_constants.rcncln_status_unchecked;
  v_company_locked_flag := FALSE;
  v_log_level := 0;

  -- Start triggered aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', v_log_level, 'Triggered Aggregations - Start');

  WHILE v_company_locked_flag = FALSE LOOP

    -- Check whether any aggregations are required.
    write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 1, 'Checking whether any aggregations are' ||
      ' required.');

    -- Open Cursor.
    OPEN csr_company_code;
    FETCH csr_company_code INTO rv_company_code;
    EXIT WHEN csr_company_code%NOTFOUND;

    WHILE csr_company_code%FOUND LOOP

    -- Begin aggregation for the company.
    write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 2, 'Aggregating Company Code [' || rv_company_code.bukrs || '].');

    -- Attempt to lock the company code row in the company table.
    BEGIN
      -- Fetch the record from the csr_lock_company cursor.
      OPEN csr_lock_company;
      FETCH csr_lock_company INTO rv_lock_company;
      CLOSE csr_lock_company;
    EXCEPTION
      WHEN OTHERS THEN
      write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 2, 'Unable to obtain lock on Company Code [' || rv_company_code.bukrs || '].');
    END;

    IF rv_lock_company.company_code IS NOT NULL THEN

        -- Successfully locked company code.
        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 3, 'Successfully locked Company Code [' || rv_company_code.bukrs || '].');

        -- Set previously failed records for the company to 'ERROR'.
        v_status := update_inv_sum_hdr(rv_company_code.bukrs, v_log_level + 3);
        IF v_status <> constants.success THEN
          v_processing_msg := 'Unable to update the sap_inv_sum_hdr table column procg_status to ''ERROR''.';
          RAISE e_processing_error;
        END IF;

        -- Initialise collection index.
        v_index := 0;

        OPEN csr_creation_date;
        LOOP
          FETCH csr_creation_date INTO rv_creation_date;
          EXIT WHEN csr_creation_date%NOTFOUND;

          -- Selecting creation dates for the company being aggregated.
          write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Selecting Creation Dates for the' ||
            ' company being aggregated.');

          -- Increment collection index.
          v_index := v_index + 1;

          -- Insert creation date and reconciliation status into the collection.
          tbl_creation_date(v_index).creation_date := rv_creation_date.fkdat;
          tbl_creation_date(v_index).rcncln_status := v_rcncln_status;

          write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Inserted Creation Date [' || rv_creation_date.fkdat || ']' ||
            ' and Reconciliation Status [' || v_rcncln_status || '] into the collection.');

          -- Set the invoice summary header rows being aggregated to 'INPROGRESS'.
          v_status := update_inv_sum_hdr(rv_company_code.bukrs,
                                         rv_creation_date.fkdat,
                                         v_log_level + 4);
          IF v_status <> constants.success THEN
            v_processing_msg := 'Unable to update the sap_inv_sum_hdr table column procg_status to ''INPROGRESS''.';
            RAISE e_processing_error;
          END IF;

        END LOOP;

        -- Initialise collection index.
        v_index := 0;

        -- Loop through and reconcile for each creation date in the collection.
        FOR RECORD IN 1..tbl_creation_date.COUNT LOOP

          -- Call the reconciliation procedure.
          write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Calling the reconciliation procedure.');

          -- Increment collection index.
          v_index := v_index + 1;

          -- Call the reconciliation procedure, returning v_rcncln_status.
          v_status := perform_reconciliation(rv_company_code.bukrs,
                                             tbl_creation_date(v_index).creation_date,
                                             v_rcncln_status,
                                             v_log_level + 4);
          IF v_status <> constants.success THEN
            v_processing_msg := 'Unable to perform reconciliation of company and creation date.';
            RAISE e_processing_error;
          END IF;

          /*
          Update the collection field rcncln_status, returned by the above procedure. Where an
          allowable difference occurred the rcncln_status will be 'SUCCESS' rather than '
          ERROR'. This is because an aggregation should still take place for the creation date.
          */
          IF v_rcncln_status IN (ods_constants.success, ods_constants.error) THEN
            tbl_creation_date(v_index).rcncln_status := ods_constants.success;
          ELSIF v_rcncln_status = ods_constants.failed THEN
            tbl_creation_date(v_index).rcncln_status := ods_constants.failed;
          END IF;

          /*
          Update the invoice summary header balanced flag.  Where there was any difference
          in the reconciliation the balncd_flag will be set to 'N'.
          */
          v_status := update_inv_sum_hdr(rv_company_code.bukrs,
                                         tbl_creation_date(v_index).creation_date,
                                         v_rcncln_status,
                                         v_log_level + 4);
          IF v_status <> constants.success THEN
            v_processing_msg := 'Unable to update the sap_inv_sum_hdr table column balncd_flag.';
            RAISE e_processing_error;
          END IF;

        END LOOP;

--        -- Calling the sales_fact_aggregation function.
--        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Calling the sales_fact_aggregation function.');
--        v_fact_status := sales_fact_aggregation(rv_company_code.bukrs, v_log_level + 4);
--        IF v_fact_status <> constants.success THEN
--          v_processing_msg := 'Unable to successfully complete the sales_fact_aggregation.';
--          RAISE e_processing_error;
--        END IF;

        -- Calling the sales_fact_aggregation_v2 function.
        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Calling the sales_fact_aggregation_v2 function.');
        v_fact_status := sales_fact_aggregation_v2(rv_company_code.bukrs, v_log_level + 4);
        IF v_fact_status <> constants.success THEN
          v_processing_msg := 'Unable to successfully complete the sales_fact_aggregation_v2.';
          RAISE e_processing_error;
        END IF;

--        -- Calling the sales_month_01_aggregation function.
--        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Calling the sales_month_01_aggregation function.');
--        v_month_status := sales_month_01_aggregation(rv_company_code.bukrs, v_log_level + 4);
--        IF v_month_status <> constants.success THEN
--          v_processing_msg := 'Unable to successfully complete the sales_month_01_aggregation.';
--          RAISE e_processing_error;
--        END IF;

        -- Calling the sales_month_01_aggregation_v2 function.
        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Calling the sales_month_01_aggregation_v2 function.');
        v_month_status := sales_month_01_aggregation_v2(rv_company_code.bukrs, v_log_level + 4);
        IF v_month_status <> constants.success THEN
          v_processing_msg := 'Unable to successfully complete the sales_month_01_aggregation_v2.';
          RAISE e_processing_error;
        END IF;

--        -- Calling the sales_period_01_aggregation function.
--        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Calling the sales_period_01_aggregation function.');
--        v_period_status := sales_period_01_aggregation(rv_company_code.bukrs, v_log_level + 4);
--        IF v_period_status <> constants.success THEN
--          v_processing_msg := 'Unable to successfully complete the sales_period_01_aggregation.';
--          RAISE e_processing_error;
--        END IF;

        -- Calling the sales_period_01_aggregation_v2 function.
        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Calling the sales_period_01_aggregation_v2 function.');
        v_period_status := sales_period_01_aggregation_v2(rv_company_code.bukrs, v_log_level + 4);
        IF v_period_status <> constants.success THEN
          v_processing_msg := 'Unable to successfully complete the sales_period_01_aggregation_v2.';
          RAISE e_processing_error;
        END IF;

        -- Delete contents from the aggregation control table, as all completed successfully.
        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Deleting the contents from the aggregation' ||
          ' control table.');
        DELETE FROM aggregtn_cntrl
        WHERE company_code = rv_company_code.bukrs;

        -- Update the processing status to 'UNFLAGGED', as all completed successfully.
        /* -- Commented out to stop flag file creation 
        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Updating the sap_inv_sum_hdr processing status' ||
          ' to ''UNFLAGGED''.');
        UPDATE sap_inv_sum_hdr
        SET procg_status = ods_constants.inv_sum_unflagged
        WHERE bukrs = rv_company_code.bukrs
          AND procg_status = ods_constants.inv_sum_inprogress
          AND valdtn_status = ods_constants.valdtn_valid;
        */
        -- Perform a commit, which will also release the lock on company code.
        COMMIT;

        -- Delete the contents of the collection, as processing has completed for the company.
        write_log(ods_constants.data_type_invoice, 'N/A', v_log_level + 4, 'Deleting the contents of the collection.');

        tbl_creation_date.DELETE;

    ELSE
      -- Unable to obtain lock on company code, therefore exit outer loop.
      v_company_locked_flag := TRUE;

    END IF;

    -- Fetch the next record in the company cursor.
    FETCH csr_company_code INTO rv_company_code;

    END LOOP;

    -- Close cursor.
    CLOSE csr_company_code;

  END LOOP;

  -- Send a message to the pipe to initiate the flag file creation process.
  --lics_pipe.spray(lics_constant.type_daemon,'FF',lics_constant.pipe_wake); -- Commented out to stop flag file creation

  -- End triggered aggregation processing.
  write_log(ods_constants.data_type_invoice, 'N/A', v_log_level, 'Triggered Aggregations - End');

EXCEPTION
  WHEN e_processing_error THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.RUN_TRIGGERED_AGGREGATION: ERROR: ' || v_processing_msg);

    -- If the aggregation process fails, flag the invoice summary as being in error.
    UPDATE sap_inv_sum_hdr
    SET procg_status = ods_constants.inv_sum_error
    WHERE bukrs = rv_company_code.bukrs
      AND procg_status = ods_constants.inv_sum_inprogress
      AND valdtn_status = ods_constants.valdtn_valid;
    COMMIT;

  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              v_log_level,
              'TRIGGERED_AGGREGATION.RUN_TRIGGERED_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
END run_triggered_aggregation;

FUNCTION update_inv_sum_hdr (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  -- Set previously failed records for the company to 'ERROR'.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Updating previously failed records for' ||
    ' the company to ''ERROR''.');
  UPDATE sap_inv_sum_hdr
  SET procg_status = ods_constants.inv_sum_error
  WHERE bukrs = i_company_code
    AND procg_status = ods_constants.inv_sum_inprogress
    AND valdtn_status = ods_constants.valdtn_valid;

  -- Commit the change of status.
  COMMIT;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.UPDATE_INV_SUM_HDR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END update_inv_sum_hdr;

FUNCTION update_inv_sum_hdr (
  i_company_code IN company.company_code%TYPE,
  i_creation_date IN sap_inv_sum_hdr.fkdat%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  -- Set the invoice summary header rows being aggregated to 'INPROGRESS'.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Updating the invoice summary header rows' ||
    ' being aggregated to ''INPROGRESS''.');
  UPDATE sap_inv_sum_hdr
  SET procg_status = ods_constants.inv_sum_inprogress
  WHERE bukrs = i_company_code
    AND fkdat = i_creation_date
    AND procg_status IN
      (ods_constants.inv_sum_process, ods_constants.inv_sum_reprocess)
    AND valdtn_status = ods_constants.valdtn_valid;

  -- Commit the change of status.
  COMMIT;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.UPDATE_INV_SUM_HDR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END update_inv_sum_hdr;

FUNCTION update_inv_sum_hdr (
  i_company_code IN company.company_code%TYPE,
  i_creation_date IN sap_inv_sum_hdr.fkdat%TYPE,
  i_rcncln_status IN VARCHAR2,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  /*
  Update the invoice summary header balanced flag.  Where there was any difference
  in the reconciliation the balncd_status will be set to 'N'.
  */
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Updating the invoice summary header' ||
    ' balanced flag.');
  IF i_rcncln_status <> ods_constants.failed THEN
    UPDATE sap_inv_sum_hdr
    SET balncd_flag = DECODE(i_rcncln_status, ods_constants.success, ods_constants.abbrd_yes,
                                              ods_constants.error, ods_constants.abbrd_no,
                                              ods_constants.failed, ods_constants.abbrd_no)
    WHERE bukrs = i_company_code
      AND fkdat = i_creation_date
      AND procg_status = ods_constants.inv_sum_inprogress
      AND valdtn_status = ods_constants.valdtn_valid;
  ELSE
    UPDATE sap_inv_sum_hdr
    SET balncd_flag = DECODE(i_rcncln_status, ods_constants.success, ods_constants.abbrd_yes,
                                              ods_constants.error, ods_constants.abbrd_no,
                                              ods_constants.failed, ods_constants.abbrd_no),
        procg_status = ods_constants.inv_sum_error
    WHERE bukrs = i_company_code
      AND fkdat = i_creation_date
      AND procg_status = ods_constants.inv_sum_inprogress
      AND valdtn_status = ods_constants.valdtn_valid;
  END IF;

  -- Commit the change of status.
  COMMIT;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.UPDATE_INV_SUM_HDR: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END;

FUNCTION perform_reconciliation (
  i_company_code IN company.company_code%TYPE,
  i_creation_date IN sap_inv_sum_hdr.fkdat%TYPE,
  io_rcncln_status IN OUT VARCHAR2,
  i_log_level IN NUMBER) RETURN NUMBER IS

  -- VARIABLE DECLARATIONS
  v_message                   VARCHAR2(4000);
  v_variance_exists           BOOLEAN;

  -- CURSOR DECLARATIONS
  -- Select invoice summary values and invoice values for reconciliation.
  CURSOR csr_sales_rcncln IS

-- IMPORTANT: PB 09/05/2005 - To be removed once Invoice Summary corrected by Atlas.

    SELECT
      creation_date,
      company_code,
      SUM(summ_count) AS summ_count,
      SUM(summ_line) AS summ_line,
      SUM(summ_value) AS summ_value,
      SUM(trans_count) AS trans_count,
      SUM(trans_line) AS trans_line,
      SUM(trans_value) AS trans_value
    FROM
     (SELECT
        a.fkdat AS creation_date,
        a.bukrs AS company_code,
        b.znumiv AS summ_count,
        b.znumps AS summ_line,
        DECODE(b.fkart,'ZRG',0,b.netwr) AS summ_value, -- PB 09/05/05: To be removed once Atlas has correct bug in Invoice Summary for ZRG Invoice Types
        0 AS trans_count,
        0 AS trans_line,
        0 AS trans_value
      FROM
        sap_inv_sum_hdr a,
        sap_inv_sum_det b
      WHERE
        a.fkdat = b.fkdat
        AND a.bukrs = b.vkorg
        AND a.bukrs = i_company_code
        AND a.fkdat = i_creation_date
    UNION ALL
      SELECT
        t1.datum AS creation_date,
        t1.orgid AS company_code,
        0 AS summ_count,
        0 AS summ_line,
        0 AS summ_value,
        SUM(trans_count) AS trans_count,
        SUM(trans_line) AS trans_line,
        SUM(trans_value) AS trans_value
      FROM
       (SELECT
          b.datum AS datum,
          c.orgid AS orgid,
          COUNT(*) AS trans_count,
          0 AS trans_line,
          0 AS trans_value
        FROM
          sap_inv_hdr a,
          sap_inv_dat b,
          sap_inv_org c
        WHERE a.valdtn_status IN (ods_constants.valdtn_valid, ods_constants.valdtn_excluded)
          AND a.belnr = b.belnr
          AND a.belnr = c.belnr
          AND b.iddat = ods_constants.invoice_document_date -- Document Date
          AND b.datum = i_creation_date
          AND c.qualf = ods_constants.invoice_sales_org -- Sales Organisation
          AND c.orgid = i_company_code
        GROUP BY
          b.datum,
          c.orgid
        UNION
        SELECT
          b.datum AS datum,
          c.orgid AS orgid,
          0 AS trans_count,
          COUNT(*) AS trans_line,
          0 AS trans_value
        FROM
          sap_inv_hdr a,
          sap_inv_dat b,
          sap_inv_org c,
          sap_inv_gen d
        WHERE a.valdtn_status IN (ods_constants.valdtn_valid, ods_constants.valdtn_excluded)
          AND a.belnr = b.belnr
          AND a.belnr = c.belnr
          AND a.belnr = d.belnr
          AND b.iddat = ods_constants.invoice_document_date -- Document Date
          AND b.datum = i_creation_date
          AND c.qualf = ods_constants.invoice_sales_org -- Sales Organisation
          AND c.orgid = i_company_code
        GROUP BY
          b.datum,
          c.orgid
        UNION
        SELECT
          b.datum AS datum,
          c.orgid AS orgid,
          0 AS trans_count,
          0 AS trans_line,
          SUM(DECODE(SIGN(INSTR(d.summe,'-',1,1)),1,-1,1) * trim('-' FROM d.summe)) AS trans_value
        FROM
          sap_inv_hdr a,
          sap_inv_dat b,
          sap_inv_org c,
          sap_inv_smy d,
          sap_inv_org e  -- PB 09/05/05: To be removed once Atlas has correct bug in Invoice Summary for ZRG Invoice Types
        WHERE a.valdtn_status IN (ods_constants.valdtn_valid, ods_constants.valdtn_excluded)
          AND a.belnr = b.belnr
          AND b.iddat = ods_constants.invoice_document_date -- Document Date
          AND b.datum = i_creation_date
          AND a.belnr = c.belnr
          AND c.qualf = ods_constants.invoice_sales_org -- Sales Organisation
          AND c.orgid = i_company_code
          AND a.belnr = d.belnr
          AND d.sumid = ods_constants.invoice_smy_qualifier -- Get SMY values to balance to summary
          and a.belnr = e.belnr   -- PB 09/05/05: To be removed once Atlas has correct bug in Invoice Summary for ZRG Invoice Types
          and e.qualf = '015'   -- PB 09/05/05: To be removed once Atlas has correct bug in Invoice Summary for ZRG Invoice Types
          and e.orgid <> 'ZRG'   -- PB 09/05/05: To be removed once Atlas has correct bug in Invoice Summary for ZRG Invoice Types
        GROUP BY
           b.datum,
           c.orgid) t1
      GROUP BY
        t1.datum,
        t1.orgid)
    GROUP BY
      creation_date,
      company_code;

/*
    SELECT
      creation_date,
      company_code,
      SUM(summ_count) AS summ_count,
      SUM(summ_line) AS summ_line,
      SUM(summ_value) AS summ_value,
      SUM(trans_count) AS trans_count,
      SUM(trans_line) AS trans_line,
      SUM(trans_value) AS trans_value
    FROM
     (SELECT
        a.fkdat AS creation_date,
        a.bukrs AS company_code,
        b.znumiv AS summ_count,
        b.znumps AS summ_line,
        b.netwr AS summ_value,
        0 AS trans_count,
        0 AS trans_line,
        0 AS trans_value
      FROM
        sap_inv_sum_hdr a,
        sap_inv_sum_det b
      WHERE
        a.fkdat = b.fkdat
        AND a.bukrs = b.vkorg
        AND a.bukrs = i_company_code
        AND a.fkdat = i_creation_date
    UNION ALL
      SELECT
        t1.datum AS creation_date,
        t1.orgid AS company_code,
        0 AS summ_count,
        0 AS summ_line,
        0 AS summ_value,
        SUM(trans_count) AS trans_count,
        SUM(trans_line) AS trans_line,
        SUM(trans_value) AS trans_value
      FROM
       (SELECT
          b.datum AS datum,
          c.orgid AS orgid,
          COUNT(*) AS trans_count,
          0 AS trans_line,
          0 AS trans_value
        FROM
          sap_inv_hdr a,
          sap_inv_dat b,
          sap_inv_org c
        WHERE a.valdtn_status IN (ods_constants.valdtn_valid, ods_constants.valdtn_excluded)
          AND a.belnr = b.belnr
          AND a.belnr = c.belnr
          AND b.iddat = ods_constants.invoice_document_date -- Document Date
          AND b.datum = i_creation_date
          AND c.qualf = ods_constants.invoice_sales_org -- Sales Organisation
          AND c.orgid = i_company_code
        GROUP BY
          b.datum,
          c.orgid
        UNION
        SELECT
          b.datum AS datum,
          c.orgid AS orgid,
          0 AS trans_count,
          COUNT(*) AS trans_line,
          0 AS trans_value
        FROM
          sap_inv_hdr a,
          sap_inv_dat b,
          sap_inv_org c,
          sap_inv_gen d
        WHERE a.valdtn_status IN (ods_constants.valdtn_valid, ods_constants.valdtn_excluded)
          AND a.belnr = b.belnr
          AND a.belnr = c.belnr
          AND a.belnr = d.belnr
          AND b.iddat = ods_constants.invoice_document_date -- Document Date
          AND b.datum = i_creation_date
          AND c.qualf = ods_constants.invoice_sales_org -- Sales Organisation
          AND c.orgid = i_company_code
        GROUP BY
          b.datum,
          c.orgid
        UNION
        SELECT
          b.datum AS datum,
          c.orgid AS orgid,
          0 AS trans_count,
          0 AS trans_line,
          SUM(DECODE(SIGN(INSTR(d.summe,'-',1,1)),1,-1,1) * trim('-' FROM d.summe)) AS trans_value
        FROM
          sap_inv_hdr a,
          sap_inv_dat b,
          sap_inv_org c,
          sap_inv_smy d
        WHERE a.valdtn_status IN (ods_constants.valdtn_valid, ods_constants.valdtn_excluded)
          AND a.belnr = b.belnr
          AND b.iddat = ods_constants.invoice_document_date -- Document Date
          AND b.datum = i_creation_date
          AND a.belnr = c.belnr
          AND c.qualf = ods_constants.invoice_sales_org -- Sales Organisation
          AND c.orgid = i_company_code
          AND a.belnr = d.belnr
          AND d.sumid = ods_constants.invoice_smy_qualifier -- Get SMY values to balance to summary
        GROUP BY
           b.datum,
           c.orgid) t1
      GROUP BY
        t1.datum,
        t1.orgid)
    GROUP BY
      creation_date,
      company_code;
*/
    rv_sales_rcncln csr_sales_rcncln%ROWTYPE;

  -- Select the allowable variance for the company.
  CURSOR csr_allowable_variance IS
    SELECT invc_summ_abs_var, invc_summ_pctg_var
    FROM company
    WHERE company_code = i_company_code;
    rv_allowable_variance csr_allowable_variance%ROWTYPE;

BEGIN

  -- Performing reconciliation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Performing reconciliation for' ||
    ' Company Code [' || i_company_code || '] and' ||
    ' Creation Date [' || i_creation_date || '].');

  -- Fetch the record from the csr_sales_rcncln cursor.
  OPEN csr_sales_rcncln;
  FETCH csr_sales_rcncln INTO rv_sales_rcncln.creation_date,
                              rv_sales_rcncln.company_code,
                              rv_sales_rcncln.summ_count,
                              rv_sales_rcncln.summ_line,
                              rv_sales_rcncln.summ_value,
                              rv_sales_rcncln.trans_count,
                              rv_sales_rcncln.trans_line,
                              rv_sales_rcncln.trans_value;
  CLOSE csr_sales_rcncln;

  -- Check whether there is a difference between the summary and invoice values.
  IF rv_sales_rcncln.summ_value <> rv_sales_rcncln.trans_value OR
     rv_sales_rcncln.summ_line <> rv_sales_rcncln.trans_line OR
     rv_sales_rcncln.summ_count <> rv_sales_rcncln.trans_count THEN

    -- Difference exists between the summary and invoices.
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Difference exists between summary and invoices.');

    -- Fetch the record from the csr_allowable_variance cursor.
    OPEN csr_allowable_variance;
    FETCH csr_allowable_variance INTO rv_allowable_variance.invc_summ_abs_var,
                                      rv_allowable_variance.invc_summ_pctg_var;
    CLOSE csr_allowable_variance;

    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'rv_sales_rcncln.trans_value:              ' || TO_CHAR(rv_sales_rcncln.trans_value,'FM9999999999990.0000'));
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'rv_sales_rcncln.summ_value:               ' || TO_CHAR(rv_sales_rcncln.summ_value,'FM9999999999990.0000'));
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'rv_allowable_variance.invc_summ_abs_var:  ' || TO_CHAR(rv_allowable_variance.invc_summ_abs_var,'FM9999999999990.0000'));
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'rv_allowable_variance.invc_summ_pctg_var: ' || TO_CHAR(rv_allowable_variance.invc_summ_pctg_var,'FM9999990.0000'));

    -- Check whether the difference is greater than the allowable variance.
    IF rv_sales_rcncln.summ_value = 0 THEN
      IF ABS(rv_sales_rcncln.trans_value - rv_sales_rcncln.summ_value) > 0 THEN
        v_variance_exists := TRUE;
      ELSE
        v_variance_exists := FALSE;   -- summary is zero and trans = 0 so no issue.
      END IF;
    ELSIF ABS(rv_sales_rcncln.trans_value - rv_sales_rcncln.summ_value) > rv_allowable_variance.invc_summ_abs_var THEN
      v_variance_exists := TRUE;
    ELSIF ABS(ROUND((rv_sales_rcncln.trans_value - rv_sales_rcncln.summ_value) / rv_sales_rcncln.summ_value, 2)) > rv_allowable_variance.invc_summ_pctg_var THEN
      v_variance_exists := TRUE;
    ELSE
      v_variance_exists := FALSE;
    END IF;

    -- If there is a greater than allowable variance...
    IF v_variance_exists = TRUE THEN

      -- Difference is greater than the allowable variance, therefore set status to 'FAILED'.
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 3, 'Difference is greater than the allowable' ||
        ' variance, therefore set status to "FAILED".');

      io_rcncln_status := ods_constants.failed;

      -- Send alert message via Tivoli.
      utils.send_tivoli_alert(ods_constants.tivoli_alert_level_critical,
                              'Fatal Error occurred during Triggered Aggregation Reconciliation.',
                              ods_constants.job_type_trig_aggregation,
                              i_company_code);

      -- Send alert message via E-mail. Included in the message are the variances.
      v_message := 'Warning: Invoice Summary / Invoices imbalance: ' ||
        rv_sales_rcncln.company_code || ' / ' || rv_sales_rcncln.creation_date || '. ' || CHR(13) ||
        '  Invoice Summary/Invoice Count [' || rv_sales_rcncln.summ_count || '] / [' || rv_sales_rcncln.trans_count || '].' || CHR(13) ||
        '  Invoice Summary/Invoice Line Count [' || rv_sales_rcncln.summ_line || '] / [' || rv_sales_rcncln.trans_line || '].' || CHR(13) ||
        '  Invoice Summary/Invoice Value [' || rv_sales_rcncln.summ_value || '] / [' || rv_sales_rcncln.trans_value || '].';

      utils.send_email_to_group(ods_constants.job_type_trig_aggregation,
                                'MFANZ CDW Invoice Summary Reconciliation' || rv_sales_rcncln.company_code || ' / ' || rv_sales_rcncln.creation_date,
                                v_message);

    ELSE
      /*
      Difference is within the allowable variance, therefore set the status to 'ERROR' so that
      the aggregation will take place for this creation date.  However, an error message will
      be sent and the invoice summary header balance flag will be updated to indicate that a
      difference exists.
      */
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 3, 'Difference is within the allowable' ||
        ' variance, therefore set the status to ''ERROR''.');

      io_rcncln_status := ods_constants.error;

      -- Send alert message via E-mail. Included in the message are the variances.
      v_message := 'Warning: Invoice Summary / Invoices imbalance: ' ||
        rv_sales_rcncln.company_code || ' / ' || rv_sales_rcncln.creation_date || '. ' || CHR(13) ||
        ' Invoice Summary/Invoice Count [' || rv_sales_rcncln.summ_count || '] / [' || rv_sales_rcncln.trans_count || '].' || CHR(13) ||
        ' Invoice Summary/Invoice Line Count [' || rv_sales_rcncln.summ_line || '] / [' || rv_sales_rcncln.trans_line || '].' || CHR(13) ||
        ' Invoice Summary/Invoice Value [' || rv_sales_rcncln.summ_value || '] / [' || rv_sales_rcncln.trans_value || '].';

      utils.send_email_to_group(ods_constants.job_type_trig_aggregation,
                                'MFANZ CDW Invoice Summary Reconciliation' || rv_sales_rcncln.company_code || ' / ' || rv_sales_rcncln.creation_date,
                                v_message);

    END IF;

  ELSE

    -- Reconciled sucessfully, therefore update the status to 'SUCCESS'.
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Reconciled sucessfully, therefore update' ||
      ' the status to ''SUCCESS''.');

    io_rcncln_status := ods_constants.success;

  END IF;

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.PERFORM_RECONCILIATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END perform_reconciliation;

FUNCTION sales_fact_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- VARIABLE DECLARATIONS
  v_sales_fact_billing_date VARCHAR2(10);

BEGIN

  -- Starting sales_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Starting SALES_FACT_OLD aggregation.');

  -- Initialise collection index.
  v_index := 0;

  -- Loop through and aggregate for each creation date in the collection.
  FOR RECORD IN 1..tbl_creation_date.COUNT LOOP

    -- Increment collection index.
    v_index := v_index + 1;

    -- Aggregate only the creation dates that are within the allowable variance.
    IF tbl_creation_date(v_index).rcncln_status = ods_constants.rcncln_status_success THEN

      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Aggregating Creation Date [' ||
        '' || tbl_creation_date(v_index).creation_date || '], which has a' ||
        ' Reconciliation Status of [' || tbl_creation_date(v_index).rcncln_status ||'].');

      /*
      Select all billing dates from the sales_fact table for the creation date and either
      update or insert into the aggregation control table.
      */
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Selecting Billing Dates from the' ||
        ' sales_fact_old table, in order to insert or update into the aggregation control table.');
      MERGE INTO aggregtn_cntrl a
      USING (SELECT DISTINCT company_code, billing_eff_date FROM dds.sales_fact_old
      WHERE company_code = i_company_code
        AND creatn_date = TO_DATE(tbl_creation_date(v_index).creation_date, 'YYYYMMDD')) b
      ON (a.company_code = b.company_code
      AND a.billing_eff_date = TO_CHAR(b.billing_eff_date,'YYYYMMDD'))
      WHEN MATCHED THEN UPDATE SET a.aggregtn_cntrl_lupdp = USER,
        a.aggregtn_cntrl_lupdt = SYSDATE
      WHEN NOT MATCHED THEN INSERT (a.company_code, a.billing_eff_date,
        a.aggregtn_cntrl_lupdp, a.aggregtn_cntrl_lupdt)
      VALUES (b.company_code, TO_CHAR(b.billing_eff_date,'YYYYMMDD'),
        USER, SYSDATE);

      -- Commit.
      COMMIT;

      /*
      Select all billing dates from the sap_inv_* tables for the creation date and either
      update or insert into the aggregation control table.
      */
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Selecting Billing Dates from the' ||
        ' sap_inv_* tables, in order to insert or update into the aggregation control table.');
      MERGE INTO aggregtn_cntrl a
      USING (SELECT DISTINCT t2.orgid AS company_code, -- Sales Organisation
        t4.datum AS billing_eff_date -- Billing Date
      FROM sap_inv_hdr t1, sap_inv_org t2, sap_inv_dat t3, sap_inv_dat t4
      WHERE t1.belnr = t2.belnr
        AND t1.belnr = t3.belnr
            AND t1.belnr = t4.belnr
        AND t2.qualf = ods_constants.invoice_sales_org -- Sales Organisation
        AND t2.orgid = i_company_code
        AND t3.iddat = ods_constants.invoice_document_date  -- Document Date
        AND t3.datum = (tbl_creation_date(v_index).creation_date)
        AND t4.iddat = ods_constants.invoice_billing_date -- Billing Date
        AND t1.valdtn_status =  ods_constants.valdtn_valid) b
      ON (a.company_code = b.company_code
      AND a.billing_eff_date = b.billing_eff_date)
      WHEN MATCHED THEN UPDATE SET a.aggregtn_cntrl_lupdp = USER,
        a.aggregtn_cntrl_lupdt = SYSDATE
      WHEN NOT MATCHED THEN INSERT (a.company_code, a.billing_eff_date,
        a.aggregtn_cntrl_lupdp, aggregtn_cntrl_lupdt)
      VALUES (b.company_code, b.billing_eff_date,
        USER, SYSDATE);

      -- Commit.
      COMMIT;

      -- Create a savepoint.
      SAVEPOINT sales_fact_savepoint;

      -- Delete from the sales_fact table based on company code and creation date.
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Deleting from SALES_FACT_OLD based on' ||
        ' Company Code [' || i_company_code || '] and Creation Date [' || tbl_creation_date(v_index).creation_date || '].');
      DELETE FROM dds.sales_fact_old
      WHERE company_code = i_company_code
        AND creatn_date = TO_DATE(tbl_creation_date(v_index).creation_date, 'YYYYMMDD');

      -- Insert into sales_fact table based on company code and creation date.
      --
      -- IMPORTANT NOTE: the following line in the GSV calculation needs to be understood:
      --      DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg)
      -- The logic is:
      --      (IF ZZ01 doesn't exists THEN 0 ELSE 1) * INVOICE_VALUE.VALUE * INVOICE_VALUE.SIGN
      -- That is, if the price has ben overridden (ZZ01 exists) then GSV equals the invoice value pricing line.
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Inserting into the SALES_FACT_OLD table.');
      INSERT INTO dds.sales_fact_old
        (
        company_code,
        billing_doc_num,
        billing_doc_line_num,
        order_doc_num,
        order_doc_line_num,
        purch_order_doc_num,
        purch_order_doc_line_num,
        dlvry_doc_num,
        dlvry_doc_line_num,
        order_type_code,
        invc_type_code,
        creatn_date,
        creatn_yyyyppdd,
        billing_eff_date,
        billing_eff_yyyymm,
        billing_eff_yyyypp,
        billing_eff_yyyyppdd,
        billing_eff_yyyyppw,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        order_qty,
        billed_qty,
        base_uom_billed_qty,
        billed_qty_gross_tonnes,
        billed_qty_net_tonnes,
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        gsv,
        gsv_xactn,
        gsv_aud,
        gsv_usd,
        gsv_eur,
        niv,
        niv_xactn,
        niv_aud,
        niv_usd,
        niv_eur,
        ngv,
        ngv_xactn,
        ngv_aud,
        ngv_usd,
        ngv_eur,
        mfanz_icb_flag,
        demand_plng_grp_division_code
        )
        SELECT
          b.orgid AS company_code,
          a.belnr AS billing_doc_num,
          d.posex AS billing_doc_line_num,
          ag.refnr AS order_doc_num,      -- Order document number
          ag.zeile AS order_doc_line_num, -- Order document line number
          NULL AS purch_order_doc_num, -- default value is NULL, column added for future requirements
          NULL AS purch_order_doc_line_num,  -- default value is NULL, column added for future requirements
          ah.refnr AS dlvry_doc_num,      -- Delivery document number
          ah.zeile AS dlvry_doc_line_num, -- Delivery document line number
          e.orgid AS order_type_code,
          f.orgid AS invc_type_code,
          TO_DATE(c.datum,'YYYYMMDD') AS creatn_date,
          ai.mars_yyyyppdd AS creatn_YYYYPPDD,  -- Creation YYYYPPDD
          TO_DATE(g.datum,'YYYYMMDD') AS billing_eff_date,
          TRUNC(h.yyyymmdd_date/100) AS billing_eff_yyyymm,
          h.mars_period AS billing_eff_yyyypp,
          h.mars_yyyyppdd AS billing_eff_yyyyppdd,
          h.mars_week AS billing_eff_yyyyppw,   -- Billing Effective YYYYPPW
          i.orgid AS hdr_sales_org_code,
          j.orgid AS hdr_distbn_chnl_code,
          k.orgid AS hdr_division_code,
          a.curcy AS doc_currcy_code,
          z.company_currcy AS company_currcy_code,
          a.wkurs AS exch_rate,
          a.augru AS order_reason_code,
          DECODE(l.partn, NULL, u.partn, l.partn) AS sold_to_cust_code,
          DECODE(m.partn, NULL, v.partn, m.partn) AS bill_to_cust_code,
          DECODE(n.partn, NULL, w.partn, n.partn) AS payer_cust_code,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.kwmeng,0) AS order_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.menge,0) AS billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.fklmg,0)  AS base_uom_billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.brgew,
                                                                  ods_constants.uom_kilograms, d.brgew / 1000,
                                                                  ods_constants.uom_grams, d.brgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.brgew / 1000000000,
                                                                  0),0) AS billed_qty_gross_tonnes,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.ntgew,
                                                                  ods_constants.uom_kilograms, d.ntgew / 1000,
                                                                  ods_constants.uom_grams, d.ntgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.ntgew / 1000000000,
                                                                  0),0) AS billed_qty_net_tonnes,
          DECODE(o.partn, NULL, x.partn, o.partn) AS ship_to_cust_code,
          LTRIM(p.idtnr, 0) AS matl_code,
          LTRIM(q.idtnr, 0) AS matl_entd,
          d.menee AS billed_qty_uom_code,
          d.meins AS billed_qty_base_uom_code,
          d.werks AS plant_code,
          d.lgort AS storage_locn_code,
          d.vkorg AS gen_sales_org_code,
          d.vtweg AS gen_distbn_chnl_code,
          d.spart AS gen_division_code,
          d.abrvw AS order_usage_code,
          DECODE(y.invc_type_sign,'-',-1,1) /
                 exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs) AS gsv,     -- GSV Market Currency
          DECODE(y.invc_type_sign,'-',-1,1) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg)) AS gsv_xactn,              -- GSV Transaction Currency
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_aud,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_aud,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_usd,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_usd,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_eur,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_eur,
          0 AS niv,
          0 AS niv_xactn,
          0 AS niv_aud,
          0 AS niv_usd,
          0 AS niv_eur,
          0 AS ngv,
          0 AS ngv_xactn,
          0 AS ngv_aud,
          0 AS ngv_usd,
          0 AS ngv_eur,
          DECODE(b.orgid, ods_constants.company_australia, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.abbrd_no),
                          ods_constants.company_new_zealand, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.abbrd_no),
                          ods_constants.abbrd_no) AS mfanz_icb_flag,
          DECODE(b.orgid || j.orgid, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(aj.bus_sgmnt_code, '01', '55', 
                                                                                                                                            '02', '57', 
                                                                                                                                            '05', '56', k.orgid),
                                                                                                                  DECODE(k.orgid, '57', DECODE(aj.bus_sgmnt_code, '02', '57', '05', '56', k.orgid), k.orgid)) demand_plng_grp_division_code
        FROM
          sap_inv_hdr a,
          sap_inv_org b,
          sap_inv_dat c,
          sap_inv_gen d,
          sap_inv_org e,
          sap_inv_org f,
          sap_inv_dat g,
          mars_date h,
          sap_inv_org i,
          sap_inv_org j,
          sap_inv_org k,
          sap_inv_ipn l,
          sap_inv_ipn m,
          sap_inv_ipn n,
          sap_inv_ipn o,
          sap_inv_iob p,
          sap_inv_iob q,
          sap_mat_uom r,
          sap_inv_icn t,
          sap_inv_pnr u,
          sap_inv_pnr v,
          sap_inv_pnr w,
          sap_inv_pnr x,
          invc_type y,
          company z,
          sap_inv_icn aa,
          sap_inv_icn ab,
          sap_inv_icn ac,
          sap_inv_icn ad,
          sap_inv_icn ae,
          order_usage af,
          sap_inv_irf ag,
          sap_inv_irf ah,
          mars_date ai,
          matl_dim aj
        WHERE
          b.belnr = a.belnr
          AND b.qualf = ods_constants.invoice_sales_org AND b.orgid = i_company_code -- b Sales Organisation
          AND c.belnr = a.belnr AND c.iddat = ods_constants.invoice_document_date AND c.datum = tbl_creation_date(v_index).creation_date -- c Document Date
          AND d.belnr = a.belnr -- d Invoice Line
          AND d.belnr = ag.belnr (+)   -- ag Order document number
          AND d.genseq = ag.genseq (+) -- ag Order document line number
          AND ag.qualf (+) = ods_constants.invoice_sales_order_flag
          AND d.belnr = ah.belnr (+)   -- ah Delivery document number
          AND d.genseq = ah.genseq (+) -- ah Delivery document line number
          AND ah.qualf (+) = ods_constants.invoice_delivery_flag
          AND c.datum = ai.yyyymmdd_date -- ai Creation YYYYPPDD
          AND e.belnr (+) = a.belnr AND e.qualf (+) = ods_constants.invoice_order_type -- e Order Type Code
          AND f.belnr (+) = a.belnr AND f.qualf (+) = ods_constants.invoice_invoice_type -- f Invoice Type Code
          AND g.belnr = a.belnr AND g.iddat = ods_constants.invoice_billing_date -- g Billing Effectivity Date
          AND h.yyyymmdd_date = g.datum -- h Billing Date (YYYYPPDD)
          AND i.belnr (+) = a.belnr AND i.qualf (+) = ods_constants.invoice_sales_org -- i Header Sales Organisation
          AND j.belnr (+) = a.belnr AND j.qualf (+) = ods_constants.invoice_distbn_chnl  -- j Header Distribution Channel
          AND k.belnr (+) = a.belnr AND k.qualf (+) = ods_constants.invoice_division -- k Header Division
          AND l.belnr (+) = d.belnr AND l.genseq (+) = d.genseq AND l.parvw (+) = ods_constants.invoice_sold_to_partner -- l Sold To (Partner - Detail record)
          AND m.belnr (+) = d.belnr AND m.genseq (+) = d.genseq AND m.parvw (+) = ods_constants.invoice_bill_to_partner -- m Bill To (Partner - Detail record)
          AND n.belnr (+) = d.belnr AND n.genseq (+) = d.genseq AND n.parvw (+) = ods_constants.invoice_payer_partner -- n Payer (Partner - Detail record)
          AND o.belnr (+) = d.belnr AND o.genseq (+) = d.genseq AND o.parvw (+) = ods_constants.invoice_ship_to_partner -- o Ship To (Partner - Detail record)
          AND p.belnr (+) = d.belnr AND p.genseq (+) = d.genseq AND p.qualf (+) = ods_constants.invoice_material_code -- p Material Code
          AND q.belnr (+) = d.belnr AND q.genseq (+) = d.genseq AND q.qualf (+) = ods_constants.invoice_material_entered -- q Material Entered
          AND r.matnr (+) = p.idtnr AND r.meinh = d.menee -- r BUOM factors
                                                                              --   .. the above joins material and UOM code into
                                                                              --      the sap_mat_uom to get BUOM conversion factors
          AND t.belnr (+) = d.belnr AND t.genseq (+) = d.genseq AND t.kotxt (+) = ods_constants.invoice_gsv
          AND a.belnr = u.belnr (+) AND u.parvw (+) = ods_constants.invoice_sold_to_partner -- u Sold-To (Partner - Header record)
          AND a.belnr = v.belnr (+) AND v.parvw (+) = ods_constants.invoice_bill_to_partner -- v Bill-To (Partner - Header record)
          AND a.belnr = w.belnr (+) AND w.parvw (+) = ods_constants.invoice_payer_partner -- w Payer (Partner - Header record)
          AND a.belnr = x.belnr (+) AND x.parvw (+) = ods_constants.invoice_ship_to_partner -- x Ship-To (Partner - Header record)
          AND f.orgid = y.invc_type_code (+)
          AND f.orgid NOT IN ('ZIV', 'ZIVR', 'ZIVS')
          AND z.company_code = i_company_code
          AND aa.belnr (+) = d.belnr AND aa.genseq (+) = d.genseq AND aa.kschl (+) = ods_constants.invoice_zv01
          AND ab.belnr (+) = d.belnr AND ab.genseq (+) = d.genseq AND ab.kschl (+) = ods_constants.invoice_zr03
          AND ac.belnr (+) = d.belnr AND ac.genseq (+) = d.genseq AND ac.kschl (+) = ods_constants.invoice_zr04
          AND ad.belnr (+) = d.belnr AND ad.genseq (+) = d.genseq AND ad.kschl (+) = ods_constants.invoice_zz01
          AND ae.belnr (+) = d.belnr AND ae.genseq (+) = d.genseq AND ae.kotxt (+) = ods_constants.invoice_gross_value
          AND af.order_usage_code(+) = d.abrvw
          AND LTRIM(p.idtnr, 0) = aj.matl_code (+)
          AND NVL(af.order_usage_gsv_flag,ods_constants.gsv_flag_gsv) = ods_constants.gsv_flag_gsv
          AND a.valdtn_status = ods_constants.valdtn_valid
        UNION
        SELECT
          b.orgid AS company_code,
          a.belnr AS billing_doc_num,
          d.posex AS billing_doc_line_num,
          NULL AS order_doc_num,      -- Order document number
          NULL AS order_doc_line_num, -- Order document line number
          ag.refnr AS purch_order_doc_num, -- default value is NULL, column added for future requirements
          ag.zeile AS purch_order_doc_line_num,  -- default value is NULL, column added for future requirements
          ah.refnr AS dlvry_doc_num,      -- Delivery document number
          ah.zeile AS dlvry_doc_line_num, -- Delivery document line number
          e.orgid AS order_type_code,
          f.orgid AS invc_type_code,
          TO_DATE(c.datum,'YYYYMMDD') AS creatn_date,
          ai.mars_yyyyppdd AS creatn_YYYYPPDD,  -- Creation YYYYPPDD
          TO_DATE(g.datum,'YYYYMMDD') AS billing_eff_date,
          TRUNC(h.yyyymmdd_date/100) AS billing_eff_yyyymm,
          h.mars_period AS billing_eff_yyyypp,
          h.mars_yyyyppdd AS billing_eff_yyyyppdd,
          h.mars_week AS billing_eff_yyyyppw,   -- Billing Effective YYYYPPW
          i.orgid AS hdr_sales_org_code,
          j.orgid AS hdr_distbn_chnl_code,
          k.orgid AS hdr_division_code,
          a.curcy AS doc_currcy_code,
          z.company_currcy AS company_currcy_code,
          a.wkurs AS exch_rate,
          a.augru AS order_reason_code,
          DECODE(l.partn, NULL, u.partn, l.partn) AS sold_to_cust_code,
          DECODE(m.partn, NULL, v.partn, m.partn) AS bill_to_cust_code,
          DECODE(n.partn, NULL, w.partn, n.partn) AS payer_cust_code,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.kwmeng,0) AS order_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.menge,0) AS billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.fklmg,0)  AS base_uom_billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.brgew,
                                                                  ods_constants.uom_kilograms, d.brgew / 1000,
                                                                  ods_constants.uom_grams, d.brgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.brgew / 1000000000,
                                                                  0),0) AS billed_qty_gross_tonnes,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.ntgew,
                                                                  ods_constants.uom_kilograms, d.ntgew / 1000,
                                                                  ods_constants.uom_grams, d.ntgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.ntgew / 1000000000,
                                                                  0),0) AS billed_qty_net_tonnes,
          DECODE(o.partn, NULL, x.partn, o.partn) AS ship_to_cust_code,
          LTRIM(p.idtnr, 0) AS matl_code,
          LTRIM(q.idtnr, 0) AS matl_entd,
          d.menee AS billed_qty_uom_code,
          d.meins AS billed_qty_base_uom_code,
          d.werks AS plant_code,
          d.lgort AS storage_locn_code,
          d.vkorg AS gen_sales_org_code,
          d.vtweg AS gen_distbn_chnl_code,
          d.spart AS gen_division_code,
          d.abrvw AS order_usage_code,
          DECODE(y.invc_type_sign,'-',-1,1) /
                 exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs) AS gsv,     -- GSV Market Currency
          DECODE(y.invc_type_sign,'-',-1,1) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg)) AS gsv_xactn,              -- GSV Transaction Currency
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_aud,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_aud,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_usd,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_usd,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_eur,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_eur,
          0 AS niv,
          0 AS niv_xactn,
          0 AS niv_aud,
          0 AS niv_usd,
          0 AS niv_eur,
          0 AS ngv,
          0 AS ngv_xactn,
          0 AS ngv_aud,
          0 AS ngv_usd,
          0 AS ngv_eur,
          DECODE(b.orgid, ods_constants.company_australia, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.abbrd_no),
                          ods_constants.company_new_zealand, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.abbrd_no),
                          ods_constants.abbrd_no) AS mfanz_icb_flag,
          DECODE(b.orgid || j.orgid, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(aj.bus_sgmnt_code, '01', '55', 
                                                                                                                                            '02', '57', 
                                                                                                                                            '05', '56', k.orgid),
                                                                                                                  DECODE(k.orgid, '57', DECODE(aj.bus_sgmnt_code, '02', '57', '05', '56', k.orgid), k.orgid)) demand_plng_grp_division_code
        FROM
          sap_inv_hdr a,
          sap_inv_org b,
          sap_inv_dat c,
          sap_inv_gen d,
          sap_inv_org e,
          sap_inv_org f,
          sap_inv_dat g,
          mars_date h,
          sap_inv_org i,
          sap_inv_org j,
          sap_inv_org k,
          sap_inv_ipn l,
          sap_inv_ipn m,
          sap_inv_ipn n,
          sap_inv_ipn o,
          sap_inv_iob p,
          sap_inv_iob q,
          sap_mat_uom r,
          sap_inv_icn t,
          sap_inv_pnr u,
          sap_inv_pnr v,
          sap_inv_pnr w,
          sap_inv_pnr x,
          invc_type y,
          company z,
          sap_inv_icn aa,
          sap_inv_icn ab,
          sap_inv_icn ac,
          sap_inv_icn ad,
          sap_inv_icn ae,
          order_usage af,
          sap_inv_irf ag,
          sap_inv_irf ah,
          mars_date ai,
          matl_dim aj
        WHERE
          b.belnr = a.belnr
          AND b.qualf = ods_constants.invoice_sales_org AND b.orgid = i_company_code -- b Sales Organisation
          AND c.belnr = a.belnr AND c.iddat = ods_constants.invoice_document_date AND c.datum = tbl_creation_date(v_index).creation_date -- c Document Date
          AND d.belnr = a.belnr -- d Invoice Line
          AND d.belnr = ag.belnr (+)   -- ag Order document number
          AND d.genseq = ag.genseq (+) -- ag Order document line number
          AND ag.qualf (+) = ods_constants.invoice_sales_order_flag
          AND d.belnr = ah.belnr (+)   -- ah Delivery document number
          AND d.genseq = ah.genseq (+) -- ah Delivery document line number
          AND ah.qualf (+) = ods_constants.invoice_delivery_flag
          AND c.datum = ai.yyyymmdd_date -- ai Creation YYYYPPDD
          AND e.belnr (+) = a.belnr AND e.qualf (+) = ods_constants.invoice_order_type -- e Order Type Code
          AND f.belnr (+) = a.belnr AND f.qualf (+) = ods_constants.invoice_invoice_type -- f Invoice Type Code
          AND g.belnr = a.belnr AND g.iddat = ods_constants.invoice_billing_date -- g Billing Effectivity Date
          AND h.yyyymmdd_date = g.datum -- h Billing Date (YYYYPPDD)
          AND i.belnr (+) = a.belnr AND i.qualf (+) = ods_constants.invoice_sales_org -- i Header Sales Organisation
          AND j.belnr (+) = a.belnr AND j.qualf (+) = ods_constants.invoice_distbn_chnl  -- j Header Distribution Channel
          AND k.belnr (+) = a.belnr AND k.qualf (+) = ods_constants.invoice_division -- k Header Division
          AND l.belnr (+) = d.belnr AND l.genseq (+) = d.genseq AND l.parvw (+) = ods_constants.invoice_sold_to_partner -- l Sold To (Partner - Detail record)
          AND m.belnr (+) = d.belnr AND m.genseq (+) = d.genseq AND m.parvw (+) = ods_constants.invoice_bill_to_partner -- m Bill To (Partner - Detail record)
          AND n.belnr (+) = d.belnr AND n.genseq (+) = d.genseq AND n.parvw (+) = ods_constants.invoice_payer_partner -- n Payer (Partner - Detail record)
          AND o.belnr (+) = d.belnr AND o.genseq (+) = d.genseq AND o.parvw (+) = ods_constants.invoice_ship_to_partner -- o Ship To (Partner - Detail record)
          AND p.belnr (+) = d.belnr AND p.genseq (+) = d.genseq AND p.qualf (+) = ods_constants.invoice_material_code -- p Material Code
          AND q.belnr (+) = d.belnr AND q.genseq (+) = d.genseq AND q.qualf (+) = ods_constants.invoice_material_entered -- q Material Entered
          AND r.matnr (+) = p.idtnr AND r.meinh = d.menee -- r BUOM factors
                                                                              --   .. the above joins material and UOM code into
                                                                              --      the sap_mat_uom to get BUOM conversion factors
          AND t.belnr (+) = d.belnr AND t.genseq (+) = d.genseq AND t.kotxt (+) = ods_constants.invoice_gsv
          AND a.belnr = u.belnr (+) AND u.parvw (+) = ods_constants.invoice_sold_to_partner -- u Sold-To (Partner - Header record)
          AND a.belnr = v.belnr (+) AND v.parvw (+) = ods_constants.invoice_bill_to_partner -- v Bill-To (Partner - Header record)
          AND a.belnr = w.belnr (+) AND w.parvw (+) = ods_constants.invoice_payer_partner -- w Payer (Partner - Header record)
          AND a.belnr = x.belnr (+) AND x.parvw (+) = ods_constants.invoice_ship_to_partner -- x Ship-To (Partner - Header record)
          AND f.orgid = y.invc_type_code (+)
          AND f.orgid IN ('ZIV', 'ZIVR', 'ZIVS')
          AND z.company_code = i_company_code
          AND aa.belnr (+) = d.belnr AND aa.genseq (+) = d.genseq AND aa.kschl (+) = ods_constants.invoice_zv01
          AND ab.belnr (+) = d.belnr AND ab.genseq (+) = d.genseq AND ab.kschl (+) = ods_constants.invoice_zr03
          AND ac.belnr (+) = d.belnr AND ac.genseq (+) = d.genseq AND ac.kschl (+) = ods_constants.invoice_zr04
          AND ad.belnr (+) = d.belnr AND ad.genseq (+) = d.genseq AND ad.kschl (+) = ods_constants.invoice_zz01
          AND ae.belnr (+) = d.belnr AND ae.genseq (+) = d.genseq AND ae.kotxt (+) = ods_constants.invoice_gross_value
          AND af.order_usage_code(+) = d.abrvw
          AND LTRIM(p.idtnr, 0) = aj.matl_code (+)
          AND NVL(af.order_usage_gsv_flag,ods_constants.gsv_flag_gsv) = ods_constants.gsv_flag_gsv
          AND a.valdtn_status = ods_constants.valdtn_valid;

      -- Commit.
      COMMIT;

    END IF;

  END LOOP;

  -- Completed sales_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Completed SALES_FACT_OLD aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO sales_fact_savepoint;
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.SALES_FACT_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END sales_fact_aggregation;

FUNCTION sales_fact_aggregation_v2 (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- VARIABLE DECLARATIONS
  v_sales_fact_billing_date VARCHAR2(10);

  -- LOCAL DECLARATIONS
  type typ_table is table of dds.sales_fact_old%rowtype index by binary_integer;
  tbl_insert typ_table;

  CURSOR csr_select IS
        SELECT
          b.orgid AS company_code,
          a.belnr AS billing_doc_num,
          d.posex AS billing_doc_line_num,
          ag.refnr AS order_doc_num,      -- Order document number
          ag.zeile AS order_doc_line_num, -- Order document line number
          NULL AS purch_order_doc_num, -- default value is NULL, column added for future requirements
          NULL AS purch_order_doc_line_num,  -- default value is NULL, column added for future requirements
          ah.refnr AS dlvry_doc_num,      -- Delivery document number
          ah.zeile AS dlvry_doc_line_num, -- Delivery document line number
          e.orgid AS order_type_code,
          f.orgid AS invc_type_code,
          TO_DATE(c.datum,'YYYYMMDD') AS creatn_date,
          ai.mars_yyyyppdd AS creatn_YYYYPPDD,  -- Creation YYYYPPDD
          TO_DATE(g.datum,'YYYYMMDD') AS billing_eff_date,
          TRUNC(h.yyyymmdd_date/100) AS billing_eff_yyyymm,
          h.mars_period AS billing_eff_yyyypp,
          h.mars_yyyyppdd AS billing_eff_yyyyppdd,
          h.mars_week AS billing_eff_yyyyppw,   -- Billing Effective YYYYPPW
          i.orgid AS hdr_sales_org_code,
          j.orgid AS hdr_distbn_chnl_code,
          k.orgid AS hdr_division_code,
          a.curcy AS doc_currcy_code,
          z.company_currcy AS company_currcy_code,
          a.wkurs AS exch_rate,
          a.augru AS order_reason_code,
          DECODE(l.partn, NULL, u.partn, l.partn) AS sold_to_cust_code,
          DECODE(m.partn, NULL, v.partn, m.partn) AS bill_to_cust_code,
          DECODE(n.partn, NULL, w.partn, n.partn) AS payer_cust_code,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.kwmeng,0) AS order_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.menge,0) AS billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.fklmg,0)  AS base_uom_billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.brgew,
                                                                  ods_constants.uom_kilograms, d.brgew / 1000,
                                                                  ods_constants.uom_grams, d.brgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.brgew / 1000000000,
                                                                  0),0) AS billed_qty_gross_tonnes,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.ntgew,
                                                                  ods_constants.uom_kilograms, d.ntgew / 1000,
                                                                  ods_constants.uom_grams, d.ntgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.ntgew / 1000000000,
                                                                  0),0) AS billed_qty_net_tonnes,
          DECODE(o.partn, NULL, x.partn, o.partn) AS ship_to_cust_code,
          LTRIM(p.idtnr, 0) AS matl_code,
          LTRIM(q.idtnr, 0) AS matl_entd,
          d.menee AS billed_qty_uom_code,
          d.meins AS billed_qty_base_uom_code,
          d.werks AS plant_code,
          d.lgort AS storage_locn_code,
          d.vkorg AS gen_sales_org_code,
          d.vtweg AS gen_distbn_chnl_code,
          d.spart AS gen_division_code,
          d.abrvw AS order_usage_code,
          DECODE(y.invc_type_sign,'-',-1,1) /
                 exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs) AS gsv,     -- GSV Market Currency
          DECODE(y.invc_type_sign,'-',-1,1) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg)) AS gsv_xactn,              -- GSV Transaction Currency
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_aud,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_aud,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_usd,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_usd,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_eur,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_eur,
          0 AS niv,
          0 AS niv_xactn,
          0 AS niv_aud,
          0 AS niv_usd,
          0 AS niv_eur,
          0 AS ngv,
          0 AS ngv_xactn,
          0 AS ngv_aud,
          0 AS ngv_usd,
          0 AS ngv_eur,
          DECODE(b.orgid, ods_constants.company_australia, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.abbrd_no),
                          ods_constants.company_new_zealand, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.abbrd_no),
                          ods_constants.abbrd_no) AS mfanz_icb_flag,
          DECODE(b.orgid || j.orgid, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(aj.bus_sgmnt_code, '01', '55', 
                                                                                                                                            '02', '57', 
                                                                                                                                            '05', '56', k.orgid),
                                                                                                                  DECODE(k.orgid, '57', DECODE(aj.bus_sgmnt_code, '02', '57', '05', '56', k.orgid), k.orgid)) demand_plng_grp_division_code
        FROM
          sap_inv_hdr a,
          sap_inv_org b,
          sap_inv_dat c,
          sap_inv_gen d,
          sap_inv_org e,
          sap_inv_org f,
          sap_inv_dat g,
          mars_date h,
          sap_inv_org i,
          sap_inv_org j,
          sap_inv_org k,
          sap_inv_ipn l,
          sap_inv_ipn m,
          sap_inv_ipn n,
          sap_inv_ipn o,
          sap_inv_iob p,
          sap_inv_iob q,
          sap_mat_uom r,
          sap_inv_icn t,
          sap_inv_pnr u,
          sap_inv_pnr v,
          sap_inv_pnr w,
          sap_inv_pnr x,
          invc_type y,
          company z,
          sap_inv_icn aa,
          sap_inv_icn ab,
          sap_inv_icn ac,
          sap_inv_icn ad,
          sap_inv_icn ae,
          order_usage af,
          sap_inv_irf ag,
          sap_inv_irf ah,
          mars_date ai,
          matl_dim aj
        WHERE
          b.belnr = a.belnr
          AND b.qualf = ods_constants.invoice_sales_org AND b.orgid = i_company_code -- b Sales Organisation
          AND c.belnr = a.belnr AND c.iddat = ods_constants.invoice_document_date AND c.datum = tbl_creation_date(v_index).creation_date -- c Document Date
          AND d.belnr = a.belnr -- d Invoice Line
          AND d.belnr = ag.belnr (+)   -- ag Order document number
          AND d.genseq = ag.genseq (+) -- ag Order document line number
          AND ag.qualf (+) = ods_constants.invoice_sales_order_flag
          AND d.belnr = ah.belnr (+)   -- ah Delivery document number
          AND d.genseq = ah.genseq (+) -- ah Delivery document line number
          AND ah.qualf (+) = ods_constants.invoice_delivery_flag
          AND c.datum = ai.yyyymmdd_date -- ai Creation YYYYPPDD
          AND e.belnr (+) = a.belnr AND e.qualf (+) = ods_constants.invoice_order_type -- e Order Type Code
          AND f.belnr (+) = a.belnr AND f.qualf (+) = ods_constants.invoice_invoice_type -- f Invoice Type Code
          AND g.belnr = a.belnr AND g.iddat = ods_constants.invoice_billing_date -- g Billing Effectivity Date
          AND h.yyyymmdd_date = g.datum -- h Billing Date (YYYYPPDD)
          AND i.belnr (+) = a.belnr AND i.qualf (+) = ods_constants.invoice_sales_org -- i Header Sales Organisation
          AND j.belnr (+) = a.belnr AND j.qualf (+) = ods_constants.invoice_distbn_chnl  -- j Header Distribution Channel
          AND k.belnr (+) = a.belnr AND k.qualf (+) = ods_constants.invoice_division -- k Header Division
          AND l.belnr (+) = d.belnr AND l.genseq (+) = d.genseq AND l.parvw (+) = ods_constants.invoice_sold_to_partner -- l Sold To (Partner - Detail record)
          AND m.belnr (+) = d.belnr AND m.genseq (+) = d.genseq AND m.parvw (+) = ods_constants.invoice_bill_to_partner -- m Bill To (Partner - Detail record)
          AND n.belnr (+) = d.belnr AND n.genseq (+) = d.genseq AND n.parvw (+) = ods_constants.invoice_payer_partner -- n Payer (Partner - Detail record)
          AND o.belnr (+) = d.belnr AND o.genseq (+) = d.genseq AND o.parvw (+) = ods_constants.invoice_ship_to_partner -- o Ship To (Partner - Detail record)
          AND p.belnr (+) = d.belnr AND p.genseq (+) = d.genseq AND p.qualf (+) = ods_constants.invoice_material_code -- p Material Code
          AND q.belnr (+) = d.belnr AND q.genseq (+) = d.genseq AND q.qualf (+) = ods_constants.invoice_material_entered -- q Material Entered
          AND r.matnr (+) = p.idtnr AND r.meinh = d.menee -- r BUOM factors
                                                                              --   .. the above joins material and UOM code into
                                                                              --      the sap_mat_uom to get BUOM conversion factors
          AND t.belnr (+) = d.belnr AND t.genseq (+) = d.genseq AND t.kotxt (+) = ods_constants.invoice_gsv
          AND a.belnr = u.belnr (+) AND u.parvw (+) = ods_constants.invoice_sold_to_partner -- u Sold-To (Partner - Header record)
          AND a.belnr = v.belnr (+) AND v.parvw (+) = ods_constants.invoice_bill_to_partner -- v Bill-To (Partner - Header record)
          AND a.belnr = w.belnr (+) AND w.parvw (+) = ods_constants.invoice_payer_partner -- w Payer (Partner - Header record)
          AND a.belnr = x.belnr (+) AND x.parvw (+) = ods_constants.invoice_ship_to_partner -- x Ship-To (Partner - Header record)
          AND f.orgid = y.invc_type_code (+)
          AND f.orgid NOT IN ('ZIV', 'ZIVR', 'ZIVS')
          AND z.company_code = i_company_code
          AND aa.belnr (+) = d.belnr AND aa.genseq (+) = d.genseq AND aa.kschl (+) = ods_constants.invoice_zv01
          AND ab.belnr (+) = d.belnr AND ab.genseq (+) = d.genseq AND ab.kschl (+) = ods_constants.invoice_zr03
          AND ac.belnr (+) = d.belnr AND ac.genseq (+) = d.genseq AND ac.kschl (+) = ods_constants.invoice_zr04
          AND ad.belnr (+) = d.belnr AND ad.genseq (+) = d.genseq AND ad.kschl (+) = ods_constants.invoice_zz01
          AND ae.belnr (+) = d.belnr AND ae.genseq (+) = d.genseq AND ae.kotxt (+) = ods_constants.invoice_gross_value
          AND af.order_usage_code(+) = d.abrvw
          AND LTRIM(p.idtnr, 0) = aj.matl_code (+)
          AND NVL(af.order_usage_gsv_flag,ods_constants.gsv_flag_gsv) = ods_constants.gsv_flag_gsv
          AND a.valdtn_status = ods_constants.valdtn_valid
        UNION
        SELECT
          b.orgid AS company_code,
          a.belnr AS billing_doc_num,
          d.posex AS billing_doc_line_num,
          NULL AS order_doc_num,      -- Order document number
          NULL AS order_doc_line_num, -- Order document line number
          ag.refnr AS purch_order_doc_num, -- default value is NULL, column added for future requirements
          ag.zeile AS purch_order_doc_line_num,  -- default value is NULL, column added for future requirements
          ah.refnr AS dlvry_doc_num,      -- Delivery document number
          ah.zeile AS dlvry_doc_line_num, -- Delivery document line number
          e.orgid AS order_type_code,
          f.orgid AS invc_type_code,
          TO_DATE(c.datum,'YYYYMMDD') AS creatn_date,
          ai.mars_yyyyppdd AS creatn_YYYYPPDD,  -- Creation YYYYPPDD
          TO_DATE(g.datum,'YYYYMMDD') AS billing_eff_date,
          TRUNC(h.yyyymmdd_date/100) AS billing_eff_yyyymm,
          h.mars_period AS billing_eff_yyyypp,
          h.mars_yyyyppdd AS billing_eff_yyyyppdd,
          h.mars_week AS billing_eff_yyyyppw,   -- Billing Effective YYYYPPW
          i.orgid AS hdr_sales_org_code,
          j.orgid AS hdr_distbn_chnl_code,
          k.orgid AS hdr_division_code,
          a.curcy AS doc_currcy_code,
          z.company_currcy AS company_currcy_code,
          a.wkurs AS exch_rate,
          a.augru AS order_reason_code,
          DECODE(l.partn, NULL, u.partn, l.partn) AS sold_to_cust_code,
          DECODE(m.partn, NULL, v.partn, m.partn) AS bill_to_cust_code,
          DECODE(n.partn, NULL, w.partn, n.partn) AS payer_cust_code,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.kwmeng,0) AS order_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.menge,0) AS billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(d.fklmg,0)  AS base_uom_billed_qty,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.brgew,
                                                                  ods_constants.uom_kilograms, d.brgew / 1000,
                                                                  ods_constants.uom_grams, d.brgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.brgew / 1000000000,
                                                                  0),0) AS billed_qty_gross_tonnes,
          DECODE(y.invc_type_sign,'-',-1,1) * NVL(DECODE(d.gewei, ods_constants.uom_tonnes, d.ntgew,
                                                                  ods_constants.uom_kilograms, d.ntgew / 1000,
                                                                  ods_constants.uom_grams, d.ntgew / 1000000,
                                                                  ods_constants.uom_milligrams, d.ntgew / 1000000000,
                                                                  0),0) AS billed_qty_net_tonnes,
          DECODE(o.partn, NULL, x.partn, o.partn) AS ship_to_cust_code,
          LTRIM(p.idtnr, 0) AS matl_code,
          LTRIM(q.idtnr, 0) AS matl_entd,
          d.menee AS billed_qty_uom_code,
          d.meins AS billed_qty_base_uom_code,
          d.werks AS plant_code,
          d.lgort AS storage_locn_code,
          d.vkorg AS gen_sales_org_code,
          d.vtweg AS gen_distbn_chnl_code,
          d.spart AS gen_division_code,
          d.abrvw AS order_usage_code,
          DECODE(y.invc_type_sign,'-',-1,1) /
                 exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs) AS gsv,     -- GSV Market Currency
          DECODE(y.invc_type_sign,'-',-1,1) *
                (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) +
                 DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) +
                 DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) +
                 DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) +
                 DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg)) AS gsv_xactn,              -- GSV Transaction Currency
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_aud,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_aud,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_usd,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_usd,
          ods_app.currcy_conv(DECODE(y.invc_type_sign,'-',-1,1) /
                              exch_rate_factor('ICB',a.curcy,z.company_currcy,TO_DATE(c.datum,'YYYYMMDD')) *
                              (DECODE(t.alckz,'-',-1,1) * DECODE(t.betrg, NULL,0,t.betrg) * a.wkurs +
                              DECODE(aa.alckz,'-',-1,1) * DECODE(aa.betrg,NULL,0,aa.betrg) * a.wkurs +
                              DECODE(ab.alckz,'-',-1,1) * DECODE(ab.betrg,NULL,0,ab.betrg) * a.wkurs +
                              DECODE(ac.alckz,'-',-1,1) * DECODE(ac.betrg,NULL,0,ac.betrg) * a.wkurs +
                              DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg) * a.wkurs),
                              z.company_currcy,
                              ods_constants.currency_eur,
                              TO_DATE(c.datum,'YYYYMMDD'),
                              ods_constants.exchange_rate_type_mppr) AS gsv_eur,
          0 AS niv,
          0 AS niv_xactn,
          0 AS niv_aud,
          0 AS niv_usd,
          0 AS niv_eur,
          0 AS ngv,
          0 AS ngv_xactn,
          0 AS ngv_aud,
          0 AS ngv_usd,
          0 AS ngv_eur,
          DECODE(b.orgid, ods_constants.company_australia, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                        ods_constants.abbrd_no),
                          ods_constants.company_new_zealand, DECODE(DECODE(o.partn,NULL,x.partn,o.partn), ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                                          ods_constants.abbrd_no),
                          ods_constants.abbrd_no) AS mfanz_icb_flag,
          DECODE(b.orgid || j.orgid, ods_constants.company_new_zealand || ods_constants.distbn_chnl_non_specific, DECODE(aj.bus_sgmnt_code, '01', '55', 
                                                                                                                                            '02', '57', 
                                                                                                                                            '05', '56', k.orgid),
                                                                                                                  DECODE(k.orgid, '57', DECODE(aj.bus_sgmnt_code, '02', '57', '05', '56', k.orgid), k.orgid)) demand_plng_grp_division_code
        FROM
          sap_inv_hdr a,
          sap_inv_org b,
          sap_inv_dat c,
          sap_inv_gen d,
          sap_inv_org e,
          sap_inv_org f,
          sap_inv_dat g,
          mars_date h,
          sap_inv_org i,
          sap_inv_org j,
          sap_inv_org k,
          sap_inv_ipn l,
          sap_inv_ipn m,
          sap_inv_ipn n,
          sap_inv_ipn o,
          sap_inv_iob p,
          sap_inv_iob q,
          sap_mat_uom r,
          sap_inv_icn t,
          sap_inv_pnr u,
          sap_inv_pnr v,
          sap_inv_pnr w,
          sap_inv_pnr x,
          invc_type y,
          company z,
          sap_inv_icn aa,
          sap_inv_icn ab,
          sap_inv_icn ac,
          sap_inv_icn ad,
          sap_inv_icn ae,
          order_usage af,
          sap_inv_irf ag,
          sap_inv_irf ah,
          mars_date ai,
          matl_dim aj
        WHERE
          b.belnr = a.belnr
          AND b.qualf = ods_constants.invoice_sales_org AND b.orgid = i_company_code -- b Sales Organisation
          AND c.belnr = a.belnr AND c.iddat = ods_constants.invoice_document_date AND c.datum = tbl_creation_date(v_index).creation_date -- c Document Date
          AND d.belnr = a.belnr -- d Invoice Line
          AND d.belnr = ag.belnr (+)   -- ag Order document number
          AND d.genseq = ag.genseq (+) -- ag Order document line number
          AND ag.qualf (+) = ods_constants.invoice_sales_order_flag
          AND d.belnr = ah.belnr (+)   -- ah Delivery document number
          AND d.genseq = ah.genseq (+) -- ah Delivery document line number
          AND ah.qualf (+) = ods_constants.invoice_delivery_flag
          AND c.datum = ai.yyyymmdd_date -- ai Creation YYYYPPDD
          AND e.belnr (+) = a.belnr AND e.qualf (+) = ods_constants.invoice_order_type -- e Order Type Code
          AND f.belnr (+) = a.belnr AND f.qualf (+) = ods_constants.invoice_invoice_type -- f Invoice Type Code
          AND g.belnr = a.belnr AND g.iddat = ods_constants.invoice_billing_date -- g Billing Effectivity Date
          AND h.yyyymmdd_date = g.datum -- h Billing Date (YYYYPPDD)
          AND i.belnr (+) = a.belnr AND i.qualf (+) = ods_constants.invoice_sales_org -- i Header Sales Organisation
          AND j.belnr (+) = a.belnr AND j.qualf (+) = ods_constants.invoice_distbn_chnl  -- j Header Distribution Channel
          AND k.belnr (+) = a.belnr AND k.qualf (+) = ods_constants.invoice_division -- k Header Division
          AND l.belnr (+) = d.belnr AND l.genseq (+) = d.genseq AND l.parvw (+) = ods_constants.invoice_sold_to_partner -- l Sold To (Partner - Detail record)
          AND m.belnr (+) = d.belnr AND m.genseq (+) = d.genseq AND m.parvw (+) = ods_constants.invoice_bill_to_partner -- m Bill To (Partner - Detail record)
          AND n.belnr (+) = d.belnr AND n.genseq (+) = d.genseq AND n.parvw (+) = ods_constants.invoice_payer_partner -- n Payer (Partner - Detail record)
          AND o.belnr (+) = d.belnr AND o.genseq (+) = d.genseq AND o.parvw (+) = ods_constants.invoice_ship_to_partner -- o Ship To (Partner - Detail record)
          AND p.belnr (+) = d.belnr AND p.genseq (+) = d.genseq AND p.qualf (+) = ods_constants.invoice_material_code -- p Material Code
          AND q.belnr (+) = d.belnr AND q.genseq (+) = d.genseq AND q.qualf (+) = ods_constants.invoice_material_entered -- q Material Entered
          AND r.matnr (+) = p.idtnr AND r.meinh = d.menee -- r BUOM factors
                                                                              --   .. the above joins material and UOM code into
                                                                              --      the sap_mat_uom to get BUOM conversion factors
          AND t.belnr (+) = d.belnr AND t.genseq (+) = d.genseq AND t.kotxt (+) = ods_constants.invoice_gsv
          AND a.belnr = u.belnr (+) AND u.parvw (+) = ods_constants.invoice_sold_to_partner -- u Sold-To (Partner - Header record)
          AND a.belnr = v.belnr (+) AND v.parvw (+) = ods_constants.invoice_bill_to_partner -- v Bill-To (Partner - Header record)
          AND a.belnr = w.belnr (+) AND w.parvw (+) = ods_constants.invoice_payer_partner -- w Payer (Partner - Header record)
          AND a.belnr = x.belnr (+) AND x.parvw (+) = ods_constants.invoice_ship_to_partner -- x Ship-To (Partner - Header record)
          AND f.orgid = y.invc_type_code (+)
          AND f.orgid IN ('ZIV', 'ZIVR', 'ZIVS')
          AND z.company_code = i_company_code
          AND aa.belnr (+) = d.belnr AND aa.genseq (+) = d.genseq AND aa.kschl (+) = ods_constants.invoice_zv01
          AND ab.belnr (+) = d.belnr AND ab.genseq (+) = d.genseq AND ab.kschl (+) = ods_constants.invoice_zr03
          AND ac.belnr (+) = d.belnr AND ac.genseq (+) = d.genseq AND ac.kschl (+) = ods_constants.invoice_zr04
          AND ad.belnr (+) = d.belnr AND ad.genseq (+) = d.genseq AND ad.kschl (+) = ods_constants.invoice_zz01
          AND ae.belnr (+) = d.belnr AND ae.genseq (+) = d.genseq AND ae.kotxt (+) = ods_constants.invoice_gross_value
          AND af.order_usage_code(+) = d.abrvw
          AND LTRIM(p.idtnr, 0) = aj.matl_code (+)
          AND NVL(af.order_usage_gsv_flag,ods_constants.gsv_flag_gsv) = ods_constants.gsv_flag_gsv
          AND a.valdtn_status = ods_constants.valdtn_valid;

BEGIN

  -- Starting sales_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Starting SALES_FACT_OLD aggregation V2.');

  -- Initialise collection index.
  v_index := 0;

  -- Loop through and aggregate for each creation date in the collection.
  FOR RECORD IN 1..tbl_creation_date.COUNT LOOP

    -- Increment collection index.
    v_index := v_index + 1;

    -- Aggregate only the creation dates that are within the allowable variance.
    IF tbl_creation_date(v_index).rcncln_status = ods_constants.rcncln_status_success THEN

      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Aggregating Creation Date [' ||
        '' || tbl_creation_date(v_index).creation_date || '], which has a' ||
        ' Reconciliation Status of [' || tbl_creation_date(v_index).rcncln_status ||'].');

      /*
      Select all billing dates from the sales_fact table for the creation date and either
      update or insert into the aggregation control table.
      */
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Selecting Billing Dates from the' ||
        ' sales_fact_old table, in order to insert or update into the aggregation control table.');
      MERGE INTO aggregtn_cntrl a
      USING (SELECT DISTINCT company_code, billing_eff_date FROM dds.sales_fact_old
      WHERE company_code = i_company_code
        AND creatn_date = TO_DATE(tbl_creation_date(v_index).creation_date, 'YYYYMMDD')) b
      ON (a.company_code = b.company_code
      AND a.billing_eff_date = TO_CHAR(b.billing_eff_date,'YYYYMMDD'))
      WHEN MATCHED THEN UPDATE SET a.aggregtn_cntrl_lupdp = USER,
        a.aggregtn_cntrl_lupdt = SYSDATE
      WHEN NOT MATCHED THEN INSERT (a.company_code, a.billing_eff_date,
        a.aggregtn_cntrl_lupdp, a.aggregtn_cntrl_lupdt)
      VALUES (b.company_code, TO_CHAR(b.billing_eff_date,'YYYYMMDD'),
        USER, SYSDATE);

      -- Commit.
      COMMIT;

      /*
      Select all billing dates from the sap_inv_* tables for the creation date and either
      update or insert into the aggregation control table.
      */
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Selecting Billing Dates from the' ||
        ' sap_inv_* tables, in order to insert or update into the aggregation control table.');
      MERGE INTO aggregtn_cntrl a
      USING (SELECT DISTINCT t2.orgid AS company_code, -- Sales Organisation
        t4.datum AS billing_eff_date -- Billing Date
      FROM sap_inv_hdr t1, sap_inv_org t2, sap_inv_dat t3, sap_inv_dat t4
      WHERE t1.belnr = t2.belnr
        AND t1.belnr = t3.belnr
            AND t1.belnr = t4.belnr
        AND t2.qualf = ods_constants.invoice_sales_org -- Sales Organisation
        AND t2.orgid = i_company_code
        AND t3.iddat = ods_constants.invoice_document_date  -- Document Date
        AND t3.datum = (tbl_creation_date(v_index).creation_date)
        AND t4.iddat = ods_constants.invoice_billing_date -- Billing Date
        AND t1.valdtn_status =  ods_constants.valdtn_valid) b
      ON (a.company_code = b.company_code
      AND a.billing_eff_date = b.billing_eff_date)
      WHEN MATCHED THEN UPDATE SET a.aggregtn_cntrl_lupdp = USER,
        a.aggregtn_cntrl_lupdt = SYSDATE
      WHEN NOT MATCHED THEN INSERT (a.company_code, a.billing_eff_date,
        a.aggregtn_cntrl_lupdp, aggregtn_cntrl_lupdt)
      VALUES (b.company_code, b.billing_eff_date,
        USER, SYSDATE);

      -- Commit.
      COMMIT;

      -- Create a savepoint.
      SAVEPOINT sales_fact_savepoint_v2;

      -- Delete from the sales_fact table based on company code and creation date.
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Deleting from SALES_FACT_OLD based on' ||
        ' Company Code [' || i_company_code || '] and Creation Date [' || tbl_creation_date(v_index).creation_date || '].');
      DELETE FROM dds.sales_fact_old
      WHERE company_code = i_company_code
        AND creatn_date = TO_DATE(tbl_creation_date(v_index).creation_date, 'YYYYMMDD');

      /*-*/
      /* Retrieve the select data in to the array
      /*-*/
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Selecting the SALES_FACT_OLD table data.');
      tbl_insert.delete;
      open csr_select;
      fetch csr_select bulk collect into tbl_insert;
      close csr_select;

      /*-*/
      /* Insert the array data into SALES_FACT
      /*-*/
      -- Insert into sales_fact table based on company code and creation date.
      --
      -- IMPORTANT NOTE: the following line in the GSV calculation needs to be understood:
      --      DECODE(ad.kschl,NULL,0,1) * DECODE(ae.alckz,'-',-1,1) * DECODE(ae.betrg,NULL,0,ae.betrg)
      -- The logic is:
      --      (IF ZZ01 doesn't exists THEN 0 ELSE 1) * INVOICE_VALUE.VALUE * INVOICE_VALUE.SIGN
      -- That is, if the price has ben overridden (ZZ01 exists) then GSV equals the invoice value pricing line.
      write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Inserting into the SALES_FACT_OLD table.');
      forall idx in 1..tbl_insert.count
         insert into dds.sales_fact_old values tbl_insert(idx);

      -- Commit.
      COMMIT;

    END IF;

  END LOOP;

  -- Completed sales_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Completed SALES_FACT_OLD aggregation V2.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO sales_fact_savepoint_v2;
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.SALES_FACT_AGGREGATION_V2: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END sales_fact_aggregation_v2;

FUNCTION sales_month_01_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- CURSOR DECLARATIONS
  -- Select all months from the aggregation control table.
  CURSOR csr_billing_yyyymm IS
    SELECT DISTINCT SUBSTR(billing_eff_date, 1, 6) AS billing_yyyymm
    FROM aggregtn_cntrl
    WHERE company_code = i_company_code;

BEGIN

  -- Starting sales_month_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Starting SALES_MONTH_01_FACT_OLD aggregation.');

  FOR rv_billing_yyyymm IN csr_billing_yyyymm LOOP

    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Aggregating BILLING_YYYYMM [' ||
        '' || rv_billing_yyyymm.billing_yyyymm || '].');

    -- Check that a partition exists for the month we are about to aggregate.
    sales_partition.check_create('SALES_MONTH_01_FACT_OLD', i_company_code,
      rv_billing_yyyymm.billing_yyyymm,'M');

    /*
    Now truncate everything from the sales month table where the month is the same as the one
    we are about to reaggregate.
    */
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Truncating the SALES_MONTH_01_FACT_OLD table.');

    sales_partition.TRUNCATE('SALES_MONTH_01_FACT_OLD', i_company_code,
      rv_billing_yyyymm.billing_yyyymm,'M');

    -- Insert into the sales_month_01_fact table the month being aggregated.
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Inserting into the SALES_MONTH_01_FACT_OLD table.');
    INSERT INTO dds.sales_month_01_fact_old
      (
      company_code,
      order_type_code,
      invc_type_code,
      billing_eff_yyyymm,
      hdr_sales_org_code,
      hdr_distbn_chnl_code,
      hdr_division_code,
      doc_currcy_code,
      company_currcy_code,
      exch_rate,
      order_reasn_code,
      sold_to_cust_code,
      bill_to_cust_code,
      payer_cust_code,
      order_qty,
      billed_qty,
      base_uom_billed_qty,
      billed_qty_gross_tonnes,
      billed_qty_net_tonnes,
      ship_to_cust_code,
      matl_code,
      matl_entd,
      billed_qty_uom_code,
      billed_qty_base_uom_code,
      plant_code,
      storage_locn_code,
      gen_sales_org_code,
      gen_distbn_chnl_code,
      gen_division_code,
      order_usage_code,
      gsv,
      gsv_xactn,
      gsv_aud,
      gsv_usd,
      gsv_eur,
      niv,
      niv_xactn,
      niv_aud,
      niv_usd,
      niv_eur,
      ngv,
      ngv_xactn,
      ngv_aud,
      ngv_usd,
      ngv_eur,
      mfanz_icb_flag,
      demand_plng_grp_division_code
      )
      SELECT
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyymm,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        SUM(order_qty),
        SUM(billed_qty),
        SUM(base_uom_billed_qty),
        SUM(billed_qty_gross_tonnes),
        SUM(billed_qty_net_tonnes),
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        SUM(gsv),
        SUM(gsv_xactn),
        SUM(gsv_aud),
        SUM(gsv_usd),
        SUM(gsv_eur),
        SUM(niv),
        SUM(niv_xactn),
        SUM(niv_aud),
        SUM(niv_usd),
        SUM(niv_eur),
        SUM(ngv),
        SUM(ngv_xactn),
        SUM(ngv_aud),
        SUM(ngv_usd),
        SUM(ngv_eur),
        DECODE(company_code, ods_constants.company_australia, DECODE(ship_to_cust_code, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.abbrd_no),
                             ods_constants.company_new_zealand, DECODE(ship_to_cust_code, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.abbrd_no),
                             ods_constants.abbrd_no) AS mfanz_icb_flag,
        demand_plng_grp_division_code
      FROM
        dds.sales_fact_old
      WHERE
        company_code = i_company_code
        AND billing_eff_yyyymm = rv_billing_yyyymm.billing_yyyymm
      GROUP BY
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyymm,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        demand_plng_grp_division_code;

    -- Commit.
    COMMIT;

  END LOOP;

  -- Completed sales_month_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Completed SALES_MONTH_01_FACT_OLD aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.SALES_MONTH_01_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END sales_month_01_aggregation;

FUNCTION sales_month_01_aggregation_v2 (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- LOCAL DECLARATIONS
  v_billing_yyyymm number;
  type typ_table is table of dds.sales_month_01_fact_old%rowtype index by binary_integer;
  tbl_insert typ_table;

  -- CURSOR DECLARATIONS
  -- Select all months from the aggregation control table.
  CURSOR csr_billing_yyyymm IS
    SELECT DISTINCT SUBSTR(billing_eff_date, 1, 6) AS billing_yyyymm
    FROM aggregtn_cntrl
    WHERE company_code = i_company_code;

  CURSOR csr_select IS
      SELECT
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyymm,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        SUM(order_qty),
        SUM(billed_qty),
        SUM(base_uom_billed_qty),
        SUM(billed_qty_gross_tonnes),
        SUM(billed_qty_net_tonnes),
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        SUM(gsv),
        SUM(gsv_xactn),
        SUM(gsv_aud),
        SUM(gsv_usd),
        SUM(gsv_eur),
        SUM(niv),
        SUM(niv_xactn),
        SUM(niv_aud),
        SUM(niv_usd),
        SUM(niv_eur),
        SUM(ngv),
        SUM(ngv_xactn),
        SUM(ngv_aud),
        SUM(ngv_usd),
        SUM(ngv_eur),
        DECODE(company_code, ods_constants.company_australia, DECODE(ship_to_cust_code, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.abbrd_no),
                             ods_constants.company_new_zealand, DECODE(ship_to_cust_code, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.abbrd_no),
                             ods_constants.abbrd_no) AS mfanz_icb_flag,
        demand_plng_grp_division_code
      FROM
        dds.sales_fact_old
      WHERE
        company_code = i_company_code
        AND billing_eff_yyyymm = v_billing_yyyymm
      GROUP BY
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyymm,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        demand_plng_grp_division_code;

BEGIN

  -- Starting sales_month_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Starting SALES_MONTH_01_FACT_OLD aggregation V2.');

  FOR rv_billing_yyyymm IN csr_billing_yyyymm LOOP

    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Aggregating BILLING_YYYYMM [' ||
        '' || rv_billing_yyyymm.billing_yyyymm || '].');

    -- Check that a partition exists for the month we are about to aggregate.
    sales_partition.check_create('SALES_MONTH_01_FACT_OLD', i_company_code,
      rv_billing_yyyymm.billing_yyyymm,'M');

    /*
    Now truncate everything from the sales month table where the month is the same as the one
    we are about to reaggregate.
    */
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Truncating the SALES_MONTH_01_FACT_OLD table.');

    sales_partition.TRUNCATE('SALES_MONTH_01_FACT_OLD', i_company_code,
      rv_billing_yyyymm.billing_yyyymm,'M');

    /*-*/
    /* Retrieve the select data in to the array
    /*-*/
    v_billing_yyyymm := rv_billing_yyyymm.billing_yyyymm;
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Selecting the SALES_MONTH_01_FACT_OLD table data.');
    tbl_insert.delete;
    open csr_select;
    fetch csr_select bulk collect into tbl_insert;
    close csr_select;

    /*-*/
    /* Insert the array data into SALES_MONTH_01_FACT
    /*-*/
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Inserting into the SALES_MONTH_01_FACT_OLD table.');
    forall idx in 1..tbl_insert.count
       insert into dds.sales_month_01_fact_old values tbl_insert(idx);

    -- Commit.
    COMMIT;

  END LOOP;

  -- Completed sales_month_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Completed SALES_MONTH_01_FACT_OLD aggregation V2.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.SALES_MONTH_01_AGGREGATION_V2: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END sales_month_01_aggregation_v2;

FUNCTION sales_period_01_aggregation (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- CURSOR DECLARATIONS
  -- Select all periods from the aggregation control table to be aggregated.
  CURSOR csr_billing_yyyypp IS
    SELECT DISTINCT b.mars_period AS billing_yyyypp
    FROM aggregtn_cntrl a, mars_date b
    WHERE a.billing_eff_date = b.yyyymmdd_date
      AND company_code = i_company_code;

BEGIN

  -- Starting sales_period_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Starting SALES_PERIOD_01_FACT_OLD aggregation.');

  FOR rv_billing_yyyypp IN csr_billing_yyyypp LOOP

    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Aggregating BILLING_YYYYPP [' ||
        '' || rv_billing_yyyypp.billing_yyyypp || '].');

    -- Check that a partition exists for the period we are about to aggregate.
    sales_partition.check_create('SALES_PERIOD_01_FACT_OLD', i_company_code,
      rv_billing_yyyypp.billing_yyyypp,'P');

    /*
    Now truncate everything from the sales period table where the period is the same as the one
    we are about to reaggregate.
    */
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Truncating the SALES_PERIOD_01_FACT_OLD table.');

    sales_partition.TRUNCATE('SALES_PERIOD_01_FACT_OLD', i_company_code,
      rv_billing_yyyypp.billing_yyyypp,'P');

    -- Insert into the sales_period_01_fact table the period being aggregated.
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Inserting into the SALES_PERIOD_01_FACT_OLD table.');
    INSERT INTO dds.sales_period_01_fact_old
      (
      company_code,
      order_type_code,
      invc_type_code,
      billing_eff_yyyypp,
      hdr_sales_org_code,
      hdr_distbn_chnl_code,
      hdr_division_code,
      doc_currcy_code,
      company_currcy_code,
      exch_rate,
      order_reasn_code,
      sold_to_cust_code,
      bill_to_cust_code,
      payer_cust_code,
      order_qty,
      billed_qty,
      base_uom_billed_qty,
      billed_qty_gross_tonnes,
      billed_qty_net_tonnes,
      ship_to_cust_code,
      matl_code,
      matl_entd,
      billed_qty_uom_code,
      billed_qty_base_uom_code,
      plant_code,
      storage_locn_code,
      gen_sales_org_code,
      gen_distbn_chnl_code,
      gen_division_code,
      order_usage_code,
      gsv,
      gsv_xactn,
      gsv_aud,
      gsv_usd,
      gsv_eur,
      niv,
      niv_xactn,
      niv_aud,
      niv_usd,
      niv_eur,
      ngv,
      ngv_xactn,
      ngv_aud,
      ngv_usd,
      ngv_eur,
      mfanz_icb_flag,
      demand_plng_grp_division_code
      )
      SELECT
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyypp,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        SUM(order_qty),
        SUM(billed_qty),
        SUM(base_uom_billed_qty),
        SUM(billed_qty_gross_tonnes),
        SUM(billed_qty_net_tonnes),
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        SUM(gsv),
        SUM(gsv_xactn),
        SUM(gsv_aud),
        SUM(gsv_usd),
        SUM(gsv_eur),
        SUM(niv),
        SUM(niv_xactn),
        SUM(niv_aud),
        SUM(niv_usd),
        SUM(niv_eur),
        SUM(ngv),
        SUM(ngv_xactn),
        SUM(ngv_aud),
        SUM(ngv_usd),
        SUM(ngv_eur),
        DECODE(company_code, ods_constants.company_australia, DECODE(ship_to_cust_code, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.abbrd_no),
                             ods_constants.company_new_zealand, DECODE(ship_to_cust_code, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.abbrd_no),
                             ods_constants.abbrd_no) AS mfanz_icb_flag,
        demand_plng_grp_division_code
      FROM
        dds.sales_fact_old
      WHERE
        company_code = i_company_code
        AND billing_eff_yyyypp = rv_billing_yyyypp.billing_yyyypp
      GROUP BY
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyypp,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        demand_plng_grp_division_code;

    -- Commit.
    COMMIT;

  END LOOP;

  -- Completed sales_period_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Completed SALES_PERIOD_01_FACT_OLD aggregation.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.SALES_PERIOD_01_AGGREGATION: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END sales_period_01_aggregation;

FUNCTION sales_period_01_aggregation_v2 (
  i_company_code IN company.company_code%TYPE,
  i_log_level IN NUMBER
  ) RETURN NUMBER IS

  -- AUTONOMOUS TRANSACTION
  PRAGMA AUTONOMOUS_TRANSACTION;

  -- LOCAL DECLARATIONS
  v_billing_yyyypp number;
  type typ_table is table of dds.sales_period_01_fact_old%rowtype index by binary_integer;
  tbl_insert typ_table;

  -- CURSOR DECLARATIONS
  -- Select all periods from the aggregation control table to be aggregated.
  CURSOR csr_billing_yyyypp IS
    SELECT DISTINCT b.mars_period AS billing_yyyypp
    FROM aggregtn_cntrl a, mars_date b
    WHERE a.billing_eff_date = b.yyyymmdd_date
      AND company_code = i_company_code;

  CURSOR csr_select IS
      SELECT
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyypp,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        SUM(order_qty),
        SUM(billed_qty),
        SUM(base_uom_billed_qty),
        SUM(billed_qty_gross_tonnes),
        SUM(billed_qty_net_tonnes),
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        SUM(gsv),
        SUM(gsv_xactn),
        SUM(gsv_aud),
        SUM(gsv_usd),
        SUM(gsv_eur),
        SUM(niv),
        SUM(niv_xactn),
        SUM(niv_aud),
        SUM(niv_usd),
        SUM(niv_eur),
        SUM(ngv),
        SUM(ngv_xactn),
        SUM(ngv_aud),
        SUM(ngv_usd),
        SUM(ngv_eur),
        DECODE(company_code, ods_constants.company_australia, DECODE(ship_to_cust_code, ods_constants.nz_auckland_1_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_auckland_2_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_christchurch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.nz_po_cold_store_icb_cust_code, ods_constants.abbrd_yes,
                                                                                        ods_constants.abbrd_no),
                             ods_constants.company_new_zealand, DECODE(ship_to_cust_code, ods_constants.pet_wod_pouch_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_chilled_roll_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.pet_port_plant_icb_cust_code, ods_constants.abbrd_yes,
                                                                                          ods_constants.abbrd_no),
                             ods_constants.abbrd_no) AS mfanz_icb_flag,
        demand_plng_grp_division_code
      FROM
        dds.sales_fact_old
      WHERE
        company_code = i_company_code
        AND billing_eff_yyyypp = v_billing_yyyypp
      GROUP BY
        company_code,
        order_type_code,
        invc_type_code,
        billing_eff_yyyypp,
        hdr_sales_org_code,
        hdr_distbn_chnl_code,
        hdr_division_code,
        doc_currcy_code,
        company_currcy_code,
        exch_rate,
        order_reasn_code,
        sold_to_cust_code,
        bill_to_cust_code,
        payer_cust_code,
        ship_to_cust_code,
        matl_code,
        matl_entd,
        billed_qty_uom_code,
        billed_qty_base_uom_code,
        plant_code,
        storage_locn_code,
        gen_sales_org_code,
        gen_distbn_chnl_code,
        gen_division_code,
        order_usage_code,
        demand_plng_grp_division_code;

BEGIN

  -- Starting sales_period_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Starting SALES_PERIOD_01_FACT_OLD aggregation V2.');

  FOR rv_billing_yyyypp IN csr_billing_yyyypp LOOP

    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Aggregating BILLING_YYYYPP [' ||
        '' || rv_billing_yyyypp.billing_yyyypp || '].');

    -- Check that a partition exists for the period we are about to aggregate.
    sales_partition.check_create('SALES_PERIOD_01_FACT_OLD', i_company_code,
      rv_billing_yyyypp.billing_yyyypp,'P');

    /*
    Now truncate everything from the sales period table where the period is the same as the one
    we are about to reaggregate.
    */
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Truncating the SALES_PERIOD_01_FACT_OLD table.');

    sales_partition.TRUNCATE('SALES_PERIOD_01_FACT_OLD', i_company_code,
      rv_billing_yyyypp.billing_yyyypp,'P');

    /*-*/
    /* Retrieve the select data in to the array
    /*-*/
    v_billing_yyyypp := rv_billing_yyyypp.billing_yyyypp;
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Selecting the SALES_PERIOD_01_FACT_OLD table data.');
    tbl_insert.delete;
    open csr_select;
    fetch csr_select bulk collect into tbl_insert;
    close csr_select;

    /*-*/
    /* Insert the array data into SALES_PERIOD_01_FACT
    /*-*/
    write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 2, 'Inserting into the SALES_PERIOD_01_FACT_OLD table.');
    forall idx in 1..tbl_insert.count
       insert into dds.sales_period_01_fact_old values tbl_insert(idx);

    -- Commit.
    COMMIT;

  END LOOP;

  -- Completed sales_period_01_fact aggregation.
  write_log(ods_constants.data_type_invoice, 'N/A', i_log_level + 1, 'Completed SALES_PERIOD_01_FACT_OLD aggregation V2.');

  -- Completed successfully.
  RETURN constants.success;

EXCEPTION
  WHEN OTHERS THEN
    write_log(ods_constants.data_type_invoice,
              'ERROR',
              0,
              'TRIGGERED_AGGREGATION.SALES_PERIOD_01_AGGREGATION_V2: ERROR: ' || SUBSTR(SQLERRM, 1, 512));
  RETURN constants.error;
END sales_period_01_aggregation_v2;

PROCEDURE write_log (
  i_data_type IN VARCHAR2,
  i_sort_field IN VARCHAR2,
  i_log_level IN NUMBER,
  i_log_text IN VARCHAR2) IS

BEGIN

  -- Write the entry into the log table.
  utils.ods_log (ods_constants.job_type_trig_aggregation,
                 i_data_type,
                 i_sort_field,
                 i_log_level,
                 i_log_text);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END write_log;

END triggered_aggregation;
/
