/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_refrnc_plant_ics  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_refrnc_plant_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/** Named _ics until testing is completed **/

/**/
/* Table creation 
/**/
create table bds.bds_refrnc_plant_ics
(
  plant_code                     varchar2(4 char) not null,
  sap_idoc_number                number,
  sap_idoc_timestamp             varchar2(14 char),
  change_flag                    varchar2(1 char),
  plant_name                     varchar2(30 char),
  vltn_area                      varchar2(4 char),
  plant_customer_no              varchar2(10 char),
  plant_vendor_no                varchar2(10 char),
  factory_calendar_key           varchar2(2 char),
  plant_name_2                   varchar2(30 char),
  plant_street                   varchar2(30 char),
  plant_po_box                   varchar2(10 char),
  plant_post_code                varchar2(10 char),
  plant_city                     varchar2(25 char),
  plant_purchasing_organisation  varchar2(4 char),
  plant_sales_organisation       varchar2(4 char),
  batch_manage_indctr            varchar2(1 char),
  plant_condition_indctr         varchar2(1 char),
  source_list_indctr             varchar2(1 char),
  activate_reqrmnt_indctr        varchar2(1 char),
  plant_country_key              varchar2(3 char),
  plant_region                   varchar2(3 char),
  plant_country_code             varchar2(3 char),
  plant_city_code                varchar2(4 char),
  plant_address                  varchar2(10 char),
  maint_planning_plant           varchar2(4 char),
  tax_jurisdiction_code          varchar2(15 char),
  dstrbtn_channel                varchar2(2 char),
  division                       varchar2(2 char),
  language_key                   varchar2(1 char),
  sop_plant                      varchar2(1 char),
  variance_key                   varchar2(6 char),
  batch_manage_old_indctr        varchar2(1 char),
  plant_ctgry                    varchar2(1 char),
  plant_sales_district           varchar2(6 char),
  plant_supply_region            varchar2(10 char),
  plant_tax_indctr               varchar2(1 char),
  regular_vendor_indctr          varchar2(1 char),
  first_reminder_days            varchar2(3 char),
  second_reminder_days           varchar2(3 char),
  third_reminder_days            varchar2(3 char),
  vendor_declaration_text_1      varchar2(16 char),
  vendor_declaration_text_2      varchar2(16 char),
  vendor_declaration_text_3      varchar2(16 char),
  po_tolerance_days              varchar2(3 char),
  plant_business_place           varchar2(4 char),
  stock_xfer_rule                varchar2(2 char),
  plant_dstrbtn_profile          varchar2(3 char),
  central_archive_marker         varchar2(1 char),
  dms_type_indctr                varchar2(1 char),
  node_type                      varchar2(3 char),
  name_formation_structure       varchar2(4 char),
  cost_control_active_indctr     varchar2(1 char),
  mixed_costing_active_indctr    varchar2(1 char),
  actual_costing_active_indctr   varchar2(1 char),
  transport_point                varchar2(4 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_refrnc_plant_ics 
  add constraint bds_refrnc_plant_ics_pk primary key (plant_code);
 
/**/
/* Authority 
/**/
grant select, insert, update, delete on bds_refrnc_plant_ics to bds_app with grant option;
grant select on bds.bds_refrnc_plant_ics to manu_app with grant option;
grant select on bds.bds_refrnc_plant_ics to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_refrnc_plant_ics for bds.bds_refrnc_plant_ics;
