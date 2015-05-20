
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_prod
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_prod] table creation script _load and _hist

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
drop table ods.qu5_prod_load cascade constraints;

create table ods.qu5_prod_load (
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
  segment_hier_id                 number(10, 0)                   null,
  brand_hier_id                   number(10, 0)                   null,
  new_start                       date                            null,
  new_end                         date                            null,
  priority_start                  date                            null,
  priority_end                    date                            null,
  is_direct_orderable             number(1, 0)                    null,
  is_indirect_orderable           number(1, 0)                    null,
  do_first_do_next_do_last_id     number(10, 0)                   null,
  layers_per_pallet               number(10, 0)                   null,
  case_per_layer                  number(10, 0)                   null,
  pallet_case_count               number(10, 0)                   null,
  unit_name                       varchar2(50 char)               null,
  inner_name                      varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_prod_load add constraint qu5_prod_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_prod_load_pk on ods.qu5_prod_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_prod_load add constraint qu5_prod_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_prod_load_uk on ods.qu5_prod_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_prod_load is '[Product][LOAD] Product master data.';
comment on column qu5_prod_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_prod_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_prod_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_prod_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_prod_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_prod_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_prod_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_prod_load.q4x_timestamp is '* Timestamp';
comment on column qu5_prod_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_prod_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu5_prod_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_prod_load.inners_per_case is '[InnersPerCase] The number of inner packages in a case.';
comment on column qu5_prod_load.is_new is '[IsNew] Is this product being considered a New product.';
comment on column qu5_prod_load.is_priority is '[IsPriority] Is this product currently a priority item';
comment on column qu5_prod_load.list_price is '[ListPrice] The list price of the product.';
comment on column qu5_prod_load.unit_of_measure_id is '[UnitOfMeasureId] Mandatory foreign key. To find the LookupList and LookupListItem this field is mapped to.<\n>Unit of measure for the product e.g. Inner';
comment on column qu5_prod_load.unit_of_measure_id_desc is '[UnitOfMeasureId_Description] Language Description in default system language';
comment on column qu5_prod_load.pack_size is '[PackSize] The number of individual items in the packet (where appropriate).';
comment on column qu5_prod_load.pack_desc is '[PackDescription] A description of the package.';
comment on column qu5_prod_load.unit_size is '[UnitSize] The size of unit.';
comment on column qu5_prod_load.sku_code is '[SKUCode] The Stock Keeping Unit code for this product.';
comment on column qu5_prod_load.name is '[Name] Product name.';
comment on column qu5_prod_load.units_per_case is '[UnitsPerCase] The number of individual items in a case.';
comment on column qu5_prod_load.units_per_inner is '[UnitsPerInner] The number of individual items in the inner package.';
comment on column qu5_prod_load.segment_hier_id is '[Segment_Hierarchy_Id] Product can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this product.';
comment on column qu5_prod_load.brand_hier_id is '[Brand_Hierarchy_Id] Extended Attribute - Whether the Product brand available for Hierarchy Orders _i not';
comment on column qu5_prod_load.new_start is '[NewStart] NewStart date of the product';
comment on column qu5_prod_load.new_end is '[NewEnd] NewEnd date of the product';
comment on column qu5_prod_load.priority_start is '[PriorityStart] Priority Start Date of the Product';
comment on column qu5_prod_load.priority_end is '[PriorityEnd] Priority End Date of the Product';
comment on column qu5_prod_load.is_direct_orderable is '[IsDirectOrderable] Extended Attribute - Whether the Product is available for Direct Orders or not';
comment on column qu5_prod_load.is_indirect_orderable is '[IsIndirectOrderable] Extended Attribute - Whether products will be available for Indirect Orders';
comment on column qu5_prod_load.do_first_do_next_do_last_id is '[DFDNDLId] Extended Attribute - Lookup Value for Do First, Do Next or Do Last';
comment on column qu5_prod_load.layers_per_pallet is '[LayersPerPallet] Extended Attribute - How many Layers Per Pallet';
comment on column qu5_prod_load.case_per_layer is '[CasesPerLayer] Extended Attribute - How many Cases Per Layer';
comment on column qu5_prod_load.pallet_case_count is '[PalletCaseCount] Extended Attribute - What is the Pallet Case Count';
comment on column qu5_prod_load.unit_name is '[UnitName] Extended Attribute - Stores Product Name for Unit UOM';
comment on column qu5_prod_load.inner_name is '[InnerName] Extended Attribute - Stores Product Name for Inner UOM';

-- Synonyms
create or replace public synonym qu5_prod_load for ods.qu5_prod_load;

-- Grants
grant select,insert,update,delete on ods.qu5_prod_load to ods_app;
grant select on ods.qu5_prod_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_prod_hist cascade constraints;

create table ods.qu5_prod_hist (
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
  segment_hier_id                 number(10, 0)                   null,
  brand_hier_id                   number(10, 0)                   null,
  new_start                       date                            null,
  new_end                         date                            null,
  priority_start                  date                            null,
  priority_end                    date                            null,
  is_direct_orderable             number(1, 0)                    null,
  is_indirect_orderable           number(1, 0)                    null,
  do_first_do_next_do_last_id     number(10, 0)                   null,
  layers_per_pallet               number(10, 0)                   null,
  case_per_layer                  number(10, 0)                   null,
  pallet_case_count               number(10, 0)                   null,
  unit_name                       varchar2(50 char)               null,
  inner_name                      varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_prod_hist add constraint qu5_prod_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_prod_hist_pk on ods.qu5_prod_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_prod_hist add constraint qu5_prod_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_prod_hist_uk on ods.qu5_prod_hist (id,q4x_batch_id)) compress;

create index ods.qu5_prod_hist_ts on ods.qu5_prod_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_prod_hist is '[Product][HIST] Product master data.';
comment on column qu5_prod_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_prod_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_prod_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_prod_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_prod_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_prod_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_prod_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_prod_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_prod_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_prod_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu5_prod_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_prod_hist.inners_per_case is '[InnersPerCase] The number of inner packages in a case.';
comment on column qu5_prod_hist.is_new is '[IsNew] Is this product being considered a New product.';
comment on column qu5_prod_hist.is_priority is '[IsPriority] Is this product currently a priority item';
comment on column qu5_prod_hist.list_price is '[ListPrice] The list price of the product.';
comment on column qu5_prod_hist.unit_of_measure_id is '[UnitOfMeasureId] Mandatory foreign key. To find the LookupList and LookupListItem this field is mapped to.<\n>Unit of measure for the product e.g. Inner';
comment on column qu5_prod_hist.unit_of_measure_id_desc is '[UnitOfMeasureId_Description] Language Description in default system language';
comment on column qu5_prod_hist.pack_size is '[PackSize] The number of individual items in the packet (where appropriate).';
comment on column qu5_prod_hist.pack_desc is '[PackDescription] A description of the package.';
comment on column qu5_prod_hist.unit_size is '[UnitSize] The size of unit.';
comment on column qu5_prod_hist.sku_code is '[SKUCode] The Stock Keeping Unit code for this product.';
comment on column qu5_prod_hist.name is '[Name] Product name.';
comment on column qu5_prod_hist.units_per_case is '[UnitsPerCase] The number of individual items in a case.';
comment on column qu5_prod_hist.units_per_inner is '[UnitsPerInner] The number of individual items in the inner package.';
comment on column qu5_prod_hist.segment_hier_id is '[Segment_Hierarchy_Id] Product can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this product.';
comment on column qu5_prod_hist.brand_hier_id is '[Brand_Hierarchy_Id] Extended Attribute - Whether the Product brand available for Hierarchy Orders _i not';
comment on column qu5_prod_hist.new_start is '[NewStart] NewStart date of the product';
comment on column qu5_prod_hist.new_end is '[NewEnd] NewEnd date of the product';
comment on column qu5_prod_hist.priority_start is '[PriorityStart] Priority Start Date of the Product';
comment on column qu5_prod_hist.priority_end is '[PriorityEnd] Priority End Date of the Product';
comment on column qu5_prod_hist.is_direct_orderable is '[IsDirectOrderable] Extended Attribute - Whether the Product is available for Direct Orders or not';
comment on column qu5_prod_hist.is_indirect_orderable is '[IsIndirectOrderable] Extended Attribute - Whether products will be available for Indirect Orders';
comment on column qu5_prod_hist.do_first_do_next_do_last_id is '[DFDNDLId] Extended Attribute - Lookup Value for Do First, Do Next or Do Last';
comment on column qu5_prod_hist.layers_per_pallet is '[LayersPerPallet] Extended Attribute - How many Layers Per Pallet';
comment on column qu5_prod_hist.case_per_layer is '[CasesPerLayer] Extended Attribute - How many Cases Per Layer';
comment on column qu5_prod_hist.pallet_case_count is '[PalletCaseCount] Extended Attribute - What is the Pallet Case Count';
comment on column qu5_prod_hist.unit_name is '[UnitName] Extended Attribute - Stores Product Name for Unit UOM';
comment on column qu5_prod_hist.inner_name is '[InnerName] Extended Attribute - Stores Product Name for Inner UOM';

-- Synonyms
create or replace public synonym qu5_prod_hist for ods.qu5_prod_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_prod_hist to ods_app;
grant select on ods.qu5_prod_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
