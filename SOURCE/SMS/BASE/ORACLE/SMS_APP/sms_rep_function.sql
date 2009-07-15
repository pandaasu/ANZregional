/******************/
/* Package Header */
/******************/
create or replace package sms_app.sms_rep_function as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : sms_rep_function
    Owner   : sms_app

    Description
    -----------
    SMS Reporting System - Report functions

    This package contain the report functions and procedures.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2009/07   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure generate(par_qry_code in varchar2,
                      par_qry_date in varchar2,
                      par_action in varchar2,
                      par_alert in varchar2,
                      par_email in varchar2);

end sms_rep_function;
/

/****************/
/* Package Body */
/****************/
create or replace package body sms_app.sms_rep_function as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private declarations
   /*-*/
   procedure send_sms(par_smtp_host in varchar2,
                      par_smtp_port in varchar2,
                      par_qry_code in varchar2,
                      par_qry_date in varchar2,
                      par_msg_seqn in number,
                      par_subject in varchar2,
                      par_content in varchar2);
   function convert_value(par_value in varchar2, par_round in number) return varchar2;

   /*-*/
   /* Private definitions
   /*-*/
   pvar_end_code number;
   pvar_cfrm varchar2(2000 char);
   type ptyp_mesg is table of varchar2(2000 char) index by binary_integer;
   ptbl_mesg ptyp_mesg;

   /************************************************/
   /* This procedure performs the generate routine */
   /************************************************/
   procedure generate(par_qry_code in varchar2,
                      par_qry_date in varchar2,
                      par_action in varchar2,
                      par_alert in varchar2,
                      par_email in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_errors boolean;
      var_warnings boolean;
      var_found boolean;
      var_process boolean;
      var_sent boolean;
      var_smtp_host varchar2(256);
      var_smtp_port varchar2(256);
      var_subject varchar2(64);
      var_mes_count number;
      var_rec_count number;
      var_out_day varchar2(64);
      var_day_number number;
      var_level varchar2(64);
      var_detail varchar2(64);
      var_total varchar2(64);
      var_sav_val01 varchar2(256);
      var_sav_val02 varchar2(256);
      var_sav_val03 varchar2(256);
      var_sav_val04 varchar2(256);
      var_sav_val05 varchar2(256);
      var_sav_val06 varchar2(256);
      var_sav_val07 varchar2(256);
      var_sav_val08 varchar2(256);
      var_sav_val09 varchar2(256);
      var_sms_text varchar2(32767);
      var_sms_work varchar2(32767);
      rcd_sms_rpt_message sms_rpt_message%rowtype;
      rcd_sms_rpt_recipient sms_rpt_recipient%rowtype;
      type typ_count is table of integer index by binary_integer;
      tbl_dcnt typ_count;
      type typ_mlin is table of sms_mes_line%rowtype index by binary_integer;
      tbl_mlin typ_mlin;
      type typ_data is table of sms_rpt_data%rowtype index by binary_integer;
      tbl_data typ_data;
      type typ_text is table of varchar2(2000 char) index by binary_integer;
      tbl_text typ_text;

      /*-*/
      /* Local constants
      /*-*/
      con_function constant varchar2(128) := 'SMS Report Generation';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_report is
         select t01.*
           from sms_rpt_header t01
          where t01.rhe_qry_code = par_qry_code
            and t01.rhe_qry_date = par_qry_date
            for update;
      rcd_report csr_report%rowtype;

      cursor csr_query is
         select t01.*
           from sms_query t01
          where t01.que_qry_code = par_qry_code;
      rcd_query csr_query%rowtype;

      cursor csr_profile is
         select t01.*
           from sms_profile t01
          where t01.pro_qry_code = par_qry_code
            and t01.pro_status = '1'
          order by t01.pro_prf_code asc;
      rcd_profile csr_profile%rowtype;

      cursor csr_pro_message is
         select t02.*
           from sms_pro_message t01,
                sms_message t02
          where t01.pme_msg_code = t02.mes_msg_code
            and t01.pme_prf_code = rcd_profile.pro_prf_code
            and t02.mes_status = '1'
          order by t02.mes_msg_code asc;
      rcd_pro_message csr_pro_message%rowtype;

      cursor csr_mes_line is
         select t01.mli_msg_code,
                t01.mli_msg_line,
                nvl(t01.mli_det_text,'*NONE') as mli_det_text,
                nvl(t01.mli_tot_text,'*NONE') as mli_tot_text,
                t01.mli_tot_child
           from sms_mes_line t01
          where t01.mli_msg_code = rcd_pro_message.mes_msg_code
          order by t01.mli_msg_line asc;
      rcd_mes_line csr_mes_line%rowtype;

      cursor csr_pro_filter is
         select t02.*
           from sms_pro_filter t01,
                sms_filter t02
          where t01.pfi_flt_code = t02.fil_flt_code
            and t01.pfi_prf_code = rcd_profile.pro_prf_code
            and t02.fil_status = '1'
          order by t02.fil_flt_code asc;
      rcd_pro_filter csr_pro_filter%rowtype;

      cursor csr_pro_recipient is
         select t02.*
           from sms_pro_recipient t01,
                sms_recipient t02
          where t01.pre_rcp_code = t02.rec_rcp_code
            and t01.pre_prf_code = rcd_profile.pro_prf_code
            and t02.rec_status = '1'
          order by t02.rec_rcp_code asc;
      rcd_pro_recipient csr_pro_recipient%rowtype;

      cursor csr_rpt_data is
         select t01.rda_qry_code,
                t01.rda_qry_date,
                t01.rda_dat_seqn,
                nvl(t01.rda_dim_cod01,'*NONE') as rda_dim_cod01,
                nvl(t01.rda_dim_cod02,'*NONE') as rda_dim_cod02,
                nvl(t01.rda_dim_cod03,'*NONE') as rda_dim_cod03,
                nvl(t01.rda_dim_cod04,'*NONE') as rda_dim_cod04,
                nvl(t01.rda_dim_cod05,'*NONE') as rda_dim_cod05,
                nvl(t01.rda_dim_cod06,'*NONE') as rda_dim_cod06,
                nvl(t01.rda_dim_cod07,'*NONE') as rda_dim_cod07,
                nvl(t01.rda_dim_cod08,'*NONE') as rda_dim_cod08,
                nvl(t01.rda_dim_cod09,'*NONE') as rda_dim_cod09,
                nvl(t01.rda_dim_val01,'*NONE') as rda_dim_val01,
                nvl(t01.rda_dim_val02,'*NONE') as rda_dim_val02,
                nvl(t01.rda_dim_val03,'*NONE') as rda_dim_val03,
                nvl(t01.rda_dim_val04,'*NONE') as rda_dim_val04,
                nvl(t01.rda_dim_val05,'*NONE') as rda_dim_val05,
                nvl(t01.rda_dim_val06,'*NONE') as rda_dim_val06,
                nvl(t01.rda_dim_val07,'*NONE') as rda_dim_val07,
                nvl(t01.rda_dim_val08,'*NONE') as rda_dim_val08,
                nvl(t01.rda_dim_val09,'*NONE') as rda_dim_val09,
                nvl(t01.rda_val_code,'*NONE') as rda_val_code,
                nvl(t01.rda_val_data,'*NONE') as rda_val_data
           from sms_rpt_data t01
          where t01.rda_qry_code = par_qry_code
            and t01.rda_qry_date = par_qry_date
            and (nvl(rcd_pro_filter.fil_dim_val01,'*ALL') = '*ALL' or nvl(t01.rda_dim_val01,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val01,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val02,'*ALL') = '*ALL' or nvl(t01.rda_dim_val02,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val02,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val03,'*ALL') = '*ALL' or nvl(t01.rda_dim_val03,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val03,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val04,'*ALL') = '*ALL' or nvl(t01.rda_dim_val04,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val04,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val05,'*ALL') = '*ALL' or nvl(t01.rda_dim_val05,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val05,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val06,'*ALL') = '*ALL' or nvl(t01.rda_dim_val06,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val06,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val07,'*ALL') = '*ALL' or nvl(t01.rda_dim_val07,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val07,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val08,'*ALL') = '*ALL' or nvl(t01.rda_dim_val08,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val08,'*ALL'),'*TOTAL'))
            and (nvl(rcd_pro_filter.fil_dim_val09,'*ALL') = '*ALL' or nvl(t01.rda_dim_val09,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val09,'*ALL'),'*TOTAL'))
          order by t01.rda_dat_seqn asc;
      rcd_rpt_data csr_rpt_data%rowtype;

      cursor csr_rpt_message is
         select t01.*
           from sms_rpt_message t01
          where t01.rme_qry_code = par_qry_code
            and t01.rme_qry_date = par_qry_date
          order by t01.rme_msg_seqn asc;
      rcd_rpt_message csr_rpt_message%rowtype;

      cursor csr_rcp_count is
         select count(*) as rec_count
           from sms_rpt_recipient t01
          where t01.rre_qry_code = par_qry_code
            and t01.rre_qry_date = par_qry_date
            and t01.rre_msg_seqn = rcd_rpt_message.rme_msg_seqn;
      rcd_rcp_count csr_rcp_count%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'SMS - REPORT_GENERATION';
      var_log_search := 'SMS_REPORT_GENERATION';
      var_errors := false;
      var_warnings := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_qry_code is null then
         raise_application_error(-20000, 'Query code must be supplied');
      end if;
      if par_qry_date is null then
         raise_application_error(-20000, 'Query date must be supplied');
      end if;
      if upper(par_action) != '*AUTO' and upper(par_action) != '*MANUAL' then
         raise_application_error(-20000, 'Action must be *AUTO or *MANUAL');
      end if;

      /*-*/
      /* Retrieve SMTP server values
      /*-*/
      var_smtp_host := sms_gen_function.retrieve_system_value('SMTP_HOST');
      var_smtp_port := sms_gen_function.retrieve_system_value('SMTP_PORT');
      if trim(var_smtp_host) is null or trim(upper(var_smtp_host)) = '*NONE' then
         raise_application_error(-20000, 'SMTP host system value has not been specified');
      end if;
      if trim(var_smtp_port) is null or trim(upper(var_smtp_port)) = '*NONE' then
         raise_application_error(-20000, 'SMTP port system value has not been specified');
      end if;

      /*-*/
      /* Retrieve and lock the report
      /*-*/
      var_found := false;
      begin
         open csr_report;
         fetch csr_report into rcd_report;
         if csr_report%found then
            var_found := true;
         end if;
         close csr_report;
      exception
         when others then
            raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_qry_date||') is currently locked');
      end;
      if var_found = false then
         raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_qry_date||') not found on the report header table');
      end if;
      if par_action = '*AUTO' then
         if rcd_report.rhe_status != '1' then
            raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_qry_date||') must be status loaded for processing action *AUTO');
         end if;
      end if;
      if par_action = '*MANUAL' then
         if rcd_report.rhe_status = '1' then
            raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_qry_date||') must not be status loaded for processing action *MANUAL');
         end if;
      end if;

      /*-*/
      /* Retrieve the related query
      /*-*/
      var_found := false;
      open csr_query;
      fetch csr_query into rcd_query;
      if csr_query%found then
         var_found := true;
      end if;
      close csr_query;
      if var_found = false then
         raise_application_error(-20000, 'Query ('||par_qry_code||') not found on the query table');
      end if;
      if rcd_query.que_status != '1' then
         raise_application_error(-20000, 'Query ('||par_qry_code||') must be status active');
      end if;
      var_subject := rcd_query.que_ema_subject;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SMS Report Generation - Parameters(' || par_qry_code || ' + ' || par_qry_date || ' + ' || par_action || ')');

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Processing SMS query - '||par_qry_code);

      /*-*/
      /* Initialise the output day
      /*-*/
      if (to_number(substr(to_char(rcd_report.rhe_crt_yyyyppw,'fm0000000'),7,1)) = 1 and
          to_number(trim(to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'D')))-2 = 0) then
         var_out_day := 'P'||to_char(to_number(substr(to_char(rcd_report.rhe_crt_yyyypp,'fm000000'),5,2)),'fm90')||
                        'W4D5';
      else
         var_out_day := 'P'||to_char(to_number(substr(to_char(rcd_report.rhe_crt_yyyypp,'fm000000'),5,2)),'fm90')||
                        'W'||substr(to_char(rcd_report.rhe_crt_yyyyppw,'fm0000000'),7,1)||
                        'D'||to_char(to_number(trim(to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'D')))-2);
      end if;
      var_day_number := to_number(trim(to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'D')));

      /*-*/
      /* Initialise the report message data
      /*-*/
      rcd_sms_rpt_message.rme_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_message.rme_qry_date := rcd_report.rhe_qry_date;
      rcd_sms_rpt_message.rme_msg_seqn := 0;

      /*-*/
      /* Initialise the report recipient data
      /*-*/
      rcd_sms_rpt_recipient.rre_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_recipient.rre_qry_date := rcd_report.rhe_qry_date;

      /*-*/
      /* Retrieve the report query profiles
      /*-*/
      open csr_profile;
      loop
         fetch csr_profile into rcd_profile;
         if csr_profile%notfound then
            exit;
         end if;

         /*-*/
         /* Check the profile processing status
         /*-*/
         var_process := false;
         if var_day_number = 1 and rcd_profile.pro_snd_day01 = '1' then
            var_process := true;
         elsif var_day_number = 2 and rcd_profile.pro_snd_day02 = '1' then
            var_process := true;
         elsif var_day_number = 3 and rcd_profile.pro_snd_day03 = '1' then
            var_process := true;
         elsif var_day_number = 4 and rcd_profile.pro_snd_day04 = '1' then
            var_process := true;
         elsif var_day_number = 5 and rcd_profile.pro_snd_day05 = '1' then
            var_process := true;
         elsif var_day_number = 6 and rcd_profile.pro_snd_day06 = '1' then
            var_process := true;
         elsif var_day_number = 7 and rcd_profile.pro_snd_day07 = '1' then
            var_process := true;
         end if;
         if var_process = false then

            /*-*/
            /* Log the event
            /*-*/
            lics_logging.write_log('#---> SMS profile - ('||rcd_profile.pro_prf_code||') '||rcd_profile.pro_prf_name||' - not not processesed on '||to_char(to_date(rcd_report.rhe_crt_date,'yyyymmdd'),'yyyy/mm/dd'));

         else

            /*-*/
            /* Log the event
            /*-*/
            lics_logging.write_log('#---> Processing SMS profile - ('||rcd_profile.pro_prf_code||') '||rcd_profile.pro_prf_name);

            /*-*/
            /* Retrieve the report query profile messages
            /*-*/
            open csr_pro_message;
            loop
               fetch csr_pro_message into rcd_pro_message;
               if csr_pro_message%notfound then
                  exit;
               end if;

               /*-*/
               /* Log the event
               /*-*/
               lics_logging.write_log('#-----> Processing SMS message - ('||rcd_pro_message.mes_msg_code||') '||rcd_pro_message.mes_msg_name);

               /*-*/
               /* Retrieve and load the related message line data
               /*-*/
               tbl_mlin.delete;
               tbl_text.delete;
               open csr_mes_line;
               fetch csr_mes_line bulk collect into tbl_mlin;
               close csr_mes_line;

               /*-*/
               /* Retrieve the report query profile filters
               /*-*/
               open csr_pro_filter;
               loop
                  fetch csr_pro_filter into rcd_pro_filter;
                  if csr_pro_filter%notfound then
                     exit;
                  end if;

                  /*-*/
                  /* Log the event
                  /*-*/
                  lics_logging.write_log('#-------> Processing SMS filter - ('||rcd_pro_filter.fil_flt_code||') '||rcd_pro_filter.fil_flt_name);

                  /*-*/
                  /* Initialise the message instance
                  /*-*/
                  tbl_text.delete;

                  /*-*/
                  /* Retrieve and load the report data based on the related filter
                  /*-*/
                  tbl_data.delete;
                  open csr_rpt_data;
                  fetch csr_rpt_data bulk collect into tbl_data;
                  close csr_rpt_data;

                  /*-*/
                  /* Initialise the data control variables
                  /*-*/
                  var_sav_val01 := '*START';
                  var_sav_val02 := '*START';
                  var_sav_val03 := '*START';
                  var_sav_val04 := '*START';
                  var_sav_val05 := '*START';
                  var_sav_val06 := '*START';
                  var_sav_val07 := '*START';
                  var_sav_val08 := '*START';
                  var_sav_val09 := '*START';
                  for idy in 1..tbl_mlin.count loop
                     tbl_dcnt(idy) := 0;
                  end loop;

                  /*-*/
                  /* Process the repprt data
                  /*-*/
                  for idx in 1..tbl_data.count loop

                     /*-*/
                     /* Change in repprt data dimensions
                     /*-*/
                     if tbl_data(idx).rda_dim_val01 != var_sav_val01 or
                        tbl_data(idx).rda_dim_val02 != var_sav_val02 or
                        tbl_data(idx).rda_dim_val03 != var_sav_val03 or
                        tbl_data(idx).rda_dim_val04 != var_sav_val04 or
                        tbl_data(idx).rda_dim_val05 != var_sav_val05 or
                        tbl_data(idx).rda_dim_val06 != var_sav_val06 or
                        tbl_data(idx).rda_dim_val07 != var_sav_val07 or
                        tbl_data(idx).rda_dim_val08 != var_sav_val08 or
                        tbl_data(idx).rda_dim_val09 != var_sav_val09 then

                        /*-*/
                        /* Determine the highest change level
                        /*-*/
                        var_level := '*NONE';
                        if tbl_data(idx).rda_dim_val01 != var_sav_val01 then
                           var_level := '*LVL01';
                        elsif tbl_data(idx).rda_dim_val02 != var_sav_val02 then
                           var_level := '*LVL02';
                        elsif tbl_data(idx).rda_dim_val03 != var_sav_val03 then
                           var_level := '*LVL03';
                        elsif tbl_data(idx).rda_dim_val04 != var_sav_val04 then
                           var_level := '*LVL04';
                        elsif tbl_data(idx).rda_dim_val05 != var_sav_val05 then
                           var_level := '*LVL05';
                        elsif tbl_data(idx).rda_dim_val06 != var_sav_val06 then
                           var_level := '*LVL06';
                        elsif tbl_data(idx).rda_dim_val07 != var_sav_val07 then
                           var_level := '*LVL07';
                        elsif tbl_data(idx).rda_dim_val08 != var_sav_val08 then
                           var_level := '*LVL08';
                        elsif tbl_data(idx).rda_dim_val09 != var_sav_val09 then
                           var_level := '*LVL09';
                        end if;

                        /*-*/
                        /* Determine the detail level
                        /*-*/
                        var_detail := '*NONE';
                        if tbl_data(idx).rda_dim_val01 != '*NONE' then
                           var_detail := '*LVL01';
                        end if;
                        if tbl_data(idx).rda_dim_val02 != '*NONE' then
                           var_detail := '*LVL02';
                        end if;
                        if tbl_data(idx).rda_dim_val03 != '*NONE' then
                           var_detail := '*LVL03';
                        end if;
                        if tbl_data(idx).rda_dim_val04 != '*NONE' then
                           var_detail := '*LVL04';
                        end if;
                        if tbl_data(idx).rda_dim_val05 != '*NONE' then
                           var_detail := '*LVL05';
                        end if;
                        if tbl_data(idx).rda_dim_val06 != '*NONE' then
                           var_detail := '*LVL06';
                        end if;
                        if tbl_data(idx).rda_dim_val07 != '*NONE' then
                           var_detail := '*LVL07';
                        end if;
                        if tbl_data(idx).rda_dim_val08 != '*NONE' then
                           var_detail := '*LVL08';
                        end if;
                        if tbl_data(idx).rda_dim_val09 != '*NONE' then
                           var_detail := '*LVL09';
                        end if;

                        /*-*/
                        /* Determine the total level
                        /*-*/
                        var_total := '*NONE';
                        if tbl_data(idx).rda_dim_val02 = '*TOTAL' then
                           var_total := '*LVL01';
                        elsif tbl_data(idx).rda_dim_val03 = '*TOTAL' then
                           var_total := '*LVL02';
                        elsif tbl_data(idx).rda_dim_val04 = '*TOTAL' then
                           var_total := '*LVL03';
                        elsif tbl_data(idx).rda_dim_val05 = '*TOTAL' then
                           var_total := '*LVL04';
                        elsif tbl_data(idx).rda_dim_val06 = '*TOTAL' then
                           var_total := '*LVL05';
                        elsif tbl_data(idx).rda_dim_val07 = '*TOTAL' then
                           var_total := '*LVL06';
                        elsif tbl_data(idx).rda_dim_val08 = '*TOTAL' then
                           var_total := '*LVL07';
                        elsif tbl_data(idx).rda_dim_val09 = '*TOTAL' then
                           var_total := '*LVL08';
                        end if;

                        /*-*/
                        /* Save the current dimension values
                        /*-*/
                        var_sav_val01 := tbl_data(idx).rda_dim_val01;
                        var_sav_val02 := tbl_data(idx).rda_dim_val02;
                        var_sav_val03 := tbl_data(idx).rda_dim_val03;
                        var_sav_val04 := tbl_data(idx).rda_dim_val04;
                        var_sav_val05 := tbl_data(idx).rda_dim_val05;
                        var_sav_val06 := tbl_data(idx).rda_dim_val06;
                        var_sav_val07 := tbl_data(idx).rda_dim_val07;
                        var_sav_val08 := tbl_data(idx).rda_dim_val08;
                        var_sav_val09 := tbl_data(idx).rda_dim_val09;

                        /*-*/
                        /* Update the heading data as required
                        /*-*/
                        if var_total = '*NONE' then
                           for idy in 1..tbl_mlin.count loop
                              if upper(tbl_mlin(idy).mli_msg_line) >= var_level then
                                 tbl_dcnt(idy) := 0;
                              end if;
                           end loop;
                           if var_level = var_detail then
                              for idy in 1..tbl_mlin.count loop
                                 if upper(tbl_mlin(idy).mli_msg_line) < var_detail then
                                    tbl_dcnt(idy) := tbl_dcnt(idy) + 1;
                                 end if;
                              end loop;
                           end if;
                           for idy in 1..tbl_mlin.count loop
                              if (upper(tbl_mlin(idy).mli_msg_line) >= var_level and
                                  upper(tbl_mlin(idy).mli_msg_line) <= var_detail and
                                  upper(tbl_mlin(idy).mli_det_text) != '*NONE') then
                                 var_sms_work := tbl_mlin(idy).mli_det_text;
                                 var_sms_work := replace(var_sms_work,'<MARS_DAY>',var_out_day);
                                 if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val01));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val02));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val03));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val04));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val05));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val06));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val07));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val08));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val09));
                                 end if;
                                 tbl_text(tbl_text.count+1) := var_sms_work;
                              end if;
                           end loop;
                        else
                           for idy in 1..tbl_mlin.count loop
                              if (upper(tbl_mlin(idy).mli_msg_line) = var_total and
                                  upper(tbl_mlin(idy).mli_tot_text) != '*NONE' and
                                  (tbl_mlin(idy).mli_tot_child = '1' or (tbl_mlin(idy).mli_tot_child = '2' and tbl_dcnt(idy) > 1))) then
                                 var_sms_work := tbl_mlin(idy).mli_tot_text;
                                 var_sms_work := replace(var_sms_work,'<MARS_DAY>',var_out_day);
                                 if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val01));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val02));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val03));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val04));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val05));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val06));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val07));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val08));
                                 elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                    var_sms_work := replace(var_sms_work,'<DIM_NAME>',sms_gen_function.retrieve_abbreviation(tbl_data(idx).rda_dim_val09));
                                 end if;
                                 tbl_text(tbl_text.count+1) := var_sms_work;
                              end if;
                           end loop;
                        end if;

                     end if;

                     /*-*/
                     /* Update the detail and total lines as required
                     /*-*/
                     if var_total = '*NONE' then
                        for idy in 1..tbl_mlin.count loop
                           if (upper(tbl_mlin(idy).mli_msg_line) = var_detail and
                               upper(tbl_mlin(idy).mli_det_text) != '*NONE') then
                              var_sms_work := tbl_text(tbl_text.count);
                              if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              end if;
                              tbl_text(tbl_text.count) := var_sms_work;
                           end if;
                        end loop;
                     else
                        for idy in 1..tbl_mlin.count loop
                           if (upper(tbl_mlin(idy).mli_msg_line) = var_total and
                               upper(tbl_mlin(idy).mli_tot_text) != '*NONE' and
                               (tbl_mlin(idy).mli_tot_child = '1' or (tbl_mlin(idy).mli_tot_child = '2' and tbl_dcnt(idy) > 1))) then
                              var_sms_work := tbl_text(tbl_text.count);
                              if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                 var_sms_work := replace(var_sms_work,'<'||tbl_data(idx).rda_val_code||'>',convert_value(tbl_data(idx).rda_val_data,0));
                              end if;
                              tbl_text(tbl_text.count) := var_sms_work;
                           end if;
                        end loop;
                     end if;

                  end loop;

                  /*-*/
                  /* Process the message when report data found
                  /*-*/
                  if tbl_data.count != 0 then

                     /*-*/
                     /* Increment the message count
                     /*-*/
                     var_mes_count := var_mes_count +1;

                     /*-*/
                     /* Build and insert the report message
                     /*-*/
                     var_sms_text := null;
                     for idt in 1..tbl_text.count loop
                        if not(var_sms_text is null) then
                           var_sms_text := var_sms_text || utl_tcp.CRLF;
                        end if;
                        var_sms_text := var_sms_text || tbl_text(idt);
                     end loop;
                     rcd_sms_rpt_message.rme_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn + 1;
                     rcd_sms_rpt_message.rme_msg_text := substr(var_sms_text,1,2000);
                     rcd_sms_rpt_message.rme_msg_time := sysdate;
                     rcd_sms_rpt_message.rme_msg_status := '1';
                     insert into sms_rpt_message values rcd_sms_rpt_message;

                     /*-*/
                     /* Retrieve and attached all profile recipients
                     /*-*/
                     var_rec_count := 0;
                     open csr_pro_recipient;
                     loop
                        fetch csr_pro_recipient into rcd_pro_recipient;
                        if csr_pro_recipient%notfound then
                           exit;
                        end if;
                        var_rec_count := var_rec_count + 1;
                        rcd_sms_rpt_recipient.rre_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn;
                        rcd_sms_rpt_recipient.rre_rcp_code := rcd_pro_recipient.rec_rcp_code;
                        rcd_sms_rpt_recipient.rre_rcp_name := rcd_pro_recipient.rec_rcp_name;
                        rcd_sms_rpt_recipient.rre_rcp_mobile := rcd_pro_recipient.rec_rcp_mobile;
                        rcd_sms_rpt_recipient.rre_rcp_email := rcd_pro_recipient.rec_rcp_email;
                        insert into sms_rpt_recipient values rcd_sms_rpt_recipient;
                     end loop;
                     close csr_pro_recipient;

                     /*-*/
                     /* Log the event
                     /*-*/
                     lics_logging.write_log('#---------> Message constructed and attached to '||to_char(var_rec_count)||' recipient(s)');

                  else

                     /*-*/
                     /* Log the event
                     /*-*/
                     lics_logging.write_log('#---------> No report data found for the filter dimensions');

                  end if;

               end loop;
               close csr_pro_filter;

            end loop;
            close csr_pro_message;

         end if;

      end loop;
      close csr_profile;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Sending SMS messages to recipients');

      /*-*/
      /* Send the report messages
      /*-*/
      open csr_rpt_message;
      loop
         fetch csr_rpt_message into rcd_rpt_message;
         if csr_rpt_message%notfound then
            exit;
         end if;
         var_sent := true;
         open csr_rcp_count;
         fetch csr_rcp_count into rcd_rcp_count;
         if csr_rcp_count%notfound then
            rcd_rcp_count.rec_count := 0;
         end if;
         close csr_rcp_count;
         if rcd_rcp_count.rec_count != 0 then
            begin
               send_sms(var_smtp_host,
                        var_smtp_port,
                        rcd_rpt_message.rme_qry_code,
                        rcd_rpt_message.rme_qry_date,
                        rcd_rpt_message.rme_msg_seqn,
                        var_subject,
                        rcd_sms_rpt_message.rme_msg_text);
            exception
               when others then
                  var_warnings := true;
                  var_sent := false;
                  lics_logging.write_log('#---> **WARNING** - SMS message ('||to_char(rcd_rpt_message.rme_msg_seqn)||') send failed - '||substr(sqlerrm, 1, 2000));
            end;
         else
            var_warnings := true;
            var_sent := false;
            lics_logging.write_log('#---> **WARNING** - SMS message ('||to_char(rcd_rpt_message.rme_msg_seqn)||') not sent - no recipients attached');
         end if;
         if var_sent = true then
            update sms_rpt_message
               set rme_msg_status = '2'
             where rme_qry_code = rcd_rpt_message.rme_qry_code
               and rme_qry_date = rcd_rpt_message.rme_qry_date
               and rme_msg_seqn = rcd_rpt_message.rme_msg_seqn;
         else
            update sms_rpt_message
               set rme_msg_status = '3'
             where rme_qry_code = rcd_rpt_message.rme_qry_code
               and rme_qry_date = rcd_rpt_message.rme_qry_date
               and rme_msg_seqn = rcd_rpt_message.rme_msg_seqn;
         end if;
      end loop;
      close csr_rpt_message;

      /*-*/
      /* Log the event
      /*-*/
      lics_logging.write_log('#-> Updating the report status');

      /*-*/
      /* Update the report header to processed
      /*-*/
      update sms_rpt_header
         set rhe_status = '2'
       where rhe_qry_code = par_qry_code
         and rhe_rpt_date = par_qry_date;

      /*-*/
      /* Commit the database
      /*-*/
      commit;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - SMS Report Generation');

      /*-*/
      /* Log end
      /*-*/
      lics_logging.end_log;

      /*-*/
      /* Warnings
      /*-*/
      if var_warnings = true then

         /*-*/
         /* Email
         /*-*/
         if not(trim(par_email) is null) and trim(upper(par_email)) != '*NONE' then
            lics_notification.send_email(sms_parameter.system_code,
                                         sms_parameter.system_unit,
                                         sms_parameter.system_environment,
                                         con_function,
                                         'SMS_REPORT_GENERATION',
                                         par_email,
                                         'SMS message warnings occurred during the SMS Report Generation execution - refer to web log - ' || lics_logging.callback_identifier);
         end if;

      end if;

      /*-*/
      /* Errors
      /*-*/
      if var_errors = true then

         /*-*/
         /* Alert and email
         /*-*/
         if not(trim(par_alert) is null) and trim(upper(par_alert)) != '*NONE' then
            lics_notification.send_alert(par_alert);
         end if;
         if not(trim(par_email) is null) and trim(upper(par_email)) != '*NONE' then
            lics_notification.send_email(sms_parameter.system_code,
                                         sms_parameter.system_unit,
                                         sms_parameter.system_environment,
                                         con_function,
                                         'SMS_REPORT_GENERATION',
                                         par_email,
                                         'One or more errors occurred during the SMS Report Generation execution - refer to web log - ' || lics_logging.callback_identifier);
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
         raise_application_error(-20000, 'FATAL ERROR - SMS_REP_FUNCTION - GENERATE - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end generate;

   /************************************************/
   /* This procedure performs the send SMS routine */
   /************************************************/
   procedure send_sms(par_smtp_host in varchar2,
                      par_smtp_port in varchar2,
                      par_qry_code in varchar2,
                      par_qry_date in varchar2,
                      par_msg_seqn in number,
                      par_subject in varchar2,
                      par_content in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_connection utl_smtp.connection;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_rpt_recipient is
         select t01.*
           from sms_rpt_recipient t01
          where t01.rre_qry_code = par_qry_code
            and t01.rre_qry_date = par_qry_date
            and t01.rre_msg_seqn = par_msg_seqn
          order by t01.rre_rcp_code asc;
      rcd_rpt_recipient csr_rpt_recipient%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

----------------MULTIPART MESSAGE
   --   tbl_line.delete;
   --   if length(par_content) <= 160 then
   --      tbl_line(1) := par_content;
   --   else
   --      var_indx := 0;
   --      for idx in 1..length(par_content) loop
--
   --         if var_indx = 160 then
   --            var_indx := 0;
   --         end if;
   --         var_indx := var_indx + 1;
   --         tbl_line(var_indx) := tbl_line(var_indx)||substr(par_content,idx,1);
--
   --      end loop;
   --   end if;

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection(par_smtp_host, par_smtp_port);
      utl_smtp.helo(var_connection, par_smtp_host);

      /*-*/
      /* Initialise the email
      /*-*/
      utl_smtp.mail(var_connection, 'SMS Sales');

      /*-*/
      /* Set the recipient(s)
      /*-*/
      open csr_rpt_recipient;
      loop
         fetch csr_rpt_recipient into rcd_rpt_recipient;
         if csr_rpt_recipient%notfound then
            exit;
         end if;
         utl_smtp.rcpt(var_connection, '"'||trim(rcd_rpt_recipient.rre_rcp_name)||'"<'||rcd_rpt_recipient.rre_rcp_mobile||'@'||par_smtp_host||'>');
      end loop;
      close csr_rpt_recipient;

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'Subject: ' || par_subject || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, utl_tcp.CRLF || par_content);

      /*-*/
      /* Close the data stream and quit the connection
      /*-*/
      utl_smtp.close_data(var_connection);
      utl_smtp.quit(var_connection);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_sms;

   /************************************************/
   /* This procedure performs the convert routine */
   /************************************************/
   function convert_value(par_value in varchar2, par_round in number) return varchar2 is

      /*-*/
      /* Local definitions
      /*-*/
      var_return varchar2(256 char);
      var_number number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Return the convert value
      /*-*/
      var_return := par_value;
      begin
         if substr(par_value,length(par_value),1) = '-' then
            var_number := to_number('-' || substr(par_value,1,length(par_value) - 1));
         else
            var_number := to_number(par_value);
         end if;
         var_return := to_char(var_number);
         if par_round != -1 then
            var_return := to_char(round(var_number,par_round));
         end if;
      exception
         when others then
            var_return := par_value;
      end;
      return var_return;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end convert_value;

end sms_rep_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_rep_function for sms_app.sms_rep_function;
grant execute on sms_app.sms_rep_function to public;
