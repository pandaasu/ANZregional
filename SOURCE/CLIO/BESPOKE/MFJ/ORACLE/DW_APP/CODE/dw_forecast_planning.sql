/******************/
/* Package Header */
/******************/
create or replace package dw_forecast_planning as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : dw_forecast_planning
 Owner   : dw_app

 Description
 -----------
 Dimensional Data Store - Forecast Planning

 This package contain the planning procedures for forecast data. The package exposes one
 procedure EXECUTE that performs the import based on the following parameters.

 1. PAR_ACTION (*ALL, *PERIOD) (MANDATORY)

    *ALL imports all forecast data from the demand planning system.
    *PERIOD imports only period forecast data from the demand planning system.

 2. PAR_COMPANY (company code) (MANDATORY)

    The company for which the import is to be performed.

 **notes**
 1. A web log is produced under the search value DW_FORECAST_PLANNING where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can
    be raised.

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2, par_company in varchar2);

end dw_forecast_planning;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_forecast_planning as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure import_period_data(par_company in varchar2);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2, par_company in varchar2) is

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

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Forecast Planning';
      con_alt_group constant varchar2(32) := 'DW_ALERT';
      con_alt_code constant varchar2(32) := 'FCST_PLANNING';
      con_ema_group constant varchar2(32) := 'DW_EMAIL_GROUP';
      con_ema_code constant varchar2(32) := 'FCST_PLANNING';

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CLIO - DW_FORECAST_PLANNING';
      var_log_search := 'DW_FORECAST_PLANNING';
      var_loc_string := 'DW_FORECAST_PLANNING';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;
      var_locked := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_action) != '*ALL' and
         upper(par_action) != '*PERIOD'then
         raise_application_error(-20000, 'Action parameter must be *ALL or ' || '*PERIOD');
      end if;
      if upper(par_company) is null then
         raise_application_error(-20000, 'Company parameter must be supplied');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Forecast Planning - Parameters(' || upper(par_action) || ' + ' || par_company || ')');

      /*-*/
      /* Request the lock on the forecast planning
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
         /* Execute the import procedure
         /*
         /*-*/
         if upper(par_action) = '*ALL' or upper(par_action) = '*PERIOD' then
            begin
               import_period_data(par_company);
            exception
               when others then
                  var_errors := true;
            end;
         end if;

         /*-*/
         /* Release the lock on the forecast planning
         /*-*/
         lics_locking.release(var_loc_string || '-' || par_company);

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Forecast Planning');

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
                                         'DW_FORECAST_PLANNING',
                                         var_email,
                                         'One or more errors occurred during the Forecast Planning execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Release the lock on the forecast planning
         /*-*/
         if var_locked = true then
            lics_locking.release(var_loc_string || '-' || par_company);
         end if;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CLIO - DW_FORECAST_PLANNING - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /**********************************************************/
   /* This procedure performs the import period data routine */
   /**********************************************************/
   procedure import_period_data(par_company in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_commit_max constant number := 1000;
      var_commit_count number;
      type typ_wrkd is table of date index by binary_integer;
      type typ_wrkq is table of number index by binary_integer;
      tbl_wrkd typ_wrkd;
      tbl_wrkq typ_wrkq;
      var_wrk_date date;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst_period_input is
         select t02.prod_cd as sap_material_code,
                t02.chan_id as sap_plant_code,
                t04.sap_distbn_chnl_code as sap_distbn_chnl_code,
                t04.sap_sales_org_code as sap_sales_org_code,
                t04.material_list_price_valid_from as material_list_price_valid_from,
                t04.material_list_price_valid_to as material_list_price_valid_to,
                t04.material_list_price as material_list_price,
                t01.pub_date as publish_date,
                t01.period as casting_date,
                t01.period + 1 as asof_date,
                t01.period_1 as fcst_date_01,
                t01.period_2 as fcst_date_02,
                t01.period_3 as fcst_date_03,
                t01.period_4 as fcst_date_04,
                t01.period_5 as fcst_date_05,
                t01.period_6 as fcst_date_06,
                t01.period_7 as fcst_date_07,
                t01.period_8 as fcst_date_08,
                t01.period_9 as fcst_date_09,
                t01.period_10 as fcst_date_10,
                t01.period_11 as fcst_date_11,
                t01.period_12 as fcst_date_12,
                t01.period_13 as fcst_date_13,
                t01.period_14 as fcst_date_14,
                t01.period_15 as fcst_date_15,
                t01.period_16 as fcst_date_16,
                t01.period_17 as fcst_date_17,
                t01.period_18 as fcst_date_18,
                t01.period_19 as fcst_date_19,
                t01.period_20 as fcst_date_20,
                t01.period_21 as fcst_date_21,
                t01.period_22 as fcst_date_22,
                t01.period_23 as fcst_date_23,
                t01.period_24 as fcst_date_24,
                t01.period_25 as fcst_date_25,
                t01.period_26 as fcst_date_26,
                t02.period_1 as fcst_case_01,
                t02.period_2 as fcst_case_02,
                t02.period_3 as fcst_case_03,
                t02.period_4 as fcst_case_04,
                t02.period_5 as fcst_case_05,
                t02.period_6 as fcst_case_06,
                t02.period_7 as fcst_case_07,
                t02.period_8 as fcst_case_08,
                t02.period_9 as fcst_case_09,
                t02.period_10 as fcst_case_10,
                t02.period_11 as fcst_case_11,
                t02.period_12 as fcst_case_12,
                t02.period_13 as fcst_case_13,
                t02.period_14 as fcst_case_14,
                t02.period_15 as fcst_case_15,
                t02.period_16 as fcst_case_16,
                t02.period_17 as fcst_case_17,
                t02.period_18 as fcst_case_18,
                t02.period_19 as fcst_case_19,
                t02.period_20 as fcst_case_20,
                t02.period_21 as fcst_case_21,
                t02.period_22 as fcst_case_22,
                t02.period_23 as fcst_case_23,
                t02.period_24 as fcst_case_24,
                t02.period_25 as fcst_case_25,
                t02.period_26 as fcst_case_26
           from net_fcast_hd_from_mercia t01,
                net_fcast_from_mercia t02,
                material_dim t03,
                material_list_price t04,
                sales_org_dim t05,
                plant_dim t06
          where t01.ref = t02.ref
            and t02.prod_cd = t03.sap_material_code
            and t04.sap_material_code = decode(t03.sap_rep_item_code,null,t03.sap_material_code,t03.sap_rep_item_code)
            and t04.sap_sales_org_code = t05.sap_sales_org_code
            and t02.chan_id = t06.sap_plant_code
            and t03.sap_bus_sgmnt_code in ('01','02','05')
            and t03.material_type_flag_tdu = 'Y'
            and t03.material_sts_code = 'ACTIVE'
            and t04.sap_cndtn_type_code = 'PR00'
            and t05.sap_sales_org_code = par_company
          order by t01.ref;
      rcd_fcst_period_input csr_fcst_period_input%rowtype;

      cursor csr_mars_date is
         select t01.mars_period as casting_yyyypp,
                t02.mars_period as asof_yyyypp,
                t03.mars_period as fcst_yyyypp
           from (select 'x' as join_value,
                        t11.mars_period
                   from mars_date t11
                  where t11.calendar_date = rcd_fcst_period_input.casting_date) t01,
                (select 'x' as join_value,
                        t12.mars_period
                   from mars_date t12
                  where t12.calendar_date = rcd_fcst_period_input.asof_date) t02,
                (select 'x' as join_value,
                        t13.mars_period
                   from mars_date t13
                  where t13.calendar_date = var_wrk_date) t03
          where t01.join_value = t02.join_value
            and t01.join_value = t03.join_value;
      rcd_mars_date csr_mars_date%rowtype;

      cursor csr_fcst_plan_period is
         select t01.publish_date,
                t01.fcst_cases
           from fcst_plan_period t01
          where t01.sap_material_code = rcd_fcst_period_input.sap_material_code
            and t01.sap_plant_code = rcd_fcst_period_input.sap_plant_code
            and t01.casting_date = rcd_fcst_period_input.casting_date
            and t01.asof_date = rcd_fcst_period_input.asof_date
            and t01.fcst_date = var_wrk_date;
      rcd_fcst_plan_period csr_fcst_plan_period%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - PERIOD Import - Parameters(' || par_company || ')');

      /*-*/
      /* Retrieve the forecast period plan data
      /*-*/
      var_commit_count := 0;
      open csr_fcst_period_input;
      loop
         fetch csr_fcst_period_input into rcd_fcst_period_input;
         if csr_fcst_period_input%notfound then
            exit;
         end if;

         /*-*/
         /* Set the forecast arrays
         /*-*/
         for idx in 1..26 loop
            tbl_wrkd(1) := null;
            tbl_wrkq(1) := 0;
	 end loop;
         tbl_wrkd(1) := rcd_fcst_period_input.fcst_date_01;
         tbl_wrkd(2) := rcd_fcst_period_input.fcst_date_02;
         tbl_wrkd(3) := rcd_fcst_period_input.fcst_date_03;
         tbl_wrkd(4) := rcd_fcst_period_input.fcst_date_04;
         tbl_wrkd(5) := rcd_fcst_period_input.fcst_date_05;
         tbl_wrkd(6) := rcd_fcst_period_input.fcst_date_06;
         tbl_wrkd(7) := rcd_fcst_period_input.fcst_date_07;
         tbl_wrkd(8) := rcd_fcst_period_input.fcst_date_08;
         tbl_wrkd(9) := rcd_fcst_period_input.fcst_date_09;
         tbl_wrkd(10) := rcd_fcst_period_input.fcst_date_10;
         tbl_wrkd(11) := rcd_fcst_period_input.fcst_date_11;
         tbl_wrkd(12) := rcd_fcst_period_input.fcst_date_12;
         tbl_wrkd(13) := rcd_fcst_period_input.fcst_date_13;
         tbl_wrkd(14) := rcd_fcst_period_input.fcst_date_14;
         tbl_wrkd(15) := rcd_fcst_period_input.fcst_date_15;
         tbl_wrkd(16) := rcd_fcst_period_input.fcst_date_16;
         tbl_wrkd(17) := rcd_fcst_period_input.fcst_date_17;
         tbl_wrkd(18) := rcd_fcst_period_input.fcst_date_18;
         tbl_wrkd(19) := rcd_fcst_period_input.fcst_date_19;
         tbl_wrkd(20) := rcd_fcst_period_input.fcst_date_20;
         tbl_wrkd(21) := rcd_fcst_period_input.fcst_date_21;
         tbl_wrkd(22) := rcd_fcst_period_input.fcst_date_22;
         tbl_wrkd(23) := rcd_fcst_period_input.fcst_date_23;
         tbl_wrkd(24) := rcd_fcst_period_input.fcst_date_24;
         tbl_wrkd(25) := rcd_fcst_period_input.fcst_date_25;
         tbl_wrkd(26) := rcd_fcst_period_input.fcst_date_26;
         tbl_wrkq(1) := rcd_fcst_period_input.fcst_case_01;
         tbl_wrkq(2) := rcd_fcst_period_input.fcst_case_02;
         tbl_wrkq(3) := rcd_fcst_period_input.fcst_case_03;
         tbl_wrkq(4) := rcd_fcst_period_input.fcst_case_04;
         tbl_wrkq(5) := rcd_fcst_period_input.fcst_case_05;
         tbl_wrkq(6) := rcd_fcst_period_input.fcst_case_06;
         tbl_wrkq(7) := rcd_fcst_period_input.fcst_case_07;
         tbl_wrkq(8) := rcd_fcst_period_input.fcst_case_08;
         tbl_wrkq(9) := rcd_fcst_period_input.fcst_case_09;
         tbl_wrkq(10) := rcd_fcst_period_input.fcst_case_10;
         tbl_wrkq(11) := rcd_fcst_period_input.fcst_case_11;
         tbl_wrkq(12) := rcd_fcst_period_input.fcst_case_12;
         tbl_wrkq(13) := rcd_fcst_period_input.fcst_case_13;
         tbl_wrkq(14) := rcd_fcst_period_input.fcst_case_14;
         tbl_wrkq(15) := rcd_fcst_period_input.fcst_case_15;
         tbl_wrkq(16) := rcd_fcst_period_input.fcst_case_16;
         tbl_wrkq(17) := rcd_fcst_period_input.fcst_case_17;
         tbl_wrkq(18) := rcd_fcst_period_input.fcst_case_18;
         tbl_wrkq(19) := rcd_fcst_period_input.fcst_case_19;
         tbl_wrkq(20) := rcd_fcst_period_input.fcst_case_20;
         tbl_wrkq(21) := rcd_fcst_period_input.fcst_case_21;
         tbl_wrkq(22) := rcd_fcst_period_input.fcst_case_22;
         tbl_wrkq(23) := rcd_fcst_period_input.fcst_case_23;
         tbl_wrkq(24) := rcd_fcst_period_input.fcst_case_24;
         tbl_wrkq(25) := rcd_fcst_period_input.fcst_case_25;
         tbl_wrkq(26) := rcd_fcst_period_input.fcst_case_26;

         /*-*/
         /* Perform the insert/update for each period 
         /*-*/
         for idx in 1..26 loop

            /*-*/
            /* Only process valid periods
            /*-*/
            if to_char(tbl_wrkd(idx),'yyyymmdd') >= to_char(rcd_fcst_period_input.material_list_price_valid_from,'yyyymmdd') and
               to_char(tbl_wrkd(idx),'yyyymmdd') <= to_char(rcd_fcst_period_input.material_list_price_valid_to,'yyyymmdd') then

               /*-*/
               /* Retrieve the period data
               /*-*/
               var_wrk_date := tbl_wrkd(idx);
               open csr_mars_date;
               fetch csr_mars_date into rcd_mars_date;
               close csr_mars_date;

               /*-*/
               /* Retrieve the forecast period base data
               /*-*/
               open csr_fcst_plan_period;
               fetch csr_fcst_plan_period into rcd_fcst_plan_period;
               if csr_fcst_plan_period%notfound then

                  /*-*/
                  /* Insert the new row as required
                  /*-*/
                  insert into fcst_plan_period
                    (sap_material_code,
                     sap_plant_code,
                     sap_distbn_chnl_code,
                     sap_sales_org_code,
                     material_list_price_year_from,
                     material_list_price_month_from,
                     material_list_price_day_from,
                     material_list_price_year_to,
                     material_list_price_month_to,
                     material_list_price_day_to,
                     material_list_price,
                     publish_date,
                     casting_date,
                     casting_yyyypp,
                     asof_date,
                     asof_yyyypp,
                     fcst_date,
                     fcst_yyyypp,
                     fcst_cases,
                     fcst_prd_lupdp,
                     fcst_prd_lupdt)
                    values (rcd_fcst_period_input.sap_material_code,
                            rcd_fcst_period_input.sap_plant_code,
                            rcd_fcst_period_input.sap_distbn_chnl_code,
                            rcd_fcst_period_input.sap_sales_org_code,
                            to_number(to_char(rcd_fcst_period_input.material_list_price_valid_from,'yyyy')),
                            to_number(to_char(rcd_fcst_period_input.material_list_price_valid_from,'mm')),
                            to_number(to_char(rcd_fcst_period_input.material_list_price_valid_from,'dd')),
                            to_number(to_char(rcd_fcst_period_input.material_list_price_valid_to,'yyyy')),
                            to_number(to_char(rcd_fcst_period_input.material_list_price_valid_to,'mm')),
                            to_number(to_char(rcd_fcst_period_input.material_list_price_valid_to,'dd')),
                            rcd_fcst_period_input.material_list_price,
                            rcd_fcst_period_input.publish_date,
                            rcd_fcst_period_input.casting_date,
                            rcd_mars_date.casting_yyyypp,
                            rcd_fcst_period_input.asof_date,
                            rcd_mars_date.asof_yyyypp,
                            tbl_wrkd(idx),
                            rcd_mars_date.fcst_yyyypp,
                            tbl_wrkq(idx),
                            user,
                            sysdate);

               else

                  /*-*/
                  /* Update the existing row when required
                  /*-*/
                  if rcd_fcst_period_input.publish_date > rcd_fcst_plan_period.publish_date or
                     tbl_wrkq(idx) != rcd_fcst_plan_period.fcst_cases then
                     update fcst_plan_period
                        set sap_material_code = rcd_fcst_period_input.sap_material_code,
                            sap_plant_code = rcd_fcst_period_input.sap_plant_code,
                            sap_distbn_chnl_code = rcd_fcst_period_input.sap_distbn_chnl_code,
                            sap_sales_org_code = rcd_fcst_period_input.sap_sales_org_code,
                            material_list_price_year_from = to_number(to_char(rcd_fcst_period_input.material_list_price_valid_from,'yyyy')),
                            material_list_price_month_from = to_number(to_char(rcd_fcst_period_input.material_list_price_valid_from,'mm')),
                            material_list_price_day_from = to_number(to_char(rcd_fcst_period_input.material_list_price_valid_from,'dd')),
                            material_list_price_year_to = to_number(to_char(rcd_fcst_period_input.material_list_price_valid_to,'yyyy')),
                            material_list_price_month_to = to_number(to_char(rcd_fcst_period_input.material_list_price_valid_to,'mm')),
                            material_list_price_day_to = to_number(to_char(rcd_fcst_period_input.material_list_price_valid_to,'dd')),
                            material_list_price = rcd_fcst_period_input.material_list_price,
                            publish_date = rcd_fcst_period_input.publish_date,
                            casting_date = rcd_fcst_period_input.casting_date,
                            casting_yyyypp = rcd_mars_date.casting_yyyypp,
                            asof_date = rcd_fcst_period_input.asof_date,
                            asof_yyyypp = rcd_mars_date.asof_yyyypp,
                            fcst_date = tbl_wrkd(idx),
                            fcst_yyyypp = rcd_mars_date.fcst_yyyypp,
                            fcst_cases  = tbl_wrkq(idx),
                            fcst_prd_lupdp = user,
                            fcst_prd_lupdt = sysdate
                      where sap_material_code = rcd_fcst_period_input.sap_material_code
                        and sap_plant_code = rcd_fcst_period_input.sap_plant_code
                        and casting_date = rcd_fcst_period_input.casting_date
                        and asof_date = rcd_fcst_period_input.asof_date
                        and fcst_date = tbl_wrkd(idx);
                  end if;

               end if;
               close csr_fcst_plan_period;

            end if;

         end loop;

         /*-*/
         /* Commit the database when required
         /*-*/
	 var_commit_count := var_commit_count + 1;
         if var_commit_count >= var_commit_max then
	    var_commit_count := 0;
            commit;
         end if;

      end loop;
      close csr_fcst_period_input;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - PERIOD Import');

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
            lics_logging.write_log('**ERROR** - PERIOD Import - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - PERIOD Import');
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
   end import_period_data;

end dw_forecast_planning;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_forecast_planning for dw_app.dw_forecast_planning;
grant execute on dw_forecast_planning to public;
