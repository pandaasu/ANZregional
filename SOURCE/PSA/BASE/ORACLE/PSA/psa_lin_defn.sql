/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_lin_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production line Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_lin_defn
   (lde_lin_code                    varchar2(32)                  not null,
    lde_lin_name                    varchar2(120 char)            not null,
    lde_lin_wastage                 number                        not null,
    lde_lin_events                  varchar2(1)                   not null,
    lde_lin_status                  varchar2(1)                   not null,
    lde_prd_type                    varchar2(32)                  not null,
    lde_upd_user                    varchar2(30)                  not null,
    lde_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_lin_defn is 'Production line Definition Table';
comment on column psa.psa_lin_defn.lde_lin_code is 'Line code';
comment on column psa.psa_lin_defn.lde_lin_name is 'Line name';
comment on column psa.psa_lin_defn.lde_lin_wastage is 'Line default wastage percentage';
comment on column psa.psa_lin_defn.lde_lin_events is 'Line auto product change events (0=no or 1=yes)';
comment on column psa.psa_lin_defn.lde_lin_status is 'Line status (0=inactive or 1=active)';
comment on column psa.psa_lin_defn.lde_prd_type is 'Production type code';
comment on column psa.psa_lin_defn.lde_upd_user is 'Line last updated user';
comment on column psa.psa_lin_defn.lde_upd_date is 'Line last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_lin_defn
   add constraint psa_lin_defn_pk primary key (lde_lin_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_lin_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_lin_defn for psa.psa_lin_defn;