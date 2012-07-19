/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_action
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_action

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/09   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_action
   (sta_str_seqn          number                       not null,
    sta_tsk_seqn          number                       not null,
    sta_evt_seqn          number                       not null,
    sta_str_code          varchar2(32 char)            not null,
    sta_str_text          varchar2(128 char)           not null,
    sta_tsk_pcde          varchar2(32 char)            not null,
    sta_tsk_code          varchar2(32 char)            not null,
    sta_tsk_text          varchar2(128 char)           not null,
    sta_evt_code          varchar2(32 char)            not null,
    sta_evt_text          varchar2(128 char)           not null,
    sta_evt_lock          varchar2(32 char)            not null,
    sta_evt_proc          varchar2(512 char)           not null,
    sta_job_group         varchar2(10 char)            not null,
    sta_opr_alert         varchar2(256 char)           null,
    sta_ema_group         varchar2(64 char)            null,
    sta_timestamp         date                         not null,
    sta_status            varchar2(10 char)            not null,
    sta_selected          varchar2(1 char)             not null,
    sta_completed         varchar2(1 char)             not null,
    sta_failed            varchar2(1 char)             not null,
    sta_message           varchar2(4000 char)          null);

/**/
/* Comments
/**/
comment on table lics_str_action is 'LICS Stream Action Table';
comment on column lics_str_action.sta_str_seqn is 'Stream action - stream sequence';
comment on column lics_str_action.sta_tsk_seqn is 'Stream action - task sequence';
comment on column lics_str_action.sta_evt_seqn is 'Stream action - event sequence';
comment on column lics_str_action.sta_str_code is 'Stream action - stream code';
comment on column lics_str_action.sta_str_text is 'Stream action - stream text';
comment on column lics_str_action.sta_tsk_pcde is 'Stream action - task parent';
comment on column lics_str_action.sta_tsk_code is 'Stream action - task code';
comment on column lics_str_action.sta_tsk_text is 'Stream action - task text';
comment on column lics_str_action.sta_evt_code is 'Stream action - event code';
comment on column lics_str_action.sta_evt_text is 'Stream action - event text';
comment on column lics_str_action.sta_evt_lock is 'Stream action - event lock';
comment on column lics_str_action.sta_evt_proc is 'Stream action - event procedure';
comment on column lics_str_action.sta_job_group is 'Stream action - job group';
comment on column lics_str_action.sta_opr_alert is 'Stream action - operator alert message';
comment on column lics_str_action.sta_ema_group is 'Stream action - email group';
comment on column lics_str_action.sta_timestamp is 'Stream action - creation time';
comment on column lics_str_action.sta_status is 'Stream action - status';
comment on column lics_str_action.sta_selected is 'Stream action - status - selected';
comment on column lics_str_action.sta_completed is 'Stream action - status - completed';
comment on column lics_str_action.sta_failed is 'Stream action - status - failed';
comment on column lics_str_action.sta_message is 'Stream action - message';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_action
   add constraint lics_str_action_pk primary key (sta_str_seqn, sta_tsk_seqn, sta_evt_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_action to lics_app;
grant select on lics_str_action to lics_exec;

/**/
/* Synonym
/**/
create or replace public synonym lics_str_action for lics.lics_str_action;