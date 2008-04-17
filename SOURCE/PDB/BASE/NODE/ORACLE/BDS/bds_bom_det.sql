/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_bom_det  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_bom_det 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_bom_det
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
alter table bds.bds_bom_det 
  add constraint bds_bom_det_pk primary key (bom_material_code, bom_alternative, bom_plant, item_sequence);
 
/**/
/* Authority 
/**/
grant select, insert, update, delete on bds_bom_det to bds_app;
grant select on bds.bds_bom_det to appsupport;
grant select on bds.bds_bom_det to fcs_user;

/**/
/* Synonym 
/**/
create or replace public synonym bds_bom_det for bds.bds_bom_det;