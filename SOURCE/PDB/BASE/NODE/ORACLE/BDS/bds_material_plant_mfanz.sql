/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_material_plant_mfanz  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_material_plant_mfanz 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_material_plant_mfanz
(
  sap_material_code               varchar2(18 char) not null,
  plant_code                      varchar2(4 char) not null,
  bds_material_desc_en            varchar2(40 char),
  material_type                   varchar2(4 char),
  material_grp                    varchar2(9 char),
  base_uom                        varchar2(3 char),
  order_unit                      varchar2(3 char),
  gross_weight                    number,
  net_weight                      number,
  gross_weight_unit               varchar2(3 char),
  length                          number,
  width                           number,
  height                          number,
  dimension_uom                   varchar2(3 char),
  interntl_article_no             varchar2(18 char),
  total_shelf_life                number,
  mars_intrmdt_prdct_compnt_flag  varchar2(1 char),
  mars_merchandising_unit_flag    varchar2(1 char),
  mars_prmotional_material_flag   varchar2(1 char),
  mars_retail_sales_unit_flag     varchar2(1 char),
  mars_semi_finished_prdct_flag   varchar2(1 char),
  mars_rprsnttv_item_flag         varchar2(1 char),
  mars_traded_unit_flag           varchar2(1 char),
  xplant_status                   varchar2(2 char),
  xplant_status_valid             date,
  batch_mngmnt_reqrmnt_indctr     varchar2(2 char),
  mars_plant_material_type        number,
  procurement_type                varchar2(1 char),
  special_procurement_type        varchar2(2 char),
  issue_storage_location          varchar2(4 char),
  mrp_controller                  varchar2(3 char),
  plant_specific_status_valid     date,
  deletion_indctr                 varchar2(1 char),
  plant_specific_status           varchar2(2 char),
  assembly_scrap_percntg          number,
  component_scrap_percntg         number,
  backflush_indctr                varchar2(1 char),
  mars_rprsnttv_item_code         varchar2(18 char),
  sales_text_147                  varchar2(4000 char),
  sales_text_149                  varchar2(4000 char),
  regional_code_10                varchar2(18 char),
  regional_code_17                varchar2(18 char),
  regional_code_18                varchar2(18 char),
  regional_code_19                varchar2(18 char),
  bds_unit_cost                   number,
  future_planned_price_1          number,
  vltn_class                      varchar2(4 char),
  bds_pce_factor_from_base_uom    number,
  mars_pce_item_code              varchar2(18 char),
  mars_pce_interntl_article_no    varchar2(18 char),
  bds_sb_factor_from_base_uom     number,
  mars_sb_item_code               varchar2(18 char),
  discontinuation_indctr          varchar2(1 char),
  followup_material               varchar2(18 char),
  material_division               varchar2(2 char),
  mrp_type                        varchar2(2 char),
  max_storage_prd                 number,
  max_storage_prd_unit            varchar2(3 char),
  issue_unit                      varchar2(3 char),
  planned_delivery_days           number,
  effective_out_date              date,
  msg_timestamp                   varchar2(14 byte),
  mars_shpping_contnr_flag        varchar2(1 char),
  mars_plan_item_flag             varchar2(6 char)
);

/**/
/* Indexes  
/**/
create index bds.bds_material_plant_idx01 on bds.bds_material_plant_mfanz(material_type);
create index bds.bds_material_plant_idx02 on bds.bds_material_plant_mfanz(plant_code);
create index bds.bds_material_plant_idx03 on bds.bds_material_plant_mfanz(procurement_type, special_procurement_type);
create index bds.bds_material_plant_idx04 on bds.bds_material_plant_mfanz(mars_plant_material_type);
create index bds.bds_material_plant_idx05 on bds.bds_material_plant_mfanz(plant_code,sap_material_code,plant_specific_status,material_division,material_type,mars_traded_unit_flag,mrp_type);
create index bds.bds_material_plant_idx06 on bds.bds_material_plant_mfanz(plant_code,material_type);
create index bds.bds_material_plant_idx07 on bds.bds_material_plant_mfanz(mars_traded_unit_flag);
create index bds.bds_material_plant_idx08 on bds.bds_material_plant_mfanz(mars_retail_sales_unit_flag);
create index bds.bds_material_plant_idx09 on bds.bds_material_plant_mfanz(mars_intrmdt_prdct_compnt_flag);
create index bds.bds_material_plant_idx10 on bds.bds_material_plant_mfanz(mrp_controller,plant_code);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_material_plant_mfanz 
  add constraint bds_mat_plant_mfanz_test_pk primary key (sap_material_code, plant_code);
 
/**/
/* Authority 
/**/
grant select, delete, insert, update on bds.bds_material_plant_mfanz to bds_app with grant option;
grant select on bds.bds_material_plant_mfanz to manu_app with grant option;
grant select on bds.bds_material_plant_mfanz to pt_app with grant option;
grant select on bds.bds_material_plant_mfanz to manu with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_material_plant_mfanz for bds.bds_material_plant_mfanz;
