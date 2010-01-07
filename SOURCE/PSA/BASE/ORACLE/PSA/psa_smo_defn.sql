/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_smo_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Shift Model Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_smo_defn
   (smd_smo_code                    varchar2(32)                  not null,
    smd_smo_name                    varchar2(120 char)            not null,
    smd_smo_status                  varchar2(1)                   not null,
    smd_upd_user                    varchar2(30)                  not null,
    smd_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_smo_defn is 'Shift Model Definition Table';
comment on column psa.psa_smo_defn.smd_smo_code is 'Shift model code';
comment on column psa.psa_smo_defn.smd_smo_name is 'Shift model name';
comment on column psa.psa_smo_defn.smd_smo_status is 'Shift model status (0=inactive or 1=active)';
comment on column psa.psa_smo_defn.smd_upd_user is 'Last updated user';
comment on column psa.psa_smo_defn.smd_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_smo_defn
   add constraint psa_smo_defn_pk primary key (smd_smo_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_smo_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_smo_defn for psa.psa_smo_defn;