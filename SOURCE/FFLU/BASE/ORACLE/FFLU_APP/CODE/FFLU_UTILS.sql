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
    - log_interface_exception    Adds a JSON formatted interface exception to LICS.
    - get_interface_suffix       The interface suffix, everything after .
    - get_interface_filename     The interface filename.
    - get_interface_row          The current interface row number. 
    - get_interface_user         The user that loaded or reprocessed file 

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-06-06  Chris Horn            Implemented the interface log progress.
  2013-06-13  Chris Horn            Added log interface errors functions.
  2013-07-05  Chris Horn            Added interface suffix,filename,row code.
  2013-07-30  Chris Horn            Added function to return the user.
  2013-08-01  Chris Horn            Added function to get interface number.  
  
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
  NAME:      LOG_INTERFACE_EXCEPTION
  PURPOSE:   This can be called to log an Oracle Exception in the correct ouput
             JSON format.
             
             The procedure of funtion that experienced the exception should 
             be passed in as the input parameter.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-26 Chris Horn           Created

*******************************************************************************/  
  procedure log_interface_exception (i_method fflu_common.st_buffer); 


/*******************************************************************************
  NAME:      GET_INTERFACE_SUFFIX
  PURPOSE:   Returns the interface suffix.  
             
             Fetches the interface code definition from callback_interface.  
             Then returns everything after the first . found in the string.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-05 Chris Horn           Created

*******************************************************************************/  
  function get_interface_suffix return fflu_common.st_interface;
  
/*******************************************************************************
  NAME:      GET_INTERFACE_FILENAME
  PURPOSE:   Just returns the interface file name straight from the call back.
             Only here for conveniance.
             
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-05 Chris Horn           Created

*******************************************************************************/  
  function get_interface_filename return fflu_common.st_filename;

/*******************************************************************************
  NAME:      GET_INTERFACE_NO
  PURPOSE:   This function returns the current ICS interface ID number.
             
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-08-01 Chris Horn           Created

*******************************************************************************/  
  function get_interface_no return fflu_common.st_sequence;

/*******************************************************************************
  NAME:      GET_INTERFACE_ROW
  PURPOSE:   Just returns the interface row straight from the call back.
             Only here for conveniance.
             
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-05 Chris Horn           Created

*******************************************************************************/  
  function get_interface_row return fflu_common.st_count;

/*******************************************************************************
  NAME:      GET_INTERFACE_USER
  PURPOSE:   Returns the user that loaded or reprocessed the file.  If the file
             was loaded directly, or reprocessed by old lics then the system 
             user will be returned.
             
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-30 Chris Horn           Created

*******************************************************************************/  
  function get_interface_user return fflu_common.st_user;

  
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