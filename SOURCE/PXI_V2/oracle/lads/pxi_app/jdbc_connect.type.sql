-- Create a type that both java and plsql can exchange data via.
create or replace type tt_jdbc_connect as table of varchar2(512);
/