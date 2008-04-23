/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_cust_sales_area_ics 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_cust_sales_area_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/* Named bds_cust_sales_area_ics for SNACK testing only */ 

/**/
/* Table creation 
/**/
create table bds.bds_cust_sales_area_ics
(
  customer_code                 varchar2(10 char) not null,
  sales_org_code                varchar2(5 char) not null,
  distbn_chnl_code              varchar2(5 char) not null,
  division_code                 varchar2(5 char) not null,
  auth_group_code               varchar2(4 char),
  deletion_flag                 varchar2(1 char),
  statistics_group              varchar2(1 char),
  order_block_flag              varchar2(2 char),
  pricing_procedure             varchar2(1 char),
  group_code                    varchar2(2 char),
  sales_district                varchar2(6 char),
  price_group                   varchar2(2 char),
  price_list_type               varchar2(2 char),
  order_probability             number,
  inter_company_terms_01        varchar2(3 char),
  inter_company_terms_02        varchar2(28 char),
  delivery_block_flag           varchar2(2 char),
  order_complete_delivery_flag  varchar2(1 char),
  partial_item_delivery_max     number,
  partial_item_delivery_flag    varchar2(1 char),
  order_combination_flag        varchar2(1 char),
  split_batch_flag              varchar2(1 char),
  delivery_priority             number,
  shipper_account_number        varchar2(12 char),
  ship_conditions               varchar2(2 char),
  billing_block_flag            varchar2(2 char),
  manual_invoice_flag           varchar2(1 char),
  invoice_dates                 varchar2(2 char),
  invoice_list_schedule         varchar2(2 char),
  currency_code                 varchar2(5 char),
  account_assign_group          varchar2(2 char),
  payment_terms_key             varchar2(4 char),
  delivery_plant_code           varchar2(4 char),
  sales_group_code              varchar2(3 char),
  sales_office_code             varchar2(4 char),
  item_proposal                 varchar2(10 char),
  invoice_combination           varchar2(3 char),
  price_band_expected           varchar2(3 char),
  accept_int_pallet             varchar2(3 char),
  price_band_guaranteed         varchar2(3 char),
  back_order_flag               varchar2(3 char),
  rebate_flag                   varchar2(1 char),
  exchange_rate_type            varchar2(4 char),
  price_determination_id        varchar2(1 char),
  abc_classification            varchar2(2 char),
  payment_guarantee_proc        varchar2(4 char),
  credit_control_area           varchar2(4 char),
  sales_block_flag              varchar2(2 char),
  rounding_off                  varchar2(1 char),
  agency_business_flag          varchar2(1 char),
  uom_group                     varchar2(4 char),
  over_delivery_tolerance       varchar2(4 char),
  under_delivery_tolerance      varchar2(4 char),
  unlimited_over_delivery       varchar2(1 char),
  product_proposal_proc         varchar2(2 char),
  pod_processing                varchar2(1 char),
  pod_confirm_timeframe         varchar2(11 char),
  po_index_compilation          varchar2(1 char),
  batch_search_strategy         number,
  vmi_input_method              number,
  current_planning_flag         varchar2(1 char),
  future_planning_flag          varchar2(1 char),
  market_account_flag           varchar2(1 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_cust_sales_area_ics
   add constraint bds_cust_sales_area_ics_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code);

/**/
/* Authority 
/**/
grant select, insert, update, delete on bds.bds_cust_sales_area_ics to bds_app with grant option;
grant select on bds.bds_cust_sales_area_ics to appsupport;
grant select on bds.bds_cust_sales_area_ics to fcs_user;
grant select on bds.bds_cust_sales_area_ics to public;

/**/
/* Synonym 
/**/
create public synonym bds_cust_sales_area_ics for bds.bds_cust_sales_area_ics;