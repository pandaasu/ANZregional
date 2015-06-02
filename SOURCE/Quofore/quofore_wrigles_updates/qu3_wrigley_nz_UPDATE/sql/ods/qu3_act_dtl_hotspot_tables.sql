
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_act_dtl_hotspot
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_act_dtl_hotspot] table creation script _load and _hist

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
drop table ods.qu3_act_dtl_hotspot_load cascade constraints;

create table ods.qu3_act_dtl_hotspot_load (
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
  no_achieved                     number(10, 0)                   null,
  no_otc_gum_facing               number(10, 0)                   null,
  no_mp_gum_facing                number(10, 0)                   null,
  no_mint_facing                  number(10, 0)                   null,
  no_confec_facing                number(10, 0)                   null,
  no_confec_facing_2              number(10, 0)                   null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_act_dtl_hotspot_load add constraint qu3_act_dtl_hotspot_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_act_dtl_hotspot_load_pk on ods.qu3_act_dtl_hotspot_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_act_dtl_hotspot_load add constraint qu3_act_dtl_hotspot_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_act_dtl_hotspot_load_uk on ods.qu3_act_dtl_hotspot_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_act_dtl_hotspot_load is '[ActivityDetail_HotSpot][LOAD] Detail file for Hot spot task';
comment on column qu3_act_dtl_hotspot_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_act_dtl_hotspot_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_act_dtl_hotspot_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_act_dtl_hotspot_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_act_dtl_hotspot_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_act_dtl_hotspot_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_act_dtl_hotspot_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_act_dtl_hotspot_load.q4x_timestamp is '* Timestamp';
comment on column qu3_act_dtl_hotspot_load.id is '[ID] Unique Internal ID for the row';
comment on column qu3_act_dtl_hotspot_load.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu3_act_dtl_hotspot_load.no_achieved is '[NumAchieved] Number achieved';
comment on column qu3_act_dtl_hotspot_load.no_otc_gum_facing is '[NumOTCGumFacing] Number of OTC gum facings (Single Packs)';
comment on column qu3_act_dtl_hotspot_load.no_mp_gum_facing is '[NumMPGumFacing] Number of multi-pack gum facings';
comment on column qu3_act_dtl_hotspot_load.no_mint_facing is '[NumMintFacing] Number of mint facings';
comment on column qu3_act_dtl_hotspot_load.no_confec_facing is '[NumConfecFacing] Number of confectionary facings Skittles';
comment on column qu3_act_dtl_hotspot_load.no_confec_facing_2 is '[NumConfecFacing2] Number of confectionary facings Starburst';
comment on column qu3_act_dtl_hotspot_load.prod_id is '[Product_ID] Foreign key from [Product].[Id].';

-- Synonyms
create or replace public synonym qu3_act_dtl_hotspot_load for ods.qu3_act_dtl_hotspot_load;

-- Grants
grant select,insert,update,delete on ods.qu3_act_dtl_hotspot_load to ods_app;
grant select on ods.qu3_act_dtl_hotspot_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_act_dtl_hotspot_hist cascade constraints;

create table ods.qu3_act_dtl_hotspot_hist (
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
  no_achieved                     number(10, 0)                   null,
  no_otc_gum_facing               number(10, 0)                   null,
  no_mp_gum_facing                number(10, 0)                   null,
  no_mint_facing                  number(10, 0)                   null,
  no_confec_facing                number(10, 0)                   null,
  no_confec_facing_2              number(10, 0)                   null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_act_dtl_hotspot_hist add constraint qu3_act_dtl_hotspot_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_act_dtl_hotspot_hist_pk on ods.qu3_act_dtl_hotspot_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_act_dtl_hotspot_hist add constraint qu3_act_dtl_hotspot_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_act_dtl_hotspot_hist_uk on ods.qu3_act_dtl_hotspot_hist (id,q4x_batch_id)) compress;

create index ods.qu3_act_dtl_hotspot_hist_ts on ods.qu3_act_dtl_hotspot_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_act_dtl_hotspot_hist is '[ActivityDetail_HotSpot][HIST] Detail file for Hot spot task';
comment on column qu3_act_dtl_hotspot_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_act_dtl_hotspot_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_act_dtl_hotspot_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_act_dtl_hotspot_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_act_dtl_hotspot_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_act_dtl_hotspot_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_act_dtl_hotspot_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_act_dtl_hotspot_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_act_dtl_hotspot_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu3_act_dtl_hotspot_hist.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu3_act_dtl_hotspot_hist.no_achieved is '[NumAchieved] Number achieved';
comment on column qu3_act_dtl_hotspot_hist.no_otc_gum_facing is '[NumOTCGumFacing] Number of OTC gum facings (Single Packs)';
comment on column qu3_act_dtl_hotspot_hist.no_mp_gum_facing is '[NumMPGumFacing] Number of multi-pack gum facings';
comment on column qu3_act_dtl_hotspot_hist.no_mint_facing is '[NumMintFacing] Number of mint facings';
comment on column qu3_act_dtl_hotspot_hist.no_confec_facing is '[NumConfecFacing] Number of confectionary facings Skittles';
comment on column qu3_act_dtl_hotspot_hist.no_confec_facing_2 is '[NumConfecFacing2] Number of confectionary facings Starburst';
comment on column qu3_act_dtl_hotspot_hist.prod_id is '[Product_ID] Foreign key from [Product].[Id].';

-- Synonyms
create or replace public synonym qu3_act_dtl_hotspot_hist for ods.qu3_act_dtl_hotspot_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_act_dtl_hotspot_hist to ods_app;
grant select on ods.qu3_act_dtl_hotspot_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
