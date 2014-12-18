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
    
  + Extract Functions
    - execute                    Called when the extract needs to be created.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2014-12-17  Chris Horn            Created Interface
                                      
*******************************************************************************/

/*******************************************************************************
  NAME:      EXECUTE                                                      PUBLIC
  PURPOSE:   This procedures creates an extract for the Apollo Demand system.  
             The recently received estimate file is used as a trigger for the
             extract to be created.

  REVISIONS:
  Ver   Date       Author               Description
  ----- ---------- -------------------- ----------------------------------------
  1.1   2014-12-18 Chris Horn           Created.
*******************************************************************************/
  procedure execute(
    i_estimate_seq in pxi_e2e_demand.st_sequence);

end pxiapo01_extract;
/