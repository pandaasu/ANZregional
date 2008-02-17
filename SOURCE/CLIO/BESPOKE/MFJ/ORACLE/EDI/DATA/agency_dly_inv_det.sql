/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : agency_dly_inv_det
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Collection Agency Daily Invoice Detail Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.agency_dly_inv_det
   (company_code                    varchar2(10 char)             not null,
    creatn_date                     varchar2(10 char)             not null,
    gen_belnr                       varchar2(35 char)             not null,
    gen_genseq                      number                        not null,
    gen_mat_legacy                  varchar2(5 char)              null,
    gen_rsu_per_tdu                 number                        null,
    gen_rsu_per_mcu                 number                        null,
    gen_mcu_per_tdu                 number                        null,
    gen_menge                       number                        null,
    gen_menee                       varchar2(3 char)              null,
    gen_pstyv                       varchar2(4 char)              null,
    gen_prod_spart                  varchar2(2 char)              null,
    iob_002_idtnr                   varchar2(35 char)             null,
    iob_r01_idtnr                   varchar2(35 char)             null,
    mat_z3_maktx                    varchar2(40 char)             null,
    ias_901_krate                   number                        null,
    ias_901_betrg                   number                        null,
    icn_zrsp_krate                  number                        null,
    icn_pr00_krate                  number                        null,
    icn_zcrp_kperc                  number                        null,
    icn_zcrp_betrg                  number                        null,
    icn_zk25_betrg                  number                        null,
    icn_zk60_betrg                  number                        null);

/**/
/* Comments
/**/
comment on table edi.agency_dly_inv_det is 'Collection Agency Daily Invoice Detail Table';

/**/
/* Primary Key Constraint
/**/
alter table edi.agency_dly_inv_det
   add constraint agency_dly_inv_det_pk primary key (gen_belnr, gen_genseq);

/**/
/* Indexes
/**/
create index agency_dly_inv_det_ix01 on agency_dly_inv_det (creatn_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.agency_dly_inv_det to dw_app;
grant select on edi.agency_dly_inv_det to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym agency_dly_inv_det for edi.agency_dly_inv_det;