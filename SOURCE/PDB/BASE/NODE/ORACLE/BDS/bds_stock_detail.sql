/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_stock_detail 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_stock_detail 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 
 2008/10   Trevor Keon    Added detseq column and updated PK

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_stock_detail
(
  company_code                   varchar2(3 char) not null,
  plant_code                     varchar2(4 char) not null,
  storage_location_code          varchar2(4 char) not null,
  stock_balance_date             varchar2(8 char) not null,
  stock_balance_time             varchar2(8 char) not null,
  material_code                  varchar2(18 char) not null,
  material_batch_number          varchar2(10 char),
  inspection_stock_flag          varchar2(1 char),
  stock_quantity                 number,
  stock_uom_code                 varchar2(3 char),
  stock_best_before_date         varchar2(8 char),
  consignment_cust_vend          varchar2(10 char),
  rcv_isu_storage_location_code  varchar2(4 char),
  stock_type_code                varchar2(2 char),
  detseq			                   number not null
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_stock_detail
   add constraint bds_stock_detail_pk primary key (company_code, plant_code, storage_location_code, stock_balance_date, stock_balance_time, material_code, detseq);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_stock_detail to bds_app with grant option;
grant select on bds.bds_stock_detail to manu_app with grant option;
grant select on bds.bds_stock_detail to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_stock_detail for bds.bds_stock_detail;
