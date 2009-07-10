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
                      par_rpt_date in varchar2,
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
                      par_rpt_date in varchar2,
                      par_alert in varchar2,
                      par_email in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_exception varchar2(4000);
      var_log_prefix varchar2(256);
      var_log_search varchar2(256);
      var_errors boolean;
      var_found boolean;
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
      type typ_text is table of varchar2(32767) index by binary_integer;
      tbl_dtxt typ_text;
      tbl_ttxt typ_text;

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
            and t01.rhe_rpt_date = par_rpt_date
            for update;
      rcd_report csr_report%rowtype;

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
         select t01.*
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
         select t01.*
           from sms_rpt_data t01
          where t01.rda_qry_code = par_qry_code
            and t01.rda_rpt_date = par_rpt_date
            and nvl(t01.rda_dim_val01,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val01,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val02,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val02,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val03,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val03,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val04,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val04,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val05,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val05,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val06,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val06,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val07,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val07,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val08,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val08,'*ALL'),'*TOTAL')
            and nvl(t01.rda_dim_val09,'*ALL') in (nvl(rcd_pro_filter.fil_dim_val09,'*ALL'),'*TOTAL')
          order by t01.rda_dat_seqn asc;
      rcd_rpt_data csr_rpt_data%rowtype;

      cursor csr_rpt_message is
         select t01.*
           from sms_rpt_message t01
          where t01.rme_qry_code = par_qry_code
            and t01.rme_rpt_date = par_rpt_date
          order by t01.rme_msg_seqn asc;
      rcd_rpt_message csr_rpt_message%rowtype;

      cursor csr_rpt_recipient is
         select t01.*
           from sms_rpt_recipient t01
          where t01.rre_qry_code = par_qry_code
            and t01.rre_rpt_date = par_rpt_date
            and t01.rre_msg_seqn = rcd_rpt_message.rme_msg_seqn
          order by t01.rre_rcp_code asc;
      rcd_rpt_recipient csr_rpt_recipient%rowtype;

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

      /*-*/
      /* Validate the parameters
      /*-*/
      if par_qry_code is null then
         raise_application_error(-20000, 'Quesry code must be supplied');
      end if;
      if par_rpt_date is null then
         raise_application_error(-20000, 'Report date must be supplied');
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
            raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_rpt_date||') is currently locked');
      end;
      if var_found = false then
         raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_rpt_date||') not found on the report header table');
      end if;
      if rcd_report.rhe_status != '1' then
         raise_application_error(-20000, 'Report ('||par_qry_code||' / '||par_rpt_date||') must be status loaded');
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - SMS Report Generation - Parameters(' || par_qry_code || ' + ' || par_rpt_date || ')');

      /*-*/
      /* Initialise the report message data
      /*-*/
      rcd_sms_rpt_message.rme_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_message.rme_rpt_date := rcd_report.rhe_rpt_date;
      rcd_sms_rpt_message.rme_msg_seqn := 0;

      /*-*/
      /* Initialise the report recipient data
      /*-*/
      rcd_sms_rpt_recipient.rre_qry_code := rcd_report.rhe_qry_code;
      rcd_sms_rpt_recipient.rre_rpt_date := rcd_report.rhe_rpt_date;

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
         /* Retrieve the report query profile messages
         /*-*/
         open csr_pro_message;
         loop
            fetch csr_pro_message into rcd_pro_message;
            if csr_pro_message%notfound then
               exit;
            end if;

            /*-*/
            /* Retrieve and load the related message line data
            /*-*/
            tbl_mlin.delete;
            tbl_dtxt.delete;
            tbl_ttxt.delete;
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
               /* Initialise the message instance
               /*-*/
               tbl_dtxt.delete;
               tbl_ttxt.delete;
               for idy in 1..tbl_mlin.count loop
                  tbl_dtxt(idy) := tbl_mlin(idy).mli_det_text;
                  tbl_ttxt(idy) := tbl_mlin(idy).mli_tot_text;
               end loop;

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
               for idc in 1..9 loop
                  tbl_dcnt(idc) := 0;
               end loop;

               /*-*/
               /* Process the repprt data
               /*-*/
               for idx in 1..tbl_data.count loop

                  /*-*/
                  /* Change in repprt data dimensions
                  /*-*/
                  if nvl(tbl_data(idx).rda_dim_val01,'*NONE') != var_sav_val01 or
                     nvl(tbl_data(idx).rda_dim_val02,'*NONE') != var_sav_val02 or
                     nvl(tbl_data(idx).rda_dim_val03,'*NONE') != var_sav_val03 or
                     nvl(tbl_data(idx).rda_dim_val04,'*NONE') != var_sav_val04 or
                     nvl(tbl_data(idx).rda_dim_val05,'*NONE') != var_sav_val05 or
                     nvl(tbl_data(idx).rda_dim_val06,'*NONE') != var_sav_val06 or
                     nvl(tbl_data(idx).rda_dim_val07,'*NONE') != var_sav_val07 or
                     nvl(tbl_data(idx).rda_dim_val08,'*NONE') != var_sav_val08 or
                     nvl(tbl_data(idx).rda_dim_val09,'*NONE') != var_sav_val09 then

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
                     elsif tbl_data(idx).rda_dim_val02 != '*NONE' then
                        var_detail := '*LVL02';
                     elsif tbl_data(idx).rda_dim_val03 != '*NONE' then
                        var_detail := '*LVL03';
                     elsif tbl_data(idx).rda_dim_val04 != '*NONE' then
                        var_detail := '*LVL04';
                     elsif tbl_data(idx).rda_dim_val05 != '*NONE' then
                        var_detail := '*LVL05';
                     elsif tbl_data(idx).rda_dim_val06 != '*NONE' then
                        var_detail := '*LVL06';
                     elsif tbl_data(idx).rda_dim_val07 != '*NONE' then
                        var_detail := '*LVL07';
                     elsif tbl_data(idx).rda_dim_val08 != '*NONE' then
                        var_detail := '*LVL08';
                     elsif tbl_data(idx).rda_dim_val09 != '*NONE' then
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
                     var_sav_val01 := nvl(tbl_data(idx).rda_dim_val01,'*NONE');
                     var_sav_val02 := nvl(tbl_data(idx).rda_dim_val02,'*NONE');
                     var_sav_val03 := nvl(tbl_data(idx).rda_dim_val03,'*NONE');
                     var_sav_val04 := nvl(tbl_data(idx).rda_dim_val04,'*NONE');
                     var_sav_val05 := nvl(tbl_data(idx).rda_dim_val05,'*NONE');
                     var_sav_val06 := nvl(tbl_data(idx).rda_dim_val06,'*NONE');
                     var_sav_val07 := nvl(tbl_data(idx).rda_dim_val07,'*NONE');
                     var_sav_val08 := nvl(tbl_data(idx).rda_dim_val08,'*NONE');
                     var_sav_val09 := nvl(tbl_data(idx).rda_dim_val09,'*NONE');

                     /*-*/
                     /* Update the heading lines as required
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
                               upper(nvl(tbl_mlin(idy).mli_det_text,'*NONE')) != '*NONE') then
                              var_sms_work := tbl_dtxt(idy);
                              var_sms_work := replace(var_sms_work,'PROCESSED_DATE',to_char(rcd_report.rhe_rpt_yyyyppdd,'fm00000000'));
                              if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val01);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val02);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val03);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val04);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val05);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val06);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val07);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val08);
                              elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                                 var_sms_work := replace(var_sms_work,'<DIM_NAME>',rcd_rpt_data.rda_dim_val09);
                              end if;
                              tbl_dtxt(idy) := var_sms_work;
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
                            upper(nvl(tbl_mlin(idy).mli_det_text,'*NONE')) != '*NONE') then
                           var_sms_work := tbl_dtxt(idy);
                           if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           end if;
                           tbl_dtxt(idy) := var_sms_work;
                        end if;
                     end loop;
                  else
                     for idy in 1..tbl_mlin.count loop
                        if (upper(tbl_mlin(idy).mli_msg_line) = var_total and
                            upper(nvl(tbl_mlin(idy).mli_tot_text,'*NONE')) != '*NONE' and
                            (tbl_mlin(idy).mli_tot_child = '1' or (tbl_mlin(idy).mli_tot_child = '2' and tbl_dcnt(idy) > 1))) then
                           var_sms_work := tbl_ttxt(idy);
                           if upper(tbl_mlin(idy).mli_msg_line) = '*LVL01' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL02' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL03' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL04' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL05' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL06' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL07' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL08' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           elsif upper(tbl_mlin(idy).mli_msg_line) = '*LVL09' then
                              var_sms_work := replace(var_sms_work,'<'||rcd_rpt_data.rda_val_code||'>',tbl_data(idx).rda_val_data);
                           end if;
                           tbl_ttxt(idy) := var_sms_work;
                        end if;
                     end loop;
                  end if;

               end loop;

               /*-*/
               /* Build and insert the report message
               /*-*/
               var_sms_text := null;
               for idy in 1..tbl_mlin.count loop
                  if upper(nvl(tbl_mlin(idy).mli_det_text,'*NONE')) != '*NONE' then
                     if not(var_sms_text is null) then
                        var_sms_text := var_sms_text || utl_tcp.CRLF;
                     end if;
                     var_sms_text := var_sms_text || tbl_dtxt(idy);
                  end if;
               end loop;
               for idy in reverse 1..tbl_mlin.count loop
                  if upper(nvl(tbl_mlin(idy).mli_tot_text,'*NONE')) != '*NONE' then
                     if not(var_sms_text is null) then
                        var_sms_text := var_sms_text || utl_tcp.CRLF;
                     end if;
                     var_sms_text := var_sms_text || tbl_ttxt(idy);
                  end if;
               end loop;
               rcd_sms_rpt_message.rme_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn + 1;
               rcd_sms_rpt_message.rme_msg_text := substr(var_sms_text,1,2000);
               rcd_sms_rpt_message.rme_msg_time := sysdate;
               insert into sms_rpt_message values rcd_sms_rpt_message;

               /*-*/
               /* Retrieve and attached all profile recipients
               /*-*/
               open csr_pro_recipient;
               loop
                  fetch csr_pro_recipient into rcd_pro_recipient;
                  if csr_pro_recipient%notfound then
                     exit;
                  end if;
                  rcd_sms_rpt_recipient.rre_msg_seqn := rcd_sms_rpt_message.rme_msg_seqn;
                  rcd_sms_rpt_recipient.rre_rcp_code := rcd_pro_recipient.rec_rcp_code;
                  rcd_sms_rpt_recipient.rre_rcp_mobile := rcd_pro_recipient.rec_rcp_mobile;
                  rcd_sms_rpt_recipient.rre_rcp_email := rcd_pro_recipient.rec_rcp_email;
                  insert into sms_rpt_recipient values rcd_sms_rpt_recipient;
               end loop;
               close csr_pro_recipient;

            end loop;
            close csr_pro_filter;

         end loop;
         close csr_pro_message;

      end loop;
      close csr_profile;

      /*-*/
      /* Send the report messages
      /*-*/
      open csr_rpt_message;
      loop
         fetch csr_rpt_message into rcd_rpt_message;
         if csr_rpt_message%notfound then
            exit;
         end if;

         /*-*/
         /* Build the recipient array
         /*-*/
         open csr_rpt_recipient;
         loop
            fetch csr_rpt_recipient into rcd_rpt_recipient;
            if csr_rpt_recipient%notfound then
               exit;
            end if;
          --  utl_smtp.rcpt(var_connection, rcd_rpt_recipient.rre_rcp_mobile);
         end loop;
         close csr_rpt_recipient;

         -- SEND THE SMS

      end loop;
      close csr_rpt_message;

      /*-*/
      /* Update the report header to processed
      /*-*/
      update sms_rpt_header
         set rhe_status = '2'
       where rhe_qry_code = par_qry_code
         and rhe_rpt_date = par_rpt_date;

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

end sms_rep_function;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym sms_rep_function for sms_app.sms_rep_function;
grant execute on sms_app.sms_rep_function to public;
