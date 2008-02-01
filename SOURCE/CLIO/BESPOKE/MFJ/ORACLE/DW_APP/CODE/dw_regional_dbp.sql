/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_regional_dbp
 Owner   : dw_app

 Description
 -----------
 Dimensional Data Store - Regional DBP

 This package contains the populate and extract procedures for the regional DBP. The package exposes
 one procedure EXECUTE that performs the populate and extract based on the following parameters:

 1. PAR_ACTION (*LOAD_AND_EXTRACT, *EXTRACT) (MANDATORY)

    *LOAD_AND EXTRACT loads the REG_DBP table with the current period to date sales and then creates
    and sends the interface file.
    *EXTRACT creates and sends the interface file.

 **notes**
 1. A web log is produced under the search value DW_REGIONAL_DBP where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can
    be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/07   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package dw_regional_dbp as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2);

end dw_regional_dbp;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_regional_dbp as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure load_period_sales;
   procedure create_interface;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_loc_string varchar2(128);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_locked boolean;
      var_errors boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Regional DBP';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'REGIONAL_DBP';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'REGIONAL_DBP';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_REGIONAL_DBP';
      var_log_search := 'DW_REGIONAL_DBP';
      var_loc_string := 'DW_REGIONAL_DBP';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*LOAD_AND_EXTRACT' and upper(par_action) != '*EXTRACT' then
         raise_application_error(-20000, 'Action parameter (' || par_action || ') must be *LOAD_AND_EXTRACT or *EXTRACT');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Regional DBP - Parameters(' || upper(par_action) || ')');

      /*-*/
      /* Request the lock on the regional dbp
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
         /* Execute the load and extract procedures as required
         /*-*/
         if upper(par_action) = '*LOAD_AND_EXTRACT' then
            begin
               load_period_sales;
            exception
               when others then
                  var_errors := true;
            end;
         end if;
         /*----*/
         if upper(par_action) = '*LOAD_AND_EXTRACT' or upper(par_action) = '*EXTRACT' then
            begin
               create_interface;
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Release the lock on the regional dbp
         /*-*/
         lics_locking.release(var_loc_string);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Regional DBP');

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
                                         'DW_REGIONAL_DBP',
                                         var_email,
                                         'One or more errors occurred during the Regional DBP execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || substr(SQLERRM, 1, 1024));
            lics_logging.end_log;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Release the lock on the regional dbp
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_REGIONAL_DBP - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*********************************************************/
   /* This procedure performs the load period sales routine */
   /*********************************************************/
   procedure load_period_sales is

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_ptd is
         select business_seg as bus_sgmnt,
                brand_flag as brand_flag,
                sum(ptd) as ptd
           from (select upper(t2.bus_sgmnt_desc) as business_seg,
                        upper(t2.brand_flag_desc) as brand_flag,
                        sum(t1.sales_dtl_price_value_13) as ptd
                   from sales_period_03_fact t1,
                        material_dim t2
                  where t1.sap_material_code = t2.sap_material_code
	            and t2.sap_bus_sgmnt_code in ('01', '02', '05')
	            and t1.sap_billing_yyyypp = (select mars_period
                                                   from mars_date
                                                  where to_char(calendar_date, 'DD/MM/YYYY') = to_char(sysdate - 1, 'DD/MM/YYYY'))
                  group by t2.bus_sgmnt_desc,
                           t2.brand_flag_desc)
          group by business_seg,
                   brand_flag
          order by business_seg,
                   brand_flag;
      rcd_ptd csr_ptd%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Regional DBP - Load period sales');

      /*-*/
      /* Clear current period values
      /*-*/
      lics_logging.write_log('Regional DBP - Load period sales - Clearing the REGIONAL DBP existing period to date values');
      update reg_dbp set ptd = 0;

      /*-*/
      /* Retrieve the current period to date values
      /*-*/
      lics_logging.write_log('Regional DBP - Load period sales - Loading the REGIONAL DBP new period to date values');
      open csr_ptd;
      loop
         fetch csr_ptd into rcd_ptd;
         if csr_ptd%notfound then
            exit;
         end if;

         /*-*/
         /* Update/insert the period to date values
         /*-*/
         update reg_dbp
            set ptd = rcd_ptd.ptd,
                reg_dbp_lupdp = user,
                reg_dbp_lupdt = sysdate
          where bus_sgmnt  = rcd_ptd.bus_sgmnt
            and brand_flag = rcd_ptd.brand_flag;
         if sql%notfound then
            insert into reg_dbp
               (bus_sgmnt,
                brand_flag,
                br_casting_yyyypp,
                op_casting_yyyy,
                ptd,
                br_p01,
                br_p02,
                br_p03,
                br_p04,
                br_p05,
                br_p06,
                br_p07,
                br_p08,
                br_p09,
                br_p10,
                br_p11,
                br_p12,
                br_p13,
                op_p01,
                op_p02,
                op_p03,
                op_p04,
                op_p05,
                op_p06,
                op_p07,
                op_p08,
                op_p09,
                op_p10,
                op_p11,
                op_p12,
                op_p13,
                reg_dbp_lupdp,
                reg_dbp_lupdt,
                br_batch_code,
                op_batch_code)
                VALUES(upper(rcd_ptd.bus_sgmnt),
                       upper(rcd_ptd.brand_flag),
                       0,
                       0,
                       rcd_ptd.ptd,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       0,
                       user,
                       sysdate,
                       'NONE',
                       'NONE');
         end if;

      end loop;
      close csr_ptd;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Regional DBP - Load period sales');

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
            lics_logging.write_log('**ERROR** - Regional DBP - Load period sales - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Regional DBP - Load period sales');
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
   end load_period_sales;

   /********************************************************/
   /* This procedure performs the create interface routine */
   /********************************************************/
   procedure create_interface is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_target_percentage number;
      var_previous_day_num mars_date.period_day_num%type;
      var_period_day mars_date.period_day_num%type;
      var_total_period_days mars_date.period_day_num%type;
      var_current_yyyypp mars_date.mars_period%type;
      var_previous_day_mars_yyyypp mars_date.mars_period%type;
      var_bus_day_nbr mars_date.period_bus_day_num%type;
      var_total_bus_days_nbr mars_date.period_bus_day_num%type;
      var_dom_or_exp varchar2(24);
      var_current_period_number varchar(2);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_current_period is
         select t1.period_num
	   from mars_date t1
	  where t1.calendar_date = (select trunc(sysdate - 1) from dual);
      rcd_current_period csr_current_period%rowtype;

      --Getting sales mars period from daily table since ptd table is in YYYYPPDD format
      cursor csr_current_yyyypp is
         select trunc(max(billing_yyyyppdd) / 100) as mars_period
           from sales_fact;
      rcd_current_yyyypp csr_current_yyyypp%rowtype;

      -- The cursor below selects the Period Day Number based on the previous day's system's date.
      -- This is needed because the Notes DBP System validates the day number
      -- before proceeding with the distribution of the DBP mailout.
      -- Since Japan does not load sales data on Saturdays, the Notes DBP system
      -- as it is currently set up, will still look for the Saturday's day number
      -- before proceeding on Mondays.
      cursor csr_previous_day_num is
         select period_day_num as period_day_num,
                mars_period as mars_period
           from mars_date
          where calendar_date = trunc(sysdate - 1);
      rcd_previous_day_num csr_previous_day_num%rowtype;

      -- Selecting the maximum day number of a given period
      cursor csr_max_period_day is
         select max(period_day_num) as max_period_day_num
           from mars_date
          where mars_period = (select trunc(max(billing_yyyyppdd) / 100)
                                 from sales_fact);
      rcd_max_period_day csr_max_period_day%rowtype;

      -- Selecting the Period's Business Day (to be used for Invoice Target) and
      -- Period Day Number (to be used for 'Extracted for....' section)
      -- The SQL for this far more complicated for Japan only because their aggregated sales
      -- table does not record the same date in a YYYYMMDD.  Consequently, the various components
      -- of the sales date were taken from the daily sales table (SALES_ACT_CUST_WSP_DLY) and used
      -- query the CAL_GENERAL_DATE from the CALENDAR table in order to obtain PERIOD_BUS_DAY_NUM
      -- and PERIOD_DAY_NUM fields from the MARS_DATE table.
      cursor csr_invoice_day is
         select period_bus_day_num as period_bus_day_num,
                period_day_num as period_day_num
          from mars_date
         where mars_yyyyppdd = (select max(billing_yyyyppdd)
                                  from sales_fact);
      rcd_invoice_day csr_invoice_day%rowtype;

      -- Selecting the maximum of the Period's Business Day Number.
      -- This is to be used to in part of the calculation to obtain the % of Invoice Target
      cursor csr_total_invoice_days is
         select max(period_bus_day_num) as max_period_bus_day_num
           from mars_date
          where mars_period = (select trunc(max(billing_yyyyppdd) / 100)
                                 from sales_fact);
      rcd_total_invoice_days csr_total_invoice_days%rowtype;

      --To retrieve the summary information of the report
      --  Totals for Domestic
      cursor csr_temp is
         select round(sum(ptd), 0) as de_invc_ptd,
                round(sum(br_p01), 0) as de_invc_br,
                round(decode(sum(br_p01), 0, 0, (sum(ptd) / sum(br_p01)) * 100), 1) as de_invc_br_percent,
                round(sum(op_p01), 0) as de_invc_op,
                round(decode(sum(op_p01), 0, 0, (sum(ptd) / sum(op_p01)) * 100), 1) as de_invc_op_percent,
                round(sum(ptd), 0) as de_ord_ptd,
                round(decode(sum(br_p01), 0, 0, (sum(ptd) / sum(br_p01)) * 100), 1) as de_ord_br_percent,
                round(decode(sum(op_p01), 0, 0, (sum(ptd) / sum(op_p01)) * 100), 1) as de_ord_op_percent
           from reg_dbp_view;
      type ref_cursor is ref cursor;
      csr_dom_exp ref_cursor;
      rcd_dom_exp csr_temp%rowtype;


      --To retrieve the total of each business group for domestic
      cursor csr_temp2 is
         select order_nbr as bs_order_nbr,
                round(sum(ptd), 0) as bs_invc_ptd,
                round(sum(br_p01), 0) as bs_invc_br,
                round(decode(sum(br_p01), 0, 0, (sum(ptd) / sum(br_p01)) * 100), 1) as bs_invc_br_percent,
                round(sum(op_p01), 0) as bs_invc_op,
                round(decode(sum(op_p01), 0, 0, (sum(ptd) / sum(op_p01)) * 100), 1) as bs_invc_op_percent,
                round(sum(ptd), 0) as bs_ord_ptd,
                round(decode(sum(br_p01), 0, 0, (sum(ptd) / sum(br_p01)) * 100), 1) as bs_ord_br_percent,
                round(decode(sum(op_p01), 0, 0, (sum(ptd) / sum(op_p01)) * 100), 1) as bs_ord_op_percent
           from reg_dbp_view;
      csr_total_bus_grp ref_cursor;
      rcd_total_bus_grp csr_temp2%rowtype;

      --To retrieve the individual items that make the total of PETCARE
      cursor csr_temp3 is
         select domestic_export as domestic_export,
                order_nbr as order_nbr,
                business_seg as business_seg,
                brand_flag as brand,
                ptd as invc_ptd,
                br_p01 as invc_br,
                decode(br_p01, 0, 0, round(ptd / br_p01 * 100, 2)) as invc_br_percent,
                op_p01 as invc_op,
                decode(op_p01, 0, 0, round(ptd / op_p01 * 100, 2)) as invc_op_percent,
                ptd as ord_ptd,
                decode(br_p01, 0, 0, round(ptd / br_p01 * 100, 2)) as ord_br_percent,
                decode(op_p01, 0, 0, round(ptd / op_p01 * 100, 2)) as ord_op_percent
           from reg_dbp_view;
      csr_petcare_invc_ordr ref_cursor;
      rcd_petcare_invc_ordr csr_temp3%rowtype;

      --To retrieve the individual items that make the total of SNACKFOOD
      csr_snackfood_invc_ordr ref_cursor;
      rcd_snackfood_invc_ordr csr_temp3%rowtype;

      --To retrieve the individual items that make the total of FOOD
      csr_food_invc_ordr ref_cursor;
      rcd_food_invc_ordr csr_temp3%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Regional DBP - Create interface');

      /*-*/
      /* Determine current period to be used in the cursors
      /*-*/
      open csr_current_period;
      fetch csr_current_period into rcd_current_period;
      var_current_period_number := to_char(rcd_current_period.period_num,'fm00');

      /*-*/
      /* Determine current mars period to be used in the header section
      /*-*/
      open csr_current_yyyypp;
      fetch csr_current_yyyypp into rcd_current_yyyypp;
      var_current_yyyypp := rcd_current_yyyypp.mars_period;

      /*-*/
      /* Determine previous day number to be used in the header section
      /*-*/
      open csr_previous_day_num;
      fetch csr_previous_day_num into rcd_previous_day_num;
      var_previous_day_num := rcd_previous_day_num.period_day_num;
      var_previous_day_mars_yyyypp := rcd_previous_day_num.mars_period;

      /*-*/
      /* Determine the Max number of days in the period (to be used in the header section)
      /*-*/
      open csr_max_period_day;
      fetch csr_max_period_day into rcd_max_period_day;
      var_total_period_days := rcd_max_period_day.max_period_day_num;

      /*-*/
      /* Determine the Invoice Day to be used in the Invoice Target calculation
      /*-*/
      open csr_invoice_day;
      fetch csr_invoice_day into rcd_invoice_day;
      var_bus_day_nbr := rcd_invoice_day.period_bus_day_num;
      var_period_day  := rcd_invoice_day.period_day_num;

      /*-*/
      /* Determine the Total Invoice Days available in the period to be used in the Invoice Target calculation
      /*-*/
      open csr_total_invoice_days;
      fetch csr_total_invoice_days into rcd_total_invoice_days;
      var_total_bus_days_nbr := rcd_total_invoice_days.max_period_bus_day_num;

      /*-*/
      /* Open Petcare Invoice/Order cursor
      /*-*/
      open csr_petcare_invc_ordr for
         'SELECT
           DOMESTIC_EXPORT                                       AS DOMESTIC_EXPORT,
           ORDER_NBR                                             AS ORDER_NBR,
           BUSINESS_SEG                                          AS BUSINESS_SEG,
           BRAND_FLAG                                            AS BRAND,
           PTD                                                   AS INVC_PTD,
           BR_P'|| var_current_period_number ||'                 AS INVC_BR,
           ROUND(DECODE(BR_P'|| var_current_period_number ||', 0, 0, (PTD / BR_P'|| var_current_period_number ||') * 100), 2) AS INVC_BR_PERCENT,
           OP_P'|| var_current_period_number ||'                  AS INVC_OP,
           ROUND(DECODE(OP_P'|| var_current_period_number ||', 0, 0, (PTD / OP_P'|| var_current_period_number ||') * 100), 2) AS INVC_OP_PERCENT,
           ''0''                                                 AS ORD_PTD,
           ''0''                                                 AS ORD_BR_PERCENT,
           ''0''                                                 AS ORD_OP_PERCENT
         FROM
           REG_DBP_VIEW
         WHERE
           UPPER(BUSINESS_SEG) = ''PETCARE''';

      /*-*/
      /* Open Snackfood Invoice/Order cursor
      /*-*/
      open csr_snackfood_invc_ordr for
         'SELECT
           DOMESTIC_EXPORT                                       AS DOMESTIC_EXPORT,
           ORDER_NBR                                             AS ORDER_NBR,
           BUSINESS_SEG                                          AS BUSINESS_SEG,
           BRAND_FLAG                                            AS BRAND,
           PTD                                                   AS INVC_PTD,
           BR_P'|| var_current_period_number ||'                 AS INVC_BR,
           ROUND(DECODE(BR_P'|| var_current_period_number ||', 0, 0, (PTD / BR_P'|| var_current_period_number ||') * 100), 2) AS INVC_BR_PERCENT,
           OP_P'|| var_current_period_number ||'                 AS INVC_OP,
           ROUND(DECODE(OP_P'|| var_current_period_number ||', 0, 0, (PTD / OP_P'|| var_current_period_number ||') * 100), 2) AS INVC_OP_PERCENT,
           ''0''                                                 AS ORD_PTD,
           ''0''                                                 AS ORD_BR_PERCENT,
           ''0''                                                 AS ORD_OP_PERCENT
         FROM
           REG_DBP_VIEW
         WHERE
           UPPER(BUSINESS_SEG) = ''SNACKFOOD''';

      /*-*/
      /* Open Food Invoice/Order cursor
      /*-*/
      open csr_food_invc_ordr for
         'SELECT
           DOMESTIC_EXPORT                                       AS DOMESTIC_EXPORT,
           ORDER_NBR                                             AS ORDER_NBR,
           BUSINESS_SEG                                          AS BUSINESS_SEG,
           BRAND_FLAG                                            AS BRAND,
           PTD                                                   AS INVC_PTD,
           BR_P'|| var_current_period_number ||'                 AS INVC_BR,
           ROUND(DECODE(BR_P'|| var_current_period_number ||', 0, 0, (PTD / BR_P'|| var_current_period_number ||') * 100), 2) AS INVC_BR_PERCENT,
           OP_P'|| var_current_period_number ||'                 AS INVC_OP,
           ROUND(DECODE(OP_P'|| var_current_period_number ||', 0, 0, (PTD / OP_P'|| var_current_period_number ||') * 100), 2) AS INVC_OP_PERCENT,
           ''0''                                                 AS ORD_PTD,
           ''0''                                                 AS ORD_BR_PERCENT,
           ''0''                                                 AS ORD_OP_PERCENT
         FROM
           REG_DBP_VIEW
         WHERE
           UPPER(BUSINESS_SEG) = ''FOOD''';

      /*-*/
      /* Open Domestic cursor
      /*-*/
      open csr_dom_exp for
         'SELECT
           ROUND(SUM(PTD), 0)                                 AS DE_INVC_PTD,
           ROUND(SUM(BR_P'|| var_current_period_number ||'), 0) AS DE_INVC_BR,
           ROUND(DECODE(SUM(BR_P'|| var_current_period_number ||'), 0, 0, (SUM(PTD) / SUM(BR_P'|| var_current_period_number ||')) * 100), 1) AS DE_INVC_BR_PERCENT,
           ROUND(SUM(OP_P'|| var_current_period_number ||'), 0) AS DE_INVC_OP,
           ROUND(DECODE(SUM(OP_P'|| var_current_period_number ||'), 0, 0, (SUM(PTD) / SUM(OP_P'|| var_current_period_number ||')) * 100), 1) AS DE_INVC_OP_PERCENT,
           ''0''                                              AS DE_ORD_PTD,
           ''0''                                              AS DE_ORD_BR_PERCENT,
           ''0''                                              AS DE_ORD_OP_PERCENT
         FROM
           REG_DBP_VIEW';

      /*-*/
      /* Open Total Business Segment cursor
      /*-*/
      open csr_total_bus_grp for
        'SELECT
          ORDER_NBR                                          AS BS_ORDER_NBR,
          ROUND(SUM(PTD), 0)                                 AS BS_INVC_PTD,
          ROUND(SUM(BR_P'|| var_current_period_number ||'), 0) AS BS_INVC_BR,
          ROUND(DECODE(SUM(BR_P'|| var_current_period_number ||'), 0, 0, (SUM(PTD) / SUM(BR_P'|| var_current_period_number ||')) * 100), 1) AS BS_INVC_BR_PERCENT,
          ROUND(SUM(OP_P'|| var_current_period_number ||'), 0) AS BS_INVC_OP,
          ROUND(DECODE(SUM(OP_P'|| var_current_period_number ||'), 0, 0, (SUM(PTD) / SUM(OP_P'|| var_current_period_number ||')) * 100), 1) AS BS_INVC_OP_PERCENT,
          ''0''                                              AS BS_ORD_PTD,
          ''0''                                              AS BS_ORD_BR_PERCENT,
          ''0''                                              AS BS_ORD_OP_PERCENT
        FROM
          REG_DBP_VIEW
        GROUP BY
          ORDER_NBR';

      /*-*/
      /* Calculate invoice target percentage
      /*-*/
      var_target_percentage := round(((var_bus_day_nbr / var_total_bus_days_nbr) * 100), 0);

      /*-*/
      /* Create the new interface
      /*-*/
      var_instance := lics_outbound_loader.create_interface('REGDBP01');

      /*-*/
      /* Output HD1
      /*-*/
      lics_outbound_loader.append_data('SAR550J                               Japan Daily Sales Report');

      /*-*/
      /* Output HD2
      /*-*/
      lics_outbound_loader.append_data('GSV (000''s JPY) ');

      /*-*/
      /* Output HD3
      /* **note**
      /* If yesterday's period day NUMBER IS equal TO the period day NUMBER IN the aggregated
      /* sales table, then display the non-monday version of v_data.  Else, display the monday
      /* version of v_data (this would only occur for the extract that is run on Sunday and published
      /* on Monday).
      /*-*/
      if (var_previous_day_num = var_period_day) then
         lics_outbound_loader.append_data(var_current_yyyypp       || '  ' ||
                                          'DAY ' || var_period_day || ' '  ||
                                          'OF '  || var_total_period_days);
      else
         lics_outbound_loader.append_data(var_previous_day_mars_yyyypp || '  ' ||
                                          'DAY '                     || var_previous_day_num  || ' '  ||
                                          'OF '                      || var_total_period_days || '  ' ||
                                          '(Extracted for '          || var_current_yyyypp    || '  ' ||
                                          'DAY '                     || var_period_day        || ' '  ||
                                          'OF '                      || var_total_period_days || ')');
      end if;

      /*-*/
      /* Output HD4
      /*-*/
      lics_outbound_loader.append_data('Invoice Target:  ' || var_target_percentage || '%');

      /*-*/
      /* Output HD5
      /*-*/
      lics_outbound_loader.append_data('                                                      Invoices                             Orders FOR Delivery');

      /*-*/
      /* Output HD6
      /*-*/
      lics_outbound_loader.append_data('                                       PTD        BR      %BR      PLAN    %PLAN            PTD      %BR    %PLAN');

      /*-*/
      /* Output HD7
      /*-*/
      lics_outbound_loader.append_data('                                  --------  --------  -------  --------  -------       --------  -------  -------');

      /*-*/
      /* Fetch Total Domestic
      /*-*/
      loop
         fetch csr_dom_exp into rcd_dom_exp;
         exit when csr_dom_exp%notfound;
         lics_outbound_loader.append_data(RPAD('JAPAN DOMESTIC', 34) ||
	                                  LPAD(ROUND(rcd_dom_exp.DE_INVC_PTD, 0), 8) ||
                                          LPAD(ROUND(rcd_dom_exp.DE_INVC_BR, 0), 10) ||
                                          LPAD(TO_CHAR(ROUND(rcd_dom_exp.DE_INVC_BR_PERCENT, 1), '9990D0'), 8) || '%' ||
                                          LPAD(ROUND(rcd_dom_exp.DE_INVC_OP, 0), 10) ||
                                          LPAD(TO_CHAR(ROUND(rcd_dom_exp.DE_INVC_OP_PERCENT, 1), '9990D0'), 8) || '%' ||
                                          LPAD('NA', 15) ||
                                          LPAD('NA', 9)  ||
	                                  LPAD('NA', 9));
      end loop;

      /*-*/
      /* Fetch total business segment
      /*-*/
      loop
         fetch csr_total_bus_grp into rcd_total_bus_grp;
         exit when csr_total_bus_grp%notfound;

         /*-*/
         /* Food
         /*-*/
	 if rcd_total_bus_grp.bs_order_nbr = 3 then

            /*-*/
            /* Food Total
            /*-*/
            lics_outbound_loader.append_data(RPAD('FOOD DOMESTIC', 34) ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_PTD, 0), 8) ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_BR, 0), 10) ||
                                             LPAD(TO_CHAR(ROUND(rcd_total_bus_grp.BS_INVC_BR_PERCENT, 1), '9990D0'), 8) || '%' ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_OP, 0), 10) ||
                                             LPAD(TO_CHAR(ROUND(rcd_total_bus_grp.BS_INVC_OP_PERCENT, 1), '9990D0'), 8) || '%' ||
                                             LPAD('NA', 15) ||
                                             LPAD('NA', 9)  ||
	   	                             LPAD('NA', 9));

            /*-*/
            /* Fetch Food Invoice/Order
            /*-*/
            loop
               fetch csr_food_invc_ordr into rcd_food_invc_ordr;
               exit when csr_food_invc_ordr%notfound;
               lics_outbound_loader.append_data('  ' || RPAD(rcd_food_invc_ordr.BRAND, 32)     ||
	                                        LPAD(ROUND(rcd_food_invc_ordr.INVC_PTD, 0), 8) ||
                                                LPAD(ROUND(rcd_food_invc_ordr.INVC_BR, 0), 10) ||
                                                LPAD(TO_CHAR(ROUND(rcd_food_invc_ordr.INVC_BR_PERCENT, 1), '9990D0'), 8) || '%' ||
                                                LPAD(ROUND(rcd_food_invc_ordr.INVC_OP, 0), 10) ||
                                                LPAD(TO_CHAR(ROUND(rcd_food_invc_ordr.INVC_OP_PERCENT, 1), '9990D0'), 8) || '%' ||
                                                LPAD('NA', 15) ||
                                                LPAD('NA', 9)  ||
		                                LPAD('NA', 9));
            end loop;

         /*-*/
         /* Petcare
         /*-*/
         elsif rcd_total_bus_grp.bs_order_nbr = 1 then

            /*-*/
            /* Petcare Total
            /*-*/
            lics_outbound_loader.append_data(RPAD('PETCARE DOMESTIC', 34) ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_PTD, 0), 8) ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_BR, 0), 10) ||
                                             LPAD(TO_CHAR(ROUND(rcd_total_bus_grp.BS_INVC_BR_PERCENT, 1), '9990D0'), 8) || '%' ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_OP, 0), 10) ||
                                             LPAD(TO_CHAR(ROUND(rcd_total_bus_grp.BS_INVC_OP_PERCENT, 1), '9990D0'), 8) || '%' ||
                                             LPAD('NA', 15) ||
                                             LPAD('NA', 9)  ||
	   	                             LPAD('NA', 9));

            /*-*/
            /* Fetch Petcare Invoice/Order
            /*-*/
            loop
               fetch csr_petcare_invc_ordr into rcd_petcare_invc_ordr;
               exit when csr_petcare_invc_ordr%notfound;
               lics_outbound_loader.append_data('  ' || RPAD(rcd_petcare_invc_ordr.BRAND, 32)     ||
	                                        LPAD(ROUND(rcd_petcare_invc_ordr.INVC_PTD, 0), 8) ||
                                                LPAD(ROUND(rcd_petcare_invc_ordr.INVC_BR, 0), 10) ||
                                                LPAD(TO_CHAR(ROUND(rcd_petcare_invc_ordr.INVC_BR_PERCENT, 1), '9990D0'), 8) || '%' ||
                                                LPAD(ROUND(rcd_petcare_invc_ordr.INVC_OP, 0), 10) ||
                                                LPAD(TO_CHAR(ROUND(rcd_petcare_invc_ordr.INVC_OP_PERCENT, 1), '9990D0'), 8) || '%' ||
                                                LPAD('NA', 15) ||
                                                LPAD('NA', 9)  ||
                                                LPAD('NA', 9));
            end loop;

         /*-*/
         /* Snackfood
         /*-*/
	 elsif rcd_total_bus_grp.bs_order_nbr = 2 then

            /*-*/
            /* Snackfood Total
            /*-*/
            lics_outbound_loader.append_data(RPAD('SNACKFOOD DOMESTIC', 34) ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_PTD, 0), 8) ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_BR, 0), 10) ||
                                             LPAD(TO_CHAR(ROUND(rcd_total_bus_grp.BS_INVC_BR_PERCENT, 1), '9990D0'), 8) || '%' ||
                                             LPAD(ROUND(rcd_total_bus_grp.BS_INVC_OP, 0), 10) ||
                                             LPAD(TO_CHAR(ROUND(rcd_total_bus_grp.BS_INVC_OP_PERCENT, 1), '9990D0'), 8) || '%' ||
                                             LPAD('NA', 15) ||
                                             LPAD('NA', 9)  ||
	   	                             LPAD('NA', 9));

            /*-*/
            /* Fetch Snackfood Invoice/Order
            /*-*/
            loop
               fetch csr_snackfood_invc_ordr into rcd_snackfood_invc_ordr;
               exit when csr_snackfood_invc_ordr%notfound;
               lics_outbound_loader.append_data('  ' || RPAD(rcd_snackfood_invc_ordr.BRAND, 32)     ||
	                                        LPAD(ROUND(rcd_snackfood_invc_ordr.INVC_PTD, 0), 8) ||
                                                LPAD(ROUND(rcd_snackfood_invc_ordr.INVC_BR, 0), 10) ||
                                                LPAD(TO_CHAR(ROUND(rcd_snackfood_invc_ordr.INVC_BR_PERCENT, 1), '9990D0'), 8) || '%' ||
                                                LPAD(ROUND(rcd_snackfood_invc_ordr.INVC_OP, 0), 10) ||
                                                LPAD(TO_CHAR(ROUND(rcd_snackfood_invc_ordr.INVC_OP_PERCENT, 1), '9990D0'), 8) || '%' ||
                                                LPAD('NA', 15) ||
                                                LPAD('NA', 9)  ||
		                                LPAD('NA', 9));
            end loop;

         end if;

      end loop;

      /*-*/
      /* Output FTR1
      /*-*/
      lics_outbound_loader.append_data('_________________________________________________________________________________________________________________');

      /*-*/
      /* Output FTR2
      /*-*/
      lics_outbound_loader.append_data('** NA denotes Not Applicable **');

      /*-*/
      /* Output FTR3
      /*-*/
      lics_outbound_loader.append_data('*END OF REPORT*');

      /*-*/
      /* Close the cursors
      /*-*/
      close csr_current_yyyypp;
      close csr_previous_day_num;
      close csr_max_period_day;
      close csr_invoice_day;
      close csr_total_invoice_days;
      close csr_petcare_invc_ordr;
      close csr_snackfood_invc_ordr;
      close csr_food_invc_ordr;
      close csr_dom_exp;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Regional DBP - Create interface');

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
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(substr(SQLERRM, 1, 512));
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - Regional DBP - Create interface - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - Regional DBP - Create interface');
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
   end create_interface;

end dw_regional_dbp;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_regional_dbp for dw_app.dw_regional_dbp;
grant execute on dw_regional_dbp to public;
