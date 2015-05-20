
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_act_hdr
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_act_hdr] table creation script _load and _hist

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
drop table ods.qu5_act_hdr_load cascade constraints;

create table ods.qu5_act_hdr_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  task_id                         number(10, 0)                   not null,
  rep_id                          number(10, 0)                   not null,
  start_date                      date                            null,
  is_complete                     number(1, 0)                    null,
  end_date                        date                            null,
  callcard_id                     number(10, 0)                   null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  notes                           varchar2(200 char)              null,
  due_date                        date                            null,
  full_name                       varchar2(101 char)              null,
  task_id_desc                    varchar2(200 char)              null,
  comments                        varchar2(100 char)              null,
  is_display_in_store             number(10, 0)                   null,
  is_display_to_gold_std          number(10, 0)                   null,
  displays_qty                    number(10, 0)                   null,
  is_gwp_allocation_received      number(10, 0)                   null,
  have_demo_in_store              number(10, 0)                   null,
  have_display_in_store           number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_act_hdr_load add constraint qu5_act_hdr_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_act_hdr_load_pk on ods.qu5_act_hdr_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_act_hdr_load add constraint qu5_act_hdr_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_act_hdr_load_uk on ods.qu5_act_hdr_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_act_hdr_load is '[ActivityHeader][LOAD] Header file for ALL the tasks transactional data. Each task instance has a separate detail file.  Captures Display Task Information, Sampling Tasks and Gift With Purchase';
comment on column qu5_act_hdr_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_act_hdr_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_act_hdr_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_act_hdr_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_act_hdr_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_act_hdr_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_act_hdr_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_act_hdr_load.q4x_timestamp is '* Timestamp';
comment on column qu5_act_hdr_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_act_hdr_load.task_id is '[Task_Id] Mandatory foreign key from [Task].[Id].';
comment on column qu5_act_hdr_load.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu5_act_hdr_load.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu5_act_hdr_load.is_complete is '[IsComplete] Indicates whether the activity has been completed successfully. 0 indicates False, 1 indicates True. Null indicates that the activity has been started, but more will be done before it is complete.';
comment on column qu5_act_hdr_load.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu5_act_hdr_load.callcard_id is '[Callcard_Id] Foreign Key to [CallCard].[Id]';
comment on column qu5_act_hdr_load.incomplete_reason_id is '[IncompleteReasonId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu5_act_hdr_load.incomplete_reason_id_desc is '[IncompleteReasonId_Description] Default language description of the node';
comment on column qu5_act_hdr_load.notes is '[Notes] Notes of the ActivityHeader';
comment on column qu5_act_hdr_load.due_date is '[DueDate] When the ActivityHeader was Due in the System';
comment on column qu5_act_hdr_load.full_name is '[FullName] Full name of the rep';
comment on column qu5_act_hdr_load.task_id_desc is '[Task_Id_Description] Task Id Description of the ActivityHeader';
comment on column qu5_act_hdr_load.comments is '[Comments] Comments of Task';
comment on column qu5_act_hdr_load.is_display_in_store is '[DIS_DispInStore] Used for Task Displays.  Matches Question "Is the display in store?"';
comment on column qu5_act_hdr_load.is_display_to_gold_std is '[DIS_DispToGoldStd] Used for Task Displays.  Matches Question "Is the Display to Gold Standard"';
comment on column qu5_act_hdr_load.displays_qty is '[DIS_NoOfDisplays] Used for Task Displays.   Matches Question "How many displays?"';
comment on column qu5_act_hdr_load.is_gwp_allocation_received is '[GWP_AllocationReceived] Used for Gift With Purchase Tasks.   Matches Question "Has the Store Received their GWP Allocation?"';
comment on column qu5_act_hdr_load.have_demo_in_store is '[SA_Demo] Used with Sampling Tasks.  Matches Question"Do you have a demo in store?"';
comment on column qu5_act_hdr_load.have_display_in_store is '[SA_Display] Used with Sampling Tasks.  Matches Question "Do you have a display in store?"';

-- Synonyms
create or replace public synonym qu5_act_hdr_load for ods.qu5_act_hdr_load;

-- Grants
grant select,insert,update,delete on ods.qu5_act_hdr_load to ods_app;
grant select on ods.qu5_act_hdr_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_act_hdr_hist cascade constraints;

create table ods.qu5_act_hdr_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  task_id                         number(10, 0)                   not null,
  rep_id                          number(10, 0)                   not null,
  start_date                      date                            null,
  is_complete                     number(1, 0)                    null,
  end_date                        date                            null,
  callcard_id                     number(10, 0)                   null,
  incomplete_reason_id            number(10, 0)                   null,
  incomplete_reason_id_desc       varchar2(50 char)               null,
  notes                           varchar2(200 char)              null,
  due_date                        date                            null,
  full_name                       varchar2(101 char)              null,
  task_id_desc                    varchar2(200 char)              null,
  comments                        varchar2(100 char)              null,
  is_display_in_store             number(10, 0)                   null,
  is_display_to_gold_std          number(10, 0)                   null,
  displays_qty                    number(10, 0)                   null,
  is_gwp_allocation_received      number(10, 0)                   null,
  have_demo_in_store              number(10, 0)                   null,
  have_display_in_store           number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_act_hdr_hist add constraint qu5_act_hdr_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_act_hdr_hist_pk on ods.qu5_act_hdr_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_act_hdr_hist add constraint qu5_act_hdr_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_act_hdr_hist_uk on ods.qu5_act_hdr_hist (id,q4x_batch_id)) compress;

create index ods.qu5_act_hdr_hist_ts on ods.qu5_act_hdr_hist (q4x_timestamp) compress;

create index ods.qu5_act_hdr_hist_sd on ods.qu5_act_hdr_hist (start_date) compress;

-- Comments
comment on table qu5_act_hdr_hist is '[ActivityHeader][HIST] Header file for ALL the tasks transactional data. Each task instance has a separate detail file.  Captures Display Task Information, Sampling Tasks and Gift With Purchase';
comment on column qu5_act_hdr_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_act_hdr_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_act_hdr_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_act_hdr_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_act_hdr_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_act_hdr_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_act_hdr_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_act_hdr_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_act_hdr_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_act_hdr_hist.task_id is '[Task_Id] Mandatory foreign key from [Task].[Id].';
comment on column qu5_act_hdr_hist.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu5_act_hdr_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu5_act_hdr_hist.is_complete is '[IsComplete] Indicates whether the activity has been completed successfully. 0 indicates False, 1 indicates True. Null indicates that the activity has been started, but more will be done before it is complete.';
comment on column qu5_act_hdr_hist.end_date is '[EndDate] The last date on which the task should be executed.';
comment on column qu5_act_hdr_hist.callcard_id is '[Callcard_Id] Foreign Key to [CallCard].[Id]';
comment on column qu5_act_hdr_hist.incomplete_reason_id is '[IncompleteReasonId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu5_act_hdr_hist.incomplete_reason_id_desc is '[IncompleteReasonId_Description] Default language description of the node';
comment on column qu5_act_hdr_hist.notes is '[Notes] Notes of the ActivityHeader';
comment on column qu5_act_hdr_hist.due_date is '[DueDate] When the ActivityHeader was Due in the System';
comment on column qu5_act_hdr_hist.full_name is '[FullName] Full name of the rep';
comment on column qu5_act_hdr_hist.task_id_desc is '[Task_Id_Description] Task Id Description of the ActivityHeader';
comment on column qu5_act_hdr_hist.comments is '[Comments] Comments of Task';
comment on column qu5_act_hdr_hist.is_display_in_store is '[DIS_DispInStore] Used for Task Displays.  Matches Question "Is the display in store?"';
comment on column qu5_act_hdr_hist.is_display_to_gold_std is '[DIS_DispToGoldStd] Used for Task Displays.  Matches Question "Is the Display to Gold Standard"';
comment on column qu5_act_hdr_hist.displays_qty is '[DIS_NoOfDisplays] Used for Task Displays.   Matches Question "How many displays?"';
comment on column qu5_act_hdr_hist.is_gwp_allocation_received is '[GWP_AllocationReceived] Used for Gift With Purchase Tasks.   Matches Question "Has the Store Received their GWP Allocation?"';
comment on column qu5_act_hdr_hist.have_demo_in_store is '[SA_Demo] Used with Sampling Tasks.  Matches Question"Do you have a demo in store?"';
comment on column qu5_act_hdr_hist.have_display_in_store is '[SA_Display] Used with Sampling Tasks.  Matches Question "Do you have a display in store?"';

-- Synonyms
create or replace public synonym qu5_act_hdr_hist for ods.qu5_act_hdr_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_act_hdr_hist to ods_app;
grant select on ods.qu5_act_hdr_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
