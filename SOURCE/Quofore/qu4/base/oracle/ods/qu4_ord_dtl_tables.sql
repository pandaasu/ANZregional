
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_ord_dtl
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_ord_dtl] table creation script _load and _hist

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
drop table ods.qu4_ord_dtl_load cascade constraints;

create table ods.qu4_ord_dtl_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  bonus_qty                       number(5, 0)                    null,
  discount_amount                 number(18, 4)                   null,
  ord_header_id                   number(10, 0)                   not null,
  ord_qty                         number(5, 0)                    null,
  original_ord_qty                number(5, 0)                    null,
  per_unit_price                  number(18, 4)                   null,
  prod_id                         number(10, 0)                   null,
  tax_percent                     number(9, 6)                    null,
  total_line_amount               number(18, 4)                   null,
  prod_id_desc                    varchar2(50 char)               null,
  line_discount_percent           number(18, 4)                   null,
  credit_reason                   varchar2(200 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_ord_dtl_load add constraint qu4_ord_dtl_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_ord_dtl_load_pk on ods.qu4_ord_dtl_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_ord_dtl_load add constraint qu4_ord_dtl_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_ord_dtl_load_uk on ods.qu4_ord_dtl_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_ord_dtl_load is '[OrderDetail][LOAD] Child table of order header.';
comment on column qu4_ord_dtl_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_ord_dtl_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_ord_dtl_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_ord_dtl_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_ord_dtl_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_ord_dtl_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_ord_dtl_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_ord_dtl_load.q4x_timestamp is '* Timestamp';
comment on column qu4_ord_dtl_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_ord_dtl_load.bonus_qty is '[BonusQuantity] The quantity of bonus product associated with this order line.';
comment on column qu4_ord_dtl_load.discount_amount is '[DiscountAmount] The value of the discount on this order line.';
comment on column qu4_ord_dtl_load.ord_header_id is '[OrderHeader_Id] Mandatory foreign key from [OrderHeader].[Id].';
comment on column qu4_ord_dtl_load.ord_qty is '[OrderQuantity] The quantity of the product ordered.';
comment on column qu4_ord_dtl_load.original_ord_qty is '[OriginalOrderQuantity] The amount ordered on the original order. Set when the order detail is created and not amended.';
comment on column qu4_ord_dtl_load.per_unit_price is '[PerUnitPrice] The price per unit of this product on this order.';
comment on column qu4_ord_dtl_load.prod_id is '[Product_Id] Foreign key from [Product].[Id].';
comment on column qu4_ord_dtl_load.tax_percent is '[TaxPercent] The tax rate attracted by this product.';
comment on column qu4_ord_dtl_load.total_line_amount is '[TotalLineAmount] The value of this order line after discounts and tax have been applied.  Will be the Override Value fro Deals and Freshness';
comment on column qu4_ord_dtl_load.prod_id_desc is '[Product_ID_Description] ';
comment on column qu4_ord_dtl_load.line_discount_percent is '[LineDiscountPercent] A Percentage Discount off the List Price, editable by the TM.  Used for Deals and Freshness';
comment on column qu4_ord_dtl_load.credit_reason is '[CreditReason] Indicates the reason for the product(s) to be returned.  Used for Deals and Freshness';

-- Synonyms
create or replace public synonym qu4_ord_dtl_load for ods.qu4_ord_dtl_load;

-- Grants
grant select,insert,update,delete on ods.qu4_ord_dtl_load to ods_app;
grant select on ods.qu4_ord_dtl_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_ord_dtl_hist cascade constraints;

create table ods.qu4_ord_dtl_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  bonus_qty                       number(5, 0)                    null,
  discount_amount                 number(18, 4)                   null,
  ord_header_id                   number(10, 0)                   not null,
  ord_qty                         number(5, 0)                    null,
  original_ord_qty                number(5, 0)                    null,
  per_unit_price                  number(18, 4)                   null,
  prod_id                         number(10, 0)                   null,
  tax_percent                     number(9, 6)                    null,
  total_line_amount               number(18, 4)                   null,
  prod_id_desc                    varchar2(50 char)               null,
  line_discount_percent           number(18, 4)                   null,
  credit_reason                   varchar2(200 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_ord_dtl_hist add constraint qu4_ord_dtl_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_ord_dtl_hist_pk on ods.qu4_ord_dtl_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_ord_dtl_hist add constraint qu4_ord_dtl_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_ord_dtl_hist_uk on ods.qu4_ord_dtl_hist (id,q4x_batch_id)) compress;

create index ods.qu4_ord_dtl_hist_ts on ods.qu4_ord_dtl_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_ord_dtl_hist is '[OrderDetail][HIST] Child table of order header.';
comment on column qu4_ord_dtl_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_ord_dtl_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_ord_dtl_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_ord_dtl_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_ord_dtl_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_ord_dtl_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_ord_dtl_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_ord_dtl_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_ord_dtl_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_ord_dtl_hist.bonus_qty is '[BonusQuantity] The quantity of bonus product associated with this order line.';
comment on column qu4_ord_dtl_hist.discount_amount is '[DiscountAmount] The value of the discount on this order line.';
comment on column qu4_ord_dtl_hist.ord_header_id is '[OrderHeader_Id] Mandatory foreign key from [OrderHeader].[Id].';
comment on column qu4_ord_dtl_hist.ord_qty is '[OrderQuantity] The quantity of the product ordered.';
comment on column qu4_ord_dtl_hist.original_ord_qty is '[OriginalOrderQuantity] The amount ordered on the original order. Set when the order detail is created and not amended.';
comment on column qu4_ord_dtl_hist.per_unit_price is '[PerUnitPrice] The price per unit of this product on this order.';
comment on column qu4_ord_dtl_hist.prod_id is '[Product_Id] Foreign key from [Product].[Id].';
comment on column qu4_ord_dtl_hist.tax_percent is '[TaxPercent] The tax rate attracted by this product.';
comment on column qu4_ord_dtl_hist.total_line_amount is '[TotalLineAmount] The value of this order line after discounts and tax have been applied.  Will be the Override Value fro Deals and Freshness';
comment on column qu4_ord_dtl_hist.prod_id_desc is '[Product_ID_Description] ';
comment on column qu4_ord_dtl_hist.line_discount_percent is '[LineDiscountPercent] A Percentage Discount off the List Price, editable by the TM.  Used for Deals and Freshness';
comment on column qu4_ord_dtl_hist.credit_reason is '[CreditReason] Indicates the reason for the product(s) to be returned.  Used for Deals and Freshness';

-- Synonyms
create or replace public synonym qu4_ord_dtl_hist for ods.qu4_ord_dtl_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_ord_dtl_hist to ods_app;
grant select on ods.qu4_ord_dtl_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
