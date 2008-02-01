/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : division_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Division Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.division_dim
   (sap_division_code        varchar2(2 char)                 not null,
    division_desc            varchar2(60 char)                not null);

/**/
/* Comments
/**/
comment on table dd.division_dim is 'Division Dimension Table';
comment on column dd.division_dim.sap_division_code is 'SAP Division Code';
comment on column dd.division_dim.division_desc is 'Division Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.division_dim
   add constraint division_dim_pk primary key (sap_division_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.division_dim to dw_app;
grant select on dd.division_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym division_dim for dd.division_dim;



