/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : manu 
 Table   : site_shiftlog_fg_matl
 Owner   : manu 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Manufacturing - site_shiftlog_fg_matl

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/11   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table manu.site_shiftlog_fg_matl
(
  matl_code       varchar2(54 char) not null,
  matl_desc       varchar2(120 char),
  units_per_case  number,
  gross_wght      number,
  gross_wght_uom  varchar2(9 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table manu.site_shiftlog_fg_matl 
  add constraint site_shiftlog_fg_matl_pk primary key (matl_code);

/**/
/* Authority 
/**/
grant select, update, delete, insert on manu.site_shiftlog_fg_matl to manu_app with grant option;
grant select on manu.site_shiftlog_fg_matl to shiftlog with grant option;
grant select on manu.site_shiftlog_fg_matl to shiftlog_app with grant option;
grant select on manu.site_shiftlog_fg_matl to manu_user;

/**/
/* Synonym 
/**/
create or replace public synonym site_shiftlog_fg_matl for manu.site_shiftlog_fg_matl;