/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : billing_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Billing Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.billing_type
   (sap_billing_code    varchar2(4 char)          not null,
    billing_type_desc   varchar2(40 char)         not null,
    billing_type_lupdp  varchar2(8 char)          not null,
    billing_type_lupdt  date                      not null);

/**/
/* Comments
/**/
comment on table od.billing_type is 'Billing Type Table';
comment on column od.billing_type.sap_billing_code is 'SAP Billing Type Code';
comment on column od.billing_type.billing_type_desc is 'Billing Type Description';
comment on column od.billing_type.billing_type_lupdp is 'Last Updated Person';
comment on column od.billing_type.billing_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.billing_type
   add constraint billing_type_pk primary key (sap_billing_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.billing_type to dw_app;
grant select on od.billing_type to od_app with grant option;
grant select on od.billing_type to od_user;
grant select on od.billing_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym billing_type for od.billing_type;
