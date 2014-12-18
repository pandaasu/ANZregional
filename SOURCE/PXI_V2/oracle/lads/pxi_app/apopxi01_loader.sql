create or replace package apopxi01_loader as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : APOPXI01_LOADER
  Author    : Chris Horn
  Interface : Apollo Dmeand to Promax PX Interfacing - Demand Data
  
  Description
  ------------------------------------------------------------------------------
  This package is used to load the demand data from Apollo into PXI Lads Schema
  tables.
  
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
  2014-12-16  Chris Horn            Created Interface
                                      
*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;
    
end apopxi01_loader;
/