DROP PROCEDURE PT_APP.SEND_MAIL;

CREATE OR REPLACE PROCEDURE PT_APP.send_mail(p_sender IN VARCHAR2, p_recipient IN VARCHAR2, p_subject IN VARCHAR2, p_message IN VARCHAR2) as
/*
MAIL ONLY
execute send_mail('craig.george@esonts1', 'anna.caine@esonts1', 'OK test 12', 'hello utl_smtp test');

SMS MEGGAGE
%APSMS@esonts1      This will send all details (from, to, subject, message)
%AUTOSMS@esonts1     This strips out all the details bar the message

execute send_mail('craig.george@esonts1', '0419505998%APSMS@esonts1', 'Phone Test Msg', 'hello phone test');
execute send_mail('craig.george@esonts1', '0419505998%AUTOSMS@esonts1', 'Phone Test Msg', 'hello phone test');
*/
-- l_mailhost VARCHAR2(255) := 'bau003.mca.ap.mars';  -- IP of an smtp enabled server
 l_mailhost VARCHAR2(255) := 'smtp.ap.mars';  -- IP of an smtp enabled server
 l_mail_conn utl_smtp.connection;
 v_phase  number;
 --e_cg  exception;

BEGIN
  v_phase := 1;
  l_mail_conn := utl_smtp.open_connection(l_mailhost, 25);

  v_phase := 2;
  utl_smtp.helo(l_mail_conn, l_mailhost);
  utl_smtp.mail(l_mail_conn, p_sender);
  utl_smtp.rcpt(l_mail_conn, p_recipient);

  v_phase := 3;
  utl_smtp.open_data(l_mail_conn);
  utl_smtp.write_data(l_mail_conn, 'TO: ' || p_recipient || utl_tcp.crlf);
  utl_smtp.write_data(l_mail_conn, 'From: ' || p_sender || utl_tcp.crlf);
  utl_smtp.write_data(l_mail_conn, 'Subject: ' || p_subject || utl_tcp.crlf);
  utl_smtp.write_data(l_mail_conn, p_message);
  utl_smtp.close_data(l_mail_conn);

  v_phase := 4;
  utl_smtp.quit(l_mail_conn);
  EXCEPTION
  WHEN OTHERS THEN
  dbms_output.put_line ('v_phase = ' || v_phase || ' - ' || substr(sqlerrm,1,80 ));
--  raise e_cg;
end;
/


