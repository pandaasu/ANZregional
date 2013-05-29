create or replace 
package fflu_api_dev as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : FFLU - Flat File Loading Utility
  Owner   : FFLU_APP
  Package : FFLU_API
  Author  : Mal Chambeyron and Chris Horn

  Description
  ------------------------------------------------------------------------------
  This package will provide the Flat File Load front end website with API access
  to the neccessary functions and pipelined table functions for loading data
  and then monitoring the progress of that data within this system and the LICS
  system. 

  Functions
  ------------------------------------------------------------------------------
  + User Functions
    - get_user_list              Returns list of users.
    - get_authorised_user        Returns single row, with the effective user.
  + Interface Functions
    - get_interface_list         Returns the list of every interface.
    - get_interface_group_list   Returns the interface group list.
    - get_user_interface_options Returns the options a user has for a interface.
  + Load Functions
    - load_start                 Used to start loading a file.
    - load_segment               Used to load a file segement. 
    - load_cancel                Used to cancel a load that is in progress. 
    - load_complete              Used to complete file loading.
    - load_execute               Called by LICS Jobs system to move data.
    - load_monitor               Used to monitor load to lics processing.
    - lics_monitor               Used to monitor lics processing. 
  + Interface Monitoring Functions
    - get_xaction_status_list    Used to display the list of lics status codes.
    - get_xaction_count          Used to get the total rows for filter criteria.
    - get_xaction_list           Used to display the list of transactions.
    - get_xaction_trace_list     Used to get the other interface trace records.
    - get_xaction_errors         Used to display the errors at the header level.
    - get_xaction_data           Used to display data rows a page at a time.
    - get_xaction_data_with_errors    Used to display data rows that have errors.
    - get_xaction_data_errors_by_dat  Used to display errors for a set of data rows.
    - get_xaction_data_errors_by_row  Used to display a page of errors.
    - reprocess_interface        Used to trigger an interface for reprocessing.
  + Other Functions
    - perform_housekeeping       Used to clean up the load staging tables.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-05-16  Mal Chambeyron        Created
  2013-05-24  Chris Horn            Updated with further spec details.
  2013-05-28  Chris Horn            Updated with the Load function specs.
  2013-05-29  Chris Horn            Updated with interface monitoring specs.

*******************************************************************************/

/*******************************************************************************
  GLOBAL CONSTANTS - Exception Codes
  These exception codes can be used by the API for determining the cause of 
  specific data exceptions.
*******************************************************************************/
  gc_execption_users         constant fflu_common.st_exception_code := -20001;
  gc_execption_interface     constant fflu_common.st_exception_code := -20002;
  gc_exception_filename      constant fflu_common.st_exception_code := -20003;
  gc_exception_load          constant fflu_common.st_exception_code := -20004;
  gc_exception_xaction_seq   constant fflu_common.st_exception_code := -20005;
  gc_exception_pagenation    constant fflu_common.st_exception_code := -20006;
  
/*******************************************************************************
  SYSTEM CONSTANTS
  The following system contants are exposed as functions for use either within 
  SQL Statements or for use by the API.  
*******************************************************************************/
  -- LICS Constants
  function get_const_int_type_inbound return varchar2;              -- *INBOUND
  function get_const_int_type_outbound return varchar2;             -- *OUTBOUND
  -- LICS Parameters
  function get_const_system_unit return varchar2;        -- System, eg. CDW | PROMAX
  function get_const_system_environment return varchar2; -- Tier, eg DEV | TEST | PROD
  function get_const_system_url return varchar2;         -- ICS URL
  function get_const_log_database return varchar2;       -- ICS Database
  -- LICS Conventions
  function get_const_all_code return varchar2;                -- *ALL
  function get_const_guest_code return varchar2;              -- *GUEST
  function get_const_loader_option return varchar2;           -- ICS_INT_LOADER
  function get_const_monitor_option return varchar2;          -- ICS_INT_MONITOR
  function get_const_process_option return varchar2;          -- ICS_INT_PROCESS
  -- API Constants
  function get_const_all_interfaces return varchar2;          -- ALL Interfaces
  function get_const_load_completed return varchar2;          -- Load Completed
  function get_const_process_working return varchar2;         -- Process Working

/*******************************************************************************
  NAME:      GET_USER_LIST
  PURPOSE:   Returns the list of available users within the LICS Environment.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-23 Chris Horn           Reviewed.  

*******************************************************************************/
  -- User List Record Type
  type rt_user_list is record (
    user_code  lics_sec_user.seu_user%type,                 -- varchar2(32 char)
    user_name  lics_sec_user.seu_description%type           -- varchar2(128 char)
  );
  -- User List Table Type
  type tt_user_list is table of rt_user_list;
  -- The pipelined table function to return the list of available users.
  function get_user_list return tt_user_list pipelined;

/*******************************************************************************
  NAME:      GET_AUTHORISED_USER
  PURPOSE:   Taking the supplied user name, return if this user is actually
             authorised to do anything or if they are going to have the
             GUEST level of access. 
             
  EXCEPTION: The following possible exceptions may be raised.
             gc_execption_users - Issues with User Code

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-28 Chris Horn           Reviewed.  

*******************************************************************************/
  function get_authorised_user (i_user_code in varchar2) 
  return tt_user_list pipelined; 


/*******************************************************************************
  NAME:      GET_INTERFACE_LIST
  PURPOSE:   Returns the list of interfaces.  The filetype field is determined 
             first from the interface fil extension field, and if not present
             calls the interface procedure package and calls the hook
             on_get_filetype, Qualifier is also determined from a call to the
             procedure hook if defined as on_get_csv_qualifier.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-23 Chris Horn           Reviewed.  
  1.2   2013-05-29 Chris Horn           Added file type and csv qualifier.

*******************************************************************************/
  -- Interface List Record
  type rt_interface_list is record (
    interface_code    lics_interface.int_interface%type,   -- varchar2(32 char)
    interface_name    lics_interface.int_description%type, -- varchar2(128 char)
    interface_type_code lics_interface.int_type%type,      -- varchar2(10 char)
    interface_thread_code lics_interface.int_group%type,   -- varchar2(10 char)
    interface_filetype fflu_common.st_filetype,
    interface_csv_qual fflu_common.st_qualifier        
  );
  -- Interface List Table Type
  type tt_interface_list is table of rt_interface_list;  
  -- Pipelined table function for returning the list of interfaces.
  function get_interface_list return tt_interface_list pipelined;

/*******************************************************************************
  NAME:      GET_INTERFACE_GROUP_LIST
  PURPOSE:   Returns the list of available interface groups.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-23 Chris Horn           Reviewed.  

*******************************************************************************/
  -- Interface Group List Record
  type rt_interface_group_list is record (
    interface_group_code lics_group.gro_group%type,        -- varchar2(32 char)
    interface_group_name lics_group.gro_description%type   -- varchar2(128 char)
  );

  -- Interface Group List Table
  type tt_interface_group_list is table of rt_interface_group_list;

  -- Pipelined table function to retrieve the interface group list.
  function get_interface_group_list return tt_interface_group_list pipelined;

/*******************************************************************************
  NAME:      GET_INTERFACE_GROUP_JOIN
  PURPOSE:   Returns the list of interfaces that belong to each interface group.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-23 Chris Horn           Reviewed.  

*******************************************************************************/
  -- Interface Groups Record
  type rt_interface_group_join is record (
    interface_group_code lics_grp_interface.gri_group%type, -- varchar2(32 char)
    interface_code lics_grp_interface.gri_interface%type    -- varchar2(32 char)
  );
  -- Interface Group Type
  type tt_interface_group_join is table of rt_interface_group_join;
  -- Pipelined table function for returning the list of 
  function get_interface_group_join return tt_interface_group_join pipelined;
  
/*******************************************************************************
  NAME:      GET_USER_INTERFACE_OPTIONS
  PURPOSE:   For a given user, return the available authorisation options that
             the user has for each particular interface.  The pipelined table
             function is best called with a filter clause on interface code.
             
  EXCEPTION: The following possible exceptions may be raised.
             gc_execption_users - Issues with User Code

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-14 Mal Chamberyon       Created.
  1.1   2013-05-23 Chris Horn           Reviewed.  

*******************************************************************************/
  -- User Interface Options Record
  type rt_user_interface_options is record (
    user_code lics_sec_user.seu_user%type,                  -- varchar2(32 char)
    interface_code lics_interface.int_interface%type,       -- varchar2(32 char)
    option_code lics_sec_option.seo_option%type             -- varchar2(32 char)
  );
  -- User Interface Options Table
  type tt_user_interface_options is table of rt_user_interface_options;
  -- Pipelined table function for returning the users interface options.   
  function get_user_interface_options (i_user_code in varchar2) 
    return tt_user_interface_options pipelined;

/*******************************************************************************
  NAME:      LOAD_START
  PURPOSE:   Called at the commencement of starting a new interface.  User Code,
             Interface Code, and File name are supplied, and the load sequence
             number is returned.  This load ssequence number will then be used 
             by the subsequent calls to the API.
             
  EXCEPTION: The following possible exceptions can be raised.
             gc_execption_users - Issues with User Code
             - Null, Too Long, Not Authorised.
             gc_exception_interface - Issue with interface code.
             - Null, Too Long, Not Authorised.
             gc_exception_filename - Issues with file name. 
             - Null, Too Long

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.

*******************************************************************************/
  function load_start(
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2) return fflu_common.st_sequence;
    
/*******************************************************************************
  NAME:      LOAD_SEGMENT
  PURPOSE:   Called for each segement of the file that has been processed
             so far by the web server.   Splits out the CLOB data into lines
             and stores each line (including line feed) into the Load Data 
             Staging table. 
    
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_load - Issues with load sequence.
             - Not Found, Status Not (Started or Loading)
             gc_execption_users - Issues with User Code
             - Not Match Header
             gc_exception_interface - Issue with interface code.
             - Not Match Header
             gc_exception_filename - Issues with file name. 
             - Not Match header
             gc_exception_segment - Issues with the segement
             - Out of Sequence, Null Data, Size Missmatch, 
               Row Count Missmatch, Row Length > 4000 bytes.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.

*******************************************************************************/
  procedure load_segment (
    i_load_sequence in fflu_common.st_sequence, 
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2,
    i_seg_count in fflu_common.st_count,    -- Current segement being processed.
    i_seg_size in fflu_common.st_count,     -- Byte Count of current segment.                       
    i_seg_rows in fflu_common.st_count,     -- Rows of data in this segement.
    i_seg_data in nclob);                   

/*******************************************************************************
  NAME:      LOAD_CANCEL
  PURPOSE:   Called by the web service when and if the load was cancelled 
             by the user or web service for any reason.

  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_load - Issues with load sequence.
             - Not Found, Status Not (Started or Loading)
             gc_execption_users - Issues with User Code
             - Not Match Header
             gc_exception_interface - Issue with interface code.
             - Not Match Header
             gc_exception_filename - Issues with file name. 
             - Not Match header

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/    
  procedure load_cancel (
    i_load_sequence in fflu_common.st_sequence,
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2);



/*******************************************************************************
  NAME:      LOAD_COMPLETE
  PURPOSE:   Called on completion of loading all the segements.  Supplying a 
             total segment and row count for validation. If all is correct then 
             a background job will be submittted to LICS to move the data from
             Load Data Staging into LICS system ready for normal execution.  

  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_load - Issues with load sequence.
             - Not Found, Status Not (Loading)
             gc_execption_users - Issues with User Code
             - Not Match Header
             gc_exception_interface - Issue with interface code.
             - Not Match Header
             gc_exception_filename - Issues with file name. 
             - Not Match header
             gc_exception_segment - Issues with the segement
             - Segment Count Missmatch, Row Count Missmatch

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.

*******************************************************************************/    
  procedure load_complete (
    i_load_sequence in fflu_common.st_sequence,
    i_user_code in varchar2, 
    i_interface_code in varchar2, 
    i_file_name in varchar2,
    i_seg_count in fflu_common.st_count,    -- Total segements sent.
    i_seg_rows in fflu_common.st_count      -- Total rows sent.
  );
  

/*******************************************************************************
  NAME:      LOAD_EXECUTE
  PURPOSE:   Called by the LICS Job System to process the data from Load 
             staging tables into the lics system.  On completion it will 
             submit the interface for processing.  This function will not
             be called specifically by the API.  

 EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_load - Issues with load sequence.
             - Not Found, Status Not (Completed)
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.

*******************************************************************************/    
  procedure load_execute(i_load_sequence in fflu_common.st_sequence);
  
  
/*******************************************************************************
  NAME:      LOAD_MONITOR
  PURPOSE:   The API after calling Load Complete will then call this function
             repatadly until it returns the LICS Sequence Number.  Which will 
             indicate that the data has been successfully copied from the 
             load staging table into the LICS system.

 EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_load - Issues with load sequence.
             - Not Found, Status (Started, Loading)
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.
  1.1   2013-05-29 Chris Horn           Added exceptions definitions.

*******************************************************************************/    
  -- Load Monitor Record
  type rt_load_monitor is record (
    rows_complete     fflu_common.st_count,         -- Rows completed.
    percent_complete  fflu_common.st_count,         -- Percentage Complete.
    estimated_time    fflu_common.st_count,         -- Estimated seconds.
    load_status       fflu_common.st_load_status,          -- The Load Status.
    lics_int_sequence lics_header.hea_header%type   -- The lices Interface Seq.
  );
  -- Load Monitor Table
  type tt_load_monitor is table of rt_load_monitor;
  -- Pipelined table function for returning the current load status.
  function load_monitor(i_load_sequence in fflu_common.st_sequence) 
    return tt_load_monitor pipelined;

/*******************************************************************************
  NAME:      LICS_MONITOR
  PURPOSE:   The API after receiving a lics interface sequence number in load
             monitor can then use the following monitor function to watch 
             the progress of the actual interface processing.  This function
             can stop being called once the lics status result becomes something 
             other than get_const_process_working and get_const_load_completed.

 EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-28 Chris Horn           Defined.
  1.1   2013-05-29 Chris Horn           Added the exception definition.

*******************************************************************************/    
  -- Lics Monitor Record
  type rt_lics_monitor is record (
    rows_complete    fflu_common.st_count,              -- Rows completed.
    percent_complete fflu_common.st_count,              -- Percentage Complete.
    estimated_time   fflu_common.st_count,              -- Estimated seconds.
    int_errors       fflu_common.st_count,              -- Interface errors.
    rows_in_error    fflu_common.st_count,              -- Rows in error. 
    lics_status      fflu_common.st_load_status         -- Status as a string.
  );
  -- Load Monitor Table
  type tt_lics_monitor is table of rt_load_monitor;
  -- Pipelined table function for returning the current load status.
  function lics_monitor(i_xaction_seq in lics_header.hea_header%type) 
    return tt_lics_monitor pipelined;


/*******************************************************************************
  NAME:      GET_XACTION_STATUS_LIST
  PURPOSE:   Provide the list of available status fields for selection drop 
             down fields.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  -- Transaction Status List Record
  type rt_xaction_status_list is record (
    xaction_status_code fflu_common.st_status,              -- varchar2(1 char)
    xaction_status_name fflu_common.st_load_status          -- varchar2(32 char)
  );
  -- Transaction Status List Table
  type tt_xaction_status_list is table of rt_xaction_status_list;
  -- Pipelined table function to retrieve the transaction status list.
  function get_xaction_status_list return tt_xaction_status_list pipelined;

/*******************************************************************************
  NAME:      GET_XACTION_COUNT
  PURPOSE:   Provide a count of the number of records that match the current
             filter criteria.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  function get_xaction_count(
    i_interface_group_code in varchar2,
    i_interface_code in varchar2, 
    i_interface_type_code in varchar2, 
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_status_code in fflu_common.st_status,
    i_start_datetime in date,
    i_end_datetime in date
  ) return fflu_common.st_count;

/*******************************************************************************
  NAME:      GET_XACTION_LIST
  PURPOSE:   Provide a pipelined table output of all the interface transactions
             for a specified criteria.  Also taking into account the row num and
             the number of rows being requested.  Records will be sorted 
             in descending xaction sequence number.

  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_pagenation - Issues with the rows requested.
             - Start Row Invalid, No Rows Requested Invalid
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  -- Interface List Record
  type rt_xaction_list is record (
    xaction_seq fflu_common.st_sequence,
    xaction_trace_seq fflu_common.st_trace,
    xaction_filename fflu_common.st_filename,
    xaction_user_code fflu_common.st_user,
    xaction_interface_code fflu_common.st_interface,
    xaction_interface_name fflu_common.st_name,
    xaction_filetype fflu_common.st_filetype,
    xaction_csv_qualifier fflu_common.st_qualifier,
    xaction_start_datetime date,
    xaction_end_datetime date,
    xaction_status_code fflu_common.st_status,
    xaction_rec_count fflu_common.st_count,    -- Total number of records.
    xaction_rec_in_error fflu_common.st_count, -- Rows that have an error.
    xaction_rec_errors fflu_common.st_count, -- Total errors against rows.
    xaction_int_errors fflu_common.st_count    -- Errors at the interface level.
  );
  -- Interface List Table Type
  type tt_xaction_list is table of rt_xaction_list;  
  -- Pipelined table function for returning the interface transaction records.
  function get_xaction_list( 
    i_interface_group_code in varchar2,
    i_interface_code in varchar2, 
    i_interface_type_code in varchar2, 
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_status_code in fflu_common.st_status,
    i_start_datetime in date,
    i_end_datetime in date,
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count
  ) return tt_xaction_list pipelined;

/*******************************************************************************
  NAME:      GET_XACTION_TRACE_LIST
  PURPOSE:   Given a particular interface transaction sequence, return all the
             other trace records that have been created for this interface.  
             ie.  All the trace records less than the supplied trace reference 
             that will already be displayed on the screen.  Records will be 
             sorted in descending trace order.
  
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  -- Pipelined table function for returning the list of interfaces.
  function get_xaction_trace_list ( 
    i_xaction_seq in fflu_common.st_sequence,
    i_xaction_trace_seq in fflu_common.st_trace
  ) return tt_xaction_list pipelined;

/*******************************************************************************
  NAME:      GET_XACTION_DATA
  PURPOSE:   This function returns the data rows of the given interface.
             
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found
             gc_exception_pagenation - Issues with the rows requested.
             - Start Dat Sequence Invalid, No Rows Requested Invalid
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  -- Transaction Data record
  type rt_xaction_data is record (
    xaction_data_seq fflu_common.st_count,
    xaction_data fflu_common.st_string,
    xaction_errors fflu_common.st_count
  );
  -- Transaction Data table.
  type tt_xaction_data is table of rt_xaction_data;
  -- Pipelined table function to display the data records.
  function get_xaction_data (
    i_xaction_seq in fflu_common.st_sequence, 
    i_start_dat_seq in fflu_common.st_count,
    i_no_rows in fflu_common.st_count) return tt_xaction_data pipelined;

/*******************************************************************************
  NAME:      GET_XACTION_DATA_WITH_ERRORS
  PURPOSE:   This function returns the data rows of the given interface but
             only the rows that contain errors.  
             
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found
             gc_exception_pagenation - Issues with the rows requested.
             - Start Row Invalid, No Rows Requested Invalid
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  function get_xaction_data_with_errors (
    i_xaction_seq in fflu_common.st_sequence, 
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count) return tt_xaction_data pipelined;

/*******************************************************************************
  NAME:      GET_XACTION_ERRORS
  PURPOSE:   This function will return error records that have been defined 
             at the header level.  
             
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  -- Transaction Error Record
  type rt_xaction_error is record (
    xaction_msg_seq fflu_common.st_msgseq,
    xaction_msg fflu_common.st_string
  );
  -- Transaction Error Table
  type tt_xaction_errors is table of rt_xaction_error;
  -- Pipelined table function to display all the errors for a current page of data records.
  function get_xaction_errors (
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace
  ) return tt_xaction_errors pipelined;
  
/*******************************************************************************
  NAME:      GET_XACTION_DATA_ERRORS_BY_DAT
  PURPOSE:   Returns all the error messages that are associated with the data
             records between two data sequence numbers inclusive.
             
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found
             gc_exception_pagenation - Issues with the rows requested.
             - Start Data Sequence is Invalid, End Data Sequence is Invalid
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  -- Transaction Data Error Record
  type rt_xaction_data_error is record (
    xaction_data_seq fflu_common.st_count,
    xaction_msg_seq fflu_common.st_msgseq,
    xaction_msg fflu_common.st_string
  );
  -- Transaction Data Error Table
  type tt_xaction_data_errors is table of rt_xaction_data_error;
  -- Pipelined table function to display all the errors for a current page of data records.
  function get_xaction_data_errors_by_dat (
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace,
    i_from_data_seq fflu_common.st_count,
    i_to_data_seq fflu_common.st_count
  ) return tt_xaction_data_errors pipelined;
  
/*******************************************************************************
  NAME:      GET_XACTION_DATA_ERRORS_BY_ROW
  PURPOSE:   Returns all the error messages by a page number.  Sorted by data 
             sequence and message sequence number.
             
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found
             gc_exception_pagenation - Issues with the rows requested.
             - Start Row Invalid, No Rows Requested Invalid
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  -- Pipelined table function to display all the errors by a page.  
  function get_xaction_data_errors_by_row (
    i_xaction_seq fflu_common.st_sequence,
    i_xaction_trace_seq fflu_common.st_trace,
    i_start_row in fflu_common.st_count,
    i_no_rows in fflu_common.st_count
    ) return tt_xaction_data_errors pipelined;
  

/*******************************************************************************
  NAME:      REPROCESS_INTERFACE
  PURPOSE:   This procedure will be called by the API when an interface is 
             needing to be resubmitted for processing.  Interface code is
             just resubmitted for an extra validation and check.
             
  EXCEPTION: The following possible exceptions can be raised.           
             gc_exception_xaction_seq - Issues with interface sequence.
             - Not Found
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-05-29 Chris Horn           Defined.

*******************************************************************************/  
  procedure reprocess_interface(
    i_xaction_seq in lics_header.hea_header%type,
    i_interface_code in varchar2);
    
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

*******************************************************************************/  
  procedure perform_housekeeping;

end fflu_api_dev;