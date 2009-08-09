
/******************/
/* Package Header */
/******************/
create or replace package care_factory_sales_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : care_factory_sales_extract
    Owner   : ods_app

    Description
    -----------
    Care - Sales Factory Extract Venus Version

    This package contains the sales extract procedure for the Care system. The package exposes
    one procedure EXECUTE that performs the extract based on the following parameters:

    1. PAR_ROLLUP (Rollup codes - comma delimited string) (MANDATORY, CODE LENGTH 4)

       *NONE = Extract is performed for planning source codes
       XXXX = Extract is performed for rollup code

    2. PAR_PLNG_SRCE (Planning source codes - comma delimited string) (MANDATORY, CODE LENGTH 4)
       
       XX99 where XX = Care prefix (e. AU) and 99 = Venus planning source code

    3. PAR_COMPANY (Company code) (MANDATORY, MAXIMUM LENGTH 6)

    4. PAR_SEGMENT (Business segment code) (MANDATORY, MAXIMUM LENGTH 4)

    5. PAR_PERIOD (Mars period to extract) (MANDATORY, MAXIMUM LENGTH 6)

       YYYYPP - Period number
       *LAST - Last completed period

    YYYY/MM   Author         Description
    -------   ------         -----------
    2007/03   Steve Gregan   Created
    2007/05   Steve Gregan   Included rollup functionality
    2007/05   Steve Gregan   Included execute all functionality
    2007/05   Steve Gregan   Included domestic and affiliate
    2007/05   Steve Gregan   Added country code filters

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute_all(par_period in varchar2);
   procedure execute(par_rollup in varchar2, par_plng_srce in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2);

end care_factory_sales_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body care_factory_sales_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure extract(par_rollup in varchar2, par_plng_srce in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2);
   procedure extract_sales(par_rollup in varchar2, par_plng_srce in varchar2, par_company01 in varchar2, par_company02 in varchar2, par_company03 in varchar2, par_segment in varchar2, par_period in number);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'Care Factory Sales Extract';
   con_alt_group constant varchar2(32) := 'CARE_EXTRACT';
   con_alt_code constant varchar2(32) := 'ALERT_STRING';
   con_ema_group constant varchar2(32) := 'CARE_EXTRACT';
   con_ema_code constant varchar2(32) := 'EMAIL_GROUP';

   /*-*/
   /* Private definitions
   /*-*/
   var_hidx number;
   type typ_output is table of varchar2(4000) index by binary_integer;
   tbl_output typ_output;
   type rcd_rollup is record(matl_code varchar2(18 char),
                             cntry_code_en varchar2(20 char),
                             sales_cases number,
                             num_units_case number,
                             num_outers_case number);
   type typ_rollup is table of rcd_rollup index by varchar2(64 char);
   tbl_rollup typ_rollup;

   /***************************************************/
   /* This procedure performs the execute all routine */
   /***************************************************/
   procedure execute_all(par_period in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_file_name varchar2(64);
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_errors boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CARE FACTORY SALES - EXTRACT ALL';
      var_log_search := 'CARE_FACTORY_SALES_EXTRACT_ALL';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Care Factory Sales Extract All - Parameters(' || par_period || ')');

      /*-*/
      /* Perform the extracts
      /*-*/
      begin

         /*-*/
         /* Clear the extract data when required
         /*-*/
         var_hidx := 0;
         tbl_output.delete;

         /*-*/
         /* Extract executions
         /*-*/
         extract('*NONE','AU01,AU02,AU03,AU04,AU05,AU06,AU07,AU08,AU11,AU12,NZ09,NZ10','147,149','05',par_period);
         extract('AU91','AU01,AU02,AU03,AU04,AU05,AU06','147,149','05',par_period);
         extract('AU92','AU07,AU08','147,149','05',par_period);
         extract('NZ93','NZ09,NZ10','147,149','05',par_period);
         extract('AU99','AU01,AU02,AU03,AU04,AU05,AU06,AU07,AU08,AU11,AU12,NZ09,NZ10','147,149','05',par_period);


AU14 - Ballarat Factory (Direct from Atlas)
AU15 - Scoresby Factory (Direct from Atlas)
AU16 - Snack BIFG (Direct from Atlas)
AU17 - Snack CoCoSub (Direct from Atlas)
AU89 - Aus Snack (AU14 + AU15 + AU16 + AU17)

00	Not Applicable
01	Wodonga Can
02	Wodonga Flexi
03	Wodonga Single Serve
04	Wodonga Nutri
05	Wodonga Pilot
06	Wodonga Winergy
07	Bathurst Dry
08	Bathurst Snacks
09	Wanganui Chilled
10	Wanganui Pouch
11	Pet Affiliate Imports
12	Pet BIFG
13	Wacol
14	Ballarat Factory
15	Scoresby Factory
16	Snack BIFG
17	Snack CoCoSub



         /*-*/
         /* Create the interface
         /*-*/
         var_file_name := 'SALCAR01.TXT';
         var_instance := lics_outbound_loader.create_interface('CDWCAR01',var_file_name);

         /*-*/
         /* Append the interface records
         /*-*/
         for idx in 1..tbl_output.count loop
            lics_outbound_loader.append_data(tbl_output(idx));
         end loop;

         /*-*/
         /* Finalise the interface
         /*-*/
         lics_outbound_loader.finalise_interface;

      exception
         when others then
            if lics_outbound_loader.is_created = true then
               lics_outbound_loader.add_exception(substr(SQLERRM, 1, 2048));
               lics_outbound_loader.finalise_interface;
            end if;
            var_errors := true;
      end;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Care Factory Sales Extract All');

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
                                         'CARE_FACTORY_SALES_EXTRACT_ALL',
                                         var_email,
                                         'One or more errors occurred during the Care factory sales extract all execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - CARE FACTORY SALES - EXTRACT ALL - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute_all;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_rollup in varchar2, par_plng_srce in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_instance number(15,0);
      var_file_name varchar2(64);
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_errors boolean;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CARE FACTORY SALES - EXTRACT';
      var_log_search := 'CARE_FACTORY_SALES_EXTRACT';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_errors := false;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Care Factory Sales Extract - Parameters(' || upper(par_rollup) || ' + ' || upper(par_plng_srce) || ' + ' || par_company || ' + ' || par_segment || ' + ' || par_period || ')');

      /*-*/
      /* Perform the extract
      /*-*/
      begin

         /*-*/
         /* Clear the extract data when required
         /*-*/
         var_hidx := 0;
         tbl_output.delete;

         /*-*/
         /* Extract execution
         /*-*/
         extract(par_rollup, par_plng_srce, par_company, par_segment, par_period);

         /*-*/
         /* Create the interface
         /*-*/
         var_file_name := 'SALCAR01.TXT';
         var_instance := lics_outbound_loader.create_interface('CDWCAR01',var_file_name);

         /*-*/
         /* Append the interface records
         /*-*/
         for idx in 1..tbl_output.count loop
            lics_outbound_loader.append_data(tbl_output(idx));
         end loop;

         /*-*/
         /* Finalise the interface
         /*-*/
         lics_outbound_loader.finalise_interface;

      exception
         when others then
            if lics_outbound_loader.is_created = true then
               lics_outbound_loader.add_exception(substr(SQLERRM, 1, 2048));
               lics_outbound_loader.finalise_interface;
            end if;
            var_errors := true;
      end;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Care Factory Sales Extract');

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
                                         'CARE_FACTORY_SALES_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the Care factory sales extract execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - CARE FACTORY SALES - EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

   /***********************************************/
   /* This procedure performs the extract routine */
   /***********************************************/
   procedure extract(par_rollup in varchar2, par_plng_srce in varchar2, par_company in varchar2, par_segment in varchar2, par_period in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_period number(6,0);
      var_source varchar2(256);
      var_company varchar2(256);
      type typ_source is table of varchar2(64 char) index by binary_integer;
      type typ_company is table of varchar2(64 char) index by binary_integer;
      tbl_source typ_source;
      tbl_company typ_company;

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
      /* Log the event
      /*-*/
      lics_logging.write_log('Begin - Extract - Parameters(' || upper(par_rollup) || ' + ' || upper(par_plng_srce) || ' + ' || par_company || ' + ' || par_segment || ' + ' || par_period || ')');

      /*-*/
      /* Validate the rollup parameter
      /*-*/
      if par_rollup is null then
         raise_application_error(-20000, 'Rollup parameter (' || par_rollup || ') must be specified');
      end if;
      if length(par_rollup) > 10 then
         raise_application_error(-20000, 'Rollup parameter exceeds maximum length 10');
      end if;

      /*-*/
      /* Validate the planning source parameter
      /*-*/
      if par_plng_srce is null then
         raise_application_error(-20000, 'Planning source parameter must be specified');
      end if;
      tbl_source.delete;
      var_source := null;
      for idx in 1..length(par_plng_srce) loop
         if substr(par_plng_srce,idx,1) = ',' then
            if not(var_source is null) then
               if length(var_source) != 4 then
                  raise_application_error(-20000, 'Planning source code must be length 4');
               end if;
               tbl_source(tbl_source.count+1) := var_source;
            end if;
            var_source := null;
         elsif substr(par_plng_srce,idx,1) != ' ' then
            var_source := var_source||substr(par_plng_srce,idx,1);
         end if;
      end loop;
      if not(var_source is null) then
         if length(var_source) != 4 then
            raise_application_error(-20000, 'Planning source code must be length 4');
         end if;
         tbl_source(tbl_source.count+1) := var_source;
      end if;

      /*-*/
      /* Validate the company parameter
      /*-*/
      if par_company is null then
         raise_application_error(-20000, 'Company parameter (' || par_company || ') must be specified');
      end if;
      tbl_company.delete;
      var_company := null;
      for idx in 1..length(par_company) loop
         if substr(par_company,idx,1) = ',' then
            if not(var_company is null) then
               if length(var_company) > 6 then
                  raise_application_error(-20000, 'Company code exceeds maximum length 6');
               end if;
               tbl_company(tbl_company.count+1) := var_company;
            end if;
            var_company := null;
         elsif substr(par_company,idx,1) != ' ' then
            var_company := var_company||substr(par_company,idx,1);
         end if;
      end loop;
      if not(var_company is null) then
         if length(var_company) > 6 then
            raise_application_error(-20000, 'Company code exceeds maximum length 6');
         end if;
         tbl_company(tbl_company.count+1) := var_company;
      end if;
      if tbl_company.count > 3 then
         raise_application_error(-20000, 'Company parameters exceed maximum 3');
      end if;
      if not(tbl_company.exists(1)) then
         tbl_company(1) := '*NULL';
      end if;
      if not(tbl_company.exists(2)) then
         tbl_company(2) := '*NULL';
      end if;
      if not(tbl_company.exists(3)) then
         tbl_company(3) := '*NULL';
      end if;

      /*-*/
      /* Validate the segment parameter
      /*-*/
      if par_segment is null then
         raise_application_error(-20000, 'Segment parameter (' || par_segment || ') must be specified');
      end if;
      if length(par_segment) > 4 then
         raise_application_error(-20000, 'Segment code exceeds maximum length 4');
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
      /* Extract sales for each planning source or rollup
      /*-*/
      if trim(upper(par_rollup)) = '*NONE' then
         for idx in 1..tbl_source.count loop
            extract_sales(par_rollup, tbl_source(idx), tbl_company(1), tbl_company(2), tbl_company(3), par_segment, var_period);
         end loop;
      else
         tbl_rollup.delete;
         for idx in 1..tbl_source.count loop
            extract_sales('*BUILD', tbl_source(idx), tbl_company(1), tbl_company(2), tbl_company(3), par_segment, var_period);
         end loop;
         extract_sales(par_rollup, '*SEND', null, null, null, null, var_period);
      end if;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('End - Extract');

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Save the exception
         /*-*/
         var_exception := substr(SQLERRM, 1, 2048);

         /*-*/
         /* Log error
         /*-*/
         begin
            lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
         exception
            when others then
               null;
         end;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract;

   /*****************************************************/
   /* This procedure performs the extract sales routine */
   /*****************************************************/
   procedure extract_sales(par_rollup in varchar2, par_plng_srce in varchar2, par_company01 in varchar2, par_company02 in varchar2, par_company03 in varchar2, par_segment in varchar2, par_period in number) is

      /*-*/
      /* Local definitions
      /*-*/
      var_output varchar2(4000);
      var_lookup varchar2(64);

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_sales is
         select t01.matl_code as matl_code,
                t01.cntry_code_en,
                max(t01.billing_eff_yyyypp) as billing_eff_yyyypp,
                sum(decode(t01.billed_qty_uom_code,'PCE',t01.sales_cases/nvl(t02.rsu_count,1)
                                                  ,'PK',t01.sales_cases/nvl(t02.mcu_count,1)
                                                  ,'SB',t01.sales_cases/nvl(t02.mcu_count,1)
                                                  ,t01.sales_cases)) as sales_cases,
                max(nvl(t02.mcu_count,1)) as num_outers_case,
                max(nvl(t02.rsu_count,1)) as num_units_case
           from (select A.matl_code as matl_code,
                        A.billed_qty_uom_code,
                        A.billing_eff_yyyypp,
                        D.cntry_code_en,
                        sum(A.base_uom_billed_qty) as sales_cases
                  from sales_period_01_fact A,
                       matl_dim B,
                       cust_sales_area_dim C,
                       cust_dim D
                 where A.matl_code = B.matl_code
                   and A.sold_to_cust_code = C.cust_code
                   and A.hdr_distbn_chnl_code = C.distbn_chnl_code
                   and A.hdr_division_code = C.division_code
                   and A.hdr_sales_org_code = C.sales_org_code
                   and A.ship_to_cust_code = D.cust_code
                   and ((par_company01 != '*NULL' and A.company_code = par_company01) or
                        (par_company02 != '*NULL' and A.company_code = par_company02) or
                        (par_company03 != '*NULL' and A.company_code = par_company03))
                   and A.billing_eff_yyyypp = par_period
                   and B.plng_srce_code = substr(par_plng_srce,3,2)
                   and ((par_segment = '*ALL' and B.bus_sgmnt_code in ('01','02','05')) or B.bus_sgmnt_code = par_segment)
                   and (C.acct_assgnmnt_grp_code = '01' or C.acct_assgnmnt_grp_code = '03')
                   and D.cntry_code_en in ('AU','BN','KH','CN','CK','TP','PF','FJ','GU','HK','ID','JP','LA','MO','MY','MV','FM','MH','KP','NC','NZ','NF','PH','PG','PN','KR','AS','SG','SB','TW','TH','TO','VU','VN','WS','CX')
                 group by A.matl_code,
                          A.billing_eff_yyyypp,
                          A.billed_qty_uom_code,
                          D.cntry_code_en) t01,
               (select ltrim(X.matnr,' 0') as matl_code,
                       decode(Y.rsu_meinh,null,1,decode(X.umrez,1,Y.mcu_umren,X.umrez*Y.mcu_umren)) as mcu_count,
                       decode(Y.rsu_meinh,null,decode(X.umrez,1,Y.mcu_umren,X.umrez*Y.mcu_umren),decode(X.umrez,1,Y.rsu_umren,X.umrez*Y.rsu_umren)) as rsu_count
                  from (select matnr,
                               meinh,
                               nvl(umren,1) as umren,
                               nvl(umrez,1) as umrez
                          from sap_mat_uom
                         where meinh = 'CS') X,
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
                                  from (select matnr,
                                               meinh,
                                               umren,
                                               umrez,
                                               dense_rank() over (partition by matnr order by umren asc) as rnkseq
                                          from sap_mat_uom
                                         where meinh != 'EA'
                                           and meinh != 'CS'
                                           and umrez = 1) A
                                 group by A.matnr,
                                          A.rnkseq) M
                         group by M.matnr) Y
                 where X.matnr = Y.matnr(+)) t02
          where t01.matl_code = t02.matl_code(+)
	  group by t01.matl_code,
                   t01.cntry_code_en
	  order by t01.matl_code,
                   t01.cntry_code_en;
      rcd_sales csr_sales%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Extract factory sales - ' || par_rollup || ' / ' || par_plng_srce);

      /*-*/
      /* Set the header row when required
      /*-*/
      if trim(upper(par_rollup)) != '*BUILD' then
         tbl_output(tbl_output.count + 1) := 'HDR';
         var_hidx := tbl_output.count;
      end if;

      /*-*/
      /* Retrieve the sales data when required
      /*-*/
      if trim(upper(par_rollup)) = '*NONE'
      or trim(upper(par_rollup)) = '*BUILD' then
         open csr_sales;
         loop
            fetch csr_sales into rcd_sales;
            if csr_sales%notfound then
               exit;
            end if;
            if trim(upper(par_rollup)) = '*NONE' then
               var_output := 'DET';
               var_output := var_output || rpad(rcd_sales.matl_code,18,' ');
               var_output := var_output || lpad(to_char(rcd_sales.sales_cases,'999999999990.999990'),20,' ');
               var_output := var_output || lpad(to_char(rcd_sales.num_units_case,'fm9990'),4,' ');
               var_output := var_output || lpad(to_char(rcd_sales.num_outers_case,'fm9990'),4,' ');
               var_output := var_output || rpad(rcd_sales.cntry_code_en,20,' ');
               tbl_output(tbl_output.count + 1) := var_output;
            else
               var_lookup := upper(rcd_sales.matl_code)||'_'||upper(rcd_sales.cntry_code_en);
               if not(tbl_rollup.exists(var_lookup)) then
                  tbl_rollup(var_lookup).matl_code := rcd_sales.matl_code;
                  tbl_rollup(var_lookup).cntry_code_en := rcd_sales.cntry_code_en;
                  tbl_rollup(var_lookup).sales_cases := rcd_sales.sales_cases;
                  tbl_rollup(var_lookup).num_units_case := rcd_sales.num_units_case;
                  tbl_rollup(var_lookup).num_outers_case := rcd_sales.num_outers_case;
               else
                  tbl_rollup(var_lookup).sales_cases := tbl_rollup(var_lookup).sales_cases + rcd_sales.sales_cases;
               end if;
            end if;
         end loop;
         close csr_sales;
      end if;

      /*-*/
      /* Retrieve the rollup data when required
      /*-*/
      if trim(upper(par_rollup)) != '*NONE'
      and trim(upper(par_rollup)) != '*BUILD' then
         var_lookup := tbl_rollup.first;
         while not(var_lookup is null) loop
            var_output := 'DET';
            var_output := var_output || rpad(tbl_rollup(var_lookup).matl_code,18,' ');
            var_output := var_output || lpad(to_char(tbl_rollup(var_lookup).sales_cases,'999999999990.999990'),20,' ');
            var_output := var_output || lpad(to_char(tbl_rollup(var_lookup).num_units_case,'fm9990'),4,' ');
            var_output := var_output || lpad(to_char(tbl_rollup(var_lookup).num_outers_case,'fm9990'),4,' ');
            var_output := var_output || rpad(tbl_rollup(var_lookup).cntry_code_en,20,' ');
            tbl_output(tbl_output.count + 1) := var_output;
            var_lookup := tbl_rollup.next(var_lookup);
         end loop;
      end if;

      /*-*/
      /* Output the extract data when required
      /*-*/
      if trim(upper(par_rollup)) != '*BUILD' then

         /*-*/
         /* Append the header record
         /*-*/
         var_output := 'HDR';
         var_output := var_output || to_char(sysdate,'yyyymmddhh24miss');
         if trim(upper(par_rollup)) = '*NONE' then
            var_output := var_output || rpad(par_plng_srce,20,' ');
         else
            var_output := var_output || rpad(par_rollup,20,' ');
         end if;
         var_output := var_output || to_char(par_period,'fm000000');
         var_output := var_output || lpad(to_char(tbl_output.count-var_hidx,'fm9999999990'),10,' ');
         var_output := var_output || 'GRD';
         var_output := var_output || 'FCT';
         tbl_output(var_hidx) := var_output;

      end if;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Extract factory sales - ' || par_rollup || ' / ' || par_plng_srce);

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   exception

      /**/
      /* Exception trap
      /**/
      when others then

         /*-*/
         /* Raise an exception to the caller
         /*-*/
         raise_application_error(-20000, substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end extract_sales;

end care_factory_sales_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym care_factory_sales_extract for ods_app.care_factory_sales_extract;
grant execute on care_factory_sales_extract to public;
