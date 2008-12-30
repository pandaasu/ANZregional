CREATE OR REPLACE PACKAGE BP_APP.bpip_extracts AS
  /*******************************************************************************
   NAME:      EXTRACT_FPPS
   PURPOSE:   This package provides all the key processing functionality required
              for sending extracts to FPPS.
  ********************************************************************************/

  /*******************************************************************************
     NAME:      INITILISE
     PURPOSE:   This procedure setups parameters for the extraction.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   14/12/2006 Nick Bates           Created this procedure.

     NOTES:
    ********************************************************************************/
  PROCEDURE initialise;

  /*******************************************************************************
     NAME:      LOOKUP_FPPS_CODE
     PURPOSE:   This procedure looks up the FPPS_CODE for the sales_org, bus_sgmnt
                and fpps_type_code.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   22/06/2008 Mary Ahyick           Created this procedure.
     
     NOTES:
    ********************************************************************************/

 FUNCTION lookup_fpps_code (
   i_company         IN common.st_code, 
   i_bus_sgmnt_code  IN common.st_code, 
   i_fpps_type_code  IN common.st_code)
   RETURN common.st_code;
  /*******************************************************************************
     NAME:      REQUEST_EXTRACT
     PURPOSE:   This procedure requests an extract and triggers the event
                processing to perform the extract.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   09/06/2006 Chris Horn           Created this procedure.

     NOTES: Called from BPIPAdministration.xla
    ********************************************************************************/
  FUNCTION request_extract (
    i_extract_type  IN      common.st_code,
    i_dataentity    IN      common.st_code,
    i_company       IN      common.st_code,
    i_bus_sgmnt     IN      common.st_code,
    i_from_period   IN      common.st_code,
    i_to_period     IN      common.st_code,
    o_result_msg    OUT     common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
     NAME:      PPV_EXTRACT
     PURPOSE:   This will extract the data and insert into table EXTCT_FPPS

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   11/08/2006 Chris Horn           Added this header

     NOTES:
    ********************************************************************************/
  FUNCTION ppv_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
     NAME:      INVENTORY_EXTRACT
     PURPOSE:   This will create a closing inventory value extract based on standards
                and send to fpps.

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   11/08/2006 Chris Horn           Added this header

     NOTES:
    ********************************************************************************/
  FUNCTION inventory_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
     NAME:      PERFORM_EXTRACT
     PURPOSE:   Selects the data set from the extct_fpps load table based on
             the extct_req.extct_req_id value passed into this procedure and creates a file

     REVISIONS:
     Ver   Date       Author               Description
     ----- ---------- -------------------- ----------------------------------------
     1.0   11/05/2007 Sal Sanghera         Added this header

     NOTES:
    ********************************************************************************/
  FUNCTION perform_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*******************************************************************************
    NAME:      SEND_EXTRACT
    PURPOSE:   Send the extracted file to the FPPS server

    REVISIONS:
    Ver   Date       Author               Description
    ----- ---------- -------------------- ----------------------------------------
    1.0   11/05/2007 Sal Sanghera         Added this header

    NOTES:
   ********************************************************************************/
  FUNCTION send_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result;

  /*************************************************************************
      NAME:      DELETE_OLD_EXTRACTS
      PURPOSE:   Delete old extracts from the extract ables.
      REVISIONS:
      Ver   Date       Author               Description
      ----- ---------- -------------------- ----------------------------------
      1.0   12/12/2006  Nick Bates        Created this function.

      NOTES: Look for extracts which are older then a given date and remove the rows
            from the extract tables.
            EXTCT_FPPS, EXTCT_REQ
    *************************************************************************/
  PROCEDURE delete_old_extracts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string);
END bpip_extracts;


CREATE OR REPLACE PACKAGE BODY BP_APP.bpip_extracts AS
  pc_package_name                CONSTANT common.st_package_name   := 'BPIP_EXTRACTS';
  pc_param_ext_days_hist_code    CONSTANT common.st_code           := 'EXTRACTS_DAYS_HIST';
  -- pc_fpps_item_total             CONSTANT common.st_code           := 'NARBPB';
  pc_param_ext_default_day_hist  CONSTANT common.st_value          := 365;
  pv_extrct_id                            common.st_counter;
  -- MQ parameters
  pc_fpps_bpip_source_mq_code    CONSTANT common.st_code           := 'FPPSBPIP_SOURCE_QMGR';
  pc_fpps_bpip_target_mq_code    CONSTANT common.st_code           := 'FPPSBPIP_TARGET_QMGR';
  pc_fpps_bpip_target_path       CONSTANT common.st_code           := 'FPPSBPIP_TARGET_PATH';
  pc_fpps_bpip_target_mq         CONSTANT common.st_code           := 'MOU100P1';
  pc_fpps_bpip_target_path_text  CONSTANT common.st_name           := '/fppsupload/site_<FPPS_MOE>/upload_files';

  pc_fpps_bpip_mq_default        CONSTANT common.st_message_string := '<set>';   -- After initialisation please change in the system params table.
  pc_system_prefix_code          CONSTANT common.st_code           := 'SYSTEM_PREFIX';   
  pc_system_prefix_default       CONSTANT common.st_message_string := '<set>';   -- After initialisation please change in the system params table.
  pc_dest_system_prefix_code          CONSTANT common.st_code           := 'BPIP';  

  -- Source Queue Manager Test = WODU03T1
  -- Target Queue Manager Test = ?
  -- Source Queue Manager Prod = WODU02P1
  -- Target Queue Manager Prod = MOU100P1


  -- All items
  PROCEDURE initialise IS
    v_result_msg      common.st_message_string;
    v_return          common.st_code;
    v_processing_msg  common.st_message_string;
    -- Exceptions
    e_load_failure    EXCEPTION;
  BEGIN
    -- Enter the method
    logit.enter_method (pc_package_name, 'INITIALISE');
    -- Exit and leave successfully.
    v_return := table_maint_gui.install_table ('FPPS_XREF', 'FPPS Cross Reference Table', 'BPIP', v_result_msg);
   
    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_error;
    END IF;

    v_return := system_params.exists_parameter (bpip_system.gc_system_code, pc_param_ext_days_hist_code, v_result_msg); 
    
    IF v_return = common.gc_failure   --- if parameter has not been registered
                                   THEN
      logit.LOG (bpip_system.gc_system_code);
      logit.LOG (pc_param_ext_days_hist_code);
      v_return := system_params.set_parameter_value (bpip_system.gc_system_code, pc_param_ext_days_hist_code, pc_param_ext_default_day_hist, v_result_msg);

      IF v_return != common.gc_success THEN   -- if parameter registration failed.
        logit.log_error (common.create_failure_msg ('Unable to set extracts days history parameter') );
      END IF;

      -- Now add a comment to the parameter.
      v_return :=
        system_params.set_parameter_comment (bpip_system.gc_system_code,
                                             pc_param_ext_days_hist_code,
                                             'This parameter controls the number of days worth of extracts history to keep in the system.',
                                             v_result_msg);

      IF v_return != common.gc_success THEN
        logit.log_error (common.create_failure_msg ('Unable to set extracts days history parameter comments.') );
      END IF;
    END IF;

    logit.LOG ('MQFT Parameters :');

    IF system_params.exists_parameter (bpip_system.gc_system_code, pc_fpps_bpip_source_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (bpip_system.gc_system_code, pc_fpps_bpip_source_mq_code, pc_fpps_bpip_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install FPPS BPIP source queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (bpip_system.gc_system_code,
                                            pc_fpps_bpip_source_mq_code,
                                            'This is the source queue manager that BPIP files should be put on for FPPS.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (bpip_system.gc_system_code, pc_fpps_bpip_target_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (bpip_system.gc_system_code, pc_fpps_bpip_target_mq_code, pc_fpps_bpip_target_mq, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install FPPS BPIP target queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (bpip_system.gc_system_code,
                                            pc_fpps_bpip_target_mq_code,
                                            'This is the target queue manager that BPIP files should be sent to for FPPS.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (bpip_system.gc_system_code, pc_fpps_bpip_target_path, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (bpip_system.gc_system_code, pc_fpps_bpip_target_path, pc_fpps_bpip_target_path_text, v_result_msg) !=
                                                                                                                                              common.gc_success THEN
        v_processing_msg := 'Unable to define BPIP FPPS target path.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (bpip_system.gc_system_code,
                                            pc_fpps_bpip_target_path,
                                            'This is the target path that the BPIP FPPS will be written to.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    -- system prefix parameter
    v_return := system_params.exists_parameter (bpip_system.gc_system_code, pc_system_prefix_code, v_result_msg);

    IF v_return = common.gc_failure   --- if parameter has not been registered
                                   THEN
      logit.LOG (bpip_system.gc_system_code);
      logit.LOG (pc_system_prefix_code);
      v_return := system_params.set_parameter_text (bpip_system.gc_system_code, pc_system_prefix_code, pc_system_prefix_default, v_result_msg);

      IF v_return != common.gc_success THEN   -- if parameter registration failed.
        logit.log_error (common.create_failure_msg ('Unable to set ' || pc_system_prefix_code) );
      END IF;

      -- Now add a comment to the parameter.
      v_return :=
        system_params.set_parameter_comment (bpip_system.gc_system_code,
                                             pc_param_ext_days_hist_code,
                                             'This parameter is the system prefix ie DEV_BPIP,TEST_BPIP or BPIP.',
                                             v_result_msg);

      IF v_return != common.gc_success THEN
        logit.log_error (common.create_failure_msg ('Unable to set comments for ' || pc_system_prefix_code) );
      END IF;
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      v_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (v_result_msg);
      logit.leave_method;
    WHEN common.ge_error THEN
      v_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (v_result_msg);
      logit.leave_method;
    WHEN e_load_failure THEN
      v_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error ('Failed to initialise parameters : ' || v_processing_msg);
      logit.leave_method;
    WHEN OTHERS THEN
      v_result_msg := common.create_error_msg ('Unable to initialise.') || common.nest_err_msg (common.create_sql_error_msg);
      logit.log_error (v_result_msg);
      logit.leave_method;
  END initialise;

  ---------------------------------------------------------------------------------
  FUNCTION lookup_fpps_code (
   i_company         IN common.st_code, 
   i_bus_sgmnt_code  IN common.st_code, 
   i_fpps_type_code  IN common.st_code)
  
    RETURN common.st_code IS
    CURSOR csr_fpps_code IS
      SELECT fpps_code
      FROM fpps_xref t1
      WHERE t1.BUS_SGMNT_CODE = i_bus_sgmnt_code AND t1.company = i_company AND t1.FPPS_TYPE_CODE = i_fpps_type_code;
    v_fpps_code  common.st_code;
  BEGIN
    v_fpps_code := NULL;

    OPEN csr_fpps_code;

    FETCH csr_fpps_code
    INTO v_fpps_code;

    CLOSE csr_fpps_code;

    RETURN v_fpps_code;
  END lookup_fpps_code;

  FUNCTION request_extract (
    i_extract_type  IN      common.st_code,
    i_dataentity    IN      common.st_code,
    i_company       IN      common.st_code,
    i_bus_sgmnt     IN      common.st_code,
    i_from_period   IN      common.st_code,
    i_to_period     IN      common.st_code,
    o_result_msg    OUT     common.st_message_string)
    RETURN common.st_result IS
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
    v_return          common.st_result;
    e_extract_id      EXCEPTION;
    e_event_error     EXCEPTION;   -- event processing error
  BEGIN
    -- Enter the method
    logit.enter_method (pc_package_name, 'REQUEST_EXTRACT');
    -- Now create an entry in the extract request table.
    logit.LOG (   'i_extract_type : '
               || i_extract_type
               || 'i_dataentity: '
               || i_dataentity
               || 'i_company: '
               || i_company
               || 'i_bus_sgmnt: '
               || i_bus_sgmnt
               || ' i_from_period: '
               || i_from_period
               || 'i_to_period: '
               || i_to_period);

    -- get the request id from the sequence and assign it to a package variable
    IF bpip_object_tracking.get_new_id ('EXTCT_REQ', 'EXTCT_REQ_ID', pv_extrct_id, v_result_msg) != common.gc_success THEN
      RAISE e_extract_id;
    END IF;

    -- Insert batch details into the EXTCT_REQ table.
    INSERT INTO extct_req a
                (extct_req_id, extct_type_code, req_time, extct_start, extct_end, req_by_id, status, error_msg, dataentity, company, bus_sgmnt,
                 from_period, to_period, extct_outpt_file_name, extct_dest_file_name)
         VALUES (pv_extrct_id, i_extract_type, SYSDATE, SYSDATE, NULL, security.current_user_id, common.gc_pending, NULL, i_dataentity, i_company, i_bus_sgmnt,
                 i_from_period, i_to_period, NULL, NULL);

    COMMIT;
    logit.LOG (' CREATE events for PPV extract or Inventory extract based on the parameter i_extract_type');

    IF i_extract_type = bpip_events.gc_extract_type_ppv THEN
      IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_ppv_extract, pv_extrct_id, 'Perform PPV Extract', v_result_msg) != common.gc_success THEN
        RAISE e_event_error;
      END IF;
    ELSIF i_extract_type = bpip_events.gc_extract_type_inventory THEN
      IF eventit.create_event (bpip_system.gc_system_code, bpip_events.gc_inventory_extract, pv_extrct_id, 'Perform Inventory Extract', v_result_msg) !=
                                                                                                                                              common.gc_success THEN
        RAISE e_event_error;
      END IF;
    END IF;

    logit.LOG (' Now trigger the event.');
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Failed to trigger event process. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

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
    WHEN e_extract_id THEN
      o_result_msg := common.create_failure_msg ('Could not allocate extract id :' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error:' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to perform extract.') || common.nest_err_msg (common.create_sql_error_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END request_extract;

  ---------------------------------------------------------------------------------
  FUNCTION ppv_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    v_processing_msg               common.st_message_string;
    v_return                       common.st_result;
    v_return_msg                   common.st_message_string;
    v_result_msg                   common.st_message_string;
    v_data_ids                     common.t_ids;
    -- Model Intersect IDS
    v_mdl_isct_ppv_comb_id         common.st_id;
    v_mdl_isct_prodn_qty_id        common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity_id    common.st_id;
    v_chrstc_type_company_id       common.st_id;
    v_chrstc_type_bus_sgmnt_id     common.st_id;
    v_chrstc_type_purch_grp_id     common.st_id;
    v_chrstc_type_matl_id          common.st_id;
    v_chrstc_type_plant_id         common.st_id;
    v_chrstc_type_period_id        common.st_id;
    v_chrstc_type_vendor_id        common.st_id;
    v_chrstc_type_activity_id      common.st_id;
    v_chrstc_type_ppv_clssfctn_id  common.st_id;
    v_chrstc_type_ppv_type_id      common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id         common.st_id;
    v_chrstc_period_id             common.st_id;
    v_chrstc_company_id            common.st_id;
    v_chrstc_bus_sgmnt_id          common.st_id;
    v_chrstc_purch_grp_id          common.st_id;
    v_chrstc_matl_id               common.st_id;
    v_chrstc_plant_id              common.st_id;
    v_chrstc_vendor_id             common.st_id;
    v_chrstc_activity_id           common.st_id;
    v_chrstc_ppv_clssfctn_id       common.st_id;
    v_chrstc_ppv_type_id           common.st_id;
    -- Characteristic Array
    v_chrstc_ids                   common.t_ids;
    -- Charactersitic codes
    v_chrstc_matl_code             common.st_code;
    v_chrstc_ppv_type_code         common.st_code;
    v_matl_type                    common.st_code;
    -- Other
    v_data_counter                 common.st_counter;
    v_value                        common.st_value;
    v_value_pos common.st_value;
    v_value_neg common.st_value;
    v_range common.st_value;
    v_top_down                     common.st_status;
    v_revision                     common.st_count;
    v_line_counter                 common.st_count;
    -- Fpps variables.
    v_fpps_code                    common.st_code;
    v_fpps_source                  common.st_code;
    v_fpps_destination             common.st_code;
    v_fpps_customer                common.st_code;
    v_fpps_line_item               common.st_code;
    -- Period Array process variable
    -- v_dataentity_fromperiod        common.st_code;
    -- v_dataentity_toperiod          common.st_code;
    v_current_period               common.st_code;
    v_period_ids                   common.t_ids;
    v_period_counter               common.st_counter;
    v_period_codes                 common.t_codes;
    v_extct_fpps_col               common.st_code;
    v_period_num                   common.st_code;
    -- Exceptions
    e_event_error                  EXCEPTION;   -- event processing error

    CURSOR csr_extract_request IS
      SELECT *
      FROM extct_req
      WHERE extct_req_id = i_extract_request_id;

    rv_extract_request             csr_extract_request%ROWTYPE;

    CURSOR csr_matl_type IS
      SELECT matl_type
      FROM matl
      WHERE matl_code = reference_functions.full_matl_code (v_chrstc_matl_code);

    PROCEDURE add_line (i_fpps_item IN common.st_code, i_value common.st_value, i_period_col IN common.st_code) IS
      v_insert_stmnt  common.st_sql;
      v_col           VARCHAR2 (3);
    BEGIN
      v_insert_stmnt :=
           'INSERT INTO extct_fpps(extct_req_id, line_num, item, source, destination, customer, line_item, currency, data_id,'
        || i_period_col
        || ') VALUES (:i_extract_request_id, :v_line_counter, :i_fpps_item, :v_fpps_source, :v_fpps_destination, :v_fpps_customer, :v_fpps_line_item, ''AUD'', '
        || v_data_ids (v_data_counter)
        || ', :i_value )';

      --logit.LOG ('v_insert_stmnt = ' || v_insert_stmnt);
      EXECUTE IMMEDIATE v_insert_stmnt
      USING i_extract_request_id, v_line_counter, i_fpps_item, v_fpps_source, v_fpps_destination, v_fpps_customer, v_fpps_line_item, i_value;

      v_line_counter := v_line_counter + 1;
    END add_line;

    PROCEDURE allocate_by_production IS
      v_where_used            recipe_functions.t_where_used;
      v_prodn_chrstc_ids      common.t_ids;
      v_counter               common.st_counter;
      v_prodn_sum_pos             common.st_value;
      v_prodn_sum_neg             common.st_value;
      v_chrstc_prodn_matl_id  common.st_id;
      v_chrstc_prodn_plant_id common.st_id;
      v_prodn_data_id         common.st_id;
      v_prodn_value           common.st_value;
      v_prodn_top_down        common.st_status;
      v_prodn_revision        common.st_value;
    BEGIN
      -- Create the where used array.
      v_return :=
         recipe_functions.where_used (rv_extract_request.company, reference_functions.full_matl_code (v_chrstc_matl_code), SYSDATE, false, v_where_used, v_return_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to perform where used check on material : ' || v_chrstc_matl_code || '.';
        RAISE common.ge_error;
      END IF;

      --logit.LOG ('Now read the production quantities.');
      v_prodn_chrstc_ids (1) := v_chrstc_dataentity_id;
      v_prodn_chrstc_ids (2) := v_chrstc_company_id;
      v_prodn_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;
      v_prodn_chrstc_ids (4) := v_chrstc_period_id;
      v_counter := 1;
      v_prodn_sum_pos := 0;
      v_prodn_sum_neg := 0;
      v_value_neg := 0;
      v_value_pos := 0;
      v_range := 0;
      

      WHILE v_counter <= v_where_used.COUNT
      LOOP
        --logit.log('Lookup the finished good characteristic id.');
        v_return :=
          characteristics.get_chrstc_id (v_chrstc_type_matl_id,
                                         reference_functions.short_matl_code (v_where_used (v_counter).matl_code),
                                         v_chrstc_prodn_matl_id,
                                         v_return_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg := 'Could not find material characteristic for : ' || reference_functions.short_matl_code (v_where_used (v_counter).matl_code)
                              || '.';
          RAISE common.ge_error;
        END IF;

        v_prodn_chrstc_ids (5) := v_chrstc_prodn_matl_id;
        
        -- Lookup the plant characteristic id.
        v_return :=
          characteristics.get_chrstc_id (v_chrstc_type_plant_id,
                                         v_where_used (v_counter).plant,
                                         v_chrstc_prodn_plant_id,
                                         v_return_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg := 'Could not find material characteristic for : ' || reference_functions.short_matl_code (v_where_used (v_counter).matl_code)
                              || '.';
          RAISE common.ge_error;
        END IF;

        v_prodn_chrstc_ids (6) := v_chrstc_prodn_plant_id;
        
        -- Now lookup the data id.
        v_return := data_values.get_data_id (v_mdl_isct_prodn_qty_id, v_prodn_chrstc_ids, v_prodn_data_id, v_return_msg);

        IF v_return = common.gc_success THEN
          v_return := data_values.get_data_vlu (v_prodn_data_id, v_prodn_value, v_prodn_top_down, v_prodn_revision, v_return_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := 'Unable to get the production quantity from data id : ' || v_prodn_data_id || '. ' || common.nest_err_msg (v_return_msg);
            RAISE common.ge_error;
          END IF;

          v_where_used (v_counter).extra_value1 := v_prodn_value * v_where_used (v_counter).proportion;
          
          if v_where_used (v_counter).extra_value1 < 0 then
            v_prodn_sum_neg := v_prodn_sum_neg + v_where_used (v_counter).extra_value1;
          else
            v_prodn_sum_pos := v_prodn_sum_pos + v_where_used (v_counter).extra_value1;
          end if;
          
          
        ELSIF v_return = common.gc_failure THEN
          v_where_used (v_counter).extra_value1 := 0;
        ELSE
          v_processing_msg := 'Unable to get the production quantity infromation for ' || v_where_used (v_counter).matl_code || '.';
          RAISE common.ge_error;
        END IF;

        -- Increase the counter.
        v_counter := v_counter + 1;
      END LOOP;

      --logit.log('Now perform the value allocation if there was was something produced.');
      IF v_prodn_sum_pos > 0 AND v_prodn_sum_neg <= 0 AND v_where_used.COUNT > 0 THEN
        -- Now perform the weighted averaging allocation
        v_counter := 1;

        v_range := ABS(v_prodn_sum_neg) + v_prodn_sum_pos;
        v_value_neg := ((ABS(v_prodn_sum_neg)/v_range) * v_value) * -1;
        v_value_pos := (v_value_neg * -1) + v_value; 

        WHILE v_counter <= v_where_used.COUNT
        LOOP
          IF v_where_used (v_counter).extra_value1 > 0 THEN
            v_where_used (v_counter).extra_value2 := (v_value_pos * v_where_used (v_counter).extra_value1) / v_prodn_sum_pos;
          elsif v_where_used (v_counter).extra_value1 < 0 THEN
            v_where_used (v_counter).extra_value2 := (v_value_neg * v_where_used (v_counter).extra_value1) / v_prodn_sum_neg;
          else
            NULL;
          END IF;

          v_counter := v_counter + 1;
        END LOOP;

        --logit.log('Now write the values to the extract table.');
        v_counter := 1;

        WHILE v_counter <= v_where_used.COUNT
        LOOP
          IF v_where_used (v_counter).extra_value2 IS NOT NULL THEN
            v_fpps_source := reference_functions.lookup_fpps_source (rv_extract_request.company, v_where_used (v_counter).matl_code);
            add_line (reference_functions.short_matl_code (v_where_used (v_counter).matl_code), v_where_used (v_counter).extra_value2, v_extct_fpps_col);
          END IF;

          v_counter := v_counter + 1;
        END LOOP;
      ELSE
        v_fpps_code := lookup_fpps_code ( rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_FG');
        add_line (v_fpps_code, v_value, v_extct_fpps_col);
      END IF;
    END allocate_by_production;
  --
  BEGIN
    -- Enter the method
    logit.enter_method (pc_package_name, 'PPV_EXTRACT');

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.status = common.gc_loading
     WHERE a.extct_req_id = i_extract_request_id;

    logit.LOG ('Clearing any past extracts.');

    DELETE FROM extct_fpps
          WHERE extct_req_id = i_extract_request_id;

    COMMIT;
    -- Open up the extract request.
    logit.LOG ('Getting extract request details.');

    OPEN csr_extract_request;

    FETCH csr_extract_request
    INTO rv_extract_request;

    IF csr_extract_request%NOTFOUND THEN
      v_processing_msg := 'Unable to find extract request details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_extract_request;

    -- Lookup the search charactersitcs.
    logit.LOG ('Looking up characteristics, Types.');
    v_return := common.gc_success;
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_purch_group, v_chrstc_type_purch_grp_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_vndr, v_chrstc_type_vendor_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (bpip_characteristics.gc_chrstc_type_activity, v_chrstc_type_activity_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (bpip_characteristics.gc_chrstc_type_ppv_clssfctn, v_chrstc_type_ppv_clssfctn_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (bpip_characteristics.gc_chrstc_type_ppv_type, v_chrstc_type_ppv_type_id, v_return_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'One or more of the characteristic Type lookups for bpip failed or errored.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('Getting mdl isct set ids.');
    v_return := common.gc_success;
    v_return := v_return + models.get_mdl_isct_set_id (bpip_model.gc_mi_ppv_combined, v_mdl_isct_ppv_comb_id, v_return_msg);
    v_return := v_return + models.get_mdl_isct_set_id (bpip_model.gc_mi_prodn_avg, v_mdl_isct_prodn_qty_id, v_return_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect for PPV combined totals or production quantity.';
      RAISE common.ge_error;
    END IF;

    -- Lookup the search characteristics.
    logit.LOG ('Now lookup the search characteristics.');
    v_return := common.gc_success;
    v_return := characteristics.get_chrstc_id (v_chrstc_type_dataentity_id, rv_extract_request.dataentity, v_chrstc_dataentity_id, v_return_msg);
    v_return := characteristics.get_chrstc_id (v_chrstc_type_company_id, rv_extract_request.company, v_chrstc_company_id, v_return_msg);
    v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt_id, rv_extract_request.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_return_msg);

    -- v_return := characteristics.get_chrstc_id (v_chrstc_type_period_id, rv_extract_request.from_period, v_chrstc_period_id, v_return_msg);

    -- TODO loop around each fo the from to periods.
    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic search lookups failed or errored';
      RAISE common.ge_error;
    END IF;

    -- create an array of the periods of the dataentity
       -- Now calculate an array of periods that this data will now need to be loaded into.
    logit.LOG ('Now calculate the periods that this data will be loaded into.');
    v_period_counter := 0;
    v_period_ids.DELETE;
    v_period_codes.DELETE;

    IF rv_extract_request.dataentity = finance_characteristics.gc_chrstc_dataentity_actuals THEN
      -- Use the batch loading period as the period that we will be loading this data into.
      v_return := characteristics.get_chrstc_id (v_chrstc_type_period_id, rv_extract_request.from_period, v_chrstc_period_id, v_return_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Period failed or errored';
        RAISE common.ge_error;
      END IF;

      v_period_counter := v_period_counter + 1;
      v_period_ids (v_period_counter) := v_chrstc_period_id;
      v_period_codes (v_period_counter) := rv_extract_request.from_period;
    ELSE
      -- get the fromperiod and toperiod characteristics

      -- Now iterate though the periods that we are loading data into and allocate the qty per day into the days of the plan we are loading data into.
      -- logit.LOG ('Data Entity : ' || rv_extract_request.dataentity || ' From Period : ' || v_dataentity_fromperiod || ' To Period : ' || v_dataentity_toperiod);
      --      logit.LOG (   'Data Entity : '|| rv_extract_request.dataentity|| ' From Period : '|| rv_extract_request.from_period|| ' To Period : '|| rv_extract_request.to_period);
      v_current_period := rv_extract_request.from_period;
      v_period_counter := 0;
      -- Period collection.
      logit.LOG ('Now create the data entity period collection.');

      LOOP
        -- Now lookup the period characteristic id.
        v_return := characteristics.get_chrstc_id (v_chrstc_type_period_id, v_current_period, v_chrstc_period_id, v_return_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := 'Characteristic lookups for Period failed or errored';
          RAISE common.ge_error;
        END IF;

        v_period_counter := v_period_counter + 1;
        v_period_ids (v_period_counter) := v_chrstc_period_id;
        v_period_codes (v_period_counter) := v_current_period;

        -- Now increment the period counter and see if we can move onto the next period.
        BEGIN
          v_current_period := TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (v_current_period), 1) );
        EXCEPTION
          WHEN OTHERS THEN
            v_processing_msg := 'Failed to increment the current period during the period array processing.';
            RAISE common.ge_error;
        END;

        -- EXIT WHEN v_current_period > v_dataentity_toperiod;
        EXIT WHEN (v_current_period > rv_extract_request.to_period OR v_period_counter > 13);
      END LOOP;
    END IF;

    -- end Create an array of the periods of the dataentity

    -- Lookup the data values.
    logit.LOG ('Now get the data ids.');
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_company_id;
    v_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;
    -- LOOP through the periods for the selected Dataentity,
    v_period_counter := 1;
    v_line_counter := 1;

    LOOP
      -- Get the period number from the period code
      v_period_num := SUBSTR (v_period_codes (v_period_counter), 5, 2);
      -- Update characteristics list for the period
      v_chrstc_ids (4) := v_period_ids (v_period_counter);
      -- assign the extct_fpps period column that will be populated ie P01 to P13
      v_extct_fpps_col := 'P' || v_period_num;
      --v_chrstc_ids (4) := v_chrstc_period_id;
      v_return := data_values.get_data_ids (v_mdl_isct_ppv_comb_id, data_values.gc_data_vlu_status_valid, v_chrstc_ids, v_data_ids, v_return_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Unable to get PPV combined intersect data ids. ' || common.nest_err_msg (v_return_msg);
        RAISE common.ge_error;
      END IF;

      -- Now process each ppv entry.
      logit.LOG ('Now processing each ppv line. ' || v_data_ids.COUNT || ' to process.');
      v_data_counter := 1;

      WHILE v_data_counter <= v_data_ids.COUNT
      LOOP
        -- Get the value.
        v_return := data_values.get_data_vlu (v_data_ids (v_data_counter), v_value, v_top_down, v_revision, v_return_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg :=
               'Unable to perform extract as the data was invalidated or not error occured during fetch of data id : '
            || v_data_ids (v_data_counter)
            || ' '
            || common.nest_err_msg (v_return_msg);
          RAISE common.ge_error;
        END IF;

        -- only do next part if v_value !=0
        IF v_value != 0 THEN
          -- Now perform the processing of this PPV line.
          v_return := common.gc_success;
          v_return := v_return + data_values.get_chrstc_id (v_data_ids (v_data_counter), v_chrstc_type_matl_id, v_chrstc_matl_id, v_return_msg);
          v_return := v_return + characteristics.get_chrstc_code (v_chrstc_matl_id, v_chrstc_matl_code, v_return_msg);
          v_return := v_return + data_values.get_chrstc_id (v_data_ids (v_data_counter), v_chrstc_type_ppv_type_id, v_chrstc_ppv_type_id, v_return_msg);
          v_return := v_return + characteristics.get_chrstc_code (v_chrstc_ppv_type_id, v_chrstc_ppv_type_code, v_return_msg);

          IF v_return != common.gc_success THEN
            v_processing_msg := 'One or more of the characteristic lookups data id ' || v_data_ids (v_data_counter) || ' failed or errored.';
            RAISE common.ge_error;
          END IF;

          -- Now lookup the material type if the material code
          OPEN csr_matl_type;

          FETCH csr_matl_type
          INTO v_matl_type;

          IF csr_matl_type%NOTFOUND THEN
            v_processing_msg := 'Unable to find material type for matl code : ' || v_chrstc_matl_code;
          END IF;

          CLOSE csr_matl_type;

          logit.LOG ('Now process the ppv based on the type.');

          CASE v_chrstc_ppv_type_code
            WHEN bpip_characteristics.gc_chrstc_ppv_type_raws THEN
              v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_RAW');
              v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_DESTINATION_RAW');
              v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_CUSTOMER_RAW');
              v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_RAW');

              IF v_chrstc_matl_code = lads_characteristics.gc_chrstc_na THEN
                v_fpps_code := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_RAW');
                add_line (v_fpps_code, v_value, v_extct_fpps_col);
              ELSE
                allocate_by_production;
              END IF;
            WHEN bpip_characteristics.gc_chrstc_ppv_type_packs THEN
              v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_PACK');
              v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_DESTINATION_PACK');
              v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_CUSTOMER_PACK');
              v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_PACK');

              IF v_chrstc_matl_code = lads_characteristics.gc_chrstc_na THEN
                v_fpps_code := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_PACK');
                add_line (v_fpps_code, v_value, v_extct_fpps_col);
              ELSE
                allocate_by_production;
              END IF;
            WHEN bpip_characteristics.gc_chrstc_ppv_type_cocosub THEN
              v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_DESTINATION_COPACK');
              v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_CUSTOMER_COPACK');

              CASE v_matl_type
                WHEN 'ROH' THEN
                  v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_RAW');
                  v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_RAW');
                WHEN 'VERP' THEN
                  v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_PACK');
                  v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_PACK');
                WHEN 'FERT' THEN
                  v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_FG');
                  v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_FG');
                ELSE
                  v_processing_msg := 'Within PPV Coco Sub Processing Entry material type detected was unknown: ' || v_matl_type || '.';
                  RAISE common.ge_error;
              END CASE;

              IF v_chrstc_matl_code = lads_characteristics.gc_chrstc_na THEN
                v_fpps_code := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_COPACK');
                add_line (v_fpps_code, v_value, v_extct_fpps_col);
              ELSE
                CASE v_matl_type
                  WHEN 'ROH' THEN
                    allocate_by_production;
                  WHEN 'VERP' THEN
                    allocate_by_production;
                  WHEN 'FERT' THEN
                    v_fpps_source :=
                                  reference_functions.lookup_fpps_source (rv_extract_request.company, reference_functions.full_matl_code (v_chrstc_matl_code) );
                    add_line (v_chrstc_matl_code, v_value, v_extct_fpps_col);
                  ELSE
                    v_processing_msg := 'Within PPV Coco Sub Processing Entry material type detected was unknown: ' || v_matl_type || '.';
                    RAISE common.ge_error;
                END CASE;
              END IF;
            WHEN bpip_characteristics.gc_chrstc_ppv_type_3rdparty THEN
              v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_FG');
              v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_DESTINATION_FG');
              v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_CUSTOMER_FG');
              v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_FG');

              IF v_chrstc_matl_code = lads_characteristics.gc_chrstc_na THEN
                v_fpps_code := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_FG');
                add_line (v_fpps_code, v_value, v_extct_fpps_col);
              ELSE
                v_fpps_source := reference_functions.lookup_fpps_source (rv_extract_request.company, reference_functions.full_matl_code (v_chrstc_matl_code) );
                add_line (v_chrstc_matl_code, v_value, v_extct_fpps_col);
              END IF;
            WHEN bpip_characteristics.gc_chrstc_ppv_type_affiliate THEN
              v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_FG');
              v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_DESTINATION_FG');
              v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_CUSTOMER_FG');
              v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_FG');


              IF v_chrstc_matl_code = lads_characteristics.gc_chrstc_na THEN
                v_fpps_code := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_FG');  
                add_line (v_fpps_code, v_value, v_extct_fpps_col);
              ELSE
                v_fpps_source := reference_functions.lookup_fpps_source (rv_extract_request.company, reference_functions.full_matl_code (v_chrstc_matl_code) );
                add_line (v_chrstc_matl_code, v_value, v_extct_fpps_col);
              END IF;
            WHEN bpip_characteristics.gc_chrstc_ppv_type_currency THEN
              v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_SOURCE_CURRENCY');
              v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_DESTINATION_CURRENCY');
              v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_CUSTOMER_CURRENCY');
              v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_LINE_ITEM_CURRENCY');

              -- Send the currency hedge ppv information to the raw materials.
              v_fpps_code := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_CURRENCY');
              add_line (v_fpps_code, v_value, v_extct_fpps_col);
            ELSE
              v_processing_msg := 'Unknown PPV Type Detected.';
              RAISE common.ge_error;
          END CASE;

          COMMIT;
          logit.LOG ('Processed ' || v_data_counter || ' of ' || v_data_ids.COUNT || ' ...');
        --
        END IF;

        v_data_counter := v_data_counter + 1;
      END LOOP;

      -- Increment the period counter.
      v_period_counter := v_period_counter + 1;
      -- Exit loop when we have finished processing all the periods.
      EXIT WHEN (v_period_counter > v_period_ids.COUNT OR v_period_num = '13');
    END LOOP;

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.status = common.gc_loaded
     WHERE a.extct_req_id = i_extract_request_id;

    -- Exit and leave successfully.
    logit.LOG ('Processing Completed.');
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_failed,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error:' || v_result_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to perform ppv extract.') || common.nest_err_msg (common.create_sql_error_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END ppv_extract;

  ---------------------------------------------------------------------------------
  FUNCTION inventory_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- Need to re write to ensure processing correct for selected periods and not just for ACTUALS single period. See inventory_extract
    v_processing_msg             common.st_message_string;
    v_return                     common.st_result;
    v_return_msg                 common.st_message_string;
    v_result_msg                 common.st_message_string;
    v_data_ids                   common.t_ids;
    -- Model Intersect IDS
    v_mdl_isct_clsng_vlu_id      common.st_id;
    v_mdl_isct_prodn_qty_id      common.st_id;
    -- Characteristic Type IDs
    v_chrstc_type_dataentity_id  common.st_id;
    v_chrstc_type_company_id     common.st_id;
    v_chrstc_type_bus_sgmnt_id   common.st_id;
    v_chrstc_type_matl_id        common.st_id;
    v_chrstc_type_plant_id       common.st_id;
    v_chrstc_type_period_id      common.st_id;
    -- Characteristic IDs
    v_chrstc_dataentity_id       common.st_id;
    v_chrstc_period_id           common.st_id;
    v_chrstc_company_id          common.st_id;
    v_chrstc_bus_sgmnt_id        common.st_id;
    v_chrstc_matl_id             common.st_id;
    -- Characteristic Array
    v_chrstc_ids                 common.t_ids;
    -- Charactersitic codes
    v_chrstc_matl_code           common.st_code;
    v_matl_type                  common.st_code;
    -- Other
    v_data_counter               common.st_counter;
    v_value                      common.st_value;
    v_value_pos common.st_value;
    v_value_neg common.st_value;
    v_range common.st_value;
    v_top_down                   common.st_status;
    v_revision                   common.st_count;
    v_line_counter               common.st_count;
    -- Fpps variables.
    v_fpps_code                  common.st_code;
    v_fpps_source                common.st_code;
    v_fpps_destination           common.st_code;
    v_fpps_customer              common.st_code;
    v_fpps_line_item             common.st_code;
    -- Period Array process variable
    v_current_period             common.st_code;
    v_period_ids                 common.t_ids;
    v_period_counter             common.st_counter;
    v_period_codes               common.t_codes;
    v_extct_fpps_col             common.st_code;
    v_period_num                 common.st_code;
    -- Exceptions
    e_event_error                EXCEPTION;   -- event processing error

    CURSOR csr_extract_request IS
      SELECT *
      FROM extct_req
      WHERE extct_req_id = i_extract_request_id;

    rv_extract_request           csr_extract_request%ROWTYPE;

    CURSOR csr_matl_type IS
      SELECT matl_type
      FROM matl
      WHERE matl_code = reference_functions.full_matl_code (v_chrstc_matl_code);

    PROCEDURE add_line (i_fpps_item IN common.st_code, i_value common.st_value, i_period_col IN common.st_code) IS
      v_insert_stmnt  common.st_sql;
      v_col           VARCHAR2 (3);
    BEGIN
      v_insert_stmnt :=
           'INSERT INTO extct_fpps(extct_req_id, line_num, item, source, destination, customer, line_item, currency, data_id,'
        || i_period_col
        || ') VALUES (:i_extract_request_id, :v_line_counter, :i_fpps_item, :v_fpps_source, :v_fpps_destination, :v_fpps_customer, :v_fpps_line_item, ''AUD'', '
        || v_data_ids (v_data_counter)
        || ', :i_value )';

      --logit.LOG ('v_insert_stmnt. i_extract_request_id,v_line_counter : ' || i_extract_request_id || ',' || v_line_counter||' i_period_col : '||i_period_col);
      EXECUTE IMMEDIATE v_insert_stmnt
      USING i_extract_request_id, v_line_counter, i_fpps_item, v_fpps_source, v_fpps_destination, v_fpps_customer, v_fpps_line_item, i_value;

      v_line_counter := v_line_counter + 1;
    END add_line;

    PROCEDURE allocate_by_production IS
      v_where_used            recipe_functions.t_where_used;
      v_prodn_chrstc_ids      common.t_ids;
      v_counter               common.st_counter;
      v_prodn_sum_pos             common.st_value;
      v_prodn_sum_neg             common.st_value;
      v_chrstc_prodn_matl_id  common.st_id;
      v_chrstc_prodn_plant_id  common.st_id;
      v_prodn_data_id         common.st_id;
      v_prodn_value           common.st_value;
      v_prodn_top_down        common.st_status;
      v_prodn_revision        common.st_value;
    BEGIN
      -- Create the where used array.
      v_return :=
         recipe_functions.where_used (rv_extract_request.company, reference_functions.full_matl_code (v_chrstc_matl_code), SYSDATE, false, v_where_used, v_return_msg);

      IF v_return <> common.gc_success THEN
        v_processing_msg := 'Unable to perform where used check on material : ' || v_chrstc_matl_code || '.';
        RAISE common.ge_error;
      END IF;

      -- Now read the production quantities.
      v_prodn_chrstc_ids (1) := v_chrstc_dataentity_id;
      v_prodn_chrstc_ids (2) := v_chrstc_company_id;
      v_prodn_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;
      v_prodn_chrstc_ids (4) := v_chrstc_period_id;
      v_counter := 1;
      v_prodn_sum_pos := 0;
      v_prodn_sum_neg := 0;
      v_value_neg := 0;
      v_value_pos := 0;
      v_range := 0;

      WHILE v_counter <= v_where_used.COUNT
      LOOP
        -- Lookup the finished good characteristic id.
        v_return :=
          characteristics.get_chrstc_id (v_chrstc_type_matl_id,
                                         reference_functions.short_matl_code (v_where_used (v_counter).matl_code),
                                         v_chrstc_prodn_matl_id,
                                         v_return_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg := 'Could not find material characteristic for : ' || reference_functions.short_matl_code (v_where_used (v_counter).matl_code)
                              || '.';
          RAISE common.ge_error;
        END IF;

        v_prodn_chrstc_ids (5) := v_chrstc_prodn_matl_id;
        
        -- Lookup the plant characteristic id.
        v_return :=
          characteristics.get_chrstc_id (v_chrstc_type_plant_id,
                                         v_where_used (v_counter).plant,
                                         v_chrstc_prodn_plant_id,
                                         v_return_msg);

        IF v_return <> common.gc_success THEN
          v_processing_msg := 'Could not find plant characteristic for :  ' ||v_chrstc_type_plant_id||' '||  v_where_used (v_counter).plant || '.';
          RAISE common.ge_error;
        END IF;

        v_prodn_chrstc_ids (6) := v_chrstc_prodn_plant_id;
        
        -- Now lookup the data id.
        v_return := data_values.get_data_id (v_mdl_isct_prodn_qty_id, v_prodn_chrstc_ids, v_prodn_data_id, v_return_msg);

        IF v_return = common.gc_success THEN
          v_return := data_values.get_data_vlu (v_prodn_data_id, v_prodn_value, v_prodn_top_down, v_prodn_revision, v_return_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg := 'Unable to get the production quantity from data id : ' || v_prodn_data_id || '. ' || common.nest_err_msg (v_return_msg);
            RAISE common.ge_error;
          END IF;
          
          v_where_used (v_counter).extra_value1 := v_prodn_value * v_where_used (v_counter).proportion;
          
          if v_where_used (v_counter).extra_value1 < 0 then
            v_prodn_sum_neg := v_prodn_sum_neg + v_where_used (v_counter).extra_value1;
          else
            v_prodn_sum_pos := v_prodn_sum_pos + v_where_used (v_counter).extra_value1;
          end if;
          
        ELSIF v_return = common.gc_failure THEN
          v_where_used (v_counter).extra_value1 := 0;
        ELSE
          v_processing_msg := 'Unable to get the production quantity infromation for ' || v_where_used (v_counter).matl_code || '.';
          RAISE common.ge_error;
        END IF;

        -- Increase the counter.
        v_counter := v_counter + 1;
      END LOOP;

      -- Now perform the value allocation if there was was something produced.
      IF v_prodn_sum_pos > 0 AND v_prodn_sum_neg <= 0 AND v_where_used.COUNT > 0 THEN
        -- Now perform the weighted averaging allocation
        v_counter := 1;
    
        v_range := ABS(v_prodn_sum_neg) + v_prodn_sum_pos;
        v_value_neg := ((ABS(v_prodn_sum_neg)/v_range) * v_value) * -1;
        v_value_pos := (v_value_neg * -1) + v_value; 

        WHILE v_counter <= v_where_used.COUNT
        LOOP
          IF v_where_used (v_counter).extra_value1 > 0 THEN
            v_where_used (v_counter).extra_value2 := (v_value_pos * v_where_used (v_counter).extra_value1) / v_prodn_sum_pos;
          elsif v_where_used (v_counter).extra_value1 < 0 THEN
            v_where_used (v_counter).extra_value2 := (v_value_neg * v_where_used (v_counter).extra_value1) / v_prodn_sum_neg;
          else
            NULL;
          END IF;

          v_counter := v_counter + 1;
        END LOOP;

        -- Now write the values to the extract table.
        v_counter := 1;

        WHILE v_counter <= v_where_used.COUNT
        LOOP
          IF v_where_used (v_counter).extra_value2 IS NOT NULL THEN
            v_fpps_source := reference_functions.lookup_fpps_source (rv_extract_request.company, v_where_used (v_counter).matl_code);
            add_line (reference_functions.short_matl_code (v_where_used (v_counter).matl_code), v_where_used (v_counter).extra_value2, v_extct_fpps_col);
          END IF;

          v_counter := v_counter + 1;
        END LOOP;
      ELSE
        v_fpps_code := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'PPV_ITEM_FG' );
        add_line (v_fpps_code, v_value, v_extct_fpps_col);
      END IF;
    END allocate_by_production;
  --
  BEGIN
    -- Enter the method
    logit.enter_method (pc_package_name, 'INVENTORY_EXTRACT');

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.status = common.gc_loading
     WHERE a.extct_req_id = i_extract_request_id;

    logit.LOG ('Clearing any past extracts.');

    DELETE FROM extct_fpps
          WHERE extct_req_id = i_extract_request_id;

    COMMIT;
    -- Open up the extract request.
    logit.LOG ('Getting extract request details.');

    OPEN csr_extract_request;

    FETCH csr_extract_request
    INTO rv_extract_request;

    IF csr_extract_request%NOTFOUND THEN
      v_processing_msg := 'Unable to find extract request details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_extract_request;

    -- Lookup the search charactersitcs.
    logit.LOG ('Looking up characteristics, Types.');
    v_return := common.gc_success;
    v_return := v_return + characteristics.get_chrstc_type_id (finance_characteristics.gc_chrstc_type_dataentity, v_chrstc_type_dataentity_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_master_data.gc_chrstc_type_company, v_chrstc_type_company_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_bus_sgmnt, v_chrstc_type_bus_sgmnt_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_matl, v_chrstc_type_matl_id, v_return_msg);
    v_return := v_return + characteristics.get_chrstc_type_id (chrstc_mars_date.gc_chrstc_type_period, v_chrstc_type_period_id, v_return_msg);

    /* add plant type retrieval chg#42537*/
    v_return := v_return + characteristics.get_chrstc_type_id (lads_characteristics.gc_chrstc_type_plant, v_chrstc_type_plant_id, v_return_msg);
    
    IF v_return != common.gc_success THEN
      v_processing_msg := 'One or more of the characteristic Type lookups for bpip failed or errored.';
      RAISE common.ge_error;
    END IF;

    -- Get the Model Intersects that we will be saving bpip base information into.
    logit.LOG ('Getting mdl isct set ids.');
    v_return := common.gc_success;
    v_return := v_return + models.get_mdl_isct_set_id (bpip_model.gc_mi_clsng_vlu, v_mdl_isct_clsng_vlu_id, v_return_msg);
    v_return := v_return + models.get_mdl_isct_set_id (bpip_model.gc_mi_prodn_avg, v_mdl_isct_prodn_qty_id, v_return_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := 'Could not find the model intersect for PPV combined totals or production quantity.';
      RAISE common.ge_error;
    END IF;

    -- Lookup the search characteristics.
    logit.LOG ('Now lookup the search characteristics.');
    v_return := common.gc_success;
    v_return := characteristics.get_chrstc_id (v_chrstc_type_dataentity_id, rv_extract_request.dataentity, v_chrstc_dataentity_id, v_return_msg);
    v_return := characteristics.get_chrstc_id (v_chrstc_type_company_id, rv_extract_request.company, v_chrstc_company_id, v_return_msg);
    v_return := characteristics.get_chrstc_id (v_chrstc_type_bus_sgmnt_id, rv_extract_request.bus_sgmnt, v_chrstc_bus_sgmnt_id, v_return_msg);
    v_return := characteristics.get_chrstc_id (v_chrstc_type_period_id, rv_extract_request.from_period, v_chrstc_period_id, v_return_msg);

    -- TODO loop around each fo the from to periods.
    IF v_return != common.gc_success THEN
      v_processing_msg := 'Characteristic search lookups failed or errored';
      RAISE common.ge_error;
    END IF;

    -- create an array of the periods of the dataentity
           -- Now calculate an array of periods that this data will now need to be loaded into.
    logit.LOG ('Now calculate the periods that this data will be loaded into.');
    v_period_counter := 0;
    v_period_ids.DELETE;
    v_period_codes.DELETE;

    IF rv_extract_request.dataentity = finance_characteristics.gc_chrstc_dataentity_actuals THEN
      -- Use the batch loading period as the period that we will be loading this data into.
      v_return := characteristics.get_chrstc_id (v_chrstc_type_period_id, rv_extract_request.from_period, v_chrstc_period_id, v_return_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Characteristic lookups for Period failed or errored';
        RAISE common.ge_error;
      END IF;

      v_period_counter := v_period_counter + 1;
      v_period_ids (v_period_counter) := v_chrstc_period_id;
      v_period_codes (v_period_counter) := rv_extract_request.from_period;
    ELSE
      -- get the fromperiod and toperiod characteristics

      -- Now iterate though the periods that we are loading data into and allocate the qty per day into the days of the plan we are loading data into.
      --logit.LOG (   'Data Entity : '| rv_extract_request.dataentity|| ' From Period : '|| rv_extract_request.from_period|| ' To Period : '|| rv_extract_request.to_period);
      v_current_period := rv_extract_request.from_period;
      v_period_counter := 0;
      -- Period collection.
      logit.LOG ('Now create the data entity period collection.');

      LOOP
        -- Now lookup the period characteristic id.
        v_return := characteristics.get_chrstc_id (v_chrstc_type_period_id, v_current_period, v_chrstc_period_id, v_return_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := 'Characteristic lookups for Period failed or errored';
          RAISE common.ge_error;
        END IF;

        v_period_counter := v_period_counter + 1;
        v_period_ids (v_period_counter) := v_chrstc_period_id;
        v_period_codes (v_period_counter) := v_current_period;

        -- Now increment the period counter and see if we can move onto the next period.
        BEGIN
          v_current_period := TO_CHAR (mars_date_utils.inc_mars_period (TO_NUMBER (v_current_period), 1) );
        EXCEPTION
          WHEN OTHERS THEN
            v_processing_msg := 'Failed to increment the current period during the period array processing.';
            RAISE common.ge_error;
        END;

        -- EXIT WHEN v_current_period > v_dataentity_toperiod;
        EXIT WHEN (v_current_period > rv_extract_request.to_period OR v_period_counter > 13);
      END LOOP;
    END IF;

    -- Lookup the data values.
    logit.LOG ('Now get the data ids.');
    v_chrstc_ids (1) := v_chrstc_dataentity_id;
    v_chrstc_ids (2) := v_chrstc_company_id;
    v_chrstc_ids (3) := v_chrstc_bus_sgmnt_id;
    -- LOOP through the periods for the selected Dataentity,
    v_period_counter := 1;
    v_line_counter := 1;

    LOOP
      -- Get the period number from the period code
      v_period_num := SUBSTR (v_period_codes (v_period_counter), 5, 2);
      -- Update characteristics list for the period
      v_chrstc_ids (4) := v_period_ids (v_period_counter);
      -- assign the extct_fpps period column that will be populated ie P01 to P13
      v_extct_fpps_col := 'P' || v_period_num;
      --v_chrstc_ids (4) := v_chrstc_period_id;
      v_return := data_values.get_data_ids (v_mdl_isct_clsng_vlu_id, data_values.gc_data_vlu_status_valid, v_chrstc_ids, v_data_ids, v_return_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Unable to get CLOSING QTY intersect data ids. ' || common.nest_err_msg (v_return_msg);
        RAISE common.ge_error;
      END IF;

      -- Now process each ppv entry.
      logit.LOG ('Now processing each closing qyt line. ' || v_data_ids.COUNT || ' to process.');
      v_data_counter := 1;

      WHILE v_data_counter <= v_data_ids.COUNT
      LOOP
        -- Now perform the processing of this inventory value line.
        v_return := common.gc_success;
        v_return := v_return + data_values.get_chrstc_id (v_data_ids (v_data_counter), v_chrstc_type_matl_id, v_chrstc_matl_id, v_return_msg);
        v_return := v_return + characteristics.get_chrstc_code (v_chrstc_matl_id, v_chrstc_matl_code, v_return_msg);

        IF v_return != common.gc_success THEN
          v_processing_msg := 'One or more of the characteristic lookups data id ' || v_data_ids (v_data_counter) || ' failed or errored.';
          RAISE common.ge_error;
        END IF;

        -- Now lookup the material type if the material code
        IF v_chrstc_matl_code = lads_characteristics.gc_chrstc_na THEN
          v_matl_type := lads_characteristics.gc_chrstc_na;
        ELSE
          OPEN csr_matl_type;

          FETCH csr_matl_type
          INTO v_matl_type;

          IF csr_matl_type%NOTFOUND THEN
            v_processing_msg := 'Unable to find material type for matl code : ' || v_chrstc_matl_code;
          END IF;

          CLOSE csr_matl_type;
        END IF;

        -- Only process raws and packs.
        IF v_matl_type IN ('ROH', 'VERP') THEN
          -- Get the value.
          v_return := data_values.get_data_vlu (v_data_ids (v_data_counter), v_value, v_top_down, v_revision, v_return_msg);

          IF v_return <> common.gc_success THEN
            v_processing_msg :=
                 'Unable to perform extract as the data was invalidated or an error occured during fetch of data id : '
              || v_data_ids (v_data_counter)
              || ' '
              || common.nest_err_msg (v_return_msg);
            RAISE common.ge_error;
          END IF;

          -- only do next part if v_value !=0
          IF v_value != 0 THEN
            --logit.LOG ('Now process the PPV based on the type.');
            CASE v_matl_type
              WHEN 'ROH' THEN
                v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_SOURCE_RAW');
                v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_LINE_ITEM_RAW');
                v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_DESTINATION_RAW');
                v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_CUSTOMER_RAW');
                allocate_by_production;
              WHEN 'VERP' THEN
                v_fpps_source := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_SOURCE_PACK');
                v_fpps_line_item := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_LINE_ITEM_PACK');
                v_fpps_destination := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_DESTINATION_PACK');
                v_fpps_customer := lookup_fpps_code (rv_extract_request.company, rv_extract_request.bus_sgmnt, 'INV_CUSTOMER_PACK');

                allocate_by_production;
              ELSE
                v_processing_msg := 'Unknown Material Type Detected.';
                RAISE common.ge_error;
            END CASE;
          END IF;
        ELSE
          logit.LOG ('Data ID : ' || v_data_ids (v_data_counter) || ' was a FERT ignoring.');
        END IF;

        COMMIT;
        logit.LOG ('Processed ' || v_data_counter || ' of ' || v_data_ids.COUNT || ' ...');
        v_data_counter := v_data_counter + 1;
      END LOOP;

      -- Increment the period counter.
      v_period_counter := v_period_counter + 1;
      -- Exit loop when we have finished processing all the periods.
      EXIT WHEN (v_period_counter > v_period_ids.COUNT OR v_period_num = '13');
    END LOOP;

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.status = common.gc_loaded
     WHERE a.extct_req_id = i_extract_request_id;

    -- Exit and leave successfully.
    logit.LOG ('Processing Completed.');
    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_failed,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error:' || v_result_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unable to perform inventory extract.') || common.nest_err_msg (common.create_sql_error_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END inventory_extract;

  ---------------------------------------------------------------------------------
  FUNCTION perform_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_date              common.st_code;   -- sysdate, header record.
    v_time              common.st_code;   -- systime, header record.
    v_result_msg        common.st_message_string;
    v_processing_msg    common.st_message_string;
    v_line              common.st_message_string;   -- A line of data to be written to the output file
    v_message           common.st_message_string;   -- standard procedure call support
    v_result            common.st_result;   -- standard procedure call supprt
    v_return            common.st_result;
    v_filename          common.st_name;
    v_prefix            common.st_code;

    -- Main cursor to select the data set from the extct_fpps load table based on the extct_req. extct_req_id value
    CURSOR csr_ppv_data (i_extract_request_id IN common.st_id) IS
      SELECT item AS fpps_item, SOURCE AS fpps_source, destination AS fpps_destination, customer AS fpps_customer, line_item AS fpps_line_item,
        SUM (p01) AS ppv_p01, SUM (p02) AS ppv_p02, SUM (p03) AS ppv_p03, SUM (p04) AS ppv_p04, SUM (p05) AS ppv_p05, SUM (p06) AS ppv_p06,
        SUM (p07) AS ppv_p07, SUM (p08) AS ppv_p08, SUM (p09) AS ppv_p09, SUM (p10) AS ppv_p10, SUM (p11) AS ppv_p11, SUM (p12) AS ppv_p12,
        SUM (p13) AS ppv_p13,
          SUM (NVL (p01, 0) )
        + SUM (NVL (p02, 0) )
        + SUM (NVL (p03, 0) )
        + SUM (NVL (p04, 0) )
        + SUM (NVL (p05, 0) )
        + SUM (NVL (p06, 0) )
        + SUM (NVL (p07, 0) )
        + SUM (NVL (p08, 0) )
        + SUM (NVL (p09, 0) )
        + SUM (NVL (p10, 0) )
        + SUM (NVL (p11, 0) )
        + SUM (NVL (p12, 0) )
        + SUM (NVL (p13, 0) ) AS total_ppv,
        currency
      FROM extct_fpps
      WHERE extct_req_id = i_extract_request_id
      GROUP BY item, SOURCE, destination, customer, line_item, currency;

    rv_ppv_data         csr_ppv_data%ROWTYPE;   -- sales forecast cursor

    CURSOR csr_extract_request IS
      SELECT *
      FROM extct_req
      WHERE extct_req_id = i_extract_request_id;

    rv_extract_request  csr_extract_request%ROWTYPE;
    -- Exceptions
    e_event_error       EXCEPTION;   -- event processing error
    e_file_error        EXCEPTION;   -- exception to deal with file I/O errors.
  BEGIN
    logit.enter_method (pc_package_name, 'PERFORM_EXTRACT');

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.status = common.gc_processing,
           a.error_msg = NULL
     WHERE a.extct_req_id = i_extract_request_id;

    OPEN csr_extract_request;

    FETCH csr_extract_request
    INTO rv_extract_request;

    IF csr_extract_request%NOTFOUND THEN
      v_processing_msg := 'Unable to find extract request details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_extract_request;

    v_return := system_params.get_parameter_text (bpip_system.gc_system_code, pc_system_prefix_code, v_prefix, v_result_msg);
    v_filename :=
         v_prefix
      || '_'
      || SUBSTR (rv_extract_request.extct_type_code, 1, 3)
      || '_'
      || rv_extract_request.company
      || '_'
      || rv_extract_request.bus_sgmnt
      || '_'
      || REPLACE (rv_extract_request.dataentity, ' ', '_')
      || '_'
      || i_extract_request_id
      || '.DAT';
    -- First close the file to make sure, that it's not open.
    v_result := fileit.close_file (v_message);

    --
    IF fileit.open_file (plan_common.gc_planning_directory, v_filename, fileit.gc_file_mode_write, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- setup variables ready to write record head to file.

    -- now build record header
    v_line := v_line || 'FPPS_ITEM';
    v_line := v_line || ',FPPS_SOURCE';
    v_line := v_line || ',FPPS_DESTINATION';
    v_line := v_line || ',FPPS_CUSTOMER';
    v_line := v_line || ',FPPS_LINE_ITEM';
    v_line := v_line || ',PPV_P1';
    v_line := v_line || ',PPV_P2';
    v_line := v_line || ',PPV_P3';
    v_line := v_line || ',PPV_P4';
    v_line := v_line || ',PPV_P5';
    v_line := v_line || ',PPV_P6';
    v_line := v_line || ',PPV_P7';
    v_line := v_line || ',PPV_P8';
    v_line := v_line || ',PPV_P9';
    v_line := v_line || ',PPV_P10';
    v_line := v_line || ',PPV_P11';
    v_line := v_line || ',PPV_P12';
    v_line := v_line || ',PPV_P13';
    v_line := v_line || ',TOTAL_PPV';
    v_line := v_line || ',CURRENCY';

    -- write record header.
    IF fileit.write_file (v_line, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    FOR rv_ppv_data IN csr_ppv_data (i_extract_request_id)   -- loop PPV data to write to file.
    LOOP
      -- Now build the line to be written to file.
      v_line := rv_ppv_data.fpps_item;
      v_line := v_line || ',' || rv_ppv_data.fpps_source;
      v_line := v_line || ',' || rv_ppv_data.fpps_destination;
      v_line := v_line || ',' || rv_ppv_data.fpps_customer;
      v_line := v_line || ',' || rv_ppv_data.fpps_line_item;
      v_line := v_line || ',' || rv_ppv_data.ppv_p01;
      v_line := v_line || ',' || rv_ppv_data.ppv_p02;
      v_line := v_line || ',' || rv_ppv_data.ppv_p03;
      v_line := v_line || ',' || rv_ppv_data.ppv_p04;
      v_line := v_line || ',' || rv_ppv_data.ppv_p05;
      v_line := v_line || ',' || rv_ppv_data.ppv_p06;
      v_line := v_line || ',' || rv_ppv_data.ppv_p07;
      v_line := v_line || ',' || rv_ppv_data.ppv_p08;
      v_line := v_line || ',' || rv_ppv_data.ppv_p09;
      v_line := v_line || ',' || rv_ppv_data.ppv_p10;
      v_line := v_line || ',' || rv_ppv_data.ppv_p11;
      v_line := v_line || ',' || rv_ppv_data.ppv_p12;
      v_line := v_line || ',' || rv_ppv_data.ppv_p13;
      v_line := v_line || ',' || rv_ppv_data.total_ppv;
      v_line := v_line || ',' || rv_ppv_data.currency;

      -- write line to file.
      IF fileit.write_file (v_line, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;
    END LOOP;

    -- Now close the file.
    IF fileit.close_file (v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.extct_outpt_file_name = v_filename,
           a.status = common.gc_pending,   -- Pending a file send.
           a.error_msg = NULL
     WHERE a.extct_req_id = i_extract_request_id;

    COMMIT;
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_file_error THEN
      -- File IO error exception.
      o_result_msg := common.create_failure_msg ('File IO Error:' || v_message);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_event_error THEN
      o_result_msg := common.create_failure_msg ('Event error:' || v_result_msg);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END perform_extract;

  ---------------------------------------------------------------------------------
  FUNCTION send_extract (i_extract_request_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_processing_msg    common.st_message_string;
    v_message           common.st_message_string;
    v_unix_path         common.st_message_string;
    v_filename          common.st_message_string;
    v_target_filename          common.st_message_string;
    v_mq_source_qmgr    common.st_message_string;
    v_mq_target_qmgr    common.st_message_string;
    v_mq_target_path    common.st_message_string;
    v_mq_target_file    common.st_message_string;
    v_return            common.st_result;
    v_result_msg        common.st_message_string;
    v_prefix            common.st_code;
    -- Exceptions
    e_execute_failure   EXCEPTION;   -- unix command execute error
    e_system_parameter  EXCEPTION;   -- failed to get system parameter

    CURSOR csr_extract_request IS
      SELECT *
      FROM extct_req a
      WHERE a.extct_req_id = i_extract_request_id;

    rv_extract_request  csr_extract_request%ROWTYPE;
  BEGIN
    logit.enter_method (pc_package_name, 'SEND_EXTRACT');

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.status = common.gc_processing,
           a.error_msg = NULL
     WHERE a.extct_req_id = i_extract_request_id;

    OPEN csr_extract_request;

    FETCH csr_extract_request
    INTO rv_extract_request;

    IF csr_extract_request%NOTFOUND THEN
      v_processing_msg := 'Unable to find extract request details.';
      RAISE common.ge_error;
    END IF;

    CLOSE csr_extract_request;

    IF system_params.get_parameter_text (plan_common.gc_system_code, plan_common.gc_unix_path_code, v_unix_path, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (bpip_system.gc_system_code, pc_fpps_bpip_source_mq_code, v_mq_source_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (bpip_system.gc_system_code, pc_fpps_bpip_target_mq_code, v_mq_target_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (bpip_system.gc_system_code, pc_fpps_bpip_target_path, v_mq_target_path, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;
    
    v_mq_target_path := REPLACE(v_mq_target_path,'<FPPS_MOE>',lookup_fpps_code(rv_extract_request.company, rv_extract_request.bus_sgmnt,'FPPS_MOE'));
    logit.LOG ('Target Path = ' || v_mq_target_path);


     v_target_filename  :=
         pc_dest_system_prefix_code
      || '_'
      || SUBSTR (rv_extract_request.extct_type_code, 1, 3)
      || '_'
      || rv_extract_request.company
      || '_'
      || rv_extract_request.bus_sgmnt
      || '_'
      || REPLACE (rv_extract_request.dataentity, ' ', '_')
      || '.DAT';
      
    v_filename := v_unix_path || 'oracle/' || rv_extract_request.extct_outpt_file_name;
    
    logit.LOG (   ' v_unix_path : '
               || v_unix_path
               || ' bin/send_mqft_file.sh : '
               || 'bin/send_mqft_file.sh '
               || ' ,v_filename :'
               || v_filename
               || ' ,v_mq_source_qmgr : '
               || v_mq_source_qmgr
               || ' ,v_mq_target_qmgr : '
               || v_mq_target_qmgr
               || ' ,v_mq_target_path and file '
               || v_mq_target_path
               || '/'
               || v_target_filename);

    -- Execute unix command to send file to FPPS Production Server
    IF fileit.execute_command (   v_unix_path
                               || 'bin/send_mqft_file.sh '
                               || v_filename
                               || ' '
                               || v_mq_source_qmgr
                               || ' '
                               || v_mq_target_qmgr
                               || ' '
                               || v_mq_target_path
                               || '/'
                               || v_target_filename,
                               v_message) != common.gc_success THEN
      RAISE e_execute_failure;
    END IF;

    -- Update the EXTCT_REQ table.
    UPDATE extct_req a
       SET a.extct_dest_file_name = rv_extract_request.extct_outpt_file_name,
           a.extct_end = SYSDATE,
           a.status = common.gc_processed,
           a.error_msg = NULL
     WHERE a.extct_req_id = i_extract_request_id;

    RETURN common.gc_success;
  EXCEPTION
    WHEN e_system_parameter THEN
      o_result_msg := common.create_error_msg ('System parameter recall failed. ' || v_message);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN e_execute_failure THEN
      -- UNIX command failed for some reason, maybe no files with specified wildcard were found.
      o_result_msg := common.create_error_msg ('Unix execute errored. ' || v_message);

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      -- unhandled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception. ') || common.create_sql_error_msg ();

      -- Update the EXTCT_REQ table.
      UPDATE extct_req a
         SET a.status = common.gc_errored,
             a.error_msg = o_result_msg
       WHERE a.extct_req_id = i_extract_request_id;

      COMMIT;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END send_extract;

  ---------------------------------------------------------------------------------
  PROCEDURE delete_old_extracts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string) IS
    v_return        common.st_code;
    v_days_history  common.st_value;
    v_result_msg    common.st_message_string;
    v_old_extracts  common.t_ids;   -- array to store list on extracts to delete
    v_counter       common.st_counter;

    -- main cursor list of extacts to delete
    CURSOR csr_extracts (i_days_history common.st_value) IS
      SELECT a.extct_req_id
      FROM extct_req a
      WHERE NVL(a.extct_end,A.REQ_TIME) < SYSDATE - i_days_history;

    rv_extracts     csr_extracts%ROWTYPE;
  BEGIN
    -- Now delete old batches.
    logit.enter_method (pc_package_name, 'DELETE_OLD_EXTRACTS');
    v_return := system_params.get_parameter_value (bpip_system.gc_system_code, pc_param_ext_days_hist_code, v_days_history, v_result_msg);

    IF v_return != common.gc_success THEN
      logit.LOG ('Unable to find parameter, using default.');
      v_days_history := pc_param_ext_default_day_hist;
    END IF;

    -- populate array, find list of extracts to delete.
    OPEN csr_extracts (v_days_history);

    FETCH csr_extracts
    BULK COLLECT INTO v_old_extracts;

    CLOSE csr_extracts;

    logit.LOG ('Now start deleting any old extracts');
    v_counter := 1;

    -- start of main loop, delete extracts stores in array,
    WHILE v_counter <= v_old_extracts.COUNT
    LOOP
      logit.LOG ('Delete extracts:' || TO_CHAR (v_old_extracts (v_counter) ) );
      -- now delete from details tables first
      logit.LOG ('delete from :extct_fpps');

      LOOP
        DELETE FROM extct_fpps
              WHERE extct_req_id = v_old_extracts (v_counter) AND ROWNUM < common.gc_common_commit_point;

        COMMIT;
        EXIT WHEN SQL%ROWCOUNT = 0;
      END LOOP;

      logit.LOG ('delete from :extct_req');

      DELETE FROM extct_req
            WHERE extct_req_id = v_old_extracts (v_counter);

      COMMIT;
      v_counter := v_counter + 1;
    END LOOP;

    logit.LOG ('Finish deletes');
    COMMIT;
    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      ROLLBACK;
      logit.leave_method;
      o_result := common.gc_error;
  END;
END bpip_extracts;

