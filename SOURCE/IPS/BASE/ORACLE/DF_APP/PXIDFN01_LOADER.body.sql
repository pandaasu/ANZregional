create or replace 
package body        PXIDFN01_LOADER as

/*******************************************************************************
  Interface Field Definitions
*******************************************************************************/  
  pc_field_week_date             constant fflu_common.st_name := 'WeekDate';
  pc_field_account_code          constant fflu_common.st_name := 'AccountCode';
  pc_field_stock_code            constant fflu_common.st_name := 'StockCode';
  pc_field_estimated_volume      constant fflu_common.st_name := 'EstEstimatedVolume';
  pc_field_normal_volume         constant fflu_common.st_name := 'EstNormalVolume';
  pc_field_incremental_volume    constant fflu_common.st_name := 'EstIncrementalVolume';
  pc_field_marketing_volume      constant fflu_common.st_name := 'EstMarketingAdjVolume';
  pc_field_state_phasing_volume  constant fflu_common.st_name := 'EstStatePhasingVolume';
  
  -- This is the formual for verification of volume information
  -- EstEstimatedVolume = EstNormalVolume + EstIncrementalVolume + 
  --                      EstMarketingAdjVolume + EstStatePhasingVolume
  --
  -- EstNormalVolume = Base
  -- EstIncrementalVolume + EstMarketingAdjVolume + EstStatePhasingVolume = Uplift

/*******************************************************************************
  Interface Type Constants
*******************************************************************************/  
  pc_file_type_draft   constant fflu_common.st_interface := 'D';
  pc_file_type_publish constant fflu_common.st_interface := 'P';

/*******************************************************************************
  Interface Type Constants
*******************************************************************************/  
  pc_load_dmnd_type_base    constant common.st_value := 10;
  pc_load_dmnd_type_uplift  constant common.st_value := 11;

/*******************************************************************************
  Package Variables
*******************************************************************************/  
  -- Record for loading a file.
  prv_load_file load_file%rowtype;
  pv_casting_week date;
  pv_line_counter common.st_count;
  pv_draft boolean;
  pv_publish boolean;
/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/  
  procedure on_start is 
    v_result_msg common.st_message_string;
  begin
    -- Assign the casting week to be the currnet system date.
    pv_casting_week := trunc(sysdate);
    -- Intialise the Line counter.
    pv_line_counter := 0;
    -- Initialise the type.
    pv_draft := false;
    pv_publish := false;
    -- Now initialise the data parsing wrapper.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier);
    -- Now define the column structure
    fflu_data.add_date_field_txt(pc_field_week_date,1,8,'YYYYMMDD');
    fflu_data.add_char_field_txt(pc_field_account_code,9,10);
    fflu_data.add_char_field_txt(pc_field_stock_code,19,18);
    fflu_data.add_number_field_txt(pc_field_estimated_volume,37,10,'9999999999');
    fflu_data.add_number_field_txt(pc_field_normal_volume,47,10,'9999999999');
    fflu_data.add_number_field_txt(pc_field_incremental_volume,57,10,'9999999999');
    fflu_data.add_number_field_txt(pc_field_marketing_volume,67,10,'9999999999');
    fflu_data.add_number_field_txt(pc_field_state_phasing_volume,77,10,'9999999999');

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
    if pv_draft = true then 
      prv_load_file.wildcard := demand_forecast.gc_wildcard_dmnd_draft;
    end if;
    if pv_publish = true then 
      prv_load_file.wildcard := demand_forecast.gc_wildcard_demand;
    end if;
      
      
    -- Now assign the moe code based on the interface configuration file information.
    case substr(fflu_utils.get_interface_suffix,1,1)
      when pxi_common.gc_interface_snack then 
        prv_load_file.moe_code := pxi_common.gc_moe_snack;
      when pxi_common.gc_interface_food then 
        prv_load_file.moe_code := pxi_common.gc_moe_food;
      when pxi_common.gc_interface_pet then 
        prv_load_file.moe_code := pxi_common.gc_moe_pet;
      when pxi_common.gc_interface_nz then 
        prv_load_file.moe_code := pxi_common.gc_moe_nz;
      else 
        prv_load_file.moe_code := null;
        fflu_data.log_interface_error('Interface Suffix', fflu_utils.get_interface_suffix ,'Unknown Interface Suffix Configuration.');
    end case;
   
   -- Now determine if this is a draft or publish, default to draft, especially if missing.
   case substr(fflu_utils.get_interface_suffix,2,1)
     when pc_file_type_draft then 
       pv_draft := true;
     when pc_file_type_publish then 
       pv_publish := true;
     else
       pv_draft := true;
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
    
/*    
      -- Now check that the data 
      if (fflu_data.get_number_field(pc_field_normal_volume) + 
          fflu_data.get_number_field(pc_field_incremental_volume) + 
          fflu_data.get_number_field(pc_field_marketing_volume) + 
          fflu_data.get_number_field(pc_field_state_phasing_volume)) <> 
          fflu_data.get_number_field(pc_field_estimated_volume) then 
        fflu_data.log_field_error(pc_field_estimated_volume,
          'Total estimated sales volume did not equal the sum of the normal, incremental, markerting adjustment, and state phasing sales uplift of [' || 
          (fflu_data.get_number_field(pc_field_normal_volume) + 
          fflu_data.get_number_field(pc_field_incremental_volume) + 
          fflu_data.get_number_field(pc_field_marketing_volume) + 
          fflu_data.get_number_field(pc_field_state_phasing_volume)) || '].');
      end if;
*/

      -- Now lookup and supply key data. 
      rv_load_dmnd.dmdunit             := null;
      rv_load_dmnd.loc                 := null;
      rv_load_dmnd.startdate           := fflu_data.get_date_field(pc_field_week_date);
      rv_load_dmnd.dur                 := 24*60*7;  -- Minutes.
      rv_load_dmnd.fcst_text           := null;
      rv_load_dmnd.promo_type          := null;
      rv_load_dmnd.mars_week           := demand_forecast.sql_get_mars_week (rv_load_dmnd.startdate);
      rv_load_dmnd.casting_mars_week   := demand_forecast.sql_get_mars_week(pv_casting_week - 3);
      rv_load_dmnd.file_id             := prv_load_file.file_id;
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

      -- Now perform the inserts if there are still no errors in the system at this point.
      if fflu_data.was_errors = false then 
        -- Now perform the insert into load demand data table for the base sales forecast volume
        rv_load_dmnd.type                := pc_load_dmnd_type_base; -- This is = to demand_forecast.gc_dmnd_type_b, Promax Base forecast.
        rv_load_dmnd.qty                 := fflu_data.get_number_field(pc_field_normal_volume);
        pv_line_counter := pv_line_counter + 1;
        rv_load_dmnd.file_line           := pv_line_counter;
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
        -- Now perform the insert into load demand data table for the incremental sales forecast volume
        rv_load_dmnd.type                := pc_load_dmnd_type_uplift; -- This is = to demand_forecast.gc_dmnd_type_u, Promax Uplift forecast. 
/*        
        rv_load_dmnd.qty                 := fflu_data.get_number_field(pc_field_incremental_volume) + 
          fflu_data.get_number_field(pc_field_marketing_volume) + 
          fflu_data.get_number_field(pc_field_state_phasing_volume);
*/
        rv_load_dmnd.qty                 := fflu_data.get_number_field(pc_field_estimated_volume) - 
          fflu_data.get_number_field(pc_field_normal_volume);
        pv_line_counter := pv_line_counter + 1;
        rv_load_dmnd.file_line           := pv_line_counter;
        
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
   c_stream_draft constant common.st_name := 'DF_DEMAND_DRAFT';
   c_stream_publish constant common.st_name := 'DF_DEMAND_FINAL';
   v_stream_package common.st_name;
  begin 
    -- Only perform a commit if there were no errors at all. 
    if fflu_data.was_errors = true then 
      rollback;
    else 
      commit;
      -- Now determine which stream we need to call.
      if pv_draft = true then 
        v_stream_package := c_stream_draft;
      end if;
      if pv_publish = true then 
        v_stream_package := c_stream_publish;
      end if;
      -- Now trigger the necessary lics stream processing jobs.
      lics_stream_loader.clear_parameters;
      lics_stream_loader.set_parameter(c_parameter_moe,prv_load_file.file_id);
      lics_stream_loader.set_parameter(c_parameter_file_id,to_char(prv_load_file.file_id));
      lics_stream_loader.execute(v_stream_package,null);
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