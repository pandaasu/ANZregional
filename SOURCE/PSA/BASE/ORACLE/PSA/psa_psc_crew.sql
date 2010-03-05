/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_crew
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Crew Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_crew
   (psc_psc_code                    varchar2(32)                  not null,
    psc_psc_week                    varchar2(7)                   not null,
    psc_prd_type                    varchar2(32)                  not null,
    psc_shf_code                    varchar2(32)                  not null,
    psc_cmo_code                    varchar2(32)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_crew is 'Production Schedule Crew Table';
comment on column psa.psa_psc_crew.psc_psc_code is 'Schedule code';
comment on column psa.psa_psc_crew.psc_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_crew.psc_prd_type is 'Production type code';
comment on column psa.psa_psc_crew.psc_shf_code is 'Shift code';
comment on column psa.psa_psc_crew.psc_cmo_code is 'Crew model code';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_crew
   add constraint psa_psc_crew_pk primary key (psc_psc_code, psc_psc_week, psc_prd_type, psc_shf_code, psc_cmo_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_crew to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_crew for psa.psa_psc_crew;