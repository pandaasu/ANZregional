/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : order_type_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Order Type Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.order_type_dim
   (sap_order_type_code      varchar2(4 char)                 not null,
    order_type_desc          varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.order_type_dim is 'Order Type Dimension Table';
comment on column dd.order_type_dim.sap_order_type_code is 'SAP Order Type Code';
comment on column dd.order_type_dim.order_type_desc is 'Order Type Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.order_type_dim
   add constraint order_type_dim_pk primary key (sap_order_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.order_type_dim to dw_app;
grant select on dd.order_type_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym order_type_dim for dd.order_type_dim;
