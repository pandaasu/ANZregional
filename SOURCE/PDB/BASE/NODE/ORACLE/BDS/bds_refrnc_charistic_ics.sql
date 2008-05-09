/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_refrnc_charistic_ics  
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_refrnc_charistic_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/** Named _ics until testing is completed **/

/**/
/* Table creation 
/**/
create table bds.bds_refrnc_charistic_ics
(
  sap_charistic_code             varchar2(30 char) not null,
  sap_charistic_value_code       varchar2(30 char) not null,
  sap_charistic_value_shrt_desc  varchar2(256 char),
  sap_charistic_value_long_desc  varchar2(256 char),
  sap_idoc_number                number,
  sap_idoc_timestamp             varchar2(14 char),
  change_flag                    varchar2(1 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_refrnc_charistic_ics 
  add constraint bds_refrnc_charistic_ics_pk primary key (sap_charistic_code, sap_charistic_value_code);
 
/**/
/* Authority 
/**/
grant delete, insert, select, update on bds.bds_refrnc_charistic_ics to bds_app with grant option;
grant select on bds.bds_refrnc_charistic_ics to manu_app with grant option;
grant select on bds.bds_refrnc_charistic_ics to pt_app with grant option;

/**/
/* Synonym 
/**/
create or replace public synonym bds_refrnc_charistic_ics for bds.bds_refrnc_charistic_ics;
