create or replace package comfod01_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app
    Package   : comfod01_loader
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [comfod01] Commercial - Food - Supplier Settings
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
    2013-09-10  Trevor Keon           [Auto Generated]
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end comfod01_loader;
/

create or replace package body comfod01_loader as 

  -- Interface column constants
  pc_supplier constant fflu_common.st_name := 'Supplier Code';
  pc_is_push constant fflu_common.st_name := 'Push Supplier Indicator'; 
  
  -- Package variables
  pv_user fflu_common.st_user;
  
  -- Package constants
  pc_bus_sgmnt_value constant bi.com_supplier_settings.bus_sgmnt%type := '02';
 
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_not_allow_missing);
    
    -- Add column structure
    fflu_data.add_char_field_del(pc_supplier,1,'Supplier',1,32,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_is_push,2,'Push',1,10,fflu_data.gc_allow_null,fflu_data.gc_not_trim);   
    
    -- Get user name - MUST be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    
    -- Delete previous table entries
    delete from bi.com_supplier_settings
    where bus_sgmnt = pc_bus_sgmnt_value;
    
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
    
    rv_insert_values bi.com_supplier_settings%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
      
      -- Set insert row columns
      begin
        -- Assign Supplier Code
        v_current_field := pc_supplier;
        rv_insert_values.supplier := initcap(trim(fflu_data.get_char_field(pc_supplier)));

--        if ods_master_data_validation.check_vendor(initcap(fflu_data.get_char_field(pc_supplier))) = false then      
--           fflu_data.log_field_error(pc_supplier, 'The provided value [' || initcap(fflu_data.get_char_field(pc_supplier)) || '] is not a valid supplier.');
--           v_row_status_ok := false;
--        else
--           rv_insert_values.supplier := fflu_data.get_char_field(pc_supplier);
--        end if;
        
        -- Assign Push Supplier Indicator
        v_current_field := pc_is_push;
        rv_insert_values.is_push := fflu_data.get_char_field(pc_is_push);

        -- Add default value for Chocolate business segment
        rv_insert_values.bus_sgmnt := pc_bus_sgmnt_value;

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
        insert into bi.com_supplier_settings values rv_insert_values;
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

end comfod01_loader;
/

grant execute on comfod01_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
