/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : special_stock_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Special Stock Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.special_stock_type
   (sap_special_stock_type_code  varchar2(2 char)      not null,
    special_stock_type_desc      varchar2(40 char)     not null,
    special_stock_type_lupdp     varchar2(8 char)      not null,
    special_stock_type_lupdt     date                  not null);

/**/
/* Comments
/**/
comment on table od.special_stock_type is 'Special Stock Type Table';
comment on column od.special_stock_type.sap_special_stock_type_code is 'SAP Special Stock Type Code';
comment on column od.special_stock_type.special_stock_type_desc is 'Special Stock Type Description';
comment on column od.special_stock_type.special_stock_type_lupdp is 'Last Updated Person';
comment on column od.special_stock_type.special_stock_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.special_stock_type
   add constraint special_stock_type_pk primary key (sap_special_stock_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.special_stock_type to dw_app;
grant select on od.special_stock_type to od_app with grant option;
grant select on od.special_stock_type to od_user;
grant select on od.special_stock_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym special_stock_type for od.special_stock_type;