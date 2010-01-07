/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_smo_shift
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Shift Model Shift Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_smo_shift
   (sms_smo_code                    varchar2(32)                  not null,
    sms_smo_seqn                    number                        not null,
    sms_shf_code                    varchar2(32)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_smo_shift is 'Shift Model Shift Table';
comment on column psa.psa_smo_shift.sms_smo_code is 'Shift model code';
comment on column psa.psa_smo_shift.sms_smo_seqn is 'Shift model sequence';
comment on column psa.psa_smo_shift.sms_shf_code is 'Shift code';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_smo_shift
   add constraint psa_smo_shift_pk primary key (sms_smo_code, sms_smo_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_smo_shift to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_smo_shift for psa.psa_smo_shift;