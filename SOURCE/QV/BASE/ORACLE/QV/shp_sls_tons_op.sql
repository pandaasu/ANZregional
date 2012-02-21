/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : shp_sls_tons_op
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - shp_sls_tons_op 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/02   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table shp_sls_tons_op
(
  sst_version         number not null,
  sst_accnt_assignmnt varchar2(5) not null,
  sst_plng_src        varchar2(5) not null,
  sst_period          number not null,
  sst_forecast        number not null
);

/**/
/* Comments 
/**/
comment on table shp_sls_tons_op is 'SHP - Sales Tonnes Operating Plan';
comment on column shp_sls_tons_op.sst_version is 'SHP OP - load version';
comment on column shp_sls_tons_op.sst_accnt_assignmnt is 'SHP OP - account assignment';
comment on column shp_sls_tons_op.sst_plng_src is 'SHP OP - planning source';
comment on column shp_sls_tons_op.sst_period is 'SHP OP - period';
comment on column shp_sls_tons_op.sst_forecast is 'SHP OP - forecast value';

/**/
/* Authority 
/**/
grant select, insert, update, delete on shp_sls_tons_op to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym shp_sls_tons_op for qv.shp_sls_tons_op;

/**/
/* Sequence 
/**/
create sequence shp_sls_tons_op_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on shp_sls_tons_op_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym shp_sls_tons_op_seq for qv.shp_sls_tons_op_seq;