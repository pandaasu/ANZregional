create or replace 
PACKAGE fflu_common AS 

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : FFLU - Flat File Loading Utility
  Owner   : FFLU_APP
  Package : FFLU_COMMON
  Author  : Chris Horn

  Description
  ------------------------------------------------------------------------------
  This package provides various standard functions for use across the 
  Flat File Loading Utility. It also provides the two key calls from the 
  LICS system back into this one.  One to perform the transfer of data
  from the Flat File Loading utility back into LICS and also a house keeping
  job to keep the environment clean and using a minimal foot print of space.

  Functions
  ------------------------------------------------------------------------------
  + Validation Functions
    - validate_non_empty_string  Used to validate that a string is not empty.
    - validate_string_length     Used to validate the length of a string.
  + Utility Functions 
    - sqlerror_string            Function to generate a sql exception string.
  + LICS Processing Jobs
    - load_execute               Called by LICS Jobs system to move data.
    - perform_housekeeping       Used to clean up the load staging tables.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-05-24  Chris Horn            Created.
  2013-06-05  Chris Horn            Moved Load Execute and Housekeeping here.
  2013-06-13  Chris Horn            Added user code reprocess writeback.
  2013-07-30  Chris Horn            Added the csv null qualifier.

*******************************************************************************/

/*******************************************************************************
** Package Types   
*******************************************************************************/
  subtype st_string is varchar2(4000 byte);    -- The maximum varchar2 field size.
  subtype st_name is varchar2(128 char);       -- The size of name fields.
  subtype st_exception_code is pls_integer;    -- Type the exception codes. 
  subtype st_size is pls_integer;              -- The size of something.  
  subtype st_status is varchar2(1 char);       -- The single character status chars.
  subtype st_sequence is number(15,0);         -- The size of sequence fields.
  subtype st_trace is number(5,0);             -- The trace field definition.  
  subtype st_msgseq is number(5,0);            -- The message sequence
  subtype st_count is number(9,0);             -- The a count field.
  subtype st_filename is varchar2(64 char);    -- The file name type field.
  subtype st_interface is varchar2(32 char);   -- The interface name field.
  subtype st_user is varchar2(30 char);        -- The size of the user field.
  subtype st_load_status is varchar2(32 char); -- The load status.
  subtype st_filetype is varchar2(3 char);     -- The file type.
  subtype st_qualifier is varchar2(1 char);    -- Ths csv text enclosing qualifier.
  subtype st_buffer is varchar2(32000 byte);   -- Larger string buffer.
  subtype st_length is pls_integer;            -- The length of a field.
  subtype st_position is pls_integer;          -- The position of a field.
  subtype st_column is pls_integer;            -- The column within a record.
  
/*******************************************************************************
  GLOBAL CONSTANTS - Exception Codes
  These exception codes can be used by the API for determining the cause of 
  specific data exceptions.
*******************************************************************************/
  -- Exceptions
  gc_execption_users         constant st_exception_code := -20001;
  gc_execption_interface     constant st_exception_code := -20002;
  gc_exception_security      constant st_exception_code := -20003;
  gc_exception_filename      constant st_exception_code := -20004;
  gc_exception_load          constant st_exception_code := -20005;
  gc_exception_segment       constant st_exception_code := -20006;
  gc_exception_xaction_seq   constant st_exception_code := -20007;
  gc_exception_pagenation    constant st_exception_code := -20008;
  gc_exception_housekeeping  constant st_exception_code := -20009;

  -- Load Status
  gc_load_status_started   constant fflu_common.st_load_status := 'Started';
  gc_load_status_loading   constant fflu_common.st_load_status := 'Loading';
  gc_load_status_completed constant fflu_common.st_load_status := 'Completed';
  gc_load_status_executed  constant fflu_common.st_load_status := 'Executed';
  gc_load_status_errored   constant fflu_common.st_load_status := 'Errored';
  gc_load_status_cancelled constant fflu_common.st_load_status := 'Cancelled';


/*******************************************************************************
  GLOBAL CONSTANTS - File and Qualifier Constants
*******************************************************************************/
  -- Expected file type extensions.
  gc_file_type_csv         constant st_filetype := 'csv';
  gc_file_type_fixed_width constant st_filetype := 'txt';
  gc_file_type_tab         constant st_filetype := 'tab';
  -- Expected CSV Qualifiers 
  gc_csv_qualifier_single_quote constant st_qualifier := '''';
  gc_csv_qualifier_double_quote constant st_qualifier := '"';
  gc_csv_qualifier_null         constant st_qualifier := null;

/*******************************************************************************
  NAME:      VALIDATE_NON_EMPTY_STRING                                    PUBLIC
  PURPOSE:   Checks that the supplied string is not null or empty. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-28 Chris Horn           Created 
*******************************************************************************/
  procedure validate_non_empty_string(i_exception_code in st_exception_code, i_string in st_string, i_name in st_name);

/*******************************************************************************
  NAME:      VALIDATE_STRING_LENGTH                                       PUBLIC
  PURPOSE:   Checks that the supplied string is between (inclusive) of the 
             supplied minimum and maximum byte length.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-28 Chris Horn           Created  
*******************************************************************************/
  procedure validate_string_length(i_exception_code in st_exception_code, i_string in st_string, i_min_len in st_size, i_max_len in st_size, i_name in st_name);

/*******************************************************************************
  NAME:      SQLERROR_STRING                                              PUBLIC
  PURPOSE:   Creates a error message that includes the SQLERROR string and 
             ensures it fits within 4000 bytes. 

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------
  1.0   2013-05-30 Chris Horn           Created  
*******************************************************************************/
  function sqlerror_string(i_message in varchar2) return st_string;

/*******************************************************************************
  NAME:      LOAD_EXECUTE
  PURPOSE:   Called by the LICS Job System to process any completed 
             interfaces into the LICS system for processing.  This function 
             will not be called specifically by the API.   This should be
             scheduled as a job to run every 300 seconds.  However the 
             on load_complete a wake up will be sent anyway.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.
  1.1   2013-05-30 Chris Horn           Redefined and Implemented.
  1.2   2013-06-13 Chris Horn           Added line for user code writeback.

*******************************************************************************/    
  procedure load_execute;


/*******************************************************************************
  NAME:      PERFORM_HOUSEKEEPING
  PURPOSE:   Called by a scheduled LICS job.  This method will every day 
             find any loads that have completed or failed to complete that are 
             two or more days old and delete the corresponding data records.  
             
             It will also then delete any records from the header that are 
             older than the lics interface header retention setting.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.
  1.1   2013-05-30 Chris Horn           Created Shell.
  1.2   2013-06-05 Chris Horn           Moved to Common Package.
  1.3   2013-06-11 Chris Horn           Cleaned up data deletion log message.
  1.4   2013-06-13 Chris Horn           Added cleanup for user writeback table.

*******************************************************************************/  
  procedure perform_housekeeping;

END fflu_common;