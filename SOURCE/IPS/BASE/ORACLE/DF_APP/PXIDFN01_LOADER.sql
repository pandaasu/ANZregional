create or replace package PXIDFN01_LOADER as

/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : DF
  Owner     : DF_APP
  Package   : PXIDFN01_LOADER
  Author    : Chris Horn, Jonathan Girling
  Interface : Promax to Demand Financials Demand Forecast

  Description
  ------------------------------------------------------------------------------
  This package will take the promax demand forecast data and convert it into 
  the Applo Demand Forecast Format and load it into the demand forecast loading
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
  2013-09-05  Chris Horn            Updated error exeception handling.
  2013-12-02  Chris Horn            Started using PXI Common Interface suffix 
                                    and updated to new petcare format of 
                                    base and uplift.  
  2014-01-16  Chris Horn            Updated to handle the additional columns 
                                    from Promax so that the total would 
                                    balance correctly.
  2014-02-26  Chris Horn            Added additional parameter to the LICS
                                    stream to make sure Promax forecasts 
                                    will append.
*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end PXIDFN01_LOADER;