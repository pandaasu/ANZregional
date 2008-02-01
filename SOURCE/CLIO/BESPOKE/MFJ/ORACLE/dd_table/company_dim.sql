/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : company_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Company Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.company_dim
   (sap_company_code         varchar2(6 char)                 not null,
    company_desc             varchar2(60 char)                not null);

/**/
/* Comments
/**/
comment on table dd.company_dim is 'Company Dimension Table';
comment on column dd.company_dim.sap_company_code is 'SAP Company Code';
comment on column dd.company_dim.company_desc is 'Company Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.company_dim
   add constraint company_dim_pk primary key (sap_company_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.company_dim to dw_app;
grant select on dd.company_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym company_dim for dd.company_dim;
