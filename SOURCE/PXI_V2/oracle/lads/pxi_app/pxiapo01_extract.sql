create or replace package pxiapo01_extract as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PXIAPO01_EXTRACT
  Author    : Chris Horn
  Interface : Promax PX Interfacing to Apollo Demand - Demand Data
  
  Description
  ------------------------------------------------------------------------------
  This package is used to load the uplift demand data from PXI to Apollo 
  Demand.  
  
  Functions
  ------------------------------------------------------------------------------
  + Exposed Internal Functions
    - pt_uplift_detail              Pipelined table to create uplift detail.
    - pt_uplift_extract             Pipelined table to create uplift extract.
    
  + Extract Functions
    - execute                       Called when the extract needs to be created.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2014-12-17  Chris Horn            Created Interface
                                      
*******************************************************************************/

/*******************************************************************************
  NAME:      PT_UPLIFT_DETAIL                                             PUBLIC
  PURPOSE:   This pipelined table function will create the data required for 
             uplift detail table.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-19 Chris Horn           Created.
*******************************************************************************/
  -- Uplift Details Table Type
  type tt_uplift_detail is table of pxi_uplift_detail%rowtype;
  -- Uplift Detail Pipelined Table Function
  function pt_uplift_detail(
    i_demand_seq in pxi_e2e_demand.st_sequence,
    i_estimate_seq in pxi_e2e_demand.st_sequence,
    i_uplift_seq in pxi_e2e_demand.st_sequence
    ) return tt_uplift_detail pipelined;

/*******************************************************************************
  NAME:      PT_UPLIFT_EXTRACT                                            PUBLIC
  PURPOSE:   This pipelined table function will create the correctly formatted
             output record for the Apollo Uplift File.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-19 Chris Horn           Created.
*******************************************************************************/
  -- Uplift Extract Record Type.
  type rt_uplift_extract is record (
    extract_data pxi_common.st_data
  );
  -- Uplift Extract Table Type
  type tt_uplift_extract is table of rt_uplift_extract;
  -- Uplift Extract Pipelined Table Function 
  function pt_uplift_extract(
    i_uplift_seq in pxi_e2e_demand.st_sequence
    ) return tt_uplift_extract pipelined;

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This procedures creates an extract for the Apollo Demand system.  
             The recently received estimate file is used as a trigger for the
             extract to be created.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-18 Chris Horn           Created.
  1.2   2014-12-19 Chris Horn           Completed Extract Code.
*******************************************************************************/
  procedure execute(
    i_estimate_seq in pxi_e2e_demand.st_sequence);

end pxiapo01_extract;
/