/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lics
 Table   : lics_job
 Owner   : lics
 Author  : Steve Gregan

 Description
 -----------
 Local Interface Control System - lics_job

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lics_job
   (job_job                      varchar2(32 char)               not null,
    job_description              varchar2(128 char)              not null,
    job_res_group                varchar2(32 char)               null,
    job_exe_history              number(5,0)                     not null,
    job_opr_alert                varchar2(256 char)              null,
    job_ema_group                varchar2(64 char)               null,
    job_type                     varchar2(10 char)               not null,
    job_int_group                varchar2(10 char)               null,
    job_procedure                varchar2(256 char)              null,
    job_next                     varchar2(4000 char)             null,
    job_interval                 varchar2(4000 char)             null,
    job_status                   varchar2(1 char)                not null);

/**/
/* Comments
/**/
comment on table lics_job is 'LICS Job table';
comment on column lics_job.job_job is 'Job - job identifier';
comment on column lics_job.job_description is 'Job - job description';
comment on column lics_job.job_res_group is 'Job - process identifier';
comment on column lics_job.job_exe_history is 'Job - trace history to retain (number)';
comment on column lics_job.job_opr_alert is 'Job - operator alert message';
comment on column lics_job.job_ema_group is 'Job - email group';
comment on column lics_job.job_type is 'Job - job type';
comment on column lics_job.job_int_group is 'Job - interface group';
comment on column lics_job.job_procedure is 'Job - procedure to execute';
comment on column lics_job.job_next is 'Job - next execution';
comment on column lics_job.job_interval is 'Job - execution interval';
comment on column lics_job.job_status is 'Job - job status';

/**/
/* Primary Key Constraint
/**/
alter table lics_job
   add constraint lics_job_pk primary key (job_job);

/**/
/* Authority
/**/
grant select, insert, update, delete on lics_job to lics_app;
grant select on lics_job to lics_exec;

/**/
/* Synonym
/**/
create public synonym lics_job for lics.lics_job;
