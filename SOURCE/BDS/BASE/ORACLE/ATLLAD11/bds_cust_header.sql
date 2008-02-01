/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_header
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Header

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_header
   (customer_code                      varchar2(10 char)        not null,
    sap_idoc_name                      varchar2(30 char)        null,
    sap_idoc_number                    number(16,0)             null,
    sap_idoc_timestamp                 varchar2(14 char)        null,
    bds_lads_date                      date                     null,
    bds_lads_status                    varchar2(2 char)         null,
    order_block_flag                   varchar2(2 char)         null,
    auth_group_code                    varchar2(4 char)         null,
    industry_code                      varchar2(4 char)         null,
    billing_block_flag                 varchar2(2 char)         null,
    fiscal_address_account             varchar2(10 char)        null,
    alternative_payer_account          varchar2(10 char)        null,
    group_key                          varchar2(10 char)        null,
    account_group_code                 varchar2(4 char)         null,
    classification_code                varchar2(2 char)         null,
    vendor_code                        varchar2(10 char)        null,
    delivery_block_flag                varchar2(2 char)         null,
    deletion_flag                      varchar2(1 char)         null,
    posting_block_flag                 varchar2(1 char)         null,
    tax_number_01                      varchar2(16 char)        null,
    tax_number_02                      varchar2(11 char)        null,
    tax_equalization_flag              varchar2(1 char)         null,
    vat_flag                           varchar2(1 char)         null,
    alternative_payee_flag             varchar2(1 char)         null,
    trading_partner_company_code       varchar2(6 char)         null,
    vat_registration_number            varchar2(20 char)        null,
    legal_status                       varchar2(2 char)         null,
    sales_year                         number                   null,
    sales_currency_code                varchar2(5 char)         null,
    sales_point_type                   varchar2(2 char)         null,
    combine_invoice_list_code          varchar2(2 char)         null,
    attribute_04                       varchar2(2 char)         null,
    attribute_05                       varchar2(2 char)         null,
    attribute_06                       varchar2(3 char)         null,
    attribute_07                       varchar2(3 char)         null,
    attribute_08                       varchar2(3 char)         null,
    attribute_09                       varchar2(3 char)         null,
    attribute_10                       varchar2(3 char)         null,
    natural_person                     varchar2(1 char)         null,
    char_field_umsa1                   varchar2(16 char)        null,
    fiscal_year_variant                varchar2(2 char)         null,
    one_time_account_group             varchar2(4 char)         null,
    tax_type                           varchar2(2 char)         null,
    tax_number_type                    varchar2(2 char)         null,
    tax_number_03                      varchar2(18 char)        null,
    tax_number_04                      varchar2(18 char)        null,
    sales_block_flag                   varchar2(2 char)         null,
    cndtn_grp_01                       varchar2(2 char)         null,
    cndtn_grp_02                       varchar2(2 char)         null,
    cndtn_grp_03                       varchar2(2 char)         null,
    cndtn_grp_04                       varchar2(2 char)         null,
    cndtn_grp_05                       varchar2(2 char)         null,
    deletion_block_flag                varchar2(1 char)         null,
    stc_customer_group                 varchar2(3 char)         null,
    plant_code                         varchar2(4 char)         null,
    char_field_zzcustom01              varchar2(1 char)         null,
    custom_attr_13                     varchar2(3 char)         null,
    custom_attr_14                     varchar2(3 char)         null,
    representative_name                varchar2(10 char)        null,
    business_type                      varchar2(30 char)        null,
    industry_type                      varchar2(30 char)        null,
    subledger_acct_procedure           varchar2(20 char)        null,
    region_code                        varchar2(2 char)         null,
    status_code                        varchar2(2 char)         null,
    retail_store_number                varchar2(8 char)         null,
    location_code                      varchar2(10 char)        null,
    demand_plan_group_code             varchar2(10 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_header is 'Business Data Store - Customer Header';
comment on column bds_cust_header.customer_code is 'Customer Number - lads_cus_hdr.kunnr';
comment on column bds_cust_header.sap_idoc_name is 'IDOC name - lads_cus_hdr.idoc_name';
comment on column bds_cust_header.sap_idoc_number is 'IDOC number - lads_cus_hdr.idoc_number';
comment on column bds_cust_header.sap_idoc_timestamp is 'IDOC timestamp - lads_cus_hdr.idoc_timestamp';
comment on column bds_cust_header.bds_lads_date is 'LADS date loaded - lads_cus_hdr.lads_date';
comment on column bds_cust_header.bds_lads_status is 'LADS status (1=valid, 2=error, 3=orphan) - lads_cus_hdr.lads_status';
comment on column bds_cust_header.order_block_flag is 'Central order block for customer - lads_cus_hdr.aufsd';
comment on column bds_cust_header.auth_group_code is 'Authorization Group - lads_cus_hdr.begru';
comment on column bds_cust_header.industry_code is 'Industry key - lads_cus_hdr.brsch';
comment on column bds_cust_header.billing_block_flag is 'Central billing block for customer - lads_cus_hdr.faksd';
comment on column bds_cust_header.fiscal_address_account is 'Account number of the master record with the fiscal address - lads_cus_hdr.fiskn';
comment on column bds_cust_header.alternative_payer_account is 'Account number of an alternative payer - lads_cus_hdr.knrza';
comment on column bds_cust_header.group_key is 'Group key - lads_cus_hdr.konzs';
comment on column bds_cust_header.account_group_code is 'Customer Account Group - lads_cus_hdr.ktokd';
comment on column bds_cust_header.classification_code is 'Customer classification - lads_cus_hdr.kukla';
comment on column bds_cust_header.vendor_code is 'Account Number of Vendor or Creditor - lads_cus_hdr.lifnr';
comment on column bds_cust_header.delivery_block_flag is 'Central delivery block for the customer - lads_cus_hdr.lifsd';
comment on column bds_cust_header.deletion_flag is 'Central Deletion Flag for Master Record - lads_cus_hdr.loevm';
comment on column bds_cust_header.posting_block_flag is 'Central posting block - lads_cus_hdr.sperr';
comment on column bds_cust_header.tax_number_01 is 'Tax Number 1 - lads_cus_hdr.stcd1';
comment on column bds_cust_header.tax_number_02 is 'Tax Number 2 - lads_cus_hdr.stcd2';
comment on column bds_cust_header.tax_equalization_flag is 'Indicator: Business Partner Subject to Equalization Tax? - lads_cus_hdr.stkza';
comment on column bds_cust_header.vat_flag is 'Liable for VAT - lads_cus_hdr.stkzu';
comment on column bds_cust_header.alternative_payee_flag is 'Indicator: Alternative payee in document allowed ? - lads_cus_hdr.xzemp';
comment on column bds_cust_header.trading_partner_company_code is 'Company ID of Trading Partner - lads_cus_hdr.vbund';
comment on column bds_cust_header.vat_registration_number is 'VAT registration number - lads_cus_hdr.stceg';
comment on column bds_cust_header.legal_status is 'Legal status - lads_cus_hdr.gform';
comment on column bds_cust_header.sales_year is 'Year For Which Sales are Given - lads_cus_hdr.umjah';
comment on column bds_cust_header.sales_currency_code is 'Currency of sales figure - lads_cus_hdr.uwaer';
comment on column bds_cust_header.sales_point_type is 'Sales Point Type - lads_cus_hdr.katr2';
comment on column bds_cust_header.combine_invoice_list_code is 'Combine Invoice List - lads_cus_hdr.katr3';
comment on column bds_cust_header.attribute_04 is 'Attribute 4 - lads_cus_hdr.katr4';
comment on column bds_cust_header.attribute_05 is 'Attribute 5 - lads_cus_hdr.katr5';
comment on column bds_cust_header.attribute_06 is 'Attribute 6 - lads_cus_hdr.katr6';
comment on column bds_cust_header.attribute_07 is 'Attribute 7 - lads_cus_hdr.katr7';
comment on column bds_cust_header.attribute_08 is 'Attribute 8 - lads_cus_hdr.katr8';
comment on column bds_cust_header.attribute_09 is 'Attribute 9 - lads_cus_hdr.katr9';
comment on column bds_cust_header.attribute_10 is 'Attribute 10 - lads_cus_hdr.katr10';
comment on column bds_cust_header.natural_person is 'Natural Person - lads_cus_hdr.stkzn';
comment on column bds_cust_header.char_field_umsa1 is 'Field of length 16 - lads_cus_hdr.umsa1';
comment on column bds_cust_header.fiscal_year_variant is 'Fiscal Year Variant - lads_cus_hdr.periv';
comment on column bds_cust_header.one_time_account_group is 'Reference Account Group for One-Time Account (Customer) - lads_cus_hdr.ktocd';
comment on column bds_cust_header.tax_type is 'Tax type - lads_cus_hdr.fityp';
comment on column bds_cust_header.tax_number_type is 'Tax Number Type - lads_cus_hdr.stcdt';
comment on column bds_cust_header.tax_number_03 is 'Tax Number 3 - lads_cus_hdr.stcd3';
comment on column bds_cust_header.tax_number_04 is 'Tax Number 4 - lads_cus_hdr.stcd4';
comment on column bds_cust_header.sales_block_flag is 'Central sales block for customer - lads_cus_hdr.cassd';
comment on column bds_cust_header.cndtn_grp_01 is 'Customer condition group 1 - lads_cus_hdr.kdkg1';
comment on column bds_cust_header.cndtn_grp_02 is 'Customer condition group 2 - lads_cus_hdr.kdkg2';
comment on column bds_cust_header.cndtn_grp_03 is 'Customer condition group 3 - lads_cus_hdr.kdkg3';
comment on column bds_cust_header.cndtn_grp_04 is 'Customer condition group 4 - lads_cus_hdr.kdkg4';
comment on column bds_cust_header.cndtn_grp_05 is 'Customer condition group 5 - lads_cus_hdr.kdkg5';
comment on column bds_cust_header.deletion_block_flag is 'Central deletion block for master record - lads_cus_hdr.nodel';
comment on column bds_cust_header.stc_customer_group is 'Customer group for Substituicao Tributaria calculation - lads_cus_hdr.xsub2';
comment on column bds_cust_header.plant_code is 'Plant - lads_cus_hdr.werks';
comment on column bds_cust_header.char_field_zzcustom01 is 'Character field length 1 - lads_cus_hdr.zzcustom01';
comment on column bds_cust_header.custom_attr_13 is 'Customer Master Custom Additional Attribute  13 POS Place - lads_cus_hdr.zzkatr13';
comment on column bds_cust_header.custom_attr_14 is 'Customer Master Custom Additional Attribute   14 POS Format - lads_cus_hdr.zzkatr14';
comment on column bds_cust_header.representative_name is 'Name of Representative - lads_cus_hdr.j_1kfrepre';
comment on column bds_cust_header.business_type is 'Type of Business - lads_cus_hdr.j_1kftbus';
comment on column bds_cust_header.industry_type is 'Type of Industry - lads_cus_hdr.j_1kftind';
comment on column bds_cust_header.subledger_acct_procedure is 'Subledger acct preprocessing procedure - lads_cus_hdr.psois';
comment on column bds_cust_header.region_code is 'Country Region - lads_cus_hdr.katr1';
comment on column bds_cust_header.status_code is 'Customer status code - lads_cus_hdr.zzcuststat';
comment on column bds_cust_header.retail_store_number is 'Retail Store Number - lads_cus_hdr.zzretstore';
comment on column bds_cust_header.location_code is 'Location Code - lads_cus_hdr.locco';
comment on column bds_cust_header.demand_plan_group_code is 'Demand Planning Group Name - lads_cus_hdr.zzdemplan';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_header
   add constraint bds_cust_header_pk primary key (customer_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_header to lics_app;
grant select, insert, update, delete on bds_cust_header to lads_app;
grant select, insert, update, delete on bds_cust_header to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_header for bds.bds_cust_header;