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

create table bds.bds_refrnc_hdr_altrnt
(
  bom_material_code  varchar2(18 char)          not null,
  bom_alternative    varchar2(2 char),
  bom_plant          varchar2(4 char)           not null,
  bom_usage          varchar2(1 char)           not null,
  bom_eff_from_date  date                       not null
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_refrnc_hdr_altrnt
  add constraint bds_refrnc_hdr_altrnt_pk primary key (bom_material_code, bom_plant, bom_usage, bom_eff_from_date);
 
/**/
/* Authority 
/**/
grant select, delete, insert, update on bds.bds_refrnc_hdr_altrnt to bds_app;
grant select on bds.bds_refrnc_hdr_altrnt to appsupport;
grant select on bds.bds_refrnc_hdr_altrnt to fcs_user;
grant select on bds.bds_refrnc_hdr_altrnt to public;

/**/
/* Synonym 
/**/
create or replace public synonym bds_refrnc_hdr_altrnt for bds.bds_refrnc_hdr_altrnt;