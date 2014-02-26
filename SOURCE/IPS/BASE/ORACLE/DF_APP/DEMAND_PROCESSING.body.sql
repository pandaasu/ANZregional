create or replace PACKAGE BODY        demand_processing AS
  pc_package_name         CONSTANT common.st_package_name := 'DEMAND_PROCESSING';
  pc_lock_name            CONSTANT lockit.st_lock_name    := pc_package_name || '.RUN_BATCH';
  pc_reference_wait_time  CONSTANT common.st_counter      := 3600;


  PROCEDURE publish_forecast (i_moe_code IN common.st_code) is
    v_result_msg common.st_message_string;
    v_error_msg common.st_message_string;
    e_moe_error exception;
    e_event_error exception;
    e_no_forecast exception;
    e_invalid_casting_week exception;
    e_fcst_allocate exception;
    -- Check that the moe code exists.
    cursor csr_moe is
    select moe_code from moe_setting where moe_code = i_moe_code;
    v_moe_code common.st_code;
    -- Create the cursor for finding the current casting week information.
    cursor csr_mars_date(i_date in date) is 
      select 
        trim(to_char(mod(mars_week,10),'0')) as casting_week,
        trim(to_char(period_num,'00')) as casting_period,
        trim(to_char(mars_year,'0000')) as casting_year, 
        trim(to_char(mars_week,'0000000')) as casting_week_full
      from mars_date where calendar_date = trunc(i_date);
    rv_mars_date csr_mars_date%rowtype;
    -- Peform the search for a forecast id. 
    cursor csr_forecast is
      SELECT fcst_id
      FROM fcst
      WHERE casting_week = rv_mars_date.casting_week and 
        casting_year = rv_mars_date.casting_year AND
        casting_period = rv_mars_date.casting_period AND
        forecast_type = demand_forecast.gc_ft_fcst AND
        status = demand_forecast.gc_fs_valid and 
        moe_code = v_moe_code;
    v_forecast_id common.st_id;
    v_new_forecast_id common.st_id;
    v_search_offset common.st_count;
    v_now date;
  BEGIN
    logit.new_log;
	logit.enter_method (pc_package_name, 'PUBLISH_FORECAST');
    -- Initialise the forecast id
    v_forecast_id := null;
    v_now := sysdate-3;  -- To allow the job to be rerun till tuesday using the current casting week. 
    
    -- Checking moe code exists.
    logit.log('Checking for valid moe code for : ' || i_moe_code);
    open csr_moe;
    fetch csr_moe into v_moe_code;
    if csr_moe%notfound then 
      raise e_moe_error;
    end if;
    close csr_moe;

    -- Determining Casting Week
    logit.log('Determining Casting Week');
    open csr_mars_date(v_now);
    fetch csr_mars_date into rv_mars_date;
    if csr_mars_date%notfound then 
      raise e_invalid_casting_week; 
    end if;
    close csr_mars_date;
    logit.log('Current Casting Week : ' || rv_mars_date.casting_week_full);
     
    -- Searching for existing forecast.
    logit.log('Searching for Forecast.');
    open csr_forecast;
    fetch csr_forecast into v_forecast_id;
    if csr_forecast%found then 
      logit.log('Found current valid forecast : ' || v_forecast_id);
    end if;
    close csr_forecast;
    
    -- Now if we couldn't find as forecast for this week go and see if we can find one.
    if v_forecast_id is null then 
      -- Search for a previous forecast.
      logit.log('Searching for a past valid forecast.');
      v_search_offset := 7;
      loop 
        -- Exit this process after three loops through.  
        exit when v_search_offset > 21 or v_forecast_id is not null;
        open csr_mars_date(v_now-v_search_offset);
        fetch csr_mars_date into rv_mars_date;
        if csr_mars_date%notfound then 
          raise e_invalid_casting_week; 
        end if;
        close csr_mars_date;
        -- Now look for the forecast.
        logit.log('Searching for forecast with casting week : ' || rv_mars_date.casting_week_full);
        open csr_forecast;
        fetch csr_forecast into v_forecast_id;
        close csr_forecast;
        -- Now increase the offset.
        v_search_offset := v_search_offset + 7;
      end loop;
      if v_forecast_id is null then 
        raise e_no_forecast;
      end if;
      logit.log('Past Valid Forecast Found to Copy : ' || v_forecast_id);
      -- Now lookup the mars casting week again for the creation process. 
      open csr_mars_date(v_now);
      fetch csr_mars_date into rv_mars_date;
      close csr_mars_date;
      -- Now create the new forecast and copy it. 
      IF demand_object_tracking.get_new_id ('FCST', 'FCST_ID', v_new_forecast_id, v_result_msg) != common.gc_success THEN
        RAISE e_fcst_allocate;
      END IF;
  
      logit.log('Copying Forward Forecast : ' || v_forecast_id || ' to new forecast id : ' || v_new_forecast_id || '.');
  
      -- Now create the the forecast header record.
      INSERT INTO fcst (
        srce_fcst_id, fcst_id, casting_week, casting_period,casting_year, forecast_type, last_updated,
        status, moe_code
      ) VALUES (
        v_forecast_id, v_new_forecast_id, rv_mars_date.casting_week, rv_mars_date.casting_period,  rv_mars_date.casting_year, demand_forecast.gc_ft_fcst,  v_now,
        demand_forecast.gc_fs_invalid, v_moe_code);  -- Status of invalid should be changed to valid once the event has been processed. 

      -- Now perform the actual copy of the draft forecast to the forecast. 
      INSERT INTO dmnd_data (
        fcst_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
      ) SELECT v_new_forecast_id, dmnd_grp_org_id, gsv, qty_in_base_uom, zrep, tdu, price, mars_week, price_condition, TYPE
        FROM dmnd_data
        WHERE fcst_id = v_forecast_id and mars_week > rv_mars_date.casting_week_full;

      COMMIT;
      -- Now assign the new forecast id to the main forecast id.
      v_forecast_id := v_new_forecast_id;
    end if;
    
    -- Creating forecast complete event.
    logit.log('Creating event to trigger the forecast as complete. Forecast ID :'|| v_forecast_id||'.');
    IF eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_fcst_complete, v_forecast_id, 'Forecast Complete', v_result_msg) <> common.gc_success then 
      RAISE e_event_error;
    end if;

    -- Trigger Event Processing.
    logit.log('Triggering the Event System to process the forecast.');
    IF eventit.trigger_events (v_result_msg) <> common.gc_success THEN
      RAISE e_event_error;
    END IF;
    
    -- Now leave the method.
    logit.leave_method;
  EXCEPTION
    WHEN e_fcst_allocate THEN
      v_error_msg := common.create_error_msg ('Unable to allocate new forecast id. ' || v_result_msg);
      logit.log_error (v_error_msg);
      logit.leave_method;
      raise_application_error(common.gc_application_error_code,'Exception During Publish Forecast. ' || v_error_msg);
    WHEN e_no_forecast THEN
      v_error_msg := common.create_error_msg ('No past forecasts could be found to publish.');
      logit.log_error (v_error_msg);
      logit.leave_method;
      raise_application_error(common.gc_application_error_code,'Exception During Publish Forecast. ' || v_error_msg);
    WHEN e_moe_error THEN
      close csr_moe;
      v_error_msg := common.create_error_msg ('Unable to find supplied moe code in moe_settings table.');
      logit.log_error (v_error_msg);
      logit.leave_method;
      raise_application_error(common.gc_application_error_code,'Exception During Publish Forecast. ' || v_error_msg);
    WHEN e_invalid_casting_week THEN
      close csr_mars_date;
      v_error_msg := common.create_error_msg ('Unable to find casting week data from mars date table for supplied date.');
      logit.log_error (v_error_msg);
      logit.leave_method;
      raise_application_error(common.gc_application_error_code,'Exception During Publish Forecast. ' || v_error_msg);
    WHEN e_event_error THEN
      v_error_msg := common.create_error_msg ('Event System Failure. ') || v_result_msg;
      logit.log_error (v_error_msg);
      logit.leave_method;
      raise_application_error(common.gc_application_error_code,'Exception During Publish Forecast. ' || v_error_msg);
    WHEN OTHERS THEN
      v_error_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.log_error (v_error_msg);
      logit.leave_method;
      raise_application_error(common.gc_application_error_code,'Exception During Publish Forecast. ' || v_error_msg);
  end publish_forecast;



  FUNCTION process_supply (i_run_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_result_msg     common.st_message_string;   -- standard prcedure message variable
    v_return         common.st_result;   -- standard prcedure message variable
    e_process_error  EXCEPTION;   -- general processing error exception
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_SUPPLY');

    -- Load data into load_sply table and validate structure of load file.
    IF demand_forecast.load_supply_feed (i_run_id, demand_forecast.gc_wildcard_supply, v_result_msg) = common.gc_success THEN   -- if no error found in file
      logit.LOG ('Loading of the supply feed was successful.');
    ELSE
      -- set error message for email
      o_result_msg := 'Supply loading error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    -- load of supply file was ok continue,.
    IF demand_forecast.process_supply_feed (demand_forecast.gc_wildcard_supply, v_result_msg) = common.gc_success THEN   -- if the supply file processed ok then.
      -- process was ok, no errors at all.
      logit.LOG ('Processing of the supply feed was successful.');
    ELSE
      -- set error message
      o_result_msg := 'Supply processing error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_process_error THEN
      -- general process error, so send email with details.
      logit.log_error (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || ' ' || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
  END process_supply;

  FUNCTION process_demand (i_run_id common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_result_msg     common.st_message_string;   -- standard procedure processing message
    e_process_error  EXCEPTION;   -- general processing error exception
    v_heading        BOOLEAN;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_DEMAND');

    -- Now load the the demand data from the unix flat file in LOAD_DMND.
    IF demand_forecast.load_demand_feed (i_run_id, demand_forecast.gc_wildcard_demand, v_result_msg) = common.gc_success THEN   -- If load ok.
      logit.LOG ('Loading of the demand feed was successful.');
    ELSE
      o_result_msg := 'Demand loading error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    -- Load went ok, now process records from LOAD_DMND_RAW into LOAD_DMND.
    IF demand_forecast.process_demand_feed (demand_forecast.gc_wildcard_demand, v_result_msg) = common.gc_success THEN
      logit.LOG ('Processing of the demand feed was successful.');
    ELSE
      o_result_msg := 'Demand processing error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    -- all after process checks passed , so return all clear.
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_process_error THEN
      -- exception handler  ,  Process error so send email with error details.
      logit.log_error (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      -- unhandeled exception handler  ,  Process error so send email with error details.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
  END process_demand;

  FUNCTION process_supply_draft (i_run_id common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_result_msg     common.st_message_string;   -- standard procedure processing message
    e_process_error  EXCEPTION;   -- general processing error exception
    v_heading        BOOLEAN;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_SUPPLY_DRAFT');

    -- Now load the the supply draft data from the unix flat file in LOAD_DMND.
    IF demand_forecast.load_supply_feed (i_run_id, demand_forecast.gc_wildcard_sply_draft, v_result_msg) = common.gc_success THEN   -- If load ok.
      logit.LOG ('Loading of the supply draft feed was successful.');
    ELSE
      o_result_msg := 'Supply draft loading error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    -- Load went ok, now process records from LOAD_SPLY_RAW into LOAD_SPLY.
    IF demand_forecast.process_supply_feed (demand_forecast.gc_wildcard_sply_draft, v_result_msg) = common.gc_success THEN
      logit.LOG ('Processing of the supply draft feed was successful.');
    ELSE
      o_result_msg := 'Supply draft processing error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    -- all after process checks passed , so return all clear.
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_process_error THEN
      -- exception handler  ,  Process error so send email with error details.
      logit.log_error (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      -- unhandeled exception handler  ,  Process error so send email with error details.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
  END process_supply_draft;

  FUNCTION process_demand_draft (i_run_id common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_result_msg     common.st_message_string;   -- standard procedure processing message
    e_process_error  EXCEPTION;   -- general processing error exception
    v_heading        BOOLEAN;
  BEGIN
    logit.enter_method (pc_package_name, 'PROCESS_DEMAND_DRAFT');

    -- Now load the the demand draft data from the unix flat file in LOAD_DMND.
    IF demand_forecast.load_demand_feed (i_run_id, demand_forecast.gc_wildcard_dmnd_draft, v_result_msg) = common.gc_success THEN   -- If load ok.
      logit.LOG ('Loading of the demand draft feed was successful.');
    ELSE
      o_result_msg := 'Demand draft loading error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    -- Load went ok, now process records from LOAD_DMND_RAW into LOAD_DMND.
    IF demand_forecast.process_demand_feed (demand_forecast.gc_wildcard_dmnd_draft, v_result_msg) = common.gc_success THEN
      logit.LOG ('Processing of the demand draft feed was successful.');
    ELSE
      o_result_msg := 'Demand draft processing error. ' || common.nest_err_msg (v_result_msg);
      RAISE e_process_error;
    END IF;

    -- all after process checks passed , so return all clear.
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_process_error THEN
      -- exception handler  ,  Process error so send email with error details.
      logit.log_error (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      -- unhandeled exception handler  ,  Process error so send email with error details.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
  END process_demand_draft;

  FUNCTION load_reference_data (o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_result_msg      common.st_message_string;   -- standard prcedure message variable
    v_message         common.st_message_string;   -- email message to sent if error occurs
    v_return          common.st_result;   -- standard prcedure message variable
    v_result          common.st_result;   -- standard prcedure message variable
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'LOAD_REFERENCE_DATA');
    -- Popluate LADS reference tables, from LADS master tables. ,
    v_return := lads_ref_data.new_request (v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to allocate new request id. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.queue_update_request (reference_events.gc_update_lads_ref_dat, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to request lads reference data update. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.queue_update_request (reference_events.gc_update_matl, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to request materials data update. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.queue_update_request (reference_events.gc_update_matl_dtrmntn, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to request material determination data update. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.queue_update_request (reference_events.gc_update_clssfctns, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to request classifications data update. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.queue_update_request (reference_events.gc_update_prices, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to request prices data update. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.queue_update_request (reference_events.gc_update_exch_rates, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to request exchange rates data update. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := eventit.trigger_events (v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to trigger event process. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.wait_for_event (reference_events.gc_matl, pc_reference_wait_time, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Materials data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.wait_for_event (reference_events.gc_matl_dtrmntn, pc_reference_wait_time, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Material Determination data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.wait_for_event (reference_events.gc_matl_fg_clssfctn, pc_reference_wait_time, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg :=
                       'Material Finished Goods Classifications data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.wait_for_event (reference_events.gc_prices, pc_reference_wait_time, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Pricing data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.wait_for_event (reference_events.gc_load_lads_xch_rat_det, pc_reference_wait_time, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Exchange rate data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_return := lads_ref_data.wait_for_event (reference_events.gc_matl_moe, pc_reference_wait_time, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Material MOE data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      -- exception handler  ,  Process error so send email with error details.
      o_result_msg := common.create_error_msg ('Reference Data Refreshing Problem. ' || v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandeled exception handler  ,  Process error so send email with error details.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      COMMIT;
      RETURN common.gc_error;
  END load_reference_data;

  ---------------------------------------------------------------------------------
  PROCEDURE run_batch AS
    v_result_msg  common.st_message_string;   -- standard prcedure message variable
    v_result      common.st_result;   -- standard prcedure message variable
    v_error_msg   common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'RUN_BATCH');
    run_batch_common (FALSE);
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      v_result_msg := common.create_sql_error_msg;
      logit.log_error (v_result_msg);
      logit.leave_method;
      v_result := common.gc_error;
  END run_batch;

  ---------------------------------------------------------------------------------
  PROCEDURE run_batch_common (i_refresh IN BOOLEAN) AS
    v_result_msg        common.st_message_string;   -- standard prcedure message variable
    v_error_msg         common.st_message_string;   -- email message to sent if error occurs
    v_group_members     common.t_strings;   -- list of email address to send error in process fails.
    v_return            common.st_result;   -- standard prcedure message variable
    v_run_id            common.st_id;   -- Run id of this batch of load files.
    v_processed         common.st_counter;
    v_processed_demand  common.st_counter;
    v_processed_supply  common.st_counter;
    e_process_error     EXCEPTION;   -- general processing error exception
    e_mail_error        EXCEPTION;   -- failed to send email exception,
    e_lock_error        EXCEPTION;   -- failed to send email exception,
    e_event_error       EXCEPTION;   -- failed to send email exception,

    -- cursor to check for invalid warehouses in load file, FATAL error in any found.
    CURSOR csr_files (i_run_id IN common.st_id) IS
      SELECT file_id, file_name, status
      FROM load_file
      WHERE run_id = i_run_id;

    rv_file             csr_files%ROWTYPE;

    -- cursor to retrieve ten examples, if an error occurs in the load into raw table.
    CURSOR csr_demand_raw (i_file_id IN common.st_id) IS
      SELECT DISTINCT status, error_msg
      FROM load_dmnd_raw
      WHERE file_id = i_file_id AND status <> common.gc_processed;

    rv_demand_raw       csr_demand_raw%ROWTYPE;

    -- cursor to check for invalid demand groups found in demand load file.
    CURSOR csr_demand (i_file_id IN common.st_id) IS
      SELECT DISTINCT status, zrep_code, error_msg
      FROM load_dmnd
      WHERE file_id = i_file_id AND status <> common.gc_processed;

    rv_demand           csr_demand%ROWTYPE;

    -- cursor to retrieve ten examples, if an error occurs in the load into raw table.
    CURSOR csr_supply_raw (i_file_id IN common.st_id) IS
      SELECT DISTINCT status, error_msg
      FROM load_sply_raw ls
      WHERE file_id = i_file_id AND status <> common.gc_processed;

    rv_supply_raw       csr_supply_raw%ROWTYPE;

    -- cursor to check for invalid warehouses in load file, FATAL error in any found.
    CURSOR csr_supply (i_file_id IN common.st_id) IS
      SELECT DISTINCT status, item, error_msg
      FROM load_sply
      WHERE file_id = i_file_id AND status <> common.gc_processed;

    rv_supply           csr_supply%ROWTYPE;
    v_heading           BOOLEAN;
    v_file_heading      BOOLEAN;
  BEGIN
    logit.enter_method (pc_package_name, 'RUN_BATCH_COMMON');
    lockit.set_lock_timeout (5);

    IF lockit.request_lock (pc_lock_name, lockit.gc_lock_mode_exclusive, FALSE, v_result_msg) != common.gc_success THEN
      RAISE e_lock_error;
    END IF;

    -- Create new email.
    IF emailit.create_email (NULL, 'DEMAND FINANCIALS EMAIL ALERT', v_result_msg) != common.gc_success THEN
      RAISE e_mail_error;
    END IF;

    logit.LOG ('Get list of user in mailing group');

    -- Get list of email address to sent message to, if errored.
    IF security.get_group_user_emails (demand_forecast.gc_demand_alerting_group, v_group_members, v_result_msg) = common.gc_success THEN
      FOR v_i IN v_group_members.FIRST .. v_group_members.LAST
      LOOP
        --logit.LOG('Add '||v_group_members (v_i));
        IF emailit.add_recipient (emailit.gc_area_to, emailit.gc_type_user, v_group_members (v_i), null, v_result_msg) != common.gc_success THEN
          logit.LOG ('Add recipeint failed');
          RAISE e_mail_error;
        END IF;
      END LOOP;
    ELSE
      logit.LOG ('Failed to find mailing list');
      RAISE e_mail_error;
    END IF;

    logit.LOG ('Allocate a Run ID:');

    -- Now get unique run id,
    IF demand_object_tracking.get_new_id ('LOAD_FILE', 'RUN_ID', v_run_id, v_result_msg) != common.gc_success THEN
      RAISE e_process_error;
    END IF;

    emailit.add_content ('Demand Financials File Batch Processing Report.');
    emailit.add_content ('-----------------------------------------------');
    emailit.add_content ('Please find below a report summarising the files that were processed');
    emailit.add_content ('during the last batch processing run. In the report any records that');
    emailit.add_content ('are ERRORED have not made it into the forecast and require immediate');
    emailit.add_content ('action.  Any records that have FAILED have had their volume included');
    emailit.add_content ('in the forecast but may not be correctly calculated and also require');
    emailit.add_content ('action.  To find more specific information about processing errors');
    emailit.add_content ('please run the Load Errors and Failure report for the associated file.');
    emailit.add_content (common.gc_crlf);
    emailit.add_content (   '## Batch Run Commenced.               '
                         || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS')
                         || ' Run ID : '
                         || TO_CHAR (v_run_id)
                         || ' Log ID : '
                         || logit.get_log_id);

    -- Now load LADS reference data.
    IF i_refresh = TRUE THEN
      logit.LOG ('Loading Reference Data.');
      emailit.add_content (' - Loading Reference Data.            ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );

      IF load_reference_data (v_result_msg) != common.gc_success THEN
        RAISE e_process_error;
      END IF;
    ELSE
      logit.LOG ('Skipping Load of Reference Data.');
      emailit.add_content (' - Reference Data Load Skipped.       ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );
    END IF;

    -- Processing Supply Files.
    logit.LOG ('Process Supply.');
    emailit.add_content (' - Processing Any Supply Files.       ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );

    IF process_supply (v_run_id, v_result_msg) != common.gc_success THEN
      RAISE e_process_error;
    END IF;

    -- Processing Demand Files.
    logit.LOG ('Process Demand.');
    emailit.add_content (' - Processing Any Demand Files.       ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );

    IF process_demand (v_run_id, v_result_msg) != common.gc_success THEN
      RAISE e_process_error;
    END IF;

    -- Processing Supply Draft Files.
    logit.LOG ('Process Supply Draft.');
    emailit.add_content (' - Processing Any Supply Draft Files. ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );

    IF process_supply_draft (v_run_id, v_result_msg) != common.gc_success THEN
      RAISE e_process_error;
    END IF;

    -- Processing Demand Draft Files.
    logit.LOG ('Process Demand Draft.');
    emailit.add_content (' - Processing Any Demand Draft Files. ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );

    IF process_demand_draft (v_run_id, v_result_msg) != common.gc_success THEN
      RAISE e_process_error;
    END IF;

    -- Complete the processing trigger events.
    logit.LOG ('Processing Completed.');
    emailit.add_content (' - Commencing Event Processing.       ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );
    logit.LOG ('Releasing processing lock.');

    IF lockit.release_lock (pc_lock_name, v_result_msg) != common.gc_success THEN
      RAISE e_lock_error;
    END IF;

    logit.LOG ('Triggering Event Processing.');

    IF eventit.trigger_events (v_result_msg) != common.gc_success THEN
      RAISE e_event_error;
    END IF;

    -- Processed ok, send email message to show success.
    emailit.add_content ('## Batch Run Completed.               ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );
    emailit.add_content (common.gc_crlf);
    -- Now perform any error messaging as required.
    logit.LOG ('Now report any error or warning message for this processing run.');
    -- Report the files processed.
    v_file_heading := FALSE;

    FOR rv_file IN csr_files (v_run_id)
    LOOP
      IF v_file_heading = FALSE THEN
        emailit.add_content ('*** File(s) Processed ***');
        v_file_heading := TRUE;
      END IF;

      emailit.add_content (' # ' || rv_file.file_name || ' - File ID:' || rv_file.file_id || ' - ' || rv_file.status);
      -- Now add any supply raw file errors.
      v_heading := FALSE;

      FOR rv_supply_raw IN csr_supply_raw (rv_file.file_id)
      LOOP
        IF v_heading = FALSE THEN
          emailit.add_content ('   SUPPLY LOAD ERRORS');
          v_heading := TRUE;
        END IF;

        emailit.add_content ('   - ' || rv_supply_raw.status || ':' || rv_supply_raw.error_msg);
      END LOOP;

      -- Now add any demand raw file errors.
      v_heading := FALSE;

      FOR rv_demand_raw IN csr_demand_raw (rv_file.file_id)
      LOOP
        IF v_heading = FALSE THEN
          emailit.add_content ('   DEMAND LOAD ERRORS');
          v_heading := TRUE;
        END IF;

        emailit.add_content ('   - ' || rv_demand_raw.status || ':' || rv_demand_raw.error_msg);
      END LOOP;

      -- Now add any supply file errors.
      v_heading := FALSE;

      FOR rv_supply IN csr_supply (rv_file.file_id)
      LOOP
        IF v_heading = FALSE THEN
          emailit.add_content ('   SUPPLY PROCESSING ERRORS');
          v_heading := TRUE;
        END IF;

        emailit.add_content ('   - ' || rv_supply.status || ':' || rv_supply.item || ' - ' || rv_supply.error_msg);
      END LOOP;

      -- Now add any demand file errors.
      v_heading := FALSE;

      FOR rv_demand IN csr_demand (rv_file.file_id)
      LOOP
        IF v_heading = FALSE THEN
          emailit.add_content ('   DEMAND PROCESSING ERRORS');
          v_heading := TRUE;
        END IF;

        emailit.add_content ('   - ' || rv_demand.status || ':' || rv_demand.zrep_code || ' - ' || rv_demand.error_msg);
      END LOOP;
    END LOOP;

    IF v_file_heading = FALSE THEN
      emailit.add_content ('*** No Files Found For Processing. ***');
    END IF;

    -- Now send the email.
    logit.LOG ('Send processing email.');
    v_return := emailit.send_email (v_result_msg);

    IF v_return <> common.gc_success THEN
      logit.log_error ('Unable to send alerting email. ' || common.nest_err_msg (v_result_msg) );
    END IF;

    -- NOw exit the procedure.
    logit.leave_method;
  EXCEPTION
    WHEN e_event_error THEN
      -- exception handler  ,  Process error so send email with error details.
      v_error_msg := common.create_error_msg ('Event error. ' || v_result_msg);
      logit.log_error (v_error_msg);
      v_return := emailit.add_content (v_error_msg, v_result_msg);
      v_return := emailit.send_email (v_result_msg);
      logit.leave_method;
      COMMIT;
    WHEN e_lock_error THEN
      -- exception handler  ,  Process error so send email with error details.
      v_error_msg := common.create_error_msg ('Lock error. ' || v_result_msg);
      logit.log_error (v_error_msg);
      v_return := emailit.add_content (v_error_msg, v_result_msg);
      v_return := emailit.send_email (v_result_msg);
      logit.leave_method;
      COMMIT;
    WHEN e_process_error THEN
      -- exception handler  ,  Process error so send email with error details.
      v_error_msg := common.create_error_msg ('Fatal Processing Error. ' || v_result_msg);
      logit.log_error (v_error_msg);

      IF lockit.release_lock (pc_lock_name, v_result_msg) != common.gc_success THEN
        NULL;
      END IF;

      v_return := emailit.add_content (v_error_msg, v_result_msg);
      v_return := emailit.send_email (v_result_msg);
      logit.leave_method;
      COMMIT;
    WHEN e_mail_error THEN
      -- exception handler  , IO error with email sub system.
      v_error_msg := common.create_error_msg ('Email send error. ' || v_result_msg);
      logit.log_error (v_error_msg);

      IF lockit.release_lock (pc_lock_name, v_result_msg) != common.gc_success THEN
        NULL;
      END IF;

      logit.leave_method;
      COMMIT;
    WHEN OTHERS THEN
      -- unhandeled exception handler  ,  Process error so send email with error details.
      v_error_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.log_error (v_error_msg);

      IF lockit.release_lock (pc_lock_name, v_result_msg) != common.gc_success THEN
        NULL;
      END IF;

      v_return := emailit.add_content (v_error_msg, v_result_msg);
      v_return := emailit.send_email (v_result_msg);
      logit.leave_method;
      COMMIT;
  END run_batch_common;

  PROCEDURE perform_housekeeping AS
    v_result_msg   common.st_message_string;   -- standard prcedure message variable
    v_return       common.st_result;   -- standard prcedure message variable
    v_error_msg    common.st_message_string;
    e_event_error  EXCEPTION;
  BEGIN
    logit.enter_method (pc_package_name, 'PERFORM_HOUSEKEEPING');
    -- Now remove any old files.
    logit.LOG ('Remove any old files.');
    v_return := demand_forecast.cleanup_old_files (v_result_msg);
    -- Now archive any old forecasts.
    logit.LOG ('Remove any old files.');
    v_return := demand_forecast.archive_old_forecasts (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_error_msg := common.create_error_msg ('Failed to archive old forecasts. ') || common.nest_err_msg (v_result_msg);
      logit.log_error (v_error_msg);
    END IF;

    -- Now purge any old forecasts.
    logit.LOG ('Remove any old files.');
    v_return := demand_forecast.purge_old_forecasts (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_error_msg := common.create_error_msg ('Failed to purge old forecasts. ') || common.nest_err_msg (v_result_msg);
      logit.log_error (v_error_msg);
    END IF;

    -- Now clear out any old object tracking information.
    logit.LOG ('Remove any old objects.');
    demand_object_tracking.delete_orphans;
    -- Now process any background events.
    logit.LOG ('Trigger any background processing for the housekeeping.');

    IF eventit.trigger_events (v_result_msg) != common.gc_success THEN
      RAISE e_event_error;
    END IF;

    IF v_return <> common.gc_success THEN
      v_error_msg := common.create_error_msg ('Failed to trigger event processing. ') || common.nest_err_msg (v_result_msg);
      logit.log_error (v_error_msg);
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN e_event_error THEN
      v_error_msg := common.create_error_msg ('Creat event failure.') || v_result_msg;
      logit.log_error (v_error_msg);
      logit.leave_method;
    WHEN OTHERS THEN
      v_error_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.log_error (v_error_msg);
      logit.leave_method;
  END perform_housekeeping;
END demand_processing;