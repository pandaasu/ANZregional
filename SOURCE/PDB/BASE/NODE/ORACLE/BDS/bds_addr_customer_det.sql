/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_addr_customer_det 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_addr_customer_det 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_addr_customer_det
(
  customer_code        varchar2(10 char)        not null,
  address_version      varchar2(5 char)         not null,
  valid_from_date      date                     not null,
  valid_to_date        date                     not null,
  title                varchar2(4 char),
  name                 varchar2(40 char),
  name_02              varchar2(40 char),
  name_03              varchar2(40 char),
  name_04              varchar2(40 char),
  city                 varchar2(40 char),
  district             varchar2(40 char),
  city_post_code       varchar2(10 char),
  po_box_post_code     varchar2(10 char),
  company_post_code    varchar2(10 char),
  po_box               varchar2(10 char),
  po_box_minus_number  varchar2(1 char),
  po_box_city          varchar2(40 char),
  po_box_region        varchar2(3 char),
  po_box_country       varchar2(3 char),
  po_box_country_iso   varchar2(2 char),
  transportation_zone  varchar2(10 char),
  street               varchar2(60 char),
  house_number         varchar2(10 char),
  location             varchar2(40 char),
  building             varchar2(20 char),
  floor                varchar2(10 char),
  room_number          varchar2(10 char),
  country              varchar2(3 char),
  country_iso          varchar2(2 char),
  language             varchar2(1 char),
  language_iso         varchar2(2 char),
  region_code          varchar2(3 char),
  search_term_01       varchar2(20 char),
  search_term_02       varchar2(20 char),
  phone_number         varchar2(30 char),
  phone_extension      varchar2(10 char),
  phone_full_number    varchar2(30 char),
  fax_number           varchar2(30 char),
  fax_extension        varchar2(10 char),
  fax_full_number      varchar2(30 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_addr_customer_det
   add constraint bds_addr_customer_det_pk primary key (customer_code, address_version, valid_from_date, valid_to_date);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_addr_customer_det to bds_app with grant option;
grant select on bds.bds_addr_customer_det to manu_app with grant option;
grant select on bds.bds_addr_customer_det to pt_app with grant option;
grant select on bds.bds_addr_customer_det to manu with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_addr_customer_det for bds.bds_addr_customer_det;



