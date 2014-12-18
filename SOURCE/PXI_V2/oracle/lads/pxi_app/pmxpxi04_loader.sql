create or replace package pmxpxi04_loader as
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : PMXPXI04_LOADER
  Author    : Chris Horn
  Interface : Promax PX to Promax PX Interfacing - 337 Estimates File
  
  Description
  ------------------------------------------------------------------------------
  This package is used to load an estimates file from Promax PX into the 
  estimates table.
  
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
  2014-12-18  Chris Horn            Created Interface
                                      
*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;
    
end pmxpxi04_loader;
/