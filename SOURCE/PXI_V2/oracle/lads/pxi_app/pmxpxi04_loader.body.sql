create or replace package body pmxpxi04_loader as
/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- Package Name
  pc_package_name      constant pxi_common.st_package_name := 'PMXPXI04_LOADER';

  -- Interface Field Definitions
  pc_field_week_date             constant fflu_common.st_name := 'Week Date';
  pc_field_account_code          constant fflu_common.st_name := 'Account Code';
  pc_field_stock_code            constant fflu_common.st_name := 'Stock Code';
  pc_field_estimated_volume      constant fflu_common.st_name := 'Est Estimated Volume';
  pc_field_normal_volume         constant fflu_common.st_name := 'Est Normal Volume';
  pc_field_incremental_volume    constant fflu_common.st_name := 'Est Incremental Volume';
  pc_field_marketing_volume      constant fflu_common.st_name := 'Est Marketing Adj Volume';
  pc_field_state_phasing_volume  constant fflu_common.st_name := 'Est StatePhasing Volume';

/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_interface_suffix    fflu_common.st_interface;
  pv_estimate_seq        pxi_e2e_demand.st_sequence;

/*******************************************************************************
  NAME:      ON_START                                                     PUBLIC
*******************************************************************************/
  procedure on_start is
    rv_header            pxi_estimate_header%rowtype;
  begin
    -- Get interface suffix
    pv_interface_suffix := fflu_app.fflu_utils.get_interface_suffix;
    -- Check that the interface suffix is valid.
    if pxi_e2e_demand.is_valid_suffix(pv_interface_suffix) = false then 
      fflu_data.log_interface_error('Interface Suffix',pv_interface_suffix,'Interface Suffix was not a valid value. Check PXI_MOE_ATTRIBUTES table for a list of valid interface suffixes');
    end if;
    
    -- Now initialise the data parsing package.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_no_file_header,fflu_data.gc_not_allow_missing);

    -- Detail Record - Fields
    fflu_data.add_date_field_txt(pc_field_week_date,1,8,'yyyymmdd',fflu_data.gc_null_min_date,fflu_data.gc_null_max_date,fflu_data.gc_not_allow_null); 
    fflu_data.add_char_field_txt(pc_field_account_code,9,10,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_txt(pc_field_stock_code,19,18,fflu_data.gc_null_min_length,fflu_data.gc_allow_null,fflu_data.gc_trim);
    fflu_data.add_number_field_txt(pc_field_estimated_volume,37,10,'9999999999',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_txt(pc_field_normal_volume,47,10,'9999999999',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_txt(pc_field_incremental_volume,57,10,'9999999999',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_txt(pc_field_marketing_volume,67,10,'9999999999',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);
    fflu_data.add_number_field_txt(pc_field_state_phasing_volume,77,10,'9999999999',fflu_data.gc_null_min_number,fflu_data.gc_null_max_number,fflu_data.gc_not_allow_null);

    -- Now carry out the header procesing.
    if fflu_data.was_errors = false then 
      select pxi_estimate_seq.nextval into rv_header.estimate_seq from dual;
      pv_estimate_seq := rv_header.estimate_seq;
      rv_header.moe_code := pxi_e2e_demand.get_moe_from_suffix(pv_interface_suffix);
      rv_header.modify_date := sysdate;
      rv_header.modify_user := fflu_utils.get_interface_user;
      -- Now insert the header record into the database.
      insert into pxi_estimate_header values rv_header;
    end if;
  exception
    when others then
      fflu_data.log_interface_exception('ON_START');
  end on_start;

/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/
  procedure on_data(p_row in varchar2) is
    -- Row Variables
    rv_detail pxi_estimate_detail%rowtype;
    v_ignore_row boolean;

  begin
    -- Now parse the incoming record.
    if fflu_data.parse_data(p_row) = true then
      -- Complete the data assignment into the array.
      rv_detail.estimate_seq := pv_estimate_seq;
      rv_detail.row_seq := fflu_utils.get_interface_row;
      rv_detail.week_date := fflu_data.get_date_field(pc_field_week_date);
      rv_detail.account_code := fflu_data.get_char_field(pc_field_account_code);
      rv_detail.stock_code := fflu_data.get_char_field(pc_field_stock_code);
      rv_detail.est_estimated_volume := fflu_data.get_number_field(pc_field_estimated_volume);
      rv_detail.est_normal_volume := fflu_data.get_number_field(pc_field_normal_volume);
      rv_detail.est_incremental_volume := fflu_data.get_number_field(pc_field_incremental_volume);
      rv_detail.est_marketing_adj_volume := fflu_data.get_number_field(pc_field_marketing_volume);
      rv_detail.est_state_phasing_volume := fflu_data.get_number_field(pc_field_state_phasing_volume);
      -- Derived Fields
      rv_detail.mars_week := pxi_e2e_demand.get_mars_week(fflu_data.get_date_field(pc_field_week_date));

      -- Check if the ZREP is valid.
      if pxi_e2e_demand.is_valid_zrep(rv_detail.stock_code) = false then 
        -- fflu_data.log_field_error(pc_field_stock_code,'Was not a valid ZREP Material Code.'); -- TODO ADD THIS LINE FOR PRODUCTION.
        v_ignore_row := true; -- TODO REMOVE FOR PRODUCTION.  This is to cater for dud test data.
      end if;

      -- Now perform the ignore row check.
      if abs(rv_detail.est_estimated_volume) + abs(rv_detail.est_normal_volume) + abs(rv_detail.est_incremental_volume) + abs(rv_detail.est_marketing_adj_volume) + abs(rv_detail.est_state_phasing_volume) = 0 then
        v_ignore_row := true;
      else 
        v_ignore_row := false;
      end if;

      -- If a row was successfully parsed and there have been no errors so far.
      if fflu_data.was_errors = false and v_ignore_row = false then 
        insert into pxi_estimate_detail values rv_detail;
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
  begin
    -- Only perform a commit if there were no errors at all.
    if fflu_data.was_errors then
      rollback;
    else
      commit;
      -- Now trigger the extract to Apollo.
      pxiapo01_extract.execute(pv_estimate_seq);
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

end pmxpxi04_loader;
/