/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_header
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_header
   (vendor_code                        varchar2(10 char)        not null,
    sap_idoc_name                      varchar2(30 char)        null,
    sap_idoc_number                    number(16,0)             null,
    sap_idoc_timestamp                 varchar2(14 char)        null,
    bds_lads_date                      date                     null,
    bds_lads_status                    varchar2(2 char)         null,
    auth_group_code                    varchar2(4 char)         null,
    industry_code                      varchar2(4 char)         null,
    create_date                        date                     null,
    create_user                        varchar2(12 char)        null,
    group_key                          varchar2(10 char)        null,
    account_group_code                 varchar2(4 char)         null,
    customer_code                      varchar2(10 char)        null,
    account_number                     varchar2(10 char)        null,
    deletion_flag                      varchar2(1 char)         null,
    vendor_name_01                     varchar2(35 char)        null,
    vendor_name_02                     varchar2(35 char)        null,
    vendor_name_03                     varchar2(35 char)        null,
    vendor_name_04                     varchar2(35 char)        null,
    sort_value                         varchar2(10 char)        null,
    posting_block_flag                 varchar2(1 char)         null,
    purchasing_block_flag              varchar2(1 char)         null,
    language_key                       varchar2(1 char)         null,
    tax_number_01                      varchar2(16 char)        null,
    tax_number_02                      varchar2(11 char)        null,
    tax_equalization_flag              varchar2(1 char)         null,
    vat_flag                           varchar2(1 char)         null,
    one_time_flag                      varchar2(1 char)         null,
    alternative_payee_flag             varchar2(1 char)         null,
    trading_partner_company_code       varchar2(6 char)         null,
    fiscal_account_number              varchar2(10 char)        null,
    vat_registration_number            varchar2(20 char)        null,
    natural_person                     varchar2(1 char)         null,
    function_block                     varchar2(2 char)         null,
    address_code                       varchar2(10 char)        null,
    withhold_tax_birth_place           varchar2(25 char)        null,
    withhold_tax_birth_date            date                     null,
    withhold_tax_sex                   varchar2(1 char)         null,
    credit_information_number          varchar2(11 char)        null,
    last_review_date                   date                     null,
    qm_system                          varchar2(4 char)         null,
    one_time_account_group             varchar2(4 char)         null,
    plant_code                         varchar2(4 char)         null,
    sub_range_flag                     varchar2(1 char)         null,
    plant_level_flag                   varchar2(1 char)         null,
    factory_calendar                   varchar2(2 char)         null,
    data_transfer_status               varchar2(1 char)         null,
    tax_jurisdiction_code              varchar2(15 char)        null,
    std_carrier_access_code            varchar2(4 char)         null,
    forward_agent_freight_group        varchar2(4 char)         null,
    delivery_transport_zone            varchar2(10 char)        null,
    service_agent_procedure_group      varchar2(4 char)         null,
    tax_type                           varchar2(2 char)         null,
    tax_number_type                    varchar2(2 char)         null,
    social_insurance_flag              varchar2(1 char)         null,
    social_insurance_acivity_code      varchar2(3 char)         null,
    tax_number_03                      varchar2(18 char)        null,
    tax_number_04                      varchar2(18 char)        null,
    tax_split                          varchar2(1 char)         null,
    profession                         varchar2(30 char)        null,
    statistics_group                   varchar2(2 char)         null,
    external_manu_code                 varchar2(10 char)        null,
    deletion_block_flag                varchar2(1 char)         null,
    url_code                           varchar2(132 char)       null,
    representative_name                varchar2(10 char)        null,
    business_type                      varchar2(30 char)        null,
    industry_type                      varchar2(30 char)        null,
    certification_valid_date           date                     null,
    proof_of_delivery_flag             varchar2(1 char)         null,
    tax_office_account_number          varchar2(10 char)        null,
    tax_office_tax_number              varchar2(18 char)        null,
    subledger_account_procedure        varchar2(20 char)        null,
    person_01                          varchar2(35 char)        null,
    person_02                          varchar2(35 char)        null,
    person_03                          varchar2(35 char)        null,
    person_first_name                  varchar2(35 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_vend_header is 'Business Data Store - Vendor Header';
comment on column bds_vend_header.vendor_code is 'Account Number of Vendor or Creditor - lads_ven_hdr.lifnr';
comment on column bds_vend_header.sap_idoc_name is 'IDOC name - lads_ven_hdr.idoc_name';
comment on column bds_vend_header.sap_idoc_number is 'IDOC number - lads_ven_hdr.idoc_number';
comment on column bds_vend_header.sap_idoc_timestamp is 'IDOC timestamp - lads_ven_hdr.idoc_timestamp';
comment on column bds_vend_header.bds_lads_date is 'LADS date loaded - lads_ven_hdr.lads_date';
comment on column bds_vend_header.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan) - lads_ven_hdr.lads_status';
comment on column bds_vend_header.auth_group_code is 'Authorization Group - lads_ven_hdr.begru';
comment on column bds_vend_header.industry_code is 'Industry key - lads_ven_hdr.brsch';
comment on column bds_vend_header.create_date is 'Date on which the Record Was Created - lads_ven_hdr.erdat';
comment on column bds_vend_header.create_user is 'Name of Person who Created the Object - lads_ven_hdr.ernam';
comment on column bds_vend_header.group_key is 'Group key - lads_ven_hdr.konzs';
comment on column bds_vend_header.account_group_code is 'Vendor account group - lads_ven_hdr.ktokk';
comment on column bds_vend_header.customer_code is 'Customer Number 1 - lads_ven_hdr.kunnr';
comment on column bds_vend_header.account_number is 'Account Number of Vendor or Creditor - lads_ven_hdr.lnrza';
comment on column bds_vend_header.deletion_flag is 'Central Deletion Flag for Master Record - lads_ven_hdr.loevm';
comment on column bds_vend_header.vendor_name_01 is 'Employees last name - lads_ven_hdr.name1';
comment on column bds_vend_header.vendor_name_02 is 'Employees last name - lads_ven_hdr.name2';
comment on column bds_vend_header.vendor_name_03 is 'Employees last name - lads_ven_hdr.name3';
comment on column bds_vend_header.vendor_name_04 is 'Employees last name - lads_ven_hdr.name4';
comment on column bds_vend_header.sort_value is 'Character Field Length = 10 - lads_ven_hdr.sortl';
comment on column bds_vend_header.posting_block_flag is 'Central posting block - lads_ven_hdr.sperr';
comment on column bds_vend_header.purchasing_block_flag is 'Centrally imposed purchasing block - lads_ven_hdr.sperm';
comment on column bds_vend_header.language_key is 'Language Key - lads_ven_hdr.spras';
comment on column bds_vend_header.tax_number_01 is 'Tax Number 1 - lads_ven_hdr.stcd1';
comment on column bds_vend_header.tax_number_02 is 'Tax Number 2 - lads_ven_hdr.stcd2';
comment on column bds_vend_header.tax_equalization_flag is 'Indicator: Business Partner Subject to Equalization Tax? - lads_ven_hdr.stkza';
comment on column bds_vend_header.vat_flag is 'Liable for VAT - lads_ven_hdr.stkzu';
comment on column bds_vend_header.one_time_flag is 'Indicator: Is the account a one-time account? - lads_ven_hdr.xcpdk';
comment on column bds_vend_header.alternative_payee_flag is 'Indicator: Alternative payee in document allowed ? - lads_ven_hdr.xzemp';
comment on column bds_vend_header.trading_partner_company_code is 'Company ID of Trading Partner - lads_ven_hdr.vbund';
comment on column bds_vend_header.fiscal_account_number is 'Account number of the master record with fiscal address - lads_ven_hdr.fiskn';
comment on column bds_vend_header.vat_registration_number is 'VAT registration number - lads_ven_hdr.stceg';
comment on column bds_vend_header.natural_person is 'Natural Person - lads_ven_hdr.stkzn';
comment on column bds_vend_header.function_block is 'Function That Will Be Blocked - lads_ven_hdr.sperq';
comment on column bds_vend_header.address_code is 'Address - lads_ven_hdr.adrnr';
comment on column bds_vend_header.withhold_tax_birth_place is 'Place of birth of the person subject to withholding tax - lads_ven_hdr.gbort';
comment on column bds_vend_header.withhold_tax_birth_date is 'Date of Birth - lads_ven_hdr.gbdat';
comment on column bds_vend_header.withhold_tax_sex is 'Key for the Sex of the Person Subject to Withholding Tax - lads_ven_hdr.sexkz';
comment on column bds_vend_header.credit_information_number is 'Credit information number - lads_ven_hdr.kraus';
comment on column bds_vend_header.last_review_date is 'Last review (external) - lads_ven_hdr.revdb';
comment on column bds_vend_header.qm_system is 'Vendors QM system - lads_ven_hdr.qssys';
comment on column bds_vend_header.one_time_account_group is 'Reference Account Group for One-Time Account (Vendor) - lads_ven_hdr.ktock';
comment on column bds_vend_header.plant_code is 'Plant - lads_ven_hdr.werks';
comment on column bds_vend_header.sub_range_flag is 'Indicator: vendor sub-range relevant - lads_ven_hdr.ltsna';
comment on column bds_vend_header.plant_level_flag is 'Indicator: plant level relevant - lads_ven_hdr.werkr';
comment on column bds_vend_header.factory_calendar is 'Factory calendar key - lads_ven_hdr.plkal';
comment on column bds_vend_header.data_transfer_status is 'Status of Data Transfer into Subsequent Release - lads_ven_hdr.duefl';
comment on column bds_vend_header.tax_jurisdiction_code is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code - lads_ven_hdr.txjcd';
comment on column bds_vend_header.std_carrier_access_code is 'Standard carrier access code - lads_ven_hdr.scacd';
comment on column bds_vend_header.forward_agent_freight_group is 'Forwarding agent freight group - lads_ven_hdr.sfrgr';
comment on column bds_vend_header.delivery_transport_zone is 'Transportation zone to or from which the goods are delivered - lads_ven_hdr.lzone';
comment on column bds_vend_header.service_agent_procedure_group is 'Service agent procedure group - lads_ven_hdr.dlgrp';
comment on column bds_vend_header.tax_type is 'Tax type - lads_ven_hdr.fityp';
comment on column bds_vend_header.tax_number_type is 'Tax Number Type - lads_ven_hdr.stcdt';
comment on column bds_vend_header.social_insurance_flag is 'Registered for Social Insurance - lads_ven_hdr.regss';
comment on column bds_vend_header.social_insurance_acivity_code is 'Activity Code for Social Insurance - lads_ven_hdr.actss';
comment on column bds_vend_header.tax_number_03 is 'Tax Number 3 - lads_ven_hdr.stcd3';
comment on column bds_vend_header.tax_number_04 is 'Tax Number 4 - lads_ven_hdr.stcd4';
comment on column bds_vend_header.tax_split is 'Tax Split - lads_ven_hdr.ipisp';
comment on column bds_vend_header.profession is 'Profession - lads_ven_hdr.profs';
comment on column bds_vend_header.statistics_group is '''Shipment: statistics group, transportation service agent'' - lads_ven_hdr.stgdl';
comment on column bds_vend_header.external_manu_code is 'External manufacturer code name or number - lads_ven_hdr.emnfr';
comment on column bds_vend_header.deletion_block_flag is 'Central deletion block for master record - lads_ven_hdr.nodel';
comment on column bds_vend_header.url_code is 'Uniform resource locator - lads_ven_hdr.lfurl';
comment on column bds_vend_header.representative_name is 'Name of Representative - lads_ven_hdr.j_1kfrepre';
comment on column bds_vend_header.business_type is 'Type of Business - lads_ven_hdr.j_1kftbus';
comment on column bds_vend_header.industry_type is 'Type of Industry - lads_ven_hdr.j_1kftind';
comment on column bds_vend_header.certification_valid_date is 'Validity date of certification - lads_ven_hdr.qssysdat';
comment on column bds_vend_header.proof_of_delivery_flag is 'Vendor indicator relevant for proof of delivery - lads_ven_hdr.podkzb';
comment on column bds_vend_header.tax_office_account_number is 'Account Number of Master Record of Tax Office Responsible - lads_ven_hdr.fisku';
comment on column bds_vend_header.tax_office_tax_number is 'Tax Number at Responsible Tax Authority - lads_ven_hdr.stenr';
comment on column bds_vend_header.subledger_account_procedure is 'Subledger acct preprocessing procedure - lads_ven_hdr.psois';
comment on column bds_vend_header.person_01 is 'Name 1 - lads_ven_hdr.pson1';
comment on column bds_vend_header.person_02 is 'Name 1 - lads_ven_hdr.pson2';
comment on column bds_vend_header.person_03 is 'Name 1 - lads_ven_hdr.pson3';
comment on column bds_vend_header.person_first_name is 'First name - lads_ven_hdr.psovn';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_header
   add constraint bds_vend_header_pk primary key (vendor_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_header to lics_app;
grant select, insert, update, delete on bds_vend_header to lads_app;
grant select, insert, update, delete on bds_vend_header to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_header for bds.bds_vend_header;