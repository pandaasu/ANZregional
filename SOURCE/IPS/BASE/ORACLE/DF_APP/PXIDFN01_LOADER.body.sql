create or replace 
package body        PXIDFN01_LOADER as

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_week_date        constant fflu_common.st_name := 'WeekDate';
  pc_field_account_code     constant fflu_common.st_name := 'AccountCode';
  pc_field_stock_code       constant fflu_common.st_name := 'StockCode';
  pc_field_estimated_volume constant fflu_common.st_name := 'EstEstimatedVolme';

/*******************************************************************************
  Interface Sufix's
*******************************************************************************/  
  pc_interface_snack constant fflu_common.st_interface := '1';
  pc_interface_food  constant fflu_common.st_interface := '2';
  pc_interface_pet   constant fflu_common.st_interface := '3';
  pc_interface_nz    constant fflu_common.st_interface := '4';
  
/*******************************************************************************
  Package Variables
*******************************************************************************/  
  -- Record for loading a file.
  prv_load_file load_file%rowtype;
  pv_casting_week date;
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
    v_result_msg common.st_message_string;
  begin
    -- Assign the casting week to be the currnet system date.
    pv_casting_week := trunc(sysdate);
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier);
    -- Now define the column structure
    fflu_data.add_date_field_txt(pc_field_week_date,1,8,'YYYYMMDD');
    fflu_data.add_char_field_txt(pc_field_account_code,9,10);
    fflu_data.add_char_field_txt(pc_field_stock_code,19,18);
    fflu_data.add_number_field_txt(pc_field_estimated_volume,37,10,'9999999999');
    
    -- Assign the inferface file name to the loading table record.
    prv_load_file.file_name := fflu_utils.get_interface_filename;

    -- Fetch a unique run id.
    IF demand_object_tracking.get_new_id ('LOAD_FILE', 'RUN_ID', prv_load_file.run_id, v_result_msg) != common.gc_success THEN
       fflu_data.log_interface_error('Load File Run ID',null,v_result_msg);
    END IF;

    -- Fetch a unique record id.
    IF demand_object_tracking.get_new_id ('LOAD_FILE', 'FILE_ID', prv_load_file.file_id, v_result_msg) != common.gc_success THEN
      fflu_data.log_interface_error('Load File File ID',null,v_result_msg);
    END IF;

    -- Now assign the other field records.
    prv_load_file.wildcard := demand_forecast.gc_wildcard_dmnd_draft;
      
    -- Now assign the moe code based on the interface configuration file information.
    case fflu_utils.get_interface_suffix 
      when pc_interface_snack then 
        prv_load_file.moe_code := '0009';
      when pc_interface_food then 
        prv_load_file.moe_code := '0021';
      when pc_interface_pet then 
        prv_load_file.moe_code := '0196';
      when pc_interface_nz then 
        prv_load_file.moe_code := '0086';
      else 
        prv_load_file.moe_code := null;
        fflu_data.log_interface_error('Interface Suffix', fflu_utils.get_interface_suffix ,'Unknown Interface Suffix Configuration.');
    end case;

    -- Populate other values.
    prv_load_file.status := common.gc_loaded;
    prv_load_file.loaded_date := sysdate;
    
    -- Now load create the file record.
    INSERT INTO load_file (
      file_id, 
      file_name, 
      status, 
      loaded_date, 
      run_id, 
      wildcard, 
      moe_code)
    VALUES (
      prv_load_file.file_id, 
      prv_load_file.file_name, 
      prv_load_file.status, 
      prv_load_file.loaded_date,
      prv_load_file.run_id,
      prv_load_file.wildcard,
      prv_load_file.moe_code
    );
  exception 
    when others then 
      fflu_data.log_interface_exception('On Start');
  end on_start;


/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/  
  procedure on_data(p_row in varchar2) is 
    -- Used to perform a matl code validation.
    CURSOR csr_matl_code (i_zrep_code in varchar2) IS
      SELECT matl_code
      FROM matl
      WHERE matl_type = 'ZREP' AND trdd_unit = 'X'
        AND matl_code = reference_functions.full_matl_code (i_zrep_code);
      rv_matl_code csr_matl_code%ROWTYPE;

    -- Used to perform a business segment validation
    CURSOR csr_bus_sgmnt_code (i_zrep_code in varchar2) IS
      SELECT bus_sgmnt_code
      FROM matl_fg_clssfctn
      WHERE matl_code = reference_functions.full_matl_code (i_zrep_code);
      
    -- Used to lookup the reverse lookup the demand group information.
    CURSOR csr_demand_group(i_dmnd_plng_node in varchar2, i_bus_sgmnt_code in varchar2) is
      select 
        t1.dmnd_grp_code
      from
        px_dmnd_lookup t1
      where 
        t1.dmnd_plng_node = lpad(i_dmnd_plng_node,10,'0')
        and t1.bus_sgmnt_code = lpad(i_bus_sgmnt_code,2,'0');
    -- Record used for createing the load demand data record.
    rv_load_dmnd load_dmnd%rowtype;
  begin
    if fflu_data.parse_data(p_row) = true then
      
      -- Now lookup and supply key data. 
      rv_load_dmnd.dmdunit             := null;
      rv_load_dmnd.loc                 := null;
      rv_load_dmnd.startdate           := fflu_data.get_date_field(pc_field_week_date);
      rv_load_dmnd.dur                 := 24*60*7;  -- Minutes.
      rv_load_dmnd.type                := demand_forecast.gc_dmnd_type_1; -- Base forecast.
      rv_load_dmnd.qty                 := fflu_data.get_number_field(pc_field_estimated_volume);
      rv_load_dmnd.fcst_text           := null;
      rv_load_dmnd.promo_type          := null;
      rv_load_dmnd.mars_week           := demand_forecast.sql_get_mars_week (rv_load_dmnd.startdate);
      rv_load_dmnd.casting_mars_week   := demand_forecast.sql_get_mars_week(pv_casting_week - 3);
      rv_load_dmnd.file_id             := prv_load_file.file_id;
      rv_load_dmnd.file_line           := fflu_utils.get_interface_row;
      rv_load_dmnd.zrep_code           := fflu_data.get_char_field(pc_field_stock_code);
      rv_load_dmnd.source_code         := demand_forecast.get_source_code (rv_load_dmnd.zrep_code);
    
      -- Now perform the matl code validation
      open csr_matl_code (rv_load_dmnd.zrep_code);
      fetch csr_matl_code into rv_matl_code;
      if csr_matl_code%found then 
        rv_load_dmnd.zrep_valid := common.gc_valid;
      else
        rv_load_dmnd.zrep_valid := common.gc_invalid;
        fflu_data.log_field_error(pc_field_stock_code,'Was not a valid ZREP Material Code.');
      end if;
      close csr_matl_code;
      
      -- Now perform a business segment validation.
      open csr_bus_sgmnt_code (rv_load_dmnd.zrep_code);
      fetch csr_bus_sgmnt_code into rv_load_dmnd.bus_sgmnt_code;
      if csr_bus_sgmnt_code%notfound then 
        fflu_data.log_field_error(pc_field_stock_code,'Could not find business segment for the supplied stock code.');
        rv_load_dmnd.bus_sgmnt_code := null;
      end if;
      close csr_bus_sgmnt_code;
      
      -- Now lookup the demand group code.
      open csr_demand_group (fflu_data.get_char_field(pc_field_account_code), rv_load_dmnd.bus_sgmnt_code);
      fetch csr_demand_group into rv_load_dmnd.dmdgroup;
      if csr_demand_group%notfound then 
        fflu_data.log_field_error(pc_field_account_code,'Could not find account code as a demand planning node in promax demand lookup table for material business segment [' || rv_load_dmnd.bus_sgmnt_code || '].');
        rv_load_dmnd.dmdgroup := null;
      end if;
      close csr_demand_group;

      -- Initialise the loading variables and reset the processing error flag before processing.      
      rv_load_dmnd.status              := common.gc_loaded;
      rv_load_dmnd.error_msg           := NULL;

      -- Now perform the insert into load demand data table.
      INSERT INTO load_dmnd
        (dmdunit, 
         dmdgroup, 
         loc, 
         casting_mars_week, 
         startdate, 
         dur, 
         type, 
         qty, 
         file_id,
         file_line, 
         fcst_text, 
         promo_type,
         zrep_code,
         source_code,
         zrep_valid,
         bus_sgmnt_code,
         status,
         mars_week,
         error_msg
      ) VALUES (
         rv_load_dmnd.dmdunit, 
         rv_load_dmnd.dmdgroup, 
         rv_load_dmnd.loc, 
         rv_load_dmnd.casting_mars_week, 
         rv_load_dmnd.startdate, 
         rv_load_dmnd.dur, 
         rv_load_dmnd.type, 
         rv_load_dmnd.qty, 
         rv_load_dmnd.file_id,
         rv_load_dmnd.file_line, 
         rv_load_dmnd.fcst_text, 
         rv_load_dmnd.promo_type,
         rv_load_dmnd.zrep_code,
         rv_load_dmnd.source_code,
         rv_load_dmnd.zrep_valid,
         rv_load_dmnd.bus_sgmnt_code,
         rv_load_dmnd.status,
         rv_load_dmnd.mars_week,
         rv_load_dmnd.error_msg
      );
    end if;
  exception 
    when others then 
      fflu_data.log_interface_exception('On Data');
  end on_data;
  
/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/  
  procedure on_end is 
   -- Demand Constants. 
   c_parameter_moe constant common.st_name := 'MOE';
   c_parameter_file_id constant common.st_name := 'FILE_ID';
   c_parameter_append constant common.st_name := 'APPEND';
   c_stream_package constant common.st_name := 'DF_DEMAND_DRAFT';
  begin 
    -- Only perform a commit if there were no errors at all. 
    if fflu_data.was_errors = true then 
      rollback;
    else 
      commit;
      -- Now trigger the necessary lics stream processing jobs.
      lics_stream_loader.clear_parameters;
      lics_stream_loader.set_parameter(c_parameter_moe,prv_load_file.moe_code);
      lics_stream_loader.set_parameter(c_parameter_file_id,to_char(prv_load_file.file_id));
      lics_stream_loader.set_parameter(c_parameter_append,'FALSE');
      lics_stream_loader.execute(c_stream_package,null);
    end if;
    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;
  exception 
    when others then 
      fflu_data.log_interface_exception('On End');
  end on_end;


/*******************************************************************************
  NAME:      ON_GET_FILE_TYPE                                             PUBLIC
*******************************************************************************/  
  function on_get_file_type return varchar2 is 
  begin 
    return fflu_common.gc_file_type_fixed_width;
  end on_get_file_type;
  
/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFER                                          PUBLIC
*******************************************************************************/  
  function on_get_csv_qualifier return varchar2 is
  begin 
    return null;
  end on_get_csv_qualifier;

end PXIDFN01_LOADER;