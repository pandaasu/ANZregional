create or replace 
PACKAGE BODY        demand_forecast AS
  -- Package Constants
  pc_package_name           CONSTANT common.st_package_name := 'DEMAND_FORECAST';
  -- House Keeping Files
  pc_keep_old_files         CONSTANT common.st_counter      := 14;
  pc_keep_old_draft_files   CONSTANT common.st_counter      := 14;
  -- Archiving Constants
  pc_archive_days_123_fcst  CONSTANT common.st_counter      := 60;
  pc_archive_days_45_fcst   CONSTANT common.st_counter      := 400;
  pc_archive_days_br        CONSTANT common.st_counter      := 800;
  -- Purging Constants
  pc_purge_days_123_fcst    CONSTANT common.st_counter      := 200;
  pc_purge_days_45_fcst     CONSTANT common.st_counter      := 800;
  pc_purge_days_br          CONSTANT common.st_counter      := 1200;

  -- Package Variables.
  TYPE t_source_code_cache IS TABLE OF common.st_code
    INDEX BY common.st_code;

  pv_source_code_cache               t_source_code_cache;


  FUNCTION get_source_code (i_material_code IN common.st_code)
    RETURN common.st_code IS
    c_default_source_code  common.st_code := 'OTHER';
    v_result               common.st_code;
    v_source_code          common.st_code;

    CURSOR csr_moe_source_xref IS
      SELECT t1.source_code
      FROM moe_source_xref t1, matl_moe t2
      WHERE t2.matl_code = reference_functions.full_matl_code (i_material_code) AND t1.moe_code = t2.moe_code AND t1.item_usage_code = t2.item_usage_code;

    CURSOR csr_item_source_xref IS
      SELECT source_code
      FROM item_source_xref t1
      WHERE t1.item_code = reference_functions.short_matl_code (i_material_code);
  BEGIN
    IF pv_source_code_cache.EXISTS (i_material_code) = TRUE THEN
      v_result := pv_source_code_cache (i_material_code);
    ELSE
      v_result := c_default_source_code;

      -- Now apply the moe source xref
      OPEN csr_moe_source_xref;

      FETCH csr_moe_source_xref
      INTO v_source_code;

      IF csr_moe_source_xref%FOUND THEN
        v_result := v_source_code;
      END IF;

      CLOSE csr_moe_source_xref;

      -- Now apply the item source xref.
      OPEN csr_item_source_xref;

      FETCH csr_item_source_xref
      INTO v_source_code;

      IF csr_item_source_xref%FOUND THEN
        v_result := v_source_code;
      END IF;

      CLOSE csr_item_source_xref;

      -- Now store the result.
      pv_source_code_cache (i_material_code) := v_result;
    END IF;

    RETURN v_result;
  END get_source_code;

  FUNCTION archive_forecast (i_forecast_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    CURSOR csr_fcst (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst
      WHERE fcst.fcst_id = i_fcst_id AND (status = gc_fs_invalid OR status = gc_fs_valid OR status = gc_fs_unarchived);

    e_forecast_invalid  EXCEPTION;   -- archive to forecast is invalid
    e_event_error       EXCEPTION;   -- error creating events
    v_message           common.st_message_string;
    -- standard message return function
    rv_fcst             csr_fcst%ROWTYPE;
  -- cursor to see if forecast exsists.
  BEGIN
    logit.enter_method (pc_package_name, 'ARCHIVE_FORECAST');
    logit.LOG ('Begin archive');

    -- check to see if forecast id is valid
    OPEN csr_fcst (i_forecast_id);

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%FOUND THEN
      -- if forecast is valid, of an archivalble type then archive forecast.
      INSERT INTO dmnd_data_archv
                  (fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE)
        SELECT fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
        FROM dmnd_data
        WHERE fcst_id = i_forecast_id;

      -- delete forecast from demand table.
      DELETE FROM dmnd_data
            WHERE fcst_id = i_forecast_id;

      -- now change the status of the forecast
      UPDATE fcst
         SET status = gc_fs_archived
       WHERE fcst_id = i_forecast_id;
    ELSE
      RAISE e_forecast_invalid;
    END IF;

    IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_archive_forecast, i_forecast_id, 'DF Forecast archived', v_message) !=
                                                                                                                                               common.gc_success THEN
      RAISE e_event_error;
    END IF;

    COMMIT;
    logit.LOG ('Finished Archive');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_result_msg := common.create_error_msg ('Event creation error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_forecast_invalid THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_result_msg := common.create_error_msg ('forecast is invalid');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      ROLLBACK;
      -- catch all for unhanded exceptions.
      o_result_msg := common.create_error_msg ('unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END archive_forecast;

  FUNCTION purge_forecast (i_forecast_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- cursor to check that forecast is valid
    CURSOR csr_fcst (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst
      WHERE fcst.fcst_id = i_fcst_id;

    e_forecast_invalid  EXCEPTION;   -- event if forecast is not valid.
    e_event_error       EXCEPTION;   -- raise event error.
    rv_fcst             csr_fcst%ROWTYPE;
    -- standard function messaging procedure
    v_message           common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'PURGE_FORECAST');
    logit.LOG ('Begin purge');

    -- check to see if forecast exists.
    OPEN csr_fcst (i_forecast_id);

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%FOUND THEN   -- if forecast found.
      -- now delete all trace of the forecast.
      DELETE FROM dmnd_data_archv
            WHERE fcst_id = i_forecast_id;

      DELETE FROM dmnd_data
            WHERE fcst_id = i_forecast_id;

      DELETE FROM inv_fcst_data
            WHERE fcst_id = i_forecast_id;

      DELETE FROM prodn_plan_data
            WHERE fcst_id = i_forecast_id;

      DELETE FROM fcst
            WHERE fcst_id = i_forecast_id;
    ELSE
      RAISE e_forecast_invalid;
    END IF;

    -- create the purge forecast event.
    IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_purge_forecasts, i_forecast_id, 'Forecast Purged.', v_message) !=
                                                                                                                                               common.gc_success THEN
      RAISE e_event_error;
    END IF;

    COMMIT;
    logit.LOG ('Finished purge');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_result_msg := common.create_error_msg ('Event creation error' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_forecast_invalid THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_result_msg := common.create_error_msg ('forecast is invalid');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      ROLLBACK;
      -- catch all for unhanded exceptions.
      o_result_msg := common.create_error_msg ('unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END purge_forecast;

  FUNCTION unarchive_forecast (i_forecast_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    CURSOR csr_fcst (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst
      WHERE fcst.fcst_id = i_fcst_id AND status = gc_fs_archived;

    e_forecast_invalid  EXCEPTION;
    -- exception raised if forecast is invalid.
    e_event_error       EXCEPTION;   --
    rv_fcst             csr_fcst%ROWTYPE;   -- forecast recordset
    v_message           common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'UNARCHIVE_FORECAST');
    logit.LOG ('Begin unarchive');

    -- now check that forecast id is valid, and that is has been archived.
    OPEN csr_fcst (i_forecast_id);

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%FOUND THEN   -- forecast is valid and archived
      -- put the data back into the demand data table.
      INSERT INTO dmnd_data
                  (fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE)
        SELECT fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
        FROM dmnd_data_archv
        WHERE fcst_id = i_forecast_id;

      -- remove the records from the archive table.
      DELETE FROM dmnd_data_archv
            WHERE fcst_id = i_forecast_id;

      -- set the forecast status to unarchived.
      UPDATE fcst
         SET status = gc_fs_unarchived,
             last_updated = SYSDATE
       WHERE fcst_id = i_forecast_id;
    ELSE
      RAISE e_forecast_invalid;
    -- forecast now found , or not in a archived state.
    END IF;

    --create unarchive event.
    IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_unarchive_forecast, i_forecast_id, 'DF Forecast unarchived', v_message) !=
                                                                                                                                               common.gc_success THEN
      RAISE e_event_error;
    END IF;

    COMMIT;
    logit.LOG ('Finished Unarchive');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_result_msg := common.create_error_msg ('Event creation error' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_forecast_invalid THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_result_msg := common.create_error_msg ('forecast is invalid');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      ROLLBACK;
      -- catch all for unhanded exceptions.
      o_result_msg := common.create_error_msg ('unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END unarchive_forecast;

  FUNCTION redo_tdu (i_fcst_id IN common.st_id, o_message_out OUT common.st_message_string)
    RETURN common.st_result IS
    -- cursor to check the supplied forecast is valid
    CURSOR csr_fcst (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst
      WHERE fcst.fcst_id = i_fcst_id;

    CURSOR csr_data (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM dmnd_data
      WHERE fcst_id = i_fcst_id AND
       dmnd_grp_org_id IN (
                SELECT dmnd_grp_org_id
                FROM dmnd_grp dg, dmnd_grp_org dog, dmnd_grp_type dt
                WHERE dg.dmnd_grp_type_id = dt.dmnd_grp_type_id AND dg.dmnd_grp_id = dog.dmnd_grp_id AND dt.dmnd_grp_type_code = gc_demand_group_code_demand)
      FOR UPDATE;

    CURSOR csr_demand_grp_org (i_dmnd_grp_org_id IN common.st_id) IS
      SELECT *
      FROM dmnd_grp_org
      WHERE dmnd_grp_org_id = i_dmnd_grp_org_id;

    CURSOR csr_matl_dtrmntn_offset (i_moe_code IN common.st_code ) IS
    SELECT *
      FROM moe_setting
      WHERE moe_code = i_moe_code;

    rv_fcst             csr_fcst%ROWTYPE;
    rv_demand_grp_org   csr_demand_grp_org%ROWTYPE;
    e_forecast_invalid  EXCEPTION;   -- forecast is invalid
    e_matl_dtrmntn_offset  EXCEPTION;   -- material determination error
    v_calendar_day      common.st_code;   -- converted mars week back to date
    v_tdu               common.st_code;   -- resulting tdu.
    v_message_out       common.st_message_string;   -- Error message
    v_matl_dtrmntn_offset common.st_counter; -- calendar date offset
    rv_matl_dtrmntn_offset csr_matl_dtrmntn_offset%ROWTYPE;

  BEGIN
    logit.enter_method (pc_package_name, 'REDO_TDU');
    logit.LOG ('Starting TDU calculation');

    -- check that supplied forecast is id valid
    OPEN csr_fcst (i_fcst_id);

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%NOTFOUND THEN
      RAISE e_forecast_invalid;
    END IF;

    OPEN csr_matl_dtrmntn_offset(rv_fcst.moe_code);

    FETCH csr_matl_dtrmntn_offset
    INTO rv_matl_dtrmntn_offset;

    IF csr_matl_dtrmntn_offset%FOUND THEN
        IF rv_matl_dtrmntn_offset.matl_dtrmntn_offset IS NOT NULL THEN
            v_matl_dtrmntn_offset := rv_matl_dtrmntn_offset.matl_dtrmntn_offset;
            logit.log ('Material determination Offset: ' || rv_matl_dtrmntn_offset.matl_dtrmntn_offset);
        ELSE
            v_matl_dtrmntn_offset := 0;
        END IF;
    ELSE
        RAISE e_matl_dtrmntn_offset;
    END IF;

    CLOSE csr_matl_dtrmntn_offset;

    -- loop throught all data to update
    FOR rv_data IN csr_data (i_fcst_id)
    LOOP
      -- this should never  fail to no need to raise exception.
      OPEN csr_demand_grp_org (rv_data.dmnd_grp_org_id);

      FETCH csr_demand_grp_org
      INTO rv_demand_grp_org;

      IF csr_demand_grp_org%FOUND THEN   -- demand group lookup successful
        -- now find the tdu.
        BEGIN
          -- find first actual day for a mars_week so tdu can be allocated.
          SELECT MIN (TO_CHAR (calendar_date, 'YYYYMMDD') )
          INTO   v_calendar_day
          FROM mars_date
          WHERE mars_week = rv_data.mars_week;

          -- only redo tdu if override flag is set to no
          IF rv_data.tdu_ovrd_flag = common.gc_no THEN
            IF get_tdu (rv_data.zrep,
                        rv_demand_grp_org.distbn_chnl,
                        rv_demand_grp_org.sales_org,
                        rv_demand_grp_org.bill_to_code,
                        rv_demand_grp_org.ship_to_code,
                        rv_demand_grp_org.cust_hrrchy_code,
                        to_char((to_date(v_calendar_day, 'yyyymmdd') + v_matl_dtrmntn_offset),'yyyymmdd'),
                        v_tdu,
                        v_message_out) = common.gc_success THEN
              UPDATE dmnd_data
                 SET tdu = v_tdu
               WHERE CURRENT OF csr_data;
            END IF;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- when no calendar day found just continue
            NULL;
        END;
      END IF;

      CLOSE csr_demand_grp_org;
    END LOOP;

    -- Update the last updated time
    UPDATE fcst
       SET last_updated = SYSDATE
     WHERE fcst_id = i_fcst_id;

    COMMIT;
    logit.LOG ('Finished TDU calculation');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_forecast_invalid THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_message_out := common.create_error_msg ('forecast is invalid');
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_matl_dtrmntn_offset THEN
      ROLLBACK;
      -- catch exceptions when material determination offset error
      o_message_out := common.create_error_msg ('Material determination offset error.');
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      ROLLBACK;
      -- catch all for unhanded exceptions.
      o_message_out := common.create_error_msg ('unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_error;
  END redo_tdu;

  FUNCTION redo_prices (i_fcst_id IN common.st_id, i_dmnd_grp_id IN common.st_id, i_acct_assign_id IN common.st_id, o_message_out OUT common.st_message_string)
    RETURN common.st_result IS
    -- cursor to check the supplied forecast is valid
    CURSOR csr_fcst (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst
      WHERE fcst.fcst_id = i_fcst_id;

    CURSOR csr_data (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM dmnd_data
      WHERE fcst_id = i_fcst_id
      FOR UPDATE;

    CURSOR csr_demand_grp (i_dmnd_grp_org_id IN common.st_id, v_dmnd_grp_id IN common.st_id, v_acct_assign_id IN common.st_id) IS
      SELECT t1.*, t2.sply_whse_lst
      FROM dmnd_grp_org t1, dmnd_grp t2
      WHERE t1.dmnd_grp_id = t2.dmnd_grp_id AND
       t1.dmnd_grp_org_id = i_dmnd_grp_org_id AND
       (v_dmnd_grp_id IS NULL OR t1.dmnd_grp_id = v_dmnd_grp_id) AND
       (v_acct_assign_id IS NULL OR t1.acct_assign_id = v_acct_assign_id);

    rv_fcst             csr_fcst%ROWTYPE;
    rv_demand_grp       csr_demand_grp%ROWTYPE;
    e_forecast_invalid  EXCEPTION;   -- forecast is invalid
    v_calendar_day      common.st_code;   -- converted mars week back to date
    v_price             common.st_value;   -- resulting price.
    v_price_condition   common.st_message_string;
    -- resulting price condition used.
    v_message_out       common.st_message_string;   -- resulting tdu.
    v_dmnd_grp_id       common.st_id;   -- demand group id
    v_acct_assign_id    common.st_id;   -- account assignment
  BEGIN
    logit.enter_method (pc_package_name, 'REDO_PRICE');
    logit.LOG ('FCST ID: ' || i_fcst_id || ' . DMND_GRP_ID: ' || i_dmnd_grp_id || ' . ACCT_ASSIGN: ' || i_acct_assign_id);

    -- GUI passes zeroes instead of NULL, this code performs conversion and uses these new variables for cursor
    IF i_dmnd_grp_id = 0 THEN
      v_dmnd_grp_id := NULL;
    ELSE
      v_dmnd_grp_id := i_dmnd_grp_id;
    END IF;

    IF i_acct_assign_id = 0 THEN
      v_acct_assign_id := NULL;
    ELSE
      v_acct_assign_id := i_acct_assign_id;
    END IF;

    -- check that supplied forecast is id valid
    OPEN csr_fcst (i_fcst_id);

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%NOTFOUND THEN
      RAISE e_forecast_invalid;
    END IF;

    -- loop throught all data to update
    FOR rv_data IN csr_data (i_fcst_id)
    LOOP
      -- this should never  fail to no need to raise exception.
      OPEN csr_demand_grp (rv_data.dmnd_grp_org_id, v_dmnd_grp_id, v_acct_assign_id);

      FETCH csr_demand_grp
      INTO rv_demand_grp;

      IF csr_demand_grp%FOUND THEN   -- demand group lookup successful
        -- now find the tdu.
        BEGIN
          -- find first actual day for a mars_week so tdu can be allocated.
          SELECT MIN (TO_CHAR (calendar_date, 'YYYYMMDD') )
          INTO   v_calendar_day
          FROM mars_date
          WHERE mars_week = rv_data.mars_week;

          IF get_price (rv_data.zrep,
                        rv_data.tdu,
                        rv_demand_grp.distbn_chnl,
                        rv_demand_grp.bill_to_code,
                        rv_demand_grp.sales_org,
                        rv_demand_grp.invc_prty,
                        rv_demand_grp.sply_whse_lst,
                        v_calendar_day,
                        rv_demand_grp.pricing_formula,
                        rv_demand_grp.currcy_code,
                        v_price_condition,
                        v_price,
                        v_message_out) = common.gc_success THEN
            UPDATE dmnd_data
               SET gsv = rv_data.qty_in_base_uom * v_price,
                   price = v_price,
                   price_condition = v_price_condition
             WHERE CURRENT OF csr_data;
          ELSE
            UPDATE dmnd_data
               SET gsv = NULL,
                   price = NULL,
                   price_condition = NULL
             WHERE CURRENT OF csr_data;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- when no calendar day found just continue
            NULL;
        END;
      END IF;

      CLOSE csr_demand_grp;
    END LOOP;

    -- Update the last updated time
    UPDATE fcst
       SET last_updated = SYSDATE
     WHERE fcst_id = i_fcst_id;

    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_forecast_invalid THEN
      ROLLBACK;
      -- exception for tdu lookup failure, none of search conbination return a value.
      o_message_out := common.create_error_msg ('forecast is invalid');
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      ROLLBACK;
      -- catch all for unhanded exceptions.
      o_message_out := common.create_error_msg ('unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_error;
  END redo_prices;

  FUNCTION get_tdu (
    i_material_code         IN      common.st_code,
    i_distribution_channel  IN      common.st_code,
    i_sales_org             IN      common.st_code,
    i_bill_to_code          IN      common.st_code,
    i_ship_to_code          IN      common.st_code,
    i_cust_hrrchy_code      IN      common.st_code,
    i_calendar_day          IN      common.st_code,
    o_tdu                   OUT     common.st_code,
    o_message_out           OUT     common.st_message_string)
    RETURN common.st_result IS
    e_tdu_failure           EXCEPTION;
    v_found                 BOOLEAN;
    v_material_code         common.st_message_string;
    v_tdu                   common.st_code;
    v_cust_code             common.st_code;
    v_test_num              NUMBER;

    -- cursor to find the correct tdu for the given ZREP, for the correct date range.
    CURSOR csr_tdu (
      i_matl_code     IN  common.st_code,
      i_sales_org     IN  common.st_code,
      i_dc            IN  common.st_code,
      i_cust_code     IN  common.st_code,
      i_calendar_day  IN  common.st_code) IS
      SELECT subst_matl_code, accss_level
      FROM matl_dtrmntn
      WHERE matl_code = i_matl_code AND
       sales_org = i_sales_org AND
       i_calendar_day BETWEEN from_date AND TO_DATE AND
       ( (cust_code IS NOT NULL AND cust_code = i_cust_code) OR cust_code IS NULL) AND
       ( (distbn_chnl IS NOT NULL AND distbn_chnl = i_dc) OR distbn_chnl IS NULL)
      ORDER BY accss_level DESC;

    rv_tdu                  csr_tdu%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'GET_TDU');
    logit.LOG ('Material code: ' || i_material_code);
    logit.LOG ('Sales org: ' || i_sales_org);
    logit.LOG ('Distribution Channel: ' || i_distribution_channel);
    logit.LOG ('Calendar Day: ' || i_calendar_day);
    logit.LOG ('Ship to code: ' || i_ship_to_code);
    logit.LOG ('Bill to code: ' || i_bill_to_code);
    logit.LOG ('Customer Hierarchy Code: ' || i_cust_hrrchy_code);
    -- pad zrep code to 18 digits with preceding 0
    v_material_code := reference_functions.full_matl_code (i_material_code);
    logit.LOG ('Material code: ' || i_material_code);
    -- apply apply material determination checks in sequence.
    v_found := FALSE;
    logit.LOG ('Begining of get_tdu - Found: ' || common.from_boolean (v_found) );

    -- ship to table presedence over bill to code.
    IF i_ship_to_code IS NOT NULL AND v_found = FALSE THEN
      v_cust_code := i_ship_to_code;
      logit.LOG ('Entering ship to if statement');
      logit.LOG ('Customer Code: ' || v_cust_code);

      OPEN csr_tdu (v_material_code, i_sales_org, i_distribution_channel, v_cust_code, i_calendar_day);

      logit.LOG ('Ship to if statement - Found: ' || common.from_boolean (v_found) );

      LOOP
        logit.LOG ('Entering ship to loop');

        FETCH csr_tdu
        INTO rv_tdu;

        IF csr_tdu%FOUND THEN
          logit.LOG ('ship to code: ' || v_cust_code || 'access level: ' || rv_tdu.accss_level);
          logit.LOG ('Entering ship to csr found');

          IF rv_tdu.accss_level = 5 THEN
            logit.LOG (   'Lookup tdu, zrep:'
                       || v_material_code
                       || ' sales org: '
                       || i_sales_org
                       || ' dc: '
                       || i_distribution_channel
                       || ' cust_code: '
                       || v_cust_code
                       || ' calendar day:'
                       || i_calendar_day                         
                       || ' accss_level: '
                       || rv_tdu.accss_level);
            v_found := TRUE;
          END IF;
        END IF;

        EXIT WHEN v_found = TRUE OR csr_tdu%NOTFOUND;
      END LOOP;

      CLOSE csr_tdu;
    END IF;

    -- bill to code is being used against the sold to sequence and the payer sequence.
    IF i_bill_to_code IS NOT NULL AND v_found = FALSE THEN
      v_cust_code := i_bill_to_code;
      logit.LOG ('Entering bill to if statement');

      -- now lookup tdu
      OPEN csr_tdu (v_material_code, i_sales_org, i_distribution_channel, v_cust_code, i_calendar_day);

      logit.LOG ('Bill to if statement - Found: ' || common.from_boolean (v_found) );

      LOOP
        logit.LOG ('Entering bill to while loop');

        FETCH csr_tdu
        INTO rv_tdu;

        logit.LOG ('Bill to if statement - Found: ' || common.from_boolean (v_found) );

        IF csr_tdu%FOUND THEN
          logit.LOG ('Ship to code: ' || v_cust_code || 'access level: ' || rv_tdu.accss_level);
          logit.LOG ('Entering bill to csr found');

          IF (rv_tdu.accss_level = 3 OR rv_tdu.accss_level = 4) AND v_found = FALSE THEN
            logit.LOG (   'Lookup tdu, zrep:'
                       || v_material_code
                       || ' sales org:'
                       || i_sales_org
                       || ' dc:'
                       || i_distribution_channel
                       || ' cust_code:'
                       || v_cust_code
                       || ' calendar day:'
                       || i_calendar_day  
                       || ' accss_level: '
                       || rv_tdu.accss_level);
            v_found := TRUE;
          END IF;
        END IF;

        EXIT WHEN v_found = TRUE OR csr_tdu%NOTFOUND;
      END LOOP;

      CLOSE csr_tdu;
    END IF;

    IF i_cust_hrrchy_code IS NOT NULL AND v_found = FALSE THEN
      v_cust_code := i_cust_hrrchy_code;
      logit.LOG ('Entering customer hierarchy if statement');
      logit.LOG ('Customer Code: ' || v_cust_code);

      -- now lookup tdu
      OPEN csr_tdu (v_material_code, i_sales_org, i_distribution_channel, v_cust_code, i_calendar_day);

      logit.LOG ('Customer Hierarchy Code - Found: ' || common.from_boolean (v_found) );
      logit.LOG ('Customer Hierarchy Code - Cursor found: ' || common.from_boolean (csr_tdu%FOUND) );

      LOOP
        logit.LOG ('Entering customer hierarchy while loop');

        FETCH csr_tdu
        INTO rv_tdu;

        logit.LOG ('Found variable in while statement: ' || common.from_boolean (v_found) );

        IF csr_tdu%FOUND THEN
          logit.LOG ('Cust hrrchy: ' || v_cust_code || ' Access level: ' || rv_tdu.accss_level);
          logit.LOG ('Entering cust hrrchy csr found');

          IF rv_tdu.accss_level = 6 AND v_found = FALSE THEN
            logit.LOG (   'Lookup tdu, zrep:'
                       || v_material_code
                       || ' sales org:'
                       || i_sales_org
                       || ' dc:'
                       || i_distribution_channel
                       || ' cust_code:'
                       || v_cust_code
                       || ' calendar day:'
                       || i_calendar_day                       
                       || 'accss_level: '
                       || rv_tdu.accss_level);
            v_found := TRUE;
            logit.LOG ('Customer Hierarchy Code Set to true');
          END IF;
        END IF;

        EXIT WHEN v_found = TRUE OR csr_tdu%NOTFOUND;
        logit.LOG ('Customer Hierarchy Code - Found: ' || common.from_boolean (v_found) );
        logit.LOG ('Customer Hierarchy Code - Cursor found: ' || common.from_boolean (csr_tdu%FOUND) );
      END LOOP;

      CLOSE csr_tdu;
    END IF;

    IF v_cust_code IS NULL OR v_found = FALSE THEN
      v_cust_code := NULL;
      logit.LOG ('Customer code is NULL or no material determination found at other level, Access Level 2');
      logit.LOG (   'Lookup tdu, zrep:'
                 || v_material_code
                 || ' sales org:'
                 || i_sales_org
                 || ' dc:'
                 || i_distribution_channel
                 || ' cust_code:'
                 || v_cust_code
                 || ' calendar day:'
                 || i_calendar_day  
                 || 'accss_level: '
                 || rv_tdu.accss_level);

      OPEN csr_tdu (v_material_code, i_sales_org, i_distribution_channel, v_cust_code, i_calendar_day);

      LOOP
        logit.LOG ('Entering while loop if customer code is NULL');

        FETCH csr_tdu
        INTO rv_tdu;

        logit.LOG ('Found variable in while statement: ' || common.from_boolean (v_found) );

        IF csr_tdu%FOUND THEN
          logit.LOG ('Customer code: ' || v_cust_code || ' Access level: ' || rv_tdu.accss_level);
          logit.LOG ('Entering null cust code, cursor found');

          IF rv_tdu.accss_level < 2 AND v_found = FALSE THEN
            logit.LOG (   'Lookup tdu, zrep:'
                       || v_material_code
                       || ' sales org:'
                       || i_sales_org
                       || ' dc:'
                       || i_distribution_channel
                       || ' cust_code:'
                       || v_cust_code
                       || ' calendar day:'
                       || i_calendar_day  
                       || 'accss_level: '
                       || rv_tdu.accss_level);
            v_found := TRUE;
            logit.LOG ('Customer Code Null Set to true');
          END IF;
        END IF;

        EXIT WHEN v_found = TRUE OR csr_tdu%NOTFOUND;
        logit.LOG ('Customer - Found: ' || common.from_boolean (v_found) );
        logit.LOG ('Customer - Cursor found: ' || common.from_boolean (csr_tdu%FOUND) );
      END LOOP;

      CLOSE csr_tdu;
    END IF;

    OPEN csr_tdu (v_material_code, i_sales_org, i_distribution_channel, v_cust_code, i_calendar_day);
    FETCH csr_tdu
    INTO rv_tdu;

    IF csr_tdu%NOTFOUND THEN   -- if tdu not found.
      RAISE e_tdu_failure;
    ELSE
      v_tdu := rv_tdu.subst_matl_code;
      logit.LOG ('TDU: ' || rv_tdu.subst_matl_code);
    END IF;

    o_tdu := reference_functions.short_matl_code (v_tdu);
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_tdu_failure THEN
      -- exception for tdu lookup failure, none of search conbination return a value.
      logit.LOG ('Material : ' || i_material_code);
      o_message_out := 'TEST';
      o_message_out := common.create_error_msg ('TDU lookup failure') || common.create_params_str ('i_material_code', i_material_code);
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- catch all for unhanded exceptions.
      o_message_out := common.create_error_msg ('unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_error;
  END get_tdu;

  FUNCTION copy_forecast (
    i_src_fcst_id       IN      common.st_id,   -- forecast to be copied
    i_fcst_type         IN      common.st_code,   -- destination forecast.
    i_data_entity_code  IN      common.st_code,   -- data entity code provided.
    i_period_from       IN      common.st_code,   -- first period to copy for ROB and OP
    i_period_to         IN      common.st_code,   -- end period to copy to
    o_result_msg        OUT     common.st_message_string)
    RETURN common.st_result IS
    v_forecast_id             common.st_id;
    v_week_count              common.st_counter;
    v_period_week_count       common.st_counter;
    v_start_period            common.st_code;
    v_end_period              common.st_code;
    v_result_msg              common.st_message_string;

    -- Cursor to check that supplied forecast id is valid, before copy starts
    CURSOR csr_forecast (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst t1
      WHERE t1.fcst_id = i_fcst_id 
        AND t1.forecast_type IN
            (demand_forecast.gc_ft_fcst, demand_forecast.gc_ft_op, demand_forecast.gc_ft_draft);

    rv_forecast               csr_forecast%ROWTYPE;
    e_invalid_fcst_id         EXCEPTION;   -- in forecast id is invalid
    e_invalid_fcst_type       EXCEPTION;   -- in forecast type is invalid
    e_invalid_period_range    EXCEPTION;   -- in from/to period
    e_period_converion_error  EXCEPTION;   -- forecast period range check fails.
    e_fcst_allocate           EXCEPTION;
    e_data_entity_code        EXCEPTION;
    e_event_error             EXCEPTION;
    v_period                  common.st_code;
    v_max_period              common.st_code;   -- max period for a br forecast
    v_min_period              common.st_code;   -- min period for a br forecast
  BEGIN
    logit.enter_method (pc_package_name, 'COPY_FORECAST');

    -- now check the that the suppied forecast id is valid.
    OPEN csr_forecast (i_src_fcst_id);

    FETCH csr_forecast
    INTO rv_forecast;

    IF csr_forecast%NOTFOUND THEN
      RAISE e_invalid_fcst_id;
    END IF;

    -- now check that the supplied forecast type is valid.
    IF i_fcst_type NOT IN (gc_ft_br, gc_ft_rob, gc_ft_op) THEN
      RAISE e_invalid_fcst_type;
    END IF;

    IF (i_fcst_type IN (gc_ft_rob, gc_ft_op) AND i_data_entity_code IS NULL) OR (i_data_entity_code IS NOT NULL AND LENGTH (i_data_entity_code) > 20) THEN
      RAISE e_data_entity_code;
    END IF;

    -- if the destination forecast type is ROB or OP, then check that a period from/to is supplied
    IF i_fcst_type IN (gc_ft_rob, gc_ft_op) THEN
      -- check that the supplied period from/to is valid.
      IF i_period_from IS NULL OR LENGTH (i_period_from) <> 6 OR i_period_to IS NULL OR LENGTH (i_period_to) <> 6 OR i_period_to < i_period_from THEN
        RAISE e_invalid_period_range;
      END IF;
    END IF;

    -- if the destination forecast type is a BR then
    IF i_fcst_type = gc_ft_br THEN
      -- find the first for the source forecast
      SELECT period
      INTO   v_min_period
      FROM (SELECT MIN (SUBSTR (mars_week, 1, 6) ) period
            FROM dmnd_data
            WHERE fcst_id = rv_forecast.fcst_id);

      logit.LOG ('min period:' || v_min_period);

      -- now find the number of weeks that should be in the first period
      SELECT COUNT (*)
      INTO   v_week_count
      FROM (SELECT DISTINCT mars_week
            FROM dmnd_data
            WHERE SUBSTR (mars_week, 1, 6) = v_min_period AND fcst_id = rv_forecast.fcst_id) weeks;

      logit.LOG ('Demand data first period week count:' || TO_CHAR (v_week_count) );

      -- now find the number weeks store in the database for the first period
      SELECT COUNT (*)
      INTO   v_period_week_count
      FROM (SELECT DISTINCT mars_week
            FROM mars_date
            WHERE mars_period = TO_NUMBER (v_min_period) ) weeks;

      logit.LOG ('first period, number of week in period count:' || TO_CHAR (v_period_week_count) );

      -- any of the above queries failed to return a value the error
      IF v_week_count = 0 OR v_period_week_count = 0 THEN
        RAISE e_period_converion_error;
      END IF;

      -- if the number of weeks stored against a forecast is then the number of weeks in an actual mars period.
      -- then the first period is incomplete so increment the first period by one. this should now be a complete period.
      IF v_week_count < v_period_week_count THEN
        v_start_period := TRIM (TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (v_min_period), 1) ) );
      ELSE
        v_start_period := v_min_period;
      END IF;

      -- reset for next check
      v_week_count := 0;
      v_period_week_count := 0;

      -- now try and find out in the last period within the source forecast is complete.

      -- find the last period with the source forecast
      SELECT period
      INTO   v_max_period
      FROM (SELECT MAX (SUBSTR (mars_week, 1, 6) ) period
            FROM dmnd_data
            WHERE fcst_id = rv_forecast.fcst_id);

      -- find the number of weeks within the last
      SELECT COUNT (*)
      INTO   v_week_count
      FROM (SELECT DISTINCT mars_week
            FROM dmnd_data
            WHERE SUBSTR (mars_week, 1, 6) = v_max_period AND fcst_id = rv_forecast.fcst_id) weeks;

      logit.LOG ('Demand data last period week count:' || TO_CHAR (v_week_count) );

      -- find number week included within the supplied forecast for the last period within the forecast
      SELECT COUNT (*)
      INTO   v_period_week_count
      FROM (SELECT DISTINCT mars_week
            FROM mars_date
            WHERE mars_period = TO_NUMBER (v_max_period) ) weeks;

      logit.LOG ('last period, number of week in period count:' || TO_CHAR (v_period_week_count) );

      -- if either of the above function return 0 then error out of the function
      IF v_week_count = 0 OR v_period_week_count = 0 THEN
        RAISE e_period_converion_error;
      END IF;

      logit.LOG ('max period:' || v_max_period);

      -- now check that the last period contains a complete set of weeks
      -- if not move the last period back by one , this should be a complete period.
      IF v_week_count < v_period_week_count THEN
        v_end_period := TRIM (TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (v_max_period), -1) ) );
      ELSE
        v_end_period := v_max_period;
      END IF;

      logit.LOG ('Start period:' || v_start_period || ' End period:' || v_end_period);

      -- now check the calcuated start and end (complete period) are valid.
      IF v_start_period IS NULL OR LENGTH (v_start_period) <> 6 OR v_end_period IS NULL OR LENGTH (v_end_period) <> 6 THEN
        RAISE e_period_converion_error;
      END IF;

      v_forecast_id := 0;

      -- get the destination forecast id.
      BEGIN
        -- check to see if BR already exsists if so reuse.
        SELECT fcst_id
        INTO   v_forecast_id
        FROM fcst
        WHERE casting_year = rv_forecast.casting_year AND
         casting_period = rv_forecast.casting_period AND
         forecast_type = demand_forecast.gc_ft_br AND
         moe_code = rv_forecast.moe_code;

        UPDATE fcst
           SET srce_fcst_id = rv_forecast.fcst_id,
               dataentity_code = i_data_entity_code,
               last_updated = SYSDATE
         WHERE fcst_id = v_forecast_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- create a new forecast.
          IF demand_object_tracking.get_new_id ('FCST', 'FCST_ID', v_forecast_id, v_result_msg) != common.gc_success THEN
            RAISE e_fcst_allocate;
          END IF;

          INSERT INTO fcst
                      (srce_fcst_id, fcst_id, casting_year, casting_period, forecast_type, dataentity_code, last_updated,
                       status, moe_code)
               VALUES (rv_forecast.fcst_id, v_forecast_id, rv_forecast.casting_year, rv_forecast.casting_period, i_fcst_type, i_data_entity_code, SYSDATE,
                       gc_fs_valid, rv_forecast.moe_code);
      END;

      IF v_forecast_id IS NULL OR v_forecast_id = 0 THEN
        RAISE e_fcst_allocate;
      END IF;

      DELETE FROM dmnd_data
            WHERE fcst_id = v_forecast_id;

      -- now copy the forecast
      INSERT INTO dmnd_data
                  (fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE)
        SELECT v_forecast_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
        FROM dmnd_data
        WHERE fcst_id = rv_forecast.fcst_id AND SUBSTR (mars_week, 1, 6) BETWEEN v_start_period AND v_end_period;

      -- raise event.
      IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_br_complete, v_forecast_id, 'BR created', v_result_msg) != common.gc_success THEN
        RAISE e_event_error;
      END IF;

      COMMIT;
    ELSE
      IF demand_object_tracking.get_new_id ('FCST', 'FCST_ID', v_forecast_id, v_result_msg) != common.gc_success THEN
        RAISE e_fcst_allocate;
      END IF;

      -- always substract one from the supply from period to create the casting period.
      v_period := TRIM (TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (i_period_from), -1) ) );

      IF LENGTH (v_period) <> 6 OR v_period IS NULL THEN
        RAISE e_invalid_period_range;
      END IF;

      -- now create new forecast, of the type ROB/OP
      INSERT INTO fcst
                  (srce_fcst_id, fcst_id, casting_year, casting_period, forecast_type, dataentity_code, last_updated,
                   end_year, end_period, status, moe_code)
           VALUES (rv_forecast.fcst_id, v_forecast_id, SUBSTR (v_period, 1, 4), SUBSTR (v_period, 5, 2), i_fcst_type, i_data_entity_code, SYSDATE,
                   SUBSTR (i_period_to, 1, 4), SUBSTR (i_period_to, 5, 2), gc_fs_valid, rv_forecast.moe_code);

      -- now copy forecast data, limited to from/to period ranges.
      INSERT INTO dmnd_data
                  (fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE)
        SELECT v_forecast_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
        FROM dmnd_data
        WHERE fcst_id = rv_forecast.fcst_id AND SUBSTR (mars_week, 1, 6) BETWEEN i_period_from AND i_period_to;

      -- tigger events.
      IF i_fcst_type = demand_forecast.gc_ft_rob THEN
        IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_rob_complete, v_forecast_id, 'ROB created', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
          RAISE e_event_error;
        END IF;
      END IF;

      IF i_fcst_type = demand_forecast.gc_ft_op THEN
        IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_op_complete, v_forecast_id, 'OP created', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
          RAISE e_event_error;
        END IF;
      END IF;

      COMMIT;
    END IF;

    CLOSE csr_forecast;

    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      ROLLBACK;
      o_result_msg := common.create_failure_msg ('Event creation error. ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_period_converion_error THEN
      --  period range data error, for supplied FCST or selection range
      ROLLBACK;
      o_result_msg := common.create_failure_msg ('Period conversion error');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_invalid_period_range THEN
      -- invalid supplied period range
      ROLLBACK;
      o_result_msg := common.create_failure_msg ('Invalid period range');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_invalid_fcst_type THEN
      -- destination forecast type invalid
      ROLLBACK;
      o_result_msg := common.create_failure_msg ('Invalid destination forecast type');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_data_entity_code THEN
      -- source forecast id invalid
      o_result_msg := common.create_failure_msg ('Data entity code must be provided');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_invalid_fcst_id THEN
      -- source forecast id invalid
      o_result_msg := common.create_failure_msg ('Invalid source forecast id, or its forecast type was not accepted.');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_fcst_allocate THEN
      -- source forecast id invalid
      o_result_msg := common.create_failure_msg ('Could not allocate new forecast id:' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exceptions
      ROLLBACK;
      o_result_msg := common.create_error_msg ('Unable to create forecast.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END copy_forecast;


  FUNCTION copy_draft_forecast (
    i_src_fcst_id       IN      common.st_id,   -- the draft forecast to be copied
    o_result_msg        OUT     common.st_message_string)
    RETURN common.st_result IS
    v_forecast_id             common.st_id;
    v_week_count              common.st_counter;
    v_period_week_count       common.st_counter;
    v_start_period            common.st_code;
    v_end_period              common.st_code;
    v_result_msg              common.st_message_string;

    -- cursor to check that supplied forecast id is valid, before copy starts
    CURSOR csr_forecast (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst t1
      WHERE t1.fcst_id = i_fcst_id 
        AND t1.forecast_type = demand_forecast.gc_ft_draft;

    rv_forecast               csr_forecast%ROWTYPE;
    e_invalid_fcst_id         EXCEPTION;   -- in forecast id is invalid
    e_fcst_allocate           EXCEPTION;
  BEGIN
    logit.enter_method (pc_package_name, 'COPY_DRAFT_FORECAST');

    -- Now check the that the suppied source forecast id is valid.
    OPEN csr_forecast (i_src_fcst_id);

    FETCH csr_forecast
    INTO rv_forecast;

    IF csr_forecast%NOTFOUND THEN
      RAISE e_invalid_fcst_id;
    END IF;
    
    CLOSE csr_forecast;

    -- Get the destination forecast id. 
    v_forecast_id := 0;
    
    BEGIN
      -- Check to see if the forecast already exsists if so reuse.
      SELECT fcst_id
      INTO   v_forecast_id
      FROM fcst
      WHERE casting_week = rv_forecast.casting_week and 
        casting_year = rv_forecast.casting_year AND
        casting_period = rv_forecast.casting_period AND
        forecast_type = demand_forecast.gc_ft_fcst AND
        moe_code = rv_forecast.moe_code;

      -- Update the source forecast id for the forecast being copied.
      UPDATE fcst
        SET srce_fcst_id = rv_forecast.fcst_id,
             last_updated = SYSDATE
        WHERE fcst_id = v_forecast_id;

      -- Clear out the previous forecast data that was in this forecast. 
      DELETE FROM dmnd_data
            WHERE fcst_id = v_forecast_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        -- Create a new forecast ID
        IF demand_object_tracking.get_new_id ('FCST', 'FCST_ID', v_forecast_id, v_result_msg) != common.gc_success THEN
          RAISE e_fcst_allocate;
        END IF;
  
        -- Now create the the forecast header record.
        INSERT INTO fcst (
          srce_fcst_id, fcst_id, casting_week, casting_period,casting_year,  forecast_type, last_updated,
          status, moe_code
        ) VALUES (
          rv_forecast.fcst_id, v_forecast_id, rv_forecast.casting_week, rv_forecast.casting_period, rv_forecast.casting_year, gc_ft_fcst,  SYSDATE,
          gc_fs_valid, rv_forecast.moe_code);
    END;

    -- Double check that we do have a forecast id. 
    IF v_forecast_id IS NULL OR v_forecast_id = 0 THEN
      v_result_msg := 'Forecast ID was null or was zero.';
      RAISE e_fcst_allocate;
    END IF;

   -- Now perform the actual copy of the draft forecast to the forecast. 
    INSERT INTO dmnd_data (
      fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
    ) SELECT v_forecast_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
      FROM dmnd_data
      WHERE fcst_id = rv_forecast.fcst_id;

    COMMIT;

    RETURN common.gc_success;
  EXCEPTION
    WHEN e_invalid_fcst_id THEN
      CLOSE csr_forecast;
      -- source forecast id invalid
      o_result_msg := common.create_failure_msg ('Invalid source forecast id, or its forecast type was not accepted.');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_fcst_allocate THEN
      -- source forecast id invalid
      o_result_msg := common.create_failure_msg ('Could not find existing or allocate new forecast id:' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exceptions
      ROLLBACK;
      o_result_msg := common.create_error_msg ('Unable to create forecast.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END copy_draft_forecast;


  FUNCTION fcst_compl_check (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
     CURSOR csr_moe_setting (i_fcst_id IN common.st_id) IS
      SELECT t1.moe_code, t1.sply_file, t1.dmnd_file, t2.fcst_id
      FROM moe_setting t1, fcst t2
      WHERE t2.fcst_id = i_fcst_id AND t1.moe_code = t2.moe_code;

    rv_moe_setting    csr_moe_setting%ROWTYPE;
    v_result          common.st_result;
    v_result_msg      common.st_message_string;
    v_complete        BOOLEAN;
    v_processing_msg  common.st_message_string;

  BEGIN
    logit.enter_method (pc_package_name, 'FCST_COMPL_CHECK');
    logit.LOG ('Checking if the forescast requires a demand and supply file.');

    OPEN csr_moe_setting (i_fcst_id);

    FETCH csr_moe_setting
    INTO rv_moe_setting;

    -- Assume FCST is valid unless found to be invalid
    v_complete := TRUE;

    IF csr_moe_setting%FOUND THEN
      -- Check to see if dmnd file is required
      IF rv_moe_setting.dmnd_file = common.gc_yes THEN
        v_result := eventit.wait_for_event (demand_forecast.gc_system_code, demand_events.gc_df_fcst_demand, i_fcst_id, 0, v_result_msg);

        IF v_result <> common.gc_success THEN
          v_complete := FALSE;
        END IF;
      END IF;

      -- Check to see if supply file is required
      IF rv_moe_setting.sply_file = common.gc_yes THEN
        v_result := eventit.wait_for_event (demand_forecast.gc_system_code, demand_events.gc_df_fcst_supply, i_fcst_id, 0, v_result_msg);

        IF v_result <> common.gc_success THEN
          v_complete := FALSE;
        END IF;
      END IF;

      -- Tirgger events based on what files have been received and what files are required
      IF v_complete = TRUE THEN
        IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_fcst_complete, i_fcst_id, 'Forecast Complete', v_result_msg) <>
                                                                                                                                              common.gc_success THEN
          RAISE common.ge_error;
        END IF;
      END IF;
    ELSE
      --Raise exception
      v_processing_msg := 'Unable to find moe code settings for forecast id : ' || i_fcst_id;
      RAISE common.ge_error;
    END IF;

    CLOSE csr_moe_setting;

    logit.leave_method ();
    logit.LOG ('Completed checking if the forescast requires a demand and supply file.');
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg ('Unable to check if forecast is complete : ' || common.nest_err_msg (v_processing_msg) );
      logit.log_error (o_result_msg);
      logit.leave_method;
      v_result := common.gc_error;
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg ('Unable to find MOE code');
      logit.LOG (o_result_msg);
      logit.leave_method;
      v_result := common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exception
      o_result_msg := common.create_error_msg ('Unhandled exception') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END fcst_compl_check;

  FUNCTION drft_compl_check (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    CURSOR csr_moe_setting (i_fcst_id IN common.st_id) IS
      SELECT t1.moe_code, t1.sply_file, t1.dmnd_file, t2.fcst_id
      FROM moe_setting t1, fcst t2
      WHERE t2.fcst_id = i_fcst_id AND t1.moe_code = t2.moe_code;

    rv_moe_setting    csr_moe_setting%ROWTYPE;
    v_result          common.st_result;
    v_result_msg      common.st_message_string;
    v_complete        BOOLEAN;
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'DRFT_COMPL_CHECK');
    logit.LOG ('Checking if the draft forescast requires a demand and supply file.');

    OPEN csr_moe_setting (i_fcst_id);

    FETCH csr_moe_setting
    INTO rv_moe_setting;

    -- Assume FCST is valid unless found to be invalid
    v_complete := TRUE;

    IF csr_moe_setting%FOUND THEN
      -- Check to see if dmnd file is required
      IF rv_moe_setting.dmnd_file = common.gc_yes THEN
        v_result := eventit.wait_for_event (demand_forecast.gc_system_code, demand_events.gc_df_draft_demand, i_fcst_id, 0, v_result_msg);

        IF v_result <> common.gc_success THEN
          v_complete := FALSE;
        END IF;
      END IF;

      -- Check to see if supply file is required
      IF rv_moe_setting.sply_file = common.gc_yes THEN
        v_result := eventit.wait_for_event (demand_forecast.gc_system_code, demand_events.gc_df_draft_supply, i_fcst_id, 0, v_result_msg);

        IF v_result <> common.gc_success THEN
          v_complete := FALSE;
        END IF;
      END IF;

      -- Tirgger events based on what files have been received and what files are required
      IF v_complete = TRUE THEN
        IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_draft_complete, i_fcst_id, 'Draft Forecast Complete', v_result_msg) <>
                                                                                                                                              common.gc_success THEN
          RAISE common.ge_error;
        END IF;
      END IF;
    ELSE
      --Raise exception
      v_processing_msg := 'Unable to find moe code settings for forecast id : ' || i_fcst_id;
      RAISE common.ge_error;
    END IF;

    CLOSE csr_moe_setting;

    logit.leave_method ();
    logit.LOG ('Completed checking if the forescast requires a demand and supply file.');
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg ('Unable to check if forecast is complete : ' || common.nest_err_msg (v_processing_msg) );
      logit.log_error (o_result_msg);
      logit.leave_method;
      v_result := common.gc_error;
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg ('Unable to find MOE code');
      logit.LOG (o_result_msg);
      logit.leave_method;
      v_result := common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exception
      o_result_msg := common.create_error_msg ('Unhandled exception') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END drft_compl_check;

  procedure perform_promax_adjustment(i_fcst_id IN common.st_id) is
    v_result_msg     common.st_message_string;
     -- Cursor to lookup the material determination offset.
      cursor csr_dmnd_data is
        select 
          t100.dmnd_grp_org_id,
          t100.mars_week, 
          t100.zrep, 
          t100.apollo_qty,
          t100.apollo_gsv,
          t100.promax_qty,
          t100.promax_gsv,
          -- This query pulls out the first tdu found aginst the supplied promax data and uses it.  This is to save having to try and rematerial determinate,
          (select tdu from dmnd_data t0 where t0.fcst_id = i_fcst_id and t0.dmnd_grp_org_id = t100.dmnd_grp_org_id and t0.type = demand_forecast.gc_dmnd_type_b and t0.mars_week = t100.mars_week and t0.zrep = t100.zrep and rownum = 1) as tdu
        from (
        select 
          t10.dmnd_grp_org_id,
          t10.mars_week, 
          t10.zrep, 
          sum(apollo_qty) as apollo_qty,
          sum(apollo_gsv) as apollo_gsv,
          sum(promax_qty) as promax_qty,
          sum(promax_gsv) as promax_gsv
        from (
          select 
            t1.dmnd_grp_org_id, 
            t1.mars_week, 
            t1.zrep, 
            sum(qty_in_base_uom) as apollo_qty,
            sum(gsv) as apollo_gsv,
            null as promax_qty,
            null as promax_gsv
          from 
            dmnd_data t1
          where 
            t1.fcst_id = i_fcst_id and 
            t1.type in (
                demand_forecast.gc_dmnd_type_1,demand_forecast.gc_dmnd_type_2,demand_forecast.gc_dmnd_type_3,demand_forecast.gc_dmnd_type_4,
                demand_forecast.gc_dmnd_type_5,demand_forecast.gc_dmnd_type_6,demand_forecast.gc_dmnd_type_7,demand_forecast.gc_dmnd_type_8,
                demand_forecast.gc_dmnd_type_9)
          group by
            t1.dmnd_grp_org_id, 
            t1.mars_week, 
            t1.zrep
          union all
          select 
            t1.dmnd_grp_org_id, 
            t1.mars_week, 
            t1.zrep, 
            null as apollo_qty,
            null as apollo_gsv,
            sum(qty_in_base_uom) as promax_qty,
            sum(gsv) as promax_gsv
          from 
            dmnd_data t1
          where 
            t1.fcst_id = i_fcst_id and
            t1.type = demand_forecast.gc_dmnd_type_b
          group by
            t1.dmnd_grp_org_id, 
            t1.mars_week, 
            t1.zrep
        ) t10
        group by 
          t10.dmnd_grp_org_id,
          t10.mars_week, 
          t10.zrep) t100;
      rv_dmnd_data csr_dmnd_data%rowtype;
    begin
      logit.enter_method (pc_package_name, 'PERFORM_PROMAX_ADJUSTMENT');
      logit.LOG ('Adjusting Promax Base Entries.');
      -- Perform a Promax P = B - Sum(1..9), and then delete B adjustment.
      open csr_dmnd_data;
      loop
        fetch csr_dmnd_data into rv_dmnd_data;
        exit when csr_dmnd_data%notfound;
        -- Check if there is any promax base data.
        if rv_dmnd_data.promax_qty is not null and rv_dmnd_data.apollo_qty is not null then 
          -- Perform the insertion of the P record for if there is a non zero difference in qty and gsv.
          if rv_dmnd_data.promax_qty <> rv_dmnd_data.apollo_qty then 
            insert into dmnd_data (
              FCST_ID,
              DMND_GRP_ORG_ID,
              MARS_WEEK,
              ZREP,
              TDU,
              QTY_IN_BASE_UOM,
              GSV,
              PRICE,
              PRICE_CONDITION,
              TYPE,
              TDU_OVRD_FLAG
            ) values (
              i_fcst_id,
              rv_dmnd_data.dmnd_grp_org_id,
              rv_dmnd_data.mars_week, 
              rv_dmnd_data.zrep, 
              rv_dmnd_data.tdu, 
              rv_dmnd_data.promax_qty - rv_dmnd_data.apollo_qty, 
              rv_dmnd_data.promax_gsv - rv_dmnd_data.apollo_gsv, 
              (rv_dmnd_data.promax_gsv - rv_dmnd_data.apollo_gsv) / (rv_dmnd_data.promax_qty - rv_dmnd_data.apollo_qty), 
              'Calc',
              gc_dmnd_type_p,
              null
            );
          end if;
          -- Now delete the previous promax base record.
          delete from dmnd_data 
          where 
            fcst_id = i_fcst_id and
            dmnd_grp_org_id = rv_dmnd_data.dmnd_grp_org_id and
            mars_week = rv_dmnd_data.mars_week and 
            zrep = rv_dmnd_data.zrep and
            type = gc_dmnd_type_b;
        end if;
      end loop;
      close csr_dmnd_data;
      commit;
      logit.leave_method;
    exception 
      when others then 
        v_result_msg := common.create_error_msg ('Unable to perform promax adjustment.') || common.create_sql_error_msg ();
        rollback;
        logit.log_error (v_result_msg);
        logit.leave_method;
    end perform_promax_adjustment;


  FUNCTION mark_forecast_valid (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- cursor to check that forecast exists before marking if valid
    CURSOR csr_forecast (i_fcst_id IN common.st_id) IS
      SELECT *
      FROM fcst
      WHERE fcst_id = i_fcst_id AND (fcst.forecast_type = demand_forecast.gc_ft_fcst OR fcst.forecast_type = demand_forecast.gc_ft_draft);

    rv_forecast      csr_forecast%ROWTYPE;
    e_fcst_id        EXCEPTION;
    v_mars_week      common.st_code;
    v_found          BOOLEAN;
    v_result         common.st_result;
    v_result_msg     common.st_message_string;
    v_forecast_type  common.st_code;
    v_moe_code       common.st_code;
    
  BEGIN
    logit.enter_method (pc_package_name, 'MARK_FORECAST_VALID');
    logit.LOG ('Marking the forecast as valid.');

    -- check to see if forecast exists.
    OPEN csr_forecast (i_fcst_id);

    FETCH csr_forecast
    INTO rv_forecast;

    v_found := FALSE;

    IF csr_forecast%FOUND THEN   -- if forecast is found then mark it at valid.
      v_forecast_type := rv_forecast.forecast_type;
      v_moe_code := rv_forecast.moe_code;

      UPDATE fcst
         SET status = demand_forecast.gc_fs_valid
       WHERE fcst_id = i_fcst_id;

      v_found := TRUE;
    END IF;

    CLOSE csr_forecast;

    COMMIT;

    -- Now report any high level missing data errors with the forecast.
    IF v_found = TRUE THEN
      DECLARE
        e_mail_error     EXCEPTION;
        v_heading        BOOLEAN;

        CURSOR csr_missing_prices (i_fcst_id IN common.st_id) IS
          SELECT e.acct_assign_name, a.zrep, (SELECT t0.matl_desc
                                              FROM matl t0
                                              WHERE t0.matl_code = reference_functions.full_matl_code (zrep) ) AS zrep_desc, a.tdu,
            ROUND (SUM (qty_in_base_uom) ) AS qty
          FROM dmnd_data a, dmnd_grp b, dmnd_grp_org c, dmnd_grp_type d, dmnd_acct_assign e
          WHERE a.fcst_id = i_fcst_id AND
           a.price IS NULL AND
           a.dmnd_grp_org_id = c.dmnd_grp_org_id AND
           b.dmnd_grp_id = c.dmnd_grp_id AND
           b.dmnd_grp_type_id = d.dmnd_grp_type_id AND
           c.acct_assign_id = e.acct_assign_id
          GROUP BY e.acct_assign_name, a.zrep, a.tdu;

        CURSOR csr_missing_determination (i_fcst_id IN common.st_id) IS
          SELECT e.acct_assign_name, a.zrep, (SELECT t0.matl_desc
                                              FROM matl t0
                                              WHERE t0.matl_code = reference_functions.full_matl_code (zrep) ) AS zrep_desc, SUM (qty_in_base_uom) AS qty
          FROM dmnd_data a, dmnd_grp b, dmnd_grp_org c, dmnd_grp_type d, dmnd_acct_assign e
          WHERE a.fcst_id = i_fcst_id AND
           a.tdu IS NULL AND
           a.dmnd_grp_org_id = c.dmnd_grp_org_id AND
           b.dmnd_grp_id = c.dmnd_grp_id AND
           b.dmnd_grp_type_id = d.dmnd_grp_type_id AND
           c.acct_assign_id = e.acct_assign_id
          GROUP BY e.acct_assign_name, a.zrep;

        CURSOR csr_negative_forecast (i_fcst_id IN common.st_id) IS
          SELECT e.acct_assign_name, b.dmnd_grp_name, a.zrep, (SELECT t0.matl_desc
                                                               FROM matl t0
                                                               WHERE t0.matl_code = reference_functions.full_matl_code (zrep) ) AS zrep_desc, a.mars_week,
            ROUND (SUM (qty_in_base_uom) ) AS qty
          FROM dmnd_data a, dmnd_grp b, dmnd_grp_org c, dmnd_grp_type d, dmnd_acct_assign e
          WHERE a.fcst_id = i_fcst_id AND
           a.dmnd_grp_org_id = c.dmnd_grp_org_id AND
           b.dmnd_grp_id = c.dmnd_grp_id AND
           b.dmnd_grp_type_id = d.dmnd_grp_type_id AND
           c.acct_assign_id = e.acct_assign_id
          GROUP BY e.acct_assign_name, b.dmnd_grp_name, a.mars_week, a.zrep
          HAVING SUM (qty_in_base_uom) <= -1
          ORDER BY acct_assign_name, dmnd_grp_name, mars_week;

        CURSOR csr_matl_moe (i_fcst_id IN common.st_id) IS
          SELECT t10.matl_code, t20.matl_desc
          FROM (SELECT DISTINCT zrep AS matl_code
                FROM dmnd_data t1
                WHERE fcst_id = i_fcst_id) t10,
            matl t20
          WHERE reference_functions.full_matl_code (t10.matl_code) = t20.matl_code AND
           NOT EXISTS (SELECT *
                       FROM matl_moe t0
                       WHERE t0.matl_code = reference_functions.full_matl_code (t10.matl_code) AND t0.item_usage_code IN ('BUY', 'MKE', 'COP') )
          UNION
          SELECT t10.matl_code, t20.matl_desc
          FROM (SELECT DISTINCT tdu AS matl_code
                FROM dmnd_data t1
                WHERE fcst_id = i_fcst_id) t10,
            matl t20
          WHERE reference_functions.full_matl_code (t10.matl_code) = t20.matl_code AND
           NOT EXISTS (SELECT *
                       FROM matl_moe t0
                       WHERE t0.matl_code = reference_functions.full_matl_code (t10.matl_code) AND t0.item_usage_code IN ('BUY', 'MKE', 'COP') );

        v_qty_total      common.st_value;
        v_counter        common.st_counter;
        v_group_members  common.t_strings;
      BEGIN
        -- Create new email.
        logit.LOG ('Now create the completed forecast email.');

        IF emailit.create_email (NULL, 'DEMAND FINANCIALS EMAIL ALERT', v_result_msg) != common.gc_success THEN
          RAISE e_mail_error;
        END IF;

        logit.LOG ('Get list of user in mailing group');

        -- Get list of email address to sent message to, if errored.
        IF security.get_group_user_emails (gc_demand_alerting_group || ' ' || v_moe_code, v_group_members, v_result_msg) = common.gc_success THEN
          FOR v_i IN v_group_members.FIRST .. v_group_members.LAST
          LOOP
            --logit.LOG('Add '||v_group_members (v_i));
            IF emailit.add_recipient (emailit.gc_area_to, emailit.gc_type_user, v_group_members (v_i), NULL, v_result_msg) != common.gc_success THEN
              logit.LOG ('Add recipeint failed');
              RAISE e_mail_error;
            END IF;
          END LOOP;
        ELSE
          logit.LOG ('Failed to find mailing list');
          RAISE e_mail_error;
        END IF;

        IF v_forecast_type = demand_forecast.gc_ft_fcst THEN
          emailit.add_content ('Demand Financials Completed Forecast Missing Data Report.');
          emailit.add_content ('---------------------------------------------------------');
          emailit.add_content ('The following forecast has just completed processing a supply file');
          emailit.add_content ('and demand file.  If there are any problems with this forecast they');
          emailit.add_content ('will be summarised below. Please run the Missing Demand Data report');
          emailit.add_content ('to find out more detail about any reported issues.');
          emailit.add_content (common.gc_crlf);
          emailit.add_content ('## Forecast ID : ' || rv_forecast.fcst_id);
          emailit.add_content ('   - Created : ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );
          emailit.add_content ('   - Casting Week : ' || rv_forecast.casting_year || LPAD (rv_forecast.casting_period, 2, '0') || rv_forecast.casting_week);
          emailit.add_content ('   - MOE Code : ' || rv_forecast.moe_code);
          emailit.add_content (common.gc_crlf);
        ELSE
          emailit.add_content ('Demand Financials Completed Draft Forecast Missing Data Report.');
          emailit.add_content ('---------------------------------------------------------------');
          emailit.add_content ('The following forecast has just completed processing a demand draft');
          emailit.add_content ('file.  If there are any problems with this forecast they will be');
          emailit.add_content ('summarised below. Please run the Missing Demand Data report to find');
          emailit.add_content ('out more detail about any reported issues.');
          emailit.add_content (common.gc_crlf);
          emailit.add_content ('## Forecast ID : ' || rv_forecast.fcst_id);
          emailit.add_content ('   - Created : ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );
          emailit.add_content ('   - Casting Week : ' || rv_forecast.casting_year || LPAD (rv_forecast.casting_period, 2, '0') || rv_forecast.casting_week);
          emailit.add_content ('   - MOE Code : ' || rv_forecast.moe_code);
          emailit.add_content (common.gc_crlf);
        END IF;

        -- Now perform any error messaging as required.
        logit.LOG ('Now report any error or warning message for this forecast.');
        -- Report the material determination or missing prices problems.
        emailit.add_content ('## Forecast Issues');
        logit.LOG ('Report any material determination issues.');
        v_heading := FALSE;
        v_qty_total := 0;
        v_counter := 0;

        FOR rv_determination IN csr_missing_determination (rv_forecast.fcst_id)
        LOOP
          IF v_heading = FALSE THEN
            emailit.add_content ('   * Material Determination Issues Were Detected.');
            v_heading := TRUE;
          END IF;

          emailit.add_content (   '     - '
                               || rv_determination.acct_assign_name
                               || ', ZREP: '
                               || rv_determination.zrep
                               || '-'
                               || rv_determination.zrep_desc
                               || ', QTY:'
                               || rv_determination.qty);
          v_counter := v_counter + 1;
          v_qty_total := v_qty_total + rv_determination.qty;
        END LOOP;

        IF v_heading = FALSE THEN
          emailit.add_content ('   * No Missing Material Determination Issues Detected.');
        ELSE
          emailit.add_content ('     - Total Issues : ' || v_counter || ', Total Quantity Affected : ' || v_qty_total);
        END IF;

        logit.LOG ('Report any pricing issues.');
        v_heading := FALSE;
        v_qty_total := 0;
        v_counter := 0;

        FOR rv_price IN csr_missing_prices (rv_forecast.fcst_id)
        LOOP
          IF v_heading = FALSE THEN
            emailit.add_content ('   * Pricing Issues Were Detected.');
            v_heading := TRUE;
          END IF;

          emailit.add_content (   '     - '
                               || rv_price.acct_assign_name
                               || ', ZREP: '
                               || rv_price.zrep
                               || '-'
                               || rv_price.zrep_desc
                               || ', TDU:'
                               || rv_price.tdu
                               || ', QTY:'
                               || rv_price.qty);
          v_counter := v_counter + 1;
          v_qty_total := v_qty_total + rv_price.qty;
        END LOOP;

        IF v_heading = FALSE THEN
          emailit.add_content ('   * No Pricing Issues Detected.');
        ELSE
          emailit.add_content ('     - Total Issues : ' || v_counter || ', Total Quantity Affected : ' || v_qty_total);
        END IF;

        logit.LOG ('Report any negative forecast issues.');
        v_heading := FALSE;
        v_qty_total := 0;
        v_counter := 0;

        FOR rv_negative IN csr_negative_forecast (rv_forecast.fcst_id)
        LOOP
          IF v_heading = FALSE THEN
            emailit.add_content ('   * Negative Forecast Issues Were Detected.');
            v_heading := TRUE;
          END IF;

          emailit.add_content (   '     - '
                               || rv_negative.acct_assign_name
                               || ', '
                               || rv_negative.dmnd_grp_name
                               || ', Mars Week:'
                               || rv_negative.mars_week
                               || ', ZREP: '
                               || rv_negative.zrep
                               || '-'
                               || rv_negative.zrep_desc
                               || ', QTY:'
                               || rv_negative.qty);
          v_counter := v_counter + 1;
          v_qty_total := v_qty_total + rv_negative.qty;
        END LOOP;

        IF v_heading = FALSE THEN
          emailit.add_content ('   * No Negative Forecast Issues Detected.');
        ELSE
          emailit.add_content ('     - Total Issues : ' || v_counter || ', Total Quantity Affected : ' || v_qty_total);
        END IF;

        -- rich code
        logit.LOG ('Report any matl moe issues.');
        v_heading := FALSE;
        v_counter := 0;

        FOR rv_matl_moe IN csr_matl_moe (rv_forecast.fcst_id)
        LOOP
          IF v_heading = FALSE THEN
            emailit.add_content ('   * The Following Materials have missing MOE information.');
            v_heading := TRUE;
          END IF;

          emailit.add_content ('     - ' || rv_matl_moe.matl_code || ', ' || rv_matl_moe.matl_desc);
          v_counter := v_counter + 1;
        END LOOP;

        IF v_heading = FALSE THEN
          emailit.add_content ('   * No Material MOE Issues Detected.');
        ELSE
          emailit.add_content ('     - Total Issues : ' || v_counter);
        END IF;

        -- Now send the email.
        logit.LOG ('Send processing email.');

        IF emailit.send_email (v_result_msg) <> common.gc_success THEN
          logit.log_error ('Unable to send alerting email. ' || common.nest_err_msg (v_result_msg) );
        END IF;
      EXCEPTION
        WHEN e_mail_error THEN
          -- exception handler  , IO error with email sub system.
          v_result_msg := common.create_error_msg ('Email send error. ' || v_result_msg);
          logit.log_error (v_result_msg);
          COMMIT;
        WHEN OTHERS THEN
          -- unhandeled exception handler  ,  Process error so send email with error details.
          v_result_msg := common.create_error_msg ('Unable to create email report correctly. ') || common.create_sql_error_msg ();
          logit.log_error (v_result_msg);
          emailit.add_content (v_result_msg);

          IF emailit.send_email (v_result_msg) = common.gc_success THEN
            logit.LOG ('Successfully sent error condition email.');
          ELSE
            logit.log_error ('Failed to send the error email.');
          END IF;

          COMMIT;
      END;
    END IF;

    logit.leave_method ();
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_fcst_id THEN
      -- casting date supplied is invalid
      o_result_msg := common.create_failure_msg ('Failed to find forecast id :' || TO_CHAR (i_fcst_id) );
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exception
      o_result_msg := common.create_error_msg ('Unable exception') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END mark_forecast_valid;

  FUNCTION br_creation_check (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- cursor to check that this is a standard forecast, that is of the type FCST.
    CURSOR csr_forecast (i_fcst_id IN common.st_id) IS
      SELECT fcst.*, moe_setting.br_week
      FROM fcst, moe_setting
      WHERE fcst_id = i_fcst_id AND fcst.forecast_type = demand_forecast.gc_ft_fcst AND fcst.moe_code = moe_setting.moe_code(+);

    rv_forecast    csr_forecast%ROWTYPE;
    e_fcst_id      EXCEPTION;
    e_create_br    EXCEPTION;
    e_dataentity   EXCEPTION;
    e_event_error  EXCEPTION;
    v_mars_week    common.st_code;
    v_message      common.st_message_string;
    v_passed       BOOLEAN;
  BEGIN
    logit.enter_method (pc_package_name, 'BR_CREATION_CHECK');
    logit.LOG ('Started BR Creation check');

    OPEN csr_forecast (i_fcst_id);

    FETCH csr_forecast
    INTO rv_forecast;

    IF csr_forecast%FOUND THEN   -- if the forecast is found and of the type FCST then
      -- find the last week for the period within the supplied forecast.
      SELECT MAX (mars_week)
      INTO   v_mars_week
      FROM mars_date
      WHERE mars_period = rv_forecast.casting_year || rv_forecast.casting_period;

      logit.LOG ('Forecast casting week:' || rv_forecast.casting_year || rv_forecast.casting_period || rv_forecast.casting_week);
      logit.LOG ('Period last week:' || v_mars_week);
      -- if this is the MOE BR week within a period.
      v_passed := FALSE;

      IF rv_forecast.br_week != '4' THEN
        IF rv_forecast.casting_year || rv_forecast.casting_period || rv_forecast.casting_week =
                                                                                  rv_forecast.casting_year || rv_forecast.casting_period || rv_forecast.br_week THEN
          v_passed := TRUE;
        END IF;
      ELSE
        IF rv_forecast.casting_year || rv_forecast.casting_period || rv_forecast.casting_week = v_mars_week THEN
          v_passed := TRUE;
        END IF;
      END IF;

      IF v_passed = TRUE THEN
        logit.LOG ('Check passed create BR');
        logit.LOG ('Create BR Data Entity for this period.');

        IF finance_characteristics.create_br_dataentity_chrstcs (rv_forecast.casting_year || rv_forecast.casting_period, v_message) != common.gc_success THEN
          RAISE e_dataentity;
        END IF;

        IF finance_characteristics.create_br_dataentity_chrstcs (mars_date_utils.inc_mars_period (rv_forecast.casting_year || rv_forecast.casting_period, 1),
                                                                 v_message) != common.gc_success THEN
          RAISE e_dataentity;
        END IF;

        logit.LOG ('Create Next Periods BR Data Entity early for other systems that may need it.  Demand financials is a good trigger for this creation.');

        -- this is the week in the period so create BR
        IF copy_forecast (i_fcst_id, demand_forecast.gc_ft_br, rv_forecast.casting_year || ' BR' || rv_forecast.casting_period, '', '', v_message) !=
                                                                                                                                               common.gc_success THEN
          RAISE e_create_br;
        ELSE
          IF eventit.trigger_events (v_message) != common.gc_success THEN
            RAISE e_event_error;
          END IF;
        END IF;
      ELSE
        logit.LOG ('Check failed');
      END IF;
    ELSE
      RAISE e_fcst_id;
    END IF;

    logit.leave_method ();
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      -- casting date supplied is invalid
      o_result_msg := common.create_failure_msg ('Failed to create event.' || TO_CHAR (i_fcst_id) || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_create_br THEN
      -- casting date supplied is invalid
      o_result_msg := common.create_failure_msg ('Failed to create br :' || TO_CHAR (i_fcst_id) || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_dataentity THEN
      -- casting date supplied is invalid
      o_result_msg := common.create_failure_msg ('Failed to br dataentity :' || TO_CHAR (i_fcst_id) || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_fcst_id THEN
      -- casting date supplied is invalid
      o_result_msg := common.create_failure_msg ('Failed to find forecast id :' || TO_CHAR (i_fcst_id) );
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exception
      o_result_msg := common.create_error_msg ('Unable exception') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END br_creation_check;

  FUNCTION create_forecast (
    i_forecast_type  IN      common.st_code,
    -- forecast type, should be FCST or DRAFT
    i_casting_week   IN      common.st_code,
    -- casting week read from incoming file, after data is loaded
    i_status         IN      common.st_code,
    -- casting week read from incoming file, after data is loaded
    i_moe_code       IN      common.st_code,
    -- moe code read from incoming file
    o_forecast_id    OUT     common.st_id,
    -- return the created forecast id
    o_result_msg     OUT     common.st_message_string)
    RETURN common.st_result IS
    v_forecast_id        common.st_id;
    e_load_date_invalid  EXCEPTION;
    e_fcst_allocate      EXCEPTION;
    v_result_msg         common.st_message_string;

    -- cursor to check for forecasrt uniqueness before forecast is created.
    CURSOR csr_forecast (i_casting_week IN common.st_code, i_forecast_type IN common.st_code, i_moe_code IN common.st_code) IS
      SELECT fcst_id
      FROM fcst
      WHERE casting_year || casting_period || casting_week = i_casting_week AND forecast_type = i_forecast_type AND moe_code = i_moe_code;

    rv_forecast          csr_forecast%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'CREATE_FORECAST');

    -- check that supply casting period is fully qaulified with week
    IF LENGTH (i_casting_week) = 7 THEN
      -- check for forecast uniqueness, using casting week, forecast type and moe code
      OPEN csr_forecast (i_casting_week, i_forecast_type, i_moe_code);

      FETCH csr_forecast
      INTO rv_forecast;

      -- if forecast does not already existing
      IF csr_forecast%NOTFOUND THEN
        -- find forecast id of forecast to create
        IF demand_object_tracking.get_new_id ('FCST', 'FCST_ID', v_forecast_id, v_result_msg) != common.gc_success THEN
          RAISE e_fcst_allocate;
        END IF;

        -- create forecasr
        INSERT INTO fcst
                    (fcst_id, casting_year, casting_period, casting_week, forecast_type, last_updated,
                     status, moe_code)
             VALUES (v_forecast_id, SUBSTR (i_casting_week, 1, 4), SUBSTR (i_casting_week, 5, 2), SUBSTR (i_casting_week, 7, 1), i_forecast_type, SYSDATE,
                     i_status, i_moe_code);

        o_forecast_id := v_forecast_id;
      ELSE
        o_forecast_id := rv_forecast.fcst_id;

        -- if forecast already exists for forecast type, moe code and casting week
        -- then update last_updated column to current system time
        UPDATE fcst
           SET last_updated = SYSDATE
         WHERE casting_year || casting_period || casting_week = i_casting_week AND forecast_type = i_forecast_type AND moe_code = i_moe_code;
      END IF;
    ELSE
      RAISE e_load_date_invalid;
    END IF;

    COMMIT;
    logit.leave_method ();
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_fcst_allocate THEN
      -- casting date supplied is invalid
      o_result_msg := common.create_failure_msg ('Failed to allocate forecast id :' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_load_date_invalid THEN
      -- casting date supplied is invalid
      o_result_msg := common.create_failure_msg ('Load date mars conversion error');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exception
      o_result_msg := common.create_error_msg ('Unable to create forecast.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END create_forecast;

  -- function below will take in a standard data as string, and return a mars period with week , qualified
  FUNCTION get_mars_week (i_string_date IN VARCHAR, i_format_string IN VARCHAR, o_mars_week OUT VARCHAR, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    e_process_failure      EXCEPTION;
    e_string_date_invalid  EXCEPTION;
    v_calender_date        DATE;
    -- used convert in string date , to a date datatype
    v_mars_day             mars_date.mars_yyyyppdd%TYPE;
    -- used to store the mars day, before be converted to mars week
    v_mars_week            mars_date.mars_week%TYPE;
    -- used to store mars week to be returned
    v_date_msg             common.st_message_string;
  BEGIN
    --valid;
    -- convert input parameter string date , to a oracle date datatype.
    v_calender_date := TO_DATE (i_string_date, i_format_string);

    -- now convert the v_calender date to a mars_day, which can then be used to find the mars week.
    IF mars_date_utils.lookup_mars_yyyyppdd (v_calender_date, v_mars_day, v_date_msg) = common.gc_success THEN
      -- mars day found, so now find the mars week.
      IF mars_date_utils.lookup_mars_week (v_mars_day, v_mars_week, v_date_msg) = common.gc_success THEN
        -- mars week found, so return value
        o_mars_week := TRIM (TO_CHAR (v_mars_week) );
        o_result_msg := 'Process Success';
        logit.leave_method ();
        RETURN common.gc_success;
      ELSE
        -- no mars week found, so raise error
        RAISE e_process_failure;
      END IF;
    ELSE
      -- no mars day found, so raise error
      RAISE e_process_failure;
    END IF;

    o_result_msg := 'Process Failure';
    logit.leave_method ();
    RETURN common.gc_failure;
  EXCEPTION
    WHEN e_string_date_invalid THEN
      --supply date is not in a valid format, so error
      o_result_msg := common.create_failure_msg ('Input date invalid') || common.create_params_str ('String date YYYYDDMM:', i_string_date);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_process_failure THEN
      -- called to mars day functions did not return a value, so error
      o_result_msg := common.create_failure_msg ('Process failure:') || common.create_params_str ('String date YYYYDDMM:', i_string_date) || v_date_msg;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END get_mars_week;

  FUNCTION sql_get_mars_week (i_date IN DATE)
    RETURN NUMBER IS
    v_calender_date  DATE;
    v_mars_week      NUMBER;

    -- cursor to find the mars week , within the mars_week reference table.
    CURSOR csr_mars_week (i_date IN DATE) IS
      SELECT t1.mars_week
      FROM mars_date t1
      WHERE t1.calendar_date = i_date;

    rv_mars_week     csr_mars_week%ROWTYPE;
  BEGIN
    -- set output to -1 , incase no value is found.
    v_mars_week := -1;

    -- try and find mars week
    OPEN csr_mars_week (i_date);

    FETCH csr_mars_week
    INTO rv_mars_week;

    -- if mars week found
    IF csr_mars_week%FOUND THEN
      -- setyp the retruned value.
      v_mars_week := rv_mars_week.mars_week;
    END IF;

    -- return mars week.
    RETURN v_mars_week;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN -1;
  END sql_get_mars_week;

  FUNCTION get_price (
    i_zrep_code             IN      common.st_code,   -- zrep to lookup.
    i_tdu_code              IN      common.st_code,   -- tdu to lookup.
    i_distribution_channel  IN      common.st_code,
    -- distribution channel used for price lookup
    i_bill_to               IN      common.st_code,
    -- bill to customer code used for price lookup
    i_company_code          IN      common.st_code,
    -- company code to use for surcharge price calculations.
    i_invoicing_party       IN      common.st_code,
    i_warehouse_list        IN      dmnd_grp.sply_whse_lst%TYPE,
    -- Supply warehouse list.
    i_calendar_day          IN      common.st_code,
    -- date for which the price will be relevant
    i_formula               IN      dmnd_grp_org.pricing_formula%TYPE,
    -- order in which the pricing conditons will be applied
    i_currency              IN      common.st_code,   -- currency of output
    o_pricing_condition     OUT     dmnd_data.price_condition%TYPE,
    -- the pricing condition that was eventually used to calc. price
    o_price                 OUT     common.st_value,
    -- and finally the price found.
    o_result_msg            OUT     common.st_message_string)
    RETURN common.st_result IS
    v_found               BOOLEAN;
    -- found was successful price found, end the search for a price
    v_sur_found           BOOLEAN;
    -- found was successful price found, end the search for a price
    v_rate                common.st_value;   --  store price found by query
    v_type                prices.crrncy_or_prcntg%TYPE;
    v_per_unit            prices.per_unit%TYPE;
    v_sur_rate            common.st_value;   --  store price surcharge
    v_sur_type            prices.crrncy_or_prcntg%TYPE;
    v_sur_per_unit        prices.per_unit%TYPE;
    v_material_code       common.st_code;
    -- store reformatted input parameter
    v_cond_type           common.st_code;
    -- split out condition, from list provided in i_formula
    v_cond_tab            common.st_code;
    -- split out condition, from list provided in i_formula
    v_cond_matl_type      common.st_code;
    -- split out of condition table , ZREP or TDU
    v_sur_charges         common.st_message_string;
    -- split out surcharges from formula string
    v_sur_charge          common.st_message_string;
    -- used to store a single surge charge.
    v_operator            common.st_code;
    v_price_formula       dmnd_grp_org.pricing_formula%TYPE;
    -- contains a sinle price records for the purpose of processing
    v_out_price_cond      dmnd_data.price_condition%TYPE;
    v_sur_out_price_cond  dmnd_data.price_condition%TYPE;
    v_start               common.st_counter;
    v_pos                 common.st_counter;
    v_rec_pos             common.st_counter;
    v_start_pos           common.st_counter;
    v_end_pos             common.st_counter;
    v_plus_pos            common.st_counter;
    v_minus_pos           common.st_counter;
    v_result              common.st_result;

    FUNCTION lookup_price (
      i_cndtn_type      IN      prices.cndtn_type%TYPE,
      i_cndtn_table     IN      prices.cndtn_table%TYPE,
      i_vrbl_key        IN      prices.vrbl_key%TYPE,
      i_calendar_date   IN      prices.from_date%TYPE,
      o_rate            OUT     prices.rate_qty_or_pcntg%TYPE,
      o_type            OUT     prices.crrncy_or_prcntg%TYPE,
      o_per_unit        OUT     prices.per_unit%TYPE,
      o_out_price_cond  OUT     dmnd_data.price_condition%TYPE)
      RETURN BOOLEAN IS
      v_rate_found  BOOLEAN;

      CURSOR csr_rate IS
        SELECT t1.rate_qty_or_pcntg, t1.crrncy_or_prcntg, t1.per_unit
        FROM prices t1
        WHERE t1.cndtn_type = i_cndtn_type AND t1.cndtn_table = i_cndtn_table AND t1.vrbl_key = i_vrbl_key
         AND i_calendar_date BETWEEN t1.from_date AND t1.TO_DATE;

      rv_rate       csr_rate%ROWTYPE;
    BEGIN
      -- try and find the price
      -- domestic price lookup with sale org only qualified.
      logit.LOG (   'Looking for Price. '
                 || common.create_params_str ('Condition Type',
                                              i_cndtn_type,
                                              'Condition Table',
                                              i_cndtn_table,
                                              'Variable Key',
                                              i_vrbl_key,
                                              'Calendar Date',
                                              i_calendar_date) );

      OPEN csr_rate;

      FETCH csr_rate
      INTO rv_rate;

      IF csr_rate%FOUND = TRUE THEN
        o_rate := rv_rate.rate_qty_or_pcntg;
        o_type := rv_rate.crrncy_or_prcntg;
        o_per_unit := rv_rate.per_unit;
        o_out_price_cond := i_cndtn_type || ':' || i_cndtn_table;
        v_rate_found := TRUE;
      ELSE
        v_rate_found := FALSE;
        o_out_price_cond := NULL;
      END IF;

      CLOSE csr_rate;

      RETURN v_rate_found;
    END lookup_price;

    FUNCTION lookup_override_price (
      i_cndtn_table     IN      ovrd_prices.cndtn_table%TYPE,
      i_matl_code       IN      ovrd_prices.matl_code%TYPE,
      i_calendar_date   IN      ovrd_prices.from_date%TYPE,
      o_rate            OUT     ovrd_prices.rate_qty_or_pcntg%TYPE,
      o_type            OUT     ovrd_prices.crrncy_or_prcntg%TYPE,
      o_per_unit        OUT     prices.per_unit%TYPE,
      o_out_price_cond  OUT     dmnd_data.price_condition%TYPE)
      RETURN BOOLEAN IS
      v_rate_found                    BOOLEAN;
      pc_cndtn_type_overide  CONSTANT common.st_code     := 'OVRD';

      CURSOR csr_rate IS
        SELECT t1.rate_qty_or_pcntg, t1.crrncy_or_prcntg
        FROM ovrd_prices t1
        WHERE t1.cndtn_table = i_cndtn_table AND t1.matl_code = i_matl_code AND i_calendar_date BETWEEN t1.from_date AND t1.TO_DATE;

      rv_rate                         csr_rate%ROWTYPE;
    BEGIN
      -- try and find the price
      -- domestic price lookup with sale org only qualified.
      logit.LOG (   'Looking for Override Price. '
                 || common.create_params_str ('Condition Type',
                                              pc_cndtn_type_overide,
                                              'Condition Table',
                                              i_cndtn_table,
                                              'Material Code',
                                              i_matl_code,
                                              'Calendar Date',
                                              i_calendar_date) );

      OPEN csr_rate;

      FETCH csr_rate
      INTO rv_rate;

      IF csr_rate%FOUND = TRUE THEN
        o_rate := rv_rate.rate_qty_or_pcntg;
        o_type := rv_rate.crrncy_or_prcntg;
        o_per_unit := 1;
        o_out_price_cond := pc_cndtn_type_overide || ':' || i_cndtn_table;
        v_rate_found := TRUE;
      ELSE
        v_rate_found := FALSE;
        o_out_price_cond := NULL;
      END IF;

      CLOSE csr_rate;

      RETURN v_rate_found;
    END lookup_override_price;
  BEGIN
    logit.enter_method (pc_package_name, 'GET_PRICE');
    v_found := FALSE;
    v_sur_found := FALSE;
    v_out_price_cond := '';
    v_pos := 1;
    v_rec_pos := 1;
    logit.LOG ('Pricing Formula:' || i_formula);
    v_out_price_cond := '';

    -- If no formula is supplied assume that this represents an always zero price.
    IF i_formula IS NULL THEN
      v_found := TRUE;
      v_rate := 0;
      v_out_price_cond := 'NO FORMULA';
    ELSE
      -- while this is a another pricing condition to try then.
      WHILE INSTR (i_formula, '#', v_rec_pos) > 0 AND v_found = FALSE
      LOOP
        -- find one pricing record and apply logic records are delimited with hash.
        v_price_formula := SUBSTR (i_formula, v_rec_pos, INSTR (i_formula, '#', v_rec_pos) );
        v_rec_pos := INSTR (i_formula, '#', v_rec_pos) + 1;
        -- reset varaibles.
        v_pos := 1;
        v_cond_tab := '';
        v_cond_type := '';
        v_sur_charges := '';
        -- separate out the pricing condition from the v_price_formula parameter
        v_start := INSTR (v_price_formula, '{', v_pos) + 1;
        v_cond_type := SUBSTR (v_price_formula, v_start, INSTR (v_price_formula, '}', v_pos) - v_start);
        -- now split zrep, tdu qualify from records.
        v_cond_matl_type := SUBSTR (v_cond_type, INSTR (v_cond_type, ',', 1) + 1, 4);
        v_cond_type := SUBSTR (v_cond_type, 1, INSTR (v_cond_type, ',') - 1);
        v_start := INSTR (v_price_formula, '(', v_pos) + 1;
        v_cond_tab := SUBSTR (v_price_formula, v_start, INSTR (v_price_formula, ')', v_pos) - v_start);
        v_pos := INSTR (v_price_formula, ')', v_pos) + 1;

        -- split of condition tab string
        IF INSTR (v_price_formula, '-', 1) > 0 OR INSTR (v_price_formula, '+', 1) > 0 THEN
          IF INSTR (v_price_formula, '-', 1) < INSTR (v_price_formula, '+', 1) AND INSTR (v_price_formula, '+', 1) > 0 THEN
            v_sur_charges := SUBSTR (v_price_formula, INSTR (v_price_formula, '-', 1), LENGTH (v_price_formula) );
          ELSE
            v_sur_charges := SUBSTR (v_price_formula, INSTR (v_price_formula, '+', 1), LENGTH (v_price_formula) );
          END IF;
        END IF;

        -- pad supplied material code to 18 chars, with proceding 0.
        v_material_code := NULL;

        IF v_cond_matl_type = 'TDU' THEN
          v_material_code := reference_functions.full_matl_code (i_tdu_code);
        END IF;

        IF v_cond_matl_type = 'ZREP' THEN
          v_material_code := reference_functions.full_matl_code (i_zrep_code);
        END IF;

        -- now run one of the following, depending of which pricing condition is next in the list.
        IF v_found = FALSE AND v_cond_tab = '811' THEN
          v_found :=
            lookup_price (v_cond_type,
                          v_cond_tab,
                          RPAD (NVL (i_company_code, '0'), 4) || NVL (i_distribution_channel, '00') || v_material_code,
                          i_calendar_day,
                          v_rate,
                          v_type,
                          v_per_unit,
                          v_out_price_cond);
        END IF;

        IF v_found = FALSE AND v_cond_tab = '812' THEN
          v_found :=
            lookup_price (v_cond_type,
                          v_cond_tab,
                          RPAD (NVL (i_company_code, '0'), 4) || v_material_code,
                          i_calendar_day,
                          v_rate,
                          v_type,
                          v_per_unit,
                          v_out_price_cond);
        END IF;

        IF v_found = FALSE AND v_cond_tab = '872' THEN
          v_found :=
            lookup_price (v_cond_type,
                          v_cond_tab,
                          RPAD (NVL (i_company_code, '0'), 4) || NVL (i_distribution_channel, '00') || LPAD (i_bill_to, 10, '0') || v_material_code,
                          i_calendar_day,
                          v_rate,
                          v_type,
                          v_per_unit,
                          v_out_price_cond);
        END IF;

        IF v_found = FALSE AND v_cond_tab = '905' THEN
          v_found :=
            lookup_price (v_cond_type,
                          v_cond_tab,
                          RPAD (NVL (i_company_code, '0'), 4) || NVL (i_distribution_channel, '00') || LPAD (i_bill_to, 10, '0') || v_material_code,
                          i_calendar_day,
                          v_rate,
                          v_type,
                          v_per_unit,
                          v_out_price_cond);
        END IF;

        IF v_found = FALSE AND v_cond_tab = '4' THEN
          v_found :=
            lookup_price (v_cond_type,
                          v_cond_tab,
                          RPAD (NVL (i_company_code, '0'), 4) || NVL (i_distribution_channel, '00') || v_material_code,
                          i_calendar_day,
                          v_rate,
                          v_type,
                          v_per_unit,
                          v_out_price_cond);
        END IF;

        IF v_found = FALSE AND v_cond_tab = '969' THEN
          v_found :=
            lookup_price (v_cond_type,
                          v_cond_tab,
                          LPAD (NVL (i_invoicing_party, '0'), 10, '0') || RPAD (v_material_code, 18, ' ') || '0',
                          i_calendar_day,
                          v_rate,
                          v_type,
                          v_per_unit,
                          v_out_price_cond);
        END IF;

        IF v_found = FALSE AND v_cond_tab = '956' THEN
          v_found :=
            lookup_price (v_cond_type,
                          v_cond_tab,
                          RPAD (NVL (i_company_code, '0'), 4) || NVL (i_distribution_channel, '00') || '01' || v_material_code,
                          i_calendar_day,
                          v_rate,
                          v_type,
                          v_per_unit,
                          v_out_price_cond);
        END IF;

        IF v_found = FALSE AND v_cond_type = 'OVRD' THEN
          v_found :=
            lookup_override_price (v_cond_tab,
                                   reference_functions.short_matl_code (v_material_code),
                                   i_calendar_day,
                                   v_rate,
                                   v_type,
                                   v_per_unit,
                                   v_out_price_cond);
        END IF;

        -- if a price was found, then set output , and return value,
        IF v_found THEN
          logit.LOG ('Price Found: ' || v_rate || ', Type/Currency: ' || v_type || ', ' || v_out_price_cond);

          IF v_type <> i_currency THEN
            logit.LOG ('Applying Currency Conversion From ' || v_type || ' to ' || i_currency || '.');
            v_rate := reference_functions.currcy_conv (v_rate, v_type, i_currency, TO_DATE (i_calendar_day, 'YYYYMMDD'), 'MPPR');
            logit.LOG ('Currency Converted Price: ' || v_rate);
          END IF;

          IF v_per_unit IS NOT NULL OR v_per_unit NOT IN (0, 1) THEN
            logit.LOG ('Applying Per Unit Conversion.');
            v_rate := v_rate / v_per_unit;
          END IF;

          -- now calclate surcharges
          v_pos := 1;

          WHILE INSTR (v_sur_charges, '-', v_pos) > 0 OR INSTR (v_sur_charges, '+', v_pos) > 0
          -- loop for all surcharges that need to be applied
          LOOP
            v_start_pos := 0;   -- parse starting point of a surcharge
            v_end_pos := 0;   -- parse end point of a surcharge.
            -- now find starting position
            v_plus_pos := INSTR (v_sur_charges, '+', v_pos);
            -- find the pos. of the first plus sign.
            v_minus_pos := INSTR (v_sur_charges, '-', v_pos);

            -- find the pos. of the first minus sign.

            -- if no plus sign found then set location pass end of string
            IF v_plus_pos = 0 THEN
              v_plus_pos := 99999999;
            END IF;

            -- if nominus sign found then set location pass end of string
            IF v_minus_pos = 0 THEN
              v_minus_pos := 99999999;
            END IF;

            -- establish wether a plus/minus sign appers first in the parsed string.
            IF v_minus_pos < v_plus_pos THEN   -- if a minus is first
              v_start_pos := INSTR (v_sur_charges, '-', v_pos);
              v_pos := v_start_pos + 1;
            ELSE   -- if a plus is first.
              v_start_pos := INSTR (v_sur_charges, '+', v_pos);
              v_pos := v_start_pos + 1;
            END IF;

            -- now find ending position
            v_plus_pos := INSTR (v_sur_charges, '+', v_pos);
            v_minus_pos := INSTR (v_sur_charges, '-', v_pos);

            IF v_plus_pos = 0 THEN
              v_plus_pos := 99999999;
            END IF;

            IF v_minus_pos = 0 THEN
              v_minus_pos := 99999999;
            END IF;

            -- establish wether a plus/minus sign appers first in the parsed string.
            IF v_minus_pos < v_plus_pos THEN
              v_end_pos := INSTR (v_sur_charges, '-', v_pos);
            ELSE
              v_end_pos := INSTR (v_sur_charges, '+', v_pos);
            END IF;

            IF v_end_pos = 0 THEN
              v_end_pos := LENGTH (v_sur_charges);
            END IF;

            -- parsing complete now separate a surcharge from the complete string and furthur separate the details.
            --
            v_sur_charge := SUBSTR (v_sur_charges, v_start_pos, v_end_pos - v_start_pos);
            logit.LOG ('Searching for Surcharge: ' || v_sur_charge);
            v_operator := '';
            v_cond_tab := '';
            v_cond_type := '';
            v_cond_matl_type := '';
            v_start := 0;
            v_operator := SUBSTR (v_sur_charge, 1, 1);
            -- separate out the pricing condition from the v_price_formula parameter
            v_start := INSTR (v_sur_charge, '{', 2) + 1;
            v_cond_type := SUBSTR (v_sur_charge, v_start, INSTR (v_sur_charge, '}', 2) - v_start);
            -- now split zrep, tdu qualify from records.
            v_cond_matl_type := SUBSTR (v_cond_type, INSTR (v_cond_type, ',', 1) + 1, 4);
            v_cond_type := SUBSTR (v_cond_type, 1, INSTR (v_cond_type, ',') - 1);
            v_start := INSTR (v_sur_charge, '(', 2) + 1;
            v_cond_tab := SUBSTR (v_sur_charge, v_start, INSTR (v_sur_charge, ')', 2) - v_start);
            v_material_code := NULL;

            -- surge charge completly split and parsed.
            IF v_cond_matl_type = 'TDU' THEN
              v_material_code := reference_functions.full_matl_code (i_tdu_code);
            END IF;

            IF v_cond_matl_type = 'ZREP' THEN
              v_material_code := reference_functions.full_matl_code (i_zrep_code);
            END IF;

            -- Now try to apply charges
            IF v_cond_tab = '980' THEN
              DECLARE
                CURSOR csr_surcharge980 IS
                  SELECT t1.rate_qty_or_pcntg, t1.crrncy_or_prcntg, t1.per_unit
                  FROM prices t1
                  WHERE t1.cndtn_type = v_cond_type AND
                   t1.cndtn_table = v_cond_tab AND
                   i_calendar_day BETWEEN t1.from_date AND t1.TO_DATE AND
                   i_warehouse_list LIKE '%' || SUBSTR (t1.vrbl_key, 11, 2) || '%';

                rv_rate  csr_surcharge980%ROWTYPE;
              BEGIN
                OPEN csr_surcharge980;

                FETCH csr_surcharge980
                INTO rv_rate;

                IF csr_surcharge980%FOUND = TRUE THEN
                  v_sur_rate := rv_rate.rate_qty_or_pcntg;
                  v_sur_type := rv_rate.crrncy_or_prcntg;
                  v_sur_per_unit := rv_rate.per_unit;
                  v_sur_out_price_cond := v_cond_type || ':' || v_cond_tab;
                  v_sur_found := TRUE;
                ELSE
                  v_sur_found := FALSE;
                  v_sur_out_price_cond := NULL;
                END IF;

                CLOSE csr_surcharge980;
              END;
            END IF;

            IF v_cond_tab = '924' THEN
              DECLARE
                CURSOR csr_surcharge924 IS
                  SELECT t1.rate_qty_or_pcntg, t1.crrncy_or_prcntg, t1.per_unit
                  FROM prices t1, cust_prtnr_roles t2
                  WHERE t1.cndtn_type = v_cond_type AND
                   t1.cndtn_table = v_cond_tab AND
                   i_calendar_day BETWEEN t1.from_date AND t1.TO_DATE AND
                   SUBSTR (t1.vrbl_key, 5, 10) = t2.cust_code AND
                   t2.sales_org = i_company_code AND
                   dstrbtn_chnl = i_distribution_channel AND
                   t2.prtnr_fnctn = 'RE' AND
                   t2.cust_code_bus_prtnr = i_bill_to;

                rv_rate  csr_surcharge924%ROWTYPE;
              BEGIN
                OPEN csr_surcharge924;

                FETCH csr_surcharge924
                INTO rv_rate;

                IF csr_surcharge924%FOUND = TRUE THEN
                  v_sur_rate := rv_rate.rate_qty_or_pcntg;
                  v_sur_type := rv_rate.crrncy_or_prcntg;
                  v_sur_per_unit := rv_rate.per_unit;
                  v_sur_out_price_cond := v_cond_type || ':' || v_cond_tab;
                  v_sur_found := TRUE;
                ELSE
                  v_sur_found := FALSE;
                  v_sur_out_price_cond := NULL;
                END IF;

                CLOSE csr_surcharge924;
              END;
            END IF;

            -- price found, set pricing condition used, and found flag so loop can exit
            IF v_sur_found = TRUE THEN
              v_out_price_cond := v_out_price_cond || v_operator || v_sur_out_price_cond;
              logit.LOG ('Surcharge Found: ' || v_sur_rate || ', Type/Currency: ' || v_sur_type || ', ' || v_sur_out_price_cond);

              -- now apply the surcharge
              IF v_sur_type = '%' THEN   -- if a percentage
                IF v_operator = '+' THEN
                  v_rate := v_rate + ( (v_rate / 100) * v_sur_rate);
                ELSE
                  v_rate := v_rate - ( (v_rate / 100) * v_sur_rate);
                END IF;
              ELSE   -- if a dollar cents amount
                IF v_sur_type <> i_currency THEN   -- if surcharge is in correct currency.
                  logit.LOG ('Applying Currency Conversion From ' || v_sur_type || ' to ' || i_currency || '.');
                  v_sur_rate := reference_functions.currcy_conv (v_sur_rate, v_sur_type, i_currency, TO_DATE (i_calendar_day, 'YYYYMMDD'), 'MPPR');
                  logit.LOG ('Currency Converted Price: ' || v_sur_rate);
                END IF;

                IF v_sur_per_unit IS NOT NULL OR v_sur_per_unit NOT IN (0, 1) THEN
                  logit.LOG ('Applying Per Unit Conversion.');
                  v_sur_rate := v_sur_rate / v_sur_per_unit;
                END IF;

                IF v_operator = '+' THEN
                  v_rate := v_rate + v_sur_rate;
                ELSE
                  v_rate := v_rate - v_sur_rate;
                END IF;
              END IF;

              logit.LOG ('Surchaged Price:' || v_rate);
            END IF;
          END LOOP;
        END IF;
      END LOOP;
    END IF;

    -- if none of pricing pricing conditions applied worked then return an error.
    IF v_found = TRUE THEN
      o_pricing_condition := v_out_price_cond;
      o_price := v_rate;
      o_result_msg := common.gc_success_str;
      v_result := common.gc_success;
    ELSE
      -- no price found raise exception
      logit.LOG ('Price Not Found');
      o_result_msg :=
           common.create_failure_msg ('No price found: ')
        || common.create_params_str ('Tdu code', i_tdu_code, 'Zrep Code', i_zrep_code, 'Calendar Date', i_calendar_day);
      v_result := common.gc_failure;
    END IF;

    logit.leave_method;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      -- unhandled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END;

  -- find the zrep for a given tdu, for a specified data.
  FUNCTION get_zrep_for_tdu (i_tdu IN common.st_code, o_zrep OUT common.st_code, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_result  common.st_result;

    -- cursor, to find zrep, take in tdu code.
    CURSOR csr_tdu (i_tdu IN common.st_code) IS
      SELECT rprsnttv_item_code
      FROM matl
      WHERE matl_code = i_tdu;

    rv_tdu    csr_tdu%ROWTYPE;
    v_tdu     common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'GET_ZREP_FOR_TDU');
    v_result := common.gc_success;
    -- try and find the zrep.
    v_tdu := reference_functions.full_matl_code (i_tdu);

    OPEN csr_tdu (v_tdu);

    FETCH csr_tdu
    INTO rv_tdu;

    -- if no zrep found , then return an error.
    IF csr_tdu%NOTFOUND THEN
      o_result_msg := 'Unable to find traded unit material for zrep lookup.';
      v_result := common.gc_failure;
    END IF;

    CLOSE csr_tdu;

    -- return the found zrep.
    -- Now check if the rep item code is null.
    IF rv_tdu.rprsnttv_item_code IS NULL THEN
      o_result_msg := 'Representative item code was null for tdu : ' || i_tdu;
      v_result := common.gc_failure;
    ELSE
      o_zrep := rv_tdu.rprsnttv_item_code;
    END IF;

    logit.leave_method ();
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      -- unhandeled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END get_zrep_for_tdu;

  FUNCTION load_supply_feed (i_run_id IN common.st_id, i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
       -- cursor to check for files that need to be processed,
    -- file that have a status of LOADED.
    CURSOR csr_file_list (i_wildcard IN VARCHAR2) IS
      SELECT *
      FROM dir_list
      WHERE UPPER (wildcard) = UPPER (i_wildcard) AND file_name NOT IN (SELECT file_name
                                                                        FROM load_file
                                                                        WHERE (status = common.gc_processed OR status = common.gc_ignored) );

    -- Cursor to retrieve all lines from a given file.
    CURSOR csr_load_data (i_file_id IN common.st_id) IS
      SELECT *
      FROM load_sply_raw
      WHERE status = common.gc_loaded AND file_id = i_file_id
      FOR UPDATE;

    e_file_error         EXCEPTION;   -- file IO error
    e_event_error        EXCEPTION;   -- event processing error
    rv_load_data         csr_load_data%ROWTYPE;
    --  data load into load_sply_raw
    rv_file_list         csr_file_list%ROWTYPE;
    -- file list for LOADED supply files.
    v_qty                common.st_value;   -- QTY forecasr
    v_item               common.st_code;   -- Item forecast
    v_dest               common.st_code;
    -- Destination warehouse, use to lookup demand group.
    v_forecast_date      DATE;
    v_casting_date       DATE;   -- Casting mars week, forecast period for.
    v_schedshipdate      DATE;
    v_conversion         common.st_message_string;
    v_message            common.st_message_string;
    v_line               common.st_message_string;
    -- line of data from file
    v_mars_week          common.st_value;   -- converted date into mars week.
    v_casting_mars_week  common.st_value;   -- Forecast date for, mars week,
    v_wildcard           common.st_message_string;
    -- wild card user for file list
    v_file_id            common.st_id;   -- file id of file being processed.
    v_line_number        common.st_value;
    -- line number of file being processed.
    v_event_type         common.st_code;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_SUPPLY_FEED');
    v_wildcard := i_wildcard;   -- file beginning with

    -- now get a list of file beginning with the wildcard
    IF get_directory_list (v_wildcard, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    IF fileit.close_file (v_message) != common.gc_success THEN
      v_message := '';
    END IF;

    -- for each file found to process loop.
    FOR rv_file_list IN csr_file_list (v_wildcard)
    LOOP
      -- open the file.
      IF fileit.open_file (plan_common.gc_planning_directory, rv_file_list.file_name, fileit.gc_file_mode_read, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      -- add the file details to load_file,  files with same name, will not be added twice.
      IF add_file (i_run_id, rv_file_list.file_name, rv_file_list.wildcard, rv_file_list.moe_code, v_file_id, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      -- if add_file failed. then error out.
      IF v_file_id IS NULL OR v_file_id = 0 THEN
        v_message := 'File id invalid, add_file failed to return value';
        RAISE e_file_error;
      END IF;

      -- Incase this is a reload of file, then delete the contents from the load tables first.
      DELETE FROM load_sply_raw
            WHERE file_id = v_file_id;

      DELETE FROM load_sply
            WHERE file_id = v_file_id;

      COMMIT;

         -- loop arround the contents of a file.
      -- add the file details unvalidated into the load_sply_raw table.
      WHILE fileit.read_file (v_line, v_message) = common.gc_success
      LOOP
        INSERT INTO load_sply_raw
                    (line, status, file_id)
             VALUES (v_line, common.gc_loaded, v_file_id);
      END LOOP;

      IF fileit.close_file (v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      -- trigger event
      IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_supply) THEN
        v_event_type := demand_events.gc_load_raw_supply;
      ELSE
        v_event_type := demand_events.gc_load_raw_sply_draft;
      END IF;

      IF eventit.create_event (demand_forecast.gc_system_code, v_event_type, v_file_id, 'Raw file loaded', v_message) != common.gc_success THEN
        RAISE e_event_error;
      END IF;

      COMMIT;
      -- reset line counter.
      v_line_number := 1;

      -- for each line in the raw file, split into field, validate, datatypes, and add to load_sply.
      FOR rv_load_data IN csr_load_data (v_file_id)
      LOOP
        v_conversion := NULL;

        BEGIN
          v_item := SUBSTR (rv_load_data.line, 1, 8);   -- TDU
          v_dest := RTRIM (SUBSTR (rv_load_data.line, 9, 5) );
          -- destination warehouse, used to find demand group.
          v_qty := TO_NUMBER (SUBSTR (rv_load_data.line, 14, 20) );
          -- the amount forecast
          v_schedshipdate := TO_DATE (SUBSTR (rv_load_data.line, 34, 8), 'YYYYMMDD');
          -- forecast day.
          v_casting_date := TO_DATE (SUBSTR (rv_load_data.line, 90, 8), 'YYYYMMDD');
          -- casting mars week,
          v_mars_week := sql_get_mars_week (v_schedshipdate);
          -- converted forecast day into mars_week.
          v_casting_mars_week := sql_get_mars_week (v_casting_date - 3);
        -- casting marsweek.
        EXCEPTION
          WHEN OTHERS THEN
            v_conversion := common.create_error_msg ('Row data conversion error:') || common.create_sql_error_msg ();
            logit.LOG (v_conversion);
        END;

        IF v_conversion IS NULL THEN
          -- record ok , so insert into load_sply.
          INSERT INTO load_sply
                      (item, dest, schedshipdate, qty, mars_week, casting_mars_week, status, file_id, file_line)
               VALUES (TRIM (v_item), v_dest, v_schedshipdate, v_qty, v_mars_week, v_casting_mars_week, common.gc_loaded, v_file_id, v_line_number);
        ELSE
          -- record failed to load so set status to errored.
          UPDATE load_sply_raw
             SET status = common.gc_errored,
                 processed_date = SYSDATE,
                 error_msg = v_conversion
           WHERE CURRENT OF csr_load_data;
        END IF;

        -- increment line number.
        v_line_number := v_line_number + 1;
      END LOOP;

      -- set to status to  processed for all line, exception all line which are errored.
      UPDATE load_sply_raw
         SET status = common.gc_processed,
             processed_date = SYSDATE
       WHERE status = common.gc_loaded AND file_id = v_file_id;

      -- now set the file status to loaded.
      UPDATE load_file
         SET status = common.gc_loaded
       WHERE file_id = v_file_id;

      -- file loaded sucessfully , so create event.
         -- tigger events.
      IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_supply) THEN
        v_event_type := demand_events.gc_load_supply;
      ELSE
        v_event_type := demand_events.gc_load_sply_draft;
      END IF;

      IF eventit.create_event (demand_forecast.gc_system_code, v_event_type, v_file_id, 'File loaded', v_message) != common.gc_success THEN
        RAISE e_event_error;
      END IF;

      COMMIT;
    END LOOP;

    o_result_msg := 'Process Success';
    logit.leave_method ();
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      COMMIT;
      o_result_msg := common.create_failure_msg ('Event error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_file_error THEN
      o_result_msg := common.create_failure_msg ('File IO error:' || v_message);
      logit.LOG (o_result_msg);
      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      ROLLBACK;

      -- on other error, then rollback , and set file load status to errored.
      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      COMMIT;
      logit.leave_method;
      RETURN common.gc_error;
  END load_supply_feed;

  FUNCTION process_supply_feed (i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    e_forecast_id_failure  EXCEPTION;   -- forecast id allocation error
    e_demand_grp_failure   EXCEPTION;   -- demand group lookup error
    e_demand_tdu_failure   EXCEPTION;   -- material lookup error
    e_business_segment     EXCEPTION;   -- business segment lookuo error
    e_company_code         EXCEPTION;
    e_demand_group_org     EXCEPTION;   -- demand group org lookup error.
    e_event_error          EXCEPTION;   -- demand event lookup error.

    -- cursor that are sitting at a state of loaded. of the type supply.
    CURSOR csr_files IS
      SELECT load_sply.file_id, MAX (load_file.moe_code) moe_code
      FROM load_sply, load_file
      WHERE load_sply.status IN (common.gc_loaded) AND
       load_sply.file_id = load_file.file_id AND
       load_file.status = common.gc_loaded AND
       UPPER (load_file.wildcard) = UPPER (i_wildcard)
      GROUP BY load_sply.file_id;

    -- buisness segment lookup cursor.
    CURSOR csr_business_segment (i_matl_code IN VARCHAR) IS
      SELECT bus_sgmnt_code
      FROM matl_fg_clssfctn
      WHERE matl_code = i_matl_code;

    -- material lookup cursor.
    CURSOR csr_matl (i_tdu IN VARCHAR) IS
      SELECT *
      FROM matl
      WHERE matl_code = i_tdu AND matl_type = 'FERT' AND trdd_unit = 'X';

    -- fine the unique casting week,  forecast line, incase a single file contained more that one forecast
    CURSOR csr_casting_weeks (i_file_id IN common.st_id) IS
      SELECT DISTINCT casting_mars_week
      FROM load_sply
      WHERE status = common.gc_loaded AND file_id = i_file_id;

    -- main data loop cursor, record for a given file /  forecast.
    CURSOR csr_load_data (i_file_id IN common.st_id, i_casting_mars_week common.st_value) IS
      SELECT load_sply.*
      FROM load_sply
      WHERE casting_mars_week = i_casting_mars_week AND status = common.gc_loaded AND file_id = i_file_id;

    -- demand group org lookup cursor
    CURSOR csr_demand_group_org (i_warehouse_code IN VARCHAR, i_source_code IN VARCHAR, i_business_segment_code IN VARCHAR) IS
      SELECT dgo.dmnd_grp_org_id, dgo.currcy_code, dgo.invc_prty, dgo.distbn_chnl, dgo.pricing_formula, dgo.bill_to_code, dgo.ship_to_code, dgo.sales_org,
        dgo.cust_hrrchy_code, dgo.mltplr_value, dg.sply_whse_lst
      FROM dmnd_grp dg, dmnd_grp_type dt, dmnd_grp_org dgo
      WHERE dg.dmnd_grp_type_id = dt.dmnd_grp_type_id AND
       dg.dmnd_grp_id = dgo.dmnd_grp_id AND
       dt.dmnd_grp_type_code = gc_demand_group_code_supply AND
       dgo.source_code = i_source_code AND
       dg.sply_whse_lst LIKE '%' || i_warehouse_code || '%' AND
       dgo.bus_sgmnt_code = i_business_segment_code;

    rv_load_data           csr_load_data%ROWTYPE;   -- main data record set
    rv_casting_weeks       csr_casting_weeks%ROWTYPE;
    -- list of forecasr(casting weeks) within a file.
    rv_demand_group_org    csr_demand_group_org%ROWTYPE;
    -- demand group org lookup.
    rv_matl                csr_matl%ROWTYPE;   -- material lookup
    rv_business_segment    csr_business_segment%ROWTYPE;
    -- business segment lookup
    v_country_code         VARCHAR2 (2);   -- country code.
    v_price_condition      common.st_message_string;
    -- pricing formula used to calculate price.
    v_item_valid           BOOLEAN;   -- TDU is valid.
    v_invalid_reason       common.st_message_string;
    -- reject reason for record.
    v_calendar_day         VARCHAR2 (8);   -- calandar day for price lookup.
    v_zrep                 common.st_code;   -- ZREP lookup from TDU.
    v_price                common.st_value;   -- price found by get_price
    v_forecast_id          common.st_id;
    -- forecast id returned by create_forecast.
    v_message_out          common.st_message_string;
    -- standard inter procedure
    v_test_num             common.st_value;   -- check char is also integer
    v_material_code        common.st_code;   -- material code
    v_dest                 common.st_code;   -- dentination warehouse
    v_source_code          common.st_code;
    -- source code returned from get_source, used for forecast row multipexing.
    v_file_id              common.st_id;   -- load file id.
    v_moe_code             common.st_code;   -- moe code.
    v_forecast_type        common.st_code;
    v_event_type           common.st_code;
    v_event_text           common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_SUPPLY_FEED');
    logit.LOG ('Begin');

    -- loop all file sitting at a state of processed, if you need to
    -- re-process a file , set its status to 'LOADED''
    FOR rv_files IN csr_files
    LOOP
      v_file_id := rv_files.file_id;
      v_moe_code := rv_files.moe_code;

      -- loop all casting week( forecasts) within a given file.
      FOR rv_casting_weeks IN csr_casting_weeks (rv_files.file_id)
      LOOP
        logit.LOG ('Loop loaded days in raw data');

        -- create the forecast, if a forecast has not alread been created for this casting period, if so return forecast_id to use.
        IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_supply) THEN
          v_forecast_type := demand_forecast.gc_ft_fcst;
        ELSE
          v_forecast_type := demand_forecast.gc_ft_draft;
        END IF;

        IF create_forecast (v_forecast_type, rv_casting_weeks.casting_mars_week, gc_fs_invalid, v_moe_code, v_forecast_id, v_message_out) = common.gc_success THEN
                -- delete any data from dmnd_data table incase this is a rerun.
          -- only delete rows for any demand_grp included with the current file.
          -- this allows for a part forecast to be processed.
          DELETE FROM dmnd_data
                WHERE fcst_id = v_forecast_id AND
                      dmnd_grp_org_id IN (
                        SELECT DISTINCT dgo.dmnd_grp_org_id
                        FROM dmnd_grp dg, dmnd_grp_org dgo, dmnd_grp_type dt, load_sply
                        WHERE dg.dmnd_grp_type_id = dt.dmnd_grp_type_id AND
                         dg.dmnd_grp_id = dgo.dmnd_grp_id AND
                         dt.dmnd_grp_type_code = gc_demand_group_code_supply AND
                         load_sply.file_id = rv_files.file_id AND
                         dg.sply_whse_lst LIKE '%' || load_sply.dest || '%');

          -- loop throught data to be loaded within a given file / forecast.
          FOR rv_load_data IN csr_load_data (rv_files.file_id, rv_casting_weeks.casting_mars_week)
          LOOP
            v_item_valid := TRUE;
            -- set to false if any validation check fail for an item.
            v_invalid_reason := NULL;   -- reason why validation failed.
            v_dest := rv_load_data.dest;

            -- split out destination warehouse.

            -- if the warecode is NOT 4 or 5 digit then error record.
            IF LENGTH (TRIM (rv_load_data.dest) ) = 4 OR LENGTH (TRIM (rv_load_data.dest) ) = 5 THEN
              -- calendar start_date to mars date,
              v_calendar_day := TO_CHAR (rv_load_data.schedshipdate, 'YYYYMMDD');
              v_material_code := reference_functions.full_matl_code (rv_load_data.item);

              -- now check that the material is valid.
              OPEN csr_matl (v_material_code);

              FETCH csr_matl
              INTO rv_matl;

              IF csr_matl%FOUND THEN
                -- material is valid

                -- now lookup the
                IF get_zrep_for_tdu (rv_load_data.item, v_zrep, v_message_out) = common.gc_success THEN
                  OPEN csr_business_segment (v_material_code);

                  FETCH csr_business_segment
                  INTO rv_business_segment;

                  IF csr_business_segment%NOTFOUND THEN
                    RAISE e_business_segment;
                  END IF;

                  v_source_code := get_source_code (v_material_code);

                  OPEN csr_demand_group_org (rv_load_data.dest, v_source_code, rv_business_segment.bus_sgmnt_code);

                  FETCH csr_demand_group_org
                  INTO rv_demand_group_org;

                  IF csr_demand_group_org%FOUND THEN
                    WHILE csr_demand_group_org%FOUND
                    LOOP
                      IF get_price (v_zrep,
                                    rv_load_data.item,
                                    rv_demand_group_org.distbn_chnl,
                                    rv_demand_group_org.bill_to_code,
                                    rv_demand_group_org.sales_org,
                                    rv_demand_group_org.invc_prty,
                                    rv_demand_group_org.sply_whse_lst,
                                    v_calendar_day,
                                    rv_demand_group_org.pricing_formula,
                                    rv_demand_group_org.currcy_code,
                                    v_price_condition,
                                    v_price,
                                    v_message_out) <> common.gc_success THEN
                        v_invalid_reason := 'Price Lookup Failure.';
                      END IF;

                      INSERT INTO dmnd_data
                                  (fcst_id, dmnd_grp_org_id, tdu, zrep,
                                   qty_in_base_uom, gsv,
                                   mars_week, price_condition, price, TYPE)
                           VALUES (v_forecast_id, rv_demand_group_org.dmnd_grp_org_id, rv_load_data.item, LTRIM (v_zrep, '0'),
                                   rv_load_data.qty * rv_demand_group_org.mltplr_value, (rv_load_data.qty * rv_demand_group_org.mltplr_value) * v_price,
                                   rv_load_data.mars_week, v_price_condition, v_price, NULL);

                      v_item_valid := TRUE;

                      --CLOSE csr_demand_data;
                      FETCH csr_demand_group_org
                      INTO rv_demand_group_org;
                    END LOOP;
                  ELSE
                    RAISE e_demand_group_org;
                  END IF;

                  CLOSE csr_demand_group_org;

                  CLOSE csr_business_segment;
                ELSE
                  v_item_valid := FALSE;
                  v_invalid_reason := 'ZREP Lookup Error.';
                END IF;
              ELSE
                v_item_valid := FALSE;
                v_invalid_reason := 'TDU Lookup Error.';
              END IF;

              CLOSE csr_matl;
            ELSE
              v_item_valid := FALSE;
              v_invalid_reason := 'Unknown Destination Error.';
            END IF;

            IF v_item_valid = FALSE THEN
              UPDATE load_sply
                 SET status = common.gc_errored,
                     processed_date = SYSDATE,
                     error_msg = v_invalid_reason
               WHERE file_id = rv_load_data.file_id AND file_line = rv_load_data.file_line;

              v_item_valid := FALSE;
            ELSE
              logit.LOG ('Record loaded');

              UPDATE load_sply
                 SET status = DECODE (v_invalid_reason, NULL, common.gc_processed, common.gc_failed),
                     processed_date = SYSDATE,
                     error_msg = v_invalid_reason
               WHERE file_id = rv_load_data.file_id AND file_line = rv_load_data.file_line;
            END IF;
          END LOOP;
        ELSE
          RAISE e_forecast_id_failure;
        END IF;

        -- create events
        IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_supply) THEN
          v_event_type := demand_events.gc_df_fcst_supply;
          v_event_text := 'Supply forecast created:' || TO_CHAR (v_forecast_id);
        ELSE
          v_event_type := demand_events.gc_df_draft_supply;
          v_event_text := 'Supply draft forecast created:' || TO_CHAR (v_forecast_id);
        END IF;

        IF eventit.create_event (demand_forecast.gc_system_code, v_event_type, v_forecast_id, v_event_text, v_message_out) != common.gc_success THEN
          RAISE e_event_error;
        END IF;

        COMMIT;
      END LOOP;

      UPDATE load_file
         SET status = common.gc_processed
       WHERE file_id = rv_files.file_id;
    END LOOP;

    --close csr_fd_aff_supply;
    COMMIT;
    o_result_msg := 'Process Success';
    logit.leave_method ();
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('event creation error. ') || v_message_out;
      ROLLBACK;

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      logit.LOG (o_result_msg);
      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_demand_group_org THEN
      o_result_msg :=
           common.create_failure_msg ('demand group org lookup failure ')
        || common.create_params_str ('tdu code', v_material_code)
        || common.create_params_str ('dest code', v_dest)
        || common.create_params_str ('source code', v_source_code)
        || common.create_params_str ('business segment', rv_business_segment.bus_sgmnt_code);
      ROLLBACK;
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_business_segment THEN
      o_result_msg := common.create_failure_msg ('Business segment invalid ') || common.create_params_str ('tdu code', v_material_code);
      ROLLBACK;
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_demand_tdu_failure THEN
      o_result_msg := common.create_failure_msg ('Failed to get zrep for TDU. ') || common.create_params_str ('tdu code', rv_load_data.item);
      ROLLBACK;
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_demand_grp_failure THEN
      o_result_msg := common.create_failure_msg ('Demand group failure warehouse code:' || v_dest);
      ROLLBACK;
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_forecast_id_failure THEN
      ROLLBACK;
      o_result_msg := common.create_failure_msg ('Forecast id invalid or null');
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      ROLLBACK;
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_error;
  END process_supply_feed;

  FUNCTION load_demand_feed (i_run_id IN common.st_id, i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    CURSOR csr_load_data (i_file_id IN common.st_id) IS
      SELECT *
      FROM load_dmnd_raw
      WHERE status = common.gc_loaded AND file_id = i_file_id;

    CURSOR csr_file_list (i_wildcard IN VARCHAR2) IS
      SELECT *
      FROM dir_list
      WHERE UPPER (wildcard) = UPPER (i_wildcard) AND file_name NOT IN (SELECT file_name
                                                                        FROM load_file
                                                                        WHERE (status = common.gc_processed OR status = common.gc_ignored) );

    e_file_error         EXCEPTION;
    e_event_error        EXCEPTION;
    rv_load_data         csr_load_data%ROWTYPE;
    rv_file_list         csr_file_list%ROWTYPE;
    v_dmdunit            common.st_code;
    v_dmdgroup           common.st_code;
    v_loc                common.st_code;
    v_load_date          DATE;
    v_start_date         DATE;
    v_dur                common.st_code;
    v_type               common.st_code;
    v_qty                NUMBER (22, 4);
    v_mars_week          common.st_value;
    v_casting_mars_week  common.st_value;
    v_conversion         common.st_message_string;
    v_message            common.st_message_string;
    v_line               common.st_message_string;
    v_file               common.st_message_string;
    v_wildcard           common.st_message_string;
    v_max_seed           NUMBER;
    v_file_id            common.st_id;
    v_line_number        common.st_value;
    v_event_type         common.st_code;
    v_fcst_text          common.st_name;
    v_promo_type         common.st_description;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_DEMAND_FEED');
    v_wildcard := i_wildcard;

    IF get_directory_list (v_wildcard, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    IF fileit.close_file (v_message) != common.gc_success THEN
      v_message := '';
    END IF;

    FOR rv_file_list IN csr_file_list (v_wildcard)
    LOOP
      IF fileit.open_file (plan_common.gc_planning_directory, rv_file_list.file_name, fileit.gc_file_mode_read, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      IF add_file (i_run_id, rv_file_list.file_name, rv_file_list.wildcard, rv_file_list.moe_code, v_file_id, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      IF v_file_id IS NULL OR v_file_id = 0 THEN
        v_message := 'File id invalid, add_file failed to return value';
        RAISE e_file_error;
      END IF;

      DELETE FROM load_dmnd_raw
            WHERE file_id = v_file_id;

      COMMIT;

      DELETE FROM load_dmnd
            WHERE file_id = v_file_id;

      COMMIT;
      v_line_number := 1;

      -- create event
      WHILE fileit.read_file (v_line, v_message) = common.gc_success
      LOOP
        INSERT INTO load_dmnd_raw
                    (line, status, file_id, file_line)
             VALUES (RTRIM (v_line), common.gc_loaded, v_file_id, v_line_number);

        v_line_number := v_line_number + 1;
      END LOOP;

      -- trigger event
      IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_demand) THEN
        v_event_type := demand_events.gc_load_raw_demand;
      ELSE
        v_event_type := demand_events.gc_load_raw_dmnd_draft;
      END IF;

      IF eventit.create_event (demand_forecast.gc_system_code, v_event_type, v_file_id, 'Raw file loaded', v_message) != common.gc_success THEN
        RAISE e_event_error;
      END IF;

      COMMIT;

      IF fileit.close_file (v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      v_line_number := 1;

      FOR rv_load_data IN csr_load_data (v_file_id)
      LOOP
        v_conversion := NULL;

        BEGIN
          v_dmdunit := SUBSTR (rv_load_data.line, 1, 16);
          v_dmdgroup := TRIM (SUBSTR (rv_load_data.line, 17, 7) );
          v_loc := TRIM (SUBSTR (rv_load_data.line, 24, 5) );
          v_load_date := TO_DATE (SUBSTR (rv_load_data.line, 29, 8), 'YYYYMMDD');
          v_start_date := TO_DATE (SUBSTR (rv_load_data.line, 43, 8), 'YYYYMMDD');
          v_dur := SUBSTR (rv_load_data.line, 57, 5);
          v_type := TO_NUMBER (SUBSTR (rv_load_data.line, 62, 1) );
          v_qty := TO_NUMBER (SUBSTR (rv_load_data.line, 63, 20) );
          v_mars_week := sql_get_mars_week (v_start_date);
          v_casting_mars_week := sql_get_mars_week (v_load_date - 3);
          v_fcst_text := TRIM (SUBSTR (rv_load_data.line, 83, 50) );
          v_promo_type := TRIM (SUBSTR (rv_load_data.line, 133, 255) );
        EXCEPTION
          WHEN OTHERS THEN
            v_conversion := common.create_error_msg ('Row data conversion error:') || common.create_sql_error_msg ();
            logit.LOG (v_conversion);
        END;

        IF v_conversion IS NULL THEN
          logit.LOG ('Now insert row:' || v_dmdunit);

          INSERT INTO load_dmnd
                      (dmdunit, dmdgroup, loc, casting_mars_week, startdate, dur, TYPE, qty, status, mars_week, file_id,
                       file_line, fcst_text, promo_type)
               VALUES (v_dmdunit, v_dmdgroup, v_loc, v_casting_mars_week, v_start_date, v_dur, v_type, v_qty, common.gc_loaded, v_mars_week, v_file_id,
                       v_line_number, v_fcst_text, v_promo_type);

          COMMIT;
        ELSE
          logit.LOG ('Set error record' || v_dmdunit);

          UPDATE load_dmnd_raw
             SET status = common.gc_errored,
                 processed_date = SYSDATE,
                 error_msg = v_conversion
           WHERE file_id = rv_load_data.file_id AND file_line = rv_load_data.file_line;

          COMMIT;
        END IF;

        v_line_number := v_line_number + 1;
      END LOOP;

      logit.LOG ('Separate ZREP from item codes');

      UPDATE load_dmnd
         SET zrep_code = SUBSTR (load_dmnd.dmdunit, 1, 6)
       WHERE status = common.gc_loaded AND file_id = v_file_id;

      COMMIT;

      UPDATE load_dmnd
         SET zrep_valid = common.gc_valid
       WHERE status = common.gc_loaded AND reference_functions.full_matl_code (zrep_code) IN (SELECT matl_code
                                                                                              FROM matl
                                                                                              WHERE matl_type = 'ZREP' AND trdd_unit = 'X')
             AND file_id = v_file_id;

      COMMIT;

      UPDATE load_dmnd
         SET bus_sgmnt_code = (SELECT bus_sgmnt_code
                               FROM matl_fg_clssfctn
                               WHERE matl_code = reference_functions.full_matl_code (zrep_code) )
       WHERE file_id = v_file_id;

      COMMIT;

      UPDATE load_dmnd
         SET source_code = get_source_code (zrep_code)
       WHERE file_id = v_file_id;

      COMMIT;
      logit.LOG ('Set all none errored rows to processed');

      UPDATE load_dmnd_raw
         SET status = common.gc_processed,
             processed_date = SYSDATE
       WHERE status = common.gc_loaded AND file_id = v_file_id;

      COMMIT;

      UPDATE load_file
         SET status = common.gc_loaded
       WHERE file_id = v_file_id;

      IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_demand) THEN
        v_event_type := demand_events.gc_load_demand;
      ELSE
        v_event_type := demand_events.gc_load_dmnd_draft;
      END IF;

      IF eventit.create_event (demand_forecast.gc_system_code, v_event_type, v_file_id, 'File loaded', v_message) != common.gc_success THEN
        RAISE e_event_error;
      END IF;

      COMMIT;
    END LOOP;

    o_result_msg := 'Process Success';
    logit.leave_method ();
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_failure;
    WHEN e_file_error THEN
      o_result_msg := common.create_failure_msg ('File IO Error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      ROLLBACK;

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
  END load_demand_feed;

  FUNCTION process_demand_feed (i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    e_forecast_id_failure  EXCEPTION;
    e_demand_grp_failure   EXCEPTION;
    e_no_files             EXCEPTION;
    e_business_segment     EXCEPTION;
    e_source_code          EXCEPTION;
    e_event_error          EXCEPTION;
    e_matl_dtrmntn_offset  EXCEPTION;

    -- read current data in feed table , and loop
    CURSOR csr_casting_weeks (i_file_id IN common.st_id) IS
      SELECT DISTINCT casting_mars_week
      FROM load_dmnd
      WHERE status = common.gc_loaded AND file_id = i_file_id;

    --      WHERE status IS NULL AND sql_get_mars_week (load_sply.schedshipdate) <> -1;
    CURSOR csr_load_data (i_file_id IN common.st_id, i_casting_mars_week common.st_value) IS
      SELECT load_dmnd.*
      FROM load_dmnd
      WHERE casting_mars_week = i_casting_mars_week AND status = common.gc_loaded AND file_id = i_file_id;

    CURSOR csr_demand_group_org (i_dmdgroup IN VARCHAR, i_business_segment IN VARCHAR, i_source_code IN VARCHAR) IS
      SELECT dgo.dmnd_grp_org_id, dgo.currcy_code, dgo.invc_prty, dgo.distbn_chnl, dgo.pricing_formula, dgo.sales_org, dgo.bill_to_code, dgo.ship_to_code,
        dgo.mltplr_value, dgo.cust_hrrchy_code, dg.sply_whse_lst
      FROM dmnd_grp dg, dmnd_grp_type dt, dmnd_grp_org dgo
      WHERE dg.dmnd_grp_type_id = dt.dmnd_grp_type_id AND
       dg.dmnd_grp_id = dgo.dmnd_grp_id AND
       dt.dmnd_grp_type_code = gc_demand_group_code_demand AND
       dg.dmnd_grp_code = i_dmdgroup AND
       dgo.source_code = i_source_code AND
       dgo.bus_sgmnt_code = i_business_segment;

    CURSOR csr_business_segment (i_matl_code IN VARCHAR) IS
      SELECT bus_sgmnt_code
      FROM matl_fg_clssfctn
      WHERE matl_code = reference_functions.full_matl_code (i_matl_code);

    CURSOR csr_matl_dtrmntn_offset (i_moe_code IN common.st_code ) IS
        SELECT *
        FROM moe_setting
        WHERE moe_code = i_moe_code;

    rv_business_segment    csr_business_segment%ROWTYPE;
    --rv_casting_week        csr_casting_weeks%ROWTYPE;
    rv_demand_group_org    csr_demand_group_org%ROWTYPE;
    --rv_matl                csr_matl%ROWTYPE;
    v_item_id              common.st_id;
    v_item_valid           BOOLEAN;
    v_invalid_reason       common.st_message_string;
    v_mars_week            VARCHAR2 (8);
    v_mars_day             VARCHAR2 (8);
    v_calendar_day         VARCHAR2 (8);
    v_tdu                  VARCHAR2 (18);
    v_zrep                 common.st_code;
    v_price                common.st_value;
    v_forecast_id          common.st_id;
    v_message_out          common.st_message_string;
    v_pricing_condition    common.st_message_string;
    v_commit_count         INTEGER;
    v_err_data             common.st_message_string;
    v_file_id              common.st_id;
    v_moe_code             common.st_code;
    v_forecast_type        common.st_code;
    v_event_type           common.st_code;
    v_event_text           common.st_message_string;
    v_dmnd_type            common.st_code;
    v_ovrd_tdu_flag        common.st_status;
    v_matl_dtrmntn_offset  common.st_counter; -- calendar date offset

    rv_matl_dtrmntn_offset csr_matl_dtrmntn_offset%ROWTYPE;

    TYPE t_files IS TABLE OF load_dmnd.file_id%TYPE;

    TYPE t_moes IS TABLE OF load_file.moe_code%TYPE;

    TYPE t_casting_week IS TABLE OF load_dmnd.casting_mars_week%TYPE;

    TYPE t_load_data IS TABLE OF load_dmnd%ROWTYPE;

    v_files                t_files;
    v_moes                 t_moes;
    v_casting_weeks        t_casting_week;
    v_load_data            t_load_data;
    v_i                    INTEGER;
    v_k                    INTEGER;
    v_l                    INTEGER;
    v_file_count           INTEGER;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_DEMAND_FEED');
    -- all unique load days, just cast process is running for mulitple days, normailly only one day will be processed
    logit.LOG ('Starting demand processing');
    logit.LOG ('Get file list');

    SELECT COUNT (*)
    INTO   v_file_count
    FROM (SELECT DISTINCT load_dmnd.file_id
          FROM load_dmnd, load_file
          WHERE load_dmnd.status IN (common.gc_loaded) AND
           load_dmnd.file_id = load_file.file_id AND
           load_file.status = common.gc_loaded AND
           UPPER (load_file.wildcard) = UPPER (i_wildcard) ) load_files;

    IF v_file_count < 1 THEN
      RAISE e_no_files;
    END IF;

    logit.LOG ('Start processing');

    SELECT load_dmnd.file_id, MAX (load_file.moe_code) moe_code
    BULK COLLECT INTO v_files, v_moes
    FROM load_dmnd, load_file
    WHERE load_dmnd.status = common.gc_loaded AND
     load_dmnd.file_id = load_file.file_id AND
     load_file.status = common.gc_loaded AND
     UPPER (load_file.wildcard) = UPPER (i_wildcard)
    GROUP BY load_dmnd.file_id;

    FOR v_i IN v_files.FIRST .. v_files.LAST
    LOOP
      v_file_id := v_files (v_i);
      v_moe_code := v_moes (v_i);
      logit.LOG ('Get casting list');

      SELECT DISTINCT casting_mars_week
      BULK COLLECT INTO v_casting_weeks
      FROM load_dmnd
      WHERE status = common.gc_loaded AND file_id = v_files (v_i);

      FOR v_k IN v_casting_weeks.FIRST .. v_casting_weeks.LAST
      LOOP
        logit.LOG ('create forecast');

        IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_demand) THEN
          v_forecast_type := demand_forecast.gc_ft_fcst;
        ELSE
          v_forecast_type := demand_forecast.gc_ft_draft;
        END IF;

        IF create_forecast (v_forecast_type, v_casting_weeks (v_k), gc_fs_invalid, v_moe_code, v_forecast_id, v_message_out) = common.gc_success THEN

        OPEN csr_matl_dtrmntn_offset(v_moe_code);

        FETCH csr_matl_dtrmntn_offset
        INTO rv_matl_dtrmntn_offset;

        IF csr_matl_dtrmntn_offset%FOUND THEN
            IF rv_matl_dtrmntn_offset.matl_dtrmntn_offset IS NOT NULL THEN
                v_matl_dtrmntn_offset := rv_matl_dtrmntn_offset.matl_dtrmntn_offset;
                logit.log ('Material determination Offset: ' || rv_matl_dtrmntn_offset.matl_dtrmntn_offset);
            ELSE
             v_matl_dtrmntn_offset := 0;
            END IF;
        ELSE
            RAISE e_matl_dtrmntn_offset;
        END IF;

        CLOSE csr_matl_dtrmntn_offset;


          -- now loop all the the unique mars weeks for a given load date, this could be an entire year, forward from current date.
          logit.LOG ('delete demand data');

          DELETE FROM dmnd_data
                WHERE fcst_id = v_forecast_id AND
                      dmnd_grp_org_id IN (
                        SELECT DISTINCT dgo.dmnd_grp_org_id
                        FROM dmnd_grp dg, dmnd_grp_org dgo, dmnd_grp_type dt, load_dmnd
                        WHERE dg.dmnd_grp_type_id = dt.dmnd_grp_type_id AND
                         dg.dmnd_grp_id = dgo.dmnd_grp_id AND
                         dt.dmnd_grp_type_code = gc_demand_group_code_demand AND
                         load_dmnd.file_id = v_files (v_i) AND
                         load_dmnd.dmdgroup = dg.dmnd_grp_code);

          COMMIT;



          LOOP
            logit.LOG ('Files:' || TO_CHAR (v_files (v_i) ) );
            logit.LOG ('Weeks:' || TO_CHAR (v_casting_weeks (v_k) ) );

            OPEN csr_load_data (v_files (v_i), v_casting_weeks (v_k) );

            FETCH csr_load_data
            BULK COLLECT INTO v_load_data LIMIT 10000;

            logit.LOG ('Close cursor after populating the collection.');

            CLOSE csr_load_data;

            logit.LOG ('Rows found:' || TO_CHAR (v_load_data.COUNT) );
            -- Exit loop if there is no data returned.
            EXIT WHEN v_load_data.COUNT = 0;

            IF v_load_data.COUNT > 0 THEN
              logit.LOG ('csr_load_data found');

              -- retrieve all records for a given mars weeks,
              FOR v_l IN v_load_data.FIRST .. v_load_data.LAST
              LOOP
                logit.LOG ('loop row load data');
                v_item_valid := TRUE;
                v_invalid_reason := NULL;

                IF v_load_data (v_l).zrep_valid = common.gc_valid THEN
                  -- lookup demand group. in demand group mapping table.
                  logit.LOG ('ZREP valid');
                  v_zrep := v_load_data (v_l).zrep_code;

                  IF v_load_data (v_l).bus_sgmnt_code IS NULL THEN
                    RAISE e_business_segment;
                  END IF;

                  logit.LOG ('Business segment valid');

                  IF v_load_data (v_l).source_code IS NULL THEN
                    RAISE e_source_code;
                  END IF;

                  logit.LOG ('Company code valid');

                  OPEN csr_demand_group_org (v_load_data (v_l).dmdgroup, v_load_data (v_l).bus_sgmnt_code, v_load_data (v_l).source_code);

                  FETCH csr_demand_group_org
                  INTO rv_demand_group_org;

                  IF csr_demand_group_org%FOUND THEN
                    -- convert start_date to mars date,
                    WHILE csr_demand_group_org%FOUND
                    LOOP
                      v_calendar_day := TO_CHAR (v_load_data (v_l).startdate, 'YYYYMMDD');
                      v_tdu := NULL;
                      -- set tdu override flag to no
                      v_ovrd_tdu_flag := common.gc_no;

                      IF v_load_data (v_l).fcst_text IS NOT NULL THEN
                        IF NOT get_ovrd_tdu (v_load_data (v_l).zrep_code,
                                             rv_demand_group_org.distbn_chnl,
                                             rv_demand_group_org.sales_org,
                                             v_load_data (v_l).fcst_text,
                                             v_tdu,
                                             v_ovrd_tdu_flag,
                                             v_invalid_reason,
                                             v_message_out) = common.gc_success THEN
                          v_invalid_reason := v_invalid_reason || 'Using standard material determination. ';
                        END IF;
                      END IF;

                      IF v_tdu IS NULL THEN
                        IF NOT get_tdu (v_load_data (v_l).zrep_code,
                                        rv_demand_group_org.distbn_chnl,
                                        rv_demand_group_org.sales_org,
                                        rv_demand_group_org.bill_to_code,
                                        rv_demand_group_org.ship_to_code,
                                        rv_demand_group_org.cust_hrrchy_code,
                                        to_char((to_date(v_calendar_day, 'yyyymmdd') + v_matl_dtrmntn_offset),'yyyymmdd'),
                                        v_tdu,
                                        v_message_out) = common.gc_success THEN
                          v_invalid_reason := v_invalid_reason || 'TDU Material Determination Lookup Failure. ';
                        END IF;
                      END IF;

                      IF NOT get_price (v_load_data (v_l).zrep_code,
                                        v_tdu,
                                        rv_demand_group_org.distbn_chnl,
                                        rv_demand_group_org.bill_to_code,
                                        rv_demand_group_org.sales_org,
                                        rv_demand_group_org.invc_prty,
                                        rv_demand_group_org.sply_whse_lst,
                                        v_calendar_day,
                                        rv_demand_group_org.pricing_formula,
                                        rv_demand_group_org.currcy_code,
                                        v_pricing_condition,
                                        v_price,
                                        v_message_out) = common.gc_success THEN
                        v_invalid_reason := v_invalid_reason || 'Price Lookup Failure. ';
                      END IF;

                      -- retrieve and convert the dmnd type column.
                      v_dmnd_type := NULL;

                      IF v_load_data (v_l).TYPE = 1 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_1;
                      ELSIF v_load_data (v_l).TYPE = 2 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_2;
                      ELSIF v_load_data (v_l).TYPE = 3 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_3;
                      ELSIF v_load_data (v_l).TYPE = 4 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_4;
                      ELSIF v_load_data (v_l).TYPE = 5 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_5;
                      ELSIF v_load_data (v_l).TYPE = 6 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_6;
                      ELSIF v_load_data (v_l).TYPE = 7 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_7;
                      ELSIF v_load_data (v_l).TYPE = 8 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_8;
                      ELSIF v_load_data (v_l).TYPE = 9 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_9;
                      ELSIF v_load_data (v_l).TYPE = 10 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_b;
                      ELSIF v_load_data (v_l).TYPE = 11 THEN
                        v_dmnd_type := demand_forecast.gc_dmnd_type_u;
                      END IF;

                      -- all check ok , now complete add or update record to demand table.
                      INSERT INTO dmnd_data
                                  (fcst_id, dmnd_grp_org_id,
                                   zrep,
                                   qty_in_base_uom,
                                   gsv, price, mars_week,
                                   price_condition, tdu, TYPE, tdu_ovrd_flag)
                           VALUES (v_forecast_id, rv_demand_group_org.dmnd_grp_org_id,
                                   SUBSTR (v_load_data (v_l).zrep_code, LENGTH (v_load_data (v_l).zrep_code) - 5, 6),
                                   v_load_data (v_l).qty * rv_demand_group_org.mltplr_value,
                                   (v_load_data (v_l).qty * rv_demand_group_org.mltplr_value) * v_price, v_price, v_load_data (v_l).mars_week,
                                   v_pricing_condition, v_tdu, v_dmnd_type, v_ovrd_tdu_flag);

                      logit.LOG ('End record' || TO_CHAR (v_load_data (v_l).file_line) );

                      FETCH csr_demand_group_org
                      INTO rv_demand_group_org;
                    END LOOP;

                    logit.LOG ('Close demand group org cursor');

                    CLOSE csr_demand_group_org;
                  ELSE
                    v_err_data :=
                         'demand group:'
                      || v_load_data (v_l).dmdgroup
                      || ' bus seg:'
                      || v_load_data (v_l).bus_sgmnt_code
                      || ' Source code:'
                      || v_load_data (v_l).source_code;
                    RAISE e_demand_grp_failure;
                  END IF;
                --CLOSE csr_business_segment;
                ELSE
                  v_item_valid := FALSE;
                  v_invalid_reason := 'ZREP Lookup Error.';
                END IF;

                -- Close csr_matl;
                logit.LOG ('set reject reason');

                IF v_item_valid = FALSE THEN
                  logit.LOG ('Item Invalid');

                  UPDATE load_dmnd
                     SET status = common.gc_errored,
                         error_msg = v_invalid_reason
                   WHERE file_id = v_load_data (v_l).file_id AND file_line = v_load_data (v_l).file_line;
                ELSE
                  logit.LOG ('Valid or valid with failures.');

                  UPDATE load_dmnd
                     SET status = DECODE (v_invalid_reason, NULL, common.gc_processed, common.gc_failed),
                         error_msg = v_invalid_reason
                   WHERE file_id = v_load_data (v_l).file_id AND file_line = v_load_data (v_l).file_line;
                END IF;

                logit.LOG ('Reject Reason Set');
              END LOOP;

              logit.LOG ('out side data loop');
            END IF;

            logit.LOG ('End of 10000 rows commit');
            COMMIT;
          -- EXIT WHEN csr_load_data%NOTFOUND;
          -- CLOSE csr_load_data;
          END LOOP;
        ELSE
          RAISE e_forecast_id_failure;
        END IF;

        IF UPPER (i_wildcard) = UPPER (demand_forecast.gc_wildcard_demand) THEN
          v_event_type := demand_events.gc_df_fcst_demand;
          v_event_text := 'Demand forecast created:' || TO_CHAR (v_forecast_id);
        ELSE
          v_event_type := demand_events.gc_df_draft_demand;
          v_event_text := 'Demand draft forecast created:' || TO_CHAR (v_forecast_id);
        END IF;

        IF eventit.create_event (demand_forecast.gc_system_code, v_event_type, v_forecast_id, v_event_text, v_message_out) != common.gc_success THEN
          RAISE e_event_error;
        END IF;
      END LOOP;

      UPDATE load_file
         SET status = common.gc_processed
       WHERE file_id = v_files (v_i);

      COMMIT;
    END LOOP;

    COMMIT;
    o_result_msg := common.gc_success_str;
    logit.leave_method ();
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error. ') || v_message_out;
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_business_segment THEN
      o_result_msg := common.create_failure_msg ('Business segment invalid zrep:') || v_zrep;
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_source_code THEN
      o_result_msg := common.create_failure_msg ('Make source invalid zrep:') || v_zrep;
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_no_files THEN
      o_result_msg := common.create_failure_msg ('No files found to process. ');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_success;
    WHEN e_demand_grp_failure THEN
      ROLLBACK;
      o_result_msg := common.create_failure_msg ('Demand group org lookup failure') || common.create_params_str ('Demand code', v_err_data);
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_forecast_id_failure THEN
      ROLLBACK;
      o_result_msg := common.create_failure_msg ('Forecast id invalid or null');
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_matl_dtrmntn_offset THEN
      ROLLBACK;
      -- catch exceptions when material determination offset error
      o_result_msg := common.create_error_msg ('Material determination offset error.');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);

      UPDATE load_file
         SET status = common.gc_errored
       WHERE file_id = v_file_id;

      COMMIT;
      logit.leave_method;
      ROLLBACK;
      RETURN common.gc_error;
  END process_demand_feed;

  FUNCTION get_directory_list (i_wildcard common.st_message_string, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    e_execute_failure   EXCEPTION;   -- unix command execute error
    e_file_error        EXCEPTION;   -- no files retuned error
    e_system_parameter  EXCEPTION;   -- failed to get system parameter
    v_message           common.st_message_string;
    v_line              common.st_message_string;
    -- read line from outputed file from ls command
    v_file              common.st_message_string;
    -- extracted filename from file line.
    v_moe_code          common.st_code;
    -- extracted moe code from file line.
    v_unix_path         common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'GET_DIRECTORY_LIST');

    IF system_params.get_parameter_text (plan_common.gc_system_code, plan_common.gc_unix_path_code, v_unix_path, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    -- clear out directory list from last run, for supplied wildcard.
    -- allows demand and supply to run simutanously.
    DELETE FROM dir_list
          WHERE wildcard = i_wildcard;

    COMMIT;

    -- execute unix command to list files beginning with supplied wildcard.
    -- the results will stored within a unix file called dirlist.
    IF fileit.execute_command (v_unix_path || 'bin/fix_up_files.sh', v_message) != common.gc_success THEN
      RAISE e_execute_failure;
    END IF;

    IF fileit.execute_command (v_unix_path || 'bin/demand_file_list.sh ' || i_wildcard, v_message) != common.gc_success THEN
      RAISE e_execute_failure;
    END IF;

    -- close file just in case.
    IF fileit.close_file (v_message) != common.gc_success THEN
      v_message := '';
    END IF;

    -- open up results of unix ls command, and process.
    IF fileit.open_file (plan_common.gc_planning_directory, 'dirlist', fileit.gc_file_mode_read, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- for each line with in the file, extract the file name
    WHILE fileit.read_file (v_line, v_message) = common.gc_success
    LOOP
      -- extact the filename
      v_file := SUBSTR (v_line, INSTR (v_line, ' ', -1) + 1, LENGTH (v_line) );

      IF LENGTH (v_file) <= 0 THEN   -- if filename is invalid then raise exception
        v_message := 'could no extract lastest filename';
        RAISE e_file_error;
      END IF;

      -- extact the moe code
      v_moe_code := SUBSTR (v_line, INSTR (v_line, i_wildcard) + LENGTH (i_wildcard), 4);

      IF LENGTH (v_moe_code) <= 0 THEN   -- if moe code is invalid then raise exception
        v_message := 'could not extract moe code from file name';
        RAISE e_file_error;
      END IF;

      -- now add the file_name and moe code to the dir_list table , for later processing.
      INSERT INTO dir_list
                  (wildcard, file_name, moe_code)
           VALUES (i_wildcard, v_file, v_moe_code);
    END LOOP;

    -- close the file.
    IF fileit.close_file (v_message) != common.gc_success THEN
      v_message := '';
    END IF;

    -- directory list found file run ok.
    logit.LOG ('found file:' || v_file);
    logit.leave_method;
    COMMIT;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_system_parameter THEN
      o_result_msg := common.create_failure_msg ('System parameter recall failde. ' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_execute_failure THEN
      -- unix command failed for some reason, maybe no files with specified wildcard were found.
      COMMIT;
      o_result_msg := common.create_failure_msg ('Unix execute failed');
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_failure;
    WHEN e_file_error THEN
      -- could not get valid filename from results dirlist file generated by unix  ls command
      o_result_msg := common.create_failure_msg ('File IO Error. ' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
  END get_directory_list;

  FUNCTION add_file (
    i_run_id         IN      common.st_id,
    i_file_name      IN      common.st_message_string,
    i_file_wildcard  IN      common.st_message_string,
    i_file_moe       IN      common.st_code,
    o_file_id        OUT     common.st_id,
    o_result_msg     OUT     common.st_message_string)
    RETURN common.st_result AS
    -- cursor to check that file_namd is unique
    CURSOR csr_file (i_file_name VARCHAR) IS
      SELECT file_id
      FROM load_file
      WHERE file_name = i_file_name;

    v_file_id     common.st_id;   -- store returned file_id
    rv_file       csr_file%ROWTYPE;
    v_result_msg  common.st_message_string;
    e_file_id     EXCEPTION;
  BEGIN
    logit.enter_method (pc_package_name, 'ADD_FILE');

    -- try and find exsisting file.
    OPEN csr_file (i_file_name);

    FETCH csr_file
    INTO rv_file;

    -- file_namd is unique so add new record
    IF csr_file%NOTFOUND THEN
      -- file id of new record
      IF demand_object_tracking.get_new_id ('LOAD_FILE', 'FILE_ID', v_file_id, v_result_msg) != common.gc_success THEN
        RAISE e_file_id;
      END IF;

      -- add the file.
      INSERT INTO load_file
                  (file_id, file_name, status, loaded_date, run_id, wildcard, moe_code)
           VALUES (v_file_id, i_file_name, common.gc_pending, SYSDATE, i_run_id, i_file_wildcard, i_file_moe);

      -- return file id of the new file.
      o_file_id := v_file_id;
    ELSE
      -- file already exists so return the file_id of this file.
      UPDATE load_file
         SET run_id = i_run_id,
             loaded_date = SYSDATE
       WHERE file_id = rv_file.file_id;

      o_file_id := rv_file.file_id;
    END IF;

    logit.leave_method ();
    COMMIT;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_file_id THEN
      o_result_msg := common.create_error_msg ('Unable to allocate file id' || v_result_msg) || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      -- unhandeled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END add_file;

  FUNCTION drop_demand_indexes (o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
  BEGIN
    logit.enter_method (pc_package_name, 'DROP_DEMAND_INDEXES');
    logit.LOG ('Dropping Demand Data Bitmap Indexes.');
    df.schema_management.drop_index ('DMND_DATA_BI02');
    df.schema_management.drop_index ('DMND_DATA_BI03');
    df.schema_management.drop_index ('DMND_DATA_BI04');
    df.schema_management.drop_index ('DMND_DATA_BI05');
    df.schema_management.drop_index ('DMND_DATA_BI06');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      -- unhandeled exceptions.
      o_result_msg := common.create_error_msg ('Unable to drop demand data bitmap indexes. ') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END drop_demand_indexes;

  FUNCTION create_demand_indexes (o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
  BEGIN
    logit.enter_method (pc_package_name, 'CREATE_DEMAND_INDEXES');
    logit.LOG ('Recreating Demand Data Bitmap Indexes.');
    df.schema_management.create_index ('DMND_DATA_BI02', 'DMND_DATA', 'FCST_ID', 'BITMAP');
    df.schema_management.create_index ('DMND_DATA_BI03', 'DMND_DATA', 'DMND_GRP_ORG_ID', 'BITMAP');
    df.schema_management.create_index ('DMND_DATA_BI04', 'DMND_DATA', 'MARS_WEEK', 'BITMAP');
    df.schema_management.create_index ('DMND_DATA_BI05', 'DMND_DATA', 'ZREP', 'BITMAP');
    df.schema_management.create_index ('DMND_DATA_BI06', 'DMND_DATA', 'TDU', 'BITMAP');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      -- unhandeled exceptions.
      o_result_msg := common.create_error_msg ('Unable to create demand data bitmap indexes.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END create_demand_indexes;

  FUNCTION remove_file (i_file_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- exception called with problems calling FILEIT , delete file.
    e_file_error      EXCEPTION;
    v_file_name       common.st_description;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;

    CURSOR csr_file IS
      SELECT file_name
      FROM load_file
      WHERE file_id = i_file_id;
  BEGIN
    logit.enter_method (pc_package_name, 'REMOVE_FILE');
    logit.LOG ('Create savepoint.');
    SAVEPOINT remove_file_savepoint;
    logit.LOG ('Getting file name.');

    OPEN csr_file;

    FETCH csr_file
    INTO v_file_name;

    IF csr_file%NOTFOUND = TRUE THEN
      v_processing_msg := 'Unable to find file for id : ' || i_file_id || ' in order to remove it.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_file;

    logit.LOG ('Removing file : ' || i_file_id || ' - ' || v_file_name);

    DELETE FROM load_dmnd_raw
          WHERE file_id = i_file_id;

    DELETE FROM load_dmnd
          WHERE file_id = i_file_id;

    DELETE FROM load_sply
          WHERE file_id = i_file_id;

    DELETE FROM load_sply_raw
          WHERE file_id = i_file_id;

    DELETE FROM load_file
          WHERE file_id = i_file_id;

    -- now delete the unix file.
    IF fileit.remove_file (plan_common.gc_planning_directory, v_file_name, v_result_msg) != common.gc_success THEN
      v_processing_msg := 'Unable to remove file : ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_error;
    END IF;

    COMMIT;
    logit.LOG ('Removing of file from demand financials complete.');
    o_result_msg := 'Successfully removed file : ' || v_file_name;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_error THEN
      ROLLBACK TO SAVEPOINT remove_file_savepoint;
      -- file errored could now delete file.
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      -- unhandeled exceptions.
      ROLLBACK TO SAVEPOINT remove_file_savepoint;
      o_result_msg := common.create_error_msg ('Unable to delete old load data.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END remove_file;

  FUNCTION cleanup_old_files (o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    -- main cursor list of file greater than x days old , supply and demand.
    CURSOR csr_files IS
      SELECT file_id, file_name
      FROM load_file
      WHERE loaded_date < SYSDATE - pc_keep_old_files AND wildcard IN ('supply_', 'demand_')
      UNION ALL
      SELECT file_id, file_name
      FROM load_file
      WHERE loaded_date < SYSDATE - pc_keep_old_draft_files AND wildcard IN ('draft_dmd_', 'draft_sply_');

    TYPE t_files IS TABLE OF csr_files%ROWTYPE
      INDEX BY common.st_counter;

    v_files           t_files;
    v_counter         common.st_counter;
    v_result_msg      common.st_message_string;
    -- standard procedure return var
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'CLEAN_UP_OLD_FILES');
    logit.LOG ('Delete old data from load tables');

    -- loop throught all files greater than 35 days old.
    OPEN csr_files;

    FETCH csr_files
    BULK COLLECT INTO v_files;

    CLOSE csr_files;

    v_counter := 1;
    logit.LOG ('Found : ' || v_files.COUNT || ' that require removing.');

    LOOP
      EXIT WHEN v_counter > v_files.COUNT;

      -- now delete all the records from supply and denamd load tables.
      IF eventit.create_event (demand_forecast.gc_system_code,
                               demand_events.gc_housekeep_file,
                               v_files (v_counter).file_id,
                               'Removing file : ' || v_files (v_counter).file_name,
                               v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to create event that will remove an old file.';
        RAISE common.ge_error;
      END IF;

      -- Increase the counter.
      v_counter := v_counter + 1;
    END LOOP;

    logit.LOG ('Triggering of house keeping will commence next time events are processed.');
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_error THEN
      -- file errored could now delete file.
      o_result_msg := common.create_error_msg ('Unable to clean up old files : ') || common.nest_err_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      -- unhandeled exceptions.
      o_result_msg := common.create_error_msg ('Unable to delete old load data.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END cleanup_old_files;

  FUNCTION archive_old_forecasts (o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_result_msg       common.st_message_string;
    v_return           common.st_result;
    e_archive_failure  EXCEPTION;
    v_found            BOOLEAN;

    CURSOR csr_forecast IS
      SELECT fcst_id
      FROM fcst
      WHERE ( (casting_week IN ('1', '2', '3') AND
               (forecast_type = demand_forecast.gc_ft_fcst OR forecast_type = demand_forecast.gc_ft_draft) AND
               SYSDATE - last_updated > pc_archive_days_123_fcst) OR
             (casting_week IN ('4', '5') AND
              (forecast_type = demand_forecast.gc_ft_fcst OR forecast_type = demand_forecast.gc_ft_draft) AND
              SYSDATE - last_updated > pc_archive_days_45_fcst) OR
             (forecast_type = demand_forecast.gc_ft_br AND SYSDATE - last_updated > pc_archive_days_br) ) AND
       status <> demand_forecast.gc_fs_archived;

    rv_forecast        csr_forecast%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'ARCHIVE_OLD_FORECASTS');
    logit.LOG ('Performing archive....');

    LOOP
      -- Now try and find a forecast to purge.
      v_found := FALSE;

      OPEN csr_forecast;

      FETCH csr_forecast
      INTO rv_forecast;

      IF csr_forecast%FOUND THEN
        v_found := TRUE;
      END IF;

      CLOSE csr_forecast;

      -- Now archive the forecast.
      EXIT WHEN v_found = FALSE;
      logit.LOG ('Archiving forecast id:' || TO_CHAR (rv_forecast.fcst_id) );

      IF demand_forecast.archive_forecast (rv_forecast.fcst_id, v_result_msg) != common.gc_success THEN
        RAISE e_archive_failure;
      END IF;
    END LOOP;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_archive_failure THEN
      -- exception handler  ,  Process error so send email with error details.
      o_result_msg := common.create_error_msg ('Archive error ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.log_error (v_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END archive_old_forecasts;

  FUNCTION purge_old_forecasts (o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_result_msg     common.st_message_string;
    v_return         common.st_result;
    e_purge_failure  EXCEPTION;
    v_found          BOOLEAN;

    CURSOR csr_forecast IS
      SELECT fcst_id
      FROM fcst
      WHERE (casting_week IN ('1', '2', '3') AND
             (forecast_type = demand_forecast.gc_ft_fcst OR forecast_type = demand_forecast.gc_ft_draft) AND
             SYSDATE - last_updated > pc_purge_days_123_fcst) OR
       (casting_week IN ('4', '5') AND
        (forecast_type = demand_forecast.gc_ft_fcst OR forecast_type = demand_forecast.gc_ft_draft) AND
        SYSDATE - last_updated > pc_purge_days_45_fcst) OR
       (forecast_type = demand_forecast.gc_ft_br AND SYSDATE - last_updated > pc_purge_days_br);

    rv_forecast      csr_forecast%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'PURGE_OLD_FORECASTS');
    logit.LOG ('Performing purge....');

    LOOP
      -- Now try and find a forecast to purge.
      v_found := FALSE;

      OPEN csr_forecast;

      FETCH csr_forecast
      INTO rv_forecast;

      IF csr_forecast%FOUND THEN
        v_found := TRUE;
      END IF;

      CLOSE csr_forecast;

      -- Now purge the forecast
      EXIT WHEN v_found = FALSE;
      logit.LOG ('Purging old forecast id:' || TO_CHAR (rv_forecast.fcst_id) );

      IF demand_forecast.purge_forecast (rv_forecast.fcst_id, v_result_msg) != common.gc_success THEN
        RAISE e_purge_failure;
      END IF;

      COMMIT;
    END LOOP;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_purge_failure THEN
      -- exception handler  ,  Process error so send email with error details.
      o_result_msg := common.create_error_msg ('Purge error ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END purge_old_forecasts;

  FUNCTION get_ovrd_tdu (
    i_material_code         IN      common.st_code,
    i_distribution_channel  IN      common.st_code,
    i_sales_org             IN      common.st_code,
    i_fcst_text             IN      common.st_name,
    o_tdu                   OUT     common.st_code,
    o_ovrd_tdu_flag         IN OUT  common.st_status,
    o_invalid_reason        IN OUT  common.st_message_string,
    o_message_out           OUT     common.st_message_string)
    RETURN common.st_result IS
    v_material_code            common.st_message_string;
    e_tdu_invalid_failure      EXCEPTION;
    e_tdu_inactive_failure     EXCEPTION;
    e_tdu_match_failure        EXCEPTION;
    e_tdu_extend_matl_failure  EXCEPTION;
    v_ovrd_tdu                 common.st_code;

    CURSOR csr_tdu (v_ovrd_tdu IN common.st_code) IS
      SELECT rprsnttv_item_code
      FROM matl
      WHERE matl_code = reference_functions.full_matl_code (v_ovrd_tdu);

    CURSOR csr_tdu_status (v_ovrd_tdu IN common.st_code) IS
      SELECT dstrbtn_chain_sts
      FROM matl_by_sales_area
      WHERE matl_code = reference_functions.full_matl_code (v_ovrd_tdu) AND sales_org = i_sales_org AND dstrbtn_chnl = i_distribution_channel;

    rv_tdu                     csr_tdu%ROWTYPE;
    rv_tdu_status              csr_tdu_status%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'GET_TDU_OVRD');
    logit.LOG ('SEARCHING FCST_TEXT FOR TDU_OVRD');
    o_ovrd_tdu_flag := common.gc_no;

    -- strip TDU from forecast text
    IF INSTR (i_fcst_text, 'TDU') != '0' THEN
      v_ovrd_tdu := SUBSTR (i_fcst_text, INSTR (i_fcst_text, 'TDU') + 3, 8);
      v_material_code := reference_functions.full_matl_code (i_material_code);

      OPEN csr_tdu (v_ovrd_tdu);

      FETCH csr_tdu
      INTO rv_tdu;

      -- Check if TDU OVRD was found in material table
      IF csr_tdu%NOTFOUND THEN
        CLOSE csr_tdu;

        RAISE e_tdu_match_failure;
      END IF;

      -- If TDU OVRD is linked to ZREP then continue
      IF rv_tdu.rprsnttv_item_code = v_material_code THEN
        OPEN csr_tdu_status (v_ovrd_tdu);

        FETCH csr_tdu_status
        INTO rv_tdu_status;

        IF csr_tdu_status%NOTFOUND THEN
          logit.LOG ('TDU_OVRD NOT EXTENDED');

          CLOSE csr_tdu_status;

          RAISE e_tdu_extend_matl_failure;
        END IF;

        IF rv_tdu_status.dstrbtn_chain_sts = '99' THEN
          logit.LOG ('TDU_OVRD INACTIVE');

          CLOSE csr_tdu_status;

          RAISE e_tdu_inactive_failure;
        END IF;

        CLOSE csr_tdu_status;

        logit.LOG ('FOUND VALID TDU_OVRD');
        o_tdu := v_ovrd_tdu;
        o_ovrd_tdu_flag := common.gc_yes;   -- set to yes if using override
      ELSE
        logit.LOG ('OVRD_TDU is not linked to ZREP');
        RAISE e_tdu_invalid_failure;
      END IF;

      CLOSE csr_tdu;
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_tdu_match_failure THEN
      -- exception for specified TDU override not existing in matl table
      o_invalid_reason := o_invalid_reason || 'TDU Override ' || v_ovrd_tdu || ' is not a valid material. ';
      logit.LOG ('Material : ' || i_material_code);
      o_message_out := 'TEST';
      o_message_out := common.create_error_msg ('TDU Override not a valid material') || common.create_params_str ('v_ovrd_tdu', v_ovrd_tdu);
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_tdu_extend_matl_failure THEN
      -- exception for specified TDU override has not been extended into matl_by_sales_area table
      o_invalid_reason := o_invalid_reason || 'TDU Override ' || v_ovrd_tdu || ' not been extended in Sales Area for Dmnd Grp/Sales Org. ';
      logit.LOG ('Material : ' || i_material_code);
      o_message_out := 'TEST';
      o_message_out := common.create_error_msg ('TDU Override not extended into sales area') || common.create_params_str ('v_ovrd_tdu', v_ovrd_tdu);
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_tdu_inactive_failure THEN
      -- exception for TDU override having inactive status of 99 in matl_by_sales_area table
      o_invalid_reason := o_invalid_reason || 'TDU Override ' || v_ovrd_tdu || ' has inactive status of 99. ';
      logit.LOG ('Material : ' || i_material_code);
      o_message_out := 'TEST';
      o_message_out := common.create_error_msg ('TDU Override inactive') || common.create_params_str ('v_ovrd_tdu', v_ovrd_tdu);
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_tdu_invalid_failure THEN
      -- exception for TDU override not being linked to ZREP
      o_invalid_reason := o_invalid_reason || 'TDU Override ' || v_ovrd_tdu || ' is not linked to ZREP. ';
      logit.LOG ('Material : ' || i_material_code);
      o_message_out := 'TEST';
      o_message_out := common.create_error_msg ('TDU Override is not linked to ZREP') || common.create_params_str ('v_ovrd_tdu', v_ovrd_tdu);
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- catch all for unhanded exceptions.
      o_message_out := common.create_error_msg ('unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_message_out);
      logit.leave_method;
      RETURN common.gc_error;
  END get_ovrd_tdu;
END demand_forecast;
