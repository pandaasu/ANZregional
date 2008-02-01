/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sales_org_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Sales Organisation Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.sales_org_dim
   (sap_sales_org_code       varchar2(4 char)                 not null,
    sales_org_desc           varchar2(60 char)                not null);

/**/
/* Comments
/**/
comment on table dd.sales_org_dim is 'Sales Organisation Dimension Table';
comment on column dd.sales_org_dim.sap_sales_org_code is 'SAP Sales Organisation Code';
comment on column dd.sales_org_dim.sales_org_desc is 'Sales Organisation Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.sales_org_dim
   add constraint sales_org_dim_pk primary key (sap_sales_org_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.sales_org_dim to dw_app;
grant select on dd.sales_org_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym sales_org_dim for dd.sales_org_dim;
