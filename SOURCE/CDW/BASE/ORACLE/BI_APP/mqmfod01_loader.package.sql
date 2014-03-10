create or replace package mqmfod01_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : bi_app
    Package   : mqmfod01_loader
    Author    : Trevor Keon         
  
    Description
    ----------------------------------------------------------------------------
    [mqmfod01] MQM Scorecard - Food - Material Risk
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
    2014-02-05  Trevor Keon           [Auto Generated]
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end mqmfod01_loader;
/

create or replace package body mqmfod01_loader as 

  -- Interface column constants
  pc_material constant fflu_common.st_name := 'Raw Material Number';
  pc_material_family constant fflu_common.st_name := 'Material Family';
  pc_risk constant fflu_common.st_name := 'Ingredient Risk Rating';
  pc_vendor constant fflu_common.st_name := 'Vendor Code';
  pc_supplier_status constant fflu_common.st_name := 'Supplier Status for Raw';
  pc_last_purchase_date constant fflu_common.st_name := 'Last Purchase Date';  
  
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
    fflu_data.add_char_field_del(pc_material,1,'Raw Material Number',1,100,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_material_family,3,'Material Family',0,100,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_risk,4,'Ingredient Risk Rating',0,100,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_number_field_del(pc_vendor,5,'Vendor Code','99999990',1,99999999,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_char_field_del(pc_supplier_status,6,'Supplier Status for Raw',1,100,fflu_data.gc_not_allow_null,fflu_data.gc_not_trim);
    fflu_data.add_char_field_del(pc_last_purchase_date,7,'Last Purchase Date',0,100,fflu_data.gc_allow_null,fflu_data.gc_not_trim);
    
    -- Get user name - MUST be called after initialising fflu_data, or after fflu_utils.log_interface_progress.
    pv_user := fflu_utils.get_interface_user;
    
    -- Delete previous table entries
    delete from bi.mqm_material_risk;
    
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
    
    rv_insert_values bi.mqm_material_risk%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
      
      -- Set insert row columns
      begin
        -- Assign Material
        v_current_field := pc_material;
        rv_insert_values.material := initcap(trim(fflu_data.get_char_field(pc_material)));
        -- Assign Material Family
        v_current_field := pc_material_family;
        rv_insert_values.material_family := initcap(trim(fflu_data.get_char_field(pc_material_family)));        
        -- Assign Ingredient Risk Rating
        v_current_field := pc_risk;
        rv_insert_values.risk := initcap(trim(fflu_data.get_char_field(pc_risk)));
        -- Assign Vendor Code
        v_current_field := pc_vendor;
        rv_insert_values.vendor := fflu_data.get_number_field(pc_vendor);
        -- Assign Supplier Status for Raw
        v_current_field := pc_supplier_status;
        rv_insert_values.supplier_status := initcap(trim(fflu_data.get_char_field(pc_supplier_status)));
        -- Assign Last Purchase Date
        v_current_field := pc_last_purchase_date;
        rv_insert_values.last_purchase_date := initcap(trim(fflu_data.get_char_field(pc_last_purchase_date)));

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
        insert into bi.mqm_material_risk values rv_insert_values;
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

end mqmfod01_loader;
/

grant execute on mqmfod01_loader to lics_app, fflu_app;

/*******************************************************************************
  END
*******************************************************************************/
