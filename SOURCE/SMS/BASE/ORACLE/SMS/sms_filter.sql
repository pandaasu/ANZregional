/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sms_filter
 Owner  : sms

 Description
 -----------
 SMS Reporting System - Filter Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/07   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sms.sms_filter
   (fil_flt_code                    varchar2(64 char)              not null,
    fil_flt_name                    varchar2(120 char)             not null,
    fil_status                      varchar2(1 char)               not null,
    fil_upd_user                    varchar2(30 char)              not null,
    fil_upd_date                    date                           not null,
    fil_qry_code                    varchar2(64 char)              not null,
    fil_dim_val01                   varchar2(256 char)             null,
    fil_dim_val02                   varchar2(256 char)             null,
    fil_dim_val03                   varchar2(256 char)             null,
    fil_dim_val04                   varchar2(256 char)             null,
    fil_dim_val05                   varchar2(256 char)             null,
    fil_dim_val06                   varchar2(256 char)             null,
    fil_dim_val07                   varchar2(256 char)             null,
    fil_dim_val08                   varchar2(256 char)             null,
    fil_dim_val09                   varchar2(256 char)             null);

/**/
/* Comments
/**/
comment on table sms.sms_filter is 'Filter Table';
comment on column sms.sms_filter.fil_flt_code is 'Filter code';
comment on column sms.sms_filter.fil_flt_name is 'Filter name';
comment on column sms.sms_filter.fil_status is 'Filter status (0=inactive or 1=active)';
comment on column sms.sms_filter.fil_upd_user is 'Filter last updated user';
comment on column sms.sms_filter.fil_upd_date is 'Filter last updated date';
comment on column sms.sms_filter.fil_qry_code is 'Query code';
comment on column sms.sms_filter.fil_dim_val01 is 'Dimension 01 value';
comment on column sms.sms_filter.fil_dim_val02 is 'Dimension 02 value';
comment on column sms.sms_filter.fil_dim_val03 is 'Dimension 03 value';
comment on column sms.sms_filter.fil_dim_val04 is 'Dimension 04 value';
comment on column sms.sms_filter.fil_dim_val05 is 'Dimension 05 value';
comment on column sms.sms_filter.fil_dim_val06 is 'Dimension 06 value';
comment on column sms.sms_filter.fil_dim_val07 is 'Dimension 07 value';
comment on column sms.sms_filter.fil_dim_val08 is 'Dimension 08 value';
comment on column sms.sms_filter.fil_dim_val09 is 'Dimension 09 value';

/**/
/* Primary Key Constraint
/**/
alter table sms.sms_filter
   add constraint sms_filter_pk primary key (fil_flt_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on sms.sms_filter to sms_app;

/**/
/* Synonym
/**/
create or replace public synonym sms_filter for sms.sms_filter;    