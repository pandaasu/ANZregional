/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_mat_defn
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Material Definition Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_mat_defn
   (mde_mat_code                    varchar2(32)                  not null,
    mde_sap_code                    varchar2(32)                  not null,
    mde_mat_name                    varchar2(120 char)            not null,
    mde_mat_type                    varchar2(10)                  not null,
    mde_mat_usage                   varchar2(10)                  not null,
    mde_mat_uom                     varchar2(10)                  not null,
    mde_gro_weight                  number                        not null,
    mde_net_weight                  number                        not null,
    mde_unt_case                    number                        not null,
    mde_sap_line                    varchar2(32)                  null,
    mde_psa_line                    varchar2(32)                  null,
    mde_mat_status                  varchar2(10)                  not null,
    mde_sys_user                    varchar2(30)                  not null,
    mde_sys_date                    date                          not null,
    mde_upd_user                    varchar2(30)                  null,
    mde_upd_date                    date                          null);

/**/
/* Comments
/**/
comment on table psa.psa_mat_defn is 'Material Definition Table';
comment on column psa.psa_mat_defn.mde_mat_code is 'Material code';
comment on column psa.psa_mat_defn.mde_sap_code is 'SAP material code';
comment on column psa.psa_mat_defn.mde_mat_name is 'Material name';
comment on column psa.psa_mat_defn.mde_mat_type is 'Material type';
comment on column psa.psa_mat_defn.mde_mat_usage is 'Material usage';
comment on column psa.psa_mat_defn.mde_mat_uom is 'Material unit of measure';
comment on column psa.psa_mat_defn.mde_gro_weight is 'Material gross weight';
comment on column psa.psa_mat_defn.mde_net_weight is 'Material net weight';
comment on column psa.psa_mat_defn.mde_unt_case is 'Material units per case';
comment on column psa.psa_mat_defn.mde_sap_line is 'SAP production line';
comment on column psa.psa_mat_defn.mde_psa_line is 'PSA production line';
comment on column psa.psa_mat_defn.mde_mat_status is 'Material status (*ADD, *CHG, *DEL, *ACTIVE or *INACTIVE)';
comment on column psa.psa_mat_defn.mde_sys_user is 'Material system updated user';
comment on column psa.psa_mat_defn.mde_sys_date is 'Material system updated date';
comment on column psa.psa_mat_defn.mde_upd_user is 'Material last updated user';
comment on column psa.psa_mat_defn.mde_upd_date is 'Material last updated date';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_mat_defn
   add constraint psa_mat_defn_pk primary key (mde_mat_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_mat_defn to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_mat_defn for psa.psa_mat_defn;