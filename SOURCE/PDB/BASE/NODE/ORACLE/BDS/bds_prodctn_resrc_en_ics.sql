/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_prodctn_resrc_en_ics  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_prodctn_resrc_en_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/** Named _ics until testing is completed **/

/**/
/* Table creation 
/**/
create table bds.bds_prodctn_resrc_en_ics
(
  resrc_id            varchar2(8 char)  not null,
  resrc_code          varchar2(8 char),
  resrc_text          varchar2(40 char),
  resrc_plant_code    varchar2(4 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_prodctn_resrc_en_ics 
  add constraint bds_prodctn_resrc_en_ics_pk primary key (resrc_id);
 
/**/
/* Authority 
/**/
grant select, insert, update, delete on bds_prodctn_resrc_en_ics to bds_app;
grant select on bds.bds_prodctn_resrc_en_ics to appsupport;
grant select on bds.bds_prodctn_resrc_en_ics to fcs_user;
grant select on bds.bds_prodctn_resrc_en_ics to public;

/**/
/* Synonym 
/**/
create public synonym bds_prodctn_resrc_en_ics for bds.bds_prodctn_resrc_en_ics;
