
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_act_dtl_storeop_ro
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_act_dtl_storeop_ro] table creation script _load and _hist

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
drop table ods.qu3_act_dtl_storeop_ro_load cascade constraints;

create table ods.qu3_act_dtl_storeop_ro_load (
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
  no_register                     number(10, 0)                   null,
  no_chiller_door                 number(10, 0)                   null,
  prod_id                         number(10, 0)                   null,
  no_parallel_store               number(10, 0)                   null,
  no_paralle_wwy_stand            number(10, 0)                   null,
  no_comp_wwy_stand               number(10, 0)                   null,
  no_oos_wwy_stand                number(10, 0)                   null,
  no_pack_date_issue              number(10, 0)                   null,
  pref_wholesaler                 number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_act_dtl_storeop_ro_load add constraint qu3_act_dtl_storeop_ro_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_act_dtl_storeop_ro_load_pk on ods.qu3_act_dtl_storeop_ro_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_act_dtl_storeop_ro_load add constraint qu3_act_dtl_storeop_ro_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_act_dtl_storeop_ro_load_uk on ods.qu3_act_dtl_storeop_ro_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_act_dtl_storeop_ro_load is '[ActivityDetail_StoreOppRoute][LOAD] Detail file for Store Opportunity Route task';
comment on column qu3_act_dtl_storeop_ro_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_act_dtl_storeop_ro_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_act_dtl_storeop_ro_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_act_dtl_storeop_ro_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_act_dtl_storeop_ro_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_act_dtl_storeop_ro_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_act_dtl_storeop_ro_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_act_dtl_storeop_ro_load.q4x_timestamp is '* Timestamp';
comment on column qu3_act_dtl_storeop_ro_load.id is '[ID] Unique Internal ID for the row';
comment on column qu3_act_dtl_storeop_ro_load.act_id is '[Activity_ID] Mandatory Foreign key from ActivityHeader.ID';
comment on column qu3_act_dtl_storeop_ro_load.no_register is '[NumRegister] Number of registers';
comment on column qu3_act_dtl_storeop_ro_load.no_chiller_door is '[NumChillerDoor] Num Bev Chiller Doors';
comment on column qu3_act_dtl_storeop_ro_load.prod_id is '[Product_ID] Foreign key from Product.ID';
comment on column qu3_act_dtl_storeop_ro_load.no_parallel_store is '[NumParallelStore] Num Parallel Import SKUs in Store';
comment on column qu3_act_dtl_storeop_ro_load.no_paralle_wwy_stand is '[NumParallelWrigStand] Num Parallel Import SKUs on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_load.no_comp_wwy_stand is '[NumCompWrigStand] Num Competitor Products on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_load.no_oos_wwy_stand is '[NumOOSWrigStand] Num OOS facings on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_load.no_pack_date_issue is '[NumPacksDateIssue] Num Wrigley packs w. date issues found in Store';
comment on column qu3_act_dtl_storeop_ro_load.pref_wholesaler is '[PreferredWholesaler] Preferred Wholesaler';

-- Synonyms
create or replace public synonym qu3_act_dtl_storeop_ro_load for ods.qu3_act_dtl_storeop_ro_load;

-- Grants
grant select,insert,update,delete on ods.qu3_act_dtl_storeop_ro_load to ods_app;
grant select on ods.qu3_act_dtl_storeop_ro_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_act_dtl_storeop_ro_hist cascade constraints;

create table ods.qu3_act_dtl_storeop_ro_hist (
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
  no_register                     number(10, 0)                   null,
  no_chiller_door                 number(10, 0)                   null,
  prod_id                         number(10, 0)                   null,
  no_parallel_store               number(10, 0)                   null,
  no_paralle_wwy_stand            number(10, 0)                   null,
  no_comp_wwy_stand               number(10, 0)                   null,
  no_oos_wwy_stand                number(10, 0)                   null,
  no_pack_date_issue              number(10, 0)                   null,
  pref_wholesaler                 number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_act_dtl_storeop_ro_hist add constraint qu3_act_dtl_storeop_ro_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_act_dtl_storeop_ro_hist_pk on ods.qu3_act_dtl_storeop_ro_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_act_dtl_storeop_ro_hist add constraint qu3_act_dtl_storeop_ro_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_act_dtl_storeop_ro_hist_uk on ods.qu3_act_dtl_storeop_ro_hist (id,q4x_batch_id)) compress;

create index ods.qu3_act_dtl_storeop_ro_hist_ts on ods.qu3_act_dtl_storeop_ro_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_act_dtl_storeop_ro_hist is '[ActivityDetail_StoreOppRoute][HIST] Detail file for Store Opportunity Route task';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_act_dtl_storeop_ro_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_act_dtl_storeop_ro_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu3_act_dtl_storeop_ro_hist.act_id is '[Activity_ID] Mandatory Foreign key from ActivityHeader.ID';
comment on column qu3_act_dtl_storeop_ro_hist.no_register is '[NumRegister] Number of registers';
comment on column qu3_act_dtl_storeop_ro_hist.no_chiller_door is '[NumChillerDoor] Num Bev Chiller Doors';
comment on column qu3_act_dtl_storeop_ro_hist.prod_id is '[Product_ID] Foreign key from Product.ID';
comment on column qu3_act_dtl_storeop_ro_hist.no_parallel_store is '[NumParallelStore] Num Parallel Import SKUs in Store';
comment on column qu3_act_dtl_storeop_ro_hist.no_paralle_wwy_stand is '[NumParallelWrigStand] Num Parallel Import SKUs on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_hist.no_comp_wwy_stand is '[NumCompWrigStand] Num Competitor Products on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_hist.no_oos_wwy_stand is '[NumOOSWrigStand] Num OOS facings on Wrigley Stands';
comment on column qu3_act_dtl_storeop_ro_hist.no_pack_date_issue is '[NumPacksDateIssue] Num Wrigley packs w. date issues found in Store';
comment on column qu3_act_dtl_storeop_ro_hist.pref_wholesaler is '[PreferredWholesaler] Preferred Wholesaler';

-- Synonyms
create or replace public synonym qu3_act_dtl_storeop_ro_hist for ods.qu3_act_dtl_storeop_ro_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_act_dtl_storeop_ro_hist to ods_app;
grant select on ods.qu3_act_dtl_storeop_ro_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
