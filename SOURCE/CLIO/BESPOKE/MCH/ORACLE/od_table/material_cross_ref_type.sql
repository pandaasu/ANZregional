/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_cross_ref_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Material Cross Reference Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.material_cross_ref_type
   (sap_matl_cross_ref_type_code   varchar2(5 char)    not null,
    material_cross_ref_type_desc   varchar2(16 char),
    material_cross_ref_type_lupdp  varchar2(8 char)    not null,
    material_cross_ref_type_lupdt  date                not null);

/**/
/* Comments
/**/
comment on table od.material_cross_ref_type is 'Material Cross Reference Type Table';
comment on column od.material_cross_ref_type.sap_matl_cross_ref_type_code is 'SAP Material Cross Reference Type Code';
comment on column od.material_cross_ref_type.material_cross_ref_type_desc is 'Material Cross Reference Type Description';
comment on column od.material_cross_ref_type.material_cross_ref_type_lupdp is 'Last Updated Person';
comment on column od.material_cross_ref_type.material_cross_ref_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.material_cross_ref_type
   add constraint material_cross_ref_type_pk primary key (sap_matl_cross_ref_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.material_cross_ref_type to dw_app;
grant select on od.material_cross_ref_type to od_app with grant option;
grant select on od.material_cross_ref_type to od_user;
grant select on od.material_cross_ref_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym material_cross_ref_type for od.material_cross_ref_type;