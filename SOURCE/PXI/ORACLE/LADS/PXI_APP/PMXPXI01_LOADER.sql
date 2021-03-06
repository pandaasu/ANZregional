create or replace 
package pmxpxi01_loader as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PMXPXI01_LOADER
  Author    : Chris Horn
  Interface : Promax PX Accruals to Atlas Interface

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
  2013-08-08  Jonathan Girling	    Updated Interface mapping
  2013-08-20  Chris Horn            Updated formatting and comments.
  2013-10-14  Chris Horn            Added amount = tax amount base for zero check.
  2013-11-04  Jonathan Girling      Updated pc_additional_info field in the 
                                    on_start procedure from 10 to 20.

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end pmxpxi01_loader;
/