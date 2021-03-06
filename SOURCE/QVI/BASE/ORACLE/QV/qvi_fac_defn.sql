/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_fac_defn
 Owner  : qv

 Description
 -----------
 QlikView - Fact Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created
 2012/04   Mal Chambeyron Added Poll Flag

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_fac_defn
   (qfd_das_code                    varchar2(32)                  not null,
    qfd_fac_code                    varchar2(32)                  not null,
    qfd_fac_name                    varchar2(120 char)            not null,
    qfd_fac_status                  varchar2(1)                   not null,
    qfd_fac_build                   varchar2(120)                 not null,
    qfd_fac_table                   varchar2(120)                 not null,
    qfd_fac_type                    varchar2(120)                 not null,
    qfd_job_group                   varchar2(10 char)             not null,
    qfd_ema_group                   varchar2(64 char)             not null,
    qfd_pol_flag                    varchar2(1)                   not null,
    qfd_flg_iface                   varchar2(32 char),
    qfd_flg_mname                   varchar2(64 char),
    qfd_upd_user                    varchar2(30)                  not null,
    qfd_upd_date                    date                          not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_fac_defn is 'Fact Definition Table';
comment on column qv.qvi_fac_defn.qfd_das_code is 'Dashboard code';
comment on column qv.qvi_fac_defn.qfd_fac_code is 'Fact code';
comment on column qv.qvi_fac_defn.qfd_fac_name is 'Fact name';
comment on column qv.qvi_fac_defn.qfd_fac_status is 'Fact status (0=inactive or 1=active)';
comment on column qv.qvi_fac_defn.qfd_fac_build is 'Fact build procedure';
comment on column qv.qvi_fac_defn.qfd_fac_table is 'Fact pipelined table function';
comment on column qv.qvi_fac_defn.qfd_fac_type is 'Fact data type';
comment on column qv.qvi_fac_defn.qfd_job_group is 'Fact build job group';
comment on column qv.qvi_fac_defn.qfd_ema_group is 'Fact build email group';
comment on column qv.qvi_fac_defn.qfd_pol_flag is 'Polling Flag (0=even-driven, 1=polling)';
comment on column qv.qvi_fac_defn.qfd_flg_iface is 'Fact build flag file interface, required for even-driven';
comment on column qv.qvi_fac_defn.qfd_flg_mname is 'Fact build flag file message name, required for even-driven';
comment on column qv.qvi_fac_defn.qfd_upd_user is 'Last updated user';
comment on column qv.qvi_fac_defn.qfd_upd_date is 'Last updated date';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_fac_defn
   add constraint qvi_fac_defn_pk primary key (qfd_das_code, qfd_fac_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_fac_defn to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_fac_defn for qv.qvi_fac_defn;