/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_material_bom_hdr 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_material_bom_hdr 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_material_bom_hdr
(
  sap_bom               varchar2(8 char)        not null,
  sap_bom_alternative   varchar2(2 char)        not null,
  bom_plant             varchar2(5 char),
  bom_usage             varchar2(1 char),
  bom_eff_date          date,
  bom_status            number,
  parent_material_code  varchar2(18 char),
  parent_base_qty       number,
  parent_base_uom       varchar2(3 char),
  msg_timestamp         varchar2(14 char)
);

/**/
/* Indexes 
/**/
create index bds.bds_material_bom_hdr_idx1 on bds.bds_material_bom_hdr(parent_material_code, sap_bom_alternative, bom_plant, bom_usage, bom_status, bom_eff_date);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_material_bom_hdr
   add constraint bds_material_bom_hdr_pk primary key (sap_bom, sap_bom_alternative);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_material_bom_hdr to bds_app with grant option;
grant select on bds.bds_material_bom_hdr to manu_app with grant option;
grant select on bds.bds_material_bom_hdr to pt_app with grant option;
grant select on bds.bds_material_bom_hdr to manu with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_material_bom_hdr for bds.bds_material_bom_hdr;