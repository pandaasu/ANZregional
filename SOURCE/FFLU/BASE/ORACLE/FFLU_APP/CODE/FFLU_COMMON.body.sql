create or replace 
PACKAGE BODY FFLU_COMMON AS 

/*******************************************************************************
  NAME:      VALIDATE_NON_EMPTY_STRING                                    PUBLIC
*******************************************************************************/
procedure validate_non_empty_string(i_exception_code in st_exception_code, i_string in st_string, i_name in st_name) is
begin
  if i_string is null then 
    raise_application_error(i_exception_code,'['||i_name || '] cannot be EMPTY / NULL');
  end if;
end validate_non_empty_string;

/*******************************************************************************
  NAME:      VALIDATE_STRING_LENGTH                                      PUBLIC
*******************************************************************************/
procedure validate_string_length(i_exception_code in st_exception_code, i_string in st_string, i_min_len in st_size, i_max_len in st_size, i_name in st_name) is
begin
  if lengthb(i_string) < i_min_len then 
    raise_application_error(i_exception_code,'[' ||i_name || '] value [' || i_string || '] length [' || lengthb(i_string) ||'] cannot be less than ' || i_min_len || ' characters.'); 
  end if;
  if lengthb(i_string) > i_max_len then 
    raise_application_error(i_exception_code,'[' ||i_name || '] value [' || i_string || '] length [' || lengthb(i_string) ||'] cannot be greater than ' || i_max_len || ' characters.'); 
  end if;
end validate_string_length;

END FFLU_COMMON;