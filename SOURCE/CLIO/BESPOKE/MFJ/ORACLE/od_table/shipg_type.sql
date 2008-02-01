/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : shipg_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Shipping Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.shipg_type
   (sap_shipg_type_code  varchar2(3 char)              not null,
    shipg_type_desc      varchar2(40 char)             not null,
    shipg_type_lupdp     varchar2(8 char)              not null,
    shipg_type_lupdt     date                          not null);

/**/
/* Comments
/**/
comment on table od.shipg_type is 'Shipping Type Table';
comment on column od.shipg_type.sap_shipg_type_code is 'SAP Shipping Type Code';
comment on column od.shipg_type.shipg_type_desc is 'Shipping Type Description';
comment on column od.shipg_type.shipg_type_lupdp is 'Last Updated Person';
comment on column od.shipg_type.shipg_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.shipg_type
   add constraint shipg_type_pk primary key (sap_shipg_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.shipg_type to dw_app;
grant select on od.shipg_type to od_app with grant option;
grant select on od.shipg_type to od_user;
grant select on od.shipg_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym shipg_type for od.shipg_type;