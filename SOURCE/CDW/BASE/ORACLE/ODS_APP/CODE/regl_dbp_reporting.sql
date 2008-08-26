create or replace package regl_dbp_reporting as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : AP Regional DBP
 Package : regl_dbp_reporting
 Owner   : REGL_APP
 Author  : Linden Glen

 Description
 -----------
  AP Regional DBP - Reporting Generation

  PARAMETERS:
    PAR_ACTION : *REPORT - just run reporting without data mart build
                 *BUILD - just build data mart for specified date
                 *BUILD_REPORT - build data mart and run reporting for given date
                 *BUILD_CHK_REPORT - build data mart and only run reporting for given date
                                     if data check passes

    PAR_YYYYMMDD : Date reporting is to be run for - must be YYYYMMDD format.

    PAR_CONTROL : Defines which report to be run

    PAR_RECIPIENT : Defines who will receive the report

 **notes**

 1. A web log is produced where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can
    be raised.


 YYYY/MM   Author            Description
 -------   ------            -----------
 2008/01   Linden Glen       Created
 2008/03   Linden Glen       Removed Thailand footnote - now ex-shipment, not ex-distributor
 2008/06   Linden Glen       Removed 149 inclusion for Australia Petcare, based on Jacob Bell Chambers request
 2008/09   Linden Glen       Changed footnote for SEA units from ex-distributor to ex-shipment

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_action in varchar2,
                     par_date_yyyymmdd in varchar2,
                     par_control in varchar2,
                     par_recipient in varchar2);

end regl_dbp_reporting;
/

create or replace package body ods_app.regl_dbp_reporting as

   /*-*/
   /* Private procedures
   /*    run_ap_cmpny_sgmnt_01 - AP ACTUAL/ORDERS/LY% by Company/Segment
   /*-*/
   procedure run_ap_cmpny_sgmnt01(par_recipient in varchar2, par_mars_yyyyppw in varchar2, par_action in varchar2);
   function getPercentage(par_numerator in number, par_denominator in number) return varchar2;
   procedure write_detail(par_action in varchar2,
                          par_country in varchar2 default null,
                          par_mrkt_sgmnt in varchar2 default null,
                          par_factor_unit in varchar2 default null,
                          par_factor in number default null,
                          par_dbp_ptd_tp_inv_gsv in number default null,
                          par_dbp_ptd_tp_ord_gsv in number default null,
                          par_dbp_prd_tp_op_gsv in number default null,
                          par_dbp_prd_ly_inv_gsv in number default null);

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Global variables
   /*-*/
   glo_tp_date_yyyyppdd varchar2(8 char);
   glo_ly_date_yyyyppdd varchar2(8 char);
   glo_tp_date_yyyyppw varchar2(7 char);
   glo_ly_date_yyyyppw varchar2(7 char);
   glo_email_sender varchar2(256);
   glo_current_fcst varchar2(256);
   glo_sms_gateway varchar2(256);     

   /*-*/
   /* Write Details variables
   /*-*/
   var_wrt_factor_unit varchar2(1 char);
   var_wrt_country varchar2(32 char);
   var_wrt_mrkt_sgmnt varchar2(32 char);
   var_wrt_factor number;
   var_wrt_count number;

   /**/
   /* Define record sets
   /**/
   type rcd_definition is record(dbp_mrkt_sgmnt varchar2(256),
                                 dbp_ptd_tp_inv_gsv number,
                                 dbp_ptd_tp_ord_gsv number,
                                 dbp_prd_tp_op_gsv number,
                                 dbp_prd_ly_inv_gsv number);
   type typ_definition is table of rcd_definition index by binary_integer;
   tbl_section_line typ_definition;
   tbl_section_total rcd_definition;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_action in varchar2,
                     par_date_yyyymmdd in varchar2,
                     par_control in varchar2,
                     par_recipient in varchar2) is

      /*-*/
      /* Local Definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_chk_error boolean;
      var_chk_output varchar2(4000);

      /*-*/
      /* Local Cursors
      /*-*/
      cursor csr_mars_date is
         select a.mars_yyyyppdd,
                a.mars_period as mars_yyyypp,
                a.mars_week
         from mars_date a
         where a.yyyymmdd_date = par_date_yyyymmdd;
      rec_mars_date csr_mars_date%rowtype;

      cursor csr_chk_data is
         select com_code, com_desc, count(*)
         from ods_dbp_company a,
              dds_dbp_week_mart b
         where a.com_code = b.dbp_company_code(+)
           and b.dbp_yyyyppw(+) = glo_tp_date_yyyyppw
         group by com_code, com_desc
         having count(*) = 1;
      rec_chk_data csr_chk_data%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'Regional Sales Reporting ' || par_action || '/' || par_date_yyyymmdd || '/' || par_control || '/' || par_recipient;
      var_log_search := 'REGL_SALES_REPORTING';
      var_chk_error := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Validate the parameters
      /*-*/
      if (upper(par_action) != '*REPORT' and
          upper(par_action) != '*BUILD' and
          upper(par_action) != '*BUILD_REPORT' and
          upper(par_action) != '*BUILD_CHK_REPORT') then
         raise_application_error(-20000, 'PAR_ACTION parameter must be *REPORT, *BUILD, *BUILD_REPORT or *BUILD_CHK_REPORT');
      end if;
      /*-*/
      if (par_control is null) then
         raise_application_error(-20000, 'PAR_CONTROL parameter cannot be null');
      end if;
      /*-*/
      if (par_recipient is null) then
         raise_application_error(-20000, 'PAR_RECIPIENT parameter cannot be null');
      end if;
      /*-*/
      open csr_mars_date;
      fetch csr_mars_date into rec_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Date parameter [' || par_date_yyyymmdd || '] not found in MARS_DATE - Required Format : YYYYMMDD');
      end if;
      close csr_mars_date;

      glo_tp_date_yyyyppdd := rec_mars_date.mars_yyyyppdd;
      glo_ly_date_yyyyppdd := substr(glo_tp_date_yyyyppdd,1,4)-1||substr(glo_tp_date_yyyyppdd,5,4);
      glo_tp_date_yyyyppw := rec_mars_date.mars_week;
      glo_ly_date_yyyyppw := substr(glo_tp_date_yyyyppw,1,4)-1||substr(glo_tp_date_yyyyppw,5,3);

      /*-*/
      /* Retrieve Global Report Settings
      /*-*/
      glo_email_sender := lics_setting_configuration.retrieve_setting('REGL_RPRT_CNTRL','EMAIL_SENDER');
      glo_current_fcst := lics_setting_configuration.retrieve_setting('REGL_RPRT_CNTRL','CURR_FCST_VRSN');
      glo_sms_gateway := lics_setting_configuration.retrieve_setting('REGL_RPRT_CNTRL','SMS_GATEWAY');

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('BEGIN - Regional Sales Reporting - Parameters(' || par_action || '/' || par_date_yyyymmdd || '/' || par_control || ')');

      if (upper(par_action) in ('*BUILD','*BUILD_REPORT','*BUILD_CHK_REPORT')) then
         regl_dbp_aggregation.build_dbp_week_mart(glo_tp_date_yyyyppw);
      end if;

      if (upper(par_action) in ('*BUILD_CHK_REPORT')) then

         lics_logging.write_log('Checking sales data available for Reporting Mars Week: ' || glo_tp_date_yyyyppw);

         open csr_chk_data;
         loop
            fetch csr_chk_data into rec_chk_data;
            if (csr_chk_data%notfound) then
               exit;
            end if;

            if not(var_chk_error) then
               var_chk_output := 'The following companies have no sales for reporting Mars Week : ' || glo_tp_date_yyyyppw || chr(10);
            end if;

            var_chk_error := true;
            var_chk_output := var_chk_output || '(' || rec_chk_data.com_code || ') ' || rec_chk_data.com_desc || chr(10);

            lics_logging.write_log('(' || rec_chk_data.com_code || ') ' || rec_chk_data.com_desc || ' - missing sales data for reporting week');

         end loop;
         close csr_chk_data;

         if (var_chk_error) then
            lics_logging.write_log('Missing Sales Data - stopping reporting');


            lics_notification.send_email('AP_REGIONAL_DBP',
                                         ods_parameter.business_unit_code,
                                         ods_parameter.system_environment,
                                         'AP_REGIONAL_DBP_REPORTING',
                                         'CHECK_SALES_DATA',
                                         lics_setting_configuration.retrieve_setting('REGL_DBP','FAILURE_GRP'),
                                         var_chk_output || chr(10) || ' Refer to web log - ' || lics_logging.callback_identifier);

            return;
         end if;
      end if;

      if (upper(par_control) = '*AP_CMPNY_SGMNT01_DIST' and 
          upper(par_action) in ('*REPORT','*BUILD_REPORT','*BUILD_CHK_REPORT')) then
         run_ap_cmpny_sgmnt01(par_recipient, glo_tp_date_yyyyppw, '*INC_DISTRIBUTOR');

      elsif (upper(par_control) = '*AP_CMPNY_SGMNT01_NODIST' and 
             upper(par_action) in ('*REPORT','*BUILD_REPORT','*BUILD_CHK_REPORT')) then
         run_ap_cmpny_sgmnt01(par_recipient, glo_tp_date_yyyyppw, '*EX_DISTRIBUTOR');

      elsif (upper(par_control) = '*AP_CMPNY_SGMNT01_MFANZ' and 
             upper(par_action) in ('*REPORT','*BUILD_REPORT','*BUILD_CHK_REPORT')) then
         run_ap_cmpny_sgmnt01(par_recipient, glo_tp_date_yyyyppw, '*MFANZ_ONLY');
      else
         raise_application_error(-20000, 'PAR_CONTROL ' || par_control || ' does not exist - must be *AP_CMPNY_SGMNT01_DIST, *AP_CMPNY_SGMNT01_NODIST or *AP_CMPNY_SGMNT01_MFANZ');
      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('END - Regional Sales Reporting');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - REGIONAL_DBP_REPORTING - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /************************************************************************************/
   /* This procedure runs the Regional Summary by Company/Business/LY% Segment Report  */
   /************************************************************************************/
   procedure run_ap_cmpny_sgmnt01(par_recipient in varchar2, par_mars_yyyyppw in varchar2, par_action in varchar2) is

      /*-*/
      /* Local Definitions
      /*-*/
      var_xtrct_date_str varchar2(256);
      var_ema_subject varchar2(256);
      var_output_width number(5);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_prd_position is
         select round(max(bus_day)/max(ttl_day)*100,1) as prd_position,
                max(calendar_date) as rprt_date
         from (select period_bus_day_num as bus_day,
                      null as ttl_day,
                      calendar_date as calendar_date
               from mars_date
               where mars_week = par_mars_yyyyppw
               union all
               select null as bus_day,
                      max(period_bus_day_num) as ttl_day,
                      null as calendar_date
               from mars_date
               where mars_period = substr(glo_tp_date_yyyyppdd,1,6));
      rec_prd_position csr_prd_position%rowtype;

      cursor csr_australia_sales(par_sgmnt varchar2) is
         select dbp_company_desc,
                dbp_aag_code,
                max(dbp_currency) as dbp_currency,
                sum(dbp_ptd_tp_inv_gsv) as dbp_ptd_tp_inv_gsv,
                sum(dbp_ptd_tp_ord_gsv) as dbp_ptd_tp_ord_gsv,
                sum(dbp_prd_tp_op_gsv) as dbp_prd_tp_op_gsv,
                sum(dbp_prd_ly_inv_gsv) as dbp_prd_ly_inv_gsv
         from (select a.dbp_company_code,
                      case
                        when (a.dbp_company_code = '147' and b.bus_sgmnt_code='01') then 'AUS_SNCK'
                        when (a.dbp_company_code = '147' and b.bus_sgmnt_code='02') then 'AUS_FOOD'
                      end as dbp_company_desc,
                      case
                        when a.dbp_aag_code = '01' then 'DOMESTIC'
                        when a.dbp_aag_code = '02' then 'EXPORT'
                        when a.dbp_aag_code = '03' then 'AFFILIATE'
                      end as dbp_aag_code,
                      b.bus_sgmnt_code,
                      a.dbp_currency,
                      a.dbp_ptd_tp_inv_gsv,
                      a.dbp_ptd_tp_ord_gsv,
                      a.dbp_prd_tp_op_gsv,
                      a.dbp_prd_ly_inv_gsv
               from dds_dbp_week_mart a,
                    grd_matl_dim b
               where a.dbp_matl_code = b.matl_code(+)
                 and a.dbp_company_code  = '147'
                 and a.dbp_aag_code in ('01','02','03')
                 and b.bus_sgmnt_code in ('01','02')
                 and a.dbp_yyyyppw = par_mars_yyyyppw)
         where dbp_company_desc = par_sgmnt
         group by dbp_company_desc,
                  dbp_aag_code;
      rec_australia_sales csr_australia_sales%rowtype;

      cursor csr_anz_pet_sales is
         select dbp_aag_code,
                max(dbp_currency) as dbp_currency,
                sum(dbp_ptd_tp_inv_gsv) as dbp_ptd_tp_inv_gsv,
                sum(dbp_ptd_tp_ord_gsv) as dbp_ptd_tp_ord_gsv,
                sum(dbp_prd_tp_op_gsv) as dbp_prd_tp_op_gsv,
                sum(dbp_prd_ly_inv_gsv) as dbp_prd_ly_inv_gsv
         from (select a.dbp_company_code,
                      case
                        when a.dbp_aag_code = '01' then 'DOMESTIC'
                        when a.dbp_aag_code = '02' then 'EXPORT'
                        when a.dbp_aag_code = '03' then 'AFFILIATE'
                      end as dbp_aag_code,
                      a.dbp_currency,
                      a.dbp_ptd_tp_inv_gsv,
                      a.dbp_ptd_tp_ord_gsv,
                      a.dbp_prd_tp_op_gsv,
                      a.dbp_prd_ly_inv_gsv
               from dds_dbp_week_mart a,
                    grd_matl_dim b
               where a.dbp_matl_code = b.matl_code(+)
                 and ((a.dbp_company_code = '147' and b.bus_sgmnt_code = '05' and a.dbp_aag_code in ('01','02','03'))) 
    --              or (a.dbp_company_code = '149' and b.bus_sgmnt_code = '05' and a.dbp_aag_code in ('02','03')))
                 and a.dbp_yyyyppw = par_mars_yyyyppw)
         group by dbp_aag_code;
      rec_anz_pet_sales csr_anz_pet_sales%rowtype;

      cursor csr_anz_unknown_sales is
         select dbp_company_code,
                max(dbp_currency) as dbp_currency,
                sum(dbp_ptd_tp_inv_gsv) as dbp_ptd_tp_inv_gsv,
                sum(dbp_ptd_tp_ord_gsv) as dbp_ptd_tp_ord_gsv,
                sum(dbp_prd_tp_op_gsv) as dbp_prd_tp_op_gsv,
                sum(dbp_prd_ly_inv_gsv) as dbp_prd_ly_inv_gsv
         from (select case
                        when a.dbp_company_code = '147' then 'AUSTRALIA'
                        when a.dbp_company_code = '149' then 'NEW ZEALAND'
                      end as dbp_company_code,
                      a.dbp_currency,
                      a.dbp_ptd_tp_inv_gsv,
                      a.dbp_ptd_tp_ord_gsv,
                      a.dbp_prd_tp_op_gsv,
                      a.dbp_prd_ly_inv_gsv
               from dds_dbp_week_mart a,
                    grd_matl_dim b
               where a.dbp_matl_code = b.matl_code(+)
                 and a.dbp_company_code in ('147','149')
                 and (nvl(b.bus_sgmnt_code,'x') not in ('05','01','02') or
                      a.dbp_aag_code not in ('01','02','03'))
                 and a.dbp_yyyyppw = par_mars_yyyyppw)
         group by dbp_company_code;
      rec_anz_unknown_sales csr_anz_unknown_sales%rowtype;

      cursor csr_nz_dom_sales is
         select bus_sgmnt_code,
                max(dbp_currency) as dbp_currency,
                sum(dbp_ptd_tp_inv_gsv) as dbp_ptd_tp_inv_gsv,
                sum(dbp_ptd_tp_ord_gsv) as dbp_ptd_tp_ord_gsv,
                sum(dbp_prd_tp_op_gsv) as dbp_prd_tp_op_gsv,
                sum(dbp_prd_ly_inv_gsv) as dbp_prd_ly_inv_gsv
         from (select a.dbp_company_code,
                      case
                        when (b.bus_sgmnt_code='01') then 'SNACK'
                        when (b.bus_sgmnt_code='02') then 'FOOD'
                        when (b.bus_sgmnt_code='05') then 'PET'
                      end as bus_sgmnt_code,
                      a.dbp_currency,
                      a.dbp_ptd_tp_inv_gsv,
                      a.dbp_ptd_tp_ord_gsv,
                      a.dbp_prd_tp_op_gsv,
                      a.dbp_prd_ly_inv_gsv
               from dds_dbp_week_mart a,
                    grd_matl_dim b
               where a.dbp_matl_code = b.matl_code(+)
                 and a.dbp_company_code  = '149'
                 and a.dbp_aag_code in ('01')
                 and b.bus_sgmnt_code in ('01','02','05')
                 and a.dbp_yyyyppw = par_mars_yyyyppw)
         group by bus_sgmnt_code;
      rec_nz_dom_sales csr_nz_dom_sales%rowtype;

      cursor csr_regional_sales(par_company varchar2) is
         select dbp_company_code,
                dbp_ctgry_desc,
                max(dbp_currency) as dbp_currency,
                sum(dbp_ptd_tp_inv_gsv) as dbp_ptd_tp_inv_gsv,
                sum(dbp_ptd_tp_ord_gsv) as dbp_ptd_tp_ord_gsv,
                sum(dbp_prd_tp_op_gsv) as dbp_prd_tp_op_gsv,
                sum(dbp_prd_ly_inv_gsv) as dbp_prd_ly_inv_gsv
         from(select dbp_company_code,
                     case
                        when (dbp_aag_code = 'UNKNOWN' or bus_sgmnt_code = 'UNKNOWN') then 'UNKNOWN'
                        else dbp_aag_code || '-' || bus_sgmnt_code
                     end as dbp_ctgry_desc,
                     dbp_currency as dbp_currency,
                     dbp_ptd_tp_inv_gsv as dbp_ptd_tp_inv_gsv,
                     dbp_ptd_tp_ord_gsv as dbp_ptd_tp_ord_gsv,
                     dbp_prd_tp_op_gsv as dbp_prd_tp_op_gsv,
                     dbp_prd_ly_inv_gsv as dbp_prd_ly_inv_gsv
              from (select a.dbp_company_code,
                           case
                             when a.dbp_aag_code = '01' then 'DOM'
                             when a.dbp_aag_code = '02' then 'EXP'
                             when a.dbp_aag_code = '03' then 'AFF'
                             else 'UNKNOWN'
                           end as dbp_aag_code,
                           case
                             when b.bus_sgmnt_code = '01' then 'SNACK'
                             when b.bus_sgmnt_code = '02' then 'FOOD'
                             when b.bus_sgmnt_code = '05' then 'PET'
                             else 'UNKNOWN'
                           end as bus_sgmnt_code,
                           a.dbp_currency,
                           a.dbp_ptd_tp_inv_gsv,
                           a.dbp_ptd_tp_ord_gsv,
                           a.dbp_prd_tp_op_gsv,
                           a.dbp_prd_ly_inv_gsv
                    from dds_dbp_week_mart a,
                         grd_matl_dim b
                    where a.dbp_matl_code = b.matl_code(+)
                      and a.dbp_company_code = par_company
                      and a.dbp_yyyyppw = par_mars_yyyyppw))
         group by dbp_company_code,
                  dbp_ctgry_desc
         order by decode(dbp_ctgry_desc,'UNKNOWN','Z',dbp_ctgry_desc);
      rec_regional_sales csr_regional_sales%rowtype;

      cursor csr_report_cntl(par_dist_type varchar2) is
         select a.com_code,
                a.com_desc,
                a.com_currency,
                a.com_rprt_factor,
                a.com_rprt_uom
         from ods_dbp_company a
         where (com_distributor = par_dist_type or 
                nvl(com_distributor,'z') = nvl(par_dist_type,'z')
           and com_source = '*REGL');
      rec_report_cntl csr_report_cntl%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('BEGIN - AP BY COMPANY/SEGMENT v LY - Parameters (' || nvl(par_recipient,'*NONE') || ' + ' || par_mars_yyyyppw || ' + ' || nvl(par_action,'*NONE') || ')');

      /*-*/
      /* Define Extract Date String
      /*-*/
      select trim(to_char(sysdate,'DAY')) || ', ' ||
             trim(to_char(sysdate,'DD')) || ' ' ||
             trim(to_char(sysdate,'MONTH')) || ' ' ||
             trim(to_char(sysdate,'YYYY'))
      into var_xtrct_date_str
      from dual;

      /*-*/
      /* Define/Initialise variables
      /*-*/
      var_ema_subject := lics_setting_configuration.retrieve_setting('RPRT_AP_CMPNY_SGMNT01', 'EMAIL_SUBJECT') || ' for D' || substr(glo_tp_date_yyyyppdd,7,2) || ' W' || substr(glo_tp_date_yyyyppw,7,1) || ' P' || substr(glo_tp_date_yyyyppdd,5,2) || ' ' || substr(glo_tp_date_yyyyppdd,1,4);
      var_output_width := 97;

      /*-*/
      /* Retrieve Period Position
      /*-*/
      open csr_prd_position;
      fetch csr_prd_position into rec_prd_position;
      if (csr_prd_position%notfound) then
         raise_application_error(-20000, 'FATAL ERROR: Cursor CSR_PRD_POSITION returned no results');
      end if;
      close csr_prd_position;

      /*-*/
      /* Create Mailer Interface
      /*-*/
      isi_mailer.create_email(par_recipient,var_ema_subject,null,null);

      /*-*/
      /* Write Report Header
      /*-*/
      isi_mailer.append_data(rpad('-',var_output_width,'-'));
      isi_mailer.append_data('                                   ASIA PACIFIC - REGIONAL DBP SUMMARY REPORT');
      isi_mailer.append_data('                          Extracted on ' || var_xtrct_date_str || ' for D' || substr(glo_tp_date_yyyyppdd,7,2) || ', W' || substr(glo_tp_date_yyyyppw,7,1) || ', P' || substr(glo_tp_date_yyyyppdd,5,2) || ' ' || substr(glo_tp_date_yyyyppdd,1,4));
      isi_mailer.append_data(rpad('-',var_output_width,'-'));
      isi_mailer.append_data('                                             INVOICE TARGET: ' || rec_prd_position.prd_position || '%');
      isi_mailer.append_data(rpad('_',var_output_width,'_'));

      isi_mailer.append_data(null);
      isi_mailer.append_data(null);

      isi_mailer.append_data('                                 ----------------------------------------------------------------');
      isi_mailer.append_data('                                 |                 INVOICES                |         ORDERS     |');
      isi_mailer.append_data(rpad('-',var_output_width,'-'));
      isi_mailer.append_data('|   COUNTRY         | MRKT/SGMNT |   PTD      | PLAN       | PLAN% | LY%   |   PTD      | PLAN% |');
      isi_mailer.append_data(rpad('=',var_output_width,'='));

      /*-*/
      /* ANZ Unknown : Generate and Output
      /*-*/
      write_detail('*START','ANZ UNKNOWN',null,'m',1000000);

      open csr_anz_unknown_sales;
      loop
         fetch csr_anz_unknown_sales into rec_anz_unknown_sales;
         if (csr_anz_unknown_sales%notfound) then
            exit;
         end if;

         write_detail('*DETAIL', null, rec_anz_unknown_sales.dbp_company_code, null, null,
                      rec_anz_unknown_sales.dbp_ptd_tp_inv_gsv,
                      rec_anz_unknown_sales.dbp_ptd_tp_ord_gsv,
                      rec_anz_unknown_sales.dbp_prd_tp_op_gsv,
                      rec_anz_unknown_sales.dbp_prd_ly_inv_gsv);

      end loop;
      close csr_anz_unknown_sales;

      write_detail('*END');
      isi_mailer.append_data(rpad('-',var_output_width,'-'));

      /*-*/
      /* PETCARE : Generate and Output
      /*-*/
      write_detail('*START','Australia Petcare',null,'m',1000000);

      open csr_anz_pet_sales;
      loop
         fetch csr_anz_pet_sales into rec_anz_pet_sales;
         if (csr_anz_pet_sales%notfound) then
            exit;
         end if;

         write_detail('*DETAIL', null, rec_anz_pet_sales.dbp_aag_code, null, null,
                      rec_anz_pet_sales.dbp_ptd_tp_inv_gsv,
                      rec_anz_pet_sales.dbp_ptd_tp_ord_gsv,
                      rec_anz_pet_sales.dbp_prd_tp_op_gsv,
                      rec_anz_pet_sales.dbp_prd_ly_inv_gsv);

      end loop;
      close csr_anz_pet_sales;

      write_detail('*END');
      isi_mailer.append_data(rpad('-',var_output_width,'-'));

      /*-*/
      /* SNACKFOOD : Generate and Output
      /*-*/
      write_detail('*START','Australia Snack',null,'m',1000000);

      open csr_australia_sales('AUS_SNCK');
      loop
         fetch csr_australia_sales into rec_australia_sales;
         if (csr_australia_sales%notfound) then
            exit;
         end if;

         write_detail('*DETAIL', null, rec_australia_sales.dbp_aag_code, null, null,
                      rec_australia_sales.dbp_ptd_tp_inv_gsv,
                      rec_australia_sales.dbp_ptd_tp_ord_gsv,
                      rec_australia_sales.dbp_prd_tp_op_gsv,
                      rec_australia_sales.dbp_prd_ly_inv_gsv);

      end loop;
      close csr_australia_sales;

      write_detail('*END');
      isi_mailer.append_data(rpad('-',var_output_width,'-'));

      /*-*/
      /* FOOD : Generate and Output
      /*-*/
      write_detail('*START','Australia Food',null,'m',1000000);

      open csr_australia_sales('AUS_FOOD');
      loop
         fetch csr_australia_sales into rec_australia_sales;
         if (csr_australia_sales%notfound) then
            exit;
         end if;

         write_detail('*DETAIL', null, rec_australia_sales.dbp_aag_code, null, null,
                      rec_australia_sales.dbp_ptd_tp_inv_gsv,
                      rec_australia_sales.dbp_ptd_tp_ord_gsv,
                      rec_australia_sales.dbp_prd_tp_op_gsv,
                      rec_australia_sales.dbp_prd_ly_inv_gsv);

      end loop;
      close csr_australia_sales;

      write_detail('*END');
      isi_mailer.append_data(rpad('-',var_output_width,'-'));

      /*-*/
      /* NZ DOMESTIC : Generate and Output
      /*-*/
      write_detail('*START','NZ DOMESTIC (AUD)',null,'m',1000000);

      open csr_nz_dom_sales;
      loop
         fetch csr_nz_dom_sales into rec_nz_dom_sales;
         if (csr_nz_dom_sales%notfound) then
            exit;
         end if;

         write_detail('*DETAIL', null, rec_nz_dom_sales.bus_sgmnt_code, null, null,
                      rec_nz_dom_sales.dbp_ptd_tp_inv_gsv,
                      rec_nz_dom_sales.dbp_ptd_tp_ord_gsv,
                      rec_nz_dom_sales.dbp_prd_tp_op_gsv,
                      rec_nz_dom_sales.dbp_prd_ly_inv_gsv);

      end loop;
      close csr_nz_dom_sales;

      write_detail('*END');
      isi_mailer.append_data(rpad('=',var_output_width,'='));


      if (nvl(par_action,'x') != '*MFANZ_ONLY') then

         /*-*/
         /* REGIONAL MARKETS : Generate and Output
         /*-*/
         open csr_report_cntl(null);
         loop
            fetch csr_report_cntl into rec_report_cntl;
            if (csr_report_cntl%notfound) then
               exit;
            end if;

            write_detail('*START', 
                         rec_report_cntl.com_desc || ' (' || rec_report_cntl.com_currency || ')', 
                         'TOTAL', 
                         rec_report_cntl.com_rprt_uom, 
                         rec_report_cntl.com_rprt_factor);

            open csr_regional_sales(rec_report_cntl.com_code);
            loop
               fetch csr_regional_sales into rec_regional_sales;
               if (csr_regional_sales%notfound) then
                  exit;
               end if;

               write_detail('*DETAIL', null, rec_regional_sales.dbp_ctgry_desc, null, null,
                            rec_regional_sales.dbp_ptd_tp_inv_gsv,
                            rec_regional_sales.dbp_ptd_tp_ord_gsv,
                            rec_regional_sales.dbp_prd_tp_op_gsv,
                            rec_regional_sales.dbp_prd_ly_inv_gsv);

            end loop;
            close csr_regional_sales;

            write_detail('*END');
            isi_mailer.append_data(rpad('-',var_output_width,'-'));

         end loop;
         close csr_report_cntl;


         /*-*/
         /* REGIONAL DISTRIBUTOR MARKETS : Generate and Output
         /*-*/
         if (par_action = '*INC_DISTRIBUTOR') then

            open csr_report_cntl('x');
            loop
               fetch csr_report_cntl into rec_report_cntl;
               if (csr_report_cntl%notfound) then
                  exit;
               end if;

               write_detail('*START', 
                            rec_report_cntl.com_desc || ' (' || rec_report_cntl.com_currency || ')', 
                            'TOTAL', 
                            rec_report_cntl.com_rprt_uom, 
                            rec_report_cntl.com_rprt_factor);

               open csr_regional_sales(rec_report_cntl.com_code);
               loop
                  fetch csr_regional_sales into rec_regional_sales;
                  if (csr_regional_sales%notfound) then
                     exit;
                  end if;

                  write_detail('*DETAIL', null, rec_regional_sales.dbp_ctgry_desc, null, null,
                               rec_regional_sales.dbp_ptd_tp_inv_gsv,
                               rec_regional_sales.dbp_ptd_tp_ord_gsv,
                               rec_regional_sales.dbp_prd_tp_op_gsv,
                               rec_regional_sales.dbp_prd_ly_inv_gsv);

               end loop;
               close csr_regional_sales;

               write_detail('*END');
               isi_mailer.append_data(rpad('-',var_output_width,'-'));

            end loop;
            close csr_report_cntl;

         end if;
      end if;

      /*-*/
      /* Write report footer
      /*-*/
      isi_mailer.append_data(null);
      isi_mailer.append_data('Notes : ');
      isi_mailer.append_data('   * This is an automated report sourced from market Datawarehouses.');
      isi_mailer.append_data('     Please email "AP Web/Notes Support" for any support issues/queries you may have');
	  isi_mailer.append_data('  ');
      isi_mailer.append_data('   * Australia Petcare - Does not include NZ Factory and Birdcare affiliate sales.');
      isi_mailer.append_data('                       - Does not include foreign exchange gains or losses');
	  isi_mailer.append_data('  ');
      isi_mailer.append_data('   * Singapore, Malaysia, Brunei, Indochina, Vietnam');
      isi_mailer.append_data('                       - values are ex-shipment (not ex-distributor)');
	  isi_mailer.append_data('  ');
      isi_mailer.append_data('   * Taiwan - values are GSV (vs AP Flash report which is Net GSV)');
	  
      /*-*/
      /* Finalise Email Interface
      /*-*/
      isi_mailer.finalise_email(glo_email_sender);


      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('END - AP BY COMPANY/SEGMENT');

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - RUN_AP_CMPNY_SGMNT01 - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end run_ap_cmpny_sgmnt01;

   /******************************************************************/
   /* This procedure performs the write_detail routine for 01 report */
   /******************************************************************/
   procedure write_detail(par_action in varchar2,
                          par_country in varchar2 default null,
                          par_mrkt_sgmnt in varchar2 default null,
                          par_factor_unit in varchar2 default null,
                          par_factor in number default null,
                          par_dbp_ptd_tp_inv_gsv in number default null,
                          par_dbp_ptd_tp_ord_gsv in number default null,
                          par_dbp_prd_tp_op_gsv in number default null,
                          par_dbp_prd_ly_inv_gsv in number default null) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      if (par_action = '*START') then

         tbl_section_line.delete;
         tbl_section_total.dbp_ptd_tp_inv_gsv := 0;
         tbl_section_total.dbp_ptd_tp_ord_gsv := 0;
         tbl_section_total.dbp_prd_tp_op_gsv := 0;
         tbl_section_total.dbp_prd_ly_inv_gsv := 0;

         var_wrt_factor_unit := par_factor_unit;
         var_wrt_factor := nvl(par_factor,1);
         var_wrt_country := par_country;
         var_wrt_count := 0;

      elsif (par_action = '*DETAIL') then

         var_wrt_count := var_wrt_count+1;

         tbl_section_line(var_wrt_count).dbp_mrkt_sgmnt := par_mrkt_sgmnt;
         tbl_section_line(var_wrt_count).dbp_ptd_tp_inv_gsv := par_dbp_ptd_tp_inv_gsv;
         tbl_section_line(var_wrt_count).dbp_ptd_tp_ord_gsv := par_dbp_ptd_tp_ord_gsv;
         tbl_section_line(var_wrt_count).dbp_prd_tp_op_gsv := par_dbp_prd_tp_op_gsv;
         tbl_section_line(var_wrt_count).dbp_prd_ly_inv_gsv := par_dbp_prd_ly_inv_gsv;

         tbl_section_total.dbp_ptd_tp_inv_gsv := tbl_section_total.dbp_ptd_tp_inv_gsv + nvl(par_dbp_ptd_tp_inv_gsv,0);
         tbl_section_total.dbp_ptd_tp_ord_gsv := tbl_section_total.dbp_ptd_tp_ord_gsv + nvl(par_dbp_ptd_tp_ord_gsv,0);
         tbl_section_total.dbp_prd_tp_op_gsv := tbl_section_total.dbp_prd_tp_op_gsv + nvl(par_dbp_prd_tp_op_gsv,0);
         tbl_section_total.dbp_prd_ly_inv_gsv := tbl_section_total.dbp_prd_ly_inv_gsv + nvl(par_dbp_prd_ly_inv_gsv,0);

      elsif (par_action = '*END') then

         isi_mailer.append_data('| ' || rpad(nvl(var_wrt_country,' '),18,' ') ||
                                '| ' || rpad('TOTAL',11,' ') ||
                                '| ' || lpad(nvl(to_char(round(tbl_section_total.dbp_ptd_tp_inv_gsv/var_wrt_factor,2)),0)||var_wrt_factor_unit,11,' ') ||
                                '| ' || lpad(nvl(to_char(round(tbl_section_total.dbp_prd_tp_op_gsv/var_wrt_factor,2)),0)||var_wrt_factor_unit,11,' ') ||
                                '| ' || rpad(getPercentage(tbl_section_total.dbp_ptd_tp_inv_gsv, tbl_section_total.dbp_prd_tp_op_gsv)||'%',6,' ') ||
                                '| ' || rpad(getPercentage(tbl_section_total.dbp_ptd_tp_inv_gsv, tbl_section_total.dbp_prd_ly_inv_gsv)||'%',6,' ') ||
                                '| ' || lpad(nvl(to_char(round(tbl_section_total.dbp_ptd_tp_ord_gsv/var_wrt_factor,2)),0)||var_wrt_factor_unit,11,' ') ||
                                '| ' || rpad(getPercentage(tbl_section_total.dbp_ptd_tp_ord_gsv, tbl_section_total.dbp_prd_tp_op_gsv)||'%',6,' ') ||
                                '|');


         for idx in 1..tbl_section_line.count loop

            isi_mailer.append_data('| ' || rpad(' ',18,' ') ||
                                   '| ' || rpad(nvl(tbl_section_line(idx).dbp_mrkt_sgmnt,' '),11,' ') ||
                                   '| ' || lpad(nvl(to_char(round(tbl_section_line(idx).dbp_ptd_tp_inv_gsv/var_wrt_factor,2)),0)||var_wrt_factor_unit,11,' ') ||
                                   '| ' || lpad(nvl(to_char(round(tbl_section_line(idx).dbp_prd_tp_op_gsv/var_wrt_factor,2)),0)||var_wrt_factor_unit,11,' ') ||
                                   '| ' || rpad(getPercentage(tbl_section_line(idx).dbp_ptd_tp_inv_gsv, tbl_section_line(idx).dbp_prd_tp_op_gsv)||'%',6,' ') ||
                                   '| ' || rpad(getPercentage(tbl_section_line(idx).dbp_ptd_tp_inv_gsv, tbl_section_line(idx).dbp_prd_ly_inv_gsv)||'%',6,' ') ||
                                   '| ' || lpad(nvl(to_char(round(tbl_section_line(idx).dbp_ptd_tp_ord_gsv/var_wrt_factor,2)),0)||var_wrt_factor_unit,11,' ') ||
                                   '| ' || rpad(getPercentage(tbl_section_line(idx).dbp_ptd_tp_ord_gsv, tbl_section_line(idx).dbp_prd_tp_op_gsv)||'%',6,' ') ||
                                   '|');

         end loop;

      else
         raise_application_error(-20000, '**ERROR** WRITE_DETAIL : Unknown Action Parameter');
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end write_detail;

   /*************************************************/
   /* This function returns a percentage value      */
   /*************************************************/
   function getPercentage(par_numerator in number,
                          par_denominator in number) return varchar2 is

      var_percentage number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      if (par_denominator = 0 or
          par_denominator is null) then
         return '-';
      else
         var_percentage := round(((par_numerator/par_denominator)*100),1);
      end if;


      if (var_percentage > 999.9) then
         return '>999'; 
      elsif (nvl(var_percentage,0) = 0) then
         return '-'; 
      else
         return to_char(var_percentage,'FM999.0');
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end getPercentage;

end regl_dbp_reporting;
/

/**/
/* Authority
/**/
grant execute on regl_dbp_reporting to lics_app;
grant execute on regl_dbp_reporting to ods_app;

/**/
/* Synonym
/**/
create or replace public synonym regl_dbp_reporting for ods_app.regl_dbp_reporting;
