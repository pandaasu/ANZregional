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
    position fflu_common.st_position,
    len fflu_common.st_length,    -- This is the fixed width length expected.
    min_len fflu_common.st_size,  -- The minimum length of a char field.
    max_len fflu_common.st_size,  -- The maxiumm length of a char field.
    min_number number,  -- The minimum expected value for a number.
    max_number number,  -- The maximum expected value for a number.
    min_date date,  -- The minimum date value we want to receive.
    max_date date,  -- The maximum date value we want to receive.
    allow_null boolean,  -- Set to true if nulls are allowed for the field.
    trim_column boolean, -- Tracks if this column should be trimed on parsing.
    value_char fflu_common.st_string,  -- A vhar value field.
    value_number number,     -- A number value field.
    value_date date,         -- A date value field.
    was_parsed boolean,        -- Tracks on parsing if this field ended up with data.
    format fflu_common.st_name, -- The formatting string to apply to the conversion.
    nls_options fflu_common.st_string, -- Any nls options to apply to the conversion.
    mars_date_column fflu_common.st_name, -- The name of the mars date column to return.
    error_count fflu_common.st_size -- Number of errors found when processing.
  );
  -- Define the table type.  
  type tt_fields is table of rt_field index by fflu_common.st_size;

/*******************************************************************************
  Package Data Stuctures
*******************************************************************************/  
  pv_initialised boolean;                    -- Tracks if data parsing has been initalised.
  pv_filetype fflu_common.st_filetype;       -- Holds the file type being parsed.
  pv_csv_qualifier fflu_common.st_qualifier; -- Holds the csv text qualifier.
  pv_allow_missing boolean;                  -- Tracks if we allow missing columns after the last bit of data.
  pv_have_parsed boolean;                    -- Set to true if we have successfully parsed a row of data.
  ptv_fields tt_fields;                       -- Holds all the field definitions.

/*******************************************************************************
  NAME:      FIND_COLUMN
  PURPOSE:   This function looks up the field number for a given column name or
             number. It is assumed that this is called after a successful data 
             parse. Else it raises a parse not completed yet error.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function find_column(
    i_column_no in fflu_common.st_column,
    o_field_no out fflu_common.st_size) return boolean is
    v_result boolean;
    v_counter fflu_common.st_size;
  begin
    v_result := true;
    o_field_no := null;
    if pv_have_parsed = false then 
      fflu_utils.log_interface_data_error(
        'Column No',i_column_no,i_column_no,'Data parser does not have a parsed row of data in memory for that column.');
      v_result := false;
    else
      -- Now reviewed the parsed data and find the field for the column requested.
      v_counter := 0;
      loop 
        v_counter := v_counter + 1;
        exit when v_counter > ptv_fields.count or o_field_no is not null;
        -- Now check if this field matches.
        if ptv_fields(v_counter).column_no = i_column_no and ptv_fields(v_counter).was_parsed = true then 
          o_field_no := v_counter;
        end if;
      end loop;
      -- Now report an error if not found.
      if o_field_no is not null then
        fflu_utils.log_interface_data_error(
          'Column No',i_column_no,i_column_no,'Data parser could not find a successfully parsed column with that number.');
        v_result := false;
      end if;
    end if;
    return v_result;
  end find_column;

  function find_column (
    i_column_name in fflu_common.st_name,
    o_field_no out fflu_common.st_size) return boolean is
    v_result boolean;
    v_counter fflu_common.st_size;
  begin
    v_result := true;
    o_field_no := null;
    if pv_have_parsed = false then 
      fflu_utils.log_interface_data_error(
        'Column Name',null,i_column_name,'Data parser does not have a parsed row of data in memory for this column.');
      v_result := false;
    else
      -- Now reviewed the parsed data and find the field for the column requested.
      v_counter := 0;
      loop 
        v_counter := v_counter + 1;
        exit when v_counter > ptv_fields.count or o_field_no is not null;
        -- Now check if this field matches.
        if ptv_fields(v_counter).column_name = i_column_name and ptv_fields(v_counter).was_parsed = true then 
          o_field_no := v_counter;
        end if;
      end loop;
      -- Now report an error if not found.
      if o_field_no is not null then
        fflu_utils.log_interface_data_error(
          'Column Name',null,i_column_name,'Data parser could not find a successfully parsed column with that name.');
        v_result := false;
      end if;
    end if;
    return v_result;
  end find_column;


/*******************************************************************************
  NAME:      GET_FIELD_VALUE_AS_STRING
  PURPOSE:   Looks at a field type for and returns the approperiate value
             field as a string.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function get_field_value_as_string(
    i_field_no in fflu_common.st_size) return fflu_common.st_string is
    v_result fflu_common.st_string;
  begin
    v_result := '';
    case ptv_fields(i_field_no).field_type 
       -- Get the record type data.
       when pc_field_type_record then 
         v_result := ptv_fields(i_field_no).value_char;
       -- Get the string data.
       when pc_field_type_char then 
         v_result := ptv_fields(i_field_no).value_char;
       -- Get the number data.
       when pc_field_type_number then 
         begin
           if ptv_fields(i_field_no).format is not null then 
             if ptv_fields(i_field_no).nls_options is not null then 
               v_result := to_char(ptv_fields(i_field_no).value_number,ptv_fields(i_field_no).format,ptv_fields(i_field_no).nls_options);
             else 
               v_result := to_char(ptv_fields(i_field_no).value_number,ptv_fields(i_field_no).format);
             end if;
           else
             v_result := to_char(ptv_fields(i_field_no).value_number);
           end if;
         exception
           -- Incase there was a conversion error with the customer formatting, use the default which should never fail. 
           when others then 
             v_result := to_char(ptv_fields(i_field_no).value_number);
         end;
       -- Get the date data.
       when pc_field_type_date then 
         begin
           if ptv_fields(i_field_no).format is not null then
             if ptv_fields(i_field_no).nls_options is not null then 
               v_result := to_char(ptv_fields(i_field_no).value_date,ptv_fields(i_field_no).format,ptv_fields(i_field_no).nls_options);
             else 
               v_result := to_char(ptv_fields(i_field_no).value_date,ptv_fields(i_field_no).format);
             end if;
           else 
             v_result := to_char(ptv_fields(i_field_no).value_date);
           end if;
          exception
            -- Incase there was a conversion error with the customer formatting, use the default which should never fail. 
            when others then 
              v_result := ptv_fields(i_field_no).value_date;
          end;
       -- gt the mars date data.
       when pc_field_type_mars_date then 
         v_result := to_char(ptv_fields(i_field_no).value_number);
       -- If an unknown data type just return null.
       else
         v_result := '';
    end case;
    return v_result;
  end get_field_value_as_string;
    

/*******************************************************************************
  NAME:      CHECK_INITIALISED
  PURPOSE:   This function checks that the system has been initiliased.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function check_initialised return boolean is
  begin
    if pv_initialised = false then 
      fflu_utils.log_interface_error(
           'Data Parser Initialised','False','Data Parsing tried to be used when not yet initialised.');
    end if;
    return pv_initialised;
  end check_initialised;
  
/*******************************************************************************
  NAME:      CHECK_FILETYPE_IS_CSV
  PURPOSE:   This function checks that the initialised file type is csv.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function check_filetype_is_csv(i_column_name in fflu_common.st_name) return boolean is
  begin
    if pv_filetype <> fflu_common.gc_file_type_csv then 
      fflu_utils.log_interface_error(
           'File Type',pv_filetype,'Data Parsing expected a csv file type for column definition [' || i_column_name || '].');
    end if;
    return pv_filetype = fflu_common.gc_file_type_csv;
  end check_filetype_is_csv;

/*******************************************************************************
  NAME:      CHECK_FILETYPE_IS_FIXED_WIDTH
  PURPOSE:   This function checks that the initialised file type is txt.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function check_filetype_is_fixed_width(i_column_name in fflu_common.st_name) return boolean is
  begin
    if pv_filetype <> fflu_common.gc_file_type_fixed_width then 
      fflu_utils.log_interface_error(
           'File Type',pv_filetype,'Data Parsing expected a txt file type for column definition [' || i_column_name || '].');
    end if;
    return pv_filetype = fflu_common.gc_file_type_fixed_width;
  end check_filetype_is_fixed_width;

/*******************************************************************************
  NAME:      CHECK_COLUMN
  PURPOSE:   Checks that the column is valid.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function check_column (
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name) return boolean is
    v_error_sufix fflu_common.st_string;
    v_result boolean;
  begin
    v_result := true;
    v_error_sufix := ' For column name [' || i_column_name || '].';
    -- Check the column number.
    if i_column is null then 
      fflu_utils.log_interface_error('Column No','null','Supplied column no cannot be null.' || v_error_sufix);
      v_result := false;
    elsif i_column <= 0 then 
      fflu_utils.log_interface_error('Column No',i_column,'Supplied column no cannot be less than or equal to zero.' || v_error_sufix);
      v_result := false;
    elsif i_column > 4000 then 
      fflu_utils.log_interface_error('Column No',i_column,'Supplied column no cannot be greater than 4000 columns.' || v_error_sufix);
      v_result := false;
    end if;
    -- Check the column name
    if trim(i_column_name) is null then 
      fflu_utils.log_interface_error('Column Name','null','Supplied column name cannot be null.');
      v_result := false;
    end if;
    return v_result;
  end check_column;
  
  function check_column (
    i_position in fflu_common.st_position, 
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name) return boolean is
    v_error_sufix fflu_common.st_string;
    v_end_position fflu_common.st_position;
    v_result boolean;
  begin
    v_result := true;
    v_error_sufix := ' For column name [' || i_column_name || '].';
    -- Check the column position.
    if i_position is null then 
      fflu_utils.log_interface_error('Position','null','Supplied column position cannot be null.' || v_error_sufix);
      v_result := false;
    elsif i_position <= 0 then 
      fflu_utils.log_interface_error('Position',i_position,'Supplied column position cannot be less than or equal to zero.' || v_error_sufix);
      v_result := false;
    elsif i_position > 4000 then 
      fflu_utils.log_interface_error('Position',i_position,'Supplied column position cannot be greater than 4000.' || v_error_sufix);
      v_result := false;
    end if;
    -- Check the column length.
    if i_length is null then 
      fflu_utils.log_interface_error('Length','null','Supplied column length cannot be null.' || v_error_sufix);
      v_result := false;
    elsif i_length <= 0 then 
      fflu_utils.log_interface_error('Length',i_position,'Supplied column length cannot be less than or equal to zero.' || v_error_sufix);
      v_result := false;
    elsif i_length > 4000 then 
      fflu_utils.log_interface_error('Length',i_position,'Supplied column length cannot be greater than 4000.' || v_error_sufix);
      v_result := false;
    end if;
    -- Now perform a check of the position + length.
    v_end_position := i_position + i_length - 1;
    if v_end_position > 4000 then 
      fflu_utils.log_interface_error('End Position',v_end_position,'Calculated end position cannot be greater than 4000.' || v_error_sufix);
      v_result := false;
    end if;
    -- Check the column name
    if trim(i_column_name) is null then 
      fflu_utils.log_interface_error('Column Name','null','Supplied column name cannot be null.');
      v_result := false;
    end if;
    return v_result;
  end check_column;
  
/*******************************************************************************
  NAME:      CHECK_MARS_DATE_COLUMN
  PURPOSE:   Checks that the supplied mars date column exists as a number
             column in the mars date table. 
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function check_mars_date_column(
    i_column_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name) return boolean is
    v_result boolean;
    v_error_sufix fflu_common.st_string;
    -- Cursor to check the mars date column name exists.
    cursor csr_check_mars_date_column is
      select column_name from all_tab_columns where table_name = 'MARS_DATE' and data_type = 'NUMBER' and column_name = upper(i_mars_date_column);
    v_column_name fflu_common.st_name;
  begin
    v_result := true;
    v_error_sufix := ' For column name [' || i_column_name || '].';
    -- Check the mars date column name
    if i_mars_date_column is null then 
      fflu_utils.log_interface_error('Mars Date Column','null','Supplied mars date column name cannot be null.' || v_error_sufix);
      v_result := false;
    else 
      -- Check the mars date column exists.
      open csr_check_mars_date_column;
      fetch csr_check_mars_date_column into v_column_name;
      if csr_check_mars_date_column%notfound then 
        fflu_utils.log_interface_error('Mars Date Column',i_mars_date_column,'Supplied mars date column did not exist in the mars date table.' || v_error_sufix);
        v_result := false;
      end if;
      close csr_check_mars_date_column;
    end if;
    return v_result;
  end check_mars_date_column;

/*******************************************************************************
  NAME:      INITIALISE                                                   PUBLIC
*******************************************************************************/  
  procedure initialise(
    i_filetype in fflu_common.st_filetype,
    i_csv_qualifier in fflu_common.st_qualifier default null,
    i_allow_missing in boolean default false) is
  begin
    pv_initialised := true;
    pv_filetype := trim(i_filetype);
    -- Check if the supplied file type was null
    if pv_filetype is null then 
      fflu_utils.log_interface_error(
        'File Type',i_filetype,'Data Parsing was initialised with a null file type.'); 
      pv_initialised := false;
    else
      -- Check if the supplied file type was unknown.
      if pv_filetype not in (fflu_common.gc_file_type_csv, fflu_common.gc_file_type_fixed_width) then 
        fflu_utils.log_interface_error(
          'File Type',i_filetype,'Data Parsing was initialised with an unknown file type.'); 
        pv_initialised := false;
      end if;
    end if;
    -- Now check the csv qualifier which is optionally supplied.
    pv_csv_qualifier := i_csv_qualifier;
    if pv_csv_qualifier is not null then
      if pv_csv_qualifier not in (fflu_common.gc_csv_qualifier_single_quote,fflu_common.gc_csv_qualifier_double_quote) then
        fflu_utils.log_interface_error(
          'CSV Qualifier',i_csv_qualifier,'Data Parsing was supplied with a csv qualifer that was unknown.');
        pv_initialised := false;
      end if;
    end if;
    pv_allow_missing := i_allow_missing;
    pv_have_parsed := false;
  end initialise;


/*******************************************************************************
  NAME:      ADD_RECORD_TYPE                                              PUBLIC
*******************************************************************************/  
  procedure add_record_type(
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_record_type in fflu_common.st_string) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_column,i_column_name) = true and check_filetype_is_csv(i_column_name) = true then 
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_record;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.allow_null := false;
      rv_field.trim_column := false; 
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_record_type;

 procedure add_record_type(
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_record_type in fflu_common.st_string) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_position,i_length,i_column_name) = true and check_filetype_is_fixed_width(i_column_name) = true then
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_record;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.column_name := i_column_name;
      rv_field.allow_null := false;
      rv_field.trim_column := false;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_record_type;

/*******************************************************************************
  NAME:      ADD_CHAR_FIELD                                               PUBLIC
*******************************************************************************/  
  procedure add_char_field(
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_min_length in fflu_common.st_size default null,
    i_max_length in fflu_common.st_size default null,
    i_allow_null in boolean default false,
    i_trim in boolean default false
    ) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_column,i_column_name) = true and check_filetype_is_csv(i_column_name) = true then 
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_char;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.min_len := i_min_length;
      rv_field.max_len := i_max_length;
      rv_field.allow_null := i_allow_null;
      rv_field.trim_column := i_trim; 
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_char_field;
  
  procedure add_char_field(
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_min_length in fflu_common.st_size default null,
    i_allow_null in boolean default false,
    i_trim in boolean default true) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_position,i_length,i_column_name) = true and check_filetype_is_fixed_width(i_column_name) = true then
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_char;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.column_name := i_column_name;
      rv_field.min_len := i_min_length;
      rv_field.max_len := i_length;
      rv_field.allow_null := i_allow_null;
      rv_field.trim_column := i_trim;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_char_field;
  
/*******************************************************************************
  NAME:      ADD_NUMBER_FIELD                                             PUBLIC
*******************************************************************************/  
  procedure add_number_field(
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_column,i_column_name) = true and check_filetype_is_csv(i_column_name) = true then 
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_number;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.min_number := i_min_number;
      rv_field.max_number := i_max_number;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_number_field;

  procedure add_number_field(
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_position,i_length,i_column_name) = true and check_filetype_is_fixed_width(i_column_name) = true then
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_number;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.column_name := i_column_name;
      rv_field.min_number := i_min_number;
      rv_field.max_number := i_max_number;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_number_field;
  
  
/*******************************************************************************
  NAME:      ADD_DATE_FIELD                                               PUBLIC
*******************************************************************************/  
  procedure add_date_field(
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_column,i_column_name) = true and check_filetype_is_csv(i_column_name) = true then 
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_number;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.format := i_format;
      rv_field.min_date := i_min_date;
      rv_field.max_date := i_max_date;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_date_field;
    
  procedure add_date_field(
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_position,i_length,i_column_name) = true and check_filetype_is_fixed_width(i_column_name) = true then
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_date;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.column_name := i_column_name;
      rv_field.format := i_format;
      rv_field.min_date := i_min_date;
      rv_field.max_date := i_max_date;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_date_field;

/*******************************************************************************
  NAME:      ADD_MARS_DATE_FIELD                                          PUBLIC 
*******************************************************************************/  
  procedure add_mars_date_field(
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_column,i_column_name) = true and check_filetype_is_csv(i_column_name) = true
        and check_mars_date_column(i_column_name, i_mars_date_column) = true then 
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_number;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.format := i_format;
      rv_field.min_date := i_min_date;
      rv_field.max_date := i_max_date;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      rv_field.mars_date_column := i_mars_date_column;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_mars_date_field;

  procedure add_mars_date_field(
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_column_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default false,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_position,i_length,i_column_name) = true and check_filetype_is_fixed_width(i_column_name) = true
        and check_mars_date_column(i_column_name, i_mars_date_column) = true then 
      -- Setup the field definition.
      rv_field.field_type := pc_field_type_date;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.column_name := i_column_name;
      rv_field.format := i_format;
      rv_field.min_date := i_min_date;
      rv_field.max_date := i_max_date;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      rv_field.mars_date_column := i_mars_date_column;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  end add_mars_date_field;

/*******************************************************************************
  NAME:      PARSE_DATA                                                   PUBLIC
*******************************************************************************/  
  function parse_data(i_data in fflu_common.st_string) return boolean is
    v_result boolean;
    v_error_count fflu_common.st_size;
    v_data fflu_common.st_string;
    v_data_len fflu_common.st_size;
    
    -- Look through all the field defintions and clear out any old data.
    procedure clear_data is
      v_counter fflu_common.st_size;
    begin
      pv_have_parsed := false;
      v_counter := 1;
      loop
        exit when v_counter > ptv_fields.count; 
        -- Now clear the field record fields.
        ptv_fields(v_counter).value_char := null;
        ptv_fields(v_counter).value_number := null;
        ptv_fields(v_counter).value_date := null;
        ptv_fields(v_counter).was_parsed := false;
        ptv_fields(v_counter).error_count := 0;
        -- Now loop onto the next definiton.
        v_counter := v_counter + 1;
      end loop;
    end clear_data;

    procedure log_field_parse_error(
      i_field_no in fflu_common.st_size,
      i_message in fflu_common.st_string) is
    begin
      v_error_count := v_error_count + 1;
      if pv_filetype = fflu_common.gc_file_type_csv then 
        fflu_utils.log_interface_data_error(
          ptv_fields(i_field_no).column_name,ptv_fields(i_field_no).column_no,get_field_value_as_string(i_field_no),i_message);
      elsif pv_filetype = fflu_common.gc_file_type_fixed_width then 
        fflu_utils.log_interface_data_error(
          ptv_fields(i_field_no).column_name,ptv_fields(i_field_no).position,
          ptv_fields(i_field_no).len,get_field_value_as_string(i_field_no),i_message);
      end if;
    end log_field_parse_error;
    
    procedure process_field (
      i_field_no in fflu_common.st_size, 
      i_field in fflu_common.st_string) is
    begin
      case ptv_fields(i_field_no).field_type
        when pc_field_type_record then
          null;
        when pc_field_type_char then 
          null;
        when pc_field_type_number then
          null;
        when pc_field_type_date then
          null;
        when pc_field_type_mars_date then 
          null;
        else
          log_field_parse_error(i_field_no,'Unknown data type was defined, internal Data Parser system error.');
      end case;
    end process_field;
    
    procedure parse_csv_record is 
    begin
      null;
    end parse_csv_record;
    
    function extract_fixed_width_field(i_field_no in fflu_common.st_size,o_process_field out boolean) return fflu_common.st_string is
      v_end_position fflu_common.st_size;
      v_result fflu_common.st_size;
    begin
      o_process_field := true;
      v_result := null;
      v_end_position := ptv_fields(i_field_no).position + ptv_fields(i_field_no).len - 1;
      if v_end_position <= v_data_len then 
        v_result := substr(v_data,ptv_fields(i_field_no).position,v_end_position);
      else 
        if pv_allow_missing = true then 
          if ptv_fields(i_field_no).position <= v_data_len then
            v_result := substr(v_data,ptv_fields(i_field_no).position,v_data_len);
          else
            v_result := null;
          end if;
        else
          log_field_parse_error(i_field_no,'Record was not long enough to contain all the required data for this field.');
          o_process_field := false;
        end if;
      end if;
    end extract_fixed_width_field;
    
    function extract_csv_field(i_field_no in fflu_common.st_size,o_process_field out boolean) return fflu_common.st_string is
    begin
      return null;
    end extract_csv_field;
    
    procedure parse_record is
      v_counter fflu_common.st_size;
      v_field fflu_common.st_size;
      v_finished boolean;   -- Tracks if we should stop processing.
      v_process_field boolean;
      v_field_mode fflu_common.st_size;
      c_field_mode_no_record constant fflu_common.st_size := 1;
      c_field_mode_in_record constant fflu_common.st_size := 2;
      c_field_mode_search_record constant fflu_common.st_size := 3;
    begin
      v_counter := 0;
      v_finished := false;
      v_field_mode := c_field_mode_no_record;
      v_data_len := length(v_data);
      loop 
        v_counter := v_counter + 1;
        exit when v_counter > ptv_fields.count or v_finished = true;
        case v_field_mode
          -- Check if we are not in a record and not searching for the next record type.
          when c_field_mode_no_record then 
            v_process_field := true;
          -- Check if we are in a current record.
          when c_field_mode_in_record then 
            if ptv_fields(v_counter).field_type = pc_field_type_record then 
              v_finished := true;
              v_process_field := false;
            else
              v_process_field := true;
            end if;
          -- Check if we are searching for the next record type field to process.
          when c_field_mode_search_record then 
            if ptv_fields(v_counter).field_type = pc_field_type_record then 
              v_process_field := true;
            else 
              v_process_field := false;
            end if;
          -- If an unkown field then do not process.
          else
            v_process_field := false;
        end case;
        -- Now process the current field.
        if v_process_field = true then 
          if pv_filetype = fflu_common.gc_file_type_fixed_width then 
            v_field := extract_fixed_width_field(v_counter,v_process_field); 
          elsif pv_filetype = fflu_common.gc_file_type_csv then 
            v_field := extract_csv_field(v_counter,v_process_field);
          end if;
        end if;
        -- If we are still processing field then perform, ie no error in the extraction.
        if v_process_field = true then 
          process_field(v_counter,v_field);
          -- Now check if this field was a record type field and if it successfully parsed as this record type.
          if ptv_fields(v_counter).field_type = pc_field_type_record then 
            if ptv_fields(v_counter).was_parsed = true  then 
              v_field_mode := c_field_mode_in_record;
            else 
              v_field_mode := c_field_mode_search_record;
            end if;
          end if;
        end if;
      end loop;
    end parse_record;
    
  begin
    v_result := true;
    v_error_count := 0;
    -- Check if we are initialised
    if check_initialised = true then 
      -- Now clear down the previous parsing results. 
      clear_data();
      -- Now take off the line feed at the end of the line if it exists.
      v_data := i_data;
      v_data_len := length(v_data);
      if v_data_len > 0 then 
        if substr(v_data,v_data_len,1) = chr(10) then 
          v_data := substr(v_data,1,v_data_len-1);
          v_data_len := v_data_len - 1;
        end if;
      end if;
      -- Now perform the parsing
      parse_record();
      -- Now check the error count.
      if v_error_count > 0 then 
        v_result := false;
      end if;
    else
      -- If the system was uninitilised.
      v_result := false;
    end if;
    return v_result;
  end parse_data;


/*******************************************************************************
  NAME:      GET_RECORD_TYPE                                              PUBLIC
*******************************************************************************/  
  function get_record_type return fflu_common.st_string is
    v_field_no fflu_common.st_size;
    v_result fflu_common.st_string;
    v_counter fflu_common.st_size;
  begin
    v_result := null;
    if check_initialised = true then 
      if pv_have_parsed = false then 
        fflu_utils.log_interface_data_error(
          null,null,null,'Data parser does not have a parsed row of data in memory to be able to find the record type.');
      else
        v_counter := 0;
        loop
          v_counter := v_counter + 1;
          exit when v_counter > ptv_fields.count or v_field_no is not null;
          if ptv_fields(v_counter).field_type = pc_field_type_record and ptv_fields(v_counter).was_parsed = true then 
            v_field_no := v_counter;
          end if;
        end loop;
        -- Check if the field no is null
        if v_field_no is not null then 
          fflu_utils.log_interface_data_error(
            null,null,null,'Data parser could not find a successfully parsed record type column.');
        else 
          -- Now return the record type.
          v_result := ptv_fields(v_field_no).value_char;
        end if;
      end if;
    end if;
  end get_record_type;

/*******************************************************************************
  NAME:      GET_CHAR_FIELD                                               PUBLIC
*******************************************************************************/  
  function get_char_field(
    i_column in fflu_common.st_column) return varchar2 is
    v_field_no fflu_common.st_size;
    v_result fflu_common.st_string;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_char;
    end if;
    return v_result;
  end get_char_field;
  
  function get_char_field(
    i_column_name in fflu_common.st_name) return varchar2 is
    v_field_no fflu_common.st_size;
    v_result fflu_common.st_string;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_char;
    end if;
    return v_result;
  end get_char_field;

/*******************************************************************************
  NAME:      GET_NUMBER_FIELD                                             PUBLIC
*******************************************************************************/  
  function get_number_field(
    i_column in fflu_common.st_column) return number is
    v_field_no fflu_common.st_size;
    v_result number;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_number;
    end if;
    return v_result;
  end get_number_field;
  
  function get_number_field(
    i_column_name in fflu_common.st_name) return number is
    v_field_no fflu_common.st_size;
    v_result number;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_number;
    end if;
    return v_result;
  end get_number_field;


/*******************************************************************************
  NAME:      GET_DATE_FIELD                                               PUBLIC
*******************************************************************************/  
  function get_date_field(
    i_column in fflu_common.st_column) return date is
    v_field_no fflu_common.st_size;
    v_result date;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_date;
    end if;
    return v_result;
  end get_date_field;
    
  function get_date_field(
    i_column_name in fflu_common.st_name) return date is
    v_field_no fflu_common.st_size;
    v_result date;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_date;
    end if;
    return v_result;
  end get_date_field;


/*******************************************************************************
  NAME:      GET_MARS_DATE_FIELD                                          PUBLIC
*******************************************************************************/  
  function get_mars_date_field(
    i_column in fflu_common.st_column) return number is
    v_field_no fflu_common.st_size;
    v_result number;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_number;
    end if;
    return v_result;
  end get_mars_date_field;
    
  function get_mars_date_field(
    i_column_name in fflu_common.st_name) return number is
    v_field_no fflu_common.st_size;
    v_result number;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_column_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_number;
    end if;
    return v_result;
  end get_mars_date_field;

/*******************************************************************************
  NAME:      LOG_FIELD_ERROR                                              PUBLIC
*******************************************************************************/  
  procedure log_field_error(
    i_column in fflu_common.st_column, 
    i_message in fflu_common.st_string) is
    v_field_no fflu_common.st_size;
  begin
    if check_initialised = true and find_column(i_column,v_field_no) = true then 
      if pv_filetype = fflu_common.gc_file_type_csv then 
        fflu_utils.log_interface_data_error(
          ptv_fields(v_field_no).column_name,ptv_fields(v_field_no).column_no,get_field_value_as_string(v_field_no),i_message);
      elsif pv_filetype = fflu_common.gc_file_type_fixed_width then 
        fflu_utils.log_interface_data_error(
          ptv_fields(v_field_no).column_name,ptv_fields(v_field_no).position,
          ptv_fields(v_field_no).len,get_field_value_as_string(v_field_no),i_message);
      end if;
    end if;
  end log_field_error;
    
  procedure log_field_error(
    i_column_name in fflu_common.st_name, 
    i_message in fflu_common.st_string) is
    v_field_no fflu_common.st_size;
  begin
    if check_initialised = true and find_column(i_column_name,v_field_no) = true then 
      if pv_filetype = fflu_common.gc_file_type_csv then 
        fflu_utils.log_interface_data_error(
          ptv_fields(v_field_no).column_name,ptv_fields(v_field_no).column_no,get_field_value_as_string(v_field_no),i_message);
      elsif pv_filetype = fflu_common.gc_file_type_fixed_width then 
        fflu_utils.log_interface_data_error(
          ptv_fields(v_field_no).column_name,ptv_fields(v_field_no).position,
          ptv_fields(v_field_no).len,get_field_value_as_string(v_field_no),i_message);
      end if;
    end if;
  end log_field_error;

/*******************************************************************************
  Initialise Package State Variables.
*******************************************************************************/  
begin
  pv_initialised := false;
  pv_filetype := null;
  pv_allow_missing := false;                  
  pv_csv_qualifier := null;
  pv_have_parsed := false;
  ptv_fields.delete;
end fflu_data;