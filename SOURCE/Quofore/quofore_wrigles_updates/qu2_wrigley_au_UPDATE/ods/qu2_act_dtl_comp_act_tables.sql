
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_act_dtl_comp_act
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_act_dtl_comp_act] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-03-18  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu2_act_dtl_comp_act_load cascade constraints;

create table ods.qu2_act_dtl_comp_act_load (
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
  wwy_comp                        number(10, 0)                   null,
  wwy_comp_call_cycle             number(10, 0)                   null,
  wwy_comp_focus                  number(10, 0)                   null,
  wwy_offer_to_retailer           number(10, 0)                   null,
  wwy_comp_act_app_by             number(10, 0)                   null,
  wwy_impact_hardware             number(10, 0)                   null,
  wwy_impact_facings              number(10, 0)                   null,
  wwy_result_exit                 number(10, 0)                   null,
  wwy_value_reward                varchar2(4000 char)             null,
  wwy_result_exit_app_by          number(10, 0)                   null,
  hier_node_id                    number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_comp_act_load add constraint qu2_act_dtl_comp_act_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_comp_act_load_pk on ods.qu2_act_dtl_comp_act_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_comp_act_load add constraint qu2_act_dtl_comp_act_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_comp_act_load_uk on ods.qu2_act_dtl_comp_act_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_act_dtl_comp_act_load is '[ActivityDetail_CompetitionAct][LOAD] Detail file for Competition Activity task';
comment on column qu2_act_dtl_comp_act_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_comp_act_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_comp_act_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_comp_act_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_comp_act_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_comp_act_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_comp_act_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_comp_act_load.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_comp_act_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_comp_act_load.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_comp_act_load.wwy_comp is '[WrigCompetitor] Competitor';
comment on column qu2_act_dtl_comp_act_load.wwy_comp_call_cycle is '[WrigCompCallCycle] Competitor call cycle';
comment on column qu2_act_dtl_comp_act_load.wwy_comp_focus is '[WrigCompFocus] Competitor focus';
comment on column qu2_act_dtl_comp_act_load.wwy_offer_to_retailer is '[WrigOfferToRetailer] Offer to retailer';
comment on column qu2_act_dtl_comp_act_load.wwy_comp_act_app_by is '[WrigCompActAppBy] Competitor activity approved by';
comment on column qu2_act_dtl_comp_act_load.wwy_impact_hardware is '[WrigImpactHardware] Impact on entry Wrigley hardware';
comment on column qu2_act_dtl_comp_act_load.wwy_impact_facings is '[WrigImpactFacings] Impact on entry Wrigley facings';
comment on column qu2_act_dtl_comp_act_load.wwy_result_exit is '[WrigResultExit] Wrigley result on exit';
comment on column qu2_act_dtl_comp_act_load.wwy_value_reward is '[WrigValueReward] Value of reward';
comment on column qu2_act_dtl_comp_act_load.wwy_result_exit_app_by is '[WrigResultExitAppBy] Wrigley result on exit approved by';
comment on column qu2_act_dtl_comp_act_load.hier_node_id is '[HierarchyNode_Id] Foreign key from [Product].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_comp_act_load for ods.qu2_act_dtl_comp_act_load;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_comp_act_load to ods_app;
grant select on ods.qu2_act_dtl_comp_act_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_act_dtl_comp_act_hist cascade constraints;

create table ods.qu2_act_dtl_comp_act_hist (
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
  wwy_comp                        number(10, 0)                   null,
  wwy_comp_call_cycle             number(10, 0)                   null,
  wwy_comp_focus                  number(10, 0)                   null,
  wwy_offer_to_retailer           number(10, 0)                   null,
  wwy_comp_act_app_by             number(10, 0)                   null,
  wwy_impact_hardware             number(10, 0)                   null,
  wwy_impact_facings              number(10, 0)                   null,
  wwy_result_exit                 number(10, 0)                   null,
  wwy_value_reward                varchar2(4000 char)             null,
  wwy_result_exit_app_by          number(10, 0)                   null,
  hier_node_id                    number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_act_dtl_comp_act_hist add constraint qu2_act_dtl_comp_act_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_act_dtl_comp_act_hist_pk on ods.qu2_act_dtl_comp_act_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_act_dtl_comp_act_hist add constraint qu2_act_dtl_comp_act_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_act_dtl_comp_act_hist_uk on ods.qu2_act_dtl_comp_act_hist (id,q4x_batch_id)) compress;

create index ods.qu2_act_dtl_comp_act_hist_ts on ods.qu2_act_dtl_comp_act_hist (q4x_timestamp) compress;

-- Comments
comment on table qu2_act_dtl_comp_act_hist is '[ActivityDetail_CompetitionAct][HIST] Detail file for Competition Activity task';
comment on column qu2_act_dtl_comp_act_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_act_dtl_comp_act_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_act_dtl_comp_act_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_act_dtl_comp_act_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_act_dtl_comp_act_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_act_dtl_comp_act_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_act_dtl_comp_act_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_act_dtl_comp_act_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_act_dtl_comp_act_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_act_dtl_comp_act_hist.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu2_act_dtl_comp_act_hist.wwy_comp is '[WrigCompetitor] Competitor';
comment on column qu2_act_dtl_comp_act_hist.wwy_comp_call_cycle is '[WrigCompCallCycle] Competitor call cycle';
comment on column qu2_act_dtl_comp_act_hist.wwy_comp_focus is '[WrigCompFocus] Competitor focus';
comment on column qu2_act_dtl_comp_act_hist.wwy_offer_to_retailer is '[WrigOfferToRetailer] Offer to retailer';
comment on column qu2_act_dtl_comp_act_hist.wwy_comp_act_app_by is '[WrigCompActAppBy] Competitor activity approved by';
comment on column qu2_act_dtl_comp_act_hist.wwy_impact_hardware is '[WrigImpactHardware] Impact on entry Wrigley hardware';
comment on column qu2_act_dtl_comp_act_hist.wwy_impact_facings is '[WrigImpactFacings] Impact on entry Wrigley facings';
comment on column qu2_act_dtl_comp_act_hist.wwy_result_exit is '[WrigResultExit] Wrigley result on exit';
comment on column qu2_act_dtl_comp_act_hist.wwy_value_reward is '[WrigValueReward] Value of reward';
comment on column qu2_act_dtl_comp_act_hist.wwy_result_exit_app_by is '[WrigResultExitAppBy] Wrigley result on exit approved by';
comment on column qu2_act_dtl_comp_act_hist.hier_node_id is '[HierarchyNode_Id] Foreign key from [Product].[Id].';

-- Synonyms
create or replace public synonym qu2_act_dtl_comp_act_hist for ods.qu2_act_dtl_comp_act_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_act_dtl_comp_act_hist to ods_app;
grant select on ods.qu2_act_dtl_comp_act_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
