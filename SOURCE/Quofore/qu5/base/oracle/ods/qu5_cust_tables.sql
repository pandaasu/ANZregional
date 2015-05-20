
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_cust
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_cust] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu5_cust_load cascade constraints;

create table ods.qu5_cust_load (
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
  outlet_ref_id                   varchar2(10 char)               null,
  phone_no                        varchar2(30 char)               null,
  web_address                     varchar2(60 char)               null,
  channel_hier_id                 number(10, 0)                   null,
  banner_hier_id                  number(10, 0)                   null,
  grade_hier_id                   number(10, 0)                   null,
  region_hier_id                  number(10, 0)                   null,
  email_2                         varchar2(50 char)               null,
  sap_no                          varchar2(50 char)               null,
  is_influenceable                number(1, 0)                    null,
  is_wholesaler                   number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu5_cust_load add constraint qu5_cust_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_cust_load_pk on ods.qu5_cust_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_cust_load add constraint qu5_cust_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_cust_load_uk on ods.qu5_cust_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_cust_load is '[Customer][LOAD] Customer master data';
comment on column qu5_cust_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_cust_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_cust_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_cust_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_cust_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_cust_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_cust_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_cust_load.q4x_timestamp is '* Timestamp';
comment on column qu5_cust_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_cust_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu5_cust_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_cust_load.cust_name is '[CustomerName] The name of the Customer';
comment on column qu5_cust_load.cust_ref_id is '[CustomerRefId] The customer reference code.  This will be the Mars Customer Reference Id';
comment on column qu5_cust_load.email is '[Email] The email address';
comment on column qu5_cust_load.fax_no is '[FaxNumber] Fax number';
comment on column qu5_cust_load.outlet_ref_id is '[OutletRefId] Contains the Store Code used for Neilson Lookups.   This will be used to Link a Customer to a Neilson Data';
comment on column qu5_cust_load.phone_no is '[PhoneNumber] Phone number';
comment on column qu5_cust_load.web_address is '[WebAddress] The customer''s web address';
comment on column qu5_cust_load.channel_hier_id is '[Channel_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Channel Hierarchy Id';
comment on column qu5_cust_load.banner_hier_id is '[Banner_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Banner Hierarchy Id';
comment on column qu5_cust_load.grade_hier_id is '[Grade_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Grade Hierarchy Id';
comment on column qu5_cust_load.region_hier_id is '[Region_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Region Hierarchy Id';
comment on column qu5_cust_load.email_2 is '[Email2] Extended Attribute - Used in the Order Integration Module.  Emails will be sent to both Addresses';
comment on column qu5_cust_load.sap_no is '[SAPNumber] Extended attribute - Used in the Order Integration Module.  Used for Direct Orders.  SAP Number';
comment on column qu5_cust_load.is_influenceable is '[Influenceable] Extended attribute - Whether a customer can be sold other products outside it''s channel.   For example: Whether a Pet Care Store can be influenced in selling Chocolate Products';
comment on column qu5_cust_load.is_wholesaler is '[IsWholesaler] Whether the Customer is a WholeSaler or Not. 1= WholeSaler, 0 = Customer';

-- Synonyms
create or replace public synonym qu5_cust_load for ods.qu5_cust_load;

-- Grants
grant select,insert,update,delete on ods.qu5_cust_load to ods_app;
grant select on ods.qu5_cust_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_cust_hist cascade constraints;

create table ods.qu5_cust_hist (
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
  outlet_ref_id                   varchar2(10 char)               null,
  phone_no                        varchar2(30 char)               null,
  web_address                     varchar2(60 char)               null,
  channel_hier_id                 number(10, 0)                   null,
  banner_hier_id                  number(10, 0)                   null,
  grade_hier_id                   number(10, 0)                   null,
  region_hier_id                  number(10, 0)                   null,
  email_2                         varchar2(50 char)               null,
  sap_no                          varchar2(50 char)               null,
  is_influenceable                number(1, 0)                    null,
  is_wholesaler                   number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu5_cust_hist add constraint qu5_cust_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_cust_hist_pk on ods.qu5_cust_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_cust_hist add constraint qu5_cust_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_cust_hist_uk on ods.qu5_cust_hist (id,q4x_batch_id)) compress;

create index ods.qu5_cust_hist_ts on ods.qu5_cust_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_cust_hist is '[Customer][HIST] Customer master data';
comment on column qu5_cust_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_cust_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_cust_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_cust_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_cust_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_cust_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_cust_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_cust_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_cust_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_cust_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu5_cust_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_cust_hist.cust_name is '[CustomerName] The name of the Customer';
comment on column qu5_cust_hist.cust_ref_id is '[CustomerRefId] The customer reference code.  This will be the Mars Customer Reference Id';
comment on column qu5_cust_hist.email is '[Email] The email address';
comment on column qu5_cust_hist.fax_no is '[FaxNumber] Fax number';
comment on column qu5_cust_hist.outlet_ref_id is '[OutletRefId] Contains the Store Code used for Neilson Lookups.   This will be used to Link a Customer to a Neilson Data';
comment on column qu5_cust_hist.phone_no is '[PhoneNumber] Phone number';
comment on column qu5_cust_hist.web_address is '[WebAddress] The customer''s web address';
comment on column qu5_cust_hist.channel_hier_id is '[Channel_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Channel Hierarchy Id';
comment on column qu5_cust_hist.banner_hier_id is '[Banner_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Banner Hierarchy Id';
comment on column qu5_cust_hist.grade_hier_id is '[Grade_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Grade Hierarchy Id';
comment on column qu5_cust_hist.region_hier_id is '[Region_Hierarchy_Id] Foreign Key to the [Hierarchy].[id] Table.  This is the Region Hierarchy Id';
comment on column qu5_cust_hist.email_2 is '[Email2] Extended Attribute - Used in the Order Integration Module.  Emails will be sent to both Addresses';
comment on column qu5_cust_hist.sap_no is '[SAPNumber] Extended attribute - Used in the Order Integration Module.  Used for Direct Orders.  SAP Number';
comment on column qu5_cust_hist.is_influenceable is '[Influenceable] Extended attribute - Whether a customer can be sold other products outside it''s channel.   For example: Whether a Pet Care Store can be influenced in selling Chocolate Products';
comment on column qu5_cust_hist.is_wholesaler is '[IsWholesaler] Whether the Customer is a WholeSaler or Not. 1= WholeSaler, 0 = Customer';

-- Synonyms
create or replace public synonym qu5_cust_hist for ods.qu5_cust_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_cust_hist to ods_app;
grant select on ods.qu5_cust_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
