/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : order_reasn_dim
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
create table dd.order_reasn_dim
   (sap_order_reasn_code     varchar2(3 char)                 not null,
    order_reasn_desc         varchar2(40 char)                not null);

/**/
/* Comments
/**/
comment on table dd.order_reasn_dim is 'Company Dimension Table';
comment on column dd.order_reasn_dim.sap_order_reasn_code is 'SAP Order Reason Code';
comment on column dd.order_reasn_dim.order_reasn_desc is 'Order Reason Description';

/**/
/* Primary Key Constraint
/**/
alter table dd.order_reasn_dim
   add constraint order_reasn_dim_pk primary key (sap_order_reasn_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.order_reasn_dim to dw_app;
grant select on dd.order_reasn_dim to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym order_reasn_dim for dd.order_reasn_dim;