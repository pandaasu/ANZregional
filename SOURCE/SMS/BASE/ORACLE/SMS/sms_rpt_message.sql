/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_rpt_message
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Report Message Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_rpt_message
   (rme_qry_code                    varchar2(64 char)             not null,
    rme_qry_date                    varchar2(14 char)             not null,
    rme_exe_seqn                    number                        not null,
    rme_msg_seqn                    number                        not null,
    rme_msg_text                    varchar2(2000 char)           not null,
    rme_msg_time                    date                          not null,
    rme_msg_status                  varchar2(1 char)              not null,
    rme_prf_code                    varchar2(64 char)             not null,
    rme_msg_code                    varchar2(64 char)             not null,
    rme_flt_code                    varchar2(64 char)             not null);  

/**/
/* Comments
/**/
comment on table sms.sms_rpt_message is 'Report Message Table';
comment on column sms.sms_rpt_message.rme_qry_code is 'Query code';
comment on column sms.sms_rpt_message.rme_qry_date is 'Query timestamp';
comment on column sms.sms_rpt_message.rme_exe_seqn is 'Generation sequence';
comment on column sms.sms_rpt_message.rme_msg_seqn is 'Message sequence';
comment on column sms.sms_rpt_message.rme_msg_text is 'Message text';
comment on column sms.sms_rpt_message.rme_msg_time is 'Message create time';
comment on column sms.sms_rpt_message.rme_msg_status is 'Message status (1=created or 2=sent or 3=error)';
comment on column sms.sms_rpt_message.rme_prf_code is 'Profile code';
comment on column sms.sms_rpt_message.rme_msg_code is 'Message code';
comment on column sms.sms_rpt_message.rme_flt_code is 'Filter code';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_rpt_message
   add constraint sms_rpt_message_pk primary key (rme_qry_code, rme_qry_date, rme_exe_seqn, rme_msg_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_rpt_message to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_rpt_message for sms.sms_rpt_message;    