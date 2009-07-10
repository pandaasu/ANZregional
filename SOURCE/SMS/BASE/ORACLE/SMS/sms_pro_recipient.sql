/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_pro_recipient
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Profile Recipient Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_pro_recipient
   (pre_prf_code                    varchar2(64 char)              not null,
    pre_rcp_code                    varchar2(64 char)              not null);

/**/
/* Comments
/**/
comment on table sms.sms_pro_recipient is 'Profile Recipient Table';
comment on column sms.sms_pro_recipient.pre_prf_code is 'Profile code';
comment on column sms.sms_pro_recipient.pre_rcp_code is 'Recipient code';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_pro_recipient
   add constraint sms_pro_recipient_pk primary key (pre_prf_code, pre_rcp_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_pro_recipient to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_pro_recipient for sms.sms_pro_recipient;    