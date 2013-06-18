create or replace 
package fflu_utils as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : FFLU - Flat File Loading Utility
  Owner   : FFLU_APP
  Package : FFLU_UTILS
  Author  : Chris Horn

  Description
  ------------------------------------------------------------------------------
  This package will provide provides utility functions to interface developers
  so that their interfaces can more seamlessly integrate with the Flat File 
  Loating Utilty web interface.

  Functions
  ------------------------------------------------------------------------------
  + Interface Hooks           
    - log_interface_progress     An interface hook to update its progress.
    - log_interface_error        Adds a JSON formatted interface error to LICS.
    - log_interface_data_error   Adds a JSON formatted interface error to LICS

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-06-06  Chris Horn            Implemented the interface log progress.
  2013-06-13  Chris Horn            Added log interface errors functions.
  
*******************************************************************************/

/*******************************************************************************
  NAME:      LOG_INTERFACE_PROGRESS
  PURPOSE:   This procedure can be called by a running interface to log
             what row it is up to in its interface processing.
             This enabled the lics monitor function to return accruate 
             estimates of current progress.
              
             This should be called at an interval that will be approximatly 
             once per second ie. approx 1000 - 10000 rows but more frequently
             will not be an issue.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-03 Chris Horn           Defined.
  
*******************************************************************************/  
  procedure log_interface_progress;
  
  
/*******************************************************************************
  NAME:      LOG_INTERFACE_ERROR
  PURPOSE:   This function creates a Flat File Loading utility front end error
             message in the correct format for display.  The error message is
             output in the correct JSON format.  Message String is truncated to 
             fit within the limit of the message column and still maintain 
             the correct structure of the JSON format.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-11 Chris Horn           Defined.
  
*******************************************************************************/  
  procedure log_interface_error(
    i_label fflu_common.st_buffer,    -- Label, specific for interface. 
    i_value fflu_common.st_buffer,    -- Value that is relevant at interface.
    i_message fflu_common.st_buffer); -- The actual error message.
  
  
/*******************************************************************************
  NAME:      LOG_INTERFACE_DATA_ERROR
  PURPOSE:   This can be called to define a new data interface error for the
             current row within the interface.
             
             Message String and or value is truncated to fit within the limit 
             of the message column and still maintain the correct structure of 
             the JSON format.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-11 Chris Horn           Defined.
  1.1   2013-06-12 Chris Horn           Updated the definition.  
  
*******************************************************************************/  
  procedure log_interface_data_error (
    i_label fflu_common.st_buffer,    -- Label, specific for interface. 
    i_column fflu_common.st_column,   -- Char Position for Fixed With, Column for CSV 
    i_value fflu_common.st_buffer,    -- The value found or not found if null. 
    i_message fflu_common.st_buffer); -- The actual error message.

  procedure log_interface_data_error (
    i_label fflu_common.st_buffer,    -- Label, specific for interface. 
    i_position fflu_common.st_position,   -- Char Position for Fixed With, Column for CSV 
    i_length fflu_common.st_length,     -- The length of the field.
    i_value fflu_common.st_buffer,    -- The value found or not found if null. 
    i_message fflu_common.st_buffer); -- The actual error message.
  
  
/*******************************************************************************
EXAMPLE JSON MESSAGES.
======================
JSON Message found at the header level.
message = 
  { 
    "label"           : "File Name", 
    "value"           : "test.csv", 
    "message"   : "File name should have contained the mars period."
  }
Results in something like “File Name [test.csv]. File name should have contained the mars period.”

message = 
  { 
    "label"           : "Records Received", 
    "value"           : "20", 
    "message"   : "Expected to receive at least 100 records but received less."
  }  
Results in something like “Records Received [20]. Expected to receive at least 100 records but received less.”



JSON Message Found at the data level for a CSV File
{ 
    "label"           : "Order Value", 
    "column"        : 3,
    "value"           : "Garbage text entry ..",
    "message"   : "Invalid Number, Expected Format [9999999999.00]"
  } 
Results in something like “Order Value [Garbage text entry ..]. Invalid Number, Expected Format [9999999999.00]”
  
  { 
    "label"           : "Customer Id", 
    "column"        : 2,
    "value"           : "123456",
    "message"   : "NOT Found"
  } 
Results in something like “Customer Id [123456]. NOT Found”

JSON Message Found at the data level for a Fixed Width Data
{ 
    "label"           : "Order Value", 
    "position"     : 10,
    "length"        : 30,
    "value"          : "Garbage text entry ..",
    "message"   : "Invalid Number, Expected Format [9999999999.00]"
  } 
Results in something like “Order Value [Garbage text entry ..]. Invalid Number, Expected Format [9999999999.00]”
  
  { 
    "label"           : "Customer Id", 
    "position"    : 50,
    "length"       : 8,
    "value"         : "123456",
    "message"  : "NOT Found"
  } 
Results in something like “Customer Id [123456]. NOT Found”

*******************************************************************************/
  
end fflu_utils;