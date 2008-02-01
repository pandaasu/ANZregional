/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : material_division_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Material Division Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.material_division_dim
   (sap_material_division_code      varchar2(2 char)                 not null,
    material_division_desc          varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.material_division_dim is 'Material Division Dimension Table';
comment on column dd.material_division_dim.sap_material_division_code is 'SAP Material Division Code';
comment on column dd.material_division_dim.material_division_desc is 'Material Division Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.material_division_dim
   add constraint material_division_dim_pk primary key (sap_material_division_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.material_division_dim to dw_app;
grant select on dd.material_division_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym material_division_dim for dd.material_division_dim;
