/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_pro_message
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Profile Message Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_pro_message
   (pme_prf_code                    varchar2(64 char)              not null,
    pme_msg_code                    varchar2(64 char)              not null);

/**/
/* Comments
/**/
comment on table sms.sms_pro_message is 'Profile Message Table';
comment on column sms.sms_pro_message.pme_prf_code is 'Profile code';
comment on column sms.sms_pro_message.pme_msg_code is 'Message code';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_pro_message
   add constraint sms_pro_message_pk primary key (pme_prf_code, pme_msg_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_pro_message to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_pro_message for sms.sms_pro_message;    