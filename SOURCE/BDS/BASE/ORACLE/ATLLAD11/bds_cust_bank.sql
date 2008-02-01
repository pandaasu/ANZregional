/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_bank
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Bank Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_bank
   (customer_code                      varchar2(10 char)        not null,
    bank_country_key                   varchar2(5 char)         not null,
    bank_number                        varchar2(15 char)        not null,
    bank_account_number                varchar2(18 char)        not null,
    bank_control_key                   varchar2(5 char)         not null,
    partner_bank_type                  varchar2(4 char)         null,
    collection_auth_flag               varchar2(1 char)         null,
    bank_detail_reference              varchar2(20 char)        null,
    bank_name                          varchar2(60 char)        null,
    address_street                     varchar2(35 char)        null,
    address_city                       varchar2(35 char)        null,
    swift_code                         varchar2(11 char)        null,
    bank_group                         varchar2(2 char)         null,
    po_current_account_flag            varchar2(1 char)         null,
    bank_number_bnklz                  varchar2(15 char)        null,
    po_current_account_number          varchar2(16 char)        null,
    bank_branch                        varchar2(40 char)        null,
    region                             varchar2(3 char)         null,
    account_holder_name                varchar2(35 char)        null,
    account_holder_name_long           varchar2(60 char)        null,
    batch_input_date_kovon             date                     null,
    batch_input_date_kobis             date                     null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_bank is 'Business Data Store - Customer Bank Detail';
comment on column bds_cust_bank.customer_code is 'Customer Number - lads_cus_bnk.kunnr';
comment on column bds_cust_bank.bank_country_key is 'Bank country key - lads_cus_bnk.banks';
comment on column bds_cust_bank.bank_number is 'Bank number - lads_cus_bnk.bankl';
comment on column bds_cust_bank.bank_account_number is 'Bank Account Number - lads_cus_bnk.bankn';
comment on column bds_cust_bank.bank_control_key is 'Bank Control Key - lads_cus_bnk.bkont';
comment on column bds_cust_bank.partner_bank_type is 'Partner bank type - lads_cus_bnk.bvtyp';
comment on column bds_cust_bank.collection_auth_flag is 'Indicator: Is there collection authorization ? - lads_cus_bnk.xezer';
comment on column bds_cust_bank.bank_detail_reference is 'Reference Specifications for Bank Details - lads_cus_bnk.bkref';
comment on column bds_cust_bank.bank_name is 'Name of bank - lads_cus_bnk.banka';
comment on column bds_cust_bank.address_street is 'House number and street - lads_cus_bnk.stras';
comment on column bds_cust_bank.address_city is 'City - lads_cus_bnk.ort01';
comment on column bds_cust_bank.swift_code is 'SWIFT Code for International Payments - lads_cus_bnk.swift';
comment on column bds_cust_bank.bank_group is 'Bank group (bank network) - lads_cus_bnk.bgrup';
comment on column bds_cust_bank.po_current_account_flag is 'Post Office Bank Current Account - lads_cus_bnk.xpgro';
comment on column bds_cust_bank.bank_number_bnklz is 'Bank number - lads_cus_bnk.bnklz';
comment on column bds_cust_bank.po_current_account_number is 'Post office bank current account number - lads_cus_bnk.pskto';
comment on column bds_cust_bank.bank_branch is 'Bank Branch - lads_cus_bnk.brnch';
comment on column bds_cust_bank.region is '''Region (State, Province, County)'' - lads_cus_bnk.provz';
comment on column bds_cust_bank.account_holder_name is 'Account Holder Name - lads_cus_bnk.koinh';
comment on column bds_cust_bank.account_holder_name_long is 'Account Holder Name - lads_cus_bnk.koinh_n';
comment on column bds_cust_bank.batch_input_date_kovon is 'Date (batch input) - lads_cus_bnk.kovon';
comment on column bds_cust_bank.batch_input_date_kobis is 'Date (batch input) - lads_cus_bnk.kobis';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_bank
   add constraint bds_cust_bank_pk primary key (customer_code, bank_country_key, bank_number, bank_account_number, bank_control_key);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_bank to lics_app;
grant select, insert, update, delete on bds_cust_bank to lads_app;
grant select, insert, update, delete on bds_cust_bank to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_bank for bds.bds_cust_bank;