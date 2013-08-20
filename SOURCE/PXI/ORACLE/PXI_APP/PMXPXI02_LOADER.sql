create or replace 
package          pmxpxi02_loader as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PMXPXI02_LOADER
  Author    : Chris Horn
  Interface : Promax PX Payments to Atlas Interface

  Description
  ------------------------------------------------------------------------------
  This package is used for processing Promax Payment information from Promax.
  It takes the information in the interface and determines if the information 
  is for AR Claims or for AP Payments.  
  
  It will then use the generic PXIATL01 Interface code to create a general 
  ledger document for on sending to Atlas.  
  
  Below is an example of the flow below. 

  Promax PX Payments 331 -> LADS (Inbound) -> Atlas PXIATL01 - AP Claims
                                           -> Atlas PXIATL01 - AP Payments

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
  2013-08-06  Jonathan Girling      Updated Interface mapping
  2013-08-06  Jonathan Girling		Updated No Tax Code from S3 to SE.

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end pmxpxi02_loader;