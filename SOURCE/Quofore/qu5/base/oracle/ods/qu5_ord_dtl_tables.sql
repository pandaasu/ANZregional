
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_ord_dtl
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_ord_dtl] table creation script _load and _hist

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
drop table ods.qu5_ord_dtl_load cascade constraints;

create table ods.qu5_ord_dtl_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  bonuse_qty                      number(5, 0)                    null,
  discount_amt                    number(18, 4)                   null,
  ord_hdr_id                      number(10, 0)                   not null,
  ord_qty                         number(5, 0)                    null,
  original_ord_qty                number(5, 0)                    null,
  per_unit_price                  number(18, 4)                   null,
  prod_id                         number(10, 0)                   null,
  tax_percent                     number(9, 6)                    null,
  total_line_amt                  number(18, 4)                   null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_ord_dtl_load add constraint qu5_ord_dtl_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_ord_dtl_load_pk on ods.qu5_ord_dtl_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_ord_dtl_load add constraint qu5_ord_dtl_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_ord_dtl_load_uk on ods.qu5_ord_dtl_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_ord_dtl_load is '[OrderDetail][LOAD] Child table of order header.';
comment on column qu5_ord_dtl_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_ord_dtl_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_ord_dtl_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_ord_dtl_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_ord_dtl_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_ord_dtl_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_ord_dtl_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_ord_dtl_load.q4x_timestamp is '* Timestamp';
comment on column qu5_ord_dtl_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_ord_dtl_load.bonuse_qty is '[BonusQuantity] The quantity of bonus product associated with this order line.';
comment on column qu5_ord_dtl_load.discount_amt is '[DiscountAmount] The value of the discount on this order line.';
comment on column qu5_ord_dtl_load.ord_hdr_id is '[OrderHeader_Id] Mandatory foreign key from [OrderHeader].[Id].';
comment on column qu5_ord_dtl_load.ord_qty is '[OrderQuantity] The quantity of the product ordered.';
comment on column qu5_ord_dtl_load.original_ord_qty is '[OriginalOrderQuantity] The amount ordered on the original order. Set when the order detail is created and not amended.';
comment on column qu5_ord_dtl_load.per_unit_price is '[PerUnitPrice] The price per unit of this product on this order.';
comment on column qu5_ord_dtl_load.prod_id is '[Product_Id] Foreign key from [Product].[Id].';
comment on column qu5_ord_dtl_load.tax_percent is '[TaxPercent] The tax rate attracted by this product.';
comment on column qu5_ord_dtl_load.total_line_amt is '[TotalLineAmount] The value of this order line after discounts and tax have been applied.  Will be the Override Value fro Deals and Freshness';
comment on column qu5_ord_dtl_load.prod_id_desc is '[Product_Id_Description] Product Id Description of the OrderDetail';

-- Synonyms
create or replace public synonym qu5_ord_dtl_load for ods.qu5_ord_dtl_load;

-- Grants
grant select,insert,update,delete on ods.qu5_ord_dtl_load to ods_app;
grant select on ods.qu5_ord_dtl_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_ord_dtl_hist cascade constraints;

create table ods.qu5_ord_dtl_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  bonuse_qty                      number(5, 0)                    null,
  discount_amt                    number(18, 4)                   null,
  ord_hdr_id                      number(10, 0)                   not null,
  ord_qty                         number(5, 0)                    null,
  original_ord_qty                number(5, 0)                    null,
  per_unit_price                  number(18, 4)                   null,
  prod_id                         number(10, 0)                   null,
  tax_percent                     number(9, 6)                    null,
  total_line_amt                  number(18, 4)                   null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_ord_dtl_hist add constraint qu5_ord_dtl_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_ord_dtl_hist_pk on ods.qu5_ord_dtl_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_ord_dtl_hist add constraint qu5_ord_dtl_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_ord_dtl_hist_uk on ods.qu5_ord_dtl_hist (id,q4x_batch_id)) compress;

create index ods.qu5_ord_dtl_hist_ts on ods.qu5_ord_dtl_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_ord_dtl_hist is '[OrderDetail][HIST] Child table of order header.';
comment on column qu5_ord_dtl_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_ord_dtl_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_ord_dtl_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_ord_dtl_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_ord_dtl_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_ord_dtl_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_ord_dtl_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_ord_dtl_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_ord_dtl_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_ord_dtl_hist.bonuse_qty is '[BonusQuantity] The quantity of bonus product associated with this order line.';
comment on column qu5_ord_dtl_hist.discount_amt is '[DiscountAmount] The value of the discount on this order line.';
comment on column qu5_ord_dtl_hist.ord_hdr_id is '[OrderHeader_Id] Mandatory foreign key from [OrderHeader].[Id].';
comment on column qu5_ord_dtl_hist.ord_qty is '[OrderQuantity] The quantity of the product ordered.';
comment on column qu5_ord_dtl_hist.original_ord_qty is '[OriginalOrderQuantity] The amount ordered on the original order. Set when the order detail is created and not amended.';
comment on column qu5_ord_dtl_hist.per_unit_price is '[PerUnitPrice] The price per unit of this product on this order.';
comment on column qu5_ord_dtl_hist.prod_id is '[Product_Id] Foreign key from [Product].[Id].';
comment on column qu5_ord_dtl_hist.tax_percent is '[TaxPercent] The tax rate attracted by this product.';
comment on column qu5_ord_dtl_hist.total_line_amt is '[TotalLineAmount] The value of this order line after discounts and tax have been applied.  Will be the Override Value fro Deals and Freshness';
comment on column qu5_ord_dtl_hist.prod_id_desc is '[Product_Id_Description] Product Id Description of the OrderDetail';

-- Synonyms
create or replace public synonym qu5_ord_dtl_hist for ods.qu5_ord_dtl_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_ord_dtl_hist to ods_app;
grant select on ods.qu5_ord_dtl_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
