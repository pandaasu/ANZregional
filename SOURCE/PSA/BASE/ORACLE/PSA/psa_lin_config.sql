/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_lin_config
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production line Configuration Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_lin_config
   (lco_lin_code                    varchar2(32)                  not null,
    lco_con_code                    varchar2(32)                  not null,
    lco_con_name                    varchar2(120 char)            not null,
    lco_con_status                  varchar2(1)                   not null,
    lco_upd_user                    varchar2(30)                  not null,
    lco_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_lin_config is 'Production line Configuration Table';
comment on column psa.psa_lin_config.lco_lin_code is 'Line code';
comment on column psa.psa_lin_config.lco_con_code is 'Line configuration code';
comment on column psa.psa_lin_config.lco_con_name is 'Line configuration name';
comment on column psa.psa_lin_config.lco_con_status is 'Line configuration status (0=inactive or 1=active)';
comment on column psa.psa_lin_config.lco_upd_user is 'Line configuration last updated user';
comment on column psa.psa_lin_config.lco_upd_date is 'Line configuration last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_lin_config
   add constraint psa_lin_config_pk primary key (lco_lin_code, lco_con_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_lin_config to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_lin_config for psa.psa_lin_config;