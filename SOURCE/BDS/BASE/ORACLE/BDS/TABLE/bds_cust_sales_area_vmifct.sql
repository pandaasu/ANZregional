/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_sales_area_vmifct
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Sales Area VMI Forecast

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_sales_area_vmifct
   (customer_code                      varchar2(10 char)        not null,
    sales_org_code                     varchar2(5 char)         not null,
    distbn_chnl_code                   varchar2(5 char)         not null,
    division_code                      varchar2(5 char)         not null,
    vmi_fcst_data_source               number                   null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_sales_area_vmifct is 'Business Data Store - Customer Sales Area VMI Forecast';
comment on column bds_cust_sales_area_vmifct.customer_code is 'Customer Number - lads_cus_zsv.kunnr';
comment on column bds_cust_sales_area_vmifct.sales_org_code is 'Sales Organization - lads_cus_sad.vkorg';
comment on column bds_cust_sales_area_vmifct.distbn_chnl_code is 'Distribution Channel - lads_cus_sad.vtweg';
comment on column bds_cust_sales_area_vmifct.division_code is 'Division - lads_cus_sad.spart';
comment on column bds_cust_sales_area_vmifct.vmi_fcst_data_source is 'VMI Forecast Data Source - lads_cus_zsv.vmifds';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_sales_area_vmifct
   add constraint bds_cust_sales_area_vmifct_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_sales_area_vmifct to lics_app;
grant select, insert, update, delete on bds_cust_sales_area_vmifct to lads_app;
grant select, insert, update, delete on bds_cust_sales_area_vmifct to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_sales_area_vmifct for bds.bds_cust_sales_area_vmifct;