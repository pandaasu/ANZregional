/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_sales_grp
 Owner  : od

 Description
 -----------
 Operational Data Store - Customer Sales Group Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cust_sales_grp
   (sap_cust_sales_grp_code  varchar2(3 char)          not null,
    cust_sales_grp_desc      varchar2(40 char)         not null,
    cust_sales_grp_lupdp     varchar2(8 char)          not null,
    cust_sales_grp_lupdt     date                      not null);

/**/
/* Comments
/**/
comment on table od.cust_sales_grp is 'Customer Sales Group Table';
comment on column od.cust_sales_grp.sap_cust_sales_grp_code is 'SAP Customer Sales Group Code';
comment on column od.cust_sales_grp.cust_sales_grp_desc is 'Customer Sales Group Description';
comment on column od.cust_sales_grp.cust_sales_grp_lupdp is 'Last Updated Person';
comment on column od.cust_sales_grp.cust_sales_grp_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.cust_sales_grp
   add constraint cust_sales_grp_pk primary key (sap_cust_sales_grp_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cust_sales_grp to dw_app;
grant select on od.cust_sales_grp to od_app with grant option;
grant select on od.cust_sales_grp to od_user;
grant select on od.cust_sales_grp to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cust_sales_grp for od.cust_sales_grp;