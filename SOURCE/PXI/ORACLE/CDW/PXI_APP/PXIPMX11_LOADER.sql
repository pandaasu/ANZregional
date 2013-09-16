create or replace package pxipmx11_loader as
  /*****************************************************************************
  ** PACKAGE DEFINITION
  ******************************************************************************
  
    Schema    : pxi_app
    Package   : pxipmx11_loader
    Author    : Chris Horn          
  
    Description
    ----------------------------------------------------------------------------
    [pxipmx11_loader] Promax - COGS Interface
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
    2013-09-15  Chris Horn            Added the interface specific aspects.
  
  *****************************************************************************/

  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

end pxipmx11_loader;
