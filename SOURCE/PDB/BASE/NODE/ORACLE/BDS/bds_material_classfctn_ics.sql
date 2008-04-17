/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_material_classfctn_ics 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_material_classfctn_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_material_classfctn_ics
(
  sap_material_code            varchar2(18 char) not null,
  bds_lads_date                date,
  bds_lads_status              varchar2(2 char),
  sap_idoc_name                varchar2(30 char),
  sap_idoc_number              number,
  sap_idoc_timestamp           varchar2(14 char),
  sap_bus_sgmnt_code           varchar2(30 char),
  sap_mrkt_sgmnt_code          varchar2(30 char),
  sap_brand_flag_code          varchar2(30 char),
  sap_funcl_vrty_code          varchar2(30 char),
  sap_ingrdnt_vrty_code        varchar2(30 char),
  sap_brand_sub_flag_code      varchar2(30 char),
  sap_supply_sgmnt_code        varchar2(30 char),
  sap_trade_sector_code        varchar2(30 char),
  sap_occsn_code               varchar2(30 char),
  sap_mrkting_concpt_code      varchar2(30 char),
  sap_multi_pack_qty_code      varchar2(30 char),
  sap_prdct_ctgry_code         varchar2(30 char),
  sap_pack_type_code           varchar2(30 char),
  sap_size_code                varchar2(30 char),
  sap_size_grp_code            varchar2(30 char),
  sap_prdct_type_code          varchar2(30 char),
  sap_trad_unit_config_code    varchar2(30 char),
  sap_trad_unit_frmt_code      varchar2(30 char),
  sap_dsply_storg_condtn_code  varchar2(30 char),
  sap_onpack_cnsmr_value_code  varchar2(30 char),
  sap_onpack_cnsmr_offer_code  varchar2(30 char),
  sap_onpack_trade_offer_code  varchar2(30 char),
  sap_brand_essnc_code         varchar2(30 char),
  sap_cnsmr_pack_frmt_code     varchar2(30 char),
  sap_cuisine_code             varchar2(30 char),
  sap_fpps_minor_pack_code     varchar2(30 char),
  sap_fighting_unit_code       varchar2(30 char),
  sap_china_bdt_code           varchar2(30 char),
  sap_mrkt_ctgry_code          varchar2(30 char),
  sap_mrkt_sub_ctgry_code      varchar2(30 char),
  sap_mrkt_sub_ctgry_grp_code  varchar2(30 char),
  sap_sop_bus_code             varchar2(30 char),
  sap_prodctn_line_code        varchar2(30 char),
  sap_planning_src_code        varchar2(30 char),
  sap_sub_fighting_unit_code   varchar2(30 char),
  sap_raw_family_code          varchar2(30 char),
  sap_raw_sub_family_code      varchar2(30 char),
  sap_raw_group_code           varchar2(30 char),
  sap_animal_parts_code        varchar2(30 char),
  sap_physical_condtn_code     varchar2(30 char),
  sap_pack_family_code         varchar2(30 char),
  sap_pack_sub_family_code     varchar2(30 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_material_classfctn_ics
   add constraint bds_material_classfctn_ics_pk primary key (sap_material_code);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_material_classfctn_ics to bds_app with grant option;
grant select on bds.bds_material_classfctn_ics to appsupport;
grant select on bds.bds_material_classfctn_ics to fcs_user;

/**/
/* Synonym 
/**/
create or replace public synonym bds_material_classfctn_ics for bds.bds_material_classfctn_ics;

