/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_exe_header
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_exe_header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_exe_header
   (sth_exe_seqn          number                       not null,
    sth_exe_text          varchar2(128 char)           not null,
    sth_exe_status        varchar2(10 char)            not null,
    sth_exe_request       varchar2(10 char)            not null,
    sth_exe_load          date                         not null,
    sth_exe_start         date                         not null,
    sth_exe_end           date                         not null,
    sth_str_code          varchar2(32 char)            not null,
    sth_str_text          varchar2(128 char)           not null,
    sth_status            varchar2(1 char)             not null,
    sth_upd_user          varchar2(30 char)            not null,
    sth_upd_time          date                         not null);

/**/
/* Comments
/**/
comment on table lics_str_exe_header is 'LICS Stream Execution Header Table';
comment on column lics_str_exe_header.sth_exe_seqn is 'Stream header - execution sequence';
comment on column lics_str_exe_header.sth_exe_text is 'Stream header - execution text';
comment on column lics_str_exe_header.sth_exe_status is 'Stream header - execution status';
comment on column lics_str_exe_header.sth_exe_request is 'Stream header - execution request';
comment on column lics_str_exe_header.sth_exe_load is 'Stream header - execution load time';
comment on column lics_str_exe_header.sth_exe_start is 'Stream header - execution start time';
comment on column lics_str_exe_header.sth_exe_end is 'Stream header - execution end time';
comment on column lics_str_exe_header.sth_str_code is 'Stream header - stream code';
comment on column lics_str_exe_header.sth_str_text is 'Stream header - stream text';
comment on column lics_str_exe_header.sth_status is 'Stream header - stream status';
comment on column lics_str_exe_header.sth_upd_user is 'Stream header - update user';
comment on column lics_str_exe_header.sth_upd_time is 'Stream header - update time';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_exe_header
   add constraint lics_str_exe_header_pk primary key (sth_exe_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_exe_header to lics_app;
grant select on lics_str_exe_header to lics_exec;
/**/
/* Synonym
/**/
create or replace public synonym lics_str_exe_header for lics.lics_str_exe_header;