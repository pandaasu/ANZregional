CREATE OR REPLACE PACKAGE BODY pxi_e2e_demand AS 
/*******************************************************************************
  Package Constants
*******************************************************************************/  
  -- This is the name of this package.
  pc_package_name      constant pxi_common.st_package_name := 'PXI_E2E_DEMAND';
  
  -- Setting Constants
  pc_setting_config_err     constant st_lics_setting := 'CONFIG_ERR_REPROT_EMAIL_GROUP';
  pc_setting_baseline_err   constant st_lics_setting := 'BASELINE_ERR_EMAIL_GROUP';
  pc_setting_retention_days constant st_lics_setting := 'RETENTION_DAYS';

/*******************************************************************************
  Package Variables
*******************************************************************************/  

/*******************************************************************************
  Global Function Constants
*******************************************************************************/

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
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'GET_MOE_FROM_SUFFIX');
  end get_moe_from_suffix;


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
  begin
    null;  -- TODO  
  exception
    when others then 
      pxi_common.reraise_promax_exception(pc_package_name,'PERFORM_HOUSEKEEPING');
  end perform_housekeeping;

END pxi_e2e_demand;
/