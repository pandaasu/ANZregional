create or replace 
PACKAGE BODY        report_nz_apollo_supply AS
  -------------------------PACKAGE DECLARATIONS --------------------------------
    -- Package Constants
    -- **Insert the name of your report in pc_package_name
  pc_package_name               CONSTANT common.st_package_name    := 'REPORT_NZ_APOLLO_SUPPLY';
  pc_report_group               CONSTANT common.st_code            := 'DEMAND';
  pc_variable_fcst_id           CONSTANT common.st_code            := 'FCST_ID';

  ------------------------------------------------------------------------------
  PROCEDURE install (o_result OUT common.st_result, o_result_msg OUT common.st_message_string) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
    v_report_name     VARCHAR2 (40);
    v_result_msg      common.st_message_string;
    v_result          common.st_result;
    v_report_grp      VARCHAR2 (40);
  BEGIN
    -- log entry and assign return value
    logit.enter_method (pc_package_name, 'INSTALL');
    o_result := common.gc_success;
    -- This is the report name that report users will see
    v_report_name := 'NZ Apollo Supply Extract';
    -- Insert the name of the report group here.
    v_report_grp := pc_report_group;
    -- Call REPORTING_GUI to inialise package
    v_result := reporting_gui.install_report (v_report_name, pc_package_name, v_report_grp, v_result_msg);

    IF v_result != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_error;
    END IF;

    -- Log entry
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      o_result := common.gc_failure;
      logit.LOG (o_result_msg);
      logit.leave_method;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      o_result := common.gc_error;
      logit.log_error (o_result_msg);
      logit.leave_method;
  END install;

  ------------------------------------------------------------------------------
  FUNCTION setup_report_variables (o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- Variable declarations
    v_processing_msg  common.st_message_string;
    v_result          common.st_result;
    v_result_msg      common.st_message_string;
    v_order           common.st_counter;

    -- Forecast variable
    CURSOR csr_fcst_id IS
      SELECT f.fcst_id,
           f.moe_code
        || ' - '
        || f.forecast_type
        || DECODE (NVL (f.casting_year, 'X'), 'X', '', ' Y' || f.casting_year)
        || DECODE (NVL (f.casting_period, 'X'), 'X', '', ' P' || f.casting_period)
        || DECODE (NVL (f.casting_week, 'X'), 'X', '', ' W' || f.casting_week)
        || DECODE (NVL (f.dataentity_code, 'X'), 'X', '', ' - ' || f.dataentity_code) fcst_descr
      FROM fcst f
      WHERE f.status != demand_forecast.gc_fs_archived
      ORDER BY f.fcst_id DESC;

    rv_fcst_id        csr_fcst_id%ROWTYPE;

  BEGIN
    -- log entry and assign return value
    logit.enter_method (pc_package_name, 'SETUP_REPORT_VARIABLES');
    v_result := common.gc_success;
    logit.LOG ('Settup report variables.');
    v_result :=
      reporting_gui.create_report_variable (pc_variable_fcst_id, reporting_gui.gc_vartype_number, '000', common.gc_true, common.gc_true, 'equals',
                                            v_result_msg);

    IF v_result != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Set up drop down lists
    -- drop down list for forecast
    v_order := 1;

    OPEN csr_fcst_id;

    LOOP
      FETCH csr_fcst_id
      INTO rv_fcst_id;

      EXIT WHEN csr_fcst_id%NOTFOUND;

      IF v_result = common.gc_success THEN
        v_result :=
          reporting_gui.set_report_variable_values (pc_variable_fcst_id,
                                                    rv_fcst_id.fcst_id,
                                                    rv_fcst_id.fcst_id || ' - ' || rv_fcst_id.fcst_descr,
                                                    v_order,
                                                    v_result_msg);

        IF v_result != common.gc_success THEN
          v_processing_msg := common.create_failure_msg ('Whilst setting Forecast variable values.') || ' ' || common.nest_err_msg (v_result_msg);
          RAISE common.ge_failure;
        END IF;

        v_order := v_order + 1;
      END IF;
    END LOOP;

    CLOSE csr_fcst_id;

    COMMIT;
    -- log entry
    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END setup_report_variables;

  ------------------------------------------------------------------------------
  FUNCTION retrieve_report (o_result_msg OUT common.st_message_string, o_sql OUT common.st_sql)
    RETURN common.st_result IS
    -- Variable Declarations
    v_return            common.st_result;
    v_processing_msg    common.st_message_string;
    v_var_retrieve      common.st_sql;
    v_indx              common.st_counter;
    v_result            common.st_result;
    v_result_msg        common.st_message_string;
    v_sql               common.st_sql;
    v_lock              common.st_result;
    v_list_indx         common.st_counter;
    v_where_sql         common.st_sql;
    v_run_id            common.st_id;
    v_sql               common.st_sql;
    v_fcst_id           common.st_id;
    v_dmnd_grp_id       common.st_id;
    v_zrep              common.st_code;
    v_tdu               common.st_code;
    v_from_week         common.st_value;
    v_to_week           common.st_value;
    v_dmnd_grp_sql      common.st_sql;
    v_zrep_sql          common.st_sql;
    v_tdu_sql           common.st_sql;
    v_from_week_sql     common.st_sql;
    v_to_week_sql       common.st_sql;
    v_currency          common.st_code;
    v_multiplier        common.st_code;
    v_data_aggregation  common.st_code;
    v_time_aggregation  common.st_code;
    v_sales_org         common.st_code;
    v_source            common.st_code;
    v_sales_org_sql     common.st_sql;
    v_source_sql        common.st_sql;
    v_acct_assign       common.st_code;
    v_acct_assign_sql   common.st_sql;
    v_demand_type       common.st_code;
    v_demand_type_sql   common.st_sql;
    v_aggregation       common.st_sql;
  BEGIN
    -- Log entry and assign return result
    logit.enter_method (pc_package_name, 'RETRIEVE_REPORT');
    v_result := common.gc_success;
    -- Now fetch back the report variables.
    logit.LOG ('Retrieve Report Variables');
    v_return := reporting_gui.get_report_variable (pc_variable_fcst_id, v_fcst_id, v_result_msg);

    IF common.are_equal (v_return, common.gc_success) = FALSE THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.LOG ('All report values retrieved');
    logit.LOG ('Build up the SQL statement based on the optional variables received');

    logit.LOG ('Now create the base sql when there is no aggregation taking place.');
    o_sql :=
        ' SELECT ' || 
        '   t10.zrep || ''_0086'' as zrep_moe, ' || 
        '   t10.dmnd_grp_code, ' || 
        '   ''NZ'' as location, ' || 
        '   ''SHIP_FOURIER'' as plan_model, ' || 
        '   ''DF_UPLOAD'' as description, ' || 
        '   ''1'' as type, ' || 
        '   ''7D'' as duration,  ' || 
        '   to_char((select min(t0.calendar_date) from mars_date t0 where t0.mars_week = t10.mars_week), ''yyyy/mm/dd'') as start_date, ' || 
        '   t10.qty_in_base_uom ' || 
        ' FROM  ' || 
        ' ( ' || 
        '   SELECT ' || 
        '     t3.dmnd_grp_code, ' || 
        '     t1.zrep, ' || 
        '     t1.mars_week, ' || 
        '     sum(t1.qty_in_base_uom) as qty_in_base_uom ' || 
        '   FROM  ' || 
        '     dmnd_data t1,   ' || 
        '     dmnd_grp_org t2, ' || 
        '     dmnd_grp t3, ' || 
        '     dmnd_acct_assign t4, ' || 
        '     dmnd_grp_type t5 ' || 
        '   WHERE  ' || 
        '     t1.fcst_id = ' || v_fcst_id || ' and t2.sales_org = 149 ' || 
        '     AND t2.dmnd_grp_org_id = t1.dmnd_grp_org_id  ' || 
        '     AND t3.dmnd_grp_id =  t2.dmnd_grp_id   ' || 
        '     AND t4.acct_assign_id = t2.acct_assign_id  ' || 
        '     AND t5.dmnd_grp_type_id = t3.dmnd_grp_type_id ' || 
        '   GROUP BY ' || 
        '     t1.zrep, ' || 
        '     t3.dmnd_grp_code, ' || 
        '     t1.mars_week ' || 
        ' ) t10 ';

    logit.LOG ('SQL for report created');
    logit.LOG (o_sql);
    logit.leave_method;
    RETURN v_result;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := v_processing_msg;
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END retrieve_report;

  ------------------------------------------------------------------------------
  FUNCTION setup_report_options (o_result_msg OUT common.st_message_string)
    RETURN common.st_result IS
    -- Variable declarations
    v_processing_msg    common.st_message_string;
    v_result            common.st_result;
    v_result_msg        common.st_message_string;
    v_lock              common.st_result;
    v_counter           PLS_INTEGER;
    v_run_id            common.st_id;
  BEGIN
    -- log entry and assign return result
    logit.enter_method (pc_package_name, 'SETUP_REPORT_OPTIONS');
    -- Get the report varaibles.
    logit.LOG ('Now setup all the formatting results.');

    -- Format the key figures in the report.
    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'QTY_IN_BASE_UOM', 'Quantity', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_column, 'QTY_IN_BASE_UOM', '#,##0.00', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;
    
    -- Format the key figures in the report.
    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'ZREP_MOE', 'ZREP / Moe', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;
    
    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'DMND_GRP_CODE', 'Demand Group Code', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'LOCATION', 'Location', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'PLAN_MODEL', 'Model', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'DESCRIPTION', 'Description', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'TYPE', 'Type', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'DURATION', 'Duration', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_heading, 'START_DATE', 'Start Date', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;


    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_column, 'START_DATE', 'dd/mm/yyyy', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;    
    

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_display, reporting_gui.gc_display_variables, common.gc_no, v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    v_result := reporting_gui.set_report_options (reporting_gui.gc_opt_type, reporting_gui.gc_type_formatted, 'NZ Apollo Supply Extract', v_result_msg);

    IF v_result <> common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.LOG ('Commiting Report Options.');
    COMMIT;
    logit.LOG ('All report options populated');
    logit.leave_method;
    RETURN v_result;
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
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END setup_report_options;
END report_nz_apollo_supply;