/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_hedr
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_hedr
   (psh_psc_code                    varchar2(32)                  not null,
    psh_psc_name                    varchar2(120 char)            not null,
    psh_psc_status                  varchar2(10)                  not null,
    psh_upd_user                    varchar2(30)                  not null,
    psh_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_hedr is 'Production Schedule Header Table';
comment on column psa.psa_psc_hedr.psh_psc_code is 'Schedule code';
comment on column psa.psa_psc_hedr.psh_psc_name is 'Schedule name';
comment on column psa.psa_psc_hedr.psh_psc_status is 'Schedule status - *ACTIVE or *WORK';
comment on column psa.psa_psc_hedr.psh_upd_user is 'Last updated user';
comment on column psa.psa_psc_hedr.psh_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_hedr
   add constraint psa_psc_hedr_pk primary key (psh_psc_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_hedr to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_hedr for psa.psa_psc_hedr;