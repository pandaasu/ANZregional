/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sales_org
 Owner  : od

 Description
 -----------
 Operational Data Store - Sales Organisation Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.sales_org
   (sap_sales_org_code  varchar2(4 char)               not null,
    sales_org_desc      varchar2(60 char)              not null,
    sap_company_code    varchar2(6 char),
    sales_org_lupdp     varchar2(8 char)               not null,
    sales_org_lupdt     date                           not null);

/**/
/* Comments
/**/
comment on table od.sales_org is 'Sales Organisation Table';
comment on column od.sales_org.sap_sales_org_code is 'SAP Sales Organisation Code';
comment on column od.sales_org.sales_org_desc is 'Sales Organisation Description';
comment on column od.sales_org.sap_company_code is 'SAP Company Code';
comment on column od.sales_org.sales_org_lupdp is 'Last Updated Person';
comment on column od.sales_org.sales_org_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.sales_org
   add constraint sales_org_pk primary key (sap_sales_org_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.sales_org to dw_app;
grant select on od.sales_org to od_app with grant option;
grant select on od.sales_org to od_user;
grant select on od.sales_org to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym sales_org for od.sales_org;