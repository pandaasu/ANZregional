/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 Package : care_sales_extract_venus
 Owner   : ods_app

 Description
 -----------
 Care - Sales Extract Venus Version

 This package contains the sales extract procedure for the Care system. The package exposes
 one procedure EXECUTE that performs the extract based on the following parameters:

 1. PAR_SOURCE (Source unit code) (MANDATORY, MAXIMUM LENGTH 4)

 2. PAR_COMPANY (Company code) (MANDATORY, MAXIMUM LENGTH 6)

 3. PAR_SEGMENT (Business segment code) (MANDATORY, MAXIMUM LENGTH 4)

 4. PAR_PERIOD (Mars period to extract) (MANDATORY, MAXIMUM LENGTH 6)

    YYYYPP - Period number
    *LAST - Last completed period

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/08   Steve Gregan   Created

*******************************************************************************/

/******************/
/* Package Header */
/******************/
create or replace package care_sales_extract_venus as

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_source in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2);

end care_sales_extract_venus;
/

/****************/
/* Package Body */
/****************/
create or replace package body care_sales_extract_venus as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure extract_sales(par_source in varchar2, par_company in varchar2, par_segment in varchar2, par_period in number);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_source in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_errors boolean;
      var_period number(6,0);

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'Care Sales Extract';
      con_alt_group constant varchar2(32) := 'CARE_EXTRACT';
      con_alt_code constant varchar2(32) := 'ALERT_STRING';
      con_ema_group constant varchar2(32) := 'CARE_EXTRACT';
      con_ema_code constant varchar2(32) := 'EMAIL_GROUP';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_this_period is
         select t01.mars_period
           from mars_date t01
          where trunc(t01.calendar_date) = trunc(sysdate);
      rcd_this_period csr_this_period%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CARE SALES - EXTRACT';
      var_log_search := 'CARE_SALES_EXTRACT';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;

      /*-*/
      /* Validate the source parameter
      /*-*/
      if par_source is null then
         raise_application_error(-20000, 'Source parameter must be specified');
      end if;
      if length(par_source) > 4 then
         raise_application_error(-20000, 'Source parameter exceeds maximum length 4');
      end if;

      /*-*/
      /* Validate the company parameter
      /*-*/
      if par_company is null then
         raise_application_error(-20000, 'Company parameter (' || par_company || ') must be specified');
      end if;
      if length(par_company) > 6 then
         raise_application_error(-20000, 'Company parameter exceeds maximum length 6');
      end if;

      /*-*/
      /* Validate the segment parameter
      /*-*/
      if par_segment is null then
         raise_application_error(-20000, 'Segment parameter (' || par_segment || ') must be specified or *ALL');
      end if;
      if length(par_segment) > 4 then
         raise_application_error(-20000, 'Segment parameter exceeds maximum length 4');
      end if;

      /*-*/
      /* Validate the period parameter
      /*-*/
      if par_period is null then
         raise_application_error(-20000, 'Period parameter must be specified');
      end if;

      /*-*/
      /* Retrieve the last period or accept the parameter period
      /*-*/
      if trim(upper(par_period)) = '*LAST' then
         open csr_this_period;
         fetch csr_this_period into rcd_this_period;
         if csr_this_period%notfound then
            raise_application_error(-20000, 'Period parameter - current period not found in MARS_DATE');
         end if;
         close csr_this_period;
         var_period := rcd_this_period.mars_period - 1;
         if to_number(substr(to_char(var_period,'fm000000'),5,2)) = 0 then
            var_period := var_period - 87;
         end if;
      else
         begin
            var_period := to_number(par_period);
         exception
            when others then
               raise_application_error(-20000, 'Period parameter (' || par_period || ') - unable to convert to number');
         end;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Care Extract Venus - Parameters(' || upper(par_source) || ' + ' || par_company || ' + ' || par_segment || ' + ' || par_period || ')');

      /*-*/
      /* Extract sales
      /*-*/
      begin
         extract_sales(par_source, par_company, par_segment, var_period);
      exception
         when others then
            var_errors := true;
      end;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Care Extract Venus');

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
            lics_notification.send_email(lics_parameter.system_code,
                                         lics_parameter.system_unit,
                                         lics_parameter.system_environment,
                                         con_function,
                                         'CARE_SALES_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the Care sales extract execution - refer to web log - ' || lics_logging.callback_identifier);
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
         var_exception := substr(SQLERRM, 1, 2048);

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CARE SALES - VENUS EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /*****************************************************/
   /* This procedure performs the extract sales routine */
   /*****************************************************/
   procedure extract_sales(par_source in varchar2, par_company in varchar2, par_segment in varchar2, par_period in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_instance number(15,0);
      var_output varchar2(4000);
      var_file_name varchar2(64);
      type typ_output is table of varchar2(4000) index by binary_integer;
      tbl_output typ_output;

      /*-*/
      /* Local cursors
      /*-*/
	  -- csr_sales - retrieves sales data by period, converted into cases for UOM's other than EA or CASE.
      cursor csr_sales is
	  select t01.matl_code as matl_code,t01.billing_eff_yyyypp,
             sum(decode(t01.billed_qty_uom_code,'PCE',t01.sales_cases/nvl(t02.rsu_count,1)
                                                ,'PK',t01.sales_cases/nvl(t02.mcu_count,1)
                                                ,'SB',t01.sales_cases/nvl(t02.mcu_count,1)
                                                ,t01.sales_cases)) as sales_cases,
             max(nvl(t02.mcu_count,1)) as num_outers_case,
             max(nvl(t02.rsu_count,1)) as num_units_case
      from   (select A.matl_code as matl_code,A.billed_qty_uom_code,A.billing_eff_yyyypp,
                        sum(A.base_uom_billed_qty) as sales_cases
              from sales_period_01_fact A,
                        matl_dim B,
                        cust_sales_area_dim C
              where A.matl_code = B.matl_code
                and A.sold_to_cust_code = C.cust_code
                and A.hdr_distbn_chnl_code = C.distbn_chnl_code
                and A.hdr_division_code = C.division_code
                and A.hdr_sales_org_code = C.sales_org_code
                and A.company_code = par_company
                and A.billing_eff_yyyypp = par_period
                and ((par_segment = '*ALL' and B.bus_sgmnt_code in ('01','02','05')) or B.bus_sgmnt_code = par_segment)
                and C.acct_assgnmnt_grp_code = '01'
			  group by A.matl_code,A.billing_eff_yyyypp,A.billed_qty_uom_code
			 ) t01,
             (select ltrim(X.matnr,' 0') as matl_code,
                     decode(Y.rsu_meinh,null,1,decode(X.umrez,1,Y.mcu_umren,X.umrez*Y.mcu_umren)) as mcu_count,
                     decode(Y.rsu_meinh,null,decode(X.umrez,1,Y.mcu_umren,X.umrez*Y.mcu_umren),decode(X.umrez,1,Y.rsu_umren,X.umrez*Y.rsu_umren)) as rsu_count
              from (select matnr, meinh,
                           nvl(umren,1) as umren,
                           nvl(umrez,1) as umrez
                    from sap_mat_uom
                    where meinh = 'CS'
				   ) X,
                   (select M.matnr as matnr,
                           nvl(max(decode(M.rnkseq,1,M.umren)),0) as mcu_umrez,
                           nvl(max(decode(M.rnkseq,1,M.umren)),0) as mcu_umren,
                           max(decode(M.rnkseq,1,M.meinh)) as mcu_meinh,
                           nvl(max(decode(M.rnkseq,2,M.umrez)),0) as rsu_umrez,
                           nvl(max(decode(M.rnkseq,2,M.umren)),0) as rsu_umren,
                           max(decode(M.rnkseq,2,M.meinh)) as rsu_meinh
                    from (select A.matnr as matnr,
                                 A.rnkseq as rnkseq,
                                 max(A.meinh) as meinh,
                                 max(A.umren) as umren,
                                 max(A.umrez) as umrez
                          from (select matnr, meinh,
                                       umren, umrez,
                                       dense_rank() over (partition by matnr order by umren asc) as rnkseq
                                from sap_mat_uom
                                where meinh != 'EA'
                                  and meinh != 'CS'
                                  and umrez = 1) A
                                group by A.matnr, A.rnkseq
								) M
                    group by M.matnr) Y
              where X.matnr = Y.matnr(+)
			 ) t02
      where t01.matl_code = t02.matl_code(+)
	  group by t01.matl_code,t01.billing_eff_yyyypp;
	  rcd_sales csr_sales%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Care Extract Venus - Extract sales');

      /*-*/
      /* Clear the extract data
      /*-*/
      tbl_output.delete;

      /*-*/
      /* Retrieve the sales data
      /*-*/
      open csr_sales;
      loop
         fetch csr_sales into rcd_sales;
         if csr_sales%notfound then
            exit;
         end if;

         /*-*/
         /* Output the sales details
         /*-*/
         var_output := 'DET';
         var_output := var_output || rpad(rcd_sales.matl_code,18,' ');
         var_output := var_output || lpad(to_char(rcd_sales.sales_cases,'999999999990.999990'),20,' ');
         var_output := var_output || lpad(to_char(rcd_sales.num_units_case,'fm9990'),4,' ');
         var_output := var_output || lpad(to_char(rcd_sales.num_outers_case,'fm9990'),4,' ');
         tbl_output(tbl_output.count + 1) := var_output;

      end loop;
      close csr_sales;

      /*-*/
      /* Create the interface
      /*-*/
      var_file_name := 'SALCAR01.TXT';
      var_instance := lics_outbound_loader.create_interface('CDWCAR01',var_file_name);

      /*-*/
      /* Append the header record
      /*-*/
      var_output := 'HDR';
      var_output := var_output || to_char(sysdate,'yyyymmddhh24miss');
      var_output := var_output || rpad(par_source,20,' ');
      var_output := var_output || to_char(par_period,'fm000000');
      var_output := var_output || lpad(to_char(tbl_output.count,'fm9999999990'),10,' ');
      var_output := var_output || 'GRD';
      lics_outbound_loader.append_data(var_output);

      /*-*/
      /* Append the detail records
      /*-*/
      for idx in 1..tbl_output.count loop
         lics_outbound_loader.append_data(tbl_output(idx));
      end loop;

      /*-*/
      /* Finalise the interface
      /*-*/
      lics_outbound_loader.finalise_interface;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Care Extract Venus - Extract sales');

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
         /* Finalise the outbound loader when required
         /*-*/
         if lics_outbound_loader.is_created = true then
            lics_outbound_loader.add_exception(var_exception);
            lics_outbound_loader.finalise_interface;
         end if;

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**ERROR** - Care Extract Venus - Extract sales - ' || var_exception);
            lics_logging.write_log('End - Care Extract Venus - Extract sales');
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
   end extract_sales;

end care_sales_extract_venus;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym care_sales_extract_venus for ods_app.care_sales_extract_venus;
grant execute on care_sales_extract_venus to public;
