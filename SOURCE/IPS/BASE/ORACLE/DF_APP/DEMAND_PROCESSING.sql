create or replace PACKAGE        demand_processing AS
  /*******************************************************************************
   NAME:      DEMAND_PROCESSING
   PURPOSE:   This package calls the key Demand Forecast procedures, to carry out
              certain processes.
  ********************************************************************************/

  /*******************************************************************************
    NAME:      PUBLISH_FORECAST
    PURPOSE:   This procedure was built for use with the Promax Demand forecast
               process into demand financials.    The logic of this function is 
               to 
               
               1.  Look for a forecast file that matches the current casting week.
                   If not found create a new forecast by copying the most recent
                   one it can find and copy its data into a new forecast with 
                   this casting week, and ensuring no data prior to the casting 
                   week is copied.
               2.  Take the found forecast and create the normal forecast create
                   event and trigger its event so that any normal on processing 
                   is performed, such as sending to Venus. 

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   08/07/2013 Chris Horn           Created this procedure.

    NOTES:     This procedure will be called by a scheduled lics job that will
               run on a Saturday.  
   ********************************************************************************/
  PROCEDURE publish_forecast (i_moe_code IN common.st_code);

  /*******************************************************************************
    NAME:      PROCESS_SUPPLY
    PURPOSE:   This fucntion perform the supply file processing.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   5/04/2006 Nick Bates            Added this header

    NOTES:
   ********************************************************************************/
  FUNCTION process_supply (i_run_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      PROCESS_DEMAND
    PURPOSE:   This function performs the demand file processing.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   5/04/2006 Nick Bates            Added this header
    1.1

    NOTES:
   ********************************************************************************/
  FUNCTION process_demand (i_run_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      PROCESS_SUPPLY_DRAFT
    PURPOSE:   This function performs the supply draft file processing.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   01/12/2006 Steve Gregan         Added this header

    NOTES:
   ********************************************************************************/
  FUNCTION process_supply_draft (i_run_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      PROCESS_DEMAND_DRAFT
    PURPOSE:   This function performs the demand draft file processing.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   22/10/2006 Steve Gregan         Added this header

    NOTES:
   ********************************************************************************/
  FUNCTION process_demand_draft (i_run_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      LOAD_REFERENCE_DATA
    PURPOSE:   This function will load all the required reference tables from LADS
               into this database.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   5/04/2006 Nick Bates            Added this header

    NOTES:
   ********************************************************************************/
  FUNCTION load_reference_data (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      run_batch
    PURPOSE:   This functions is called by MQ-SERIES everytime a supply or demand file arrives

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   04/05/2006 Nick Bates            Added this header

    NOTES:
   ********************************************************************************/
  PROCEDURE run_batch;



   /*******************************************************************************
   NAME:      run_batch_common
   PURPOSE:   This function is called by run batch everytime a supply or demand file arrives
               and the GUI. It is a procedure as it is called from a DBMS Job and run in the background.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   28/05/2007 Sal Sanghera         Added this header
   1.1   30/05/2007 Chris Horn           Changed procedure to use boolean.

   NOTES:
  ********************************************************************************/
  PROCEDURE run_batch_common (i_refresh IN BOOLEAN);

  /*******************************************************************************
    NAME:      PERFORM_HOUSEKEEPING
    PURPOSE:   This procedure will be called on a weekly basis to clear out any
               old files and data from the load tables and the unix file system.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   23/05/2006 Chris Horn           Created this procedure.

    NOTES:     Any file with a loaded date older than 35 days are removed.
   ********************************************************************************/
  PROCEDURE perform_housekeeping;
END demand_processing; 
 