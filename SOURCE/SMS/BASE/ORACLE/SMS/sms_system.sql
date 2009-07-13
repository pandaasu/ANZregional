/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_system
 Owner  : sms

 Description
 -----------
 SMS Reporting System - System Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_system
   (sys_code                        varchar2(64 char)             not null,
    sys_value                       varchar2(256 char)            not null,
    sys_upd_user                    varchar2(30 char)             not null,
    sys_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table sms.sms_system is 'System Table';
comment on column sms.sms_system.sys_code is 'System code';
comment on column sms.sms_system.sys_value is 'System value';
comment on column sms.sms_system.sys_upd_user is 'System last updated user';
comment on column sms.sms_system.sys_upd_date is 'System last updated date';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_system
   add constraint sms_system_pk primary key (sys_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_system to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_system for sms.sms_system;    