/******************/
/* Package Header */
/******************/
create or replace package dw_scheduled_forecast as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_scheduled_forecast
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Scheduled Forecast

    This package contain the scheduled forecast procedures. The package exposes one
    procedure EXECUTE that performs the forecast aggregation based on the following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the forecast aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_SCHEDULED_FORECAST where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All base tables will attempt to be aggregated and and errors logged.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2010/12   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2, par_date in date default null);

end dw_scheduled_forecast;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_scheduled_forecast as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure fcst_fact_load(par_company_code in varchar2, par_date in date);
   procedure demand_plng_fcst_fact_load(par_company_code in varchar2, par_date in date);
   procedure dcs_order_fact_load(par_company_code in varchar2, par_date in date);
   procedure fcst_region_fact_load(par_company_code in varchar2, par_date in date);
   procedure reload_fcst_region_fact(par_company_code in varchar2, par_moe_code in varchar2, par_reload_yyyypp in number);
   function get_mars_period(par_date in date, par_offset_days in number) return number;

   /*-*/
   /* Private constants
   /*-*/
   pc_fcst_dtl_typ_dfn_adj        constant varchar2(1) := '0';
   pc_fcst_dtl_typ_base           constant varchar2(1) := '1';
   pc_fcst_dtl_typ_aggr_mkt_act   constant varchar2(1) := '2';
   pc_fcst_dtl_typ_lock           constant varchar2(1) := '3';
   pc_fcst_dtl_typ_rcncl          constant varchar2(1) := '4';
   pc_fcst_dtl_typ_auto_adj       constant varchar2(1) := '5';
   pc_fcst_dtl_typ_override       constant varchar2(1) := '6';
   pc_fcst_dtl_typ_mkt_act        constant varchar2(1) := '7';
   pc_fcst_dtl_typ_data_driven    constant varchar2(1) := '8';
   pc_fcst_dtl_typ_tgt_imapct     constant varchar2(1) := '9';
   
   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_company in varchar2, par_date in date default null) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;
      var_company_code company.company_code%type;
      var_company_currcy company.company_currcy%type;
      var_date date;
      var_process_date varchar2(8);
      var_process_code varchar2(32);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Scheduled Forecast';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = par_company;
      rcd_company csr_company%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'DW - SCHEDULED_FORECAST';
      var_log_search := 'DW_SCHEDULED_FORECAST' || '_' || lics_stream_processor.callback_event;
      var_loc_string := lics_stream_processor.callback_lock;
      var_alert := lics_stream_processor.callback_alert;
      var_email := lics_stream_processor.callback_email;
      var_errors := false;
      var_locked := false;
      if var_loc_string is null then
         raise_application_error(-20000, 'Stream lock not returned - must be executed from the ICS Stream Processor');
      end if;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_company) is null then
         raise_application_error(-20000, 'Company parameter must be supplied');
      end if;
      open csr_company;
      fetch csr_company into rcd_company;
      if csr_company%notfound then
         raise_application_error(-20000, 'Company ' || par_company || ' not found on the company table');
      end if;
      close csr_company;
      var_company_code := rcd_company.company_code;
      var_company_currcy := rcd_company.company_currcy;
      var_process_code := 'SCHEDULED_FORECAST_'||var_company_code;

      /*-*/
      /* Aggregation date is always based on the previous day when not supplied (converted using the company timezone)
      /*-*/
      if par_date is null then
         var_date := trunc(sysdate);
         var_process_date := to_char(var_date-1,'yyyymmdd');
         if rcd_company.company_timezone_code != 'Australia/NSW' then
            var_date := dw_to_timezone(trunc(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')),'Australia/NSW',rcd_company.company_timezone_code);
            var_process_date := to_char(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')-1,'yyyymmdd');
         end if;
      else
         var_date := trunc(par_date);
         var_process_date := to_char(var_date,'yyyymmdd');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Scheduled Forecast - Parameters(' || var_company_code || ' + ' || to_char(var_date,'yyyy/mm/dd') || ' + ' || to_char(to_date(var_process_date,'yyyymmdd'),'yyyy/mm/dd') || ')');

      /*-*/
      /* Request the lock on the aggregation
      /*-*/
      begin
         lics_locking.request(var_loc_string);
         var_locked := true;
      exception
         when others then
            var_errors := true;
            lics_logging.write_log(substr(SQLERRM, 1, 1024));
      end;

      /*-*/
      /* Execute the requested procedures
      /* **note** these procedures must be executed in this exact sequence
      /*-*/
      if var_locked = true then

         /*-*/
         /* FCST_FACT load
         /*-*/
         begin
            fcst_fact_load(var_company_code, var_date);
         exception
            when others then
               var_errors := true;
         end;
         
         /*-*/
         /* Set the scheduled forecast trace for the current company and date when required
         /* **note** Only FCST_FACT load required to trigger the data mart loading
         /*-*/
         if var_errors = false then
            lics_logging.write_log('Set the stream process - ('||var_process_code||' / '||var_process_date||')');
            lics_processing.set_trace(var_process_code, var_process_date);
         end if;

         /*-*/
         /* DEMAND_PLNG_FCST_FACT load
         /*-*/
         begin
            demand_plng_fcst_fact_load(var_company_code, var_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* DCS_ORDER_FACT load
         /*-*/
         begin
            dcs_order_fact_load(var_company_code, var_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* FCST_REGION_FACT load
         /*-*/
         begin
            fcst_region_fact_load(var_company_code, var_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Release the lock on the aggregation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;
      var_locked := false;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Scheduled Forecast');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         ods_app.utils.send_tivoli_alert('CRITICAL','Fatal Error occurred during Scheduled Aggregation.',2,var_company_code);
        -- if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
        --    lics_notification.send_alert(var_alert);
        -- end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(dw_parameter.system_code,
                                         dw_parameter.system_unit,
                                         dw_parameter.system_environment,
                                         con_function,
                                         'DW_SCHEDULED_FORECAST',
                                         var_email,
                                         'One or more errors occurred during the Scheduled Forecast execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

      end if;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Release the lock when required
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DW_SCHEDULED_FORECAST - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**********************************************************/
   /* This procedure performs the forecast fact load routine */
   /**********************************************************/
   procedure fcst_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_fcst_type_code             fcst_hdr.fcst_type_code%TYPE;
      v_sales_org_code             fcst_hdr.sales_org_code%TYPE;
      v_distbn_chnl_code           fcst_hdr.distbn_chnl_code%TYPE;
      v_division_code              fcst_hdr.division_code%TYPE;
      v_moe_code                   fcst_hdr.moe_code%TYPE;
      v_adjust_min_casting_yyyypp  NUMBER(6);
      v_adjust_min_casting_yyyyppw NUMBER(7);

      /*-*/
      /* Local cursors
      /*-*/
      -- Check whether any forecasts are to be aggregated.
      CURSOR csr_forecast IS
       SELECT DISTINCT
         fcst_type_code,
         sales_org_code,
         distbn_chnl_code,
         division_code,
         moe_code
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
         AND TRUNC(fcst_hdr_lupdt, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid;
       rv_forecast csr_forecast%ROWTYPE;

      -- Select the minimum casting period for a forecast that is to be aggregated.
      CURSOR csr_min_casting_period IS
       SELECT
         MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
         current_fcst_flag
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND moe_code = v_moe_code
         AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
         AND TRUNC(fcst_hdr_lupdt, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid
       GROUP BY current_fcst_flag
       ORDER BY current_fcst_flag DESC;
       rv_min_casting_period csr_min_casting_period%ROWTYPE;

      -- Select all casting periods starting at the minimum casting period for a forecast that is to be aggregated.
      CURSOR csr_casting_period IS
       SELECT
         casting_year AS casting_yyyy,
         casting_period AS casting_pp,
         (casting_year || LPAD(casting_period,2,0)) AS casting_yyyypp
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND moe_code = v_moe_code
         AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
         AND casting_year || LPAD(casting_period,2,0) >= v_adjust_min_casting_yyyypp
         AND valdtn_status = ods_constants.valdtn_valid
       ORDER BY TO_NUMBER(casting_year || casting_period) ASC;
       rv_casting_period csr_casting_period%ROWTYPE;

      -- Select the minimum casting week for a forecast that is to be aggregated (used for forecast type FCST).
      CURSOR csr_min_casting_week IS
       SELECT
         MIN(casting_year || LPAD(casting_period,2,0) || casting_week) AS min_casting_yyyyppw,
         current_fcst_flag
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND moe_code = v_moe_code
         AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
         AND TRUNC(fcst_hdr_lupdt, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid
       GROUP BY current_fcst_flag
       ORDER BY current_fcst_flag DESC;
       rv_min_casting_week csr_min_casting_week%ROWTYPE;

      -- Select all casting weeks starting at the minimum casting week for a weekly forecast that is to be aggregated.
      CURSOR csr_casting_week IS
       SELECT
         casting_year AS casting_yyyy,
         casting_period AS casting_pp,
         casting_week AS casting_w,
         (casting_year || LPAD(casting_period,2,0) || casting_week) AS casting_yyyyppw
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND moe_code = v_moe_code
         AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
         AND casting_year || LPAD(casting_period,2,0) || casting_week >= v_adjust_min_casting_yyyyppw
         AND valdtn_status = ods_constants.valdtn_valid
       ORDER BY TO_NUMBER(casting_year || casting_period || casting_week) ASC;
      rv_casting_week csr_casting_week%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FCST_FACT Load');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      lics_logging.write_log('--> Check whether any forecast are to be aggregated');
      FOR rv_forecast IN csr_forecast LOOP

       -- Handling the following unique forecast type.
       lics_logging.write_log('--> Handling - Forecast Type/MOE/Sales Org/Distribute Channel/Division [' ||
         rv_forecast.fcst_type_code || '/' || rv_forecast.moe_code || '/' || rv_forecast.sales_org_code ||
          '/' || rv_forecast.distbn_chnl_code || '/' || rv_forecast.division_code || '].');

       -- Now pass cursor results into variables.
       v_fcst_type_code :=  rv_forecast.fcst_type_code;
       v_sales_org_code := rv_forecast.sales_org_code;
       v_distbn_chnl_code := rv_forecast.distbn_chnl_code;
       v_division_code := rv_forecast.division_code;
       v_moe_code := rv_forecast.moe_code;

       -- Check and create the required partition.
       var_partition_code := par_company_code||'_'||v_moe_code||'_'||v_fcst_type_code;
       dds_dw_partition.check_create_list('fcst_fact', var_partition_code, var_partition_code);

      /* -----------------------------------------------------------------------------------
       Check to see if the forecast type is weekly i.e. FCST. If it is then process
       weekly forecast, if not then bypass this section as the forecast is a period forecast.
      -------------------------------------------------------------------------------------*/

      IF v_fcst_type_code = ods_constants.fcst_type_fcst_weekly THEN

         -- Fetch only the first record from the csr_min_casting_week cursor.
         lics_logging.write_log('--> Fetching only the first record' ||
           ' from the csr_min_casting_week cursor.');

         OPEN csr_min_casting_week;
         FETCH csr_min_casting_week INTO rv_min_casting_week;
         CLOSE csr_min_casting_week;

         -- Fetched the minimum casting_yyyyppw for the forecast being aggregated.
         lics_logging.write_log('--> The forecast being aggregated' ||
           ' has the Minimum Casting week of [' || rv_min_casting_week.min_casting_yyyyppw || ']' ||
           ' and Current Forecast Flag of [' || rv_min_casting_week.current_fcst_flag || '].');

         -- Update the min_casting_yyyyppw variable based on the status of the current_fcst_flag.
         IF rv_min_casting_week.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

           /*
           The current_fcst_flag = 'D' (Deleted) therefore set min_casting_yyyyppw to that of the prior
           forecast before the forecast which is to be deleted.
           */
           lics_logging.write_log('--> Updating the min_casting_yyyyppw' ||
             ' as the current_fcst_flag = ''D'' (Deleted).');

           SELECT MAX(casting_year || LPAD(casting_period,2,0) || casting_week) INTO v_adjust_min_casting_yyyyppw
           FROM fcst_hdr
           WHERE (casting_year || LPAD(casting_period,2,0) || casting_week) < rv_min_casting_week.min_casting_yyyyppw
             AND company_code = par_company_code
             AND fcst_type_code = v_fcst_type_code
             AND sales_org_code = v_sales_org_code
             AND distbn_chnl_code = v_distbn_chnl_code
             AND ((division_code = v_division_code) OR
                  (division_code IS NULL AND v_division_code IS NULL))
             AND moe_code = v_moe_code
             AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
             AND valdtn_status = ods_constants.valdtn_valid;

           -- If no prior forecast exists then set v_adjust_min_casting_yyyyppw to zero.
           IF v_adjust_min_casting_yyyyppw IS NULL THEN
             v_adjust_min_casting_yyyyppw := 0;
           END IF;

         ELSE
           -- Else the current_fcst_flag = 'Y', therefore use min_casting_yyyyppw.
           v_adjust_min_casting_yyyyppw := rv_min_casting_week.min_casting_yyyyppw;

         END IF;

         /*
         Loop through and aggregate forecast for all casting weeks starting with the minimum
         changed casting week through to the maximum casting week for the forecast.
         */
         lics_logging.write_log('--> Loop through and aggregate forecast' ||
           ' starting with the minimum casting week through to the maximum casting week.');

         FOR rv_casting_week IN csr_casting_week LOOP

           -- Delete forecasts from the fcst_fact table that are to be rebuilt.
           lics_logging.write_log('--> Deleting from FCST_FACT based' ||
             ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');
           DELETE FROM fcst_fact
           WHERE company_code = par_company_code
           AND fcst_type_code = v_fcst_type_code
           AND sales_org_code = v_sales_org_code
           AND distbn_chnl_code = v_distbn_chnl_code
           AND ((division_code = v_division_code) OR
                (division_code IS NULL AND v_division_code IS NULL))
           AND (moe_code = v_moe_code OR moe_code IS NULL)
           AND fcst_yyyyppw > rv_casting_week.casting_yyyyppw;

           lics_logging.write_log('--> Delete Count: ' || TO_CHAR(SQL%ROWCOUNT));

           -- Insert the forecast into the fcst_fact table.
           lics_logging.write_log('--> Inserting into FCST_FACT based' ||
             ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');

           INSERT INTO fcst_fact
             (
             partition_code,
             company_code,
             sales_org_code,
             distbn_chnl_code,
             division_code,
             moe_code,
             fcst_type_code,
             fcst_yyyypp,
             fcst_yyyyppw,
             demand_plng_grp_code,
             cntry_code,
             region_code,
             multi_mkt_acct_code,
             banner_code,
             cust_buying_grp_code,
             acct_assgnmnt_grp_code,
             pos_format_grpg_code,
             distbn_route_code,
             cust_code,
             matl_zrep_code,
             matl_tdu_code,
             currcy_code,
             fcst_value,
             fcst_value_aud,
             fcst_value_usd,
             fcst_value_eur,
             fcst_qty,
             fcst_qty_gross_tonnes,
             fcst_qty_net_tonnes,
             base_value,
             base_qty,
             aggreg_mkt_actvty_value,
             aggreg_mkt_actvty_qty,
             lock_value,
             lock_qty,
             rcncl_value,
             rcncl_qty,
             auto_adjmt_value,
             auto_adjmt_qty,
             override_value,
             override_qty,
             mkt_actvty_value,
             mkt_actvty_qty,
             data_driven_event_value,
             data_driven_event_qty,
             tgt_impact_value,
             tgt_impact_qty,
             dfn_adjmt_value,
             dfn_adjmt_qty
             )
             SELECT
               t1.company_code||'_'||t1.moe_code||'_'||t1.fcst_type_code,
               t1.company_code,
               t1.sales_org_code,
               t1.distbn_chnl_code,
               t1.division_code,
               t1.moe_code,
               t1.fcst_type_code,
               t1.fcst_yyyypp,
               t1.fcst_yyyyppw,
               t1.demand_plng_grp_code,
               t1.cntry_code,
               t1.region_code,
               t1.multi_mkt_acct_code,
               t1.banner_code,
               t1.cust_buying_grp_code,
               t1.acct_assgnmnt_grp_code,
               t1.pos_format_grpg_code,
               t1.distbn_route_code,
               t1.cust_code,
               t1.matl_zrep_code,
               t1.matl_tdu_code,
               t1.currcy_code,
               t1.fcst_value,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_aud,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_usd,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_eur,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
               t1.fcst_qty,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                   ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                                  0),0) AS fcst_qty_gross_tonnes,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                   ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                   0),0) AS fcst_qty_net_tonnes,
               base_value,
               base_qty,
               aggreg_mkt_actvty_value,
               aggreg_mkt_actvty_qty,
               lock_value,
               lock_qty,
               rcncl_value,
               rcncl_qty,
               auto_adjmt_value,
               auto_adjmt_qty,
               override_value,
               override_qty,
               mkt_actvty_value,
               mkt_actvty_qty,
               data_driven_event_value,
               data_driven_event_qty,
               tgt_impact_value,
               tgt_impact_qty,
               dfn_adjmt_value,
               dfn_adjmt_qty
             FROM  -- Sum up to material level before calling the functions to convert currency and tonnes for performance
               (SELECT
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
                  (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week) AS fcst_yyyyppw,
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
                  LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
                  b.currcy_code,
                  SUM(b.fcst_value) as fcst_value,
                  SUM(b.fcst_qty) AS fcst_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
                FROM
                  fcst_hdr a,
                  fcst_dtl b
                WHERE
                  a.fcst_hdr_code = b.fcst_hdr_code
                  AND (a.casting_year = rv_casting_week.casting_yyyy AND
                       a.casting_period = rv_casting_week.casting_pp AND
                       a.casting_week = rv_casting_week.casting_w)
                  AND a.company_code = par_company_code
                  AND a.fcst_type_code = v_fcst_type_code
                  AND a.sales_org_code = v_sales_org_code
                  AND a.distbn_chnl_code = v_distbn_chnl_code
                  AND ((a.division_code = v_division_code) OR
                       (a.division_code IS NULL AND v_division_code IS NULL))
                  AND a.moe_code = v_moe_code
                  AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
                  AND a.valdtn_status = ods_constants.valdtn_valid
                GROUP BY
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)),
                  (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week),
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  b.matl_zrep_code,
                  b.matl_tdu_code,
                  b.currcy_code ) t1,
               company t2,
               sap_mat_hdr t3
            WHERE t1.company_code = t2.company_code
            AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

           lics_logging.write_log('--> Insert Count: ' || TO_CHAR(SQL%ROWCOUNT));

           -- Commit.
           COMMIT;

         END LOOP;

      ELSE --Do fact entry for forecast types other than the weekly FCST type.

         -- Fetch only the first record from the csr_min_casting_period cursor.
         lics_logging.write_log('--> Fetching only the first record' ||
           ' from the csr_min_casting_period cursor.');

         OPEN csr_min_casting_period;
         FETCH csr_min_casting_period INTO rv_min_casting_period;
         CLOSE csr_min_casting_period;

         -- Fetched the minimum casting_yyyypp for the forecast being aggregated.
         lics_logging.write_log('--> The forecast being handled' ||
           ' has the Minimum Casting Period of [' || rv_min_casting_period.min_casting_yyyypp || ']' ||
           ' and Current Forecast Flag of [' || rv_min_casting_period.current_fcst_flag || '].');

         -- Update the min_casting_yyyypp variable based on the status of the current_fcst_flag.
         IF rv_min_casting_period.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

           /*
           The current_fcst_flag = 'D' (Deleted) therefore set min_casting_yyyypp to that of the prior
           forecast before the forecast which is to be deleted.
           */
           lics_logging.write_log('--> Updating the min_casting_yyyypp' ||
             ' as the current_fcst_flag = ''D'' (Deleted).');

           SELECT MAX(casting_year || LPAD(casting_period,2,0)) INTO v_adjust_min_casting_yyyypp
           FROM fcst_hdr
           WHERE (casting_year || LPAD(casting_period,2,0)) < rv_min_casting_period.min_casting_yyyypp
             AND company_code = par_company_code
             AND fcst_type_code = v_fcst_type_code
             AND sales_org_code = v_sales_org_code
             AND distbn_chnl_code = v_distbn_chnl_code
             AND ((division_code = v_division_code) OR
                  (division_code IS NULL AND v_division_code IS NULL))
             AND moe_code = v_moe_code
             AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
             AND valdtn_status = ods_constants.valdtn_valid;

           -- If no prior forecast exists then set v_adjust_min_casting_yyyypp to zero.
           IF v_adjust_min_casting_yyyypp IS NULL THEN
             v_adjust_min_casting_yyyypp := 0;
           END IF;

         ELSE
           -- Else the current_fcst_flag = 'Y', therefore use min_casting_yyyypp.
           v_adjust_min_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;

         END IF;

         /*
         Loop through and aggregate forecast for all casting periods starting with the minimum
         changed casting period through to the maximum casting period for the forecast.
         */
         lics_logging.write_log('--> Loop through and aggregate forecast' ||
           ' starting with the minimum casting period through to the maximum casting period.');

         FOR rv_casting_period IN csr_casting_period LOOP

              -- Delete forecasts from the fcst_fact table that are to be rebuilt.
              lics_logging.write_log('--> Deleting from FCST_FACT where fcst_yyyypp > [' ||
                rv_casting_period.casting_yyyypp || '].');

              DELETE FROM fcst_fact
              WHERE company_code = par_company_code
              AND fcst_type_code = v_fcst_type_code
              AND sales_org_code = v_sales_org_code
              AND distbn_chnl_code = v_distbn_chnl_code
              AND ((division_code = v_division_code) OR
                   (division_code IS NULL AND v_division_code IS NULL))
              AND (moe_code = v_moe_code OR moe_code IS NULL)
              AND fcst_yyyypp > rv_casting_period.casting_yyyypp;

              lics_logging.write_log('--> Delete count : ' || TO_CHAR(SQL%ROWCOUNT) );

              -- Insert the forecast into the fcst_fact table.
              lics_logging.write_log('--> Inserting into FCST_FACT where ' ||
                ' Casting Period = [' || rv_casting_period.casting_yyyypp || '] and fcst_yyyypp > [' || rv_casting_period.casting_yyyypp || ']' );

              INSERT INTO fcst_fact
                (
                 partition_code,
                 company_code,
                 sales_org_code,
                 distbn_chnl_code,
                 division_code,
                 moe_code,
                 fcst_type_code,
                 fcst_yyyypp,
                 fcst_yyyyppw,
                 demand_plng_grp_code,
                 cntry_code,
                 region_code,
                 multi_mkt_acct_code,
                 banner_code,
                 cust_buying_grp_code,
                 acct_assgnmnt_grp_code,
                 pos_format_grpg_code,
                 distbn_route_code,
                 cust_code,
                 matl_zrep_code,
                 matl_tdu_code,
                 currcy_code,
                 fcst_value,
                 fcst_value_aud,
                 fcst_value_usd,
                 fcst_value_eur,
                 fcst_qty,
                 fcst_qty_gross_tonnes,
                 fcst_qty_net_tonnes,
                 base_value,
                 base_qty,
                 aggreg_mkt_actvty_value,
                 aggreg_mkt_actvty_qty,
                 lock_value,
                 lock_qty,
                 rcncl_value,
                 rcncl_qty,
                 auto_adjmt_value,
                 auto_adjmt_qty,
                 override_value,
                 override_qty,
                 mkt_actvty_value,
                 mkt_actvty_qty,
                 data_driven_event_value,
                 data_driven_event_qty,
                 tgt_impact_value,
                 tgt_impact_qty,
                 dfn_adjmt_value,
                 dfn_adjmt_qty
                )
                SELECT
                  t1.company_code||'_'||t1.moe_code||'_'||t1.fcst_type_code,
                  t1.company_code,
                  t1.sales_org_code,
                  t1.distbn_chnl_code,
                  t1.division_code,
                  t1.moe_code,
                  t1.fcst_type_code,
                  t1.fcst_yyyypp,
                  t1.fcst_yyyyppw,
                  t1.demand_plng_grp_code,
                  t1.cntry_code,
                  t1.region_code,
                  t1.multi_mkt_acct_code,
                  t1.banner_code,
                  t1.cust_buying_grp_code,
                  t1.acct_assgnmnt_grp_code,
                  t1.pos_format_grpg_code,
                  t1.distbn_route_code,
                  t1.cust_code,
                  t1.matl_zrep_code,
                  t1.matl_tdu_code,
                  t1.currcy_code,
                  t1.fcst_value,
                  ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_aud,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
                  ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_usd,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
                  ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_eur,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
                  t1.fcst_qty,
                  NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                   ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                                  0),0) AS fcst_qty_gross_tonnes,
                  NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                   ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                   0),0) AS fcst_qty_net_tonnes,
                  base_value,
                  base_qty,
                  aggreg_mkt_actvty_value,
                  aggreg_mkt_actvty_qty,
                  lock_value,
                  lock_qty,
                  rcncl_value,
                  rcncl_qty,
                  auto_adjmt_value,
                  auto_adjmt_qty,
                  override_value,
                  override_qty,
                  mkt_actvty_value,
                  mkt_actvty_qty,
                  data_driven_event_value,
                  data_driven_event_qty,
                  tgt_impact_value,
                  tgt_impact_qty,
                  dfn_adjmt_value,
                  dfn_adjmt_qty
                FROM
                  (SELECT
                     a.company_code,
                     a.sales_org_code,
                     a.distbn_chnl_code,
                     a.division_code,
                     a.moe_code,
                     a.fcst_type_code,
                     (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
                     NULL AS fcst_yyyyppw,
                     b.demand_plng_grp_code,
                     b.cntry_code,
                     b.region_code,
                     b.multi_mkt_acct_code,
                     b.banner_code,
                     b.cust_buying_grp_code,
                     b.acct_assgnmnt_grp_code,
                     b.pos_format_grpg_code,
                     b.distbn_route_code,
                     b.cust_code,
                     LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
                     LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
                     b.currcy_code,
                     SUM(b.fcst_value) as fcst_value,
                     SUM(b.fcst_qty) AS fcst_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
                     SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
                   FROM
                     fcst_hdr a,
                     fcst_dtl b
                   WHERE
                     a.fcst_hdr_code = b.fcst_hdr_code
                     AND (a.casting_year = rv_casting_period.casting_yyyy AND
                          a.casting_period = rv_casting_period.casting_pp )
                     AND a.company_code = par_company_code
                     AND a.fcst_type_code = v_fcst_type_code
                     AND a.sales_org_code = v_sales_org_code
                     AND a.distbn_chnl_code = v_distbn_chnl_code
                     AND ((a.division_code = v_division_code) OR
                          (a.division_code IS NULL AND v_division_code IS NULL))
                     AND a.moe_code = v_moe_code
                     AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
                     AND a.valdtn_status = ods_constants.valdtn_valid
                     AND (b.fcst_year || LPAD(b.fcst_period,2,0)) > rv_casting_period.casting_yyyypp
                   GROUP BY
                     a.company_code,
                     a.sales_org_code,
                     a.distbn_chnl_code,
                     a.division_code,
                     a.moe_code,
                     a.fcst_type_code,
                     (b.fcst_year || LPAD(b.fcst_period,2,0)),
                     b.demand_plng_grp_code,
                     b.cntry_code,
                     b.region_code,
                     b.multi_mkt_acct_code,
                     b.banner_code,
                     b.cust_buying_grp_code,
                     b.acct_assgnmnt_grp_code,
                     b.pos_format_grpg_code,
                     b.distbn_route_code,
                     b.cust_code,
                     b.matl_zrep_code,
                     b.matl_tdu_code,
                     b.currcy_code ) t1,
                  company t2,
                  sap_mat_hdr t3
               WHERE t1.company_code = t2.company_code
               AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

              lics_logging.write_log('--> Insert count : ' || TO_CHAR(SQL%ROWCOUNT) );

           -- Commit.
           COMMIT;

         END LOOP;

      END IF;

      END LOOP;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - FCST_FACT Load');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - FCST_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - FCST_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end fcst_fact_load;

   /**************************************************************************/
   /* This procedure performs the demand planning forecast fact load routine */
   /**************************************************************************/
   procedure demand_plng_fcst_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_fcst_type_code fcst_hdr.fcst_type_code%TYPE;
      v_sales_org_code fcst_hdr.sales_org_code%TYPE;
      v_distbn_chnl_code fcst_hdr.distbn_chnl_code%TYPE;
      v_division_code fcst_hdr.division_code%TYPE;
      v_no_insert_flag BOOLEAN := FALSE;
      v_min_casting_yyyyppw VARCHAR2(7);
      v_min_casting_yyyypp VARCHAR2(6);
      v_moe_code fcst_hdr.moe_code%TYPE;

      /*-*/
      /* Local cursors
      /*-*/
      -- Check whether any forecasts are to be aggregated.
      CURSOR csr_forecast IS
       SELECT DISTINCT
         fcst_type_code,
         sales_org_code,
         distbn_chnl_code,
         division_code,
         moe_code
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
         AND TRUNC(fcst_hdr_lupdt, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid;
       rv_forecast csr_forecast%ROWTYPE;

      -- Select the minimum casting period for a forecast that is to be aggregated.
      CURSOR csr_min_casting_period IS
       SELECT
         MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
         current_fcst_flag
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND moe_code = v_moe_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
         AND TRUNC(fcst_hdr_lupdt, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid
       GROUP BY current_fcst_flag
       ORDER BY current_fcst_flag DESC;
       rv_min_casting_period csr_min_casting_period%ROWTYPE;

      -- Select all casting periods starting at the minimum casting period for a forecast that is to be aggregated.
      CURSOR csr_casting_period IS
       SELECT
         casting_year AS casting_yyyy,
         casting_period AS casting_pp,
         (casting_year || LPAD(casting_period,2,0)) AS casting_yyyypp
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND moe_code = v_moe_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
         AND casting_year || LPAD(casting_period,2,0) >= v_min_casting_yyyypp
         AND valdtn_status = ods_constants.valdtn_valid
       ORDER BY TO_NUMBER(casting_year || casting_period) ASC;  -- KL (fix bug) convert to number otherwise the order is not as expected
       rv_casting_period csr_casting_period%ROWTYPE;

      -- Select the minimum casting week for a forecast that is to be aggregated (used for forecast type FCST).
      CURSOR csr_min_casting_week IS
       SELECT
         MIN(casting_year || LPAD(casting_period,2,0) || casting_week) AS min_casting_yyyyppw,
         current_fcst_flag
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND moe_code = v_moe_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND current_fcst_flag IN (ods_constants.fcst_current_fcst_flag_yes, ods_constants.fcst_current_fcst_flag_deleted)
         AND TRUNC(fcst_hdr_lupdt, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid
       GROUP BY current_fcst_flag
       ORDER BY current_fcst_flag DESC;
       rv_min_casting_week csr_min_casting_week%ROWTYPE;

      -- Select all casting weeks starting at the minimum casting week for a weekly forecast that is to be aggregated.
      CURSOR csr_casting_week IS
       SELECT
         casting_year AS casting_yyyy,
         casting_period AS casting_pp,
         casting_week AS casting_w,
         (casting_year || LPAD(casting_period,2,0) || casting_week) AS casting_yyyyppw
       FROM fcst_hdr
       WHERE company_code = par_company_code
         AND moe_code = v_moe_code
         AND fcst_type_code = v_fcst_type_code
         AND sales_org_code = v_sales_org_code
         AND distbn_chnl_code = v_distbn_chnl_code
         AND ((division_code = v_division_code) OR
              (division_code IS NULL AND v_division_code IS NULL))
         AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
         AND casting_year || LPAD(casting_period,2,0) || casting_week >= v_min_casting_yyyyppw
         AND valdtn_status = ods_constants.valdtn_valid
       ORDER BY TO_NUMBER(casting_year || casting_period || casting_week) ASC;  -- KL (fix bug) convert to number otherwise the order is not as expected
      rv_casting_week csr_casting_week%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - DEMAND_PLNG_FCST_FACT Load');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      lics_logging.write_log('--> Check whether any forecast are to be aggregated');
      FOR rv_forecast IN csr_forecast LOOP

       -- The following forecast requires aggregation.
       lics_logging.write_log('--> Aggregating: Forecast Type/MOE/Sales Org/Distribute Channel/Division [' ||
         rv_forecast.fcst_type_code || '/' || rv_forecast.moe_code || '/' || rv_forecast.sales_org_code ||
          '/' || rv_forecast.distbn_chnl_code || '/' || rv_forecast.division_code || '].');

       -- Now pass cursor results into variables.
       v_fcst_type_code :=  rv_forecast.fcst_type_code;
       v_sales_org_code := rv_forecast.sales_org_code;
       v_distbn_chnl_code := rv_forecast.distbn_chnl_code;
       v_division_code := rv_forecast.division_code;
       v_moe_code := rv_forecast.moe_code;

      /* -----------------------------------------------------------------------------------
       Check to see if the forecast type is weekly i.e. FCST. If it is then process
       weekly forecast, if not then bypass this section as the forecast is a period forecast.
      -------------------------------------------------------------------------------------*/

      IF v_fcst_type_code = ods_constants.fcst_type_fcst_weekly THEN

         -- Fetch only the first record from the csr_min_casting_week cursor.
         lics_logging.write_log('--> Fetching only the first record' ||
           ' from the csr_min_casting_week cursor.');

         OPEN csr_min_casting_week;
         FETCH csr_min_casting_week INTO rv_min_casting_week;
         CLOSE csr_min_casting_week;

         -- Fetched the minimum casting_yyyyppw for the forecast being aggregated.
         lics_logging.write_log('--> The forecast being aggregated' ||
           ' has the Minimum Casting week of [' || rv_min_casting_week.min_casting_yyyyppw || ']' ||
           ' and Current Forecast Flag of [' || rv_min_casting_week.current_fcst_flag || '].');

         -- Check the status of the current_fcst_flag.
         IF rv_min_casting_week.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

           -- If current_fcst_flag = 'D' (deleted) then delete the data from DEMAND_PLNG_FCST_FACT table for that
           -- casting week as it is no longer needed and no insert will be done into DEMAND_PLNG_FCST_FACT table.
           -- if the status is D.
           lics_logging.write_log('--> Deleting from DEMAND_PLNG_FCST_FACT ' ||
             ' as the current_fcst_flag = ''D'' (Deleted) for Casting Week ' || rv_min_casting_week.min_casting_yyyyppw || ' .');

           DELETE FROM demand_plng_fcst_fact
           WHERE company_code = par_company_code
           AND fcst_type_code = v_fcst_type_code
           AND sales_org_code = v_sales_org_code
           AND distbn_chnl_code = v_distbn_chnl_code
           AND ((division_code = v_division_code) OR
                (division_code IS NULL AND v_division_code IS NULL))
           AND (moe_code = v_moe_code OR moe_code IS NULL)
           AND casting_yyyyppw = rv_min_casting_week.min_casting_yyyyppw;

           lics_logging.write_log('--> Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

           -- The current_fcst_flag = 'D', therefore no insert is required.
           v_no_insert_flag      := TRUE;
           v_min_casting_yyyyppw := NULL;

           -- Commit.
           COMMIT;

         ELSE -- Status of minimum casting week forecast is not 'D'.

           -- The current_fcst_flag = 'Y', therefore use min_casting_yyyyppw.
           v_no_insert_flag       := FALSE;
           v_min_casting_yyyyppw  := rv_min_casting_week.min_casting_yyyyppw;

         END IF;

         /*
          Loop through and aggregate forecast for all casting weeks starting with the minimum changed casting
          week through to the maximum casting week for the forecast.
          Do this only if the minimum casting week selected above is not DELETED.
         */

         -- If the status of minimum forecast week is not 'D', then open the cursor and process.
         IF v_no_insert_flag = FALSE  THEN

           lics_logging.write_log('--> Loop through and aggregate forecast' ||
             ' starting with the minimum casting week through to the maximum casting week.');

           FOR rv_casting_week IN csr_casting_week LOOP

             -- Delete forecasts from the demand_plng_fcst_fact table that are to be rebuilt.
             lics_logging.write_log('--> Deleting from DEMAND_PLNG_FCST_FACT based' ||
             ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');
             DELETE FROM demand_plng_fcst_fact
             WHERE company_code = par_company_code
             AND fcst_type_code = v_fcst_type_code
             AND sales_org_code = v_sales_org_code
             AND distbn_chnl_code = v_distbn_chnl_code
             AND ((division_code = v_division_code) OR
                  (division_code IS NULL AND v_division_code IS NULL))
             AND (moe_code = v_moe_code OR moe_code IS NULL)
             AND casting_yyyyppw = rv_casting_week.casting_yyyyppw;

           lics_logging.write_log('--> Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

           -- Insert the forecast into the demand_plng_fcast_fact table.
           lics_logging.write_log('--> Inserting into DEMAND_PLNG_FCST_FACT based' ||
             ' on Casting Week [' || rv_casting_week.casting_yyyyppw || '].');

           INSERT INTO demand_plng_fcst_fact
             (
             company_code,
             sales_org_code,
             distbn_chnl_code,
             division_code,
             moe_code,
             fcst_type_code,
             casting_yyyypp,
             casting_yyyyppw,
             fcst_yyyypp,
             fcst_yyyyppw,
             demand_plng_grp_code,
             cntry_code,
             region_code,
             multi_mkt_acct_code,
             banner_code,
             cust_buying_grp_code,
             acct_assgnmnt_grp_code,
             pos_format_grpg_code,
             distbn_route_code,
             cust_code,
             matl_zrep_code,
             matl_tdu_code,
             currcy_code,
             fcst_value,
             fcst_value_aud,
             fcst_value_usd,
             fcst_value_eur,
             fcst_qty,
             fcst_qty_gross_tonnes,
             fcst_qty_net_tonnes,
             base_value,
             base_qty,
             aggreg_mkt_actvty_value,
             aggreg_mkt_actvty_qty,
             lock_value,
             lock_qty,
             rcncl_value,
             rcncl_qty,
             auto_adjmt_value,
             auto_adjmt_qty,
             override_value,
             override_qty,
             mkt_actvty_value,
             mkt_actvty_qty,
             data_driven_event_value,
             data_driven_event_qty,
             tgt_impact_value,
             tgt_impact_qty,
             dfn_adjmt_value,
             dfn_adjmt_qty
             )
             SELECT
               t1.company_code,
               t1.sales_org_code,
               t1.distbn_chnl_code,
               t1.division_code,
               t1.moe_code,
               t1.fcst_type_code,
               t1.casting_yyyypp,
               t1.casting_yyyyppw,
               t1.fcst_yyyypp,
               t1.fcst_yyyyppw,
               t1.demand_plng_grp_code,
               t1.cntry_code,
               t1.region_code,
               t1.multi_mkt_acct_code,
               t1.banner_code,
               t1.cust_buying_grp_code,
               t1.acct_assgnmnt_grp_code,
               t1.pos_format_grpg_code,
               t1.distbn_route_code,
               t1.cust_code,
               t1.matl_zrep_code,
               t1.matl_tdu_code,
               t1.currcy_code,
               t1.fcst_value,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_aud,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_usd,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_eur,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
               t1.fcst_qty,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                   ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                                  0),0) AS fcst_qty_gross_tonnes,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                   ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                   0),0) AS fcst_qty_net_tonnes,
               base_value,
               base_qty,
               aggreg_mkt_actvty_value,
               aggreg_mkt_actvty_qty,
               lock_value,
               lock_qty,
               rcncl_value,
               rcncl_qty,
               auto_adjmt_value,
               auto_adjmt_qty,
               override_value,
               override_qty,
               mkt_actvty_value,
               mkt_actvty_qty,
               data_driven_event_value,
               data_driven_event_qty,
               tgt_impact_value,
               tgt_impact_qty,
               dfn_adjmt_value,
               dfn_adjmt_qty
             FROM
               (SELECT
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  a.casting_year || LPAD(a.casting_period,2,0) AS casting_yyyypp,
                  a.casting_year || LPAD(a.casting_period,2,0) || a.casting_week AS casting_yyyyppw,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
                  (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week) AS fcst_yyyyppw,
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
                  LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
                  b.currcy_code,
                  SUM(b.fcst_value) as fcst_value,
                  SUM(b.fcst_qty) AS fcst_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
                FROM
                  fcst_hdr a,
                  fcst_dtl b
                WHERE
                  a.fcst_hdr_code = b.fcst_hdr_code
                  AND (a.casting_year = rv_casting_week.casting_yyyy AND
                       a.casting_period = rv_casting_week.casting_pp AND
                       a.casting_week = rv_casting_week.casting_w)
                  AND a.company_code = par_company_code
                  AND a.fcst_type_code = v_fcst_type_code
                  AND a.sales_org_code = v_sales_org_code
                  AND a.distbn_chnl_code = v_distbn_chnl_code
                  AND ((a.division_code = v_division_code) OR
                       (a.division_code IS NULL AND v_division_code IS NULL))
                  AND moe_code = v_moe_code
                  AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
                  AND a.valdtn_status = ods_constants.valdtn_valid
                GROUP BY
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  a.casting_year || LPAD(a.casting_period,2,0),
                  a.casting_year || LPAD(a.casting_period,2,0) || a.casting_week,
                  (b.fcst_year || LPAD(b.fcst_period,2,0)),
                  (b.fcst_year || LPAD(b.fcst_period,2,0) || b.fcst_week),
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  b.matl_zrep_code,
                  b.matl_tdu_code,
                  b.currcy_code ) t1,
               company t2,
               sap_mat_hdr t3
            WHERE t1.company_code = t2.company_code
            AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

           lics_logging.write_log('--> Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

           -- Commit.
           COMMIT;

         END LOOP;   -- End of csr_casting_week cursor.
       END IF;       -- End of v_no_insert_flag = FALSE check.

      --  Forecast type is not weekly 'FCST', therefore process period forecast.
      ELSE

         -- Fetch only the first record from the csr_min_casting_period cursor.
         lics_logging.write_log('--> Fetching only the first record' ||
           ' from the csr_min_casting_period cursor.');

         OPEN csr_min_casting_period;
         FETCH csr_min_casting_period INTO rv_min_casting_period;
         CLOSE csr_min_casting_period;

         -- Fetched the minimum casting_yyyypp for the forecast being aggregated.
         lics_logging.write_log('--> The forecast being aggregated' ||
           ' has the Minimum Casting Period of [' || rv_min_casting_period.min_casting_yyyypp || ']' ||
           ' and Current Forecast Flag of [' || rv_min_casting_period.current_fcst_flag || '].');

         -- Check the status of the current_fcst flag.
         IF rv_min_casting_period.current_fcst_flag = ods_constants.fcst_current_fcst_flag_deleted THEN

           -- If current_fcst_flag = 'D' (deleted) then delete the data from DEMAND_PLNG_FCST_FACT table for that
           -- casting period as it is no longer needed and no insert will be done into DEMAND_PLNG_FCST_FACT table
           -- if the status is D.
           lics_logging.write_log('--> Deleting from DEMAND_PLNG_FCST_FACT ' ||
             ' as the current_fcst_flag = ''D'' (Deleted) for Casting Period ' || rv_min_casting_period.min_casting_yyyypp || ' .');

           DELETE FROM demand_plng_fcst_fact
           WHERE company_code = par_company_code
           AND fcst_type_code = v_fcst_type_code
           AND sales_org_code = v_sales_org_code
           AND distbn_chnl_code = v_distbn_chnl_code
           AND ((division_code = v_division_code) OR
                (division_code IS NULL AND v_division_code IS NULL))
           AND (moe_code = v_moe_code OR moe_code IS NULL)
           AND casting_yyyypp = rv_min_casting_period.min_casting_yyyypp;

           lics_logging.write_log('--> Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

           -- The current_fcst_flag = 'D', therefore no insert is required.
           v_no_insert_flag      := TRUE;
           v_min_casting_yyyypp  := NULL;

           -- Commit.
           COMMIT;

         ELSE -- Status of minimum casting period forecast is not 'D'.

           -- The current_fcst_flag = 'Y', therefore use min_casting_yyyypp.
           v_no_insert_flag     := FALSE;
           v_min_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;

         END IF;

         /*
          Loop through and aggregate forecast for all casting periods starting with the minimum changed casting
          period through to the maximum casting period for the forecast.
          Do this only if the minimum casting period selected above is not DELETED.
         */

         -- If the status of minimum forecast period is not 'D' then open the cursor and process.
         IF  v_no_insert_flag = FALSE  THEN

           lics_logging.write_log('--> Loop through and aggregate forecast' ||
               ' starting with the minimum casting period through to the maximum casting period.');

           FOR rv_casting_period IN csr_casting_period LOOP

             -- Delete forecasts from the demand_plng_fcst_fact table that are to be rebuilt.
             lics_logging.write_log('--> Deleting from DEMAND_PLNG_FCST_FACT based' ||
               ' on Casting Period [' || rv_casting_period.casting_yyyypp || '].');
             DELETE FROM demand_plng_fcst_fact
             WHERE company_code = par_company_code
             AND fcst_type_code = v_fcst_type_code
             AND sales_org_code = v_sales_org_code
             AND distbn_chnl_code = v_distbn_chnl_code
             AND ((division_code = v_division_code) OR
                  (division_code IS NULL AND v_division_code IS NULL))
             AND (moe_code = v_moe_code OR moe_code IS NULL)
             AND casting_yyyypp = rv_casting_period.casting_yyyypp;

             lics_logging.write_log('--> Delete Count: ' || TO_CHAR(SQL%ROWCOUNT));

             -- Insert the forecast into the demand_plng_fcst_fact table.
             lics_logging.write_log('--> Inserting into DEMAND_PLNG_FCST_FACT based' ||
               ' on Casting Period [' || rv_casting_period.casting_yyyypp || '].');
             INSERT INTO demand_plng_fcst_fact
             (
             company_code,
             sales_org_code,
             distbn_chnl_code,
             division_code,
             moe_code,
             fcst_type_code,
             casting_yyyypp,
             casting_yyyyppw,
             fcst_yyyypp,
             fcst_yyyyppw,
             demand_plng_grp_code,
             cntry_code,
             region_code,
             multi_mkt_acct_code,
             banner_code,
             cust_buying_grp_code,
             acct_assgnmnt_grp_code,
             pos_format_grpg_code,
             distbn_route_code,
             cust_code,
             matl_zrep_code,
             matl_tdu_code,
             currcy_code,
             fcst_value,
             fcst_value_aud,
             fcst_value_usd,
             fcst_value_eur,
             fcst_qty,
             fcst_qty_gross_tonnes,
             fcst_qty_net_tonnes,
             base_value,
             base_qty,
             aggreg_mkt_actvty_value,
             aggreg_mkt_actvty_qty,
             lock_value,
             lock_qty,
             rcncl_value,
             rcncl_qty,
             auto_adjmt_value,
             auto_adjmt_qty,
             override_value,
             override_qty,
             mkt_actvty_value,
             mkt_actvty_qty,
             data_driven_event_value,
             data_driven_event_qty,
             tgt_impact_value,
             tgt_impact_qty,
             dfn_adjmt_value,
             dfn_adjmt_qty
             )
             SELECT
               t1.company_code,
               t1.sales_org_code,
               t1.distbn_chnl_code,
               t1.division_code,
               t1.moe_code,
               t1.fcst_type_code,
               t1.casting_yyyypp,
               t1.casting_yyyyppw,
               t1.fcst_yyyypp,
               t1.fcst_yyyyppw,
               t1.demand_plng_grp_code,
               t1.cntry_code,
               t1.region_code,
               t1.multi_mkt_acct_code,
               t1.banner_code,
               t1.cust_buying_grp_code,
               t1.acct_assgnmnt_grp_code,
               t1.pos_format_grpg_code,
               t1.distbn_route_code,
               t1.cust_code,
               t1.matl_zrep_code,
               t1.matl_tdu_code,
               t1.currcy_code,
               t1.fcst_value,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_aud,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_aud,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_usd,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_usd,
               ods_app.currcy_conv(t1.fcst_value,
                                   t2.company_currcy,
                                   ods_constants.currency_eur,
                                   (SELECT TO_DATE(yyyymmdd_date,'YYYYMMDD')
                                    FROM mars_date
                                    WHERE mars_yyyyppdd = (fcst_yyyypp || '01')),
                                   ods_constants.exchange_rate_type_mppr) AS fcst_value_eur,
               t1.fcst_qty,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, DECODE(t3.brgew,0,t3.ntgew,t3.brgew),
                                   ods_constants.uom_kilograms, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (DECODE(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                                  0),0) AS fcst_qty_gross_tonnes,
               NVL(DECODE(t3.gewei, ods_constants.uom_tonnes, t3.ntgew,
                                   ods_constants.uom_kilograms, (t3.ntgew / 1000)*t1.fcst_qty,
                                   ods_constants.uom_grams, (t3.ntgew / 1000000)*t1.fcst_qty,
                                   ods_constants.uom_milligrams, (t3.ntgew / 1000000000)*t1.fcst_qty,
                                   0),0) AS fcst_qty_net_tonnes,
               base_value,
               base_qty,
               aggreg_mkt_actvty_value,
               aggreg_mkt_actvty_qty,
               lock_value,
               lock_qty,
               rcncl_value,
               rcncl_qty,
               auto_adjmt_value,
               auto_adjmt_qty,
               override_value,
               override_qty,
               mkt_actvty_value,
               mkt_actvty_qty,
               data_driven_event_value,
               data_driven_event_qty,
               tgt_impact_value,
               tgt_impact_qty,
               dfn_adjmt_value,
               dfn_adjmt_qty
             FROM
               (SELECT
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  a.casting_year || LPAD(a.casting_period,2,0) AS casting_yyyypp,
                  NULL casting_yyyyppw,        -- casting_yyyyppw is null if fcst_type is not FCST.
                  (b.fcst_year || LPAD(b.fcst_period,2,0)) AS fcst_yyyypp,
                  NULL AS fcst_yyyyppw,        -- forecast_yyyyppw is null if fcst_type is not FCST.
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  LTRIM(b.matl_zrep_code, 0) as matl_zrep_code,
                  LTRIM(b.matl_tdu_code, 0) as matl_tdu_code,
                  b.currcy_code,
                  SUM(b.fcst_value) as fcst_value,
                  SUM(b.fcst_qty) AS fcst_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
                  SUM(DECODE(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty            -- KL
                FROM
                  fcst_hdr a,
                  fcst_dtl b
                WHERE
                  a.fcst_hdr_code = b.fcst_hdr_code
                  AND (a.casting_year = rv_casting_period.casting_yyyy AND
                       a.casting_period = rv_casting_period.casting_pp )
                  AND a.company_code = par_company_code
                  AND a.fcst_type_code = v_fcst_type_code
                  AND a.sales_org_code = v_sales_org_code
                  AND a.distbn_chnl_code = v_distbn_chnl_code
                  AND ((a.division_code = v_division_code) OR
                       (a.division_code IS NULL AND v_division_code IS NULL))
                  AND moe_code = v_moe_code
                  AND a.current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
                  AND a.valdtn_status = ods_constants.valdtn_valid
                GROUP BY
                  a.company_code,
                  a.sales_org_code,
                  a.distbn_chnl_code,
                  a.division_code,
                  a.moe_code,
                  a.fcst_type_code,
                  a.casting_year || LPAD(a.casting_period,2,0),
                  (b.fcst_year || LPAD(b.fcst_period,2,0)),
                  b.demand_plng_grp_code,
                  b.cntry_code,
                  b.region_code,
                  b.multi_mkt_acct_code,
                  b.banner_code,
                  b.cust_buying_grp_code,
                  b.acct_assgnmnt_grp_code,
                  b.pos_format_grpg_code,
                  b.distbn_route_code,
                  b.cust_code,
                  b.matl_zrep_code,
                  b.matl_tdu_code,
                  b.currcy_code ) t1,
               company t2,
               sap_mat_hdr t3
            WHERE t1.company_code = t2.company_code
            AND t1.matl_zrep_code = LTRIM(t3.matnr,'0');

             lics_logging.write_log('--> Insert Count: ' || TO_CHAR(SQL%ROWCOUNT));

           -- Commit.
           COMMIT;

         END LOOP;   -- End of csr_casting_period cursor.
       END IF;       -- End of v_no_insert_flag = FALSE check.

      END IF; -- End forecast type check for weekly FCST.

      END LOOP;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - DEMAND_PLNG_FCST_FACT Load');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - DEMAND_PLNG_FCST_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - DEMAND_PLNG_FCST_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end demand_plng_fcst_fact_load;

   /***********************************************************/
   /* This procedure performs the DCS order fact load routine */
   /***********************************************************/
   procedure dcs_order_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local cursors
      /*-*/
      -- Check whether any fundraising orders were received or updated yesterday.
      CURSOR csr_dcs_order_count IS
       SELECT
         count(*) AS dcs_order_count
       FROM
         dcs_sales_order
       WHERE
         company_code = par_company_code
         AND TRUNC(dcs_sales_order_lupdt) = par_date
         AND valdtn_status = ods_constants.valdtn_valid;
       rv_dcs_order_count csr_dcs_order_count%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - DCS_ORDER_FACT Load');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      -- Fetch the record from the csr_dcs_order_count cursor.
      OPEN csr_dcs_order_count;
      FETCH csr_dcs_order_count INTO rv_dcs_order_count.dcs_order_count;
      CLOSE csr_dcs_order_count;

      -- If any fundraising orders were received or updated then continue the aggregation process.
      lics_logging.write_log('--> Checking whether any fundraising orders' ||
       ' were received or updated yesterday.');

      IF rv_dcs_order_count.dcs_order_count > 0 THEN

       -- Delete all existing dsc orders for the company first.
       lics_logging.write_log('--> Deleting from DCS_SALES_ORDER_FACT based on' ||
         ' Company Code [' || par_company_code || ']');

       -- delete all the existing record first, becasue no history required to be kept in this table
       DELETE FROM dcs_sales_order_fact
       WHERE company_code = par_company_code;

       lics_logging.write_log('--> Delete count: ' || TO_CHAR(SQL%ROWCOUNT));

       -- Insert into dcs_sales_order_fact table based on company code.
       lics_logging.write_log('--> Inserting into the DCS_SALES_ORDER_FACT table.');
       INSERT INTO dcs_sales_order_fact
         (
           company_code,
           order_doc_num,
           order_doc_line_num,
           order_type_code,
           creatn_date,
           order_eff_date,
           sales_org_code,
           distbn_chnl_code,
           division_code,
           doc_currcy_code,
           exch_rate,
           sold_to_cust_code,
           ship_to_cust_code,
           bill_to_cust_code,
           payer_cust_code,
           base_uom_order_qty,
           order_qty_base_uom_code,
           plant_code,
           storage_locn_code,
           order_gsv,
           matl_zrep_code,
           creatn_yyyyppdd,
           order_eff_yyyyppdd
         )
       SELECT
         company_code,
         order_doc_num,
         order_doc_line_num,
         order_type_code,
         creatn_date,
         order_eff_date,
         sales_org_code,
         distbn_chnl_code,
         division_code,
         doc_currcy_code,
         exch_rate,
         sold_to_cust_code,
         ship_to_cust_code,
         bill_to_cust_code,
         payer_cust_code,
         base_uom_order_qty,
         order_qty_base_uom_code,
         t1.plant_code,
         storage_locn_code,
         order_gsv,
         decode(t2.matl_type_code, 'ZREP', t2.matl_code, t2.rep_item) as matl_zrep_code,
         t3.mars_yyyyppdd as creatn_yyyyppdd,
         t4.mars_yyyyppdd as order_eff_yyyyppdd
       FROM
         dcs_sales_order t1,     -- this list is refreshed every day, no need to check the load date
         matl_dim t2,
         mars_date_dim t3,
         mars_date_dim t4
       WHERE
         t1.company_code = par_company_code
         AND t1.valdtn_status = ods_constants.valdtn_valid
         AND t1.matl_code = t2.matl_code
         AND t1.creatn_date = t3.calendar_date (+)
         AND t1.order_eff_date = t4.calendar_date (+)
         AND (t2.matl_type_code = 'ZREP' or t2.rep_item is not null);

       lics_logging.write_log('--> Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

       -- Commit.
       COMMIT;

      END IF;
      
      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - DCS_ORDER_FACT Load');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - DCS_ORDER_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - DCS_ORDER_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end dcs_order_fact_load;
   
   /*****************************************************************/
   /* This procedure performs the forecast region fact load routine */
   /*****************************************************************/
   procedure fcst_region_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_casting_yyyypp        mars_date_dim.mars_period%TYPE;
      v_aggregation_date      DATE;
      v_reload_yyyypp         mars_date_dim.mars_period%TYPE;
      v_snack_br_cast_period  mars_date_dim.mars_period%TYPE;
      v_moe_code              fcst_fact.moe_code%TYPE;
      v_snack_reload          BOOLEAN := FALSE;
      v_reload                BOOLEAN := FALSE;

      /*-*/
      /* Local cursors
      /*-*/
      -- Check the min casting period for the BR forecast type and moe_code exist in fcst_demand_grp_local_region
      -- and changed on the aggregation date.
      CURSOR csr_min_casting_period IS
       SELECT
         MIN(casting_year || LPAD(casting_period,2,0)) AS min_casting_yyyypp,
         moe_code
       FROM fcst_hdr  t1
       WHERE company_code = par_company_code
         AND current_fcst_flag = ods_constants.fcst_current_fcst_flag_yes
         AND fcst_type_code = 'BR'  -- Period forecast
         AND EXISTS (SELECT * FROM fcst_demand_grp_local_region t2 WHERE t1.moe_code = t2.moe_code) -- only has moe set up
         AND TRUNC(fcst_hdr_lupdt, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid
       GROUP BY
         moe_code;
      rv_min_casting_period csr_min_casting_period%ROWTYPE;

      -- Get the reload period for snack BR which is one period ahead then the other business.
      CURSOR csr_snack_reload_period IS
       SELECT mars_period AS reload_yyyypp
       FROM mars_date_dim
       WHERE calendar_date = (SELECT MAX(calendar_date) + 1
                              FROM mars_date_dim
                              WHERE mars_period = v_casting_yyyypp);

      -- Used to check whether this is the first day of the current period for snack business
      -- becasue this day the moe_code = 0009 will reload to fcst_fact and we need to reload to
      -- fcst_local_region_fact as well.
      CURSOR csr_mars_date IS
       SELECT
         mars_period,
         period_day_num
       FROM mars_date_dim
       WHERE calendar_date = v_aggregation_date;
      rv_mars_date csr_mars_date%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FORECAST_REGION_FACT Load');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      FOR rv_min_casting_period IN csr_min_casting_period LOOP

        -- Handling the following unique moe_code.
        lics_logging.write_log('--> Handling - MOE/MIN Casting Period [' ||
                  rv_min_casting_period.moe_code || '/' || rv_min_casting_period.min_casting_yyyypp || ']');

        v_casting_yyyypp := rv_min_casting_period.min_casting_yyyypp;
        v_moe_code := rv_min_casting_period.moe_code;
        v_reload_yyyypp := rv_min_casting_period.min_casting_yyyypp;
        v_reload := TRUE;

        -- Snack BR type has special reload trigger.
        IF v_moe_code = '0009' THEN

           -- Get the current expected Snackfood BR casting period and compare with the received min casting period
           v_snack_br_cast_period := get_mars_period (par_date, -56);

           IF v_casting_yyyypp <= v_snack_br_cast_period THEN
              v_snack_reload := TRUE;
              v_reload := TRUE;

              -- Then reload forecast period greater than casting_yyyypp + 1
              OPEN csr_snack_reload_period;
              FETCH csr_snack_reload_period INTO v_reload_yyyypp;
              CLOSE csr_snack_reload_period;

           ELSE
              lics_logging.write_log('--> No action taken for this snackfood BR type. Reason: this casting period > casting period - 2 [' ||
                          v_casting_yyyypp || ' > ' || v_snack_br_cast_period || '].');

              v_reload :=  FALSE;
           END IF;

        END IF;

        IF v_reload = TRUE THEN
           reload_fcst_region_fact (par_company_code, v_moe_code, v_reload_yyyypp);

        END IF;
      END LOOP;

      -- Only checking for first day of period trigger if we have reload for snack today.
      IF v_snack_reload = FALSE THEN

         -- Use current date as the aggregation_date AND check whether today is the first day of the current period
         -- Snackfood, BR type has been reloaded on first day of the period, we need to reload fcst_local_region_fact
         v_aggregation_date := TRUNC(sysdate);

         OPEN csr_mars_date;
         FETCH csr_mars_date INTO rv_mars_date;
         CLOSE csr_mars_date;

         IF rv_mars_date.period_day_num = 1 THEN

            lics_logging.write_log('--> First day of period [' || rv_mars_date.mars_period || ']');

            -- We reload from current period so pass in last period becasue the reload function use greater than
            v_reload_yyyypp := get_mars_period (v_aggregation_date, -20);
            v_moe_code := '0009';

            reload_fcst_region_fact (par_company_code, v_moe_code, v_reload_yyyypp);
         ELSE
            lics_logging.write_log('--> First day of period [' || rv_mars_date.mars_period || ']');
         END IF;

      END IF;
      
      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - FORECAST_REGION_FACT Load');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Rollback the database
         /*-*/
         rollback;

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**ERROR** - FORECAST_REGION_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - DFORECAST_REGION_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end fcst_region_fact_load;
   
   /*******************************************************************/
   /* This procedure performs the forecast region fact reload routine */
   /*******************************************************************/
   procedure reload_fcst_region_fact(par_company_code in varchar2, par_moe_code in varchar2, par_reload_yyyypp in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      lics_logging.write_log('----> Start - reload_fcst_region_fact.');
      -- Delete given moe_code and fcst_yyyypp > reload_yyyypp.
      DELETE FROM fcst_local_region_fact
      WHERE
        company_code = par_company_code
        AND moe_code = par_moe_code
        AND fcst_type_code = 'BR'
        AND fcst_yyyypp > par_reload_yyyypp;

      lics_logging.write_log('----> Delete from fcst_local_region_fact where moe_code [' || par_moe_code ||
                '] and fcst_yyyypp > [' || par_reload_yyyypp || '] with count [ ' || TO_CHAR(SQL%ROWCOUNT) || ']');
      INSERT INTO fcst_local_region_fact
        (
          company_code,
          moe_code,
          sales_org_code,
          distbn_chnl_code,
          division_code,
          fcst_type_code,
          fcst_yyyypp,
          acct_assgnmnt_grp_code,
          demand_plng_grp_code,
          local_region_code,
          fcst_value
        )
      SELECT
        t1.company_code,
        t1.moe_code,
        t1.sales_org_code,
        t1.distbn_chnl_code,
        t1.division_code,
        t1.fcst_type_code,
        t1.fcst_yyyypp,
        t1.acct_assgnmnt_grp_code,
        t1.demand_plng_grp_code,
        t2.local_region_code,
        (t1.fcst_value * pct) as region_fcst_value
      FROM
        ( -- Sum up the fcst_value to group value.
          SELECT
            company_code,
            moe_code,
            sales_org_code,
            distbn_chnl_code,
            division_code,
            fcst_type_code,
            fcst_yyyypp,
            acct_assgnmnt_grp_code,
            demand_plng_grp_code,
            SUM(fcst_value) as fcst_value  -- Sum up to above grouping before dividing to local region amount.
          FROM
            fcst_fact t1
          WHERE
            fcst_yyyypp > par_reload_yyyypp
            AND company_code = par_company_code
            AND moe_code = par_moe_code
            AND fcst_type_code = 'BR'
            AND EXISTS (SELECT *
                        FROM
                          fcst_local_region_pct t2,
                          fcst_demand_grp_local_region t3
                        WHERE t2.demand_plng_grp_code = t3.demand_plng_grp_code
                          AND t3.moe_code = par_moe_code
                          AND t2.fcst_yyyypp = t1.fcst_yyyypp
                          AND t2.demand_plng_grp_code = t1.demand_plng_grp_code
                          AND t2.fcst_yyyypp > par_reload_yyyypp)  -- Only the demand group and fcst period have been set up.
          GROUP BY
            company_code,
            moe_code,
            sales_org_code,
            distbn_chnl_code,
            division_code,
            fcst_type_code,
            t1.fcst_yyyypp,
            acct_assgnmnt_grp_code,
            t1.demand_plng_grp_code) t1,
        fcst_local_region_pct t2
      WHERE t1.fcst_yyyypp = t2.fcst_yyyypp
        AND t1.demand_plng_grp_code = t2.demand_plng_grp_code
        AND t2.fcst_yyyypp > par_reload_yyyypp;

      lics_logging.write_log('----> Insert count: ' || TO_CHAR(SQL%ROWCOUNT));

      -- Commit.
      COMMIT;

      -- Completed fcst_local_region_fact aggregation.
      lics_logging.write_log('----> Completed reload_fcst_region_fact.');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end reload_fcst_region_fact;
   
   /*******************************************************/
   /* This procedure performs the get MARS period routine */
   /*******************************************************/
   function get_mars_period(par_date in date, par_offset_days in number) return number is
   
      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_mars_period IS
       SELECT mars_period as mars_period
       FROM mars_date_dim
       WHERE calendar_date = TRUNC(par_date + par_offset_days,'DD');
      rv_mars_period csr_mars_period%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin
   
      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      -- Fetch the record from the csr_mars_week cursor.
      OPEN csr_mars_period;
      FETCH csr_mars_period INTO rv_mars_period;
      IF csr_mars_period%NOTFOUND THEN
           RETURN 0;
      ELSE
           CLOSE csr_mars_period;
           RETURN rv_mars_period.mars_period;
      END IF;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end get_mars_period;

end dw_scheduled_forecast;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_scheduled_forecast for dw_app.dw_scheduled_forecast;
grant execute on dw_scheduled_forecast to public;
