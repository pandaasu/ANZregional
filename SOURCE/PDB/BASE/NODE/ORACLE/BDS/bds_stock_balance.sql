/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_stock_balance
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_stock_balance

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/10   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_stock_balance
(
  company_code                   varchar2(4 char)   not null,
  plant_code                     varchar2(4 char)   not null,
  storage_location_code          varchar2(36 char)  not null,
  stock_balance_date             varchar2(8 char)   not null,
  stock_balance_time             varchar2(8 char)   not null,
  material_code                  varchar2(18 char),
  material_batch_number          varchar2(10 char),
  inspection_stock_flag          varchar2(1 char),
  stock_quantity                 number,
  stock_uom_code                 varchar2(3 char),
  stock_best_before_date         varchar2(8 char),
  consignment_cust_vend          varchar2(10 char),
  rcv_isu_storage_location_code  varchar2(4 char),
  stock_type_code                varchar2(18 char)
);

/**/
/* Indexes 
/**/
create index bds.bds_stock_balance_idx01 on bds.bds_stock_balance(company_code, plant_code, storage_location_code, stock_balance_date, stock_balance_time);

/**/
/* Authority 
/**/
grant select, delete, insert, update on bds.bds_stock_balance to bds_app with grant option;
grant select on bds.bds_stock_balance to manu with grant option;
grant select on bds.bds_stock_balance to manu_app with grant option;
grant select on bds.bds_stock_balance to appsupport;
grant select on bds.bds_stock_balance to dco_app;
grant select on bds.bds_stock_balance to fcs_reader;
grant select on bds.bds_stock_balance to pplan_app;
grant select on bds.bds_stock_balance to pkgspec_app;
grant select on bds.bds_stock_balance to esched_app;

/**/
/* Synonym 
/**/
create or replace public synonym bds_stock_balance for bds.bds_stock_balance;