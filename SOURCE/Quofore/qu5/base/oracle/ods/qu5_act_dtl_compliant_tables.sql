
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_act_dtl_compliant
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_act_dtl_compliant] table creation script _load and _hist

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
drop table ods.qu5_act_dtl_compliant_load cascade constraints;

create table ods.qu5_act_dtl_compliant_load (
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
  hier_node_id                    number(10, 0)                   null,
  is_promo_complient              number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_act_dtl_compliant_load add constraint qu5_act_dtl_compliant_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_act_dtl_compliant_load_pk on ods.qu5_act_dtl_compliant_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_act_dtl_compliant_load add constraint qu5_act_dtl_compliant_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_act_dtl_compliant_load_uk on ods.qu5_act_dtl_compliant_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_act_dtl_compliant_load is '[ActivityDetail_PromoCompliance][LOAD] Captures details whether a store is promotional compliant';
comment on column qu5_act_dtl_compliant_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_act_dtl_compliant_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_act_dtl_compliant_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_act_dtl_compliant_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_act_dtl_compliant_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_act_dtl_compliant_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_act_dtl_compliant_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_act_dtl_compliant_load.q4x_timestamp is '* Timestamp';
comment on column qu5_act_dtl_compliant_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_act_dtl_compliant_load.act_id is '[Activity_Id] foreign key from [Activity].[Id]';
comment on column qu5_act_dtl_compliant_load.hier_node_id is '[HierarchyNode_Id] foreign key from [Hierarchy].[Id]';
comment on column qu5_act_dtl_compliant_load.is_promo_complient is '[PC_PromoCompliance] Whether the Products are Promotional Compliant';

-- Synonyms
create or replace public synonym qu5_act_dtl_compliant_load for ods.qu5_act_dtl_compliant_load;

-- Grants
grant select,insert,update,delete on ods.qu5_act_dtl_compliant_load to ods_app;
grant select on ods.qu5_act_dtl_compliant_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_act_dtl_compliant_hist cascade constraints;

create table ods.qu5_act_dtl_compliant_hist (
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
  hier_node_id                    number(10, 0)                   null,
  is_promo_complient              number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_act_dtl_compliant_hist add constraint qu5_act_dtl_compliant_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_act_dtl_compliant_hist_pk on ods.qu5_act_dtl_compliant_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_act_dtl_compliant_hist add constraint qu5_act_dtl_compliant_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_act_dtl_compliant_hist_uk on ods.qu5_act_dtl_compliant_hist (id,q4x_batch_id)) compress;

create index ods.qu5_act_dtl_compliant_hist_ts on ods.qu5_act_dtl_compliant_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_act_dtl_compliant_hist is '[ActivityDetail_PromoCompliance][HIST] Captures details whether a store is promotional compliant';
comment on column qu5_act_dtl_compliant_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_act_dtl_compliant_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_act_dtl_compliant_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_act_dtl_compliant_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_act_dtl_compliant_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_act_dtl_compliant_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_act_dtl_compliant_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_act_dtl_compliant_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_act_dtl_compliant_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_act_dtl_compliant_hist.act_id is '[Activity_Id] foreign key from [Activity].[Id]';
comment on column qu5_act_dtl_compliant_hist.hier_node_id is '[HierarchyNode_Id] foreign key from [Hierarchy].[Id]';
comment on column qu5_act_dtl_compliant_hist.is_promo_complient is '[PC_PromoCompliance] Whether the Products are Promotional Compliant';

-- Synonyms
create or replace public synonym qu5_act_dtl_compliant_hist for ods.qu5_act_dtl_compliant_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_act_dtl_compliant_hist to ods_app;
grant select on ods.qu5_act_dtl_compliant_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
