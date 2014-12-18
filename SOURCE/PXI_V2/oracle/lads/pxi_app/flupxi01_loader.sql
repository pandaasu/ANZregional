create or replace package flupxi01_loader as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : PXI
  Owner     : PXI_APP
  Package   : FLUPXI01_LOADER
  Author    : Chris Horn
  Interface : File Loading Utility to Promax PX Interfacing - Demand Group to 
              Account Mapping

  Description
  ------------------------------------------------------------------------------
  This package is used to process demand group to account code mapping 
  information into a cross reference table that will be used by the 
  process that sends data to and from Apollo Demand and Promax PX systems.

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
  2014-12-10  Chris Horn            Created Interface
                                      
*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;
    
end flupxi01_loader;
/