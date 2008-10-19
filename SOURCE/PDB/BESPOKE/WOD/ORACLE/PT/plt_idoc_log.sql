/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : plt_idoc_log_ics  
 Owner   : pt 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - plt_idoc_log_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt_app.plt_idoc_log_ics
(
  plt_code      varchar2(20 byte)               not null,
  xactn_type    varchar2(10 byte)               not null,
  resend_count  number                          not null,
  status        varchar2(12 byte),
  err_mesg      varchar2(512 byte),
  log_datime    date                            not null,
  err_num       number
);

/**/
/* Primary Key Constraint 
/**/
alter table pt_app.plt_idoc_log_ics add constraint pk_plt_idoc_log_ics primary key (plt_code, xactn_type, resend_count);

/**/
/* Foreign Key Constraints  
/**/
alter table pt_app.plt_idoc_log_ics add constraint fk2_plt_code foreign key (plt_code) references pt_app.plt_hdr_ics (plt_code);

/**/
/* Authority 
/**/
grant select on pt_app.plt_idoc_log_ics to ev_app;
grant select on pt_app.plt_idoc_log_ics to manu_user;
--grant select on pt_app.plt_idoc_log_ics to pt_app with grant option;
grant select on pt_app.plt_idoc_log_ics to manu_app with grant option;
--grant delete, insert, update on pt_app.plt_idoc_log_ics to pt_app;
grant delete, insert, update on pt_app.plt_idoc_log_ics to manu_app;
grant delete, insert, update, select on pt_app.plt_idoc_log_ics to appsupport;
grant delete, insert, update, select on pt_app.plt_idoc_log_ics to sitesupport;

/**/
/* Synonym 
/**/
create or replace public synonym plt_idoc_log_ics for pt_app.plt_idoc_log_ics;