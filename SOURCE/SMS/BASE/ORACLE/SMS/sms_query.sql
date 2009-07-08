/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_query
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Query Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_query
   (que_qry_code                    varchar2(64 char)             not null,
    que_qry_name                    varchar2(120 char)            not null,
    que_status                      varchar2(1 char)              not null,
    que_upd_user                    varchar2(30 char)             not null,
    que_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table sms.sms_query is 'Query Table';
comment on column sms.sms_query.que_qry_code is 'Query code';
comment on column sms.sms_query.que_qry_name is 'Query name';
comment on column sms.sms_query.que_status is 'Query status (0=inactive or 1=active)';
comment on column sms.sms_query.que_upd_user is 'Query last updated user';
comment on column sms.sms_query.que_upd_date is 'Query last updated date';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_query
   add constraint sms_query_pk primary key (que_qry_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_query to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_query for sms.sms_query;    