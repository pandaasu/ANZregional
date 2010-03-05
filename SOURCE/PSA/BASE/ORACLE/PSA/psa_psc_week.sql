/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_week
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Week Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_week
   (psw_psc_code                    varchar2(32)                  not null,
    psw_psc_week                    varchar2(7)                   not null,
    psw_smo_code                    varchar2(32)                  not null,
    psw_req_code                    varchar2(32)                  not null,
    psw_upd_user                    varchar2(30)                  not null,
    psw_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_week is 'Production Schedule Week Table';
comment on column psa.psa_psc_week.psw_psc_code is 'Schedule code';
comment on column psa.psa_psc_week.psw_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_week.psw_smo_code is 'Shift model code';
comment on column psa.psa_psc_week.psw_req_code is 'Requirement code';
comment on column psa.psa_psc_week.psw_upd_user is 'Last updated user';
comment on column psa.psa_psc_week.psw_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_week
   add constraint psa_psc_week_pk primary key (psw_psc_code, psw_psc_week);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_week to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_week for psa.psa_psc_week;