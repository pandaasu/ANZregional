/******************/
/* Package Header */
/******************/
create or replace package dw_sales_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_sales_aggregation (Hong Kong Version)
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Sales Aggregation (Hong Kong Version)

    This package contain the load and aggregation procedures for sales data. The package exposes
    one procedure EXECUTE that performs the load and aggregation based on the following parameters:

    1. PAR_ACTION (*DATE, *REBUILD) (MANDATORY)

       *DATE aggregates the requested fact table(s) from the operational data store
       for a particular date. *REBUILD replaces the requested fact table(s) with the
       aggregated data from the operational data store but does NOT load the
       SALES_FACT table. The SALES_FACT table can only be load one day at a time,
       that is, PAR_ACTION = *DATE.

    2. PAR_TABLE (*ALL, 'table name') (MANDATORY)

       *ALL performs the aggregation for all fact tables. A table name performs the
       aggregation for the requested fact table.

    3. PAR_DATE (date in string format YYYYMMDD) (OPTIONAL)

       The date for which the aggregation is to be performed. Only required for
       PAR_ACTION = *DATE

    4. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed. 

    **notes**
    1. A web log is produced under the search value DW_SALES_AGGREGATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All requested fact tables will attempt to be aggregated and and errors logged.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/01   Steve Gregan   Created
    2005/10   Steve Gregan   Added aggregation tables for SAP sales recognition date
                                SALES_DAY_MONTH_02_FACT
                                SALES_MONTH_04_FACT
                                SALES_MONTH_05_FACT
                                SALES_MONTH_06_FACT
                                SALES_PERIOD_04_FACT
    2006/03   Steve Gregan   Modified for Hong Kong pricing
    2006/04   Steve Gregan   Modified reference document from qualf 016 to 011 for Hong Kong
                             Removed CUST_PARTNER_FUNCN2 for Hong Kong
                             Included Report extract trigger for Hong Kong
                             Included Hermes trigger for Hong Kong
                             Move reference document from LADS_INV_IRF to LADS_INV_REF for Hong Kong
    2006/05   Steve Gregan   Added pricing condition R100
                             Included order aggregation for Hong Kong
                             Excluded invoice type ZF8 for Hong Kong
    2006/05   Steve Gregan   Changed quantity assignment/calculation
    2006/06   Steve Gregan   Modified invoice base UOM quantity from Atlas value to calculation.

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_table in varchar2, par_date in varchar2, par_company in varchar2);

end dw_sales_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_sales_aggregation as

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
   procedure sales_fact_load(par_date in date, par_company in varchar2);
   procedure sales_day_month_01_aggregation(par_yyyyppdd in number, par_company in varchar2);
   procedure sales_day_month_02_aggregation(par_yyyyppdd in number, par_company in varchar2);
   procedure sales_month_01_aggregation(par_yyyymm in number, par_company in varchar2);
   procedure sales_month_02_aggregation(par_yyyymm in number, par_company in varchar2);
   procedure sales_month_03_aggregation(par_yyyymm in number, par_company in varchar2);
   procedure sales_month_04_aggregation(par_yyyymm in number, par_company in varchar2);
   procedure sales_month_05_aggregation(par_yyyymm in number, par_company in varchar2);
   procedure sales_month_06_aggregation(par_yyyymm in number, par_company in varchar2);
   procedure sales_period_01_aggregation(par_yyyypp in number, par_company in varchar2);
   procedure sales_period_02_aggregation(par_yyyypp in number, par_company in varchar2);
   procedure sales_period_03_aggregation(par_yyyypp in number, par_company in varchar2);
   procedure sales_period_04_aggregation(par_yyyypp in number, par_company in varchar2);

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
   var_range_d02 tab_date;
   var_range_w02 tab_week;
   var_range_m02 tab_month;
   var_range_p02 tab_period;
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
      var_email_warning varchar2(256);
      var_locked boolean;
      var_errors boolean;
      var_date date;
      var_yyyypp number(6,0);
      var_yyyymm number(6,0);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Sales Aggregation';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'SALES_AGGREGATION';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'SALES_AGGREGATION';
      con_war_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_war_code constant varchar2(32) := 'SALES_DATE_WARNING';
      con_ord_alt_group constant varchar2(32) := 'DW_ALERT';
      con_ord_alt_code constant varchar2(32) := 'ORDER_AGGREGATION';
      con_ord_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ord_ema_code constant varchar2(32) := 'ORDER_AGGREGATION';
      con_ord_tri_group constant varchar2(32) := 'DW_JOB_GROUP';
      con_ord_tri_code constant varchar2(32) := 'ORDER_AGGREGATION';
      con_her_alt_group constant varchar2(32) := 'DW_ALERT';
      con_her_alt_code constant varchar2(32) := 'HERMES_ACTUAL_UPDATE';
      con_her_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_her_ema_code constant varchar2(32) := 'HERMES_ACTUAL_UPDATE';
      con_her_tri_group constant varchar2(32) := 'DW_JOB_GROUP';
      con_her_tri_code constant varchar2(32) := 'HERMES_ACTUAL_UPDATE';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select t1.mars_period,
                (t1.year_num * 100) + t1.month_num as mars_month
           from mars_date t1
          where trunc(t1.calendar_date) = trunc(var_date);
      rcd_mars_date csr_mars_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_SALES_AGGREGATION';
      var_log_search := 'DW_SALES_AGGREGATION';
      var_loc_string := 'DW_SALES_AGGREGATION';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_email_warning := lics_setting_configuration.retrieve_setting(con_war_group, con_war_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*DATE' and upper(par_action) != '*REBUILD' then
         raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *DATE or *REBUILD');
      end if;
      if upper(par_table) != '*ALL' and
         upper(par_table) != 'SALES_FACT' and
         upper(par_table) != 'SALES_DAY_MONTH_01_FACT' and
         upper(par_table) != 'SALES_DAY_MONTH_02_FACT' and
         upper(par_table) != 'SALES_MONTH_01_FACT' and
         upper(par_table) != 'SALES_MONTH_02_FACT' and
         upper(par_table) != 'SALES_MONTH_03_FACT' and
         upper(par_table) != 'SALES_MONTH_04_FACT' and
         upper(par_table) != 'SALES_MONTH_05_FACT' and
         upper(par_table) != 'SALES_MONTH_06_FACT' and
         upper(par_table) != 'SALES_PERIOD_01_FACT' and
         upper(par_table) != 'SALES_PERIOD_02_FACT' and
         upper(par_table) != 'SALES_PERIOD_03_FACT' and
         upper(par_table) != 'SALES_PERIOD_04_FACT' then
         raise_application_error(-20000, 'Table parameter (' || par_table || ') must be *ALL or ' ||
                                         'SALES_FACT, ' ||
                                         'SALES_DAY_MONTH_01_FACT, ' ||
                                         'SALES_DAY_MONTH_02_FACT, ' ||
                                         'SALES_MONTH_01_FACT, ' ||
                                         'SALES_MONTH_02_FACT, ' ||
                                         'SALES_MONTH_03_FACT, ' ||
                                         'SALES_MONTH_04_FACT, ' ||
                                         'SALES_MONTH_05_FACT, ' ||
                                         'SALES_MONTH_06_FACT, ' ||
                                         'SALES_PERIOD_01_FACT, ' ||
                                         'SALES_PERIOD_02_FACT, ' ||
                                         'SALES_PERIOD_03_FACT, ' ||
                                         'SALES_PERIOD_04_FACT');
      end if;
      if upper(par_action) = '*DATE' and (upper(par_table) != '*ALL' and upper(par_table) != 'SALES_FACT') then
         raise_application_error(-20000, 'Table parameter must be *ALL or SALES_FACT for action *DATE');
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
         var_range_d02.delete;
         var_range_w02.delete;
         var_range_m02.delete;
         var_range_p02.delete;
         var_range_d01(1) := 99999999;
         var_range_w01(1) := 9999999;
         var_range_m01(1) := 999999;
         var_range_p01(1) := 999999;
         var_range_d02(1) := 99999999;
         var_range_w02(1) := 9999999;
         var_range_m02(1) := 999999;
         var_range_p02(1) := 999999;
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
      lics_logging.write_log('Begin - Sales Aggregation - Parameters(' || upper(par_action) || ' + ' || upper(par_table) || ' + ' || nvl(par_date,'NULL') || ' + ' || par_company || ')');

      /*-*/
      /* Request the lock on the sales aggregation
      /*-*/
      begin
         lics_locking.request(var_loc_string || '-' || par_company);
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
         /*             sales_fact
         /*                ==> sales_day_month_01_fact
         /*                ==> sales_day_month_02_fact
         /*                ==> sales_month_01_fact
         /*                       ==> sales_month_02_fact
         /*                       ==> sales_month_03_fact
         /*                ==> sales_month_04_fact
         /*                       ==> sales_month_05_fact
         /*                       ==> sales_month_06_fact
         /*                ==> sales_period_01_fact
         /*                       ==> sales_period_02_fact
         /*                ==> sales_period_03_fact
         /*                       ==> sales_period_04_fact
         /*
         /*          2. Processed as follows
         /*
         /*             sales_fact
         /*                ==> sales_day_month_01_fact
         /*                ==> sales_day_month_02_fact
         /*                ==> sales_month_01_fact
         /*                       ==> sales_month_02_fact
         /*                       ==> sales_month_03_fact
         /*                ==> sales_month_04_fact
         /*                       ==> sales_month_05_fact
         /*                       ==> sales_month_06_fact
         /*                ==> sales_period_01_fact
         /*                       ==> sales_period_02_fact
         /*                ==> sales_period_03_fact
         /*                       ==> sales_period_04_fact
         /*
         /*          3. Sales fact must always and only be loaded when
         /*                PAR_ACTION = *DATE
         /*
         /*-*/

         /*-*/
         /* SALES_FACT aggregation - based on invoice creation date
         /*
         /* 1. Extract distinct time dimensions from old SALES_FACT rows for the creation date
         /* 2. Replace existing SALES_FACT rows for the creation date
         /* 3. Extract distinct time dimensions from new SALES_FACT rows for the creation date
         /*-*/
         if upper(par_action) = '*DATE' then
            begin
               load_time_range(var_date, var_yyyymm, var_yyyypp, par_company, 'OLD');
               sales_fact_load(var_date, par_company);
               load_time_range(var_date, var_yyyymm, var_yyyypp, par_company, 'NEW');
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Perform SALES_FACT dependant aggregations when no errors 
         /*-*/
         if var_errors = false then

            /*-*/
            /* SALES_DAY_MONTH_01_FACT aggregation - based on billing date (goods issued)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_DAY_MONTH_01_FACT' then
               for idx in 1..var_range_d01.count loop
                  begin
                     sales_day_month_01_aggregation(var_range_d01(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_DAY_MONTH_02_FACT aggregation - based on SAP billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_DAY_MONTH_02_FACT' then
               for idx in 1..var_range_d02.count loop
                  begin
                     sales_day_month_02_aggregation(var_range_d02(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_MONTH_01_FACT aggregation - based on billing date (goods issued)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_MONTH_01_FACT' then
               for idx in 1..var_range_m01.count loop
                  begin
                     sales_month_01_aggregation(var_range_m01(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_MONTH_02_FACT aggregation - based on billing date (goods issued)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_MONTH_02_FACT' then
               for idx in 1..var_range_m01.count loop
                  begin
                     sales_month_02_aggregation(var_range_m01(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_MONTH_03_FACT aggregation - based on billing date (goods issued)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_MONTH_03_FACT' then
               for idx in 1..var_range_m01.count loop
                  begin
                     sales_month_03_aggregation(var_range_m01(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_MONTH_04_FACT aggregation - based on SAP billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_MONTH_04_FACT' then
               for idx in 1..var_range_m02.count loop
                  begin
                     sales_month_04_aggregation(var_range_m02(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_MONTH_05_FACT aggregation - based on SAP billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_MONTH_05_FACT' then
               for idx in 1..var_range_m02.count loop
                  begin
                     sales_month_05_aggregation(var_range_m02(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_MONTH_06_FACT aggregation - based on SAP billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_MONTH_06_FACT' then
               for idx in 1..var_range_m02.count loop
                  begin
                     sales_month_06_aggregation(var_range_m02(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_PERIOD_01_FACT aggregation - based on billing date (goods issued)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_PERIOD_01_FACT' then
               for idx in 1..var_range_p01.count loop
                  begin
                     sales_period_01_aggregation(var_range_p01(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                 end;
               end loop;
            end if;

            /*-*/
            /* SALES_PERIOD_02_FACT aggregation - based on billing date (goods issued)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_PERIOD_02_FACT' then
               for idx in 1..var_range_p01.count loop
                  begin
                     sales_period_02_aggregation(var_range_p01(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_PERIOD_03_FACT aggregation - based on SAP billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_PERIOD_03_FACT' then
               for idx in 1..var_range_p02.count loop
                  begin
                     sales_period_03_aggregation(var_range_p02(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                  end;
               end loop;
            end if;

            /*-*/
            /* SALES_PERIOD_04_FACT aggregation - based on SAP billing date (requested delivery date)
            /*-*/
            if upper(par_table) = '*ALL' or upper(par_table) = 'SALES_PERIOD_04_FACT' then
               for idx in 1..var_range_p02.count loop
                  begin
                     sales_period_04_aggregation(var_range_p02(idx), par_company);
                  exception
                     when others then
                        var_errors := true;
                 end;
               end loop;
            end if;

         end if;

         /*-*/
         /* Release the lock on the sales aggregation
         /*-*/
         lics_locking.release(var_loc_string || '-' || par_company);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Sales Aggregation');

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
         if not(trim(var_email_warning) is null) and trim(upper(var_email_warning)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_SALES_AGGREGATION',
                                         var_email_warning,
                                         'Date warnings occurred during the Sales Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      end if;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_SALES_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Sales Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      /*-*/
      /* Set processing trace when required
      /*-*/
      else

         /*-*/
         /* Normal daily run
         /*-*/
         if par_action = '*DATE' and par_table = '*ALL' then

            /*-*/
            /* Set the sales aggregation trace for the current company
            /*-*/
            lics_processing.set_trace('SALES_AGGREGATION_' || par_company, par_date);

            /*-*/
            /* Trigger the order aggregation
            /*-*/
            lics_trigger_loader.execute('DW Order Aggregation',
                                        'dw_order_aggregation.execute(''' || par_date || ''',''' || par_company || ''')',
                                        lics_setting_configuration.retrieve_setting(con_ord_alt_group, con_ord_alt_code),
                                        lics_setting_configuration.retrieve_setting(con_ord_ema_group, con_ord_ema_code),
                                        lics_setting_configuration.retrieve_setting(con_ord_tri_group, con_ord_tri_code));

            /*-*/
            /* Trigger the Hermes actuals
            /*-*/
            lics_trigger_loader.execute('Hermes Actual Maintenance',
                                        'hermes_act_maintenance.retrieve_actual(''' || par_company || ''')',
                                        lics_setting_configuration.retrieve_setting(con_her_alt_group, con_her_alt_code),
                                        lics_setting_configuration.retrieve_setting(con_her_ema_group, con_her_ema_code),
                                        lics_setting_configuration.retrieve_setting(con_her_tri_group, con_her_tri_code));

         end if;

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
         var_exception := substr(SQLERRM, 1, 1024);

         /*-*/
         /* Log error
         /*-*/
         if lics_logging.is_created = true then
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         end if;

         /*-*/
         /* Release the lock on the sales aggregation
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string || '-' || par_company);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_SALES_AGGREGATION - ' || var_exception);

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
         select distinct t1.billing_yyyyppdd as billing_yyyyppdd
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_d01 csr_range_d01%rowtype;

      cursor csr_range_w01 is
         select distinct t1.billing_yyyyppw as billing_yyyyppw
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_w01 csr_range_w01%rowtype;

      cursor csr_range_m01 is
         select distinct t1.billing_yyyymm as billing_yyyymm
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_m01 csr_range_m01%rowtype;

      cursor csr_range_p01 is
         select distinct t1.billing_yyyypp as billing_yyyypp
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_p01 csr_range_p01%rowtype;

      cursor csr_range_d02 is
         select distinct t1.sap_billing_yyyyppdd as sap_billing_yyyyppdd
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_d02 csr_range_d02%rowtype;

      cursor csr_range_w02 is
         select distinct t1.sap_billing_yyyyppw as sap_billing_yyyyppw
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_w02 csr_range_w02%rowtype;

      cursor csr_range_m02 is
         select distinct t1.sap_billing_yyyymm as sap_billing_yyyymm
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_m02 csr_range_m02%rowtype;

      cursor csr_range_p02 is
         select distinct t1.sap_billing_yyyypp as sap_billing_yyyypp
           from sales_fact t1
          where t1.sap_company_code = par_company
            and t1.creatn_date = trunc(par_date);
      rcd_range_p02 csr_range_p02%rowtype;

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
         var_range_d02.delete;
         var_range_w02.delete;
         var_range_m02.delete;
         var_range_p02.delete;
      end if;

      /*-*/
      /* Retrieve the goods issued date time dimensions
      /*-*/
      open csr_range_d01;
      loop
         fetch csr_range_d01 into rcd_range_d01;
         if csr_range_d01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_d01.count loop
            if var_range_d01(idx) = rcd_range_d01.billing_yyyyppdd then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_d01.count + 1;
            var_range_d01(var_index) := rcd_range_d01.billing_yyyyppdd;
         end if;
      end loop;
      close csr_range_d01;

      /*-*/
      /* Retrieve the goods issued week time dimensions
      /*-*/
      open csr_range_w01;
      loop
         fetch csr_range_w01 into rcd_range_w01;
         if csr_range_w01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_w01.count loop
            if var_range_w01(idx) = rcd_range_w01.billing_yyyyppw then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_w01.count + 1;
            var_range_w01(var_index) := rcd_range_w01.billing_yyyyppw;
         end if;
      end loop;
      close csr_range_w01;

      /*-*/
      /* Retrieve the goods issued month time dimensions
      /*-*/
      open csr_range_m01;
      loop
         fetch csr_range_m01 into rcd_range_m01;
         if csr_range_m01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_m01.count loop
            if var_range_m01(idx) = rcd_range_m01.billing_yyyymm then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_m01.count + 1;
            var_range_m01(var_index) := rcd_range_m01.billing_yyyymm;
         end if;
      end loop;
      close csr_range_m01;

      /*-*/
      /* Retrieve the goods issued period time dimensions
      /*-*/
      open csr_range_p01;
      loop
         fetch csr_range_p01 into rcd_range_p01;
         if csr_range_p01%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_p01.count loop
            if var_range_p01(idx) = rcd_range_p01.billing_yyyypp then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_p01.count + 1;
            var_range_p01(var_index) := rcd_range_p01.billing_yyyypp;
         end if;
      end loop;
      close csr_range_p01;

      /*-*/
      /* Retrieve the billing date time dimensions
      /*-*/
      open csr_range_d02;
      loop
         fetch csr_range_d02 into rcd_range_d02;
         if csr_range_d02%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_d02.count loop
            if var_range_d02(idx) = rcd_range_d02.sap_billing_yyyyppdd then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_d02.count + 1;
            var_range_d02(var_index) := rcd_range_d02.sap_billing_yyyyppdd;
         end if;
      end loop;
      close csr_range_d02;

      /*-*/
      /* Retrieve the billing week time dimensions
      /*-*/
      open csr_range_w02;
      loop
         fetch csr_range_w02 into rcd_range_w02;
         if csr_range_w02%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_w02.count loop
            if var_range_w02(idx) = rcd_range_w02.sap_billing_yyyyppw then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_w02.count + 1;
            var_range_w02(var_index) := rcd_range_w02.sap_billing_yyyyppw;
         end if;
      end loop;
      close csr_range_w02;

      /*-*/
      /* Retrieve the billing month time dimensions
      /*-*/
      open csr_range_m02;
      loop
         fetch csr_range_m02 into rcd_range_m02;
         if csr_range_m02%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_m02.count loop
            if var_range_m02(idx) = rcd_range_m02.sap_billing_yyyymm then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_m02.count + 1;
            var_range_m02(var_index) := rcd_range_m02.sap_billing_yyyymm;
         end if;
      end loop;
      close csr_range_m02;

      /*-*/
      /* Retrieve the billing period time dimensions
      /*-*/
      open csr_range_p02;
      loop
         fetch csr_range_p02 into rcd_range_p02;
         if csr_range_p02%notfound then
            exit;
         end if;
         var_found := false;
         for idx in 1..var_range_p02.count loop
            if var_range_p02(idx) = rcd_range_p02.sap_billing_yyyypp then
               var_found := true;
               exit;
            end if;
         end loop;
         if var_found = false then
            var_index := var_range_p02.count + 1;
            var_range_p02(var_index) := rcd_range_p02.sap_billing_yyyypp;
         end if;
      end loop;
      close csr_range_p02;

      /*-*/
      /* Check the time dimension ranges when required
      /*-*/
      if upper(par_range) = 'NEW' then

         var_string := null;
         for idx in 1..var_range_m01.count loop
            if var_range_m01(idx) < par_yyyymm then
               if var_string is null then
                  var_string := '**WARNING** - Prior creation date months exist for invoice data - ' || var_range_m01(idx);
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
                  var_string := '**WARNING** - Prior creation date periods exist for invoice data - ' || var_range_p01(idx);
               else
                  var_string := var_string || ',' || var_range_p01(idx);
               end if;
            end if;
         end loop;
         if not(var_string is null) then
            lics_logging.write_log(var_string);
            var_warning := true;
         end if;

         var_string := null;
         for idx in 1..var_range_m02.count loop
            if var_range_m02(idx) < par_yyyymm then
               if var_string is null then
                  var_string := '**WARNING** - Prior billing date months exist for invoice data - ' || var_range_m02(idx);
               else
                  var_string := var_string || ',' || var_range_m02(idx);
               end if;
            end if;
         end loop;
         if not(var_string is null) then
            lics_logging.write_log(var_string);
            var_warning := true;
         end if;

         var_string := null;
         for idx in 1..var_range_p02.count loop
            if var_range_p02(idx) < par_yyyypp then
               if var_string is null then
                  var_string := '**WARNING** - Prior billing date periods exist for invoice data - ' || var_range_p02(idx);
               else
                  var_string := var_string || ',' || var_range_p02(idx);
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
   /* This procedure performs the sales fact load routine */
   /*******************************************************/
   procedure sales_fact_load(par_date in date, par_company in varchar2) is

      /*-*/
      /* Local variables
      /*-*/
      rcd_sales_fact sales_fact%rowtype;
      var_reqd_dlvry_date date;
      var_invc_type_sign invc_type.invc_type_sign%type;
      var_sap_material_code rcd_sales_fact.sap_material_code%type;
      var_invoice_type_factor number;
      var_price_record_factor number;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_invoice is
         select count(*) as inv_count
           from lads_inv_hdr t01,
                (select t21.belnr as belnr
                   from lads_inv_dat t21
                  where t21.iddat = '015'
                    and lads_to_date(t21.datum,'yyyymmdd') = trunc(par_date)
                  group by t21.belnr) T02,
                (select t31.belnr as belnr
                   from lads_inv_org t31
                  where t31.qualf = '003'
                    and t31.orgid = par_company) t03
          where t01.belnr = t02.belnr
            and t01.belnr = t03.belnr;
      rcd_invoice csr_invoice%rowtype;

      cursor csr_lads_inv_hdr is
         select t01.belnr as belnr,
                t01.curcy as curcy,
                nvl(lads_to_number(t01.wkurs),1) as wkurs,
                augru as augru
           from lads_inv_hdr t01,
                (select t21.belnr as belnr
                   from lads_inv_dat t21
                  where t21.iddat = '015'
                    and lads_to_date(t21.datum,'yyyymmdd') = trunc(par_date)
                  group by t21.belnr) T02,
                (select t31.belnr as belnr
                   from lads_inv_org t31
                  where t31.qualf = '003'
                    and t31.orgid = par_company) t03
          where t01.belnr = t02.belnr
            and t01.belnr = t03.belnr;
      rcd_lads_inv_hdr csr_lads_inv_hdr%rowtype;

      cursor csr_lads_inv_dat is
         select t01.belnr as belnr,
                t01.iddat as iddat,
                lads_to_date(t01.datum,'yyyymmdd') as datum,
                t02.mars_yyyyppdd as mars_yyyyppdd,
                t02.mars_week as mars_yyyyppw,
                t02.mars_period as mars_yyyypp,
                (t02.year_num * 100) + t02.month_num as mars_yyyymm
           from lads_inv_dat t01,
                mars_date t02
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.iddat in ('015','024','026')
            and lads_to_date(t01.datum,'yyyymmdd') = t02.calendar_date(+);
      rcd_lads_inv_dat csr_lads_inv_dat%rowtype;

      cursor csr_lads_inv_org is
         select t01.belnr as belnr,
                t01.qualf as qualf,
                t01.orgid as orgid
           from lads_inv_org t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.qualf in ('003','006','007','008','012','015');
      rcd_lads_inv_org csr_lads_inv_org%rowtype;

      cursor csr_lads_inv_pnr is
         select t01.belnr as belnr,
                t01.parvw as parvw,
                lads_trim_code(t01.partn) as partn
           from lads_inv_pnr t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.parvw in ('AG','RE','RG','Z5','Z6','ZA');
      rcd_lads_inv_pnr csr_lads_inv_pnr%rowtype;

      cursor csr_lads_inv_ref is
         select t01.qualf as qualf,
                t01.refnr as refnr,
                t01.posnr as posnr
           from lads_inv_ref t01
          where t01.belnr = rcd_lads_inv_hdr.belnr
            and t01.qualf in ('011');
      rcd_lads_inv_ref csr_lads_inv_ref%rowtype;

      cursor csr_lads_inv_gen is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.vsart as vsart,
                t01.zztarif as zztarif,
                t01.menee as menee,
                t01.meins as meins,
                t01.werks as werks,
                t01.lgort as lgort,
                t01.prod_spart as prod_spart,
                t01.vkorg as vkorg,
                t01.vtweg as vtweg,
                t01.spart as spart,
                t01.abrvw as abrvw,
                nvl(lads_to_number(t01.menge),0) as menge,
                nvl(lads_to_number(t01.fklmg),0) as fklmg,
                t01.kwmeng as kwmeng
           from lads_inv_gen t01
          where t01.belnr = rcd_lads_inv_hdr.belnr;
      rcd_lads_inv_gen csr_lads_inv_gen%rowtype;

      cursor csr_lads_inv_iob is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.qualf as qualf,
                t01.idtnr as idtnr
           from lads_inv_iob t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.qualf in ('002','010','Z01')
            and length(trim(t01.idtnr)) > 0;
      rcd_lads_inv_iob csr_lads_inv_iob%rowtype;

      cursor csr_lads_inv_idt is
         select t01.iddat as iddat,
                lads_to_date(t01.datum,'yyyymmdd') as datum
           from lads_inv_idt t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.iddat in ('022','024','026');
      rcd_lads_inv_idt csr_lads_inv_idt%rowtype;

      cursor csr_lads_inv_ipn is
         select t01.parvw as parvw,
                lads_trim_code(t01.partn) as partn
           from lads_inv_ipn t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.parvw = 'WE';
      rcd_lads_inv_ipn csr_lads_inv_ipn%rowtype;

      cursor csr_lads_inv_irf is
         select t01.qualf as qualf,
                t01.refnr as refnr,
                t01.zeile as zeile
           from lads_inv_irf t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.qualf in ('001','002');
      rcd_lads_inv_irf csr_lads_inv_irf%rowtype;

      cursor csr_lads_inv_icn is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.alckz as alckz,
                t01.kschl as kschl,
                nvl(lads_to_number(t01.betrg),0) as betrg
           from lads_inv_icn t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and not(t01.kschl is null);
      rcd_lads_inv_icn csr_lads_inv_icn%rowtype;

      cursor csr_lads_inv_ias is
         select t01.belnr as belnr,
                t01.genseq as genseq,
                t01.qualf as qualf,
                nvl(lads_to_number(t01.betrg),0) as betrg
           from lads_inv_ias t01
          where t01.belnr = rcd_lads_inv_gen.belnr
            and t01.genseq = rcd_lads_inv_gen.genseq
            and t01.qualf in ('002','003');
      rcd_lads_inv_ias csr_lads_inv_ias%rowtype;

      cursor csr_lads_mat_uom is
         select t01.meins as meins,
                t01.gewei as gewei,
                nvl(t01.ntgew,0) as ntgew,
                nvl(t02.umren,1) as sal_umren,
                nvl(t02.umrez,1) as sal_umrez,
                nvl(t03.umren,1) as pce_umren,
                nvl(t03.umrez,1) as pce_umrez
           from lads_mat_hdr t01,
                (select t21.matnr,
                        t21.umren,
                        t21.umrez
                   from lads_mat_uom t21
                  where t21.matnr = var_sap_material_code
                    and t21.meinh = rcd_sales_fact.sap_billed_qty_uom_code) t02,
                (select t31.matnr,
                        t31.umren,
                        t31.umrez
                   from lads_mat_uom t31
                  where t31.matnr = var_sap_material_code
                    and t31.meinh = 'PCE') t03
          where t01.matnr = t02.matnr(+)
            and t01.matnr = t03.matnr(+)
            and t01.matnr = var_sap_material_code;
      rcd_lads_mat_uom csr_lads_mat_uom%rowtype;

      cursor csr_invc_type is
         select t01.invc_type_sign as invc_type_sign
           from invc_type t01
          where t01.sap_invc_type_code = rcd_sales_fact.sap_invc_type_code;
      rcd_invc_type csr_invc_type%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_FACT Load - Parameters(' || to_char(par_date,'yyyy/mm/dd') || ' + ' || par_company || ')');

      /*-*/
      /* Delete the sales fact rows for the parameter date and company only when invoice transactions exist
      /*-*/
      open csr_invoice;
      fetch csr_invoice into rcd_invoice;
      if csr_invoice%found and rcd_invoice.inv_count > 0 then
         delete from sales_fact
          where creatn_date = trunc(par_date)
            and sap_company_code = par_company;
      end if;

      /*-*/
      /* Retrieve the invoices for the parameter date and company
      /*-*/
      open csr_lads_inv_hdr;
      loop
         fetch csr_lads_inv_hdr into rcd_lads_inv_hdr;
         if csr_lads_inv_hdr%notfound then
            exit;
         end if;

         /*-*/
         /* Set the sales fact header values
         /*-*/
         rcd_sales_fact.invc_num := rcd_lads_inv_hdr.belnr;
         rcd_sales_fact.sap_doc_currcy_code := rcd_lads_inv_hdr.curcy;
         rcd_sales_fact.exch_rate := rcd_lads_inv_hdr.wkurs;
         rcd_sales_fact.sap_order_reasn_code := rcd_lads_inv_hdr.augru;

         /*-*/
         /* Retrieve the invoice date data
         /*-*/
         rcd_sales_fact.creatn_date := null;
         rcd_sales_fact.billing_date := null;
         rcd_sales_fact.billing_yyyyppdd := null;
         rcd_sales_fact.billing_yyyyppw := null;
         rcd_sales_fact.billing_yyyypp := null;
         rcd_sales_fact.billing_yyyymm := null;
         rcd_sales_fact.sap_billing_date := null;
         rcd_sales_fact.sap_billing_yyyyppdd := null;
         rcd_sales_fact.sap_billing_yyyyppw := null;
         rcd_sales_fact.sap_billing_yyyypp := null;
         rcd_sales_fact.sap_billing_yyyymm := null;
         var_reqd_dlvry_date := null;
         open csr_lads_inv_dat;
         loop
            fetch csr_lads_inv_dat into rcd_lads_inv_dat;
            if csr_lads_inv_dat%notfound then
               exit;
            end if;
            if rcd_lads_inv_dat.iddat = '015' then
               rcd_sales_fact.creatn_date := rcd_lads_inv_dat.datum;
               rcd_sales_fact.billing_date := rcd_lads_inv_dat.datum;
               rcd_sales_fact.billing_yyyyppdd := rcd_lads_inv_dat.mars_yyyyppdd;
               rcd_sales_fact.billing_yyyyppw := rcd_lads_inv_dat.mars_yyyyppw;
               rcd_sales_fact.billing_yyyypp := rcd_lads_inv_dat.mars_yyyypp;
               rcd_sales_fact.billing_yyyymm := rcd_lads_inv_dat.mars_yyyymm;
            elsif rcd_lads_inv_dat.iddat = '024' then
               var_reqd_dlvry_date := rcd_lads_inv_dat.datum;
            elsif rcd_lads_inv_dat.iddat = '026' then
               rcd_sales_fact.sap_billing_date := rcd_lads_inv_dat.datum;
               rcd_sales_fact.sap_billing_yyyyppdd := rcd_lads_inv_dat.mars_yyyyppdd;
               rcd_sales_fact.sap_billing_yyyyppw := rcd_lads_inv_dat.mars_yyyyppw;
               rcd_sales_fact.sap_billing_yyyypp := rcd_lads_inv_dat.mars_yyyypp;
               rcd_sales_fact.sap_billing_yyyymm := rcd_lads_inv_dat.mars_yyyymm;
            end if;
         end loop;
         close csr_lads_inv_dat;

         /*-*/
         /* Retrieve the invoice organisation data
         /*-*/
         rcd_sales_fact.sap_order_type_code := null;
         rcd_sales_fact.sap_invc_type_code := null;
         rcd_sales_fact.sap_company_code := null;
         rcd_sales_fact.sap_sales_hdr_sales_org_code := null;
         rcd_sales_fact.sap_sales_hdr_distbn_chnl_code := null;
         rcd_sales_fact.sap_sales_hdr_division_code := null;
         open csr_lads_inv_org;
         loop
            fetch csr_lads_inv_org into rcd_lads_inv_org;
            if csr_lads_inv_org%notfound then
               exit;
            end if;
            case rcd_lads_inv_org.qualf
               when '012' then rcd_sales_fact.sap_order_type_code := rcd_lads_inv_org.orgid;
               when '015' then rcd_sales_fact.sap_invc_type_code := rcd_lads_inv_org.orgid;
               when '003' then rcd_sales_fact.sap_company_code := rcd_lads_inv_org.orgid;
               when '008' then rcd_sales_fact.sap_sales_hdr_sales_org_code := rcd_lads_inv_org.orgid;
               when '007' then rcd_sales_fact.sap_sales_hdr_distbn_chnl_code := rcd_lads_inv_org.orgid;
               when '006' then rcd_sales_fact.sap_sales_hdr_division_code := rcd_lads_inv_org.orgid;
               else null;
            end case;
         end loop;
         close csr_lads_inv_org;

         /*-*/
         /* Retrieve the invoice type sign
         /*-*/
         var_invc_type_sign := null;
         open csr_invc_type;
         fetch csr_invc_type into rcd_invc_type;
         if csr_invc_type%found then
            var_invc_type_sign := rcd_invc_type.invc_type_sign;
         end if;
         close csr_invc_type;
         var_invoice_type_factor := 1;
	 if var_invc_type_sign = '-' then
	    var_invoice_type_factor := -1;
         end if;

         /*-*/
         /* Retrieve the invoice partner data
         /*-*/
         rcd_sales_fact.sap_sold_to_cust_code := null;
         rcd_sales_fact.sap_bill_to_cust_code := null;
         rcd_sales_fact.sap_payer_cust_code := null;
         rcd_sales_fact.sap_secondary_ws_cust_code := null;
         rcd_sales_fact.sap_tertiary_ws_cust_code := null;
         rcd_sales_fact.sap_sales_force_hier_cust_code := null;
         rcd_sales_fact.sap_pmt_path_pri_ws_cust_code := null;
         rcd_sales_fact.sap_pmt_path_sec_ws_cust_code := null;
         rcd_sales_fact.sap_pmt_path_ter_ws_cust_code := null;
         rcd_sales_fact.sap_pmt_path_ret_cust_code := null;
         open csr_lads_inv_pnr;
         loop
            fetch csr_lads_inv_pnr into rcd_lads_inv_pnr;
            if csr_lads_inv_pnr%notfound then
               exit;
            end if;
            case rcd_lads_inv_pnr.parvw
               when 'AG' then rcd_sales_fact.sap_sold_to_cust_code := rcd_lads_inv_pnr.partn;
               when 'RE' then rcd_sales_fact.sap_bill_to_cust_code := rcd_lads_inv_pnr.partn;
               when 'RG' then rcd_sales_fact.sap_payer_cust_code := rcd_lads_inv_pnr.partn;
               when 'Z5' then rcd_sales_fact.sap_secondary_ws_cust_code := rcd_lads_inv_pnr.partn;
               when 'Z6' then rcd_sales_fact.sap_tertiary_ws_cust_code:= rcd_lads_inv_pnr.partn;
               when 'ZA' then rcd_sales_fact.sap_sales_force_hier_cust_code := rcd_lads_inv_pnr.partn;
               else null;
            end case;
         end loop;
         close csr_lads_inv_pnr;
         rcd_sales_fact.sap_pmt_path_pri_ws_cust_code := rcd_sales_fact.sap_sold_to_cust_code;

         /*-*/
         /* Set the invoice reference data
         /*-*/
         rcd_sales_fact.ref_doc_num := null;
         rcd_sales_fact.ref_doc_line_num := null;
         open csr_lads_inv_ref;
         loop
            fetch csr_lads_inv_ref into rcd_lads_inv_ref;
            if csr_lads_inv_ref%notfound then
               exit;
            end if;
            if rcd_lads_inv_ref.qualf =  '011' then
               rcd_sales_fact.ref_doc_num := rcd_lads_inv_ref.refnr;
               rcd_sales_fact.ref_doc_line_num := rcd_lads_inv_ref.posnr;
            end if;
         end loop;
         close csr_lads_inv_ref;

         /*-*/
         /* Retrieve the invoice line data
         /*-*/
         open csr_lads_inv_gen;
         loop
            fetch csr_lads_inv_gen into rcd_lads_inv_gen;
            if csr_lads_inv_gen%notfound then
               exit;
            end if;

            /*-*/
            /* Retrieve the invoice object identification data
            /*-*/
            rcd_sales_fact.sap_material_code := null;
            rcd_sales_fact.batch_num := null;
            rcd_sales_fact.material_entd := null;
            open csr_lads_inv_iob;
            loop
               fetch csr_lads_inv_iob into rcd_lads_inv_iob;
               if csr_lads_inv_iob%notfound then
                  exit;
               end if;
               case rcd_lads_inv_iob.qualf
                  when '002' then rcd_sales_fact.sap_material_code := rcd_lads_inv_iob.idtnr;
                  when '010' then rcd_sales_fact.batch_num := rcd_lads_inv_iob.idtnr;
                  when 'Z01' then rcd_sales_fact.material_entd := lads_trim_code(rcd_lads_inv_iob.idtnr);
                  else null;
               end case;
            end loop;
            close csr_lads_inv_iob;

            /*-*/
            /* Only load the invoice line when material code present
            /*-*/
            if not(rcd_sales_fact.sap_material_code is null) then

               /*-*/
               /* Save the untrimmed sap material code
               /*-*/
               var_sap_material_code := rcd_sales_fact.sap_material_code;
               rcd_sales_fact.sap_material_code := lads_trim_code(rcd_sales_fact.sap_material_code);

               /*-*/
               /* Set the invoice item data
               /*-*/
               rcd_sales_fact.sap_shipg_type_code := rcd_lads_inv_gen.vsart;
               rcd_sales_fact.crpc_price_band := rcd_lads_inv_gen.zztarif;
               rcd_sales_fact.sap_billed_qty_uom_code := rcd_lads_inv_gen.menee;
               rcd_sales_fact.sap_billed_qty_base_uom_code := rcd_lads_inv_gen.meins;
               rcd_sales_fact.sap_plant_code := rcd_lads_inv_gen.werks;
               rcd_sales_fact.sap_storage_locn_code := rcd_lads_inv_gen.lgort;
               rcd_sales_fact.sap_material_division_code := rcd_lads_inv_gen.prod_spart;
               rcd_sales_fact.sap_sales_dtl_sales_org_code := rcd_lads_inv_gen.vkorg;
               rcd_sales_fact.sap_sales_dtl_distbn_chnl_code := rcd_lads_inv_gen.vtweg;
               rcd_sales_fact.sap_sales_dtl_division_code := rcd_lads_inv_gen.spart;
               rcd_sales_fact.sap_order_usage_code := rcd_lads_inv_gen.abrvw;

               /*-*/
               /* Set the invoice item partner data
               /*-*/
               rcd_sales_fact.sap_ship_to_cust_code := null;
               open csr_lads_inv_ipn;
               fetch csr_lads_inv_ipn into rcd_lads_inv_ipn;
               if csr_lads_inv_ipn%found then
                  rcd_sales_fact.sap_ship_to_cust_code := rcd_lads_inv_ipn.partn;
               end if;
               close csr_lads_inv_ipn;

               /*-*/
               /* Retrieve the material uom data
               /*-*/
               rcd_sales_fact.order_qty := rcd_lads_inv_gen.kwmeng * var_invoice_type_factor;
               rcd_sales_fact.billed_qty := rcd_lads_inv_gen.menge * var_invoice_type_factor;
               rcd_sales_fact.base_uom_billed_qty := rcd_sales_fact.billed_qty;
               rcd_sales_fact.pieces_billed_qty := rcd_sales_fact.billed_qty;
               rcd_sales_fact.tonnes_billed_qty := 0;
               open csr_lads_mat_uom;
               fetch csr_lads_mat_uom into rcd_lads_mat_uom;
               if csr_lads_mat_uom%found then
                  rcd_sales_fact.sap_billed_qty_base_uom_code := rcd_lads_mat_uom.meins;
                  rcd_sales_fact.base_uom_billed_qty := (rcd_sales_fact.billed_qty * rcd_lads_mat_uom.sal_umrez) / rcd_lads_mat_uom.sal_umren;
                  if rcd_sales_fact.sap_billed_qty_uom_code != 'PCE' then
                     rcd_sales_fact.pieces_billed_qty := (rcd_sales_fact.base_uom_billed_qty / rcd_lads_mat_uom.pce_umrez) * rcd_lads_mat_uom.pce_umren;
                  end if;
                  case rcd_lads_mat_uom.gewei
                     when 'G' then rcd_sales_fact.tonnes_billed_qty := rcd_sales_fact.base_uom_billed_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                     when 'GRM' then rcd_sales_fact.tonnes_billed_qty := rcd_sales_fact.base_uom_billed_qty * (rcd_lads_mat_uom.ntgew / 1000000);
                     when 'KG' then rcd_sales_fact.tonnes_billed_qty := rcd_sales_fact.base_uom_billed_qty * (rcd_lads_mat_uom.ntgew / 1000);
                     when 'KGM' then rcd_sales_fact.tonnes_billed_qty := rcd_sales_fact.base_uom_billed_qty * (rcd_lads_mat_uom.ntgew / 1000);
                     when 'TO' then rcd_sales_fact.tonnes_billed_qty := rcd_sales_fact.base_uom_billed_qty * (rcd_lads_mat_uom.ntgew / 1);
                     when 'TON' then rcd_sales_fact.tonnes_billed_qty := rcd_sales_fact.base_uom_billed_qty * (rcd_lads_mat_uom.ntgew / 1);
                     else rcd_sales_fact.tonnes_billed_qty := 0;
                  end case;
               end if;
               close csr_lads_mat_uom;

               /*-*/
               /* Set the invoice item date data
               /*-*/
               rcd_sales_fact.goods_issued_date := rcd_sales_fact.billing_date;
               rcd_sales_fact.reqd_dlvry_date := var_reqd_dlvry_date;
               rcd_sales_fact.purch_order_date := null;
               open csr_lads_inv_idt;
               loop
                  fetch csr_lads_inv_idt into rcd_lads_inv_idt;
                  if csr_lads_inv_idt%notfound then
                     exit;
                  end if;
                  case rcd_lads_inv_idt.iddat
                     when '022' then rcd_sales_fact.purch_order_date := rcd_lads_inv_idt.datum;
                     when '024' then rcd_sales_fact.reqd_dlvry_date := rcd_lads_inv_idt.datum;
                     when '026' then rcd_sales_fact.goods_issued_date := rcd_lads_inv_idt.datum;
                     else null;
                  end case;
               end loop;
               close csr_lads_inv_idt;

               /*-*/
               /* Set the invoice item reference data
               /*-*/
               rcd_sales_fact.sales_doc_num := null;
               rcd_sales_fact.sales_doc_line_num := null;
               rcd_sales_fact.purch_order_num := null;
               open csr_lads_inv_irf;
               loop
                  fetch csr_lads_inv_irf into rcd_lads_inv_irf;
                  if csr_lads_inv_irf%notfound then
                     exit;
                  end if;
                  if rcd_lads_inv_irf.qualf = '001' then
                     rcd_sales_fact.purch_order_num := rcd_lads_inv_irf.refnr;
                  elsif rcd_lads_inv_irf.qualf = '002' then
                     rcd_sales_fact.sales_doc_num := rcd_lads_inv_irf.refnr;
                     rcd_sales_fact.sales_doc_line_num := rcd_lads_inv_irf.zeile;
                  end if;
               end loop;
               close csr_lads_inv_irf;

               /*-*/
               /* Retrieve the invoice item condition data
               /*-*/
               rcd_sales_fact.sales_dtl_price_value_1 := 0;
               rcd_sales_fact.sales_dtl_price_value_2 := 0;
               rcd_sales_fact.sales_dtl_price_value_3 := 0;
               rcd_sales_fact.sales_dtl_price_value_4 := 0;
               rcd_sales_fact.sales_dtl_price_value_5 := 0;
               rcd_sales_fact.sales_dtl_price_value_6 := 0;
               rcd_sales_fact.sales_dtl_price_value_7 := 0;
               rcd_sales_fact.sales_dtl_price_value_8 := 0;
               rcd_sales_fact.sales_dtl_price_value_9 := 0;
               rcd_sales_fact.sales_dtl_price_value_10 := 0;
               rcd_sales_fact.sales_dtl_price_value_12 := 0;
               rcd_sales_fact.sales_dtl_price_value_14 := 0;
               rcd_sales_fact.sales_dtl_price_value_15 := 0;
               rcd_sales_fact.sales_dtl_price_value_18 := 0;
               rcd_sales_fact.sales_dtl_price_value_19 := 0;
               rcd_sales_fact.sales_dtl_price_value_20 := 0;
               rcd_sales_fact.sales_dtl_price_value_21 := 0;
               rcd_sales_fact.sales_dtl_price_value_22 := 0;
               rcd_sales_fact.sales_dtl_price_value_23 := 0;
               open csr_lads_inv_icn;
               loop
                  fetch csr_lads_inv_icn into rcd_lads_inv_icn;
                  if csr_lads_inv_icn%notfound then
                     exit;
                  end if;
                  var_price_record_factor := 1;
                  if rcd_lads_inv_icn.alckz = '-' then
                     var_price_record_factor := -1;
                  end if;
                  rcd_lads_inv_icn.betrg := rcd_lads_inv_icn.betrg * var_invoice_type_factor * var_price_record_factor;
                  case rcd_lads_inv_icn.kschl
                     when 'ZRSP' then rcd_sales_fact.sales_dtl_price_value_1 := round(rcd_lads_inv_icn.betrg*rcd_sales_fact.exch_rate,2);
                     when 'ZH00' then rcd_sales_fact.sales_dtl_price_value_2 := round(rcd_lads_inv_icn.betrg*rcd_sales_fact.exch_rate,2);
                     when 'ZH10' then rcd_sales_fact.sales_dtl_price_value_3 := round(rcd_lads_inv_icn.betrg*rcd_sales_fact.exch_rate,2);
                     when 'ZH11' then rcd_sales_fact.sales_dtl_price_value_4 := round(rcd_lads_inv_icn.betrg*rcd_sales_fact.exch_rate,2);
                     when 'ZH35' then rcd_sales_fact.sales_dtl_price_value_5 := round(rcd_lads_inv_icn.betrg*rcd_sales_fact.exch_rate,2);
                     when 'ZH36' then rcd_sales_fact.sales_dtl_price_value_6 := round(rcd_lads_inv_icn.betrg*rcd_sales_fact.exch_rate,2);
                     when 'R100' then rcd_sales_fact.sales_dtl_price_value_7 := round(rcd_lads_inv_icn.betrg*rcd_sales_fact.exch_rate,2);
                     else null;
                  end case;
               end loop;
               close csr_lads_inv_icn;

               /*-*/
               /* Retrieve the invoice item amount data
               /*-*/
               rcd_sales_fact.sales_dtl_price_value_11 := 0;
               rcd_sales_fact.sales_dtl_price_value_13 := 0;
               rcd_sales_fact.sales_dtl_price_value_16 := 0;
               rcd_sales_fact.sales_dtl_price_value_17 := 0;
               open csr_lads_inv_ias;
               loop
                  fetch csr_lads_inv_ias into rcd_lads_inv_ias;
                  if csr_lads_inv_ias%notfound then
                     exit;
                  end if;
                  var_price_record_factor := 1;
                  rcd_lads_inv_ias.betrg := rcd_lads_inv_ias.betrg * var_invoice_type_factor * var_price_record_factor;
                  case rcd_lads_inv_ias.qualf
                     when '002' then rcd_sales_fact.sales_dtl_price_value_13 := round(rcd_lads_inv_ias.betrg*rcd_sales_fact.exch_rate,2);
                     when '003' then rcd_sales_fact.sales_dtl_price_value_17 := round(rcd_lads_inv_ias.betrg*rcd_sales_fact.exch_rate,2);
                     else null;
                  end case;
               end loop;
               close csr_lads_inv_ias;
               rcd_sales_fact.sales_dtl_price_value_16 := rcd_sales_fact.sales_dtl_price_value_13 - rcd_sales_fact.sales_dtl_price_value_17;

               /*-*/
               /* Perform the sales fact data checks
               /*-*/
               if rcd_sales_fact.invc_num is null then
                  raise_application_error(-20000, 'Invoice number is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_doc_currcy_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Currency code is null - unable to continue');
               end if;
               if rcd_sales_fact.exch_rate is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Exchange rate is null - unable to continue');
               end if;
               if rcd_sales_fact.creatn_date is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Creation date is null - unable to continue');
               end if;
               if rcd_sales_fact.billing_date is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Billing date is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_billing_date is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - SAP billing date is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_invc_type_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Invoice type is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_company_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Company is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_sales_hdr_sales_org_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales header sales organisation is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_sales_hdr_distbn_chnl_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales header distribution channel is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_sales_hdr_division_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales header division is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_sold_to_cust_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sold to to customer is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_bill_to_cust_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Bill to customer is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_payer_cust_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Payer customer is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_material_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Material is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_ship_to_cust_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Ship to customer is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_billed_qty_base_uom_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Billed quantity base uom is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_plant_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Plant is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_material_division_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Material division is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_sales_dtl_sales_org_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales detail sales organisation is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_sales_dtl_distbn_chnl_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales detail distribution channel is null - unable to continue');
               end if;
               if rcd_sales_fact.sap_sales_dtl_division_code is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales detail division is null - unable to continue');
               end if;
               if rcd_sales_fact.order_qty is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Order quantity is null - unable to continue');
               end if;
               if rcd_sales_fact.billed_qty is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Billed quantity is null - unable to continue');
               end if;
               if rcd_sales_fact.sales_doc_num is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales document number is null - unable to continue');
               end if;
               if rcd_sales_fact.sales_doc_line_num is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Sales document line is null - unable to continue');
               end if;
               if var_invc_type_sign is null then
                  raise_application_error(-20000, 'Invoice (' || rcd_sales_fact.invc_num || ') - Invoice type sign is null - unable to continue');
               end if;

               /*-*/
               /* Insert the sales fact row
               /*-*/
               insert into sales_fact
                  (sap_order_type_code,
                   sap_invc_type_code,
                   creatn_date,
                   billing_date,
                   billing_yyyyppdd,
                   billing_yyyyppw,
                   billing_yyyypp,
                   billing_yyyymm,
                   sap_billing_date,
                   sap_billing_yyyyppdd,
                   sap_billing_yyyyppw,
                   sap_billing_yyyypp,
                   sap_billing_yyyymm,
                   sap_company_code,
                   sap_sales_hdr_sales_org_code,
                   sap_sales_hdr_distbn_chnl_code,
                   sap_sales_hdr_division_code,
                   invc_num,
                   sap_doc_currcy_code,
                   exch_rate,
                   sap_order_reasn_code,
                   sap_sold_to_cust_code,
                   sap_bill_to_cust_code,
                   sap_payer_cust_code,
                   sap_secondary_ws_cust_code,
                   sap_tertiary_ws_cust_code,
                   sap_pmt_path_pri_ws_cust_code,
                   sap_pmt_path_sec_ws_cust_code,
                   sap_pmt_path_ter_ws_cust_code,
                   sap_pmt_path_ret_cust_code,
                   sap_sales_force_hier_cust_code,
                   batch_num,
                   goods_issued_date,
                   reqd_dlvry_date,
                   order_qty,
                   billed_qty,
                   base_uom_billed_qty,
                   pieces_billed_qty,
                   tonnes_billed_qty,
                   sap_ship_to_cust_code,
                   sap_material_code,
                   material_entd,
                   sap_shipg_type_code,
                   crpc_price_band,
                   sap_billed_qty_uom_code,
                   sap_billed_qty_base_uom_code,
                   sap_plant_code,
                   sap_storage_locn_code,
                   sap_material_division_code,
                   sales_doc_num,
                   sales_doc_line_num,
                   ref_doc_num,
                   ref_doc_line_num,
                   sap_sales_dtl_sales_org_code,
                   sap_sales_dtl_distbn_chnl_code,
                   sap_sales_dtl_division_code,
                   sap_order_usage_code,
                   purch_order_num,
                   purch_order_date,
                   sales_dtl_price_value_1,
                   sales_dtl_price_value_2,
                   sales_dtl_price_value_3,
                   sales_dtl_price_value_4,
                   sales_dtl_price_value_5,
                   sales_dtl_price_value_6,
                   sales_dtl_price_value_7,
                   sales_dtl_price_value_8,
                   sales_dtl_price_value_9,
                   sales_dtl_price_value_10,
                   sales_dtl_price_value_11,
                   sales_dtl_price_value_12,
                   sales_dtl_price_value_13,
                   sales_dtl_price_value_14,
                   sales_dtl_price_value_15,
                   sales_dtl_price_value_16,
                   sales_dtl_price_value_17,
                   sales_dtl_price_value_18,
                   sales_dtl_price_value_19,
                   sales_dtl_price_value_20,
                   sales_dtl_price_value_21,
                   sales_dtl_price_value_22,
                   sales_dtl_price_value_23)
                  values(rcd_sales_fact.sap_order_type_code,
                         rcd_sales_fact.sap_invc_type_code,
                         rcd_sales_fact.creatn_date,
                         rcd_sales_fact.billing_date,
                         rcd_sales_fact.billing_yyyyppdd,
                         rcd_sales_fact.billing_yyyyppw,
                         rcd_sales_fact.billing_yyyypp,
                         rcd_sales_fact.billing_yyyymm,
                         rcd_sales_fact.sap_billing_date,
                         rcd_sales_fact.sap_billing_yyyyppdd,
                         rcd_sales_fact.sap_billing_yyyyppw,
                         rcd_sales_fact.sap_billing_yyyypp,
                         rcd_sales_fact.sap_billing_yyyymm,
                         rcd_sales_fact.sap_company_code,
                         rcd_sales_fact.sap_sales_hdr_sales_org_code,
                         rcd_sales_fact.sap_sales_hdr_distbn_chnl_code,
                         rcd_sales_fact.sap_sales_hdr_division_code,
                         rcd_sales_fact.invc_num,
                         rcd_sales_fact.sap_doc_currcy_code,
                         rcd_sales_fact.exch_rate,
                         rcd_sales_fact.sap_order_reasn_code,
                         rcd_sales_fact.sap_sold_to_cust_code,
                         rcd_sales_fact.sap_bill_to_cust_code,
                         rcd_sales_fact.sap_payer_cust_code,
                         rcd_sales_fact.sap_secondary_ws_cust_code,
                         rcd_sales_fact.sap_tertiary_ws_cust_code,
                         rcd_sales_fact.sap_pmt_path_pri_ws_cust_code,
                         rcd_sales_fact.sap_pmt_path_sec_ws_cust_code,
                         rcd_sales_fact.sap_pmt_path_ter_ws_cust_code,
                         rcd_sales_fact.sap_pmt_path_ret_cust_code,
                         rcd_sales_fact.sap_sales_force_hier_cust_code,
                         rcd_sales_fact.batch_num,
                         rcd_sales_fact.goods_issued_date,
                         rcd_sales_fact.reqd_dlvry_date,
                         rcd_sales_fact.order_qty,
                         rcd_sales_fact.billed_qty,
                         rcd_sales_fact.base_uom_billed_qty,
                         rcd_sales_fact.pieces_billed_qty,
                         rcd_sales_fact.tonnes_billed_qty,
                         rcd_sales_fact.sap_ship_to_cust_code,
                         rcd_sales_fact.sap_material_code,
                         rcd_sales_fact.material_entd,
                         rcd_sales_fact.sap_shipg_type_code,
                         rcd_sales_fact.crpc_price_band,
                         rcd_sales_fact.sap_billed_qty_uom_code,
                         rcd_sales_fact.sap_billed_qty_base_uom_code,
                         rcd_sales_fact.sap_plant_code,
                         rcd_sales_fact.sap_storage_locn_code,
                         rcd_sales_fact.sap_material_division_code,
                         rcd_sales_fact.sales_doc_num,
                         rcd_sales_fact.sales_doc_line_num,
                         rcd_sales_fact.ref_doc_num,
                         rcd_sales_fact.ref_doc_line_num,
                         rcd_sales_fact.sap_sales_dtl_sales_org_code,
                         rcd_sales_fact.sap_sales_dtl_distbn_chnl_code,
                         rcd_sales_fact.sap_sales_dtl_division_code,
                         rcd_sales_fact.sap_order_usage_code,
                         rcd_sales_fact.purch_order_num,
                         rcd_sales_fact.purch_order_date,
                         rcd_sales_fact.sales_dtl_price_value_1,
                         rcd_sales_fact.sales_dtl_price_value_2,
                         rcd_sales_fact.sales_dtl_price_value_3,
                         rcd_sales_fact.sales_dtl_price_value_4,
                         rcd_sales_fact.sales_dtl_price_value_5,
                         rcd_sales_fact.sales_dtl_price_value_6,
                         rcd_sales_fact.sales_dtl_price_value_7,
                         rcd_sales_fact.sales_dtl_price_value_8,
                         rcd_sales_fact.sales_dtl_price_value_9,
                         rcd_sales_fact.sales_dtl_price_value_10,
                         rcd_sales_fact.sales_dtl_price_value_11,
                         rcd_sales_fact.sales_dtl_price_value_12,
                         rcd_sales_fact.sales_dtl_price_value_13,
                         rcd_sales_fact.sales_dtl_price_value_14,
                         rcd_sales_fact.sales_dtl_price_value_15,
                         rcd_sales_fact.sales_dtl_price_value_16,
                         rcd_sales_fact.sales_dtl_price_value_17,
                         rcd_sales_fact.sales_dtl_price_value_18,
                         rcd_sales_fact.sales_dtl_price_value_19,
                         rcd_sales_fact.sales_dtl_price_value_20,
                         rcd_sales_fact.sales_dtl_price_value_21,
                         rcd_sales_fact.sales_dtl_price_value_22,
                         rcd_sales_fact.sales_dtl_price_value_23);

            end if;

         end loop;
         close csr_lads_inv_gen;

      end loop;
      close csr_lads_inv_hdr;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_FACT Load');

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
            lics_logging.write_log('**ERROR** - SALES_FACT Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_FACT Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_fact_load;

   /**********************************************************************/
   /* This procedure performs the sales day month 01 aggregation routine */
   /**********************************************************************/
   procedure sales_day_month_01_aggregation(par_yyyyppdd in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.billing_yyyyppdd as billing_yyyyppdd
           from sales_fact t1
          where t1.sap_company_code = par_company
            and (t1.billing_yyyyppdd = par_yyyyppdd or
                 par_yyyyppdd = 99999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_DAY_MONTH_01_FACT Aggregation - Parameters(' || to_char(par_yyyyppdd) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate/delete the required data
      /* **notes**
      /* 1. Day with data may not have new data so will always be truncated/deleted
      /* 2. par_yyyyppdd = 999999 truncates all data
      /*-*/
      if par_yyyyppdd = 99999999 then
         lics_logging.write_log('SALES_DAY_MONTH_01_FACT Aggregation - Truncating the table');
         delete from sales_day_month_01_fact
            where sap_company_code = par_company;
      else
         lics_logging.write_log('SALES_DAY_MONTH_01_FACT Aggregation - Deleting the data - Day(' || to_char(par_yyyyppdd) || ')');
         delete from sales_day_month_01_fact
            where billing_yyyyppdd = par_yyyyppdd
              and sap_company_code = par_company;
      end if;

      /*-*/
      /* Perform the aggregation by day
      /* **notes**
      /* 1. Days are aggregated based on source data
      /* 2. par_yyyyppdd = 99999999 aggregates all days
      /*-*/
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            exit;
         end if;

         /*-*/
         /* Build the data for the current day
         /*-*/
         lics_logging.write_log('SALES_DAY_MONTH_01_FACT Aggregation - Building the data - Day(' || to_char(rcd_source.billing_yyyyppdd) || ')');
         insert into sales_day_month_01_fact
            (sap_order_type_code,
             sap_invc_type_code,
             billing_date,
             billing_yyyyppdd,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   min(t1.billing_date),
                   t1.billing_yyyyppdd,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_fact t1
             where t1.billing_yyyyppdd = rcd_source.billing_yyyyppdd
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.billing_yyyyppdd,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_DAY_MONTH_01_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_DAY_MONTH_01_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_DAY_MONTH_01_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_day_month_01_aggregation;

   /**********************************************************************/
   /* This procedure performs the sales day month 02 aggregation routine */
   /**********************************************************************/
   procedure sales_day_month_02_aggregation(par_yyyyppdd in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.sap_billing_yyyyppdd as sap_billing_yyyyppdd
           from sales_fact t1
          where t1.sap_company_code = par_company
            and (t1.sap_billing_yyyyppdd = par_yyyyppdd or
                 par_yyyyppdd = 99999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_DAY_MONTH_02_FACT Aggregation - Parameters(' || to_char(par_yyyyppdd) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate/delete the required data
      /* **notes**
      /* 1. Day with data may not have new data so will always be truncated/deleted
      /* 2. par_yyyyppdd = 999999 truncates all data
      /*-*/
      if par_yyyyppdd = 99999999 then
         lics_logging.write_log('SALES_DAY_MONTH_02_FACT Aggregation - Truncating the table');
         delete from sales_day_month_02_fact
            where sap_company_code = par_company;
      else
         lics_logging.write_log('SALES_DAY_MONTH_02_FACT Aggregation - Deleting the data - Day(' || to_char(par_yyyyppdd) || ')');
         delete from sales_day_month_02_fact
            where sap_billing_yyyyppdd = par_yyyyppdd
              and sap_company_code = par_company;
      end if;

      /*-*/
      /* Perform the aggregation by day
      /* **notes**
      /* 1. Days are aggregated based on source data
      /* 2. par_yyyyppdd = 99999999 aggregates all days
      /*-*/
      open csr_source;
      loop
         fetch csr_source into rcd_source;
         if csr_source%notfound then
            exit;
         end if;

         /*-*/
         /* Build the data for the current day
         /*-*/
         lics_logging.write_log('SALES_DAY_MONTH_02_FACT Aggregation - Building the data - Day(' || to_char(rcd_source.sap_billing_yyyyppdd) || ')');
         insert into sales_day_month_02_fact
            (sap_order_type_code,
             sap_invc_type_code,
             sap_billing_date,
             sap_billing_yyyyppdd,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   min(t1.sap_billing_date),
                   t1.sap_billing_yyyyppdd,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_fact t1
             where t1.sap_billing_yyyyppdd = rcd_source.sap_billing_yyyyppdd
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.sap_billing_yyyyppdd,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_DAY_MONTH_02_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_DAY_MONTH_02_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_DAY_MONTH_02_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_day_month_02_aggregation;

   /******************************************************************/
   /* This procedure performs the sales month 01 aggregation routine */
   /******************************************************************/
   procedure sales_month_01_aggregation(par_yyyymm in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.billing_yyyymm as billing_yyyymm
           from sales_fact t1
          where t1.sap_company_code = par_company
            and (t1.billing_yyyymm = par_yyyymm or
                 par_yyyymm = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_MONTH_01_FACT Aggregation - Parameters(' || to_char(par_yyyymm) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyymm = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_MONTH_01_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_month_01_fact',par_yyyymm,par_company,'m');

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
         lics_logging.write_log('SALES_MONTH_01_FACT Aggregation - Check/create partition - Month(' || to_char(rcd_source.billing_yyyymm) || ')');
         dd_partition.check_create('sales_month_01_fact',rcd_source.billing_yyyymm,par_company,'m');

         /*-*/
         /* Build the partition for the current month 
         /*-*/
         lics_logging.write_log('SALES_MONTH_01_FACT Aggregation - Building the partition - Month(' || to_char(rcd_source.billing_yyyymm) || ')');
         insert into sales_month_01_fact
            (sap_order_type_code,
             sap_invc_type_code,
             billing_yyyymm,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_material_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.billing_yyyymm,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_material_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_fact t1
             where t1.billing_yyyymm = rcd_source.billing_yyyymm
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.billing_yyyymm,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_material_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_MONTH_01_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_MONTH_01_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_MONTH_01_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_month_01_aggregation;

   /******************************************************************/
   /* This procedure performs the sales month 02 aggregation routine */
   /******************************************************************/
   procedure sales_month_02_aggregation(par_yyyymm in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.billing_yyyymm as billing_yyyymm
           from sales_month_01_fact t1
          where t1.sap_company_code = par_company
            and (t1.billing_yyyymm = par_yyyymm or
                 par_yyyymm = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_MONTH_02_FACT Aggregation - Parameters(' || to_char(par_yyyymm) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyymm = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_MONTH_02_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_month_02_fact',par_yyyymm,par_company,'m');

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
         lics_logging.write_log('SALES_MONTH_02_FACT Aggregation - Check/create partition - Month(' || to_char(rcd_source.billing_yyyymm) || ')');
         dd_partition.check_create('sales_month_02_fact',rcd_source.billing_yyyymm,par_company,'m');

         /*-*/
         /* Build the partition for the current month 
         /*-*/
         lics_logging.write_log('SALES_MONTH_02_FACT Aggregation - Building the partition - Month(' || to_char(rcd_source.billing_yyyymm) || ')');
         insert into sales_month_02_fact
            (sap_order_type_code,
             sap_invc_type_code,
             billing_yyyymm,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.billing_yyyymm,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_month_01_fact t1
             where t1.billing_yyyymm = rcd_source.billing_yyyymm
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.billing_yyyymm,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_MONTH_02_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_MONTH_02_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_MONTH_02_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_month_02_aggregation;

   /******************************************************************/
   /* This procedure performs the sales month 03 aggregation routine */
   /******************************************************************/
   procedure sales_month_03_aggregation(par_yyyymm in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.billing_yyyymm as billing_yyyymm
           from sales_month_01_fact t1
          where t1.sap_company_code = par_company
            and (t1.billing_yyyymm = par_yyyymm or
                 par_yyyymm = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_MONTH_03_FACT Aggregation - Parameters(' || to_char(par_yyyymm) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyymm = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_MONTH_03_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_month_03_fact',par_yyyymm,par_company,'m');

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
         lics_logging.write_log('SALES_MONTH_03_FACT Aggregation - Check/create partition - Month(' || to_char(rcd_source.billing_yyyymm) || ')');
         dd_partition.check_create('sales_month_03_fact',rcd_source.billing_yyyymm,par_company,'m');

         /*-*/
         /* Build the partition for the current month 
         /*-*/
         lics_logging.write_log('SALES_MONTH_03_FACT Aggregation - Building the partition - Month(' || to_char(rcd_source.billing_yyyymm) || ')');
         insert into sales_month_03_fact
            (sap_order_type_code,
             sap_invc_type_code,
             billing_yyyymm,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_brand_flag_code,
             sap_brand_sub_flag_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.billing_yyyymm,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t3.sap_brand_flag_code,
                   t4.sap_brand_sub_flag_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_month_01_fact t1,
                   material t2,
                   brand_flag t3,
                   brand_sub_flag t4
             where t1.sap_material_code = t2.sap_material_code
               and t2.sap_brand_flag_code = t3.sap_brand_flag_code(+)
               and t2.sap_brand_sub_flag_code = t4.sap_brand_sub_flag_code(+)
               and t1.billing_yyyymm = rcd_source.billing_yyyymm
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.billing_yyyymm,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t3.sap_brand_flag_code,
                      t4.sap_brand_sub_flag_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_MONTH_03_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_MONTH_03_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_MONTH_03_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_month_03_aggregation;

   /******************************************************************/
   /* This procedure performs the sales month 04 aggregation routine */
   /******************************************************************/
   procedure sales_month_04_aggregation(par_yyyymm in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.sap_billing_yyyymm as sap_billing_yyyymm
           from sales_fact t1
          where t1.sap_company_code = par_company
            and (t1.sap_billing_yyyymm = par_yyyymm or
                 par_yyyymm = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_MONTH_04_FACT Aggregation - Parameters(' || to_char(par_yyyymm) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyymm = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_MONTH_04_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_month_04_fact',par_yyyymm,par_company,'m');

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
         lics_logging.write_log('SALES_MONTH_04_FACT Aggregation - Check/create partition - Month(' || to_char(rcd_source.sap_billing_yyyymm) || ')');
         dd_partition.check_create('sales_month_04_fact',rcd_source.sap_billing_yyyymm,par_company,'m');

         /*-*/
         /* Build the partition for the current month 
         /*-*/
         lics_logging.write_log('SALES_MONTH_04_FACT Aggregation - Building the partition - Month(' || to_char(rcd_source.sap_billing_yyyymm) || ')');
         insert into sales_month_04_fact
            (sap_order_type_code,
             sap_invc_type_code,
             sap_billing_yyyymm,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_material_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.sap_billing_yyyymm,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_material_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_fact t1
             where t1.sap_billing_yyyymm = rcd_source.sap_billing_yyyymm
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.sap_billing_yyyymm,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_material_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_MONTH_04_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_MONTH_04_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_MONTH_04_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_month_04_aggregation;

   /******************************************************************/
   /* This procedure performs the sales month 05 aggregation routine */
   /******************************************************************/
   procedure sales_month_05_aggregation(par_yyyymm in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.sap_billing_yyyymm as sap_billing_yyyymm
           from sales_month_04_fact t1
          where t1.sap_company_code = par_company
            and (t1.sap_billing_yyyymm = par_yyyymm or
                 par_yyyymm = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_MONTH_05_FACT Aggregation - Parameters(' || to_char(par_yyyymm) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyymm = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_MONTH_05_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_month_05_fact',par_yyyymm,par_company,'m');

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
         lics_logging.write_log('SALES_MONTH_05_FACT Aggregation - Check/create partition - Month(' || to_char(rcd_source.sap_billing_yyyymm) || ')');
         dd_partition.check_create('sales_month_05_fact',rcd_source.sap_billing_yyyymm,par_company,'m');

         /*-*/
         /* Build the partition for the current month 
         /*-*/
         lics_logging.write_log('SALES_MONTH_05_FACT Aggregation - Building the partition - Month(' || to_char(rcd_source.sap_billing_yyyymm) || ')');
         insert into sales_month_05_fact
            (sap_order_type_code,
             sap_invc_type_code,
             sap_billing_yyyymm,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.sap_billing_yyyymm,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_month_04_fact t1
             where t1.sap_billing_yyyymm = rcd_source.sap_billing_yyyymm
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.sap_billing_yyyymm,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_MONTH_05_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_MONTH_05_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_MONTH_05_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_month_05_aggregation;

   /******************************************************************/
   /* This procedure performs the sales month 06 aggregation routine */
   /******************************************************************/
   procedure sales_month_06_aggregation(par_yyyymm in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.sap_billing_yyyymm as sap_billing_yyyymm
           from sales_month_04_fact t1
          where t1.sap_company_code = par_company
            and (t1.sap_billing_yyyymm = par_yyyymm or
                 par_yyyymm = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_MONTH_06_FACT Aggregation - Parameters(' || to_char(par_yyyymm) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyymm = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_MONTH_06_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_month_06_fact',par_yyyymm,par_company,'m');

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
         lics_logging.write_log('SALES_MONTH_06_FACT Aggregation - Check/create partition - Month(' || to_char(rcd_source.sap_billing_yyyymm) || ')');
         dd_partition.check_create('sales_month_06_fact',rcd_source.sap_billing_yyyymm,par_company,'m');

         /*-*/
         /* Build the partition for the current month 
         /*-*/
         lics_logging.write_log('SALES_MONTH_06_FACT Aggregation - Building the partition - Month(' || to_char(rcd_source.sap_billing_yyyymm) || ')');
         insert into sales_month_06_fact
            (sap_order_type_code,
             sap_invc_type_code,
             sap_billing_yyyymm,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_brand_flag_code,
             sap_brand_sub_flag_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.sap_billing_yyyymm,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t3.sap_brand_flag_code,
                   t4.sap_brand_sub_flag_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_month_04_fact t1,
                   material t2,
                   brand_flag t3,
                   brand_sub_flag t4
             where t1.sap_material_code = t2.sap_material_code
               and t2.sap_brand_flag_code = t3.sap_brand_flag_code(+)
               and t2.sap_brand_sub_flag_code = t4.sap_brand_sub_flag_code(+)
               and t1.sap_billing_yyyymm = rcd_source.sap_billing_yyyymm
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.sap_billing_yyyymm,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t3.sap_brand_flag_code,
                      t4.sap_brand_sub_flag_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_MONTH_06_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_MONTH_06_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_MONTH_06_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_month_06_aggregation;

   /*******************************************************************/
   /* This procedure performs the sales period 01 aggregation routine */
   /*******************************************************************/
   procedure sales_period_01_aggregation(par_yyyypp in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.billing_yyyypp as billing_yyyypp
           from sales_fact t1
          where t1.sap_company_code = par_company
            and (t1.billing_yyyypp = par_yyyypp or
                 par_yyyypp = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_PERIOD_01_FACT Aggregation - Parameters(' || to_char(par_yyyypp) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyypp = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_PERIOD_01_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_period_01_fact',par_yyyypp,par_company,'p');

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
         lics_logging.write_log('SALES_PERIOD_01_FACT Aggregation - Check/create partition - Period(' || to_char(rcd_source.billing_yyyypp) || ')');
         dd_partition.check_create('sales_period_01_fact',rcd_source.billing_yyyypp,par_company,'p');

         /*-*/
         /* Build the partition for the current period
         /*-*/
         lics_logging.write_log('SALES_PERIOD_01_FACT Aggregation - Building the partition - Period(' || to_char(rcd_source.billing_yyyypp) || ')');
         insert into sales_period_01_fact
            (sap_order_type_code,
             sap_invc_type_code,
             billing_yyyypp,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_material_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.billing_yyyypp,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_material_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_fact t1
             where t1.billing_yyyypp = rcd_source.billing_yyyypp
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.billing_yyyypp,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_material_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_PERIOD_01_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_PERIOD_01_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_PERIOD_01_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_period_01_aggregation;

   /*******************************************************************/
   /* This procedure performs the sales period 02 aggregation routine */
   /*******************************************************************/
   procedure sales_period_02_aggregation(par_yyyypp in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.billing_yyyypp as billing_yyyypp
           from sales_period_01_fact t1
          where t1.sap_company_code = par_company
            and (t1.billing_yyyypp = par_yyyypp or
                 par_yyyypp = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_PERIOD_02_FACT Aggregation - Parameters(' || to_char(par_yyyypp) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyypp = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_PERIOD_02_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_period_02_fact',par_yyyypp,par_company,'p');

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
         lics_logging.write_log('SALES_PERIOD_02_FACT Aggregation - Check/create partition - Period(' || to_char(rcd_source.billing_yyyypp) || ')');
         dd_partition.check_create('sales_period_02_fact',rcd_source.billing_yyyypp,par_company,'p');

         /*-*/
         /* Build the partition for the current period
         /*-*/
         lics_logging.write_log('SALES_PERIOD_02_FACT Aggregation - Building the partition - Period(' || to_char(rcd_source.billing_yyyypp) || ')');
         insert into sales_period_02_fact
            (sap_order_type_code,
             sap_invc_type_code,
             billing_yyyypp,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_mkt_sgmnt_code,
             sap_brand_flag_code,
             sap_brand_sub_flag_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.billing_yyyypp,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t3.sap_mkt_sgmnt_code,
                   t4.sap_brand_flag_code,
                   t5.sap_brand_sub_flag_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_period_01_fact t1,
                   material t2,
                   mkt_sgmnt t3,
                   brand_flag t4,
                   brand_sub_flag t5
             where t1.sap_material_code = t2.sap_material_code
               and t2.sap_mkt_sgmnt_code = t3.sap_mkt_sgmnt_code(+)
               and t2.sap_brand_flag_code = t4.sap_brand_flag_code(+)
               and t2.sap_brand_sub_flag_code = t5.sap_brand_sub_flag_code(+)
               and t1.billing_yyyypp = rcd_source.billing_yyyypp
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.billing_yyyypp,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t3.sap_mkt_sgmnt_code,
                      t4.sap_brand_flag_code,
                      t5.sap_brand_sub_flag_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_PERIOD_02_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_PERIOD_02_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_PERIOD_02_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_period_02_aggregation;

   /*******************************************************************/
   /* This procedure performs the sales period 03 aggregation routine */
   /*******************************************************************/
   procedure sales_period_03_aggregation(par_yyyypp in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.sap_billing_yyyypp as sap_billing_yyyypp
           from sales_fact t1
          where t1.sap_company_code = par_company
            and (t1.sap_billing_yyyypp = par_yyyypp or
                 par_yyyypp = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_PERIOD_03_FACT Aggregation - Parameters(' || to_char(par_yyyypp) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyypp = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_PERIOD_03_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_period_03_fact',par_yyyypp,par_company,'p');

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
         lics_logging.write_log('SALES_PERIOD_03_FACT Aggregation - Check/create partition - Period(' || to_char(rcd_source.sap_billing_yyyypp) || ')');
         dd_partition.check_create('sales_period_03_fact',rcd_source.sap_billing_yyyypp,par_company,'p');

         /*-*/
         /* Build the partition for the current period
         /*-*/
         lics_logging.write_log('SALES_PERIOD_03_FACT Aggregation - Building the partition - Period(' || to_char(rcd_source.sap_billing_yyyypp) || ')');
         insert into sales_period_03_fact
            (sap_order_type_code,
             sap_invc_type_code,
             sap_billing_yyyypp,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_material_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.sap_billing_yyyypp,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t1.sap_material_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_fact t1
             where t1.sap_billing_yyyypp = rcd_source.sap_billing_yyyypp
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.sap_billing_yyyypp,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t1.sap_material_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_PERIOD_03_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_PERIOD_03_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_PERIOD_03_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_period_03_aggregation;

   /*******************************************************************/
   /* This procedure performs the sales period 04 aggregation routine */
   /*******************************************************************/
   procedure sales_period_04_aggregation(par_yyyypp in number, par_company in varchar2) is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_source is
         select distinct t1.sap_billing_yyyypp as sap_billing_yyyypp
           from sales_period_03_fact t1
          where t1.sap_company_code = par_company
            and (t1.sap_billing_yyyypp = par_yyyypp or
                 par_yyyypp = 999999);
      rcd_source csr_source%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SALES_PERIOD_04_FACT Aggregation - Parameters(' || to_char(par_yyyypp) || ' + ' || par_company || ')');

      /*-*/
      /* Truncate the required partitions
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /* 2. par_yyyypp = 999999 truncates all partitions
      /*-*/
      lics_logging.write_log('SALES_PERIOD_04_FACT Aggregation - Truncating the partition(s)');
      dd_partition.truncate('sales_period_04_fact',par_yyyypp,par_company,'p');

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
         lics_logging.write_log('SALES_PERIOD_04_FACT Aggregation - Check/create partition - Period(' || to_char(rcd_source.sap_billing_yyyypp) || ')');
         dd_partition.check_create('sales_period_04_fact',rcd_source.sap_billing_yyyypp,par_company,'p');

         /*-*/
         /* Build the partition for the current period
         /*-*/
         lics_logging.write_log('SALES_PERIOD_04_FACT Aggregation - Building the partition - Period(' || to_char(rcd_source.sap_billing_yyyypp) || ')');
         insert into sales_period_04_fact
            (sap_order_type_code,
             sap_invc_type_code,
             sap_billing_yyyypp,
             sap_company_code,
             sap_sales_hdr_sales_org_code,
             sap_sales_hdr_distbn_chnl_code,
             sap_sales_hdr_division_code,
             sap_doc_currcy_code,
             sap_order_reasn_code,
             sap_sold_to_cust_code,
             sap_bill_to_cust_code,
             sap_payer_cust_code,
             sap_secondary_ws_cust_code,
             sap_tertiary_ws_cust_code,
             sap_pmt_path_pri_ws_cust_code,
             sap_pmt_path_sec_ws_cust_code,
             sap_pmt_path_ter_ws_cust_code,
             sap_pmt_path_ret_cust_code,
             sap_sales_force_hier_cust_code,
             base_uom_billed_qty,
             pieces_billed_qty,
             tonnes_billed_qty,
             sap_ship_to_cust_code,
             sap_mkt_sgmnt_code,
             sap_brand_flag_code,
             sap_brand_sub_flag_code,
             sap_plant_code,
             sap_storage_locn_code,
             sap_material_division_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_order_usage_code,
             sales_dtl_price_value_1,
             sales_dtl_price_value_2,
             sales_dtl_price_value_3,
             sales_dtl_price_value_4,
             sales_dtl_price_value_5,
             sales_dtl_price_value_6,
             sales_dtl_price_value_7,
             sales_dtl_price_value_8,
             sales_dtl_price_value_9,
             sales_dtl_price_value_10,
             sales_dtl_price_value_11,
             sales_dtl_price_value_12,
             sales_dtl_price_value_13,
             sales_dtl_price_value_14,
             sales_dtl_price_value_15,
             sales_dtl_price_value_16,
             sales_dtl_price_value_17,
             sales_dtl_price_value_18,
             sales_dtl_price_value_19,
             sales_dtl_price_value_20,
             sales_dtl_price_value_21,
             sales_dtl_price_value_22,
             sales_dtl_price_value_23)
            select t1.sap_order_type_code,
                   t1.sap_invc_type_code,
                   t1.sap_billing_yyyypp,
                   t1.sap_company_code,
                   t1.sap_sales_hdr_sales_org_code,
                   t1.sap_sales_hdr_distbn_chnl_code,
                   t1.sap_sales_hdr_division_code,
                   t1.sap_doc_currcy_code,
                   t1.sap_order_reasn_code,
                   t1.sap_sold_to_cust_code,
                   t1.sap_bill_to_cust_code,
                   t1.sap_payer_cust_code,
                   t1.sap_secondary_ws_cust_code,
                   t1.sap_tertiary_ws_cust_code,
                   t1.sap_pmt_path_pri_ws_cust_code,
                   t1.sap_pmt_path_sec_ws_cust_code,
                   t1.sap_pmt_path_ter_ws_cust_code,
                   t1.sap_pmt_path_ret_cust_code,
                   t1.sap_sales_force_hier_cust_code,
                   sum(t1.base_uom_billed_qty),
                   sum(t1.pieces_billed_qty),
                   sum(t1.tonnes_billed_qty),
                   t1.sap_ship_to_cust_code,
                   t3.sap_mkt_sgmnt_code,
                   t4.sap_brand_flag_code,
                   t5.sap_brand_sub_flag_code,
                   t1.sap_plant_code,
                   t1.sap_storage_locn_code,
                   t1.sap_material_division_code,
                   t1.sap_sales_dtl_sales_org_code,
                   t1.sap_sales_dtl_distbn_chnl_code,
                   t1.sap_sales_dtl_division_code,
                   t1.sap_order_usage_code,
                   sum(t1.sales_dtl_price_value_1),
                   sum(t1.sales_dtl_price_value_2),
                   sum(t1.sales_dtl_price_value_3),
                   sum(t1.sales_dtl_price_value_4),
                   sum(t1.sales_dtl_price_value_5),
                   sum(t1.sales_dtl_price_value_6),
                   sum(t1.sales_dtl_price_value_7),
                   sum(t1.sales_dtl_price_value_8),
                   sum(t1.sales_dtl_price_value_9),
                   sum(t1.sales_dtl_price_value_10),
                   sum(t1.sales_dtl_price_value_11),
                   sum(t1.sales_dtl_price_value_12),
                   sum(t1.sales_dtl_price_value_13),
                   sum(t1.sales_dtl_price_value_14),
                   sum(t1.sales_dtl_price_value_15),
                   sum(t1.sales_dtl_price_value_16),
                   sum(t1.sales_dtl_price_value_17),
                   sum(t1.sales_dtl_price_value_18),
                   sum(t1.sales_dtl_price_value_19),
                   sum(t1.sales_dtl_price_value_20),
                   sum(t1.sales_dtl_price_value_21),
                   sum(t1.sales_dtl_price_value_22),
                   sum(t1.sales_dtl_price_value_23)
              from sales_period_03_fact t1,
                   material t2,
                   mkt_sgmnt t3,
                   brand_flag t4,
                   brand_sub_flag t5
             where t1.sap_material_code = t2.sap_material_code
               and t2.sap_mkt_sgmnt_code = t3.sap_mkt_sgmnt_code(+)
               and t2.sap_brand_flag_code = t4.sap_brand_flag_code(+)
               and t2.sap_brand_sub_flag_code = t5.sap_brand_sub_flag_code(+)
               and t1.sap_billing_yyyypp = rcd_source.sap_billing_yyyypp
               and t1.sap_company_code = par_company
             group by t1.sap_order_type_code,
                      t1.sap_invc_type_code,
                      t1.sap_billing_yyyypp,
                      t1.sap_company_code,
                      t1.sap_sales_hdr_sales_org_code,
                      t1.sap_sales_hdr_distbn_chnl_code,
                      t1.sap_sales_hdr_division_code,
                      t1.sap_doc_currcy_code,
                      t1.sap_order_reasn_code,
                      t1.sap_sold_to_cust_code,
                      t1.sap_bill_to_cust_code,
                      t1.sap_payer_cust_code,
                      t1.sap_secondary_ws_cust_code,
                      t1.sap_tertiary_ws_cust_code,
                      t1.sap_pmt_path_pri_ws_cust_code,
                      t1.sap_pmt_path_sec_ws_cust_code,
                      t1.sap_pmt_path_ter_ws_cust_code,
                      t1.sap_pmt_path_ret_cust_code,
                      t1.sap_sales_force_hier_cust_code,
                      t1.sap_ship_to_cust_code,
                      t3.sap_mkt_sgmnt_code,
                      t4.sap_brand_flag_code,
                      t5.sap_brand_sub_flag_code,
                      t1.sap_plant_code,
                      t1.sap_storage_locn_code,
                      t1.sap_material_division_code,
                      t1.sap_sales_dtl_sales_org_code,
                      t1.sap_sales_dtl_distbn_chnl_code,
                      t1.sap_sales_dtl_division_code,
                      t1.sap_order_usage_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_source;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SALES_PERIOD_04_FACT Aggregation');

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
            lics_logging.write_log('**ERROR** - SALES_PERIOD_04_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - SALES_PERIOD_04_FACT Aggregation');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end sales_period_04_aggregation;

end dw_sales_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_sales_aggregation for dw_app.dw_sales_aggregation;
grant execute on dw_sales_aggregation to public;
