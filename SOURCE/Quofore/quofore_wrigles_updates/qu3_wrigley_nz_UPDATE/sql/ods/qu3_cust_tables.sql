
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_cust
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_cust] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu3_cust_load cascade constraints;

create table ods.qu3_cust_load (
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
  cust_hier_id                    number(10, 0)                   null,
  grade_hier_id                   number(10, 0)                   null,
  structured_id                   number(10, 0)                   null,
  barons_id                       number(10, 0)                   null,
  ind_groc_program_id             number(10, 0)                   null,
  locality_id                     number(10, 0)                   null,
  abn_no                          varchar2(50 char)               null,
  visit_frequency                 number(10, 0)                   null,
  expo_tier_id                    varchar2(50 char)               null,
  is_wholesaler                   number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu3_cust_load add constraint qu3_cust_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_cust_load_pk on ods.qu3_cust_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_cust_load add constraint qu3_cust_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_cust_load_uk on ods.qu3_cust_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_cust_load is '[Customer][LOAD] Customer master data';
comment on column qu3_cust_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_cust_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_cust_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_cust_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_cust_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_cust_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_cust_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_cust_load.q4x_timestamp is '* Timestamp';
comment on column qu3_cust_load.id is '[Id] Unique Internal ID for the row';
comment on column qu3_cust_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu3_cust_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu3_cust_load.cust_name is '[CustomerName] The name of the Customer';
comment on column qu3_cust_load.cust_ref_id is '[CustomerRefID] The customer reference code.';
comment on column qu3_cust_load.email is '[Email] The email address';
comment on column qu3_cust_load.fax_no is '[FaxNumber] Fax number';
comment on column qu3_cust_load.group_edi_code is '[GroupEDICode] The EDI code for the Group of stores';
comment on column qu3_cust_load.outlet_ref_id is '[OutletRefID] The Id the customer refers to itself by';
comment on column qu3_cust_load.phone_no is '[PhoneNumber] Phone number';
comment on column qu3_cust_load.store_edi_code is '[StoreEDICode] The Store EDI code.';
comment on column qu3_cust_load.web_addrs is '[WebAddress] The customer''s web address';
comment on column qu3_cust_load.cust_hier_id is '[CustomerHierarchyID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu3_cust_load.grade_hier_id is '[GradeHierarchyID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu3_cust_load.structured_id is '[StructuredID] Extended attribute: Values = Structured or Unstructured';
comment on column qu3_cust_load.barons_id is '[BaronsID] Extended attribute: Used to identify the ownership or trading name of a group of independent stores.';
comment on column qu3_cust_load.ind_groc_program_id is '[IndGrocProgramID] Extended attribute for independent grocery program';
comment on column qu3_cust_load.locality_id is '[LocalityID] Extended attribute for locality';
comment on column qu3_cust_load.abn_no is '[ABNNumber] ';
comment on column qu3_cust_load.visit_frequency is '[VisitFrequency] # of weeks suggested between visits. For reporting purposes';
comment on column qu3_cust_load.expo_tier_id is '[ExpoTierID] Extended attribute';
comment on column qu3_cust_load.is_wholesaler is '[IsWholesaler] Whether this customer is actually a wholesaler';

-- Synonyms
create or replace public synonym qu3_cust_load for ods.qu3_cust_load;

-- Grants
grant select,insert,update,delete on ods.qu3_cust_load to ods_app;
grant select on ods.qu3_cust_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_cust_hist cascade constraints;

create table ods.qu3_cust_hist (
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
  cust_hier_id                    number(10, 0)                   null,
  grade_hier_id                   number(10, 0)                   null,
  structured_id                   number(10, 0)                   null,
  barons_id                       number(10, 0)                   null,
  ind_groc_program_id             number(10, 0)                   null,
  locality_id                     number(10, 0)                   null,
  abn_no                          varchar2(50 char)               null,
  visit_frequency                 number(10, 0)                   null,
  expo_tier_id                    varchar2(50 char)               null,
  is_wholesaler                   number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu3_cust_hist add constraint qu3_cust_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_cust_hist_pk on ods.qu3_cust_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_cust_hist add constraint qu3_cust_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_cust_hist_uk on ods.qu3_cust_hist (id,q4x_batch_id)) compress;

create index ods.qu3_cust_hist_ts on ods.qu3_cust_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_cust_hist is '[Customer][HIST] Customer master data';
comment on column qu3_cust_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_cust_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_cust_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_cust_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_cust_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_cust_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_cust_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_cust_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_cust_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu3_cust_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu3_cust_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu3_cust_hist.cust_name is '[CustomerName] The name of the Customer';
comment on column qu3_cust_hist.cust_ref_id is '[CustomerRefID] The customer reference code.';
comment on column qu3_cust_hist.email is '[Email] The email address';
comment on column qu3_cust_hist.fax_no is '[FaxNumber] Fax number';
comment on column qu3_cust_hist.group_edi_code is '[GroupEDICode] The EDI code for the Group of stores';
comment on column qu3_cust_hist.outlet_ref_id is '[OutletRefID] The Id the customer refers to itself by';
comment on column qu3_cust_hist.phone_no is '[PhoneNumber] Phone number';
comment on column qu3_cust_hist.store_edi_code is '[StoreEDICode] The Store EDI code.';
comment on column qu3_cust_hist.web_addrs is '[WebAddress] The customer''s web address';
comment on column qu3_cust_hist.cust_hier_id is '[CustomerHierarchyID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu3_cust_hist.grade_hier_id is '[GradeHierarchyID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column qu3_cust_hist.structured_id is '[StructuredID] Extended attribute: Values = Structured or Unstructured';
comment on column qu3_cust_hist.barons_id is '[BaronsID] Extended attribute: Used to identify the ownership or trading name of a group of independent stores.';
comment on column qu3_cust_hist.ind_groc_program_id is '[IndGrocProgramID] Extended attribute for independent grocery program';
comment on column qu3_cust_hist.locality_id is '[LocalityID] Extended attribute for locality';
comment on column qu3_cust_hist.abn_no is '[ABNNumber] ';
comment on column qu3_cust_hist.visit_frequency is '[VisitFrequency] # of weeks suggested between visits. For reporting purposes';
comment on column qu3_cust_hist.expo_tier_id is '[ExpoTierID] Extended attribute';
comment on column qu3_cust_hist.is_wholesaler is '[IsWholesaler] Whether this customer is actually a wholesaler';

-- Synonyms
create or replace public synonym qu3_cust_hist for ods.qu3_cust_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_cust_hist to ods_app;
grant select on ods.qu3_cust_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
