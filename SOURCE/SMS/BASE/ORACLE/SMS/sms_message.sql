/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_message
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Message Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_message
   (mes_msg_code                    varchar2(64 char)              not null,
    mes_msg_name                    varchar2(120 char)             not null,
    mes_status                      varchar2(1 char)               not null,
    mes_upd_user                    varchar2(30 char)              not null,
    mes_upd_date                    date                           not null,
    mes_qry_code                    varchar2(64 char)              not null);  

/**/
/* Comments
/**/
comment on table sms.sms_message is 'Message Table';
comment on column sms.sms_message.mes_msg_code is 'Message code';
comment on column sms.sms_message.mes_msg_name is 'Message name';
comment on column sms.sms_message.mes_status is 'Message status (0=inactive or 1=active)';
comment on column sms.sms_message.mes_upd_user is 'Message last updated user';
comment on column sms.sms_message.mes_upd_date is 'Message last updated date';
comment on column sms.sms_message.mes_qry_code is 'Query code';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_message
   add constraint sms_message_pk primary key (mes_msg_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_message to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_message for sms.sms_message;    