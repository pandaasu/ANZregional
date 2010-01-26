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
    mde_mat_name                    varchar2(120 char)            not null,
    mde_mat_type                    varchar2(4)                   not null,
    mde_mat_usage                   varchar2(4)                   not null,
    mde_mat_uom                     varchar2(4)                   not null,
    mde_gro_weight                  number                        not null,
    mde_net_weight                  number                        not null,
    mde_unt_case                    number                        not null,
    mde_mat_status                  varchar2(10                   not null,
    mde_prd_type                    varchar2(32)                  not null,
    mde_sch_priority                number                        not null,
    mde_dft_line                    varchar2(32)                  not null,
    mde_cas_pallet                  number                        not null,
    mde_btc_quantity                number                        not null,
    mde_yld_percent                 number                        not null,
    mde_yld_value                   number                        not null,
    mde_pkw_percent                 number                        not null,
    mde_pkw_value                   number                        not null,
    mde_btw_value                   number                        not null,
    mde_upd_user                    varchar2(30)                  not null,
    mde_upd_date                    date                          not null);

/**/
/* Comments
/**/
comment on table psa.psa_mat_defn is 'Material Definition Table';
comment on column psa.psa_mat_defn.mde_mat_code is 'Line code';
comment on column psa.psa_mat_defn.mde_mat_name is 'Line name';
comment on column psa.psa_mat_defn.mde_mat_wastage is 'Line default wastage percentage';
comment on column psa.psa_mat_defn.mde_mat_events is 'Line auto product change events (0=no or 1=yes)';
comment on column psa.psa_mat_defn.mde_mat_status is 'Line status (0=inactive or 1=active)';
comment on column psa.psa_mat_defn.mde_prd_type is 'Production type code';
comment on column psa.psa_mat_defn.mde_upd_user is 'Line last updated user';
comment on column psa.psa_mat_defn.mde_upd_date is 'Line last updated date';

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