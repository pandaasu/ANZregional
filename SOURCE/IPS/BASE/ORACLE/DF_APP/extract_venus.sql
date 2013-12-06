CREATE OR REPLACE PACKAGE        extract_venus AS
  /*******************************************************************************
   NAME:      EXTRACT_VENUS
   PURPOSE:   This package provides all the key processing functionality required
              for sending extracts to Venus.
  ********************************************************************************/

  /*******************************************************************************
     NAME:      INITILISE
     PURPOSE:   This procedure setups parameters for the extraction.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   09/06/2006 Chris Horn           Created this procedure.

     NOTES:
    ********************************************************************************/
  PROCEDURE initialise;

  /*******************************************************************************
     NAME:      EXTRACT_DEMAND_FORECAST
     PURPOSE:   This file create an extract file to send to venus for a given forecast id.
                The file is written to the a unix file, then sent to venus via a MQ-Series command.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   5/04/2006 Nick Bates            Added this header

     NOTES:
    ********************************************************************************/
  FUNCTION extract_demand_forecast (i_fcst_id in common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
     NAME:      EXTRACT_PRODUCTION_PLAN
     PURPOSE:   This file create an extract file to send to venus for a given forecast id.
                The file is written to the a unix file, then sent to venus via a MQ-Series command.
                The file will be used for production planning.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   20/04/2006 Nick Bates           Added this header

     NOTES:
    ********************************************************************************/
  FUNCTION extract_production_plan (i_fcst_id in common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
      NAME:      EXTRACT_INVENTORY_FORECAST
      PURPOSE:   This file create an extract file to send to venus for a given forecast id.
                 The file is written to the a unix file, then sent to venus via a MQ-Series command.
                 The file will be used for projected inventory reporting.

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------------
      1.0   20/04/2006 Nick Bates           Added this header
      1.1   24/05/2006 Chris Horn           Renamed function.

      NOTES:
     ********************************************************************************/
  FUNCTION extract_inventory_forecast (i_fcst_id in common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
       NAME:      SEND_DEMAND_FORECAST
       PURPOSE:   Send the extracted to VENUS file name is fixed, unix call is based to MQ-SERIES

       REVISIONS:
       Ver   Date       Author               Description
       ----- ---------- -------------------- ----------------------------------------
       1.0   05/05/2006 Nick Bates           Added this header

       NOTES:
      ********************************************************************************/
  FUNCTION send_demand_forecast (i_fcst_id in common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
       NAME:      SEND_PROFUCTION_PLAN
       PURPOSE:   Send the extracted to VENUS file name is fixed, unix call is based to MQ-SERIES

       REVISIONS:
       Ver   Date       Author               Description
       ----- ---------- -------------------- ----------------------------------------
       1.0   05/05/2006 Nick Bates           Added this header

       NOTES:
      ********************************************************************************/
  FUNCTION send_production_plan (i_fcst_id in common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
       NAME:      SEND_INVENTORY_FORECAST
       PURPOSE:   Send the extracted to VENUS file name is fixed, unix call is based to MQ-SERIES

       REVISIONS:
       Ver   Date       Author               Description
       ----- ---------- -------------------- ----------------------------------------
       1.0   05/05/2006 Nick Bates           Added this header
       1.1   24/05/2006 Chris Horn           Renamed function.

       NOTES:
      ********************************************************************************/
  FUNCTION send_inventory_forecast (i_fcst_id in common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;
END extract_venus;
