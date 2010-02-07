/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : psa_req_header
 Owner  : psa

 Description
 -----------
 Production Scheduling Application - Production Requirement Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2009/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table psa.psa_req_header
   (rhe_mat_code                    varchar2(32)                  not null,
    rhe_sap_code                    varchar2(32)                  not null,
    rhe_mat_name                    varchar2(120 char)            not null,
    rhe_mat_type                    varchar2(10)                  not null,
    rhe_mat_usage                   varchar2(10)                  not null,
    rhe_mat_uom                     varchar2(10)                  not null,
    rhe_gro_weight                  number                        not null,
    rhe_net_weight                  number                        not null,
    rhe_unt_case                    number                        not null,
    rhe_sap_line                    varchar2(32)                  null,
    rhe_mat_status                  varchar2(10)                  not null,
    rhe_sys_user                    varchar2(30)                  not null,
    rhe_sys_date                    date                          not null,
    rhe_upd_user                    varchar2(30)                  null,
    rhe_upd_date                    date                          null,
    rhe_prd_type                    varchar2(32)                  null,
    rhe_sch_priority                number                        null,
    rhe_dft_line                    varchar2(32)                  null,
    rhe_cas_pallet                  number                        null,
    rhe_bch_quantity                number                        null,
    rhe_yld_percent                 number                        null,
    rhe_yld_value                   number                        null,
    rhe_pck_percent                 number                        null,
    rhe_pck_weight                  number                        null,
    rhe_bch_weight                  number                        null);

/**/
/* Comments
/**/
comment on table psa.psa_req_header is 'Production Requirement Header Table';
comment on column psa.psa_req_header.rhe_mat_code is 'Material code';
comment on column psa.psa_req_header.rhe_sap_code is 'SAP material code';
comment on column psa.psa_req_header.rhe_mat_name is 'Material name';
comment on column psa.psa_req_header.rhe_mat_type is 'Material type';
comment on column psa.psa_req_header.rhe_mat_usage is 'Material usage';
comment on column psa.psa_req_header.rhe_mat_uom is 'Material unit of measure';
comment on column psa.psa_req_header.rhe_gro_weight is 'Material gross weight';
comment on column psa.psa_req_header.rhe_net_weight is 'Material net weight';
comment on column psa.psa_req_header.rhe_unt_case is 'Material units per case';
comment on column psa.psa_req_header.rhe_sap_line is 'SAP production line';
comment on column psa.psa_req_header.rhe_mat_status is 'Material status (*ADD, *CHG, *DEL, *ACTIVE or *INACTIVE)';
comment on column psa.psa_req_header.rhe_sys_user is 'Material system updated user';
comment on column psa.psa_req_header.rhe_sys_date is 'Material system updated date';
comment on column psa.psa_req_header.rhe_upd_user is 'Material last updated user';
comment on column psa.psa_req_header.rhe_upd_date is 'Material last updated date';
comment on column psa.psa_req_header.rhe_prd_type is 'Production type code';
comment on column psa.psa_req_header.rhe_sch_priority is 'Production schedule priority';
comment on column psa.psa_req_header.rhe_dft_line is 'Default production line';
comment on column psa.psa_req_header.rhe_cas_pallet is 'Cases per pallet';
comment on column psa.psa_req_header.rhe_bch_quantity is 'Batch/lot quantity';
comment on column psa.psa_req_header.rhe_yld_percent is 'Yieald percentage';
comment on column psa.psa_req_header.rhe_yld_value is 'Yield value';
comment on column psa.psa_req_header.rhe_pck_percent is 'Pack weight percentage';
comment on column psa.psa_req_header.rhe_pck_weight is 'Pack weight';
comment on column psa.psa_req_header.rhe_bch_weight is 'Batch weight';

/**/
/* Primary Key Constraint
/**/
alter table psa.psa_req_header
   add constraint psa_req_header_pk primary key (rhe_mat_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on psa.psa_req_header to psa_app;

/**/
/* Synonym
/**/
create or replace public synonym psa_req_header for psa.psa_req_header;