/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_rpt_header
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Report Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_rpt_header
   (rhe_qry_code                    varchar2(64 char)             not null,
    rhe_rpt_date                    varchar2(8 char)              not null,
    rhe_rpt_yyyypp                  number(6,0)                   not null,
    rhe_rpt_yyyyppw                 number(7,0)                   not null,
    rhe_rpt_yyyyppdd                number(8,0)                   not null,
    rhe_crt_user                    varchar2(30 char)             not null,
    rhe_crt_date                    date                          not null,
    rhe_crt_yyyypp                  number(6,0)                   not null,
    rhe_crt_yyyyppw                 number(7,0)                   not null,
    rhe_crt_yyyyppdd                number(8,0)                   not null);

/**/
/* Comments
/**/
comment on table sms.sms_rpt_header is 'Report Header Table';
comment on column sms.sms_rpt_header.rhe_qry_code is 'Query code';
comment on column sms.sms_rpt_header.rhe_rpt_date is 'Report date';
comment on column sms.sms_rpt_header.rhe_rpt_yyyypp is 'Report Mars period';
comment on column sms.sms_rpt_header.rhe_rpt_yyyyppw is 'Report Mars week';
comment on column sms.sms_rpt_header.rhe_rpt_yyyyppdd is 'Report Mars day';
comment on column sms.sms_rpt_header.rhe_crt_user is 'creation user';
comment on column sms.sms_rpt_header.rhe_crt_date is 'creation timestamp';
comment on column sms.sms_rpt_header.rhe_crt_yyyypp is 'creation Mars period';
comment on column sms.sms_rpt_header.rhe_crt_yyyyppw is 'creation Mars week';
comment on column sms.sms_rpt_header.rhe_crt_yyyyppdd is 'creation Mars day';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_rpt_header
   add constraint sms_rpt_header_pk primary key (rhe_qry_code, rhe_rpt_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_rpt_header to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_rpt_header for sms.sms_rpt_header;    