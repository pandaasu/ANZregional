/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : currency_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Currency Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.currency_dim
   (sap_currcy_code          varchar2(5 char)                 not null,
    currcy_desc              varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.currency_dim is 'Currency Dimension Table';
comment on column dd.currency_dim.sap_currcy_code is 'SAP Currency Code';
comment on column dd.currency_dim.currcy_desc is 'Currency Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.currency_dim
   add constraint currency_dim_pk primary key (sap_currcy_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.currency_dim to dw_app;
grant select on dd.currency_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym currency_dim for dd.currency_dim;



