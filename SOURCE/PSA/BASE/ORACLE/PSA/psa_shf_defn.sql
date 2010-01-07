/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_shf_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Shift Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_shf_defn
   (sde_shf_code                    varchar2(32)                  not null,
    sde_shf_name                    varchar2(120 char)            not null,
    sde_shf_start                   number                        not null,
    sde_shf_duration                number                        not null,
    sde_shf_status                  varchar2(1)                   not null,
    sde_upd_user                    varchar2(30)                  not null,
    sde_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_shf_defn is 'Shift Definition Table';
comment on column psa.psa_shf_defn.sde_shf_code is 'Shift code';
comment on column psa.psa_shf_defn.sde_shf_name is 'Shift name';
comment on column psa.psa_shf_defn.sde_shf_start is 'Shift start time HH24:MI';
comment on column psa.psa_shf_defn.sde_shf_duration is 'Shift duration minutes';
comment on column psa.psa_shf_defn.sde_shf_status is 'Shift status (0=inactive or 1=active)';
comment on column psa.psa_shf_defn.sde_upd_user is 'Last updated user';
comment on column psa.psa_shf_defn.sde_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_shf_defn
   add constraint psa_shf_defn_pk primary key (sde_shf_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_shf_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_shf_defn for psa.psa_shf_defn;