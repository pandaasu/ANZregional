/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_exe_event
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_exe_event

 YYYY/MM   Author         Description
 -------   ------         -----------
 2011/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_exe_event
   (ste_exe_seqn          number                       not null,
    ste_exe_status        varchar2(10 char)            not null,
    ste_exe_queued        date                         not null,
    ste_exe_open          date                         not null,
    ste_exe_start         date                         not null,
    ste_exe_end           date                         not null,
    ste_exe_message       varchar2(4000 char)          null,
    ste_str_code          varchar2(32 char)            not null,
    ste_tsk_code          varchar2(32 char)            not null,
    ste_evt_code          varchar2(32 char)            not null,
    ste_evt_seqn          number                       not null,
    ste_evt_text          varchar2(128 char)           not null,
    ste_evt_lock          varchar2(32 char)            not null,
    ste_evt_proc          varchar2(512 char)           not null,
    ste_job_group         varchar2(10 char)            not null,
    ste_opr_alert         varchar2(256 char)           null,
    ste_ema_group         varchar2(64 char)            null);

/**/
/* Comments
/**/
comment on table lics_str_exe_event is 'LICS Stream Execution Event Table';
comment on column lics_str_exe_event.ste_exe_seqn is 'Stream event - execution sequence';
comment on column lics_str_exe_event.ste_exe_status is 'Stream event - execution status';
comment on column lics_str_exe_event.ste_exe_queued is 'Stream event - execution queued time';
comment on column lics_str_exe_event.ste_exe_open is 'Stream event - execution open time';
comment on column lics_str_exe_event.ste_exe_start is 'Stream event - execution start time';
comment on column lics_str_exe_event.ste_exe_end is 'Stream event - execution end time';
comment on column lics_str_exe_event.ste_exe_message is 'Stream event - execution message';
comment on column lics_str_exe_event.ste_str_code is 'Stream event - stream code';
comment on column lics_str_exe_event.ste_tsk_code is 'Stream event - task code';
comment on column lics_str_exe_event.ste_evt_code is 'Stream event - event code';
comment on column lics_str_exe_event.ste_evt_seqn is 'Stream event - event sequence';
comment on column lics_str_exe_event.ste_evt_text is 'Stream event - event text';
comment on column lics_str_exe_event.ste_evt_lock is 'Stream event - event lock';
comment on column lics_str_exe_event.ste_evt_proc is 'Stream event - event procedure';
comment on column lics_str_exe_event.ste_job_group is 'Stream event - job group';
comment on column lics_str_exe_event.ste_opr_alert is 'Stream event - operator alert message';
comment on column lics_str_exe_event.ste_ema_group is 'Stream event - email group';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_exe_event
   add constraint lics_str_exe_event_pk primary key (ste_exe_seqn, ste_evt_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_exe_event to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_str_exe_event for lics.lics_str_exe_event;