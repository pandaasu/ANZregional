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
    - was_errors                  Return if any errors have been recorded.
  + Other Functions

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-06-13  Chris Horn            Defined the specification.
  2013-06-18  Chris Horn            Refined spec and implemented.
  2013-06-20  Chris Horn            Added was errors function.

*******************************************************************************/

/*******************************************************************************
  NAME:      INITIALISE
  PURPOSE:   Setups an empty definition for the incoming data. 
             
             Allow Missing = True, will prevent exception when whitespace, 
             or commas are missing for empty fields.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-03 Chris Horn           Defined.
  
*******************************************************************************/  
  procedure initialise(
    i_filetype in fflu_common.st_filetype,
    i_csv_qualifier in fflu_common.st_qualifier default null,
    i_allow_missing in boolean default false);

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
  procedure add_record_type(
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_record_type in fflu_common.st_string);

 procedure add_record_type(
    i_column in fflu_common.st_column, 
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_record_type in fflu_common.st_string);

/*******************************************************************************
  NAME:      ADD_CHAR_FIELD
  PURPOSE:   This function defines the char field.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-13 Chris Horn           Defined.

*******************************************************************************/  
  procedure add_char_field(
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_min_length in fflu_common.st_size default null,
    i_max_length in fflu_common.st_size default null,
    i_allow_null in boolean default false,
    i_trim in boolean default false
    );
  
  procedure add_char_field(
    i_column in fflu_common.st_column, 
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_min_length in fflu_common.st_size default null,
    i_allow_null in boolean default false,
    i_trim in boolean default true);
  
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
  procedure add_number_field(
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null);

  procedure add_number_field(
    i_column in fflu_common.st_column, 
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null);
  
  
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

*******************************************************************************/  
  procedure add_date_field(
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null);

  procedure add_date_field(
    i_column in fflu_common.st_column, 
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null);

/*******************************************************************************
  NAME:      ADD_MARS_DATE_FIELD
  PURPOSE:   This function defines a mars date field.  The mars date column is 
            the name of the mars date table return column.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Defined.
  1.1   2013-06-20 Chris Horn           Added column number to fixed width.

*******************************************************************************/  
  procedure add_mars_date_field(
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null);

  procedure add_mars_date_field(
    i_column in fflu_common.st_column,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null);
    
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
  function get_char_field(i_column in fflu_common.st_column) return varchar2;
  function get_char_field(i_column_name in fflu_common.st_name) return varchar2; 

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
  function get_number_field(i_column in fflu_common.st_column) return number;
  function get_number_field(i_column_name in fflu_common.st_name) return number; 

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
  function get_date_field(i_column in fflu_common.st_column) return date;
  function get_date_field(i_column_name in fflu_common.st_name) return date; 

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
  function get_mars_date_field(i_column in fflu_common.st_column) return number;
  function get_mars_date_field(i_column_name in fflu_common.st_name) return number; 

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
  procedure log_field_error(
    i_column in fflu_common.st_column, 
    i_message in fflu_common.st_string);
    
  procedure log_field_error(
    i_column_name in fflu_common.st_name, 
    i_message in fflu_common.st_string);
  
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