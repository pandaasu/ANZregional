/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_reso
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Resource Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_reso
   (psr_psc_code                    varchar2(32)                  not null,
    psr_psc_week                    varchar2(7)                   not null,
    psr_prd_type                    varchar2(32)                  not null,
    psr_lin_code                    varchar2(32)                  not null,
    psr_con_code                    varchar2(32)                  not null,
    psr_smo_seqn                    number                        not null,
    psr_res_code                    varchar2(32)                  not null,
    psr_res_qnty                    number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_reso is 'Production Schedule Resource Table';
comment on column psa.psa_psc_reso.psr_psc_code is 'Schedule code';
comment on column psa.psa_psc_reso.psr_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_reso.psr_prd_type is 'Production type code';
comment on column psa.psa_psc_reso.psr_lin_code is 'Line code';
comment on column psa.psa_psc_reso.psr_con_code is 'Line configuration code';
comment on column psa.psa_psc_reso.psr_smo_seqn is 'Shift model sequence';
comment on column psa.psa_psc_reso.psr_res_code is 'Resource code';
comment on column psa.psa_psc_reso.psr_res_qnty is 'Resource quantity';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_reso
   add constraint psa_psc_reso_pk primary key (psr_psc_code, psr_psc_week, psr_prd_type, psr_lin_code, psr_con_code, psr_smo_seqn, psr_res_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_reso to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_reso for psa.psa_psc_reso;