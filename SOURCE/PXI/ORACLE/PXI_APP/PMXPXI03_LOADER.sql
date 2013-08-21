create or replace 
package pmxpxi03_loader as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PMXPXI03_LOADER
  Author    : Jonathan Girling
  Interface : Promax PX Promotions to Atlas Interface

  Description
  ------------------------------------------------------------------------------
  This package is used for processing Promax Promotion information from Promax.
  It takes the information in the interface and determines if the information 
  is for AR Claims or for AP Payments.  
  
  Below is an example of the flow below. 

  Promax PX Promotions 359 -> LADS (Inbound) -> Atlas PXIATL02 - Pricing Conditions

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
  2013-08-02  Jonathan Girling      Created Interface
  2013-08-15  Mal Chambeyron        Added deletion / synchronization logic.
  2013-08-21  Chris Horn            Basic Clean Up.

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

  procedure execute(p_xactn_seq in number);
  
end pmxpxi03_loader;
/