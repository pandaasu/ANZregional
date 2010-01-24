/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_lin_filler
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production line Configuration Filler Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_lin_filler
   (lfi_lin_code                    varchar2(32)                  not null,
    lfi_con_code                    varchar2(32)                  not null,
    lfi_fil_code                    varchar2(32)                  not null);

/**/
/* Comments
/**/
comment on table psa.psa_lin_filler is 'Production line Configuration Filler Table';
comment on column psa.psa_lin_filler.lfi_lin_code is 'Line code';
comment on column psa.psa_lin_filler.lfi_con_code is 'Line configuration code';
comment on column psa.psa_lin_filler.lfi_fil_code is 'Filler code';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_lin_filler
   add constraint psa_lin_filler_pk primary key (lfi_lin_code, lfi_con_code, lfi_fil_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_lin_filler to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_lin_filler for psa.psa_lin_filler;