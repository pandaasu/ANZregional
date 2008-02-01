/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_sales_area_licse
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Sales Area License

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_sales_area_licse
   (customer_code                      varchar2(10 char)        not null,
    sales_org_code                     varchar2(5 char)         not null,
    distbn_chnl_code                   varchar2(5 char)         not null,
    division_code                      varchar2(5 char)         not null,
    departure_country                  varchar2(5 char)         not null,
    tax_category_code                  varchar2(5 char)         not null,
    valid_from_date                    date                     not null,
    valid_to_date                      date                     not null,
    license_number                     varchar2(15 char)        null,
    license_confirm_flag               varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_sales_area_licse is 'Business Data Store - Customer Sales Area License';
comment on column bds_cust_sales_area_licse.customer_code is 'Customer Number - lads_cus_lid.kunnr';
comment on column bds_cust_sales_area_licse.sales_org_code is 'Sales Organization - lads_cus_sad.vkorg';
comment on column bds_cust_sales_area_licse.distbn_chnl_code is 'Distribution Channel - lads_cus_sad.vtweg';
comment on column bds_cust_sales_area_licse.division_code is 'Division - lads_cus_sad.spart';
comment on column bds_cust_sales_area_licse.departure_country is 'Departure country (country from which the goods are sent) - lads_cus_lid.aland';
comment on column bds_cust_sales_area_licse.tax_category_code is '''Tax category (sales tax, federal sales tax,...)'' - lads_cus_lid.tatyp';
comment on column bds_cust_sales_area_licse.valid_from_date is 'Valid-From Date - lads_cus_lid.datab';
comment on column bds_cust_sales_area_licse.valid_to_date is 'Valid To Date - lads_cus_lid.datbi';
comment on column bds_cust_sales_area_licse.license_number is 'License number - lads_cus_lid.licnr';
comment on column bds_cust_sales_area_licse.license_confirm_flag is 'Confirmation for licenses - lads_cus_lid.belic';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_sales_area_licse
   add constraint bds_cust_sales_area_licse_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code, departure_country, tax_category_code, valid_from_date, valid_to_date);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_sales_area_licse to lics_app;
grant select, insert, update, delete on bds_cust_sales_area_licse to lads_app;
grant select, insert, update, delete on bds_cust_sales_area_licse to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_sales_area_licse for bds.bds_cust_sales_area_licse;