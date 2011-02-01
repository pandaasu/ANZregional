/******************/
/* Package Header */
/******************/
create or replace package dw_scheduled_inventory as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_scheduled_inventory
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Scheduled Inventory

    This package contain the scheduled inventory procedures. The package exposes one
    procedure EXECUTE that performs the inventory aggregation based on the following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the forecast aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_SCHEDULED_INVENTORY where all errors are logged.

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

end dw_scheduled_inventory;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_scheduled_inventory as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure temp_table_load(par_company_code in varchar2, par_date in date);
   procedure inv_baln_fact_load(par_company_code in varchar2, par_date in date);
   procedure intransit_fact_load(par_company_code in varchar2, par_date in date);
   procedure prodn_plan_fact_load(par_company_code in varchar2, par_date in date);
   procedure proc_plan_order_fact_load(par_company_code in varchar2, par_date in date);
   procedure bifg_fact_load(par_company_code in varchar2, par_date in date);

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
      var_date date;
      var_dam1 date;
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
      var_log_prefix := 'DW - SCHEDULED_INVENTORY';
      var_log_search := 'DW_SCHEDULED_INVENTORY' || '_' || lics_stream_processor.callback_event;
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
      var_process_code := 'SCHEDULED_INVENTORY_'||var_company_code;

      /*-*/
      /* Aggregation date is always based on today when not supplied (converted using the company timezone)
      /*-*/
      if par_date is null then
         var_date := trunc(sysdate);
         var_process_date := to_char(var_date,'yyyymmdd');
         if rcd_company.company_timezone_code != 'Australia/NSW' then
            var_date := dw_to_timezone(trunc(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')),'Australia/NSW',rcd_company.company_timezone_code);
            var_process_date := to_char(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW'),'yyyymmdd');
         end if;
      else
         var_date := trunc(par_date);
         var_process_date := to_char(var_date,'yyyymmdd');
      end if;
      var_dam1 := trunc(var_date-1);

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Scheduled Inventory - Parameters(' || var_company_code || ' + ' || to_char(var_date,'yyyy/mm/dd') || ' + ' || to_char(to_date(var_process_date,'yyyymmdd'),'yyyy/mm/dd') || ')');

      /*-*/
      /* Request the lock on the process
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
         /* TEMP_TABLES load - requested date
         /*-*/
         begin
            temp_table_load(var_company_code, var_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* INV_BALN_FACT load - requested date
         /*-*/
         begin
            inv_baln_fact_load(var_company_code, var_date);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* INTRANSIT_FACT load - prior date
         /*-*/
         begin
            intransit_fact_load(var_company_code, var_dam1);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* Set the scheduled inventory trace for the current company and date when required
         /* **note** Only INV_BALN_FACT and INTRANSIT_FACT load required to trigger the reporting
         /*-*/
         if var_errors = false then
            lics_logging.write_log('Set the stream process - ('||var_process_code||' / '||var_process_date||')');
            lics_processing.set_trace(var_process_code, var_process_date);
         end if;

         /*-*/
         /* Only perform the following aggregations for Australia
         /*-*/
         if var_company_code = ods_constants.company_australia then

            /*-*/
            /* PRODN_PLAN_FACT load - prior date
            /*-*/
            begin
               prodn_plan_fact_load(var_company_code, var_dam1);
            exception
               when others then
                  var_errors := true;
            end;

            /*-*/
            /* PROC_PLAN_ORDER_FACT load - requested date
            /*-*/
            begin
               proc_plan_order_fact_load(var_company_code, var_date);
            exception
               when others then
                  var_errors := true;
            end;

            /*-*/
            /* BIFG_FACT load - prior date
            /*-*/
            begin
               bifg_fact_load(var_company_code, var_dam1);
            exception
               when others then
                  var_errors := true;
            end;

         end if;

         /*-*/
         /* Release the lock on the aggregation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;
      var_locked := false;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Scheduled Inventory');

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
                                         'DW_SCHEDULED_INVENTORY',
                                         var_email,
                                         'One or more errors occurred during the Scheduled Inventory execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - DW_SCHEDULED_INVENTORY - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;
   
   /*********************************************************************/
   /* This procedure performs the forecast temporary table load routine */
   /*********************************************************************/
   procedure temp_table_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/


      /*-*/
      /* Local cursors
      /*-*/



   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - TEMP_TABLE Load - Date('||to_char(par_date,'yyyy/mm/dd')||')');
      
      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/

      -- Deletion is required as ICS cannot guarantee that the session ID would have reset.
      -- All data is deleted from the tables to ensure there is no error.
      lics_logging.write_log('--> Delete data from all temporary tables, incase session ID has not reset.');
      DELETE
      FROM temp_stk_bal_hdr;

      DELETE
      FROM temp_mat_pid;

      DELETE
      FROM temp_mat_pch;

      -- Commit
      COMMIT;

      lics_logging.write_log('--> Inserting into TEMP_STK_BAL_HDR.');
      INSERT INTO temp_stk_bal_hdr
      SELECT
        bukrs,
        werks,
        lgort,
        budat,
        MAX(timlo)
      FROM
        sap_stk_bal_hdr
      WHERE
        bukrs = par_company_code
        AND budat = TO_CHAR(par_date,'YYYYMMDD')
        AND valdtn_status = ods_constants.valdtn_valid
      GROUP BY
        bukrs,
        werks,
        lgort,
        budat;
      COMMIT;

      lics_logging.write_log('--> Inserting into TEMP_MAT_PID.');
      INSERT INTO temp_mat_pid
      SELECT
        t02.matnr,
        t01.pchseq,
        t01.pcrseq,
        t01.pihseq,
        MAX(t01.pidseq),
        t01.trgqty,
        t01.unitqty
      FROM
        sap_mat_pid t01,
        sap_mat_hdr t02,
        sap_mat_pch t03
      WHERE
        t01.component = t02.matnr
        AND t01.detail_itemtype = ods_constants.inventory_item_type_code
        AND t02.mtart != ods_constants.material_type_verp
        AND t02.valdtn_status =  ods_constants.valdtn_valid
        AND t01.matnr = t03.matnr
        AND t01.pchseq = t03.pchseq
        AND t03.kotabnr = ods_constants.inventory_exfactory_config
      GROUP BY
        t02.matnr,
        t01.pchseq,
        t01.pcrseq,
        t01.pihseq,
        t01.trgqty,
        t01.unitqty;
      COMMIT;

      lics_logging.write_log('--> Inserting into TEMP_MAT_PCH.');
      INSERT INTO temp_mat_pch
      SELECT
        t02.matnr,
        t02.pchseq,
        t02.vkorg
      FROM
        sap_mat_hdr t01,
        sap_mat_pch t02
      WHERE
        t01.matnr = t02.matnr
        AND t02.kvewe = ods_constants.inventory_cndtn_type_code
        AND t02.kappl = ods_constants.inventory_pkg_object_code
        AND t02.kschl = ods_constants.inventory_dtmntn_type_code
        AND t02.kotabnr = ods_constants.inventory_exfactory_config
        AND t01.valdtn_status = ods_constants.valdtn_valid;
      COMMIT;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - TEMP_TABLE Load');

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
            lics_logging.write_log('**ERROR** - TEMP_TABLE Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - TEMP_TABLE Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end temp_table_load;

   /*******************************************************************/
   /* This procedure performs the inventory balance fact load routine */
   /*******************************************************************/
   procedure inv_baln_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_year_num NUMBER(4);
      v_week_num  NUMBER(2);
      v_day_code  VARCHAR2(1);
      v_day_num NUMBER(1);
      v_period_num NUMBER(2,2);
      v_start_week NUMBER(4);
      v_prodn_yyyyppdd NUMBER(8);
      v_start_year NUMBER(4);
      v_prodn_ddmmyyyy DATE;
      v_current_decade NUMBER(4);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_inventory_count IS
       SELECT count(*) AS inventory_count
       FROM sap_stk_bal_hdr a
       WHERE a.bukrs = par_company_code
       AND a.budat = TO_CHAR(par_date,'YYYYMMDD');
       rv_inventory_count csr_inventory_count%ROWTYPE;

      CURSOR csr_inv_data IS
       SELECT /*+ INDEX(A SAP_STK_BAL_HDR_PK) */
         a.bukrs AS company_code,
         a.werks AS plant_code,
         a.lgort AS storage_locn_code,
         TO_DATE(a.budat, 'YYYYMMDD') AS inv_baln_date,
         c.mars_yyyyppdd AS inv_baln_yyyyppdd,
         b.detseq AS inv_baln_dtl_seq,
         LTRIM(b.matnr, 0) AS matl_code,
         b.charg AS batch_num,
         NVL(b.menga, 0) AS inv_baln_base_uom_qty,
         b.altme AS inv_baln_base_uom_code,
         TO_DATE(b.vfdat, 'YYYYMMDD') AS best_before_date,
         b.insmk AS inv_type_code,
         ROUND(d.stprs/d.peinh,2) AS std_cost,
         -- Convert base qty on stock balance table, to UOM qty found on MAT_PID table.
         -- If MAT_PID has item in PCE qty and BUOM is CS, qty must be converted to PCE qty,
         -- before pallet calculation can be performed.
         DECODE(i.meinh, NULL, NULL, NVL(b.menga, 0) / (NVL(i.umrez, 0)/NVL(i.umren, 1))) / NVL(h.trgqty, 1) AS inv_baln_plt_qty,
         NVL(DECODE(k.gewei,
            ods_constants.uom_tonnes, DECODE(k.brgew,NULL,0,k.brgew),
            ods_constants.uom_kilograms, (DECODE(k.brgew,NULL,0,k.brgew) / 1000)*NVL(b.menga, 0),
            ods_constants.uom_grams, (DECODE(k.brgew,NULL,0,k.brgew) / 1000000)*NVL(b.menga, 0),
            ods_constants.uom_milligrams, (DECODE(k.brgew,NULL,0,k.brgew) / 1000000000)*NVL(b.menga, 0),
            0),0) AS inv_baln_qty_gross_tonnes,
         NVL(DECODE(k.gewei,
            ods_constants.uom_tonnes, k.ntgew,
            ods_constants.uom_kilograms, (k.ntgew / 1000)* NVL(b.menga, 0),
            ods_constants.uom_grams, (k.ntgew / 1000000)* NVL(b.menga, 0),
            ods_constants.uom_milligrams, (k.ntgew / 1000000000)*NVL(b.menga, 0),
            0),0) AS inv_baln_qty_net_tonnes
       FROM
         sap_stk_bal_hdr a,
         sap_stk_bal_det b,
         mars_date c,
         sap_mat_mbe d,
         temp_mat_pch e,
         sap_mat_pcr f,
         sap_mat_pih g,
         temp_mat_pid h,
         sap_mat_uom i,
         temp_stk_bal_hdr j,
         sap_mat_hdr k
       WHERE
         a.bukrs = b.bukrs
         AND a.werks = b.werks
         AND a.lgort = b.lgort
         AND a.budat = b.budat
         AND a.timlo = b.timlo
         AND a.bukrs = j.bukrs
         AND a.werks = j.werks
         AND a.lgort = j.lgort
         AND a.budat = j.budat
         AND a.timlo = j.timlo
         AND b.matnr = k.matnr
         AND a.budat = c.yyyymmdd_date -- c Inventory Balance YYYYPPDD
         AND b.matnr = d.matnr(+) -- d Standard Cost
         AND b.werks = d.bwkey(+)
         AND d.matnr = e.matnr(+)
         AND e.matnr = f.matnr(+)
         AND e.pchseq = f.pchseq(+)
         -- Note: Default dates in decode will mean record is returned if found.
         AND decode(f.datab, null, a.budat, f.datab) <= a.budat -- Start Date
         AND decode(f.datbi, null, a.budat, f.datbi) >= a.budat -- End Date
         AND f.matnr = g.matnr(+)
         AND f.pchseq = g.pchseq(+)
         AND f.pcrseq = g.pcrseq(+)
         AND g.matnr = h.matnr(+)
         AND g.pchseq = h.pchseq(+)
         AND g.pcrseq = h.pcrseq(+)
         AND g.pihseq = h.pihseq(+)
         AND h.matnr = i.matnr(+)
         AND h.unitqty = i.meinh(+)
         AND a.valdtn_status = ods_constants.valdtn_valid
         AND k.valdtn_status = ods_constants.valdtn_valid
         AND e.vkorg(+) = par_company_code
         AND a.bukrs = par_company_code
         AND a.budat = TO_CHAR(par_date,'YYYYMMDD');
       rv_inv_data csr_inv_data%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - INV_BALN_FACT Load - Date('||to_char(par_date,'yyyy/mm/dd')||')');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/

      -- Fetch the record from the csr_inventory_count cursor.
      OPEN csr_inventory_count;
      FETCH csr_inventory_count INTO rv_inventory_count.inventory_count;
      CLOSE csr_inventory_count;

      -- If any inventory balances were received today continue the aggregation process.
      lics_logging.write_log('--> Checking whether any inventory balances were received today.');

      IF rv_inventory_count.inventory_count > 0 THEN

       -- Delete any inventory balances that may already exist for the company being aggregated.
       lics_logging.write_log('--> Deleting from INV_BALN_FACT.');
       DELETE FROM inv_baln_fact
       WHERE company_code = par_company_code
       AND TRUNC(inv_baln_date,'DD') = TRUNC(par_date,'DD');

       -- Insert into inv_baln_fact table based on company code and date.
       lics_logging.write_log('--> Inserting into the INV_BALN_FACT table.');
       OPEN csr_inv_data;
       FETCH csr_inv_data INTO rv_inv_data;
       WHILE csr_inv_data%FOUND LOOP

         -- Set variables to null.
         v_prodn_yyyyppdd := NULL;
         v_prodn_ddmmyyyy := NULL;

         -- If batch number exists, then calculate the production date.
         IF rv_inv_data.batch_num IS NOT NULL THEN

           BEGIN
             v_year_num := TO_NUMBER(SUBSTR(rv_inv_data.batch_num, 1, 1));
             v_week_num := TO_NUMBER(SUBSTR(rv_inv_data.batch_num, 2, 2));

             -- Retrieve the current decade.
             v_current_decade := TO_NUMBER(TO_CHAR(SYSDATE,'YYYY'));

             -- Find the mars date week number for the beginning of the year.
             -- If the year finishes with 9, then check current year is not the
             -- first year of a new decade.  If it is, last decade is used for
             -- the manufacturing date.
             IF v_year_num = 9 THEN
              IF SUBSTR(TO_CHAR(SYSDATE,'YYYY'), 4, 1) = '0' THEN
                 v_current_decade := TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - 1;
               END IF;
             END IF;

             -- Retrieve the current decade: use the first three digits.
             v_current_decade := TRUNC(v_current_decade/10);

             -- Retrieve the mars year.
             SELECT DISTINCT
               mars_year
             INTO
               v_start_year
             FROM
               mars_date_dim
             WHERE
               mars_year = v_current_decade || v_year_num;

             -- Retrieve the day code from the batch code number.
             v_day_code := substr(rv_inv_data.batch_num, 4, 1);

             -- Convert the day code to a number suitable for mars date addition.
             v_day_num :=
             CASE v_day_code
               WHEN 'A' THEN 1
               WHEN 'B' THEN 2
               WHEN 'C' THEN 3
               WHEN 'D' THEN 4
               WHEN 'E' THEN 5
               WHEN 'F' THEN 6
               WHEN 'G' THEN 0
               ELSE NULL
             END;

             -- Retrieve the yyyyppdd for the beginning of the week.
             SELECT
               MIN(mars_yyyyppdd)
             INTO
               v_prodn_yyyyppdd
             FROM
               mars_date_dim
             WHERE
               mars_week_of_year = v_week_num
               AND mars_year = v_start_year;

             -- Retrieve week start date in Gregorian calendar date format.
             SELECT
               calendar_date
             INTO
               v_prodn_ddmmyyyy
             FROM
               mars_date_dim
             WHERE
               mars_yyyyppdd = v_prodn_yyyyppdd;

             -- Calculate production date in yyyyppdd format.
             v_prodn_ddmmyyyy := v_prodn_ddmmyyyy + v_day_num;

             -- Retrieve production date in yyyyppdd format.
             SELECT
               mars_yyyyppdd
             INTO
               v_prodn_yyyyppdd
             FROM
               mars_date_dim
             WHERE
               calendar_date = v_prodn_ddmmyyyy;

           EXCEPTION
             WHEN OTHERS THEN
               v_prodn_ddmmyyyy := NULL;
               v_prodn_yyyyppdd := NULL;
           END;

       END IF; -- End If for batch_num is NOT NULL


       INSERT INTO inv_baln_fact
         (
         company_code,
         plant_code,
         storage_locn_code,
         inv_baln_date,
         inv_baln_yyyyppdd,
         inv_prodn_date,
         inv_prodn_yyyyppdd,
         inv_baln_dtl_seq,
         matl_code,
         batch_num,
         inv_baln_base_uom_qty,
         inv_baln_base_uom_code,
         best_before_date,
         inv_type_code,
         std_cost,
         inv_baln_plt_qty,
         inv_baln_qty_gross_tonnes,
         inv_baln_qty_net_tonnes
         )
       VALUES
        (
         rv_inv_data.company_code,
         rv_inv_data.plant_code,
         rv_inv_data.storage_locn_code,
         rv_inv_data.inv_baln_date,
         rv_inv_data.inv_baln_yyyyppdd,
         v_prodn_ddmmyyyy,
         v_prodn_yyyyppdd,
         rv_inv_data.inv_baln_dtl_seq,
         rv_inv_data.matl_code,
         rv_inv_data.batch_num,
         rv_inv_data.inv_baln_base_uom_qty,
         rv_inv_data.inv_baln_base_uom_code,
         rv_inv_data.best_before_date,
         rv_inv_data.inv_type_code,
         rv_inv_data.std_cost,
         rv_inv_data.inv_baln_plt_qty,
         rv_inv_data.inv_baln_qty_gross_tonnes,
         rv_inv_data.inv_baln_qty_net_tonnes
        );

         FETCH csr_inv_data INTO rv_inv_data;
       END LOOP;

       -- Commit.
       COMMIT;

      END IF;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - INV_BALN_FACT Load');

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
            lics_logging.write_log('**ERROR** - INV_BALN_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - INV_BALN_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end inv_baln_fact_load;

   /***********************************************************/
   /* This procedure performs the intransit fact load routine */
   /***********************************************************/
   procedure intransit_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_year_num NUMBER(4);
      v_week_num  NUMBER(2);
      v_day_code  VARCHAR2(1);
      v_day_num NUMBER(1);
      v_period_num NUMBER(2,2);
      v_start_week NUMBER(4);
      v_prodn_yyyyppdd NUMBER(8);
      v_start_year NUMBER(4);
      v_prodn_ddmmyyyy DATE;
      v_current_decade NUMBER(4);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_intransit_count IS
       SELECT count(*) AS intransit_count
       FROM sap_int_stk_hdr a, sap_int_stk_det b
       WHERE a.werks = b.werks
       AND b.burks = par_company_code
       AND TRUNC(a.sap_int_stk_hdr_lupdt, 'DD') = par_date;
       rv_intransit_count csr_intransit_count%ROWTYPE;

      CURSOR csr_intransit_data IS
       SELECT
         a.werks AS plant_code,
         b.detseq AS intransit_dtl_seq,
         b.burks AS company_code,
         b.vgbel AS purch_order_num,
         b.vend AS vendor_code,
         b.tknum AS shipment_num,
         b.vbeln AS intransit_doc_num,
         b.werks1 AS srce_plant_code,
         b.logort1 AS srce_storage_locn_code,
         b.werks2 AS srce_shipg_plant_code,
         b.werks3 AS dest_plant_code,
         b.lgort AS dest_storage_locn_code,
         DECODE(TRUNC(b.aedat), 0, TO_DATE('99991231', 'YYYYMMDD'), TO_DATE(b.aedat, 'YYYYMMDD')) AS shipg_date,
         DECODE(TRUNC(b.zardte), 0, TO_DATE('99991231', 'YYYYMMDD'), TO_DATE(b.zardte, 'YYYYMMDD')) AS arrvl_date,
         DECODE(TRUNC(b.verab), 0, TO_DATE('99991231', 'YYYYMMDD'), TO_DATE(b.verab, 'YYYYMMDD')) AS maturation_date,
         DECODE(TRUNC(b.atwrt), 0, TO_DATE('99991231', 'YYYYMMDD'), TO_DATE(b.atwrt, 'YYYYMMDD')) AS best_before_date,
         b.charg AS batch_num,
         b.vsbed AS transport_model_code,
         LTRIM(b.matnr, 0) AS matl_code,
         NVL(b.lfimg, 0) AS intransit_base_uom_qty,
         b.meins AS intransit_base_uom_code,
         b.exidv2 AS contnr_num,
         b.exti1 AS vessel_name,
         b.signi AS voyage_desc,
         b.insmk AS inv_type_code,
         b.bsart AS purch_order_type_code,
         -- Convert base qty on stock intransit table, to UOM qty found on MAT_PID table.
         -- If MAT_PID has item in PCE qty and BUOM is CS, qty must be converted to PCE qty,
         -- before pallet calculation can be performed.
         DECODE(g.meinh, NULL, NULL, NVL(b.lfimg, 0) / (NVL(g.umrez, 0)/NVL(g.umren, 1))) / NVL(f.trgqty, 1) AS intransit_plt_qty,
         NVL(DECODE(h.gewei,
            ods_constants.uom_tonnes, DECODE(h.brgew,NULL,0,h.brgew),
            ods_constants.uom_kilograms, (DECODE(h.brgew,NULL,0,h.brgew) / 1000)*NVL(b.lfimg, 0),
            ods_constants.uom_grams, (DECODE(h.brgew,NULL,0,h.brgew) / 1000000)*NVL(b.lfimg, 0),
            ods_constants.uom_milligrams, (DECODE(h.brgew,NULL,0,h.brgew) / 1000000000)*NVL(b.lfimg, 0),
            0),0) AS intransit_qty_gross_tonnes,
         NVL(DECODE(h.gewei,
            ods_constants.uom_tonnes, h.ntgew,
            ods_constants.uom_kilograms, (h.ntgew / 1000)* NVL(b.lfimg, 0),
            ods_constants.uom_grams, (h.ntgew / 1000000)* NVL(b.lfimg, 0),
            ods_constants.uom_milligrams, (h.ntgew / 1000000000)*NVL(b.lfimg, 0),
            0),0) AS intransit_qty_net_tonnes
       FROM
         sap_int_stk_hdr a,
         sap_int_stk_det b,
         temp_mat_pch c,
         sap_mat_pcr d,
         sap_mat_pih e,
         temp_mat_pid f,
         sap_mat_uom g,
         sap_mat_hdr h
       WHERE
         a.werks = b.werks
         AND TRUNC(a.sap_int_stk_hdr_lupdt, 'DD') = par_date
         AND b.matnr = h.matnr
         AND b.matnr = c.matnr(+)
         AND c.matnr = d.matnr(+)
         AND c.pchseq = d.pchseq(+)
         -- Note: Default dates in decode will mean record is returned if found.
         AND decode(d.datab, null, DECODE(TRUNC(b.aedat), 0, '19000101',b.aedat), d.datab) <=  DECODE(TRUNC(b.aedat), 0, '19000101',b.aedat)  -- Start Date
         AND decode(d.datbi, null, DECODE(TRUNC(b.aedat), 0, '99991231',b.aedat), d.datbi) >=  DECODE(TRUNC(b.aedat), 0, '99991231',b.aedat)  -- End Date:
         AND d.matnr = e.matnr(+)
         AND d.pchseq = e.pchseq(+)
         AND d.pcrseq = e.pcrseq(+)
         AND e.matnr = f.matnr(+)
         AND e.pchseq = f.pchseq(+)
         AND e.pcrseq = f.pcrseq(+)
         AND e.pihseq = f.pihseq(+)
         AND f.matnr = g.matnr(+)
         AND f.unitqty = g.meinh(+)
         AND c.vkorg(+) = par_company_code
         AND a.valdtn_status = ods_constants.valdtn_valid
         AND b.burks = par_company_code;
       rv_intransit_data csr_intransit_data%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - INTRANSIT_FACT Load - Date('||to_char(par_date,'yyyy/mm/dd')||')');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      
      -- Fetch the record from the csr_intransit_count cursor.
      OPEN csr_intransit_count;
      FETCH csr_intransit_count INTO rv_intransit_count.intransit_count;
      CLOSE csr_intransit_count;

      -- If any inventory intransits were received today continue the aggregation process.
      lics_logging.write_log('--> Checking whether any inventory intransits were received today.');

      IF rv_intransit_count.intransit_count > 0 THEN

       -- Delete all inventory intransits that exist for the company being aggregated.
       lics_logging.write_log('--> Deleting from INTRANSIT_FACT.');
       DELETE FROM intransit_fact
       WHERE company_code = par_company_code;

       -- Insert into intransit_fact table based on company code and date.
       lics_logging.write_log('--> Inserting into the INTRANSIT_FACT table.');
       OPEN csr_intransit_data;
       FETCH csr_intransit_data INTO rv_intransit_data;
       WHILE csr_intransit_data%FOUND LOOP

         -- Set variables to null.
         v_prodn_yyyyppdd := NULL;
         v_prodn_ddmmyyyy := NULL;

         -- If batch number exists, then calculate the production date.
         IF rv_intransit_data.batch_num IS NOT NULL THEN

           BEGIN
             v_year_num := TO_NUMBER(SUBSTR(rv_intransit_data.batch_num, 1, 1));
             v_week_num := TO_NUMBER(SUBSTR(rv_intransit_data.batch_num, 2, 2));

             -- Retrieve the current decade.
             v_current_decade := TO_NUMBER(TO_CHAR(SYSDATE,'YYYY'));

             -- Find the mars date week number for the beginning of the year.
             -- If the year finishes with 9, then check current year is not the
             -- first year of a new decade.  If it is, last decade is used for
             -- the manufacturing date.
             IF v_year_num = 9 THEN
              IF SUBSTR(TO_CHAR(SYSDATE,'YYYY'), 4, 1) = '0' THEN
                 v_current_decade := TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - 1;
               END IF;
             END IF;

             -- Retrieve the current decade: use the first three digits.
             v_current_decade := TRUNC(v_current_decade/10);

             -- Retrieve the mars year.
             SELECT DISTINCT
               mars_year
             INTO
               v_start_year
             FROM
               mars_date_dim
             WHERE
               mars_year = v_current_decade || v_year_num;

             -- Retrieve the day code from the batch code number.
             v_day_code := substr(rv_intransit_data.batch_num, 4, 1);

             -- Convert the day code to a number suitable for mars date addition.
             v_day_num :=
             CASE v_day_code
               WHEN 'A' THEN 1
               WHEN 'B' THEN 2
               WHEN 'C' THEN 3
               WHEN 'D' THEN 4
               WHEN 'E' THEN 5
               WHEN 'F' THEN 6
               WHEN 'G' THEN 0
               ELSE NULL
             END;

             -- Find the yyyyppdd for the beginning of the week.
             SELECT
               MIN(mars_yyyyppdd)
             INTO
               v_prodn_yyyyppdd
             FROM
               mars_date_dim
             WHERE
               mars_week_of_year = v_week_num
               AND mars_year = v_start_year;

             -- Retrieve week start date in Gregorian calendar date format.
             SELECT
               calendar_date
             INTO
               v_prodn_ddmmyyyy
             FROM
               mars_date_dim
             WHERE
               mars_yyyyppdd = v_prodn_yyyyppdd;

             -- Calculate production date in yyyyppdd format.
             v_prodn_ddmmyyyy := v_prodn_ddmmyyyy + v_day_num;

             -- Retrieve production date in yyyyppdd format.
             SELECT
               mars_yyyyppdd
             INTO
               v_prodn_yyyyppdd
             FROM
               mars_date_dim
             WHERE
               calendar_date = v_prodn_ddmmyyyy;

           EXCEPTION
             WHEN OTHERS THEN
               v_prodn_ddmmyyyy := NULL;
               v_prodn_yyyyppdd := NULL;
           END;

       END IF; -- End If for batch_num is NOT NULL

        INSERT INTO intransit_fact
         (
         plant_code,
         intransit_dtl_seq,
         company_code,
         purch_order_num,
         vendor_code,
         shipment_num,
         intransit_doc_num,
         srce_plant_code,
         srce_storage_locn_code,
         srce_shipg_plant_code,
         dest_plant_code,
         dest_storage_locn_code,
         inv_prodn_date,
         inv_prodn_yyyyppdd,
         shipg_date,
         arrvl_date,
         maturation_date,
         best_before_date,
         batch_num,
         transport_model_code,
         matl_code,
         intransit_base_uom_qty,
         intransit_base_uom_code,
         contnr_num,
         vessel_name,
         voyage_desc,
         inv_type_code,
         purch_order_type_code,
         intransit_plt_qty,
         intransit_qty_gross_tonnes,
         intransit_qty_net_tonnes
         )
       VALUES
        (
         rv_intransit_data.plant_code,
         rv_intransit_data.intransit_dtl_seq,
         rv_intransit_data.company_code,
         rv_intransit_data.purch_order_num,
         rv_intransit_data.vendor_code,
         rv_intransit_data.shipment_num,
         rv_intransit_data.intransit_doc_num,
         rv_intransit_data.srce_plant_code,
         rv_intransit_data.srce_storage_locn_code,
         rv_intransit_data.srce_shipg_plant_code,
         rv_intransit_data.dest_plant_code,
         rv_intransit_data.dest_storage_locn_code,
         v_prodn_ddmmyyyy,
         v_prodn_yyyyppdd,
         rv_intransit_data.shipg_date,
         rv_intransit_data.arrvl_date,
         rv_intransit_data.maturation_date,
         rv_intransit_data.best_before_date,
         rv_intransit_data.batch_num,
         rv_intransit_data.transport_model_code,
         rv_intransit_data.matl_code,
         rv_intransit_data.intransit_base_uom_qty,
         rv_intransit_data.intransit_base_uom_code,
         rv_intransit_data.contnr_num,
         rv_intransit_data.vessel_name,
         rv_intransit_data.voyage_desc,
         rv_intransit_data.inv_type_code,
         rv_intransit_data.purch_order_type_code,
         rv_intransit_data.intransit_plt_qty,
         rv_intransit_data.intransit_qty_gross_tonnes,
         rv_intransit_data.intransit_qty_net_tonnes
       );

         FETCH csr_intransit_data INTO rv_intransit_data;
       END LOOP;

       -- Commit.
       COMMIT;
      END IF;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - INTRANSIT_FACT Load');

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
            lics_logging.write_log('**ERROR** - INTRANSIT_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - INTRANSIT_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end intransit_fact_load;
   
   /*****************************************************************/
   /* This procedure performs the production plan fact load routine */
   /*****************************************************************/
   procedure prodn_plan_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_fcst_type VARCHAR2(4 CHAR);
      v_moe_code VARCHAR2(4 CHAR);
      v_casting_year NUMBER(4);
      v_casting_period NUMBER(6);
      v_casting_week NUMBER(7);

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_prodn_plan_hdr IS
       SELECT DISTINCT
         casting_year,
         casting_period,
         casting_week,
         prodn_plan_type_code,
         moe_code,
         prodn_plan_hdr_lupdt
       FROM
         prodn_plan_hdr
       WHERE
         valdtn_status = ods_constants.valdtn_valid
         AND prodn_plan_rcncln_flag = ods_constants.fcst_current_fcst_flag_yes
         AND TRUNC(prodn_plan_hdr_lupdt, 'DD') = par_date
       ORDER BY
         prodn_plan_hdr_lupdt ASC;
      rv_prodn_plan_hdr csr_prodn_plan_hdr%ROWTYPE;

      -- Select the casting week for the production plan that is to be aggregated.
      CURSOR csr_prodn_plan_week_fact IS
       SELECT DISTINCT
         casting_yyyyppw
       FROM
         prodn_plan_fact
       WHERE
         prodn_plan_type_code = v_fcst_type
         AND moe_code = v_moe_code
         AND casting_yyyyppw = v_casting_week;
      rv_prodn_plan_week_fact csr_prodn_plan_week_fact%ROWTYPE;

      -- Select the casting period for the production plan that is to be aggregated.
      CURSOR csr_prodn_plan_period_fact IS
       SELECT DISTINCT
         casting_yyyypp
       FROM
         prodn_plan_fact
       WHERE
         prodn_plan_type_code = v_fcst_type
         AND moe_code = v_moe_code
         AND casting_yyyypp = v_casting_period;
      rv_prodn_plan_period_fact csr_prodn_plan_period_fact%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PRODN_PLAN_FACT Load - Date('||to_char(par_date,'yyyy/mm/dd')||')');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      
       -- Loop through all records in the cursor.
       FOR rv_prodn_plan_hdr IN csr_prodn_plan_hdr LOOP

         v_fcst_type := rv_prodn_plan_hdr.prodn_plan_type_code;
         v_moe_code := rv_prodn_plan_hdr.moe_code;
         v_casting_period := rv_prodn_plan_hdr.casting_year || LPAD(rv_prodn_plan_hdr.casting_period,2,0);
         v_casting_week := rv_prodn_plan_hdr.casting_year || LPAD(rv_prodn_plan_hdr.casting_period,2,0) || rv_prodn_plan_hdr.casting_week;

         IF v_fcst_type = ods_constants.fcst_type_fcst_weekly THEN

            -- Check if production plan already exists in prodn_plan_fact table.
            OPEN csr_prodn_plan_week_fact;
            FETCH csr_prodn_plan_week_fact INTO rv_prodn_plan_week_fact;

            -- If production plan already exists, then delete from the DDS table.
            IF csr_prodn_plan_week_fact%FOUND THEN

              lics_logging.write_log('--> Production plan with casting week ' || v_casting_week || ', production plan type ' || v_fcst_type || ' and MOE ' || v_moe_code || ' exists in the DDS.');
              lics_logging.write_log('--> Deleting production plan from DDS table.');
              DELETE FROM prodn_plan_fact t01
              WHERE t01.prodn_plan_type_code = v_fcst_type
                AND t01.moe_code = v_moe_code
                AND t01.casting_yyyyppw = v_casting_week;

             END IF;

              -- Insert into the production plan table.
              lics_logging.write_log('--> Insert prodn plan for week ' || rv_prodn_plan_hdr.casting_week || ' and prodn plan type ' || rv_prodn_plan_hdr.prodn_plan_type_code || ' into prodn_plan_fact.');
              INSERT INTO prodn_plan_fact
              (
                prodn_plan_type_code,
              casting_yyyypp,
                casting_yyyyppw,
                prodn_plan_yyyyppw,
                prodn_plan_yyyypp,
                plant_code,
                matl_code,
                prodn_plan_base_uom_qty,
              prodn_plan_qty_gross_tonnes,
              prodn_plan_qty_net_tonnes,
              moe_code
              )
             SELECT
               t01.prodn_plan_type_code,
               t01.casting_year || LPAD(t01.casting_period,2,0),
               t01.casting_year || LPAD(t01.casting_period,2,0) || t01.casting_week,
               t02.prodn_plan_week,
               substr(t02.prodn_plan_week, 0, 6), -- Production Plan Period
               t02.plant_code,
               LTRIM(t02.matl_code,'0'),
               t02.prodn_plan_base_uom_qty,
               NVL(DECODE(t03.gewei,
                   ods_constants.uom_tonnes, DECODE(t03.brgew,NULL,0,t03.brgew),
                   ods_constants.uom_kilograms, (DECODE(t03.brgew,NULL,0,t03.brgew) / 1000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_grams, (DECODE(t03.brgew,NULL,0,t03.brgew) / 1000000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_milligrams, (DECODE(t03.brgew,NULL,0,t03.brgew) / 1000000000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   0),0) AS prodn_plan_qty_gross_tonnes,
               NVL(DECODE(t03.gewei,
                   ods_constants.uom_tonnes, t03.ntgew,
                   ods_constants.uom_kilograms, (t03.ntgew / 1000)* NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_grams, (t03.ntgew / 1000000)* NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_milligrams, (t03.ntgew / 1000000000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   0),0) AS prodn_plan_qty_net_tonnes,
               t01.moe_code
             FROM
               prodn_plan_hdr t01,
               prodn_plan_dtl t02,
               sap_mat_hdr t03
             WHERE
               t01.prodn_plan_hdr_code = t02.prodn_plan_hdr_code
               AND t02.matl_code = LTRIM(t03.matnr, '0')
                AND t01.prodn_plan_type_code = v_fcst_type
                AND t01.casting_year = rv_prodn_plan_hdr.casting_year
               AND t01.casting_period = rv_prodn_plan_hdr.casting_period
               AND t01.casting_week = rv_prodn_plan_hdr.casting_week
               AND t03.valdtn_status = ods_constants.valdtn_valid;

             COMMIT;

             CLOSE csr_prodn_plan_week_fact;
         -- If forecast type NOT equal to weekly, then period aggregation must be performed.
         ELSE
            -- Check if production plan already exists in prodn_plan_fact table.
            OPEN csr_prodn_plan_period_fact;
            FETCH csr_prodn_plan_period_fact INTO rv_prodn_plan_period_fact;

            -- If production plan already exists, then delete from the DDS table.
            IF csr_prodn_plan_period_fact%FOUND THEN

              lics_logging.write_log('--> Production plan with casting period of ' || v_casting_period || ', production plan type ' || v_fcst_type || ' and MOE ' || v_moe_code || ' exists in the DDS.');
              lics_logging.write_log('--> Deleting production plan from DDS table.');
              DELETE FROM prodn_plan_fact t01
              WHERE t01.prodn_plan_type_code = v_fcst_type
               AND t01.moe_code = v_moe_code
               AND t01.casting_yyyypp = v_casting_period;

             END IF;

              -- Insert into the production plan table.
              lics_logging.write_log('--> Insert prodn plan for period ' || v_casting_period || ' and prodn plan type ' || rv_prodn_plan_hdr.prodn_plan_type_code || ' into prodn_plan_fact.');
              INSERT INTO prodn_plan_fact
              (
                prodn_plan_type_code,
              casting_yyyypp,
              casting_yyyyppw,
                prodn_plan_yyyyppw,
                prodn_plan_yyyypp,
                plant_code,
                matl_code,
                prodn_plan_base_uom_qty,
              prodn_plan_qty_gross_tonnes,
              prodn_plan_qty_net_tonnes,
              moe_code
              )
             SELECT
               t01.prodn_plan_type_code,
               t01.casting_year || LPAD(t01.casting_period,2,0),
               NULL,
               t02.prodn_plan_week,
               substr(t02.prodn_plan_week, 0, 6), -- Production Plan Period
               t02.plant_code,
               LTRIM(t02.matl_code,'0'),
               t02.prodn_plan_base_uom_qty,
               NVL(DECODE(t03.gewei,
                   ods_constants.uom_tonnes, DECODE(t03.brgew,NULL,0,t03.brgew),
                   ods_constants.uom_kilograms, (DECODE(t03.brgew,NULL,0,t03.brgew) / 1000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_grams, (DECODE(t03.brgew,NULL,0,t03.brgew) / 1000000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_milligrams, (DECODE(t03.brgew,NULL,0,t03.brgew) / 1000000000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   0),0) AS prodn_plan_qty_gross_tonnes,
               NVL(DECODE(t03.gewei,
                   ods_constants.uom_tonnes, t03.ntgew,
                   ods_constants.uom_kilograms, (t03.ntgew / 1000)* NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_grams, (t03.ntgew / 1000000)* NVL( t02.prodn_plan_base_uom_qty, 0),
                   ods_constants.uom_milligrams, (t03.ntgew / 1000000000)*NVL( t02.prodn_plan_base_uom_qty, 0),
                   0),0) AS prodn_plan_qty_net_tonnes,
               t01.moe_code
             FROM
               prodn_plan_hdr t01,
               prodn_plan_dtl t02,
               sap_mat_hdr t03
             WHERE
               t01.prodn_plan_hdr_code = t02.prodn_plan_hdr_code
               AND t02.matl_code = LTRIM(t03.matnr, '0')
                 AND t01.prodn_plan_type_code = v_fcst_type
                 AND t01.casting_year = rv_prodn_plan_hdr.casting_year
               AND t01.casting_period = rv_prodn_plan_hdr.casting_period
               AND t03.valdtn_status = ods_constants.valdtn_valid;

             COMMIT;

             CLOSE csr_prodn_plan_period_fact;
         END IF;

       END LOOP;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PRODN_PLAN_FACT Load');

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
            lics_logging.write_log('**ERROR** - PRODN_PLAN_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - PRODN_PLAN_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end prodn_plan_fact_load;
   
   /***********************************************************************/
   /* This procedure performs the process planned order fact load routine */
   /***********************************************************************/
   procedure proc_plan_order_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_start_yyyyppdd NUMBER;
      v_end_yyyyppdd NUMBER;
      v_base_uom_code VARCHAR2(3);
      v_base_uom_qty NUMBER;
      v_numerator NUMBER;
      v_demoninator NUMBER;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_ods_ppo IS
       SELECT *
       FROM
         sap_ppo_hdr
       WHERE
         coco = par_company_code
         AND TRUNC(sap_ppo_hdr_load_date, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid;
      rv_ods_ppo csr_ods_ppo%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PROC_PLAN_ORDER_FACT Load - Date('||to_char(par_date,'yyyy/mm/dd')||')');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      
       -- If an process and planned orders exist in the DDS, delete them.
       lics_logging.write_log('--> Check if process and planned cursor contains records.');
       OPEN csr_ods_ppo;
       FETCH csr_ods_ppo INTO rv_ods_ppo;
       IF csr_ods_ppo%FOUND THEN
         lics_logging.write_log('--> Deleting all records from PROC_PLAN_ORDER_FACT.');
         DELETE
         FROM
           proc_plan_order_fact
         WHERE
           company_code = par_company_code;
       END IF;
       CLOSE csr_ods_ppo;

       -- Retrieve the YYYYPPDD start and end dates.
       lics_logging.write_log('--> Insert all records retrieved from the ODS.');

       -- Loop through each record returned from the ODS.
       FOR rv_ods_ppo IN csr_ods_ppo LOOP

         SELECT
           t02.mars_yyyyppdd INTO v_start_yyyyppdd
         FROM
           sap_ppo_hdr t01,
           mars_date t02
         WHERE
           t02.yyyymmdd_date LIKE SUBSTR(t01.start_date_time,0,8)
           AND t01.order_id = rv_ods_ppo.order_id;

         SELECT
           t02.mars_yyyyppdd INTO v_end_yyyyppdd
         FROM
           sap_ppo_hdr t01,
           mars_date t02
         WHERE
           t02.yyyymmdd_date LIKE SUBSTR(t01.end_date_time,0,8)
           AND t01.order_id = rv_ods_ppo.order_id;

         -- Find Base UOM
         SELECT
           meins
         INTO
           v_base_uom_code
           FROM
           sap_mat_hdr
           WHERE
           sap_mat_hdr.matnr = rv_ods_ppo.item;

         -- If billed UOM is not base UOM, then find base UOM and convert quantity.
         IF v_base_uom_code = rv_ods_ppo.uom THEN
           v_base_uom_qty := rv_ods_ppo.quantity;
         ELSE
           SELECT
             sap_mat_uom.umrez,
             sap_mat_uom.umren
           INTO
             v_numerator,
             v_demoninator
             FROM
             sap_mat_uom
             WHERE
             sap_mat_uom.matnr  = rv_ods_ppo.item
               AND sap_mat_uom.meinh = rv_ods_ppo.uom;

           v_base_uom_qty := (TO_NUMBER(v_numerator)/TO_NUMBER(v_demoninator)) * rv_ods_ppo.quantity;
         END IF;

         -- Insert into the process and planned orders fact table.
         INSERT INTO proc_plan_order_fact
          ( company_code,
            proc_order_num,
            plant_code,
            prodn_line_code,
            matl_code,
            order_profile_code,
            mrp_area_code,
            start_date,
            start_time,
            start_yyyyppdd,
            end_date,
            end_time,
            end_yyyyppdd,
            order_status,
            mstr_recpe_code,
            achvmt_qty,
            order_qty,
            order_qty_uom_code,
            base_uom_order_qty,
            order_qty_base_uom_code
          )
          VALUES
          (
            rv_ods_ppo.coco,
            rv_ods_ppo.order_id,
            rv_ods_ppo.location,
            rv_ods_ppo.line,
            LTRIM(rv_ods_ppo.item,'0'),
            rv_ods_ppo.order_profil,
            rv_ods_ppo.mrp_area,
            TO_DATE(SUBSTR(rv_ods_ppo.start_date_time,0,8), 'YYYYMMDD'),
            SUBSTR(rv_ods_ppo.start_date_time,9,6),
            v_start_yyyyppdd,
            TO_DATE(SUBSTR(rv_ods_ppo.end_date_time,0,8), 'YYYYMMDD'),
            SUBSTR(rv_ods_ppo.end_date_time,9,6),
            v_end_yyyyppdd,
            rv_ods_ppo.order_status,
            rv_ods_ppo.mp_resource,
            rv_ods_ppo.achievement,
            rv_ods_ppo.quantity,
            rv_ods_ppo.uom,
            v_base_uom_qty,
            v_base_uom_code
          );

       END LOOP;

       -- Commit.
       COMMIT;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PROC_PLAN_ORDER_FACT Load');

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
            lics_logging.write_log('**ERROR** - PROC_PLAN_ORDER_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - PROC_PLAN_ORDER_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end proc_plan_order_fact_load;
   
   /******************************************************/
   /* This procedure performs the BIFG fact load routine */
   /******************************************************/
   procedure bifg_fact_load(par_company_code in varchar2, par_date in date) is

      /*-*/
      /* Local variables
      /*-*/
      v_expt_dlvry_date_yyyyppdd NUMBER(8);
      v_ship_date_yyyyppdd NUMBER(8);
      v_ship_date_yyyymmdd DATE;
      v_base_uom_code VARCHAR2(3);
      v_base_uom_qty NUMBER;
      v_numerator NUMBER;
      v_demoninator NUMBER;

      /*-*/
      /* Local cursors
      /*-*/
      CURSOR csr_purch_order_bifg_fact IS
       SELECT
         co_code,
         order_num,
         order_item,
         target,
         material,
         vendor,
         sto_location,
         opr_date,
         recreq_qty,
         rec_indicator,
         uom,
         mrp_type,
         plant,
         doc_type,
         source_plant,
         issue_sloc,
         ship_date,
         item_category
       FROM
         sap_opr_hdr
       WHERE
         co_code = par_company_code
         AND TRUNC(sap_opr_hdr_load_date, 'DD') = par_date
         AND valdtn_status = ods_constants.valdtn_valid;
       rv_purch_order_bifg_fact csr_purch_order_bifg_fact%ROWTYPE;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - BIFG_FACT Load - Date('||to_char(par_date,'yyyy/mm/dd')||')');

      /*-*/
      /* Perform the existing logic - remains unchanged
      /*-*/
      

      OPEN csr_purch_order_bifg_fact;
      FETCH csr_purch_order_bifg_fact INTO rv_purch_order_bifg_fact;
      IF csr_purch_order_bifg_fact%FOUND THEN

       -- Delete any purchase orders for BIFG items that may already exist for the company being aggregated.
       lics_logging.write_log('--> Deleting from PURCH_ORDER_BIFG_FACT.');
       DELETE FROM purch_order_bifg_fact
       WHERE company_code = par_company_code;
      END IF;
      CLOSE csr_purch_order_bifg_fact;

      -- Insert into purch_order_bifg_fact table based on company code and date.
      lics_logging.write_log('--> Inserting into the PURCH_ORDER_BIFG_FACT table.');

      FOR rv_purch_order_bifg_fact IN csr_purch_order_bifg_fact LOOP

       -- Find yyyyppdd for opr_date
       SELECT
         mars_yyyyppdd INTO v_expt_dlvry_date_yyyyppdd
       FROM
         mars_date
       WHERE
         yyyymmdd_date = rv_purch_order_bifg_fact.opr_date;

       -- Check if ship data exists
       IF rv_purch_order_bifg_fact.ship_date IS NOT NULL THEN
         -- Find yyyyppdd for ship_date
         SELECT
           mars_yyyyppdd INTO v_ship_date_yyyyppdd
         FROM
           mars_date
         WHERE
           yyyymmdd_date = rv_purch_order_bifg_fact.ship_date;

         -- Convert Ship date to Gregorian date
         v_ship_date_yyyymmdd := TO_DATE(rv_purch_order_bifg_fact.ship_date, 'YYYYMMDD');
       ELSE
         v_ship_date_yyyymmdd := NULL;
         v_ship_date_yyyyppdd := NULL;
       END IF;

       -- Find Base UOM
       SELECT
         meins
       INTO
         v_base_uom_code
         FROM
         sap_mat_hdr
         WHERE
         sap_mat_hdr.matnr = rv_purch_order_bifg_fact.material;

       -- If billed UOM is not base UOM, then find base UOM and convert quantity.
       IF v_base_uom_code = rv_purch_order_bifg_fact.uom THEN
         v_base_uom_qty := rv_purch_order_bifg_fact.recreq_qty;
       ELSE
         SELECT
           sap_mat_uom.umrez,
           sap_mat_uom.umren
         INTO
           v_numerator,
           v_demoninator
           FROM
           sap_mat_uom
           WHERE
           sap_mat_uom.matnr  = rv_purch_order_bifg_fact.material
             AND sap_mat_uom.meinh =  rv_purch_order_bifg_fact.uom;

         v_base_uom_qty := (TO_NUMBER(v_numerator)/TO_NUMBER(v_demoninator)) * rv_purch_order_bifg_fact.recreq_qty;
       END IF;

       INSERT INTO purch_order_bifg_fact
         (
         company_code,
         purch_order_doc_num,
         purch_order_doc_line_num,
         mrp_area_code,
         matl_code,
         vendor_code,
         storage_locn_code,
         expected_dlvry_date,
         expected_dlvry_date_yyyyppdd,
         purch_order_qty,
         receipt_status,
         purch_order_qty_uom_code,
         mrp_type_code,
         plant_code,
         purch_order_doc_type,
         source_plant_code,
         source_storage_locn_code,
         ship_date,
         ship_date_yyyyppdd,
         matl_category_code,
         purch_order_base_uom_code,
         purch_order_base_uom_qty
         )
       VALUES
        (
         rv_purch_order_bifg_fact.co_code,
         rv_purch_order_bifg_fact.order_num,
         rv_purch_order_bifg_fact.order_item,
         rv_purch_order_bifg_fact.target,
         LTRIM(rv_purch_order_bifg_fact.material,'0'),
         rv_purch_order_bifg_fact.vendor,
         rv_purch_order_bifg_fact.sto_location,
         TO_DATE(rv_purch_order_bifg_fact.opr_date, 'YYYYMMDD'),
         v_expt_dlvry_date_yyyyppdd,
         rv_purch_order_bifg_fact.recreq_qty,
         rv_purch_order_bifg_fact.rec_indicator,
         rv_purch_order_bifg_fact.uom,
         rv_purch_order_bifg_fact.mrp_type,
         rv_purch_order_bifg_fact.plant,
         rv_purch_order_bifg_fact.doc_type,
         rv_purch_order_bifg_fact.source_plant,
         rv_purch_order_bifg_fact.issue_sloc,
         v_ship_date_yyyymmdd,
         v_ship_date_yyyyppdd,
         rv_purch_order_bifg_fact.item_category,
         v_base_uom_code,
         v_base_uom_qty
         );

      END LOOP;

      -- Commit.
      COMMIT;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - BIFG_FACT Load');

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
            lics_logging.write_log('**ERROR** - BIFG_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - BIFG_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end bifg_fact_load;

end dw_scheduled_inventory;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_scheduled_inventory for dw_app.dw_scheduled_inventory;
grant execute on dw_scheduled_inventory to public;
