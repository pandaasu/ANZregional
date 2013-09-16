create or replace package body pxipmx11_loader as 

/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- Interface column constants
  pc_mars_period constant fflu_common.st_name := 'Mars Period';
  pc_zrep_matl_code constant fflu_common.st_name := 'ZREP Matl Code - Short';
  pc_cost constant fflu_common.st_name := 'Cost of Goods Sold';  
  
  -- Interface Sufix's
  pc_interface_snack constant fflu_common.st_interface := '1';
  pc_interface_food  constant fflu_common.st_interface := '2';
  pc_interface_pet   constant fflu_common.st_interface := '3';
  pc_interface_nz    constant fflu_common.st_interface := '4';
  
  -- Package variables
  pv_first_row_flag boolean;
  pv_user fflu_common.st_user;
  prv_initial_values pxi.pmx_cogs%rowtype;
 
  ------------------------------------------------------------------------------
  -- LICS : ON_START 
  ------------------------------------------------------------------------------
  procedure on_start is
  
  begin
    -- Now assign the moe code based on the interface configuration file information.
    case fflu_utils.get_interface_suffix 
      when pc_interface_snack then 
        prv_initial_values.cmpny_code := pxi_common.gc_australia;
        prv_initial_values.div_code := pxi_common.gc_bus_sgmnt_snack;
      when pc_interface_food then 
        prv_initial_values.cmpny_code := pxi_common.gc_australia;
        prv_initial_values.div_code := pxi_common.gc_bus_sgmnt_food;
      when pc_interface_pet then 
        prv_initial_values.cmpny_code :=  pxi_common.gc_australia;
        prv_initial_values.div_code := pxi_common.gc_bus_sgmnt_petcare;
      when pc_interface_nz then 
        prv_initial_values.cmpny_code :=  pxi_common.gc_new_zealand;
        prv_initial_values.div_code := pxi_common.gc_new_zealand;
      else 
        prv_initial_values.cmpny_code := null;
        prv_initial_values.div_code := null;
        fflu_data.log_interface_error('Interface Suffix', fflu_utils.get_interface_suffix ,'Unknown Interface Suffix Configuration.');
    end case;

    -- Initialise data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_not_allow_missing);
    
    -- Add column structure
    fflu_data.add_number_field_del(pc_mars_period,1,'PERIOD','999999',190001,999913,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_zrep_matl_code,2,'ZREP_',fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    fflu_data.add_number_field_del(pc_cost,3,'COGS','99999.99',0,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null,fflu_data.gc_null_nls_options);
    
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
    
    rv_insert_values pxi.pmx_cogs%rowtype;

  begin
    if fflu_data.parse_data(p_row) = true then
      -- Set row status
      v_row_status_ok := true;
            
      -- Set insert row columns
      begin
        -- Assign Company Code
        rv_insert_values.cmpny_code := prv_initial_values.cmpny_code;
        -- Assign Division Code
        rv_insert_values.div_code := prv_initial_values.div_code;
        -- Assign Mars Period
        v_current_field := pc_mars_period;
        rv_insert_values.mars_period := fflu_data.get_number_field(pc_mars_period);
        -- Assign ZREP Matl Code - Short
        v_current_field := pc_zrep_matl_code;
        rv_insert_values.zrep_matl_code := pxi_common.full_matl_code(fflu_data.get_number_field(pc_zrep_matl_code));
        -- Assign Cost of Goods Sold
        v_current_field := pc_cost;
        rv_insert_values.cost := fflu_data.get_number_field(pc_cost);

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
        prv_initial_values.mars_period := rv_insert_values.mars_period;

        -- Delete on "Replace Key"
        delete from pxi.pmx_cogs
        where cmpny_code = prv_initial_values.cmpny_code
        and div_code = prv_initial_values.div_code
        and mars_period = prv_initial_values.mars_period;

      else -- Check that "Replace Key" remains consistient

        if prv_initial_values.mars_period != rv_insert_values.mars_period then
          v_row_status_ok := false;
          fflu_data.log_field_error(pc_mars_period, 'Replace Key Value Inconsistient');
        end if;

      end if;
      
      -- Insert row, if row status is ok 
      if v_row_status_ok = true then 
        insert into pxi.pmx_cogs values rv_insert_values;
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

end pxipmx11_loader;
