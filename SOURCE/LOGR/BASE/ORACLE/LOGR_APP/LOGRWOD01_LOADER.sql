create or replace 
PACKAGE LOGRWOD01_LOADER AS 
/*******************************************************************************
** PACKAGE DEFINITION
********************************************************************************

  System    : LOGR
  Owner     : LOGR_APP
  Package   : LOGRWOD01_LOADER
  Author    : Chris Horn
  Interface : Laws of Growth - Australia Petcare - Sales Scan Data

  Description
  ------------------------------------------------------------------------------
  This package perform a sales data upload of scan data. 
  
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
  2013-06-25  Chris Horn            Created Interface
  2013-07-19  Chris Horn            Updated Interface
  2013-07-26  Chris Horn            Split Cat and Dog and updated fields.
  2013-08-11  Chris Horn            Added last updated time, user fields.
  2013-08-14  Chris Horn            Updated exception handling.
  2013-10-09  Chris Horn            Added multi period handling.
  2013-10-15  Chris Horn            Added Occasion handling for dog.

*******************************************************************************/
  -- LICS Hooks.
  procedure on_start;
  procedure on_data(p_row in varchar2);
  procedure on_end;
  -- FFLU Hooks.
  function on_get_file_type return varchar2;
  function on_get_csv_qualifier return varchar2;

END LOGRWOD01_LOADER;