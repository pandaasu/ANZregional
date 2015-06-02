
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_graveyard
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_graveyard] table creation script _load and _hist

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
drop table ods.qu2_graveyard_load cascade constraints;

create table ods.qu2_graveyard_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  entity                          varchar2(50 char)               not null,
  unique_id                       varchar2(100 char)              null,
  id_lookup                       number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_graveyard_load add constraint qu2_graveyard_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_graveyard_load_pk on ods.qu2_graveyard_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_graveyard_load add constraint qu2_graveyard_load_uk unique (id,entity,q4x_batch_id)
  using index (create unique index ods.qu2_graveyard_load_uk on ods.qu2_graveyard_load (id,entity,q4x_batch_id)) compress;

-- Comments
comment on table qu2_graveyard_load is '[Graveyard][LOAD] File that contains information on the records to delete for each entity.<\n>Deletion can be specified for entities which have primary key comprising of up to 2 columns.';
comment on column qu2_graveyard_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_graveyard_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_graveyard_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_graveyard_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_graveyard_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_graveyard_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_graveyard_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_graveyard_load.q4x_timestamp is '* Timestamp';
comment on column qu2_graveyard_load.id is '[ID] Internal ID for the row of entity. Unique within an entity but can be repeated for different entities.';
comment on column qu2_graveyard_load.entity is '[Entity] Name of the entity where deletion needs to be done e.g. CustomerTerritory';
comment on column qu2_graveyard_load.unique_id is '[UniqueID] Computed field for internal use only (it''s just a concatenation of Entity and ID fields). You may also use this as Primary Key';
comment on column qu2_graveyard_load.id_lookup is '[id_lookup] ';

-- Synonyms
create or replace public synonym qu2_graveyard_load for ods.qu2_graveyard_load;

-- Grants
grant select,insert,update,delete on ods.qu2_graveyard_load to ods_app;
grant select on ods.qu2_graveyard_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_graveyard_hist cascade constraints;

create table ods.qu2_graveyard_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  entity                          varchar2(50 char)               not null,
  unique_id                       varchar2(100 char)              null,
  id_lookup                       number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_graveyard_hist add constraint qu2_graveyard_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_graveyard_hist_pk on ods.qu2_graveyard_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_graveyard_hist add constraint qu2_graveyard_hist_uk unique (id,entity,q4x_batch_id)
  using index (create unique index ods.qu2_graveyard_hist_uk on ods.qu2_graveyard_hist (id,entity,q4x_batch_id)) compress;

create index ods.qu2_graveyard_hist_ts on ods.qu2_graveyard_hist (q4x_timestamp) compress;

-- Comments
comment on table qu2_graveyard_hist is '[Graveyard][HIST] File that contains information on the records to delete for each entity.<\n>Deletion can be specified for entities which have primary key comprising of up to 2 columns.';
comment on column qu2_graveyard_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_graveyard_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_graveyard_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_graveyard_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_graveyard_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_graveyard_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_graveyard_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_graveyard_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_graveyard_hist.id is '[ID] Internal ID for the row of entity. Unique within an entity but can be repeated for different entities.';
comment on column qu2_graveyard_hist.entity is '[Entity] Name of the entity where deletion needs to be done e.g. CustomerTerritory';
comment on column qu2_graveyard_hist.unique_id is '[UniqueID] Computed field for internal use only (it''s just a concatenation of Entity and ID fields). You may also use this as Primary Key';
comment on column qu2_graveyard_hist.id_lookup is '[id_lookup] ';

-- Synonyms
create or replace public synonym qu2_graveyard_hist for ods.qu2_graveyard_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_graveyard_hist to ods_app;
grant select on ods.qu2_graveyard_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
