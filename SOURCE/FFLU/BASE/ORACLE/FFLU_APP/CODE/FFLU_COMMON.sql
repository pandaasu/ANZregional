create or replace 
PACKAGE FFLU_COMMON AS 

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

END FFLU_COMMON;