/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_prd_type
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_prd_type
   (pty_prd_type                    varchar2(32)                  not null,
    pty_prd_name                    varchar2(120 char)            not null,
    pty_prd_status                  varchar2(1)                   not null,
    pty_prd_mat_usage               varchar2(1)                   not null,
    pty_prd_lin_usage               varchar2(1)                   not null,
    pty_prd_run_usage               varchar2(1)                   not null,
    pty_prd_res_usage               varchar2(1)                   not null,
    pty_prd_cre_usage               varchar2(1)                   not null,
    pty_prd_act_usage               varchar2(1)                   not null,
    pty_prd_lin_wastage             varchar2(1)                   not null,
    pty_prd_lin_filler              varchar2(1)                   not null,
    pty_prd_run_efficiency          varchar2(1)                   not null,
    pty_prd_run_wastage             varchar2(1)                   not null,
    pty_prd_run_value               varchar2(30)                  not null,
    pty_prd_act_value               varchar2(30)                  not null,
    pty_upd_user                    varchar2(30)                  not null,
    pty_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_prd_type is 'Production Type Table';
comment on column psa.psa_prd_type.pty_prd_type is 'Production type code';
comment on column psa.psa_prd_type.pty_prd_name is 'Production type name';
comment on column psa.psa_prd_type.pty_prd_status is 'Production type status (0=inactive or 1=active)';
comment on column psa.psa_prd_type.pty_prd_mat_usage is 'Production type material usage';
comment on column psa.psa_prd_type.pty_prd_lin_usage is 'Production type line usage';
comment on column psa.psa_prd_type.pty_prd_run_usage is 'Production type run rate usage';
comment on column psa.psa_prd_type.pty_prd_res_usage is 'Production type resource usage';
comment on column psa.psa_prd_type.pty_prd_cre_usage is 'Production type crew usage';
comment on column psa.psa_prd_type.pty_prd_act_usage is 'Production type actuals usage';
comment on column psa.psa_prd_type.pty_prd_lin_wastage is 'Production type line wastage required';
comment on column psa.psa_prd_type.pty_prd_lin_filler is 'Production type line filler required';
comment on column psa.psa_prd_type.pty_prd_run_efficiency is 'Production type run rate efficiency required';
comment on column psa.psa_prd_type.pty_prd_run_wastage is 'Production type run rate wastage required';
comment on column psa.psa_prd_type.pty_prd_run_value is 'Production type run rate value type';
comment on column psa.psa_prd_type.pty_prd_act_value is 'Production type actuals value type';
comment on column psa.psa_prd_type.pty_upd_user is 'Last updated user';
comment on column psa.psa_prd_type.pty_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_prd_type
   add constraint psa_prd_type_pk primary key (pty_prd_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_prd_type to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_prd_type for psa.psa_prd_type;