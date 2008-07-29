/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_plant_dept
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Plant Department

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_plant_dept
   (customer_code                      varchar2(10 char)        not null,
    cust_plant                         varchar2(10 char)        not null,
    cust_department                    varchar2(5 char)         not null,
    receive_point                      varchar2(25 char)        null,
    sales_area_space                   number                   null,
    sales_area_space_unit              varchar2(3 char)         null,
    layout                             varchar2(10 char)        null,
    area                               varchar2(4 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_plant_dept is 'Business Data Store - Customer Plant Department';
comment on column bds_cust_plant_dept.customer_code is 'Customer Number - lads_cus_pdp.kunnr';
comment on column bds_cust_plant_dept.cust_plant is 'Customer number for plant - lads_cus_pdp.locnr';
comment on column bds_cust_plant_dept.cust_department is 'Department number - lads_cus_pdp.abtnr';
comment on column bds_cust_plant_dept.receive_point is 'Receiving point - lads_cus_pdp.empst';
comment on column bds_cust_plant_dept.sales_area_space is 'Sales area (floor space) - lads_cus_pdp.verfl';
comment on column bds_cust_plant_dept.sales_area_space_unit is 'Sales area (floor space) unit - lads_cus_pdp.verfe';
comment on column bds_cust_plant_dept.layout is 'Layout - lads_cus_pdp.layvr';
comment on column bds_cust_plant_dept.area is 'Area schema - lads_cus_pdp.flvar';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_plant_dept
   add constraint bds_cust_plant_dept_pk primary key (customer_code, cust_plant, cust_department);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_plant_dept to lics_app;
grant select, insert, update, delete on bds_cust_plant_dept to lads_app;
grant select, insert, update, delete on bds_cust_plant_dept to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_plant_dept for bds.bds_cust_plant_dept;