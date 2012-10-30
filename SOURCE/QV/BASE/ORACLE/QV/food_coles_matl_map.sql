/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : food_coles_matl_map
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - food_coles_matl_map 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2012/07   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table food_coles_matl_map
(
  fcmm_version      number not null,
  fcmm_rep_item     varchar2(18 char) not null,
  fcmm_coles_code   varchar2(18 char) not null
);

/**/
/* Comments 
/**/
comment on table food_coles_matl_map is 'Food Coles Material Mapping';
comment on column food_coles_matl_map.fcmm_version is 'Food Coles Material Mapping - load version';
comment on column food_coles_matl_map.fcmm_rep_item is 'Food Coles Material Mapping - ZREP code';
comment on column food_coles_matl_map.fcmm_coles_code is 'Food Coles Material Mapping - Coles code';

/**/
/* Primary Key Constraint 
/**/
alter table food_coles_matl_map 
   add constraint food_coles_matl_map_pk primary key (fcmm_coles_code, fcmm_rep_item);

/**/
/* Authority 
/**/
grant select, insert, update, delete on food_coles_matl_map to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym food_coles_matl_map for qv.food_coles_matl_map;

/**/
/* Sequence 
/**/
create sequence food_coles_matl_map_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on food_coles_matl_map_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym food_coles_matl_map_seq for qv.food_coles_matl_map_seq;