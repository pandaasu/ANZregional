/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds 
 Table   : bds_vend_comp_ics 
 Owner   : bds 
 Author  : Trevor Keon 

 Description 
 ----------- 
 Business Data Store - bds_vend_comp_ics 

 YYYY/MM   Author         Description 
 -------   ------         ----------- 
 2008/04   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation 
/**/
create table bds.bds_vend_comp_ics
(
  vendor_code                 varchar2(10 char) not null,
  company_code                varchar2(6 char)  not null,
  create_date                 date,
  create_user                 varchar2(12 char),
  posting_block_flag          varchar2(1 char),
  deletion_flag               varchar2(1 char),
  assignment_sort_key         varchar2(3 char),
  reconciliation_account      varchar2(10 char),
  authorisation_group         varchar2(4 char),
  interest_calc_ind           varchar2(2 char),
  payment_method              varchar2(10 char),
  clearing_flag               varchar2(1 char),
  payment_block_flag          varchar2(1 char),
  payment_terms               varchar2(4 char),
  shipper_account             varchar2(12 char),
  vendor_clerk                varchar2(15 char),
  planning_group              varchar2(10 char),
  account_clerk_code          varchar2(2 char),
  head_office_account         varchar2(10 char),
  alternative_payee_account   varchar2(10 char),
  interest_calc_key_date      date,
  interest_calc_freq          number,
  nterest_calc_run_date       date,
  local_process_flag          varchar2(1 char),
  bill_of_exchange_limit      number,
  probable_check_paid_time    number,
  inv_crd_check_flag          varchar2(1 char),
  tolerance_group_code        varchar2(4 char),
  house_bank_key              varchar2(5 char),
  pay_item_separate_flag      varchar2(1 char),
  withhold_tax_certificate    varchar2(10 char),
  withhold_tax_valid_date     date,
  withhold_tax_code           varchar2(2 char),
  subsidy_flag                varchar2(2 char),
  minority_indicator          varchar2(3 char),
  previous_record_number      varchar2(10 char),
  payment_grouping_code       varchar2(2 char),
  dunning_notice_group_code   varchar2(2 char),
  recipient_type              varchar2(2 char),
  withhold_tax_exemption      varchar2(1 char),
  withhold_tax_country        varchar2(3 char),
  edi_payment_advice          varchar2(1 char),
  release_approval_group      varchar2(4 char),
  accounting_fax              varchar2(31 char),
  accounting_url              varchar2(130 char),
  credit_payment_terms        varchar2(4 char),
  income_tax_activity_code    varchar2(2 char),
  employ_tax_distbn_type      varchar2(2 char),
  periodic_account_statement  varchar2(1 char),
  certification_date          date,
  invoice_tolerance_group     varchar2(4 char),
  personnel_number            number,
  deletion_block_flag         varchar2(1 char),
  accounting_phone            varchar2(30 char),
  execution_flag              varchar2(1 char),
  vendor_name_01              varchar2(35 char),
  vendor_name_02              varchar2(35 char),
  vendor_name_03              varchar2(35 char),
  vendor_name_04              varchar2(35 char)
);

/**/
/* Primary Key Constraint 
/**/
alter table bds.bds_vend_comp_ics
   add constraint bds_vend_comp_ics_pk primary key (vendor_code, company_code);

/**/
/* Authority 
/**/
grant select, update, delete, insert on bds.bds_vend_comp_ics to bds_app with grant option;
grant select on bds.bds_vend_comp_ics to appsupport;
grant select on bds.bds_vend_comp_ics to fcs_user;
grant select on bds.bds_vend_comp_ics to public;

/**/
/* Synonym 
/**/
create or replace public synonym bds_vend_comp_ics for bds.bds_vend_comp_ics;