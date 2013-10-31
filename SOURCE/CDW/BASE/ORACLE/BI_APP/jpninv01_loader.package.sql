create or replace package jpninv01_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app
    Package   : jpninv01_loader
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [jpninv01] Japan Inventory - Target Days Cover
    [replace_all] Template
    
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
    2013-10-31  Trevor Keon           [Auto Generated]
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end jpninv01_loader;
/

create or replace package body jpninv01_loader as 

  -- Interface column constants
  pc_matl_code constant fflu_common.st_name := 'Material Code';
  pc_plant_code constant fflu_common.st_name := 'Plant Code';
  pc_target_days_cover constant fflu_common.st_name := 'Target Days Cover';  
  
  -- Package variables
  pv_user fflu_common.st_user;
 
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_not_allow_missing);
    
    -- Add column structure
    fflu_data.add_char_field_del(pc_matl_code,1,'Material code',1,100,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_plant_code,2,'Location',1,100,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_target_days_cover,3,'target days cover','99999990',1,9999,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    
    -- Get user name - MUST be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    
    -- Delete previous table entries
    delete from bi.japan_target_days_cover;
    
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
    
    rv_insert_values bi.japan_target_days_cover%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
      
      -- Set insert row columns
      begin
        -- Assign Material Code
        v_current_field := pc_matl_code;
        rv_insert_values.matl_code := fflu_data.get_char_field(pc_matl_code);
        -- Assign Plant Code
        v_current_field := pc_plant_code;
        rv_insert_values.plant_code := fflu_data.get_char_field(pc_plant_code);
        -- Assign Target Days Cover
        v_current_field := pc_target_days_cover;
        rv_insert_values.target_days_cover := fflu_data.get_number_field(pc_target_days_cover);

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
      
      -- Insert row, if row status is ok 
      if v_row_status_ok = true then 
        insert into bi.japan_target_days_cover values rv_insert_values;
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
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;

end jpninv01_loader;
/

grant execute on jpninv01_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
