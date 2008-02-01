/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Material Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.material_type
   (sap_material_type_code  varchar2(4 char)           not null,
    material_type_desc      varchar2(40 char)          not null,
    material_type_lupdp     varchar2(8 char)           not null,
    material_type_lupdt     date                       not null);

/**/
/* Comments
/**/
comment on table od.material_type is 'Material Type Table';
comment on column od.material_type.sap_material_type_code is 'SAP Material Type Code';
comment on column od.material_type.material_type_desc is 'Material Type Description';
comment on column od.material_type.material_type_lupdp is 'Last Updated Person';
comment on column od.material_type.material_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.material_type
   add constraint material_type_pk primary key (sap_material_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.material_type to dw_app;
grant select on od.material_type to od_app with grant option;
grant select on od.material_type to od_user;
grant select on od.material_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym material_type for od.material_type;