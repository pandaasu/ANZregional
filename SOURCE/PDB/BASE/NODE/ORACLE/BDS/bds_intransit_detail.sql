/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_intransit_detail 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_intransit_detail 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_intransit_detail
(
  plant_code                    varchar2(4 char) not null,
  detseq                        number          not null,
  company_code                  varchar2(4 char),
  business_segment_code         number,
  cnn_number                    varchar2(35 char),
  purch_order_number            varchar2(10 char),
  vendor_code                   varchar2(10 char),
  shipment_number               varchar2(10 char),
  inbound_delivery_number       varchar2(10 char),
  source_plant_code             varchar2(4 char),
  source_storage_location_code  varchar2(4 char),
  shipping_plant_code           varchar2(4 char),
  target_storage_location_code  varchar2(4 char),
  target_mrp_plant_code         varchar2(4 char),
  shipping_date                 varchar2(8 char),
  arrival_date                  varchar2(8 char),
  maturation_date               varchar2(8 char),
  batch_number                  varchar2(10 char),
  best_before_date              varchar2(8 char),
  transportation_model_code     varchar2(2 char),
  forward_agent_code            varchar2(10 char),
  forward_agent_trailer_number  varchar2(10 char),
  material_code                 varchar2(18 char),
  quantity                      number,
  uom_code                      varchar2(3 char),
  stock_type_code               varchar2(1 char),
  order_type_code               varchar2(4 char),
  container_number              varchar2(20 char),
  seal_number                   varchar2(40 char),
  vessel_name                   varchar2(20 char),
  voyage                        varchar2(20 char),
  record_sequence               varchar2(15 char),
  record_count                  varchar2(15 char),
  record_timestamp              varchar2(18 char)
);


/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_intransit_detail
   add constraint bds_intransit_detail_pk primary key (plant_code, detseq);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_intransit_detail to bds_app with grant option;
grant select on bds.bds_intransit_detail to appsupport;
grant select on bds.bds_intransit_detail to fcs_user;

/**/
/* Synonym 
/**/
create or replace public synonym bds_intransit_detail for bds.bds_intransit_detail;