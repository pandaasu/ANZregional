
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_prod_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_prod_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_prod_hist cascade constraints;

create table ods.quo_prod_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_source_id                   number(4)                       not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  id_lookup                       varchar2(50 char)               null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  inners_per_case                 number(5, 0)                    null,
  is_new                          number(1, 0)                    null,
  is_priority                     number(1, 0)                    null,
  list_price                      number(18, 4)                   null,
  unit_of_measure_id              number(10, 0)                   null,
  unit_of_measure_id_lookup       varchar2(50 char)               null,
  unit_of_measure_id_desc         varchar2(50 char)               null,
  pack_size                       number(5, 0)                    null,
  pack_desc                       varchar2(200 char)              null,
  unit_size                       number(5, 0)                    null,
  sku_code                        varchar2(50 char)               null,
  name                            varchar2(50 char)               null,
  units_per_case                  number(5, 0)                    null,
  units_per_inner                 number(5, 0)                    null,
  prod_hier_id                    number(10, 0)                   null,
  ord_multiple                    number(5, 0)                    null,
  site                            varchar2(50 char)               null,
  pack_group_id                   number(10, 0)                   null,
  pack_group_id_lookup            varchar2(50 char)               null,
  pack_group_id_desc              varchar2(50 char)               null,
  pack_size_2                     varchar2(50 char)               null,
  cases_per_layer                 number(5, 0)                    null,
  layers_per_pallet               number(5, 0)                    null,
  min_ord_qty                     number(5, 0)                    null,
  new_start                       date                            null,
  new_end                         date                            null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_prod_hist add constraint quo_prod_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_prod_hist_pk on ods.quo_prod_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_prod_hist add constraint quo_prod_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_prod_hist_uk on ods.quo_prod_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_prod_hist_ts on ods.quo_prod_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_prod_hist is '[Product] Product master data';
comment on column quo_prod_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_prod_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_prod_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_prod_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_prod_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_prod_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_prod_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_prod_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_prod_hist.q4x_timestamp is '* Timestamp';
comment on column quo_prod_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_prod_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_prod_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_prod_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_prod_hist.inners_per_case is '[InnersPerCase] The number of inner packages in a case.';
comment on column quo_prod_hist.is_new is '[IsNew] Is this product being considered a New product.';
comment on column quo_prod_hist.is_priority is '[IsPriority] Is this product currently a priority item';
comment on column quo_prod_hist.list_price is '[ListPrice] The list price of the product.';
comment on column quo_prod_hist.unit_of_measure_id is '[UnitOfMeasureId] Mandatory foreign key. To find the LookupList and LookupListItem this field is mapped to.<\n>Unit of measure for the product e.g. Case.';
comment on column quo_prod_hist.unit_of_measure_id_lookup is '[UnitOfMeasureId_Lookup] Integration Id, Should be unique for all Lookup List Items';
comment on column quo_prod_hist.unit_of_measure_id_desc is '[UnitOfMeasureId_Description] Language Description in default system language';
comment on column quo_prod_hist.pack_size is '[PackSize] The number of individual items in the packet (where appropriate).';
comment on column quo_prod_hist.pack_desc is '[PackDescription] A description of the package.';
comment on column quo_prod_hist.unit_size is '[UnitSize] The size of unit.';
comment on column quo_prod_hist.sku_code is '[SKUCode] The Stock Keeping Unit code for this product.';
comment on column quo_prod_hist.name is '[Name] Product name.';
comment on column quo_prod_hist.units_per_case is '[UnitsPerCase] The number of individual items in a case.';
comment on column quo_prod_hist.units_per_inner is '[UnitsPerInner] The number of individual items in the inner package.';
comment on column quo_prod_hist.prod_hier_id is '[ProductHierarchy_Hierarchy_ID] Product can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this product.<\n>For Mars there''s only 1 product hierarchy i.e. ProductHierarchy.';
comment on column quo_prod_hist.ord_multiple is '[OrderMultiple] Extended attribute to specify order multiple for ordering.';
comment on column quo_prod_hist.site is '[Site] Extended attribute to specify site where product should be ordered from.';
comment on column quo_prod_hist.pack_group_id is '[PackGroupID] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_prod_hist.pack_group_id_lookup is '[PackGroupID_Lookup] Integration Id, Should be unique for all Lookup List Items';
comment on column quo_prod_hist.pack_group_id_desc is '[PackGroupID_Description] Language Description in default system language';
comment on column quo_prod_hist.pack_size_2 is '[PackSize2] Extended attribute. Alphanumeric pack size.';
comment on column quo_prod_hist.cases_per_layer is '[CasesPerLayer] Extended attribute.';
comment on column quo_prod_hist.layers_per_pallet is '[LayersPerPallet] Extended attribute.';
comment on column quo_prod_hist.min_ord_qty is '[MinimumOrderQuantity] Extended attribute.';
comment on column quo_prod_hist.new_start is '[NewStart] NewStart date of the product';
comment on column quo_prod_hist.new_end is '[NewEnd] NewEnd date of the product';


-- Synonyms
create or replace public synonym quo_prod_hist for ods.quo_prod_hist;

-- Grants
grant select,update,delete,insert on ods.quo_prod_hist to ods_app;
grant select on ods.quo_prod_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
