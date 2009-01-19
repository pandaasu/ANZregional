/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_prodctn_resrc_en  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_prodctn_resrc_en 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_prodctn_resrc_en
(
  resrc_id            varchar2(8 char)  not null,
  resrc_code          varchar2(8 char),
  resrc_text          varchar2(40 char),
  resrc_plant_code    varchar2(4 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_prodctn_resrc_en 
  add constraint bds_prodctn_resrc_en_pk primary key (resrc_id);
 
/**/
/* Authority 
/**/
grant select, insert, update, delete on bds_prodctn_resrc_en to bds_app with grant option;
grant select on bds.bds_prodctn_resrc_en to manu_app with grant option;
grant select on bds.bds_prodctn_resrc_en to pt_app with grant option;
grant select on bds.bds_prodctn_resrc_en to manu with grant option;

/**/
/* Synonym 
/**/
create public synonym bds_prodctn_resrc_en for bds.bds_prodctn_resrc_en;
