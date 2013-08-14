create or replace 
PACKAGE LOGRWOD08_LOADER AS 
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : ODS
  Owner     : ODS_APP
  Package   : LOGRWOD08_LOADER
  Author    : Chris Horn
  Interface : Laws of Growth - Australia Petcare - Product Performance

  Description
  ------------------------------------------------------------------------------
  This package perform an upload of product performance data.  

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
  2013-07-19  Chris Horn            Created Interface
  2013-08-14  Chris Horn            Implemented Interface

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

END LOGRWOD08_LOADER;