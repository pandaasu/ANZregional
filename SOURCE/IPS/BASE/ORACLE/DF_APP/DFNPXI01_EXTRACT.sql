create or replace 
PACKAGE          DFNPXI01_EXTRACT as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : IPS
 Package : DFNPXI_EXTRACT
 Owner   : DF_APP
 Author  : Chris Horn

 Description
 -----------
   Demand Financials (Outbound) -> LADS (Passthrough) 
   -> Promax PX - Demand Base - PX Interface 355DMND
 
 Date        Author                Description
 ----------  --------------------  ---------------------------------------------
 2013-11-29  Chris Horn            Created.
 2013-12-01  Chris Horn            Completed first version.
 
*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This interface creates an extract of apollo base forecast 
             data.
  
             As the extract cannot handle negatives or decimals all quantites
             are brought to zero and then rounded.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2013-11-29 Chris Horn           Created.

*******************************************************************************/
   procedure execute(i_fcst_id in common.st_id);


/*******************************************************************************
  NAME:      ALLOCATE_DEMAND_DATA
  PURPOSE:   Using the Promax demand Lookup tables allocate out the forecast
             data to the demand planning nodes that are actually used in 
             promax for planning purposes. 
             
             This pipelined table function takes the input qty rounds it to a 
             whole number, and if less than zero makes it zero.  It then will 
             allocate based on lowest percentage split records out accordinly.
             The sum of the amounts allocated will always equal the rounded 
             positive numbers.  

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.0   2013-12-01 Chris Horn           Created.
  1.1   2013-12-02 Chris Horn           Completed.
  
*******************************************************************************/
  -- Hierarchy Node Record
  type rt_demand_data is record (
      forecast_customer common.st_code,
      zrep_matl_code common.st_code,
      forecast_start_date date,
      forecast_end_date date,
      base_sales_volume common.st_value
    );  
  -- Define the hierarchy table type.
  type tt_demand_data is table of rt_demand_data;
  -- The pipelined table function to return the product hierarchy nodes.
  function allocate_demand_data(
    i_dmnd_grp_code in common.st_code,
    i_bus_sgmnt_code in common.st_code,
    i_zrep in common.st_code,
    i_mars_week in common.st_code,
    i_qty in common.st_value
    ) return tt_demand_data pipelined;

end DFNPXI01_EXTRACT;