/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : plt_cnsmptn_ics  
 Owner   : pt 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - plt_cnsmptn_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt_app.plt_cnsmptn_ics
(
  plt_cnsmptn_ics_id  number,
  proc_order      varchar2(12 byte),
  matl_code       varchar2(8 byte),
  qty             number,
  uom             varchar2(4 byte),
  plant_code      varchar2(4 byte),
  sent_flag       varchar2(1 byte),
  store_locn      varchar2(4 byte),
  upd_datime      date,
  trans_id        number,
  trans_type      varchar2(20 byte)
);

/**/
/* Indexes  
/**/
create index pt_app.plt_cnsmptn_ics_idx01 on pt_app.plt_cnsmptn_ics(proc_order);
create index pt_app.plt_cnsmptn_ics_idx02 on pt_app.plt_cnsmptn_ics(matl_code);

/**/
/* Primary Key Constraint 
/**/
alter table pt_app.plt_cnsmptn_ics add constraint plt_cnsmptn_ics_pk1 primary key (plt_cnsmptn_ics_id);

/**/
/* Authority 
/**/
grant select on pt_app.plt_cnsmptn_ics to ev_app;
grant select on pt_app.plt_cnsmptn_ics to manu_user;
--grant select on pt_app.plt_cnsmptn_ics to pt_app with grant option;
grant select on pt_app.plt_cnsmptn_ics to manu_app with grant option;
--grant delete, insert, update on pt_app.plt_cnsmptn_ics to pt_app;
grant delete, insert, update on pt_app.plt_cnsmptn_ics to manu_app;
grant delete, insert, update, select on pt_app.plt_cnsmptn_ics to appsupport;
grant delete, insert, update, select on pt_app.plt_cnsmptn_ics to sitesupport;

/**/
/* Synonym 
/**/
create or replace public synonym plt_cnsmptn_ics for pt_app.plt_cnsmptn_ics;
