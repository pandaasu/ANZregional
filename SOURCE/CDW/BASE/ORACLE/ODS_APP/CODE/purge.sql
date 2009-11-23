CREATE OR REPLACE PACKAGE           "PURGE" AS

  /*******************************************************************************
    NAME:      purge_all_companies
    PURPOSE:   Run all purges for all companies.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   07/07/2004 Peter Smith          Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    None

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_all_companies;



  /*******************************************************************************
    NAME:      run_company_purge
    PURPOSE:   Run all of the purging procedures for a company.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                          Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE run_company_purge(
	  i_company_code IN company.company_code%TYPE
		);



	/*******************************************************************************
    NAME:      purge_ods_sales_orders
    PURPOSE:   Purging Sales Orders from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_sales_orders(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_deliveries
    PURPOSE:   Purging Deliveries from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_deliveries(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_purchase_orders
    PURPOSE:   Purging Purchase Orders from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_purchase_orders(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_invoices
    PURPOSE:   Purging Invoices from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_invoices(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_invoice_sum
    PURPOSE:   Purging Invoice Summaries from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_invoice_sum(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_hierarchies
    PURPOSE:   Purging Hierarchy Information from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of days back in history   i_retention_days
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_hierarchies(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_days    IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_stock_balances
    PURPOSE:   Purging Stock Balances from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_stock_balances(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_intransits
    PURPOSE:   Purging Intransit Data from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_intransits(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_forecasts
    PURPOSE:   Purging Forecast Data from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_forecasts(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_ods_deleted_forecasts
    PURPOSE:   Purging Deleted Forecast Data from the ODS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_ods_deleted_forecasts(
	  i_company_code IN company.company_code%TYPE,
		i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
		);


   /*******************************************************************************
    NAME:      purge_dds_forecasts
    PURPOSE:   Purging Forecast Data from the DDS.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     company.company_code%TYPE
                         The company code that you want to    i_company_code
                         purge information for.
		2    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		3    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_dds_forecasts(
	  i_company_code      IN company.company_code%TYPE,
		i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      purge_logs
    PURPOSE:   Purging Logs from the system.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
		1    IN     NUMBER   The max log level that you want to   i_max_log_level
				 								 keep.
    2    IN     NUMBER   The number of prds back in history   i_retention_prds
                         to keep log data for.
    3    IN     NUMBER   The number of days back in history   i_retention_days
                         to keep log data for.
		4    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES:
  ********************************************************************************/
  PROCEDURE purge_logs(
		i_max_log_level  IN NUMBER,
	  i_retention_prds IN NUMBER DEFAULT ods_constants.logs_retn_prds,
	  i_retention_days IN NUMBER DEFAULT ods_constants.logs_retn_days,
		i_log_level      IN ods.log.log_level%TYPE DEFAULT 0
		);



	/*******************************************************************************
    NAME:      get_retention_date
    PURPOSE:   Return the calendar date based on todays date - retension periods.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		2    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This function is generic, and is used by a number of other procedures.
		       The function receives the input parameter, input_retention_periods,
					 which is the number of periods for which historic data is to be
					 retained. The function subtracts the input_retention_periods from the
					 period number of the current date, and returns the earliest date in the
					 resulting period. Only data before this date should be made available
					 to purge.
  ********************************************************************************/
  FUNCTION get_retention_date(
	  i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		) RETURN DATE;



	/*******************************************************************************
    NAME:      get_retention_period
    PURPOSE:   Return the Mars Year and Period based on todays date
		           minus retension periods.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/07/2004 Gerald Arnold        Created this procedure.

    PARAMETERS:
    Pos  Type   Format   Description                           Example
    ---- ------ -------- ------------------------------------ --------------------
    1    IN     NUMBER   The number of period back in history i_retention_periods
                         to keep data for.
		2    IN     NUMBER   The level to start logging at.       i_log_level

    RETURN VALUE:
    ASSUMPTIONS:
    NOTES: This function is generic, and is used by other procedures. The function
		       receives the input parameter, input_retention_periods, which is the\
					 number of periods for which historic data is to be retained. The
					 function subtracts the input_retention_periods from the period number
					 of the current date, and returns the resulting year and period (yyyypp
					 format). Only data before this year/period should be made available to
					 purge.
  ********************************************************************************/
  FUNCTION get_retention_period(
	  i_retention_periods IN NUMBER,
		i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
		) RETURN NUMBER;

END purge;

/


CREATE OR REPLACE PACKAGE BODY           "PURGE" AS

  v_had_errors  BOOLEAN        := FALSE;
  v_error_count PLS_INTEGER    := 1;
  v_message     VARCHAR2(4000);
  v_db_name     VARCHAR2(256)  := NULL;

  TYPE error_line IS RECORD(data_type     ods.log.data_type%TYPE,
                            sort_field    ods.log.sort_field%TYPE,
                            error_message VARCHAR2(70));

  TYPE error_name IS TABLE OF error_line
    INDEX BY PLS_INTEGER;

  error_table error_name;






  PROCEDURE purge_all_companies IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Declare Cursors
    CURSOR csr_company IS
      SELECT
        *
      FROM
        company;
    rv_company csr_company%ROWTYPE;

  BEGIN

    -- Setup local variables.
    v_job_type   := ods_constants.job_type_purge;
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
                  'Purge Start');

    -- Loop through a purge data for all companies in the company table.
    OPEN csr_company;
    FOR rv_company IN csr_company LOOP

      -- Call run_all_purge for this company.
      run_company_purge(rv_company.company_code);

    END LOOP;
    CLOSE csr_company;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Purge Ending');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF (csr_company%ISOPEN) THEN
        CLOSE csr_company;
      END IF;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR PURGE ALL COMPANIES.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));
      utils.send_email_to_group(v_job_type,
                                'Error during Purge All Companies' ||
                                ' on Database: ' || v_db_name,
                                'A fatal error occured on the Database ' ||
                                v_db_name ||
                                ', on the Server: ' || ods_constants.hostname ||
                                '.' || utl_tcp.crlf ||
                                'Fatal error during Purge All Companies.' ||
                                utl_tcp.crlf ||
                                'ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512) ||
                                utl_tcp.crlf ||
                                'There may have been other errors, check the '||
                                'logs for these.');
  END purge_all_companies;



  PROCEDURE run_company_purge(
    i_company_code IN company.company_code%TYPE
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_max_log_level PLS_INTEGER := 0;

    -- CURSORS
    CURSOR csr_company IS
      SELECT
        A.ods_ord_retn_prd,
        A.ods_dlvry_retn_prd,
                A.ods_invc_retn_prd,
        A.ods_invc_sum_retn_prd,
        A.ods_stk_bal_retn_prd,
        A.ods_intransit_retn_prd,
        A.ods_fcst_retn_prd,
        A.dds_ord_retn_prd,
        A.dds_dlvry_retn_prd,
        A.dds_invc_retn_prd
      FROM
        company A
      WHERE
        A.company_code = i_company_code;
    rv_company csr_company%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
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
                  'Starting Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    -- Get the purge parameters for this company.
    OPEN csr_company;

    -- Make sure that there is something to fetch back
    FETCH csr_company INTO rv_company;
    IF (csr_company%FOUND) THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Information for Company Code: ' || i_company_code || ' found.');
      v_log_level := v_log_level + 1;

      /***************/
-- Run all routines commented out by Paul Jacobs 12/5/2006
-- Risk of someone accidentally triggering this procedure in production is to high,
-- thus run all routine has been effectively commented out.
/*
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Starting ODS Purging for Company Code: ' ||
                    i_company_code || '.');
      v_log_level := v_log_level + 1;


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Sales Orders for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_sales_orders(i_company_code,
                             rv_company.ods_ord_retn_prd,
                             v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Deliveries for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_deliveries(i_company_code,
                           rv_company.ods_dlvry_retn_prd,
                           v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Purchase Orders for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_purchase_orders(i_company_code,
                                rv_company.ods_dlvry_retn_prd,
                                v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Invoices for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_invoices(i_company_code,
                         rv_company.ods_invc_retn_prd,
                         v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Invoice Summaries for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_invoice_sum(i_company_code,
                            rv_company.ods_invc_sum_retn_prd,
                            v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Hierarchies for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_hierarchies(i_company_code,
                            ods_constants.ods_cus_hier_retn_days,
                            v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Stock Balances for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_stock_balances(i_company_code,
                               rv_company.ods_stk_bal_retn_prd,
                               v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS In-Transits for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_intransits(i_company_code,
                           rv_company.ods_intransit_retn_prd,
                           v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Forecasts for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_forecasts(i_company_code,
                          rv_company.ods_fcst_retn_prd,
                          v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Deleted Forecasts for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_deleted_forecasts(i_company_code,
                                  v_log_level + 1);


      v_log_level := v_log_level - 1;
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Finisheding ODS Purging for Company Code: ' ||
                    i_company_code || '.');
*/
      /***************/
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Starting DDS Purging for Company Code: ' ||
                    i_company_code || '.');
      v_log_level := v_log_level + 1;

/*
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging DDS Sales Orders for Company Code: ' ||
                    i_company_code || '.');
      purge_dds_sales_orders(i_company_code,
                             rv_company.dds_ord_retn_prd,
                             v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Deliveries for Company Code: ' ||
                    i_company_code || '.');
      purge_dds_deliveries(i_company_code,
                           rv_company.dds_dlvry_retn_prd,
                           v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging DDS Purchase Orders for Company Code: ' ||
                    i_company_code || '.');
      purge_dds_purchase_orders(i_company_code,
                                rv_company.dds_dlvry_retn_prd,
                                v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging ODS Invoices for Company Code: ' ||
                    i_company_code || '.');
      purge_dds_invoices(i_company_code,
                         rv_company.dds_invc_retn_prd,
                         v_log_level + 1);


      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Calling Purging DDS Forecasts for Company Code: ' ||
                    i_company_code || '.');
      purge_ods_forecasts(i_company_code,
                          rv_company.dds_invc_retn_prd,
                          v_log_level + 1);


      v_log_level := v_log_level - 1;
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'Finisheding DDS Purging for Company Code: ' ||
                    i_company_code || '.');
*/
      /***************/
      v_log_level := v_log_level - 1;

    ELSE
      utils.ods_log(v_job_type,
                    v_data_type,
                    v_sort_field,
                    v_log_level,
                    'No information for Company Code: ' || i_company_code || ' found, exiting.');
    END IF;

    CLOSE csr_company;

    /***************/
    v_log_level := v_log_level + 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Log Purging.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Calling Purging Logs.');
    purge_logs(ods_constants.logs_max_log_level,
               ods_constants.logs_retn_prds,
               ods_constants.logs_retn_days,
               v_log_level + 1);


    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finisheding Log Purging.');
    v_log_level := v_log_level - 1;

    -- Check to see if anything failed
    IF (v_had_errors) THEN
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Error Occured During Purging for Company Code: ' ||
                  i_company_code || '. Sending out e-mail.');

      FOR i in 1 ..error_table.COUNT LOOP
        v_message := v_message ||
                     error_table(i).data_type     || '|'   ||
                     error_table(i).sort_field    || ' - ' ||
                     error_table(i).error_message || utl_tcp.crlf;
      END LOOP;

      utils.send_email_to_group(ods_constants.job_type_flattening,
                                'Purge Errors for Company Code: ' || i_company_code ||
                                ' on Database: ' || v_db_name,
                                'An error occured on the Database ' ||
                                v_db_name ||
                                ', on the Server: ' || ods_constants.hostname ||
                                '.' || utl_tcp.crlf ||
                                'The Purge process for Company Code: ' || i_company_code ||
                                ', had the following failures: ' || utl_tcp.crlf ||
                                v_message, i_company_code, v_log_level + 1);
    END IF;


    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR RUN ALL PURGING ' ||
                    'FOR COMPANY CODE: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      utils.send_email_to_group(v_job_type,
                                'Error during Purge procedure for Company Code: ' || i_company_code ||
                                ' on Database: ' || v_db_name,
                                'An error occured on the Database ' ||
                                v_db_name ||
                                ', on the Server: ' || ods_constants.hostname ||
                                '.' || utl_tcp.crlf ||
                                'Fatal error during run all purging ' ||
                                'for Company Code: ' ||
                                i_company_code || '.' ||
                                utl_tcp.crlf ||
                                'ERROR MESSAGE: ' ||
                                SUBSTR(SQLERRM, 1, 512) ||
                                utl_tcp.crlf ||
                                'There may have been other errors, check the '||
                                'logs for these.', i_company_code);
  END run_company_purge;



  PROCEDURE purge_ods_sales_orders(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    CURSOR csr_sales_order IS
      SELECT
        A.belnr  -- Document Number
      FROM
        sap_sal_ord_hdr A, -- Header
        sap_sal_ord_dat B, -- Date
        sap_sal_ord_org C  -- Sales Organisation
      WHERE
        B.belnr = A.belnr
        AND C.belnr = A.belnr
        AND B.iddat = ods_constants.sales_order_creation_date
        AND B.datum < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND C.qualf = ods_constants.sales_order_sales_org
        AND C.orgid = i_company_code;
    rv_sales_order csr_sales_order%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_sales_order;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Sales Orders Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := get_retention_date(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting ODS Sales Orders for Company Code: ' ||
                  i_company_code ||
                  ' that have a date greater than: ' ||
                  v_retention_date || '.');
    -- Delete all sales orders in the ODS whose creation date is
    -- before the retention date.
    OPEN csr_sales_order;
    LOOP
      -- Get the Sales Order to be purged.
      FETCH csr_sales_order INTO rv_sales_order;
      EXIT WHEN csr_sales_order%NOTFOUND;

      -- Delete all records associated with the Sales Order in the ODS.
      DELETE sap_sal_ord_smy WHERE belnr = rv_sales_order.belnr; -- Order Summary
      DELETE sap_sal_ord_iid WHERE belnr = rv_sales_order.belnr; -- Item Object Identification
      DELETE sap_sal_ord_ipn WHERE belnr = rv_sales_order.belnr; -- Item Partner
      DELETE sap_sal_ord_ico WHERE belnr = rv_sales_order.belnr; -- Item Condition
      DELETE sap_sal_ord_idt WHERE belnr = rv_sales_order.belnr; -- Item Date
      DELETE sap_sal_ord_irf WHERE belnr = rv_sales_order.belnr; -- Item Reference
      DELETE sap_sal_ord_gen WHERE belnr = rv_sales_order.belnr; -- General
      DELETE sap_sal_ord_ref WHERE belnr = rv_sales_order.belnr; -- Reference
      DELETE sap_sal_ord_pnr WHERE belnr = rv_sales_order.belnr; -- Partner
      DELETE sap_sal_ord_con WHERE belnr = rv_sales_order.belnr; -- Condition
      DELETE sap_sal_ord_dat WHERE belnr = rv_sales_order.belnr; -- Date
      DELETE sap_sal_ord_org WHERE belnr = rv_sales_order.belnr; -- Sales Organisation
      DELETE sap_sal_ord_hdr WHERE belnr = rv_sales_order.belnr; -- Header
      COMMIT;

    END LOOP;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Sales Orders Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS SALES ORDERS PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '''.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_sales_order%ISOPEN) THEN
        CLOSE csr_sales_order;
      END IF;

  END purge_ods_sales_orders;



  PROCEDURE purge_ods_deliveries(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    CURSOR csr_deliveries IS
      SELECT
        A.vbeln -- Sales and Distribution Document Number
      FROM
        sap_del_hdr A, -- Header
        sap_del_tim B, -- Time
        sap_del_add C  -- Address
      WHERE
        B.vbeln = A.vbeln
        AND C.vbeln = A.vbeln
        AND B.qualf = ods_constants.delivery_document_date
        AND B.ntanf < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND C.partner_q = ods_constants.delivery_sales_org
        AND C.partner_id = i_company_code;
    rv_deliveries csr_deliveries%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_delivery;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Deliveries Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := get_retention_date(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS Deliveries for Company Code: ' ||
                  i_company_code || '.');
    -- Delete all deliveries in the ODS whose creation date is before the retention date.
    OPEN csr_deliveries;
    LOOP

      -- Get the Delivery to be purged.
      FETCH csr_deliveries INTO rv_deliveries;
      EXIT WHEN csr_deliveries%NOTFOUND;

      -- Delete all records associated with the Delivery in the ODS.
      DELETE sap_del_irf WHERE vbeln = rv_deliveries.vbeln; -- Detail Internal Reference
      DELETE sap_del_det WHERE vbeln = rv_deliveries.vbeln; -- Detail
      DELETE sap_del_tim WHERE vbeln = rv_deliveries.vbeln; -- Time
      DELETE sap_del_add WHERE vbeln = rv_deliveries.vbeln; -- Address
      DELETE sap_del_hdr WHERE vbeln = rv_deliveries.vbeln; -- Header
      COMMIT;

    END LOOP;
    CLOSE csr_deliveries;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Deliveries Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS DELIVERIES PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_deliveries%ISOPEN) THEN
        CLOSE csr_deliveries;
      END IF;

  END purge_ods_deliveries;


  PROCEDURE purge_ods_purchase_orders(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    -- CURSORS
    CURSOR csr_purchase_orders IS
      SELECT
        a.belnr
      FROM
        sap_sto_po_hdr a,
        sap_sto_po_org b,
        sap_sto_po_pnr c,
        sap_cus_hdr d,
        sap_cus_sad e
      WHERE
        a.belnr = b.belnr
        AND b.qualf = ods_constants.purch_order_purch_order_type -- Purchase Order Type
        AND b.orgid = ods_constants.purch_order_icb_purch_order -- Inter-Company Business Purchase Order
        AND a.belnr = c.belnr
        AND c.parvw = ods_constants.purch_order_vendor -- c  Vendor
        AND c.partn = d.lifnr -- d Customer
        AND d.kunnr = e.kunnr
        AND e.vkorg = i_company_code -- e Company
        AND TRUNC(a.sap_sto_po_hdr_lupdt, 'DD') = TRUNC(v_retention_date, 'DD');
    rv_purchase_orders csr_purchase_orders%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_purch_order;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Purchase Order Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := get_retention_date(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS Purchase Orders for Company Code: ' ||
                  i_company_code || '.');
    -- Delete all Purchase Orders in the ODS whose creation date is before the retention date.
    OPEN csr_purchase_orders;
    LOOP

      -- Get the Purchase Orders to be purged.
      FETCH csr_purchase_orders INTO rv_purchase_orders;
      EXIT WHEN csr_purchase_orders%NOTFOUND;

            DELETE FROM sap_sto_po_con WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_dat WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_del WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_gen WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_hti WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_htx WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_itp WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_oid WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_org WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_pad WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_pay WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_pnr WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_ref WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_sch WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_smy WHERE belnr = rv_purchase_orders.belnr;
            DELETE FROM sap_sto_po_hdr WHERE belnr = rv_purchase_orders.belnr;

    END LOOP;
    CLOSE csr_purchase_orders;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Purchase Order Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS PURCHASE ORDER PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_purchase_orders%ISOPEN) THEN
        CLOSE csr_purchase_orders;
      END IF;

  END purge_ods_purchase_orders;



  PROCEDURE purge_ods_invoices(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    -- CURSORS
    CURSOR csr_invoices IS
      SELECT
        A.belnr -- Document number
      FROM
        sap_inv_hdr A, -- Header
        sap_inv_dat B, -- Date
        sap_inv_org C  -- Sales Organistion
      WHERE
        B.belnr = A.belnr
        AND C.belnr = A.belnr
        AND B.iddat = ods_constants.invoice_document_date
        AND B.datum < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND C.qualf = ods_constants.invoice_sales_org
        AND C.orgid = i_company_code;
    rv_invoices csr_invoices%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_invoice;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Invoice Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := get_retention_date(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS Invoices for Company Code: ' ||
                  i_company_code || '.');
    -- Delete all invoices in the ODS whose creation date is before the retention date.
    OPEN csr_invoices;
    LOOP

      -- Get the Invoices to be purged.
      FETCH csr_invoices INTO rv_invoices;
      EXIT WHEN csr_invoices%NOTFOUND;

      -- Delete all records associated with the Invoice in the ODS.
      DELETE sap_inv_smy WHERE belnr = rv_invoices.belnr; -- Invoice Summary
      DELETE sap_inv_icn WHERE belnr = rv_invoices.belnr; -- Item Condition
      DELETE sap_inv_ipn WHERE belnr = rv_invoices.belnr; -- Item Partner
      DELETE sap_inv_ias WHERE belnr = rv_invoices.belnr; -- Item Amount
      DELETE sap_inv_iob WHERE belnr = rv_invoices.belnr; -- Item Object Identifier
      DELETE sap_inv_idt WHERE belnr = rv_invoices.belnr; -- Item Date
      DELETE sap_inv_irf WHERE belnr = rv_invoices.belnr; -- Item Reference
      DELETE sap_inv_mat WHERE belnr = rv_invoices.belnr; -- Item Material Desc
      DELETE sap_inv_gen WHERE belnr = rv_invoices.belnr; -- Item General
      DELETE sap_inv_org WHERE belnr = rv_invoices.belnr; -- Sales Organisation
      DELETE sap_inv_cur WHERE belnr = rv_invoices.belnr; -- Currency
      DELETE sap_inv_dat WHERE belnr = rv_invoices.belnr; -- Date
      DELETE sap_inv_ref WHERE belnr = rv_invoices.belnr; -- Reference
      DELETE sap_inv_pnr WHERE belnr = rv_invoices.belnr; -- Partner
      DELETE sap_inv_con WHERE belnr = rv_invoices.belnr; -- Condition
      DELETE sap_inv_hdr WHERE belnr = rv_invoices.belnr; -- Header
      COMMIT;


    END LOOP;
    CLOSE csr_invoices;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Invoice Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS INVOICE PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_invoices%ISOPEN) THEN
        CLOSE csr_invoices;
      END IF;

  END purge_ods_invoices;



  PROCEDURE purge_ods_invoice_sum(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    -- CURSORS
    CURSOR csr_invoice_summaries IS
      SELECT
        fkdat, -- Invoice Creation Date
        bukrs  -- Company Code
      FROM
        sap_inv_sum_hdr A
      WHERE
        fkdat < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND bukrs = i_company_code;
    rv_invoice_summaries csr_invoice_summaries%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_inv_summ;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Invoice Summary Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := get_retention_date(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS Invoice Summaries for Company Code: ' ||
                  i_company_code || '.');
     -- Delete all invoice summaries in the ODS whose creation date is before the retention date.
    OPEN csr_invoice_summaries;
    LOOP

      -- Get the Invoice Summaries to be purged.
      FETCH csr_invoice_summaries INTO rv_invoice_summaries;
      EXIT WHEN csr_invoice_summaries%NOTFOUND;

      -- Delete all records associated with the Invoice Summary in the ODS.
      DELETE
        sap_inv_sum_det -- Summary Detail
      WHERE
        fkdat = rv_invoice_summaries.fkdat
        AND vkorg = rv_invoice_summaries.bukrs;

      DELETE
        sap_inv_sum_hdr -- Summary Header
      WHERE
        fkdat = rv_invoice_summaries.fkdat
        AND bukrs = rv_invoice_summaries.bukrs;

      COMMIT;


    END LOOP;
    CLOSE csr_invoice_summaries;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Invoice Summary Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS INVOICE SUMMARY PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_invoice_summaries%ISOPEN) THEN
        CLOSE csr_invoice_summaries;
      END IF;

  END purge_ods_invoice_sum;



  PROCEDURE purge_ods_hierarchies(
    i_company_code      IN company.company_code%TYPE,
    i_retention_days    IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    -- CURSORS
    CURSOR csr_hierarchies IS
      SELECT DISTINCT
        A.hdrdat, -- Header Date
        A.hdrseq  -- Header Seq Number
      FROM
        sap_hie_cus_hdr A,
        sap_hie_cus_det B
      WHERE
        B.vkorg = i_company_code
        AND A.hdrdat < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND B.hdrdat = A.hdrdat
        AND B.hdrseq = A.hdrseq;
    rv_hierarchies csr_hierarchies%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_hierarchy;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Hierarchy Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := trunc(sysdate - i_retention_days, 'DD');

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS Hierarchy Data for Company Code: ' ||
                  i_company_code || '.');

      -- Delete all hierachies in the ODS whose creation date is before the retention date.
      OPEN csr_hierarchies;
      LOOP

        -- Get the Hierarchies to be purged.
        FETCH csr_hierarchies INTO rv_hierarchies;
        EXIT WHEN csr_hierarchies%NOTFOUND;

         -- Delete all records associated with the Hierarchy in the ODS.
        DELETE
          sap_hie_cus_det
        WHERE
          hdrdat = rv_hierarchies.hdrdat
          AND hdrseq = rv_hierarchies.hdrseq; -- Hierarchy Detail

        DELETE
          sap_hie_cus_hdr
        WHERE
          hdrdat = rv_hierarchies.hdrdat
          AND hdrseq = rv_hierarchies.hdrseq; -- Hierarchy Header

        COMMIT;


      END LOOP;
      CLOSE csr_hierarchies;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Hierarchy Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS HIERARCHY PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_hierarchies%ISOPEN) THEN
        CLOSE csr_hierarchies;
      END IF;

  END purge_ods_hierarchies;



  PROCEDURE purge_ods_stock_balances(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    -- CURSORS
     CURSOR csr_stock_balances IS
      SELECT
        bukrs, -- Company Code
        werks, -- Plant
        lgort, -- Storage Location
        budat, -- Date of Stock Balance
        timlo  -- Stock Balance Time
      FROM
        sap_stk_bal_hdr
      WHERE
        vbund = i_company_code
        AND budat < TO_CHAR(v_retention_date, 'YYYYMMDD');
    rv_stock_balances csr_stock_balances%ROWTYPE;


  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_intransit;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Stock Balance Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := get_retention_date(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS Stock Balance Data for Company Code: ' ||
                  i_company_code || '.');
    -- Delete all stock balances in the ODS whose creation date is before the retention date.
    OPEN csr_stock_balances;
    LOOP

      -- Get the Stock Balances to be purged.
      FETCH csr_stock_balances INTO rv_stock_balances;
      EXIT WHEN csr_stock_balances%NOTFOUND;

      -- Delete all records associated with the Stock Balance in the ODS.
      DELETE
        sap_stk_bal_det -- Balance Detail
      WHERE
        bukrs = rv_stock_balances. bukrs
        AND werks = rv_stock_balances.werks
        AND lgort = rv_stock_balances.lgort
        AND budat = rv_stock_balances.budat
        AND timlo = rv_stock_balances.timlo;

      DELETE
        sap_stk_bal_hdr -- Balance Header
      WHERE
        bukrs = rv_stock_balances. bukrs
        AND werks = rv_stock_balances.werks
        AND lgort = rv_stock_balances.lgort
        AND budat = rv_stock_balances.budat
        AND timlo = rv_stock_balances.timlo;

      COMMIT;

    END LOOP;
    CLOSE csr_stock_balances;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Sock Balance Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS STOCK BALANCE PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_stock_balances%ISOPEN) THEN
        CLOSE csr_stock_balances;
      END IF;

  END purge_ods_stock_balances;



  PROCEDURE purge_ods_intransits(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date DATE;

    -- CURSORS
    CURSOR csr_icb_intransits IS
      SELECT
        venum -- External Handling Unit ID
      FROM
        sap_icb_llt_hdr
      WHERE
        bukrs = i_company_code
        AND SUBSTR(idoc_timestamp, 1, 8) < TO_CHAR(v_retention_date, 'YYYYMMDD');
    rv_icb_intransits csr_icb_intransits%ROWTYPE;


    CURSOR csr_stock_intransit IS
          SELECT
              werks -- plant code
            FROM
              sap_int_stk_hdr
            WHERE
              TRUNC(sap_int_stk_hdr_lupdt, 'DD') < TRUNC(v_retention_date, 'DD');
        rv_stock_intransit csr_stock_intransit%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_intransit;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Intransit Data Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention date. That is, the date FROM which data
    -- must be retained.
    v_retention_date := get_retention_date(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS ICB Intransit Data for Company Code: ' ||
                  i_company_code || '.');
    -- Delete all icb intransits in the ODS whose IDOC date/time stamp is before the retention date.
    OPEN csr_icb_intransits;
    LOOP

      -- Get the ICB Intransits to be purged.
      FETCH csr_icb_intransits INTO rv_icb_intransits;
      EXIT WHEN csr_icb_intransits%NOTFOUND;

      -- Delete all records associated with the ICB Intransit in the ODS.
      DELETE sap_icb_llt_det WHERE venum = rv_icb_intransits.venum; -- Detail
      DELETE sap_icb_llt_hdr WHERE venum = rv_icb_intransits.venum; -- Header
      COMMIT;

    END LOOP;
    CLOSE csr_icb_intransits;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Deleting the ICB Intransit Data for Company Code: ' ||
                  i_company_code || '.');



    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting the Stock Intransit Data.');
        OPEN csr_stock_intransit;
        LOOP

          -- Getting all the Stock Intransit rows that are to old
            FETCH csr_stock_intransit INTO rv_stock_intransit;
            EXIT WHEN csr_stock_intransit%NOTFOUND;

      -- Delete all records associated with the Stock Intransit in the ODS.
      DELETE sap_int_stk_det WHERE werks = rv_stock_intransit.werks; -- Detail
      DELETE sap_int_stk_hdr WHERE werks = rv_stock_intransit.werks; -- Header
      COMMIT;

        END LOOP;
        CLOSE csr_stock_intransit;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Deleting the ICB Intransit Data.');


    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Intransit Data Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS INTRANSIT PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_icb_intransits%ISOPEN) THEN
        CLOSE csr_icb_intransits;
      END IF;

      IF (csr_stock_intransit%ISOPEN) THEN
        CLOSE csr_stock_intransit;
      END IF;

  END purge_ods_intransits;



  PROCEDURE purge_ods_forecasts(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_period PLS_INTEGER;

    -- CURSORS
    CURSOR csr_forecasts IS
      SELECT
        fcst_hdr_code -- Header Code
      FROM
        fcst_hdr
      WHERE
        sales_org_code = i_company_code
        AND ((casting_year * 100) + casting_period) < v_retention_period
        AND current_fcst_flag <> ods_constants.fcst_current_fcst;
    rv_forecasts csr_forecasts%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_forecast;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Forecast Data Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention period.');
    -- Get the retention period. That is, the date FROM which data
    -- must be retained.
    v_retention_period := get_retention_period(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the ODS Forecast Data for Company Code: ' ||
                  i_company_code || '.');
     -- Delete all forecasts in the ODS whose casting year / period is before the retention date.
    OPEN csr_forecasts;
    LOOP

      -- Get the Forecasts to be purged.
      FETCH csr_forecasts INTO rv_forecasts;
      EXIT WHEN csr_forecasts%NOTFOUND;

      -- Delete all records associated with the Intransit in the ODS.
      DELETE fcst_dtl WHERE fcst_hdr_code = rv_forecasts.fcst_hdr_code; -- Detail
      DELETE fcst_hdr WHERE fcst_hdr_code = rv_forecasts.fcst_hdr_code; -- Header
      COMMIT;

    END LOOP;
    CLOSE csr_forecasts;


    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Forecast Data Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS FORECASTS PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_forecasts%ISOPEN) THEN
        CLOSE csr_forecasts;
      END IF;

  END purge_ods_forecasts;



  PROCEDURE purge_ods_deleted_forecasts(
    i_company_code IN company.company_code%TYPE,
    i_log_level    IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_period PLS_INTEGER;

    -- CURSORS
    CURSOR csr_forecasts IS
      SELECT
        fcst_hdr_code -- Header Code
      FROM
        fcst_hdr
      WHERE
        sales_org_code = i_company_code
        AND current_fcst_flag <> ods_constants.fcst_current_fcst_flag_deleted;
    rv_forecasts csr_forecasts%ROWTYPE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_forecast;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting ODS Deleted Forecast Data Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;

    OPEN csr_forecasts;
    LOOP
      FETCH csr_forecasts INTO rv_forecasts;
      EXIT WHEN csr_forecasts%NOTFOUND;

      -- Delete all records associated with the Forecast in the ODS.
      DELETE fcst_dtl WHERE fcst_hdr_code = rv_forecasts.fcst_hdr_code; -- Detail
      DELETE fcst_hdr WHERE fcst_hdr_code = rv_forecasts.fcst_hdr_code; -- Header
      COMMIT;

    END LOOP;
    CLOSE csr_forecasts;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished ODS Deleted Forecast Data Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR ODS DELETED FORECASTS PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      IF (csr_forecasts%ISOPEN) THEN
        CLOSE csr_forecasts;
      END IF;

  END purge_ods_deleted_forecasts;


  PROCEDURE purge_dds_forecasts(
    i_company_code      IN company.company_code%TYPE,
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_period PLS_INTEGER;
    v_num_row_to_delete PLS_INTEGER;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_ods_purge;
    v_sort_field := ods_constants.data_type_forecast;
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting DDS Forecast Purging for Company Code: ' ||
                  i_company_code || '.');
    v_log_level := v_log_level + 1;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the retention date.');
    -- Get the retention period. That is, the date FROM which data
    -- must be retained.
    v_retention_period := get_retention_period(i_retention_periods, v_log_level + 1);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting all the DDS Forecast for Company Code: ' ||
                  i_company_code || '.');
    -- Delete all forecasts in the DDS whose creation date is before the retention date.
    -- DONE THIS WAY SO THAT WE DO NOT RUN OUT OF TEMP SPACE
    LOOP
      SELECT
        COUNT(*)
      INTO
        v_num_row_to_delete
      FROM
        fcst_fact
      WHERE
        company_code = i_company_code
        AND fcst_yyyypp < v_retention_period;

      EXIT WHEN v_num_row_to_delete = 0;

      DELETE
        fcst_fact
      WHERE
        company_code = i_company_code
        AND fcst_yyyypp < v_retention_period;

      COMMIT;
		END LOOP;

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished DDS Forecast Purging for Company Code: ' ||
                  i_company_code || '.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR DDS FORECAST PURGING ' ||
                    'FOR Company Code: ' ||
                    i_company_code ||
                    '.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

      --IF (csr_forecasts%ISOPEN) THEN
      --  CLOSE csr_forecasts;
      --END IF;

  END purge_dds_forecasts;



  PROCEDURE purge_logs(
    i_max_log_level  IN NUMBER,
    i_retention_prds IN NUMBER DEFAULT ods_constants.logs_retn_prds,
    i_retention_days IN NUMBER DEFAULT ods_constants.logs_retn_days,
    i_log_level      IN ods.log.log_level%TYPE DEFAULT 0
    ) IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- Local Variables
    v_retention_date       DATE;
    v_num_rows_to_delete   PLS_INTEGER := 0;

    v_prds_deleted_row_num PLS_INTEGER := 0;
    v_days_deleted_row_num PLS_INTEGER := 0;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := ods_constants.data_type_log_purge;
    v_sort_field := ods_constants.data_type_log_purge;
    v_log_level  := i_log_level;


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Logs Purging.');
    v_log_level := v_log_level + 1;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting the entire log, for logs that have been in ' ||
                  'the system greater than: ' || i_retention_prds || ' period(s).');
    -- Getting the day minus the number of retention periods
    v_retention_date := get_retention_date(i_retention_prds, v_log_level + 1);

    -- DONE THIS WAY SO THAT WE DO NOT RUN OUT OF TEMP SPACE
    LOOP
      SELECT
        COUNT(*)
      INTO
        v_num_rows_to_delete
      FROM
        ods.log
      WHERE
        TO_CHAR(log.log_lupdt, 'YYYYMMDD') < TO_CHAR(v_retention_date, 'YYYYMMDD');

      EXIT WHEN v_num_rows_to_delete = 0;

      DELETE FROM
        ods.log
      WHERE
        TO_CHAR(log.log_lupdt, 'YYYYMMDD') < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND ROWNUM < ods_constants.max_rows_before_commit;

      COMMIT;

      IF (v_num_rows_to_delete < ods_constants.max_rows_before_commit) THEN
        v_prds_deleted_row_num := v_prds_deleted_row_num + v_num_rows_to_delete;
      ELSE
        v_prds_deleted_row_num := v_prds_deleted_row_num + ods_constants.max_rows_before_commit;
      END IF;

    END LOOP;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  v_prds_deleted_row_num || ' rows deleted from the log table ' ||
                  'that had a date greater than: ' || i_retention_prds || ' period(s).');


    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Deleting the sections of the log, that have a log level ' ||
                  'greater than: ' || i_max_log_level || ' and have been in the '||
                  'system for greater than: ' || i_retention_days || ' days.');
    -- Get the date minus the number of retention days
    v_retention_date := sysdate - i_retention_days;

    -- DONE THIS WAY SO THAT WE DO NOT RUN OUT OF TEMP SPACE
    LOOP
      SELECT
        COUNT(*)
      INTO
        v_num_rows_to_delete
      FROM
        ods.log
      WHERE
        TO_CHAR(log.log_lupdt, 'YYYYMMDD') < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND log_level > i_max_log_level;

      EXIT WHEN v_num_rows_to_delete = 0;

      DELETE FROM
        ods.log
      WHERE
        TO_CHAR(log.log_lupdt, 'YYYYMMDD') < TO_CHAR(v_retention_date, 'YYYYMMDD')
        AND log_level > i_max_log_level
        AND ROWNUM < ods_constants.max_rows_before_commit;

      COMMIT;

      IF (v_num_rows_to_delete < ods_constants.max_rows_before_commit) THEN
        v_days_deleted_row_num := v_days_deleted_row_num + v_num_rows_to_delete;
      ELSE
        v_days_deleted_row_num := v_days_deleted_row_num + ods_constants.max_rows_before_commit;
      END IF;

    END LOOP;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  v_days_deleted_row_num || ' rows deleted from the log table ' ||
                  'that had a date greater than: ' || i_retention_days ||
                  ' days and that have a log level greater than: ' || i_max_log_level || '.');

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Logs Purging.');

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR LOGS PURGING.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

  END purge_logs;



  FUNCTION get_retention_date(
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN DATE IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_retention_periods PLS_INTEGER;
    v_retention_date    DATE;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := 'N/A';
    v_sort_field := 'GET RETENTION DATE';
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Get Retention Date.');
    v_log_level := v_log_level + 1;


    -- In case the retention periods was a negative, make it a positive.
    v_retention_periods := ABS(i_retention_periods);

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Getting the Retention Date.');
    -- Get the retention date, which is the earliest date in the period, which is input_retention_periods
    SELECT
      MIN(calendar_date) INTO v_retention_date
    FROM
      mars_date_dim
    WHERE
      mars_prd_seq_num = (SELECT
                            mars_prd_seq_num - v_retention_periods
                          FROM
                            mars_date_dim
                          WHERE
                            yyyymmdd_date = to_char(sysdate,'yyyymmdd'));

    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Get Retension Date.');

    RETURN v_retention_date;
  EXCEPTION
    WHEN OTHERS THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR GET RETENTION DATE.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

  END get_retention_date;



  FUNCTION get_retention_period(
    i_retention_periods IN NUMBER,
    i_log_level         IN ods.log.log_level%TYPE DEFAULT 0
    ) RETURN NUMBER IS

    -- Logging Variables
    v_job_type   ods.log.job_type_code%TYPE;
    v_data_type  ods.log.data_type%TYPE;
    v_sort_field ods.log.sort_field%TYPE;
    v_log_level  ods.log.log_level%TYPE;

    -- LOCAL VARIABLES
    v_retention_periods PLS_INTEGER;
    v_mars_yyyypp       PLS_INTEGER;

  BEGIN
    v_job_type   := ods_constants.job_type_purge;
    v_data_type  := 'N/A';
    v_sort_field := 'GET RETENTION PERIOD';
    v_log_level  := i_log_level;

    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Starting Get Retension Period.');
    v_log_level := v_log_level + 1;

    -- In case the retention periods was a negative, make it a positive.
    v_retention_periods := ABS(i_retention_periods);

    -- Get the retention date, which is the earliest date in the period, which is input_retention_periods
    SELECT DISTINCT
      mars_period
    INTO
      v_mars_yyyypp
    FROM
      mars_date_dim
    WHERE
      mars_prd_seq_num = (SELECT
                            A.mars_prd_seq_num - v_retention_periods
                          FROM
                            mars_date_dim A
                          WHERE
                            A.yyyymmdd_date = TO_CHAR(sysdate, 'yyyymmdd'));


    v_log_level := v_log_level - 1;
    utils.ods_log(v_job_type,
                  v_data_type,
                  v_sort_field,
                  v_log_level,
                  'Finished Get Retension Period.');

    RETURN v_mars_yyyypp;
  EXCEPTION
    WHEN OTHERS THEN
      utils.ods_log(v_job_type,
                    v_data_type,
                    ods_constants.data_type_error,
                    0,
                    '!!!ERROR!!! - FATAL ERROR FOR GET RETENTION PERIOD PURGING.' ||
                    ' ERROR MESSAGE: ' || SUBSTR(SQLERRM, 1, 512));

      v_had_errors := TRUE;
      error_table(v_error_count).data_type     := v_data_type;
      error_table(v_error_count).sort_field    := v_sort_field;
      error_table(v_error_count).error_message := SUBSTR(SQLERRM, 1, 70);
      v_error_count := v_error_count + 1;

  END get_retention_period;

END purge;
/
