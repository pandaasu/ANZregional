/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_sequence
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_sequence

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2011/02   Steve Gregan   End point architecture version

*******************************************************************************/

/**/
/* Sequence creation
/**/
create sequence lics_header_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence lics_execution_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence lics_triggered_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence lics_event_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence lics_log_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence lics_stream_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

create sequence lics_file_sequence
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;

/**/
/* Authority
/**/
grant select on lics_header_sequence to lics_app;
grant select on lics_execution_sequence to lics_app;
grant select on lics_triggered_sequence to lics_app;
grant select on lics_event_sequence to lics_app;
grant select on lics_log_sequence to lics_app;
grant select on lics_stream_sequence to lics_app;
grant select on lics_file_sequence to lics_app;

grant select on lics_header_sequence to lics_exec;
grant select on lics_execution_sequence to lics_exec;
grant select on lics_triggered_sequence to lics_exec;
grant select on lics_event_sequence to lics_exec;
grant select on lics_log_sequence to lics_exec;
grant select on lics_stream_sequence to lics_exec;
grant select on lics_file_sequence to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_header_sequence for lics.lics_header_sequence;
create or replace public synonym lics_execution_sequence for lics.lics_execution_sequence;
create or replace public synonym lics_triggered_sequence for lics.lics_triggered_sequence;
create or replace public synonym lics_event_sequence for lics.lics_event_sequence;
create or replace public synonym lics_log_sequence for lics.lics_log_sequence;
create or replace public synonym lics_stream_sequence for lics.lics_stream_sequence;
create or replace public synonym lics_file_sequence for lics.lics_file_sequence;
