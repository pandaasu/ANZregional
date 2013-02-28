
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_task_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_task_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_task_hist cascade constraints;

create table ods.quo_task_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_source_id                   number(4)                       not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  id_lookup                       varchar2(50 char)               null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_lookup     varchar2(50 char)               null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  status_id                       number(10, 0)                   null,
  status_id_lookup                varchar2(50 char)               null,
  status_id_desc                  varchar2(50 char)               null,
  is_recurring                    number(1, 0)                    null,
  is_all_day                      number(1, 0)                    null,
  name                            varchar2(50 char)               null,
  start_date                      date                            null,
  end_date                        date                            null,
  priority_id                     number(10, 0)                   null,
  priority_id_lookup              varchar2(50 char)               null,
  priority_id_desc                varchar2(50 char)               null,
  due_date                        date                            null,
  time                            date                            null,
  duration                        date                            null,
  note                            varchar2(200 char)              null,
  task_type_id                    number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_task_hist add constraint quo_task_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_task_hist_pk on ods.quo_task_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_task_hist add constraint quo_task_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_task_hist_uk on ods.quo_task_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_task_hist_ts on ods.quo_task_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_task_hist is '[Task] Main task details';
comment on column quo_task_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_task_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_task_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_task_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_task_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_task_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_task_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_task_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_task_hist.q4x_timestamp is '* Timestamp';
comment on column quo_task_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_task_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_task_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_task_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_task_hist.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_task_hist.incomplete_reason_id_lookup is '[IncompleteReasonID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_task_hist.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column quo_task_hist.status_id is '[StatusID] To find the LookupList and LookupListItem for Status.';
comment on column quo_task_hist.status_id_lookup is '[StatusID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_task_hist.status_id_desc is '[StatusID_Description] Default language description of the node';
comment on column quo_task_hist.is_recurring is '[IsRecurring] Indicates whether the task should be performed in each visit to the same location. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column quo_task_hist.is_all_day is '[IsAllDay] Indicates whether this task is an "all-day" task. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column quo_task_hist.name is '[Name] The name of the survey.';
comment on column quo_task_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column quo_task_hist.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column quo_task_hist.priority_id is '[PriorityID] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_task_hist.priority_id_lookup is '[PriorityID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_task_hist.priority_id_desc is '[PriorityID_Description] Default language description of the node';
comment on column quo_task_hist.due_date is '[DueDate] The date the task is due.';
comment on column quo_task_hist.time is '[Time] The time of day that the task is to be executed.';
comment on column quo_task_hist.duration is '[Duration] How long the task is expected to take to complete.';
comment on column quo_task_hist.note is '[Notes] Notes about the task.';
comment on column quo_task_hist.task_type_id is '[TaskTypeID] To find the LookupList and LookupListItem this field is mapped to.<\n>This tells us the type of task e.g. distribution check, share of shelf etc.';


-- Synonyms
create or replace public synonym quo_task_hist for ods.quo_task_hist;

-- Grants
grant select,update,delete,insert on ods.quo_task_hist to ods_app;
grant select on ods.quo_task_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
