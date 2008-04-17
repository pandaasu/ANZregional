/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_intransit_header 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_intransit_header 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_intransit_header
(
  plant_code            varchar2(4 char)        not null,
  target_planning_area  varchar2(10 char),
  msg_timestamp         varchar2(14 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_intransit_header
   add constraint bds_intransit_header_pk primary key (plant_code);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_intransit_header to bds_app with grant option;
grant select on bds.bds_intransit_header to appsupport;
grant select on bds.bds_intransit_header to fcs_user;

/**/
/* Synonym 
/**/
create or replace public synonym bds_intransit_header for bds.bds_intransit_header;
