/******************/
/* Package Header */
/******************/
create or replace package lics_notification as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : lics
    Package : lics_notification
    Owner   : lics_app
    Author  : Steve Gregan - January 2004

    DESCRIPTION
    -----------
    Local Interface Control System - Notification

    YYYY/MM   Author         Description
    -------   ------         -----------
    2004/01   Steve Gregan   Created
    2007/10   Steve Gregan   Changed email timestamp to 24 hour clock
    2007/10   Steve Gregan   Included optional site code on internal email URL
    2011/02   Steve Gregan   End point architecture version

   *******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure log_success(par_job in varchar2,
                         par_execution in number,
                         par_type in varchar2,
                         par_group in varchar2,
                         par_procedure in varchar2,
                         par_interface in varchar2,
                         par_header in number,
                         par_hdr_trace in number,
                         par_message in varchar2);

   procedure log_error(par_job in varchar2,
                       par_execution in number,
                       par_type in varchar2,
                       par_group in varchar2,
                       par_procedure in varchar2,
                       par_interface in varchar2,
                       par_header in number,
                       par_hdr_trace in number,
                       par_message in varchar2,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2);

   procedure log_warning(par_job in varchar2,
                         par_execution in number,
                         par_type in varchar2,
                         par_group in varchar2,
                         par_procedure in varchar2,
                         par_interface in varchar2,
                         par_header in number,
                         par_hdr_trace in number,
                         par_message in varchar2,
                         par_opr_alert in varchar2,
                         par_ema_group in varchar2);

   procedure log_fatal(par_job in varchar2,
                       par_execution in number,
                       par_type in varchar2,
                       par_group in varchar2,
                       par_procedure in varchar2,
                       par_interface in varchar2,
                       par_header in number,
                       par_hdr_trace in number,
                       par_message in varchar2);

   procedure send_alert(par_message in varchar2);

   procedure send_email(par_system varchar2,
                        par_unit varchar2,
                        par_environment varchar2,
                        par_function in varchar2,
                        par_procedure in varchar2,
                        par_ema_group in varchar2,
                        par_message in varchar2);

end lics_notification;
/

/****************/
/* Package Body */
/****************/
create or replace package body lics_notification as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**/
   /* Private declarations
   /**/
   procedure log_event(par_result in varchar2,
                       par_job in varchar2,
                       par_execution in number,
                       par_type in varchar2,
                       par_group in varchar2,
                       par_procedure in varchar2,
                       par_interface in varchar2,
                       par_header in number,
                       par_hdr_trace in number,
                       par_message in varchar2,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2);
   procedure send_internal_alert;
   procedure send_internal_email;

   /*-*/
   /* Private definitions
   /*-*/
   rcd_lics_event lics_event%rowtype;

   /***************************************************/
   /* This procedure performs the log success routine */
   /***************************************************/
   procedure log_success(par_job in varchar2,
                         par_execution in number,
                         par_type in varchar2,
                         par_group in varchar2,
                         par_procedure in varchar2,
                         par_interface in varchar2,
                         par_header in number,
                         par_hdr_trace in number,
                         par_message in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log the success event
      /*-*/
      log_event(lics_constant.event_success,
                par_job,
                par_execution,
                par_type,
                par_group,
                par_procedure,
                par_interface,
                par_header,
                par_hdr_trace,
                par_message,
                null,
                null);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end log_success;

   /*************************************************/
   /* This procedure performs the log error routine */
   /*************************************************/
   procedure log_error(par_job in varchar2,
                       par_execution in number,
                       par_type in varchar2,
                       par_group in varchar2,
                       par_procedure in varchar2,
                       par_interface in varchar2,
                       par_header in number,
                       par_hdr_trace in number,
                       par_message in varchar2,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log the error event
      /*-*/
      log_event(lics_constant.event_error,
                par_job,
                par_execution,
                par_type,
                par_group,
                par_procedure,
                par_interface,
                par_header,
                par_hdr_trace,
                par_message,
                par_opr_alert,
                par_ema_group);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end log_error;

   /***************************************************/
   /* This procedure performs the log warning routine */
   /***************************************************/
   procedure log_warning(par_job in varchar2,
                         par_execution in number,
                         par_type in varchar2,
                         par_group in varchar2,
                         par_procedure in varchar2,
                         par_interface in varchar2,
                         par_header in number,
                         par_hdr_trace in number,
                         par_message in varchar2,
                         par_opr_alert in varchar2,
                         par_ema_group in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log the warning event
      /*-*/
      log_event(lics_constant.event_warning,
                par_job,
                par_execution,
                par_type,
                par_group,
                par_procedure,
                par_interface,
                par_header,
                par_hdr_trace,
                par_message,
                par_opr_alert,
                par_ema_group);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end log_warning;

   /*************************************************/
   /* This procedure performs the log fatal routine */
   /*************************************************/
   procedure log_fatal(par_job in varchar2,
                       par_execution in number,
                       par_type in varchar2,
                       par_group in varchar2,
                       par_procedure in varchar2,
                       par_interface in varchar2,
                       par_header in number,
                       par_hdr_trace in number,
                       par_message in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Log the fatal event
      /*-*/
      log_event(lics_constant.event_fatal,
                par_job,
                par_execution,
                par_type,
                par_group,
                par_procedure,
                par_interface,
                par_header,
                par_hdr_trace,
                par_message,
                lics_parameter.fatal_opr_alert,
                lics_parameter.fatal_ema_group);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end log_fatal;

   /*************************************************/
   /* This procedure performs the log event routine */
   /*************************************************/
   procedure log_event(par_result in varchar2,
                       par_job in varchar2,
                       par_execution in number,
                       par_type in varchar2,
                       par_group in varchar2,
                       par_procedure in varchar2,
                       par_interface in varchar2,
                       par_header in number,
                       par_hdr_trace in number,
                       par_message in varchar2,
                       par_opr_alert in varchar2,
                       par_ema_group in varchar2) is

      /*-*/
      /* Autonomous transaction
      /*-*/
      pragma autonomous_transaction;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Insert the event row
      /*-*/
      select lics_event_sequence.nextval into rcd_lics_event.eve_sequence from dual;
      rcd_lics_event.eve_time := sysdate;
      rcd_lics_event.eve_result := par_result;
      rcd_lics_event.eve_job := par_job;
      rcd_lics_event.eve_execution := par_execution;
      rcd_lics_event.eve_type := par_type;
      rcd_lics_event.eve_group := par_group;
      rcd_lics_event.eve_procedure := par_procedure;
      rcd_lics_event.eve_interface := par_interface;
      rcd_lics_event.eve_header := par_header;
      rcd_lics_event.eve_hdr_trace := par_hdr_trace;
      rcd_lics_event.eve_message := par_message;
      rcd_lics_event.eve_opr_alert := par_opr_alert;
      rcd_lics_event.eve_ema_group := par_ema_group;
      insert into lics_event
         (eve_sequence,
          eve_time,
          eve_result,
          eve_job,
          eve_execution,
          eve_type,
          eve_group,
          eve_procedure,
          eve_interface,
          eve_header,
          eve_hdr_trace,
          eve_message,
          eve_opr_alert,
          eve_ema_group)
      values(rcd_lics_event.eve_sequence,
             rcd_lics_event.eve_time,
             rcd_lics_event.eve_result,
             rcd_lics_event.eve_job,
             rcd_lics_event.eve_execution,
             rcd_lics_event.eve_type,
             rcd_lics_event.eve_group,
             rcd_lics_event.eve_procedure,
             rcd_lics_event.eve_interface,
             rcd_lics_event.eve_header,
             rcd_lics_event.eve_hdr_trace,
             rcd_lics_event.eve_message,
             rcd_lics_event.eve_opr_alert,
             rcd_lics_event.eve_ema_group);

      /*-*/
      /* Commit the database
      /* note - isolated commit (autonomous transaction)
      /*-*/
      commit;

      /*-*/
      /* Send the internal alert when required
      /*-*/
      if not(trim(rcd_lics_event.eve_opr_alert) is null) and
         trim(upper(rcd_lics_event.eve_opr_alert)) != '*NONE' then
         send_internal_alert;
      end if;

      /*-*/
      /* Send the internal email when required
      /*-*/
      if not(trim(rcd_lics_event.eve_ema_group) is null) and
         trim(upper(rcd_lics_event.eve_ema_group)) != '*NONE' then
         send_internal_email;
      end if;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end log_event;

   /***********************************************************/
   /* This procedure performs the send internal alert routine */
   /***********************************************************/
   procedure send_internal_alert is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Fix the message data
      /*-*/
      var_message := rcd_lics_event.eve_opr_alert;
      var_message := replace(var_message,'"','""');
      var_message := replace(var_message,chr(9),' ');
      var_message := replace(var_message,chr(10),' ');
      var_message := replace(var_message,chr(13),' ');
      var_message := '['||to_char(sysdate,'yyyy-mm-dd_hh24:mi:ss')||'] INFO '||upper(lics_parameter.log_environment)||' '||upper(lics_parameter.log_database)||' '||var_message;

      /*-*/
      /* Send the operator alert
      /*-*/
      lics_filesystem.write_log(lics_parameter.ami_logfile, var_message);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_internal_alert;

   /***********************************************************/
   /* This procedure performs the send internal email routine */
   /***********************************************************/
   procedure send_internal_email is

      /*-*/
      /* Local definitions
      /*-*/
      var_url varchar2(1024);
      var_site varchar2(256);
      var_message varchar2(4000);
      var_connection utl_smtp.connection;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the message url when required
      /*-*/
      var_site := lics_setting_configuration.retrieve_setting('ICS_WEBSITE','SITE_CODE');
      var_url := null;
      if not(to_char(rcd_lics_event.eve_header,'FM999999999999990') is null) and
         not(to_char(rcd_lics_event.eve_hdr_trace,'FM99990') is null) then
         var_url := lics_parameter.system_url;
         if trim(var_site) is null or trim(upper(var_site)) = '*NONE' then
            var_url := var_url || 'ics_child.asp?Child=ics_int_detail.asp';
         else
            var_url := var_url || 'ics_child.asp?Site=' || trim(var_site) || '&Child=ics_int_detail.asp';
         end if;
         var_url := var_url || '&QRY_Header=' ||
                               to_char(rcd_lics_event.eve_header,'FM999999999999990') ||
                               '&QRY_Trace=' ||
                               to_char(rcd_lics_event.eve_hdr_trace,'FM99990');
      elsif not(to_char(rcd_lics_event.eve_execution,'FM999999999999990') is null) then
         var_url := lics_parameter.system_url;
         if trim(var_site) is null or trim(upper(var_site)) = '*NONE' then
            var_url := var_url || 'ics_child.asp?Child=ics_int_detail.asp';
         else
            var_url := var_url || 'ics_child.asp?Site=' || trim(var_site) || '&Child=ics_int_detail.asp';
         end if;
         var_url := var_url || '&QRY_Execution=' ||
                               to_char(rcd_lics_event.eve_execution,'FM999999999999990');
      end if;

      /*-*/
      /* Initialise the email message
      /*-*/
      var_message := 'INTERFACE CONTROL SYSTEM' || chr(13);
      var_message := var_message || '========================' || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'System               : ' || lics_parameter.system_code || chr(13);
      var_message := var_message || 'Business Unit        : ' || lics_parameter.system_unit || chr(13);
      var_message := var_message || 'Environment          : ' || lics_parameter.system_environment || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'Event Timestamp      : ' || to_char(rcd_lics_event.eve_time,'YYYY/MM/DD HH24:MI:SS') || chr(13);
      var_message := var_message || 'Event Result         : ' || rcd_lics_event.eve_result || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'Job Identifier       : ' || rcd_lics_event.eve_job || chr(13);
      var_message := var_message || 'Job Number           : ' || nvl(to_char(rcd_lics_event.eve_execution,'FM999999999999990'),'NOT APPLICABLE') || chr(13);
      var_message := var_message || 'Job Type             : ' || nvl(rcd_lics_event.eve_type,'NOT APPLICABLE') || chr(13);
      var_message := var_message || 'Interface Group      : ' || nvl(rcd_lics_event.eve_group,'NOT APPLICABLE') || chr(13);
      var_message := var_message || 'Interface Identifier : ' || nvl(rcd_lics_event.eve_interface,'NOT APPLICABLE') || chr(13);
      var_message := var_message || 'Interface Number     : ' || nvl(to_char(rcd_lics_event.eve_header,'FM999999999999990'),'NOT APPLICABLE') || chr(13);
      var_message := var_message || 'Interface Trace      : ' || nvl(to_char(rcd_lics_event.eve_hdr_trace,'FM99990'),'NOT APPLICABLE') || chr(13);
      var_message := var_message || 'Procedure            : ' || nvl(rcd_lics_event.eve_procedure,'NOT APPLICABLE') || chr(13);
      var_message := var_message || chr(13);
      if not(var_url is null) then
         var_message := var_message || 'URL Reference        : ' || var_url || chr(13);
         var_message := var_message || chr(13);
      end if;
      var_message := var_message || nvl(rcd_lics_event.eve_message,'** NO MESSAGE **');

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection(lics_parameter.email_smtp_host, lics_parameter.email_smtp_port);
      utl_smtp.helo(var_connection, lics_parameter.email_smtp_host);

      /*-*/
      /* Initialise the email
      /*-*/
      -- utl_smtp.mail(var_connection, lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment);
	  utl_smtp.mail(var_connection, lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment ||  LICS_PARAMETER.EMAIL_SUFFIX );
      /*-*/
      /* Set the recipient
      /*-*/
      utl_smtp.rcpt(var_connection, rcd_lics_event.eve_ema_group);

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'From: ' || lics_parameter.system_code || '_' || lics_parameter.system_unit || '_' || lics_parameter.system_environment || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'To: ' || rcd_lics_event.eve_ema_group || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'Subject: Interface Control System - Message' || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, utl_tcp.CRLF || var_message);
      utl_smtp.close_data(var_connection);

      /*-*/
      /* Quit the connection
      /*-*/
      utl_smtp.quit(var_connection);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_internal_email;

   /**************************************************/
   /* This procedure performs the send alert routine */
   /**************************************************/
   procedure send_alert(par_message in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Fix the message data
      /*-*/
      var_message := par_message;
      var_message := replace(var_message,'"','""');
      var_message := replace(var_message,chr(9),' ');
      var_message := replace(var_message,chr(10),' ');
      var_message := replace(var_message,chr(13),' ');
      var_message := '['||to_char(sysdate,'yyyy-mm-dd_hh24:mi:ss')||'] INFO '||upper(lics_parameter.log_environment)||' '||upper(lics_parameter.log_database)||' '||var_message;

      /*-*/
      /* Send the operator alert
      /*-*/
      lics_filesystem.write_log(lics_parameter.ami_logfile, var_message);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_alert;

   /**************************************************/
   /* This procedure performs the send email routine */
   /**************************************************/
   procedure send_email(par_system varchar2,
                        par_unit varchar2,
                        par_environment varchar2,
                        par_function in varchar2,
                        par_procedure in varchar2,
                        par_ema_group in varchar2,
                        par_message in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);
      var_connection utl_smtp.connection;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the email message
      /*-*/
      var_message := upper(nvl(par_function,'NO FUNCTION')) || chr(13);
      var_message := var_message || rpad('=',length(nvl(par_function,'NO FUNCTION')),'=') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'System        : ' || par_system || chr(13);
      var_message := var_message || 'Business Unit : ' || par_unit || chr(13);
      var_message := var_message || 'Environment   : ' || par_environment || chr(13);
      var_message := var_message || 'Timestamp     : ' || to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'Procedure     : ' || nvl(par_procedure,'NOT APPLICABLE') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || nvl(par_message,'** NO MESSAGE **');

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection(lics_parameter.email_smtp_host, lics_parameter.email_smtp_port);
      utl_smtp.helo(var_connection, lics_parameter.email_smtp_host);

      /*-*/
      /* Initialise the email
      /*-*/
      utl_smtp.mail(var_connection, par_system || '_' || par_unit || '_' || par_environment);

      /*-*/
      /* Set the recipient
      /*-*/
      utl_smtp.rcpt(var_connection, par_ema_group);

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'From: ' || par_system || '_' || par_unit || '_' || par_environment || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'To: ' || par_ema_group || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'Subject: ' || nvl(par_function,'NO FUNCTION') || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, utl_tcp.CRLF || var_message);
      utl_smtp.close_data(var_connection);

      /*-*/
      /* Quit the connection
      /*-*/
      utl_smtp.quit(var_connection);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_email;

end lics_notification;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_notification for lics_app.lics_notification;
grant execute on lics_notification to public;