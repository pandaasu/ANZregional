/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : qvi_dim_defn
 Owner  : qv

 Description
 -----------
 QlikView - Dimension Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2012/03   Steve Gregan   Created
 2012/04   Mal Chambeyron Added Update Sequence and Poll Flag

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table qv.qvi_dim_defn
   (qdd_dim_code                    varchar2(32)                  not null,
    qdd_dim_name                    varchar2(120 char)            not null,
    qdd_dim_status                  varchar2(1)                   not null,
    qdd_dim_table                   varchar2(120)                 not null,
    qdd_dim_type                    varchar2(120)                 not null,
    qdd_lod_status                  varchar2(1)                   not null,
    qdd_pol_flag                    varchar2(1)                   not null,
    qdd_flg_iface                   varchar2(32 char),
    qdd_flg_mname                   varchar2(64 char),
    qdd_upd_seqn                    number(15)                    not null,
    qdd_str_date                    date                          not null,
    qdd_end_date                    date                          not null,
    qdd_upd_user                    varchar2(30)                  not null,
    qdd_upd_date                    date                          not null);

/*-*/
/* Comments
/*-*/
comment on table qv.qvi_dim_defn is 'Dimension Definition Table';
comment on column qv.qvi_dim_defn.qdd_dim_code is 'Dimension code';
comment on column qv.qvi_dim_defn.qdd_dim_name is 'Fact name';
comment on column qv.qvi_dim_defn.qdd_dim_status is 'Dimension status (0=inactive or 1=active)';
comment on column qv.qvi_dim_defn.qdd_dim_table is 'Dimension pipelined table function';
comment on column qv.qvi_dim_defn.qdd_dim_type is 'Dimension data type';
comment on column qv.qvi_dim_defn.qdd_lod_status is 'Load status (0=empty, 1=loading or 2=loaded)';
comment on column qv.qvi_dim_defn.qdd_pol_flag is 'Polling Flag (0=even-driven, 1=polling)';
comment on column qv.qvi_dim_defn.qdd_flg_iface is 'Dimension flag file interface, required for even-driven';
comment on column qv.qvi_dim_defn.qdd_flg_mname is 'Dimension flag file message name, required for even-driven';
comment on column qv.qvi_dim_defn.qdd_upd_seqn is 'Update sequence, common across facts and dimensions, updated on dimension data finalise';
comment on column qv.qvi_dim_defn.qdd_str_date is 'Load start date';
comment on column qv.qvi_dim_defn.qdd_end_date is 'Load end date';
comment on column qv.qvi_dim_defn.qdd_upd_user is 'Last updated user';
comment on column qv.qvi_dim_defn.qdd_upd_date is 'Last updated date';

/*-*/
/* Primary Key Constraint
/*-*/
alter table qv.qvi_dim_defn
   add constraint qvi_dim_defn_pk primary key (qdd_dim_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on qv.qvi_dim_defn to qv_app;

/*-*/
/* Synonym
/*-*/
create or replace public synonym qvi_dim_defn for qv.qvi_dim_defn;