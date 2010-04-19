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
    pss_prd_type                    varchar2(32)                  not null,
    pss_lin_code                    varchar2(32)                  not null,
    pss_con_code                    varchar2(32)                  not null,
    pss_smo_seqn                    number                        not null,
    pss_shf_code                    varchar2(32)                  not null,
    pss_shf_date                    date                          not null,
    pss_shf_start                   number                        not null,
    pss_shf_duration                number                        not null,
    pss_cmo_code                    varchar2(32)                  not null,
    pss_str_bar                     number                        not null,
    pss_end_bar                     number                        not null,
    pss_win_code                    varchar2(32)                  not null,
    pss_win_type                    varchar2(1)                   null,
    pss_win_stim                    date                          null,
    pss_win_etim                    date                          null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_shft is 'Production Schedule Shift Table';
comment on column psa.psa_psc_shft.pss_psc_code is 'Schedule code';
comment on column psa.psa_psc_shft.pss_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_shft.pss_prd_type is 'Production type code';
comment on column psa.psa_psc_shft.pss_lin_code is 'Line code';
comment on column psa.psa_psc_shft.pss_con_code is 'Line configuration code';
comment on column psa.psa_psc_shft.pss_smo_seqn is 'Shift model sequence';
comment on column psa.psa_psc_shft.pss_shf_code is 'Shift code';
comment on column psa.psa_psc_shft.pss_shf_date is 'Shift start date YYYY/MM/DD';
comment on column psa.psa_psc_shft.pss_shf_start is 'Shift start time HH24:MI';
comment on column psa.psa_psc_shft.pss_shf_duration is 'Shift duration minutes';
comment on column psa.psa_psc_shft.pss_cmo_code is 'Crew model code';
comment on column psa.psa_psc_shft.pss_str_bar is 'Shift start model bar';
comment on column psa.psa_psc_shft.pss_end_bar is 'Shift end model bar';
comment on column psa.psa_psc_shft.pss_win_code is 'Window code (spans one or more shifts)';
comment on column psa.psa_psc_shft.pss_win_type is 'Window type (0=none, 1=parent, 2=child)';
comment on column psa.psa_psc_shft.pss_win_stim is 'Window start time YYYYMMDDHH24MI';
comment on column psa.psa_psc_shft.pss_win_etim is 'Window end time YYYYMMDDHH24MI';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_shft
   add constraint psa_psc_shft_pk primary key (pss_psc_code, pss_psc_week, pss_prd_type, pss_lin_code, pss_con_code, pss_smo_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_shft to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_shft for psa.psa_psc_shft;