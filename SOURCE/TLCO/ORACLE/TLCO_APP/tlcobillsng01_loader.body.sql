create or replace package body tlcobillsng01_loader as 

  -- Interface column constants
  pc_call_description2 constant fflu_common.st_name := 'Call Description 2';
  pc_data_usage constant fflu_common.st_name := 'Data Usage';
  pc_payment_amount constant fflu_common.st_name := 'Payment Amount';
  pc_autoroam_operator constant fflu_common.st_name := 'Autoroam Operator';
  pc_call_description1 constant fflu_common.st_name := 'Call Description 1';
  pc_duration constant fflu_common.st_name := 'Duration)';
  pc_call_details constant fflu_common.st_name := 'Call Details';
  pc_terminating_number constant fflu_common.st_name := 'Terminating Number';
  pc_destination constant fflu_common.st_name := 'Destination';
  pc_usage_type constant fflu_common.st_name := 'Usage Type';
  pc_time_of_call constant fflu_common.st_name := 'Time of Call';
  pc_date_of_call constant fflu_common.st_name := 'Date of Call';
  pc_charges constant fflu_common.st_name := 'Charges';
  pc_origin_number constant fflu_common.st_name := 'Originating Number';
  pc_service_type constant fflu_common.st_name := 'Service Type';
  pc_bill_id constant fflu_common.st_name := 'Bill ID';
  pc_account_number constant fflu_common.st_name := 'Account Number';
  pc_bill_date constant fflu_common.st_name := 'Bill Date';  
  
  -- Package variables
  pv_first_row_flag boolean;
  pv_user fflu_common.st_user;
  rpv_initial_values tlco.tlco_bill_raw_sng%rowtype;
 
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_not_allow_missing);
    
    -- Add column structure
    fflu_data.add_char_field_del(pc_call_description2,1,'Call Description2',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_data_usage,2,'Data Usage (kByte)',fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_payment_amount,3,'Payment Amount',fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_autoroam_operator,4,'Autoroam Operator',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_call_description1,5,'Call Description',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_duration,6,'Duration (Min)',fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_call_details,7,'Call Details',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_terminating_number,8,'Terminating Number',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_destination,9,'Destination',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_usage_type,10,'Usage Type',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_time_of_call,11,'Time of Call',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_date_of_call,12,'Date of Call',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_charges,13,'Charges',fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_origin_number,14,'Originating Number',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_service_type,15,'Service Type',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_bill_id,16,'Bill ID',fflu_data.gc_null_min_length,fflu_data.gc_null_max_length,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_account_number,17,'Account Number',fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_del(pc_bill_date,18,'Bill Date','yyyymmdd',fflu_data.gc_null_offset,fflu_data.gc_null_offset_len,fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    
    -- Get user name - MUST be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    
    -- Initialise First Row Flag
    pv_first_row_flag := true;
    
  exception 
    when others then 
      fflu_data.log_interface_exception('On Start');
  end on_start;

  ------------------------------------------------------------------------------
  -- LICS : ON_DATA
  ------------------------------------------------------------------------------
  procedure on_data(p_row in varchar2) is
  
    v_row_status_ok boolean;
    v_current_field fflu_common.st_name;
    
    rv_insert_values tlco.tlco_bill_raw_sng%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
            
      -- Set insert row columns
      begin
        -- Assign Call Description2
        v_current_field := pc_call_description2;
        rv_insert_values.call_description2 := fflu_data.get_char_field(pc_call_description2);
        -- Assign Data Usage (kByte)
        v_current_field := pc_data_usage;
        rv_insert_values.data_usage := fflu_data.get_number_field(pc_data_usage);
        -- Assign Payment Amount
        v_current_field := pc_payment_amount;
        rv_insert_values.payment_amount := fflu_data.get_number_field(pc_payment_amount);
        -- Assign Autoroam Operator
        v_current_field := pc_autoroam_operator;
        rv_insert_values.autoroam_operator := fflu_data.get_char_field(pc_autoroam_operator);
        -- Assign Call Description
        v_current_field := pc_call_description1;
        rv_insert_values.call_description1 := fflu_data.get_char_field(pc_call_description1);
        -- Assign Duration (Min)
        v_current_field := pc_duration;
        rv_insert_values.duration := fflu_data.get_number_field(pc_duration);
        -- Assign Call Details
        v_current_field := pc_call_details;
        rv_insert_values.call_details := fflu_data.get_char_field(pc_call_details);
        -- Assign Terminating Number
        v_current_field := pc_terminating_number;
        rv_insert_values.terminating_number := fflu_data.get_char_field(pc_terminating_number);
        -- Assign Destination
        v_current_field := pc_destination;
        rv_insert_values.destination := fflu_data.get_char_field(pc_destination);
        -- Assign Usage Type
        v_current_field := pc_usage_type;
        rv_insert_values.usage_type := fflu_data.get_char_field(pc_usage_type);
        -- Assign Time of Call
        v_current_field := pc_time_of_call;
        rv_insert_values.time_of_call := fflu_data.get_char_field(pc_time_of_call);
        -- Assign Date of Call
        v_current_field := pc_date_of_call;
        rv_insert_values.date_of_call := fflu_data.get_char_field(pc_date_of_call);
        -- Assign Charges
        v_current_field := pc_charges;
        rv_insert_values.charges := fflu_data.get_number_field(pc_charges);
        -- Assign Originating Number
        v_current_field := pc_origin_number;
        rv_insert_values.origin_number := fflu_data.get_char_field(pc_origin_number);
        -- Assign Service Type
        v_current_field := pc_service_type;
        rv_insert_values.service_type := fflu_data.get_char_field(pc_service_type);
        -- Assign Bill ID
        v_current_field := pc_bill_id;
        rv_insert_values.bill_id := fflu_data.get_char_field(pc_bill_id);
        -- Assign Account Number
        v_current_field := pc_account_number;
        rv_insert_values.account_number := fflu_data.get_number_field(pc_account_number);
        -- Assign Bill Date
        v_current_field := pc_bill_date;
        rv_insert_values.bill_date := fflu_data.get_date_field(pc_bill_date);

        -- Default Columns .. Added to ALL Tables
        -- Last Update User
        v_current_field := 'Last Update User';        
        rv_insert_values.last_update_user := pv_user;
        -- Last Update Date
        v_current_field := 'Last Update Date';        
        rv_insert_values.last_update_date := sysdate;
      exception
        when others then
          v_row_status_ok := false;
          fflu_data.log_field_exception(v_current_field, 'Field Assignment Error');
      end;
      
      -- "Replace Key" processing
      if pv_first_row_flag = true then
        pv_first_row_flag := false;
        
        -- Take initial copy of "Replace Key"
        rpv_initial_values.bill_id := rv_insert_values.bill_id;

        -- Delete on "Replace Key"
        delete from tlco.tlco_bill_raw_sng
        where bill_id = rpv_initial_values.bill_id;

      else -- Check that "Replace Key" remains consistient
      
        if rpv_initial_values.bill_id != rv_insert_values.bill_id then
          v_row_status_ok := false;
          fflu_data.log_field_error(pc_bill_id, 'Replace Key Value Inconsistient');
        end if;

      end if;
      
      -- Insert row, if row status is ok 
      if v_row_status_ok = true then 
        insert into tlco.tlco_bill_raw_sng values rv_insert_values;
      end if;   
      
    end if;
  exception 
    when others then 
      fflu_data.log_interface_exception('On Data');
  end on_data;
  
  ------------------------------------------------------------------------------
  -- LICS : ON_END
  ------------------------------------------------------------------------------
  procedure on_end is 
  begin 
    -- Only perform a commit if there were no errors at all 
    if fflu_data.was_errors = true then 
      rollback;
    else 
      commit;
    end if;
    -- Perform a final cleanup and a last progress logging
    fflu_data.cleanup;
  exception 
    when others then 
      fflu_data.log_interface_exception('On End');
      rollback;
  end on_end;

  ------------------------------------------------------------------------------
  -- FFLU : ON_GET_FILE_TYPE
  ------------------------------------------------------------------------------
  function on_get_file_type return varchar2 is 
  begin 
    return fflu_common.gc_file_type_csv;
  end on_get_file_type;

  ------------------------------------------------------------------------------
  -- FFLU : ON_GET_CSV_QUALIFER
  ------------------------------------------------------------------------------
  function on_get_csv_qualifier return varchar2 is
  begin 
    return fflu_common.gc_csv_qualifier_double_quote;
  end on_get_csv_qualifier;

end tlcobillsng01_loader;

