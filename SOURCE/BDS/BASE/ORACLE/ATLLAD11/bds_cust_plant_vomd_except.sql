/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_plant_vomd_except
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Plant Value Only Material Determination Exception

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_plant_vomd_except
   (customer_code                      varchar2(10 char)        not null,
    cust_plant                         varchar2(10 char)        not null,
    material_code                      varchar2(18 char)        not null,
    posting_material_code              varchar2(18 char)        not null,
    material_group_code                varchar2(9 char)         not null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_plant_vomd_except is 'Business Data Store - Customer Plant Value Only Material Determination Exception';
comment on column bds_cust_plant_vomd_except.customer_code is 'Customer Number - lads_cus_mge.kunnr';
comment on column bds_cust_plant_vomd_except.cust_plant is 'Customer number for plant - lads_cus_mge.locnr';
comment on column bds_cust_plant_vomd_except.material_code is 'Material Number - lads_cus_mge.matnr';
comment on column bds_cust_plant_vomd_except.posting_material_code is 'Posting material number of value-only or individual material - lads_cus_mge.wmatn';
comment on column bds_cust_plant_vomd_except.material_group_code is 'Material Group - lads_cus_mge.matkl';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_plant_vomd_except
   add constraint bds_cust_plant_vomd_except_pk primary key (customer_code, cust_plant, material_code, posting_material_code, material_group_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_plant_vomd_except to lics_app;
grant select, insert, update, delete on bds_cust_plant_vomd_except to lads_app;
grant select, insert, update, delete on bds_cust_plant_vomd_except to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_plant_vomd_except for bds.bds_cust_plant_vomd_except;