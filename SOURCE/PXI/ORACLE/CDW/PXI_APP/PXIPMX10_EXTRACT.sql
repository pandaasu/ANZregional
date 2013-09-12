create or replace package pxipmx10_extract as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : pxi_app
    Package   : pxipmx10_extract
    Author    : Chris Horn          
  
    Description
    ----------------------------------------------------------------------------
    [pxipmx10_extract] Promax - COGS Interface
    [replace_on_key] Template
    
    Functions
    ----------------------------------------------------------------------------
    + LICS Hooks 
      - on_start                   Called on starting the interface.
      - on_data(i_row in varchar2) Called for each row of data in the interface.
      - on_end                     Called at the end of processing.
    + FFLU Hooks
      - on_get_file_type           Returns the type of file format expected.
      - on_get_csv_qualifier       Returns the CSV file format qualifier.  
  
    Date        Author                Description
    ----------  --------------------  ------------------------------------------
    2013-09-11  Chris Horn            [Auto Generated]
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end pxipmx10_extract;
