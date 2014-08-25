create or replace package dfnapo01_extract as
/*******************************************************************************
* Package Definition                                                           *
********************************************************************************

  System  : IPS
  Package : DFNPXI01_EXTRACT
  Owner   : DF_APP
  Author  : Chris Horn

  Description
  -----------
  Demand Financials (Outbound) -> Apollo Supply (Inbound)

  This interface creates and outbound domestic forecast extract to be 
  sent to Apollo Supply. 

  As the extract cannot handle negatives or decimals all quantites
  are brought to zero and then rounded.

  Date        Author                Description
  ----------  --------------------  ---------------------------------------------
  2014-08-22  Chris Horn            Created.
  2014-08-25  Chris Horn            Completed first version.

*******************************************************************************/

/*******************************************************************************
  NAME: FORECAST_MOE                                                      PUBLIC
  PURPOSE : Function to return [moe_code] for a given [fcst_id]
*******************************************************************************/
  function forecast_moe(
    i_fcst_id in common.st_id
  ) return common.st_code;

/*******************************************************************************
  NAME:  FIRST_DATE_FCST_CASTING_WEEK                                     PUBLIC
*******************************************************************************/
  function first_date_mars_week(
    i_mars_week in common.st_count
  ) return date;

/*******************************************************************************
  NAME: GET_FORECAST                                                      PUBLIC
  PURPOSE : Pipeline to return the calculated forcast for interfacing.
*******************************************************************************/
  -- Record ype.
  type rt_forecast is record (
    -- Information Fields.
    fcst_id                         fcst.fcst_id%type,
    moe_code                        fcst.moe_code%type,
    dmnd_grp_code                   dmnd_grp.dmnd_grp_code%type,
    mars_week                       dmnd_data.mars_week%type,
    -- Actual Output Fields.
    tdu_matl_code                   dmnd_data.tdu%type,  -- Material Determined TDU code that needs to be shipped.
    plant_code                      common.st_code,      -- The plant code that we expect to ship this product from.
    start_date                      date,                -- This is the starting date in DD/MM/YYYY Sunday of this week. 
    qty                             common.st_value      -- This is the quantity that we expect to ship.  
  );

  -- Table for the extract.
  type tt_forecast is table of rt_forecast;
  
  -- Function to create the forecast extract.
  function get_forecast (
    i_fcst_id in common.st_id
  ) return tt_forecast pipelined;

/*******************************************************************************
  NAME: EXECUTE                                                           PUBLIC
  PURPOSE: Creates the outbound interface using get forecast.
*******************************************************************************/
  procedure execute(
    i_fcst_id in common.st_id
  );

end dfnapo01_extract;