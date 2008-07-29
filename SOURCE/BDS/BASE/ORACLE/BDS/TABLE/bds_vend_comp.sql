/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_comp
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Company

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_comp
   (vendor_code                        varchar2(10 char)        not null,
    company_code                       varchar2(6 char)         not null,
    create_date                        date                     null,
    create_user                        varchar2(12 char)        null,
    posting_block_flag                 varchar2(1 char)         null,
    deletion_flag                      varchar2(1 char)         null,
    assignment_sort_key                varchar2(3 char)         null,
    reconciliation_account             varchar2(10 char)        null,
    authorisation_group                varchar2(4 char)         null,
    interest_calc_ind                  varchar2(2 char)         null,
    payment_method                     varchar2(10 char)        null,
    clearing_flag                      varchar2(1 char)         null,
    payment_block_flag                 varchar2(1 char)         null,
    payment_terms                      varchar2(4 char)         null,
    shipper_account                    varchar2(12 char)        null,
    vendor_clerk                       varchar2(15 char)        null,
    planning_group                     varchar2(10 char)        null,
    account_clerk_code                 varchar2(2 char)         null,
    head_office_account                varchar2(10 char)        null,
    alternative_payee_account          varchar2(10 char)        null,
    interest_calc_key_date             date                     null,
    interest_calc_freq                 number                   null,
    nterest_calc_run_date              date                     null,
    local_process_flag                 varchar2(1 char)         null,
    bill_of_exchange_limit             number                   null,
    probable_check_paid_time           number                   null,
    inv_crd_check_flag                 varchar2(1 char)         null,
    tolerance_group_code               varchar2(4 char)         null,
    house_bank_key                     varchar2(5 char)         null,
    pay_item_separate_flag             varchar2(1 char)         null,
    withhold_tax_certificate           varchar2(10 char)        null,
    withhold_tax_valid_date            date                     null,
    withhold_tax_code                  varchar2(2 char)         null,
    subsidy_flag                       varchar2(2 char)         null,
    minority_indicator                 varchar2(3 char)         null,
    previous_record_number             varchar2(10 char)        null,
    payment_grouping_code              varchar2(2 char)         null,
    dunning_notice_group_code          varchar2(2 char)         null,
    recipient_type                     varchar2(2 char)         null,
    withhold_tax_exemption             varchar2(1 char)         null,
    withhold_tax_country               varchar2(3 char)         null,
    edi_payment_advice                 varchar2(1 char)         null,
    release_approval_group             varchar2(4 char)         null,
    accounting_fax                     varchar2(31 char)        null,
    accounting_url                     varchar2(130 char)       null,
    credit_payment_terms               varchar2(4 char)         null,
    income_tax_activity_code           varchar2(2 char)         null,
    employ_tax_distbn_type             varchar2(2 char)         null,
    periodic_account_statement         varchar2(1 char)         null,
    certification_date                 date                     null,
    invoice_tolerance_group            varchar2(4 char)         null,
    personnel_number                   number                   null,
    deletion_block_flag                varchar2(1 char)         null,
    accounting_phone                   varchar2(30 char)        null,
    execution_flag                     varchar2(1 char)         null,
    vendor_name_01                     varchar2(35 char)        null,
    vendor_name_02                     varchar2(35 char)        null,
    vendor_name_03                     varchar2(35 char)        null,
    vendor_name_04                     varchar2(35 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_vend_comp is 'Business Data Store - Vendor Company';
comment on column bds_vend_comp.vendor_code is 'Account Number of Vendor or Creditor - lads_ven_ccd.lifnr';
comment on column bds_vend_comp.company_code is 'Company Code - lads_ven_ccd.bukrs';
comment on column bds_vend_comp.create_date is 'Date on which the Record Was Created - lads_ven_ccd.erdat';
comment on column bds_vend_comp.create_user is 'Name of Person who Created the Object - lads_ven_ccd.ernam';
comment on column bds_vend_comp.posting_block_flag is 'Posting block for company code - lads_ven_ccd.sperr';
comment on column bds_vend_comp.deletion_flag is 'Deletion Flag for Master Record (Company Code Level) - lads_ven_ccd.loevm';
comment on column bds_vend_comp.assignment_sort_key is 'Key for sorting according to assignment numbers - lads_ven_ccd.zuawa';
comment on column bds_vend_comp.reconciliation_account is 'Reconciliation Account in General Ledger - lads_ven_ccd.akont';
comment on column bds_vend_comp.authorisation_group is 'Authorization Group - lads_ven_ccd.begru';
comment on column bds_vend_comp.interest_calc_ind is 'Interest calculation indicator - lads_ven_ccd.vzskz';
comment on column bds_vend_comp.payment_method is 'List of the Payment Methods to be Considered - lads_ven_ccd.zwels';
comment on column bds_vend_comp.clearing_flag is 'Indicator: Clearing between customer and vendor? - lads_ven_ccd.xverr';
comment on column bds_vend_comp.payment_block_flag is 'Block key for payment - lads_ven_ccd.zahls';
comment on column bds_vend_comp.payment_terms is 'Terms of payment key - lads_ven_ccd.zterm';
comment on column bds_vend_comp.shipper_account is 'Shippers (Our) Account Number at the Customer or Vendor - lads_ven_ccd.eikto';
comment on column bds_vend_comp.vendor_clerk is 'Clerk at vendor - lads_ven_ccd.zsabe';
comment on column bds_vend_comp.planning_group is 'Planning group - lads_ven_ccd.fdgrv';
comment on column bds_vend_comp.account_clerk_code is 'Accounting clerk - lads_ven_ccd.busab';
comment on column bds_vend_comp.head_office_account is 'Head office account number - lads_ven_ccd.lnrze';
comment on column bds_vend_comp.alternative_payee_account is 'Account number of the alternative payee - lads_ven_ccd.lnrzb';
comment on column bds_vend_comp.interest_calc_key_date is 'Key date of the last interest calculation - lads_ven_ccd.zindt';
comment on column bds_vend_comp.interest_calc_freq is 'Interest calculation frequency in months - lads_ven_ccd.zinrt';
comment on column bds_vend_comp.nterest_calc_run_date is 'Date of the last interest calculation run - lads_ven_ccd.datlz';
comment on column bds_vend_comp.local_process_flag is 'Indicator: Local processing? - lads_ven_ccd.xdezv';
comment on column bds_vend_comp.bill_of_exchange_limit is 'Bill of exchange limit (in local currency) - lads_ven_ccd.webtr';
comment on column bds_vend_comp.probable_check_paid_time is 'Probable time until check is paid - lads_ven_ccd.kultg';
comment on column bds_vend_comp.inv_crd_check_flag is 'Check Flag for Double Invoices or Credit Memos - lads_ven_ccd.reprf';
comment on column bds_vend_comp.tolerance_group_code is 'Tolerance group for the business partner/G/L account - lads_ven_ccd.togru';
comment on column bds_vend_comp.house_bank_key is 'Short key for a house bank - lads_ven_ccd.hbkid';
comment on column bds_vend_comp.pay_item_separate_flag is 'Indicator: Pay all items separately ? - lads_ven_ccd.xpore';
comment on column bds_vend_comp.withhold_tax_certificate is 'Certificate Number of the Withholding Tax Exemption - lads_ven_ccd.qsznr';
comment on column bds_vend_comp.withhold_tax_valid_date is 'Validity Date for Withholding Tax Exemption Certificate - lads_ven_ccd.qszdt';
comment on column bds_vend_comp.withhold_tax_code is 'Withholding Tax Code - lads_ven_ccd.qsskz';
comment on column bds_vend_comp.subsidy_flag is 'Subsidy indicator for determining the reduction rates - lads_ven_ccd.blnkz';
comment on column bds_vend_comp.minority_indicator is 'Minority Indicators - lads_ven_ccd.mindk';
comment on column bds_vend_comp.previous_record_number is 'Previous Master Record Number - lads_ven_ccd.altkn';
comment on column bds_vend_comp.payment_grouping_code is 'Key for Payment Grouping - lads_ven_ccd.zgrup';
comment on column bds_vend_comp.dunning_notice_group_code is 'Key for dunning notice grouping - lads_ven_ccd.mgrup';
comment on column bds_vend_comp.recipient_type is 'Vendor Recipient Type - lads_ven_ccd.qsrec';
comment on column bds_vend_comp.withhold_tax_exemption is 'Authority for Exemption from Withholding Tax - lads_ven_ccd.qsbgr';
comment on column bds_vend_comp.withhold_tax_country is 'Withholding Tax Country Key - lads_ven_ccd.qland';
comment on column bds_vend_comp.edi_payment_advice is 'Indicator: Send Payment Advices by EDI - lads_ven_ccd.xedip';
comment on column bds_vend_comp.release_approval_group is 'Release Approval Group - lads_ven_ccd.frgrp';
comment on column bds_vend_comp.accounting_fax is 'Accounting clerks fax number at the customer/vendor - lads_ven_ccd.tlfxs';
comment on column bds_vend_comp.accounting_url is 'Internet address of partner company clerk - lads_ven_ccd.intad';
comment on column bds_vend_comp.credit_payment_terms is 'Payment Terms Key for Credit Memos - lads_ven_ccd.guzte';
comment on column bds_vend_comp.income_tax_activity_code is 'Activity Code for Gross Income Tax - lads_ven_ccd.gricd';
comment on column bds_vend_comp.employ_tax_distbn_type is 'Distribution Type for Employment Tax - lads_ven_ccd.gridt';
comment on column bds_vend_comp.periodic_account_statement is 'Indicator for periodic account statements - lads_ven_ccd.xausz';
comment on column bds_vend_comp.certification_date is 'Certification date - lads_ven_ccd.cerdt';
comment on column bds_vend_comp.invoice_tolerance_group is 'Tolerance group; Invoice Verification - lads_ven_ccd.togrr';
comment on column bds_vend_comp.personnel_number is 'Personnel Number - lads_ven_ccd.pernr';
comment on column bds_vend_comp.deletion_block_flag is 'Deletion bock for master record (company code level) - lads_ven_ccd.nodel';
comment on column bds_vend_comp.accounting_phone is 'Accounting clerks telephone number at business partner - lads_ven_ccd.tlfns';
comment on column bds_vend_comp.execution_flag is 'Indicator means that the vendor is in execution - lads_ven_ccd.gmvkzk';
comment on column bds_vend_comp.vendor_name_01 is 'Employees last name - lads_ven_hdr.name1';
comment on column bds_vend_comp.vendor_name_02 is 'Employees last name - lads_ven_hdr.name2';
comment on column bds_vend_comp.vendor_name_03 is 'Employees last name - lads_ven_hdr.name3';
comment on column bds_vend_comp.vendor_name_04 is 'Employees last name - lads_ven_hdr.name4';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_comp
   add constraint bds_vend_comp_pk primary key (vendor_code, company_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_comp to lics_app;
grant select, insert, update, delete on bds_vend_comp to lads_app;
grant select, insert, update, delete on bds_vend_comp to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_comp for bds.bds_vend_comp;