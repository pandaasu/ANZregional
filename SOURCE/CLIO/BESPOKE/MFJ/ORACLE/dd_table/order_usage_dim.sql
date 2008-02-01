/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : order_usage_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Order Usage Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.order_usage_dim
   (sap_order_usage_code     varchar2(3 char)                 not null,
    order_usage_desc         varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.order_usage_dim is 'Order Usage Dimension Table';
comment on column dd.order_usage_dim.sap_order_usage_code is 'SAP Order Usage Code';
comment on column dd.order_usage_dim.order_usage_desc is 'Order Usage Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.order_usage_dim
   add constraint order_usage_dim_pk primary key (sap_order_usage_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.order_usage_dim to dw_app;
grant select on dd.order_usage_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym order_usage_dim for dd.order_usage_dim;

