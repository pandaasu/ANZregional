/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_material_bom_det 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_material_bom_det 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_material_bom_det
(
  sap_bom              varchar2(8 char)         not null,
  sap_bom_alternative  varchar2(2 char)         not null,
  child_material_code  varchar2(18 char)        not null,
  child_item_category  varchar2(1 char),
  child_base_qty       number,
  child_base_uom       varchar2(3 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_material_bom_det
   add constraint bds_material_bom_det_pk primary key (sap_bom, sap_bom_alternative, child_material_code);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_material_bom_det to bds_app with grant option;
grant select on bds.bds_material_bom_det to manu_app with grant option;
grant select on bds.bds_material_bom_det to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_material_bom_det for bds.bds_material_bom_det;
