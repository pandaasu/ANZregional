/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_material
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Material Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/12   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_material
   (sap_material_code               varchar2(18 char)      not null,
    planning_status                 number                 null,
    planning_type                   number                 null,
    planning_cat_old                number                 null,
    planning_cat_prv                number                 null,
    planning_category               number                 null,
    planning_src_unit               varchar2(255 char)     null);

/**/
/* Comments
/**/
comment on table od.fcst_material is 'Forecast Material Table';
comment on column od.fcst_material.sap_material_code is 'SAP material code';
comment on column od.fcst_material.planning_status is 'Planning status code 0 or 1';
comment on column od.fcst_material.planning_type is 'Planning type';
comment on column od.fcst_material.planning_cat_old  is 'Planning category - Old';
comment on column od.fcst_material.planning_cat_prv is 'Planning category - Previous';
comment on column od.fcst_material.planning_category is 'Planning category - Current';
comment on column od.fcst_material.planning_src_unit is 'Planning source unit';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_material
   add constraint fcst_material_pk primary key (sap_material_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_material to dw_app;
grant select on od.fcst_material to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_material for od.fcst_material;