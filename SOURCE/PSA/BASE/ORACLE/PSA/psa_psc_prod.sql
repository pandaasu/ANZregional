/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_prod
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Production Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_prod
   (psp_psc_code                    varchar2(32)                  not null,
    psp_psc_week                    varchar2(7)                   not null,
    psp_prd_type                    varchar2(32)                  not null,
    psp_upd_user                    varchar2(30)                  not null,
    psp_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_prod is 'Production Schedule Production Type Table';
comment on column psa.psa_psc_prod.psp_psc_code is 'Schedule code';
comment on column psa.psa_psc_prod.psp_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_prod.psp_prd_type is 'Production type code';
comment on column psa.psa_psc_prod.psp_upd_user is 'Last updated user';
comment on column psa.psa_psc_prod.psp_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_prod
   add constraint psa_psc_prod_pk primary key (psp_psc_code, psp_psc_week, psp_prd_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_prod to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_prod for psa.psa_psc_prod;