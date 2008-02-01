/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : order_usage
 Owner  : od

 Description
 -----------
 Operational Data Store - Order Usage Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.order_usage
   (sap_order_usage_code  varchar2(3 char)             not null,
    order_usage_desc      varchar2(40 char)            not null,
    order_usage_lupdp     varchar2(8 char)             not null,
    order_usage_lupdt     date                         not null);

/**/
/* Comments
/**/
comment on table od.order_usage is 'Order Usage Table';
comment on column od.order_usage.sap_order_usage_code is 'SAP Order Usage Code';
comment on column od.order_usage.order_usage_desc is 'Order Usage Description';
comment on column od.order_usage.order_usage_lupdp is 'Last Updated Person';
comment on column od.order_usage.order_usage_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.order_usage
   add constraint order_usage_pk primary key (sap_order_usage_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.order_usage to dw_app;
grant select on od.order_usage to od_app with grant option;
grant select on od.order_usage to od_user;
grant select on od.order_usage to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym order_usage for od.order_usage;