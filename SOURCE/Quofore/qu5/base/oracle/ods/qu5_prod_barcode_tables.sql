
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_prod_barcode
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_prod_barcode] table creation script _load and _hist

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
drop table ods.qu5_prod_barcode_load cascade constraints;

create table ods.qu5_prod_barcode_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  created_date                    date                            null,
  barcode_desc                    varchar2(50 char)               null,
  barcode_type_id                 number(10, 0)                   not null,
  barcode_type_id_desc            varchar2(50 char)               null,
  code                            varchar2(35 char)               null,
  prod_id                         number(10, 0)                   null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_prod_barcode_load add constraint qu5_prod_barcode_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_prod_barcode_load_pk on ods.qu5_prod_barcode_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_prod_barcode_load add constraint qu5_prod_barcode_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_prod_barcode_load_uk on ods.qu5_prod_barcode_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_prod_barcode_load is '[ProductBarcode][LOAD] Child table of product. Each barcode has a type assigned (e.g. RSU_Barcode, MSU_Barcode). Then products are assigned a barcode type and actual barcode value in this table.';
comment on column qu5_prod_barcode_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_prod_barcode_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_prod_barcode_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_prod_barcode_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_prod_barcode_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_prod_barcode_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_prod_barcode_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_prod_barcode_load.q4x_timestamp is '* Timestamp';
comment on column qu5_prod_barcode_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_prod_barcode_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_prod_barcode_load.barcode_desc is '[BarcodeDescription] Describes the package this barcode is on. E.g. Food Stuffs South Island Code,Countdown Code,Unit Barcode,Inner Barcode,Case Barcode,Food Stuffs Auckland Code,Food Stuffs Wellington Code';
comment on column qu5_prod_barcode_load.barcode_type_id is '[BarcodeTypeId] The Id of the Barcode Type from General List';
comment on column qu5_prod_barcode_load.barcode_type_id_desc is '[BarcodeTypeId_Description] Language Description in default system language';
comment on column qu5_prod_barcode_load.code is '[Code] The code represented by the barcode.';
comment on column qu5_prod_barcode_load.prod_id is '[Product_Id] Foreign key from [Product].[Id]. Links a specific product to a product barcode';
comment on column qu5_prod_barcode_load.prod_id_desc is '[Product_Id_Description] Product Id Description of the ProductBarcode';

-- Synonyms
create or replace public synonym qu5_prod_barcode_load for ods.qu5_prod_barcode_load;

-- Grants
grant select,insert,update,delete on ods.qu5_prod_barcode_load to ods_app;
grant select on ods.qu5_prod_barcode_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_prod_barcode_hist cascade constraints;

create table ods.qu5_prod_barcode_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  created_date                    date                            null,
  barcode_desc                    varchar2(50 char)               null,
  barcode_type_id                 number(10, 0)                   not null,
  barcode_type_id_desc            varchar2(50 char)               null,
  code                            varchar2(35 char)               null,
  prod_id                         number(10, 0)                   null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_prod_barcode_hist add constraint qu5_prod_barcode_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_prod_barcode_hist_pk on ods.qu5_prod_barcode_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_prod_barcode_hist add constraint qu5_prod_barcode_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_prod_barcode_hist_uk on ods.qu5_prod_barcode_hist (id,q4x_batch_id)) compress;

create index ods.qu5_prod_barcode_hist_ts on ods.qu5_prod_barcode_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_prod_barcode_hist is '[ProductBarcode][HIST] Child table of product. Each barcode has a type assigned (e.g. RSU_Barcode, MSU_Barcode). Then products are assigned a barcode type and actual barcode value in this table.';
comment on column qu5_prod_barcode_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_prod_barcode_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_prod_barcode_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_prod_barcode_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_prod_barcode_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_prod_barcode_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_prod_barcode_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_prod_barcode_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_prod_barcode_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_prod_barcode_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_prod_barcode_hist.barcode_desc is '[BarcodeDescription] Describes the package this barcode is on. E.g. Food Stuffs South Island Code,Countdown Code,Unit Barcode,Inner Barcode,Case Barcode,Food Stuffs Auckland Code,Food Stuffs Wellington Code';
comment on column qu5_prod_barcode_hist.barcode_type_id is '[BarcodeTypeId] The Id of the Barcode Type from General List';
comment on column qu5_prod_barcode_hist.barcode_type_id_desc is '[BarcodeTypeId_Description] Language Description in default system language';
comment on column qu5_prod_barcode_hist.code is '[Code] The code represented by the barcode.';
comment on column qu5_prod_barcode_hist.prod_id is '[Product_Id] Foreign key from [Product].[Id]. Links a specific product to a product barcode';
comment on column qu5_prod_barcode_hist.prod_id_desc is '[Product_Id_Description] Product Id Description of the ProductBarcode';

-- Synonyms
create or replace public synonym qu5_prod_barcode_hist for ods.qu5_prod_barcode_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_prod_barcode_hist to ods_app;
grant select on ods.qu5_prod_barcode_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
