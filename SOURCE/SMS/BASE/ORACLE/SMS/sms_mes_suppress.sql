/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_mes_suppress
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Message Suppress Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_mes_suppress
   (msu_msg_code                    varchar2(64 char)              not null,
    msu_dim_code                    varchar2(256 char)             not null,
    msu_dim_valu                    varchar2(256 char)             not null,
    msu_sup_total                   varchar2(1 char)               not null);  

/**/
/* Comments
/**/
comment on table sms.sms_mes_suppress is 'Message Suppress Table';
comment on column sms.sms_mes_suppress.msu_msg_code is 'Message code';
comment on column sms.sms_mes_suppress.msu_dim_code is 'Dimension code';
comment on column sms.sms_mes_suppress.msu_dim_valu is 'Dimension value';
comment on column sms.sms_mes_suppress.msu_sup_total is 'Suppress total (0=no or 1=yes)';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_mes_suppress
   add constraint sms_mes_suppress_pk primary key (msu_msg_code, msu_dim_code, msu_dim_valu);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_mes_suppress to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_mes_suppress for sms.sms_mes_suppress;    