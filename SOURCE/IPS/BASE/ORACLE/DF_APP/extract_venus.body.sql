create or replace 
PACKAGE BODY        "EXTRACT_VENUS" AS
  pc_package_name                  CONSTANT common.st_package_name   := 'EXTRACT_VENUS';
  pc_venus_df_source_mq_code   CONSTANT common.st_code           := 'VENUS_DF_SOURCE_QMGR';
  pc_venus_df_target_mq_code   CONSTANT common.st_code           := 'VENUS_DF_TARGET_QMGR';
  pc_venus_df_target_filename  CONSTANT    common.st_code             := 'VENUS_DF_TARGET_FILE';
  pc_venus_df_mq_default         CONSTANT common.st_message_string := '<set>';   -- After initialisation please change in the system params table.
  -- Source test=WODU03T1
  -- Target test=WODU03T1
  pc_venus_if_source_mq_code   CONSTANT common.st_code           := 'VENUS_IF_SOURCE_QMGR';
  pc_venus_if_target_mq_code   CONSTANT common.st_code           := 'VENUS_IF_TARGET_QMGR';
  pc_venus_if_target_filename  CONSTANT    common.st_code             := 'VENUS_IF_TARGET_FILE';
  pc_venus_if_mq_default         CONSTANT common.st_message_string := '<set>';   -- After initialisation please change in the system params table.
  -- Source test=
  -- Target test=
  pc_venus_pp_source_mq_code   CONSTANT common.st_code           := 'VENUS_PP_SOURCE_QMGR';
  pc_venus_pp_target_mq_code   CONSTANT common.st_code           := 'VENUS_PP_TARGET_QMGR';
  pc_venus_pp_target_filename  CONSTANT    common.st_code             := 'VENUS_PP_TARGET_FILE';
  pc_venus_pp_mq_default         CONSTANT common.st_message_string := '<set>';   -- After initialisation please change in the system params table.
  -- Source test=WODU03T1
  -- Target test=WODU03T1

  PROCEDURE initialise IS
    v_processing_msg  common.st_message_string;
    v_result_msg      common.st_message_string;
    e_load_failure    EXCEPTION;
  BEGIN
    logit.enter_method (pc_package_name, 'INITIALISE');

    IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_df_source_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_df_source_mq_code, pc_venus_df_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install venus demand source queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_df_source_mq_code,
                                            'This is the source queue manager that demand forecast files should be put on for Venus.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_df_target_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_df_target_mq_code, pc_venus_df_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install venus demand target queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_df_target_mq_code,
                                            'This is the target queue manager that demand forecast files should be sent to for Venus.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_df_target_filename, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_df_target_filename, pc_venus_df_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to define demand forecast target path and filename.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_df_target_filename,
                                            'This is the target path and filename that the demand forecast will be written to.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_if_source_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_if_source_mq_code, pc_venus_if_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install venus inventory forecast source queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_if_source_mq_code,
                                            'This is the source queue manager that inventory forecast files should be put on for Venus.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

       IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_if_target_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_if_target_mq_code, pc_venus_if_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install venus inventory forecast target queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_if_target_mq_code,
                                            'This is the target queue manager that inventory forecast files should be put on for Venus.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_if_target_filename, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_if_target_filename, pc_venus_if_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to define inventory forecast target path and filename.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_if_target_filename,
                                            'This is the target path and filename that the inventory forecast will be written to.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_pp_source_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_pp_source_mq_code, pc_venus_pp_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install venus production plan source queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_pp_source_mq_code,
                                            'This is the source queue manager name that production plan files should be put on for Venus.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

     IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_pp_target_mq_code, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_pp_target_mq_code, pc_venus_pp_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to install venus production plan target queue manager.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_pp_target_mq_code,
                                            'This is the target queue manager name that production plan files should be put on for Venus.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    IF system_params.exists_parameter (demand_forecast.gc_system_code, pc_venus_pp_target_filename, v_result_msg) != common.gc_success THEN
      IF system_params.set_parameter_text (demand_forecast.gc_system_code, pc_venus_pp_target_filename, pc_venus_pp_mq_default, v_result_msg) != common.gc_success THEN
        v_processing_msg := 'Unable to define production plan target path and filename.';
        RAISE e_load_failure;
      END IF;
    END IF;

    -- Now update the description on the parameter.
    IF system_params.set_parameter_comment (demand_forecast.gc_system_code,
                                            pc_venus_pp_target_filename,
                                            'This is the target path and filename that the production plan will be written to.',
                                            v_result_msg) != common.gc_success THEN
      RAISE e_load_failure;
    END IF;

    logit.leave_method;
  EXCEPTION
    WHEN e_load_failure THEN
      logit.log_error ('Failed to initialise parameters : ' || v_processing_msg);
  END;


 FUNCTION extract_demand_forecast_new (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_record_type           common.st_code;   -- always 'DET'
    v_forecast_type         common.st_code;   -- read from FCST table.
    v_version               common.st_code;   -- always '1''
    v_casting_period        common.st_code;   -- read from FCST table
    v_sales_org             common.st_code;   -- read from DMND_GRP table, 147
    v_moe_code              common.st_code;   -- read from FCST table
    v_dc                    common.st_code;   -- read from DMND_GRP table, 10,11,99
    v_division              common.st_code;   -- read from DMND_GRP table,
    v_customer_no           common.st_code;   -- SHIP_TO from DMDND_GRP, if not then BILL_TO
    v_region                common.st_code;   --  Always Blank.
    v_country               common.st_code;   -- Country from DMDND_GRP table.
    v_multi_market          VARCHAR (50);     -- Always Blank.
    v_banner                common.st_code;   -- Always Blank.
    v_buying_group          VARCHAR (50);     -- Always Blank.
    v_pos_format            VARCHAR (50);     -- Always Blank.
    v_dist_route            common.st_code;   -- Always Blank.
    v_account_assign        common.st_code;   -- GRD account assign, 01 Domestic, 02 Affilate , 03 Foriegn
    v_demand_planning_node  VARCHAR (10);     -- Demand planning node from the DMND_GRP table.
    v_material_number       common.st_code;   -- ZREP
    v_forecast_period       common.st_code;   -- Marsweek if standard FCST otherwise PERIOD for BR,OP
    v_gsv                   common.st_code;   -- Gross Sales Value
    v_qty                   common.st_code;   -- Total Qty sold, Base unit of measure.
    v_currency              common.st_code;   -- done
    v_head_rec_type         common.st_code;   -- 'CTL' , , header record
    v_idoc_name             VARCHAR (50);     -- 'Z_FORECAST' , header record
    v_idoc_number           common.st_code;   -- Always '0'' , header record
    v_idoc_date             common.st_code;   -- sysdate, header record.
    v_idoc_time             common.st_code;   -- systime, header record.
    v_material_code         common.st_code;   -- TDU
    v_forecast_dmnd_type    common.st_code;   -- forecast demand type, 1,2,3 etc


    -- Main cursor to retreive sales forecast information for a given forecast.
--    CURSOR csr_demand_data (i_fcst_id IN common.st_id) IS
--      SELECT dd.mars_week, f.forecast_type, f.casting_year, f.casting_period, f.casting_week, NVL (dmnd_plng_node, ' ') dmnd_plng_node,
--        NVL (dgo.sales_org, ' ') AS sales_org, NVL (dgo.distbn_chnl, ' ') AS distbn_chnl, NVL (dgo.cust_div, ' ') AS cust_div, dgo.mltplr_code,
--        NVL(F.MOE_CODE, ' ') AS MOE_CODE, NVL (dgo.bill_to_code, ' ') AS bill_to_code, dgo.ship_to_code, NVL (dgo.region_code, ' ') as region_code,
--        NVL (c.cntry_code, ' ') AS cntry_code, NVL (dgo.multi_mrkt_accnt_code, ' ') as multi_mrket_accnt_code, NVL (dgo.banner_code, ' ') as banner_code,
--        NVL (dgo.cust_buying_group_code, ' ') as cust_buying_group_code, NVL (dgo.pos_frmt_grpng_code, ' ') AS pos_frmt_grpng_code, NVL (dgo.dstrbtn_route_code, ' ') as dstrbtn_route_code,
--        NVL (a.acct_assign_code, ' ') AS acct_assign_code, NVL (dd.zrep, ' ') AS zrep, NVL (dd.tdu, ' ') AS tdu, NVL (dd.TYPE, ' ') AS type,
--        NVL (dd.gsv, 0) AS gsv, NVL (dd.qty_in_base_uom, 0) AS cases, NVL (dgo.currcy_code, ' ') AS currcy_code
--      FROM dmnd_data dd, dmnd_grp dg, dmnd_grp_org dgo, fcst f, dmnd_cntry c, dmnd_acct_assign a
--      WHERE dg.dmnd_grp_id = dgo.dmnd_grp_id AND
--       dd.dmnd_grp_org_id = dgo.dmnd_grp_org_id AND
--       f.fcst_id = dd.fcst_id AND
--       dg.cntry_id = c.cntry_id AND
--       dgo.acct_assign_id = a.acct_assign_id AND
--       f.fcst_id = i_fcst_id AND
--       dd.mars_week > f.casting_year || f.casting_period || f.casting_week;
    CURSOR csr_demand_data (i_fcst_id IN common.st_id) IS
        SELECT dd.mars_week,
               f.forecast_type,
               f.casting_year,
               f.casting_period,
               f.casting_week,
               NVL (dmnd_plng_node, ' ') dmnd_plng_node,
               NVL (dgo.sales_org, ' ') AS sales_org,
               NVL (dgo.distbn_chnl, ' ') AS distbn_chnl,
               NVL (dgo.cust_div, ' ') AS cust_div,
               dgo.mltplr_code,
               NVL (F.MOE_CODE, ' ') AS MOE_CODE,
               NVL (dgo.bill_to_code, ' ') AS bill_to_code,
               dgo.ship_to_code,
               NVL (dgo.region_code, ' ') AS region_code,
               NVL (c.cntry_code, ' ') AS cntry_code,
               NVL (dgo.multi_mrkt_accnt_code, ' ') AS multi_mrket_accnt_code,
               NVL (dgo.banner_code, ' ') AS banner_code,
               NVL (dgo.cust_buying_group_code, ' ') AS cust_buying_group_code,
               NVL (dgo.pos_frmt_grpng_code, ' ') AS pos_frmt_grpng_code,
               NVL (dgo.dstrbtn_route_code, ' ') AS dstrbtn_route_code,
               NVL (a.acct_assign_code, ' ') AS acct_assign_code,
               NVL (dd.zrep, ' ') AS zrep,
               NVL (dd.tdu, ' ') AS tdu,
               case 
                 when dd.TYPE is null then ' '
                 when dd.type = demand_forecast.gc_dmnd_type_u then demand_forecast.gc_dmnd_type_4 
                 when dd.type = demand_forecast.gc_dmnd_type_b or dd.type = demand_forecast.gc_dmnd_type_p then demand_forecast.gc_dmnd_type_1
                else 
                   dd.TYPE
               end AS TYPE,
               SUM(NVL (dd.gsv, 0)) AS gsv,
               SUM(NVL (dd.qty_in_base_uom, 0)) AS cases,
               NVL (dgo.currcy_code, ' ') AS currcy_code
          FROM dmnd_data dd,
               dmnd_grp dg,
               dmnd_grp_org dgo,
               fcst f,
               dmnd_cntry c,
               dmnd_acct_assign a
         WHERE     dg.dmnd_grp_id = dgo.dmnd_grp_id
               AND dd.dmnd_grp_org_id = dgo.dmnd_grp_org_id
               AND f.fcst_id = dd.fcst_id
               AND dg.cntry_id = c.cntry_id
               AND dgo.acct_assign_id = a.acct_assign_id
               AND f.fcst_id = i_fcst_id
               AND dd.mars_week >
                      f.casting_year || f.casting_period || f.casting_week
         GROUP BY dd.mars_week,
               f.forecast_type,
               f.casting_year,
               f.casting_period,
               f.casting_week,
               NVL (dmnd_plng_node, ' '),
               NVL (dgo.sales_org, ' '),
               NVL (dgo.distbn_chnl, ' '),
               NVL (dgo.cust_div, ' '),
               dgo.mltplr_code,
               NVL (F.MOE_CODE, ' '),
               NVL (dgo.bill_to_code, ' '),
               dgo.ship_to_code,
               NVL (dgo.region_code, ' '),
               NVL (c.cntry_code, ' '),
               NVL (dgo.multi_mrkt_accnt_code, ' '),
               NVL (dgo.banner_code, ' '),
               NVL (dgo.cust_buying_group_code, ' '),
               NVL (dgo.pos_frmt_grpng_code, ' '),
               NVL (dgo.dstrbtn_route_code, ' '),
               NVL (a.acct_assign_code, ' '),
               NVL (dd.zrep, ' '),
               NVL (dd.tdu, ' '),
               case 
                 when dd.TYPE is null then ' '
                 when dd.type = demand_forecast.gc_dmnd_type_u then demand_forecast.gc_dmnd_type_4
                 when dd.type = demand_forecast.gc_dmnd_type_b or dd.type = demand_forecast.gc_dmnd_type_p then demand_forecast.gc_dmnd_type_1
                else 
                  dd.TYPE
               end,
               NVL (dgo.currcy_code, ' ');

    rv_demand_data          csr_demand_data%ROWTYPE;   -- sales forecast cursor
    v_line                  common.st_message_string;   -- A line of data to be written to the output file
    v_message               common.st_message_string;   -- standard procedure call support
    v_result                common.st_result;   -- standard procedure call supprt
    e_file_error            EXCEPTION;   -- exception to deal with file I/O errors.
  BEGIN
    logit.enter_method (pc_package_name, 'EXTRACT_DEMAND_FORECAST');
    -- First close the file to make sure, that it's not open.
    v_result := fileit.close_file (v_message);

    IF fileit.open_file (plan_common.gc_planning_directory, 'send_venus_df_' || TRIM (TO_CHAR (i_fcst_id) ), fileit.gc_file_mode_write, v_message) !=
                                                                                                                                              common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- setup variables ready to write record head to file.
    v_line := '';
    v_head_rec_type := 'CTL';
    v_idoc_name := RPAD ('Z_FORECAST', 30, ' ');
    v_idoc_number := LPAD ('0', 16, '0');
    v_idoc_date := TO_CHAR (SYSDATE, 'YYYYMMDD');
    v_idoc_time := TO_CHAR (SYSDATE, 'HHMISS');
    -- now build record header
    v_line := v_line || v_head_rec_type;
    v_line := v_line || v_idoc_name;
    v_line := v_line || v_idoc_number;
    v_line := v_line || v_idoc_date;
    v_line := v_line || v_idoc_time;

    -- write record header.
    IF fileit.write_file (v_line, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    FOR rv_demand_data IN csr_demand_data (i_fcst_id)   -- loop sales forecast data to write to file.
    LOOP
      -- build up a line of dat
      v_record_type := 'DET';
      v_forecast_type := RPAD (SUBSTR (rv_demand_data.forecast_type, 1, 4), 4, ' ');
      v_version := '1';

      -- Truncate MARS_WEEK to a period for, BR/OP forecasts.
      IF rv_demand_data.forecast_type = demand_forecast.gc_ft_fcst  THEN   -- If forecast is FCST include week, othewise remove.
            v_casting_period :=
                    RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.casting_year || rv_demand_data.casting_period || rv_demand_data.casting_week), 1, 7) ), 7, ' ');
      ELSE
        v_casting_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.casting_year || rv_demand_data.casting_period), 1, 6) ), 7, ' ');
      END IF;

      IF rv_demand_data.mltplr_code = 'ELIMINATION' THEN
        v_demand_planning_node := RPAD (' ', 10, ' ');
      ELSE
        v_demand_planning_node := RPAD (TRIM (SUBSTR(rv_demand_data.dmnd_plng_node,1,10)), 10, ' ');
      END IF;

      v_sales_org := RPAD (SUBSTR (rv_demand_data.sales_org, 1, 4), 4, ' ');
      v_dc := RPAD (SUBSTR (rv_demand_data.distbn_chnl, 1, 2), 2, ' ');
      v_division := SUBSTR (rv_demand_data.cust_div, 1, 2);
      v_currency := RPAD (SUBSTR (rv_demand_data.currcy_code, 1, 3), 3, ' ');

      -- Ship to overwrites Bill to, if present on DMND_GRP record.
      IF rv_demand_data.ship_to_code IS NULL THEN
        v_customer_no := RPAD (rv_demand_data.bill_to_code, 10, ' ');
      ELSE
        v_customer_no := RPAD (rv_demand_data.ship_to_code, 10, ' ');
      END IF;

      --v_customer_no := RPAD (rv_demand_data.bill_to_code, 10, ' ');
      v_region := RPAD (NVL(TRIM (rv_demand_data.region_code),' '), 3, ' ');
      v_country := RPAD (TRIM (rv_demand_data.cntry_code), 3, ' ');
      v_multi_market := RPAD (NVL(TRIM (rv_demand_data.multi_mrket_accnt_code),' '), 30, ' ');
      v_banner := RPAD (NVL(TRIM (rv_demand_data.banner_code),' '), 5, ' ');
      v_buying_group := RPAD (NVL(TRIM (rv_demand_data.cust_buying_group_code), ' '), 30, ' ');
      --      v_pos_format := RPAD (' ', 30, ' ');
      v_pos_format := RPAD (rv_demand_data.pos_frmt_grpng_code, 30, ' ');
      v_dist_route := RPAD (NVL(TRIM (rv_demand_data.dstrbtn_route_code), ' '),3,' ');
      v_account_assign := RPAD (SUBSTR (rv_demand_data.acct_assign_code, 1, 2), 2, ' ');
      v_material_number := RPAD (TRIM (rv_demand_data.zrep), 18, ' ');

      IF rv_demand_data.forecast_type = demand_forecast.gc_ft_fcst THEN   -- If forecast is FCST include week, othewise remove.
        v_forecast_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.mars_week), 1, 7) ), 7, ' ');
      ELSE
        v_forecast_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.mars_week), 1, 6) ), 7, ' ');
      END IF;

      v_gsv := RPAD (SUBSTR (TRIM (TO_CHAR (rv_demand_data.gsv) ), 1, 13), 13, ' ');
      v_qty := RPAD (SUBSTR (TRIM (TO_CHAR (rv_demand_data.cases) ), 1, 13), 13, ' ');

      --v_qty := RPAD (SUBSTR (TRIM (TO_CHAR (rv_demand_data.cases, '9999999999.99') ), 1, 13), 13, ' ');

      v_moe_code := RPAD (SUBSTR (rv_demand_data.moe_code, 1, 4), 4, ' ');

      v_material_code := RPAD(NVL(TRIM(rv_demand_data.tdu),' '),18, ' ');

      v_forecast_dmnd_type := RPAD (NVL(TRIM (rv_demand_data.type),' '), 1, ' ');

      -- Now build the line to be written to file.
      v_line := '';
      v_line := v_record_type;
      v_line := v_line || v_forecast_type;
      v_line := v_line || v_version;
      v_line := v_line || v_casting_period;
      v_line := v_line || v_demand_planning_node;
      v_line := v_line || v_sales_org;
      v_line := v_line || v_moe_code;
      v_line := v_line || v_dc;
      v_line := v_line || v_division;
      v_line := v_line || v_customer_no;
      v_line := v_line || v_region;
      v_line := v_line || v_country;
      v_line := v_line || v_multi_market;
      v_line := v_line || v_banner;
      v_line := v_line || v_buying_group;
      v_line := v_line || v_pos_format;
      v_line := v_line || v_dist_route;
      v_line := v_line || v_account_assign;
      v_line := v_line || v_material_number;
      v_line := v_line || v_material_code;
      v_line := v_line || v_forecast_period;
      v_line := v_line || v_forecast_dmnd_type;
      v_line := v_line || v_gsv;
      v_line := v_line || v_qty;
      v_line := v_line || v_currency;

      -- write line to file.
      IF fileit.write_file (v_line, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;
    END LOOP;

    -- now close the file.
    IF fileit.close_file (v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_file_error THEN
      -- File IO error exception.
      o_result_msg := common.create_failure_msg ('File IO Error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END extract_demand_forecast_new;


  FUNCTION extract_demand_forecast (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_record_type           common.st_code;   -- always 'DET'
    v_forecast_type         common.st_code;   -- read from FCST table.
    v_version               common.st_code;   -- always '1''
    v_casting_period        common.st_code;   -- read from FCST table
    v_sales_org             common.st_code;   -- read from DMND_GRP table, 147
    v_moe_code              common.st_code;   -- read from FCST table
    v_dc                    common.st_code;   -- read from DMND_GRP table, 10,11,99
    v_division              common.st_code;   -- read from DMND_GRP table,
    v_customer_no           common.st_code;   -- SHIP_TO from DMDND_GRP, if not then BILL_TO
    v_region                common.st_code;   --  Always Blank.
    v_country               common.st_code;   -- Country from DMDND_GRP table.
    v_multi_market          VARCHAR (50);     -- Always Blank.
    v_banner                common.st_code;   -- Always Blank.
    v_buying_group          VARCHAR (50);     -- Always Blank.
    v_pos_format            VARCHAR (50);     -- Always Blank.
    v_dist_route            common.st_code;   -- Always Blank.
    v_account_assign        common.st_code;   -- GRD account assign, 01 Domestic, 02 Affilate , 03 Foriegn
    v_demand_planning_node  VARCHAR (10);     -- Demand planning node from the DMND_GRP table.
    v_material_number       common.st_code;   -- ZREP
    v_forecast_period       common.st_code;   -- Marsweek if standard FCST otherwise PERIOD for BR,OP
    v_gsv                   common.st_code;   -- Gross Sales Value
    v_qty                   common.st_code;   -- Total Qty sold, Base unit of measure.
    v_currency              common.st_code;   -- done
    v_head_rec_type         common.st_code;   -- 'CTL' , , header record
    v_idoc_name             VARCHAR (50);     -- 'Z_FORECAST' , header record
    v_idoc_number           common.st_code;   -- Always '0'' , header record
    v_idoc_date             common.st_code;   -- sysdate, header record.
    v_idoc_time             common.st_code;   -- systime, header record.
    v_material_code         common.st_code;   -- TDU
    v_forecast_dmnd_type    common.st_code;   -- forecast demand type, 1,2,3 etc


    -- Main cursor to retreive sales forecast information for a given forecast.
--    CURSOR csr_demand_data (i_fcst_id IN common.st_id) IS
--      SELECT dd.mars_week, f.forecast_type, f.casting_year, f.casting_period, f.casting_week, NVL (dmnd_plng_node, ' ') dmnd_plng_node,
--        NVL (dgo.sales_org, ' ') AS sales_org, NVL (dgo.distbn_chnl, ' ') AS distbn_chnl, NVL (dgo.cust_div, ' ') AS cust_div, dgo.mltplr_code,
--        NVL(F.MOE_CODE, ' ') AS MOE_CODE, NVL (dgo.bill_to_code, ' ') AS bill_to_code, dgo.ship_to_code, NVL (dgo.region_code, ' ') as region_code,
--        NVL (c.cntry_code, ' ') AS cntry_code, NVL (dgo.multi_mrkt_accnt_code, ' ') as multi_mrket_accnt_code, NVL (dgo.banner_code, ' ') as banner_code,
--        NVL (dgo.cust_buying_group_code, ' ') as cust_buying_group_code, NVL (dgo.pos_frmt_grpng_code, ' ') AS pos_frmt_grpng_code, NVL (dgo.dstrbtn_route_code, ' ') as dstrbtn_route_code,
--        NVL (a.acct_assign_code, ' ') AS acct_assign_code, NVL (dd.zrep, ' ') AS zrep, NVL (dd.tdu, ' ') AS tdu, NVL (dd.TYPE, ' ') AS type,
--        NVL (dd.gsv, 0) AS gsv, NVL (dd.qty_in_base_uom, 0) AS cases, NVL (dgo.currcy_code, ' ') AS currcy_code
--      FROM dmnd_data dd, dmnd_grp dg, dmnd_grp_org dgo, fcst f, dmnd_cntry c, dmnd_acct_assign a
--      WHERE dg.dmnd_grp_id = dgo.dmnd_grp_id AND
--       dd.dmnd_grp_org_id = dgo.dmnd_grp_org_id AND
--       f.fcst_id = dd.fcst_id AND
--       dg.cntry_id = c.cntry_id AND
--       dgo.acct_assign_id = a.acct_assign_id AND
--       f.fcst_id = i_fcst_id AND
--       dd.mars_week > f.casting_year || f.casting_period || f.casting_week;
    CURSOR csr_demand_data (i_fcst_id IN common.st_id) IS
        SELECT dd.mars_week,
               f.forecast_type,
               f.casting_year,
               f.casting_period,
               f.casting_week,
               NVL (dmnd_plng_node, ' ') dmnd_plng_node,
               NVL (dgo.sales_org, ' ') AS sales_org,
               NVL (dgo.distbn_chnl, ' ') AS distbn_chnl,
               NVL (dgo.cust_div, ' ') AS cust_div,
               dgo.mltplr_code,
               NVL (F.MOE_CODE, ' ') AS MOE_CODE,
               NVL (dgo.bill_to_code, ' ') AS bill_to_code,
               dgo.ship_to_code,
               NVL (dgo.region_code, ' ') AS region_code,
               NVL (c.cntry_code, ' ') AS cntry_code,
               NVL (dgo.multi_mrkt_accnt_code, ' ') AS multi_mrket_accnt_code,
               NVL (dgo.banner_code, ' ') AS banner_code,
               NVL (dgo.cust_buying_group_code, ' ') AS cust_buying_group_code,
               NVL (dgo.pos_frmt_grpng_code, ' ') AS pos_frmt_grpng_code,
               NVL (dgo.dstrbtn_route_code, ' ') AS dstrbtn_route_code,
               NVL (a.acct_assign_code, ' ') AS acct_assign_code,
               NVL (dd.zrep, ' ') AS zrep,
               NVL (dd.tdu, ' ') AS tdu,
              case 
                 when dd.TYPE is null then ' '
                 when dd.type = demand_forecast.gc_dmnd_type_u then demand_forecast.gc_dmnd_type_4 
                 when dd.type = demand_forecast.gc_dmnd_type_b or dd.type = demand_forecast.gc_dmnd_type_p then demand_forecast.gc_dmnd_type_1
                else 
                   dd.TYPE
               end AS TYPE,
               SUM(NVL (dd.gsv, 0)) AS gsv,
               SUM(NVL (dd.qty_in_base_uom, 0)) AS cases,
               NVL (dgo.currcy_code, ' ') AS currcy_code
          FROM dmnd_data dd,
               dmnd_grp dg,
               dmnd_grp_org dgo,
               fcst f,
               dmnd_cntry c,
               dmnd_acct_assign a
         WHERE     dg.dmnd_grp_id = dgo.dmnd_grp_id
               AND dd.dmnd_grp_org_id = dgo.dmnd_grp_org_id
               AND f.fcst_id = dd.fcst_id
               AND dg.cntry_id = c.cntry_id
               AND dgo.acct_assign_id = a.acct_assign_id
               AND f.fcst_id = i_fcst_id
               AND dd.mars_week >
                      f.casting_year || f.casting_period || f.casting_week
         GROUP BY dd.mars_week,
               f.forecast_type,
               f.casting_year,
               f.casting_period,
               f.casting_week,
               NVL (dmnd_plng_node, ' '),
               NVL (dgo.sales_org, ' '),
               NVL (dgo.distbn_chnl, ' '),
               NVL (dgo.cust_div, ' '),
               dgo.mltplr_code,
               NVL (F.MOE_CODE, ' '),
               NVL (dgo.bill_to_code, ' '),
               dgo.ship_to_code,
               NVL (dgo.region_code, ' '),
               NVL (c.cntry_code, ' '),
               NVL (dgo.multi_mrkt_accnt_code, ' '),
               NVL (dgo.banner_code, ' '),
               NVL (dgo.cust_buying_group_code, ' '),
               NVL (dgo.pos_frmt_grpng_code, ' '),
               NVL (dgo.dstrbtn_route_code, ' '),
               NVL (a.acct_assign_code, ' '),
               NVL (dd.zrep, ' '),
               NVL (dd.tdu, ' '),
               case 
                 when dd.TYPE is null then ' '
                 when dd.type = demand_forecast.gc_dmnd_type_u then demand_forecast.gc_dmnd_type_4 
                 when dd.type = demand_forecast.gc_dmnd_type_b or dd.type = demand_forecast.gc_dmnd_type_p then demand_forecast.gc_dmnd_type_1
                else 
                   dd.TYPE
               end,
               NVL (dgo.currcy_code, ' ');

    rv_demand_data          csr_demand_data%ROWTYPE;   -- sales forecast cursor
    v_line                  common.st_message_string;   -- A line of data to be written to the output file
    v_message               common.st_message_string;   -- standard procedure call support
    v_result                common.st_result;   -- standard procedure call supprt
    e_file_error            EXCEPTION;   -- exception to deal with file I/O errors.
  BEGIN
    logit.enter_method (pc_package_name, 'EXTRACT_DEMAND_FORECAST');
    -- First close the file to make sure, that it's not open.
    v_result := fileit.close_file (v_message);

    IF fileit.open_file (plan_common.gc_planning_directory, 'send_venus_df_' || TRIM (TO_CHAR (i_fcst_id) ), fileit.gc_file_mode_write, v_message) !=
                                                                                                                                              common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- setup variables ready to write record head to file.
    v_line := '';
    v_head_rec_type := 'CTL';
    v_idoc_name := RPAD ('Z_FORECAST', 30, ' ');
    v_idoc_number := LPAD ('0', 16, '0');
    v_idoc_date := TO_CHAR (SYSDATE, 'YYYYMMDD');
    v_idoc_time := TO_CHAR (SYSDATE, 'HHMISS');
    -- now build record header
    v_line := v_line || v_head_rec_type;
    v_line := v_line || v_idoc_name;
    v_line := v_line || v_idoc_number;
    v_line := v_line || v_idoc_date;
    v_line := v_line || v_idoc_time;

    -- write record header.
    IF fileit.write_file (v_line, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    FOR rv_demand_data IN csr_demand_data (i_fcst_id)   -- loop sales forecast data to write to file.
    LOOP
      -- build up a line of dat
      v_record_type := 'DET';
      v_forecast_type := RPAD (SUBSTR (rv_demand_data.forecast_type, 1, 4), 4, ' ');
      v_version := '1';

      -- Truncate MARS_WEEK to a period for, BR/OP forecasts.
      IF rv_demand_data.forecast_type = demand_forecast.gc_ft_fcst  THEN   -- If forecast is FCST include week, othewise remove.
            v_casting_period :=
                    RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.casting_year || rv_demand_data.casting_period || rv_demand_data.casting_week), 1, 7) ), 7, ' ');
      ELSE
        v_casting_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.casting_year || rv_demand_data.casting_period), 1, 6) ), 7, ' ');
      END IF;

      IF rv_demand_data.mltplr_code = 'ELIMINATION' THEN
        v_demand_planning_node := RPAD (' ', 10, ' ');
      ELSE
        v_demand_planning_node := RPAD (TRIM (SUBSTR(rv_demand_data.dmnd_plng_node,1,10)), 10, ' ');
      END IF;

      v_sales_org := RPAD (SUBSTR (rv_demand_data.sales_org, 1, 4), 4, ' ');
      v_dc := RPAD (SUBSTR (rv_demand_data.distbn_chnl, 1, 2), 2, ' ');
      v_division := SUBSTR (rv_demand_data.cust_div, 1, 2);
      v_currency := RPAD (SUBSTR (rv_demand_data.currcy_code, 1, 3), 3, ' ');

      -- Ship to overwrites Bill to, if present on DMND_GRP record.
      IF rv_demand_data.ship_to_code IS NULL THEN
        v_customer_no := RPAD (rv_demand_data.bill_to_code, 10, ' ');
      ELSE
        v_customer_no := RPAD (rv_demand_data.ship_to_code, 10, ' ');
      END IF;

      --v_customer_no := RPAD (rv_demand_data.bill_to_code, 10, ' ');
      v_region := RPAD (NVL(TRIM (rv_demand_data.region_code),' '), 3, ' ');
      v_country := RPAD (TRIM (rv_demand_data.cntry_code), 3, ' ');
      v_multi_market := RPAD (NVL(TRIM (rv_demand_data.multi_mrket_accnt_code),' '), 30, ' ');
      v_banner := RPAD (NVL(TRIM (rv_demand_data.banner_code),' '), 5, ' ');
      v_buying_group := RPAD (NVL(TRIM (rv_demand_data.cust_buying_group_code), ' '), 30, ' ');
      --      v_pos_format := RPAD (' ', 30, ' ');
      v_pos_format := RPAD (rv_demand_data.pos_frmt_grpng_code, 30, ' ');
      v_dist_route := RPAD (NVL(TRIM (rv_demand_data.dstrbtn_route_code), ' '),3,' ');
      v_account_assign := RPAD (SUBSTR (rv_demand_data.acct_assign_code, 1, 2), 2, ' ');
      v_material_number := RPAD (TRIM (rv_demand_data.zrep), 18, ' ');

      IF rv_demand_data.forecast_type = demand_forecast.gc_ft_fcst THEN   -- If forecast is FCST include week, othewise remove.
        v_forecast_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.mars_week), 1, 7) ), 7, ' ');
      ELSE
        v_forecast_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_demand_data.mars_week), 1, 6) ), 7, ' ');
      END IF;

      v_gsv := RPAD (SUBSTR (TRIM (TO_CHAR (rv_demand_data.gsv) ), 1, 13), 13, ' ');
      v_qty := RPAD (SUBSTR (TRIM (TO_CHAR (rv_demand_data.cases) ), 1, 13), 13, ' ');

      --v_qty := RPAD (SUBSTR (TRIM (TO_CHAR (rv_demand_data.cases, '9999999999.99') ), 1, 13), 13, ' ');

      v_moe_code := RPAD (SUBSTR (rv_demand_data.moe_code, 1, 4), 4, ' ');

      v_material_code := RPAD(NVL(TRIM(rv_demand_data.tdu),' '),18, ' ');

      v_forecast_dmnd_type := RPAD (NVL(TRIM (rv_demand_data.type),' '), 1, ' ');

      -- Now build the line to be written to file.
      v_line := '';
      v_line := v_record_type;
      v_line := v_line || v_forecast_type;
      v_line := v_line || v_version;
      v_line := v_line || v_casting_period;
      v_line := v_line || v_demand_planning_node;
      v_line := v_line || v_sales_org;
      v_line := v_line || v_moe_code;
      v_line := v_line || v_dc;
      v_line := v_line || v_division;
      v_line := v_line || v_customer_no;
      v_line := v_line || v_region;
      v_line := v_line || v_country;
      v_line := v_line || v_multi_market;
      v_line := v_line || v_banner;
      v_line := v_line || v_buying_group;
      v_line := v_line || v_pos_format;
      v_line := v_line || v_dist_route;
      v_line := v_line || v_account_assign;
      v_line := v_line || v_material_number;
      v_line := v_line || v_material_code;
      v_line := v_line || v_forecast_period;
      v_line := v_line || v_forecast_dmnd_type;
      v_line := v_line || v_gsv;
      v_line := v_line || v_qty;
      v_line := v_line || v_currency;

      -- write line to file.
      IF fileit.write_file (v_line, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;
    END LOOP;

    -- now close the file.
    IF fileit.close_file (v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_file_error THEN
      -- File IO error exception.
      o_result_msg := common.create_failure_msg ('File IO Error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END extract_demand_forecast;

  FUNCTION extract_production_plan (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_record_type      common.st_code;   -- Always 'DET''
    v_forecast_type    common.st_code;   -- Forecast type, read from FCST table.
    v_moe_code         common.st_code;    -- MOE code from FCST table.
    v_casting_period   common.st_code;   -- Casting period, read from FCST table.
    v_plant_code       common.st_code;   -- Plant code from production plan table.
    v_material_number  common.st_code;   -- TDU from production plan table.
    v_forecast_period  common.st_code;   -- MARS week forecast for.
    v_qty              VARCHAR (50);   -- Amount forecast.
    v_head_rec_type    common.st_code;   -- 'CTL' always CTL. , header record
    v_rec_count        common.st_counter;   --  Total number of records withing file, written to end of file.
    v_qty_total        NUMBER;   --  Total for the entire forecast, written to end of file.
    v_idoc_name        VARCHAR (50);   --  Z_FORECAST always, header record.
    v_idoc_number      common.st_code;   --  '0' , Always , header record.
    v_idoc_date        common.st_code;   --  sysdate, header record.
    v_idoc_time        common.st_code;   -- systime, header record

    -- Main cursor to retrieve production plan information for a give forecast.
    CURSOR csr_pp_data (i_fcst_id IN common.st_id) IS
      SELECT NVL (pp.qty_in_base_uom, 0) qty_in_base_uom, NVL (pp.tdu, ' ') tdu, NVL (pp.plant_code, ' ') plant_code, pp.mars_week, f.forecast_type, f.moe_code,
        f.casting_year, f.casting_period, f.casting_week
      FROM prodn_plan_data pp, fcst f
      WHERE f.fcst_id = pp.fcst_id AND f.fcst_id = i_fcst_id;

    rv_pp_data         csr_pp_data%ROWTYPE;   -- record type
    v_line             common.st_message_string;   -- complete line of data to be written to the file.
    v_message          common.st_message_string;   -- standard procedure return, variable.
    v_result           common.st_result;   -- standard procedure return. variable.
    e_file_error       EXCEPTION;   -- exception handler for file IO error.
  BEGIN
    -- start processing
    logit.enter_method (pc_package_name, 'EXTRACT_PRODUCTION_PLAN');
    -- close file incase already open.
    v_result := fileit.close_file (v_message);

    -- try to open file.
    IF fileit.open_file (plan_common.gc_planning_directory, 'send_venus_pp_' || TRIM (TO_CHAR (i_fcst_id) ), fileit.gc_file_mode_write, v_message) !=
                                                                                                                                              common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- Zrero records count.
    logit.LOG ('Set Record type');
    logit.LOG ('Now reset counters');
    v_rec_count := 0;
    v_qty_total := 0;

    -- Main loop write a line to the output file for each record within the cursor.
    FOR rv_pp_data IN csr_pp_data (i_fcst_id)
    LOOP
      IF v_rec_count = 0 THEN   -- if the first record then write the header record.
        -- build the header record, first line.
        v_line := '';
        v_head_rec_type := 'CTL';
        v_idoc_name := RPAD ('Z_FORECAST', 30, ' ');
        v_idoc_number := LPAD ('0', 16, '0');
        v_idoc_date := TO_CHAR (SYSDATE, 'YYYYMMDD');
        v_idoc_time := TO_CHAR (SYSDATE, 'HHMISS');
        v_line := v_line || v_head_rec_type;
        v_line := v_line || v_idoc_name;
        v_line := v_line || v_idoc_number;
        v_line := v_line || v_idoc_date;
        v_line := v_line || v_idoc_time;

        -- write the head record , first line,
        IF fileit.write_file (v_line, v_message) != common.gc_success THEN
          RAISE e_file_error;
        END IF;

        -- build the header record, second line.
        v_line := '';
        v_head_rec_type := 'HDR';
        v_forecast_type := RPAD (SUBSTR (rv_pp_data.forecast_type, 1, 4), 4, ' ');
        v_moe_code := rv_pp_data.moe_code;

        -- if forecast is FCST , write MARS_WEEK, otherwise write the period for OP,ROB
        IF rv_pp_data.forecast_type = demand_forecast.gc_ft_fcst THEN
          v_casting_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_pp_data.casting_year || rv_pp_data.casting_period || rv_pp_data.casting_week), 1, 7) ), 7, ' ');
        ELSE
          v_casting_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_pp_data.casting_year || rv_pp_data.casting_period), 1, 6) ), 7, ' ');
        END IF;

        v_line := v_head_rec_type;
        v_line := v_line || v_forecast_type;
        v_line := v_line || v_moe_code;
        v_line := v_line || v_casting_period;
        -- write head record.
        logit.LOG ('Now write header record');

        IF fileit.write_file (v_line, v_message) != common.gc_success THEN
          RAISE e_file_error;
        END IF;
      END IF;

      -- Build a line for writing to flat file.
      v_record_type := 'DET';
      v_forecast_period := RPAD (TRIM (rv_pp_data.mars_week), 7, ' ');
      v_material_number := RPAD (TRIM (rv_pp_data.tdu), 18, ' ');
      v_qty := RPAD (SUBSTR (TRIM (TO_CHAR (rv_pp_data.qty_in_base_uom, '9999999999999999999.99') ), 1, 22), 22, ' ');
      v_plant_code := RPAD (TRIM (rv_pp_data.plant_code), 4, ' ');
      v_line := '';
      v_line := v_record_type;
      v_line := v_line || v_forecast_period;
      v_line := v_line || v_material_number;
      v_line := v_line || v_plant_code;
      v_line := v_line || v_qty;

      -- Write a line to the flat file.
      IF fileit.write_file (v_line, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      -- update the trailor record totals.
      v_qty_total := v_qty_total + rv_pp_data.qty_in_base_uom;
      v_rec_count := v_rec_count + 1;
    END LOOP;

    -- end of main loop.  now write trailor records.
    v_line := 'REC' || RPAD (SUBSTR (TRIM (TO_CHAR (v_rec_count, '9999999999999') ), 1, 13), 13, ' ');

    IF fileit.write_file (v_line, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    v_line := 'QTY' || RPAD (SUBSTR (TRIM (TO_CHAR (v_qty_total, '9999999999.99') ), 1, 13), 13, ' ');

    IF fileit.write_file (v_line, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- process complete , so close file.
    IF fileit.close_file (v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_file_error THEN
      -- FILE IO exception handler.
      o_result_msg := common.create_failure_msg ('File IO Error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exception error handler.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END extract_production_plan;

  FUNCTION extract_inventory_forecast (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    v_record_type      common.st_code;   -- Always 'DET''
    v_forecast_type    common.st_code;   -- Forecast type, read from FCST table.
    v_casting_period   common.st_code;   -- Casting period, read from FCST table.
    v_plant_code       common.st_code;   -- Plant code from projected inventory table.
    v_material_number  common.st_code;   -- TDU from projected inventory table.
    v_forecast_period  common.st_code;   -- MARS week forecast for.
    v_qty              VARCHAR (50);   -- Amount forecast.
    v_head_rec_type    common.st_code;   -- 'CTL' always CTL. , header record
    v_rec_count        common.st_counter;   --  Total number of records withing file, written to end of file.
    v_qty_total        NUMBER;   --  Total for the entire forecast, written to end of file.
    v_idoc_name        VARCHAR (50);   --  Z_FORECAST always, header record.
    v_idoc_number      common.st_code;   --  '0' , Always , header record.
    v_idoc_date        common.st_code;   --  sysdate, header record.
    v_idoc_time        common.st_code;   -- systime, header record

    -- main cursor to retrive inventory information.
    CURSOR csr_inv_data (i_fcst_id IN common.st_id) IS
      SELECT NVL (inv.qty_in_base_uom, 0) qty_in_base_uom, NVL (inv.tdu, ' ') tdu, NVL (inv.plant_code, ' ') plant_code, inv.mars_week, f.forecast_type,
        f.casting_year, f.casting_period, f.casting_week
      FROM inv_fcst_data inv, fcst f
      WHERE f.fcst_id = inv.fcst_id AND f.fcst_id = i_fcst_id;

    rv_inv_data        csr_inv_data%ROWTYPE;
    v_line             common.st_message_string;   -- complete line of data to be written to the file.
    v_message          common.st_message_string;   -- standard procedure return, variable.
    v_result           common.st_result;   -- standard procedure return. variable.
    e_file_error       EXCEPTION;   -- exception handler for file IO error.
  BEGIN
    logit.enter_method (pc_package_name, 'EXTRACT_INVENTORY_FORECAST');
    -- close file , just incase file is open.
    v_result := fileit.close_file (v_message);

    -- open flat file read to write data.
    IF fileit.open_file (plan_common.gc_planning_directory, 'send_venus_if_' || TRIM (TO_CHAR (i_fcst_id) ), fileit.gc_file_mode_write, v_message) !=
                                                                                                                                              common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- reset trailor record totals.
    logit.LOG ('Set Record type');
    logit.LOG ('Now reset counters');
    v_rec_count := 0;
    v_qty_total := 0;

    -- loop main data and write a line of data for each row within the cursor.
    FOR rv_inv_data IN csr_inv_data (i_fcst_id)
    LOOP
      IF v_rec_count = 0 THEN   -- if this is the first record, then write the head record.
        -- build first line of header record.
        v_line := '';
        v_head_rec_type := 'CTL';
        v_idoc_name := RPAD ('Z_FORECAST', 30, ' ');
        v_idoc_number := LPAD ('0', 16, '0');
        v_idoc_date := TO_CHAR (SYSDATE, 'YYYYMMDD');
        v_idoc_time := TO_CHAR (SYSDATE, 'HHMISS');
        v_line := v_line || v_head_rec_type;
        v_line := v_line || v_idoc_name;
        v_line := v_line || v_idoc_number;
        v_line := v_line || v_idoc_date;
        v_line := v_line || v_idoc_time;

        -- Write this line to the file.
        IF fileit.write_file (v_line, v_message) != common.gc_success THEN
          RAISE e_file_error;
        END IF;

        -- build second line of header record.
        v_line := '';
        v_head_rec_type := 'HDR';
        v_forecast_type := RPAD (SUBSTR (rv_inv_data.forecast_type, 1, 4), 4, ' ');

        -- If this forecast is a FCST type, then write MARSWEEK, otherwise truncate to PERIOD.
        IF rv_inv_data.forecast_type = demand_forecast.gc_ft_fcst THEN
          v_casting_period :=
                             RPAD (TRIM (SUBSTR (TO_CHAR (rv_inv_data.casting_year || rv_inv_data.casting_period || rv_inv_data.casting_week), 1, 7) ), 7, ' ');
        ELSE
          v_casting_period := RPAD (TRIM (SUBSTR (TO_CHAR (rv_inv_data.casting_year || rv_inv_data.casting_period), 1, 6) ), 7, ' ');
        END IF;

        v_line := v_head_rec_type;
        v_line := v_line || v_forecast_type;
        v_line := v_line || v_casting_period;
        logit.LOG ('Now write header record');

        -- write second line of header record to the file.
        IF fileit.write_file (v_line, v_message) != common.gc_success THEN
          RAISE e_file_error;
        END IF;
      END IF;

      -- Now build a standard line, and write this to the file.
      v_record_type := 'DET';
      v_forecast_period := RPAD (TRIM (rv_inv_data.mars_week), 7, ' ');
      v_material_number := RPAD (TRIM (rv_inv_data.tdu), 18, ' ');
      v_qty := RPAD (SUBSTR (TRIM (TO_CHAR (rv_inv_data.qty_in_base_uom, '9999999999999999999.99') ), 1, 22), 22, ' ');
      v_plant_code := RPAD (TRIM (rv_inv_data.plant_code), 4, ' ');
      v_line := '';
      v_line := v_record_type;
      v_line := v_line || v_forecast_period;
      v_line := v_line || v_material_number;
      v_line := v_line || v_plant_code;
      v_line := v_line || v_qty;

      -- write a line of data to the output file.
      IF fileit.write_file (v_line, v_message) != common.gc_success THEN
        RAISE e_file_error;
      END IF;

      -- increment totals. for trailor record.
      v_qty_total := v_qty_total + rv_inv_data.qty_in_base_uom;
      v_rec_count := v_rec_count + 1;
    END LOOP;

    -- Now build Trailor record.
    v_line := 'REC' || RPAD (SUBSTR (TRIM (TO_CHAR (v_rec_count, '9999999999999') ), 1, 13), 13, ' ');

    -- write first line of trailor record.
    IF fileit.write_file (v_line, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    -- write second line of trailor record.
    v_line := 'QTY' || RPAD (SUBSTR (TRIM (TO_CHAR (v_qty_total, '9999999999.99') ), 1, 13), 13, ' ');

    IF fileit.write_file (v_line, v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    IF fileit.close_file (v_message) != common.gc_success THEN
      RAISE e_file_error;
    END IF;

    logit.leave_method;
    RETURN common.gc_success;
  EXCEPTION
    WHEN e_file_error THEN
      -- File IO error, exception hander.
      o_result_msg := common.create_failure_msg ('File IO Error:' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END extract_inventory_forecast;

  FUNCTION send_demand_forecast (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    e_execute_failure   EXCEPTION;   -- unix command execute error
    e_system_parameter  EXCEPTION;   -- failed to get system parameter
    v_message           common.st_message_string;
    v_unix_path         common.st_message_string;
    v_filename          common.st_message_string;
    v_mq_source_qmgr       common.st_message_string;
    v_mq_target_qmgr    common.st_message_string;
    v_mq_target_file    common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'SEND_DEMAND_FORECAST');

    IF system_params.get_parameter_text (plan_common.gc_system_code, plan_common.gc_unix_path_code, v_unix_path, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_df_source_mq_code, v_mq_source_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_df_target_mq_code, v_mq_target_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_df_target_filename, v_mq_target_file, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    v_filename := v_unix_path || 'oracle/send_venus_df_' || TRIM (TO_CHAR (i_fcst_id) );

    -- execute unix command to send file to fpps demand forecast.
    IF fileit.execute_command (v_unix_path || 'bin/send_mqft_file.sh ' || v_filename || ' ' || v_mq_source_qmgr || ' ' || v_mq_target_qmgr || ' ' || v_mq_target_file, v_message) != common.gc_success THEN
      LOGIT.LOG_ERROR('execution failed:'||v_unix_path || 'bin/send_mqft_file.sh ' || v_filename || ' ' || v_mq_source_qmgr || ' ' || v_mq_target_qmgr || ' ' || v_mq_target_file);
      RAISE e_execute_failure;
    END IF;

    RETURN common.gc_success;
  EXCEPTION
    WHEN e_system_parameter THEN
      o_result_msg := common.create_failure_msg ('System parameter recall failed. ' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_execute_failure THEN
      -- unix command failed for some reason, maybe no files with specified wildcard were found.
      o_result_msg := common.create_failure_msg ('Unix execute failed.');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception. ') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END send_demand_forecast;

  FUNCTION send_production_plan (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    e_execute_failure   EXCEPTION;   -- unix command execute error
    e_system_parameter  EXCEPTION;   -- failed to get system parameter
    v_message           common.st_message_string;
    v_unix_path         common.st_message_string;
    v_filename          common.st_message_string;
    v_mq_source_qmgr       common.st_message_string;
    v_mq_target_qmgr    common.st_message_string;
    v_mq_target_file    common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'SEND_PRODUCTION_PLAN');

    IF system_params.get_parameter_text (plan_common.gc_system_code, plan_common.gc_unix_path_code, v_unix_path, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_pp_source_mq_code, v_mq_source_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_pp_target_mq_code, v_mq_target_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_pp_target_filename, v_mq_target_file, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    v_filename := v_unix_path || 'oracle/send_venus_pp_' || TRIM (TO_CHAR (i_fcst_id) );

    -- execute unix command to send file to fpps demand forecast.
    IF fileit.execute_command (v_unix_path || 'bin/send_mqft_file.sh ' || v_filename || ' ' || v_mq_source_qmgr || ' ' || v_mq_target_qmgr || ' ' || v_mq_target_file, v_message) != common.gc_success THEN
      RAISE e_execute_failure;
    END IF;

    RETURN common.gc_success;
  EXCEPTION
    WHEN e_system_parameter THEN
      o_result_msg := common.create_failure_msg ('System parameter recall failed. ' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_execute_failure THEN
      -- unix command failed for some reason,
      o_result_msg := common.create_failure_msg ('Unix execute failed');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END send_production_plan;

  FUNCTION send_inventory_forecast (i_fcst_id IN common.st_id, o_result_msg OUT common.st_message_string)
    RETURN common.st_result AS
    e_execute_failure   EXCEPTION;   -- unix command execute error
    e_system_parameter  EXCEPTION;   -- failed to get system parameter
    v_message           common.st_message_string;
    v_unix_path         common.st_message_string;
    v_filename          common.st_message_string;
    v_mq_source_qmgr    common.st_message_string;
    v_mq_target_qmgr    common.st_message_string;
    v_mq_target_file    common.st_message_string;
  BEGIN
    logit.enter_method (pc_package_name, 'SEND_INVENTORY_FORECAST');

    IF system_params.get_parameter_text (plan_common.gc_system_code, plan_common.gc_unix_path_code, v_unix_path, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_if_source_mq_code, v_mq_source_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_if_target_mq_code, v_mq_target_qmgr, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    IF system_params.get_parameter_text (demand_forecast.gc_system_code, pc_venus_if_target_filename, v_mq_target_file, v_message) != common.gc_success THEN
      RAISE e_system_parameter;
    END IF;

    v_filename := v_unix_path || 'oracle/send_venus_if_' || TRIM (TO_CHAR (i_fcst_id) );

    -- execute unix command to send file to fpps demand forecast.
    IF fileit.execute_command (v_unix_path || 'bin/send_mqft_file.sh ' || v_filename || ' ' || v_mq_source_qmgr || ' ' || v_mq_target_qmgr || ' ' || v_mq_target_file, v_message) != common.gc_success THEN
      RAISE e_execute_failure;
    END IF;

    RETURN common.gc_success;
  EXCEPTION
    WHEN e_system_parameter THEN
      o_result_msg := common.create_failure_msg ('System parameter recall failed. ' || v_message);
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN e_execute_failure THEN
      -- unix command failed for some reason
      o_result_msg := common.create_failure_msg ('Unix execute failed.');
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_failure;
    WHEN OTHERS THEN
      -- unhandled exceptions.
      o_result_msg := common.create_error_msg ('Unhandled exception.') || common.create_sql_error_msg ();
      logit.LOG (o_result_msg);
      logit.leave_method;
      RETURN common.gc_error;
  END send_inventory_forecast;
END extract_venus;