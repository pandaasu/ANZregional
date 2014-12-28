create or replace package pxi_e2e_demand as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System  : PXI - Promax PX Interfacing System
  Owner   : PXI
  Package : PXI_E2E_DEMAND
  Author  : Chris Horn

  Description
  ------------------------------------------------------------------------------
  This function provides a number of common end to end demand common processing
  and lookup functions.

  Functions
  ------------------------------------------------------------------------------
  + Utility Functions
    - is_valid_suffix              Check if the interfacing suffix is valid.
    - get_moe_from_suffix          This function fetches the moe code.
    - get_suffix_from_moe          This function fetches the suffix code.
    - get_moe_from_demand_unit     Extracts Moe code from demand unit.
    - get_zrep_from_demand_unit    Extracts ZREP code from demand unit.
    - get_location_code            Lookups location code from moe attributes.
    - get_demand_group             Lookups up a demand group.
    - get_account_code             Lookups up primary account code.
    - short_account_code           Returns a trimmed account code.
    - get_mars_week                Returns mars week for corresponding date.
    - get_week_date                Returns the first day of a given mars week.
    - is_valid_zrep                Returns if the ZREP is known in LADS.
  + ICS Settings Functions
    - get_config_err_email_group   Returns email address for config errors.
    - get_baseline_err_email_group Returns email address for baseline errors. 
    - get_retention_days           Returns days to retain data for.
  + Other Functions
    - perform_housekeeping         A scheduled job to house keep data files.

  Date        Author               Description
  ----------  -------------------  --------------------------------------------
  2014-12-11  Chris Horn           Created first version of this package.
  2014-12-16  Chris Horn           Added ICS setting retrieve functions.
  2014-12-19  Chris Horn           Added various utility functions.
  2014-12-22  Chris Horn           Added constant for email sending.
  2014-12-23  Chris Horn           Created perform house keeping.

*******************************************************************************/

/*******************************************************************************
** Package Types   
*******************************************************************************/
  subtype st_lics_setting is varchar2(32 byte);
  subtype st_lics_setting_value is varchar2(256 byte);
  subtype st_days is number(5,0);
  subtype st_sequence is number(15,0);
  subtype st_type_code is number(1,0);
  subtype st_mars_week is number(7,0);
  subtype st_counter is pls_integer;
  subtype st_demand_code is varchar2(50 byte);
  subtype st_flag is varchar2(1 byte);
  
/*******************************************************************************
  Global Constants
*******************************************************************************/
  -- Apollo Type Codes
  gc_type_1_base       st_type_code := 1; -- Base                              #
  gc_type_2_aggregate  st_type_code := 2; -- Aggregate Market Activity
  gc_type_3_lock       st_type_code := 3; -- Lock
  gc_type_4_reconcile  st_type_code := 4; -- Reconcile                         #
  gc_type_5_auto_adj   st_type_code := 5; -- Auto Adjustment
  gc_type_6_override   st_type_code := 6; -- Override                          #
  gc_type_7_market     st_type_code := 7; -- Market Activity                   *
  gc_type_8_data_event st_type_code := 8; -- Data Driven Event
  gc_type_9_impacts    st_type_code := 9; -- Target Impacts.
  -- # 1,4,6 Apollo Demand Baseline -> Sent to Promax
  -- * 7 Promax Uplift -> Sent to Apollo Demand
  -- Sender Codes
  gc_email_sender      st_lics_setting_value := 'AP.Applications.Support@effem.com'; 
  -- Flags
  gc_yes               st_flag := 'Y';
  gc_no                st_flag := 'N';
  
/*******************************************************************************
  Global Function Constants
*******************************************************************************/
  -- Base Type
  function fc_type_1_base         return st_type_code;
  function fc_type_2_aggregate    return st_type_code;
  function fc_type_3_lock         return st_type_code;
  function fc_type_4_reconcile    return st_type_code;
  function fc_type_5_auto_adj     return st_type_code;
  function fc_type_6_override     return st_type_code;
  function fc_type_7_market       return st_type_code;
  function fc_type_8_data_event   return st_type_code;
  function fc_type_9_impacts      return st_type_code;
  -- Flags
  function fc_yes                 return st_flag;
  function fc_no                  return st_flag;


/*******************************************************************************
  NAME:      IS_VALID_SUFFIX                                              PUBLIC
  PURPOSE:   To check if the supplied suffix is in the moe attribute table as
             a valid suffix.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-10 Chris Horn           Created
*******************************************************************************/
  function is_valid_suffix(
    i_interface_suffix in pxi_common.st_interface_name) return boolean;

/*******************************************************************************
  NAME:      GET_MOE_FROM_SUFFIX                                          PUBLIC
  PURPOSE:   Returns a MOE Code from the Interface Suffix Information.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-10 Chris Horn           Created
*******************************************************************************/
  function get_moe_from_suffix(
    i_interface_suffix in pxi_common.st_interface_name) 
    return pxi_common.st_moe_code;

/*******************************************************************************
  NAME:      GET_SUFFIX_FROM_MOE                                          PUBLIC
  PURPOSE:   Returns a Interface Suffix Code from the Moe Code Information.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-19 Chris Horn           Created
*******************************************************************************/
  function get_suffix_from_moe(
    i_moe_code in pxi_common.st_moe_code) 
    return pxi_common.st_interface_name;

/*******************************************************************************
  NAME:      GET_MOE_FROM_DEMAND_UNIT                                     PUBLIC
  PURPOSE:   Returns a moe code from the demand unit syntax.  {zrep}_{moe}.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-16 Chris Horn           Created
*******************************************************************************/
  function get_moe_from_demand_unit(
    i_demand_unit in pxi_common.st_material) 
    return pxi_common.st_moe_code;

/*******************************************************************************
  NAME:      GET_DEMAND_GROUP                                             PUBLIC
  PURPOSE:   Returns a demand group from a supplied moe and customer account.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-19 Chris Horn           Created
*******************************************************************************/
  function get_demand_group(
    i_moe_code in pxi_common.st_moe_code,
    i_account_code in pxi_common.st_customer) 
    return st_demand_code;

/*******************************************************************************
  NAME:      GET_LOCATION_CODE                                            PUBLIC
  PURPOSE:   Returns the demand location code from the Moe Attributes table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-19 Chris Horn           Created
*******************************************************************************/
  function get_location_code(
    i_moe_code in pxi_common.st_moe_code) 
    return st_demand_code;

    
/*******************************************************************************
  NAME:      GET_ACCOUNT_CODE                                             PUBLIC
  PURPOSE:   Returns the primary account code for a given demand group.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-19 Chris Horn           Created
*******************************************************************************/
  function get_account_code (
    i_moe_code in pxi_common.st_moe_code,
    i_demand_group in st_demand_code) 
    return pxi_common.st_customer;

/*******************************************************************************
  NAME:      SHORT_ACCOUNT_CODE                                           PUBLIC
  PURPOSE:   Returns a shortened account code.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-23 Chris Horn           Created
*******************************************************************************/
  function short_account_code (
    i_account_code in pxi_common.st_customer) 
    return pxi_common.st_customer;

/*******************************************************************************
  NAME:      GET_ZREP_FROM_DEMAND_UNIT                                    PUBLIC
  PURPOSE:   Returns a ZREP code from the demand unit syntax.  {zrep}_{moe}.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-16 Chris Horn           Created
*******************************************************************************/
  function get_zrep_from_demand_unit(
    i_demand_unit in pxi_common.st_material) 
    return pxi_common.st_material;

/*******************************************************************************
  NAME:      GET_MARS_WEEK                                                PUBLIC
  PURPOSE:   Taking a date returns a mars week.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-16 Chris Horn           Created
*********************F**********************************************************/
  function get_mars_week(
    i_date in date) 
    return st_mars_week;

/*******************************************************************************
  NAME:      GET_WEEK_DATE                                                PUBLIC
  PURPOSE:   Returns the first day of a given mars week.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-19 Chris Horn           Created
*******************************************************************************/
  function get_week_date(
    i_mars_week in st_mars_week) 
    return date;

/*******************************************************************************
  NAME:      IS_VALID_ZREP                                                PUBLIC
  PURPOSE:   This function checks the BDS Material tables to see that the 
             material code provided is ZREP Tradded Unit material.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-18 Chris Horn           Created
*******************************************************************************/
  function is_valid_zrep(
    i_material_code in pxi_common.st_material) return boolean;


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
    ) return st_lics_setting; 

/*******************************************************************************
  NAME:      GET_CONFIG_ERR_EMAIL_GROUP                                   PUBLIC
  PURPOSE:   Returns the ICS setting CONFIG_ERR_REPORT_EMAIL_GROUP for the 
             nominated Promax PX System Code.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-16 Chris Horn           Created
*******************************************************************************/
  function get_config_err_email_group (
    i_system_code in st_lics_setting) 
    return st_lics_setting_value;


/*******************************************************************************
  NAME:      GET_BASELINE_ERR_EMAIL_GROUP                                 PUBLIC
  PURPOSE:   Returns the ICS setting BASELINE_ERR_REPORT_EMAIL_GROUP for the 
             nominated Promax PX System Code.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-16 Chris Horn           Created
*******************************************************************************/
  function get_baseline_email_group (
    i_system_code in st_lics_setting) 
    return st_lics_setting_value;

/*******************************************************************************
  NAME:      GET_RETENTION_DAYS                                           PUBLIC
  PURPOSE:   Returns the ICS setting RETENTION_DAYS for the 
             nominated Promax PX System Code.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-16 Chris Horn           Created
*******************************************************************************/
  function get_retention_days (
    i_system_code in st_lics_setting) 
    return st_days;

/*******************************************************************************
  NAME:      PERFORM_HOUSEKEEPIN                                          PUBLIC
  PURPOSE:   Performs house keeping on various data tables and retains data
             as per get retention days function.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2014-12-16 Chris Horn           Created
  1.1   2014-12-23 Chris Horn           Implemented function.
*******************************************************************************/
  procedure perform_housekeeping;

end pxi_e2e_demand;
/