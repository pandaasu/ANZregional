/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_dcs_det
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_dcs_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Steve Gregan   Created
 2008/02   Steve Gregan   Added the customer GTIN
 2008/06   Steve Gregan   Added the material code

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_dcs_det
   (dcd_mars_cde varchar2(10 char) not null,
    dcd_pick_nbr varchar2(10 char) not null,
    dcd_seqn_nbr number not null,
    dcd_whs_sscc_nbr varchar2(18 char) null,
    dcd_whs_iden_typ varchar2(3 char) null,
    dcd_whs_pack_typ varchar2(17 char) null,
    dcd_whs_eqpt_typ varchar2(35 char) null,
    dcd_whs_gtin varchar2(14 char) null,
    dcd_whs_btch varchar2(10 char) null,
    dcd_whs_bbdt varchar2(8 char) null,
    dcd_whs_palt_qty number null,
    dcd_whs_palt_lay number null,
    dcd_whs_layr_unt number null,
    dcd_whs_cust_gtin varchar2(22 char) null,
    dcd_whs_matl_code varchar2(18 char) null);

/**/
/* Comments
/**/
comment on table asn_dcs_det is 'ASN Distribution Centre Shipment Detail Table';
comment on column asn_dcs_det.dcd_mars_cde is 'Mars unit code';
comment on column asn_dcs_det.dcd_pick_nbr is 'Pick number';
comment on column asn_dcs_det.dcd_seqn_nbr is 'Sequencial number within parent ASN_DC_HDR';
comment on column asn_dcs_det.dcd_whs_sscc_nbr is 'Warehouse - SSCC number';
comment on column asn_dcs_det.dcd_whs_iden_typ is 'Warehouse - Identifier type';
comment on column asn_dcs_det.dcd_whs_pack_typ is 'Warehouse - Package type';
comment on column asn_dcs_det.dcd_whs_eqpt_typ is 'Warehouse - Equipment type';
comment on column asn_dcs_det.dcd_whs_gtin is 'Warehouse - Product GTIN';
comment on column asn_dcs_det.dcd_whs_btch is 'Warehouse - Batch code';
comment on column asn_dcs_det.dcd_whs_bbdt is 'Warehouse - Best before date';
comment on column asn_dcs_det.dcd_whs_palt_qty is 'Warehouse - Pallet unit qty';
comment on column asn_dcs_det.dcd_whs_palt_lay is 'Warehouse - Pallet layers';
comment on column asn_dcs_det.dcd_whs_layr_unt is 'Warehouse - Layer units';
comment on column asn_dcs_det.dcd_whs_cust_gtin is 'Warehouse - Customer GTIN';
comment on column asn_dcs_det.dcd_whs_matl_code is 'Warehouse - Material code';

/**/
/* Primary Key Constraint
/**/
alter table asn_dcs_det
   add constraint asn_dcs_det_pk primary key (dcd_mars_cde, dcd_pick_nbr, dcd_seqn_nbr);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_dcs_det to ics_app;
grant select on asn_dcs_det to public;

/**/
/* Synonym
/**/
create or replace public synonym asn_dcs_det for asn.asn_dcs_det;
