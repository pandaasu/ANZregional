/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_material_uom  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_material_uom 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_material_uom
(
  sap_material_code              varchar2(18 char) not null,
  uom_code                       varchar2(3 char) not null,
  sap_function                   varchar2(3 char),
  base_uom_numerator             number,
  base_uom_denominator           number,
  bds_factor_to_base_uom         number,
  bds_factor_from_base_uom       number,
  interntl_article_no            varchar2(18 char),
  interntl_article_no_ctgry      varchar2(2 char),
  length                         number,
  width                          number,
  height                         number,
  dimension_uom                  varchar2(3 char),
  volume                         number,
  volume_unit                    varchar2(3 char),
  gross_weight                   number,
  gross_weight_unit              varchar2(3 char),
  lower_level_hierachy_uom       varchar2(3 char),
  global_trade_item_variant      varchar2(2 char),
  mars_mutli_convrsn_uom_indctr  varchar2(1 char),
  mars_pc_item_code              varchar2(18 char),
  mars_pc_level                  number,
  mars_order_uom_prfrnc_indctr   varchar2(1 char),
  mars_sales_uom_prfrnc_indctr   varchar2(1 char),
  mars_issue_uom_prfrnc_indctr   varchar2(1 char),
  mars_wm_uom_prfrnc_indctr      varchar2(1 char),
  mars_rprsnttv_material_code    varchar2(18 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_material_uom 
  add constraint bds_material_uom_pk primary key (sap_material_code, uom_code);
 
/**/
/* Authority 
/**/
grant select, delete, insert, update on bds.bds_material_uom to bds_app with grant option;
grant select on bds.bds_material_uom to manu_app with grant option;
grant select on bds.bds_material_uom to pt_app with grant option;
grant select on bds.bds_material_uom to manu with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_material_uom for bds.bds_material_uom;

