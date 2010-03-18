/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_line
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Line Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_line
   (psl_psc_code                    varchar2(32)                  not null,
    psl_psc_week                    varchar2(7)                   not null,
    psl_prd_type                    varchar2(32)                  not null,
    psl_lin_code                    varchar2(32)                  not null,
    psl_con_code                    varchar2(32)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_line is 'Production Schedule Line Table';
comment on column psa.psa_psc_line.psl_psc_code is 'Schedule code';
comment on column psa.psa_psc_line.psl_psc_week is 'Schedule MARS week';
comment on column psa.psa_psc_line.psl_prd_type is 'Production type code';
comment on column psa.psa_psc_line.psl_lin_code is 'Line code';
comment on column psa.psa_psc_line.psl_con_code is 'Line configuration code';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_line
   add constraint psa_psc_line_pk primary key (psl_psc_code, psl_psc_week, psl_prd_type, psl_lin_code, psl_con_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_line to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_line for psa.psa_psc_line;