/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : plt_reclaim
 Owner   : pt
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - plt_reclaim

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt.plt_reclaim
(
  reclaim_ltds_id   number                      not null,
  plt_code          varchar2(18 byte),
  material_code     varchar2(18 byte),
  qty               number,
  plant_code        varchar2(4 byte),
  proc_order        varchar2(12 byte),
  dispn_code        varchar2(4 byte),
  batch_code        varchar2(30 byte),
  use_by_date       date,
  transaction_type  varchar2(10 byte),
  last_upd_by       varchar2(30 byte),
  last_upd_datime   date
);

/**/
/* Primary Key Constraint 
/**/
alter table pt.plt_reclaim
   add constraint plt_reclaim_pk01 primary key (reclaim_ltds_id);

/**/
/* Authority 
/**/
grant select on pt.plt_reclaim to appsupport;
grant select on pt.plt_reclaim to pt_app with grant option;
grant delete, insert, update on pt.plt_reclaim to pt_app;

/**/
/* Synonym 
/**/
create or replace public synonym plt_reclaim for pt.plt_reclaim;
