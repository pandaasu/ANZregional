create or replace 
package        PXIDFN01_LOADER as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : ODS
  Owner     : ODS_APP
  Package   : PXIDFN01_LOADER
  Author    : Chris Horn, Jonathan Girling
  Interface : Promax to Demand Financials Demand Forecast

  Description
  ------------------------------------------------------------------------------
  This package will take the promax demand forecast data and convert it into 
  the Apollo Demand Forecast Format and load it into the demand forecast loading
  table and then trigger the normal demand forecast processing job.  
  
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
  2013-07-04  Chris Horn            Created Interface
  2013-07-18  Jonathan Girling      Updated Interface to reference 
                                    px_dmnd_lookup table.

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end PXIDFN01_LOADER;