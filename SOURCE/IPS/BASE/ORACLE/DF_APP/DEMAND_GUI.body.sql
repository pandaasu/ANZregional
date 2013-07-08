create or replace 
PACKAGE BODY        demand_gui AS
  -- PACKAGE CONSTANTS ---------------------------------------------------------
  pc_pkg_name             CONSTANT common.st_package_name := 'DEMAND_GUI';
  pc_reference_wait_time  CONSTANT common.st_counter      := 1800;

  -------------------------------------------------------------------------------
  PROCEDURE run_batch (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_refresh IN common.st_status) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
    v_job             PLS_INTEGER;
    v_job_sql         common.st_sql;
  BEGIN
    logit.enter_method (pc_pkg_name, 'RUN_BATCH');
    o_result := common.gc_success;

    IF i_refresh = common.gc_yes THEN
      v_job_sql := 'TRUE';
    ELSE
      v_job_sql := 'FALSE';
    END IF;

    v_job_sql := 'DEMAND_PROCESSING.RUN_BATCH_COMMON(' || v_job_sql || ');';
    dbms_job.submit (v_job, v_job_sql);
    o_result_msg := 'Job submitted';
    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END run_batch;

  PROCEDURE get_dmnd_grp_codes (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_dmnd_grp_codes OUT common.t_ref_cursor) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DMND_GRP_CODES');
    o_result := common.gc_success;

    OPEN o_dmnd_grp_codes FOR
      SELECT a.dmnd_grp_code, a.dmnd_grp_name
      FROM dmnd_grp a
      ORDER BY a.dmnd_grp_code;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_dmnd_grp_codes;

  -------------------------------------------------------------------------------
  PROCEDURE get_file_list (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_file_list OUT common.t_ref_cursor) IS
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_RERUN_FILE_LIST');
    o_result := common.gc_success;

    OPEN o_file_list FOR
      SELECT file_id, file_name, status, loaded_date
      FROM load_file
      ORDER BY file_id DESC;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_file_list;

  -------------------------------------------------------------------------------
  PROCEDURE set_file_status (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_file_id IN common.st_id, i_status IN common.st_code) IS
    v_processing_msg  common.st_message_string;
    e_status          EXCEPTION;
    e_file            EXCEPTION;
    v_count           NUMBER;
  BEGIN
    logit.enter_method (pc_pkg_name, 'SET_FILE_STATUS');
    o_result := common.gc_success;

    IF i_status <> common.gc_loaded AND i_status <> common.gc_ignored THEN
      RAISE e_status;
    END IF;

    /*
    select count(*) into v_count from load_file
     where file_name=i_filename
     and status<>common.gc_processed;

     if v_count<> 1 then
       raise e_file;
     end if;
    */
    UPDATE load_file
       SET status = i_status
     WHERE file_id = i_file_id;

    COMMIT;
    logit.leave_method;
  EXCEPTION
    WHEN e_file THEN
      o_result_msg := 'Filename/status error. Cannot set status';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN e_status THEN
      o_result_msg := 'Status code is invalid';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
      NULL;
  END set_file_status;

  -------------------------------------------------------------------------------
  PROCEDURE get_countries (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_cntry_codes OUT common.t_ref_cursor) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_COUNTRIES');
    o_result := common.gc_success;

    OPEN o_cntry_codes FOR
      SELECT a.cntry_code, a.cntry_name
      FROM dmnd_cntry a
      ORDER BY a.cntry_name;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_countries;

  -------------------------------------------------------------------------------
  PROCEDURE get_dmnd_grp_types (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_dmnd_grp_types OUT common.t_ref_cursor) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DMND_GRP_TYPES');
    o_result := common.gc_success;

    OPEN o_dmnd_grp_types FOR
      SELECT a.dmnd_grp_type_code, a.dmnd_grp_type_name
      FROM dmnd_grp_type a
      ORDER BY a.dmnd_grp_type_name;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_dmnd_grp_types;

  -------------------------------------------------------------------------------
  PROCEDURE get_accnt_assgnmts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_accnt_assnmts OUT common.t_ref_cursor) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_ACC_ASSGNMTS');
    o_result := common.gc_success;

    OPEN o_accnt_assnmts FOR
      SELECT a.acct_assign_code, a.acct_assign_name
      FROM dmnd_acct_assign a
      ORDER BY a.acct_assign_name;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_accnt_assgnmts;

  -------------------------------------------------------------------------------
  PROCEDURE get_dmnd_grp_record (
    o_result              OUT     common.st_result,
    o_result_msg          OUT     common.st_message_string,
    i_dmnd_grp_code       IN      dmnd_grp.dmnd_grp_code%TYPE,
    o_dmnd_grp_name       OUT     dmnd_grp.dmnd_grp_name%TYPE,
    o_cntry_code          OUT     dmnd_cntry.cntry_code%TYPE,
    o_dmnd_grp_type_code  OUT     dmnd_grp_type.dmnd_grp_type_code%TYPE,
    o_dmnd_plng_node      OUT     dmnd_grp.dmnd_plng_node%TYPE,
    o_sply_whse_lst       OUT     dmnd_grp.sply_whse_lst%TYPE) IS
    v_processing_msg  common.st_message_string;
    -- main cursor to retrive all information for given demand group code
    e_demand_group    EXCEPTION;

    CURSOR csr_demand_group (i_dmnd_grp_code IN common.st_code) IS
      SELECT dmnd_grp_name, c.cntry_code, dt.dmnd_grp_type_code, dmnd_plng_node, sply_whse_lst
      FROM dmnd_grp dg, dmnd_cntry c, dmnd_grp_type dt
      WHERE dg.dmnd_grp_code = i_dmnd_grp_code AND dg.dmnd_grp_type_id = dt.dmnd_grp_type_id AND dg.cntry_id = c.cntry_id;

    rv_demand_group   csr_demand_group%ROWTYPE;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DMND_GRP_RECORD');
    o_result := common.gc_success;

    OPEN csr_demand_group (i_dmnd_grp_code);

    FETCH csr_demand_group
    INTO rv_demand_group;

    IF csr_demand_group%NOTFOUND THEN
       --CLOSE csr_demand_group;
      -- RAISE e_demand_group;
      NULL;
    ELSE
      o_dmnd_grp_name := rv_demand_group.dmnd_grp_name;
      o_cntry_code := rv_demand_group.cntry_code;
      o_dmnd_grp_type_code := rv_demand_group.dmnd_grp_type_code;
      o_dmnd_plng_node := rv_demand_group.dmnd_plng_node;
      o_sply_whse_lst := rv_demand_group.sply_whse_lst;
    END IF;

    CLOSE csr_demand_group;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_demand_group THEN
      o_result_msg := 'Demand group Code not found or null';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_dmnd_grp_record;

  -------------------------------------------------------------------------------
  PROCEDURE get_dmnd_grp_orgs (
    o_result         OUT     common.st_result,
    o_result_msg     OUT     common.st_message_string,
    i_dmnd_grp_code  IN      dmnd_grp.dmnd_grp_code%TYPE,
    o_dmnd_grp_org   OUT     common.t_ref_cursor) IS
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DMND_GRP_ORGS');
    o_result := common.gc_success;

    OPEN o_dmnd_grp_org FOR
      SELECT a.dmnd_grp_org_id, a.dmnd_grp_id, a.bus_sgmnt_code, a.source_code, a.sales_org, a.currcy_code, a.distbn_chnl, a.acct_assign_id, a.cust_div,
        a.ship_to_code, a.bill_to_code, a.sold_to_cmpny_code, a.cust_hrrchy_code, a.invc_prty, a.pricing_formula, a.profit_centre, a.ACCOUNT, a.fpps_gsv_line_item,
        a.fpps_qty_line_item, a.fpps_cust, a.fpps_dest, a.fpps_moe, a.mltplr_code, a.mltplr_value
      FROM dmnd_grp_org a, dmnd_acct_assign b, dmnd_grp c
      WHERE a.dmnd_grp_id = c.dmnd_grp_id AND a.acct_assign_id = b.acct_assign_id AND c.dmnd_grp_code = i_dmnd_grp_code
      ORDER BY a.bus_sgmnt_code, a.source_code, a.sales_org;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_dmnd_grp_orgs;

  -------------------------------------------------------------------------------
  PROCEDURE get_dmnd_grp_org_record (
    o_result               OUT     common.st_result,
    o_result_msg           OUT     common.st_message_string,
    i_dmnd_grp_org_id      IN      dmnd_grp_org.dmnd_grp_org_id%TYPE,
    o_bus_sgmnt_code       OUT     dmnd_grp_org.bus_sgmnt_code%TYPE,
    o_source_code          OUT     dmnd_grp_org.source_code%TYPE,
    o_sales_org            OUT     dmnd_grp_org.sales_org%TYPE,
    o_currcy_code          OUT     dmnd_grp_org.currcy_code%TYPE,
    o_distbn_chnl          OUT     dmnd_grp_org.distbn_chnl%TYPE,
    o_acct_assign_code     OUT     dmnd_acct_assign.acct_assign_code%TYPE,
    o_cust_div             OUT     dmnd_grp_org.cust_div%TYPE,
    o_ship_to_code         OUT     dmnd_grp_org.ship_to_code%TYPE,
    o_bill_to_code         OUT     dmnd_grp_org.bill_to_code%TYPE,
    o_sold_to_cmpny_code   OUT     dmnd_grp_org.sold_to_cmpny_code%TYPE,
    o_cust_hrrchy_code     OUT     dmnd_grp_org.cust_hrrchy_code%TYPE,
    o_invc_prty            OUT     dmnd_grp_org.invc_prty%TYPE,
    o_pricing_formula      OUT     dmnd_grp_org.pricing_formula%TYPE,
    o_profit_centre        OUT     dmnd_grp_org.profit_centre%TYPE,
    o_account              OUT     dmnd_grp_org.ACCOUNT%TYPE,
    o_fpps_gsv_line_item   OUT     dmnd_grp_org.fpps_gsv_line_item%TYPE,
    o_fpps_qty_line_item   OUT     dmnd_grp_org.fpps_qty_line_item%TYPE,
    o_fpps_cust            OUT     dmnd_grp_org.fpps_cust%TYPE,
    o_fpps_dest            OUT     dmnd_grp_org.fpps_dest%TYPE,
    o_fpps_moe             OUT     dmnd_grp_org.fpps_moe%TYPE,
    o_pos_frmt_grpng_code  OUT     dmnd_grp_org.pos_frmt_grpng_code%TYPE,
    o_mltplr_code          OUT     dmnd_grp_org.mltplr_code%TYPE,
    o_mltplr_value         OUT     dmnd_grp_org.mltplr_value%TYPE) IS
    e_demand_group       EXCEPTION;

    CURSOR csr_demand_group_org IS
      SELECT a.dmnd_grp_org_id, a.dmnd_grp_id, a.bus_sgmnt_code, a.source_code, a.sales_org, a.currcy_code, a.distbn_chnl, b.acct_assign_code, a.cust_div,
        a.ship_to_code, a.bill_to_code, a.sold_to_cmpny_code, a.cust_hrrchy_code, a.invc_prty, a.pricing_formula, a.profit_centre, a.ACCOUNT, a.fpps_gsv_line_item,
        a.fpps_qty_line_item, a.fpps_cust, a.fpps_dest, a.fpps_moe, a.pos_frmt_grpng_code, a.mltplr_code, a.mltplr_value
      FROM dmnd_grp_org a, dmnd_acct_assign b
      WHERE a.acct_assign_id = b.acct_assign_id AND a.dmnd_grp_org_id = i_dmnd_grp_org_id;

    rv_demand_group_org  csr_demand_group_org%ROWTYPE;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DMND_GRP_ORG_RECORD');
    o_result := common.gc_success;

    OPEN csr_demand_group_org;

    FETCH csr_demand_group_org
    INTO rv_demand_group_org;

    IF csr_demand_group_org%NOTFOUND THEN
      CLOSE csr_demand_group_org;

      RAISE e_demand_group;
    ELSE
      o_bus_sgmnt_code := rv_demand_group_org.bus_sgmnt_code;
      o_source_code := rv_demand_group_org.source_code;
      o_sales_org := rv_demand_group_org.sales_org;
      o_currcy_code := rv_demand_group_org.currcy_code;
      o_distbn_chnl := rv_demand_group_org.distbn_chnl;
      o_acct_assign_code := rv_demand_group_org.acct_assign_code;
      o_cust_div := rv_demand_group_org.cust_div;
      o_ship_to_code := rv_demand_group_org.ship_to_code;
      o_bill_to_code := rv_demand_group_org.bill_to_code;
      o_sold_to_cmpny_code := rv_demand_group_org.sold_to_cmpny_code;
      o_cust_hrrchy_code := rv_demand_group_org.cust_hrrchy_code;
      o_invc_prty := rv_demand_group_org.invc_prty;
      o_pricing_formula := rv_demand_group_org.pricing_formula;
      o_profit_centre := rv_demand_group_org.profit_centre;
      o_account := rv_demand_group_org.ACCOUNT;
      o_fpps_gsv_line_item := rv_demand_group_org.fpps_gsv_line_item;
      o_fpps_qty_line_item := rv_demand_group_org.fpps_qty_line_item;
      o_fpps_cust := rv_demand_group_org.fpps_cust;
      o_fpps_dest := rv_demand_group_org.fpps_dest;
      o_fpps_moe := rv_demand_group_org.fpps_moe;
      o_pos_frmt_grpng_code := rv_demand_group_org.pos_frmt_grpng_code;
      o_mltplr_code := rv_demand_group_org.mltplr_code;
      o_mltplr_value := rv_demand_group_org.mltplr_value;
    END IF;

    CLOSE csr_demand_group_org;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_demand_group THEN
      o_result_msg := 'Demand Group Org not found or null';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_dmnd_grp_org_record;

  -------------------------------------------------------------------------------
  PROCEDURE update_dmnd_grp (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_dmnd_grp_code   IN      dmnd_grp.dmnd_grp_code%TYPE,
    i_dmnd_grp_name   IN      dmnd_grp.dmnd_grp_name%TYPE,
    i_cntry           IN      dmnd_cntry.cntry_code%TYPE,
    i_dmnd_grp_type   IN      dmnd_grp_type.dmnd_grp_type_code%TYPE,
    i_dmnd_plng_node  IN      dmnd_grp.dmnd_plng_node%TYPE,
    i_sply_whse_lst   IN      dmnd_grp.sply_whse_lst%TYPE) IS
    e_demand_planning_node   EXCEPTION;   -- demand planning node to long
    e_supply_warehouse_list  EXCEPTION;   -- supply warehouse to long.
    e_demand_group_code      EXCEPTION;
    e_demand_group_name      EXCEPTION;
    e_demand_grp_type        EXCEPTION;
    e_country                EXCEPTION;
    e_grp_id                 EXCEPTION;

    CURSOR csr_country (i_country_code IN common.st_code) IS
      SELECT *
      FROM dmnd_cntry
      WHERE cntry_code = i_country_code;

    CURSOR csr_demand_grp_type (i_demand_grp_type IN common.st_code) IS
      SELECT *
      FROM dmnd_grp_type
      WHERE dmnd_grp_type_code = i_demand_grp_type;

    CURSOR csr_demand_group (i_demand_group_code IN VARCHAR) IS
      SELECT *
      FROM dmnd_grp
      WHERE dmnd_grp_code = i_demand_group_code;

    rv_demand_grp_type       csr_demand_grp_type%ROWTYPE;
    rv_country               csr_country%ROWTYPE;
    rv_demand_group          csr_demand_group%ROWTYPE;
    v_result_msg             common.st_message_string;
    v_grp_id                 common.st_id;
  BEGIN
    logit.enter_method (pc_pkg_name, 'UPDATE_DMND_GRP');

    IF LENGTH (TRIM (i_sply_whse_lst) ) > 200 THEN
      RAISE e_supply_warehouse_list;
    END IF;

    IF TRIM (i_dmnd_grp_code) IS NULL OR LENGTH (TRIM (i_dmnd_grp_code) ) > 7 THEN
      RAISE e_demand_group_code;
    END IF;

    IF TRIM (i_dmnd_grp_name) IS NULL OR LENGTH (TRIM (i_dmnd_grp_name) ) > 90 THEN
      RAISE e_demand_group_name;
    END IF;

    IF LENGTH (TRIM (i_dmnd_plng_node) ) > 20 THEN
      RAISE e_demand_planning_node;
    END IF;

    OPEN csr_country (TRIM (i_cntry) );

    FETCH csr_country
    INTO rv_country;

    IF csr_country%NOTFOUND THEN
      RAISE e_country;
    END IF;

    OPEN csr_demand_grp_type (TRIM (i_dmnd_grp_type) );

    FETCH csr_demand_grp_type
    INTO rv_demand_grp_type;

    IF csr_demand_grp_type%NOTFOUND THEN
      RAISE e_demand_grp_type;
    END IF;

    OPEN csr_demand_group (TRIM (i_dmnd_grp_code) );

    FETCH csr_demand_group
    INTO rv_demand_group;

    IF csr_demand_group%FOUND THEN
      UPDATE dmnd_grp a
         SET a.dmnd_grp_name = TRIM (i_dmnd_grp_name),
             a.dmnd_plng_node = TRIM (i_dmnd_plng_node),
             a.sply_whse_lst = TRIM (i_sply_whse_lst),
             a.cntry_id = rv_country.cntry_id,
             a.dmnd_grp_type_id = rv_demand_grp_type.dmnd_grp_type_id
       WHERE a.dmnd_grp_id = rv_demand_group.dmnd_grp_id;
    ELSE
      IF demand_object_tracking.get_new_id ('DMND_GRP', 'DMND_GRP_ID', v_grp_id, v_result_msg) != common.gc_success THEN
        RAISE e_grp_id;
      END IF;

      INSERT INTO dmnd_grp
                  (dmnd_grp_id, cntry_id, dmnd_grp_type_id, dmnd_grp_code, dmnd_grp_name, dmnd_plng_node,
                   sply_whse_lst)
           VALUES (v_grp_id, rv_country.cntry_id, rv_demand_grp_type.dmnd_grp_type_id, TRIM (i_dmnd_grp_code), TRIM (i_dmnd_grp_name), TRIM (i_dmnd_plng_node),
                   TRIM (i_sply_whse_lst) );
    END IF;

    CLOSE csr_country;

    CLOSE csr_demand_grp_type;

    CLOSE csr_demand_group;

    COMMIT;
    o_result_msg := common.gc_success_str;
    logit.leave_method ();
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_demand_planning_node THEN
      o_result_msg := common.create_failure_msg ('Demand Planning Node is too long.');
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_supply_warehouse_list THEN
      o_result_msg := common.create_failure_msg ('Supply Warehouse List is too long.');
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_grp_id THEN
      o_result_msg := common.create_failure_msg ('Could not allocate group id :' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_country THEN
      o_result_msg := common.create_failure_msg ('Country Code is Invalid. ') || common.create_params_str ('Country Code X(2):', i_cntry);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_demand_grp_type THEN
      o_result_msg := common.create_failure_msg ('Demand Group Type is Invalid. ')
                      || common.create_params_str ('Demand Group Type Code X(7):', i_dmnd_grp_type);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_demand_group_code THEN
      o_result_msg := common.create_failure_msg ('Demand Group Code is Invalid. ') || common.create_params_str ('Demand Group Code X(7):', i_dmnd_grp_code);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_demand_group_name THEN
      o_result_msg := common.create_failure_msg ('Demand Group Name is Invalid. ') || common.create_params_str ('Demand Group Name X(90):', i_dmnd_grp_name);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled Exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END update_dmnd_grp;

  -------------------------------------------------------------------------------
  PROCEDURE update_dmnd_grp_org (
    o_result               OUT     common.st_result,
    o_result_msg           OUT     common.st_message_string,
    i_dmnd_grp_code        IN      dmnd_grp.dmnd_grp_code%TYPE,
    i_bus_sgmnt_code       IN      dmnd_grp_org.bus_sgmnt_code%TYPE,
    i_source_code          IN      dmnd_grp_org.source_code%TYPE,
    i_sales_org            IN      dmnd_grp_org.sales_org%TYPE,
    i_currcy_code          IN      dmnd_grp_org.currcy_code%TYPE,
    i_distbn_chnl          IN      dmnd_grp_org.distbn_chnl%TYPE,
    i_acct_assign          IN      dmnd_acct_assign.acct_assign_code%TYPE,
    i_cust_div             IN      dmnd_grp_org.cust_div%TYPE,
    i_ship_to_code         IN      dmnd_grp_org.ship_to_code%TYPE,
    i_bill_to_code         IN      dmnd_grp_org.bill_to_code%TYPE,
    i_sold_to_cmpny_code   IN      dmnd_grp_org.sold_to_cmpny_code%TYPE,
    i_cust_hrrchy_code     IN      dmnd_grp_org.cust_hrrchy_code%TYPE,
    i_pricing_formula      IN      dmnd_grp_org.pricing_formula%TYPE,
    i_profit_centre        IN      dmnd_grp_org.profit_centre%TYPE,
    i_account              IN      dmnd_grp_org.ACCOUNT%TYPE,
    i_fpps_gsv_line_item   IN      dmnd_grp_org.fpps_gsv_line_item%TYPE,
    i_fpps_qty_line_item   IN      dmnd_grp_org.fpps_qty_line_item%TYPE,
    i_fpps_cust            IN      dmnd_grp_org.fpps_cust%TYPE,
    i_fpps_dest            IN      dmnd_grp_org.fpps_dest%TYPE,
    i_invc_prty            IN      dmnd_grp_org.invc_prty%TYPE,
    i_fpps_moe             IN      dmnd_grp_org.fpps_moe%TYPE,
    i_pos_frmt_grpng_code  IN      dmnd_grp_org.pos_frmt_grpng_code%TYPE,
    i_mltplr_code          IN      dmnd_grp_org.mltplr_code%TYPE,
    i_mltplr_value         IN      dmnd_grp_org.mltplr_value%TYPE) IS
    CURSOR csr_acct_assignment (i_acct_assignment_code IN common.st_code) IS
      SELECT *
      FROM dmnd_acct_assign
      WHERE acct_assign_code = i_acct_assignment_code;

    CURSOR csr_demand_group (i_demand_group_code IN VARCHAR) IS
      SELECT *
      FROM dmnd_grp
      WHERE dmnd_grp_code = i_demand_group_code;

    CURSOR csr_demand_group_org (
      i_demand_grp_id       common.st_id,
      i_source_code     IN  VARCHAR,
      i_sales_org       IN  VARCHAR,
      i_bus_sgmnt_code  IN  VARCHAR,
      i_mltplr_code     IN  VARCHAR2) IS
      SELECT *
      FROM dmnd_grp_org
      WHERE dmnd_grp_id = i_demand_grp_id AND
       source_code = i_source_code AND
       sales_org = i_sales_org AND
       bus_sgmnt_code = i_bus_sgmnt_code AND
       mltplr_code = i_mltplr_code;

    rv_acct_assignment      csr_acct_assignment%ROWTYPE;
    rv_demand_group         csr_demand_group%ROWTYPE;
    rv_demand_group_org     csr_demand_group_org%ROWTYPE;
    e_inv_party             EXCEPTION;
    e_customer_division     EXCEPTION;
    e_distribution_channel  EXCEPTION;
    e_sales_org             EXCEPTION;
    e_pricing_formula       EXCEPTION;   -- pricing formula blank or to long
    e_profit_centre         EXCEPTION;
    e_account               EXCEPTION;
    e_source_code           EXCEPTION;
    e_acct_assignment       EXCEPTION;
    e_currency_code         EXCEPTION;
    e_bill_to_code          EXCEPTION;
    e_ship_to_code          EXCEPTION;
    e_sold_company_code     EXCEPTION;
    e_cust_hrrchy_code      EXCEPTION;
    e_demand_code           EXCEPTION;
    e_grp_org_id            EXCEPTION;
    e_fpps                  EXCEPTION;
    e_fpps_moe              EXCEPTION;
    e_bus_sgmnt_code        EXCEPTION;
    e_pos_frmt_grpng_code   EXCEPTION;
    e_mltplr_code           EXCEPTION;
    e_mltplr_value          EXCEPTION;
    v_result_msg            common.st_message_string;
    v_grp_org_id            common.st_id;
  BEGIN
    logit.enter_method (pc_pkg_name, 'ADD_DEMAND_GROUP_ORG');
    logit.LOG ('Add demand group org:' || i_dmnd_grp_code);

    IF LENGTH (TRIM (i_source_code) ) > 20 OR TRIM (i_source_code) IS NULL THEN
      RAISE e_source_code;
    END IF;

    IF TRIM (i_dmnd_grp_code) IS NULL OR LENGTH (TRIM (i_dmnd_grp_code) ) > 10 THEN
      RAISE e_demand_code;
    END IF;

    IF TRIM (i_sales_org) IS NULL OR LENGTH (TRIM (i_sales_org) ) > 3 THEN
      RAISE e_sales_org;
    END IF;

    IF TRIM (i_bus_sgmnt_code) IS NULL OR LENGTH (TRIM (i_bus_sgmnt_code) ) > 2 THEN
      RAISE e_bus_sgmnt_code;
    END IF;

    IF TRIM (i_currcy_code) IS NULL OR LENGTH (TRIM (i_currcy_code) ) > 3 THEN
      RAISE e_currency_code;
    END IF;

    IF TRIM (i_distbn_chnl) IS NULL OR LENGTH (TRIM (i_distbn_chnl) ) > 2 THEN
      RAISE e_distribution_channel;
    END IF;

    IF LENGTH (TRIM (i_cust_div) ) > 20 OR TRIM (i_cust_div) IS NULL THEN
      RAISE e_customer_division;
    END IF;

    IF LENGTH (TRIM (i_bill_to_code) ) > 10 THEN
      RAISE e_customer_division;
    END IF;

    IF LENGTH (TRIM (i_ship_to_code) ) > 10 THEN
      RAISE e_customer_division;
    END IF;
    
    IF LENGTH (TRIM (i_cust_hrrchy_code) ) > 10 THEN
        RAISE e_cust_hrrchy_code;
    END IF;

    IF LENGTH (TRIM (i_pricing_formula) ) > 100 THEN
      RAISE e_pricing_formula;
    END IF;

    IF LENGTH (TRIM (i_sold_to_cmpny_code) ) > 10 THEN
      RAISE e_sold_company_code;
    END IF;

    IF TRIM (i_profit_centre) IS NULL OR LENGTH (TRIM (i_profit_centre) ) > 6 THEN
      RAISE e_profit_centre;
    END IF;

    IF TRIM (i_account) IS NULL OR LENGTH (TRIM (i_account) ) > 6 THEN
      RAISE e_account;
    END IF;

    IF LENGTH (TRIM (i_fpps_gsv_line_item) ) > 20 THEN
      RAISE e_fpps;
    END IF;

    IF LENGTH (TRIM (i_fpps_qty_line_item) ) > 20 THEN
      RAISE e_fpps;
    END IF;

    IF LENGTH (TRIM (i_fpps_cust) ) > 20 THEN
      RAISE e_fpps;
    END IF;

    IF LENGTH (TRIM (i_fpps_dest) ) > 20 THEN
      RAISE e_fpps;
    END IF;

    IF LENGTH (TRIM (i_invc_prty) ) > 20 THEN
      RAISE e_inv_party;
    END IF;

    IF LENGTH (TRIM (i_fpps_moe) ) > 20 THEN
      RAISE e_fpps_moe;
    END IF;

    IF LENGTH (TRIM (i_pos_frmt_grpng_code) ) > 30 THEN
      RAISE e_pos_frmt_grpng_code;
    END IF;

    IF LENGTH (TRIM (i_mltplr_code) ) > 20 OR TRIM (i_mltplr_code) IS NULL THEN
      RAISE e_mltplr_code;
    END IF;

    IF LENGTH (TRIM (i_mltplr_value) ) > 20 OR TRIM (i_mltplr_value) IS NULL THEN
      RAISE e_mltplr_value;
    END IF;

    OPEN csr_acct_assignment (TRIM (i_acct_assign) );

    FETCH csr_acct_assignment
    INTO rv_acct_assignment;

    logit.LOG ('rv_acct_assignment.id' || TO_CHAR (rv_acct_assignment.acct_assign_id) );

    IF csr_acct_assignment%NOTFOUND THEN
      RAISE e_acct_assignment;
    END IF;

    CLOSE csr_acct_assignment;

    OPEN csr_demand_group (TRIM (i_dmnd_grp_code) );

    FETCH csr_demand_group
    INTO rv_demand_group;

    IF csr_demand_group%NOTFOUND THEN
      RAISE e_demand_code;
    END IF;

    CLOSE csr_demand_group;

    OPEN csr_demand_group_org (rv_demand_group.dmnd_grp_id, TRIM (i_source_code), TRIM (i_sales_org), TRIM (i_bus_sgmnt_code), TRIM (i_mltplr_code) );

    FETCH csr_demand_group_org
    INTO rv_demand_group_org;

    IF csr_demand_group_org%FOUND THEN
      UPDATE dmnd_grp_org
         SET distbn_chnl = TRIM (i_distbn_chnl),
             bus_sgmnt_code = TRIM (i_bus_sgmnt_code),
             source_code = TRIM (i_source_code),
             sales_org = TRIM (i_sales_org),
             bill_to_code = TRIM (i_bill_to_code),
             ship_to_code = TRIM (i_ship_to_code),
             sold_to_cmpny_code = TRIM (i_sold_to_cmpny_code),
             cust_hrrchy_code = TRIM (i_cust_hrrchy_code),
             profit_centre = TRIM (i_profit_centre),
             ACCOUNT = TRIM (i_account),
             pricing_formula = TRIM (i_pricing_formula),
             acct_assign_id = rv_acct_assignment.acct_assign_id,
             cust_div = TRIM (i_cust_div),
             fpps_gsv_line_item = TRIM (i_fpps_gsv_line_item),
             fpps_qty_line_item = TRIM (i_fpps_qty_line_item),
             fpps_cust = TRIM (i_fpps_cust),
             fpps_dest = TRIM (i_fpps_dest),
             invc_prty = TRIM (i_invc_prty),
             fpps_moe = TRIM (i_fpps_moe),
             currcy_code = TRIM (i_currcy_code),
             pos_frmt_grpng_code = TRIM (i_pos_frmt_grpng_code),
             mltplr_code = TRIM (i_mltplr_code),
             mltplr_value = i_mltplr_value
       WHERE dmnd_grp_org_id = rv_demand_group_org.dmnd_grp_org_id;
    ELSE
      IF demand_object_tracking.get_new_id ('DMND_GRP_ORG', 'DMND_GRP_ORG_ID', v_grp_org_id, v_result_msg) != common.gc_success THEN
        RAISE e_grp_org_id;
      END IF;

      INSERT INTO dmnd_grp_org
                  (dmnd_grp_id, dmnd_grp_org_id, source_code, bus_sgmnt_code, acct_assign_id,
                   sales_org, distbn_chnl, bill_to_code, ship_to_code, sold_to_cmpny_code, cust_hrrchy_code, profit_centre,
                   ACCOUNT, pricing_formula, cust_div, fpps_gsv_line_item, fpps_qty_line_item, fpps_cust,
                   fpps_dest, invc_prty, fpps_moe, currcy_code, pos_frmt_grpng_code, mltplr_code,
                   mltplr_value)
           VALUES (rv_demand_group.dmnd_grp_id, v_grp_org_id, TRIM (i_source_code), TRIM (i_bus_sgmnt_code), rv_acct_assignment.acct_assign_id,
                   TRIM (i_sales_org), TRIM (i_distbn_chnl), TRIM (i_bill_to_code), TRIM (i_ship_to_code), TRIM (i_sold_to_cmpny_code), 
                   TRIM (i_cust_hrrchy_code), TRIM (i_profit_centre), TRIM (i_account), TRIM (i_pricing_formula), TRIM (i_cust_div), 
                   TRIM (i_fpps_gsv_line_item), TRIM (i_fpps_qty_line_item), TRIM (i_fpps_cust), TRIM (i_fpps_dest), TRIM (i_invc_prty), 
                   TRIM (i_fpps_moe), TRIM (i_currcy_code), TRIM (i_pos_frmt_grpng_code), TRIM (i_mltplr_code),
                   i_mltplr_value);
    END IF;

    CLOSE csr_demand_group_org;

    COMMIT;
    o_result_msg := common.gc_success_str;
    logit.leave_method ();
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_bus_sgmnt_code THEN
      o_result_msg := common.create_failure_msg ('Business Segment Code is too long or null ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_inv_party THEN
      o_result_msg := common.create_failure_msg ('Invoicing Party is too long ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_fpps THEN
      o_result_msg := common.create_failure_msg ('FPPS Line Item/Customer Code is too long ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_grp_org_id THEN
      o_result_msg := common.create_failure_msg ('Failed to allocate demand_grp_org id. ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_demand_code THEN
      o_result_msg := common.create_failure_msg ('Demand Group is invalid, null or not found' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_sold_company_code THEN
      o_result_msg := common.create_failure_msg ('Sold to Company code is too long' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_bill_to_code THEN
      o_result_msg := common.create_failure_msg ('Bill to code too long' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_ship_to_code THEN
      o_result_msg := common.create_failure_msg ('Ship To Code is too long' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_cust_hrrchy_code THEN
      o_result_msg := common.create_failure_msg ('Customer hierarchy code is too long' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_pricing_formula THEN
      o_result_msg := common.create_failure_msg ('Pricing Formula is too long or null' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_currency_code THEN
      o_result_msg := common.create_failure_msg ('Currency code is too long or null' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_source_code THEN
      o_result_msg := common.create_failure_msg ('Source code too long or null' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_customer_division THEN
      o_result_msg := common.create_failure_msg ('Customer Division is too long or null' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_acct_assignment THEN
      o_result_msg := common.create_failure_msg ('Account Assignment is Invalid ') || common.create_params_str ('Account Assignment X(3):', i_acct_assign);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_sales_org THEN
      o_result_msg := common.create_failure_msg ('Sales Org is Invalid ') || common.create_params_str ('Sales org X(3):', i_sales_org);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_distribution_channel THEN
      o_result_msg := common.create_failure_msg ('Distribution Channel is Invalid ') || common.create_params_str ('Distribution Channel X(2):', i_distbn_chnl);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_profit_centre THEN
      o_result_msg := common.create_failure_msg ('Profit Centre is Invalid ') || common.create_params_str ('Profit Centre X(6):', i_profit_centre);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_account THEN
      o_result_msg := common.create_failure_msg ('Account is Invalid ') || common.create_params_str ('Account X(6):', i_account);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_pos_frmt_grpng_code THEN
      o_result_msg := common.create_failure_msg ('Pos Format Grouping is Invalid ') || common.create_params_str ('Account X(6):', i_account);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_mltplr_code THEN
      o_result_msg := common.create_failure_msg ('Multiplier Code is Invalid ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_mltplr_value THEN
      o_result_msg := common.create_failure_msg ('Multiplier Value is Invalid ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled Exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END update_dmnd_grp_org;

  -------------------------------------------------------------------------------
  PROCEDURE delete_dmnd_grp (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_dmnd_grp_code IN dmnd_grp.dmnd_grp_code%TYPE) IS
    v_result_msg              common.st_message_string;

    CURSOR csr_demand_group (i_demand_group_code IN VARCHAR) IS
      SELECT *
      FROM dmnd_grp
      WHERE dmnd_grp_code = i_demand_group_code;

    CURSOR csr_demand_group_org (i_demand_grp_id common.st_id) IS
      SELECT *
      FROM dmnd_grp_org
      WHERE dmnd_grp_id = i_demand_grp_id;

    rv_demand_group           csr_demand_group%ROWTYPE;
    rv_demand_group_org       csr_demand_group_org%ROWTYPE;
    e_demand_code             EXCEPTION;
    e_demand_group_org_found  EXCEPTION;
  BEGIN
    logit.enter_method (pc_pkg_name, 'DELETE_DEMAND_GROUP');
    logit.LOG ('Delete demand group :' || i_dmnd_grp_code);

    IF TRIM (i_dmnd_grp_code) IS NULL OR LENGTH (TRIM (i_dmnd_grp_code) ) > 10 THEN
      RAISE e_demand_code;
    END IF;

    OPEN csr_demand_group (TRIM (i_dmnd_grp_code) );

    FETCH csr_demand_group
    INTO rv_demand_group;

    IF csr_demand_group%NOTFOUND THEN
      RAISE e_demand_code;
    END IF;

    CLOSE csr_demand_group;

    OPEN csr_demand_group_org (rv_demand_group.dmnd_grp_id);

    FETCH csr_demand_group_org
    INTO rv_demand_group_org;

    IF csr_demand_group_org%FOUND THEN
      RAISE e_demand_group_org_found;
    END IF;

    CLOSE csr_demand_group_org;

    -- Now delete the demand group.
    DELETE FROM dmnd_grp
          WHERE dmnd_grp_id = rv_demand_group.dmnd_grp_id;

    COMMIT;
    o_result_msg := common.gc_success_str;
    logit.leave_method ();
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_demand_code THEN
      o_result_msg := common.create_failure_msg ('Demand Group is invalid null or not found' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_demand_group_org_found THEN
      o_result_msg := common.create_failure_msg ('Demand Group could not be deleted, delete Demand Group Orgs first ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END delete_dmnd_grp;

  -------------------------------------------------------------------------------
  PROCEDURE delete_dmnd_grp_org (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_dmnd_grp_code   IN      dmnd_grp.dmnd_grp_code%TYPE,
    i_bus_sgmnt_code  IN      dmnd_grp_org.bus_sgmnt_code%TYPE,
    i_source_code     IN      dmnd_grp_org.source_code%TYPE,
    i_sales_org       IN      dmnd_grp_org.sales_org%TYPE,
    i_mltplr_code     IN      dmnd_grp_org.mltplr_code%TYPE) IS
    v_result_msg                  common.st_message_string;

    CURSOR csr_demand_group (i_demand_group_code IN VARCHAR) IS
      SELECT *
      FROM dmnd_grp
      WHERE dmnd_grp_code = i_demand_group_code;

    CURSOR csr_demand_group_org (
      i_demand_grp_id       common.st_id,
      i_source_code     IN  VARCHAR,
      i_sales_org       IN  VARCHAR,
      i_bus_sgmnt_code  IN  VARCHAR,
      i_mltplr_code     IN  VARCHAR2) IS
      SELECT *
      FROM dmnd_grp_org
      WHERE dmnd_grp_id = i_demand_grp_id AND
       source_code = i_source_code AND
       sales_org = i_sales_org AND
       bus_sgmnt_code = i_bus_sgmnt_code AND
       mltplr_code = i_mltplr_code;

    rv_demand_group               csr_demand_group%ROWTYPE;
    rv_demand_group_org           csr_demand_group_org%ROWTYPE;
    e_sales_org                   EXCEPTION;
    e_source_code                 EXCEPTION;
    e_demand_code                 EXCEPTION;
    e_grp_org_id                  EXCEPTION;
    e_bus_sgmnt_code              EXCEPTION;
    e_demand_group_org_not_found  EXCEPTION;
  BEGIN
    logit.enter_method (pc_pkg_name, 'DELETE_DEMAND_GROUP_ORG');
    logit.LOG ('Delete demand group org:' || i_dmnd_grp_code);

    IF LENGTH (TRIM (i_source_code) ) > 20 OR TRIM (i_source_code) IS NULL THEN
      RAISE e_source_code;
    END IF;

    IF TRIM (i_dmnd_grp_code) IS NULL OR LENGTH (TRIM (i_dmnd_grp_code) ) > 10 THEN
      RAISE e_demand_code;
    END IF;

    IF TRIM (i_sales_org) IS NULL OR LENGTH (TRIM (i_sales_org) ) > 3 THEN
      RAISE e_sales_org;
    END IF;

    IF TRIM (i_bus_sgmnt_code) IS NULL OR LENGTH (TRIM (i_bus_sgmnt_code) ) > 2 THEN
      RAISE e_bus_sgmnt_code;
    END IF;

    OPEN csr_demand_group (TRIM (i_dmnd_grp_code) );

    FETCH csr_demand_group
    INTO rv_demand_group;

    IF csr_demand_group%NOTFOUND THEN
      RAISE e_demand_code;
    END IF;

    CLOSE csr_demand_group;

    OPEN csr_demand_group_org (rv_demand_group.dmnd_grp_id, TRIM (i_source_code), TRIM (i_sales_org), TRIM (i_bus_sgmnt_code), TRIM (i_mltplr_code) );

    FETCH csr_demand_group_org
    INTO rv_demand_group_org;

    IF csr_demand_group_org%FOUND THEN
      DELETE FROM dmnd_grp_org
            WHERE dmnd_grp_org_id = rv_demand_group_org.dmnd_grp_org_id;
    ELSE
      RAISE e_demand_group_org_not_found;
    END IF;

    CLOSE csr_demand_group_org;

    COMMIT;
    o_result_msg := common.gc_success_str;
    logit.leave_method ();
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_bus_sgmnt_code THEN
      o_result_msg := common.create_failure_msg ('Business Segment code is too long or null ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_grp_org_id THEN
      o_result_msg := common.create_failure_msg ('Failed to allocate demand_grp_org id. ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_demand_code THEN
      o_result_msg := common.create_failure_msg ('Demand Group is invalid, null or not found' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_source_code THEN
      o_result_msg := common.create_failure_msg ('Source code is too long or null' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_demand_group_org_not_found THEN
      o_result_msg := common.create_failure_msg ('Demand Group Org was not found, and could not be deleted ' || v_result_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN e_sales_org THEN
      o_result_msg := common.create_failure_msg ('Sales Org is invalid ') || common.create_params_str ('Sales org X(3):', i_sales_org);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END delete_dmnd_grp_org;

  -------------------------------------------------------------------------------
  PROCEDURE get_forecasts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_forecasts OUT common.t_ref_cursor) IS
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_FORECASTS');
    o_result := common.gc_success;

    OPEN o_forecasts FOR
      SELECT f.fcst_id,
           f.moe_code
        || ' - '
        || f.forecast_type
        || DECODE (NVL (f.casting_year, 'X'), 'X', '', ' Y' || f.casting_year)
        || DECODE (NVL (f.casting_period, 'X'), 'X', '', ' P' || f.casting_period)
        || DECODE (NVL (f.casting_week, 'X'), 'X', '', ' W' || f.casting_week)
        || DECODE (NVL (f.dataentity_code, 'X'), 'X', '', ' - ' || f.dataentity_code) AS fcst_description,
        f.forecast_type AS fcst_type
      FROM fcst f
      ORDER BY f.fcst_id DESC;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_forecasts;

  PROCEDURE get_draft_forecasts (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_forecasts OUT common.t_ref_cursor) IS
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DRAFT_FORECASTS');
    o_result := common.gc_success;

    OPEN o_forecasts FOR
      SELECT f.fcst_id,
           f.moe_code
        || ' - '
        || f.forecast_type
        || DECODE (NVL (f.casting_year, 'X'), 'X', '', ' Y' || f.casting_year)
        || DECODE (NVL (f.casting_period, 'X'), 'X', '', ' P' || f.casting_period)
        || DECODE (NVL (f.casting_week, 'X'), 'X', '', ' W' || f.casting_week)
        || DECODE (NVL (f.dataentity_code, 'X'), 'X', '', ' - ' || f.dataentity_code) AS fcst_description,
        f.forecast_type AS fcst_type
      FROM fcst f where f.forecast_type = demand_forecast.gc_ft_draft
      ORDER BY f.fcst_id DESC;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_draft_forecasts;


  -------------------------------------------------------------------------------
  PROCEDURE get_forecast_record (
    o_result           OUT     common.st_result,
    o_result_msg       OUT     common.st_message_string,
    i_fcst_id          IN      common.st_id,
    o_last_updated     OUT     fcst.last_updated%TYPE,
    o_forecast_type    OUT     fcst.forecast_type%TYPE,
    o_srce_fcst_id     OUT     fcst.srce_fcst_id%TYPE,
    o_dataentity_code  OUT     fcst.dataentity_code%TYPE,
    o_period           OUT     common.st_code,
    o_status           OUT     fcst.status%TYPE,
    o_end_year_period  OUT     common.st_code,
    o_moe              OUT     common.st_code) IS
    e_fcst   EXCEPTION;

    CURSOR csr_fcst IS
      SELECT a.fcst_id, a.casting_year || a.casting_period || a.casting_week period, a.dataentity_code, a.forecast_type, a.last_updated, a.srce_fcst_id,
        DECODE (a.status, 'I', 'Invalid', 'V', 'Valid', 'A', 'Archived', 'U', 'Unarchived', a.status) status, a.end_year || a.end_period end_year_period,
        a.moe_code
      FROM fcst a
      WHERE a.fcst_id = i_fcst_id;

    rv_fcst  csr_fcst%ROWTYPE;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_FORECAST_RECORD');
    o_result := common.gc_success;

    OPEN csr_fcst;

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%NOTFOUND THEN
      CLOSE csr_fcst;

      RAISE e_fcst;
    ELSE
      o_last_updated := rv_fcst.last_updated;
      o_forecast_type := rv_fcst.forecast_type;
      o_srce_fcst_id := rv_fcst.srce_fcst_id;
      o_dataentity_code := rv_fcst.dataentity_code;
      o_period := rv_fcst.period;
      o_status := rv_fcst.status;
      o_end_year_period := rv_fcst.end_year_period;
      o_moe := rv_fcst.moe_code;
    END IF;

    CLOSE csr_fcst;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_fcst THEN
      o_result_msg := 'Forecast id not found or null';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_forecast_record;

  -------------------------------------------------------------------------------
  PROCEDURE get_data_entites (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_data_entites OUT common.t_ref_cursor) IS
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DATA_ENTITES');
    o_result := common.gc_success;

    OPEN o_data_entites FOR
      SELECT chrstc_code AS data_entity
      FROM chrstc t1, chrstc_type t2
      WHERE t2.chrstc_type_code = 'DATAENTITY' AND t1.chrstc_type_id = t2.chrstc_type_id AND t1.status = 'V'
      ORDER BY chrstc_code DESC;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_data_entites;

  -------------------------------------------------------------------------------
  PROCEDURE copy_forecast (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_fcst_id         IN      common.st_id,
    i_dest_fcst_type  IN      common.st_code,
    i_period_from     IN      common.st_code,
    i_period_to       IN      common.st_code,
    i_data_entity     IN      common.st_code) IS
    v_result_msg      common.st_message_string;
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    e_fcst            EXCEPTION;
    e_event_error     EXCEPTION;

    CURSOR csr_fcst IS
      SELECT a.fcst_id, a.casting_year || a.casting_period || a.casting_week period, a.dataentity_code, a.forecast_type, a.last_updated, a.srce_fcst_id,
        a.status
      FROM fcst a
      WHERE a.fcst_id = i_fcst_id;

    rv_fcst           csr_fcst%ROWTYPE;
  BEGIN
    logit.enter_method (pc_pkg_name, 'COPY_FORECAST');
    o_result := common.gc_success;

    OPEN csr_fcst;

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%NOTFOUND THEN
      CLOSE csr_fcst;

      RAISE e_fcst;
    ELSE
      v_return := demand_forecast.copy_forecast (i_fcst_id, i_dest_fcst_type, i_data_entity, i_period_from, i_period_to, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      -- tigger events
      IF eventit.trigger_events (v_result_msg) != common.gc_success THEN
        RAISE e_event_error;
      END IF;
    END IF;

    CLOSE csr_fcst;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_event_error THEN
      o_result_msg := 'Event creation error.' || v_result_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN e_fcst THEN
      o_result_msg := 'Forecast id not found or null';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END copy_forecast;

  PROCEDURE copy_draft_forecast (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_fcst_id         IN      common.st_id) IS
    v_result_msg      common.st_message_string;
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    e_fcst            EXCEPTION;
    e_event_error     EXCEPTION;

    CURSOR csr_fcst IS
      SELECT a.fcst_id, a.casting_year || a.casting_period || a.casting_week period, a.dataentity_code, a.forecast_type, a.last_updated, a.srce_fcst_id,
        a.status
      FROM fcst a
      WHERE a.fcst_id = i_fcst_id and a.forecast_type = demand_forecast.gc_ft_draft;

    rv_fcst           csr_fcst%ROWTYPE;
  BEGIN
    logit.enter_method (pc_pkg_name, 'COPY_DRAFT_FORECAST');
    o_result := common.gc_success;

    OPEN csr_fcst;

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%NOTFOUND THEN
      CLOSE csr_fcst;

      RAISE e_fcst;
    ELSE
      v_return := demand_forecast.copy_draft_forecast (i_fcst_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

    END IF;

    CLOSE csr_fcst;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_fcst THEN
      o_result_msg := 'Forecast id not found or null';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END copy_draft_forecast;

  -------------------------------------------------------------------------------
  PROCEDURE redo_material_determination (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_result_msg      common.st_message_string;
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    e_fcst            EXCEPTION;

    CURSOR csr_fcst IS
      SELECT a.fcst_id
      FROM fcst a
      WHERE a.fcst_id = i_fcst_id;

    rv_fcst           csr_fcst%ROWTYPE;
  BEGIN
    logit.enter_method (pc_pkg_name, 'REDO_MATERIAL_DETERMINATION');
    o_result := common.gc_success;

    OPEN csr_fcst;

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%NOTFOUND THEN
      CLOSE csr_fcst;

      RAISE e_fcst;
    ELSE
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

      v_return := lads_ref_data.queue_update_request (reference_events.gc_update_matl_dtrmntn, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Failed to request Material Determination update. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := eventit.trigger_events (v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Failed to trigger event process. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := lads_ref_data.wait_for_event (reference_events.gc_matl_dtrmntn, pc_reference_wait_time, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Material Determination data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := demand_forecast.redo_tdu (i_fcst_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;
    END IF;

    CLOSE csr_fcst;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_fcst THEN
      o_result_msg := 'Forecast id not found or null';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END redo_material_determination;

  -------------------------------------------------------------------------------
  PROCEDURE redo_pricing (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_fcst_id         IN      common.st_id,
    i_dmnd_grp_id     IN      common.st_id,
    i_acct_assign_id  IN      common.st_id) IS
    CURSOR csr_fcst IS
      SELECT a.fcst_id
      FROM fcst a
      WHERE a.fcst_id = i_fcst_id;

    rv_fcst           csr_fcst%ROWTYPE;
    v_result_msg      common.st_message_string;
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    e_fcst            EXCEPTION;
  BEGIN
    logit.enter_method (pc_pkg_name, 'REDO_PRICING');
    o_result := common.gc_success;

    OPEN csr_fcst;

    FETCH csr_fcst
    INTO rv_fcst;

    IF csr_fcst%NOTFOUND THEN
      CLOSE csr_fcst;

      RAISE e_fcst;
    ELSE
      -- Popluate LADS reference tables, from LADS master tables. ,
      v_return := lads_ref_data.new_request (v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Failed to allocate new request id. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := lads_ref_data.queue_update_request (reference_events.gc_update_prices, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Failed to request pricing data update. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := lads_ref_data.queue_update_request (reference_events.gc_update_exch_rates, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Failed to request exchange rate data update. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := eventit.trigger_events (v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Failed to trigger event process. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := lads_ref_data.wait_for_event (reference_events.gc_prices, pc_reference_wait_time, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Pricing data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := lads_ref_data.wait_for_event (reference_events.gc_load_lads_xch_rat_det, pc_reference_wait_time, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := 'Lads Exchange Rate data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;

      v_return := demand_forecast.redo_prices (i_fcst_id, i_dmnd_grp_id, i_acct_assign_id, v_result_msg);

      IF v_return != common.gc_success THEN
        v_processing_msg := common.nest_err_msg (v_result_msg);
        RAISE common.ge_failure;
      END IF;
    END IF;

    CLOSE csr_fcst;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN e_fcst THEN
      o_result_msg := 'Forecast id not found or null';
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END redo_pricing;

  -------------------------------------------------------------------------------
  PROCEDURE archive_forecast (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_processing_msg  common.st_message_string;
    e_fcst            EXCEPTION;
  BEGIN
    logit.enter_method (pc_pkg_name, 'ARCHIVE_FORECAST');

    IF demand_forecast.archive_forecast (i_fcst_id, v_processing_msg) != common.gc_success THEN
      RAISE common.ge_failure;
    END IF;

    IF eventit.trigger_events (v_processing_msg) != common.gc_success THEN
      RAISE common.ge_failure;
    END IF;

    o_result := common.gc_success;
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END archive_forecast;

  PROCEDURE unarchive_forecast (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_processing_msg  common.st_message_string;
    e_fcst            EXCEPTION;
  BEGIN
    logit.enter_method (pc_pkg_name, 'UNARCHIVE_FORECAST');

    IF demand_forecast.unarchive_forecast (i_fcst_id, v_processing_msg) != common.gc_success THEN
      RAISE common.ge_failure;
    END IF;

    IF eventit.trigger_events (v_processing_msg) != common.gc_success THEN
      RAISE common.ge_failure;
    END IF;

    o_result := common.gc_success;
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END unarchive_forecast;

  -------------------------------------------------------------------------------
  PROCEDURE purge_forecast (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_processing_msg  common.st_message_string;
    e_fcst            EXCEPTION;
  BEGIN
    logit.enter_method (pc_pkg_name, 'PURGE_FORECAST');

    IF demand_forecast.purge_forecast (i_fcst_id, v_processing_msg) != common.gc_success THEN
      RAISE common.ge_failure;
    END IF;

    IF eventit.trigger_events (v_processing_msg) != common.gc_success THEN
      RAISE common.ge_failure;
    END IF;

    o_result := common.gc_success;
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END purge_forecast;

  -------------------------------------------------------------------------------
  PROCEDURE venus_demand_plan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'VENUS_DEMAND_PLAN_EXTRACT');
    o_result := common.gc_success;
    -- Now trigger the extract.
    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_extract_venus, i_fcst_id, NULL, v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to create venus demand plan extract event. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now trigger the events for processing.
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END venus_demand_plan_extract;

  -------------------------------------------------------------------------------
  PROCEDURE venus_production_plan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'VENUS_PRODUCTION_PLAN_EXTRACT');
    o_result := common.gc_success;
    -- Now trigger the extract.
    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_pp_extract_venus, i_fcst_id, NULL, v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to create venus production plan extract event. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now trigger the events for processing.
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END venus_production_plan_extract;

  -------------------------------------------------------------------------------
  PROCEDURE venus_inv_forecast_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'VENUS_INV_FORECAST_EXTRACT');
    o_result := common.gc_success;
    -- Now trigger the extract.
    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_if_extract_venus, i_fcst_id, NULL, v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to create venus inventory forecast extract event. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now trigger the events for processing.
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END venus_inv_forecast_extract;

  PROCEDURE logistics_demand_plan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'LOGISTICS_DEMAND_PLAN_EXTRACT');
    o_result := common.gc_success;
    -- Now trigger the extract.
    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_extract_lg, i_fcst_id, NULL, v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to create logistics demand plan extract event. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now trigger the events for processing.
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END logistics_demand_plan_extract;
  
  
  
  
  
  
    PROCEDURE logistics_pplan_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'LOGISTICS_PPLAN_EXTRACT');
    o_result := common.gc_success;
    -- Now trigger the extract.
    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_extract_lg_pp, i_fcst_id, NULL, v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to create Logistics Production Plan extract event. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now trigger the events for processing.
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END logistics_pplan_extract;
  
  
  
  

  -------------------------------------------------------------------------------
  PROCEDURE fpps_demand_plan_extract (
    o_result      OUT  common.st_result,
    o_result_msg  OUT  common.st_message_string,
    i_dataentity       common.st_code,
    i_fcst_id          common.st_id,
    i_df_extct_type  common.st_code) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'FPPS_DEMAND_PLAN_EXTRACT');
    o_result := common.gc_success;
    -- Now perform a load of the customers information.
      -- Popluate LADS reference tables, from LADS master tables. ,
    -- check whether this referece event needs to be created or not   
    
--    v_return := lads_ref_data.queue_update_request (reference_events.gc_update_customers, v_result_msg);

--    IF v_return != common.gc_success THEN
--      v_processing_msg := 'Failed to request customer data update. ' || common.nest_err_msg (v_result_msg);
--      RAISE common.ge_failure;
--    END IF;

--    v_return := eventit.trigger_events (v_result_msg);

--    IF v_return != common.gc_success THEN
--      v_processing_msg := 'Failed to trigger event process. ' || common.nest_err_msg (v_result_msg);
--      RAISE common.ge_failure;
--    END IF;

--    v_return := lads_ref_data.wait_for_event (reference_events.gc_cust, pc_reference_wait_time, v_result_msg);

--    IF v_return != common.gc_success THEN
--      v_processing_msg := 'Customer data refresh didn''t complete within the expected time. ' || common.nest_err_msg (v_result_msg);
--      RAISE common.ge_failure;
--    END IF;

    -- call df_app.extract_fpps.request_extract which will now create and trigger the event processing
    v_return := extract_fpps.request_extract ( i_dataentity, i_fcst_id,i_df_extct_type, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

        -- Now trigger the extract.
    --    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_extract_fpps, i_fcst_id, NULL, v_result_msg);

    --    IF v_return <> common.gc_success THEN
    --      v_processing_msg := 'Failed to create fpps demand plan extract event. ' || common.nest_err_msg (v_result_msg);
    --      RAISE common.ge_failure;
    --    END IF;

    --    -- Now trigger the events for processing.
    --    v_return := eventit.trigger_events (v_result_msg);

    --    IF v_return <> common.gc_success THEN
    --      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
    --      RAISE common.ge_failure;
    --    END IF;
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END fpps_demand_plan_extract;

  PROCEDURE fpps_production_plan_extract (
    o_result      OUT  common.st_result,
    o_result_msg  OUT  common.st_message_string,
    i_dataentity       common.st_code,
    i_fcst_id          common.st_id,
    i_fpps_moe         common.st_code) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'FPPS_PRODUCTION_PLAN_EXTRACT');
    o_result := common.gc_success;
    -- Now trigger the extract.

    -- call df_app.extract_fpps.request_extract which will now create and trigger the event processing

   -- v_return := extract_fpps.request_extract (demand_events.gc_extract_type_fpps_df, i_dataentity, i_fcst_id, i_fpps_moe,NULL, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    --    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_pp_extract_fpps, i_fcst_id, NULL, v_result_msg);

    --    IF v_return <> common.gc_success THEN
    --      v_processing_msg := 'Failed to create fpps production plan extract event. ' || common.nest_err_msg (v_result_msg);
    --      RAISE common.ge_failure;
    --    END IF;

    --    -- Now trigger the events for processing.
    --    v_return := eventit.trigger_events (v_result_msg);

    --    IF v_return <> common.gc_success THEN
    --      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
    --      RAISE common.ge_failure;
    --    END IF;
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END fpps_production_plan_extract;

  -------------------------------------------------------------------------------
  PROCEDURE fpps_inv_forecast_extract (
    o_result      OUT  common.st_result,
    o_result_msg  OUT  common.st_message_string,
    i_dataentity       common.st_code,
    i_fcst_id          common.st_id,
    i_fpps_moe         common.st_code) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'FPPS_INV_FORECAST_EXTRACT');
    o_result := common.gc_success;
    -- call df_app.extract_fpps.request_extract which will now create and trigger the event processing

  --  v_return := extract_fpps.request_extract (demand_events.gc_extract_type_fpps_df, i_dataentity, i_fcst_id, i_fpps_moe,NULL, v_result_msg);

    IF v_return != common.gc_success THEN
      v_processing_msg := common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

        -- Now trigger the extract.
    --    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_if_extract_fpps, i_fcst_id, NULL, v_result_msg);

    --    IF v_return <> common.gc_success THEN
    --      v_processing_msg := 'Failed to create fpps inventory forecast extract event. ' || common.nest_err_msg (v_result_msg);
    --      RAISE common.ge_failure;
    --    END IF;

    --    -- Now trigger the events for processing.
    --    v_return := eventit.trigger_events (v_result_msg);

    --    IF v_return <> common.gc_success THEN
    --      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
    --      RAISE common.ge_failure;
    --    END IF;
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END fpps_inv_forecast_extract;

  -------------------------------------------------------------------------------
  PROCEDURE fin_plan_demand_extract (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_id) IS
    v_return          common.st_result;
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'FIN_PLAN_DEMAND_EXTRACT');
    o_result := common.gc_success;
    -- Now trigger the extract.
    v_return := eventit.create_event (demand_forecast.gc_system_code, demand_events.gc_df_extract_fp, i_fcst_id, NULL, v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to create finance model demand extract event. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    -- Now trigger the events for processing.
    v_return := eventit.trigger_events (v_result_msg);

    IF v_return <> common.gc_success THEN
      v_processing_msg := 'Failed to trigger event processing. ' || common.nest_err_msg (v_result_msg);
      RAISE common.ge_failure;
    END IF;

    logit.leave_method;
    o_result := common.gc_success;
  EXCEPTION
    WHEN common.ge_failure THEN
      o_result_msg := common.create_failure_msg (v_processing_msg);
      logit.LOG (o_result_msg);
      logit.leave_method;
      o_result := common.gc_failure;
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END fin_plan_demand_extract;

  -------------------------------------------------------------------------------
  PROCEDURE get_accnt_assgnmt_ids (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_accnt_assnmts OUT common.t_ref_cursor) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_ACC_ASSGNMTS');
    o_result := common.gc_success;

    OPEN o_accnt_assnmts FOR
      SELECT a.acct_assign_id, a.acct_assign_code, a.acct_assign_name
      FROM dmnd_acct_assign a
      ORDER BY a.acct_assign_name;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_accnt_assgnmt_ids;

  -------------------------------------------------------------------------------
  PROCEDURE get_dmnd_grp_ids (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_dmnd_grp OUT common.t_ref_cursor) IS
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DMND_GRP_ORGS');
    o_result := common.gc_success;

    OPEN o_dmnd_grp FOR
      SELECT c.dmnd_grp_id, c.dmnd_grp_code, c.dmnd_grp_name
      FROM dmnd_grp c
      ORDER BY c.dmnd_grp_code;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_dmnd_grp_ids;

  -------------------------------------------------------------------------------
  PROCEDURE get_mltplr_code (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, o_mltplr_code OUT common.t_ref_cursor) IS
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_MLTPLR_CODE');
    o_result := common.gc_success;

    OPEN o_mltplr_code FOR
      SELECT DISTINCT a.mltplr_code
      FROM dmnd_grp_org a
      ORDER BY a.mltplr_code;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_mltplr_code;
  
  PROCEDURE get_drop_down_list (
    o_result          OUT     common.st_result,
    o_result_msg      OUT     common.st_message_string,
    i_drop_down       IN      common.st_code,
    o_drop_down_list  OUT     common.t_ref_cursor) IS
    -- Variable Declarations
    v_processing_msg  common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'GET_DROP_DOWN_LIST');
    o_result := common.gc_success;

    CASE i_drop_down
      WHEN 'DMND_GRP' THEN
        OPEN o_drop_down_list FOR
          SELECT a.dmnd_grp_code AS code, a.dmnd_grp_name AS description
          FROM dmnd_grp a
          ORDER BY a.dmnd_grp_code;
      WHEN 'ACCNT_ASSGNMNT_GRP' THEN
        OPEN o_drop_down_list FOR
          SELECT DISTINCT t1.acct_assign_code AS code, t1.acct_assign_name AS description
          FROM dmnd_grp_org t2, dmnd_acct_assign t1
          WHERE t1.acct_assign_id = t2.acct_assign_id
          ORDER BY t1.acct_assign_code;
      WHEN 'SALES_ORG' THEN
        OPEN o_drop_down_list FOR
          SELECT DISTINCT sales_org AS code, sales_org AS description
          FROM dmnd_grp_org
          ORDER BY sales_org;
      WHEN 'SOURCE' THEN
        OPEN o_drop_down_list FOR
          SELECT DISTINCT source_code AS code, source_code AS description
          FROM dmnd_grp_org
          ORDER BY source_code;
      WHEN 'MLTPLR' THEN
        OPEN o_drop_down_list FOR
          SELECT DISTINCT mltplr_code AS code, mltplr_code AS description
          FROM dmnd_grp_org
          ORDER BY mltplr_code;
      WHEN 'MATL_FG_CLSSFCTN' THEN
        OPEN o_drop_down_list FOR
          SELECT 'BUS_SGMNT' AS code, 'Business Segment' AS description
          FROM DUAL
          UNION ALL
          SELECT 'MKT_SGMNT' AS code, 'Market Segment' AS description
          FROM DUAL
          UNION ALL
          SELECT 'BRAND_FLAG' AS code, 'Brand Flag' AS description
          FROM DUAL
          UNION ALL
          SELECT 'BRAND_SUB_FLAG' AS code, 'Brand Sub Flag' AS description
          FROM DUAL
          UNION ALL
          SELECT 'SPPLY_SGMNT' AS code, 'Supply Segment' AS description
          FROM DUAL
          UNION ALL
          SELECT 'INGRDNT_VRTY' AS code, 'Ingredient Variety' AS description
          FROM DUAL
          UNION ALL
          SELECT 'FNCTNL_VRTY' AS code, 'Functional Variety' AS description
          FROM DUAL
          UNION ALL
          SELECT 'TRADE_SCTR' AS code, 'Trade Sector' AS description
          FROM DUAL
          UNION ALL
          SELECT 'MRKTNG_CNCPT' AS code, 'Marketing Concept' AS description
          FROM DUAL
          UNION ALL
          SELECT 'MLTPCK_QTY' AS code, 'Multipack Quantity' AS description
          FROM DUAL
          UNION ALL
          SELECT 'OCCSN' AS code, 'Occasion' AS description
          FROM DUAL
          UNION ALL
          SELECT 'PRDCT_CTGRY' AS code, 'Product Category' AS description
          FROM DUAL
          UNION ALL
          SELECT 'PRDCT_TYPE' AS code, 'Product Type' AS description
          FROM DUAL
          UNION ALL
          SELECT 'SIZE' AS code, 'Size' AS description
          FROM DUAL
          UNION ALL
          SELECT 'BRAND_ESSNC' AS code, 'Brand Essence' AS description
          FROM DUAL
          UNION ALL
          SELECT 'PACK_TYPE' AS code, 'Pack Type' AS description
          FROM DUAL
          UNION ALL
          SELECT 'SIZE_GROUP' AS code, 'Size Group' AS description
          FROM DUAL
          UNION ALL
          SELECT 'DSPLY_STRG_CNDTN' AS code, 'Display Storage Condition' AS description
          FROM DUAL
          UNION ALL
          SELECT 'TDU_FRMT' AS code, 'TDU Format' AS description
          FROM DUAL
          UNION ALL
          SELECT 'TDU_CNFGRTN' AS code, 'TDU Configuration' AS description
          FROM DUAL
          UNION ALL
          SELECT 'ON_PACK_CNSMR_VALUE' AS code, 'On Pack Consumer Value' AS description
          FROM DUAL
          UNION ALL
          SELECT 'ON_PACK_CNSMR_OFFER' AS code, 'On Pack Consumer Offer' AS description
          FROM DUAL
          UNION ALL
          SELECT 'ON_PACK_TRADE_OFFER' AS code, 'On Pack Trade Offer' AS description
          FROM DUAL
          UNION ALL
          SELECT 'CNSMR_PACK_FRMT' AS code, 'Consumer Pack Format' AS description
          FROM DUAL
          UNION ALL
          SELECT 'MKT_CAT' AS code, 'Market Category' AS description
          FROM DUAL
          UNION ALL
          SELECT 'MKT_SUB_CAT' AS code, 'Market Sub Category' AS description
          FROM DUAL
          UNION ALL
          SELECT 'MKT_SUB_CAT_GRP' AS code, 'Market Sub Category Group' AS description
          FROM DUAL
          UNION ALL
          SELECT 'SOP_BUS' AS code, 'SOP Business Classification' AS description
          FROM DUAL
          UNION ALL
          SELECT 'PRODN_LINE' AS code, 'Production Line' AS description
          FROM DUAL
          UNION ALL
          SELECT 'FIGHTING_UNIT' AS code, 'Fighting Unit' AS description
          FROM DUAL
          UNION ALL
          SELECT 'PLNG_SRCE' AS code, 'Planning Source' AS description
          FROM DUAL
          UNION ALL 
          SELECT 'NZ_PROMOTION_GROUP' As code, 'NZ Promotion Group' As description
          FROM DUAL
          UNION ALL 
          SELECT 'NZ_S_AND_OP_BUSINESS' As code, 'NZ S and OP Bussiness' As description
          FROM DUAL
          UNION ALL 
          SELECT 'NZ_MUST_WIN_BATTLE' As code, 'NZ Must Win Battle' As description
          FROM DUAL;
      WHEN 'BUS_SGMNT' THEN
        OPEN o_drop_down_list FOR
          SELECT bus_sgmnt_code AS code, bus_sgmnt_short_desc AS description
          FROM bus_sgmnt
          ORDER BY bus_sgmnt_code;
      WHEN 'MKT_SGMNT' THEN
        OPEN o_drop_down_list FOR
          SELECT mkt_sgmnt_code AS code, mkt_sgmnt_short_desc AS description
          FROM mkt_sgmnt
          ORDER BY mkt_sgmnt_code;
      WHEN 'BRAND_FLAG' THEN
        OPEN o_drop_down_list FOR
          SELECT brand_flag_code AS code, brand_flag_long_desc AS description
          FROM brand_flag
          ORDER BY brand_flag_code;
      WHEN 'BRAND_SUB_FLAG' THEN
        OPEN o_drop_down_list FOR
          SELECT brand_sub_flag_code AS code, brand_sub_flag_long_desc AS description
          FROM brand_sub_flag
          ORDER BY brand_sub_flag_code;
      WHEN 'SPPLY_SGMNT' THEN
        OPEN o_drop_down_list FOR
          SELECT spply_sgmnt_code AS code, spply_sgmnt_short_desc AS description
          FROM spply_sgmnt
          ORDER BY spply_sgmnt_code;
      WHEN 'INGRDNT_VRTY' THEN
        OPEN o_drop_down_list FOR
          SELECT ingrdnt_vrty_code AS code, ingrdnt_vrty_short_desc AS description
          FROM ingrdnt_vrty
          ORDER BY ingrdnt_vrty_code;
      WHEN 'FNCTNL_VRTY' THEN
        OPEN o_drop_down_list FOR
          SELECT fnctnl_vrty_code AS code, fnctnl_vrty_short_desc AS description
          FROM fnctnl_vrty
          ORDER BY fnctnl_vrty_code;
      WHEN 'TRADE_SCTR' THEN
        OPEN o_drop_down_list FOR
          SELECT trade_sctr_code AS code, trade_sctr_short_desc AS description
          FROM trade_sctr
          ORDER BY trade_sctr_code;
      WHEN 'MRKTNG_CNCPT' THEN
        OPEN o_drop_down_list FOR
          SELECT mrktng_cncpt_code AS code, mrktng_cncpt_short_desc AS description
          FROM mrktng_cncpt
          ORDER BY mrktng_cncpt_code;
      WHEN 'MLTPCK_QTY' THEN
        OPEN o_drop_down_list FOR
          SELECT mltpck_qty_code AS code, mltpck_qty_short_desc AS description
          FROM mltpck_qty
          ORDER BY mltpck_qty_code;
      WHEN 'OCCSN' THEN
        OPEN o_drop_down_list FOR
          SELECT occsn_code AS code, occsn_short_desc AS description
          FROM occsn
          ORDER BY occsn_code;
      WHEN 'PRDCT_CTGRY' THEN
        OPEN o_drop_down_list FOR
          SELECT prdct_ctgry_code AS code, prdct_ctgry_short_desc AS description
          FROM prdct_ctgry
          ORDER BY prdct_ctgry_code;
      WHEN 'PRDCT_TYPE' THEN
        OPEN o_drop_down_list FOR
          SELECT prdct_type_code AS code, prdct_type_short_desc AS description
          FROM prdct_type
          ORDER BY prdct_type_code;
      WHEN 'SIZE' THEN
        OPEN o_drop_down_list FOR
          SELECT size_code AS code, size_short_desc AS description
          FROM size_dscrptv
          ORDER BY size_code;
      WHEN 'BRAND_ESSNC' THEN
        OPEN o_drop_down_list FOR
          SELECT brand_essnc_code AS code, brand_essnc_short_desc AS description
          FROM brand_essnc
          ORDER BY brand_essnc_code;
      WHEN 'PACK_TYPE' THEN
        OPEN o_drop_down_list FOR
          SELECT pack_type_code AS code, pack_type_short_desc AS description
          FROM pack_type
          ORDER BY pack_type_code;
      WHEN 'SIZE_GROUP' THEN
        OPEN o_drop_down_list FOR
          SELECT size_group_code AS code, size_group_short_desc AS description
          FROM size_group
          ORDER BY size_group_code;
      WHEN 'DSPLY_STRG_CNDTN' THEN
        OPEN o_drop_down_list FOR
          SELECT dsply_strg_cndtn_code AS code, dsply_strg_cndtn_short_desc AS description
          FROM dsply_strg_cndtn
          ORDER BY dsply_strg_cndtn_code;
      WHEN 'TDU_FRMT' THEN
        OPEN o_drop_down_list FOR
          SELECT tdu_frmt_code AS code, tdu_frmt_short_desc AS description
          FROM tdu_frmt
          ORDER BY tdu_frmt_code;
      WHEN 'TDU_CNFGRTN' THEN
        OPEN o_drop_down_list FOR
          SELECT tdu_cnfgrtn_code AS code, tdu_cnfgrtn_short_desc AS description
          FROM tdu_cnfgrtn
          ORDER BY tdu_cnfgrtn_code;
      WHEN 'ON_PACK_CNSMR_VALUE' THEN
        OPEN o_drop_down_list FOR
          SELECT on_pack_cnsmr_value_code AS code, on_pack_cnsmr_value_short_desc AS description
          FROM on_pack_cnsmr_value
          ORDER BY on_pack_cnsmr_value_code;
      WHEN 'ON_PACK_CNSMR_OFFER' THEN
        OPEN o_drop_down_list FOR
          SELECT on_pack_cnsmr_offer_code AS code, on_pack_cnsmr_offer_short_desc AS description
          FROM on_pack_cnsmr_offer
          ORDER BY on_pack_cnsmr_offer_code;
      WHEN 'ON_PACK_TRADE_OFFER' THEN
        OPEN o_drop_down_list FOR
          SELECT on_pack_trade_offer_code AS code, on_pack_trade_offer_short_desc AS description
          FROM on_pack_trade_offer
          ORDER BY on_pack_trade_offer_code;
      WHEN 'CNSMR_PACK_FRMT' THEN
        OPEN o_drop_down_list FOR
          SELECT cnsmr_pack_frmt_code AS code, cnsmr_pack_frmt_short_desc AS description
          FROM cnsmr_pack_frmt
          ORDER BY cnsmr_pack_frmt_code;
      WHEN 'MKT_CAT' THEN
        OPEN o_drop_down_list FOR
          SELECT mkt_cat_code AS code, mkt_cat_desc AS description
          FROM mkt_cat
          ORDER BY mkt_cat_code;
      WHEN 'MKT_SUB_CAT' THEN
        OPEN o_drop_down_list FOR
          SELECT mkt_sub_cat_code AS code, mkt_sub_cat_desc AS description
          FROM mkt_sub_cat
          ORDER BY mkt_sub_cat_code;
      WHEN 'MKT_SUB_CAT_GRP' THEN
        OPEN o_drop_down_list FOR
          SELECT mkt_sub_cat_grp_code AS code, mkt_sub_cat_grp_desc AS description
          FROM mkt_sub_cat_grp
          ORDER BY mkt_sub_cat_grp_code;
      WHEN 'SOP_BUS' THEN
        OPEN o_drop_down_list FOR
          SELECT sop_bus_code AS code, sop_bus_desc AS description
          FROM sop_bus
          ORDER BY sop_bus_code;
      WHEN 'PRODN_LINE' THEN
        OPEN o_drop_down_list FOR
          SELECT prodn_line_code AS code, prodn_line_desc AS description
          FROM prodn_line
          ORDER BY prodn_line_code;
      WHEN 'FIGHTING_UNIT' THEN
        OPEN o_drop_down_list FOR
          SELECT fighting_unit_code AS code, fighting_unit_desc AS description
          FROM fighting_unit
          ORDER BY fighting_unit_code;
      WHEN 'PLNG_SRCE' THEN
        OPEN o_drop_down_list FOR
          SELECT plng_srce_code AS code, plng_srce_desc AS description
          FROM plng_srce
          ORDER BY plng_srce_code;
      WHEN 'NZ_PROMOTION_GROUP' THEN
        OPEN o_drop_down_list FOR
          SELECT NZ_PROMOTION_GROUP_CODE AS code, NZ_PROMOTION_GROUP_DESC AS description
          FROM NZ_PROMOTION_GROUP
          ORDER BY NZ_PROMOTION_GROUP_CODE;          
      WHEN 'NZ_S_AND_OP_BUSINESS' THEN
        OPEN o_drop_down_list FOR
          SELECT NZ_S_AND_OP_BUSINESS_CODE AS code, NZ_S_AND_OP_BUSINESS_DESC AS description
          FROM NZ_S_AND_OP_BUSINESS
          ORDER BY NZ_S_AND_OP_BUSINESS_CODE;
      WHEN 'NZ_MUST_WIN_BATTLE' THEN
        OPEN o_drop_down_list FOR
          SELECT NZ_MUST_WIN_BATTLE_CODE AS code, NZ_MUST_WIN_BATTLE_DESC AS description
          FROM NZ_MUST_WIN_BATTLE
          ORDER BY NZ_MUST_WIN_BATTLE_CODE;            
      ELSE
        OPEN o_drop_down_list FOR
          SELECT 'X' AS code, 'X' AS description
          FROM DUAL
          WHERE 1 = 0;
    END CASE;

    logit.leave_method;
  EXCEPTION
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END get_drop_down_list;

  -------------------------------------------------------------------------------
  PROCEDURE adjust_forecast (
    o_result         OUT     common.st_result,
    o_result_msg     OUT     common.st_message_string,
    i_mode           IN      common.st_status,
    i_fcst_id        IN      common.st_code,
    i_dmnd_grp       IN      common.st_code,
    i_acct_assign    IN      common.st_code,
    i_sales_org      IN      common.st_code,
    i_multiplier     IN      common.st_code,
    i_source         IN      common.st_code,
    i_fromweek       IN      common.st_code,
    i_toweek         IN      common.st_code,
    i_class_type_1   IN      common.st_code,
    i_class_value_1  IN      common.st_code,
    i_class_type_2   IN      common.st_code,
    i_class_value_2  IN      common.st_code,
    i_class_type_3   IN      common.st_code,
    i_class_value_3  IN      common.st_code,
    i_class_type_4   IN      common.st_code,
    i_class_value_4  IN      common.st_code,
    i_class_type_5   IN      common.st_code,
    i_class_value_5  IN      common.st_code,
    i_matl_code      IN      common.st_code,
    i_adjustment     IN      common.st_code,
    i_target_cases   IN      common.st_code,
    i_target_gsv     IN      common.st_code,
    o_case_total     OUT     common.st_value,
    o_gsv_total      OUT     common.st_value,
    o_case_change    OUT     common.st_value,
    o_gsv_change     OUT     common.st_value) IS
    -- Constant Declarations
    c_mode_apply            common.st_status         := 'A';
    c_mode_analyse          common.st_status         := 'Z';
    -- Variable Declarations
    v_processing_msg        common.st_message_string;
    v_return                common.st_result;
    v_return_msg            common.st_message_string;
    -- Strcuture for the materials
    v_zreps                 common.t_codes_by_code;
    v_zrep                  common.st_code;
    v_dmnd_grp_orgs         common.t_ids;
    v_fcst_id               common.st_id;
    v_delete_zrep           common.st_code;
    v_dmnd_grp_org_counter  common.st_counter;
    v_dmnd_data_counter     common.st_counter;
    v_counter               common.st_counter;
    v_adjustment            common.st_value;

    -- Demand Data Record Strucutre.
    TYPE t_dmnd_data IS TABLE OF dmnd_data%ROWTYPE
      INDEX BY common.st_counter;

    v_dmnd_data             t_dmnd_data;

    -- Cursor for the demand data structure.
    CURSOR csr_dmnd_data (i_dmnd_grp_org_id IN common.st_id) IS
      SELECT *
      FROM dmnd_data
      WHERE fcst_id = v_fcst_id AND
       dmnd_grp_org_id = i_dmnd_grp_org_id AND
       (mars_week >= i_fromweek OR i_fromweek IS NULL) AND
       (mars_week <= i_toweek OR i_toweek IS NULL);

    -- Cursor to find the demand group orgs to process.
    CURSOR csr_dmnd_grp_orgs IS
      SELECT dmnd_grp_org_id
      FROM dmnd_grp_org t1, dmnd_grp t2, dmnd_acct_assign t3
      WHERE t1.dmnd_grp_id = t2.dmnd_grp_id AND
       t1.acct_assign_id = t3.acct_assign_id AND
       (t2.dmnd_grp_code = i_dmnd_grp OR i_dmnd_grp IS NULL) AND
       (t1.source_code = i_source OR i_source IS NULL) AND
       (t1.mltplr_code = i_multiplier OR i_multiplier IS NULL) AND
       (t1.sales_org = i_sales_org OR i_sales_org IS NULL) AND
       (t3.acct_assign_code = i_acct_assign OR i_acct_assign IS NULL) AND
       EXISTS (SELECT *
               FROM dmnd_data t0
               WHERE t0.fcst_id = v_fcst_id AND t0.dmnd_grp_org_id = t1.dmnd_grp_org_id);

    CURSOR csr_zreps IS
      SELECT DISTINCT zrep
      FROM dmnd_data t1
      WHERE fcst_id = v_fcst_id;

    FUNCTION has_classn_value (i_zrep IN common.st_code, i_class_type IN common.st_code, i_class_value IN common.st_code)
      RETURN BOOLEAN IS
      v_found      BOOLEAN;
      csr_classn   common.t_ref_cursor;
      v_matl_code  common.st_code;
    BEGIN
      v_found := FALSE;

      IF i_class_type IS NULL THEN
        v_found := TRUE;
      ELSE
        IF i_class_value IS NULL THEN
          v_found := FALSE;
        ELSE
          OPEN csr_classn FOR    'select matl_code from matl_fg_clssfctn t0 '
                              || ' where t0.matl_code = reference_functions.full_matl_code(:i_zrep) and '
                              || ' '
                              || i_class_type
                              || '_CODE = '''
                              || i_class_value
                              || '''' USING i_zrep;

          FETCH csr_classn
          INTO v_matl_code;

          IF csr_classn%FOUND = TRUE THEN
            v_found := TRUE;
          ELSE
            v_found := FALSE;
          END IF;

          CLOSE csr_classn;
        END IF;
      END IF;

      RETURN v_found;
    EXCEPTION
      WHEN OTHERS THEN
        v_processing_msg := 'During classification filtering. ' || common.nest_err_msg (common.create_sql_error_msg);
        RAISE common.ge_error;
    END has_classn_value;
  BEGIN
    logit.enter_method (pc_pkg_name, 'ADJUST_FORECAST');
    o_result := common.gc_success;
    o_case_change := 0;
    o_gsv_change := 0;
    o_case_total := 0;
    o_gsv_total := 0;
    -- Now convert the forecast id.
    logit.LOG ('Checking for valid forecast id.');

    IF i_fcst_id IS NULL THEN
      v_processing_msg := 'No forecast id was supplied.';
      RAISE common.ge_error;
    END IF;

    BEGIN
      v_fcst_id := TO_NUMBER (i_fcst_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_processing_msg := 'Unable to convert forecast id to a number.';
        RAISE common.ge_error;
    END;

    logit.LOG ('Forecast ID for processing : ' || v_fcst_id);
    -- Now load the dmand group orgs that we will be processing into a collection
    logit.LOG ('Finding valid demand group orgs to process.');

    OPEN csr_dmnd_grp_orgs;

    FETCH csr_dmnd_grp_orgs
    BULK COLLECT INTO v_dmnd_grp_orgs;

    CLOSE csr_dmnd_grp_orgs;

    logit.LOG ('Found ' || v_dmnd_grp_orgs.COUNT || ' to process.');

    -- See if we have been supplied with a specific zrep code.
    IF i_matl_code IS NOT NULL THEN
      logit.LOG ('Specific matl code supplied.  Added that to zrep collection.');
      v_zreps (i_matl_code) := i_matl_code;
    ELSE
      -- Now we need to find the list of zreps that we may need to process.
      logit.LOG ('Finding zreps that we will need to process.');

      OPEN csr_zreps;

      LOOP
        FETCH csr_zreps
        INTO v_zrep;

        EXIT WHEN csr_zreps%NOTFOUND;
        v_zreps (v_zrep) := v_zrep;
      END LOOP;

      CLOSE csr_zreps;

      -- Now checking if we should remove any materials that don't meet the filter criteria.
      logit.LOG ('Now apply classification filters.  Started with ' || v_zreps.COUNT || ' materials.');
      v_zrep := v_zreps.FIRST;
      v_delete_zrep := NULL;

      LOOP
        EXIT WHEN v_zrep IS NULL;

        -- Now process the current zrep.
        IF has_classn_value (v_zrep, i_class_type_1, i_class_value_1) = TRUE THEN
          IF has_classn_value (v_zrep, i_class_type_2, i_class_value_2) = TRUE THEN
            IF has_classn_value (v_zrep, i_class_type_3, i_class_value_3) = TRUE THEN
              IF has_classn_value (v_zrep, i_class_type_4, i_class_value_4) = TRUE THEN
                IF has_classn_value (v_zrep, i_class_type_5, i_class_value_5) = TRUE THEN
                  -- Nothing required material meets all the necessary filter criteria.
                  NULL;
                ELSE
                  v_delete_zrep := v_zrep;
                END IF;
              ELSE
                v_delete_zrep := v_zrep;
              END IF;
            ELSE
              v_delete_zrep := v_zrep;
            END IF;
          ELSE
            v_delete_zrep := v_zrep;
          END IF;
        ELSE
          v_delete_zrep := v_zrep;
        END IF;

        -- Now move onto the next zrep.
        v_zrep := v_zreps.NEXT (v_zrep);

        -- Now delete if required.
        IF v_delete_zrep IS NOT NULL THEN
          v_zreps.DELETE (v_delete_zrep);
          v_delete_zrep := NULL;
        END IF;
      END LOOP;
    END IF;

    logit.LOG ('Have ' || v_zreps.COUNT || ' ZREPs for the forecast.');
    -- Now load into memory each of the records that needs to have the adjustment applied.
    logit.LOG ('Loading demand data records into memory.');
    v_dmnd_grp_org_counter := 1;
    v_dmnd_data_counter := 0;

    LOOP
      EXIT WHEN v_dmnd_grp_org_counter > v_dmnd_grp_orgs.COUNT;

      OPEN csr_dmnd_data (v_dmnd_grp_orgs (v_dmnd_grp_org_counter) );

      LOOP
        FETCH csr_dmnd_data
        INTO v_dmnd_data (v_dmnd_data_counter + 1);

        EXIT WHEN csr_dmnd_data%NOTFOUND = TRUE;

        -- If we received a record lets decide if it is for a zrep we are interested in.
        IF v_zreps.EXISTS (v_dmnd_data (v_dmnd_data_counter + 1).zrep) = TRUE THEN
          v_dmnd_data_counter := v_dmnd_data_counter + 1;
        END IF;
      END LOOP;

      CLOSE csr_dmnd_data;

      v_dmnd_grp_org_counter := v_dmnd_grp_org_counter + 1;
    END LOOP;

    logit.LOG ('Found ' || v_dmnd_data_counter || ' demand data records that match the necessary criteria.');
    -- Now calculate the current totals before adjustment.
    logit.LOG ('Calculate totals prior to adjustment.');
    v_counter := 1;

    LOOP
      EXIT WHEN v_counter > v_dmnd_data_counter;
      o_case_total := o_case_total + NVL (v_dmnd_data (v_counter).qty_in_base_uom, 0);
      o_gsv_total := o_gsv_total + NVL (v_dmnd_data (v_counter).gsv, 0);
      v_counter := v_counter + 1;
    END LOOP;

    logit.LOG ('Pre adjustment total cases : ' || o_case_total || ' and total gsv : ' || o_gsv_total);
    -- Now work out the percentage adjustment required for each of the different option types.
    logit.LOG ('Calculate the necessary adjustment factors.');

    IF i_adjustment IS NOT NULL THEN
      BEGIN
        v_adjustment := TO_NUMBER (i_adjustment);
      EXCEPTION
        WHEN OTHERS THEN
          v_processing_msg := 'Unable to convert supplied adjustment value into an adjustment percentage number.';
          RAISE common.ge_error;
      END;

      logit.LOG ('Adjustment value supplied : ' || v_adjustment || '.');
    END IF;

    -- Now calculate the percentage adjustment where a target cases was used.
    IF i_target_cases IS NOT NULL THEN
      IF o_case_total = 0 THEN
        v_processing_msg := 'Unable to calculate a target case adjustment factor as there were no cases to start with.';
        RAISE common.ge_error;
      END IF;

      DECLARE
        v_target      common.st_value;
        v_difference  common.st_value;
      BEGIN
        v_target := TO_NUMBER (i_target_cases);
        v_difference := v_target - o_case_total;
        v_adjustment := v_difference / o_case_total * 100;
        logit.LOG (   'Target cases value supplied : '
                   || v_target
                   || ', Total was : '
                   || o_case_total
                   || ', Difference : '
                   || v_difference
                   || ', Calculated Adjustment Factor : '
                   || v_adjustment
                   || '.');
      EXCEPTION
        WHEN OTHERS THEN
          v_processing_msg := 'Unable to determine the supplied target cases quantity from supplied value.';
          RAISE common.ge_error;
      END;
    END IF;

    -- Now calculate the percentage adjustment where a target gsv was used.
    IF i_target_gsv IS NOT NULL THEN
      IF o_gsv_total = 0 THEN
        v_processing_msg := 'Unable to calculate a target gsv adjustment factor as there was no GSV to start with.';
        RAISE common.ge_error;
      END IF;

      DECLARE
        v_target      common.st_value;
        v_difference  common.st_value;
      BEGIN
        v_target := TO_NUMBER (i_target_gsv);
        v_difference := v_target - o_gsv_total;
        v_adjustment := v_difference / o_gsv_total * 100;
        logit.LOG (   'Target gsv value supplied : '
                   || v_target
                   || ', Total was : '
                   || o_gsv_total
                   || ', Difference : '
                   || v_difference
                   || ', Calculated Adjustment Factor : '
                   || v_adjustment
                   || '.');
      EXCEPTION
        WHEN OTHERS THEN
          v_processing_msg := 'Unable to determine the supplied target cases quantity from supplied value.';
          RAISE common.ge_error;
      END;
    END IF;

    -- Now calculate the adjustment.
    logit.LOG ('Calculating required adjustment.');
    v_counter := 1;

    LOOP
      EXIT WHEN v_counter > v_dmnd_data_counter;
      v_dmnd_data (v_counter).qty_in_base_uom := v_dmnd_data (v_counter).qty_in_base_uom * v_adjustment / 100;
      v_dmnd_data (v_counter).gsv := v_dmnd_data (v_counter).gsv * v_adjustment / 100;
      o_case_change := o_case_change + NVL (v_dmnd_data (v_counter).qty_in_base_uom, 0);
      o_gsv_change := o_gsv_change + NVL (v_dmnd_data (v_counter).gsv, 0);
      v_counter := v_counter + 1;
    END LOOP;

    o_case_total := o_case_total + o_case_change;
    o_gsv_total := o_gsv_total + o_gsv_change;
    logit.LOG ('Adjustment change cases : ' || o_case_change || ' and change gsv : ' || o_gsv_change);
    logit.LOG ('Post adjustment total cases : ' || o_case_total || ' and total gsv : ' || o_gsv_total);

    -- Now if we are applying drop the demand indexes.
    IF i_mode = c_mode_apply THEN

      -- Now insert the new demand data records as a result of applying the change.
      logit.LOG ('Now inserting the adjusted records into the table.');
      v_counter := 1;

      LOOP
        EXIT WHEN v_counter > v_dmnd_data_counter;

        INSERT INTO dmnd_data
                    (fcst_id, dmnd_grp_org_id, gsv,
                     qty_in_base_uom, zrep, tdu, price,
                     mars_week, price_condition, TYPE)
             VALUES (v_dmnd_data (v_counter).fcst_id, v_dmnd_data (v_counter).dmnd_grp_org_id, v_dmnd_data (v_counter).gsv,
                     v_dmnd_data (v_counter).qty_in_base_uom, v_dmnd_data (v_counter).zrep, v_dmnd_data (v_counter).tdu, v_dmnd_data (v_counter).price,
                     v_dmnd_data (v_counter).mars_week, v_dmnd_data (v_counter).price_condition, '0'   -- Type 0 - Forecast Adjustment.
                                                                                                    );

        v_counter := v_counter + 1;

        IF MOD (v_counter, common.gc_common_commit_point) = 0 THEN
          COMMIT;
        END IF;
      END LOOP;

      COMMIT;
      logit.LOG ('Adjust records, ' || v_dmnd_data_counter || ' of, were successfully inserted.');
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END adjust_forecast;

  PROCEDURE delete_adjustments (o_result OUT common.st_result, o_result_msg OUT common.st_message_string, i_fcst_id IN common.st_code) IS
    v_fcst_id         common.st_id;
    v_processing_msg  common.st_message_string;
    v_return          common.st_result;
    v_return_msg      common.st_message_string;
  BEGIN
    logit.enter_method (pc_pkg_name, 'ADJUST_FORECAST');
    o_result := common.gc_success;
    -- Now convert the forecast id.
    logit.LOG ('Checking for valid forecast id.');

    IF i_fcst_id IS NULL THEN
      v_processing_msg := 'No forecast id was supplied.';
      RAISE common.ge_error;
    END IF;

    BEGIN
      v_fcst_id := TO_NUMBER (i_fcst_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_processing_msg := 'Unable to convert forecast id to a number.';
        RAISE common.ge_error;
    END;

    logit.LOG ('Forecast ID for deleting adjustments : ' || v_fcst_id);

    DELETE FROM dmnd_data
          WHERE fcst_id = v_fcst_id AND TYPE = '0';

    COMMIT;
    logit.LOG ('Adjustments deleted, ' || SQL%ROWCOUNT || ' of.');
    logit.leave_method;
  EXCEPTION
    WHEN common.ge_error THEN
      o_result_msg := common.create_error_msg (v_processing_msg);
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
    WHEN OTHERS THEN
      o_result_msg := common.create_sql_error_msg;
      logit.log_error (o_result_msg);
      logit.leave_method;
      o_result := common.gc_error;
  END delete_adjustments;
---------------------
END demand_gui; 