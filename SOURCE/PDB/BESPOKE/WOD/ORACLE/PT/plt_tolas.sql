/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : plt_tolas_ics  
 Owner   : pt 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - plt_tolas_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt_app.plt_tolas_ics
(
  plt_code   varchar2(20 byte)                  not null,
  tolas_seq  varchar2(8 byte)
);

/**/
/* Indexes  
/**/
create index pt_app.plt_tolas_ics_idx01 on pt_app.plt_tolas_ics(plt_code);

/**/
/* Foreign Key Constraints  
/**/
alter table pt_app.plt_tolas_ics add constraint plt_tolas_ics_fk01 foreign key (plt_code) references pt_app.plt_hdr_ics (plt_code);

/**/
/* Authority 
/**/
grant select on pt_app.plt_tolas_ics to ev_app;
grant select on pt_app.plt_tolas_ics to manu_user;
--grant select on pt_app.plt_tolas_ics to pt_app with grant option;
grant select on pt_app.plt_tolas_ics to manu_app with grant option;
--grant delete, insert, update on pt_app.plt_tolas_ics to pt_app;
grant delete, insert, update on pt_app.plt_tolas_ics to manu_app;
grant delete, insert, update, select on pt_app.plt_tolas_ics to appsupport;
grant delete, insert, update, select on pt_app.plt_tolas_ics to sitesupport;

/**/
/* Synonym 
/**/
create or replace public synonym plt_tolas_ics for pt_app.plt_tolas_ics;