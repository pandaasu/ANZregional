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
    rre_rpt_date                    varchar2(8 char)              not null,
    rre_msg_seqn                    number                        not null,
    rre_rcp_code                    varchar2(64 char)             not null,
    rre_rcp_mobile                  varchar2(64 char)             not null,
    rre_rcp_email                   varchar2(128 char)            not null,
    rre_rcp_snd_time                date                          not null);  

/**/
/* Comments
/**/
comment on table sms.sms_rpt_recipient is 'Report Recipient Table';
comment on column sms.sms_rpt_recipient.rre_qry_code is 'Query code';
comment on column sms.sms_rpt_recipient.rre_rpt_date is 'Report date';
comment on column sms.sms_rpt_recipient.rre_msg_seqn is 'Message sequence';
comment on column sms.sms_rpt_recipient.rre_rcp_code is 'Recipient code';
comment on column sms.sms_rpt_recipient.rre_rcp_mobile is 'Recipient mobile phone number';
comment on column sms.sms_rpt_recipient.rre_rcp_email is 'Recipient email address (*NONE)';
comment on column sms.sms_rpt_recipient.rre_rcp_snd_time is 'Recipient message send time';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_rpt_recipient
   add constraint sms_rpt_recipient_pk primary key (rre_qry_code, rre_rpt_date, rre_mes_seqn, rre_rcp_name);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_rpt_recipient to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_rpt_recipient for sms.sms_rpt_recipient;    