/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_psc_invt
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Schedule Inventory Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_psc_invt
   (psi_act_code                    number                        not null,
    psi_mat_code                    varchar2(32)                  not null,
    psi_mov_type                    varchar2(1)                   not null,
    psi_mov_qnty                    number                        not null,
    psi_avl_qnty                    number                        not null);

/**/
/* Comments
/**/
comment on table psa.psa_psc_invt is 'Production Schedule Inventory Table';
comment on column psa.psa_psc_invt.psi_act_code is 'Activity code';
comment on column psa.psa_psc_invt.psi_mat_code is 'Material code';
comment on column psa.psa_psc_invt.psi_mov_type is 'Inventory movement type (P=production or C=consumption)';
comment on column psa.psa_psc_invt.psi_mov_qnty is 'Inventory movement quantity';
comment on column psa.psa_psc_invt.psi_avl_qnty is 'Inventory available quantity';


/**/
/* Primary Key Constraint
/**/
alter table psa.psa_psc_invt
   add constraint psa_psc_invt_pk primary key (psi_act_code, psi_mat_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_psc_invt to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_psc_invt for psa.psa_psc_invt;