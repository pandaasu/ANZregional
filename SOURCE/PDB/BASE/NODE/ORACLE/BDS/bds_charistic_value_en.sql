/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_charistic_value_en  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_charistic_value_en 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/05   Trevor Keon    Created 

*******************************************************************************/

/** Named _ics until testing is completed **/

/**/
/* Table creation 
/**/
create table bds.bds_charistic_value_en
(
  sap_charistic_code        varchar2(30 char)   not null,
  sap_charistic_value_code  varchar2(30 char)   not null,
  sap_charistic_value_desc  varchar2(30 char)
);

/**/
/* Indexes  
/**/
create unique index bds.bds_charistic_value_en_pk on bds.bds_charistic_value_en (sap_charistic_code, sap_charistic_value_code);
 
/**/
/* Authority 
/**/
grant select, insert, update, delete on bds.bds_charistic_value_en to bds_app with grant option;
grant select on bds.bds_charistic_value_en to manu_app with grant option;
grant select on bds.bds_charistic_value_en to pt_app with grant option;
grant select on bds.bds_charistic_value_en to manu with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_charistic_value_en for bds.bds_charistic_value_en;
