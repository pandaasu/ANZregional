/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cross_plant_material_status
 Owner  : od

 Description
 -----------
 Operational Data Store - Cross Plant Material Status Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cross_plant_material_status
   (sap_cross_plant_matl_sts_code  varchar2(2 char)    not null,
    cross_plant_matl_sts_desc      varchar2(40 char)   not null,
    cross_plant_matl_sts_lupdp     varchar2(8 char)    not null,
    cross_plant_matl_sts_lupdt     date                not null);

/**/
/* Comments
/**/
comment on table od.cross_plant_material_status is 'Cross Plant Material Status Table';
comment on column od.cross_plant_material_status.sap_cross_plant_matl_sts_code is 'SAP Cross Plant Material Status Code';
comment on column od.cross_plant_material_status.cross_plant_matl_sts_desc is 'Cross Plant Material Status Description';
comment on column od.cross_plant_material_status.cross_plant_matl_sts_lupdp is 'Last Updated Person';
comment on column od.cross_plant_material_status.cross_plant_matl_sts_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.cross_plant_material_status
   add constraint cross_plant_material_status_pk primary key (sap_cross_plant_matl_sts_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cross_plant_material_status to dw_app;
grant select on od.cross_plant_material_status to od_app with grant option;
grant select on od.cross_plant_material_status to od_user;
grant select on od.cross_plant_material_status to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cross_plant_material_status for od.cross_plant_material_status;