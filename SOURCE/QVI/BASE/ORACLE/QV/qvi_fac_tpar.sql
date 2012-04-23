/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_fac_tpar
 Owner  : qv

 Description
 -----------
 QlikView - Fact Time Part Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_fac_tpar
   (qft_das_code                    varchar2(32)                  not null,
    qft_fac_code                    varchar2(32)                  not null,
    qft_tim_code                    varchar2(32)                  not null,
    qft_par_code                    varchar2(32)                  not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_fac_tpar is 'Fact Time Part Table';
comment on column qv.qvi_fac_tpar.qft_das_code is 'Dashboard code';
comment on column qv.qvi_fac_tpar.qft_fac_code is 'Fact code';
comment on column qv.qvi_fac_tpar.qft_tim_code is 'Time code';
comment on column qv.qvi_fac_tpar.qft_par_code is 'Part code';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_fac_tpar
   add constraint qvi_fac_tpar_pk primary key (qft_das_code, qft_fac_code, qft_tim_code, qft_par_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_fac_tpar to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_fac_tpar for qv.qvi_fac_tpar;