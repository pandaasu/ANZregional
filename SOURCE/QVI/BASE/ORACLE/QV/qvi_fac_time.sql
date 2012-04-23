/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_fac_time
 Owner  : qv

 Description
 -----------
 QlikView - Fact Time Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_fac_time
   (qft_das_code                    varchar2(32)                  not null,
    qft_fac_code                    varchar2(32)                  not null,
    qft_tim_code                    varchar2(32)                  not null,
    qft_tim_status                  varchar2(1)                   not null,
    qft_upd_user                    varchar2(30)                  not null,
    qft_upd_date                    date                          not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_fac_time is 'Fact Time Table';
comment on column qv.qvi_fac_time.qft_das_code is 'Dashboard code';
comment on column qv.qvi_fac_time.qft_fac_code is 'Fact code';
comment on column qv.qvi_fac_time.qft_tim_code is 'Time code';
comment on column qv.qvi_fac_time.qft_tim_status is 'Time status (1=opened, 2=submitted, 3=completed)';
comment on column qv.qvi_fac_time.qft_upd_user is 'Last updated user';
comment on column qv.qvi_fac_time.qft_upd_date is 'Last updated date';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_fac_time
   add constraint qvi_fac_time_pk primary key (qft_das_code, qft_fac_code, qft_tim_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_fac_time to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_fac_time for qv.qvi_fac_time;