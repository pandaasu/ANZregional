
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_act_dtl_selfscan_q
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_act_dtl_selfscan_q] table creation script _load and _hist

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
drop table ods.qu2_act_dtl_selfscan_q_load cascade constraints;

create table ods.qu2_act_dtl_selfscan_q_load (
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
  zone_no                         number(10, 0)                   null,
  no_sku                          number(10, 0)                   null,
  no_sku_adjacent                 number(10, 0)                   null,
  is_active                       number(1, 0)                    null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_selfscan_q_load add constraint qu2_act_dtl_selfscan_q_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_selfscan_q_load_pk on ods.qu2_act_dtl_selfscan_q_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_selfscan_q_load add constraint qu2_act_dtl_selfscan_q_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_selfscan_q_load_uk on ods.qu2_act_dtl_selfscan_q_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_act_dtl_selfscan_q_load is '[ActivityDetail_Checkout_SelfscanQZ][LOAD] Detail file for Selfscan Checkout Queuing Zone Audit task';
comment on column qu2_act_dtl_selfscan_q_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_selfscan_q_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_selfscan_q_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_selfscan_q_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_selfscan_q_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_selfscan_q_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_selfscan_q_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_selfscan_q_load.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_selfscan_q_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_selfscan_q_load.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_selfscan_q_load.zone_no is '[ZoneNum] Selfscan Queueing Zone Number';
comment on column qu2_act_dtl_selfscan_q_load.no_sku is '[NumSKU] Number of SKUs in queuing zone';
comment on column qu2_act_dtl_selfscan_q_load.no_sku_adjacent is '[NumSKUAdjacent] Number of SKUs in Adjacent location';
comment on column qu2_act_dtl_selfscan_q_load.is_active is '[IsActive] Active flag. This is used to easily identify what products are / aren''t part of capture.';
comment on column qu2_act_dtl_selfscan_q_load.prod_id is '[Product_ID] Foreign key from [StoreSellingArea].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_selfscan_q_load for ods.qu2_act_dtl_selfscan_q_load;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_selfscan_q_load to ods_app;
grant select on ods.qu2_act_dtl_selfscan_q_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_act_dtl_selfscan_q_hist cascade constraints;

create table ods.qu2_act_dtl_selfscan_q_hist (
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
  zone_no                         number(10, 0)                   null,
  no_sku                          number(10, 0)                   null,
  no_sku_adjacent                 number(10, 0)                   null,
  is_active                       number(1, 0)                    null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_selfscan_q_hist add constraint qu2_act_dtl_selfscan_q_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_selfscan_q_hist_pk on ods.qu2_act_dtl_selfscan_q_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_selfscan_q_hist add constraint qu2_act_dtl_selfscan_q_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_selfscan_q_hist_uk on ods.qu2_act_dtl_selfscan_q_hist (id,q4x_batch_id)) compress;

create index ods.qu2_act_dtl_selfscan_q_hist_ts on ods.qu2_act_dtl_selfscan_q_hist (q4x_timestamp) compress;

-- Comments
comment on table qu2_act_dtl_selfscan_q_hist is '[ActivityDetail_Checkout_SelfscanQZ][HIST] Detail file for Selfscan Checkout Queuing Zone Audit task';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_selfscan_q_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_selfscan_q_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_selfscan_q_hist.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_selfscan_q_hist.zone_no is '[ZoneNum] Selfscan Queueing Zone Number';
comment on column qu2_act_dtl_selfscan_q_hist.no_sku is '[NumSKU] Number of SKUs in queuing zone';
comment on column qu2_act_dtl_selfscan_q_hist.no_sku_adjacent is '[NumSKUAdjacent] Number of SKUs in Adjacent location';
comment on column qu2_act_dtl_selfscan_q_hist.is_active is '[IsActive] Active flag. This is used to easily identify what products are / aren''t part of capture.';
comment on column qu2_act_dtl_selfscan_q_hist.prod_id is '[Product_ID] Foreign key from [StoreSellingArea].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_selfscan_q_hist for ods.qu2_act_dtl_selfscan_q_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_selfscan_q_hist to ods_app;
grant select on ods.qu2_act_dtl_selfscan_q_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
