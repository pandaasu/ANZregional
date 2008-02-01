/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_grp
 Owner  : od

 Description
 -----------
 Operational Data Store - Material Group Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.material_grp
   (sap_material_grp_code  varchar2(9 char)            not null,
    material_grp_desc      varchar2(40 char)           not null,
    material_grp_lupdp     varchar2(8 char)            not null,
    material_grp_lupdt     date                        not null);

/**/
/* Comments
/**/
comment on table od.material_grp is 'Material Group Table';
comment on column od.material_grp.sap_material_grp_code is 'SAP Material Group Code';
comment on column od.material_grp.material_grp_desc is 'Material Group Description';
comment on column od.material_grp.material_grp_lupdp is 'Last Updated Person';
comment on column od.material_grp.material_grp_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.material_grp
   add constraint material_grp_pk primary key (sap_material_grp_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.material_grp to dw_app;
grant select on od.material_grp to od_app with grant option;
grant select on od.material_grp to od_user;
grant select on od.material_grp to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym material_grp for od.material_grp;