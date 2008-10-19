/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : pt 
 Table   : plt_det_ics  
 Owner   : pt 
 Author  : Unknown

 Description 
 ----------- 
 Pallet Tagging - plt_det_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 ????/??   Unknown        Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table pt_app.plt_det_ics
(
  plt_code     varchar2(20 byte)                not null,
  xactn_type   varchar2(12 byte)                not null,
  user_id      varchar2(8 byte),
  reason       varchar2(12 byte),
  xactn_date   date                             not null,
  xactn_time   number,
  sender_name  varchar2(32 byte),
  sent_flag    varchar2(1 byte),
  atlas_type   varchar2(10 byte)
);

/**/
/* Column Comments
/**/
comment on column pt_app.plt_det_ics.xactn_type is 'Create or Cancel';
comment on column pt_app.plt_det_ics.user_id is 'User 5 + 3';

/**/
/* Primary Key Constraint 
/**/
alter table pt_app.plt_det_ics add constraint pk_plt_det_ics primary key (plt_code, xactn_type);

/**/
/* Foreign Key Constraints  
/**/
alter table pt_app.plt_det_ics add constraint fk1_plt_code foreign key (plt_code) references pt_app.plt_hdr_ics (plt_code);

/**/
/* Authority 
/**/
grant select on pt_app.plt_det_ics to ev_app;
grant select on pt_app.plt_det_ics to manu_user;
--grant select on pt_app.plt_det_ics to pt_app with grant option;
grant select on pt_app.plt_det_ics to manu_app with grant option;
--grant delete, insert, update on pt_app.plt_det_ics to pt_app;
grant delete, insert, update on pt_app.plt_det_ics to manu_app;
grant delete, insert, update, select on pt_app.plt_det_ics to appsupport;
grant delete, insert, update, select on pt_app.plt_det_ics to sitesupport;

/**/
/* Synonym 
/**/
create or replace public synonym plt_det_ics for pt_app.plt_det_ics;