/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : cdw 
 Table   : sap_bom_hdr
 Owner   : ods 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Operational Data Store - sap_bom_hdr

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/08   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table ods.sap_bom_hdr
(
  bom_material_code   varchar2(18 char)         not null,
  bom_alternative     varchar2(2 char)          not null,
  bom_plant           varchar2(4 char)          not null,
  sap_idoc_name       varchar2(30 char),
  sap_idoc_number     number,
  sap_idoc_timestamp  varchar2(14 char),
  bom_number          varchar2(8 char),
  bom_msg_function    varchar2(3 char),
  bom_usage           varchar2(1 char),
  bom_eff_from_date   date,
  bom_eff_to_date     date,
  bom_base_qty        number,
  bom_base_uom        varchar2(3 char),
  bom_status          varchar2(2 char),
  load_date           date
);

/**/
/* Primary Key Constraint 
/**/
alter table ods.sap_bom_hdr
   add constraint sap_bom_hdr_pk primary key (bom_material_code, bom_alternative, bom_plant);

/**/
/* Column comments 
/**/
comment on table ods.sap_bom_hdr is 'Operational Data Store - Bill Of Material Header (LOIBOM01)';
comment on column ods.sap_bom_hdr.bom_material_code is 'Material Number - lads_bom_hdr.matnr';
comment on column ods.sap_bom_hdr.bom_alternative is 'Alternative BOM - lads_bom_hdr.stlal';
comment on column ods.sap_bom_hdr.bom_plant is 'Plant - lads_bom_hdr.werks';
comment on column ods.sap_bom_hdr.sap_idoc_name is 'IDOC name - lads_bom_hdr.idoc_name';
comment on column ods.sap_bom_hdr.sap_idoc_number is 'IDOC number - lads_bom_hdr.idoc_number';
comment on column ods.sap_bom_hdr.sap_idoc_timestamp is 'IDOC timestamp - lads_bom_hdr.idoc_timestamp';
comment on column ods.sap_bom_hdr.bom_number is 'Bill of Material - lads_bom_hdr.stlnr';
comment on column ods.sap_bom_hdr.bom_msg_function is 'BOM Message Function - lads_bom_hdr.msgfn';
comment on column ods.sap_bom_hdr.bom_usage is 'BOM Usage - lads_bom_hdr.stlan';
comment on column ods.sap_bom_hdr.bom_eff_from_date is 'BOM Valid From Date - lads_bom_hdr.datuv';
comment on column ods.sap_bom_hdr.bom_eff_to_date is 'BOM Valid To Date - lads_bom_hdr.datub';
comment on column ods.sap_bom_hdr.bom_base_qty is 'Base Quantity - lads_bom_hdr.bmeng';
comment on column ods.sap_bom_hdr.bom_base_uom is 'UOM for Base Quantity - lads_bom_hdr.bmein';
comment on column ods.sap_bom_hdr.bom_status is 'BOM status - lads_bom_hdr.stlst';

/**/
/* Authority 
/**/
grant select, update, delete, insert on ods.sap_bom_hdr to ods_app with grant option;
grant select on ods.sap_bom_hdr to dds_app with grant option;
grant select on ods.sap_bom_hdr to lics_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym sap_bom_hdr for ods.sap_bom_hdr;
