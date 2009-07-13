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
    que_upd_date                    date                          not null,
    que_ema_subject                 varchar2(64 char)             not null,
    que_rcv_day01                   varchar2(1 char)              not null,
    que_rcv_day02                   varchar2(1 char)              not null,
    que_rcv_day03                   varchar2(1 char)              not null,
    que_rcv_day04                   varchar2(1 char)              not null,
    que_rcv_day05                   varchar2(1 char)              not null,
    que_rcv_day06                   varchar2(1 char)              not null,
    que_rcv_day07                   varchar2(1 char)              not null,
    que_dim_depth                   number                        not null,
    que_dim_cod01                   varchar2(256 char)            null,
    que_dim_cod02                   varchar2(256 char)            null,
    que_dim_cod03                   varchar2(256 char)            null,
    que_dim_cod04                   varchar2(256 char)            null,
    que_dim_cod05                   varchar2(256 char)            null,
    que_dim_cod06                   varchar2(256 char)            null,
    que_dim_cod07                   varchar2(256 char)            null,
    que_dim_cod08                   varchar2(256 char)            null,
    que_dim_cod09                   varchar2(256 char)            null);

/**/
/* Comments
/**/
comment on table sms.sms_query is 'Query Table';
comment on column sms.sms_query.que_qry_code is 'Query code';
comment on column sms.sms_query.que_qry_name is 'Query name';
comment on column sms.sms_query.que_status is 'Query status (0=inactive or 1=active)';
comment on column sms.sms_query.que_upd_user is 'Query last updated user';
comment on column sms.sms_query.que_upd_date is 'Query last updated date';
comment on column sms.sms_query.que_ema_subject is 'Query SMS email subject';
comment on column sms.sms_query.que_rcv_day01 is 'Receive query sunday (0=no or 1=yes)';
comment on column sms.sms_query.que_rcv_day02 is 'Receive query monday (0=no or 1=yes)';
comment on column sms.sms_query.que_rcv_day03 is 'Receive query tuesday (0=no or 1=yes)';
comment on column sms.sms_query.que_rcv_day04 is 'Receive query wednesday (0=no or 1=yes)';
comment on column sms.sms_query.que_rcv_day05 is 'Receive query thursday (0=no or 1=yes)';
comment on column sms.sms_query.que_rcv_day06 is 'Receive query friday (0=no or 1=yes)';
comment on column sms.sms_query.que_rcv_day07 is 'Receive query saturday (0=no or 1=yes)';
comment on column sms.sms_query.que_dim_depth is 'Query dimension depth';
comment on column sms.sms_query.que_dim_cod01 is 'Dimension 01 code';
comment on column sms.sms_query.que_dim_cod02 is 'Dimension 02 code';
comment on column sms.sms_query.que_dim_cod03 is 'Dimension 03 code';
comment on column sms.sms_query.que_dim_cod04 is 'Dimension 04 code';
comment on column sms.sms_query.que_dim_cod05 is 'Dimension 05 code';
comment on column sms.sms_query.que_dim_cod06 is 'Dimension 06 code';
comment on column sms.sms_query.que_dim_cod07 is 'Dimension 07 code';
comment on column sms.sms_query.que_dim_cod08 is 'Dimension 08 code';
comment on column sms.sms_query.que_dim_cod09 is 'Dimension 09 code';

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