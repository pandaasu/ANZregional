/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_mat_prod
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Material Production Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_mat_prod
   (mpr_mat_code                    varchar2(32)                  not null,
    mpr_prd_type                    varchar2(32)                  not null,
    mpr_sch_priority                number                        null,
    mpr_req_flag                    varchar2(1)                   null,
    mpr_dft_line                    varchar2(32)                  null,
    mpr_cas_pallet                  number                        null,
    mpr_bch_quantity                number                        null,
    mpr_yld_percent                 number                        null,
    mpr_yld_value                   number                        null,
    mpr_pck_percent                 number                        null,
    mpr_pck_weight                  number                        null,
    mpr_bch_weight                  number                        null);

/**/
/* Comments
/**/
comment on table psa.psa_mat_prod is 'Material Production Table';
comment on column psa.psa_mat_prod.mpr_mat_code is 'Material code';
comment on column psa.psa_mat_prod.mpr_prd_type is 'Production type code';
comment on column psa.psa_mat_prod.mpr_sch_priority is 'Production schedule priority';
comment on column psa.psa_mat_prod.mpr_req_flag is 'Requirements flag 0(no) or 1(yes)';
comment on column psa.psa_mat_prod.mpr_dft_line is 'Default production line';
comment on column psa.psa_mat_prod.mpr_cas_pallet is 'Cases per pallet';
comment on column psa.psa_mat_prod.mpr_bch_quantity is 'Batch/lot quantity';
comment on column psa.psa_mat_prod.mpr_yld_percent is 'Yield percentage';
comment on column psa.psa_mat_prod.mpr_yld_value is 'Yield value';
comment on column psa.psa_mat_prod.mpr_pck_percent is 'Pack weight percentage';
comment on column psa.psa_mat_prod.mpr_pck_weight is 'Pack weight';
comment on column psa.psa_mat_prod.mpr_bch_weight is 'Batch weight';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_mat_prod
   add constraint psa_mat_prod_pk primary key (mpr_mat_code, mpr_prd_type);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_mat_prod to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_mat_prod for psa.psa_mat_prod;