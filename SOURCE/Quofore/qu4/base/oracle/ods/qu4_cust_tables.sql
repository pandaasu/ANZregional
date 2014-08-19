
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_cust
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_cust] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu4_cust_load cascade constraints;

create table ods.qu4_cust_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  cust_name                       varchar2(50 char)               null,
  cust_ref_id                     varchar2(10 char)               null,
  email                           varchar2(60 char)               null,
  fax_no                          varchar2(30 char)               null,
  group_edi_code                  varchar2(50 char)               null,
  outlet_ref_id                   varchar2(10 char)               null,
  phone_no                        varchar2(30 char)               null,
  store_edi_code                  varchar2(50 char)               null,
  web_addrs                       varchar2(60 char)               null,
  channel_hier_id                 number(10, 0)                   null,
  store_size_hier_id              number(10, 0)                   null,
  must_win_hier_id                number(10, 0)                   null,
  sales_region_hier_id            number(10, 0)                   null,
  merchant_code                   varchar2(50 char)               null,
  merchant_name                   varchar2(50 char)               null,
  buying_group                    varchar2(50 char)               null,
  abn                             varchar2(50 char)               null,
  visit_frequency                 number(10, 0)                   null,
  is_wholesaler                   number(1, 0)                    null,
  xml_ord_flag                    number(1, 0)                    null,
  corporate_flag                  number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu4_cust_load add constraint qu4_cust_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_cust_load_pk on ods.qu4_cust_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_cust_load add constraint qu4_cust_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_cust_load_uk on ods.qu4_cust_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_cust_load is '[Customer][LOAD] Customer master data';
comment on column qu4_cust_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_cust_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_cust_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_cust_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_cust_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_cust_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_cust_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_cust_load.q4x_timestamp is '* Timestamp';
comment on column qu4_cust_load.id is '[Id] Unique Internal ID for the row';
comment on column qu4_cust_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu4_cust_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_cust_load.cust_name is '[CustomerName] The name of the Customer';
comment on column qu4_cust_load.cust_ref_id is '[CustomerRefID] The customer reference code.';
comment on column qu4_cust_load.email is '[Email] The email address';
comment on column qu4_cust_load.fax_no is '[FaxNumber] Fax number';
comment on column qu4_cust_load.group_edi_code is '[GroupEDICode] The EDI code for the Group of stores';
comment on column qu4_cust_load.outlet_ref_id is '[OutletRefID] The Id the customer refers to itself by';
comment on column qu4_cust_load.phone_no is '[PhoneNumber] Phone number';
comment on column qu4_cust_load.store_edi_code is '[StoreEDICode] The Store EDI code.';
comment on column qu4_cust_load.web_addrs is '[WebAddress] The customer''s web address';
comment on column qu4_cust_load.channel_hier_id is '[Channel_Hierarchy_ID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu4_cust_load.store_size_hier_id is '[StoreSize_Hierarchy_ID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu4_cust_load.must_win_hier_id is '[MustWin_Hierarchy_ID] ';
comment on column qu4_cust_load.sales_region_hier_id is '[SalesRegion_Hierarchy_ID] ';
comment on column qu4_cust_load.merchant_code is '[MerchantCode] Extended Attribute - Used to store the Metcash Customer Code';
comment on column qu4_cust_load.merchant_name is '[MerchantName] Extended attribute';
comment on column qu4_cust_load.buying_group is '[BuyingGroup] Extended attribute';
comment on column qu4_cust_load.abn is '[ABN] Extended attribute - ABN Number of Customer';
comment on column qu4_cust_load.visit_frequency is '[VisitFrequency] Number of days between visits (e.g. fortnightly = 14)';
comment on column qu4_cust_load.is_wholesaler is '[IsWholesaler] Whether the Customer is a WholeSaler or Not. 1= WholeSaler, 0 = Customer';
comment on column qu4_cust_load.xml_ord_flag is '[XMLOrderFlag] Extended attribute. Flag to indicate if the order needs to be sent as an XML file. True = ''Y'', False = ''N'' (Forward looking attribute)';
comment on column qu4_cust_load.corporate_flag is '[CorporateFlag] Extended attribute. Used to determine if customer is corporately owned or not. For instance, Company owned BP outlet as apposed to a franchised owned BP outlet. Possible values: 0,1 (0 = not Corporate)';

-- Synonyms
create or replace public synonym qu4_cust_load for ods.qu4_cust_load;

-- Grants
grant select,insert,update,delete on ods.qu4_cust_load to ods_app;
grant select on ods.qu4_cust_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_cust_hist cascade constraints;

create table ods.qu4_cust_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  cust_name                       varchar2(50 char)               null,
  cust_ref_id                     varchar2(10 char)               null,
  email                           varchar2(60 char)               null,
  fax_no                          varchar2(30 char)               null,
  group_edi_code                  varchar2(50 char)               null,
  outlet_ref_id                   varchar2(10 char)               null,
  phone_no                        varchar2(30 char)               null,
  store_edi_code                  varchar2(50 char)               null,
  web_addrs                       varchar2(60 char)               null,
  channel_hier_id                 number(10, 0)                   null,
  store_size_hier_id              number(10, 0)                   null,
  must_win_hier_id                number(10, 0)                   null,
  sales_region_hier_id            number(10, 0)                   null,
  merchant_code                   varchar2(50 char)               null,
  merchant_name                   varchar2(50 char)               null,
  buying_group                    varchar2(50 char)               null,
  abn                             varchar2(50 char)               null,
  visit_frequency                 number(10, 0)                   null,
  is_wholesaler                   number(1, 0)                    null,
  xml_ord_flag                    number(1, 0)                    null,
  corporate_flag                  number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu4_cust_hist add constraint qu4_cust_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_cust_hist_pk on ods.qu4_cust_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_cust_hist add constraint qu4_cust_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_cust_hist_uk on ods.qu4_cust_hist (id,q4x_batch_id)) compress;

create index ods.qu4_cust_hist_ts on ods.qu4_cust_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_cust_hist is '[Customer][HIST] Customer master data';
comment on column qu4_cust_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_cust_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_cust_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_cust_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_cust_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_cust_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_cust_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_cust_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_cust_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu4_cust_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu4_cust_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_cust_hist.cust_name is '[CustomerName] The name of the Customer';
comment on column qu4_cust_hist.cust_ref_id is '[CustomerRefID] The customer reference code.';
comment on column qu4_cust_hist.email is '[Email] The email address';
comment on column qu4_cust_hist.fax_no is '[FaxNumber] Fax number';
comment on column qu4_cust_hist.group_edi_code is '[GroupEDICode] The EDI code for the Group of stores';
comment on column qu4_cust_hist.outlet_ref_id is '[OutletRefID] The Id the customer refers to itself by';
comment on column qu4_cust_hist.phone_no is '[PhoneNumber] Phone number';
comment on column qu4_cust_hist.store_edi_code is '[StoreEDICode] The Store EDI code.';
comment on column qu4_cust_hist.web_addrs is '[WebAddress] The customer''s web address';
comment on column qu4_cust_hist.channel_hier_id is '[Channel_Hierarchy_ID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu4_cust_hist.store_size_hier_id is '[StoreSize_Hierarchy_ID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu4_cust_hist.must_win_hier_id is '[MustWin_Hierarchy_ID] ';
comment on column qu4_cust_hist.sales_region_hier_id is '[SalesRegion_Hierarchy_ID] ';
comment on column qu4_cust_hist.merchant_code is '[MerchantCode] Extended Attribute - Used to store the Metcash Customer Code';
comment on column qu4_cust_hist.merchant_name is '[MerchantName] Extended attribute';
comment on column qu4_cust_hist.buying_group is '[BuyingGroup] Extended attribute';
comment on column qu4_cust_hist.abn is '[ABN] Extended attribute - ABN Number of Customer';
comment on column qu4_cust_hist.visit_frequency is '[VisitFrequency] Number of days between visits (e.g. fortnightly = 14)';
comment on column qu4_cust_hist.is_wholesaler is '[IsWholesaler] Whether the Customer is a WholeSaler or Not. 1= WholeSaler, 0 = Customer';
comment on column qu4_cust_hist.xml_ord_flag is '[XMLOrderFlag] Extended attribute. Flag to indicate if the order needs to be sent as an XML file. True = ''Y'', False = ''N'' (Forward looking attribute)';
comment on column qu4_cust_hist.corporate_flag is '[CorporateFlag] Extended attribute. Used to determine if customer is corporately owned or not. For instance, Company owned BP outlet as apposed to a franchised owned BP outlet. Possible values: 0,1 (0 = not Corporate)';

-- Synonyms
create or replace public synonym qu4_cust_hist for ods.qu4_cust_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_cust_hist to ods_app;
grant select on ods.qu4_cust_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
