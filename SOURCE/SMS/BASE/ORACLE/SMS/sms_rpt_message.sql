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
    rme_rpt_date                    varchar2(8 char)              not null,
    rme_msg_seqn                    number                        not null,
    rme_msg_data                    varchar2(2048 char)           not null,
    rme_msg_crt_time                date                          not null);  

/**/
/* Comments
/**/
comment on table sms.sms_rpt_message is 'Report Message Table';
comment on column sms.sms_rpt_message.rme_qry_code is 'Query code';
comment on column sms.sms_rpt_message.rme_rpt_date is 'Report date';
comment on column sms.sms_rpt_message.rme_msg_seqn is 'Message sequence';
comment on column sms.sms_rpt_message.rme_msg_data is 'Message data';
comment on column sms.sms_rpt_message.rme_msg_crt_time is 'Message create time';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_rpt_message
   add constraint sms_rpt_message_pk primary key (rme_qry_code, rme_rpt_date, rme_msg_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_rpt_message to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_rpt_message for sms.sms_rpt_message;    