/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_plant_vomd
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Plant Value Only Material Determination

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_plant_vomd
   (customer_code                      varchar2(10 char)        not null,
    cust_plant                         varchar2(10 char)        not null,
    material_group                     varchar2(9 char)         not null,
    material_group_material_code       varchar2(18 char)        not null,
    inventory_manage_exception         varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_plant_vomd is 'Business Data Store - Customer Plant Value Only Material Determination';
comment on column bds_cust_plant_vomd.customer_code is 'Customer Number - lads_cus_mgv.kunnr';
comment on column bds_cust_plant_vomd.cust_plant is 'Customer number for plant - lads_cus_mgv.locnr';
comment on column bds_cust_plant_vomd.material_group is 'Material Group - lads_cus_mgv.matkl';
comment on column bds_cust_plant_vomd.material_group_material_code is 'Material group material - lads_cus_mgv.wwgpa';
comment on column bds_cust_plant_vomd.inventory_manage_exception is 'Indicates exceptions to type of Inventory Management - lads_cus_mgv.kedet';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_plant_vomd
   add constraint bds_cust_plant_vomd_pk primary key (customer_code, cust_plant, material_group, material_group_material_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_plant_vomd to lics_app;
grant select, insert, update, delete on bds_cust_plant_vomd to lads_app;
grant select, insert, update, delete on bds_cust_plant_vomd to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_plant_vomd for bds.bds_cust_plant_vomd;