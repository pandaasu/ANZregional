/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : bank_acct_type
 Owner  : od

 Description
 -----------
 Operational Data Store - Bank Account Type Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.bank_acct_type
   (sap_bank_acct_type_code  varchar2(2 char)     not null,
    bank_acct_type_desc      varchar2(40 char)    not null,
    bank_acct_type_lupdp     varchar2(8 char)     not null,
    bank_acct_type_lupdt     date                 not null);

/**/
/* Comments
/**/
comment on table od.bank_acct_type is 'Bank Account Type Table';
comment on column od.bank_acct_type.sap_bank_acct_type_code is 'SAP Bank Account Type Code';
comment on column od.bank_acct_type.bank_acct_type_desc is 'Bank Account Type Description';
comment on column od.bank_acct_type.bank_acct_type_lupdp is 'Last Updated Person';
comment on column od.bank_acct_type.bank_acct_type_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.bank_acct_type
   add constraint bank_acct_type_pk primary key (sap_bank_acct_type_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.bank_acct_type to dw_app;
grant select on od.bank_acct_type to od_app with grant option;
grant select on od.bank_acct_type to od_user;
grant select on od.bank_acct_type to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym bank_acct_type for od.bank_acct_type;
