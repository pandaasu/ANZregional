create or replace 
PACKAGE          "ROWIT" IS
  /*************************************************************************
    NAME:      ROWIT
    PURPOSE:   This package is used to track the ids of a table for the
               purposes of deleting records that were not found.
  *************************************************************************/

  /*************************************************************************
    NAME:      RESET_ROWID_TRACKING
    PURPOSE:   Sets the number of rowids counter to 0, and initialise the
               other variables used to maintaining the system.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION reset_rowid_tracking (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      ADD_ROWID
    PURPOSE:   Add a rowid to the collection and mark it as being not found.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION add_rowid (i_row_id IN ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      MARK_ROWID_FOUND
    PURPOSE:   Mark a particular rowid as being found.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION mark_rowid_found (i_row_id IN ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GO_TO_START_OF_LIST
    PURPOSE:   Sets the system to be at the start of the list. Will return
               failure if there are no rowids in the collection.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION go_to_start (o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GET_NEXT_FOUND_ROWID
    PURPOSE:   Returns the next rowid that is marked found.  Will return
               failure if there are no more rowids marked as such.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION get_next_found_rowid (o_row_id OUT ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GET_NEXT_NOT_FOUND_ROWID
    PURPOSE:   Returns the next rowid that is marked not found.  Will return
               failure if there are no more rowids marked as such.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION get_next_not_found_rowid (o_row_id OUT ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GET_NO_ROWIDS
    PURPOSE:   Returns the number of rowids.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION get_no_rowids (o_no_rowids OUT common.st_counter, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GET_NO_FOUND_ROWIDS
    PURPOSE:   Returns the number of rowids that are marked found.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION get_no_found_rowids (o_no_found_rowids OUT common.st_counter, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GET_NO_NOT_FOUND_ROWIDS
    PURPOSE:   Returns the number of rowids that are marked not found.

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  FUNCTION get_no_not_found_rowids (o_no_not_found_rowids OUT common.st_counter, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
    NAME:      GET_ROW_NUM
    PURPOSE:   This function returns a plsql counter number against each row in a
               select statement.  If Group by is specific

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------
    1.0   14/05/2000 Chris Horn           Created this function.
    1.1   13/07/2006 Chris Horn           Updated to use new loging.

    NOTES:
  *************************************************************************/
  function get_row_number(i_group_by_id in common.st_id default null) return common.st_count;
END rowit; 
 
 