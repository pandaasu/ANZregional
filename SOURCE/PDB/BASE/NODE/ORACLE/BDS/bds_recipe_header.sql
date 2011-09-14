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
 2011/09   Ben Halicki	  Modified some varchar2 datatypes from BYTE to CHAR
							for unicode

*******************************************************************************/
create table bds.bds_recipe_header
(
  proc_order          varchar2(12 byte) not null,
  cntl_rec_id         number(18) not null,
  plant_code          varchar2(4 byte) not null,
  cntl_rec_status     varchar2(5 byte),
  test_flag           varchar2(1 byte),
  recipe_text         varchar2(40 char),
  material            varchar2(18 char) not null,
  material_text       varchar2(40 char),
  quantity            number,
  insplot             varchar2(12 byte),
  uom                 varchar2(4 byte),
  batch               varchar2(10 byte),
  sched_start_datime  date,
  run_start_datime    date not null,
  run_end_datime      date not null,
  version             number,
  upd_datime          date,
  cntl_rec_xfer       varchar2(1 byte) not null,
  teco_status         varchar2(4 byte),
  storage_locn        varchar2(4 byte),
  idoc_timestamp      varchar2(16 byte) not null
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_recipe_header
  add constraint bds_recipe_header_pk primary key (proc_order);

/**/
/* Indexes
/**/
create index bds.bds_recipe_header_idx01 on bds.bds_recipe_header (material);
create index bds.bds_recipe_header_idx02 on bds.bds_recipe_header (teco_status);
create index bds.bds_recipe_header_idx03 on bds.bds_recipe_header (plant_code);
create unique index bds.bds_recipe_header_uk01 on bds.bds_recipe_header (cntl_rec_id);

/**/
/* Authority 
/**/
grant delete, insert, select, update on bds.bds_recipe_header to bds_app with grant option;
grant select on bds.bds_recipe_header to appsupport;
grant select on bds.bds_recipe_header to manu with grant option;
grant select on bds.bds_recipe_header to manu_app with grant option;
grant select on bds.bds_recipe_header to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_recipe_header for bds.bds_recipe_header;