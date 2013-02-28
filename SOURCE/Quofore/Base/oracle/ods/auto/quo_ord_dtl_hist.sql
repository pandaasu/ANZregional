
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_ord_dtl_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_ord_dtl_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_ord_dtl_hist cascade constraints;

create table ods.quo_ord_dtl_hist (
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
  bonus_qty                       number(5, 0)                    null,
  discount_amount                 number(18, 4)                   null,
  ord_hdr_id                      number(10, 0)                   null,
  ord_hdr_id_lookup               varchar2(50 char)               null,
  ord_qty                         number(5, 0)                    null,
  orig_ord_qty                    number(5, 0)                    null,
  per_unit_price                  number(18, 4)                   null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  varchar2(50 char)               null,
  tax_percent                     number(9, 6)                    null,
  total_line_amount               number(18, 4)                   null,
  prod_id_desc                    varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_ord_dtl_hist add constraint quo_ord_dtl_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_ord_dtl_hist_pk on ods.quo_ord_dtl_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_ord_dtl_hist add constraint quo_ord_dtl_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_ord_dtl_hist_uk on ods.quo_ord_dtl_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_ord_dtl_hist_ts on ods.quo_ord_dtl_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_ord_dtl_hist is '[OrderDetail] Child table of order header';
comment on column quo_ord_dtl_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_ord_dtl_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_ord_dtl_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_ord_dtl_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_ord_dtl_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_ord_dtl_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_ord_dtl_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_ord_dtl_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_ord_dtl_hist.q4x_timestamp is '* Timestamp';
comment on column quo_ord_dtl_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_ord_dtl_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_ord_dtl_hist.bonus_qty is '[BonusQuantity] The quantity of bonus product associated with this order line.';
comment on column quo_ord_dtl_hist.discount_amount is '[DiscountAmount] The value of the discount on this order line.';
comment on column quo_ord_dtl_hist.ord_hdr_id is '[OrderHeader_Id] Mandatory foreign key to [OrderHeader].[Id].';
comment on column quo_ord_dtl_hist.ord_hdr_id_lookup is '[OrderHeader_Id_Lookup] ';
comment on column quo_ord_dtl_hist.ord_qty is '[OrderQuantity] The quantity of the product ordered.';
comment on column quo_ord_dtl_hist.orig_ord_qty is '[OriginalOrderQuantity] The amount ordered on the original order. Set when the order detail is created and not amended.';
comment on column quo_ord_dtl_hist.per_unit_price is '[PerUnitPrice] The price per unit of this product on this order.';
comment on column quo_ord_dtl_hist.prod_id is '[Product_Id] Foreign key to [Product].[Id].';
comment on column quo_ord_dtl_hist.prod_id_lookup is '[Product_Id_Lookup] ';
comment on column quo_ord_dtl_hist.tax_percent is '[TaxPercent] The tax rate attracted by this product.';
comment on column quo_ord_dtl_hist.total_line_amount is '[TotalLineAmount] The value of this order line after discounts and tax have been applied.';
comment on column quo_ord_dtl_hist.prod_id_desc is '[Product_ID_Description] ';


-- Synonyms
create or replace public synonym quo_ord_dtl_hist for ods.quo_ord_dtl_hist;

-- Grants
grant select,update,delete,insert on ods.quo_ord_dtl_hist to ods_app;
grant select on ods.quo_ord_dtl_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
