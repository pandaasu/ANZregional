/******************/
/* Package Header */
/******************/
create or replace package df_email as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : ips
    Package : df_email
    Owner   : df_app
    Author  : Steve Gregan

    Description
    -----------
    Integrated Planning Demand Financials - Email

    This package contain the procedures for emailing.

    **notes**
    1. A web log is produced under the search value DF_EMAIL where all errors are logged.

    1. All errors will raise an exception to the calling application so that an alert can
       be raised.

    YYYY/MM   Author             Description
    -------   ------             -----------
    2009/01   Steve Gregan       Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure forecast_alert(par_fcst_id in number);

end df_email; 
/

/****************/
/* Package Body */
/****************/
create or replace package body df_email as

   /*-*/
   /* Private exceptions 
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /******************************************************/
   /* This procedure performs the forecast alert routine */
   /******************************************************/
   procedure forecast_alert(par_fcst_id in number) is

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
      v_result_msg varchar2(3900);
      v_heading boolean;
      v_qty_total common.st_value;
      v_counter common.st_counter;
      v_group_members common.t_strings;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DF Email Forecast Alert';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_fcst is
         select t01.*
           from fcst t01
          where t01.fcst_id = par_fcst_id;
      rcd_fcst csr_fcst%rowtype;

      cursor csr_missing_prices(i_fcst_id in common.st_id) is
         SELECT e.acct_assign_name, a.zrep, (SELECT t0.matl_desc
                                              FROM matl t0
                                              WHERE t0.matl_code = reference_functions.full_matl_code (zrep) ) AS zrep_desc, a.tdu,
            ROUND (SUM (qty_in_base_uom) ) AS qty
          FROM dmnd_data a, dmnd_grp b, dmnd_grp_org c, dmnd_grp_type d, dmnd_acct_assign e
          WHERE a.fcst_id = i_fcst_id AND
           a.price IS NULL AND
           a.dmnd_grp_org_id = c.dmnd_grp_org_id AND
           b.dmnd_grp_id = c.dmnd_grp_id AND
           b.dmnd_grp_type_id = d.dmnd_grp_type_id AND
           c.acct_assign_id = e.acct_assign_id
          GROUP BY e.acct_assign_name, a.zrep, a.tdu;

      cursor csr_missing_determination(i_fcst_id in common.st_id) is
         SELECT e.acct_assign_name, a.zrep, (SELECT t0.matl_desc
                                              FROM matl t0
                                              WHERE t0.matl_code = reference_functions.full_matl_code (zrep) ) AS zrep_desc, SUM (qty_in_base_uom) AS qty
          FROM dmnd_data a, dmnd_grp b, dmnd_grp_org c, dmnd_grp_type d, dmnd_acct_assign e
          WHERE a.fcst_id = i_fcst_id AND
           a.tdu IS NULL AND
           a.dmnd_grp_org_id = c.dmnd_grp_org_id AND
           b.dmnd_grp_id = c.dmnd_grp_id AND
           b.dmnd_grp_type_id = d.dmnd_grp_type_id AND
           c.acct_assign_id = e.acct_assign_id
          GROUP BY e.acct_assign_name, a.zrep;

      cursor csr_negative_forecast(i_fcst_id in common.st_id) is
         SELECT e.acct_assign_name, b.dmnd_grp_name, a.zrep, (SELECT t0.matl_desc
                                                               FROM matl t0
                                                               WHERE t0.matl_code = reference_functions.full_matl_code (zrep) ) AS zrep_desc, a.mars_week,
            ROUND (SUM (qty_in_base_uom) ) AS qty
          FROM dmnd_data a, dmnd_grp b, dmnd_grp_org c, dmnd_grp_type d, dmnd_acct_assign e
          WHERE a.fcst_id = i_fcst_id AND
           a.dmnd_grp_org_id = c.dmnd_grp_org_id AND
           b.dmnd_grp_id = c.dmnd_grp_id AND
           b.dmnd_grp_type_id = d.dmnd_grp_type_id AND
           c.acct_assign_id = e.acct_assign_id
          GROUP BY e.acct_assign_name, b.dmnd_grp_name, a.mars_week, a.zrep
          HAVING SUM (qty_in_base_uom) <= -1
          ORDER BY acct_assign_name, dmnd_grp_name, mars_week;

      cursor csr_matl_moe(i_fcst_id in common.st_id) is
         SELECT t10.matl_code, t20.matl_desc
          FROM (SELECT DISTINCT zrep AS matl_code
                FROM dmnd_data t1
                WHERE fcst_id = i_fcst_id) t10,
            matl t20
          WHERE reference_functions.full_matl_code (t10.matl_code) = t20.matl_code AND
           NOT EXISTS (SELECT *
                       FROM matl_moe t0
                       WHERE t0.matl_code = reference_functions.full_matl_code (t10.matl_code) AND t0.item_usage_code IN ('BUY', 'MKE', 'COP') )
          UNION
          SELECT t10.matl_code, t20.matl_desc
          FROM (SELECT DISTINCT tdu AS matl_code
                FROM dmnd_data t1
                WHERE fcst_id = i_fcst_id) t10,
            matl t20
          WHERE reference_functions.full_matl_code (t10.matl_code) = t20.matl_code AND
           NOT EXISTS (SELECT *
                       FROM matl_moe t0
                       WHERE t0.matl_code = reference_functions.full_matl_code (t10.matl_code) AND t0.item_usage_code IN ('BUY', 'MKE', 'COP') );

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the procedure
      /*-*/
      var_log_prefix := 'DF - EMAIL_FORECAST_ALERT';
      var_log_search := 'DF_EMAIL_FORECAST_ALERT' || '_' || to_char(par_fcst_id);
      var_loc_string := lics_stream_processor.callback_lock;
      var_alert := lics_stream_processor.callback_alert;
      var_email := lics_stream_processor.callback_email;
      var_errors := false;
      var_locked := false;
      if var_loc_string is null then
         raise_application_error(-20000, 'Stream lock not returned - must be executed from the ICS Stream Processor');
      end if;

      /*-*/
      /* Retrieve the forecast
      /*-*/
      open csr_fcst;
      fetch csr_fcst into rcd_fcst;
      if csr_fcst%notfound then
         raise_application_error(-20000, 'Forecast ' || to_char(par_fcst_id) || ' not found');
      end if;
      close csr_fcst;

      /*-*/
      /* Required for invoked demand financials functions
      /* **notes** 1. NEW_LOG required because ICS job processes multiple requests
      /*           2. Should be removed as existing functions replaced
      /*-*/
      logit.new_log;
      logit.enter_method('DF_EMAIL', 'FORECAST_ALERT');
      logit.log('**ICS_START**');

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Log the event start
      /*-*/
      lics_logging.write_log('Begin - Email Forecast Alert - Parameters(' || to_char(par_fcst_id) || ')');

      /*-*/
      /* Create and send the forecast alert email
      /*-*/
      begin

         /*-*/
         /* Create the email
         /*-*/
         if emailit.create_email(null, 'DEMAND FINANCIALS EMAIL ALERT', v_result_msg) != common.gc_success then
            raise_application_error(-20000, 'Email creation failed - '||v_result_msg);
         end if;

         /*-*/
         /* Get list of email address to sent message to
         /*-*/
         if security.get_group_user_emails(demand_forecast.gc_demand_alerting_group || ' ' || rcd_fcst.moe_code, v_group_members, v_result_msg) = common.gc_success then
            for idx in v_group_members.first..v_group_members.last loop
               if emailit.add_recipient(emailit.gc_area_to, emailit.gc_type_user, v_group_members(idx), null, v_result_msg) != common.gc_success then
                  raise_application_error(-20000, 'Add recipient failed - '||v_result_msg);
               end if;
            end loop;
         else
            raise_application_error(-20000, 'Failed to find mailing list - '||v_result_msg);
         end if;

         /*-*/
         /* Email heading
         /*-*/
         if rcd_fcst.forecast_type = demand_forecast.gc_ft_fcst then
            emailit.add_content ('Demand Financials Completed Forecast Missing Data Report.');
            emailit.add_content ('---------------------------------------------------------');
            emailit.add_content ('The following forecast has just completed processing a supply file');
            emailit.add_content ('and demand file.  If there are any problems with this forecast they');
            emailit.add_content ('will be summarised below. Please run the Missing Demand Data report');
            emailit.add_content ('to find out more detail about any reported issues.');
            emailit.add_content (common.gc_crlf);
            emailit.add_content ('## Forecast ID : ' || rcd_fcst.fcst_id);
            emailit.add_content ('   - Created : ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );
            emailit.add_content ('   - Casting Week : ' || rcd_fcst.casting_year || LPAD (rcd_fcst.casting_period, 2, '0') || rcd_fcst.casting_week);
            emailit.add_content ('   - MOE Code : ' || rcd_fcst.moe_code);
            emailit.add_content (common.gc_crlf);
         else
            emailit.add_content ('Demand Financials Completed Draft Forecast Missing Data Report.');
            emailit.add_content ('---------------------------------------------------------------');
            emailit.add_content ('The following forecast has just completed processing a demand draft');
            emailit.add_content ('file.  If there are any problems with this forecast they will be');
            emailit.add_content ('summarised below. Please run the Missing Demand Data report to find');
            emailit.add_content ('out more detail about any reported issues.');
            emailit.add_content (common.gc_crlf);
            emailit.add_content ('## Forecast ID : ' || rcd_fcst.fcst_id);
            emailit.add_content ('   - Created : ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY HH24:MI:SS') );
            emailit.add_content ('   - Casting Week : ' || rcd_fcst.casting_year || LPAD (rcd_fcst.casting_period, 2, '0') || rcd_fcst.casting_week);
            emailit.add_content ('   - MOE Code : ' || rcd_fcst.moe_code);
            emailit.add_content (common.gc_crlf);
         end if;
         emailit.add_content('## Forecast Issues');

         /*-*/
         /* Material determination
         /*-*/
         v_heading := false;
         v_qty_total := 0;
         v_counter := 0;
         for rv_determination in csr_missing_determination(rcd_fcst.fcst_id) loop
            if v_heading = false then
               emailit.add_content('   * Material Determination Issues Were Detected.');
               v_heading := true;
            end if;
            emailit.add_content(   '     - '
                                || rv_determination.acct_assign_name
                                || ', ZREP: '
                                || rv_determination.zrep
                                || '-'
                                || rv_determination.zrep_desc
                                || ', QTY:'
                                || rv_determination.qty);
            v_counter := v_counter + 1;
            v_qty_total := v_qty_total + rv_determination.qty;
         end loop;
         if v_heading = false then
            emailit.add_content('   * No Missing Material Determination Issues Detected.');
         else
            emailit.add_content('     - Total Issues : ' || v_counter || ', Total Quantity Affected : ' || v_qty_total);
         end if;

         /*-*/
         /* Pricing
         /*-*/
         v_heading := false;
         v_qty_total := 0;
         v_counter := 0;
         for rv_price IN csr_missing_prices(rcd_fcst.fcst_id) loop
            if v_heading = false then
               emailit.add_content('   * Pricing Issues Were Detected.');
               v_heading := true;
            end if;
            emailit.add_content(   '     - '
                                || rv_price.acct_assign_name
                                || ', ZREP: '
                                || rv_price.zrep
                                || '-'
                                || rv_price.zrep_desc
                                || ', TDU:'
                                || rv_price.tdu
                                || ', QTY:'
                                || rv_price.qty);
            v_counter := v_counter + 1;
            v_qty_total := v_qty_total + rv_price.qty;
         end loop;
         if v_heading = false then
            emailit.add_content('   * No Pricing Issues Detected.');
         else
            emailit.add_content('     - Total Issues : ' || v_counter || ', Total Quantity Affected : ' || v_qty_total);
         end if;

         /*-*/
         /* Negative forecasts
         /*-*/
         v_heading := false;
         v_qty_total := 0;
         v_counter := 0;
         for rv_negative in csr_negative_forecast(rcd_fcst.fcst_id) loop
            if v_heading = false then
               emailit.add_content('   * Negative Forecast Issues Were Detected.');
               v_heading := true;
            end if;
            emailit.add_content(   '     - '
                                || rv_negative.acct_assign_name
                                || ', '
                                || rv_negative.dmnd_grp_name
                                || ', Mars Week:'
                                || rv_negative.mars_week
                                || ', ZREP: '
                                || rv_negative.zrep
                                || '-'
                                || rv_negative.zrep_desc
                                || ', QTY:'
                                || rv_negative.qty);
            v_counter := v_counter + 1;
            v_qty_total := v_qty_total + rv_negative.qty;
         end loop;
         if v_heading = false then
            emailit.add_content('   * No Negative Forecast Issues Detected.');
         else
            emailit.add_content('     - Total Issues : ' || v_counter || ', Total Quantity Affected : ' || v_qty_total);
         end if;

         /*-*/
         /* Material moe
         /*-*/
         v_heading := false;
         v_counter := 0;
         for rv_matl_moe in csr_matl_moe(rcd_fcst.fcst_id) loop
            if v_heading = false then
               emailit.add_content('   * The Following Materials have missing MOE information.');
               v_heading := true;
            end if;
            emailit.add_content('     - ' || rv_matl_moe.matl_code || ', ' || rv_matl_moe.matl_desc);
            v_counter := v_counter + 1;
         end loop;
         if v_heading = false then
            emailit.add_content ('   * No Material MOE Issues Detected.');
         else
            emailit.add_content ('     - Total Issues : ' || v_counter);
         end if;

         /*-*/
         /* Send the email
         /*-*/
         if emailit.send_email(v_result_msg) != common.gc_success then
            raise_application_error(-20000, 'Email send failed - '||v_result_msg);
         end if;

      /*-*/
      /* Email exception
      /*-*/
      exception
         when others then
            var_errors := true;
            lics_logging.write_log('--> Email forecast alert failed - '||substr(SQLERRM, 1, 3000));
      end;

      /*-*/
      /* Log the event end
      /*-*/
      lics_logging.write_log('End - Email Forecast Alert');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Required for invoked demand financials functions
      /* **notes** 1. Should be removed as existing functions replaced
      /*-*/
      logit.log('**ICS_END**');
      logit.leave_method;

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
            lics_notification.send_email(df_parameter.system_code,
                                         df_parameter.system_unit,
                                         df_parameter.system_environment,
                                         con_function,
                                         'DF_EMAIL_FORECAST_ALERT',
                                         var_email,
                                         'One or more errors occurred during the Demand Financials Email Forecast Alert execution - refer to web log - ' || lics_logging.callback_identifier);
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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - DF_EMAIL - FORECAST ALERT - ' || var_exception);

   end forecast_alert;

end df_email; 
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym df_email for df_app.df_email;
grant execute on df_email to public;
