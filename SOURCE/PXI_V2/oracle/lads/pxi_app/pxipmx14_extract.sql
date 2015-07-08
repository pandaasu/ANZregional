create or replace package pxipmx14_extract as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PXIPMX14_EXTRACT
  Author    : Chris Horn
  Interface : Promax PX Interfacing to Promax PX - External Baseline

  Description
  ------------------------------------------------------------------------------
  This package is used to load the the demand forecast to promax.

  Functions
  ------------------------------------------------------------------------------
  + Exposed Internal Pipelined Table Functions
    - pt_baseline                   Retrieves the Capped baseline data.
    - pt_baseline_extract           Retrieves the baseline promax formatted data.
    - pt_baseline_error_report      Retrieves the errors with baseline data.
  + Exposed Internal Procedures
    - update_baseline               Updates the baseline with the latest demand.
    - validate_promax_account_skus  Checks the accounts and skus are valid.
    - create_extract                Creates an extract based on baseline data.
    - create_baseline_error_report  Creates email report of baseline errors.
    - create_config_error_report    Creates email report of configuration errors.
  + Extract Functions
    - execute                       Called when the extract needs to be created.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2014-12-18  Chris Horn            Created Interface
  2014-12-23  Chris Horn            Implemented the extract.
  2014-12-24  Chris Horn            Completed the extract.
  2015-07-08  Chris Horn            Fixed bug, overzealous baseline zero'ing.
  
*******************************************************************************/

/*******************************************************************************
  Package Constants
*******************************************************************************/

/*******************************************************************************
  NAME:      PT_MARS_WEEK                                                 PUBLIC
  PURPOSE:   Pipeline to return Mars Week Start / Stop Dates for future plus
             last two years.  Dates are skewed for a Monday - Sunday Week.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  -- Mars Week Record Type
  type rt_mars_week is record (
    mars_week                       mars_date.mars_week%type,
    start_date                      mars_date.calendar_date%type,
    end_date                        mars_date.calendar_date%type
  );
  -- Mars Week Table Type
  type tt_mars_weeks is table of rt_mars_week;
  -- Mars Weeks Pipeline Table Function
  function pt_mars_weeks return tt_mars_weeks pipelined;

/*******************************************************************************
  NAME:      UPDATE_BASELINE                                              PUBLIC
  PURPOSE:   Takes a new demand file and updates the baseline data with the
             latest information.  This function will delete any data older than
             20 periods as a part of the update.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  procedure update_baseline(
    i_demand_seq in pxi_e2e_demand.st_sequence);

/*******************************************************************************
  NAME:      VALIDATE_PROMAX_ACCOUNT_SKUS                                 PUBLIC
  PURPOSE:   This function will check all the baseline accoun

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  procedure validate_promax_account_skus(
    i_moe_code in pxi_common.st_moe_code);

/*******************************************************************************
  NAME:      PT_BASELINE                                                  PUBLIC
  PURPOSE:   Takes the caculated baseline data and orders it and adds demand
             capping records as required.  Demand capping is used to send a zero
             records for all missing locations in the baseline account sku
             combinations within the minium and maximum weeks of the current
             baseline data.  Any records that do not have a Y on Has Account,
             Sku, Account Sku will be skipped.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  -- Baseline Extract Table Type
  type tt_baseline is table of pxi_baseline%rowtype;
  -- Baseline Extract Pipelined Table Function
  function pt_baseline(
    i_moe_code in pxi_common.st_moe_code
    ) return tt_baseline pipelined;

/*******************************************************************************
  NAME:      PT_BASELINE_EXTRACT                                          PUBLIC
  PURPOSE:   This pipelined table function will create the correctly formatted
             output record for the Promax 355 External Baseline file.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  -- Baseline Extract Record Type.
  type rt_baseline_extract is record (
    extract_data pxi_common.st_data
  );
  -- Baseline Extract Table Type
  type tt_baseline_extract is table of rt_baseline_extract;
  -- Baseline Extract Pipelined Table Function
  function pt_baseline_extract(
    i_moe_code in pxi_common.st_moe_code
    ) return tt_baseline_extract pipelined;

/*******************************************************************************
  NAME:      CREATE_EXTRACT                                               PUBLIC
  PURPOSE:   This procedure actually creates the extract and sends to it to
             promax via ICS Lads.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  procedure create_extract(
    i_moe_code in pxi_common.st_moe_code);

/*******************************************************************************
  NAME:      PT_BASELINE_ERROR_REPORT                                     PUBLIC
  PURPOSE:   This pipelined table function will create a record set of errors.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  -- Error Report Record Type
  type rt_baseline_error_report is record (
    sort_seq                        pxi_e2e_demand.st_sequence,
    error_desc                      pxi_common.st_data,
    account_code                    pxi_baseline.account_code%type,
    demand_group                    pxi_baseline.demand_group%type,
    zrep_code                       pxi_baseline.zrep_code%type,
    zrep_desc                       bds_material_hdr.bds_material_desc_en%type,
    start_date                      pxi_baseline.start_date%type,
    stop_date                       pxi_baseline.stop_date%type,
    record_count                    pxi_e2e_demand.st_sequence,
    volume                          pxi_baseline.volume%type
  );
  -- Error Report Table Type
  type tt_baseline_error_report is table of rt_baseline_error_report;
  -- Pipeline Table Function
  function pt_baseline_error_report (
    i_moe_code in pxi_common.st_moe_code
  ) return tt_baseline_error_report pipelined;

/*******************************************************************************
  NAME:      EMAIL_BASELINE_ERROR_REPORT                                  PUBLIC
  PURPOSE:   This procedure will look at the baseline table and report any
             missing account, missing sku or missing account sku mappings within
             promax.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  procedure email_baseline_error_report(
    i_moe_code in pxi_common.st_moe_code);

/*******************************************************************************
  NAME:      EMAIL_CONFIG_ERROR_REPORT                                    PUBLIC
  PURPOSE:   This procedure report on any missing demand group to account
             configuration errors.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-23 Chris Horn           Created.
*******************************************************************************/
  procedure email_config_error_report(
    i_demand_seq in pxi_e2e_demand.st_sequence);

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This procedures creates an extract for the Promax PX using the
             supplied Apollo Demand file as a base.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-18 Chris Horn           Created.
*******************************************************************************/
  procedure execute(
    i_demand_seq in pxi_e2e_demand.st_sequence);

end pxipmx14_extract;