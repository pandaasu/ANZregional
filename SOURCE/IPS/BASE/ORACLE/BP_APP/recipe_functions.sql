CREATE OR REPLACE PACKAGE        recipe_functions AS
  /*****************************************************************************
      NAME:      RECIPE_FUNCTIONS
      PURPOSE:   This package provides useful functions for interpurting the
                 recipe data that is in the system.
  *****************************************************************************/
  TYPE t_where_used_rec IS RECORD (
    plant           common.st_code,   -- The plant the finished good was going to be produced within.
    matl_code       common.st_code,   -- The finished good material that the supplied material is used within.
    proportion      common.st_value,   -- The calculated proportion that the supplied material makes up of this finished good material, 1 equals for every 1 produced product 1 of the supplied item has had to go into the product.
    extra_value0    common.st_value,   -- Store extra calculation value. Production average.
    extra_value1    common.st_value,   -- Store extra calculation value. Proportion x ABS(Production Average)
    extra_value2    common.st_value,   -- Store extra calculation value. Proportion X ABS(Production Average) / Total Proportion x ABS(Production Average) * Allocation Amount
    bom_path        common.st_message_string  -- Allow the bom path that was used to be output in the table.
  );

  TYPE t_where_used IS TABLE OF t_where_used_rec
    INDEX BY common.st_counter;

  /*****************************************************************************
      NAME:      WHERE_USED
      PURPOSE:   This procedure takes a ROH or VERP material code and then finds
                 the boms used on a given date that contain that this material.
                 It then traverses those BOMS's until it finds a FERT TDU.  Then
                 it calculates a percentage that would be within that bom.

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ------------------------------------
      1.0   15/08/2006 Chris Horn           Created this procedure.
      1.1   14/11/2008 Chris Horn           Updated function to store path.

      NOTES:
    ***************************************************************************/
  FUNCTION where_used (i_company in common.st_code, i_matl_code IN common.st_code, i_date IN DATE, i_bom_path in boolean, o_where_used OUT t_where_used, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*****************************************************************************
      NAME:      WHERE_USED_ALLOCATION
      PURPOSE:   This procedure takes a ROH or VERP material code and then finds
                 the boms used on a given date that contain that this material.
                 It then traverses those BOMS's until it finds a FERT TDU.  Then
                 it calculates a percentage that would be within that bom.

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ------------------------------------
      1.0   18/06/2009 Steve Gregan         Created this procedure to replace WHERE_USED.

      NOTES:
    ***************************************************************************/
  FUNCTION where_used_allocation (i_company in common.st_code, i_matl_code IN common.st_code, i_date IN DATE, i_alloc_type IN common.st_code, i_bom_path in boolean, o_where_used OUT t_where_used, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*****************************************************************************
      NAME:      GET_ALTERNATIVE
      PURPOSE:   This function, takes a plant and bom code and a date and returns
                 the alternative that should be in effect on this date.

      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ------------------------------------
      1.0   15/08/2006 Chris Horn           Created this procedure.

      NOTES:
    ***************************************************************************/
  FUNCTION get_alternative (i_plant IN common.st_code, i_matl_code IN common.st_code, i_effective_date IN common.st_code)
    RETURN common.st_code;
END recipe_functions;
/


CREATE OR REPLACE PACKAGE BODY        recipe_functions AS
  -------------------------PACKAGE DECLARATIONS --------------------------------
  -- Package Constants
  pc_package_name            common.st_package_name := 'RECIPE_FUNCTIONS';
  pc_max_bom_depth  CONSTANT common.st_value        := 100;

  FUNCTION get_alternative (i_plant IN common.st_code, i_matl_code IN common.st_code, i_effective_date IN common.st_code)
    RETURN common.st_code IS
    v_alternative  common.st_code;

    CURSOR csr_alternative IS
      SELECT altv
      FROM bom_sched
      WHERE start_date <= i_effective_date AND plant = i_plant AND matl_code = i_matl_code
      ORDER BY start_date DESC;

    CURSOR csr_bom IS
      SELECT altv
      FROM bom_hdr
      WHERE plant = i_plant AND matl_code = i_matl_code AND i_effective_date BETWEEN valid_from AND valid_to;
  BEGIN
    OPEN csr_alternative;

    FETCH csr_alternative
    INTO v_alternative;

    IF csr_alternative%NOTFOUND THEN
      OPEN csr_bom;

      FETCH csr_bom
      INTO v_alternative;

      IF csr_bom%NOTFOUND THEN
        v_alternative := NULL;
      END IF;

      CLOSE csr_bom;
    END IF;

    CLOSE csr_alternative;

    RETURN v_alternative;
  END get_alternative;

  ------------------------------------------------------------------------------
  FUNCTION where_used (
    i_company     IN      common.st_code,
    i_matl_code   IN      common.st_code,
    i_date        IN      DATE,
    i_bom_path in boolean,
    o_where_used  OUT     t_where_used,
    o_result_msg  OUT     common.st_message_string)
    RETURN common.st_result IS
    -- Variable declarations
    v_processing_msg  common.st_message_string;
    v_return          common.st_result;
    v_return_msg      common.st_message_string;
    v_date            common.st_code;
    v_bom_depth       common.st_counter;

    PROCEDURE search (i_current_matl_code IN common.st_code, i_proportion IN common.st_value, i_path in common.st_message_string) IS
      v_position  common.st_counter;

      CURSOR csr_bom_det IS
        SELECT t1.plant, t1.matl_code, t1.altv, t1.qty AS cmpnt_qty, t1.uom AS cmpnt_uom, t4.matl_type AS cmpnt_matl_type, t2.qty AS bom_qty,
          t2.uom AS bom_uom, t3.matl_type AS bom_matl_type, t3.trdd_unit
        FROM bom_det t1, bom_hdr t2, matl t3, matl t4, plant t5
        WHERE cmpnt_matl_code = i_current_matl_code AND
         v_date BETWEEN t1.valid_from AND t1.valid_to AND
         recipe_functions.get_alternative (t1.plant, t1.matl_code, v_date) = t1.altv AND
         t1.plant = t2.plant AND
         t1.matl_code = t2.matl_code AND
         t1.altv = t2.altv AND
         t1.matl_code = t3.matl_code AND
         t1.cmpnt_matl_code = t4.matl_code AND
         t1.plant = t5.plant AND
         t5.sales_org = i_company;

      rv_bom_det  csr_bom_det%ROWTYPE;
      v_path common.st_message_string;

      FUNCTION calc_proportion
        RETURN common.st_value IS
        v_value  common.st_value;
      BEGIN
        v_value := 1 * i_proportion;

        IF rv_bom_det.cmpnt_uom = rv_bom_det.bom_uom AND rv_bom_det.cmpnt_uom = 'KGM' THEN
          v_value := (rv_bom_det.cmpnt_qty / rv_bom_det.bom_qty) * i_proportion;
        END IF;

        RETURN v_value;
      END calc_proportion;
    BEGIN
      OPEN csr_bom_det;

      v_bom_depth := v_bom_depth + 1;

      LOOP
        FETCH csr_bom_det
        INTO rv_bom_det;

        EXIT WHEN csr_bom_det%NOTFOUND;

        --
        if i_bom_path = true then
          v_path := i_path || '->' || rv_bom_det.matl_code || ',' || rv_bom_det.plant || ',' || rv_bom_det.altv;
        end if;

        IF rv_bom_det.bom_matl_type = 'FERT' AND rv_bom_det.trdd_unit = 'X' THEN
          -- logit.LOG ('Add this record now to the collection.');
          v_position := o_where_used.COUNT + 1;
          o_where_used (v_position).plant := rv_bom_det.plant;
          o_where_used (v_position).matl_code := rv_bom_det.matl_code;
          o_where_used (v_position).proportion := calc_proportion;
          o_where_used (v_position).bom_path := v_path;
        ELSE
          IF v_bom_depth >= pc_max_bom_depth  THEN
            -- If the number of open cursors is > 100 then fail this material
            v_processing_msg := 'Number of BOM levels > ' || pc_max_bom_depth || ', material not fully proportioned : ' || i_matl_code;
            o_result_msg := v_processing_msg;
            EXIT;
          ELSE
            --logit.LOG ('Continue searching');
            search (rv_bom_det.matl_code, calc_proportion,v_path);
          END IF;
        END IF;
      END LOOP;

      v_bom_depth := v_bom_depth - 1;
      CLOSE csr_bom_det;

    END search;
  BEGIN
    -- log entry and assign return value
    logit.enter_method (pc_package_name, 'WHERE_USED');
    -- Now ensure that the collection is empty.
    logit.LOG ('Initialising');
    o_where_used.DELETE;
    v_date := TO_CHAR (i_date, 'YYYYMMDD');
    logit.LOG ('Effective Date : ' || v_date);
    logit.LOG ('Now starting search on : ' || i_matl_code);
    v_bom_depth := 0;
    search (i_matl_code, 1,i_matl_code);
    logit.LOG ('Exit and leave successfully. o_where_used COUNT : ' || o_where_used.COUNT);
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to calculate where used information.') || common.nest_err_msg (common.create_sql_error_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END where_used;

  FUNCTION where_used_allocation (
    i_company     IN      common.st_code,
    i_matl_code   IN      common.st_code,
    i_date        IN      DATE,
    i_alloc_type   IN     common.st_code,
    i_bom_path in boolean,
    o_where_used  OUT     t_where_used,
    o_result_msg  OUT     common.st_message_string)
    RETURN common.st_result IS
    -- Variable declarations
    v_processing_msg  common.st_message_string;
    v_return          common.st_result;
    v_return_msg      common.st_message_string;
    v_date            common.st_code;
    v_bom_depth       common.st_counter;

    PROCEDURE search (i_current_matl_code IN common.st_code, i_proportion IN common.st_value, i_path in common.st_message_string) IS
      v_position  common.st_counter;
      v_path common.st_message_string;
      v_value  common.st_value;

      CURSOR csr_bom_det IS
        SELECT t1.plant, t1.matl_code, t1.altv, t1.qty AS cmpnt_qty, t1.uom AS cmpnt_uom, t4.matl_type AS cmpnt_matl_type, t2.qty AS bom_qty,
          t2.uom AS bom_uom, t3.matl_type AS bom_matl_type, t3.trdd_unit,
          t3.base_uom as bom_base_uom,t3.net_wght as bom_net_wght,t3.gross_wght as bom_gross_wght,
          t4.base_uom as cmpnt_base_uom,t4.net_wght as cmpnt_net_wght,t4.gross_wght as cmpnt_gross_wght
        FROM bom_det t1, bom_hdr t2, matl t3, matl t4, plant t5
        WHERE cmpnt_matl_code = i_current_matl_code AND
         v_date BETWEEN t1.valid_from AND t1.valid_to AND
         recipe_functions.get_alternative (t1.plant, t1.matl_code, v_date) = t1.altv AND
         t1.plant = t2.plant AND
         t1.matl_code = t2.matl_code AND
         t1.altv = t2.altv AND
         t1.matl_code = t3.matl_code AND
         t1.cmpnt_matl_code = t4.matl_code AND
         t1.plant = t5.plant AND
         t5.sales_org = i_company;
      rv_bom_det  csr_bom_det%ROWTYPE;

    BEGIN
      OPEN csr_bom_det;

      v_bom_depth := v_bom_depth + 1;

      LOOP
        FETCH csr_bom_det
        INTO rv_bom_det;

        EXIT WHEN csr_bom_det%NOTFOUND;

        --
        if i_bom_path = true then
          v_path := i_path || '->' || rv_bom_det.matl_code || ',' || rv_bom_det.plant || ',' || rv_bom_det.altv;
        end if;

        v_value := 1 * i_proportion;
        if i_alloc_type = 'QTY' then
           IF rv_bom_det.cmpnt_uom = rv_bom_det.bom_uom AND rv_bom_det.cmpnt_uom = 'KGM' THEN
             v_value := (rv_bom_det.cmpnt_qty / rv_bom_det.bom_qty) * i_proportion;
           END IF;
        elsif i_alloc_type = 'NWT' then
           IF rv_bom_det.cmpnt_base_uom = rv_bom_det.bom_base_uom THEN
              v_value := (rv_bom_det.cmpnt_net_wght / rv_bom_det.bom_net_wght) * i_proportion;
           end if;
        elsif i_alloc_type = 'GWT' then
           IF rv_bom_det.cmpnt_base_uom = rv_bom_det.bom_base_uom THEN
              v_value := (rv_bom_det.cmpnt_gross_wght / rv_bom_det.bom_gross_wght) * i_proportion;
           end if;
        end if;

        IF rv_bom_det.bom_matl_type = 'FERT' AND rv_bom_det.trdd_unit = 'X' THEN
          v_position := o_where_used.COUNT + 1;
          o_where_used (v_position).plant := rv_bom_det.plant;
          o_where_used (v_position).matl_code := rv_bom_det.matl_code;
          o_where_used (v_position).proportion := v_value;
          o_where_used (v_position).bom_path := v_path;
        ELSE
          IF v_bom_depth >= pc_max_bom_depth  THEN
            -- If the number of open cursors is > 100 then fail this material
            v_processing_msg := 'Number of BOM levels > ' || pc_max_bom_depth || ', material not fully proportioned : ' || i_matl_code;
            o_result_msg := v_processing_msg;
            EXIT;
          ELSE
            search (rv_bom_det.matl_code, v_value,v_path);
          END IF;
        END IF;
      END LOOP;

      v_bom_depth := v_bom_depth - 1;
      CLOSE csr_bom_det;

    END search;
  BEGIN
    o_where_used.DELETE;
    v_date := TO_CHAR (i_date, 'YYYYMMDD');
    v_bom_depth := 0;
    search (i_matl_code, 1,i_matl_code);
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to calculate where used information.') || common.nest_err_msg (common.create_sql_error_msg);
      RETURN common.gc_error;
  END where_used_allocation;

END recipe_functions;
/
