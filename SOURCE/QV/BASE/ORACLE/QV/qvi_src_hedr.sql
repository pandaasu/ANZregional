/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_src_hedr
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
create table qv.qvi_src_hedr
   (qsh_das_code                    varchar2(32)                  not null,
    qsh_fac_code                    varchar2(32)                  not null,
    qsh_tim_code                    varchar2(32)                  not null,
    qsh_par_code                    varchar2(32)                  not null,
    qsh_hdr_status                  varchar2(1)                   not null,
    qsh_str_date                    date                          not null,
    qsh_end_date                    date                          not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_src_hedr is 'Source Header Table';
comment on column qv.qvi_src_hedr.qsh_das_code is 'Dashboard code';
comment on column qv.qvi_src_hedr.qsh_fac_code is 'Fact code';
comment on column qv.qvi_src_hedr.qsh_tim_code is 'Time code';
comment on column qv.qvi_src_hedr.qsh_par_code is 'Part code';
comment on column qv.qvi_src_hedr.qsh_hdr_status is 'Header status (0=xxxx, 1=xxxx or 2=xxxx)';
comment on column qv.qvi_src_hedr.qsh_str_date is 'Load start date';
comment on column qv.qvi_src_hedr.qsh_end_date is 'Load end date';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_src_hedr
   add constraint qvi_src_hedr_pk primary key (qsh_das_code, qsh_fac_code, qsh_tim_code, qsh_par_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_src_hedr to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_src_hedr for qv.qvi_src_hedr;