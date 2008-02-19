/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : china_tax_customer
 Owner  : od

 Description
 -----------
 Operational Data Store - China Tax Customer Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.china_tax_customer
   (cust_code           varchar2(4 char)                     not null,
    cust_name           varchar2(100 char)                   not null,
    cust_addr           varchar2(80 char)                    not null,
    cust_bank           varchar2(80 char)                    not null,
    tax_code            varchar2(15 char)                    not null);

/**/
/* Comments
/**/
comment on table od.china_tax_customer is 'China Tax Customer Table';
comment on column od.china_tax_customer.cust_code is 'Tax customer code - plant code';
comment on column od.china_tax_customer.cust_name is 'Tax customer name';
comment on column od.china_tax_customer.cust_addr is 'Tax customer address';
comment on column od.china_tax_customer.cust_bank is 'Tax customer bank account';
comment on column od.china_tax_customer.tax_code is 'Tax code';

/**/
/* Primary Key Constraint
/**/
alter table od.china_tax_customer
   add constraint china_tax_customer_pk primary key (cust_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.china_tax_customer to dw_app;
grant select on od.china_tax_customer to public with grant option;

/**/
/* Synonym
/**/
create public synonym china_tax_customer for od.china_tax_customer;