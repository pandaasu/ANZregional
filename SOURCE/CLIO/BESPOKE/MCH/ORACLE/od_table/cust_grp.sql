/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_grp
 Owner  : od

 Description
 -----------
 Operational Data Store - Customer Group Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cust_grp
   (sap_cust_grp_code  varchar2(2 char)                not null,
    cust_grp_desc      varchar2(40 char)               not null,
    cust_grp_lupdp     varchar2(8 char)                not null,
    cust_grp_lupdt     date                            not null);

/**/
/* Comments
/**/
comment on table od.cust_grp is 'Customer Group Table';
comment on column od.cust_grp.sap_cust_grp_code is 'SAP Customer Group Code';
comment on column od.cust_grp.cust_grp_desc is 'Customer Group Description';
comment on column od.cust_grp.cust_grp_lupdp is 'Last Updated Person';
comment on column od.cust_grp.cust_grp_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.cust_grp
   add constraint cust_grp_pk primary key (sap_cust_grp_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cust_grp to dw_app;
grant select on od.cust_grp to od_app with grant option;
grant select on od.cust_grp to od_user;
grant select on od.cust_grp to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cust_grp for od.cust_grp;