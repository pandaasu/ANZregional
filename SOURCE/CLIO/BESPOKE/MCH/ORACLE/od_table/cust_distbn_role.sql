/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_distbn_role
 Owner  : od

 Description
 -----------
 Operational Data Store - Customer Distribution Role Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cust_distbn_role
   (sap_cust_distbn_role_code       varchar2(3 char)   not null,
    cust_distbn_role_abbrd_desc     varchar2(12 char)  not null,
    cust_distbn_role_desc           varchar2(30 char)  not null,
    cust_distbn_role_lupdp          varchar2(8 char)   not null,
    cust_distbn_role_lupdt          date               not null);

/**/
/* Comments
/**/
comment on table od.cust_distbn_role is 'Customer Distribution Role Table';
comment on column od.cust_distbn_role.sap_cust_distbn_role_code is 'SAP Customer Distribution Role Code';
comment on column od.cust_distbn_role.cust_distbn_role_abbrd_desc is 'Customer Distribution Role Abbreviated Description';
comment on column od.cust_distbn_role.cust_distbn_role_desc is 'Customer Distribution Role Description';
comment on column od.cust_distbn_role.cust_distbn_role_lupdp is 'Last Updated Person';
comment on column od.cust_distbn_role.cust_distbn_role_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.cust_distbn_role
   add constraint cust_distbn_role_pk primary key (sap_cust_distbn_role_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cust_distbn_role to dw_app;
grant select on od.cust_distbn_role to od_app with grant option;
grant select on od.cust_distbn_role to od_user;
grant select on od.cust_distbn_role to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cust_distbn_role for od.cust_distbn_role;
