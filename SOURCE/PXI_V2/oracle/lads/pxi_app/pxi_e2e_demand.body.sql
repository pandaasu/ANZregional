CREATE OR REPLACE PACKAGE BODY pxi_e2e_demand AS 
/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- This is the name of this package.
  pc_package_name      constant pxi_common.st_package_name := 'PXI_E2E_DEMAND';
  
  -- Setting Constants
  pc_setting_config_err     constant st_lics_setting := 'CONFIG_ERR_REPORT_EMAIL_GROUP';
  pc_setting_baseline_err   constant st_lics_setting := 'BASELINE_ERR_EMAIL_GROUP';
  pc_setting_retention_days constant st_lics_setting := 'RETENTION_DAYS';

/*******************************************************************************
  Package Variables
*******************************************************************************/  

/*******************************************************************************
  Global Function Constants
*******************************************************************************/
  -- Apollo Type Codes
  function fc_type_1_base         return st_type_code is begin return gc_type_1_base; end fc_type_1_base;
  function fc_type_2_aggregate    return st_type_code is begin return gc_type_2_aggregate; end fc_type_2_aggregate;
  function fc_type_3_lock         return st_type_code is begin return gc_type_3_lock; end fc_type_3_lock;
  function fc_type_4_reconcile    return st_type_code is begin return gc_type_4_reconcile; end fc_type_4_reconcile;
  function fc_type_5_auto_adj     return st_type_code is begin return gc_type_5_auto_adj; end fc_type_5_auto_adj;
  function fc_type_6_override     return st_type_code is begin return gc_type_6_override; end fc_type_6_override;
  function fc_type_7_market       return st_type_code is begin return gc_type_7_market; end fc_type_7_market;
  function fc_type_8_data_event   return st_type_code is begin return gc_type_8_data_event; end fc_type_8_data_event;
  function fc_type_9_impacts      return st_type_code is begin return gc_type_9_impacts; end fc_type_9_impacts;
  -- Flags
  function fc_yes                 return st_flag is begin return gc_yes; end fc_yes;
  function fc_no                  return st_flag is begin return gc_no; end fc_no;
/*******************************************************************************
  NAME:      IS_VALID_SUFFIX                                              PUBLIC
*******************************************************************************/
  function is_valid_suffix(
    i_interface_suffix in pxi_common.st_interface_name) return boolean is 
    v_result boolean;
    cursor csr_moe_attributes is select * from pxi_moe_attributes where interface_suffix = i_interface_suffix;
    rv_moe_attributes csr_moe_attributes%rowtype;
  begin
    v_result := false;
    open csr_moe_attributes;
    fetch csr_moe_attributes into rv_moe_attributes;
    if csr_moe_attributes%found = true then 
      v_result := true;
    end if;
    close csr_moe_attributes;
    return v_result;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'IS_VALID_SUFFIX');
  end is_valid_suffix;

/*******************************************************************************
  NAME:      GET_MOE_FROM_SUFFIX                                          PUBLIC
*******************************************************************************/
  function get_moe_from_suffix(
    i_interface_suffix in pxi_common.st_interface_name) 
    return pxi_common.st_moe_code is 
    v_result pxi_common.st_moe_code;
    cursor csr_moe_attributes is select * from pxi_moe_attributes where interface_suffix = i_interface_suffix;
    rv_moe_attributes csr_moe_attributes%rowtype;
  begin
    v_result := '';
    open csr_moe_attributes;
    fetch csr_moe_attributes into rv_moe_attributes;
    if csr_moe_attributes%found = true then 
      v_result := rv_moe_attributes.moe_code;
    end if;
    return v_result;
    close csr_moe_attributes;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_MOE_FROM_SUFFIX');
  end get_moe_from_suffix;

/*******************************************************************************
  NAME:      GET_LOCATION_CODE                                            PUBLIC
*******************************************************************************/
  function get_location_code(
    i_moe_code in pxi_common.st_moe_code) 
    return st_demand_code is
    v_result st_demand_code;
    cursor csr_moe_attributes is select * from pxi_moe_attributes where moe_code = i_moe_code;
    rv_moe_attributes csr_moe_attributes%rowtype;
  begin
    v_result := '';
    open csr_moe_attributes;
    fetch csr_moe_attributes into rv_moe_attributes;
    if csr_moe_attributes%found = true then 
      v_result := rv_moe_attributes.location_code;
    end if;
    return v_result;
    close csr_moe_attributes;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_LOCATION_CODE');
  end get_location_code;

/*******************************************************************************
  NAME:      GET_SUFFIX_FROM_MOE                                          PUBLIC
*******************************************************************************/
  function get_suffix_from_moe(
    i_moe_code in pxi_common.st_moe_code) 
    return pxi_common.st_interface_name is 
    v_result pxi_common.st_interface_name;
    cursor csr_moe_attributes is select * from pxi_moe_attributes where moe_code = i_moe_code;
    rv_moe_attributes csr_moe_attributes%rowtype;
  begin
    v_result := '';
    open csr_moe_attributes;
    fetch csr_moe_attributes into rv_moe_attributes;
    if csr_moe_attributes%found = true then 
      v_result := rv_moe_attributes.interface_suffix;
    end if;
    close csr_moe_attributes;
    return v_result;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_SUFFIX_FROM_MOE');
  end get_suffix_from_moe;

/*******************************************************************************
  NAME:      GET_SYSTEM_CODE                                              PUBLIC
  PURPOSE:   This function returns the system code associated with this moe.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-19 Chris Horn           Created
*******************************************************************************/
  function get_system_code (
    i_moe_code in pxi_common.st_moe_code
    ) return st_lics_setting is 
    v_result st_lics_setting;
    cursor csr_moe_attributes is select * from pxi_moe_attributes where moe_code = i_moe_code;
    rv_moe_attributes csr_moe_attributes%rowtype;
  begin
    v_result := '';
    open csr_moe_attributes;
    fetch csr_moe_attributes into rv_moe_attributes;
    if csr_moe_attributes%found = true then 
      v_result := rv_moe_attributes.system_code;
    end if;
    close csr_moe_attributes;
    return v_result;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_SYSTEM_CODE');
  end get_system_code;

/*******************************************************************************
  NAME:      GET_DEMAND_GROUP                                             PUBLIC
*******************************************************************************/
  function get_demand_group(
    i_moe_code in pxi_common.st_moe_code,
    i_account_code in pxi_common.st_customer) 
    return st_demand_code is
    v_demand_group st_demand_code;
    -- Cursor to find the demand group.
    cursor csr_demand_group is 
      select demand_group from pxi_demand_group_to_account 
      where 
        moe_code = i_moe_code and 
        account_code = pxi_common.full_cust_code(i_account_code);
  begin
    open csr_demand_group;
    fetch csr_demand_group into v_demand_group;
    if csr_demand_group%notfound = true then 
      v_demand_group := null;
    end if;
    close csr_demand_group;
    return v_demand_group;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_DEMAND_GROUP');
  end get_demand_group;

/*******************************************************************************
  NAME:      GET_ACCOUNT_CODE                                             PUBLIC
*******************************************************************************/
  function get_account_code(
    i_moe_code in pxi_common.st_moe_code,
    i_demand_group in st_demand_code) 
    return pxi_common.st_customer is
    v_account_code pxi_common.st_customer;
    -- Cursor to find the demand group.
    cursor csr_account_code is 
      select 
        account_code 
      from 
        pxi_demand_group_to_account 
      where 
        moe_code = i_moe_code and 
        demand_group = i_demand_group and 
        primary_account = 'Y';
  begin
    open csr_account_code;
    fetch csr_account_code into v_account_code;
    if csr_account_code%notfound = true then 
      v_account_code := null;
    end if;
    close csr_account_code;
    return v_account_code;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_ACCOUNT_CODE');
  end get_account_code;

/*******************************************************************************
  NAME:      SHORT_ACCOUNT_CODE                                           PUBLIC
*******************************************************************************/
  function short_account_code (
    i_account_code in pxi_common.st_customer) 
    return pxi_common.st_customer is 
  begin
    return trim (ltrim (i_account_code, '0') );
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'SHORT_ACCOUNT_CODE');    
  end short_account_code;

/*******************************************************************************
  NAME:      GET_MOE_FROM_DEMAND_UNIT                                     PUBLIC
*******************************************************************************/
  function get_moe_from_demand_unit(
    i_demand_unit in pxi_common.st_material) 
    return pxi_common.st_moe_code is
    v_moe_code pxi_common.st_moe_code;
    v_position st_counter;
  begin
    v_moe_code := null;
    v_position := instr(i_demand_unit,'_');
    if v_position > 0 and v_position < length(i_demand_unit) then 
      v_moe_code := substr(i_demand_unit,v_position+1);
    end if;
    return v_moe_code;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_MOE_CODE_FROM_DEMAND_UNIT');
  end get_moe_from_demand_unit;

/*******************************************************************************
  NAME:      GET_ZREP_FROM_DEMAND_UNIT                                    PUBLIC
*******************************************************************************/
  function get_zrep_from_demand_unit(
    i_demand_unit in pxi_common.st_material) 
    return pxi_common.st_material is
    v_zrep_code pxi_common.st_material;
    v_position st_counter;
  begin
    v_zrep_code := null;
    v_position := instr(i_demand_unit,'_');
    if v_position > 1 then 
      v_zrep_code := substr(i_demand_unit,1,v_position-1);
    end if;
    return v_zrep_code;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_ZREP_FROM_DEMAND_UNIT');
  end get_zrep_from_demand_unit;

/*******************************************************************************
  NAME:      GET_MARS_WEEK                                                PUBLIC
*******************************************************************************/
  function get_mars_week(
    i_date in date)
    return st_mars_week is
    v_mars_week st_mars_week;
  begin
    -- Basic quick select of the mars week for a given date. 
    select mars_week into v_mars_week from mars_date where calendar_date = trunc(i_date);
    return v_mars_week;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_MARS_WEEK');
  end get_mars_week;

/*******************************************************************************
  NAME:      GET_MARS_WEEK                                                PUBLIC
*******************************************************************************/
  function get_week_date(
    i_mars_week in st_mars_week)
    return date is
    v_week_date date;
  begin
    -- Basic quick select of the mars week for a given date. 
    select min(calendar_date) into v_week_date from mars_date where mars_week = i_mars_week;
    return v_week_date;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_WEEK_DATE');
  end get_week_date;



/*******************************************************************************
  NAME:      IS_VALID_ZREP                                                PUBLIC
*******************************************************************************/
  function is_valid_zrep(
    i_material_code in pxi_common.st_material) return boolean is
    -- Used to perform a matl code validation.
    cursor csr_matl_code IS
      select sap_material_code from bds_material_hdr
      where material_type = 'ZREP' and mars_traded_unit_flag = 'X'
        and sap_material_code = pxi_common.full_matl_code (i_material_code);
      rv_matl_code csr_matl_code%ROWTYPE;
    v_result boolean;
  begin
    v_result := false;
    -- Now perform the matl code validation
    open csr_matl_code;
    fetch csr_matl_code into rv_matl_code;
    if csr_matl_code%found = true then
      v_result := true;
    end if;
    close csr_matl_code; 
    return v_result;  
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'IS_VALID_ZREP');
  end is_valid_zrep;

/*******************************************************************************
  NAME:      GET_CONFIG_ERR_EMAIL_GROUP                                   PUBLIC
*******************************************************************************/
  function get_config_err_email_group (
    i_system_code in st_lics_setting) 
    return st_lics_setting_value is
    v_setting st_lics_setting_value;
  begin
    if i_system_code is null then 
      pxi_common.raise_promax_error(pc_package_name,'GET_CONFIG_ERR_EMAIL_GROUP','System Code ['||i_system_code||'] was not defined.');
    end if;
    v_setting := lics_setting_configuration.retrieve_setting(i_system_code, pc_setting_config_err);
    if v_setting is null then
      pxi_common.raise_promax_error(pc_package_name,'GET_CONFIG_ERR_EMAIL_GROUP','System Code ['||i_system_code||'].['||pc_setting_config_err || '] was not found in ICS Settings.');
    end if;
    return v_setting;
  end get_config_err_email_group;


/*******************************************************************************
  NAME:      GET_BASELINE_ERR_EMAIL_GROUP                                 PUBLIC
*******************************************************************************/
  function get_baseline_email_group (
    i_system_code in st_lics_setting) 
    return st_lics_setting_value is
    v_setting st_lics_setting_value;
  begin
    if i_system_code is null then 
      pxi_common.raise_promax_error(pc_package_name,'GET_BASELINE_ERR_EMAIL_GROUP','System Code ['||i_system_code||'] was not defined.');
    end if;
    v_setting := lics_setting_configuration.retrieve_setting(i_system_code, pc_setting_baseline_err);
    if v_setting is null then
      pxi_common.raise_promax_error(pc_package_name,'GET_BASELINE_ERR_EMAIL_GROUP','System Code ['||i_system_code||'].['||pc_setting_baseline_err || '] was not found in ICS Settings.');
    end if;
    return v_setting;
  end get_baseline_email_group;
  

/*******************************************************************************
  NAME:      GET_RETENTION_DAYS                                           PUBLIC
*******************************************************************************/
  function get_retention_days (
    i_system_code in st_lics_setting) 
    return st_days is
    v_setting st_lics_setting_value;
    v_days st_days;
  begin
    if i_system_code is null then 
      pxi_common.raise_promax_error(pc_package_name,'GET_RETENTION_DAYS','System Code ['||i_system_code||'] was not defined.');
    end if;
    v_setting := lics_setting_configuration.retrieve_setting(i_system_code, pc_setting_retention_days);
    if v_setting is null then
      pxi_common.raise_promax_error(pc_package_name,'GET_RETENTION_DAYS','System Code ['||i_system_code||'].['||pc_setting_retention_days || '] not found in ICS Settings.');
    end if;
    -- Now convert the setting to a number of days. 
    begin
      v_days := to_number(v_setting);
    exception 
      when others then 
        pxi_common.raise_promax_error(pc_package_name,'GET_RETENTION_DAYS','System Code ['||i_system_code||'].['||pc_setting_retention_days || '], value [' || v_setting || '] could not be convered to a number of days.');
    end;
    return v_days;
  end get_retention_days;

/*******************************************************************************
  NAME:      PERFORM_HOUSEKEEPING                                         PUBLIC
*******************************************************************************/
  procedure perform_housekeeping is
    cursor csr_systems is select system_code,moe_code from pxi_moe_attributes; 
    rv_system csr_systems%rowtype;
    
    -- Now perform the house keeping associated this this specific system.
    procedure perform_system_housekeeping is
      v_days st_days;
      cursor csr_demand is select demand_seq from pxi_demand_header where modify_date < sysdate-v_days and moe_code = rv_system.moe_code;
      cursor csr_estimate is select estimate_seq from pxi_estimate_header where modify_date < sysdate-v_days and moe_code = rv_system.moe_code;
      cursor csr_uplift is select uplift_seq from pxi_uplift_header where modify_date < sysdate-v_days and moe_code = rv_system.moe_code;
      v_sequence st_sequence;
    begin
      -- Get the number of days retention
      v_days := get_retention_days(rv_system.system_code);
      -- Now delete demand data.
      loop
        v_sequence := null;
        open csr_demand;
        fetch csr_demand into v_sequence;
        close csr_demand;
        exit when v_sequence is null;
        -- Perform the specific demand deletes.
        delete from pxi_demand_detail where demand_seq = v_sequence;
        delete from pxi_demand_header where demand_seq = v_sequence;
        commit;
      end loop;
      -- Now delete estimate data.
      loop
        v_sequence := null;
        open csr_estimate;
        fetch csr_estimate into v_sequence;
        close csr_estimate;
        exit when v_sequence is null;
        -- Perform the specific demand deletes.
        delete from pxi_estimate_detail where estimate_seq = v_sequence;
        delete from pxi_estimate_header where estimate_seq = v_sequence;
        commit;
      end loop;
      -- Now delete uplift data.
      loop
        v_sequence := null;
        open csr_uplift;
        fetch csr_uplift into v_sequence;
        close csr_uplift;
        exit when v_sequence is null;
        -- Perform the specific demand deletes.
        delete from pxi_uplift_detail where uplift_seq = v_sequence;
        delete from pxi_uplift_header where uplift_seq = v_sequence;
        commit;
      end loop;
    end perform_system_housekeeping;
    
  begin
    -- Iterate around the list of all the system codes.
    open csr_systems;
    loop
      fetch csr_systems into rv_system;
      exit when csr_systems%notfound = true;
      -- Now perform the system house keeping.
      perform_system_housekeeping;
    end loop;
    close csr_systems;
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'PERFORM_HOUSEKEEPING');
  end perform_housekeeping;

END pxi_e2e_demand;
/