create or replace 
package          pmxpxi01_loader as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PMXPXI01_LOADER
  Author    : Chris Horn
  Interface : Promax PX Payments to Atlas Interface

  Description
  ------------------------------------------------------------------------------
  This package is used for processing Promax Accrual information from Promax.
  
  It will then use the generic PXIATL01 Interface code to create a general 
  ledger document for on sending to Atlas.  
  
  Below is an example of the flow below. 
  
  Promax PX Accruals 325 -> LADS (Inbound) -> Atlas PXIATL01 - Accruals

  Functions
  ------------------------------------------------------------------------------
  + LICS Hooks 
    - on_start                   Called on starting the interface.
    - on_data(i_row in varchar2) Called for each row of data in the interface.
    - on_end                     Called at the end of processing.
  + FFLU Hooks
    - on_get_file_type           Returns the type of file format expected.
    - on_get_csv_qualifier       Returns the CSV file format qualifier.  

  Date        Author                Description
  ----------  --------------------  --------------------------------------------
  2013-07-30  Chris Horn            Created Interface

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end pmxpxi01_loader;