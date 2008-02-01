/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sap_order_type
 Owner  : lads

 Description
 -----------
 Local Atlas Data Store - Order Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/05   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads.sap_order_type
   (sap_order_type_code  varchar2(4 char)              not null,
    order_type_desc      varchar2(40 char)             not null,
    order_type_sign      varchar2(1 char)              null,
    order_type_gsv       varchar2(1 char)              null);

/**/
/* Comments
/**/
comment on table lads.sap_order_type is 'Order Type Table';
comment on column lads.sap_order_type.sap_order_type_code is 'SAP Order Type Code';
comment on column lads.sap_order_type.order_type_desc is 'Order Type Description';
comment on column lads.sap_order_type.order_type_sign is 'Order Type Sign';
comment on column lads.sap_order_type.order_type_gsv is 'Order Type GSV - 0=Non GSV, 1=GSV';

/**/
/* Primary Key Constraint
/**/
alter table lads.sap_order_type
   add constraint sap_order_type_pk primary key (sap_order_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads.sap_order_type to lads_app;
grant select on lads.sap_order_type to ics_app;

/**/
/* Synonym
/**/
create or replace public synonym sap_order_type for lads.sap_order_type;