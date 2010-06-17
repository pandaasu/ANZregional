/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_recipe_src_text  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_recipe_src_text 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_recipe_src_text
(
  recipe_src_text_id  number not null,
  proc_order          varchar2(12 byte) not null,
  operation           varchar2(4 byte),
  phase               varchar2(4 byte),
  seq                 varchar2(4 byte),
  src_text            varchar2(4000 byte),
  src_type            varchar2(10 byte),
  machine_code        varchar2(4 byte),
  detail_desc         varchar2(4000 byte),
  plant_code          varchar2(4 byte)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_recipe_src_text 
  add constraint bds_recipe_src_text_pk primary key (recipe_src_text_id);

/**/
/* Indexes
/**/
create index bds.bds_recipe_src_text_idx01 on bds.bds_recipe_src_text(proc_order);

/**/
/* Authority 
/**/
grant delete, insert, select, update on bds.bds_recipe_src_text to bds_app with grant option;
grant select on bds.bds_recipe_src_text to appsupport;
grant select on bds.bds_recipe_src_text to manu with grant option;
grant select on bds.bds_recipe_src_text to manu_app with grant option;
grant select on bds.bds_recipe_src_text to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_recipe_src_text for bds.bds_recipe_src_text;