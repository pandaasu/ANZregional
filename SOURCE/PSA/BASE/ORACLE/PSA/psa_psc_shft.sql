/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_shft
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Shift Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_shft
   (pss_psc_code                    varchar2(32)                  not null,
    pss_psc_week                    varchar2(7)                   not null,
    pss_smo_seqn                    number                        not null,
    pss_shf_code                    varchar2(32)                  not null,
    pss_shf_start                   number                        not null,
    pss_shf_duration                number                        not null,
    pss_cmo_code                    varchar2(32)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_shft is 'Production Schedule Shift Table';
comment on column psa.psa_psc_shft.pss_psc_code is 'Schedule code';
comment on column psa.psa_psc_shft.pss_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_shft.pss_smo_seqn is 'Shift model sequence';
comment on column psa.psa_psc_shft.pss_shf_code is 'Shift code';
comment on column psa.psa_psc_shft.pss_shf_start is 'Shift start time HH24:MI';
comment on column psa.psa_psc_shft.pss_shf_duration is 'Shift duration minutes';
comment on column psa.psa_psc_shft.pss_cmo_code is 'Crew model code';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_shft
   add constraint psa_psc_shft_pk primary key (pss_psc_code, pss_psc_week, pss_smo_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_shft to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_shft for psa.psa_psc_shft;