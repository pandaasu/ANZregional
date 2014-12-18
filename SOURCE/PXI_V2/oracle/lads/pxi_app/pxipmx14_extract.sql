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
  + Exposed Internal Functions
    
  + Extract Functions
    - execute                    Called when the extract needs to be created.

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2014-12-18  Chris Horn            Created Interface
                                      
*******************************************************************************/

/*******************************************************************************
  Package Constants
*******************************************************************************/

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
/