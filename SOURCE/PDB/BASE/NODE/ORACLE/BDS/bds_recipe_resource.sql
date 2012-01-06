/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_recipe_resource  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_recipe_resource 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 
 2012/01   Ben Halicki    Added index to improve manufacturing systems performance

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_recipe_resource
(
  recipe_resource_id  number not null,
  proc_order          varchar2(12 byte) not null,
  operation           varchar2(4 byte),
  resource_code       varchar2(9 byte) not null,
  batch_qty           number,
  batch_uom           varchar2(4 byte),
  phantom             varchar2(8 byte),
  phantom_desc        varchar2(40 byte),
  phantom_qty         varchar2(20 byte),
  phantom_uom         varchar2(10 byte),
  plant_code          varchar2(4 byte)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_recipe_resource 
  add constraint bds_recipe_resource_pk primary key (recipe_resource_id);

/**/
/* Indexes
/**/
create index bds.bds_recipe_resource_idx01 on bds.bds_recipe_resource (resource_code, proc_order);
create index bds.bds_recipe_resource_idx02 on bds.bds_recipe_resource (resource_code);
create index bds.bds_recipe_resource_idx03 on bds.bds_recipe_resource(ltrim("PROC_ORDER",'0'), operation)

/**/
/* Authority 
/**/
grant delete, insert, select, update on bds.bds_recipe_resource to bds_app with grant option;
grant select on bds.bds_recipe_resource to appsupport;
grant select on bds.bds_recipe_resource to manu with grant option;
grant select on bds.bds_recipe_resource to manu_app with grant option;
grant select on bds.bds_recipe_resource to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_recipe_resource for bds.bds_recipe_resource;