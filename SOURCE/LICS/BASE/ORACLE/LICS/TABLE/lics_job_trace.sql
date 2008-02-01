/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_job_trace
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_job_trace

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_job_trace
   (jot_execution                number(15,0)                    not null,
    jot_job                      varchar2(32 char)               not null,
    jot_type                     varchar2(10 char)               not null,
    jot_int_group                varchar2(10 char)               null,
    jot_procedure                varchar2(256 char)              null,
    jot_user                     varchar2(30 char)               not null,
    jot_str_time                 date                            not null,
    jot_end_time                 date                            not null,
    jot_status                   varchar2(1 char)                not null,
    jot_message                  varchar2(4000 char)             null);

/**/
/* Comments
/**/
comment on table lics_job_trace is 'LICS Job Trace Table';
comment on column lics_job_trace.jot_execution is 'Job trace - job execution number';
comment on column lics_job_trace.jot_job is 'Job trace - job identifier';
comment on column lics_job_trace.jot_type is 'Job trace - job type';
comment on column lics_job_trace.jot_int_group is 'Job trace - interface group';
comment on column lics_job_trace.jot_procedure is 'Job trace - job procedure';
comment on column lics_job_trace.jot_user is 'Job trace - user identifier';
comment on column lics_job_trace.jot_str_time is 'Job trace - trace start time';
comment on column lics_job_trace.jot_end_time is 'Job trace - trace end time';
comment on column lics_job_trace.jot_status is 'Job trace - job status';
comment on column lics_job_trace.jot_message is 'Job trace - job message';

/**/
/* Primary Key Constraint
/**/
alter table lics_job_trace
   add constraint lics_job_trace_pk primary key (jot_execution);

/**/
/* Foreign Key Constraints
/**/
--alter table lics_job_trace
--   add constraint lics_job_trace_fk01 foreign key (jot_job)
--      references lics_job (job_job);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_job_trace to lics_app;

/**/
/* Synonym
/**/
create public synonym lics_job_trace for lics.lics_job_trace;
