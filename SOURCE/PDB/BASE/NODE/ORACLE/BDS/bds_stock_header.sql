/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_stock_header 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_stock_header 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_stock_header
(
  company_code           varchar2(3 char)       not null,
  plant_code             varchar2(4 char)       not null,
  storage_location_code  varchar2(4 char)       not null,
  stock_balance_date     varchar2(8 char)       not null,
  stock_balance_time     varchar2(8 char)       not null,
  company_identifier     varchar2(6 char),
  inventory_document     varchar2(10 char),
  msg_timestamp          varchar2(14 char)
);


/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_stock_header
   add constraint bds_stock_header_pk primary key (company_code, plant_code, storage_location_code, stock_balance_date, stock_balance_time);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_stock_header to bds_app with grant option;
grant select on bds.bds_stock_header to appsupport;
grant select on bds.bds_stock_header to fcs_user;

/**/
/* Synonym 
/**/
create or replace public synonym bds_stock_header for bds.bds_stock_header;