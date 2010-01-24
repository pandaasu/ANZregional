/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_lin_rate
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production line Configuration Run Rate Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_lin_rate
   (lra_lin_code                    varchar2(32)                  not null,
    lra_con_code                    varchar2(32)                  not null,
    lra_rra_code                    varchar2(32)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_lin_rate is 'Production line Configuration Run Rate Table';
comment on column psa.psa_lin_rate.lra_lin_code is 'Line code';
comment on column psa.psa_lin_rate_lra_con_code is 'Line configuration code';
comment on column psa.psa_lin_rate_lra_rra_code is 'Run rate code';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_lin_rate
   add constraint psa_lin_rate_pk primary key (lra_lin_code, lra_con_code, lra_rra_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_lin_rate to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_lin_rate for psa.psa_lin_rate;