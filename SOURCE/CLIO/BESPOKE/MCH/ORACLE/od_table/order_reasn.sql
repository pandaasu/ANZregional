/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : order_reasn
 Owner  : od

 Description
 -----------
 Operational Data Store - Order Reason Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.order_reasn
   (sap_order_reasn_code  varchar2(3 char)             not null,
    order_reasn_desc      varchar2(40 char)            not null,
    order_reasn_lupdp     varchar2(8 char)             not null,
    order_reasn_lupdt     date                         not null);

/**/
/* Comments
/**/
comment on table od.order_reasn is 'Order Reason Table';
comment on column od.order_reasn.sap_order_reasn_code is 'SAP Order Reason Code';
comment on column od.order_reasn.order_reasn_desc is 'Order Reason Description';
comment on column od.order_reasn.order_reasn_lupdp is 'Last Updated Person';
comment on column od.order_reasn.order_reasn_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.order_reasn
   add constraint order_reasn_pk primary key (sap_order_reasn_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.order_reasn to dw_app;
grant select on od.order_reasn to od_app with grant option;
grant select on od.order_reasn to od_user;
grant select on od.order_reasn to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym order_reasn for od.order_reasn;