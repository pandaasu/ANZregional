DROP PROCEDURE MANU_APP.MAILOUT;

CREATE OR REPLACE PROCEDURE MANU_APP.Mailout
  (
  message     IN VARCHAR2, mail_to IN VARCHAR2 DEFAULT '', locn IN VARCHAR2 DEFAULT ''
  ) IS

  
   /*-*/
   /* Public email parameters
   /*-*/
   email_smtp_host CONSTANT VARCHAR2(64) := manu_common.EMAIL_SERVER;
   email_smtp_port CONSTANT NUMBER(2,0) := 25;
   
   
   ema_group       CONSTANT VARCHAR2(100) := manu_common.MANAGERS_LOCAL_SUPPORT;
   fatal_cc        CONSTANT VARCHAR2(64)  := '';
   
   
   sender          CONSTANT VARCHAR2(100)  := manu_common.DB_Name;
   
   email_subject   CONSTANT VARCHAR2(100) := 'Error ocurred in scheduled Job running in Oracle';
   
   /*-*/
   /* Public business unit parameters
   /*-*/
   business_unit_code CONSTANT VARCHAR2(100) := manu_common.LOCATION;

   /*-*/
   /* Public system parameters
   /*-*/
   system_environment CONSTANT VARCHAR2(100) := manu_common.ENVIRONMENT;
   
   
   crlf            VARCHAR2(2)       := UTL_TCP.CRLF;
   connection      utl_smtp.connection;
   
   header          VARCHAR2(1000);
   v_message       VARCHAR2(4000);

   email_sender    VARCHAR2(200);
   fatal_ema_group VARCHAR2(200);
   
BEGIN

    IF locn = '' THEN
        email_sender := sender;
    ELSE
        email_sender := REPLACE(locn,' ','_');
    END IF;
    IF mail_to = '' THEN
        fatal_ema_group := ema_group;
    ELSE
        fatal_ema_group := mail_to;
    END IF;
    
    v_message := CHR(13) || 'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' )  || CHR(13) ;
    /*-*/
    /* Initialise the email message
    /*-*/
   
    v_message := v_message || '========================' || CHR(13);
    v_message := v_message || CHR(13);
    v_message := v_message || 'Business Unit        : ' || business_unit_code || CHR(13);
    v_message := v_message || 'Environment          : ' || system_environment || CHR(13);
    v_message := v_message || CHR(13);
    v_message := v_message || '========================' || CHR(13);
    v_message := v_message || crlf || Message;
   
  --
  -- Start the connection.
  --
  connection := utl_smtp.open_connection(email_smtp_host, email_smtp_port);

  header:= 'Date: '    || TO_CHAR(SYSDATE,'dd Mon yy hh24:mi:ss') || crlf ||
           'From: '    || email_sender || '' || crlf ||
           'Subject: ' || email_subject || crlf ||
           'To: '      || fatal_ema_group ; 
           --|| crlf  ||
           --  'CC: '      || fatal_cc
           --;
 
  --
  -- Handshake with the SMTP server
  --
  utl_smtp.helo(connection, email_smtp_host);
 
  utl_smtp.mail(connection, email_sender);
  utl_smtp.rcpt(connection, fatal_ema_group);
  -- no cc required so commeted out
  --utl_smtp.rcpt(connection, fatal_cc);
  utl_smtp.open_data(connection);
  
  --
  -- Write the header
  --
  utl_smtp.write_data(connection, header);
  
  
  --
  -- The crlf is required to distinguish that what comes next is not simply part of the header..
  --
  utl_smtp.write_data(connection, crlf || v_message);
  utl_smtp.close_data(connection);
  utl_smtp.quit(connection);

EXCEPTION
  WHEN UTL_SMTP.INVALID_OPERATION THEN
    dbms_output.put_line(' Invalid Operation in SMTP transaction.');
  WHEN UTL_SMTP.TRANSIENT_ERROR THEN
    dbms_output.put_line(' Temporary problems with sending email - try again later.');
  WHEN UTL_SMTP.PERMANENT_ERROR THEN
    dbms_output.put_line(' Errors in code for SMTP transaction.');   
END;
/


