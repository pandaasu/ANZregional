/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_rpt_execution
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Report Execution Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_rpt_execution
   (rex_qry_code                    varchar2(64 char)             not null,
    rex_qry_date                    varchar2(14 char)             not null,
    rex_exe_seqn                    number                        not null,
    rex_exe_user                    varchar2(30 char)             not null,
    rex_exe_date                    date                          not null,
    rex_status                      varchar2(1 char)              not null);  

/**/
/* Comments
/**/
comment on table sms.sms_rpt_execution is 'Report Execution Table';
comment on column sms.sms_rpt_execution.rex_qry_code is 'Query code';
comment on column sms.sms_rpt_execution.rex_qry_date is 'Query timestamp';
comment on column sms.sms_rpt_execution.rex_gen_seqn is 'Execution sequence';
comment on column sms.sms_rpt_execution.rex_upd_user is 'Execution user';
comment on column sms.sms_rpt_execution.rex_upd_date is 'Execution date';
comment on column sms.sms_rpt_execution.rex_status is 'Execution status (1=loaded or 2=processed or 3=resend or 4=stopped)';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_rpt_execution
   add constraint sms_rpt_execution_pk primary key (rex_qry_code, rex_qry_date, rex_exe_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_rpt_execution to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_rpt_execution for sms.sms_rpt_execution;    