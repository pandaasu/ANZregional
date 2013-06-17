create or replace 
package body fflu_data as

/*******************************************************************************
  Package Subtypes
*******************************************************************************/  
  subtype st_field_type is number(2,0);

/*******************************************************************************
  Package Constants
*******************************************************************************/  
  pc_field_type_record    constant st_field_type := 1;
  pc_field_type_char      constant st_field_type := 2;
  pc_field_type_number    constant st_field_type := 3;
  pc_field_type_date      constant st_field_type := 4;
  pc_field_type_mars_date constant st_field_type := 5;

/*******************************************************************************
  Package Data Types
*******************************************************************************/  
  -- Define the record type.
  type rt_field is record (
    field_type st_field_type,
    column_no fflu_common.st_column,
    column_name fflu_common.st_name,
    postion fflu_common.st_position,
    len fflu_common.st_length,    -- This is the fixed width length expected.
    min_len fflu_common.st_size,  -- The minimum length of a char field.
    max_len fflu_common.st_size,  -- The maxiumm length of a char field.
    min_value number,  -- The minimum expected value for a number.
    max_value number,  -- The maximum expected value for a number.
    min_date date,  -- The minimum date value we want to receive.
    max_date date,  -- The maximum date value we want to receive.
    value_char fflu_common.st_string,  -- A vhar value field.
    value_number number,     -- A number value field.
    value_date date,         -- A date value field.
    has_value boolean,        -- Tracks on parsing if this field ended up with data.
    format fflu_common.st_name, -- The formatting string to apply to the conversion.
    nls_options fflu_common.st_string, -- Any nls options to apply to the conversion.
    error_count fflu_common.st_size -- Number of errors found when processing.
  );
  -- Define the table type.  
  type tt_fields is table of rt_field index by fflu_common.st_size;

/*******************************************************************************
  Package Data Stuctures
*******************************************************************************/  
  pv_filetype fflu_common.st_filetype;       -- Holds the file type being parsed.
  pv_csv_qualifier fflu_common.st_qualifier; -- Holds the csv text qualifier.
  pv_allow_missing boolean;                  -- Tracks if we allow missing columns after the last bit of data.
  pv_fields tt_fields;                       -- Holds all the field definitions.

/*******************************************************************************
  NAME:      LOG_INTERFACE_PROGRESS                                       PUBLIC
*******************************************************************************/  
  
/*******************************************************************************
  NAME:      ESCAPE_JSON_STRING
  PURPOSE:   This function takes a supplied string and converts all whitespace
             characters to a space.  It then escapes \ / ' and trims the left 
             and right most spaces from the string and returns. 
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-13 Chris Horn           Created
  
*******************************************************************************/   

/*******************************************************************************
  Initialise Package State Variables.
*******************************************************************************/  
begin
  pv_filetype := null;
  pv_csv_qualifier := null;
end fflu_data;