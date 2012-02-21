/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : shp_route_dim
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - shp_route_dim 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/12   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table shp_route_dim
(
  srd_version         number not null,
  srd_route_code      varchar2(10) not null,
  srd_route_desc      varchar2(100) not null
);

/**/
/* Comments 
/**/
comment on table shp_route_dim is 'SHP - Route Dimension';
comment on column shp_route_dim.srd_version is 'SHP Route - load version';
comment on column shp_route_dim.srd_route_code is 'SHP Route - route code';
comment on column shp_route_dim.srd_route_desc is 'SHP Route - route description';

/**/
/* Authority 
/**/
grant select, insert, update, delete on shp_route_dim to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym shp_route_dim for qv.shp_route_dim;

/**/
/* Sequence 
/**/
create sequence shp_route_dim_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on shp_route_dim_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym shp_route_dim_seq for qv.shp_route_dim_seq;