/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_sales_office
 Owner  : od

 Description
 -----------
 Operational Data Store - Customer Sales Office Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cust_sales_office
   (sap_cust_sales_office_code  varchar2(4 char)       not null,
    cust_sales_office_desc      varchar2(40 char)      not null,
    cust_sales_office_lupdp     varchar2(8 char)       not null,
    cust_sales_office_lupdt     date                   not null);

/**/
/* Comments
/**/
comment on table od.cust_sales_office is 'Customer Sales Office Table';
comment on column od.cust_sales_office.sap_cust_sales_office_code is 'SAP Customer Sales Office Code';
comment on column od.cust_sales_office.cust_sales_office_desc is 'Customer Sales Office Description';
comment on column od.cust_sales_office.cust_sales_office_lupdp is 'Last Updated Person';
comment on column od.cust_sales_office.cust_sales_office_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.cust_sales_office
   add constraint cust_sales_office_pk primary key (sap_cust_sales_office_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cust_sales_office to dw_app;
grant select on od.cust_sales_office to od_app with grant option;
grant select on od.cust_sales_office to od_user;
grant select on od.cust_sales_office to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cust_sales_office for od.cust_sales_office;