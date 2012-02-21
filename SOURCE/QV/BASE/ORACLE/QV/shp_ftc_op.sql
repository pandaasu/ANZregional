/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : shp_ftc_op
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - shp_ftc_op 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2011/02   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table shp_ftc_op
(
  sfo_version         number not null,
  sfo_accnt_assignmnt varchar2(5) not null,
  sfo_plant           varchar2(5) null,
  sfo_period          number not null,
  sfo_forecast        number not null
);

/**/
/* Comments 
/**/
comment on table shp_ftc_op is 'SHP - Sales Tonnes Operating Plan';
comment on column shp_ftc_op.sfo_version is 'SHP OP - load version';
comment on column shp_ftc_op.sfo_accnt_assignmnt is 'SHP OP - account assignment';
comment on column shp_ftc_op.sfo_plant is 'SHP OP - plant';
comment on column shp_ftc_op.sfo_period is 'SHP OP - period';
comment on column shp_ftc_op.sfo_forecast is 'SHP OP - forecast value';

/**/
/* Authority 
/**/
grant select, insert, update, delete on shp_ftc_op to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym shp_ftc_op for qv.shp_ftc_op;

/**/
/* Sequence 
/**/
create sequence shp_ftc_op_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on shp_ftc_op_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym shp_ftc_op_seq for qv.shp_ftc_op_seq;