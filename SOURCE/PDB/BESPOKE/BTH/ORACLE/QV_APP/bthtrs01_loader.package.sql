create or replace package bthtrs01_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : qv_app
    Package   : bthtrs01_loader
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [bthtrs01] BTH Plant DB - TRS Times
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
    2014-06-20  Trevor Keon           [Auto Generated]
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end bthtrs01_loader;
/

create or replace package body bthtrs01_loader as 

  -- Interface column constants
  pc_mars_week constant fflu_common.st_name := 'Mars Week';
  pc_lights_on constant fflu_common.st_name := 'Lights On';
  pc_lights_off constant fflu_common.st_name := 'Lights Off';  
  pc_holiday_hours constant fflu_common.st_name := 'Holiday Hours';
  pc_pm_hours constant fflu_common.st_name := 'PM Hours';
  
  -- Package variables
  pv_first_row_flag boolean;
  pv_user fflu_common.st_user;
  prv_initial_values qv.bth_trs_times%rowtype;
 
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_allow_missing);
    
    -- Add column structure
    fflu_data.add_number_field_del(pc_mars_week,1,'Mars Week','9999990',1900011,9999134,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_date_field_del(pc_lights_on,2,'Lights On','dd/mm/yyyy hh24:mi');
    fflu_data.add_date_field_del(pc_lights_off,3,'Lights Off','dd/mm/yyyy hh24:mi');
    fflu_data.add_number_field_del(pc_holiday_hours,4,'Holiday Hours', '9999990.99', 0, 9999999.99, fflu_data.gc_allow_null, fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_pm_hours,5,'PM Hours', '9999990.99', 0, 9999999.99, fflu_data.gc_allow_null, fflu_data.gc_null_nls_options);
    
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
    
    rv_insert_values qv.bth_trs_times%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
      
      -- Set insert row columns
      begin
        -- Assign Mars Week
        v_current_field := pc_mars_week;
        rv_insert_values.mars_week := fflu_data.get_number_field(pc_mars_week);
        -- Assign Lights On
        v_current_field := pc_lights_on;
        rv_insert_values.lights_on := fflu_data.get_date_field(pc_lights_on);
        -- Assign Lights Off
        v_current_field := pc_lights_off;
        rv_insert_values.lights_off := fflu_data.get_date_field(pc_lights_off);
        -- Assign Holiday Hours
        v_current_field := pc_holiday_hours;
        rv_insert_values.holiday_hours := fflu_data.get_number_field(pc_holiday_hours);
        -- Assign Planned Maintenance Hours
        v_current_field := pc_pm_hours;
        rv_insert_values.pm_hours := fflu_data.get_number_field(pc_pm_hours);

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
      
      -- Remove any previous entries for this week 
      delete from qv.bth_trs_times
      where mars_week = rv_insert_values.mars_week;      
      
      -- Insert row, if row status is ok 
      if v_row_status_ok = true then 
        insert into qv.bth_trs_times values rv_insert_values;
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

end bthtrs01_loader;
/

grant execute on bthtrs01_loader to lics_app, fflu_app, qv_user;

/*******************************************************************************
  END
*******************************************************************************/
