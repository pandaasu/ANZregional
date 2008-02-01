/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_sales_area_taxind
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Sales Area Tax Indicator

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_sales_area_taxind
   (customer_code                      varchar2(10 char)        not null,
    sales_org_code                     varchar2(5 char)         not null,
    distbn_chnl_code                   varchar2(5 char)         not null,
    division_code                      varchar2(5 char)         not null,
    departure_country                  varchar2(5 char)         not null,
    tax_category_code                  varchar2(5 char)         not null,
    tax_classification_code            varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_sales_area_taxind is 'Business Data Store - Customer Sales Area Tax Indicator';
comment on column bds_cust_sales_area_taxind.customer_code is 'Customer Number - lads_cus_stx.kunnr';
comment on column bds_cust_sales_area_taxind.sales_org_code is 'Sales Organization - lads_cus_sad.vkorg';
comment on column bds_cust_sales_area_taxind.distbn_chnl_code is 'Distribution Channel - lads_cus_sad.vtweg';
comment on column bds_cust_sales_area_taxind.division_code is 'Division - lads_cus_sad.spart';
comment on column bds_cust_sales_area_taxind.departure_country is 'Departure country (country from which the goods are sent) - lads_cus_stx.aland';
comment on column bds_cust_sales_area_taxind.tax_category_code is '''Tax category (sales tax, federal sales tax,...)'' - lads_cus_stx.tatyp';
comment on column bds_cust_sales_area_taxind.tax_classification_code is 'Tax classification for customer - lads_cus_stx.taxkd';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_sales_area_taxind
   add constraint bds_cust_sales_area_taxind_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code, departure_country, tax_category_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_sales_area_taxind to lics_app;
grant select, insert, update, delete on bds_cust_sales_area_taxind to lads_app;
grant select, insert, update, delete on bds_cust_sales_area_taxind to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_sales_area_taxind for bds.bds_cust_sales_area_taxind;