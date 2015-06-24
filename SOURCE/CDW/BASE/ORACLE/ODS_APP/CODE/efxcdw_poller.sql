CREATE OR REPLACE package ODS_APP.efxcdw_poller as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    Package : efxcdw_poller
    Owner   : ods_app

    Description
    -----------
    Operational Data Store - Efex CDW Poller

    This package contain the polling logic for the Efex to CDW extracts

    YYYY/MM   Author         Description
    -------   ------         -----------
    2001/06   Steve Gregan   Created 
    2015/06   Trevor Keon    Updated to support ICS v32 

   *******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure execute;

end efxcdw_poller;
/

CREATE OR REPLACE package body ODS_APP.efxcdw_poller as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);
   snapshot_exception exception;
   pragma exception_init(snapshot_exception, -1555);

   /***********************************************/
   /* This procedure performs the execute routine */
   /***********************************************/
   procedure execute is

      /*-*/
      /* Local definitions
      /*-*/
      var_company varchar2(32 char);
      var_alert varchar2(256);
      var_email varchar2(256);
      var_extract_status varchar2(32);
      var_available boolean;
      var_completed boolean;

      /*-*/
      /* Local constants
      /*-*/
      con_alt_group constant varchar2(32) := 'EFEX_CDW_POLLER';
      con_alt_code constant varchar2(32) := 'ALERT_STRING';
      con_ema_group constant varchar2(32) := 'EFEX_CDW_POLLER';
      con_ema_code constant varchar2(32) := 'EMAIL_GROUP';

      /*-*/
      /* Local cursors
      /*-*/
      cursor csr_list is
         select t01.*
           from efex_cntl_hdr t01
          where (t01.extract_status != '*COMPLETED' and t01.extract_status != '*CANCELLED')
          order by t01.market_id asc,
                   t01.extract_time asc;
      rcd_list csr_list%rowtype;

      cursor csr_header is
         select t01.*
           from efex_cntl_hdr t01
          where t01.market_id = rcd_list.market_id
            and t01.extract_time = rcd_list.extract_time
            for update nowait;
      rcd_header csr_header%rowtype;

      cursor csr_override is
         select t01.*
           from efex_cntl_hdr t01
          where t01.market_id = rcd_header.market_id
            and t01.extract_time > rcd_header.extract_time;
      rcd_override csr_override%rowtype;

      cursor csr_detail is
         select t01.*
           from efex_cntl_det t01
          where t01.market_id = rcd_header.market_id
            and t01.extract_time = rcd_header.extract_time
          order by t01.iface_code asc;
      rcd_detail csr_detail%rowtype;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the procedure
      /*-*/
      var_alert := lics_setting_configuration.retrieve_setting(con_alt_group, con_alt_code);
      var_email := lics_setting_configuration.retrieve_setting(con_ema_group, con_ema_code);

      /*-*/
      /* Retrieve the outstanding control headers
      /*-*/
      open csr_list;
      loop
         begin
            fetch csr_list into rcd_list;
            if csr_list%notfound then
               exit;
            end if;
         exception
            when snapshot_exception then
               exit;
         end;

         /*-*/
         /* Attempt to lock the header row
         /* notes - must still exist
         /*         must still be available status
         /*         must not be locked
         /*-*/
         var_available := true;
         begin
            open csr_header;
            fetch csr_header into rcd_header;
            if csr_header%notfound then
               var_available := false;
            end if;
            if rcd_header.extract_status = '*COMPLETED' or
               rcd_header.extract_status = '*CANCELLED' then
               var_available := false;
            end if;
         exception
            when others then
               var_available := false;
         end;
         if csr_header%isopen then
            close csr_header;
         end if;

         /*-*/
         /* Release the header lock when not available
         /* 1. Cursor row locks are not released until commit or rollback
         /* 2. Cursor close does not release row locks
         /*-*/
         if var_available = false then

            /*-*/
            /* Rollback to release row locks
            /*-*/
            rollback;

         /*-*/
         /* Process the header when available
         /*-*/
         else

            /*-*/
            /* Default the extract status
            /*-*/
            var_extract_status := rcd_header.extract_status;

            /*-*/
            /* Cancel the extract when required
            /* **note** 1. extract is cancelled when an override is found
            /*          2. extract is cancelled when unknown market
            /*          3. extract is more than 24 hours old
            /*-*/
            open csr_override;
            fetch csr_override into rcd_override;
            if csr_override%found then
               var_extract_status := '*CANCELLED';
            end if;
            close csr_override;
            /*-*/
            var_company := null;
            if rcd_header.market_id = 1 then
               var_company := '147';
            elsif rcd_header.market_id = 5 then
               var_company := '149';
            else
               var_extract_status := '*CANCELLED';
            end if;
            /*-*/
            if to_date(rcd_header.extract_time,'yyyymmddhh24miss') < (sysdate - 1) then
               var_extract_status := '*CANCELLED';
            end if;

            /*-*/
            /* Attempt to complete when extract when the control interface has been received
            /*-*/
            if var_extract_status = '*CONTROL' then
   
               /*-*/
               /* Retrieve the related interface details
               /*-*/
               var_completed := true;
               open csr_detail;
               loop
                  fetch csr_detail into rcd_detail;
                  if csr_detail%notfound then
                     exit;
                  end if;

                  /*-*/
                  /* Detail not received - bypass
                  /*-*/
                  if rcd_detail.iface_recvd = 0 then
                     var_completed := false;
                     exit;
                  end if;

                  /*-*/
                  /* Detail not balanced - bypass
                  /*-*/
                  if rcd_detail.iface_count != rcd_detail.iface_recvd then
                     var_completed := false;
                     exit;
                  end if;

               end loop;
               close csr_detail;

               /*-*/
               /* Complete the extract when required
               /*-*/
               if var_completed = true then
                  var_extract_status := '*COMPLETED';
               end if;

            end if;

            /*-*/
            /* Update the header
            /*-*/
            update efex_cntl_hdr
               set extract_status = var_extract_status
             where market_id = rcd_header.market_id
               and extract_time = rcd_header.extract_time;

            /*-*/
            /* Commit the database
            /*-*/
            commit;

            /*-*/
            /* Load the processing stream when completed
            /*-*/
            if var_extract_status = '*COMPLETED' then
--               lics_stream_loader.execute('EFEX_CDW_STREAM_'||var_company,null);
               lics_stream_loader.load('EFEX_CDW_STREAM_', 'Running EFEX CDW stream for company '||var_company, null);    
               lics_stream_loader.execute;
            end if;

            /*-*/
            /* Alert/email when cancelled
            /*-*/
            if var_extract_status = '*CANCELLED' then

               /*-*/
               /* Send the alert when required
               /*-*/
               if not(trim(var_alert) is null) and trim(upper(var_alert)) != '*NONE' then
                  lics_notification.send_alert(var_alert);
               end if;

               /*-*/
               /* Send the email when required
               /*-*/
               if not(trim(var_email) is null) and trim(upper(var_email)) != '*NONE' then

                  /*-*/
                  /* Create the new email and create the email text header part
                  /*-*/
                  lics_mailer.create_email('EFEX_CDW_POLLER_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment,
                                           var_email,
                                           'Efex CDW Poller - Cancelled Efex CDW Extract - Market('||to_char(rcd_header.market_id)||')',
                                           null,
                                           null);
                  lics_mailer.create_part(null);
                  lics_mailer.append_data('Efex CDW Poller - Cancelled Efex CDW Extract - Market('||to_char(rcd_header.market_id)||')');
                  lics_mailer.append_data(null);
                  lics_mailer.append_data(null);
                  lics_mailer.append_data(null);

                  /*-*/
                  /* Create the email file and output the header data
                  /*-*/
                  lics_mailer.create_part('efex_cdw_cancelled_extract.xls');
                  lics_mailer.append_data('<head><meta http-equiv=Content-Type content="text/html; charset=utf-8"></head>');
                  lics_mailer.append_data('<table border=1 cellpadding="0" cellspacing="0">');
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td align=center colspan=3 style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Efex CDW Poller - Cancelled Efex CDW Extract</td>');
                  lics_mailer.append_data('</tr>');
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td align=center colspan=3></td>');
                  lics_mailer.append_data('</tr>');
                  lics_mailer.append_data('<tr>');
                  if var_company is null then
                     lics_mailer.append_data('<td align=center colspan=3>** Extract market id is unknown **</td>');
                  else
                     if rcd_header.extract_status = '*CONTROL' then
                        lics_mailer.append_data('<td align=center colspan=3>** Extract control EFXCDW00 interface does not balance to received interfaces **</td>');
                     elsif rcd_header.extract_status = '*INTERFACE' then
                        lics_mailer.append_data('<td align=center colspan=3>** Extract control EFXCDW00 interface not received **</td>');
                     end if;
                  end if;
                  lics_mailer.append_data('</tr>');

                  /*-*/
                  /* Output the extract header
                  /*-*/
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td></td>');
                  lics_mailer.append_data('<td></td>');
                  lics_mailer.append_data('<td></td>');
                  lics_mailer.append_data('</tr>');
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Market Id</td>');
                  lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Extract Time</td>');
                  lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Extract Status</td>');
                  lics_mailer.append_data('</tr>');
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td align=center style="mso-number-format:\@;">'||to_char(rcd_header.market_id)||'</td>');
                  lics_mailer.append_data('<td align=center style="mso-number-format:\@;">'||rcd_header.extract_time||'</td>');
                  lics_mailer.append_data('<td align=center>'||var_extract_status||'</td>');
                  lics_mailer.append_data('</tr>');

                  /*-*/
                  /* Output the extract detail
                  /*-*/
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td></td>');
                  lics_mailer.append_data('<td></td>');
                  lics_mailer.append_data('<td></td>');
                  lics_mailer.append_data('</tr>');
                  lics_mailer.append_data('<tr>');
                  lics_mailer.append_data('<td align=center style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Interface</td>');
                  lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Control Count</td>');
                  lics_mailer.append_data('<td align=right style="FONT-FAMILY:Arial,Verdana,Tahoma,sans-serif;FONT-SIZE:9pt;FONT-WEIGHT:bold;BACKGROUND-COLOR:#40414c;COLOR:#ffffff;">Received Count</td>');
                  lics_mailer.append_data('</tr>');

                  /*-*/
                  /* Retrieve the detail data
                  /*-*/
                  open csr_detail;
                  loop
                     fetch csr_detail into rcd_detail;
                     if csr_detail%notfound then
                        exit;
                     end if;

                     /*-*/
                     /* Output the detail data
                     /*-*/
                     lics_mailer.append_data('<tr>');
                     if rcd_detail.iface_count != rcd_detail.iface_recvd then
                        lics_mailer.append_data('<td align=center style="BACKGROUND-COLOR:#ff0000;COLOR:#ffffff;">'||rcd_detail.iface_code||'</td>');
                     else
                        lics_mailer.append_data('<td align=center>'||rcd_detail.iface_code||'</td>');
                     end if;
                     lics_mailer.append_data('<td align=right>'||to_char(rcd_detail.iface_count)||'</td>');
                     lics_mailer.append_data('<td align=right>'||to_char(rcd_detail.iface_recvd)||'</td>');
                     lics_mailer.append_data('</tr>');

                  end loop;
                  close csr_detail;

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

            end if;

         end if;

      end loop;
      close csr_list;

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
         /* Raise an exception to the calling application
         /*-*/
         raise_application_error(-20000, 'FATAL ERROR - EFXCDW_POLLER - ' || substr(SQLERRM, 1, 2048));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end execute;

end efxcdw_poller;
/