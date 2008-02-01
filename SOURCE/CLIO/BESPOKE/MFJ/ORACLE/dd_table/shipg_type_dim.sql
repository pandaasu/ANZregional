/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : shipg_type_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Shipping Type Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.shipg_type_dim
   (sap_shipg_type_code      varchar2(3 char)                 not null,
    shipg_type_desc          varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.shipg_type_dim is 'Shipping Type Dimension Table';
comment on column dd.shipg_type_dim.sap_shipg_type_code is 'SAP Shipping Type Code';
comment on column dd.shipg_type_dim.shipg_type_desc is 'Shipping Type Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.shipg_type_dim
   add constraint shipg_type_dim_pk primary key (sap_shipg_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.shipg_type_dim to dw_app;
grant select on dd.shipg_type_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym shipg_type_dim for dd.shipg_type_dim;
