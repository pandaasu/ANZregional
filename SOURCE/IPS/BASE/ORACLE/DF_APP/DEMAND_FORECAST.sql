create or replace 
PACKAGE        demand_forecast AS
  /*******************************************************************************
   NAME:      DEMAND_FORECAST
   PURPOSE:   This package provides all the key processing functionality required
              for taking Apollo demand and supply forecasts and creating a
              combined forecast by GSV.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-11-26  <Many>                Previous Versions.  No Change History.
  2013-11-27  Chris Horn            Added promax type codes.
  2013-12-02  Chris Horn            Added new demand loading number translation
                                    codes. 
              
  ********************************************************************************/
  -- Forecast Type Constants
  gc_ft_fcst                   CONSTANT common.st_code           := 'FCST';   -- Standard forecast
  gc_ft_br                     CONSTANT common.st_code           := 'BR';   -- BR forecast
  gc_ft_rob                    CONSTANT common.st_code           := 'ROB';   -- ROB forecast
  gc_ft_op                     CONSTANT common.st_code           := 'OP';   -- Operating plan forecast
  gc_ft_draft                  CONSTANT common.st_code           := 'DRAFT';   -- Draft forecast
  -- File Status Constants
  gc_fs_invalid                CONSTANT common.st_code           := 'I';   -- Invalid forecasr supply and demand need to be complete
  gc_fs_valid                  CONSTANT common.st_code           := 'V';   -- forecast valid supply and demand complete
  gc_fs_deleted                CONSTANT common.st_code           := 'D';   -- forecast deleted
  gc_fs_archived               CONSTANT common.st_code           := 'A';   -- forecast archived.
  gc_fs_unarchived             CONSTANT common.st_code           := 'U';   -- forecast unarchived.
  -- System Constants
  gc_system_code               CONSTANT common.st_code           := 'DEMAND_FINANCIALS';
  gc_system_name               CONSTANT common.st_message_string := 'DEMAND FINANCIALS';
  gc_system_description        CONSTANT common.st_message_string := 'Demand Financials - Forecast Consolidation and GSV Calculation.';
  -- Demand Alerting Constants
  gc_demand_alerting_group     CONSTANT common.st_message_string := 'DEMAND FINANCIALS ALERTING';
  gc_demand_group_code_demand  CONSTANT common.st_code           := 'DEMAND';
  gc_demand_group_code_supply  CONSTANT common.st_code           := 'SUPPLY';
  -- File Search Wild Card Constants
  gc_wildcard_demand           CONSTANT common.st_message_string := 'demand_';
  gc_wildcard_supply           CONSTANT common.st_message_string := 'supply_';
  gc_wildcard_sply_draft       CONSTANT common.st_message_string := 'draft_sply_';
  gc_wildcard_dmnd_draft       CONSTANT common.st_message_string := 'draft_dmd_';
  -- Demand Forecast Types 
  gc_dmnd_type_0               CONSTANT common.st_status           := '0';   -- Demand Financials Adjustment
  gc_dmnd_type_1               CONSTANT common.st_status           := '1';   -- Base
  gc_dmnd_type_2               CONSTANT common.st_status           := '2';   -- Aggregated Market Activities
  gc_dmnd_type_3               CONSTANT common.st_status           := '3';   -- Lock
  gc_dmnd_type_4               CONSTANT common.st_status           := '4';   -- Reconcile
  gc_dmnd_type_5               CONSTANT common.st_status           := '5';   -- Auto Adjustment
  gc_dmnd_type_6               CONSTANT common.st_status           := '6';   -- Override
  gc_dmnd_type_7               CONSTANT common.st_status           := '7';   -- Market Activities
  gc_dmnd_type_8               CONSTANT common.st_status           := '8';   -- Data Driven Event
  gc_dmnd_type_9               CONSTANT common.st_status           := '9';   -- Target Impact
  gc_dmnd_type_b               CONSTANT common.st_status           := 'B';   -- The base as supplied from promax.  - Code 10 in demand file.
  gc_dmnd_type_p               CONSTANT common.st_status           := 'P';   -- The retained base, for calculation P = B - 1. Delete B where 1 is not null.
  gc_dmnd_type_u               CONSTANT common.st_status           := 'U';   -- Promax Uplift. - Code 11 in demand file.
  -- Account Assignment Constants
  gc_acct_assgnmnt_domestic    CONSTANT common.st_code             := '01';   -- Domestic Account Assignment Group 

  /*******************************************************************************
   NAME:      REDO_TDU
   PURPOSE:   Function takes in a existing forecast id, and recalculates the material determination, zrep
              for a given xzep,  the process will only process , demand groups of the type 'demand' not supply.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006   Nick Bates            Added this header
   1.1   04-Apr-2008 Scott R. Harding    Added material determination offset

   NOTES:
  ********************************************************************************/
  FUNCTION redo_tdu (i_fcst_id IN common.st_id, o_message_out OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      REDO_PRICES
   PURPOSE:   Functions takes an existing forecast id, and recalculates the price for all records suppply and demand.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION redo_prices (i_fcst_id IN common.st_id, i_dmnd_grp_id IN common.st_id, i_acct_assign_id IN common.st_id, o_message_out OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      GET_TDU
   PURPOSE:   Function to to lookup tdu for a given zrep-- start by qualifing the sales organisation and distribution channel
              then with distribution channel, then the material code by itself

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006  Nick Bates           Added this header
   1.1   15/12/2006 Steve Gregan         Addes demand geoup and account assignment

   NOTES:
  ********************************************************************************/
  FUNCTION get_tdu (
    i_material_code         IN      common.st_code,
    i_distribution_channel  IN      common.st_code,
    i_sales_org             IN      common.st_code,
    i_bill_to_code          IN      common.st_code,
    i_ship_to_code          IN      common.st_code,
    i_cust_hrrchy_code      IN      common.st_code,
    i_calendar_day          IN      common.st_code,
    o_tdu                   OUT     common.st_code,
    o_message_out           OUT     common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      GET_SOURCE_CODE
   PURPOSE:   This function determins which source code to apply to a material.
              It defaults to "OTHER" if it cannot find a match on either
              i_material X matl_moe X moe_source_xref
              or
              i_material X item_source_xref table.



   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   10/05/2006 Chris Horn           Created this function.

   NOTES:     For performance reasons this function caches the results of previous
              lookups.
  ********************************************************************************/
  FUNCTION get_source_code (i_material_code IN common.st_code)
    RETURN common.st_code;

  /*******************************************************************************
   NAME:      COPY_FORECAST
   PURPOSE:   Function to copy a complete forecast of the type FCST to BR or OP,ROB.
              Copy to BR does NOT require a period from and period to,  incomplete first and last period for a given forecast will be trimmed
              out of the resulting BR.
              OP and ROB require the specification of the period from and period to parameters.
              the i_period_from period will be incremented by one period.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/

  FUNCTION copy_forecast (
    i_src_fcst_id       IN      common.st_id,
    i_fcst_type         IN      common.st_code,
    i_data_entity_code  IN      common.st_code,
    i_period_from       IN      common.st_code,
    i_period_to         IN      common.st_code,
    o_result_msg        OUT     common.st_message_string)
    RETURN common.st_result;

/*******************************************************************************
   NAME:      COPY_DRAFT_FORECAST
   PURPOSE:   Function to copy a complete draft forecast DRAFT to type FCST.
              It does not create the normal on event creation items as on 
              creating this forecast we do not want to trigger the normal 
              forecast event processing. 

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   08/07/2013 Chris Horn           Created this procedure.

   NOTES: This was based of the normal copy forecast function.
  ********************************************************************************/

  FUNCTION copy_draft_forecast (
    i_src_fcst_id       IN      common.st_id,
    o_result_msg        OUT     common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
     NAME:      FCST_COMPL_CHECK
     PURPOSE:   This function checks to see if a supply and demand file are
                required for the forecast.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   14/02/2008 Mary Ahyick          Created this function.

     NOTES:
    ********************************************************************************/

 FUNCTION fcst_compl_check (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;


  /*******************************************************************************
     NAME:      DRFT_COMPL_CHECK
     PURPOSE:   This function checks to see if a supply and demand file are
                required for the forecast.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   14/02/2008 Mary Ahyick          Created this function.

     NOTES:
    ********************************************************************************/

 FUNCTION drft_compl_check (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;


  /*******************************************************************************
     NAME:      MARK_FORECAST_VALID
     PURPOSE:   This function takes a forecast id and marks it as being valid.
                Once this forecast is valid then the rest of the processing can
                occur for that forecast.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   29/05/2006 Chris Horn           Created this function.
	   1.1   22/10/2006 Steve Gregan         Modified function to accept both FCST and DRAFT.
     1.2   02/12/2013 Chris Horn           Perform the promax base reconcilliation adjustment.

     NOTES:
    ********************************************************************************/
  FUNCTION mark_forecast_valid (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
     NAME:      BR_CREATION_CHECK
     PURPOSE:   This function checks to see if the supplied forecast has a casting
                week that is equal to the maximum week for the specified period.
                If it does then excute the copy forecast function to copy this
                forecast into its corresponding BR.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   25/05/2006 Chris Horn           Created this function.

     NOTES:     Maximum week is not always 4 it can sometimes be 5.
    ********************************************************************************/
  FUNCTION br_creation_check (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;


  /*******************************************************************************
   NAME:      UNARCHIVE_FORECAST
   PURPOSE:   restores an archived forecast from the dmnd_data_arch table, and moves them to the dmnd_data table
              Update the forecast status to  un-archived.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   16/05/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION unarchive_forecast (i_forecast_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      ATCHIVE_FORECAST
    PURPOSE:   Removes the records for a forecast from the dmnd_data table, and moves them to the dmnd_data_acrh table
               Update the forecast status to archived.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/04/2006 Nick Bates            Added this header

    NOTES:
   ********************************************************************************/
  FUNCTION archive_forecast (i_forecast_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      PURGE_FORECAST
    PURPOSE:   Removes the records for a forecast from the dmnd_data table,
               and removes records from fcst.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   06/04/2006 Nick Bates            Added this header

    NOTES:
   ********************************************************************************/
  FUNCTION purge_forecast (i_forecast_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      CREATE_FORECAST
   PURPOSE:   Function to created new forecast, uses casting week within forecast file
              to establish weather a forcast has already been created,  forecast type is
              also used to establish uniqueness.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header
   1.1   22/10/2006 Steve Gregan         Modified function to accept moe code.

   NOTES:
  ********************************************************************************/
  FUNCTION create_forecast (
    i_forecast_type  IN      common.st_code,
    i_casting_week   IN      common.st_code,
    i_status         IN      common.st_code,   -- casting week read from incoming file, after data is loaded
	i_moe_code       IN      common.st_code,
    o_forecast_id    OUT     common.st_id,
    o_result_msg     OUT     common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      GET_MARS_WEEK
   PURPOSE:   function below will take in a standard data as string, and return a mars period with week , qualified

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION get_mars_week (i_string_date IN VARCHAR, i_format_string IN VARCHAR, o_mars_week OUT VARCHAR, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      SQL_GET_MARS_WEEK
   PURPOSE:   function used to convert a normal data into a mars weeks, i.e.  YYYYPPW   (Year, Mars Period, Mars week)
              function only called from sql statements, as a calculated column.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION sql_get_mars_week (i_date IN DATE)
    RETURN NUMBER;

  /*******************************************************************************
   NAME:      GET_PRICE
   PURPOSE:   Function to return the price for a given material, always assumes the sales organisation of 147.
              The the strinf i_formula will detemine how the price will found, and in which order the pricing
              condition will be apply, the pricing conditions will be applyed in turn until a price is found
              The order of the pricing condition is ser within the dmnd_grp table for each demand group.
              The calling procedure will read the pricing formula from the dmnd_grp table and pass it to this function.
              It will return the price, and the pricing condition used to find the price.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header
   1.1   16/07/2006 Chris Horn           Added code to handle the surchages.

   NOTES:
  ********************************************************************************/
  FUNCTION get_price (
    i_zrep_code             IN      common.st_code,
    i_tdu_code              IN      common.st_code,
    i_distribution_channel  IN      common.st_code,
    i_bill_to               IN      common.st_code,
    i_company_code          IN      common.st_code,
    i_invoicing_party       IN      common.st_code,
    i_warehouse_list        in      dmnd_grp.SPLY_WHSE_LST%type, -- Supply warehouse list.
    i_calendar_day          IN      common.st_code,
    i_formula               IN      dmnd_grp_org.pricing_formula%TYPE,
    i_currency              IN      common.st_code,
    o_pricing_condition     OUT     dmnd_data.price_condition%TYPE,
    o_price                 OUT     common.st_value,
    o_result_msg            OUT     common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      GET_ZREP_FOR_TDU
   PURPOSE:   find the zrep for a given tdu, for a specified data.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION get_zrep_for_tdu (i_tdu IN common.st_code, o_zrep OUT common.st_code, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      LOAD_SUPPLY_FEED
   PURPOSE:   load the data from the file to be loaded into the holding table load_sply_raw.
              after the data has been loaded into the raw table from the os files, the record will be transfered to the load_sply tables.
              if they meet the required format definitions.
              set to processed flag to 'LOADED' for these records, so that the process_supply_feed functions know which records to load.
              function will split that flat file into separate fields
              mars week and casting week will be calculated as part of this function to aid performance, the rest of logic is applied by the process function


   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header
   1.1   22/10/2006 Steve Gregan         Added wildcard parameter to allow for draft forecasts

   NOTES:
  ********************************************************************************/
  FUNCTION load_supply_feed (i_run_id IN common.st_id, i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      PROCESS_SUPPLY_FEED
   PURPOSE:   function to create the forecast of the tyoe FCST, and validate data from load_sply, the results validated records
              will be loaded into the dmnd_data table, check will be performed to validate demand group and tdu, the price and zrep will then
              calculated, records that pass validation will be set to 'PROCESSED' otherwise set to 'ERRORED'


   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header
   1.1   22/10/2006 Steve Gregan         Added wildcard parameter to allow for draft forecasts

   NOTES:
  ********************************************************************************/
  FUNCTION process_supply_feed (i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      LOAD_DEMAND_FEED
   PURPOSE:   load the data from the file to be loaded into the holding table load_dmnd_raw.
              after the data has been loaded into the raw table from the os files, the record will be transfered to the load_dmnd tables.
              if they meet the required format definitions.
              set to processed flag to 'LOADED' for these records, so that the process_demand_feed functions know which records to load.
              function will split that flat file into separate fields.
              mars week and casting week will be calculated as part of this function to aid performance, the rest of logic is applied by the process function


   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header
   1.1   22/10/2006 Steve Gregan         Added wildcard parameter to allow for draft forecasts

   NOTES:
  ********************************************************************************/
  FUNCTION load_demand_feed (i_run_id IN common.st_id, i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      PROCESS_DEMAND_FEED
   PURPOSE:   function to create the forecast of the tyoe FCST, and validate data from load_dmnd, the results validated records
              will be loaded into the dmnd_data table, check will be performed to validate demand group and zrep, the price and tdu will then
              calculated, records that pass validation will be set to 'PROCESSED' otherwise set to 'ERRORED'

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header
   1.1   22/10/2006 Steve Gregan         Added wildcard parameter to allow for draft forecasts
   1.2   04-Apr-2008 Scott R. Harding    Added material determination offset

   NOTES:
  ********************************************************************************/
  FUNCTION process_demand_feed (i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      GET_DIRECTORY_LIST
   PURPOSE:   function called and the beginning of the load run to get a list of files to process.
              A unix 'ls' command will be executed on the planning load directory.
              the results will be piped into the dir_list table.
              functions takes in a wildcard, only file begenning with this will card will be returned.
              different wildcard will be specified for demand or supply

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION get_directory_list (i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      ADD_FILE
   PURPOSE:   function call to add details of a file found to load , into the load_file table
              function will first check to see if the file has already been added,
              if the i_file_name is not unqique within the load_file table, then the file will not be added,
              if the file is already added then the file_id of the file will be returned otherwise
              the file_id of the new record will be returned.


   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   5/04/2006 Nick Bates            Added this header
   1.1   22/10/2006 Steve Gregan         Added wildcard and moe parameters

   NOTES:
  ********************************************************************************/
  FUNCTION add_file (i_run_id IN common.st_id, i_file_name IN common.st_message_string, i_file_wildcard IN common.st_message_string, i_file_moe IN common.st_code, o_file_id OUT common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      REMOVE_FILE
   PURPOSE:   This procedure removes a file from the loading tables and the file
              system.

   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   03/08/2006 Chris Horn           Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION remove_file (i_file_id in common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
   NAME:      CLEANUP_OLD_FILES
   PURPOSE:   Function called to delete old data from LOAD_DMND / LOAD_DMND_RAW
              LOAD_SPLY, and LOAD_SPLY_RAW tables. Also delete files flat file
              from unix directory.


   REVISIONS:
   Ver   Date       Author               Description
   ----- ---------- -------------------- ----------------------------------------
   1.0   2/05/2006 Nick Bates            Added this header

   NOTES:
  ********************************************************************************/
  FUNCTION cleanup_old_files (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      ARCHIVE_OLD_FORECASTS
    PURPOSE:   This procedure will archive old forecasts.


    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   23/05/2006 Chris Horn           Created this procedure.

    NOTES:     Archiving Rules
               Type      Casting Week     Archive After Last Updated Older Than
               FCST      1,2,3            60 Days
               FCST      4,5              400 Days
               BR                         800 Days
               ROB                        None / Manual
               OP                         None / Manual

   ********************************************************************************/
  FUNCTION archive_old_forecasts (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      PURGE_OLD_FORECASTS
    PURPOSE:   This procedure will purge old forecasts.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   23/05/2006 Chris Horn           Created this procedure.

    NOTES:     Purging Rules
               Type      Casting Week     Purge After Last Updated Older Than
               FCST      1,2,3            200 Days
               FCST      4,5              800 Days
               BR                         1200 Days
               ROB                        None / Manual
               OP                         None / Manual
   ********************************************************************************/
  FUNCTION purge_old_forecasts (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

 /*******************************************************************************
    NAME:      GET_OVRD_TDU
    PURPOSE:   This procedure will check the forecast text field for an override
                TDU and then use this code, rather than the standard material
                determination.


    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   12/07/2007 Richard Wong          Created this procedure.



   ********************************************************************************/

  FUNCTION get_ovrd_tdu (i_material_code IN common.st_code, i_distribution_channel IN common.st_code, i_sales_org IN common.st_code, i_fcst_text IN common.st_name, o_tdu OUT common.st_code, o_ovrd_tdu_flag IN OUT common.st_status, o_invalid_reason IN OUT  common.st_message_string, o_message_out OUT common.st_message_string)
    RETURN common.st_result;
    
    
    
 /*******************************************************************************
    NAME:      PERFORM_PROMAX_ADJUSTMENT
    PURPOSE:   This procedure reconciles the apollo forecast types with the 
               supplied promax types and manipulats the data until it 
               matches.  

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   26/02/2014 Chris Horn           Created this procedure.

   ********************************************************************************/
  procedure perform_promax_adjustment(i_fcst_id IN common.st_id);

END demand_forecast; 
 