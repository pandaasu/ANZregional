/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : qv 
 Table   : nz_demand_plng_regroup
 Owner   : qv 
 Author  : Trevor Keon 

 Description
 -----------
 Qlikview Loader - nz_demand_plng_regroup 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2010/09   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table nz_demand_plng_regroup
(
  dpr_version         number not null,
  dpr_regroup_dpg     varchar2(100) not null,
  dpr_demand_plng_grp varchar2(100) not null,
  dpr_regroup_abbr    varchar2(10) null,
  dpr_sort_order      number null
);

/**/
/* Comments 
/**/
comment on table nz_demand_plng_regroup is 'DBP - NZ Demand Planning Regroup';
comment on column nz_demand_plng_regroup.dpr_version is 'NZ Regroup - load version';
comment on column nz_demand_plng_regroup.dpr_regroup_dpg is 'NZ Regroup - regroup DPG';
comment on column nz_demand_plng_regroup.dpr_demand_plng_grp is 'NZ Regroup - demand planning group';
comment on column nz_demand_plng_regroup.dpr_regroup_abbr is 'NZ Regroup - regroup abbreviation';
comment on column nz_demand_plng_regroup.dpr_sort_order is 'NZ Regroup - sort order';

/**/
/* Authority 
/**/
grant select, insert, update, delete on nz_demand_plng_regroup to qv_app;

/**/
/* Synonym 
/**/
create or replace public synonym nz_demand_plng_regroup for qv.nz_demand_plng_regroup;

/**/
/* Sequence 
/**/
create sequence nz_dmnd_plng_regrp_seq
   increment by 1
   start with 1
   maxvalue 999999999999999
   minvalue 1
   nocycle
   nocache;
   
/**/
/* Authority
/**/
grant select on nz_dmnd_plng_regrp_seq to qv_app;

/**/
/* Synonym
/**/
create or replace public synonym nz_dmnd_plng_regrp_seq for qv.nz_dmnd_plng_regrp_seq;