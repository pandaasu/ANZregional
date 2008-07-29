/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_sales_area_vmityp
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Sales Area VMI Type

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_sales_area_vmityp
   (customer_code                      varchar2(10 char)        not null,
    sales_org_code                     varchar2(5 char)         not null,
    distbn_chnl_code                   varchar2(5 char)         not null,
    division_code                      varchar2(5 char)         not null,
    vmi_customer_type                  number                   null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_sales_area_vmityp is 'Business Data Store - Customer Sales Area VMI Type';
comment on column bds_cust_sales_area_vmityp.customer_code is 'Customer Number - lads_cus_zsd.kunnr';
comment on column bds_cust_sales_area_vmityp.sales_org_code is 'Sales Organization - lads_cus_sad.vkorg';
comment on column bds_cust_sales_area_vmityp.distbn_chnl_code is 'Distribution Channel - lads_cus_sad.vtweg';
comment on column bds_cust_sales_area_vmityp.division_code is 'Division - lads_cus_sad.spart';
comment on column bds_cust_sales_area_vmityp.vmi_customer_type is 'VMI Customer type - lads_cus_zsd.vmict';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_sales_area_vmityp
   add constraint bds_cust_sales_area_vmityp_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_sales_area_vmityp to lics_app;
grant select, insert, update, delete on bds_cust_sales_area_vmityp to lads_app;
grant select, insert, update, delete on bds_cust_sales_area_vmityp to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_sales_area_vmityp for bds.bds_cust_sales_area_vmityp;