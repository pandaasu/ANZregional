CREATE OR REPLACE package regl_dbp_aggregation as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : AP Regional DBP
 Package : regl_dbp_aggregation
 Owner   : REGL_APP
 Author  : Linden Glen

 Description
 -----------
   - process_fpps_forecast - Aggregation of FPPS Forecast data from ODS to DDS
   - process_fpps_actuals - Aggregation of FPPS Actuals data from ODS to DDS
   - build_dbp_week_mart - Aggregation of DBP Week level Data Mart

 **notes**

 1. A web log is produced where all errors are logged.

 2. All errors will raise an exception to the calling application so that an alert can
    be raised.


 YYYY/MM   Author            Description
 -------   ------            -----------
 2008/01   Linden Glen       Created
 2008/04   Linden Glen       Changed Venus Actual aggregation to pickup YYYYPP for 
                             Effective Billing date, not range to current point in time
 2008/05   Linden Glen       Changed Company code for China (908 to 135 after Atlas GoLive)

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure process_fpps_forecast(par_company_code in varchar2,
                                   par_fcst_type in varchar2,
                                   par_fcst_yyyy in varchar2);
   procedure process_fpps_actual(par_company_code in varchar2,
                                 par_actual_yyyy in varchar2);  
   procedure build_dbp_week_mart(par_yyyyppw in varchar2);  

end regl_dbp_aggregation;
/


/****************/
/* Package Body */
/****************/
create or replace package body regl_dbp_aggregation as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);


   /*************************************************/
   /* This procedure performs the file load routine */
   /*************************************************/
   procedure process_fpps_forecast(par_company_code in varchar2,
                                   par_fcst_type in varchar2,
                                   par_fcst_yyyy in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_errors boolean;
      /*-*/
      rcd_dds_fpps_fcst_fact dds_fpps_fcst_fact%rowtype;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_fpps_forecast is
         select a.company_code,
                a.fcst_yyyy,
                a.fcst_type,
                b.fcst_matl_code,
                b.fcst_period,
                c.cntl_value as fcst_aag_code,
                max(a.fcst_currency) as fcst_currency,
                sum(b.fcst_mrkt_gsv) as fcst_mrkt_gsv,
                sum(b.fcst_mrkt_ton) as fcst_mrkt_ton,
                sum(b.fcst_mrkt_qty) as fcst_mrkt_qty,
                sum(b.fcst_fctry_gsv) as fcst_fctry_gsv,
                sum(b.fcst_fctry_ton) as fcst_fctry_ton,
                sum(b.fcst_fctry_qty) as fcst_fctry_qty
         from ods_fpps_fcst_hdr a,
              ods_fpps_fcst_det b,
              regl_sales_cntl c
         where a.company_code = b.company_code
           and a.fcst_yyyy = b.fcst_yyyy
           and a.fcst_type = b.fcst_type
           and upper(b.fcst_destination) = upper(c.cntl_code(+))
           and a.company_code = par_company_code
           and a.fcst_type = par_fcst_type
           and a.fcst_yyyy = par_fcst_yyyy
           and c.group_id(+) = 'FCST_ACCT_ASSGNMNT_' || par_company_code
         group by a.company_code,
                  a.fcst_yyyy,
                  a.fcst_type,
                  b.fcst_matl_code,
                  b.fcst_period,
                  c.cntl_value;
      rcd_fpps_forecast  csr_fpps_forecast%rowtype;

      cursor csr_aag_code(par_lookup varchar2) is
        select a.cntl_value
        from regl_sales_cntl a
        where a.group_id = 'FCST_ACCT_ASSGNMNT_' || par_company_code
          and upper(a.cntl_code) = upper(par_lookup);
      rcd_aag_code  csr_aag_code%ROWTYPE;

      cursor csr_aag_chk is
         select a.fcst_destination
         from ods_fpps_fcst_det a,
              regl_sales_cntl b
         where upper(a.fcst_destination) = upper(b.cntl_code(+))
           and a.company_code = par_company_code
           and a.fcst_type = par_fcst_type
           and a.fcst_yyyy = par_fcst_yyyy
           and b.group_id(+) = 'FCST_ACCT_ASSGNMNT_' || par_company_code
           and b.cntl_code is null
         group by a.fcst_destination;
      rcd_aag_chk  csr_aag_chk%ROWTYPE;

      cursor csr_xchg_date(par_yyyy varchar2) is
         select to_date(yyyymmdd_date,'YYYYMMDD') as xchg_date
         from mars_date
         where mars_yyyyppdd = par_yyyy ;
      rcd_xchg_date  csr_xchg_date%ROWTYPE;                                                                             

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_log_prefix := 'PROCESS FPPS Forecast to DDS (' || par_company_code || '/' || par_fcst_type || '/' || par_fcst_yyyy || ')';
      var_log_search := 'REGL_DBP_AGGREGATION.PROCESS_FPPS_FORECAST';
      var_errors := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Validate the parameters
      /*-*/
      if (par_company_code is null) then
         raise_application_error(-20000, 'PAR_COMPANY_CODE parameter must be specified.');
      end if;
      /*-*/
      if (upper(par_fcst_type) != '*OP') then
         raise_application_error(-20000, 'PAR_FCST_TYPE parameter must be *OP');
      end if;
      /*-*/
      if (par_fcst_yyyy is null) then
         raise_application_error(-20000, 'PAR_FCST_YYYY parameter must be specified and be in format YYYY.');
      end if;

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('BEGIN - FPPS Forecast Process - Parameters(' || par_company_code || ' + ' || par_fcst_type || ' + ' || par_fcst_yyyy || ')');

      /*-*/
      /* Check Account Assignment Groups have been configured for all destinations
      /*-*/
      open csr_aag_chk;
      loop
         fetch csr_aag_chk into rcd_aag_chk;
         if(csr_aag_chk%notfound) then
            exit;
         end if;      

         lics_logging.write_log('Account Assignment Group Code not found in REGL_SALES_CNTL for [' || rcd_aag_chk.fcst_destination || ']');
         lics_logging.write_log('insert into regl_sales_cntl values (''FCST_ACCT_ASSGNMNT_'|| par_company_code || ''',''' || upper(rcd_aag_chk.fcst_destination) || ''',''x'',''Forecast AAG Code'');');
         var_errors := true;

      end loop;
      close csr_aag_chk;

      /*-*/
      /* Continue processing if no errors identified
      /*-*/
      if not(var_errors) then   

         lics_logging.write_log('DELETE - DDS_FPPS_FCST_FACT');
         /*------------------------------*/
         /* DELETE - DDS TABLE           */
         /*------------------------------*/
         delete from dds_fpps_fcst_fact a
          where a.company_code = par_company_code
            and a.fcst_type = par_fcst_type
            and substr(a.fcst_yyyypp,1,4) = par_fcst_yyyy; 

         lics_logging.write_log('BUILD - DDS_FPPS_FCST_FACT');
         /*-*/
         /* Process forecast data
         /*-*/
         open csr_fpps_forecast;
         loop
            fetch csr_fpps_forecast into rcd_fpps_forecast;
            if(csr_fpps_forecast%notfound) then
               exit;
            end if;
 
            rcd_dds_fpps_fcst_fact.company_code := par_company_code;
            rcd_dds_fpps_fcst_fact.fcst_type := par_fcst_type;
            rcd_dds_fpps_fcst_fact.fcst_yyyypp := par_fcst_yyyy || lpad(rcd_fpps_forecast.fcst_period,2,'0');
            rcd_dds_fpps_fcst_fact.fcst_aag_code := rcd_fpps_forecast.fcst_aag_code;
            rcd_dds_fpps_fcst_fact.fcst_matl_code := rcd_fpps_forecast.fcst_matl_code;
            rcd_dds_fpps_fcst_fact.fcst_currency := rcd_fpps_forecast.fcst_currency;
           
            /*-*/
            /* Retrieve Exchange Rate Date
            /*-*/
            open csr_xchg_date(rcd_dds_fpps_fcst_fact.fcst_yyyypp||'01');
            fetch csr_xchg_date into rcd_xchg_date;
            if (csr_xchg_date%notfound) then
               raise_application_error(-20000, 'Date not found in MARS_DATE for ' || rcd_dds_fpps_fcst_fact.fcst_yyyypp || '01.');
            end if;
            close csr_xchg_date;

            /*-*/
            /* Calculate GSV
            /*  note: if Account Assignment is 03 (Affiliate) - then GSV is Factory, not Market
            /*-*/
            if (rcd_dds_fpps_fcst_fact.fcst_aag_code = '03') then
               rcd_dds_fpps_fcst_fact.fcst_gsv := rcd_fpps_forecast.fcst_fctry_gsv;
               rcd_dds_fpps_fcst_fact.fcst_gsv_usd := round(ods_app.currcy_conv(rcd_fpps_forecast.fcst_fctry_gsv,
                                                                                rcd_dds_fpps_fcst_fact.fcst_currency,
                                                                                ods_constants.currency_usd,
                                                                                rcd_xchg_date.xchg_date,
                                                                                ods_constants.exchange_rate_type_usdx),2);
            else
               rcd_dds_fpps_fcst_fact.fcst_gsv := rcd_fpps_forecast.fcst_mrkt_gsv;
               rcd_dds_fpps_fcst_fact.fcst_gsv_usd := round(ods_app.currcy_conv(rcd_fpps_forecast.fcst_mrkt_gsv,
                                                                                rcd_dds_fpps_fcst_fact.fcst_currency,
                                                                                ods_constants.currency_usd,
                                                                                rcd_xchg_date.xchg_date,
                                                                                ods_constants.exchange_rate_type_usdx),2);
            end if;

            /*------------------------------*/
            /* INSERT - Forecast Data       */
            /*------------------------------*/
            insert into dds_fpps_fcst_fact
                 (company_code,
                  fcst_type,
                  fcst_yyyypp, 
                  fcst_matl_code,
                  fcst_currency,
                  fcst_aag_code,
                  fcst_gsv,
                  fcst_gsv_usd)
              values (rcd_dds_fpps_fcst_fact.company_code,
                      rcd_dds_fpps_fcst_fact.fcst_type,
                      rcd_dds_fpps_fcst_fact.fcst_yyyypp, 
                      rcd_dds_fpps_fcst_fact.fcst_matl_code,
                      rcd_dds_fpps_fcst_fact.fcst_currency,
                      rcd_dds_fpps_fcst_fact.fcst_aag_code,
                      rcd_dds_fpps_fcst_fact.fcst_gsv,
                      rcd_dds_fpps_fcst_fact.fcst_gsv_usd);

         end loop;
         close csr_fpps_forecast;

         /*-*/
         /* Commit
         /*-*/
         commit;

      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - REGL_DBP_AGGREGATION.PROCESS_FPPS_FORECAST- ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_fpps_forecast;

   /*************************************************/
   /* This procedure performs the file load routine */
   /*************************************************/
   procedure process_fpps_actual(par_company_code in varchar2,
                                 par_actual_yyyy in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_errors boolean;
      /*-*/
      rcd_dds_fpps_actual_fact dds_fpps_actual_fact%rowtype;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_fpps_actual is
         select a.company_code,
                a.actual_yyyy,
                b.actual_matl_code,
                b.actual_period,
                c.cntl_value as actual_aag_code,
                max(a.actual_currency) as actual_currency,
                sum(b.actual_mrkt_gsv) as actual_mrkt_gsv,
                sum(b.actual_mrkt_ton) as actual_mrkt_ton,
                sum(b.actual_mrkt_qty) as actual_mrkt_qty,
                sum(b.actual_fctry_gsv) as actual_fctry_gsv,
                sum(b.actual_fctry_ton) as actual_fctry_ton,
                sum(b.actual_fctry_qty) as actual_fctry_qty
         from ods_fpps_actual_hdr a,
              ods_fpps_actual_det b,
              regl_sales_cntl c
         where a.company_code = b.company_code
           and a.actual_yyyy = b.actual_yyyy
           and upper(b.actual_destination) = upper(c.cntl_code(+))
           and a.company_code = par_company_code
           and a.actual_yyyy = par_actual_yyyy
           and c.group_id(+) = 'FCST_ACCT_ASSGNMNT_' || par_company_code
         group by a.company_code,
                  a.actual_yyyy,
                  b.actual_matl_code,
                  b.actual_period,
                  c.cntl_value;
      rcd_fpps_actual  csr_fpps_actual%rowtype;

      cursor csr_aag_chk is
         select a.actual_destination
         from ods_fpps_actual_det a,
              regl_sales_cntl b
         where upper(a.actual_destination) = upper(b.cntl_code(+))
           and a.company_code = par_company_code
           and a.actual_yyyy = par_actual_yyyy
           and b.group_id(+) = 'FCST_ACCT_ASSGNMNT_' || par_company_code
           and b.cntl_code is null
         group by a.actual_destination;
      rcd_aag_chk  csr_aag_chk%ROWTYPE;

      cursor csr_xchg_date(par_yyyy varchar2) is
         select to_date(yyyymmdd_date,'YYYYMMDD') as xchg_date
         from mars_date
         where mars_yyyyppdd = par_yyyy ;
      rcd_xchg_date  csr_xchg_date%ROWTYPE;                                                                             

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_log_prefix := 'PROCESS FPPS Actuals to DDS (' || par_company_code || '/' || par_actual_yyyy || ')';
      var_log_search := 'REGL_DBP_AGGREGATION.PROCESS_FPPS_ACTUALS';
      var_errors := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Validate the parameters
      /*-*/
      if (par_company_code is null) then
         raise_application_error(-20000, 'PAR_COMPANY_CODE parameter must be specified.');
      end if;
      /*-*/
      if (par_actual_yyyy is null) then
         raise_application_error(-20000, 'PAR_ACTUAL_YYYY parameter must be specified and be in format YYYY.');
      end if;

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('BEGIN - FPPS Actuals Process - Parameters(' || par_company_code || ' + ' || par_actual_yyyy || ')');

      /*-*/
      /* Check Account Assignment Groups have been configured for all destinations
      /*-*/
      open csr_aag_chk;
      loop
         fetch csr_aag_chk into rcd_aag_chk;
         if(csr_aag_chk%notfound) then
            exit;
         end if;      

         lics_logging.write_log('Account Assignment Group Code not found in REGL_SALES_CNTL for [' || rcd_aag_chk.actual_destination || ']');
         lics_logging.write_log('insert into regl_sales_cntl values (''FCST_ACCT_ASSGNMNT_'|| par_company_code || ''',''' || upper(rcd_aag_chk.actual_destination) || ''',''x'',''AAG Code'');');
         var_errors := true;

      end loop;
      close csr_aag_chk;

      /*-*/
      /* Continue processing if no errors identified
      /*-*/
      if not(var_errors) then   

         lics_logging.write_log('DELETE - DDS_FPPS_ACTUAL_FACT');
         /*------------------------------*/
         /* DELETE - DDS TABLE           */
         /*------------------------------*/
         delete from dds_fpps_actual_fact a
          where a.company_code = par_company_code
            and substr(a.actual_yyyypp,1,4) = par_actual_yyyy; 

         lics_logging.write_log('BUILD - DDS_FPPS_ACTUAL_FACT');
         /*-*/
         /* Process actual data
         /*-*/
         open csr_fpps_actual;
         loop
            fetch csr_fpps_actual into rcd_fpps_actual;
            if(csr_fpps_actual%notfound) then
               exit;
            end if;
 
            rcd_dds_fpps_actual_fact.company_code := par_company_code;
            rcd_dds_fpps_actual_fact.actual_yyyypp := par_actual_yyyy || lpad(rcd_fpps_actual.actual_period,2,'0');
            rcd_dds_fpps_actual_fact.actual_aag_code := rcd_fpps_actual.actual_aag_code;
            rcd_dds_fpps_actual_fact.actual_matl_code := rcd_fpps_actual.actual_matl_code;
            rcd_dds_fpps_actual_fact.actual_currency := rcd_fpps_actual.actual_currency;
           
            /*-*/
            /* Retrieve Exchange Rate Date
            /*-*/
            open csr_xchg_date(rcd_dds_fpps_actual_fact.actual_yyyypp||'01');
            fetch csr_xchg_date into rcd_xchg_date;
            if (csr_xchg_date%notfound) then
               raise_application_error(-20000, 'Date not found in MARS_DATE for ' || rcd_dds_fpps_actual_fact.actual_yyyypp || '01.');
            end if;
            close csr_xchg_date;

            /*-*/
            /* Calculate GSV
            /*  note: if Account Assignment is 03 (Affiliate) - then GSV is Factory, not Market
            /*-*/
            if (rcd_dds_fpps_actual_fact.actual_aag_code = '03') then
               rcd_dds_fpps_actual_fact.actual_gsv := rcd_fpps_actual.actual_fctry_gsv;
               rcd_dds_fpps_actual_fact.actual_gsv_usd := round(ods_app.currcy_conv(rcd_fpps_actual.actual_fctry_gsv,
                                                                                rcd_dds_fpps_actual_fact.actual_currency,
                                                                                ods_constants.currency_usd,
                                                                                rcd_xchg_date.xchg_date,
                                                                                ods_constants.exchange_rate_type_usdx),2);
            else
               rcd_dds_fpps_actual_fact.actual_gsv := rcd_fpps_actual.actual_mrkt_gsv;
               rcd_dds_fpps_actual_fact.actual_gsv_usd := round(ods_app.currcy_conv(rcd_fpps_actual.actual_mrkt_gsv,
                                                                                rcd_dds_fpps_actual_fact.actual_currency,
                                                                                ods_constants.currency_usd,
                                                                                rcd_xchg_date.xchg_date,
                                                                                ods_constants.exchange_rate_type_usdx),2);
            end if;

            /*------------------------------*/
            /* INSERT - actual Data       */
            /*------------------------------*/
            insert into dds_fpps_actual_fact
                 (company_code,
                  actual_yyyypp, 
                  actual_matl_code,
                  actual_currency,
                  actual_aag_code,
                  actual_gsv,
                  actual_gsv_usd)
              values (rcd_dds_fpps_actual_fact.company_code,
                      rcd_dds_fpps_actual_fact.actual_yyyypp, 
                      rcd_dds_fpps_actual_fact.actual_matl_code,
                      rcd_dds_fpps_actual_fact.actual_currency,
                      rcd_dds_fpps_actual_fact.actual_aag_code,
                      rcd_dds_fpps_actual_fact.actual_gsv,
                      rcd_dds_fpps_actual_fact.actual_gsv_usd);

         end loop;
         close csr_fpps_actual;

         /*-*/
         /* Commit
         /*-*/
         commit;

      end if;

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
         raise_application_error(-20000, 'FATAL ERROR - REGL_DBP_AGGREGATION.PROCESS_FPPS_ACTUALS - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end process_fpps_actual;

   /*************************************************/
   /* This procedure builds the DBP Weekly Fact Mart*/
   /*************************************************/
   procedure build_dbp_week_mart(par_yyyyppw in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      /*-*/
      rcd_dds_dbp_week_mart dds_dbp_week_mart%rowtype;

      /*-*/
      /* Cursor definitions
      /*-*/
      cursor csr_cdw_week_dbp is
         select company_code, 
                dbp_aag_code, 
                dbp_matl_code,
                'AUD' as dbp_currency,
                sum(dbp_ptd_tp_inv_gsv) as dbp_ptd_tp_inv_gsv,
                sum(dbp_prd_ly_inv_gsv) as dbp_prd_ly_inv_gsv,
                sum(dbp_prd_tp_op_gsv) as dbp_prd_tp_op_gsv,
                sum(dbp_ptd_tp_ord_gsv) as dbp_ptd_tp_ord_gsv
         from (/******************/
               /* CDW PTD Actuals*/
               /******************/
               select a.company_code as company_code,
                      nvl(c.acct_assgnmnt_grp_code,'99') as dbp_aag_code,
                      nvl(a.matl_code,'999999999999999999') as dbp_matl_code,
                      a.gsv_aud as dbp_ptd_tp_inv_gsv,
                      null as dbp_prd_ly_inv_gsv,
                      null as dbp_prd_tp_op_gsv,
                      null as dbp_ptd_tp_ord_gsv
               from sales_fact a,
                    cust_sales_area_dim b,
                    acct_assgnmnt_grp_dim c
               where a.sold_to_cust_code = b.cust_code(+)
                 and a.hdr_distbn_chnl_code = b.distbn_chnl_code(+)
                 and a.hdr_division_code = b.division_code(+)
                 and a.hdr_sales_org_code = b.sales_org_code(+)
                 and b.acct_assgnmnt_grp_code = c.acct_assgnmnt_grp_code(+)
                 and a.company_code in ('147','149')
                 and a.billing_eff_yyyypp = substr(par_yyyyppw,1,6)
               union all
               /******************/
               /* CDW PTD Orders */
               /******************/
               select a.company_code as company_code,
                      nvl(c.acct_assgnmnt_grp_code,'99') as dbp_aag_code,
                      nvl(a.matl_code,'999999999999999999') as dbp_matl_code,
                      null as dbp_ptd_tp_inv_gsv,
                      null as dbp_prd_ly_inv_gsv,
                      null as dbp_prd_tp_op_gsv,
                      a.gsv_aud as dbp_ptd_tp_ord_gsv
               from outstanding_order_fact a,
                    cust_sales_area_dim b,
                    acct_assgnmnt_grp_dim c
               where a.hier_link_cust_code = b.cust_code(+)
                 and a.distbn_chnl_code = b.distbn_chnl_code(+)
                 and a.division_code = b.division_code(+)
                 and a.sales_org_code = b.sales_org_code(+)
                 and b.acct_assgnmnt_grp_code = c.acct_assgnmnt_grp_code(+)
                 and a.company_code in ('147','149')
                 and substr(a.eff_yyyyppdd,1,6) = substr(par_yyyyppw,1,6)
               union all
               /**************************/
               /* FPPS LY Period Actuals */
               /**************************/
               select a.company_code as company_code,
                      nvl(a.actual_aag_code,'99') as dbp_aag_code,
                      nvl(a.actual_matl_code,'999999999999999999') as dbp_matl_code,
                      null as dbp_ptd_tp_inv_gsv,
                      a.actual_gsv as dbp_prd_ly_inv_gsv,
                      null as dbp_prd_tp_op_gsv,
                      null as dbp_ptd_tp_ord_gsv
               from dds_fpps_actual_fact a
               where a.company_code in ('147','149')
                 and a.actual_yyyypp = substr(par_yyyyppw,1,4)-1||substr(par_yyyyppw,5,2)
               union all
               /***********************/
               /* FPPS Period Forecast*/
               /***********************/
               select a.company_code as company_code,
                      nvl(a.fcst_aag_code,'99') as dbp_aag_code,
                      nvl(a.fcst_matl_code,'999999999999999999') as dbp_matl_code,
                      null as dbp_ptd_tp_inv_gsv,
                      null as dbp_prd_ly_inv_gsv,
                      a.fcst_gsv as dbp_prd_tp_op_gsv,
                      null as dbp_ptd_tp_ord_gsv
               from dds_fpps_fcst_fact a
               where a.company_code in ('147','149')
                 and a.fcst_yyyypp = substr(par_yyyyppw,1,6)
                 and a.fcst_type = '*OP')
         group by company_code, dbp_aag_code, dbp_matl_code;
      rcd_cdw_week_dbp  csr_cdw_week_dbp%rowtype;
                                                                         
      cursor csr_regl_week_dbp is
         select company_code, 
                dbp_aag_code, 
                dbp_matl_code,
                'AUD' as dbp_currency,
                sum(dbp_ptd_tp_inv_gsv) as dbp_ptd_tp_inv_gsv,
                sum(dbp_prd_ly_inv_gsv) as dbp_prd_ly_inv_gsv,
                sum(dbp_prd_tp_op_gsv) as dbp_prd_tp_op_gsv,
                sum(dbp_ptd_tp_ord_gsv) as dbp_ptd_tp_ord_gsv
         from (/*******************************/
               /* REGL PTD Actuals and Orders */
               /*******************************/
               select a.company_code as company_code,
                      nvl(a.acct_assgnmnt_grp_code,'99') as dbp_aag_code,
                      nvl(a.matl_code,'999999999999999999') as dbp_matl_code,
                      a.invc_ptd_gsv as dbp_ptd_tp_inv_gsv,
                      null as dbp_prd_ly_inv_gsv,
                      null as dbp_prd_tp_op_gsv,
                      a.order_ptd_gsv as dbp_ptd_tp_ord_gsv
               from regl_sales_fact a,
                    (select t01.company_code,
                            max(t01.rprting_yyyymmdd) as rprting_yyyymmdd
                     from regl_sales_fact t01
                     where rprting_yyyyppdd in (select mars_yyyyppdd from mars_date
                                                where mars_week between substr(par_yyyyppw,1,6)||'1' and par_yyyyppw)
                       and company_code in ('131','900','901','902','903','904','905','906','907','135','909','912')
                     group by t01.company_code) b
               where a.company_code = b.company_code
                 and a.rprting_yyyymmdd = b.rprting_yyyymmdd
               union all
               /***********************/
               /* FPPS Period Actuals */
               /***********************/
               select a.company_code as company_code,
                      nvl(a.actual_aag_code,'99') as dbp_aag_code,
                      nvl(a.actual_matl_code,'999999999999999999') as dbp_matl_code,
                      null as dbp_ptd_tp_inv_gsv,
                      a.actual_gsv as dbp_prd_ly_inv_gsv,
                      null as dbp_prd_tp_op_gsv,
                      null as dbp_ptd_tp_ord_gsv
               from dds_fpps_actual_fact a
               where a.company_code in ('131','900','901','902','903','904','905','906','907','135','909','912')
                 and a.actual_yyyypp = substr(par_yyyyppw,1,4)-1||substr(par_yyyyppw,5,2)
               union all
               /***********************/
               /* FPPS Period Forecast*/
               /***********************/
               select a.company_code as company_code,
                      nvl(a.fcst_aag_code,'99') as dbp_aag_code,
                      nvl(a.fcst_matl_code,'999999999999999999') as dbp_matl_code,
                      null as dbp_ptd_tp_inv_gsv,
                      null as dbp_prd_ly_inv_gsv,
                      a.fcst_gsv as dbp_prd_tp_op_gsv,
                      null as dbp_ptd_tp_ord_gsv
               from dds_fpps_fcst_fact a
               where a.company_code in ('131','900','901','902','903','904','905','906','907','135','909','912')
                 and a.fcst_yyyypp = substr(par_yyyyppw,1,6)
                 and a.fcst_type = '*OP')
         group by company_code, dbp_aag_code, dbp_matl_code;
      rcd_regl_week_dbp  csr_regl_week_dbp%rowtype;


   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise variables
      /*-*/
      var_log_prefix := 'BUILD DBP Weekly Data Mart (' || par_yyyyppw || ')';
      var_log_search := 'REGL_DBP_REPORTING.BUILD_DBP_WEEK_MART';

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('BEGIN - BUILD DBP Weekly Data Mart - Parameters(' || par_yyyyppw || ')');

      /*--------------------------------------*/
      /* Build CDW/Venus Companies (149, 147) */
      /*--------------------------------------*/ 
      lics_logging.write_log('COMMENCE build for SAP companies 147/149');

      lics_logging.write_log('DELETE for Company Codes 147/149 and Week ' || par_yyyyppw);      
      delete dds_dbp_week_mart
       where dbp_company_code in ('147','149')
         and dbp_yyyyppw = par_yyyyppw;

      /*-*/
      /* Process CDW Company Data
      /*-*/
      lics_logging.write_log('LOAD for Company Codes 147/149 and Week ' || par_yyyyppw); 
      open csr_cdw_week_dbp;
      loop
         fetch csr_cdw_week_dbp into rcd_cdw_week_dbp;
         if(csr_cdw_week_dbp%notfound) then
            exit;
         end if;

         rcd_dds_dbp_week_mart.dbp_company_code := rcd_cdw_week_dbp.company_code;
         rcd_dds_dbp_week_mart.dbp_yyyyppw := par_yyyyppw; 
         rcd_dds_dbp_week_mart.dbp_matl_code := rcd_cdw_week_dbp.dbp_matl_code;
         rcd_dds_dbp_week_mart.dbp_aag_code := rcd_cdw_week_dbp.dbp_aag_code;
         rcd_dds_dbp_week_mart.dbp_currency := rcd_cdw_week_dbp.dbp_currency;
         rcd_dds_dbp_week_mart.dbp_ptd_tp_inv_gsv := rcd_cdw_week_dbp.dbp_ptd_tp_inv_gsv;
         rcd_dds_dbp_week_mart.dbp_ptd_tp_ord_gsv := rcd_cdw_week_dbp.dbp_ptd_tp_ord_gsv;
         rcd_dds_dbp_week_mart.dbp_prd_tp_op_gsv := rcd_cdw_week_dbp.dbp_prd_tp_op_gsv;
         rcd_dds_dbp_week_mart.dbp_prd_ly_inv_gsv := rcd_cdw_week_dbp.dbp_prd_ly_inv_gsv;

         /*------------------------------*/
         /* INSERT - Weekly Data Mart    */
         /*------------------------------*/
         insert into dds_dbp_week_mart
            (dbp_company_code,
             dbp_yyyyppw,
             dbp_matl_code,
             dbp_aag_code,
             dbp_currency,
             dbp_ptd_tp_inv_gsv,
             dbp_ptd_tp_ord_gsv,
             dbp_prd_tp_op_gsv,
             dbp_prd_ly_inv_gsv)
           values (rcd_dds_dbp_week_mart.dbp_company_code,
                   rcd_dds_dbp_week_mart.dbp_yyyyppw,
                   rcd_dds_dbp_week_mart.dbp_matl_code,
                   rcd_dds_dbp_week_mart.dbp_aag_code,
                   rcd_dds_dbp_week_mart.dbp_currency,
                   rcd_dds_dbp_week_mart.dbp_ptd_tp_inv_gsv,
                   rcd_dds_dbp_week_mart.dbp_ptd_tp_ord_gsv,
                   rcd_dds_dbp_week_mart.dbp_prd_tp_op_gsv,
                   rcd_dds_dbp_week_mart.dbp_prd_ly_inv_gsv);
  
      end loop;
      close csr_cdw_week_dbp;

      lics_logging.write_log('BUILD COMPLETE for SAP companies 147/149');

      /*-*/
      /* Reset variables
      /*-*/
      rcd_dds_dbp_week_mart.dbp_company_code := null;
      rcd_dds_dbp_week_mart.dbp_yyyyppw := null;
      rcd_dds_dbp_week_mart.dbp_matl_code := null;
      rcd_dds_dbp_week_mart.dbp_aag_code := null;
      rcd_dds_dbp_week_mart.dbp_currency := null;
      rcd_dds_dbp_week_mart.dbp_ptd_tp_inv_gsv := null;
      rcd_dds_dbp_week_mart.dbp_ptd_tp_ord_gsv := null;
      rcd_dds_dbp_week_mart.dbp_prd_tp_op_gsv := null;
      rcd_dds_dbp_week_mart.dbp_prd_ly_inv_gsv := null;

      /*--------------------------------------*/
      /* Build Regional Companies             */
      /*--------------------------------------*/ 
      lics_logging.write_log('COMMENCE build for SAP companies 131/900/901/902/903/904/905/906/907/135/909/912');

      lics_logging.write_log('DELETE for Regional Companies and Week ' || par_yyyyppw);      
      delete dds_dbp_week_mart
       where dbp_company_code in ('131','900','901','902','903','904','905','906','907','135','909','912')
         and dbp_yyyyppw = par_yyyyppw;

      /*-*/
      /* Process CDW Company Data
      /*-*/
      lics_logging.write_log('LOAD for Regional Company Codes and Week ' || par_yyyyppw); 
      open csr_regl_week_dbp;
      loop
         fetch csr_regl_week_dbp into rcd_regl_week_dbp;
         if(csr_regl_week_dbp%notfound) then
            exit;
         end if;

         rcd_dds_dbp_week_mart.dbp_company_code := rcd_regl_week_dbp.company_code;
         rcd_dds_dbp_week_mart.dbp_yyyyppw := par_yyyyppw; 
         rcd_dds_dbp_week_mart.dbp_matl_code := rcd_regl_week_dbp.dbp_matl_code;
         rcd_dds_dbp_week_mart.dbp_aag_code := rcd_regl_week_dbp.dbp_aag_code;
         rcd_dds_dbp_week_mart.dbp_currency := rcd_regl_week_dbp.dbp_currency;
         rcd_dds_dbp_week_mart.dbp_ptd_tp_inv_gsv := rcd_regl_week_dbp.dbp_ptd_tp_inv_gsv;
         rcd_dds_dbp_week_mart.dbp_ptd_tp_ord_gsv := rcd_regl_week_dbp.dbp_ptd_tp_ord_gsv;
         rcd_dds_dbp_week_mart.dbp_prd_tp_op_gsv := rcd_regl_week_dbp.dbp_prd_tp_op_gsv;
         rcd_dds_dbp_week_mart.dbp_prd_ly_inv_gsv := rcd_regl_week_dbp.dbp_prd_ly_inv_gsv;

         /*------------------------------*/
         /* INSERT - Weekly Data Mart    */
         /*------------------------------*/
         insert into dds_dbp_week_mart
            (dbp_company_code,
             dbp_yyyyppw,
             dbp_matl_code,
             dbp_aag_code,
             dbp_currency,
             dbp_ptd_tp_inv_gsv,
             dbp_ptd_tp_ord_gsv,
             dbp_prd_tp_op_gsv,
             dbp_prd_ly_inv_gsv)
           values (rcd_dds_dbp_week_mart.dbp_company_code,
                   rcd_dds_dbp_week_mart.dbp_yyyyppw,
                   rcd_dds_dbp_week_mart.dbp_matl_code,
                   rcd_dds_dbp_week_mart.dbp_aag_code,
                   rcd_dds_dbp_week_mart.dbp_currency,
                   rcd_dds_dbp_week_mart.dbp_ptd_tp_inv_gsv,
                   rcd_dds_dbp_week_mart.dbp_ptd_tp_ord_gsv,
                   rcd_dds_dbp_week_mart.dbp_prd_tp_op_gsv,
                   rcd_dds_dbp_week_mart.dbp_prd_ly_inv_gsv);
  
      end loop;
      close csr_regl_week_dbp;

      lics_logging.write_log('BUILD COMPLETE for Regional Companies');
      /*-*/
      /* Commit
      /*-*/
      commit;

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
         raise_application_error(-20000, 'FATAL ERROR - REGL_DBP_REPORTING.BUILD_DBP_WEEK_MART - ' || substr(SQLERRM, 1, 512));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end build_dbp_week_mart;    

end regl_dbp_aggregation;
/


/**/
/* Authority
/**/
grant execute on regl_dbp_aggregation to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym regl_dbp_aggregation for ods_app.regl_dbp_aggregation;
