/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_material_pkg_instr_det_t  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_material_pkg_instr_det_t 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/
create table bds.bds_material_pkg_instr_det_t
(
  sap_material_code      varchar2(18 char)      not null,
  pkg_instr_table_usage  varchar2(1 char)       not null,
  pkg_instr_table        varchar2(64 char)      not null,
  pkg_instr_type         varchar2(4 char)       not null,
  pkg_instr_application  varchar2(2 char)       not null,
  item_ctgry             varchar2(2 char)       not null,
  sales_organisation     varchar2(4 char)       not null,
  component              varchar2(20 char)      not null,
  pkg_instr_start_date   date                   not null,
  pkg_instr_end_date     date                   not null,
  variable_key           varchar2(100 char),
  height                 number,
  width                  number,
  length                 number,
  hu_total_weight        number,
  hu_total_volume        number,
  dimension_uom          varchar2(3 char),
  weight_unit            varchar2(3 char),
  volume_unit            varchar2(3 char),
  target_qty             number,
  rounding_qty           number,
  uom                    varchar2(3 char)
);

/**/
/* Indexes  
/**/
create index bds.bds_material_pkg_instr_t_idx1 on bds.bds_material_pkg_instr_det_t(sap_material_code);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_material_pkg_instr_det_t 
  add constraint bds_mat_pkg_instr_det_t_pk primary key (sap_material_code, pkg_instr_table_usage, pkg_instr_table, pkg_instr_type, pkg_instr_application, pkg_instr_start_date, pkg_instr_end_date, sales_organisation, item_ctgry, component);
 
/**/
/* Authority 
/**/
grant delete, insert, select, update on bds.bds_material_pkg_instr_det_t to bds_app with grant option;
grant select on bds.bds_material_pkg_instr_det_t to manu_app with grant option;
grant select on bds.bds_material_pkg_instr_det_t to pt_app with grant option;
/**/
/* Synonym 
/**/
create or replace public synonym bds_material_pkg_instr_det_t for bds.bds_material_pkg_instr_det_t;
