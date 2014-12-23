create or replace package body apopxi01_loader as
/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- Package Name
  pc_package_name      constant pxi_common.st_package_name := 'APOPXI01_LOADER';

  -- Interface Field Definitions
  pc_field_demand_unit       constant fflu_common.st_name := 'Demand Unit';
  pc_field_demand_group      constant fflu_common.st_name := 'Demand Group';
  pc_field_location_code     constant fflu_common.st_name := 'Location Code';
  pc_field_load_date         constant fflu_common.st_name := 'Load Date';
  pc_field_start_date        constant fflu_common.st_name := 'Start Date';
  pc_field_duration          constant fflu_common.st_name := 'Duration (Mins)';
  pc_field_type_code         constant fflu_common.st_name := 'Type Code';
  pc_field_quantity          constant fflu_common.st_name := 'Quantity';
  pc_field_forecast_text     constant fflu_common.st_name := 'Forecast Text';
  pc_field_promotion_type    constant fflu_common.st_name := 'Promotion Type';

/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_interface_suffix    fflu_common.st_interface;
  pv_expected_moe_code   pxi_common.st_moe_code;
  pv_first_row           boolean;
  prv_header             pxi_demand_header%rowtype;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/
  procedure on_start is
  begin
    -- Get interface suffix
    pv_interface_suffix := fflu_app.fflu_utils.get_interface_suffix;
    -- Check that the interface suffix is valid.
    if pxi_e2e_demand.is_valid_suffix(pv_interface_suffix) = false then 
      fflu_data.log_interface_error('Interface Suffix',pv_interface_suffix,'Interface Suffix was not a valid value. Check PXI_MOE_ATTRIBUTES table for a list of valid interface suffixes');
    end if;
    -- Now look up the expected moe code.
    pv_expected_moe_code := pxi_e2e_demand.get_moe_from_suffix(pv_interface_suffix);
    
    -- Now initialise the data parsing package.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_file_header,fflu_data.gc_not_allow_missing);

    -- Detail Record - Fields
    fflu_data.add_char_field_txt(pc_field_demand_unit,1,16,3,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_field_demand_group,17,7,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_field_location_code,24,5,fflu_data.gc_null_min_length,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_date_field_txt(pc_field_load_date,29,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null); 
    fflu_data.add_date_field_txt(pc_field_start_date,43,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_txt(pc_field_duration,57,5,fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_txt(pc_field_type_code,62,1,fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_txt(pc_field_quantity,63,20,fflu_data.gc_null_format,fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);
    fflu_data.add_char_field_txt(pc_field_forecast_text,83,50,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_field_promotion_type,133,255,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    
    -- Flag the first row will be next.
    pv_first_row := true;
    
  exception
    when others then
      fflu_data.log_interface_exception('ON_START');
  end on_start;

/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/
  procedure on_data(p_row in varchar2) is
    -- Row Variables
    rv_detail pxi_demand_detail%rowtype;
    v_ignore_row boolean;
    
    -- This procedure perform the header creation.
    procedure create_header is 
    begin
      -- Initialise the demand sequence
      select pxi_demand_seq.nextval into prv_header.demand_seq from dual;
      -- Extract the rest of the other values for the header from this first row.
      prv_header.moe_code := pxi_e2e_demand.get_moe_from_demand_unit(fflu_data.get_char_field(pc_field_demand_unit));
      prv_header.location_code := fflu_data.get_char_field(pc_field_location_code);
      prv_header.load_date := fflu_data.get_date_field(pc_field_load_date);
      prv_header.min_mars_week := null;
      prv_header.max_mars_week := null;
      prv_header.modify_date := sysdate;
      prv_header.modify_user := fflu_utils.get_interface_user;
      -- Now insert the header record into the database.
      insert into pxi_demand_header values prv_header;
    end create_header;
    
  begin
    -- Now parse the incoming record.
    if fflu_data.parse_data(p_row) = true then
      -- Initialise Row Ignoring Variable.
      v_ignore_row := false;
      
      -- Perform an expected moe check on the data.
      if pv_expected_moe_code <> pxi_e2e_demand.get_moe_from_demand_unit(fflu_data.get_char_field(pc_field_demand_unit)) then 
        fflu_data.log_field_error(pc_field_demand_unit,'MOE Code did not match the expected moe code of [' || pv_expected_moe_code || '] for this interface.');
      end if;

      -- If this is the first row that was successfully parsed.
      if pv_first_row = true then 
        -- Allocate a new demand sequence number.
        if fflu_data.was_errors = false then 
          create_header;
        end if;
        -- Now clear the first row processing flag.
        pv_first_row := false;
      end if;
      
      -- Complete the data assignment into the array.
      rv_detail.demand_seq := prv_header.demand_seq;
      rv_detail.row_seq := fflu_utils.get_interface_row;
      rv_detail.demand_unit := fflu_data.get_char_field(pc_field_demand_unit);
      rv_detail.demand_group := fflu_data.get_char_field(pc_field_demand_group);
      rv_detail.start_date := fflu_data.get_date_field(pc_field_start_date);
      rv_detail.duration_mins := fflu_data.get_number_field(pc_field_duration);
      rv_detail.type_code := fflu_data.get_number_field(pc_field_type_code);
      rv_detail.qty := fflu_data.get_number_field(pc_field_quantity);
      rv_detail.demand_text := fflu_data.get_char_field(pc_field_forecast_text);
      rv_detail.promo_type := fflu_data.get_char_field(pc_field_promotion_type);
      -- Derived Fields
      rv_detail.zrep_code := pxi_e2e_demand.get_zrep_from_demand_unit(fflu_data.get_char_field(pc_field_demand_unit));
      rv_detail.mars_week := pxi_e2e_demand.get_mars_week(fflu_data.get_date_field(pc_field_start_date));

      -- Perform a location field header check.
      if prv_header.location_code <> fflu_data.get_char_field(pc_field_location_code) then
        fflu_data.log_field_error(pc_field_location_code,'Location code did not match the location code of the first row of data [' || prv_header.location_code || '].');
      end if;
      
      -- Check if the ZREP is valid.
      if pxi_e2e_demand.is_valid_zrep(rv_detail.zrep_code) = false then 
        -- fflu_data.log_field_error(pc_field_demand_unit,'Was not a valid ZREP Material Code.'); -- TODO ADD THIS LINE FOR PRODUCTION.
        v_ignore_row := true; -- TODO REMOVE FOR PRODUCTION.  This is to cater for dud test data.
      end if;
      
      -- Now perform the ignore row check.
      if rv_detail.type_code not in (pxi_e2e_demand.gc_type_1_base,pxi_e2e_demand.gc_type_4_reconcile,pxi_e2e_demand.gc_type_6_override) or rv_detail.qty = 0 then
        v_ignore_row := true;
      else 
        -- Now perform a minimum maximum mars week check.
        if prv_header.min_mars_week is null then 
          prv_header.min_mars_week := rv_detail.mars_week;
        else 
          if rv_detail.mars_week < prv_header.min_mars_week then 
            prv_header.min_mars_week := rv_detail.mars_week;
          end if;
        end if;
        if prv_header.max_mars_week is null then 
          prv_header.max_mars_week := rv_detail.mars_week;
        else 
          if rv_detail.mars_week > prv_header.max_mars_week then 
            prv_header.max_mars_week := rv_detail.mars_week;
          end if;
        end if;
      end if;
      
      -- If a row was successfully parsed and there have been no errors so far.
      if fflu_data.was_errors = false and v_ignore_row = false then 
        insert into pxi_demand_detail values rv_detail;
      end if;
    end if;
  exception
    when others then
      fflu_data.log_interface_exception('ON_DATA');
  end on_data;

/*******************************************************************************
  NAME:      ON_END                                                       PUBLIC
*******************************************************************************/
  procedure on_end is
  
    procedure update_header is
    begin
      -- Now set the minimum and maximum mars weeks that were detected.
      if prv_header.demand_seq is not null then 
        update pxi_demand_header 
        set 
          min_mars_week = prv_header.min_mars_week,
          max_mars_week = prv_header.max_mars_week,
          modify_date = sysdate
        where
          demand_seq = prv_header.demand_seq;
      end if;
    end update_header;
  
  begin
    -- Update Header.
    update_header;
    
    -- Only perform a commit if there were no errors at all.
    if fflu_data.was_errors then
      rollback;
    else
      commit;
      -- Now trigger the extract to Promax PX
      pxipmx14_extract.execute(prv_header.demand_seq);
    end if;

    -- Perform a final cleanup and a last progress logging.
    fflu_data.cleanup;
  exception
    when others then
      fflu_data.log_interface_exception('ON_END');
  end on_end;

/*******************************************************************************
  NAME:      ON_GET_FILE_TYPE                                             PUBLIC
*******************************************************************************/
  function on_get_file_type return varchar2 is
  begin
    return fflu_common.gc_file_type_fixed_width;
  end on_get_file_type;

/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFIER                                         PUBLIC
*******************************************************************************/
  function on_get_csv_qualifier return varchar2 is
  begin
    return fflu_common.gc_csv_qualifier_null;
  end on_get_csv_qualifier;

end apopxi01_loader;
/
