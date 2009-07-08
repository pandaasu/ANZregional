/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_recipient
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Recipient Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_recipient
   (rec_rcp_code                    varchar2(64 char)             not null,
    rec_rcp_name                    varchar2(120 char)            not null,
    rec_rcp_mobile                  varchar2(64 char)             not null,
    rec_rcp_email                   varchar2(128 char)            not null,
    rec_status                      varchar2(1 char)              not null,
    rec_upd_user                    varchar2(30 char)             not null,
    rec_upd_date                    date                          not null);  

/**/
/* Comments
/**/
comment on table sms.sms_recipient is 'Recipient Table';
comment on column sms.sms_recipient.rec_rcp_code is 'Recipient code';
comment on column sms.sms_recipient.rec_rcp_name is 'Recipient name';
comment on column sms.sms_recipient.rec_rcp_mobile is 'Recipient mobile number';
comment on column sms.sms_recipient.rec_rcp_email is 'Recipient email address';
comment on column sms.sms_recipient.rec_status is 'Recipient status (0=inactive or 1=active)';
comment on column sms.sms_recipient.rec_upd_user is 'Recipient last updated user';
comment on column sms.sms_recipient.rec_upd_date is 'Recipient last updated date';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_recipient
   add constraint sms_recipient_pk primary key (rec_rcp_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_recipient to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_recipient for sms.sms_recipient;    