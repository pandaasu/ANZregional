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
    field_name fflu_common.st_name,  -- The unique identifier for this field.  
    field_type st_field_type,
    column_no fflu_common.st_column,
    column_name fflu_common.st_name,
    position fflu_common.st_position,
    offset fflu_common.st_position, -- This is the position within the field that we should start looking for the field.
    offset_len fflu_common.st_length, -- The length to extract from the offset.
    len fflu_common.st_length,    -- This is the fixed width length expected.
    min_len fflu_common.st_size,  -- The minimum length of a char field.
    max_len fflu_common.st_size,  -- The maxiumm length of a char field.
    min_number number,  -- The minimum expected value for a number.
    max_number number,  -- The maximum expected value for a number.
    min_date date,  -- The minimum date value we want to receive.
    max_date date,  -- The maximum date value we want to receive.
    allow_null boolean,  -- Set to true if nulls are allowed for the field.
    trim_column boolean, -- Tracks if this column should be trimed on parsing.
    record_type fflu_common.st_string, -- The record type data.
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
  pv_csv_header boolean;                     -- Tracks if this csv file has a header.
  pv_allow_missing boolean;                  -- Tracks if we allow missing columns after the last bit of data.
  pv_have_parsed boolean;                    -- Set to true if we have successfully parsed a row of data.
  pv_errors boolean;                         -- Tracks if any errors have been raised since the last initialisation.
  ptv_fields tt_fields;                      -- Holds all the field definitions.

/*******************************************************************************
  NAME:      FIND_COLUMN
  PURPOSE:   This function looks up the field number for a given field  It is 
             assumed that this is called after a successful data 
             parse. Else it raises a parse not completed yet error.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function find_column (
    i_field_name in fflu_common.st_name,
    o_field_no out fflu_common.st_size) return boolean is
    v_result boolean;
    v_counter fflu_common.st_size;
  begin
    v_result := true;
    o_field_no := null;
    if pv_have_parsed = false then 
      fflu_utils.log_interface_data_error(
        'Field Name',null,i_field_name,'Data parser does not have a parsed row of data in memory.');
      pv_errors := true;
      v_result := false;
    else
      -- Now reviewed the parsed data and find the field for the column requested.
      v_counter := 0;
      loop 
        v_counter := v_counter + 1;
        exit when v_counter > ptv_fields.count or o_field_no is not null;
        -- Now check if this field matches.
        if ptv_fields(v_counter).field_name = i_field_name and ptv_fields(v_counter).was_parsed = true then 
          o_field_no := v_counter;
        end if;
      end loop;
      -- Now report an error if not found.
      if o_field_no is null then
        fflu_utils.log_interface_data_error(
          'Field Name',null,i_field_name,'Data parser could not find a successfully parsed field with that name.');
        pv_errors := true;
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
      pv_errors := true;
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
  function check_filetype_is_csv(i_field_name in fflu_common.st_name) return boolean is
  begin
    if pv_filetype <> fflu_common.gc_file_type_csv then 
      fflu_utils.log_interface_error(
           'File Type',pv_filetype,'Data Parsing expected a csv file type for field definition [' || i_field_name || '].');
      pv_errors := true;
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
  function check_filetype_is_fixed_width(i_field_name in fflu_common.st_name) return boolean is
  begin
    if pv_filetype <> fflu_common.gc_file_type_fixed_width then 
      fflu_utils.log_interface_error(
           'File Type',pv_filetype,'Data Parsing expected a txt file type for field definition [' || i_field_name || '].');
      pv_errors := true;
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
  1.1   2013-06-20 Chris Horn           Added column no for fixed with.
  
*******************************************************************************/   
  function check_column (
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column) return boolean is
    v_error_sufix fflu_common.st_string;
    v_result boolean;
  begin
    v_result := true;
    v_error_sufix := ' For field name [' || i_field_name || '].';
    -- Check the column number.
    if i_column is null then 
      fflu_utils.log_interface_error('Column No','null','Supplied column no cannot be null.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    elsif i_column <= 0 then 
      fflu_utils.log_interface_error('Column No',i_column,'Supplied column no cannot be less than or equal to zero.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    elsif i_column > 4000 then 
      fflu_utils.log_interface_error('Column No',i_column,'Supplied column no cannot be greater than 4000 columns.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    end if;
    -- Check the column name
    if trim(i_field_name) is null then 
      fflu_utils.log_interface_error('Field Name','null','Supplied column name cannot be null.');
      pv_errors := true;
      v_result := false;
    end if;
    return v_result;
  end check_column;
  
  function check_column (
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position, 
    i_length in fflu_common.st_length) return boolean is
    v_error_sufix fflu_common.st_string;
    v_end_position fflu_common.st_position;
    v_result boolean;
  begin
    v_result := true;
    v_error_sufix := ' For field name [' || i_field_name || '].';
    -- Check the column position.
    if i_position is null then 
      fflu_utils.log_interface_error('Position','null','Supplied column position cannot be null.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    elsif i_position <= 0 then 
      fflu_utils.log_interface_error('Position',i_position,'Supplied column position cannot be less than or equal to zero.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    elsif i_position > 4000 then 
      fflu_utils.log_interface_error('Position',i_position,'Supplied column position cannot be greater than 4000.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    end if;
    -- Check the column length.
    if i_length is null then 
      fflu_utils.log_interface_error('Length','null','Supplied column length cannot be null.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    elsif i_length <= 0 then 
      fflu_utils.log_interface_error('Length',i_position,'Supplied column length cannot be less than or equal to zero.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    elsif i_length > 4000 then 
      fflu_utils.log_interface_error('Length',i_position,'Supplied column length cannot be greater than 4000.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    end if;
    -- Now perform a check of the position + length.
    v_end_position := i_position + i_length - 1;
    if v_end_position > 4000 then 
      fflu_utils.log_interface_error('End Position',v_end_position,'Calculated end position cannot be greater than 4000.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    end if;
    -- Check the column name
    if trim(i_field_name) is null then 
      fflu_utils.log_interface_error('Field Name','null','Supplied field name cannot be null.');
      pv_errors := true;
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
    i_field_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name) return boolean is
    v_result boolean;
    v_error_sufix fflu_common.st_string;
    -- Cursor to check the mars date column name exists.
    cursor csr_check_mars_date_column is
      select column_name from all_tab_columns where table_name = 'MARS_DATE' and data_type = 'NUMBER' and column_name = upper(i_mars_date_column);
    v_column_name fflu_common.st_name;
  begin
    v_result := true;
    v_error_sufix := ' For column name [' || i_field_name || '].';
    -- Check the mars date column name
    if i_mars_date_column is null then 
      fflu_utils.log_interface_error('Mars Date Column','null','Supplied mars date column name cannot be null.' || v_error_sufix);
      pv_errors := true;
      v_result := false;
    else 
      -- Check the mars date column exists.
      open csr_check_mars_date_column;
      fetch csr_check_mars_date_column into v_column_name;
      if csr_check_mars_date_column%notfound = true then 
        fflu_utils.log_interface_error('Mars Date Column',i_mars_date_column,'Supplied mars date column did not exist in the mars date table.' || v_error_sufix);
        pv_errors := true;
        v_result := false;
      end if;
      close csr_check_mars_date_column;
    end if;
    return v_result;
  end check_mars_date_column;

/*******************************************************************************
  NAME:      CHECK_OFFSET
  PURPOSE:   Checks that supplied offset information is valid and correct. 
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-07-19 Chris Horn           Created
  
*******************************************************************************/
  function check_offset(
    i_field_name in fflu_common.st_name,
    i_offset in fflu_common.st_position default null,
    i_offset_len in fflu_common.st_length default null) return boolean is
    v_result boolean;
    v_error_sufix fflu_common.st_string;
    v_column_name fflu_common.st_name;
    v_end_position fflu_common.st_position;
  begin
    v_result := true;
    v_error_sufix := ' For column name [' || i_field_name || '].';
    -- Check that if off set are being used then the lenght must be specified.
    if i_offset is not null then 
      if i_offset <= 0 then 
        fflu_utils.log_interface_error('Offset',i_offset,'Supplied column offset cannot be less than or equal to zero.' || v_error_sufix);
        pv_errors := true;
        v_result := false;
      elsif i_offset > 4000 then 
        fflu_utils.log_interface_error('Offset',i_offset,'Supplied column offset cannot be greater than 4000.' || v_error_sufix);
        pv_errors := true;
        v_result := false;
      end if;
      if i_offset_len is null then 
        fflu_utils.log_interface_error('Offset Len','null','Supplied column offset length cannot be null when an offset has been defined.' || v_error_sufix);
        pv_errors := true;
        v_result := false;
      else
        if i_offset_len <= 0 then 
          fflu_utils.log_interface_error('Offset Len',i_offset_len,'Supplied column offset length cannot be less than or equal to zero.' || v_error_sufix);
          pv_errors := true;
          v_result := false;
        elsif i_offset_len > 4000 then 
          fflu_utils.log_interface_error('Offset Len',i_offset_len,'Supplied column offset length cannot be greater than 4000.' || v_error_sufix);
          pv_errors := true;
          v_result := false;
        end if;
        -- Now perform a check of the offset + offset_length
        v_end_position := i_offset + i_offset_len - 1;
        if v_end_position > 4000 then 
          fflu_utils.log_interface_error('Offset End Position',v_end_position,'Calculated offset end position cannot be greater than 4000.' || v_error_sufix);
          pv_errors := true;
          v_result := false;
        end if;
      end if;
    end if;
    -- Check the column length.
    return v_result;
  end check_offset;

       


/*******************************************************************************
  NAME:      INITIALISE                                                   PUBLIC
*******************************************************************************/  
  procedure initialise(
    i_filetype in fflu_common.st_filetype,
    i_csv_qualifier in fflu_common.st_qualifier default null,
    i_csv_header in boolean default gc_no_csv_header, 
    i_allow_missing in boolean default gc_not_allow_missing) is
  begin
    pv_initialised := true;
    pv_errors := false;
    pv_filetype := trim(i_filetype);
    -- Check if the supplied file type was null
    if pv_filetype is null then 
      fflu_utils.log_interface_error(
        'File Type',i_filetype,'Data Parsing was initialised with a null file type.'); 
      pv_errors := true;
      pv_errors := true;
      pv_initialised := false;
    else
      -- Check if the supplied file type was unknown.
      if pv_filetype not in (fflu_common.gc_file_type_csv, fflu_common.gc_file_type_fixed_width) then 
        fflu_utils.log_interface_error(
          'File Type',i_filetype,'Data Parsing was initialised with an unknown file type.'); 
        pv_errors := true;
        pv_errors := true;
        pv_initialised := false;
      end if;
    end if;
    -- Now check the csv qualifier which is optionally supplied.
    pv_csv_qualifier := i_csv_qualifier;
    if pv_csv_qualifier is not null then
      if pv_csv_qualifier not in (fflu_common.gc_csv_qualifier_single_quote,fflu_common.gc_csv_qualifier_double_quote) then
        fflu_utils.log_interface_error(
          'CSV Qualifier',i_csv_qualifier,'Data Parsing was supplied with a csv qualifer that was unknown.');
        pv_errors := true;
        pv_initialised := false;
      end if;
    end if;
    if pv_filetype = fflu_common.gc_file_type_csv then
      pv_csv_header := i_csv_header;
    else
      pv_csv_header := false;
    end if;
    pv_allow_missing := i_allow_missing;
    pv_have_parsed := false;
    -- Make sure interface progress has been called at least once.
    fflu_utils.log_interface_progress;
  end initialise;


/*******************************************************************************
  NAME:      ADD_RECORD_TYPE                                              PUBLIC
*******************************************************************************/  
  procedure add_record_type_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_record_type in fflu_common.st_string) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_column) = true and check_filetype_is_csv(i_field_name) = true then 
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_record;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.record_type := i_record_type;
      rv_field.allow_null := false;
      rv_field.trim_column := false; 
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception
    when others then 
      fflu_utils.log_interface_error('Data Parser - Add Record Type Error',sqlcode,sqlerrm);
      pv_errors := true;
  end add_record_type_csv;

  procedure add_record_type_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_record_type in fflu_common.st_string) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_position,i_length) = true and check_filetype_is_fixed_width(i_field_name) = true then
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_record;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.record_type := i_record_type;
      rv_field.allow_null := false;
      rv_field.trim_column := false;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Record Type');
      pv_errors := true;
  end add_record_type_txt;

/*******************************************************************************
  NAME:      ADD_CHAR_FIELD                                               PUBLIC
*******************************************************************************/  
  procedure add_char_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_min_length in fflu_common.st_size default null,
    i_max_length in fflu_common.st_size default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_trim in boolean default gc_not_trim
    ) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_column) = true and check_filetype_is_csv(i_field_name) = true then 
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
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
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Char Field');
      pv_errors := true;
  end add_char_field_csv;
  
  procedure add_char_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_min_length in fflu_common.st_size default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_trim in boolean default gc_trim) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_position,i_length) = true and check_filetype_is_fixed_width(i_field_name) = true then
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_char;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.min_len := i_min_length;
      rv_field.max_len := i_length;
      rv_field.allow_null := i_allow_null;
      rv_field.trim_column := i_trim;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Char Field');
      pv_errors := true;
  end add_char_field_txt;
  
/*******************************************************************************
  NAME:      ADD_NUMBER_FIELD                                             PUBLIC
*******************************************************************************/  
  procedure add_number_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column, 
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_column) = true and check_filetype_is_csv(i_field_name) = true then 
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
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
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Number Field');
      pv_errors := true;    
  end add_number_field_csv;

  procedure add_number_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_position,i_length) = true and check_filetype_is_fixed_width(i_field_name) = true then
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_number;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.min_number := i_min_number;
      rv_field.max_number := i_max_number;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Number Field');
      pv_errors := true;
  end add_number_field_txt;
  
  
/*******************************************************************************
  NAME:      ADD_DATE_FIELD                                               PUBLIC
*******************************************************************************/  
  procedure add_date_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_offset in fflu_common.st_position default null,
    i_offset_len in fflu_common.st_length default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_column) = true and 
      check_filetype_is_csv(i_field_name) = true and check_offset(i_field_name,i_offset,i_offset_len) = true then 
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_date;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.format := i_format;
      rv_field.offset := i_offset;
      rv_field.offset := i_offset_len;  
      rv_field.min_date := i_min_date;
      rv_field.max_date := i_max_date;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Date Field');
      pv_errors := true;    
  end add_date_field_csv;
    
  procedure add_date_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_format in fflu_common.st_name default null,
    i_min_date in date default null, 
    i_max_date in date default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_position,i_length) = true and check_filetype_is_fixed_width(i_field_name) = true then
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_date;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.format := i_format;
      rv_field.min_date := i_min_date;
      rv_field.max_date := i_max_date;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Date Field');
      pv_errors := true;
  end add_date_field_txt;

/*******************************************************************************
  NAME:      ADD_MARS_DATE_FIELD                                          PUBLIC 
*******************************************************************************/  
  procedure add_mars_date_field_csv(
    i_field_name in fflu_common.st_name,
    i_column in fflu_common.st_column,
    i_column_name in fflu_common.st_name,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_offset in fflu_common.st_position default null,
    i_offset_len in fflu_common.st_length default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_column) = true and check_filetype_is_csv(i_field_name) = true
        and check_mars_date_column(i_field_name, i_mars_date_column) = true and check_offset(i_field_name,i_offset,i_offset_len) = true then 
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_mars_date;
      rv_field.column_no := i_column;
      rv_field.column_name := i_column_name;
      rv_field.format := i_format;
      rv_field.offset := i_offset;
      rv_field.offset_len := i_offset_len; 
      rv_field.min_number := i_min_number;
      rv_field.max_number := i_max_number;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      rv_field.mars_date_column := i_mars_date_column;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Mars Date Field');
      pv_errors := true;
  end add_mars_date_field_csv;

  procedure add_mars_date_field_txt(
    i_field_name in fflu_common.st_name,
    i_position in fflu_common.st_position,
    i_length in fflu_common.st_length,
    i_mars_date_column in fflu_common.st_name,
    i_format in fflu_common.st_name default null,
    i_min_number in number default null, 
    i_max_number in number default null,
    i_allow_null in boolean default gc_not_allow_null,
    i_nls_options in varchar2 default null) is
    rv_field rt_field;
  begin
    -- Check system is initialised and column definition is valid.
    if check_initialised = true and check_column(i_field_name,i_position,i_length) = true and check_filetype_is_fixed_width(i_field_name) = true
      and check_mars_date_column(i_field_name, i_mars_date_column) = true  then 
      -- Setup the field definition.
      rv_field.field_name := i_field_name;
      rv_field.field_type := pc_field_type_mars_date;
      rv_field.position := i_position;
      rv_field.len := i_length;
      rv_field.format := i_format;
      rv_field.min_number := i_min_number;
      rv_field.max_number := i_max_number;
      rv_field.allow_null := i_allow_null;
      rv_field.nls_options := i_nls_options;
      rv_field.mars_date_column := i_mars_date_column;
      -- Now add the field record to the fields collection.
      ptv_fields(ptv_fields.count+1) := rv_field;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Add Mars Date Field');
      pv_errors := true;
  end add_mars_date_field_txt;


/*******************************************************************************
  NAME:      PARSE_DATA                                                   PUBLIC
*******************************************************************************/  
  function parse_data(i_data in fflu_common.st_string) return boolean is
    v_result boolean;
    v_error_count fflu_common.st_size;
    v_data fflu_common.st_string;
    v_data_len fflu_common.st_size;
    type tt_columns is table of fflu_common.st_string index by fflu_common.st_size;
    tv_columns tt_columns;
    
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
    exception 
      when others then 
        fflu_utils.log_interface_exception('Data Parser - Clear Data');
        v_error_count := v_error_count + 1;
        pv_errors := true;
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
          ptv_fields(i_field_no).field_name,ptv_fields(i_field_no).position,
          ptv_fields(i_field_no).len,get_field_value_as_string(i_field_no),i_message);
      end if;
      ptv_fields(i_field_no).error_count := ptv_fields(i_field_no).error_count + 1;
      pv_errors := true;
    exception 
      when others then 
        fflu_utils.log_interface_exception('Data Parser - Log Field Parse Error');
        v_error_count := v_error_count + 1;
        pv_errors := true;
    end log_field_parse_error;
    
    procedure process_field (
      i_field_no in fflu_common.st_size, 
      i_field_data in fflu_common.st_string) is
      v_field_data fflu_common.st_string;
      v_message fflu_common.st_string;
      
      procedure parse_number is
      begin
        -- Perform the actual parse.
        begin
          if ptv_fields(i_field_no).format is not null then 
            if ptv_fields(i_field_no).nls_options is not null then 
              ptv_fields(i_field_no).value_number := to_number(v_field_data,ptv_fields(i_field_no).format,ptv_fields(i_field_no).nls_options);
            else
              ptv_fields(i_field_no).value_number := to_number(v_field_data,ptv_fields(i_field_no).format);
            end if;
          else
            ptv_fields(i_field_no).value_number := to_number(v_field_data);
          end if;
        exception 
          when others then 
            v_message := 'Unable to parse number value [' || v_field_data || ']';
            if ptv_fields(i_field_no).format is not null then 
              v_message := v_message || ' using format [' ||  ptv_fields(i_field_no).format || ']';
              if ptv_fields(i_field_no).nls_options is not null then 
                v_message := v_message || ' and nls options [' ||  ptv_fields(i_field_no).nls_options || ']';
              end if;
            end if;
            v_message := v_message || '. ' || SQLERRM;
            log_field_parse_error(i_field_no,v_message);
        end;
        -- Now perform the additional min max checks.
        if ptv_fields(i_field_no).min_number is not null and ptv_fields(i_field_no).value_number < ptv_fields(i_field_no).min_number then
          log_field_parse_error(i_field_no,'Value needs to be at least ' || ptv_fields(i_field_no).min_number || '.');
        end if;
        if ptv_fields(i_field_no).max_number is not null and ptv_fields(i_field_no).value_number > ptv_fields(i_field_no).max_number then 
          log_field_parse_error(i_field_no,'Value cannot be greater than ' || ptv_fields(i_field_no).max_number || '.');
        end if;
        if ptv_fields(i_field_no).allow_null = false and ptv_fields(i_field_no).value_number is null then 
          log_field_parse_error(i_field_no,'Value field cannot be null.');
        end if;
      exception
        when others then 
          fflu_utils.log_interface_exception('Data Parser - Parse Number');
          v_error_count := v_error_count + 1;
          pv_errors := true;
      end parse_number;
      
      procedure parse_date is 
      begin
        -- Perform the actual parse.
        begin
          if ptv_fields(i_field_no).format is not null then 
            if ptv_fields(i_field_no).nls_options is not null then 
              ptv_fields(i_field_no).value_date := to_date(v_field_data,ptv_fields(i_field_no).format,ptv_fields(i_field_no).nls_options);
            else
              ptv_fields(i_field_no).value_date := to_date(v_field_data,ptv_fields(i_field_no).format);
            end if;
          else
            ptv_fields(i_field_no).value_date := to_date(v_field_data);
          end if;
        exception 
          when others then 
            v_message := 'Unable to parse date value [' || v_field_data || ']';
            if ptv_fields(i_field_no).format is not null then 
              v_message := v_message || ' using format [' ||  ptv_fields(i_field_no).format || ']';
              if ptv_fields(i_field_no).nls_options is not null then 
                v_message := v_message || ' and nls options [' ||  ptv_fields(i_field_no).nls_options || ']';
              end if;
            end if;
            v_message := v_message || '. ' || SQLERRM;
            log_field_parse_error(i_field_no,v_message);
        end;
        -- Now perform the additional min max checks.
        if ptv_fields(i_field_no).min_date is not null and ptv_fields(i_field_no).value_date < ptv_fields(i_field_no).min_date then
          log_field_parse_error(i_field_no,'Date needs to be at least ' || ptv_fields(i_field_no).min_date || '.');
        end if;
        if ptv_fields(i_field_no).max_date is not null and ptv_fields(i_field_no).value_date > ptv_fields(i_field_no).max_date then 
          log_field_parse_error(i_field_no,'Date cannot be greater than ' || ptv_fields(i_field_no).max_date || '.');
        end if;
        if ptv_fields(i_field_no).allow_null = false and ptv_fields(i_field_no).value_date is null then 
          log_field_parse_error(i_field_no,'Date field cannot be null.');
        end if;
      exception 
        when others then 
          fflu_utils.log_interface_exception('Data Parser - Parse Date');
          v_error_count := v_error_count + 1;
          pv_errors := true;
      end parse_date;
      
      procedure process_mars_date is 
      begin
        -- Perform the selection of the mars date column into the number variable.
        declare
          v_date date;
          v_mars_date number;
        begin
          v_date := trunc(ptv_fields(i_field_no).value_date);
          execute immediate 'select ' || ptv_fields(i_field_no).mars_date_column || 
            ' from mars_date where calendar_date = :i_value_date'
            into v_mars_date
            using v_date;
          ptv_fields(i_field_no).value_number := v_mars_date;
        exception
          when others then 
            log_field_parse_error(i_field_no,'Unable to lookup mars date column [' || ptv_fields(i_field_no).mars_date_column || '] for date [' || to_char(ptv_fields(i_field_no).value_date,'DD/MM/YYYY') || '] - ' || SQLERRM || '.');
        end;
        -- Now perform some additional checks on the mars date number field.
        if ptv_fields(i_field_no).min_number is not null and ptv_fields(i_field_no).value_number < ptv_fields(i_field_no).min_number then
          log_field_parse_error(i_field_no,'Mars date needs to be at least ' || ptv_fields(i_field_no).min_number || '.');
        end if;
        if ptv_fields(i_field_no).max_number is not null and ptv_fields(i_field_no).value_number > ptv_fields(i_field_no).max_number then 
          log_field_parse_error(i_field_no,'Mars date cannot be greater than ' || ptv_fields(i_field_no).max_number || '.');
        end if;
        if ptv_fields(i_field_no).allow_null = false and ptv_fields(i_field_no).value_number is null then 
          log_field_parse_error(i_field_no,'Mars date value cannot be null.');
        end if;
      exception
        when others then 
          fflu_utils.log_interface_exception('Data Parser - Parse Mars Date');
          v_error_count := v_error_count + 1;
          pv_errors := true;
    end process_mars_date;
      
    begin
      v_field_data := i_field_data;
      -- Check if a trim of the data is required to processing the field.
      if ptv_fields(i_field_no).trim_column = true then 
        v_field_data := trim(v_field_data);
      end if;
      -- Now perform the record type specific processing.
      case ptv_fields(i_field_no).field_type
        -- Parse a record type field.
        when pc_field_type_record then
          if v_field_data = ptv_fields(i_field_no).record_type then 
            ptv_fields(i_field_no).was_parsed := true;
            ptv_fields(i_field_no).value_char := v_field_data;
          else 
            if ptv_fields(i_field_no).allow_null = false and v_field_data is null then 
              log_field_parse_error(i_field_no,'Record type data field cannot be null.');
            end if;
          end if;
        -- Parses a character type field.
        when pc_field_type_char then 
          ptv_fields(i_field_no).was_parsed := true;
          ptv_fields(i_field_no).value_char := v_field_data;
          if ptv_fields(i_field_no).allow_null = false and v_field_data is null then 
            log_field_parse_error(i_field_no,'Character field cannot be null.');
          end if;
          if ptv_fields(i_field_no).min_len is not null and nvl(length(v_field_data),0) < ptv_fields(i_field_no).min_len then
            log_field_parse_error(i_field_no,'Data needs to be at least ' || ptv_fields(i_field_no).min_len || ' characters in length, it was ' || nvl(length(v_field_data),0) || '.');
          end if;
          if ptv_fields(i_field_no).max_len is not null and nvl(length(v_field_data),0) > ptv_fields(i_field_no).max_len then 
            log_field_parse_error(i_field_no,'Data cannot be greater than ' || ptv_fields(i_field_no).max_len || ' characters in length, it was ' || nvl(length(v_field_data),0) || '.');
          end if;
        -- Parse a number field.
        when pc_field_type_number then
          ptv_fields(i_field_no).was_parsed := true;
          parse_number;
        when pc_field_type_date then
          ptv_fields(i_field_no).was_parsed := true;
          parse_date;
        when pc_field_type_mars_date then 
          ptv_fields(i_field_no).was_parsed := true;
          parse_date;
          if ptv_fields(i_field_no).error_count = 0 then 
            process_mars_date;
          end if;
        else
          log_field_parse_error(i_field_no,'Unknown data type was defined, internal Data Parser system error.');
      end case;
    exception 
      when others then 
        fflu_utils.log_interface_exception('Data Parser - Process Field');
        v_error_count := v_error_count + 1;
        pv_errors := true;
    end process_field;

    procedure check_header (
      i_field_no in fflu_common.st_size, 
      i_field_data in fflu_common.st_string) is
    begin
      if ptv_fields(i_field_no).column_name <> i_field_data then 
        log_field_parse_error(i_field_no,'Column no [' || ptv_fields(i_field_no).column_no || ']''s heading [' || i_field_data || '] did not match expected column heading of [' || ptv_fields(i_field_no).column_name || '].');
      end if;
    exception 
      when others then 
        fflu_utils.log_interface_exception('Data Parser - Check Header');
        v_error_count := v_error_count + 1;
        pv_errors := true;
    end check_header;
    
    procedure extract_csv_columns is
      c_delimiter constant fflu_common.st_string := ',';
      v_position fflu_common.st_size;
      v_char fflu_common.st_string;
      v_prev_char fflu_common.st_string;
      v_column fflu_common.st_string;
      v_in_text boolean;
    begin
      v_char := null;
      v_prev_char := null;
      v_position := 0;
      v_column := null;
      v_in_text := false;
      loop 
        v_position := v_position + 1;
        exit when v_position > v_data_len;
        -- Track the current characters.
        v_prev_char := v_char;
        v_char := substr(v_data,v_position,1);
        -- Now process the current data. 
        if v_in_text = true then
          if v_char = pv_csv_qualifier and v_prev_char = pv_csv_qualifier then 
            v_column := v_column || pv_csv_qualifier;
            v_char := null;
          elsif v_char = c_delimiter and v_prev_char = pv_csv_qualifier then 
            v_in_text := false;
            tv_columns(tv_columns.count+1) := v_column;
            v_column := null;
          elsif v_char = pv_csv_qualifier then 
            null;  -- Just ignore for now.
          else 
            v_column := v_column || v_char;
          end if;
        else
          if v_char = c_delimiter then 
            tv_columns(tv_columns.count+1) := v_column;
            v_column := null;
          elsif v_char = pv_csv_qualifier and v_prev_char = c_delimiter then 
            v_in_text := true;
            v_char := null;
          else 
            v_column := v_column || v_char;
          end if;
        end if;
      end loop;
      if nvl(length(v_column),0) > 0 then 
        tv_columns(tv_columns.count+1) := v_column;
      end if;
    exception 
      when others then 
        fflu_utils.log_interface_exception('Data Parser - Extract CSV Columns');
        v_error_count := v_error_count + 1;
        pv_errors := true;
    end extract_csv_columns;

    function extract_fixed_width_field(i_field_no in fflu_common.st_size,o_process_field out boolean) return fflu_common.st_string is
      v_end_position fflu_common.st_size;
      v_result fflu_common.st_string;
    begin
      o_process_field := true;
      v_result := null;
      v_end_position := ptv_fields(i_field_no).position + ptv_fields(i_field_no).len - 1;
      if v_end_position <= v_data_len then 
        v_result := substr(v_data,ptv_fields(i_field_no).position,ptv_fields(i_field_no).len);
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
      return v_result;
    exception 
      when others then 
        fflu_utils.log_interface_exception('Data Parser - Extract Fixed Width Field');
        v_error_count := v_error_count + 1;
        pv_errors := true;
    end extract_fixed_width_field;
    
    function extract_csv_field(i_field_no in fflu_common.st_size,o_process_field out boolean) return fflu_common.st_string is
      v_result fflu_common.st_string;
    begin
      v_result := null;
      o_process_field := true;
      if ptv_fields(i_field_no).column_no <= tv_columns.count then 
        v_result := tv_columns(ptv_fields(i_field_no).column_no);
        -- Now apply any offset that may have been specified for CSV sub field.
        if ptv_fields(i_field_no).offset is not null then 
          v_result := substr(v_result,ptv_fields(i_field_no).offset,ptv_fields(i_field_no).offset_len);
        end if;
      else
        if pv_allow_missing = false then 
          o_process_field := false;
          log_field_parse_error(i_field_no,'CSV line record did not contain a column ' || ptv_fields(i_field_no).column_no || '.');
        end if;
      end if;
      return v_result;
    exception 
      when others then 
        fflu_utils.log_interface_exception('Data Parser - Extract CSV Field');
        v_error_count := v_error_count + 1;
        pv_errors := true;
    end extract_csv_field;
    
    procedure parse_record is
      v_counter fflu_common.st_size;
      v_field fflu_common.st_string;
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
      v_data_len := nvl(length(v_data),0);
      -- If this is a csv file type, then lets extract all the columns first.
      if pv_filetype = fflu_common.gc_file_type_csv then 
        extract_csv_columns;
      end if;
      -- Now process each actual field definition.
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
          if pv_csv_header = true then 
            check_header(v_counter,v_field);
          else
            process_field(v_counter,v_field);
          end if;
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
    exception 
      when others then
        fflu_utils.log_interface_exception('Data Parser - Parse Record');
        v_error_count := v_error_count + 1;
        pv_errors := true;
    end parse_record;
    
  begin
    -- Initialise variables
    v_result := true;
    v_error_count := 0;
    -- Update the log interface progress.
    if mod(lics_inbound_processor.callback_row, 100) = 0 then 
      fflu_utils.log_interface_progress;
    end if;
    -- Now commence the parsing process.
    -- Check if we are initialised
    if check_initialised = true then 
      -- Now clear down the previous parsing results. 
      clear_data();
      -- Now take off the line feed at the end of the line if it exists.
      v_data := i_data;
      v_data_len := nvl(length(v_data),0);
      if v_data_len > 0 then 
        if substr(v_data,v_data_len,1) = chr(10) then 
          v_data := substr(v_data,1,v_data_len-1);
          v_data_len := v_data_len - 1;
        end if;
      end if;
      -- Now perform the parsing
      parse_record();
      pv_have_parsed := true;
      -- Now check the error count.
      if v_error_count > 0 then 
        v_result := false;
      end if;
      -- If this was a csv header record we just checked then now clear that flag for future records.
      if pv_csv_header = true then 
        pv_csv_header := false;
        v_result := false;  -- Always return false for header rows.  A check for was errors can be performed.
      end if;
    else
      -- If the system was uninitilised.
      v_result := false;
    end if;
    return v_result;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Parse Data');
      return false;
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
        pv_errors := true;
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
        if v_field_no is null then 
          fflu_utils.log_interface_data_error(
            null,null,null,'Data parser could not find a successfully parsed record type column.');
          pv_errors := true;
        else 
          -- Now return the record type.
          v_result := ptv_fields(v_field_no).value_char;
        end if;
      end if;
    end if;
    return v_result;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Get Record Type');
      pv_errors := true;
      return null;        
  end get_record_type;

/*******************************************************************************
  NAME:      GET_CHAR_FIELD                                               PUBLIC
*******************************************************************************/  
  function get_char_field(
    i_field_name in fflu_common.st_name) return varchar2 is
    v_field_no fflu_common.st_size;
    v_result fflu_common.st_string;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_field_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_char;
    end if;
    return v_result;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Get Char Field');
      pv_errors := true;
      return null;        
  end get_char_field;

/*******************************************************************************
  NAME:      GET_NUMBER_FIELD                                             PUBLIC
*******************************************************************************/  
  function get_number_field(
    i_field_name in fflu_common.st_name) return number is
    v_field_no fflu_common.st_size;
    v_result number;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_field_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_number;
    end if;
    return v_result;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Get Number Field');
      pv_errors := true;
      return null;    
  end get_number_field;

/*******************************************************************************
  NAME:      GET_DATE_FIELD                                               PUBLIC
*******************************************************************************/  
  function get_date_field(
    i_field_name in fflu_common.st_name) return date is
    v_field_no fflu_common.st_size;
    v_result date;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_field_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_date;
    end if;
    return v_result;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Get Date Field');
      pv_errors := true;
      return null;
  end get_date_field;


/*******************************************************************************
  NAME:      GET_MARS_DATE_FIELD                                          PUBLIC
*******************************************************************************/  
  function get_mars_date_field(
    i_field_name in fflu_common.st_name) return number is
    v_field_no fflu_common.st_size;
    v_result number;
  begin
    v_result := null;
    if check_initialised = true and find_column(i_field_name,v_field_no) = true then
      v_result := ptv_fields(v_field_no).value_number;
    end if;
    return v_result;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Get Mars Date Field');
      pv_errors := true;
      return null;
  end get_mars_date_field;

/*******************************************************************************
  NAME:      LOG_FIELD_ERROR                                              PUBLIC
*******************************************************************************/  
  procedure log_field_error(
    i_field_name in fflu_common.st_name, 
    i_message in fflu_common.st_string) is
    v_field_no fflu_common.st_size;
  begin
    if check_initialised = true and find_column(i_field_name,v_field_no) = true then 
      if pv_filetype = fflu_common.gc_file_type_csv then 
        fflu_utils.log_interface_data_error(
          ptv_fields(v_field_no).column_name,ptv_fields(v_field_no).column_no,get_field_value_as_string(v_field_no),i_message);
      elsif pv_filetype = fflu_common.gc_file_type_fixed_width then 
        fflu_utils.log_interface_data_error(
          ptv_fields(v_field_no).column_name,ptv_fields(v_field_no).position,
          ptv_fields(v_field_no).len,get_field_value_as_string(v_field_no),i_message);
      end if;
      pv_errors := true;
      ptv_fields(v_field_no).error_count := ptv_fields(v_field_no).error_count + 1;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Log Field Error');
      pv_errors := true;
  end log_field_error;

/*******************************************************************************
  NAME:      LOG_FIELD_ERROR                                              PUBLIC
*******************************************************************************/  
  function was_errors return boolean is
  begin
    return pv_errors;
  end was_errors;
  
/*******************************************************************************
  NAME:      LOG_FIELD_ERROR                                              PUBLIC
*******************************************************************************/  
  procedure cleanup is
  begin
    if pv_initialised = true then 
      -- Make sure the interface process has been logged.
      fflu_utils.log_interface_progress;
      -- Now clean up all the package fields.
      pv_initialised := false;
      pv_filetype := null;
      pv_allow_missing := false;
      pv_csv_qualifier := null;
      pv_have_parsed := null;
      pv_errors := false;
      ptv_fields.delete;
    end if;
  exception 
    when others then 
      fflu_utils.log_interface_exception('Data Parser - Cleanup');
  end cleanup;

/*******************************************************************************
  Initialise Package State Variables.
*******************************************************************************/  
begin
  pv_initialised := false;
  pv_filetype := null;
  pv_allow_missing := false;                  
  pv_csv_qualifier := null;
  pv_have_parsed := false;
  pv_errors := false;
  ptv_fields.delete;
  pv_csv_header := false;
end fflu_data;