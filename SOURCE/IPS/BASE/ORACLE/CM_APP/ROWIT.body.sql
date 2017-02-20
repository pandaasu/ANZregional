create or replace 
PACKAGE BODY          "ROWIT" AS
  ------------------------ PACKAGE DECLARATIONS ----------------------------------
  pc_package_name  CONSTANT common.st_package_name := 'ROWIT';

  -- COLLECTION RELATED TYPE DECLARATIONS.
  SUBTYPE st_rowid IS VARCHAR2 (18);

  TYPE t_rowid IS RECORD (
    row_id  ROWID,
    FOUND   BOOLEAN
  );

  TYPE t_rowids IS TABLE OF t_rowid
    INDEX BY st_rowid;

  -- COLLECTION VARIABLE DECLARATIONS
  pv_rowids                 t_rowids;
  -- COLLECTION REC COUNTERS DECLARATIONS
  pv_current_rowid          st_rowid;
  pv_found_count            common.st_counter;
  pv_not_found_count        common.st_counter;
  -- Private Variables for tracking the get row number function.
  pv_last_group_by_id       common.st_id;
  pv_last_row_number        common.st_count;

  FUNCTION reset_rowid_tracking (o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
  BEGIN
    logit.enter_method (pc_package_name, 'RESET_ROWID_TRACKING');
    logit.LOG ('Resting Row ID Tracking System.');
    pv_rowids.DELETE;
    pv_current_rowid := NULL;
    pv_found_count := 0;
    pv_not_found_count := 0;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process reset rowid tracking.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END reset_rowid_tracking;

  FUNCTION add_rowid (i_row_id IN ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_ROWID');
    -- Add the row id and set found status.
    pv_rowids (i_row_id).row_id := i_row_id;
    pv_rowids (i_row_id).FOUND := FALSE;
    -- Update the counters.
    pv_not_found_count := pv_not_found_count + 1;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process add rowid.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END add_rowid;

  FUNCTION mark_rowid_found (i_row_id IN ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- VARIABLE DECLARATIONS
    v_result  common.st_result;
  BEGIN
    logit.enter_method (pc_package_name, 'MARK_ROWID_FOUND');
    v_result := common.gc_success;

    -- First test to see if there are any records in the collection to compare
    -- against.
    IF pv_rowids.EXISTS (i_row_id) = TRUE THEN
      IF pv_rowids (i_row_id).FOUND = FALSE THEN
        pv_rowids (i_row_id).FOUND := TRUE;
        pv_found_count := pv_found_count + 1;
        pv_not_found_count := pv_not_found_count - 1;
      END IF;
    ELSE
      o_result_msg := common.create_failure_msg ('RowID wasn''t found to mark to be able to mark found.');
      v_result := common.gc_failure;
    END IF;

    logit.leave_method;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process mark rowid found.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END mark_rowid_found;

  FUNCTION go_to_start (o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_result  common.st_result;
  BEGIN
    logit.enter_method (pc_package_name, 'GO_TO_START');

    -- First check to see if there are any rowids in the collection
    IF pv_rowids.COUNT = 0 THEN
      o_result_msg := common.create_failure_msg ('There are no rowids in the collection.');
      v_result := common.gc_failure;
    ELSE
      pv_current_rowid := pv_rowids.FIRST;
    END IF;

    logit.leave_method;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process reset go to start of list.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END go_to_start;

  FUNCTION get_next_found_rowid (o_row_id OUT ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- VARIABLE DECLARATIONS
    v_found   BOOLEAN;
    v_result  common.st_result;
  BEGIN
    logit.enter_method (pc_package_name, 'GET_NEXT_FOUND_ROWID');

    -- First check to see if there are any rowids in the collection
    IF pv_rowids.COUNT = 0 THEN
      o_result_msg := common.create_failure_msg ('There are no rowids in the collection.');
      v_result := common.gc_failure;
    ELSE
      -- Now loop until we find the next found rowid
      v_found := FALSE;

      LOOP
        -- Check if we need to exit the loop now.
        EXIT WHEN pv_current_rowid IS NULL OR v_found = TRUE;

        -- Now check to see if the current row id is marked found.
        IF pv_rowids (pv_current_rowid).FOUND = TRUE THEN
          o_row_id := pv_rowids (pv_current_rowid).row_id;
          v_found := TRUE;
        END IF;

        pv_current_rowid := pv_rowids.NEXT (pv_current_rowid);
      END LOOP;

      -- Return the approperiate result.
      IF v_found = FALSE THEN
        o_result_msg := common.create_failure_msg ('There are no more marked found rowids.');
        v_result := common.gc_failure;
      END IF;
    END IF;

    logit.leave_method;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process get next found rowid.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END get_next_found_rowid;

  FUNCTION get_next_not_found_rowid (o_row_id OUT ROWID, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- VARIABLE DECLARATIONS
    v_found   BOOLEAN;
    v_result  common.st_result;
  BEGIN
    logit.enter_method (pc_package_name, 'GET_NEXT_NOT_FOUND_ROWID');

    -- First check to see if there are any rowids in the collection
    IF pv_rowids.COUNT = 0 THEN
      o_result_msg := common.create_failure_msg ('There are no rowids in the collection.');
      v_result := common.gc_failure;
    ELSE
      -- Now loop until we find the next found rowid
      v_found := FALSE;

      LOOP
        -- Check if we need to exit the loop now.
        EXIT WHEN pv_current_rowid IS NULL OR v_found = TRUE;

        -- Now check to see if the current row id is marked not found.
        IF pv_rowids (pv_current_rowid).FOUND = FALSE THEN
          o_row_id := pv_rowids (pv_current_rowid).row_id;
          v_found := TRUE;
        END IF;

        pv_current_rowid := pv_rowids.NEXT (pv_current_rowid);
      END LOOP;

      -- Return the approperiate result.
      IF v_found = FALSE THEN
        o_result_msg := common.create_failure_msg ('There are no more marked found rowids.');
        v_result := common.gc_failure;
      END IF;
    END IF;

    logit.leave_method;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process get next not found rowid.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END get_next_not_found_rowid;

  FUNCTION get_no_rowids (o_no_rowids OUT common.st_counter, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
  BEGIN
    logit.enter_method (pc_package_name, 'GET_NO_ROWIDS');
    o_no_rowids := pv_rowids.COUNT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process get no rowids.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END get_no_rowids;

  FUNCTION get_no_found_rowids (o_no_found_rowids OUT common.st_counter, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
  BEGIN
    logit.enter_method (pc_package_name, 'GET_NO_FOUND_ROWIDS');
    o_no_found_rowids := pv_found_count;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process get no found rowids.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END get_no_found_rowids;

  FUNCTION get_no_not_found_rowids (o_no_not_found_rowids OUT common.st_counter, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
  BEGIN
    logit.enter_method (pc_package_name, 'GET_NO_NOT_FOUND_ROWIDS');
    o_no_not_found_rowids := pv_not_found_count;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to process get no not found rowids.') || common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END get_no_not_found_rowids;

  FUNCTION get_row_number (i_group_by_id IN common.st_id DEFAULT NULL)
    RETURN common.st_count IS
  BEGIN
    IF pv_last_row_number IS NULL THEN
      pv_last_row_number := 0;
    END IF;

    IF common.are_equal (i_group_by_id, pv_last_group_by_id) = TRUE THEN
      pv_last_row_number := pv_last_row_number + 1;
    ELSE
      pv_last_group_by_id := i_group_by_id;
      pv_last_row_number := 1;
    END IF;

    RETURN pv_last_row_number;
  END get_row_number;
END rowit; 