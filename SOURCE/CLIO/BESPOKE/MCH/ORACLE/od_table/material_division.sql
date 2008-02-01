/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_division
 Owner  : od

 Description
 -----------
 Operational Data Store - Material Division Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.material_division
   (sap_material_division_code  varchar2(2 char)       not null,
    material_division_desc      varchar2(40 char)      not null,
    material_division_lupdp     varchar2(8 char)       not null,
    material_division_lupdt     date                   not null);

/**/
/* Comments
/**/
comment on table od.material_division is 'Material Division Table';
comment on column od.material_division.sap_material_division_code is 'SAP Material Division Code';
comment on column od.material_division.material_division_desc is 'Material Division Description';
comment on column od.material_division.material_division_lupdp is 'Last Updated Person';
comment on column od.material_division.material_division_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.material_division
   add constraint material_division_pk primary key (sap_material_division_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.material_division to dw_app;
grant select on od.material_division to od_app with grant option;
grant select on od.material_division to od_user;
grant select on od.material_division to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym material_division for od.material_division;