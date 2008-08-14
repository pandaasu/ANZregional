/******************/
/* Package Header */
/******************/
create or replace package dw_triggered_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_triggered_aggregation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Triggered Aggregation

    This package contain the load and aggregation procedures for sales data. The package exposes
    one procedure EXECUTE that performs the load and aggregation based on the following parameters:

    1. PAR_ACTION (*DATE, *REBUILD) (MANDATORY)

       *DATE aggregates the requested fact table(s) from the operational data store
       for a particular date. *REBUILD replaces the requested fact table(s) with the
       aggregated data from the operational data store but does NOT load the
       SALES_BASE table. The SALES_BASE table can only be load one day at a time,
       that is, PAR_ACTION = *DATE.

    2. PAR_TABLE (*ALL, 'table name') (MANDATORY)

       *ALL performs the aggregation for all fact tables. A table name performs the
       aggregation for the requested fact table only.

    3. PAR_DATE (date in string format YYYYMMDD) (OPTIONAL)

       The date for which the aggregation is to be performed. Only required for
       PAR_ACTION = *DATE

    4. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_TRIGGERED_AGGREGATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All requested fact tables will attempt to be aggregated and and errors logged.

    4. A deadly embrace with scheduled aggregation is avoided by all data warehouse components
       use the same process isolation locking string and sharing the same ICS stream code.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/08   Steve Gregan   Created
    2008/05   Steve Gregan   Modified for NZ demand planning group division
    2008/08   Steve Gregan   Added flag file processing
    2008/08   Steve Gregan   Modified demand planning group division logic

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_table in varchar2, par_date in varchar2, par_company in varchar2);

end dw_triggered_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_triggered_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure load_time_range(par_date in date,
                             par_yyyymm in number,
                             par_yyyypp in number,
                             par_company in varchar2,
                             par_range in varchar2);
   procedure sales_base_load(par_date in date, par_company in varchar2, par_currency in varchar2);
   procedure sales_month_01_aggregation(par_yyyymm in number, par_company in varchar2);
   procedure sales_period_01_aggregation(par_yyyypp in number, par_company in varchar2);

   /*-*/
   /* Private definitions
   /*-*/
   type tab_date is table of number(8,0) index by binary_integer;
   type tab_week is table of number(7,0) index by binary_integer;
   type tab_month is table of number(6,0) index by binary_integer;
   type tab_period is table of number(6,0) index by binary_integer;
   var_range_d01 tab_date;
   var_range_w01 tab_week;
   var_range_m01 tab_month;
   var_range_p01 tab_period;
   var_warning boolean;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_table in varchar2, par_date in varchar2, par_company in varchar2) is

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
      var_yyyypp number(6,0);
      var_yyyymm number(6,0);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Triggered Aggregation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = par_company;
      rcd_company csr_company%rowtype;

      cursor csr_mars_date is
         select t01.mars_period,
                (t01.year_num * 100) + t01.month_num as mars_month
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(var_date);
      rcd_mars_date csr_mars_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the procedure
      /*-*/
      var_log_prefix := 'DW - TRIGGERED_AGGREGATION';
      var_log_search := 'DW_TRIGGERED_AGGREGATION' || '_' || lics_stream_processor.callback_event;
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
      if upper(par_action) != '*DATE' and upper(par_action) != '*REBUILD' then
         raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *DATE or *REBUILD');
      end if;
      if upper(par_table) != '*ALL' and
         upper(par_table) != 'SALES_BASE' and
         upper(par_table) != 'SALES_MONTH_01_FACT' and
         upper(par_table) != 'SALES_PERIOD_01_FACT' then
         raise_application_error(-20000, 'Table parameter (' || par_table || ') must be *ALL or ' ||
                                         'SALES_BASE, ' ||
                                         'SALES_MONTH_01_FACT, ' ||
                                         'SALES_PERIOD_01_FACT');
      end if;
      if upper(par_action) = '*DATE' and (upper(par_table) != '*ALL' and upper(par_table) != 'SALES_BASE') then
         raise_application_error(-20000, 'Table parameter must be *ALL or SALES_BASE for action *DATE');
      end if;
      if upper(par_action) = '*DATE' then
         if par_date is null then
            raise_application_error(-20000, 'Date parameter must be supplied for action *DATE');
         else
            begin
               var_date := to_date(par_date,'yyyymmdd');
            exception
               when others then
                  raise_application_error(-20000, 'Date parameter (' || par_date || ') - unable to convert to date format YYYYMMDD');
            end;
         end if;
      end if;
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

      /*-*/
      /* Set the time dimension array values for *REBUILD
      /* Get the current period and month for *DATE
      /*-*/
      var_warning := false;
      if upper(par_action) = '*REBUILD' then
         var_range_d01.delete;
         var_range_w01.delete;
         var_range_m01.delete;
         var_range_p01.delete;
         var_range_d01(1) := 99999999;
         var_range_w01(1) := 9999999;
         var_range_m01(1) := 999999;
         var_range_p01(1) := 999999;
      else
         open csr_mars_date;
         fetch csr_mars_date into rcd_mars_date;
         if csr_mars_date%notfound then
            raise_application_error(-20000, 'Date ' || to_char(var_date,'yyyy/mm/dd') || ' not found in MARS_DATE');
         end if;
         close csr_mars_date;
         var_yyyypp := rcd_mars_date.mars_period;
         var_yyyymm := rcd_mars_date.mars_month;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Triggered Aggregation - Parameters(' || upper(par_action) || ' + ' || upper(par_table) || ' + ' || nvl(par_date,'NULL') || ' + ' || par_company || ')');

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
      /*-*/
      if var_locked = true then

         /*-*/
         /* Execute the load and aggregation procedures as required
         /* **note** 1. Dependancy as follows
         /*
         /*             sales_base
         /*                ==> sales_month_01_fact
         /*                ==> sales_period_01_fact
         /*
         /*          2. Processed as follows
         /*
         /*             sales_base
         /*                ==> sales_month_01_fact
         /*                ==> sales_period_01_fact
         /*
         /*          3. Sales base must always and only be loaded when
         /*                PAR_ACTION = *DATE
         /*
         /*-*/

         /*-*/
         /* SALES_BASE aggregation - based on invoice creation date
         /*
         /* 1. Extract distinct time dimensions from old SALES_BASE rows for the creation date
         /* 2. Replace existing SALES_BASE rows for the creation date
         /* 3. Extract distinct time dimensions from new SALES_BASE rows for the creation date
         /*-*/
         if upper(par_action) = '*DATE' then
            begin
               load_time_range(var_date, var_yyyymm, var_yyyypp, var_company_code, 'OLD');
               sales_base_load(var_date, var_company_code, var_company_currcy);
               load_time_range(var_date, var_yyyymm, var_yyyypp, var_company_code, 'NEW');
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Perform SALES_BASE dependant aggregations when no errors 
         /*-*/
         if var_errors = false then

            /*-*/
            /* SALES_MONTH_01_FACT aggregation - based on billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_MONTH_01_FACT' then
               for idx in 1..var_range_m01.count loop
                  begin
                     sales_month_01_aggregation(var_range_m01(idx), var_company_code);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_PERIOD_01_FACT aggregation - based on billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_PERIOD_01_FACT' then
               for idx in 1..var_range_p01.count loop
                  begin
                     sales_period_01_aggregation(var_range_p01(idx), var_company_code);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

         end if;

         /*-*/
         /* Update the flag file status to UNFLAGGED and wake the flag file daemon when required
         /*-*/
         if var_errors = false then
            if upper(par_action) = '*DATE' then
               lics_logging.write_log('Begin - Flag file creation');
               update sap_inv_sum_hdr
                  set flag_file_status = 'UNFLAGGED'
                where bukrs = par_company
                  and fkdat = par_date
                  and flag_file_status = 'LOADED';
               commit;
               lics_pipe.spray(lics_constant.type_daemon,'FF',lics_constant.pipe_wake);
               lics_logging.write_log('End - Flag file creation');
            end if;
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
      lics_logging.write_log('End - Triggered Aggregation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Warning
      /*-*/
      if var_warning = true then

         /*-*/
         /* Email
         /*-*/
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(dw_parameter.system_code,
                                         dw_parameter.system_unit,
                                         dw_parameter.system_environment,
                                         con_function,
                                         'DW_TRIGGERED_AGGREGATION',
                                         var_email,
                                         'Date warnings occurred during the Triggered Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      end if;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         ods_app.utils.send_tivoli_alert('CRITICAL','Fatal Error occurred during Triggered Aggregation Reconciliation.',1,var_company_code);
         --if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
         --   lics_notification.send_alert(var_alert);
         --end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(dw_parameter.system_code,
                                         dw_parameter.system_unit,
                                         dw_parameter.system_environment,
                                         con_function,
                                         'DW_TRIGGERED_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Triggered Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - DW_TRIGGERED_AGGREGATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*****************************************************************/
   /* This procedure performs the time dimension range load routine */
   /*****************************************************************/
   procedure load_time_range(par_date in date,
                             par_yyyymm in number,
                             par_yyyypp in number,
                             par_company in varchar2,
                             par_range in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number(9,0);
      var_found boolean;
      var_string varchar2(4000);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_range_d01 is
         select distinct t01.billing_eff_yyyyppdd as billing_eff_yyyyppdd
           from dw_sales_base t01
          where t01.company_code = par_company
            and t01.creatn_date = trunc(par_date);
      rcd_range_d01 csr_range_d01%rowtype;

      cursor csr_range_w01 is
         select distinct t01.billing_eff_yyyyppw as billing_eff_yyyyppw
           from dw_sales_base t01
          where t01.company_code = par_company
            and t01.creatn_date = trunc(par_date);
      rcd_range_w01 csr_range_w01%rowtype;

      cursor csr_range_m01 is
         select distinct t01.billing_eff_yyyymm as billing_eff_yyyymm
           from dw_sales_base t01
          where t01.company_code = par_company
            and t01.creatn_date = trunc(par_date);
      rcd_range_m01 csr_range_m01%rowtype;

      cursor csr_range_p01 is
         select distinct t01.billing_eff_yyyypp as billing_eff_yyyypp
           from dw_sales_base t01
          where t01.company_code = par_company
            and t01.creatn_date = trunc(par_date);
      rcd_range_p01 csr_range_p01%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - TIME_RANGE (' || par_range || ') Load - Parameters(' || to_char(par_date,'yyyy/mm/dd') || ' + ' || par_company || ')');

      /*-*/
      /* Clear the time dimension ranges when required
      /*-*/
      if upper(par_range) = 'OLD' then
         var_range_d01.delete;
         var_range_w01.delete;
         var_range_m01.delete;
         var_range_p01.delete;
      end if;

      /*-*/
      /* Retrieve the billing effective date time dimensions
      /*-*/
      open csr_range_d01;
      loop
         fetch csr_range_d01 into rcd_range_d01;
         if csr_range_d01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_d01.count loop
            if var_range_d01(idx) = rcd_range_d01.billing_eff_yyyyppdd then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_d01.count + 1;
            var_range_d01(var_index) := rcd_range_d01.billing_eff_yyyyppdd;
         end if;
      end loop;
      close csr_range_d01;

      /*-*/
      /* Retrieve the billing effective week time dimensions
      /*-*/
      open csr_range_w01;
      loop
         fetch csr_range_w01 into rcd_range_w01;
         if csr_range_w01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_w01.count loop
            if var_range_w01(idx) = rcd_range_w01.billing_eff_yyyyppw then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_w01.count + 1;
            var_range_w01(var_index) := rcd_range_w01.billing_eff_yyyyppw;
         end if;
      end loop;
      close csr_range_w01;

      /*-*/
      /* Retrieve the billing effective month time dimensions
      /*-*/
      open csr_range_m01;
      loop
         fetch csr_range_m01 into rcd_range_m01;
         if csr_range_m01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_m01.count loop
            if var_range_m01(idx) = rcd_range_m01.billing_eff_yyyymm then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_m01.count + 1;
            var_range_m01(var_index) := rcd_range_m01.billing_eff_yyyymm;
         end if;
      end loop;
      close csr_range_m01;

      /*-*/
      /* Retrieve the billing effective period time dimensions
      /*-*/
      open csr_range_p01;
      loop
         fetch csr_range_p01 into rcd_range_p01;
         if csr_range_p01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_p01.count loop
            if var_range_p01(idx) = rcd_range_p01.billing_eff_yyyypp then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_p01.count + 1;
            var_range_p01(var_index) := rcd_range_p01.billing_eff_yyyypp;
         end if;
      end loop;
      close csr_range_p01;

      /*-*/
      /* Check the time dimension ranges when required
      /*-*/
      if upper(par_range) = 'NEW' then

         var_string := null;
         for idx in 1..var_range_m01.count loop
            if var_range_m01(idx) < par_yyyymm then
               if var_string is null then
                  var_string := '**WARNING** - Prior billing effective date months exist for invoice data - ' || var_range_m01(idx);
               else
                  var_string := var_string || ',' || var_range_m01(idx);
               end if;
            end if;
         end loop;
         if not(var_string is null) then
            lics_logging.write_log(var_string);
            var_warning := true;
         end if;

         var_string := null;
         for idx in 1..var_range_p01.count loop
            if var_range_p01(idx) < par_yyyypp then
               if var_string is null then
                  var_string := '**WARNING** - Prior billing effective date periods exist for invoice data - ' || var_range_p01(idx);
               else
                  var_string := var_string || ',' || var_range_p01(idx);
               end if;
            end if;
         end loop;
         if not(var_string is null) then
            lics_logging.write_log(var_string);
            var_warning := true;
         end if;

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - TIME_RANGE (' || par_range || ') Load');

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
            lics_logging.write_log('**ERROR** - TIME_RANGE (' || par_range || ') Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - TIME_RANGE (' || par_range || ') Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end load_time_range;

   /*******************************************************/
   /* This procedure performs the sales base load routine */
   /*******************************************************/
   procedure sales_base_load(par_date in date, par_company in varchar2, par_currency in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      rcd_sales_base dw_sales_base%rowtype;
      var_order_usage_gsv_flag order_usage.order_usage_gsv_flag%type;
      var_invoice_type_factor number;
      var_gsv_value number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_trace is
         select t01.*,
                t02.atwrt as mat_bus_sgmnt_code
           from (select t01.*
                   from (select t01.*,
                                rank() over (partition by t01.billing_doc_num
                                                 order by t01.trace_seqn desc) as rnkseq
                           from sap_inv_trace t01
                          where t01.company_code = par_company
                            and t01.creatn_date = trunc(par_date)) t01
                  where t01.rnkseq = 1) t01,
                sap_cla_chr t02
          where t01.matl_code = t02.objek(+)
            and 'MARA' = t02.obtab(+)
            and '001' = t02.klart(+)
            and 'CLFFERT01' = t02.atnam(+)
            and t01.trace_status = '*ACTIVE';
      rcd_trace csr_trace%rowtype;

      cursor csr_invc_type is
         select decode(t01.invc_type_sign,'-',-1,1) as invoice_type_factor
           from invc_type t01
          where t01.invc_type_code = rcd_sales_base.invc_type_code;
      rcd_invc_type csr_invc_type%rowtype;

      cursor csr_order_usage is
         select t01.order_usage_gsv_flag as order_usage_gsv_flag
           from order_usage t01
          where t01.order_usage_code = rcd_sales_base.order_usage_code;
      rcd_order_usage csr_order_usage%rowtype;

      cursor csr_icb_flag is
         select 'Y' as icb_flag
           from table(lics_datastore.retrieve_value('CDW','ICB_FLAG',rcd_sales_base.company_code)) t01
          where t01.dsv_value = rcd_sales_base.ship_to_cust_code;
      rcd_icb_flag csr_icb_flag%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_BASE Load - Parameters(' || to_char(par_date,'yyyy/mm/dd') || ' + ' || par_company || ')');

      /*-*/
      /* STEP #1
      /*
      /* Update the DLVRY_BASE rows to *OPEN when related to an existing
      /* sales line for the requested creation date. Ensures that the DLVRY_BASE
      /* row invoice values are updated for reruns (invoice could be removed)
      /*-*/
      lics_logging.write_log('--> Reopening related delivery base data before sales base load');
      update dw_dlvry_base
         set dlvry_line_status = '*OPEN'
       where company_code = par_company
         and (dlvry_doc_num, dlvry_doc_line_num) in (select dlvry_doc_num, dlvry_doc_line_num
                                                       from dw_sales_base
                                                      where company_code = par_company
                                                        and creatn_date = trunc(par_date));

      /*-*/
      /* STEP #2
      /*
      /* Update the ORDER_BASE rows to *OPEN when related to an existing
      /* sales line for the requested creation date. Ensures that the ORDER_BASE
      /* row delivery values are updated for reruns (invoice could be removed)
      /*-*/
      lics_logging.write_log('--> Reopening related order base data before sales base load');
      update dw_order_base
         set order_line_status = '*OPEN'
       where company_code = par_company
         and (order_doc_num, order_doc_line_num) in (select order_doc_num, order_doc_line_num
                                                       from dw_sales_base
                                                      where company_code = par_company
                                                        and creatn_date = trunc(par_date)
                                                        and order_doc_num is not null);

      /*-*/
      /* STEP #3
      /*
      /* Update the PURCH_BASE rows to *OPEN when related to an existing
      /* sales line for the requested creation date. Ensures that the PURCH_BASE
      /* row delivery values are updated for reruns (invoice could be removed)
      /*-*/
      lics_logging.write_log('--> Reopening related purchase base data before sales base load');
      update dw_purch_base
         set purch_order_line_status = '*OPEN'
       where company_code = par_company
         and (purch_order_doc_num, purch_order_doc_line_num) in (select purch_order_doc_num, purch_order_doc_line_num
                                                                   from dw_sales_base
                                                                  where company_code = par_company
                                                                    and creatn_date = trunc(par_date)
                                                                    and purch_order_doc_num is not null);

      /*-*/
      /* STEP #4
      /*
      /* Delete any existing sales base rows 
      /* **notes** 1. Delete all sales base rows for the company and creation date.
      /*-*/
      lics_logging.write_log('--> Deleting existing sales base data');
      delete from dw_sales_base
       where company_code = par_company
         and creatn_date = trunc(par_date);

      /*-*/
      /* STEP #5
      /*
      /* Load the sales base fact rows from the ODS trace data
      /* **notes** 1. Select all sales base rows for the company and creation date.
      /*           2. Only valid invoices are selected (TRACE_STATUS = *ACTIVE)
      /*-*/
      lics_logging.write_log('--> Loading new sales base data');
      open csr_trace;
      loop
         fetch csr_trace into rcd_trace;
         if csr_trace%notfound then
            exit;
         end if;

         /*---------------------------*/
         /* SALES_BASE Initialisation */
         /*---------------------------*/

         /*-*/
         /* Initialise the sales base row
         /*-*/
         rcd_sales_base.billing_doc_num := rcd_trace.billing_doc_num;
         rcd_sales_base.billing_doc_line_num := rcd_trace.billing_doc_line_num;
         rcd_sales_base.billing_trace_seqn := rcd_trace.trace_seqn;
         rcd_sales_base.creatn_date := trunc(rcd_trace.creatn_date);
         rcd_sales_base.creatn_yyyyppdd := rcd_trace.creatn_yyyyppdd;
         rcd_sales_base.creatn_yyyyppw := rcd_trace.creatn_yyyyppw;
         rcd_sales_base.creatn_yyyypp := rcd_trace.creatn_yyyypp;
         rcd_sales_base.creatn_yyyymm := rcd_trace.creatn_yyyymm;
         rcd_sales_base.billing_eff_date := trunc(rcd_trace.billing_eff_date);
         rcd_sales_base.billing_eff_yyyyppdd := rcd_trace.billing_eff_yyyyppdd;
         rcd_sales_base.billing_eff_yyyyppw := rcd_trace.billing_eff_yyyyppw;
         rcd_sales_base.billing_eff_yyyypp := rcd_trace.billing_eff_yyyypp;
         rcd_sales_base.billing_eff_yyyymm := rcd_trace.billing_eff_yyyymm;
         rcd_sales_base.order_doc_num := rcd_trace.order_doc_num;
         rcd_sales_base.order_doc_line_num := rcd_trace.order_doc_line_num;
         rcd_sales_base.purch_order_doc_num := rcd_trace.purch_order_doc_num;
         rcd_sales_base.purch_order_doc_line_num := rcd_trace.purch_order_doc_line_num;
         rcd_sales_base.dlvry_doc_num := rcd_trace.dlvry_doc_num;
         rcd_sales_base.dlvry_doc_line_num := rcd_trace.dlvry_doc_line_num;
         rcd_sales_base.company_code := rcd_trace.company_code;
         rcd_sales_base.hdr_sales_org_code := rcd_trace.hdr_sales_org_code;
         rcd_sales_base.hdr_distbn_chnl_code := rcd_trace.hdr_distbn_chnl_code;
         rcd_sales_base.hdr_division_code := rcd_trace.hdr_division_code;
         rcd_sales_base.gen_sales_org_code := rcd_trace.gen_sales_org_code;
         rcd_sales_base.gen_distbn_chnl_code := rcd_trace.gen_distbn_chnl_code;
         rcd_sales_base.gen_division_code := rcd_trace.gen_division_code;
         rcd_sales_base.doc_currcy_code := rcd_trace.doc_currcy_code;
         rcd_sales_base.company_currcy_code := par_currency;
         rcd_sales_base.exch_rate := rcd_trace.exch_rate;
         rcd_sales_base.invc_type_code := rcd_trace.invc_type_code;
         rcd_sales_base.order_type_code := rcd_trace.order_type_code;
         rcd_sales_base.order_reasn_code := rcd_trace.order_reasn_code;
         rcd_sales_base.order_usage_code := rcd_trace.order_usage_code;
         rcd_sales_base.sold_to_cust_code := nvl(rcd_trace.gen_sold_to_cust_code, rcd_trace.hdr_sold_to_cust_code);
         rcd_sales_base.bill_to_cust_code := nvl(rcd_trace.gen_bill_to_cust_code, rcd_trace.hdr_bill_to_cust_code);
         rcd_sales_base.payer_cust_code := nvl(rcd_trace.gen_payer_cust_code, rcd_trace.hdr_payer_cust_code);
         rcd_sales_base.ship_to_cust_code := nvl(rcd_trace.gen_ship_to_cust_code, rcd_trace.hdr_ship_to_cust_code);
         rcd_sales_base.matl_code := dw_trim_code(rcd_trace.matl_code);
         rcd_sales_base.ods_matl_code := rcd_trace.matl_code;
         rcd_sales_base.matl_entd := dw_trim_code(rcd_trace.matl_entd);
         rcd_sales_base.plant_code := rcd_trace.plant_code;
         rcd_sales_base.storage_locn_code := rcd_trace.storage_locn_code;
         rcd_sales_base.order_qty := 0;
         rcd_sales_base.billed_weight_unit := rcd_trace.billed_weight_unit;
         rcd_sales_base.billed_gross_weight := rcd_trace.billed_gross_weight;
         rcd_sales_base.billed_net_weight := rcd_trace.billed_net_weight;
         rcd_sales_base.billed_uom_code := rcd_trace.billed_uom_code;
         rcd_sales_base.billed_base_uom_code := null;
         rcd_sales_base.billed_qty := 0;
         rcd_sales_base.billed_qty_base_uom := 0;
         rcd_sales_base.billed_qty_gross_tonnes := 0;
         rcd_sales_base.billed_qty_net_tonnes := 0;
         rcd_sales_base.billed_gsv := 0;
         rcd_sales_base.billed_gsv_xactn := 0;
         rcd_sales_base.billed_gsv_aud := 0;
         rcd_sales_base.billed_gsv_usd := 0;
         rcd_sales_base.billed_gsv_eur := 0;
         rcd_sales_base.mfanz_icb_flag := 'N';
         rcd_sales_base.demand_plng_grp_division_code := rcd_trace.hdr_division_code;
         if (rcd_sales_base.hdr_sales_org_code = '149' and
             rcd_sales_base.hdr_distbn_chnl_code = '10') then
            if rcd_trace.mat_bus_sgmnt_code = '01' then
               rcd_sales_base.demand_plng_grp_division_code := '55';
            elsif rcd_trace.mat_bus_sgmnt_code = '02' then
               rcd_sales_base.demand_plng_grp_division_code := '57';
            elsif rcd_trace.mat_bus_sgmnt_code = '05' then
               rcd_sales_base.demand_plng_grp_division_code := '56';
            end if;
         else
            if rcd_sales_base.demand_plng_grp_division_code = '57' then
               if rcd_trace.mat_bus_sgmnt_code = '02' then
                  rcd_sales_base.demand_plng_grp_division_code := '57';
               elsif rcd_trace.mat_bus_sgmnt_code = '05' then
                  rcd_sales_base.demand_plng_grp_division_code := '56';
               end if;
            end if;
         end if;

         /*-*/
         /* Retrieve the invoice type factor
         /*
         /* **note**
         /* 1. The invoice type factor defaults to 1 for unrecognised invoice type codes
         /*    and will therefore be loaded into the sales base table as a positive
         /*-*/
         var_invoice_type_factor := 1;
         open csr_invc_type;
         fetch csr_invc_type into rcd_invc_type;
         if csr_invc_type%found then
            var_invoice_type_factor := rcd_invc_type.invoice_type_factor;
         end if;
         close csr_invc_type;

         /*-*/
         /* Retrieve the order usage gsv flag
         /*
         /* **note**
         /* 1. The order usage GSV flag defaults to 'GSV' for unrecognised order usage codes
         /*    and will therefore always be loaded into the sales base table
         /*-*/
         var_order_usage_gsv_flag := 'GSV';
         open csr_order_usage;
         fetch csr_order_usage into rcd_order_usage;
         if csr_order_usage%found then
            var_order_usage_gsv_flag := rcd_order_usage.order_usage_gsv_flag;
         end if;
         close csr_order_usage;

         /*-*/
         /* Retrieve the ICB flag
         /*
         /* **note**
         /* 1. The ICB flag is set to 'Y' only when the ship to customer
         /*    exists in the data store with 'CDW' - 'ICB_FLAG' - company code
         /*-*/
         rcd_sales_base.mfanz_icb_flag := 'N';
         open csr_icb_flag;
         fetch csr_icb_flag into rcd_icb_flag;
         if csr_icb_flag%found then
            rcd_sales_base.mfanz_icb_flag := 'Y';
         end if;
         close csr_icb_flag;

         /*-*/
         /* Only load the sales base row when order usage 'GSV'
         /*-*/
         if var_order_usage_gsv_flag = 'GSV' and not(rcd_sales_base.billed_uom_code is null) then

            /*-------------------------*/
            /* SALES_BASE Calculations */
            /*-------------------------*/

            /*-*/
            /* Calculate the sales quantity values from the material GRD data
            /* **notes** 1. Recalculation from the material GRD data allows the base tables to be rebuilt from the ODS when GRD data errors are corrected.
            /*           2. Ensures consistency when reducing outstanding quantity and weight from delivery and invoice.
            /*           3. Is the only way to reduce the order quantity with the delivery quantity (different material or UOM).
            /*-*/
            rcd_sales_base.billed_qty := var_invoice_type_factor * rcd_trace.billed_qty;
            dw_utility.pkg_qty_fact.ods_matl_code := rcd_sales_base.ods_matl_code;
            dw_utility.pkg_qty_fact.uom_code := rcd_sales_base.billed_uom_code;
            dw_utility.pkg_qty_fact.uom_qty := rcd_sales_base.billed_qty;
            dw_utility.calculate_quantity;
            rcd_sales_base.billed_base_uom_code := dw_utility.pkg_qty_fact.base_uom_code;
            rcd_sales_base.billed_qty_base_uom := dw_utility.pkg_qty_fact.qty_base_uom;
            rcd_sales_base.billed_qty_gross_tonnes := dw_utility.pkg_qty_fact.qty_gross_tonnes;
            rcd_sales_base.billed_qty_net_tonnes := dw_utility.pkg_qty_fact.qty_net_tonnes;

            /*-*/
            /* Calculate the sales GSV values
            /*-*/
            rcd_sales_base.billed_gsv_xactn := round(var_invoice_type_factor * nvl(rcd_trace.billed_gsv,0), 2);
            var_gsv_value := (var_invoice_type_factor / ods_app.exch_rate_factor('ICB',
                                                                                 rcd_sales_base.doc_currcy_code,
                                                                                 rcd_sales_base.company_currcy_code,
                                                                                 rcd_sales_base.creatn_date))
                             * (nvl(rcd_trace.billed_gsv,0) * rcd_sales_base.exch_rate);
            rcd_sales_base.billed_gsv := round(var_gsv_value, 2);
            rcd_sales_base.billed_gsv_aud := round(
                                                ods_app.currcy_conv(
                                                   var_gsv_value,
                                                   rcd_sales_base.company_currcy_code,
                                                   'AUD',
                                                   rcd_sales_base.creatn_date,
                                                   'MPPR'), 2);
            rcd_sales_base.billed_gsv_usd := round(
                                                ods_app.currcy_conv(
                                                   var_gsv_value,
                                                   rcd_sales_base.company_currcy_code,
                                                   'USD',
                                                   rcd_sales_base.creatn_date,
                                                   'MPPR'), 2);
            rcd_sales_base.billed_gsv_eur := round(
                                                ods_app.currcy_conv(
                                                   var_gsv_value,
                                                   rcd_sales_base.company_currcy_code,
                                                   'EUR',
                                                   rcd_sales_base.creatn_date,
                                                   'MPPR'), 2);

            /*---------------------*/
            /* SALES_BASE Creation */
            /*---------------------*/

            /*-*/
            /* Insert the sales fact row
            /*-*/
            insert into dw_sales_base values rcd_sales_base;

         end if;

      end loop;
      close csr_trace;

      /*-*/
      /* STEP #6
      /*
      /* Update the sales base row delivery pointers for returns
      /*-*/
      lics_logging.write_log('--> Updating sales base data delivery pointers for returns');
      dw_alignment.sales_base_return(par_company);

      /*-*/
      /* STEP #7
      /*
      /* Update the DLVRY_BASE rows to *OPEN when related to a new
      /* sales line for the requested creation date. Ensures that the DLVRY_BASE
      /* row invoice values are updated for current execution (document pointers changed)
      /*-*/
      lics_logging.write_log('--> Reopening related delivery base data after sales base load');
      update dw_dlvry_base
         set dlvry_line_status = '*OPEN'
       where company_code = par_company
         and (dlvry_doc_num, dlvry_doc_line_num) in (select dlvry_doc_num, dlvry_doc_line_num
                                                       from dw_sales_base
                                                      where company_code = par_company
                                                        and creatn_date = trunc(par_date));

      /*-*/
      /* STEP #8
      /*
      /* Update the ORDER_BASE rows to *OPEN when related to a new
      /* sales line for the requested creation date. Ensures that the ORDER_BASE
      /* row delivery values are updated for current execution (document pointers changed)
      /*-*/
      lics_logging.write_log('--> Reopening related order base data after sales base load');
      update dw_order_base
         set order_line_status = '*OPEN'
       where company_code = par_company
         and (order_doc_num, order_doc_line_num) in (select order_doc_num, order_doc_line_num
                                                       from dw_sales_base
                                                      where company_code = par_company
                                                        and creatn_date = trunc(par_date)
                                                        and order_doc_num is not null);

      /*-*/
      /* STEP #9
      /*
      /* Update the PURCH_BASE rows to *OPEN when related to a new
      /* sales line for the requested creation date. Ensures that the PURCH_BASE
      /* row delivery values are updated for current execution (document pointers changed)
      /*-*/
      lics_logging.write_log('--> Reopening related purchase base data after sales base load');
      update dw_purch_base
         set purch_order_line_status = '*OPEN'
       where company_code = par_company
         and (purch_order_doc_num, purch_order_doc_line_num) in (select purch_order_doc_num, purch_order_doc_line_num
                                                                   from dw_sales_base
                                                                  where company_code = par_company
                                                                    and creatn_date = trunc(par_date)
                                                                    and purch_order_doc_num is not null);

      /*-*/
      /* STEP #10
      /*
      /* Update the open delivery base row data
      /*-*/
      lics_logging.write_log('--> Updating open delivery base data');
      dw_alignment.dlvry_base_status(par_company);

      /*-*/
      /* STEP #11
      /*
      /* Update the open order base row data
      /*-*/
      lics_logging.write_log('--> Updating open order base data');
      dw_alignment.order_base_status(par_company);

      /*-*/
      /* STEP #12
      /*
      /* Update the open purchase base row data
      /*-*/
      lics_logging.write_log('--> Updating open purchase base data');
      dw_alignment.purch_base_status(par_company);

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_BASE Load');

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
            lics_logging.write_log('**ERROR** - SALES_BASE Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_BASE Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_base_load;

   /******************************************************************/
   /* This procedure performs the sales month 01 aggregation routine */
   /******************************************************************/
   procedure sales_month_01_aggregation(par_yyyymm in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t01.billing_eff_yyyymm as billing_eff_yyyymm
           from dw_sales_base t01
          where t01.company_code = par_company
            and (t01.billing_eff_yyyymm = par_yyyymm or
                 par_yyyymm = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_MONTH01 Aggregation - Parameters(' || to_char(par_yyyymm) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyymm = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('--> Truncating the partition(s)');
      dds_partition.truncate('dw_sales_month01',par_yyyymm,par_company,'m');

      /*-*/
      /* Perform the aggregation by partition
      /* **notes**
      /* 1. Partitions are aggregated based on source data
      /* 2. par_yyyymm = 999999 aggregates all partitions
      /*-*/
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            exit;
         end if;

         /*-*/
         /* Check that a partition exists for the current month
         /*-*/
         lics_logging.write_log('--> Check/create partition - Month(' || to_char(rcd_source.billing_eff_yyyymm) || ')');
         dds_partition.check_create('dw_sales_month01',rcd_source.billing_eff_yyyymm,par_company,'m');

         /*-*/
         /* Build the partition for the current month 
         /*-*/
         lics_logging.write_log('--> Building the partition - Month(' || to_char(rcd_source.billing_eff_yyyymm) || ')');
         insert into dw_sales_month01
            (company_code,
             order_type_code,
             invc_type_code,
             billing_eff_yyyymm,
             hdr_sales_org_code,
             hdr_distbn_chnl_code,
             hdr_division_code,
             doc_currcy_code,
             company_currcy_code,
             exch_rate,
             order_reasn_code,
             sold_to_cust_code,
             bill_to_cust_code,
             payer_cust_code,
             order_qty,
             billed_qty,
             billed_qty_base_uom,
             billed_qty_gross_tonnes,
             billed_qty_net_tonnes,
             ship_to_cust_code,
             matl_code,
             matl_entd,
             billed_uom_code,
             billed_base_uom_code,
             plant_code,
             storage_locn_code,
             gen_sales_org_code,
             gen_distbn_chnl_code,
             gen_division_code,
             order_usage_code,
             billed_gsv,
             billed_gsv_xactn,
             billed_gsv_aud,
             billed_gsv_usd,
             billed_gsv_eur,
             mfanz_icb_flag,
             demand_plng_grp_division_code)
            select t01.company_code,
                   t01.order_type_code,
                   t01.invc_type_code,
                   t01.billing_eff_yyyymm,
                   t01.hdr_sales_org_code,
                   t01.hdr_distbn_chnl_code,
                   t01.hdr_division_code,
                   t01.doc_currcy_code,
                   t01.company_currcy_code,
                   t01.exch_rate,
                   t01.order_reasn_code,
                   t01.sold_to_cust_code,
                   t01.bill_to_cust_code,
                   t01.payer_cust_code,
                   sum(t01.order_qty),
                   sum(t01.billed_qty),
                   sum(t01.billed_qty_base_uom),
                   sum(t01.billed_qty_gross_tonnes),
                   sum(t01.billed_qty_net_tonnes),
                   t01.ship_to_cust_code,
                   t01.matl_code,
                   t01.matl_entd,
                   t01.billed_uom_code,
                   t01.billed_base_uom_code,
                   t01.plant_code,
                   t01.storage_locn_code,
                   t01.gen_sales_org_code,
                   t01.gen_distbn_chnl_code,
                   t01.gen_division_code,
                   t01.order_usage_code,
                   sum(t01.billed_gsv),
                   sum(t01.billed_gsv_xactn),
                   sum(t01.billed_gsv_aud),
                   sum(t01.billed_gsv_usd),
                   sum(t01.billed_gsv_eur),
                   max(t01.mfanz_icb_flag),
                   t01.demand_plng_grp_division_code
              from dw_sales_base t01
             where t01.billing_eff_yyyymm = rcd_source.billing_eff_yyyymm
               and t01.company_code = par_company
             group by t01.company_code,
                      t01.order_type_code,
                      t01.invc_type_code,
                      t01.billing_eff_yyyymm,
                      t01.hdr_sales_org_code,
                      t01.hdr_distbn_chnl_code,
                      t01.hdr_division_code,
                      t01.doc_currcy_code,
                      t01.company_currcy_code,
                      t01.exch_rate,
                      t01.order_reasn_code,
                      t01.sold_to_cust_code,
                      t01.bill_to_cust_code,
                      t01.payer_cust_code,
                      t01.ship_to_cust_code,
                      t01.matl_code,
                      t01.matl_entd,
                      t01.billed_uom_code,
                      t01.billed_base_uom_code,
                      t01.plant_code,
                      t01.storage_locn_code,
                      t01.gen_sales_org_code,
                      t01.gen_distbn_chnl_code,
                      t01.gen_division_code,
                      t01.order_usage_code,
                      t01.demand_plng_grp_division_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_MONTH01 Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_MONTH01 Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_MONTH01 Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_month_01_aggregation;

   /*******************************************************************/
   /* This procedure performs the sales period 01 aggregation routine */
   /*******************************************************************/
   procedure sales_period_01_aggregation(par_yyyypp in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t01.billing_eff_yyyypp as billing_eff_yyyypp
           from dw_sales_base t01
          where t01.company_code = par_company
            and (t01.billing_eff_yyyypp = par_yyyypp or
                 par_yyyypp = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_PERIOD01 Aggregation - Parameters(' || to_char(par_yyyypp) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyypp = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('--> Truncating the partition(s)');
      dds_partition.truncate('dw_sales_period01',par_yyyypp,par_company,'p');

      /*-*/
      /* Perform the aggregation by partition
      /* **notes**
      /* 1. Partitions are aggregated based on source data
      /* 2. par_yyyypp = 999999 aggregates all partitions
      /*-*/
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            exit;
         end if;

         /*-*/
         /* Check that a partition exists for the current period
         /*-*/
         lics_logging.write_log('--> Check/create partition - Period(' || to_char(rcd_source.billing_eff_yyyypp) || ')');
         dds_partition.check_create('dw_sales_period01',rcd_source.billing_eff_yyyypp,par_company,'p');

         /*-*/
         /* Build the partition for the current period
         /*-*/
         lics_logging.write_log('--> Building the partition - Period(' || to_char(rcd_source.billing_eff_yyyypp) || ')');
         insert into dw_sales_period01
            (company_code,
             order_type_code,
             invc_type_code,
             billing_eff_yyyypp,
             hdr_sales_org_code,
             hdr_distbn_chnl_code,
             hdr_division_code,
             doc_currcy_code,
             company_currcy_code,
             exch_rate,
             order_reasn_code,
             sold_to_cust_code,
             bill_to_cust_code,
             payer_cust_code,
             order_qty,
             billed_qty,
             billed_qty_base_uom,
             billed_qty_gross_tonnes,
             billed_qty_net_tonnes,
             ship_to_cust_code,
             matl_code,
             matl_entd,
             billed_uom_code,
             billed_base_uom_code,
             plant_code,
             storage_locn_code,
             gen_sales_org_code,
             gen_distbn_chnl_code,
             gen_division_code,
             order_usage_code,
             billed_gsv,
             billed_gsv_xactn,
             billed_gsv_aud,
             billed_gsv_usd,
             billed_gsv_eur,
             mfanz_icb_flag,
             demand_plng_grp_division_code)
            select t01.company_code,
                   t01.order_type_code,
                   t01.invc_type_code,
                   t01.billing_eff_yyyypp,
                   t01.hdr_sales_org_code,
                   t01.hdr_distbn_chnl_code,
                   t01.hdr_division_code,
                   t01.doc_currcy_code,
                   t01.company_currcy_code,
                   t01.exch_rate,
                   t01.order_reasn_code,
                   t01.sold_to_cust_code,
                   t01.bill_to_cust_code,
                   t01.payer_cust_code,
                   sum(t01.order_qty),
                   sum(t01.billed_qty),
                   sum(t01.billed_qty_base_uom),
                   sum(t01.billed_qty_gross_tonnes),
                   sum(t01.billed_qty_net_tonnes),
                   t01.ship_to_cust_code,
                   t01.matl_code,
                   t01.matl_entd,
                   t01.billed_uom_code,
                   t01.billed_base_uom_code,
                   t01.plant_code,
                   t01.storage_locn_code,
                   t01.gen_sales_org_code,
                   t01.gen_distbn_chnl_code,
                   t01.gen_division_code,
                   t01.order_usage_code,
                   sum(t01.billed_gsv),
                   sum(t01.billed_gsv_xactn),
                   sum(t01.billed_gsv_aud),
                   sum(t01.billed_gsv_usd),
                   sum(t01.billed_gsv_eur),
                   max(t01.mfanz_icb_flag),
                   t01.demand_plng_grp_division_code
              from dw_sales_base t01
             where t01.billing_eff_yyyypp = rcd_source.billing_eff_yyyypp
               and t01.company_code = par_company
             group by t01.company_code,
                      t01.order_type_code,
                      t01.invc_type_code,
                      t01.billing_eff_yyyypp,
                      t01.hdr_sales_org_code,
                      t01.hdr_distbn_chnl_code,
                      t01.hdr_division_code,
                      t01.doc_currcy_code,
                      t01.company_currcy_code,
                      t01.exch_rate,
                      t01.order_reasn_code,
                      t01.sold_to_cust_code,
                      t01.bill_to_cust_code,
                      t01.payer_cust_code,
                      t01.ship_to_cust_code,
                      t01.matl_code,
                      t01.matl_entd,
                      t01.billed_uom_code,
                      t01.billed_base_uom_code,
                      t01.plant_code,
                      t01.storage_locn_code,
                      t01.gen_sales_org_code,
                      t01.gen_distbn_chnl_code,
                      t01.gen_division_code,
                      t01.order_usage_code,
                      t01.demand_plng_grp_division_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_PERIOD01 Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_PERIOD01 Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_PERIOD01 Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_period_01_aggregation;

end dw_triggered_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_triggered_aggregation for dw_app.dw_triggered_aggregation;
grant execute on dw_triggered_aggregation to public;
