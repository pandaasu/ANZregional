/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : plt_hdr_ics  
 Owner   : pt 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - plt_hdr_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt_app.plt_hdr_ics
(
  plt_code            varchar2(20 byte)         not null,
  matl_code           varchar2(8 byte)          not null,
  qty                 number(12,3)              not null,
  status              varchar2(12 byte)         not null,
  plant_code          varchar2(4 byte)          not null,
  zpppi_batch         varchar2(10 byte),
  proc_order          varchar2(12 byte)         not null,
  stor_locn_code      varchar2(4 byte),
  dispn_code          varchar2(1 byte),
  use_by_date         date,
  last_gr_flag        varchar2(1 byte),
  plt_create_datime   date,
  uom                 varchar2(4 byte),
  full_plt_flag       varchar2(1 byte),
  plt_type            varchar2(1 byte)          default 'a',
  start_prodn_datime  date,
  end_prodn_datime    date
);

/**/
/* Column Comments
/**/
comment on column pt_app.plt_hdr_ics.plt_code is 'Uniquie Pallet code supplied by Interface';
comment on column pt_app.plt_hdr_ics.matl_code is 'Material Code based on MATERIAL_VW';
comment on column pt_app.plt_hdr_ics.qty is 'Qty on Pallet';
comment on column pt_app.plt_hdr_ics.status is 'Current Status - CREATE, CANCEL etc';
comment on column pt_app.plt_hdr_ics.plant_code is 'Curren Plant Code';
comment on column pt_app.plt_hdr_ics.zpppi_batch is 'Batch Code';
comment on column pt_app.plt_hdr_ics.proc_order is 'Proc Order from Atlas';
comment on column pt_app.plt_hdr_ics.stor_locn_code is 'Defined in Material View';

/**/
/* Primary Key Constraint 
/**/
alter table pt_app.plt_hdr_ics add constraint pk_plt_hdr_ics primary key (plt_code);

/**/
/* Authority 
/**/
grant select on pt_app.plt_hdr_ics to ev_app;
grant select on pt_app.plt_hdr_ics to manu_user;
--grant select on pt_app.plt_hdr_ics to pt_app with grant option;
grant select on pt_app.plt_hdr_ics to manu_app with grant option;
--grant delete, insert, update on pt_app.plt_hdr_ics to pt_app;
grant delete, insert, update, select on pt_app.plt_hdr_ics to appsupport;
grant delete, insert, update, select on pt_app.plt_hdr_ics to sitesupport;

/**/
/* Synonym 
/**/
create or replace public synonym plt_hdr_ics for pt_app.plt_hdr_ics;