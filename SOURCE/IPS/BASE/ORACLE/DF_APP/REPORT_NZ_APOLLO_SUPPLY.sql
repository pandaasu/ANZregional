create or replace 
PACKAGE        report_nz_apollo_supply AS
  /*******************************************************************************
  NAME:    REPORT_NZ_APOLLO_SUPPLY
  PURPOSE: This report allows for the downloading an extract of forecast data 
           for use with the apollo supply system.
           
           Note : All demand types are output as = 1 Base.
           
  *******************************************************************************/

  /*******************************************************************************
      NAME:      INSTALL
      PURPOSE:   This procedure is only called once and is used to insert necessary
                 information into tables so the report can be available to run.
                 This procedure is executed by the developer and will NOT be
                 called by any other package or procedures.


      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------------
      1.0   25/07/2013 Chris Horn           Created this procedure.

      NOTES:
  ********************************************************************************/
  PROCEDURE install (o_result OUT common.st_result, o_result_msg OUT common.st_message_string);

  /*******************************************************************************
      NAME:      SETUP_REPORT_VARIABLES
      PURPOSE:   This function is called from the REPORTING_GUI and is used to
                 create a variable array and input the variables for a report
                 into the array ready for the variable values to assigned into
                 the array.


      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------------
      1.0   25/07/2013 Chris Horn           Created this procedure.

      NOTES:
  ********************************************************************************/
  FUNCTION setup_report_variables (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
      NAME:      RETRIEVE_REPORT
      PURPOSE:   This procedure is called from the REPORTING_GUI and uses the
                 information in the variable array to generate SQL that is returned to
                 the REPORTING_GUI for execution.

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------------
      1.0   25/07/2013 Chris Horn           Created this procedure.

  NOTES:
  ********************************************************************************/
  FUNCTION retrieve_report (o_result_msg OUT common.st_message_string, o_sql OUT common.st_sql)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      SETUP_REPORT_OPTIONS
    PURPOSE:   This procedure is used to populate the REP_OPTIONS table with
               all the detail needed to format the report in excel


    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
      1.0   25/07/2013 Chris Horn           Created this procedure.

  NOTES:
  ********************************************************************************/
  FUNCTION setup_report_options (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;
END report_nz_apollo_supply; 
 