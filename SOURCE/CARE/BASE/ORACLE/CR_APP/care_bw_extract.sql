/******************/
/* Package Header */
/******************/
create or replace package care_bw_extract as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : care_bw_extract
    Owner   : cr_app

    Description
    -----------
    Care - BW Extract

    This package contains the extract procedure for the consumer response SAP BW extract.
    The package exposes one procedure EXECUTE that performs the extract based on the following parameter:

    1. PAR_PERIOD (*LAST or period in string format (YYYYPP) (MANDATORY)

       *LAST extracts consumer response data for the previous three periods.
       YYYYPP extracts consumer response data for the requested period.

    YYYY/MM   Author         Description
    -------   ------         -----------
    2008/11   Steve Gregan   Created

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute(par_period in varchar2);

end care_bw_extract;
/

/****************/
/* Package Body */
/****************/
create or replace package body care_bw_extract as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Private constants
   /*-*/
   con_function constant varchar2(128) := 'Care SAP BW Extract';
   con_alt_group constant varchar2(32) := 'CARE_SAPBW_EXTRACT';
   con_alt_code constant varchar2(32) := 'ALERT_STRING';
   con_ema_group constant varchar2(32) := 'CARE_SAPBW_EXTRACT';
   con_ema_code constant varchar2(32) := 'EMAIL_GROUP';
   con_rpt_group constant varchar2(32) := 'CARE_SAPBW_EXTRACT';
   con_rpt_code constant varchar2(32) := 'REPORT_GROUP';

   /*-*/
   /* Private definitions
   /*-*/
   type typ_suffix is table of varchar2(1 char) index by binary_integer;
   tbl_suffix typ_suffix;

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute(par_period in varchar2) is

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
      var_report varchar2(256);
      var_errors boolean;
      var_save_tran varchar2(10);
      var_suffix number;
      var_output varchar2(4000);
      type typ_output is table of varchar2(4000) index by binary_integer;
      tbl_email typ_output;
      tbl_output typ_output;

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_check is
         select t01.*
           from period t01
          where to_char(t01.salesyear * 100 + t01.period,'fm000000') = par_period;
      rcd_check csr_check%rowtype;

      cursor csr_period is
         select t01.salesyear,
                t01.period,
                t01.salestart,
                t01.salesend,
                to_char(t01.salesyear * 100 + t01.period,'fm000000') as yyyypp,
                substr(to_char(t01.salesyear * 100 + t01.period,'fm000000'),1,4)||'/'||substr(to_char(t01.salesyear * 100 + t01.period,'fm000000'),5,2) as yyyy_pp
           from period t01
          where ((upper(par_period) = '*LAST' and trunc(t01.salesend) <= trunc(sysdate)) or
                 (upper(par_period) != '*LAST' and to_char(t01.salesyear * 100 + t01.period,'fm000000') = par_period))
            and rownum <= 3
          order by t01.salesyear desc, t01.period desc;
      rcd_period csr_period%rowtype;

      cursor csr_extract is
         select 'CA' || substr(t01.incident_number,4,7) as trans_id,
                nvl(t61.bw_code, '**ERROR** - Sales organisation BW XREF not found for ('||t01.keyword_3||')') as sales_org,
                null as prd_id_grd,
                decode(t02.level_one, 'NOPROD', '98', SUBSTR(t02.level_one, 4, 2)) as bus_seg,
                nvl(substr(t02.level_eleven,4,2), '0') as mkt_seg,
                nvl(substr(t02.level_two,4,3), '0') as brand_flag,
                nvl(substr(t02.level_ten,4,3), '0') as supp_seg,
                nvl(substr(t02.level_four,4,2), '0') as pack_format,
                nvl(substr(t02.level_five,4,2), '0') as prod_cat,
                nvl(t62.bw_code, t01.keyword_6) as factory_moe,
                nvl(t63.bw_code, '**ERROR** - Reason level one BW XREF not found for ('||t03.level_one||')') as reason_l1,
                nvl(t64.bw_code, '**ERROR** - Reason level two BW XREF not found for ('||t03.level_two||')') as reason_l2,
                nvl(t65.bw_code, '**ERROR** - Reason level three BW XREF not found for ('||t03.level_three||')') as reason_l3,
                nvl(t66.bw_code, '**ERROR** - Severity id BW XREF not found for ('||t04.keyword||')') as severity_id, 
                to_char(t01.opened_date, 'yyyymmdd') as creation_date, 
                substr(t05.verbatim_1, 1, 60) as verbatim, 
                substr(t03.level_five_desc, 1, 60) as reason_text
           from incident t01, 
                keyword_1 t02,
                keyword_2 t03, 
                extra_keyword_9 t04, 
                verbatim t05,
                cr.care_bw_xref t61,
                cr.care_bw_xref t62,
                cr.care_bw_xref t63,
                cr.care_bw_xref t64,
                cr.care_bw_xref t65,
                cr.care_bw_xref t66
          where t01.keyword_1 = t02.keyword
            and t01.keyword_2 = t03.keyword
            and t01.extra_keyword_9 = t04.keyword
            and t01.incident_number = t05.incident_number
            and t01.keyword_3 = t61.code(+)
            and t01.keyword_6 = t62.code(+)
            and t03.level_one = t63.code(+)
            and t03.level_two = t64.code(+)
            and t03.level_three = t65.code(+)
            and t04.keyword = t66.code(+)
            and t01.opened_date >= rcd_period.salestart
            and t01.opened_date <= rcd_period.salesend
            and t03.level_three not in ('FOLLUP', 'NA')
          order by t01.opened_date asc;
      rcd_extract csr_extract%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the log/lock variables
      /*-*/
      var_log_prefix := 'CARE SAPBW EXTRACT';
      var_log_search := 'CARE_SAPBW_EXTRACT';
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);
      var_report := lics_setting_configuration.retrieve_setting(con_rpt_group, con_rpt_code);
      var_errors := false;

      /*-*/
      /* Validate the parameters
      /*-*/
      if upper(par_period) != '*LAST' then
         open csr_check;
         fetch csr_check into rcd_check;
         if csr_check%notfound then
            raise_application_error(-20000, 'Period ('||par_period||') not found in PERIOD table');
         end if;
         close csr_check;
      end if;

      /*-*/
      /* Log start
      /*-*/
      lics_logging.start_log(var_log_prefix, var_log_search);

      /*-*/
      /* Begin procedure
      /*-*/
      lics_logging.write_log('Begin - Care SAP BW Extract - Parameters(' || par_period || ')');

      /*-*/
      /* Perform the period extracts
      /*-*/
      begin

         /*-*/
         /* Retrieve the requested period information
         /*-*/
         open csr_period;
         loop
            fetch csr_period into rcd_period;
            if csr_period%notfound then
               exit;
            end if;

            /*-*/
            /* Log event
            /*-*/
            lics_logging.write_log('Extracting data for period (' || rcd_period.yyyy_pp || ')');

            /*-*/
            /* Initialise the period
            /*-*/
            tbl_email.delete;
            tbl_output.delete;
            var_save_tran := '*NULL';

            /*-*/
            /* Retrieve the extract data
            /*-*/
            open csr_extract;
            loop
               fetch csr_extract into rcd_extract;
               if csr_extract%notfound then
                  exit;
               end if;

               /*-*/
               /* Create a unique transaction identifier
               /*-*/
               if var_save_tran != rcd_extract.trans_id then
                  var_save_tran := rcd_extract.trans_id;
                  var_suffix := 0;
               end if;
               var_suffix := var_suffix + 1;
               if var_suffix > 26 then
                  lics_logging.write_log('Transaction identifier suffix count exceeds maximum 26');
                  raise_application_error(-20000, 'Transaction identifier suffix count exceeds maximum 26');
               end if;
               rcd_extract.trans_id := rcd_extract.trans_id || tbl_suffix(var_suffix);

               /*-*/
               /* Output the email text when errors
               /*-*/
               if (substr(rcd_extract.sales_org,1,9) = '**ERROR**' or
                   substr(rcd_extract.reason_l1,1,9) = '**ERROR**' or
                   substr(rcd_extract.reason_l2,1,9) = '**ERROR**' or
                   substr(rcd_extract.reason_l3,1,9) = '**ERROR**' or
                   substr(rcd_extract.severity_id,1,9) = '**ERROR**') then
                  tbl_email(tbl_email.count+1) := '<tr>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.trans_id||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.sales_org||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.prd_id_grd||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.bus_seg||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.mkt_seg||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.brand_flag||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.supp_seg||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.pack_format||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.prod_cat||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.factory_moe||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.reason_l1||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.reason_l2||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.reason_l3||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.severity_id||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_period.salesyear||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_period.period||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.creation_date||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.verbatim||'</td>';
                  tbl_email(tbl_email.count+1) := '<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;">'||rcd_extract.reason_text||'</td>';
                  tbl_email(tbl_email.count+1) := '</tr>';
               end if;

               /*-*/
               /* Output the extract string when no errors
               /*-*/
               if tbl_email.count = 0 then
                  var_output := '"'||replace(rcd_extract.trans_id,'"','""')||'";';
                  var_output := var_output||rcd_extract.sales_org||';';
                  var_output := var_output||'"'||replace(rcd_extract.prd_id_grd,'"','""')||'";';
                  var_output := var_output||rcd_extract.bus_seg||';';
                  var_output := var_output||rcd_extract.mkt_seg||';';
                  var_output := var_output||rcd_extract.brand_flag||';';
                  var_output := var_output||rcd_extract.supp_seg||';';
                  var_output := var_output|| '"'||replace(rcd_extract.pack_format,'"','""')||'";';
                  var_output := var_output||rcd_extract.prod_cat||';';
                  var_output := var_output||rcd_extract.factory_moe||';';
                  var_output := var_output||rcd_extract.reason_l1||';';
                  var_output := var_output||rcd_extract.reason_l2||';';
                  var_output := var_output||rcd_extract.reason_l3||';';
                  var_output := var_output||rcd_extract.severity_id||';';
                  var_output := var_output||rcd_period.salesyear||';';
                  var_output := var_output||rcd_period.period||';';
                  var_output := var_output|| '"'||replace(rcd_extract.creation_date,'"','""')||'";';
                  var_output := var_output|| '"'||replace(rcd_extract.verbatim,'"','""')||'";';
                  var_output := var_output|| '"'||replace(rcd_extract.reason_text,'"','""')||'"';
                  tbl_output(tbl_output.count+1) := var_output;
               end if;

            end loop;
            close csr_extract;

            /*-*/
            /* Process the interface when required
            /*-*/
            if tbl_email.count = 0 then

               /*-*/
               /* Create the notification when no data for the period
               /*-*/
               if tbl_output.count = 0 then

                  /*-*/
                  /* Log event
                  /*-*/
                  lics_logging.write_log('Sending no data information email for period (' || rcd_period.yyyy_pp || ') to ' || var_report);

                  /*-*/
                  /* Create the notification email
                  /*-*/
                  lics_mailer.create_email(lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment,
                                           var_report,
                                           'Consumer Response Interface (Care to SAP BW) - No Data - ' || rcd_period.yyyy_pp,
                                           null,
                                           null);
                  lics_mailer.create_part(null);
                  lics_mailer.append_data('Consumer Response Interface (Care to SAP BW) - No Data - ' || rcd_period.yyyy_pp || ' - Information Only');
                  lics_mailer.append_data(null);
                  lics_mailer.append_data(null);
                  lics_mailer.append_data('The consumer response interface extract job was executed for period (' || rcd_period.yyyy_pp || ') but no data was found');
                  lics_mailer.append_data(null);
                  lics_mailer.append_data('** Email End **');
                  lics_mailer.finalise_email('utf-8');

               /*-*/
               /* Create the interface when required
               /*-*/
               else

                  /*-*/
                  /* Log event
                  /*-*/
                  lics_logging.write_log('Creating interface for period (' || rcd_period.yyyy_pp || ')');

                  /*-*/
                  /* Create the interface
                  /*-*/
                  var_file_name := 'CA_CONTACTS_'||rcd_period.yyyypp||'.csv';
                  var_instance := lics_outbound_loader.create_interface('CARSBW01',null,var_file_name);

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

               end if;

            /*-*/
            /* Create the email when required
            /*-*/
            else

               /*-*/
               /* Log event
               /*-*/
               lics_logging.write_log('Sending error report email for period (' || rcd_period.yyyy_pp || ') to ' || var_report);

               /*-*/
               /* Create the new email and create the email text header part
               /*-*/
               lics_mailer.create_email(lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment,
                                        var_report,
                                        'Consumer Response Interface (Care to SAP BW) - Error Report - ' || rcd_period.yyyy_pp,
                                        null,
                                        null);
               lics_mailer.create_part(null);
               lics_mailer.append_data('Consumer Response Interface (Care to SAP BW) - Error Report - ' || rcd_period.yyyy_pp);
               lics_mailer.append_data(null);
               lics_mailer.append_data(null);
               lics_mailer.append_data(null);

               /*-*/
               /* Create the email file and output the header data
               /*-*/
               lics_mailer.create_part('Consumer_Response_Interface_Error_Report_'||rcd_period.yyyypp||'.xls');
               lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
               lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
               lics_mailer.append_data('<tr>');
               lics_mailer.append_data('<td align=center colspan=19 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Consumer Response Interface (Care to SAP BW) - Error Report - '||rcd_period.yyyy_pp||'</td>');
               lics_mailer.append_data('</tr>');

               /*-*/
               /* Output the header
               /*-*/
               lics_mailer.append_data('<tr>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('<td></td>');
               lics_mailer.append_data('</tr>');
               lics_mailer.append_data('<tr>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Transaction Id</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Sales Organisation</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Product Id</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Business Segment</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Market Segment</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Brand Flag</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Supplier Segment</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Pack Format</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Product Category</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Factory MOE</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Reason Level 1</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Reason Level 2</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Reason Level 3</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Severity Id</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Year</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Period</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Creation Date</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Verbatim</td>');
               lics_mailer.append_data('<td align=left style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:8pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Reason Text</td>');
               lics_mailer.append_data('</tr>');

               /*-*/
               /* Append the details
               /*-*/
               for idx in 1..tbl_email.count loop
                  lics_mailer.append_data(tbl_email(idx));
               end loop;

               /*-*/
               /* Output the email file part trailer data
               /*-*/
               lics_mailer.append_data('</table>');
               lics_mailer.create_part(null);
               lics_mailer.append_data(null);
               lics_mailer.append_data(null);
               lics_mailer.append_data(null);
               lics_mailer.append_data('** Email End **');
               lics_mailer.finalise_email('utf-8');

            end if;

         end loop;
         close csr_period;

      exception
         when others then
            begin
               lics_logging.write_log(substr(SQLERRM, 1, 2048));
               if lics_outbound_loader.is_created = true then
                  lics_outbound_loader.add_exception(substr(SQLERRM, 1, 2048));
                  lics_outbound_loader.finalise_interface;
               end if;
            exception
               when others then
                  null;
            end;
            var_errors := true;
      end;

      /*-*/
      /* End procedure
      /*-*/
      lics_logging.write_log('End - Care SAP BW Extract');

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
                                         'CARE_SAP_BW_EXTRACT',
                                         var_email,
                                         'One or more errors occurred during the Care SAP BW extract execution - refer to web log - ' || lics_logging.callback_identifier);
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
            if lics_logging.is_created = true then
               lics_logging.write_log('**FATAL ERROR** - ' || var_exception);
               lics_logging.end_log;
            end if;
         exception
            when others then
               null;
         end;

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - CARE SAP BW - EXTRACT - ' || var_exception);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package variables
   /*-*/
   tbl_suffix(1) := 'A';
   tbl_suffix(2) := 'B';
   tbl_suffix(3) := 'C';
   tbl_suffix(4) := 'D';
   tbl_suffix(5) := 'E';
   tbl_suffix(6) := 'F';
   tbl_suffix(7) := 'G';
   tbl_suffix(8) := 'H';
   tbl_suffix(9) := 'I';
   tbl_suffix(10) := 'J';
   tbl_suffix(11) := 'K';
   tbl_suffix(12) := 'L';
   tbl_suffix(13) := 'M';
   tbl_suffix(14) := 'N';
   tbl_suffix(15) := 'O';
   tbl_suffix(16) := 'P';
   tbl_suffix(17) := 'Q';
   tbl_suffix(18) := 'R';
   tbl_suffix(19) := 'S';
   tbl_suffix(20) := 'T';
   tbl_suffix(21) := 'U';
   tbl_suffix(22) := 'V';
   tbl_suffix(23) := 'W';
   tbl_suffix(24) := 'X';
   tbl_suffix(25) := 'Y';
   tbl_suffix(26) := 'Z';

end care_bw_extract;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym care_bw_extract for cr_app.care_bw_extract;
grant execute on care_bw_extract to public;
