/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_bom_all  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_bom_all 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/10   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_bom_all
(
  bom_material_code   varchar2(18 char)         not null,
  bom_alternative     varchar2(2 char)          not null,
  bom_plant           varchar2(4 char)          not null,
  bom_number          varchar2(8 char),
  bom_msg_function    varchar2(3 char),
  bom_usage           varchar2(1 char),
  bom_eff_from_date   date,
  bom_eff_to_date     date,
  bom_base_qty        number,
  bom_base_uom        varchar2(3 char),
  bom_status          varchar2(2 char),
  item_sequence       number                    not null,
  item_number         varchar2(4 char),
  item_msg_function   varchar2(3 char),
  item_material_code  varchar2(18 char),
  item_category       varchar2(1 char),
  item_base_qty       number,
  item_base_uom       varchar2(3 char),
  item_eff_from_date  date,
  item_eff_to_date    date
);

/**/
/* Indexes 
/**/
create index bds.bds_bom_all_idx01 on bds.bds_bom_all(bom_material_code, item_material_code);
create index bds.bds_bom_all_idx02 on bds.bds_bom_all(item_material_code, bom_material_code);
create index bds.bds_bom_all_idx03 on bds.bds_bom_all(bom_plant);
create index bds.bds_bom_all_idx04 on bds.bds_bom_all(bom_material_code, bom_alternative, bom_plant);
create index bds.bds_bom_all_idx05 on bds.bds_bom_all(bom_plant, item_number, bom_material_code, bom_eff_from_date);


/**/
/* Authority 
/**/
grant select, delete, insert, update on bds.bds_bom_all to bds_app with grant option;
grant select on bds.bds_bom_all to manu with grant option;
grant select on bds.bds_bom_all to manu_app with grant option;
grant select on bds.bds_bom_all to appsupport;
grant select on bds.bds_bom_all to dco_app;
grant select on bds.bds_bom_all to fcs_reader;
grant select on bds.bds_bom_all to pplan_app;
grant select on bds.bds_bom_all to pkgspec_app;

/**/
/* Synonym 
/**/
create or replace public synonym bds_bom_all for bds.bds_bom_all;