/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_rpt_recipient
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Report Recipient Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_rpt_recipient
   (rre_qry_code                    varchar2(64 char)             not null,
    rre_qry_date                    varchar2(14 char)             not null,
    rre_exe_seqn                    number                        not null,
    rre_msg_seqn                    number                        not null,
    rre_rcp_code                    varchar2(64 char)             not null,
    rre_rcp_name                    varchar2(120 char)            not null,
    rre_rcp_mobile                  varchar2(64 char)             not null,
    rre_rcp_email                   varchar2(128 char)            not null);  

/**/
/* Comments
/**/
comment on table sms.sms_rpt_recipient is 'Report Recipient Table';
comment on column sms.sms_rpt_recipient.rre_qry_code is 'Query code';
comment on column sms.sms_rpt_recipient.rre_qry_date is 'Query timestamp';
comment on column sms.sms_rpt_recipient.rre_exe_seqn is 'Generation sequence';
comment on column sms.sms_rpt_recipient.rre_msg_seqn is 'Message sequence';
comment on column sms.sms_rpt_recipient.rre_rcp_code is 'Recipient code';
comment on column sms.sms_rpt_recipient.rre_rcp_name is 'Recipient name';
comment on column sms.sms_rpt_recipient.rre_rcp_mobile is 'Recipient mobile phone number';
comment on column sms.sms_rpt_recipient.rre_rcp_email is 'Recipient email address (*NONE)';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_rpt_recipient
   add constraint sms_rpt_recipient_pk primary key (rre_qry_code, rre_qry_date, rre_exe_seqn, rre_msg_seqn, rre_rcp_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_rpt_recipient to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_rpt_recipient for sms.sms_rpt_recipient;    