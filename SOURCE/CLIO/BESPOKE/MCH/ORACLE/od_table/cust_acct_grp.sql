/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_acct_grp
 Owner  : od

 Description
 -----------
 Operational Data Store - Customer Account Group Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.cust_acct_grp
   (sap_cust_acct_grp_code  varchar2(4 char)           not null,
    cust_acct_grp_desc      varchar2(40 char)          not null,
    node_role               varchar2(2 char),
    cust_acct_grp_lupdp     varchar2(8 char)           not null,
    cust_acct_grp_lupdt     date                       not null);

/**/
/* Comments
/**/
comment on table od.cust_acct_grp is 'Customer Account Group Table';
comment on column od.cust_acct_grp.sap_cust_acct_grp_code is 'SAP Customer Account Group Code';
comment on column od.cust_acct_grp.cust_acct_grp_desc is 'Customer Account Group Description';
comment on column od.cust_acct_grp.node_role is 'Node Role';
comment on column od.cust_acct_grp.cust_acct_grp_lupdp is 'Last Updated Person';
comment on column od.cust_acct_grp.cust_acct_grp_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.cust_acct_grp
   add constraint cust_acct_grp_pk primary key (sap_cust_acct_grp_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.cust_acct_grp to dw_app;
grant select on od.cust_acct_grp to od_app with grant option;
grant select on od.cust_acct_grp to od_user;
grant select on od.cust_acct_grp to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym cust_acct_grp for od.cust_acct_grp;