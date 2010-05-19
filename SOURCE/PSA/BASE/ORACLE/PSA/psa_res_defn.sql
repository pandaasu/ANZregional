/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_res_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Resource Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_res_defn
   (rde_res_code                    varchar2(32)                  not null,
    rde_res_name                    varchar2(120 char)            not null,
    rde_res_status                  varchar2(1)                   not null,
    rde_prd_type                    varchar2(32)                  not null,
    rde_upd_user                    varchar2(30)                  not null,
    rde_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_res_defn is 'Resource Definition Table';
comment on column psa.psa_res_defn.rde_res_code is 'Resource code';
comment on column psa.psa_res_defn.rde_res_name is 'Resource name';
comment on column psa.psa_res_defn.rde_res_status is 'Resource status (0=inactive or 1=active)';
comment on column psa.psa_res_defn.rde_prd_type is 'Production type code';
comment on column psa.psa_res_defn.rde_upd_user is 'Last updated user';
comment on column psa.psa_res_defn.rde_upd_date is 'Last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_res_defn
   add constraint psa_res_defn_pk primary key (rde_res_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_res_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_res_defn for psa.psa_res_defn;