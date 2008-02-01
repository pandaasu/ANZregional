/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_comp
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Company

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_comp
   (customer_code                      varchar2(10 char)        not null,
    company_code                       varchar2(6 char)         not null,
    posting_block_flag                 varchar2(1 char)         null,
    deletion_flag                      varchar2(1 char)         null,
    assignment_sort_key                varchar2(3 char)         null,
    account_clerk_code                 varchar2(2 char)         null,
    reconciliation_account             varchar2(10 char)        null,
    auth_group_code                    varchar2(4 char)         null,
    head_office_account_number         varchar2(10 char)        null,
    alt_payer_account_number           varchar2(10 char)        null,
    cust_payment_notice_ci_flag        varchar2(1 char)         null,
    sales_payment_notice_flag          varchar2(1 char)         null,
    legal_payment_notice_flag          varchar2(1 char)         null,
    account_payment_notice_flag        varchar2(1 char)         null,
    cust_payment_notice_woci_flag      varchar2(1 char)         null,
    payment_method_code                varchar2(10 char)        null,
    cust_vend_clearing_flag            varchar2(1 char)         null,
    payment_block_flag                 varchar2(1 char)         null,
    payment_terms_code                 varchar2(4 char)         null,
    payment_terms_boec_flag            varchar2(4 char)         null,
    interest_calc_code                 varchar2(2 char)         null,
    interest_calc_last_date            date                     null,
    interest_calc_freq                 number                   null,
    cust_mars_account                  varchar2(12 char)        null,
    cust_user                          varchar2(15 char)        null,
    cust_memo                          varchar2(30 char)        null,
    planning_group_code                varchar2(10 char)        null,
    export_cred_insur_inst_nbr         varchar2(2 char)         null,
    insured_amount                     number                   null,
    insurance_laed_months              number                   null,
    deductable_percent_rate            number                   null,
    insurance_number                   varchar2(10 char)        null,
    insurance_valid_date               date                     null,
    collective_inv_variant             varchar2(1 char)         null,
    local_processing_flag              varchar2(1 char)         null,
    periodic_statements_flag           varchar2(1 char)         null,
    bill_of_exch_limit                 number                   null,
    next_payee                         varchar2(10 char)        null,
    interest_calc_run_date             date                     null,
    record_pay_history_flag            varchar2(1 char)         null,
    tolerance_group_code               varchar2(4 char)         null,
    probable_payment_time              number                   null,
    house_bank_key                     varchar2(5 char)         null,
    pay_items_separately               varchar2(1 char)         null,
    reduction_rate_subsidy             varchar2(2 char)         null,
    prev_master_record                 varchar2(10 char)        null,
    payment_grouping_code              varchar2(2 char)         null,
    known_leave_key                    varchar2(4 char)         null,
    dunning_notice_group_code          varchar2(2 char)         null,
    payment_lockbox                    varchar2(7 char)         null,
    payment_method_supplement          varchar2(2 char)         null,
    buying_group_account_number        varchar2(10 char)        null,
    payment_advice_select_rule         varchar2(3 char)         null,
    edi_payments_flag                  varchar2(1 char)         null,
    release_approval_group_code        varchar2(4 char)         null,
    convert_version_reason_code        varchar2(3 char)         null,
    cust_vend_fax                      varchar2(31 char)        null,
    cust_vend_phone                    number                   null,
    cust_vend_email                    varchar2(130 char)       null,
    credit_memo_payment_terms          varchar2(4 char)         null,
    gross_income_tax_activity          varchar2(2 char)         null,
    employ_tax_distbn_type             varchar2(2 char)         null,
    value_adjust_key                   varchar2(2 char)         null,
    deletion_block_flag                varchar2(1 char)         null,
    partner_phone                      varchar2(30 char)        null,
    receivable_pledging_flag           varchar2(2 char)         null,
    debt_enforecement_flag             varchar2(1 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_comp is 'Business Data Store - Customer Company';
comment on column bds_cust_comp.customer_code is 'Customer Number - lads_cus_cud.kunnr';
comment on column bds_cust_comp.company_code is 'Company Code - lads_cus_cud.bukrs';
comment on column bds_cust_comp.posting_block_flag is 'Posting block for company code - lads_cus_cud.sperr';
comment on column bds_cust_comp.deletion_flag is 'Deletion Flag for Master Record (Company Code Level) - lads_cus_cud.loevm';
comment on column bds_cust_comp.assignment_sort_key is 'Key for sorting according to assignment numbers - lads_cus_cud.zuawa';
comment on column bds_cust_comp.account_clerk_code is 'Accounting clerk - lads_cus_cud.busab';
comment on column bds_cust_comp.reconciliation_account is 'Reconciliation Account in General Ledger - lads_cus_cud.akont';
comment on column bds_cust_comp.auth_group_code is 'Authorization Group - lads_cus_cud.begru';
comment on column bds_cust_comp.head_office_account_number is 'Head office account number (in branch accounts) - lads_cus_cud.knrze';
comment on column bds_cust_comp.alt_payer_account_number is 'Account number of an alternative payer - lads_cus_cud.knrzb';
comment on column bds_cust_comp.cust_payment_notice_ci_flag is 'Indicator: Payment notice to customer (with cleared items)? - lads_cus_cud.zamim';
comment on column bds_cust_comp.sales_payment_notice_flag is 'Indicator: payment notice to sales department? - lads_cus_cud.zamiv';
comment on column bds_cust_comp.legal_payment_notice_flag is 'Indicator: payment notice to legal department? - lads_cus_cud.zamir';
comment on column bds_cust_comp.account_payment_notice_flag is 'Indicator: Payment notice to the accounting department ? - lads_cus_cud.zamib';
comment on column bds_cust_comp.cust_payment_notice_woci_flag is 'Indicator: payment notice to customer (w/o cleared items)? - lads_cus_cud.zamio';
comment on column bds_cust_comp.payment_method_code is 'List of the Payment Methods to be Considered - lads_cus_cud.zwels';
comment on column bds_cust_comp.cust_vend_clearing_flag is 'Indicator: Clearing between customer and vendor ? - lads_cus_cud.xverr';
comment on column bds_cust_comp.payment_block_flag is 'Block key for payment - lads_cus_cud.zahls';
comment on column bds_cust_comp.payment_terms_code is 'Terms of payment key - lads_cus_cud.zterm';
comment on column bds_cust_comp.payment_terms_boec_flag is 'Terms of payment key for bill of exchange charges - lads_cus_cud.wakon';
comment on column bds_cust_comp.interest_calc_code is 'Interest calculation indicator - lads_cus_cud.vzskz';
comment on column bds_cust_comp.interest_calc_last_date is 'Key date of the last interest calculation - lads_cus_cud.zindt';
comment on column bds_cust_comp.interest_calc_freq is 'Interest calculation frequency in months - lads_cus_cud.zinrt';
comment on column bds_cust_comp.cust_mars_account is 'Our account number at customer - lads_cus_cud.eikto';
comment on column bds_cust_comp.cust_user is 'User at customer - lads_cus_cud.zsabe';
comment on column bds_cust_comp.cust_memo is 'Memo - lads_cus_cud.kverm';
comment on column bds_cust_comp.planning_group_code is 'Planning group - lads_cus_cud.fdgrv';
comment on column bds_cust_comp.export_cred_insur_inst_nbr is 'Export credit insurance institution number - lads_cus_cud.vrbkz';
comment on column bds_cust_comp.insured_amount is 'Amount Insured - lads_cus_cud.vlibb';
comment on column bds_cust_comp.insurance_laed_months is 'Insurance lead months - lads_cus_cud.vrszl';
comment on column bds_cust_comp.deductable_percent_rate is 'Deductible percentage rate - lads_cus_cud.vrspr';
comment on column bds_cust_comp.insurance_number is 'Insurance number - lads_cus_cud.vrsnr';
comment on column bds_cust_comp.insurance_valid_date is 'Insurance validity date - lads_cus_cud.verdt';
comment on column bds_cust_comp.collective_inv_variant is 'Collective invoice variant - lads_cus_cud.perkz';
comment on column bds_cust_comp.local_processing_flag is 'Indicator: Local processing? - lads_cus_cud.xdezv';
comment on column bds_cust_comp.periodic_statements_flag is 'Indicator for periodic account statements - lads_cus_cud.xausz';
comment on column bds_cust_comp.bill_of_exch_limit is 'Bill of exchange limit (in local currency) - lads_cus_cud.webtr';
comment on column bds_cust_comp.next_payee is 'Next payee - lads_cus_cud.remit';
comment on column bds_cust_comp.interest_calc_run_date is 'Date of the last interest calculation run - lads_cus_cud.datlz';
comment on column bds_cust_comp.record_pay_history_flag is 'Indicator: Record Payment History ? - lads_cus_cud.xzver';
comment on column bds_cust_comp.tolerance_group_code is 'Tolerance group for the business partner/G/L account - lads_cus_cud.togru';
comment on column bds_cust_comp.probable_payment_time is 'Probable time until check is paid - lads_cus_cud.kultg';
comment on column bds_cust_comp.house_bank_key is 'Short key for a house bank - lads_cus_cud.hbkid';
comment on column bds_cust_comp.pay_items_separately is 'Indicator: Pay all items separately ? - lads_cus_cud.xpore';
comment on column bds_cust_comp.reduction_rate_subsidy is 'Subsidy indicator for determining the reduction rates - lads_cus_cud.blnkz';
comment on column bds_cust_comp.prev_master_record is 'Previous Master Record Number - lads_cus_cud.altkn';
comment on column bds_cust_comp.payment_grouping_code is 'Key for Payment Grouping - lads_cus_cud.zgrup';
comment on column bds_cust_comp.known_leave_key is 'Short Key for Known/Negotiated Leave - lads_cus_cud.urlid';
comment on column bds_cust_comp.dunning_notice_group_code is 'Key for dunning notice grouping - lads_cus_cud.mgrup';
comment on column bds_cust_comp.payment_lockbox is 'Key of the Lockbox to Which the Customer Is To Pay - lads_cus_cud.lockb';
comment on column bds_cust_comp.payment_method_supplement is 'Payment method supplement - lads_cus_cud.uzawe';
comment on column bds_cust_comp.buying_group_account_number is 'Account Number of Buying Group - lads_cus_cud.ekvbd';
comment on column bds_cust_comp.payment_advice_select_rule is 'Selection Rule for Payment Advices - lads_cus_cud.sregl';
comment on column bds_cust_comp.edi_payments_flag is 'Indicator: Send Payment Advices by EDI - lads_cus_cud.xedip';
comment on column bds_cust_comp.release_approval_group_code is 'Release Approval Group - lads_cus_cud.frgrp';
comment on column bds_cust_comp.convert_version_reason_code is 'Reason Code Conversion Version - lads_cus_cud.vrsdg';
comment on column bds_cust_comp.cust_vend_fax is 'Accounting clerks fax number at the customer/vendor - lads_cus_cud.tlfxs';
comment on column bds_cust_comp.cust_vend_phone is 'Personnel Number - lads_cus_cud.pernr';
comment on column bds_cust_comp.cust_vend_email is 'Internet address of partner company clerk - lads_cus_cud.intad';
comment on column bds_cust_comp.credit_memo_payment_terms is 'Payment Terms Key for Credit Memos - lads_cus_cud.guzte';
comment on column bds_cust_comp.gross_income_tax_activity is 'Activity Code for Gross Income Tax - lads_cus_cud.gricd';
comment on column bds_cust_comp.employ_tax_distbn_type is 'Distribution Type for Employment Tax - lads_cus_cud.gridt';
comment on column bds_cust_comp.value_adjust_key is 'Value Adjustment Key - lads_cus_cud.wbrsl';
comment on column bds_cust_comp.deletion_block_flag is 'Deletion bock for master record (company code level) - lads_cus_cud.nodel';
comment on column bds_cust_comp.partner_phone is 'Accounting clerks telephone number at business partner - lads_cus_cud.tlfns';
comment on column bds_cust_comp.receivable_pledging_flag is 'Accounts Receivable Pledging Indicator - lads_cus_cud.cession_kz';
comment on column bds_cust_comp.debt_enforecement_flag is 'Indicates that a customer is in debt enforcement - lads_cus_cud.gmvkzd';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_comp
   add constraint bds_cust_comp_pk primary key (customer_code, company_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_comp to lics_app;
grant select, insert, update, delete on bds_cust_comp to lads_app;
grant select, insert, update, delete on bds_cust_comp to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_comp for bds.bds_cust_comp;