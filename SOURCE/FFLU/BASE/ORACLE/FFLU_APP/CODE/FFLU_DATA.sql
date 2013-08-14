create or replace 
package fflu_data as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : FFLU - Flat File Loading Utility
  Owner   : FFLU_APP
  Package : FFLU_DATA
  Author  : Chris Horn

  Description
  ------------------------------------------------------------------------------
  This package is designed to be used as a helper module for parsing interface
  data.  Either fixed width or csv files.  There are various functions to 
  help with the parsing and data validation.  
  
  Functions
  ------------------------------------------------------------------------------
  + Data Parsing Functions
    - initialise                  Initialise the data table definitions.
    - cleanup                     Called after data processing has completed.
    - add_record_type             Defines a record type field.
    - add_char_field              Defines a character field.
    - add_date_field              Defines a date field.
    - add_number_field            Defines a number field.
    - add_mars_date_field         Defines a mars date field.
    - parse_data                  Takes the supplied data and parses it.
    - get_record_type             Returns the record type for.
    - get_char_field              Returns a char field.
    - get_number_field            Returns a number field.
    - get_date_field              Returns a date field.
    - get_mars_date_field         Returns a mars date field out.
    - log_field_error             Logs and error associated with a field.
    - log_interface_error         Calls utils log interface error.
    - log_interface_exception     Calls utils log interface exception.
    - was_errors                  Return if any errors have been recorded.
  
  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-06-13  Chris Horn            Defined the specification.
  2013-06-18  Chris Horn            Refined spec and implemented.
  2013-06-20  Chris Horn            Added was errors function.
  2013-06-25  Chris Horn            Completed the CSV extraction logic.
  2013-06-25  Chris Horn            Added a check for the header fields matching.
  2013-06-25  Chris Horn            Moved to a unique field name arrangement.
  2013-07-19  Chris Horn            Added field offset to date functions.  
  2013-07-29  Chris Horn            Added constants various true false values.
  2013-07-30  Chris Horn            Added constant values for mins and maxes.
  2013-08-14  Chris Horn            Added interface error and exception methods.

*******************************************************************************/

/*******************************************************************************
  SYSTEM CONSTANTS
  The following system constants are available for use with various functions 
  below for easy reability of source code.
*******************************************************************************/
  -- Data Parser Initialisation Constants.
  gc_csv_header        boolean := true;
  gc_no_csv_header     boolean := false;
  gc_allow_missing     boolean := true;
  gc_not_allow_missing boolean := false;
  -- Field Constants
  gc_allow_null        boolean := true;
  gc_not_allow_null    boolean := false;
  gc_trim              boolean := true;
  gc_not_trim          boolean := false;
  -- Null Field Constants
  gc_null_min_length    constant fflu_common.st_size      := null;
  gc_null_max_length    constant fflu_common.st_size      := null;
  gc_null_format        constant fflu_common.st_name      := null;    
  gc_null_min_number    constant number                   := null; 
  gc_null_max_number    constant number                   := null;
  gc_null_nls_options   constant fflu_common.st_string    := null;
  gc_null_offset        constant fflu_common.st_position  := null;
  gc_null_offset_len    constant fflu_common.st_length    := null; 
  gc_null_min_date      constant date                     := null; 
  gc_null_max_date      constant date                     := null;
  

/*******************************************************************************
  NAME:      INITIALISE
  PURPOSE:   Setups an empty definition for the incoming data. 
             
             Allow Missing = True, will prevent exception when whitespace, 
             or commas are missing for empty fields.
             
             CVS Header = True, the file will contain a header row.  Field names
             much match there header definitions.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-03 Chris Horn           Defined.
  1.1   2013-06-25 Chris Horn           Added if csv file contains a header.
  
*******************************************************************************/  
  procedure initialise(
    i_filetype in fflu_common.st_filetype,
    i_csv_qualifier in fflu_common.st_qualifier default fflu_common.gc_csv_qualifier_null,
    i_csv_header in boolean default gc_no_csv_header, 
    i_allow_missing in boolean default gc_not_allow_missing);
    

/*******************************************************************************
  NAME:      ADD_RECORD_TYPE
  PURPOSE:   This function can be used to parses multiple different types of 
             record types within a given interface.  There can only be one 
             record type per row.  Each record type should be added first 
             followed by the fields that are assocaites with this record type.
             The record type doesn't have to be the first column, but it does have
             to be added to this parser before other columns within the record.
             All added fields up to the next record type will be parsed during
             the parsing.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.
  1.1   2013-06-20 Chris Horn           Added column number to fixed width.

*******************************************************************************/  
  procedure add_record_type_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_record_type in fflu_common.st_string);

 procedure add_record_type_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_record_type in fflu_common.st_string);

/*******************************************************************************
  NAME:      ADD_CHAR_FIELD
  PURPOSE:   This function defines the char field.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-13 Chris Horn           Defined.

*******************************************************************************/  
  procedure add_char_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_min_length in fflu_common.st_size default gc_null_min_length,
    i_max_length in fflu_common.st_size default gc_null_max_length,
    i_allow_null in boolean default gc_not_allow_null,
    i_trim in boolean default gc_not_trim);
  
  procedure add_char_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_min_length in fflu_common.st_size default gc_null_min_length,
    i_allow_null in boolean default gc_not_allow_null,
    i_trim in boolean default gc_trim);
  
/*******************************************************************************
  NAME:      ADD_NUMBER_FIELD
  PURPOSE:   This function defines a number field.
             For the NLS Options check, out TO_NUMBER (NLS_NUMERIC_CHARACTERS,
             NLS_CURRENCY,NLS_ISO_CURRENCY).
             
             Notes : 
             1. For i_format use 9 for numeric position, D for decimal place, 
                G for format seperator of comma.  ie.  99G999D99 
             2. For Euorpean format set i_nls_option 
                to 'nls_numeric_characters = '',.'''
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-13 Chris Horn           Defined.
  1.1   2013-06-20 Chris Horn           Added column number to fixed width.
  
*******************************************************************************/  
  procedure add_number_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default gc_null_format,
    i_min_number in number default gc_null_min_number, 
    i_max_number in number default gc_null_max_number,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default gc_null_nls_options);

  procedure add_number_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_format in fflu_common.st_name default gc_null_format,
    i_min_number in number default gc_null_min_number, 
    i_max_number in number default gc_null_max_number,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default gc_null_nls_options);
  
  
/*******************************************************************************
  NAME:      ADD_DATE_FIELD
  PURPOSE:   This function defines a date field.
             For the NLS Options check, out TO_DATE (NLS_DATE_LANGUAGE,
             NLS_CALENDAR).
             
             Notes : 
             Example Date Time Converstion Function 'DD/MM/YYYY HH:MI:SS';
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-13 Chris Horn           Defined.
  1.1   2013-06-20 Chris Horn           Added column number to fixed width.
  1.2   2013-07-19 Chris Horn           Added a position offset for date extraction.

*******************************************************************************/  
  procedure add_date_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default gc_null_format,
    i_offset in fflu_common.st_position default gc_null_offset,
    i_offset_len in fflu_common.st_length default gc_null_offset_len, 
    i_min_date in date default gc_null_min_date, 
    i_max_date in date default gc_null_max_date,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default gc_null_nls_options);

  procedure add_date_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_format in fflu_common.st_name default gc_null_format,
    i_min_date in date default gc_null_min_date, 
    i_max_date in date default gc_null_max_date,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default gc_null_nls_options);

/*******************************************************************************
  NAME:      ADD_MARS_DATE_FIELD
  PURPOSE:   This function defines a mars date field.  The mars date column is 
            the name of the mars date table return column.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.
  1.1   2013-06-20 Chris Horn           Added column number to fixed width.
  1.2   2013-07-19 Chris Horn           Added a position offset for date extraction.

*******************************************************************************/  
  procedure add_mars_date_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default gc_null_format,
    i_offset in fflu_common.st_position default gc_null_offset,
    i_offset_len in fflu_common.st_length default gc_null_offset_len, 
    i_min_number in number default gc_null_min_number, 
    i_max_number in number default gc_null_max_number,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default gc_null_nls_options);

  procedure add_mars_date_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default gc_null_format,
    i_min_number in number default gc_null_min_number, 
    i_max_number in number default gc_null_max_number,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default gc_null_nls_options);
    
/*******************************************************************************
  NAME:      PARSE_DATA
  PURPOSE:   This function will take the supplied record and parse it and 
             perform all the validations that have been defined.  It will return
             true if the parsing and validations were all successful.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-13 Chris Horn           Defined.

*******************************************************************************/  
  function parse_data(i_data in fflu_common.st_string) return boolean;

/*******************************************************************************
  NAME:      GET_RECORD_TYPE
  PURPOSE:   This function returns the record type that was found on the 
             currently parsed row.  It returns null if no record type field
             was found on the row.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.

*******************************************************************************/  
  function get_record_type return fflu_common.st_string;

/*******************************************************************************
  NAME:      GET_CHAR_FIELD
  PURPOSE:   This function returns a char field either via column number or 
             via column name as supplied in the definition.
             
             Errors will be logged if attempting to access an incorrect field
             or column name, or a value was not supplied in the data.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-13 Chris Horn           Defined.

*******************************************************************************/  
  function get_char_field(i_field_name in fflu_common.st_name) return varchar2; 

/*******************************************************************************
  NAME:      GET_NUMBER_FIELD
  PURPOSE:   This function returns a number field either via column number or 
             via column name as supplied in the definition.
             
             Errors will be logged if attempting to access an incorrect field
             or column name, or a value was not supplied in the data.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.

*******************************************************************************/  
  function get_number_field(i_field_name in fflu_common.st_name) return number; 

/*******************************************************************************
  NAME:      GET_DATE_FIELD
  PURPOSE:   This function returns a date field either via column number or 
             via column name as supplied in the definition.
             
             Errors will be logged if attempting to access an incorrect field
             or column name, or a value was not supplied in the data.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.

*******************************************************************************/  
  function get_date_field(i_field_name in fflu_common.st_name) return date; 

/*******************************************************************************
  NAME:      GET_MARS_DATE_FIELD
  PURPOSE:   This function returns a mars date field either via column number or 
             via column name as supplied in the definition.
             
             Errors will be logged if attempting to access an incorrect field
             or column name, or a value was not supplied in the data.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.

*******************************************************************************/  
  function get_mars_date_field(i_field_name in fflu_common.st_name) return number; 

/*******************************************************************************
  NAME:      LOG_FIELD_ERROR
  PURPOSE:   This procedure allows you to quickly log an error against a field.
             Its position, column and value information will be correctly 
             passed to the fflu_utils.log_interface_data_error function.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.

*******************************************************************************/  
  procedure log_field_error (
    i_field_name in fflu_common.st_name, 
    i_message in fflu_common.st_string);

/*******************************************************************************
  NAME:      LOG_INTERFACE_ERROR
  PURPOSE:   This method calls the utils implemetation by the same name, but
             also updates if there have been errors during this load.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-08-14 Chris Horn           Defined.
  
*******************************************************************************/  
  procedure log_interface_error(
    i_label fflu_common.st_buffer,    -- Label, specific for interface. 
    i_value fflu_common.st_buffer,    -- Value that is relevant at interface.
    i_message fflu_common.st_buffer); -- The actual error message.

/*******************************************************************************
  NAME:      LOG_INTERFACE_EXCEPTION
  PURPOSE:   This method calls the utils implemetation by the same name, but
             also updates if there have been errors during this load.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-08-14 Chris Horn           Created

*******************************************************************************/  
  procedure log_interface_exception (i_method fflu_common.st_buffer); 


  
/*******************************************************************************
  NAME:      WAS_ERRORS
  PURPOSE:   Tracks if any errors have been raised since the last 
             initialisation.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-20 Chris Horn           Created

*******************************************************************************/  
  function was_errors return boolean;

/*******************************************************************************
  NAME:      CLEANUP
  PURPOSE:   Logs a final interface progress record and clears definition.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-20 Chris Horn           Created

*******************************************************************************/  
  procedure cleanup;
  
end fflu_data;