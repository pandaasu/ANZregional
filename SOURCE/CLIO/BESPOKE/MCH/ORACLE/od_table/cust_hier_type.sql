/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_hier_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Customer Hierarchy Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cust_hier_type
   (sap_cust_hier_type_code  varchar2(1 char)          not null,
    cust_hier_type_desc      varchar2(40 char)         not null,
    cust_hier_type_lupdp     varchar2(8 char)          not null,
    cust_hier_type_lupdt     date                      not null);

/**/
/* Comments
/**/
comment on table od.cust_hier_type is 'Customer Hierarchy Type Table';
comment on column od.cust_hier_type.sap_cust_hier_type_code is 'SAP Customer Hierarchy Type Code';
comment on column od.cust_hier_type.cust_hier_type_desc is 'Customer Hierarchy Type Description';
comment on column od.cust_hier_type.cust_hier_type_lupdp is 'Last Updated Person';
comment on column od.cust_hier_type.cust_hier_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.cust_hier_type
   add constraint cust_hier_type_pk primary key (sap_cust_hier_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cust_hier_type to dw_app;
grant select on od.cust_hier_type to od_app with grant option;
grant select on od.cust_hier_type to od_user;
grant select on od.cust_hier_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cust_hier_type for od.cust_hier_type;