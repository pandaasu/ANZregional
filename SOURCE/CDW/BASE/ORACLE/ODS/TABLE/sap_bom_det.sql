/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : cdw 
 Table   : sap_bom_det
 Owner   : ods 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Operational Data Store - sap_bom_det

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table ods.sap_bom_det
(
  bom_material_code   varchar2(18 char)         not null,
  bom_alternative     varchar2(2 char)          not null,
  bom_plant           varchar2(4 char)          not null,
  item_sequence       number                    not null,
  item_number         varchar2(4 char),
  item_msg_function   varchar2(3 char),
  item_material_code  varchar2(18 char),
  item_category       varchar2(1 char),
  item_base_qty       number,
  item_base_uom       varchar2(3 char),
  item_eff_from_date  date,
  item_eff_to_date    date,
  bom_number          varchar2(8 char),
  bom_msg_function    varchar2(3 char),
  bom_usage           varchar2(1 char),
  bom_eff_from_date   date,
  bom_eff_to_date     date,
  bom_base_qty        number,
  bom_base_uom        varchar2(3 char),
  bom_status          varchar2(2 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table ods.sap_bom_det
   add constraint sap_bom_det_pk primary key (bom_material_code, bom_alternative, bom_plant, item_sequence);

/**/
/* Column comments 
/**/
comment on table ods.sap_bom_det is 'Business Data Store - Bill Of Material Detail (LOIBOM01)';
comment on column ods.sap_bom_det.item_category is 'Item Category - lads_bom_det.postp';
comment on column ods.sap_bom_det.item_base_qty is 'Component Quantity - lads_bom_det.menge';
comment on column ods.sap_bom_det.item_base_uom is 'Component UOM - lads_bom_det.meins';
comment on column ods.sap_bom_det.item_eff_from_date is 'Component Valid From Date - lads_bom_det.datuv';
comment on column ods.sap_bom_det.item_eff_to_date is 'Component Valid To Date - lads_bom_det.datub';
comment on column ods.sap_bom_det.bom_number is 'Bill of Material - lads_bom_hdr.stlnr';
comment on column ods.sap_bom_det.bom_msg_function is 'BOM Message Function - lads_bom_hdr.msgfn';
comment on column ods.sap_bom_det.bom_usage is 'BOM Usage - lads_bom_hdr.stlan';
comment on column ods.sap_bom_det.bom_eff_from_date is 'BOM Valid From Date - lads_bom_hdr.datuv';
comment on column ods.sap_bom_det.bom_eff_to_date is 'BOM Valid To Date - lads_bom_hdr.datub';
comment on column ods.sap_bom_det.bom_base_qty is 'Base Quantity - lads_bom_hdr.bmeng';
comment on column ods.sap_bom_det.bom_base_uom is 'UOM for Base Quantity - lads_bom_hdr.bmein';
comment on column ods.sap_bom_det.bom_status is 'BOM status - lads_bom_hdr.stlst';
comment on column ods.sap_bom_det.bom_material_code is 'Material Number - lads_bom_det.matnr';
comment on column ods.sap_bom_det.bom_alternative is 'Alternative BOM - lads_bom_det.stlal';
comment on column ods.sap_bom_det.bom_plant is 'Plant - lads_bom_det.werks';
comment on column ods.sap_bom_det.item_sequence is 'Item Sequence - lads_bom_det.detseq';
comment on column ods.sap_bom_det.item_number is 'Item Number - lads_bom_det.posnr';
comment on column ods.sap_bom_det.item_msg_function is 'Item Message Function - lads_bom_det.msgfn';
comment on column ods.sap_bom_det.item_material_code is 'Component - lads_bom_det.idnrk';

/**/
/* Authority 
/**/
grant select, update, delete, insert on ods.sap_bom_det to ods_app with grant option;
grant select on ods.sap_bom_det to dds_app with grant option;
grant select on ods.sap_bom_det to lics_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym sap_bom_det for ods.sap_bom_det;
