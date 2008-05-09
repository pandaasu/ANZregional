/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_refrnc_prchsing_src_ics  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_refrnc_prchsing_src_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/** Named _ics until testing is completed **/

/**/
/* Table creation 
/**/
create table bds.bds_refrnc_prchsing_src_ics
(
  sap_material_code              varchar2(18 char) not null,
  plant_code                     varchar2(4 char) not null,
  record_no                      varchar2(5 char) not null,
  creatn_date                    date,
  creatn_user                    varchar2(12 char),
  src_list_valid_from            date,
  src_list_valid_to              date,
  vendor_code                    varchar2(10 char),
  fixed_vendor_indctr            varchar2(1 char),
  agreement_no                   varchar2(10 char),
  agreement_item                 varchar2(5 char),
  fixed_purchase_agreement_item  varchar2(1 char),
  plant_procured_from            varchar2(4 char),
  sto_fixed_issuing_plant        varchar2(1 char),
  manufctr_part_refrnc_material  varchar2(18 char),
  blocked_supply_src_flag        varchar2(1 char),
  purchasing_organisation        varchar2(4 char),
  purchasing_document_ctgry      varchar2(1 char),
  src_list_ctgry                 varchar2(1 char),
  src_list_planning_usage        varchar2(1 char),
  order_unit                     varchar2(3 char),
  logical_system                 varchar2(10 char),
  special_stock_indctr           varchar2(1 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_refrnc_prchsing_src_ics 
  add constraint bds_refrnc_prchsing_src_ics_pk primary key (sap_material_code, plant_code, record_no);
 
/**/
/* Authority 
/**/
grant select, insert, update, delete on bds_refrnc_prchsing_src_ics to bds_app with grant option;
grant select on bds.bds_refrnc_prchsing_src_ics to manu_app with grant option;
grant select on bds.bds_refrnc_prchsing_src_ics to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_refrnc_prchsing_src_ics for bds.bds_refrnc_prchsing_src_ics;
