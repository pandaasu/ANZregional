/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : au_coles_matl_map 
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - au_coles_matl_map 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2012/07   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table au_coles_matl_map
(
  acmm_version      number not null,
  acmm_rep_item     varchar2(18 char) not null,
  acmm_coles_code   varchar2(18 char) not null
);

/**/
/* Comments 
/**/
comment on table au_coles_matl_map is 'AU Coles Material Mapping';
comment on column au_coles_matl_map.acmm_version is 'AU Coles Material Mapping - load version';
comment on column au_coles_matl_map.acmm_rep_item is 'AU Coles Material Mapping - ZREP code';
comment on column au_coles_matl_map.acmm_coles_code is 'AU Coles Material Mapping - Coles code';

/**/
/* Primary Key Constraint 
/**/
alter table au_coles_matl_map 
   add constraint au_coles_matl_map_pk primary key (acmm_coles_code, acmm_rep_item);

/**/
/* Authority 
/**/
grant select, insert, update, delete on au_coles_matl_map to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym au_coles_matl_map for qv.au_coles_matl_map;

/**/
/* Sequence 
/**/
create sequence au_coles_matl_map_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on au_coles_matl_map_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym au_coles_matl_map_seq for qv.au_coles_matl_map_seq;