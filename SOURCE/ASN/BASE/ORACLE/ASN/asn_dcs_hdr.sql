/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : asn
 Table   : asn_dcs_hdr
 Owner   : asn
 Author  : Steve Gregan

 Description
 -----------
 Advanced Shipping Notice - asn_dcs_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   Steve Gregan   Created
 2006/03   Steve Gregan   Added dch_trn_byer_ide
                          Changed dch_smsg_ack to date
 2006/11   Steve Gregan   Added send message original sent time
                          Added ship to target
 2007/11   Steve Gregan   Added sales order creation date

*******************************************************************************/

/**/
/* Table creation
/**/
create table asn_dcs_hdr
   (dch_mars_cde varchar2(10 char) not null,
    dch_pick_nbr varchar2(10 char) not null,
    dch_pick_typ varchar2(6 char) not null,
    dch_crtn_tim date not null,
    dch_updt_tim date not null,
    dch_stat_cde varchar2(32 char) not null,
    dch_delv_ind varchar2(1 char) not null,
    dch_sord_ind varchar2(1 char) not null,
    dch_ship_ind varchar2(1 char) not null,
    dch_invc_ind varchar2(1 char) not null,
    dch_splr_iid varchar2(15 char) not null,
    dch_splr_nam varchar2(35 char) not null,
    dch_smsg_nbr number null,
    dch_smsg_cnt number null,
    dch_smsg_tim date null,
    dch_smsg_ack date null,
    dch_emsg_txt varchar2(4000 char) null,
    dch_whs_file_ide varchar2(6 char) null,
    dch_whs_pick_nbr varchar2(10 char) null,
    dch_whs_ship_frm varchar2(3 char) null,
    dch_whs_send_dte varchar2(14 char) null,
    dch_whs_desp_dte varchar2(14 char) null,
    dch_whs_palt_num number null,
    dch_whs_palt_spc number null,
    dch_whs_csgn_nbr varchar2(10 char) null,
    dch_whs_ship_tar varchar2(10 char) null,
    dch_trn_pick_nbr varchar2(10 char) null,
    dch_trn_sord_nbr varchar2(10 char) null,
    dch_trn_ship_nbr varchar2(10 char) null,
    dch_trn_invc_nbr varchar2(10 char) null,
    dch_trn_mars_iid varchar2(15 char) null,
    dch_trn_cust_iid varchar2(15 char) null,
    dch_trn_cust_pon varchar2(35 char) null,
    dch_trn_agrd_dte varchar2(14 char) null,
    dch_trn_ordr_dte varchar2(14 char) null,
    dch_trn_invc_dte varchar2(8 char) null,
    dch_trn_splt_shp varchar2(1 char) null,
    dch_trn_invc_val number null,
    dch_trn_invc_gst number null,
    dch_trn_crcy_cde varchar2(3 char) null,
    dch_trn_ship_iid varchar2(15 char) null,
    dch_trn_ship_nam varchar2(35 char) null,
    dch_trn_dock_nbr varchar2(10 char) null,
    dch_trn_byer_ide varchar2(17 char) null);


/**/
/* Comments
/**/
comment on table asn_dcs_hdr is 'ASN Distribution Centre Shipment Header Table';
comment on column asn_dcs_hdr.dch_mars_cde is 'Mars unit code';
comment on column asn_dcs_hdr.dch_pick_nbr is 'Pick number';
comment on column asn_dcs_hdr.dch_pick_typ is 'Type code (*ATLDC, *LOGDC)';
comment on column asn_dcs_hdr.dch_crtn_tim is 'Created date/time';
comment on column asn_dcs_hdr.dch_updt_tim is 'Updated date/time';
comment on column asn_dcs_hdr.dch_stat_cde is 'Status code';
comment on column asn_dcs_hdr.dch_delv_ind is 'Delivery indicator';
comment on column asn_dcs_hdr.dch_sord_ind is 'Sales order indicator';
comment on column asn_dcs_hdr.dch_ship_ind is 'Shipment indicator';
comment on column asn_dcs_hdr.dch_invc_ind is 'Invoice indicator';
comment on column asn_dcs_hdr.dch_splr_iid is 'Sender interchange id';
comment on column asn_dcs_hdr.dch_splr_nam is 'Sender name';
comment on column asn_dcs_hdr.dch_smsg_nbr is 'Send message number';
comment on column asn_dcs_hdr.dch_smsg_cnt is 'Send message count';
comment on column asn_dcs_hdr.dch_smsg_tim is 'Send message original sent time';
comment on column asn_dcs_hdr.dch_smsg_ack is 'Send message acknowledged';
comment on column asn_dcs_hdr.dch_emsg_txt is 'Error message text';
comment on column asn_dcs_hdr.dch_whs_file_ide is 'Warehouse - File identifier';
comment on column asn_dcs_hdr.dch_whs_pick_nbr is 'Warehouse - Pick number';
comment on column asn_dcs_hdr.dch_whs_ship_frm is 'Warehouse - Ship from site';
comment on column asn_dcs_hdr.dch_whs_send_dte is 'Warehouse - ASN data send date/time';
comment on column asn_dcs_hdr.dch_whs_desp_dte is 'Warehouse - Despatch date/time';
comment on column asn_dcs_hdr.dch_whs_palt_num is 'Warehouse - Number of pallets';
comment on column asn_dcs_hdr.dch_whs_palt_spc is 'Warehouse - Pallet spaces';
comment on column asn_dcs_hdr.dch_whs_csgn_nbr is 'Warehouse - Consignment number';
comment on column asn_dcs_hdr.dch_whs_ship_tar is 'Warehouse - Ship to target';
comment on column asn_dcs_hdr.dch_trn_pick_nbr is 'Transaction - Pick number';
comment on column asn_dcs_hdr.dch_trn_sord_nbr is 'Transaction - Sales order number';
comment on column asn_dcs_hdr.dch_trn_ship_nbr is 'Transaction - Shipment number';
comment on column asn_dcs_hdr.dch_trn_invc_nbr is 'Transaction - Invoice number';
comment on column asn_dcs_hdr.dch_trn_mars_iid is 'Transaction - Mars interchange id';
comment on column asn_dcs_hdr.dch_trn_cust_iid is 'Transaction - Customer interchange id';
comment on column asn_dcs_hdr.dch_trn_cust_pon is 'Transaction - Customer PO number';
comment on column asn_dcs_hdr.dch_trn_agrd_dte is 'Transaction - Agreed delivery date/time';
comment on column asn_dcs_hdr.dch_trn_ordr_dte is 'Transaction - Order date/time';
comment on column asn_dcs_hdr.dch_trn_invc_dte is 'Transaction - Invoice date';
comment on column asn_dcs_hdr.dch_trn_splt_shp is 'Transaction - Split shipment flag';
comment on column asn_dcs_hdr.dch_trn_invc_val is 'Transaction - Invoice value';
comment on column asn_dcs_hdr.dch_trn_invc_gst is 'Transaction - Invoice GST';
comment on column asn_dcs_hdr.dch_trn_crcy_cde is 'Transaction - Currency code';
comment on column asn_dcs_hdr.dch_trn_ship_iid is 'Transaction - Ship to interchange id';
comment on column asn_dcs_hdr.dch_trn_ship_nam is 'Transaction - Ship to name';
comment on column asn_dcs_hdr.dch_trn_dock_nbr is 'Transaction - Dock number';
comment on column asn_dcs_hdr.dch_trn_byer_ide is 'Transaction - Buyer identifier';

/**/
/* Primary Key Constraint
/**/
alter table asn_dcs_hdr
   add constraint asn_dcs_hdr_pk primary key (dch_mars_cde, dch_pick_nbr);

/**/
/* Authority
/**/
grant select, insert, update, delete on asn_dcs_hdr to ics_app;
grant select on asn_dcs_hdr to public;

/**/
/* Synonym
/**/
create or replace public synonym asn_dcs_hdr for asn.asn_dcs_hdr;
