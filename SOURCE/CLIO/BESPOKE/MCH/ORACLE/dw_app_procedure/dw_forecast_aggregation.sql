/******************/
/* Package Header */
/******************/
create or replace package dw_forecast_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_forecast_aggregation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Aggregation

    This package contain the aggregation procedures for forecast data.
    The package exposes one procedure EXECUTE that performs the aggregation based on
    the following parameters.

    1. PAR_ACTION (*DATE, *REBUILD) (MANDATORY)

       *DATE aggregates the requested fact table(s) from the operational data store
       for a particular date. *REBUILD replaces the requested fact table(s) with the
       aggregated data from the operational data store.

    2. PAR_TABLE (*ALL, 'table name') (MANDATORY)

       *ALL performs the aggregation for all fact tables. A table name performs the
       aggregation for the requested fact table.

    **notes**
    1. Allows progressive aggregation based on the requested month/period where
       each casting month/period replaces the future months/periods.
       (ie. month 200502 uses casting month 200501 and aggregates 200502 onwards).

    2. Allows the current month/period forecasts to be aggregated.

    3. A web log is produced under the search value DW_FORECAST_AGGREGATION where all errors are logged.

    4. All errors will raise an exception to the calling application so that an alert can
       be raised.

    5. All requested fact tables will attempt to be aggregated and and errors logged.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/01   Steve Gregan   Created
    2005/09   Steve Gregan   Changed forecast selection to ignore current and future casting periods
    2006/04   Steve Gregan   Changed le (latest estimate) to rb (review of business) for Hong Kong

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_table in varchar2);

end dw_forecast_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_forecast_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure forecast_month_01_aggregation(par_yyyymm in number);
   procedure forecast_month_02_aggregation(par_yyyymm in number);
   procedure forecast_period_01_aggregation(par_yyyypp in number);
   procedure forecast_period_02_aggregation(par_yyyypp in number);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_table in varchar2) is

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
      var_date date;
      var_yyyypp number(6,0);
      var_yyyymm number(6,0);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Forecast Aggregation';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'FCST_AGGREGATION';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'FCST_AGGREGATION';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_mars_date is
         select t1.mars_period,
                t1.year_num,
                t1.month_num
           from mars_date t1
          where trunc(t1.calendar_date) = trunc(sysdate);
      rcd_mars_date csr_mars_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_FORECAST_AGGREGATION';
      var_log_search := 'DW_FORECAST_AGGREGATION';
      var_loc_string := 'DW_FORECAST_AGGREGATION';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*DATE' and upper(par_action) != '*REBUILD' then
         raise_application_error(-20000, 'Action parameter must be *DATE or *REBUILD');
      end if;
      if upper(par_table) != '*ALL' and
         upper(par_table) != 'FCST_MONTH_01_FACT' and
         upper(par_table) != 'FCST_MONTH_02_FACT' and
         upper(par_table) != 'FCST_PERIOD_01_FACT' and
         upper(par_table) != 'FCST_PERIOD_02_FACT' then
         raise_application_error(-20000, 'Table parameter must be *ALL or ' ||
                                         'FCST_MONTH_01_FACT, ' ||
                                         'FCST_MONTH_02_FACT, ' ||
                                         'FCST_PERIOD_01_FACT, ' ||
                                         'FCST_PERIOD_02_FACT');
      end if;

      /*-*/
      /* Set the time variables based on the parameters
      /*-*/
      if upper(par_action) = '*REBUILD' then
         var_yyyypp := 999999;
         var_yyyymm := 999999;
      else
         open csr_mars_date;
         fetch csr_mars_date into rcd_mars_date;
         if csr_mars_date%notfound then
            raise_application_error(-20000, 'Date ' || to_char(sysdate,'yyyy/mm/dd hh24:mi:ss') || ' not found in MARS_DATE');
         end if;
         close csr_mars_date;
         var_yyyypp := rcd_mars_date.mars_period;
         var_yyyymm := (rcd_mars_date.year_num * 100) + rcd_mars_date.month_num;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Forecast Aggregation - Parameters(' || upper(par_action) || ' + ' || upper(par_table) || ')');

      /*-*/
      /* Request the lock on the forecast aggregation
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
         /* Execute the aggregation procedures as required
         /* **note** 1. Dependancy as follows
         /*
         /*             fcst_month
         /*                ==> forecast_month_01_aggregation
         /*                ==> forecast_month_02_aggregation
         /*             fcst_period
         /*                ==> forecast_period_01_aggregation
         /*                ==> forecast_period_02_aggregation
         /*
         /*          2. Processed (level) as follows
         /*
         /*             fcst_month
         /*                ==> forecast_month_01_aggregation
         /*                ==> forecast_month_02_aggregation
         /*             fcst_period
         /*                ==> forecast_period_01_aggregation
         /*                ==> forecast_period_02_aggregation
         /*
         /*          3. fcst_month and fcst_period are NOT part
         /*             of the aggregation process
         /*
         /*-*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'FCST_MONTH_01_FACT' then
            begin
               forecast_month_01_aggregation(var_yyyymm);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'FCST_MONTH_02_FACT' then
            begin
               forecast_month_02_aggregation(var_yyyymm);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'FCST_PERIOD_01_FACT' then
            begin
               forecast_period_01_aggregation(var_yyyypp);
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_table) = '*ALL' or upper(par_table) = 'FCST_PERIOD_02_FACT' then
            begin
               forecast_period_02_aggregation(var_yyyypp);
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Release the lock on the forecast aggregation
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Forecast Aggregation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(lads_parameter.system_code,
                                         lads_parameter.system_unit,
                                         lads_parameter.system_environment,
                                         con_function,
                                         'DW_FORECAST_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Forecast Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
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
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock on the forecast aggregation
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_AGGREGATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*********************************************************************/
   /* This procedure performs the forecast month 01 aggregation routine */
   /*********************************************************************/
   procedure forecast_month_01_aggregation(par_yyyymm in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_previous_month number(6,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_month is
         select distinct t01.casting_yyyymm as casting_yyyymm
           from fcst_month t01
          where ((par_yyyymm = 999999) or
                 (par_yyyymm != 999999 and t01.casting_yyyymm = var_previous_month))
          order by t01.casting_yyyymm;
      rcd_fcst_month csr_fcst_month%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FCST_MONTH_01_FACT Aggregation - Parameter(' || to_char(par_yyyymm) || ')');

      /*-*/
      /* Calculate the previous month as required
      /* **notes** 1. rebuild - remove existing data
      /*-*/
      if par_yyyymm = 999999 then
         lics_logging.write_log('FCST_MONTH_01_FACT Aggregation - Truncating the table');
         dd_table.truncate('fcst_month_01_fact');
         var_previous_month := 0;
      else
         if mod(par_yyyymm, 100) = 1 then
            var_previous_month := trunc(par_yyyymm/100)*100;
         else
            var_previous_month := par_yyyymm - 1;
         end if;
      end if;

      /*-*/
      /* Retrieve the forecast month data
      /*-*/
      open csr_fcst_month;
      loop
         fetch csr_fcst_month into rcd_fcst_month;
         if csr_fcst_month%notfound then
            exit;
         end if;

         /*-*/
         /* Delete where the billing_yyyymm is greater than casting_yyyymm
         /*-*/
         lics_logging.write_log('FCST_MONTH_01_FACT Aggregation - Deleting the data - Casting month(' || to_char(rcd_fcst_month.casting_yyyymm) || ')');
         delete fcst_month_01_fact
            where billing_yyyymm > rcd_fcst_month.casting_yyyymm;

         /*-*/
         /* Insert into the forecast month fact table for each casting_yyyymm returned
         /*-*/
         lics_logging.write_log('FCST_MONTH_01_FACT Aggregation - Building the data - Casting month(' || to_char(rcd_fcst_month.casting_yyyymm) || ')');
         insert into fcst_month_01_fact
            (billing_yyyymm,
             sap_material_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_sales_div_cust_code,
             sap_sales_div_sales_org_code,
             sap_sales_div_distbn_chnl_code,
             sap_sales_div_division_code,
             br_base_price_value,
             br_gsv_value,
             br_qty,
             op_base_price_value,
             op_gsv_value,
             op_qty,
             rb_base_price_value,
             rb_gsv_value,
             rb_qty)
            select fcst_yyyymm,
                   sap_material_code,
                   sap_sales_dtl_sales_org_code,
                   sap_sales_dtl_distbn_chnl_code,
                   sap_sales_dtl_division_code,
                   sap_sales_div_cust_code,
                   sap_sales_div_sales_org_code,
                   sap_sales_div_distbn_chnl_code,
                   sap_sales_div_division_code,
                   sum(br_base_price_value),
                   sum(br_gsv_value),
                   sum(decode(br_base_price_qty,0,br_gsv_qty,br_base_price_qty)),
                   sum(op_base_price_value),
                   sum(op_gsv_value),
                   sum(decode(op_base_price_qty,0,op_gsv_qty,op_base_price_qty)),
                   sum(rb_base_price_value),
                   sum(rb_gsv_value),
                   sum(decode(rb_base_price_qty,0,rb_gsv_qty,rb_base_price_qty))
              from (select t01.fcst_yyyymm,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           t01.sap_sales_div_cust_code,
                           t01.sap_sales_div_sales_org_code,
                           t01.sap_sales_div_distbn_chnl_code,
                           t01.sap_sales_div_division_code,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,1,t01.fcst_value)),0)) as br_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,1,t01.fcst_value)),0)) as br_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,1,t01.fcst_qty)),0)) as br_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,1,t01.fcst_qty)),0)) as br_gsv_qty,
                           0 as op_base_price_value,
                           0 as op_gsv_value,
                           0 as op_base_price_qty,
                           0 as op_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,5,t01.fcst_value)),0)) as rb_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,5,t01.fcst_value)),0)) as rb_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,5,t01.fcst_qty)),0)) as rb_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,5,t01.fcst_qty)),0)) as rb_gsv_qty
                      from fcst_month t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code in (1,5)
                       and t03.fcst_price_type_code in (1,2)
                       and t01.sap_sales_div_cust_code is not null
                       and t01.casting_yyyymm = rcd_fcst_month.casting_yyyymm
                     group by t01.fcst_yyyymm,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code,
                              t01.sap_sales_div_cust_code,
                              t01.sap_sales_div_sales_org_code,
                              t01.sap_sales_div_distbn_chnl_code,
                              t01.sap_sales_div_division_code
                     union all
                    select t01.fcst_yyyymm,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           t01.sap_sales_div_cust_code,
                           t01.sap_sales_div_sales_org_code,
                           t01.sap_sales_div_distbn_chnl_code,
                           t01.sap_sales_div_division_code,
                           0 as br_base_price_value,
                           0 as br_gsv_value,
                           0 as br_base_price_qty,
                           0 as br_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,2,t01.fcst_value)),0)) as op_base_price_valUE,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,2,t01.fcst_value)),0)) as op_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,2,t01.fcst_qty)),0)) as op_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,2,t01.fcst_qty)),0)) as op_gsv_qty,
                           0 as rb_base_price_value,
                           0 as rb_gsv_value,
                           0 as rb_base_price_qty,
                           0 as rb_gsv_qty
                      from fcst_month t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code = 2
                       and t03.fcst_price_type_code in (1,2)
                       and t01.sap_sales_div_cust_code is not null
                       and t01.casting_yyyymm = trunc(rcd_fcst_month.casting_yyyymm/100)*100
                       and t01.fcst_yyyymm > rcd_fcst_month.casting_yyyymm
                     group by t01.fcst_yyyymm,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code,
                              t01.sap_sales_div_cust_code,
                              t01.sap_sales_div_sales_org_code,
                              t01.sap_sales_div_distbn_chnl_code,
                              t01.sap_sales_div_division_code)
             group by fcst_yyyymm,
                      sap_material_code,
                      sap_sales_dtl_sales_org_code,
                      sap_sales_dtl_distbn_chnl_code,
                      sap_sales_dtl_division_code,
                      sap_sales_div_cust_code,
                      sap_sales_div_sales_org_code,
                      sap_sales_div_distbn_chnl_code,
                      sap_sales_div_division_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_fcst_month;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - FCST_MONTH_01_FACT Aggregation');

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
         begin
            lics_logging.write_log('**ERROR** - FCST_MONTH_01_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - FCST_MONTH_01_FACT Aggregation');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end forecast_month_01_aggregation;

   /*********************************************************************/
   /* This procedure performs the forecast month 02 aggregation routine */
   /*********************************************************************/
   procedure forecast_month_02_aggregation(par_yyyymm in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_previous_month number(6,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_month is
         select distinct t01.casting_yyyymm as casting_yyyymm
           from fcst_month t01
          where ((par_yyyymm = 999999) or
                 (par_yyyymm != 999999 and t01.casting_yyyymm = var_previous_month))
          order by t01.casting_yyyymm;
      rcd_fcst_month csr_fcst_month%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FCST_MONTH_02_FACT Aggregation - Parameter(' || to_char(par_yyyymm) || ')');

      /*-*/
      /* Calculate the previous month as required
      /* **notes** 1. rebuild - remove existing data
      /*-*/
      if par_yyyymm = 999999 then
         lics_logging.write_log('FCST_MONTH_02_FACT Aggregation - Truncating the table');
         dd_table.truncate('fcst_month_02_fact');
         var_previous_month := 0;
      else
         if mod(par_yyyymm, 100) = 1 then
            var_previous_month := trunc(par_yyyymm/100)*100;
         else
            var_previous_month := par_yyyymm - 1;
         end if;
      end if;

      /*-*/
      /* Retrieve the forecast month data
      /*-*/
      open csr_fcst_month;
      loop
         fetch csr_fcst_month into rcd_fcst_month;
         if csr_fcst_month%notfound then
            exit;
         end if;

         /*-*/
         /* Delete where the billing_yyyymm is greater than casting_yyyymm
         /*-*/
         lics_logging.write_log('FCST_MONTH_02_FACT Aggregation - Deleting the data - Casting month(' || to_char(rcd_fcst_month.casting_yyyymm) || ')');
         delete fcst_month_02_fact
            where billing_yyyymm > rcd_fcst_month.casting_yyyymm;

         /*-*/
         /* Insert into the forecast month fact table for each casting_yyyymm returned
         /*-*/
         lics_logging.write_log('FCST_MONTH_02_FACT Aggregation - Building the data - Casting month(' || to_char(rcd_fcst_month.casting_yyyymm) || ')');
         insert into fcst_month_02_fact
            (billing_yyyymm,
             sap_material_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             br_base_price_value,
             br_gsv_value,
             br_qty,
             op_base_price_value,
             op_gsv_value,
             op_qty,
             rb_base_price_value,
             rb_gsv_value,
             rb_qty)
            select fcst_yyyymm,
                   sap_material_code,
                   sap_sales_dtl_sales_org_code,
                   sap_sales_dtl_distbn_chnl_code,
                   sap_sales_dtl_division_code,
                   sum(br_base_price_value),
                   sum(br_gsv_value),
                   sum(decode(br_base_price_qty,0,br_gsv_qty,br_base_price_qty)),
                   sum(op_base_price_value),
                   sum(op_gsv_value),
                   sum(decode(op_base_price_qty,0,op_gsv_qty,op_base_price_qty)),
                   sum(rb_base_price_value),
                   sum(rb_gsv_value),
                   sum(decode(rb_base_price_qty,0,rb_gsv_qty,rb_base_price_qty))
              from (select t01.fcst_yyyymm,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,1,t01.fcst_value)),0)) as br_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,1,t01.fcst_value)),0)) as br_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,1,t01.fcst_qty)),0)) as br_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,1,t01.fcst_qty)),0)) as br_gsv_qty,
                           0 as op_base_price_value,
                           0 as op_gsv_value,
                           0 as op_base_price_qty,
                           0 as op_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,5,t01.fcst_value)),0)) as rb_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,5,t01.fcst_value)),0)) as rb_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,5,t01.fcst_qty)),0)) as rb_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,5,t01.fcst_qty)),0)) as rb_gsv_qty
                      from fcst_month t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code in (1,5)
                       and t03.fcst_price_type_code in (1,2)
                       and t01.casting_yyyymm = rcd_fcst_month.casting_yyyymm
                     group by t01.fcst_yyyymm,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code
                     union all
                    select t01.fcst_yyyymm,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           0 as br_base_price_value,
                           0 as br_gsv_value,
                           0 as br_base_price_qty,
                           0 as br_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,2,t01.fcst_value)),0)) as op_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,2,t01.fcst_value)),0)) as op_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,2,t01.fcst_qty)),0)) as op_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,2,t01.fcst_qty)),0)) as op_gsv_qty,
                           0 as rb_base_price_value,
                           0 as rb_gsv_value,
                           0 as rb_base_price_qty,
                           0 as rb_gsv_qty
                      from fcst_month t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code = 2
                       and t03.fcst_price_type_code in (1,2)
                       and t01.casting_yyyymm = trunc(rcd_fcst_month.casting_yyyymm/100)*100
                       and t01.fcst_yyyymm > rcd_fcst_month.casting_yyyymm
                     group by t01.fcst_yyyymm,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code)
             group by fcst_yyyymm,
                      sap_material_code,
                      sap_sales_dtl_sales_org_code,
                      sap_sales_dtl_distbn_chnl_code,
                      sap_sales_dtl_division_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_fcst_month;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - FCST_MONTH_02_FACT Aggregation');

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
         begin
            lics_logging.write_log('**ERROR** - FCST_MONTH_02_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - FCST_MONTH_02_FACT Aggregation');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end forecast_month_02_aggregation;

   /**********************************************************************/
   /* This procedure performs the forecast period 01 aggregation routine */
   /**********************************************************************/
   procedure forecast_period_01_aggregation(par_yyyypp in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_previous_mars_period number(6,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_period is
         select distinct t01.casting_yyyypp as casting_yyyypp
           from fcst_period t01
          where ((par_yyyypp = 999999) or
                 (par_yyyypp != 999999 and t01.casting_yyyypp = var_previous_mars_period))
          order by t01.casting_yyyypp;
      rcd_fcst_period csr_fcst_period%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FCST_PERIOD_01_FACT Aggregation - Parameter(' || to_char(par_yyyypp) || ')');

      /*-*/
      /* Calculate the previous mars period as required
      /* **notes** 1. rebuild - remove existing data
      /*-*/
      if par_yyyypp = 999999 then
         lics_logging.write_log('FCST_PERIOD_01_FACT Aggregation - Truncating the table');
         dd_table.truncate('fcst_period_01_fact');
         var_previous_mars_period := 0;
      else
         if mod(par_yyyypp, 100) = 1 then
            var_previous_mars_period := trunc(par_yyyypp/100)*100;
         else
            var_previous_mars_period := par_yyyypp - 1;
         end if;
      end if;

      /*-*/
      /* Retrieve the forecast period data
      /*-*/
      open csr_fcst_period;
      loop
         fetch csr_fcst_period into rcd_fcst_period;
         if csr_fcst_period%notfound then
            exit;
         end if;

         /*-*/
         /* Delete where the billing_yyyypp is greater than casting_yyyypp
         /*-*/
         lics_logging.write_log('FCST_PERIOD_01_FACT Aggregation - Deleting the data - Casting period(' || to_char(rcd_fcst_period.casting_yyyypp) || ')');
         delete fcst_period_01_fact
            where billing_yyyypp > rcd_fcst_period.casting_yyyypp;

         /*-*/
         /* Insert into the forecast period fact table for each casting_yyyypp returned
         /*-*/
         lics_logging.write_log('FCST_PERIOD_01_FACT Aggregation - Building the data - Casting period(' || to_char(rcd_fcst_period.casting_yyyypp) || ')');
         insert into fcst_period_01_fact
            (billing_yyyypp,
             sap_material_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             sap_sales_div_cust_code,
             sap_sales_div_sales_org_code,
             sap_sales_div_distbn_chnl_code,
             sap_sales_div_division_code,
             br_base_price_value,
             br_gsv_value,
             br_qty,
             op_base_price_value,
             op_gsv_value,
             op_qty,
             rb_base_price_value,
             rb_gsv_value,
             rb_qty)
            select fcst_yyyypp,
                   sap_material_code,
                   sap_sales_dtl_sales_org_code,
                   sap_sales_dtl_distbn_chnl_code,
                   sap_sales_dtl_division_code,
                   sap_sales_div_cust_code,
                   sap_sales_div_sales_org_code,
                   sap_sales_div_distbn_chnl_code,
                   sap_sales_div_division_code,
                   sum(br_base_price_value),
                   sum(br_gsv_value),
                   sum(decode(br_base_price_qty,0,br_gsv_qty,br_base_price_qty)),
                   sum(op_base_price_value),
                   sum(op_gsv_value),
                   sum(decode(op_base_price_qty,0,op_gsv_qty,op_base_price_qty)),
                   sum(rb_base_price_value),
                   sum(rb_gsv_value),
                   sum(decode(rb_base_price_qty,0,rb_gsv_qty,rb_base_price_qty))
              from (select t01.fcst_yyyypp,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           t01.sap_sales_div_cust_code,
                           t01.sap_sales_div_sales_org_code,
                           t01.sap_sales_div_distbn_chnl_code,
                           t01.sap_sales_div_division_code,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,3,t01.fcst_value)),0)) as br_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,3,t01.fcst_value)),0)) as br_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,3,t01.fcst_qty)),0)) as br_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,3,t01.fcst_qty)),0)) as br_gsv_qty,
                           0 as op_base_price_value,
                           0 as op_gsv_value,
                           0 as op_base_price_qty,
                           0 as op_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,6,t01.fcst_value)),0)) as rb_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,6,t01.fcst_value)),0)) as rb_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,6,t01.fcst_qty)),0)) as rb_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,6,t01.fcst_qty)),0)) as rb_gsv_qty
                      from fcst_period t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code in (3,6)
                       and t03.fcst_price_type_code in (1,2)
                       and t01.sap_sales_div_cust_code is not null
                       and t01.casting_yyyypp = rcd_fcst_period.casting_yyyypp
                     group by t01.fcst_yyyypp,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code,
                              t01.sap_sales_div_cust_code,
                              t01.sap_sales_div_sales_org_code,
                              t01.sap_sales_div_distbn_chnl_code,
                              t01.sap_sales_div_division_code
                     union all
                    select t01.fcst_yyyypp,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           t01.sap_sales_div_cust_code,
                           t01.sap_sales_div_sales_org_code,
                           t01.sap_sales_div_distbn_chnl_code,
                           t01.sap_sales_div_division_code,
                           0 as br_base_price_value,
                           0 as br_gsv_value,
                           0 as br_base_price_qty,
                           0 as br_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,4,t01.fcst_value)),0)) as op_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,4,t01.fcst_value)),0)) as op_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,4,t01.fcst_qty)),0)) as op_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,4,t01.fcst_qty)),0)) as op_gsv_qty,
                           0 as rb_base_price_value,
                           0 as rb_gsv_value,
                           0 as rb_base_price_qty,
                           0 as rb_gsv_qty
                      from fcst_period t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code = 4
                       and t03.fcst_price_type_code in (1,2)
                       and t01.sap_sales_div_cust_code is not null
                       and t01.casting_yyyypp = trunc(rcd_fcst_period.casting_yyyypp/100)*100
                       and t01.fcst_yyyypp > rcd_fcst_period.casting_yyyypp
                     group by t01.fcst_yyyypp,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code,
                              t01.sap_sales_div_cust_code,
                              t01.sap_sales_div_sales_org_code,
                              t01.sap_sales_div_distbn_chnl_code,
                              t01.sap_sales_div_division_code)
             group by fcst_yyyypp,
                      sap_material_code,
                      sap_sales_dtl_sales_org_code,
                      sap_sales_dtl_distbn_chnl_code,
                      sap_sales_dtl_division_code,
                      sap_sales_div_cust_code,
                      sap_sales_div_sales_org_code,
                      sap_sales_div_distbn_chnl_code,
                      sap_sales_div_division_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_fcst_period;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - FCST_PERIOD_01_FACT Aggregation');

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
         begin
            lics_logging.write_log('**ERROR** - FCST_PERIOD_01_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - FCST_PERIOD_01_FACT Aggregation');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end forecast_period_01_aggregation;

   /**********************************************************************/
   /* This procedure performs the forecast period 02 aggregation routine */
   /**********************************************************************/
   procedure forecast_period_02_aggregation(par_yyyypp in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_previous_mars_period number(6,0);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_period is
         select distinct t01.casting_yyyypp as casting_yyyypp
           from fcst_period t01
          where ((par_yyyypp = 999999) or
                 (par_yyyypp != 999999 and t01.casting_yyyypp = var_previous_mars_period))
          order by t01.casting_yyyypp;
      rcd_fcst_period csr_fcst_period%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FCST_PERIOD_02_FACT Aggregation - Parameter(' || to_char(par_yyyypp) || ')');

      /*-*/
      /* Calculate the previous mars period as required
      /* **notes** 1. rebuild - remove existing data
      /*-*/
      if par_yyyypp = 999999 then
         lics_logging.write_log('FCST_PERIOD_02_FACT Aggregation - Truncating the table');
         dd_table.truncate('fcst_period_02_fact');
         var_previous_mars_period := 0;
      else
         if mod(par_yyyypp, 100) = 1 then
            var_previous_mars_period := trunc(par_yyyypp/100)*100;
         else
            var_previous_mars_period := par_yyyypp - 1;
         end if;
      end if;

      /*-*/
      /* Retrieve the forecast period data
      /*-*/
      open csr_fcst_period;
      loop
         fetch csr_fcst_period into rcd_fcst_period;
         if csr_fcst_period%notfound then
            exit;
         end if;

         /*-*/
         /* Delete where the billing_yyyypp is greater than casting_yyyypp
         /*-*/
         lics_logging.write_log('FCST_PERIOD_02_FACT Aggregation - Deleting the data - Casting period(' || to_char(rcd_fcst_period.casting_yyyypp) || ')');
         delete fcst_period_02_fact
            where billing_yyyypp > rcd_fcst_period.casting_yyyypp;

         /*-*/
         /* Insert into the forecast period fact table for each casting_yyyypp returned
         /*-*/
         lics_logging.write_log('FCST_PERIOD_02_FACT Aggregation - Building the data - Casting period(' || to_char(rcd_fcst_period.casting_yyyypp) || ')');
         insert into fcst_period_02_fact
            (billing_yyyypp,
             sap_material_code,
             sap_sales_dtl_sales_org_code,
             sap_sales_dtl_distbn_chnl_code,
             sap_sales_dtl_division_code,
             br_base_price_value,
             br_gsv_value,
             br_qty,
             op_base_price_value,
             op_gsv_value,
             op_qty,
             rb_base_price_value,
             rb_gsv_value,
             rb_qty)
            select fcst_yyyypp,
                   sap_material_code,
                   sap_sales_dtl_sales_org_code,
                   sap_sales_dtl_distbn_chnl_code,
                   sap_sales_dtl_division_code,
                   sum(br_base_price_value),
                   sum(br_gsv_value),
                   sum(decode(br_base_price_qty,0,br_gsv_qty,br_base_price_qty)),
                   sum(op_base_price_value),
                   sum(op_gsv_value),
                   sum(decode(op_base_price_qty,0,op_gsv_qty,op_base_price_qty)),
                   sum(rb_base_price_value),
                   sum(rb_gsv_value),
                   sum(decode(rb_base_price_qty,0,rb_gsv_qty,rb_base_price_qty))
              from (select t01.fcst_yyyypp,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,3,t01.fcst_value)),0)) as br_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,3,t01.fcst_value)),0)) as br_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,3,t01.fcst_qty)),0)) as br_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,3,t01.fcst_qty)),0)) as br_gsv_qty,
                           0 as op_base_price_value,
                           0 as op_gsv_value,
                           0 as op_base_price_qty,
                           0 as op_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,6,t01.fcst_value)),0)) as rb_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,6,t01.fcst_value)),0)) as rb_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,6,t01.fcst_qty)),0)) as rb_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,6,t01.fcst_qty)),0)) as rb_gsv_qty
                      from fcst_period t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code in (3,6)
                       and t03.fcst_price_type_code in (1,2)
                       and t01.casting_yyyypp = rcd_fcst_period.casting_yyyypp
                     group by t01.fcst_yyyypp,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code
                     union all
                    select t01.fcst_yyyypp,
                           t01.sap_material_code,
                           t01.sap_sales_dtl_sales_org_code,
                           t01.sap_sales_dtl_distbn_chnl_code,
                           t01.sap_sales_dtl_division_code,
                           0 as br_base_price_value,
                           0 as br_gsv_value,
                           0 as br_base_price_qty,
                           0 as br_gsv_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,4,t01.fcst_value)),0)) as op_base_price_value,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,4,t01.fcst_value)),0)) as op_gsv_value,
                           sum(nvl(decode(t01.fcst_price_type_code,1,decode(t01.fcst_type_code,4,t01.fcst_qty)),0)) as op_base_price_qty,
                           sum(nvl(decode(t01.fcst_price_type_code,2,decode(t01.fcst_type_code,4,t01.fcst_qty)),0)) as op_gsv_qty,
                           0 as rb_base_price_value,
                           0 as rb_gsv_value,
                           0 as rb_base_price_qty,
                           0 as rb_gsv_qty
                      from fcst_period t01,
                           fcst_type t02,
                           fcst_price_type t03
                     where t01.fcst_type_code = t02.fcst_type_code
                       and t01.fcst_price_type_code = t03.fcst_price_type_code
                       and t02.fcst_type_code = 4
                       and t03.fcst_price_type_code in (1,2)
                       and t01.casting_yyyypp = trunc(rcd_fcst_period.casting_yyyypp/100)*100
                       and t01.fcst_yyyypp > rcd_fcst_period.casting_yyyypp
                     group by t01.fcst_yyyypp,
                              t01.sap_material_code,
                              t01.sap_sales_dtl_sales_org_code,
                              t01.sap_sales_dtl_distbn_chnl_code,
                              t01.sap_sales_dtl_division_code)
             group by fcst_yyyypp,
                      sap_material_code,
                      sap_sales_dtl_sales_org_code,
                      sap_sales_dtl_distbn_chnl_code,
                      sap_sales_dtl_division_code;

         /*-*/
         /* Commit the database
         /*-*/
         commit;

      end loop;
      close csr_fcst_period;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - FCST_PERIOD_02_FACT Aggregation');

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
         begin
            lics_logging.write_log('**ERROR** - FCST_PERIOD_02_FACT Aggregation - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - FCST_PERIOD_02_FACT Aggregation');
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end forecast_period_02_aggregation;

end dw_forecast_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_forecast_aggregation for dw_app.dw_forecast_aggregation;
grant execute on dw_forecast_aggregation to public;
