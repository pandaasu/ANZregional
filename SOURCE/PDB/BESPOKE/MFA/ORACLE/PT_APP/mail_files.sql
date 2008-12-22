DROP PROCEDURE PT_APP.MAIL_FILES;

CREATE OR REPLACE PROCEDURE PT_APP.mail_files ( from_name varchar2,
                                         to_name varchar2,
                                         subject varchar2,
                                         message varchar2,
                                         max_size number default 9999999999,
                                         filename1 varchar2 default null,
                                         filename2 varchar2 default null,
                                         filename3 varchar2 default null,
                                         debug number default 0 ) is
/*
  This procedure uses the UTL_SMTP package to send an email message.
  Up to three file names may be specified as attachments.
  Parameters are:
    1) from_name (varchar2)
    2) to_name   (varchar2)
    3) subject   (varchar2)
    4) message   (varchar2)
    5) max_size  (number)
    5) filename1 (varchar2)
    6) filename2 (varchar2)
    7) filename3 (varchar2)
  eg.
    mail_files( from_name => 'oracle' ,
                to_name   => 'someone@somewhere.com' ,
                subject   => 'A test',
                message   => 'A test message',
                filename1 => '/data/oracle/dave_test1.txt',
                filename2 => '/data/oracle/dave_test2.txt');
  Most of the parameters are self-explanatory. "message" is a varchar2
  parameter, up to 32767 bytes long which contains the text of the message
  to be placed in the main body of the email.
  filename{1,2,3} are the names of the files to be attached to the email.
  The full pathname of each file must be specified. The files must exist
  in one of the directories specified in the init.ora parameter
  UTL_FILE_DIR. All filename parameters are optional: It is not necessary
  to specify unused file parameters (eg. filename3 is missing in the above
  example).
  The max_size parameter enables you to place a constraint on the maximum
  size of message, including all attachments, that the procedure will send.
  If this limit is exceeded, the procedure will truncate the message at
  that point with a '*** truncated ***' message. The default is effectively
  unlimited. However, the text of message body is still limited to 32Kb, as
  it is passed in as a varchar2.
  Obviously, as with any Oracle procedure, the parameter values can (and
  usually will be) PL/SQL variables, rather than hard-coded literals, as
  shown here.
  Written: Dave Wotton, 14/6/01 (Cambridge UK)
           This script comes with no warranty or support. You are free to
           modify it as you wish, but please retain an acknowledgement of
           my original authorship.
  Amended: Dave Wotton, 10/7/01
           Now uses the utl_smtp.write_data() method to send the message,
           eliminating the 32Kb message size constraint imposed by the
           utl_smtp.data() procedure.
  Amended: Dave Wotton, 20/7/01
           Increased the v_line variable, which holds the file attachment
           lines from 400 to 1000 bytes. This is the maximum supported
           by RFC2821, The Simple Mail Transfer Protocol specification.
  Amended: Dave Wotton, 24/7/01
           Now inserts a blank line before each MIME boundary line. Some
           mail-clients require this.
  Amended: Dave Wotton, 4/10/01
           Introduced a 'debug' parameter. Defaults to 0. If set to
           non-zero then errors in opening files for attaching are
           reported using dbms_output.put_line.
           Include code to hand MS Windows style pathnames.
*/
/*
  You may need to modify the following variable if you don't have a local
  SMTP service running (particularlyrelevant to Windows 2000 servers).
  Refer to http://home.clara.net/dwotton/dba/oracle_smtp.htm for more
  details.
*/
  --v_smtp_server      varchar2(20) := 'bau003.mca.ap.mars'; --'localhost';
  v_smtp_server      varchar2(20) := 'smtp.ap.mars'; --'localhost';
  v_smtp_server_port number  := 25;
  v_directory_name   varchar2(100);
  v_file_name        varchar2(100);
  v_line             varchar2(1000);
  crlf               varchar2(2):= chr(13) || chr(10);
  mesg               varchar2(32767);
  conn               UTL_SMTP.CONNECTION;
--  type varchar2_table is table of varchar2(200) index by binary_integer;
  type varchar2_table is table of varchar2(1000) index by binary_integer;
  file_array         varchar2_table;
  i                  binary_integer;
  v_file_handle      utl_file.file_type;
  v_slash_pos        number;
  mesg_len           number;
  mesg_too_long      exception;
  invalid_path       exception;
  mesg_length_exceeded boolean := false;
begin
   -- first load the three filenames into an array for easier handling later ...
   file_array(1) := filename1;
   file_array(2) := filename2;
   file_array(3) := filename3;
   -- Open the SMTP connection ...
   -- ------------------------
   conn:= utl_smtp.open_connection( v_smtp_server, v_smtp_server_port );
   -- Initial handshaking ...
   -- -------------------
   utl_smtp.helo( conn, v_smtp_server );
   utl_smtp.mail( conn, from_name );
   utl_smtp.rcpt( conn, to_name );
   utl_smtp.open_data ( conn );
   -- build the start of the mail message ...
   -- -----------------------------------
   mesg:= 'Date: ' || TO_CHAR( SYSDATE, 'dd Mon yy hh24:mi:ss' ) || crlf ||
          'From: ' || from_name || crlf ||
          'Subject: ' || subject || crlf ||
          'To: ' || to_name || crlf ||
          'Mime-Version: 1.0' || crlf ||
          'Content-Type: multipart/mixed; boundary="DMW.Boundary.605592468"' || crlf ||
          '' || crlf ||
          'This is a Mime message, which your current mail reader may not' || crlf ||
          'understand. Parts of the message will appear as text. If the remainder' || crlf ||
          'appears as random characters in the message body, instead of as' || crlf ||
          'attachments, then you''ll have to extract these parts and decode them' || crlf ||
          'manually.' || crlf ||
          '' || crlf ||
          '--DMW.Boundary.605592468' || crlf ||
          'Content-Type: text/plain; name="message.txt"; charset=US-ASCII' || crlf ||
          'Content-Disposition: inline; filename="message.txt"' || crlf ||
          'Content-Transfer-Encoding: 7bit' || crlf ||
          '' || crlf ||
          message || crlf ;
   mesg_len := length(mesg);
   if mesg_len > max_size then
      mesg_length_exceeded := true;
   end if;
   utl_smtp.write_data ( conn, mesg );
   -- Append the files ...
   -- ----------------
   for i in  1..3 loop
       -- Exit if message length already exceeded ...
       exit when mesg_length_exceeded;
       -- If the filename has been supplied ...
       if file_array(i) is not null then
          begin
             -- locate the final '/' or '\' in the pathname ...
             v_slash_pos := instr(file_array(i), '/', -1 );
             if v_slash_pos = 0 then
                v_slash_pos := instr(file_array(i), '\', -1 );
             end if;
             -- separate the filename from the directory name ...
             v_directory_name := substr(file_array(i), 1, v_slash_pos - 1 );
             v_file_name      := substr(file_array(i), v_slash_pos + 1 );
             -- open the file ...
             v_file_handle := utl_file.fopen(v_directory_name, v_file_name, 'r' );
             -- generate the MIMEboundary line ...
             mesg := crlf || '--DMW.Boundary.605592468' || crlf ||
             'Content-Type: application/octet-stream; name="' || v_file_name || '"' || crlf ||
             'Content-Disposition: attachment; filename="' || v_file_name || '"' || crlf ||
             'Content-Transfer-Encoding: 7bit' || crlf || crlf ;
             mesg_len := mesg_len + length(mesg);
             utl_smtp.write_data ( conn, mesg );
             -- and append the file contents to the end of the message ...
             loop
                 utl_file.get_line(v_file_handle, v_line);
                 if mesg_len + length(v_line) > max_size then
                    mesg := '*** truncated ***' || crlf;
                    utl_smtp.write_data ( conn, mesg );
                    mesg_length_exceeded := true;
                    raise mesg_too_long;
                 end if;
                 mesg := v_line || crlf;
                 utl_smtp.write_data ( conn, mesg );
                 mesg_len := mesg_len + length(mesg);
             end loop;
          exception
             when utl_file.invalid_path then
                 if debug > 0 then
                    dbms_output.put_line('Error in opening attachment '||
                                          file_array(i) );
                 end if;
             -- All other exceptions are ignored ....
             when others then
                 null;
          end;
          mesg := crlf;
          utl_smtp.write_data ( conn, mesg );
          -- close the file ...
          utl_file.fclose(v_file_handle);
        end if;
   end loop;
   -- append the final boundary line ...
   mesg := crlf || '--DMW.Boundary.605592468--' || crlf;
   utl_smtp.write_data ( conn, mesg );
   -- and close the SMTP connection  ...
   utl_smtp.close_data( conn );
   utl_smtp.quit( conn );
end;
/


