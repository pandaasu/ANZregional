/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_bank
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Bank

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_bank
   (vendor_code                        varchar2(10 char)        not null,
    bank_country_key                   varchar2(5 char)         not null,
    bank_number                        varchar2(15 char)        not null,
    bank_account_number                varchar2(18 char)        not null,
    bank_control_key                   varchar2(5 char)         not null,
    partner_bank_type                  varchar2(4 char)         null,
    collection_auth_flag               varchar2(1 char)         null,
    bank_name                          varchar2(60 char)        null,
    location                           varchar2(25 char)        null,
    swift_code                         varchar2(11 char)        null,
    bank_group                         varchar2(2 char)         null,
    checkbox                           varchar2(1 char)         null,
    bank_number_bnklz                  varchar2(15 char)        null,
    po_current_account_number          varchar2(16 char)        null,
    bank_detail_reference              varchar2(20 char)        null,
    bank_branch                        varchar2(40 char)        null,
    region                             varchar2(3 char)         null,
    address_street                     varchar2(35 char)        null,
    address_city                       varchar2(35 char)        null,
    account_holder_name                varchar2(60 char)        null,
    batch_input_date_kovon             date                     null,
    batch_input_date_kobis             date                     null);

/*-*/
/* Comments
/*-*/
comment on table bds_vend_bank is 'Business Data Store - Vendor Bank';
comment on column bds_vend_bank.vendor_code is 'Account Number of Vendor or Creditor - lads_ven_bnk.lifnr';
comment on column bds_vend_bank.bank_country_key is 'Bank country key - lads_ven_bnk.banks';
comment on column bds_vend_bank.bank_number is 'Bank Key - lads_ven_bnk.bankl';
comment on column bds_vend_bank.bank_account_number is 'Bank Account Number - lads_ven_bnk.bankn';
comment on column bds_vend_bank.bank_control_key is 'Bank Control Key - lads_ven_bnk.bkont';
comment on column bds_vend_bank.partner_bank_type is 'Partner bank type - lads_ven_bnk.bvtyp';
comment on column bds_vend_bank.collection_auth_flag is 'Indicator: Is there collection authorization ? - lads_ven_bnk.xezer';
comment on column bds_vend_bank.bank_name is 'Name of bank - lads_ven_bnk.banka';
comment on column bds_vend_bank.location is 'Location - lads_ven_bnk.ort01';
comment on column bds_vend_bank.swift_code is 'SWIFT Code for International Payments - lads_ven_bnk.swift';
comment on column bds_vend_bank.bank_group is 'Bank group (bank network) - lads_ven_bnk.bgrup';
comment on column bds_vend_bank.checkbox is 'Checkbox - lads_ven_bnk.xpgro';
comment on column bds_vend_bank.bank_number_bnklz is 'Bank number - lads_ven_bnk.bnklz';
comment on column bds_vend_bank.po_current_account_number is 'Post office bank current account number - lads_ven_bnk.pskto';
comment on column bds_vend_bank.bank_detail_reference is 'Reference Specifications for Bank Details - lads_ven_bnk.bkref';
comment on column bds_vend_bank.bank_branch is 'Bank Branch - lads_ven_bnk.brnch';
comment on column bds_vend_bank.region is '''Region (State, Province, County)'' - lads_ven_bnk.prov2';
comment on column bds_vend_bank.address_street is 'House number and street - lads_ven_bnk.stra2';
comment on column bds_vend_bank.address_city is 'City - lads_ven_bnk.ort02';
comment on column bds_vend_bank.account_holder_name is 'Account Holder Name - lads_ven_bnk.koinh';
comment on column bds_vend_bank.batch_input_date_kovon is 'Date (batch input) - lads_ven_bnk.kovon';
comment on column bds_vend_bank.batch_input_date_kobis is 'Date (batch input) - lads_ven_bnk.kobis';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_bank
   add constraint bds_vendr_bank_pk primary key (vendor_code, bank_country_key, bank_number, bank_account_number, bank_control_key);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_bank to lics_app;
grant select, insert, update, delete on bds_vend_bank to lads_app;
grant select, insert, update, delete on bds_vend_bank to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_bank for bds.bds_vend_bank;