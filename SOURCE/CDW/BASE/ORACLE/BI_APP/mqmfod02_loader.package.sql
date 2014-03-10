create or replace package mqmfod02_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app
    Package   : mqmfod02_loader
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [mqmfod02] MQM Scorecard - Food - Audit Results
    [replace_on_key] Template
    
    Functions
    ----------------------------------------------------------------------------
    + LICS Hooks 
      - on_start                   Called on starting the interface.
      - on_data(i_row in varchar2) Called for each row of data in the interface.
      - on_end                     Called at the end of processing.
    + FFLU Hooks
      - on_get_file_type           Returns the type of file format expected.
      - on_get_csv_qualifier       Returns the CSV file format qualifier.  
  
    Date        Author                Description
    ----------  --------------------  ------------------------------------------
    2014-02-05  Trevor Keon           [Auto Generated] 
    2014-02-18  Trevor Keon           Added additional fields 
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end mqmfod02_loader;
/

create or replace package body mqmfod02_loader as 

  -- Interface column constants
  pc_supplier constant fflu_common.st_name := 'Supplier Code';
  pc_audit_score constant fflu_common.st_name := 'Audit Score';
  pc_audit_date constant fflu_common.st_name := 'Audit Date';
  pc_activity_status constant fflu_common.st_name := 'Activity Status';
  pc_status constant fflu_common.st_name := 'Status';
  pc_last_status_change constant fflu_common.st_name := 'Last Status Change';
  pc_auditor constant fflu_common.st_name := 'Auditor';
  pc_critical constant fflu_common.st_name := '# of critical non-conformance';
  pc_major constant fflu_common.st_name := '# of major non-conformance';
  pc_minor constant fflu_common.st_name := '# of minor non-conformance';  
  
  -- Package variables
  pv_first_row_flag boolean;
  pv_user fflu_common.st_user;
  prv_initial_values bi.mqm_audit_result%rowtype;
 
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_not_allow_missing);
    
    -- Add column structure
    fflu_data.add_char_field_del(pc_supplier,1,'Supplier',1,500,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_audit_score,2,'Audit Score',1,10,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_date_field_del(pc_audit_date, 3, 'Audit Date', 'dd/mm/yyyy', fflu_data.gc_null_offset, fflu_data.gc_null_offset_len, fflu_data.gc_null_min_date, fflu_data.gc_null_max_date, fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_del(pc_activity_status, 4, 'Activity Status',0,100,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_status, 5, 'Status',0,4,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_date_field_del(pc_last_status_change, 6, 'Last Status Change', 'dd/mm/yyyy', fflu_data.gc_null_offset, fflu_data.gc_null_offset_len, fflu_data.gc_null_min_date, fflu_data.gc_null_max_date, fflu_data.gc_allow_null);
    fflu_data.add_char_field_del(pc_auditor, 7, 'Auditor',0,50,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_critical,8,'Critical NC','99999990',0,99999999,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_major,9,'Major NC','99999990',0,99999999,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_minor,10,'Minor NC','99999990',0,99999999,fflu_data.gc_allow_null,fflu_data.gc_null_nls_options);
    
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
    
    rv_insert_values bi.mqm_audit_result%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
            
      -- Set insert row columns
      begin
        -- Assign Supplier Description
        v_current_field := pc_supplier;
        rv_insert_values.supplier := trim(fflu_data.get_char_field(pc_supplier));
        -- Assign Audit Score
        v_current_field := pc_audit_score;
        rv_insert_values.audit_score := trim(fflu_data.get_char_field(pc_audit_score));
        -- Assign Audit date
        v_current_field := pc_audit_date;
        rv_insert_values.audit_date := fflu_data.get_date_field(pc_audit_date);
        -- Assign Activity Status
        v_current_field := pc_activity_status;
        rv_insert_values.activity_status := trim(fflu_data.get_char_field(pc_activity_status));
        -- Assign Status
        v_current_field := pc_status;
        rv_insert_values.status := trim(fflu_data.get_char_field(pc_status));        
        -- Assign Last Status change 
        v_current_field := pc_last_status_change;
        rv_insert_values.last_status_change := fflu_data.get_date_field(pc_last_status_change);        
        -- Assign Auditor 
        v_current_field := pc_auditor;
        rv_insert_values.auditor := trim(fflu_data.get_char_field(pc_auditor));        
        -- Assign # of critical non-conformance
        v_current_field := pc_critical;
        rv_insert_values.critical := fflu_data.get_number_field(pc_critical);
        -- Assign # of major non-conformance
        v_current_field := pc_major;
        rv_insert_values.major := fflu_data.get_number_field(pc_major);
        -- Assign # of minor non-conformance
        v_current_field := pc_minor;
        rv_insert_values.minor := fflu_data.get_number_field(pc_minor);

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
      
      delete from bi.mqm_audit_result
      where supplier = rv_insert_values.supplier
         and audit_date = rv_insert_values.audit_date;      
      
      -- Insert row, if row status is ok 
      if v_row_status_ok = true then 
        insert into bi.mqm_audit_result values rv_insert_values;
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

end mqmfod02_loader;
/

grant execute on mqmfod02_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
