create or replace 
PACKAGE LOGRWOD07_LOADER AS 
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : LOGR
  Owner     : LOGR_APP
  Package   : LOGRWOD07_LOADER
  Author    : Chris Horn
  Interface : Laws of Growth - Australian Petcare - Household Penetration

  Description
  ------------------------------------------------------------------------------
  This package performs an upload of house hold penetration data.

  Interface Sufix 1 = Dog, 2 = Cat

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
  2013-08-12  Chris Horn            Implemented Interface
  2013-08-14  Chris Horn            Updated error and exception handling.

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

END LOGRWOD07_LOADER;