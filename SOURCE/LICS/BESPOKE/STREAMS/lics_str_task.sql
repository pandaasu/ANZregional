/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_str_task
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_str_task

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/09   Steve Gregan   Created
 2011/11   Steve Gregan   Added stt_tsk_type to allow dependency gates
                          *GATE can only have *TOP as parent

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_str_task
   (stt_str_code          varchar2(32 char)            not null,
    stt_tsk_code          varchar2(32 char)            not null,
    stt_tsk_pcde          varchar2(32 char)            not null,
    stt_tsk_seqn          number                       not null,
    stt_tsk_text          varchar2(128 char)           not null,
    stt_tsk_type          varchar2(10 char)            not null);

/**/
/* Comments
/**/
comment on table lics_str_task is 'LICS Stream Task Table';
comment on column lics_str_task.stt_str_code is 'Stream task - stream code';
comment on column lics_str_task.stt_tsk_code is 'Stream task - task code';
comment on column lics_str_task.stt_tsk_pcde is 'Stream task - task parent';
comment on column lics_str_task.stt_tsk_seqn is 'Stream task - task sequence';
comment on column lics_str_task.stt_tsk_text is 'Stream task - task text';
comment on column lics_str_task.stt_tsk_type is 'Stream task - task type (*EXEC=Execution or *GATE=Gate)';

/**/
/* Primary Key Constraint
/**/
alter table lics_str_task
   add constraint lics_str_task_pk primary key (stt_str_code, stt_tsk_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_str_task to lics_app;

/**/
/* Synonym
/**/
create or replace public synonym lics_str_task for lics.lics_str_task;