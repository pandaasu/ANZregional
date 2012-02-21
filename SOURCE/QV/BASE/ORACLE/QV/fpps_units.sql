/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : fpps_units
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - fpps_units 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/05   Trevor Keon    Created 
 2011/12   Trevor Keon    Altered FUN_UNIT column to be varchar2 instead of number

*******************************************************************************/

/**/
/* Table creation
/**/
create table fpps_units
(
  fun_version   number not null,
  fun_unit      varchar2(20 char) not null,
  fun_desc      varchar2(50 char) not null
);

/**/
/* Comments 
/**/
comment on table fpps_units is 'FPPS - Unit Master Data';
comment on column fpps_units.fun_version is 'FPPS Unit - load version';
comment on column fpps_units.fun_unit is 'FPPS Unit - unit';
comment on column fpps_units.fun_desc is 'FPPS Unit - unit description';

/**/
/* Primary Key Constraint 
/**/
alter table fpps_units
   add constraint fpps_units_pk primary key (fun_version, fun_unit);

/**/
/* Authority 
/**/
grant select, insert, update, delete on fpps_units to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym fpps_units for qv.fpps_units;

/**/
/* Sequence 
/**/
create sequence fpps_units_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on fpps_units_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym fpps_units_seq for qv.fpps_units_seq;