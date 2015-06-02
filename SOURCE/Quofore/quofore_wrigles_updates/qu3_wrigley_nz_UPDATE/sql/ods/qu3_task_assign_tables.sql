
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_task_assign
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_task_assign] table creation script _load and _hist

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
drop table ods.qu3_task_assign_load cascade constraints;

create table ods.qu3_task_assign_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  created_date                    date                            null,
  task_id                         number(10, 0)                   null,
  rep_id                          number(10, 0)                   null,
  role_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_task_assign_load add constraint qu3_task_assign_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_task_assign_load_pk on ods.qu3_task_assign_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_task_assign_load add constraint qu3_task_assign_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_task_assign_load_uk on ods.qu3_task_assign_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_task_assign_load is '[TaskAssignment][LOAD] Assignment of tasks to Rep or roles.';
comment on column qu3_task_assign_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_task_assign_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_task_assign_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_task_assign_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_task_assign_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_task_assign_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_task_assign_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_task_assign_load.q4x_timestamp is '* Timestamp';
comment on column qu3_task_assign_load.id is '[ID] Unique Internal ID for the row';
comment on column qu3_task_assign_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu3_task_assign_load.task_id is '[Task_ID] Mandatory foreign key from [Task].[Id].';
comment on column qu3_task_assign_load.rep_id is '[Rep_ID] Either Rep_ID or Role_ID field is compulsory';
comment on column qu3_task_assign_load.role_id is '[Role_ID] Either Rep_ID or Role_ID field is compulsory';

-- Synonyms
create or replace public synonym qu3_task_assign_load for ods.qu3_task_assign_load;

-- Grants
grant select,insert,update,delete on ods.qu3_task_assign_load to ods_app;
grant select on ods.qu3_task_assign_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_task_assign_hist cascade constraints;

create table ods.qu3_task_assign_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  created_date                    date                            null,
  task_id                         number(10, 0)                   null,
  rep_id                          number(10, 0)                   null,
  role_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu3_task_assign_hist add constraint qu3_task_assign_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_task_assign_hist_pk on ods.qu3_task_assign_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_task_assign_hist add constraint qu3_task_assign_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_task_assign_hist_uk on ods.qu3_task_assign_hist (id,q4x_batch_id)) compress;

create index ods.qu3_task_assign_hist_ts on ods.qu3_task_assign_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_task_assign_hist is '[TaskAssignment][HIST] Assignment of tasks to Rep or roles.';
comment on column qu3_task_assign_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_task_assign_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_task_assign_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_task_assign_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_task_assign_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_task_assign_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_task_assign_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_task_assign_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_task_assign_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu3_task_assign_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu3_task_assign_hist.task_id is '[Task_ID] Mandatory foreign key from [Task].[Id].';
comment on column qu3_task_assign_hist.rep_id is '[Rep_ID] Either Rep_ID or Role_ID field is compulsory';
comment on column qu3_task_assign_hist.role_id is '[Role_ID] Either Rep_ID or Role_ID field is compulsory';

-- Synonyms
create or replace public synonym qu3_task_assign_hist for ods.qu3_task_assign_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_task_assign_hist to ods_app;
grant select on ods.qu3_task_assign_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
