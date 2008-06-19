DROP PACKAGE CR_APP.SIL_NOTIFICATION;

CREATE OR REPLACE PACKAGE CR_APP.sil_notification as
/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : STANDARD INTERFACE LOADER
 Package : sil_notification
 Owner   : cr_app
 Author  : Linden Glen

 DESCRIPTION
 -----------
 STANDARD INTERFACE LOADER - Notification

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/10   Linden Glen    Created

*******************************************************************************/

   procedure send_email(par_system varchar2,
                        par_unit varchar2,
                        par_environment varchar2,
                        par_function in varchar2,
                        par_procedure in varchar2,
                        par_ema_group in varchar2,
                        par_message in varchar2);

end sil_notification;
/


DROP PACKAGE BODY CR_APP.SIL_NOTIFICATION;

CREATE OR REPLACE PACKAGE BODY CR_APP.sil_notification as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

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
      var_message := var_message || 'Timestamp     : ' || to_char(sysdate,'YYYY/MM/DD HH:MI:SS') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || 'Procedure     : ' || nvl(par_procedure,'NOT APPLICABLE') || chr(13);
      var_message := var_message || chr(13);
      var_message := var_message || nvl(par_message,'** NO MESSAGE **');

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection(sil_parameter.email_smtp_host, sil_parameter.email_smtp_port);
      utl_smtp.helo(var_connection, sil_parameter.email_smtp_host);

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

end sil_notification;
/


DROP PUBLIC SYNONYM SIL_NOTIFICATION;

CREATE PUBLIC SYNONYM SIL_NOTIFICATION FOR CR_APP.SIL_NOTIFICATION;


GRANT EXECUTE ON CR_APP.SIL_NOTIFICATION TO PUBLIC;

