/******************/
/* Package Header */
/******************/
create or replace package dw_fcst_aggregation as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : dw_fcst_aggregation
    Owner   : dw_app

    Description
    -----------
    Dimensional Data Store - Forecast Aggregation

    This package contain the forecast aggregation procedures. The package exposes one
    procedure EXECUTE that performs the aggregation based on the following parameters:

    1. PAR_COMPANY (company code) (MANDATORY)

       The company for which the aggregation is to be performed.

    **notes**
    1. A web log is produced under the search value DW_FCST_AGGREGATION where all errors are logged.

    2. All errors will raise an exception to the calling application so that an alert can
       be raised.

    3. All base tables will attempt to be aggregated and and errors logged.

    4. A deadly embrace with scheduled aggregation is avoided by all data warehouse components
       use the same process isolation locking string and sharing the same ICS stream code.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/08   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_company in varchar2);

end dw_fcst_aggregation;
/

/****************/
/* Package Body */
/****************/
create or replace package body dw_fcst_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure fcst_fact_brhist_load(par_company_code in varchar2, par_fcst_code in varchar2, par_cast_yyyypp in number);

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
   procedure execute(par_company in varchar2) is

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
      var_process_date varchar2(8);
      var_process_code varchar2(32);
      var_cast_yyyypp number(6,0);
      var_cam1_yyyypp number(6,0);
      var_cam2_yyyypp number(6,0);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'DW Forecast Aggregation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_company is
         select t01.*
           from company t01
          where t01.company_code = par_company;
      rcd_company csr_company%rowtype;

      cursor csr_mars_date is
         select t01.mars_period
           from mars_date t01
          where trunc(t01.calendar_date) = to_date(var_process_date,'yyyymmdd');
      rcd_mars_date csr_mars_date%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'DW - FORECAST_AGGREGATION';
      var_log_search := 'DW_FORECAST_AGGREGATION' || '_' || lics_stream_processor.callback_event;
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

      /*-*/
      /* Aggregation date is always based on the previous day (converted using the company timezone)
      /*-*/
      var_date := trunc(sysdate);
      var_process_date := to_char(var_date-1,'yyyymmdd');
      var_process_code := 'FORECAST_AGGREGATION_'||var_company_code;
      if rcd_company.company_timezone_code != 'Australia/NSW' then
         var_date := dw_to_timezone(trunc(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')),'Australia/NSW',rcd_company.company_timezone_code);
         var_process_date := to_char(dw_to_timezone(sysdate,rcd_company.company_timezone_code,'Australia/NSW')-1,'yyyymmdd');
      end if;

      /*-*/
      /* Aggregation casting periods are always based on the previous day (converted using the company timezone)
      /*-*/
      open csr_mars_date;
      fetch csr_mars_date into rcd_mars_date;
      if csr_mars_date%notfound then
         raise_application_error(-20000, 'Date ' || to_char(var_process_date,'yyyy/mm/dd hh24:mi:ss') || ' not found in MARS_DATE');
      end if;
      close csr_mars_date;
      var_cast_yyyypp := rcd_mars_date.mars_period - 1;
      if to_number(substr(to_char(var_cast_yyyypp,'fm000000'),5,2)) < 1 then
         var_cast_yyyypp := var_cast_yyyypp - 88;
      end if;
      var_cam1_yyyypp := var_cast_yyyypp - 1;
      if to_number(substr(to_char(var_cam1_yyyypp,'fm000000'),5,2)) < 1 then
         var_cam1_yyyypp := var_cam1_yyyypp - 88;
      end if;
      var_cam2_yyyypp := var_cam1_yyyypp - 1;
      if to_number(substr(to_char(var_cam2_yyyypp,'fm000000'),5,2)) < 1 then
         var_cam2_yyyypp := var_cam2_yyyypp - 88;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Forecast Aggregation - Parameters(' || var_company_code || ' + ' || to_char(var_date,'yyyy/mm/dd hh24:mi:ss') || ' + ' || to_char(to_date(var_process_date,'yyyymmdd'),'yyyy/mm/dd') || ')');

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
         /* BRM1 load
         /*-*/
         begin
            fcst_fact_brhist_load(var_company_code, 'BRM1', var_cam1_yyyypp);
         exception
            when others then
               var_errors := true;
         end;

         /*-*/
         /* BRM2 load
         /*-*/
         begin
            fcst_fact_brhist_load(var_company_code, 'BRM2', var_cam2_yyyypp);
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
      lics_logging.write_log('End - Forecast Aggregation');

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
         if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
            lics_notification.send_alert(var_alert);
         end if;
         if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then
            lics_notification.send_email(dw_parameter.system_code,
                                         dw_parameter.system_unit,
                                         dw_parameter.system_environment,
                                         con_function,
                                         'DW_FORECAST_AGGREGATION',
                                         var_email,
                                         'One or more errors occurred during the Forecast Aggregation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**LOGGED ERROR**');

      /*-*/
      /* Set processing trace when required
      /*-*/
      else

         /*-*/
         /* Set the forecast aggregation trace for the current company and date
         /*-*/
         lics_processing.set_trace(var_process_code, var_process_date);

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
         raise_application_error(-20000, 'FATAL ERROR - DW_FORECAST_AGGREGATION - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /********************************************************************/
   /* This procedure performs the business review history load routine */
   /********************************************************************/
   procedure fcst_fact_brhist_load(par_company_code in varchar2, par_fcst_code in varchar2, par_cast_yyyypp in number) is

      /*-*/
      /* Local variables
      /*-*/
      var_fcst_identifier dw_fcst_base.fcst_identifier%type;
      var_cast_yyyypp number;
      var_cast_yyyy number;
      var_cast_pp number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - FCST_FACT ('||par_fcst_code||') Load - Casting period ('||to_char(par_cast_yyyypp)||')');

      /*-*/
      /* Initialise the forecast
      /*-*/
      var_fcst_identifier := par_fcst_code||'_COM'||par_company_code;
      var_cast_yyyypp := par_cast_yyyypp;
      var_cast_yyyy := to_number(substr(to_char(par_cast_yyyypp,'fm000000'),1,4));
      var_cast_pp := to_number(substr(to_char(par_cast_yyyypp,'fm000000'),5,2));

      /*-*/
      /* Truncate the required partition
      /* **notes**
      /* 1. Partition with data may not have new data so will always be truncated
      /*-*/
      lics_logging.write_log('--> Truncating the partition - Forecast(' || var_fcst_identifier || ')');
      dds_dw_partition.truncate_list('dw_fcst_base',var_fcst_identifier);

      /*-*/
      /* Check that a partition exists for the current forecast
      /*-*/
      lics_logging.write_log('--> Check/create partition - Forecast(' || var_fcst_identifier || ')');
      dds_dw_partition.check_create_list('dw_fcst_base',var_fcst_identifier);

      /*-*/
      /* Build the partition for the current forecast
      /*-*/
      lics_logging.write_log('--> Loading the partition - Forecast(' || var_fcst_identifier || ')');
      insert into dw_fcst_base
         (fcst_identifier,
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
          dfn_adjmt_qty)
         select var_fcst_identifier,
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
                                    'AUD',
                                    (select to_date(yyyymmdd_date,'yyyymmdd')
                                       from mars_date
                                      where mars_yyyyppdd = (fcst_yyyypp || '01')),
                                    'MPPR') as fcst_value_aud,
                ods_app.currcy_conv(t1.fcst_value,
                                    t2.company_currcy,
                                    'USD',
                                    (select to_date(yyyymmdd_date,'yyyymmdd')
                                       from mars_date
                                       where mars_yyyyppdd = (fcst_yyyypp || '01')),
                                    'MPPR') as fcst_value_usd,
                ods_app.currcy_conv(t1.fcst_value,
                                    t2.company_currcy,
                                    'EUR',
                                    (select to_date(yyyymmdd_date,'yyyymmdd')
                                       from mars_date
                                      where mars_yyyyppdd = (fcst_yyyypp || '01')),
                                    'MPPR') as fcst_value_eur,
                t1.fcst_qty,
                nvl(decode(t3.gewei, 'TNE', decode(t3.brgew,0,t3.ntgew,t3.brgew),
                                     'KGM', (decode(t3.brgew,0,t3.ntgew,t3.brgew) / 1000)*t1.fcst_qty,
                                     'GRM', (decode(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000)*t1.fcst_qty,
                                     'MGM', (decode(t3.brgew,0,t3.ntgew,t3.brgew) / 1000000000)*t1.fcst_qty,
                                     0),0) as fcst_qty_gross_tonnes,
                nvl(decode(t3.gewei, 'TNE', t3.ntgew,
                                     'KGM', (t3.ntgew / 1000)*t1.fcst_qty,
                                     'GRM', (t3.ntgew / 1000000)*t1.fcst_qty,
                                     'MGM', (t3.ntgew / 1000000000)*t1.fcst_qty,
                                     0),0) as fcst_qty_net_tonnes,
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
           from (select /*+ index(b fcst_dtl_pk) */
                        a.company_code,
                        a.sales_org_code,
                        a.distbn_chnl_code,
                        a.division_code,
                        a.moe_code,
                        a.fcst_type_code,
                        (b.fcst_year || lpad(b.fcst_period,2,0)) as fcst_yyyypp,
                        null as fcst_yyyyppw,
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
                        ltrim(b.matl_zrep_code, 0) as matl_zrep_code,
                        ltrim(b.matl_tdu_code, 0) as matl_tdu_code,
                        b.currcy_code,
                        sum(b.fcst_value) as fcst_value,
                        sum(b.fcst_qty) as fcst_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_value,0)) as base_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_base, b.fcst_qty,0)) as base_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_value,0)) as aggreg_mkt_actvty_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_aggr_mkt_act, b.fcst_qty,0)) as aggreg_mkt_actvty_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_value,0)) as lock_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_lock, b.fcst_qty,0)) as lock_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_value,0)) as rcncl_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_rcncl, b.fcst_qty,0)) as rcncl_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_value,0)) as auto_adjmt_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_auto_adj, b.fcst_qty,0)) as auto_adjmt_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_value,0)) as override_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_override, b.fcst_qty,0)) as override_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_value,0)) as mkt_actvty_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_mkt_act, b.fcst_qty,0)) as mkt_actvty_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_value,0)) as data_driven_event_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_data_driven, b.fcst_qty,0)) as data_driven_event_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_value,0)) as tgt_impact_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_tgt_imapct, b.fcst_qty,0)) as tgt_impact_qty,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_value,0)) as dfn_adjmt_value,
                        sum(decode(b.fcst_dtl_type_code, pc_fcst_dtl_typ_dfn_adj, b.fcst_qty,0)) as dfn_adjmt_qty
                   from fcst_hdr a,
                        fcst_dtl b
                  where a.fcst_hdr_code = b.fcst_hdr_code
                    and a.company_code = par_company_code
                    and a.fcst_type_code = 'BR'
                    and a.casting_year = var_cast_yyyy
                    and a.casting_period = var_cast_pp
                    and a.valdtn_status = 'VALID'
                    and (b.fcst_year || lpad(b.fcst_period,2,0)) > var_cast_yyyypp
                  group by a.company_code,
                           a.sales_org_code,
                           a.distbn_chnl_code,
                           a.division_code,
                           a.moe_code,
                           a.fcst_type_code,
                           (b.fcst_year || lpad(b.fcst_period,2,0)),
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
                           b.currcy_code) t1,
                company t2,
                sap_mat_hdr t3
          where t1.company_code = t2.company_code
            and t1.matl_zrep_code = ltrim(t3.matnr,'0');

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - DW_FCST_BASE ('||par_fcst_code||') Load');

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
            lics_logging.write_log('**ERROR** - DW_FCST_BASE ('||par_fcst_code||') Load - ' || substr(SQLERRM, 1, 1024));
            lics_logging.write_log('End - DW_FCST_BASE ('||par_fcst_code||') Load');
         end if;

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, '**ERROR**');

   /*-------------*/
   /* End routine */
   /*-------------*/
   end fcst_fact_brhist_load;

end dw_fcst_aggregation;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym dw_fcst_aggregation for dw_app.dw_fcst_aggregation;
grant execute on dw_fcst_aggregation to public;
