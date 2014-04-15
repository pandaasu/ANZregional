CREATE OR REPLACE package LICS_APP.lics_mailer as

/******************************************************************************/
/* Package Definition                                                         */
/******************************************************************************/
/**
 System  : lics
 Package : lics_mailer
 Owner   : lics_app
 Author  : Linden Glen

 DESCRIPTION
 -----------
 Local Interface Control System - Mailer

 The package implements the mailer functionality.

  PROCEDURE: CREATE_EMAIL

   1. PAR_SENDER ('sender@host', null)  null = default of 'CURRENT_USER@DB_NAME'
   1. PAR_RECIPIENT ('linden.glen','linden.glen@ap.effem.com','linden.glen@smtp.ap.mars')
   2. PAR_SUBJECT   ('subject', null)
   3. PAR_SMTP_HOST ('host', null)  null = default of 'smtp.ap.mars'
   4. PAR_SMTP_PORT ('port', null)  null = default of 25

  PROCEDURE: CREATE_PART

   1. PAR_File ('file name', null)

      Part to be created in email body.
      File name ('filename.ext') - max length 128 characters (null = text in body)

  PROCEDURE: APPEND_DATA

   1. PAR_DATA ('data', null)

      Data line to be written to email body. Max length 4000 characters.

  PROCEDURE: FINALISE_EMAIL

  FUNCTION: IS_CREATED

   1. RETURN : BOOLEAN

      TRUE  : CREATE_EMAIL successfully executed (ready to receive data)
      FALSE : CREATE_EMAIL not executed

  EXAMPLE USAGE :

     begin
        < processing >

        lics_mailer.create_email('RECORD_LOADER@AP0001P.AP.MARS','linden.glen','Data Loading System',null,null);
        lics_mailer.create_part(null);
        lics_mailer.append_data('100 records were just loaded.');
        lics_mailer.append_data('See attachment for details :');

        lics_mailer.create_part('file_load.txt');
        < open loop >
           lics_mailer.append_data(< cursor record >);
        < finish loop >

        lics_mailer.create_part(null);
        lics_mailer.append_data('End of load report');

        lics_mailer.finalise_email;

     exception
        when others then
           if (lics_mailer.is_created) then
              lics_mailer.append_data('** FATAL ERROR DURING LOAD ** - Records listed were loaded successfully');
              lics_mailer.finalise_email;
           end if;
     end;


  SHORT EMAIL EXAMPLE USAGE :

     begin
        < processing >

        lics_mailer.send_short_email('LOADER@AP0001P.AP.MARS',
                                     'linden.glen',
                                     'INFO : Processing Complete',
                                     '123 records processed on 20051023 successfully',
                                     null,
                                     null);

        < processing >

     end;

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/01   Linden Glen    Created
 2006/12   Steve Gregan   Changed to handle multiple part emails
 2008/01   Steve Gregan   Changed to handle character sets
 2010/05   Steve Gregan   Changed to handle 128 character file names

*******************************************************************************/

   /*-*/
   /* Public declarations
   /*-*/
   procedure send_short_email(par_sender in varchar2,
                              par_recipient in varchar2,
                              par_subject in varchar2,
                              par_body in varchar2,
                              par_smtp_host in varchar2,
                              par_smtp_port in number);
   procedure create_email(par_sender in varchar2,
                          par_recipient in varchar2,
                          par_subject in varchar2,
                          par_smtp_host in varchar2,
                          par_smtp_port in number);
   procedure create_part(par_file in varchar2);
   procedure append_data(par_data in varchar2);
   procedure finalise_email(par_charset in varchar2 default null);
   function is_created return boolean;

end lics_mailer;

/****************/
/* Package Body */
/****************/
create or replace package body lics_mailer as

   /*-*/
   /* Private exceptions
   /*-*/
   application_exception exception;
   pragma exception_init(application_exception, -20000);

   /*-*/
   /* Constants
   /*-*/
   con_default_smtp_host CONSTANT varchar2(32) := 'smtp.ap.mars';
   con_default_smtp_port CONSTANT number := 25;
   con_email_boundary CONSTANT varchar2(64) := '-----7D81B75CCC90D2974F7A1CBD';
   con_open_email_boundary CONSTANT varchar2(64) := '--' || con_email_boundary;
   con_close_email_boundary CONSTANT varchar2(64) := '--' || con_email_boundary || '--';
   con_email_mime_type CONSTANT varchar2(64) := 'multipart/mixed';
   con_part_mime_type CONSTANT varchar2(64) := 'text/plain';

   /*-*/
   /* Private definitions
   /*-*/
   var_created boolean;
   var_sender varchar2(128);
   var_recipient varchar2(128);
   var_subject varchar2(512);
   var_smtp_host varchar2(128);
   var_smtp_port number;
   type rcd_part is record(part_file varchar2(128 char), part_dsix number, part_deix number);
   type typ_part is table of rcd_part index by binary_integer;
   type typ_data is table of varchar2(4000 char) index by binary_integer;
   tbl_part typ_part;
   tbl_data typ_data;

   /**************************************************/
   /* This function performs the short email routine */
   /**************************************************/
   procedure send_short_email(par_sender in varchar2,
                              par_recipient in varchar2,
                              par_subject in varchar2,
                              par_body in varchar2,
                              par_smtp_host in varchar2,
                              par_smtp_port in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Create email
      /*-*/
      create_email(par_sender, par_recipient, par_subject, par_smtp_host, par_smtp_port);

      /*-*/
      /* Create a text part and append the body
      /*-*/
      create_part(null);
      append_data(par_body);

      /*-*/
      /* Finalise email
      /*-*/
      finalise_email;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   --exception

      /**/
      /* Exception trap
      /**/
     -- when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
       --  raise_application_error(-20000, 'FATAL ERROR - LICS_MAILER - SEND_SHORT_EMAIL - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end send_short_email;

   /***************************************************/
   /* This function performs the create email routine */
   /***************************************************/
   procedure create_email(par_sender in varchar2,
                          par_recipient in varchar2,
                          par_subject in varchar2,
                          par_smtp_host in varchar2,
                          par_smtp_port in number) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Validate the parameters
      /*-*/
      if length(par_sender) > 128 then
         raise_application_error(-20000, 'Maximum sender length of 128 characters exceeded');
      end if;
      if par_recipient is null then
         raise_application_error(-20000, 'Mail recipient not defined');
      end if;
      if length(par_recipient) > 128 then
         raise_application_error(-20000, 'Maximum recepient length of 128 characters exceeded');
      end if;
      if length(par_subject) > 512 then
         raise_application_error(-20000, 'Maximum subject length of 512 characters exceeded');
      end if;
      if length(par_smtp_host) > 512 then
         raise_application_error(-20000, 'Maximum SMTP host length of 128 characters exceeded');
      end if;

      /*-*/
      /* Default and set the sender variable
      /*-*/
      if par_sender is null then
         select upper(sys_context('USERENV','CURRENT_USER') || '@' || sys_context('USERENV','DB_NAME'))
           into var_sender
           from dual;
      else
         var_sender := par_sender;
      end if;

      /*-*/
      /* Set the recipient variable
      /*-*/
      -- var_recipient := par_recipient;
	  -- for smtp change. by derek
      if instr(par_recipient, '@') = 0 then
        var_recipient := trim(par_recipient) || LICS_PARAMETER.EMAIL_SUFFIX;
      else
         var_recipient := par_recipient;
      end if;
	  
      /*-*/
      /* Set the subject variable
      /*-*/
      var_subject := par_subject;

      /*-*/
      /* Default and set the SMTP host variable
      /*-*/
      if par_smtp_host is null then
         var_smtp_host := con_default_smtp_host;
      else
         var_smtp_host := par_smtp_host;
      end if;
	  
      -- for smtp change. by derek
      if instr(par_sender, '@') = 0 then
        var_sender := trim(par_sender) || LICS_PARAMETER.EMAIL_SUFFIX;
      end if;
	  
      /*-*/
      /* Default and set the SMTP port variable
      /*-*/
      if par_smtp_host is null then
         var_smtp_port := con_default_smtp_port;
      else
         var_smtp_port := par_smtp_port;
      end if;

      /*-*/
      /* Clear the email array data
      /*-*/
      tbl_part.delete;
      tbl_data.delete;

      /*-*/
      /* Define email as created
      /*-*/
      var_created := true;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   --exception

      /**/
      /* Exception trap
      /**/
     -- when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
       --  raise_application_error(-20000, 'FATAL ERROR - LICS_MAILER - CREATE_EMAIL - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_email;

   /**************************************************/
   /* This function performs the create part routine */
   /**************************************************/
   procedure create_part(par_file in varchar2) is

      /*-*/
      /* Local definitions
      /*-*/
      var_index number;

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Email must be created
      /*-*/
      if var_created is null then
         raise_application_error(-20000, 'Email has not been created');
      end if;

      /*-*/
      /* Validate the part file
      /*-*/
      if not(par_file is null) then
         if length(par_file) > 128 then
            raise_application_error(-20000, 'Maximum file name length of 128 characters exceeded');
         end if;
      end if;

      /*-*/
      /* Append the part to the part array
      /*-*/
      var_index := tbl_part.count + 1;
      tbl_part(var_index).part_file := par_file;
      tbl_part(var_index).part_dsix := 0;
      tbl_part(var_index).part_deix := 0;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   --exception

      /**/
      /* Exception trap
      /**/
     -- when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
       --  raise_application_error(-20000, 'FATAL ERROR - LICS_MAILER - CREATE_PART - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end create_part;

   /*******************************************/
   /* This function appends data to the email */
   /*******************************************/
   procedure append_data(par_data in varchar2) is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Email must be created
      /*-*/
      if var_created is null then
         raise_application_error(-20000, 'Email has not been created');
      end if;

      /*-*/
      /* Email part must be created
      /*-*/
      if tbl_part.count = 0 then
         raise_application_error(-20000, 'Email part has not been created');
      end if;

      /*-*/
      /* Email data must be valid
      /*-*/
      if length(par_data) > 4000 then
         raise_application_error(-20000, 'Maximum data length of 4000 characters exceeded');
      end if;

      /*-*/
      /* Append the data to the data array
      /*-*/
      tbl_data(tbl_data.count + 1) := par_data;

      /*-*/
      /* Update the part data pointers
      /*-*/
      if tbl_part(tbl_part.count).part_dsix = 0 then
         tbl_part(tbl_part.count).part_dsix := tbl_data.count;
      end if;
      tbl_part(tbl_part.count).part_deix := tbl_data.count;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
  -- exception

      /**/
      /* Exception trap
      /**/
    --  when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
       --  raise_application_error(-20000, 'FATAL ERROR - LICS_MAILER - APPEND_DATA - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end append_data;

   /***********************************************/
   /* This function finalises and sends the email */
   /***********************************************/
   procedure finalise_email(par_charset in varchar2 default null) is

      /*-*/
      /* Local definitions
      /*-*/
      var_connection utl_smtp.connection;
      var_email_content varchar2(1024 char);
      var_part_content varchar2(1024 char);

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Email must be created
      /*-*/
      if var_created is null then
         raise_application_error(-20000, 'Email has not been created');
      end if;

      /*-*/
      /* Set the content types
      /*-*/
      if par_charset is null then
         var_email_content := 'Content-Type: ' || con_email_mime_type || '; boundary="'|| con_email_boundary || '"' || utl_tcp.CRLF || utl_tcp.CRLF;
         var_part_content := 'Content-Type: ' || con_part_mime_type;
      else
         var_email_content := 'Content-Type: ' || con_email_mime_type || '; charset=' || par_charset || '; boundary="'|| con_email_boundary || '"' || utl_tcp.CRLF || utl_tcp.CRLF;
         var_part_content := 'Content-Type: ' || con_part_mime_type || '; charset=' || par_charset;
      end if;

      /*-*/
      /* Initialise the email environment
      /*-*/
      var_connection := utl_smtp.open_connection(var_smtp_host, var_smtp_port);
      utl_smtp.helo(var_connection, var_smtp_host);

      /*-*/
      /* Initialise the email
      /*-*/
      utl_smtp.mail(var_connection, var_sender);

      /*-*/
      /* Set the recipient
      /*-*/
      utl_smtp.rcpt(var_connection, var_recipient);

      /*-*/
      /* Load the email message
      /*-*/
      utl_smtp.open_data(var_connection);
      utl_smtp.write_data(var_connection, 'From: ' || var_sender || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'To: ' || var_recipient || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, 'Subject: ' || var_subject || utl_tcp.CRLF);
      utl_smtp.write_data(var_connection, var_email_content);

      /*-*/
      /* Write email body from the part and data array
      /*-*/
      for pidx in 1..tbl_part.count loop
         if tbl_part(pidx).part_file is null then
            utl_smtp.write_data(var_connection, con_open_email_boundary || utl_tcp.CRLF);
            utl_smtp.write_data(var_connection, var_part_content || utl_tcp.CRLF || utl_tcp.CRLF);
         else
            utl_smtp.write_data(var_connection, con_open_email_boundary || utl_tcp.CRLF);
            utl_smtp.write_data(var_connection, var_part_content || utl_tcp.CRLF);
            utl_smtp.write_data(var_connection, 'Content-Disposition: attachment; filename= ' || tbl_part(pidx).part_file || utl_tcp.CRLF);
         end if;
         if par_charset is null then
            utl_smtp.write_data(var_connection, utl_tcp.CRLF);
         else
            utl_smtp.write_raw_data(var_connection, utl_raw.cast_to_raw(utl_tcp.CRLF));
         end if;
         for didx in tbl_part(pidx).part_dsix..tbl_part(pidx).part_deix loop
            if par_charset is null then
               utl_smtp.write_data(var_connection, tbl_data(didx) || utl_tcp.CRLF);
            else
               utl_smtp.write_raw_data(var_connection, utl_raw.cast_to_raw(tbl_data(didx) || utl_tcp.CRLF));
            end if;
         end loop;
      end loop;

      /*-*/
      /* Close the email boundary
      /*-*/
      utl_smtp.write_data(var_connection, con_close_email_boundary || utl_tcp.CRLF);

      /*-*/
      /* Close the data stream and quit the connection
      /*-*/
      utl_smtp.close_data(var_connection);
      utl_smtp.quit(var_connection);

      /*-*/
      /* Reset the package
      /*-*/
      var_created := null;

   /*-------------------*/
   /* Exception handler */
   /*-------------------*/
   --exception

      /**/
      /* Exception trap
      /**/
   --   when others then

         /*-*/
         /* Raise an exception to the calling application
         /*-*/
       --  raise_application_error(-20000, 'FATAL ERROR - LICS_MAILER - FINALISE_EMAIL - ' || substr(SQLERRM, 1, 1024));

   /*-------------*/
   /* End routine */
   /*-------------*/
   end finalise_email;

   /*************************************************/
   /* This function performs the is created routine */
   /*************************************************/
   function is_created return boolean is

   /*-------------*/
   /* Begin block */
   /*-------------*/
   begin

      /*-*/
      /* Email is created
      /*-*/
      if var_created is null then
         return false;
      end if;
      return true;

   /*-------------*/
   /* End routine */
   /*-------------*/
   end is_created;

/*----------------------*/
/* Initialisation block */
/*----------------------*/
begin

   /*-*/
   /* Initialise the package
   /*-*/
   var_created := null;

end lics_mailer;
/  

/**************************/
/* Package Synonym/Grants */
/**************************/
create or replace public synonym lics_mailer for lics_app.lics_mailer;
grant execute on lics_mailer to public;