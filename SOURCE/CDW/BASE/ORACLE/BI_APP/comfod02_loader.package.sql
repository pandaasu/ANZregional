create or replace package comfod02_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app
    Package   : comfod02_loader
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [comfod02] Commercial - Food - DIFOT Overwrite
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
    2013-09-10  Trevor Keon           [Auto Generated]
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end comfod02_loader;
/

create or replace package body comfod02_loader as 

  -- Interface column constants
  pc_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_supplier constant fflu_common.st_name := 'Supplier';
  pc_difot_value constant fflu_common.st_name := 'DIFOT overwrite value';
  pc_update_user constant fflu_common.st_name := 'Update user'; 
  pc_user_comment constant fflu_common.st_name := 'User comment';      
  
  -- Package variables
  pv_first_row_flag boolean;
  pv_user fflu_common.st_user;

  -- Package constants
  pc_bus_sgmnt_value constant bi.com_supplier_difot_update.bus_sgmnt%type := '02'; 

  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_not_allow_missing);
    
    -- Add column structure
    fflu_data.add_number_field_del(pc_mars_period,1,'Period','999990',190001,999913,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_supplier,2,'Supplier',1,32,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_difot_value,3,'DIFOT','990.90',0,100,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_update_user,4,'User',1,30,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_user_comment,5,'Comments',1,4000,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    
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
    
    rv_insert_values bi.com_supplier_difot_update%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
            
      -- Set insert row columns
      begin
        -- Assign Mars Period
        v_current_field := pc_mars_period;
        rv_insert_values.mars_period := fflu_data.get_number_field(pc_mars_period);
        
        -- Assign Supplier
        v_current_field := pc_supplier;
        rv_insert_values.supplier := initcap(trim(fflu_data.get_char_field(pc_supplier)));     

        -- Assign DIFOT overwrite value
        v_current_field := pc_difot_value;
        rv_insert_values.difot_value := fflu_data.get_number_field(pc_difot_value);

        -- Assign Update user 
        v_current_field := pc_update_user;
        rv_insert_values.update_user := initcap(trim(fflu_data.get_char_field(pc_update_user)));
        
        -- Assign User comment 
        v_current_field := pc_user_comment;
        rv_insert_values.user_comment := initcap(trim(fflu_data.get_char_field(pc_user_comment)));        

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
      
      delete from bi.com_supplier_difot_update
      where mars_period = rv_insert_values.mars_period
         and supplier = rv_insert_values.supplier
         and bus_sgmnt = pc_bus_sgmnt_value;      
      
      -- Insert row, if row status is ok 
      if v_row_status_ok = true then 
        insert into bi.com_supplier_difot_update values rv_insert_values;
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

end comfod02_loader;
/

grant execute on comfod02_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
