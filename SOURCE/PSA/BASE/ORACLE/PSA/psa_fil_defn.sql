/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_fil_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Filler Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_fil_defn
   (fde_fil_code                    varchar2(32)                  not null,
    fde_fil_name                    varchar2(120 char)            not null,
    fde_fil_status                  varchar2(1)                   not null,
    fde_upd_user                    varchar2(30)                  not null,
    fde_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_fil_defn is 'Filler Definition Table';
comment on column psa.psa_fil_defn.fde_fil_code is 'Filler code';
comment on column psa.psa_fil_defn.fde_fil_name is 'Filler name';
comment on column psa.psa_fil_defn.fde_fil_status is 'Filler status (0=inactive or 1=active)';
comment on column psa.psa_fil_defn.fde_upd_user is 'Last updated user';
comment on column psa.psa_fil_defn.fde_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_fil_defn
   add constraint psa_fil_defn_pk primary key (fde_fil_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_fil_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_fil_defn for psa.psa_fil_defn;