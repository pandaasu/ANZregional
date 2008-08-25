/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_recipe_src_value
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_recipe_src_value

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/
create table bds.bds_recipe_src_value
(
  recipe_src_value_id  number not null,
  proc_order           varchar2(12 byte) not null,
  operation            varchar2(4 byte),
  phase                varchar2(4 byte),
  seq                  varchar2(4 byte),
  src_tag              varchar2(40 byte),
  src_desc             varchar2(4000 byte),
  src_val              varchar2(30 byte),
  src_uom              varchar2(20 byte),
  machine_code         varchar2(4 byte),
  detail_desc          varchar2(4000 byte),
  plant_code           varchar2(4 byte)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_recipe_src_value
  add constraint bds_recipe_src_value_pk primary key (recipe_src_value_id);

/**/
/* Indexes
/**/
create index bds.bds_recipe_src_value_idx01 on bds.bds_recipe_src_value (proc_order);

/**/
/* Authority 
/**/
grant delete, insert, select, update on bds.bds_recipe_src_value to bds_app with grant option;
grant select on bds.bds_recipe_src_value to appsupport;
grant select on bds.bds_recipe_src_value to manu with grant option;
grant select on bds.bds_recipe_src_value to manu_app with grant option;
grant select on bds.bds_recipe_src_value to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_recipe_src_value for bds.bds_recipe_src_value;