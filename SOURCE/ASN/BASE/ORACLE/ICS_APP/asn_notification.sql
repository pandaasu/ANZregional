/******************/
/* Package Header */
/******************/
create or replace package asn_notification as

   /******************************************************************************/
   /* Package Definition                                                         */
   /******************************************************************************/
   /**
    System  : asn
    Package : asn_notification
    Owner   : ics_app
    Author  : Steve Gregan

    Description
    -----------
    Advanced Shipping Notice - ASN Notification

    YYYY/MM   Author         Description
    -------   ------         -----------
    2005/11   Steve Gregan   Created
    2006/11   Steve Gregan   Added alert message
    2007/05   Steve Gregan   Added generic email

*******************************************************************************/

   /**/
   /* Public declarations
   /**/
   procedure send_generic_email(par_subject varchar2,
                                par_snd_address in varchar2,
                                par_rcv_address in varchar2,
                                par_message in varchar2);
   procedure send_warning_email(par_environment varchar2,
                                par_ema_group in varchar2,
                                par_message in varchar2);
   procedure send_alert_email(par_environment varchar2,
                              par_ema_group in varchar2,
                              par_message in varchar2);
   procedure send_alert_message(par_message in varchar2);

end asn_notification;
/

/****************/
/* Package Body */
/****************/
create or replace package body asn_notification as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /**********************************************************/
   /* This procedure performs the send generic email routine */
   /**********************************************************/
   procedure send_generic_email(par_subject varchar2,
                                par_snd_address in varchar2,
                                par_rcv_address in varchar2,
                                par_message in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_connection utl_smtp.connection;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection('esosn1.ap.mars', 25);
      utl_smtp.helo(var_connection, 'esosn1.ap.mars');

      /*-*/
      /* Initialise the email
      /*-*/
      utl_smtp.mail(var_connection, par_snd_address);

      /*-*/
      /* Set the recipient
      /*-*/
      utl_smtp.rcpt(var_connection, par_rcv_address);

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'From: ' || par_snd_address || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'To: ' || par_rcv_address || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'Subject: ' || par_subject || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, utl_tcp.CRLF || par_message);
      utl_smtp.close_data(var_connection);

      /*-*/
      /* Quit the connection
      /*-*/
      utl_smtp.quit(var_connection);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_generic_email;

   /**********************************************************/
   /* This procedure performs the send warning email routine */
   /**********************************************************/
   procedure send_warning_email(par_environment varchar2,
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
      var_message := 'ASN WARNING' || chr(13);
      var_message := var_message || rpad('=',length('ASN WARNING'),'=') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'Environment   : ' || par_environment || chr(13);
      var_message := var_message || 'Timestamp     : ' || to_char(sysdate,'YYYY/MM/DD HH:MI:SS') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || nvl(par_message,'** NO MESSAGE **');

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection('esosn1.ap.mars', 25);
      utl_smtp.helo(var_connection, 'esosn1.ap.mars');

      /*-*/
      /* Initialise the email
      /*-*/
      utl_smtp.mail(var_connection, 'ASN_' || par_environment);

      /*-*/
      /* Set the recipient
      /*-*/
      utl_smtp.rcpt(var_connection, par_ema_group);

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'From: ' || 'ASN_' || par_environment || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'To: ' || par_ema_group || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'Subject: ASN Warning' || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, utl_tcp.CRLF || var_message);
      utl_smtp.close_data(var_connection);

      /*-*/
      /* Quit the connection
      /*-*/
      utl_smtp.quit(var_connection);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_warning_email;

   /********************************************************/
   /* This procedure performs the send alert email routine */
   /********************************************************/
   procedure send_alert_email(par_environment varchar2,
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
      var_message := 'ASN ALERT' || chr(13);
      var_message := var_message || rpad('=',length('ASN ALERT'),'=') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'Environment   : ' || par_environment || chr(13);
      var_message := var_message || 'Timestamp     : ' || to_char(sysdate,'YYYY/MM/DD HH:MI:SS') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || nvl(par_message,'** NO MESSAGE **');

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection('esosn1.ap.mars', 25);
      utl_smtp.helo(var_connection, 'esosn1.ap.mars');

      /*-*/
      /* Initialise the email
      /*-*/
      utl_smtp.mail(var_connection, 'ASN_' || par_environment);

      /*-*/
      /* Set the recipient
      /*-*/
      utl_smtp.rcpt(var_connection, par_ema_group);

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'From: ' || 'ASN_' || par_environment || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'To: ' || par_ema_group || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'Subject: ASN Alert' || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, utl_tcp.CRLF || var_message);
      utl_smtp.close_data(var_connection);

      /*-*/
      /* Quit the connection
      /*-*/
      utl_smtp.quit(var_connection);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_alert_email;

   /**********************************************************/
   /* This procedure performs the send alert message routine */
   /**********************************************************/
   procedure send_alert_message(par_message in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_message varchar2(4000);
      var_parameter varchar2(4000);

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

      /*-*/
      /* Initialise the operator alert
      /*-*/
      var_parameter := lics_parameter.operator_alert_script || ' "' || var_message || '"';

      /*-*/
      /* Send the operator alert
      /*-*/
      java_utility.execute_external_procedure(var_parameter);

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_alert_message;

end asn_notification;
/

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym asn_notification for ics_app.asn_notification;
grant execute on asn_notification to public;