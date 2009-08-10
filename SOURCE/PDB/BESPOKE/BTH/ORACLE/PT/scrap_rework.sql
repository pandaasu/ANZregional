/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : scrap_rework 
 Owner   : pt
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - scrap_rework

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt.scrap_rework
(
  scrap_rework_id    number                     not null,
  sent_flag          varchar2(1 byte),
  proc_order         varchar2(12 byte),
  matl_code          varchar2(18 byte)          not null,
  plt_code           varchar2(18 byte),
  qty                number                     not null,
  uom                varchar2(4 byte),
  storage_locn       varchar2(4 byte),
  batch_code         varchar2(10 byte),
  event_datime       date,
  plant_code         varchar2(4 byte)           not null,
  scrap_rework_code  varchar2(1 byte)           not null,
  reason_code        varchar2(4 byte),
  rework_code        varchar2(18 byte),
  rework_batch_code  varchar2(10 byte),
  rework_exp_date    date,
  rework_sloc        varchar2(4 byte),
  cost_centre        varchar2(32 byte),
  bin_code           varchar2(32 byte),
  area_in_code       varchar2(32 byte),
  area_out_code      varchar2(32 byte),
  status_code        varchar2(10 byte)
);

/**/
/* Comments 
/**/
comment on column pt.scrap_rework.scrap_rework_code is '''R'' = rework; ''S'' = scrap';

/**/
/* Authority 
/**/
grant select on pt.scrap_rework to appsupport;
grant select on pt.scrap_rework to pt_app with grant option;
grant delete, insert, update on pt.scrap_rework to pt_app;

/**/
/* Synonym 
/**/
create or replace public synonym scrap_rework for pt.scrap_rework;