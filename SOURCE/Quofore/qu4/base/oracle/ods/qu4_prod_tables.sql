
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_prod
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_prod] table creation script _load and _hist

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
drop table ods.qu4_prod_load cascade constraints;

create table ods.qu4_prod_load (
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
  inners_per_case                 number(5, 0)                    null,
  is_new                          number(1, 0)                    null,
  is_priority                     number(1, 0)                    null,
  list_price                      number(18, 4)                   null,
  unit_of_measure_id              number(10, 0)                   not null,
  unit_of_measure_id_desc         varchar2(50 char)               null,
  pack_size                       number(5, 0)                    null,
  pack_desc                       varchar2(200 char)              null,
  unit_size                       number(5, 0)                    null,
  sku_code                        varchar2(50 char)               null,
  name                            varchar2(50 char)               null,
  units_per_case                  number(5, 0)                    null,
  units_per_inner                 number(5, 0)                    null,
  prod_hier_id                    number(10, 0)                   null,
  brand_hier_id                   number(10, 0)                   null,
  new_start                       date                            null,
  new_end                         date                            null,
  pack_size_desc                  varchar2(200 char)              null,
  inner_name                      varchar2(50 char)               null,
  inner_price                     number(18, 4)                   null,
  case_name                       varchar2(50 char)               null,
  cases_per_layer                 number(10, 0)                   null,
  layers_per_pallet               number(10, 0)                   null,
  unit_rrp                        number(18, 4)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_prod_load add constraint qu4_prod_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_prod_load_pk on ods.qu4_prod_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_prod_load add constraint qu4_prod_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_prod_load_uk on ods.qu4_prod_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_prod_load is '[Product][LOAD] Product master data.';
comment on column qu4_prod_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_prod_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_prod_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_prod_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_prod_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_prod_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_prod_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_prod_load.q4x_timestamp is '* Timestamp';
comment on column qu4_prod_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_prod_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu4_prod_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_prod_load.inners_per_case is '[InnersPerCase] The number of inner packages in a case.';
comment on column qu4_prod_load.is_new is '[IsNew] Is this product being considered a New product.';
comment on column qu4_prod_load.is_priority is '[IsPriority] Is this product currently a priority item';
comment on column qu4_prod_load.list_price is '[ListPrice] The list price of the product.';
comment on column qu4_prod_load.unit_of_measure_id is '[UnitOfMeasureId] Mandatory foreign key. To find the LookupList and LookupListItem this field is mapped to.<\n>Unit of measure for the product e.g. Inner';
comment on column qu4_prod_load.unit_of_measure_id_desc is '[UnitOfMeasureId_Description] Language Description in default system language';
comment on column qu4_prod_load.pack_size is '[PackSize] The number of individual items in the packet (where appropriate).';
comment on column qu4_prod_load.pack_desc is '[PackDescription] A description of the package.';
comment on column qu4_prod_load.unit_size is '[UnitSize] The size of unit.';
comment on column qu4_prod_load.sku_code is '[SKUCode] The Stock Keeping Unit code for this product.';
comment on column qu4_prod_load.name is '[Name] Product name.';
comment on column qu4_prod_load.units_per_case is '[UnitsPerCase] The number of individual items in a case.';
comment on column qu4_prod_load.units_per_inner is '[UnitsPerInner] The number of individual items in the inner package.';
comment on column qu4_prod_load.prod_hier_id is '[ProductGroup_Hierarchy_ID] Product can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this product.';
comment on column qu4_prod_load.brand_hier_id is '[Brand_Hierarchy_ID] ';
comment on column qu4_prod_load.new_start is '[NewStart] NewStart date of the product';
comment on column qu4_prod_load.new_end is '[NewEnd] NewEnd date of the product';
comment on column qu4_prod_load.pack_size_desc is '[PackSizeDescription] Extended Attribute';
comment on column qu4_prod_load.inner_name is '[InnerName] Extended Attribute: MCU (Inner) description of item, to be used for orders.';
comment on column qu4_prod_load.inner_price is '[InnerPrice] Extended Attribute: MCU Price (Inner)';
comment on column qu4_prod_load.case_name is '[CaseName] Extended Attribute';
comment on column qu4_prod_load.cases_per_layer is '[CasesPerLayer] Extended Attribute: Cases per layer';
comment on column qu4_prod_load.layers_per_pallet is '[LayersPerPallet] Extended Attribute: Layers per pallet';
comment on column qu4_prod_load.unit_rrp is '[UnitRRP] Extended Attribute: Recommended Retail Price (RRP)';

-- Synonyms
create or replace public synonym qu4_prod_load for ods.qu4_prod_load;

-- Grants
grant select,insert,update,delete on ods.qu4_prod_load to ods_app;
grant select on ods.qu4_prod_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_prod_hist cascade constraints;

create table ods.qu4_prod_hist (
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
  inners_per_case                 number(5, 0)                    null,
  is_new                          number(1, 0)                    null,
  is_priority                     number(1, 0)                    null,
  list_price                      number(18, 4)                   null,
  unit_of_measure_id              number(10, 0)                   not null,
  unit_of_measure_id_desc         varchar2(50 char)               null,
  pack_size                       number(5, 0)                    null,
  pack_desc                       varchar2(200 char)              null,
  unit_size                       number(5, 0)                    null,
  sku_code                        varchar2(50 char)               null,
  name                            varchar2(50 char)               null,
  units_per_case                  number(5, 0)                    null,
  units_per_inner                 number(5, 0)                    null,
  prod_hier_id                    number(10, 0)                   null,
  brand_hier_id                   number(10, 0)                   null,
  new_start                       date                            null,
  new_end                         date                            null,
  pack_size_desc                  varchar2(200 char)              null,
  inner_name                      varchar2(50 char)               null,
  inner_price                     number(18, 4)                   null,
  case_name                       varchar2(50 char)               null,
  cases_per_layer                 number(10, 0)                   null,
  layers_per_pallet               number(10, 0)                   null,
  unit_rrp                        number(18, 4)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_prod_hist add constraint qu4_prod_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_prod_hist_pk on ods.qu4_prod_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_prod_hist add constraint qu4_prod_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_prod_hist_uk on ods.qu4_prod_hist (id,q4x_batch_id)) compress;

create index ods.qu4_prod_hist_ts on ods.qu4_prod_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_prod_hist is '[Product][HIST] Product master data.';
comment on column qu4_prod_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_prod_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_prod_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_prod_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_prod_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_prod_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_prod_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_prod_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_prod_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_prod_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu4_prod_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_prod_hist.inners_per_case is '[InnersPerCase] The number of inner packages in a case.';
comment on column qu4_prod_hist.is_new is '[IsNew] Is this product being considered a New product.';
comment on column qu4_prod_hist.is_priority is '[IsPriority] Is this product currently a priority item';
comment on column qu4_prod_hist.list_price is '[ListPrice] The list price of the product.';
comment on column qu4_prod_hist.unit_of_measure_id is '[UnitOfMeasureId] Mandatory foreign key. To find the LookupList and LookupListItem this field is mapped to.<\n>Unit of measure for the product e.g. Inner';
comment on column qu4_prod_hist.unit_of_measure_id_desc is '[UnitOfMeasureId_Description] Language Description in default system language';
comment on column qu4_prod_hist.pack_size is '[PackSize] The number of individual items in the packet (where appropriate).';
comment on column qu4_prod_hist.pack_desc is '[PackDescription] A description of the package.';
comment on column qu4_prod_hist.unit_size is '[UnitSize] The size of unit.';
comment on column qu4_prod_hist.sku_code is '[SKUCode] The Stock Keeping Unit code for this product.';
comment on column qu4_prod_hist.name is '[Name] Product name.';
comment on column qu4_prod_hist.units_per_case is '[UnitsPerCase] The number of individual items in a case.';
comment on column qu4_prod_hist.units_per_inner is '[UnitsPerInner] The number of individual items in the inner package.';
comment on column qu4_prod_hist.prod_hier_id is '[ProductGroup_Hierarchy_ID] Product can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this product.';
comment on column qu4_prod_hist.brand_hier_id is '[Brand_Hierarchy_ID] ';
comment on column qu4_prod_hist.new_start is '[NewStart] NewStart date of the product';
comment on column qu4_prod_hist.new_end is '[NewEnd] NewEnd date of the product';
comment on column qu4_prod_hist.pack_size_desc is '[PackSizeDescription] Extended Attribute';
comment on column qu4_prod_hist.inner_name is '[InnerName] Extended Attribute: MCU (Inner) description of item, to be used for orders.';
comment on column qu4_prod_hist.inner_price is '[InnerPrice] Extended Attribute: MCU Price (Inner)';
comment on column qu4_prod_hist.case_name is '[CaseName] Extended Attribute';
comment on column qu4_prod_hist.cases_per_layer is '[CasesPerLayer] Extended Attribute: Cases per layer';
comment on column qu4_prod_hist.layers_per_pallet is '[LayersPerPallet] Extended Attribute: Layers per pallet';
comment on column qu4_prod_hist.unit_rrp is '[UnitRRP] Extended Attribute: Recommended Retail Price (RRP)';

-- Synonyms
create or replace public synonym qu4_prod_hist for ods.qu4_prod_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_prod_hist to ods_app;
grant select on ods.qu4_prod_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
