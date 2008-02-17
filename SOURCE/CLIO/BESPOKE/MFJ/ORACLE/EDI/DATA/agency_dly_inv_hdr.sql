/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : agency_dly_inv_hdr
 Owner  : edi

 Description
 -----------
 Electronic Data Interchange - Collection Agency Daily Invoice Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table edi.agency_dly_inv_hdr
   (company_code                    varchar2(10 char)             not null,
    creatn_date                     varchar2(10 char)             not null,
    hdr_belnr                       varchar2(35 char)             not null,
    hdr_expnr                       varchar2(20 char)             null,
    hdr_crpc_version                varchar2(2 char)              null,
    org_006_orgid                   varchar2(35 char)             null,
    org_007_orgid                   varchar2(35 char)             null,
    org_008_orgid                   varchar2(35 char)             null,
    org_012_orgid                   varchar2(35 char)             null,
    org_015_orgid                   varchar2(35 char)             null,
    pnr_rg_partn                    varchar2(17 char)             null,
    pnr_ag_partn                    varchar2(17 char)             null,
    adj_ag_z3_name1                 varchar2(128 char)            null,
    adj_ag_z3_street                varchar2(128 char)            null,
    adj_ag_z3_city1                 varchar2(128 char)            null,
    pnr_z5_partn                    varchar2(17 char)             null,
    pnr_z5_knref                    varchar2(30 char)             null,
    adj_z5_z3_name1                 varchar2(128 char)            null,
    adj_z5_z3_street                varchar2(128 char)            null,
    adj_z5_z3_city1                 varchar2(128 char)            null,
    ipn_we_partn                    varchar2(17 char)             null,
    iaj_we_z3_name1                 varchar2(128 char)            null,
    iaj_we_z3_street                varchar2(128 char)            null,
    iaj_we_z3_city1                 varchar2(128 char)            null,
    gen_vsart                       varchar2(2 char)              null,
    gen_werks                       varchar2(4 char)              null,
    gen_knref                       varchar2(30 char)             null,
    gen_org_dlvnr                   varchar2(10 char)             null,
    gen_org_dlvdt                   varchar2(8 char)              null,
    gen_zztarif                     varchar2(3 char)              null,
    dat_024_datum                   varchar2(8 char)              null,
    ref_001_refnr                   varchar2(35 char)             null,
    ref_012_refnr                   varchar2(35 char)             null,
    txt_ja_tdline                   varchar2(70 char)             null,
    edi_partn_code                  varchar2(20 char)             null,
    edi_partn_name                  varchar2(128 char)            null,
    edi_agency_code                 varchar2(20 char)             null,
    edi_interface                   varchar2(32 char)             null,
    edi_tran_code                   varchar2(10 char)             null,
    edi_disc_code                   varchar2(10 char)             null,
    edi_disc_name                   varchar2(128 char)            null,
    edi_ship_to_type                varchar2(30 char)             null,
    edi_denpyo_number               varchar2(35 char)             null,
    edi_sub_denpyo_number           varchar2(35 char)             null,
    edi_sub_denpyo_date             varchar2(10 char)             null);

/**/
/* Comments
/**/
comment on table edi.agency_dly_inv_hdr is 'Collection Agency Daily Invoice Header Table';

/**/
/* Primary Key Constraint
/**/
alter table edi.agency_dly_inv_hdr
   add constraint agency_dly_inv_hdr_pk primary key (hdr_belnr);

/**/
/* Indexes
/**/
create index agency_dly_inv_hdr_ix01 on agency_dly_inv_hdr (creatn_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on edi.agency_dly_inv_hdr to dw_app;
grant select on edi.agency_dly_inv_hdr to public with grant option;

/**/
/* Synonym
/**/
create or replace public synonym agency_dly_inv_hdr for edi.agency_dly_inv_hdr;