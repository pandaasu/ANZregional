
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_task
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_task] table creation script _load and _hist

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
drop table ods.qu2_task_load cascade constraints;

create table ods.qu2_task_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  status_id                       number(10, 0)                   null,
  status_id_desc                  varchar2(50 char)               null,
  is_recurring                    number(1, 0)                    null,
  is_all_day                      number(1, 0)                    null,
  name                            varchar2(50 char)               null,
  start_date                      date                            null,
  end_date                        date                            null,
  priority_id                     number(10, 0)                   null,
  priority_id_desc                varchar2(50 char)               null,
  due_date                        date                            null,
  time                            date                            null,
  duration                        date                            null,
  note                            varchar2(200 char)              null,
  task_type_id                    number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_task_load add constraint qu2_task_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_task_load_pk on ods.qu2_task_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_task_load add constraint qu2_task_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_task_load_uk on ods.qu2_task_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_task_load is '[Task][LOAD] Main task details.';
comment on column qu2_task_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_task_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_task_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_task_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_task_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_task_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_task_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_task_load.q4x_timestamp is '* Timestamp';
comment on column qu2_task_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_task_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu2_task_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu2_task_load.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_task_load.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column qu2_task_load.status_id is '[StatusID] To find the LookupList and LookupListItem for Status.';
comment on column qu2_task_load.status_id_desc is '[StatusID_Description] Default language description of the node';
comment on column qu2_task_load.is_recurring is '[IsRecurring] Indicates whether the task should be performed in each visit to the same location. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu2_task_load.is_all_day is '[IsAllDay] Indicates whether this task is an "all-day" task. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu2_task_load.name is '[Name] The name of the survey.';
comment on column qu2_task_load.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu2_task_load.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu2_task_load.priority_id is '[PriorityID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_task_load.priority_id_desc is '[PriorityID_Description] Default language description of the node';
comment on column qu2_task_load.due_date is '[DueDate] The date the task is due.';
comment on column qu2_task_load.time is '[Time] The time of day that the task is to be executed.';
comment on column qu2_task_load.duration is '[Duration] How long the task is expected to take to complete.';
comment on column qu2_task_load.note is '[Notes] Notes about the task.';
comment on column qu2_task_load.task_type_id is '[TaskTypeID] To find the LookupList and LookupListItem this field is mapped to.<\n>This tells us the type of task e.g. distribution check, share of shelf etc.';

-- Synonyms
create or replace public synonym qu2_task_load for ods.qu2_task_load;

-- Grants
grant select,insert,update,delete on ods.qu2_task_load to ods_app;
grant select on ods.qu2_task_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_task_hist cascade constraints;

create table ods.qu2_task_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  status_id                       number(10, 0)                   null,
  status_id_desc                  varchar2(50 char)               null,
  is_recurring                    number(1, 0)                    null,
  is_all_day                      number(1, 0)                    null,
  name                            varchar2(50 char)               null,
  start_date                      date                            null,
  end_date                        date                            null,
  priority_id                     number(10, 0)                   null,
  priority_id_desc                varchar2(50 char)               null,
  due_date                        date                            null,
  time                            date                            null,
  duration                        date                            null,
  note                            varchar2(200 char)              null,
  task_type_id                    number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu2_task_hist add constraint qu2_task_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_task_hist_pk on ods.qu2_task_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_task_hist add constraint qu2_task_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_task_hist_uk on ods.qu2_task_hist (id,q4x_batch_id)) compress;

create index ods.qu2_task_hist_ts on ods.qu2_task_hist (q4x_timestamp) compress;

create index ods.qu2_task_hist_sd on ods.qu2_task_hist (start_date) compress;

-- Comments
comment on table qu2_task_hist is '[Task][HIST] Main task details.';
comment on column qu2_task_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_task_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_task_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_task_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_task_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_task_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_task_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_task_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_task_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_task_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu2_task_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu2_task_hist.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_task_hist.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column qu2_task_hist.status_id is '[StatusID] To find the LookupList and LookupListItem for Status.';
comment on column qu2_task_hist.status_id_desc is '[StatusID_Description] Default language description of the node';
comment on column qu2_task_hist.is_recurring is '[IsRecurring] Indicates whether the task should be performed in each visit to the same location. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu2_task_hist.is_all_day is '[IsAllDay] Indicates whether this task is an "all-day" task. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu2_task_hist.name is '[Name] The name of the survey.';
comment on column qu2_task_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu2_task_hist.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu2_task_hist.priority_id is '[PriorityID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_task_hist.priority_id_desc is '[PriorityID_Description] Default language description of the node';
comment on column qu2_task_hist.due_date is '[DueDate] The date the task is due.';
comment on column qu2_task_hist.time is '[Time] The time of day that the task is to be executed.';
comment on column qu2_task_hist.duration is '[Duration] How long the task is expected to take to complete.';
comment on column qu2_task_hist.note is '[Notes] Notes about the task.';
comment on column qu2_task_hist.task_type_id is '[TaskTypeID] To find the LookupList and LookupListItem this field is mapped to.<\n>This tells us the type of task e.g. distribution check, share of shelf etc.';

-- Synonyms
create or replace public synonym qu2_task_hist for ods.qu2_task_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_task_hist to ods_app;
grant select on ods.qu2_task_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
