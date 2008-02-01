/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : stock_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Stock Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.stock_type
   (sap_stock_type_code  varchar2(2 char)              not null,
    stock_type_desc      varchar2(40 char)             not null,
    stock_type_lupdp     varchar2(8 char)              not null,
    stock_type_lupdt     date                          not null);

/**/
/* Comments
/**/
comment on table od.stock_type is 'Stock Type Table';
comment on column od.stock_type.sap_stock_type_code is 'SAP Stock Type Code';
comment on column od.stock_type.stock_type_desc is 'Stock Type Description';
comment on column od.stock_type.stock_type_lupdp is 'Last Updated Person';
comment on column od.stock_type.stock_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.stock_type
   add constraint stock_type_pk primary key (sap_stock_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.stock_type to dw_app;
grant select on od.stock_type to od_app with grant option;
grant select on od.stock_type to od_user;
grant select on od.stock_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym stock_type for od.stock_type;