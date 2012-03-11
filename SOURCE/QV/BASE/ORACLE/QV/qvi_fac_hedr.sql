/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_fac_hedr
 Owner  : qv

 Description
 -----------
 QlikView - Source Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_fac_hedr
   (qfh_das_code                    varchar2(32)                  not null,
    qfh_fac_code                    varchar2(32)                  not null,
    qfh_tim_code                    varchar2(32)                  not null,
    qfh_hdr_status                  varchar2(1)                   not null,
    qfh_str_date                    date                          not null,
    qfh_end_date                    date                          not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_fac_hedr is 'Fact Header Table';
comment on column qv.qvi_fac_hedr.qfh_das_code is 'Dashboard code';
comment on column qv.qvi_fac_hedr.qfh_fac_code is 'Fact code';
comment on column qv.qvi_fac_hedr.qfh_tim_code is 'Time code';
comment on column qv.qvi_fac_hedr.qfh_hdr_status is 'Header status (0=xxxx, 1=xxxx or 2=xxxx)';
comment on column qv.qvi_fac_hedr.qfh_str_date is 'Build start date';
comment on column qv.qvi_fac_hedr.qfh_end_date is 'Build end date';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_fac_hedr
   add constraint qvi_fac_hedr_pk primary key (qfh_das_code, qfh_fac_code, qfh_tim_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_fac_hedr to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_fac_hedr for qv.qvi_fac_hedr;