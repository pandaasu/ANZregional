/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_log
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_log

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_log
   (log_sequence                 number(15,0)                    not null,
    log_trace                    number(7,0)                     not null,
    log_time                     date                            not null,
    log_text                     varchar2(4000 char)             not null,
    log_search                   varchar2(256)                   null);

/**/
/* Comments
/**/
comment on table lics_log is 'LICS Log Table';
comment on column lics_log.log_sequence is 'Log - log sequence number (sequence generated)';
comment on column lics_log.log_trace is 'Log - log trace number (incremental)';
comment on column lics_log.log_time is 'Log - log time';
comment on column lics_log.log_text is 'log - log text';
comment on column lics_log.log_search is 'Log - log search';

/**/
/* Primary Key Constraint
/**/
alter table lics_log
   add constraint lics_log_pk primary key (log_sequence, log_trace);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_log to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_log for lics.lics_log;
