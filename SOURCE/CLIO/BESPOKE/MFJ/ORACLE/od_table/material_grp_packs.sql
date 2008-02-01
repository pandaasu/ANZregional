/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_grp_packs
 Owner  : od

 Description
 -----------
 Operational Data Store - Material Group Packs Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.material_grp_packs
   (sap_material_grp_packs_code  varchar2(4 char)      not null,
    material_grp_packs_desc      varchar2(40 char)     not null,
    material_grp_packs_lupdp     varchar2(8 char)      not null,
    material_grp_packs_lupdt     date                  not null);

/**/
/* Comments
/**/
comment on table od.material_grp_packs is 'Material Group Packs Table';
comment on column od.material_grp_packs.sap_material_grp_packs_code is 'SAP Material Group Packs Code';
comment on column od.material_grp_packs.material_grp_packs_desc is 'Material Group Packs Description';
comment on column od.material_grp_packs.material_grp_packs_lupdp is 'Last Updated Person';
comment on column od.material_grp_packs.material_grp_packs_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.material_grp_packs
   add constraint material_grp_packs_pk primary key (sap_material_grp_packs_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.material_grp_packs to dw_app;
grant select on od.material_grp_packs to od_app with grant option;
grant select on od.material_grp_packs to od_user;
grant select on od.material_grp_packs to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym material_grp_packs for od.material_grp_packs;