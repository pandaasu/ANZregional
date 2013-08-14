create or replace 
PACKAGE LOGRWOD05_LOADER AS 
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : ODS
  Owner     : ODS_APP
  Package   : LOGRWOD05_LOADER
  Author    : Chris Horn
  Interface : Laws of Growth - Australia Petcare - Advertising Effectiveness.

  Description
  ------------------------------------------------------------------------------
  This package perform a upload of advertising effectiveness data.

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
  2013-08-13  Chris Horn            Implemented Interface
  2013-08-14  Chris Horn            Updated exception handling.
  
*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

END LOGRWOD05_LOADER;