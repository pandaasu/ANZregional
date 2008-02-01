/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : order_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Order Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/04   Steve Gregan   Added order_type_sign for order aggregation

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.order_type
   (sap_order_type_code  varchar2(4 char)              not null,
    order_type_desc      varchar2(40 char)             not null,
    order_type_sign      varchar2(1 char)              null,
    order_type_gsv       varchar2(1 char)              null,
    order_type_lupdp     varchar2(8 char)              not null,
    order_type_lupdt     date                          not null);

/**/
/* Comments
/**/
comment on table od.order_type is 'Order Type Table';
comment on column od.order_type.sap_order_type_code is 'SAP Order Type Code';
comment on column od.order_type.order_type_desc is 'Order Type Description';
comment on column od.order_type.order_type_sign is 'Order Type Sign';
comment on column od.order_type.order_type_gsv is 'Order Type GSV - 0= Non GSV, 1=GSV';
comment on column od.order_type.order_type_lupdp is 'Last Updated Person';
comment on column od.order_type.order_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.order_type
   add constraint order_type_pk primary key (sap_order_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.order_type to dw_app;
grant select on od.order_type to od_app with grant option;
grant select on od.order_type to od_user;
grant select on od.order_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym order_type for od.order_type;