create or replace package body flupxi01_loader as
/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- Package Name
  pc_package_name      constant pxi_common.st_package_name := 'FLUPXI01_LOADER';

  -- Interface Field Definitions
  pc_field_demand_group      constant fflu_common.st_name := 'Demand Group';
  pc_field_account_code      constant fflu_common.st_name := 'Account Code';
  pc_field_primary_account   constant fflu_common.st_name := 'Primary Account';
  pc_field_moe_code          constant fflu_common.st_name := 'MOE Code';

/*******************************************************************************
  Package Variables
*******************************************************************************/  
  pv_interface_suffix    fflu_common.st_interface;
  pv_expected_moe_code   pxi_common.st_moe_code;

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
    -- Now look up the expected moe code and delete all existing records from this table with the matching moe, will be rolled back if the input data does not match.
    pv_expected_moe_code := pxi_e2e_demand.get_moe_from_suffix(pv_interface_suffix);
    delete from pxi_demand_group_to_account where moe_code = pv_expected_moe_code;
    
    -- Now initialise the data parsing package.
    fflu_data.initialise(on_get_file_type,on_get_csv_qualifier,fflu_data.gc_file_header,fflu_data.gc_not_allow_missing);

    -- Detail Record - Fields
    fflu_data.add_char_field_del(pc_field_demand_group,1,pc_field_demand_group,1,50,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_account_code,2,pc_field_account_code,1,20,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_primary_account,3,pc_field_primary_account,1,1,fflu_data.gc_not_allow_null,fflu_data.gc_trim);
    fflu_data.add_char_field_del(pc_field_moe_code,4,pc_field_moe_code,1,10,fflu_data.gc_not_allow_null,fflu_data.gc_trim);

  exception
    when others then
      fflu_data.log_interface_exception('ON_START');
  end on_start;

/*******************************************************************************
  NAME:      ON_DATA                                                      PUBLIC
*******************************************************************************/
  procedure on_data(p_row in varchar2) is
    -- Row Variables
    rv_data pxi_demand_group_to_account%rowtype;
  begin
    -- Now parse the incoming record.
    if fflu_data.parse_data(p_row) = true then
      -- Complete the data assignment into the array.
      rv_data.demand_group := fflu_data.get_char_field(pc_field_demand_group);
      rv_data.account_code := lpad(fflu_data.get_char_field(pc_field_account_code),10,'0');
      rv_data.primary_account := upper(fflu_data.get_char_field(pc_field_primary_account));
      rv_data.moe_code := lpad(fflu_data.get_char_field(pc_field_moe_code),4,'0');
  
      -- Perform an expected moe check.
      if pv_expected_moe_code <> rv_data.moe_code then 
        fflu_data.log_field_error(pc_field_moe_code,'MOE Code did not match the expected moe code of [' || pv_expected_moe_code || '] for this interface.');
      end if;
      
      -- Check Primary Account Flag is Valid.
      if rv_data.primary_account not in ('Y','N') then
        fflu_data.log_field_error(pc_field_primary_account,'Needs to be Y for Yes or N for No.');
      end if;

      -- If a row was successfully parsed and there have been no errors so far.
      if fflu_data.was_errors = false then
        insert into pxi_demand_group_to_account values rv_data;
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
    return fflu_common.gc_file_type_csv;
  end on_get_file_type;

/*******************************************************************************
  NAME:      ON_GET_CSV_QUALIFIER                                         PUBLIC
*******************************************************************************/
  function on_get_csv_qualifier return varchar2 is
  begin
    return fflu_common.gc_csv_qualifier_double_quote;
  end on_get_csv_qualifier;

end flupxi01_loader;
/