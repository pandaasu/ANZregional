/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_recipe_bom
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_recipe_bom

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/
create table bds.bds_recipe_bom
(
  recipe_bom_id   number not null,
  proc_order      varchar2(12 byte) not null,
  operation       varchar2(4 byte),
  phase           varchar2(4 byte),
  seq             varchar2(4 byte),
  material_code   varchar2(18 byte),
  material_desc   varchar2(40 byte),
  material_qty    number,
  material_uom    varchar2(4 byte),
  material_prnt   varchar2(18 byte),
  bf_item         varchar2(1 byte),
  reservation     varchar2(40 byte),
  plant_code      varchar2(4 byte),
  pan_size        number,
  last_pan_size   number,
  pan_size_flag   varchar2(1 byte),
  pan_qty         number,
  phantom         varchar2(1 byte),
  operation_from  varchar2(4 byte)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_recipe_bom
  add constraint bds_recipe_bom_pk primary key (recipe_bom_id);

/**/
/* Indexes
/**/
create index bds.bds_recipe_bom_idx01 on bds.bds_recipe_bom (proc_order);
create index bds.bds_recipe_bom_idx02 on bds.bds_recipe_bom (proc_order, operation, phase, seq);

/**/
/* Authority 
/**/
grant delete, insert, select, update on bds.bds_recipe_bom to bds_app with grant option;
grant delete, insert, select, update on bds.bds_recipe_bom to manu_app with grant option;
grant select on bds.bds_recipe_bom to appsupport;
grant select on bds.bds_recipe_bom to manu with grant option;
grant select on bds.bds_recipe_bom to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_recipe_bom for bds.bds_recipe_bom;