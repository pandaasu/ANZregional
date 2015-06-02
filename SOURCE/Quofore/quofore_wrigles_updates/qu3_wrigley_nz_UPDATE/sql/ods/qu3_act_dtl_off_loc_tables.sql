
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_act_dtl_off_loc
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_act_dtl_off_loc] table creation script _load and _hist

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
drop table ods.qu3_act_dtl_off_loc_load cascade constraints;

create table ods.qu3_act_dtl_off_loc_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  act_id                          number(10, 0)                   null,
  no_gondola                      number(10, 0)                   null,
  no_wing                         number(10, 0)                   null,
  no_flat_pack_tower              number(10, 0)                   null,
  no_pre_pack_tower               number(10, 0)                   null,
  no_flat_pack_cdus               number(10, 0)                   null,
  no_pre_pack_cdus                number(10, 0)                   null,
  no_buckets                      number(10, 0)                   null,
  no_clip_strip                   number(10, 0)                   null,
  no_other                        number(10, 0)                   null,
  stock_qty                       number(10, 0)                   null,
  promo_start_date                date                            null,
  promo_end_date                  date                            null,
  prod_id                         number(10, 0)                   null,
  coop_spend                      number(18, 4)                   null,
  sold_in_by                      number(10, 0)                   null,
  built_by                        number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_act_dtl_off_loc_load add constraint qu3_act_dtl_off_loc_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_act_dtl_off_loc_load_pk on ods.qu3_act_dtl_off_loc_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_act_dtl_off_loc_load add constraint qu3_act_dtl_off_loc_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_act_dtl_off_loc_load_uk on ods.qu3_act_dtl_off_loc_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_act_dtl_off_loc_load is '[ActivityDetail_OffLocation][LOAD] Detail file for Off Location Sales & Promotion Leverage task';
comment on column qu3_act_dtl_off_loc_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_act_dtl_off_loc_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_act_dtl_off_loc_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_act_dtl_off_loc_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_act_dtl_off_loc_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_act_dtl_off_loc_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_act_dtl_off_loc_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_act_dtl_off_loc_load.q4x_timestamp is '* Timestamp';
comment on column qu3_act_dtl_off_loc_load.id is '[ID] Unique Internal ID for the row';
comment on column qu3_act_dtl_off_loc_load.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu3_act_dtl_off_loc_load.no_gondola is '[NumGondola] Number of gondola ends negotiated';
comment on column qu3_act_dtl_off_loc_load.no_wing is '[NumWing] Number of wings negotiated';
comment on column qu3_act_dtl_off_loc_load.no_flat_pack_tower is '[NumFlatPackTower] Number of flat pack towers';
comment on column qu3_act_dtl_off_loc_load.no_pre_pack_tower is '[NumPrePackTower] Number of prepack towers';
comment on column qu3_act_dtl_off_loc_load.no_flat_pack_cdus is '[NumFlatPackCDUs] Number of flat pack CDUs';
comment on column qu3_act_dtl_off_loc_load.no_pre_pack_cdus is '[NumPrePackCDUs] Number of pre pack CDUs';
comment on column qu3_act_dtl_off_loc_load.no_buckets is '[NumBuckets] Number of buckets';
comment on column qu3_act_dtl_off_loc_load.no_clip_strip is '[NumClipStrip] Number of clip strips negotiated/Num in Store';
comment on column qu3_act_dtl_off_loc_load.no_other is '[NumOther] Number of other off-locations negotiated';
comment on column qu3_act_dtl_off_loc_load.stock_qty is '[StockQty] Quantity of stock negotiated as part of this deal';
comment on column qu3_act_dtl_off_loc_load.promo_start_date is '[PromoStartDate] Promotion Start Date';
comment on column qu3_act_dtl_off_loc_load.promo_end_date is '[PromoEndDate] Promotion End Date';
comment on column qu3_act_dtl_off_loc_load.prod_id is '[Product_ID] Foreign key from [Product].[Id].';
comment on column qu3_act_dtl_off_loc_load.coop_spend is '[Coopspend] The Co Op Spend Amount.';
comment on column qu3_act_dtl_off_loc_load.sold_in_by is '[SoldInBy] Sold In By';
comment on column qu3_act_dtl_off_loc_load.built_by is '[BuiltBy] Built By';

-- Synonyms
create or replace public synonym qu3_act_dtl_off_loc_load for ods.qu3_act_dtl_off_loc_load;

-- Grants
grant select,insert,update,delete on ods.qu3_act_dtl_off_loc_load to ods_app;
grant select on ods.qu3_act_dtl_off_loc_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_act_dtl_off_loc_hist cascade constraints;

create table ods.qu3_act_dtl_off_loc_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  act_id                          number(10, 0)                   null,
  no_gondola                      number(10, 0)                   null,
  no_wing                         number(10, 0)                   null,
  no_flat_pack_tower              number(10, 0)                   null,
  no_pre_pack_tower               number(10, 0)                   null,
  no_flat_pack_cdus               number(10, 0)                   null,
  no_pre_pack_cdus                number(10, 0)                   null,
  no_buckets                      number(10, 0)                   null,
  no_clip_strip                   number(10, 0)                   null,
  no_other                        number(10, 0)                   null,
  stock_qty                       number(10, 0)                   null,
  promo_start_date                date                            null,
  promo_end_date                  date                            null,
  prod_id                         number(10, 0)                   null,
  coop_spend                      number(18, 4)                   null,
  sold_in_by                      number(10, 0)                   null,
  built_by                        number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_act_dtl_off_loc_hist add constraint qu3_act_dtl_off_loc_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_act_dtl_off_loc_hist_pk on ods.qu3_act_dtl_off_loc_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_act_dtl_off_loc_hist add constraint qu3_act_dtl_off_loc_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_act_dtl_off_loc_hist_uk on ods.qu3_act_dtl_off_loc_hist (id,q4x_batch_id)) compress;

create index ods.qu3_act_dtl_off_loc_hist_ts on ods.qu3_act_dtl_off_loc_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_act_dtl_off_loc_hist is '[ActivityDetail_OffLocation][HIST] Detail file for Off Location Sales & Promotion Leverage task';
comment on column qu3_act_dtl_off_loc_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_act_dtl_off_loc_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_act_dtl_off_loc_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_act_dtl_off_loc_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_act_dtl_off_loc_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_act_dtl_off_loc_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_act_dtl_off_loc_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_act_dtl_off_loc_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_act_dtl_off_loc_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu3_act_dtl_off_loc_hist.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu3_act_dtl_off_loc_hist.no_gondola is '[NumGondola] Number of gondola ends negotiated';
comment on column qu3_act_dtl_off_loc_hist.no_wing is '[NumWing] Number of wings negotiated';
comment on column qu3_act_dtl_off_loc_hist.no_flat_pack_tower is '[NumFlatPackTower] Number of flat pack towers';
comment on column qu3_act_dtl_off_loc_hist.no_pre_pack_tower is '[NumPrePackTower] Number of prepack towers';
comment on column qu3_act_dtl_off_loc_hist.no_flat_pack_cdus is '[NumFlatPackCDUs] Number of flat pack CDUs';
comment on column qu3_act_dtl_off_loc_hist.no_pre_pack_cdus is '[NumPrePackCDUs] Number of pre pack CDUs';
comment on column qu3_act_dtl_off_loc_hist.no_buckets is '[NumBuckets] Number of buckets';
comment on column qu3_act_dtl_off_loc_hist.no_clip_strip is '[NumClipStrip] Number of clip strips negotiated/Num in Store';
comment on column qu3_act_dtl_off_loc_hist.no_other is '[NumOther] Number of other off-locations negotiated';
comment on column qu3_act_dtl_off_loc_hist.stock_qty is '[StockQty] Quantity of stock negotiated as part of this deal';
comment on column qu3_act_dtl_off_loc_hist.promo_start_date is '[PromoStartDate] Promotion Start Date';
comment on column qu3_act_dtl_off_loc_hist.promo_end_date is '[PromoEndDate] Promotion End Date';
comment on column qu3_act_dtl_off_loc_hist.prod_id is '[Product_ID] Foreign key from [Product].[Id].';
comment on column qu3_act_dtl_off_loc_hist.coop_spend is '[Coopspend] The Co Op Spend Amount.';
comment on column qu3_act_dtl_off_loc_hist.sold_in_by is '[SoldInBy] Sold In By';
comment on column qu3_act_dtl_off_loc_hist.built_by is '[BuiltBy] Built By';

-- Synonyms
create or replace public synonym qu3_act_dtl_off_loc_hist for ods.qu3_act_dtl_off_loc_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_act_dtl_off_loc_hist to ods_app;
grant select on ods.qu3_act_dtl_off_loc_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
