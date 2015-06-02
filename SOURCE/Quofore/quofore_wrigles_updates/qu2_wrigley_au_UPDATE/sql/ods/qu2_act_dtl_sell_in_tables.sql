
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_act_dtl_sell_in
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_act_dtl_sell_in] table creation script _load and _hist

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
drop table ods.qu2_act_dtl_sell_in_load cascade constraints;

create table ods.qu2_act_dtl_sell_in_load (
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
  no_deals_sold                   number(10, 0)                   null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_sell_in_load add constraint qu2_act_dtl_sell_in_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_sell_in_load_pk on ods.qu2_act_dtl_sell_in_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_sell_in_load add constraint qu2_act_dtl_sell_in_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_sell_in_load_uk on ods.qu2_act_dtl_sell_in_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_act_dtl_sell_in_load is '[ActivityDetail_Sell_In][LOAD] Detail file for Sell in (Deals) task';
comment on column qu2_act_dtl_sell_in_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_sell_in_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_sell_in_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_sell_in_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_sell_in_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_sell_in_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_sell_in_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_sell_in_load.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_sell_in_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_sell_in_load.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_sell_in_load.no_deals_sold is '[NumDealsSold] Number of prepacks sold';
comment on column qu2_act_dtl_sell_in_load.prod_id is '[Product_ID] Foreign key from [Hierarchy].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_sell_in_load for ods.qu2_act_dtl_sell_in_load;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_sell_in_load to ods_app;
grant select on ods.qu2_act_dtl_sell_in_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_act_dtl_sell_in_hist cascade constraints;

create table ods.qu2_act_dtl_sell_in_hist (
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
  no_deals_sold                   number(10, 0)                   null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_sell_in_hist add constraint qu2_act_dtl_sell_in_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_sell_in_hist_pk on ods.qu2_act_dtl_sell_in_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_sell_in_hist add constraint qu2_act_dtl_sell_in_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_sell_in_hist_uk on ods.qu2_act_dtl_sell_in_hist (id,q4x_batch_id)) compress;

create index ods.qu2_act_dtl_sell_in_hist_ts on ods.qu2_act_dtl_sell_in_hist (q4x_timestamp) compress;

-- Comments
comment on table qu2_act_dtl_sell_in_hist is '[ActivityDetail_Sell_In][HIST] Detail file for Sell in (Deals) task';
comment on column qu2_act_dtl_sell_in_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_sell_in_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_sell_in_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_sell_in_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_sell_in_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_sell_in_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_sell_in_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_sell_in_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_sell_in_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_sell_in_hist.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_sell_in_hist.no_deals_sold is '[NumDealsSold] Number of prepacks sold';
comment on column qu2_act_dtl_sell_in_hist.prod_id is '[Product_ID] Foreign key from [Hierarchy].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_sell_in_hist for ods.qu2_act_dtl_sell_in_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_sell_in_hist to ods_app;
grant select on ods.qu2_act_dtl_sell_in_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
