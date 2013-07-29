create or replace 
package body fflu_utils as
/*******************************************************************************
  NAME:      LOG_INTERFACE_PROGRESS                                       PUBLIC
*******************************************************************************/  
  procedure log_interface_progress is
    pragma autonomous_transaction;
    v_sequence fflu_common.st_sequence;
    cursor csr_xaction_writeback is select user_code from fflu_xaction_writeback where
      lics_header_seq = lics_inbound_processor.callback_header;
    v_user_code fflu_common.st_user;
  begin
    -- Get the sequence number for the current interface. Only insert a record 
    -- if the sequence is defined.  
    v_sequence := lics_inbound_processor.callback_header;
    if v_sequence is not null then 
      -- Check if there is a user code waiting in the writeback table for processing.
      open csr_xaction_writeback;
      fetch csr_xaction_writeback into v_user_code;
      if csr_xaction_writeback%found then 
        update lics_hdr_trace set het_user = v_user_code 
        where het_header = lics_inbound_processor.callback_header and 
          het_hdr_trace = lics_inbound_processor.callback_trace;
        delete from fflu_xaction_writeback where lics_header_seq = lics_inbound_processor.callback_header;
      end if;
      close csr_xaction_writeback;
      -- Now update the progress.    
      update fflu_xaction_progress 
        set 
          dat_seq = nvl(lics_inbound_processor.callback_row,0), 
          last_updtd_time = sysdate
        where lics_header_seq = v_sequence;
      if SQL%Rowcount = 0 then 
        -- If there was nothing updated then insert the record instead.  Also calculate the total number of rows on this first insert so that we can calculate a percentage complete.
        insert into fflu_xaction_progress (
          lics_header_seq,dat_count,dat_seq,last_updtd_time
        ) values (
          v_sequence, (select count(t0.DAT_DTA_SEQ) from lics_data t0 where t0.DAT_HEADER = v_sequence), nvl(lics_inbound_processor.callback_row,0), sysdate);
      end if;
      -- Now commit the progress update.
      commit;
    end if;
  exception
    when others then 
      lics_inbound_utility.add_exception(fflu_common.sqlerror_string('Exception whilst logging interface progress.'));
  end log_interface_progress;
  
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
  function escape_json_string(i_string in fflu_common.st_buffer) return fflu_common.st_buffer is
    v_string fflu_common.st_buffer;
  begin
    v_string := regexp_replace(i_string,'[[:space:]]*$',' '); --  \n \t \f \r \v
    v_string := replace(v_string,'\','\\');
    v_string := replace(v_string,'/','\/');
    v_string := replace(v_string,'''','\''');
    v_string := replace(v_string,'"','\"');
    v_string := replace(v_string,'' || chr(7) || '',' ');
    v_string := trim(v_string);
    return v_string;
  end escape_json_string;

/*******************************************************************************
  NAME:      JSON_NUMBER
  PURPOSE:   This function takes a number and represents it as null or its
             corresponding number.
             
  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-06-18 Chris Horn           Created
  
*******************************************************************************/   
  function json_number(i_number in number) return fflu_common.st_buffer is
    v_string fflu_common.st_buffer;
  begin
    if i_number is null then 
      v_string := 'null';
    else 
      v_string := '' || i_number;
    end if;
    return v_string;
  end json_number;
  
/*******************************************************************************
  NAME:      LOG_INTERFACE_ERROR                                          PUBLIC
*******************************************************************************/  
  procedure log_interface_error(
    i_label fflu_common.st_buffer,    -- Label, specific for interface. 
    i_value fflu_common.st_buffer,    -- Value that is relevant at interface.
    i_message fflu_common.st_buffer) is -- The actual error message.
    v_lics_message fflu_common.st_buffer;
    v_label fflu_common.st_buffer;
    v_value fflu_common.st_buffer;
    v_message fflu_common.st_buffer;
  begin
    v_label := i_label;
    v_value := i_value;
    v_message := i_message;
    -- Now construct the string.  
    loop
      v_lics_message := '{"label":"' ||escape_json_string(v_label) ||'","value":"'||escape_json_string(v_value)||'","message":"'||escape_json_string(v_message)||'"}';
      exit when lengthb(v_lics_message) <= 4000;
      -- Use a brute force approach to truncating the message keeping some of each part.
      if lengthb(v_message) > 1000 then
        v_message := substr(v_message,1,length(v_message)-1);
      elsif length(v_value) > 1000 then 
        v_value := substr(v_value,1,length(v_value)-1);
      elsif length(v_label) > 100 then
        v_label := substr(v_label,1,length(v_label)-1);
      end if;
    end loop;
    -- Now add the exception message.
    lics_inbound_utility.add_exception(v_lics_message);
  end log_interface_error;
  
/*******************************************************************************
  NAME:      LOG_INTERFACE_PROGRESS                                       PUBLIC
*******************************************************************************/  
  procedure log_interface_data_error (
    i_label fflu_common.st_buffer,    -- Label, specific for interface. 
    i_column fflu_common.st_column,   -- Char Position for Fixed With, Column for CSV 
    i_value fflu_common.st_buffer,    -- The value found or not found if null. 
    i_message fflu_common.st_buffer) is -- The actual error message.
    v_lics_message fflu_common.st_buffer;
    v_label fflu_common.st_buffer;
    v_value fflu_common.st_buffer;
    v_message fflu_common.st_buffer;
  begin
    v_label := i_label;
    v_value := i_value;
    v_message := i_message;
    -- Now construct the string.  
    loop
      v_lics_message := '{"label":"' ||escape_json_string(v_label) ||'","column":' || json_number(i_column) || ',"value":"'||escape_json_string(v_value)||'","message":"'||escape_json_string(v_message)||'"}';
      exit when lengthb(v_lics_message) <= 4000;
      -- Use a brute force approach to truncating the message keeping some of each part.
      if lengthb(v_message) > 1000 then
        v_message := substr(v_message,1,length(v_message)-1);
      elsif length(v_value) > 1000 then 
        v_value := substr(v_value,1,length(v_value)-1);
      elsif length(v_label) > 100 then
        v_label := substr(v_label,1,length(v_label)-1);
      end if;
    end loop;
    -- Now add the exception message.
    lics_inbound_utility.add_exception(v_lics_message);  
  end log_interface_data_error;

/*******************************************************************************
  NAME:      LOG_INTERFACE_DATA_ERROR                                     PUBLIC
*******************************************************************************/  
  procedure log_interface_data_error (
    i_label fflu_common.st_buffer,    -- Label, specific for interface. 
    i_position fflu_common.st_position,   -- Char Position for Fixed With, Column for CSV 
    i_length fflu_common.st_length,     -- The length of the field.
    i_value fflu_common.st_buffer,    -- The value found or not found if null. 
    i_message fflu_common.st_buffer) is -- The actual error message.
    v_lics_message fflu_common.st_string;
    v_label fflu_common.st_buffer;
    v_value fflu_common.st_buffer;
    v_message fflu_common.st_buffer;
  begin
    v_label := i_label;
    v_value := i_value;
    v_message := i_message;
    -- Now construct the string.  
    loop
      v_lics_message := '{"label":"' ||escape_json_string(v_label) ||'","position":' || json_number(i_position) || ',"length":' || json_number(i_length) || ',"value":"'||escape_json_string(v_value)||'","message":"'||escape_json_string(v_message)||'"}';
      exit when nvl(lengthb(v_lics_message),0) <= 4000;
      -- Use a brute force approach to truncating the message keeping some of each part.
      if lengthb(v_message) > 1000 then
        v_message := substr(v_message,1,length(v_message)-1);
      elsif length(v_value) > 1000 then 
        v_value := substr(v_value,1,length(v_value)-1);
      elsif length(v_label) > 100 then
        v_label := substr(v_label,1,length(v_label)-1);
      end if;
    end loop;
    -- Now add the exception message.
    lics_inbound_utility.add_exception(v_lics_message);
  end log_interface_data_error;
  
/*******************************************************************************
  NAME:      LOG_INTERFACE_ERROR                                          PUBLIC
*******************************************************************************/  
  procedure log_interface_exception (
    i_method fflu_common.st_buffer) is
  begin
    log_interface_error('Method',i_method,'EXCEPTION : ' || SQLERRM);
  end log_interface_exception;
  
/*******************************************************************************
  NAME:      GET_INTERFACE_SUFFIX                                         PUBLIC
*******************************************************************************/  
  function get_interface_suffix return fflu_common.st_interface is
    v_suffix fflu_common.st_interface;
    v_pos fflu_common.st_size;
  begin
    v_suffix := lics_inbound_processor.callback_interface;
    v_suffix := substr(v_suffix,instr(v_suffix,'.')+1);
    return v_suffix;
  end get_interface_suffix;
  
/*******************************************************************************
  NAME:      GET_INTERFACE_FILENAME                                       PUBLIC
*******************************************************************************/  
  function get_interface_filename return fflu_common.st_filename is
  begin
    return lics_inbound_processor.callback_file_name; 
  end get_interface_filename;
  
/*******************************************************************************
  NAME:      GET_INTERFACE_ROW                                            PUBLIC
*******************************************************************************/  
  function get_interface_row return fflu_common.st_count is
  begin
    return lics_inbound_processor.callback_row;
  end get_interface_row;

/*******************************************************************************
  NAME:      GET_INTERFACE_ROW                                            PUBLIC
*******************************************************************************/  
  function get_interface_user return fflu_common.st_user is
  begin
    null;
  end get_interface_user;
  
end fflu_utils;