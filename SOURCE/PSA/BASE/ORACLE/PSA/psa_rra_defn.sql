/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_rde_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Run Rate Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_rde_defn
   (rde_rra_code                    varchar2(32)                  not null,
    rde_rra_name                    varchar2(120 char)            not null,
    rde_rra_units                   number                        not null,
    rde_rra_efficiency              number                        not null,
    rde_rra_wastage                 number                        not null,
    rde_rra_status                  varchar2(1)                   not null,
    rde_prd_type                    varchar2(32)                  not null,
    rde_upd_user                    varchar2(30)                  not null,
    rde_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_rde_defn is 'Run Rate Table';
comment on column psa.psa_rde_defn.rde_rra_code is 'Run rate code';
comment on column psa.psa_rde_defn.rde_rra_name is 'Run rate name';
comment on column psa.psa_rde_defn.rde_rra_units is 'Run rate units';
comment on column psa.psa_rde_defn.rde_rra_efficiency is 'Run rate efficiency percentage';
comment on column psa.psa_rde_defn.rde_rra_wastage is 'Run rate wastage percentage';
comment on column psa.psa_rde_defn.rde_rra_status is 'Run rate status (0=inactive or 1=active)';
comment on column psa.psa_rde_defn.rde_prd_type is 'Production type code';
comment on column psa.psa_rde_defn.rde_upd_user is 'Run rate last updated user';
comment on column psa.psa_rde_defn.rde_upd_date is 'Run rate last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_rde_defn
   add constraint psa_rde_defn_pk primary key (rde_rra_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_rde_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_rde_defn for psa.psa_rde_defn;