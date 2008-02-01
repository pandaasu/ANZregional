/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_vat
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Additional Tax Number

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_vat
   (customer_code                      varchar2(10 char)        not null,
    country_code                       varchar2(5 char)         not null,
    vat_registration_number            varchar2(20 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_vat is 'Business Data Store - Customer Additional Tax Number';
comment on column bds_cust_vat.customer_code is 'Customer Number - lads_cus_vat.kunnr';
comment on column bds_cust_vat.country_code is 'Country Key - lads_cus_vat.land1';
comment on column bds_cust_vat.vat_registration_number is 'VAT registration number - lads_cus_vat.stceg';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_vat
   add constraint bds_cust_vat_pk primary key (customer_code, country_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_vat to lics_app;
grant select, insert, update, delete on bds_cust_vat to lads_app;
grant select, insert, update, delete on bds_cust_vat to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_vat for bds.bds_cust_vat;