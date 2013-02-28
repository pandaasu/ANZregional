
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_act_hdr_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_act_hdr_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_act_hdr_hist cascade constraints;

create table ods.quo_act_hdr_hist (
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
  task_id                         number(10, 0)                   null,
  task_id_lookup                  varchar2(50 char)               null,
  rep_id                          number(10, 0)                   null,
  rep_id_lookup                   varchar2(50 char)               null,
  start_date                      date                            null,
  is_complete                     number(1, 0)                    null,
  end_date                        date                            null,
  duration                        date                            null,
  callcard_id                     number(10, 0)                   null,
  callcard_id_lookup              varchar2(50 char)               null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_lookup     varchar2(50 char)               null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  note                            varchar2(200 char)              null,
  task_name                       varchar2(50 char)               null,
  due_date                        date                            null,
  full_name                       varchar2(101 char)              null,
  task_id_desc                    varchar2(200 char)              null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_act_hdr_hist add constraint quo_act_hdr_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_act_hdr_hist_pk on ods.quo_act_hdr_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_act_hdr_hist add constraint quo_act_hdr_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_act_hdr_hist_uk on ods.quo_act_hdr_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_act_hdr_hist_ts on ods.quo_act_hdr_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_act_hdr_hist is '[ActivityHeader] Header file for ALL the tasks transactional data. Each task instance has a separate detail file.';
comment on column quo_act_hdr_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_act_hdr_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_act_hdr_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_act_hdr_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_act_hdr_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_act_hdr_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_act_hdr_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_act_hdr_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_act_hdr_hist.q4x_timestamp is '* Timestamp';
comment on column quo_act_hdr_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_act_hdr_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_act_hdr_hist.task_id is '[Task_ID] Mandatory foreign key to [Task].[Id].';
comment on column quo_act_hdr_hist.task_id_lookup is '[Task_ID_Lookup] ';
comment on column quo_act_hdr_hist.rep_id is '[Rep_ID] Mandatory foreign key to [Rep].[Id].';
comment on column quo_act_hdr_hist.rep_id_lookup is '[Rep_ID_Lookup] ';
comment on column quo_act_hdr_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column quo_act_hdr_hist.is_complete is '[IsComplete] Indicates whether the activity has been completed successfully. 0 indicates False, 1 indicates True. Null indicates that the activity has been started, but more will be done before it is complete.';
comment on column quo_act_hdr_hist.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column quo_act_hdr_hist.duration is '[Duration] How long the task is expected to take to complete.';
comment on column quo_act_hdr_hist.callcard_id is '[Callcard_ID] Foreign key to [CallCard].[Id]. Populated if the rep completed the survey as part of a visit.';
comment on column quo_act_hdr_hist.callcard_id_lookup is '[Callcard_ID_Lookup] ';
comment on column quo_act_hdr_hist.incomplete_reason_id is '[IncompleteReasonID] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_act_hdr_hist.incomplete_reason_id_lookup is '[IncompleteReasonID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_act_hdr_hist.incomplete_reason_id_desc is '[IncompleteReasonID_Description] Default language description of the node';
comment on column quo_act_hdr_hist.note is '[Notes] ';
comment on column quo_act_hdr_hist.task_name is '[TaskName] ';
comment on column quo_act_hdr_hist.due_date is '[DueDate] ';
comment on column quo_act_hdr_hist.full_name is '[FullName] ';
comment on column quo_act_hdr_hist.task_id_desc is '[Task_ID_Description] ';


-- Synonyms
create or replace public synonym quo_act_hdr_hist for ods.quo_act_hdr_hist;

-- Grants
grant select,update,delete,insert on ods.quo_act_hdr_hist to ods_app;
grant select on ods.quo_act_hdr_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
