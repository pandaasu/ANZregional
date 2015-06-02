
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_callcard
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_callcard] table creation script _load and _hist

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
drop table ods.qu2_callcard_load cascade constraints;

create table ods.qu2_callcard_load (
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
  appoint_id                      number(10, 0)                   null,
  call_type_id                    number(10, 0)                   null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  duration                        date                            null,
  pos_id                          number(10, 0)                   null,
  pos_id_lookup                   varchar2(50 char)               null,
  rep_id                          number(10, 0)                   null,
  start_date                      date                            null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  auto_stocker_chk                number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu2_callcard_load add constraint qu2_callcard_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_callcard_load_pk on ods.qu2_callcard_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_callcard_load add constraint qu2_callcard_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_callcard_load_uk on ods.qu2_callcard_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_callcard_load is '[CallCard][LOAD] Callcard transactional data.';
comment on column qu2_callcard_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_callcard_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_callcard_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_callcard_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_callcard_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_callcard_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_callcard_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_callcard_load.q4x_timestamp is '* Timestamp';
comment on column qu2_callcard_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_callcard_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu2_callcard_load.appoint_id is '[Appointment_Id] ';
comment on column qu2_callcard_load.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_callcard_load.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column qu2_callcard_load.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu2_callcard_load.duration is '[Duration] How long the task is expected to take to complete.';
comment on column qu2_callcard_load.pos_id is '[Position_Id] Mandatory foreign key from [Position].[Id].';
comment on column qu2_callcard_load.pos_id_lookup is '[Position_Id_Lookup] ';
comment on column qu2_callcard_load.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu2_callcard_load.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu2_callcard_load.cust_id_desc is '[Customer_ID_Description] name of the customer';
comment on column qu2_callcard_load.full_name is '[FullName] Full name of the rep';
comment on column qu2_callcard_load.auto_stocker_chk is '[AutostockerChk] indicates if the autostocker or store replenishment system was calibrated';

-- Synonyms
create or replace public synonym qu2_callcard_load for ods.qu2_callcard_load;

-- Grants
grant select,insert,update,delete on ods.qu2_callcard_load to ods_app;
grant select on ods.qu2_callcard_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_callcard_hist cascade constraints;

create table ods.qu2_callcard_hist (
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
  appoint_id                      number(10, 0)                   null,
  call_type_id                    number(10, 0)                   null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  duration                        date                            null,
  pos_id                          number(10, 0)                   null,
  pos_id_lookup                   varchar2(50 char)               null,
  rep_id                          number(10, 0)                   null,
  start_date                      date                            null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  auto_stocker_chk                number(1, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu2_callcard_hist add constraint qu2_callcard_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_callcard_hist_pk on ods.qu2_callcard_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_callcard_hist add constraint qu2_callcard_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_callcard_hist_uk on ods.qu2_callcard_hist (id,q4x_batch_id)) compress;

create index ods.qu2_callcard_hist_ts on ods.qu2_callcard_hist (q4x_timestamp) compress;

create index ods.qu2_callcard_hist_sd on ods.qu2_callcard_hist (start_date) compress;

-- Comments
comment on table qu2_callcard_hist is '[CallCard][HIST] Callcard transactional data.';
comment on column qu2_callcard_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_callcard_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_callcard_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_callcard_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_callcard_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_callcard_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_callcard_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_callcard_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_callcard_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_callcard_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu2_callcard_hist.appoint_id is '[Appointment_Id] ';
comment on column qu2_callcard_hist.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_callcard_hist.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column qu2_callcard_hist.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu2_callcard_hist.duration is '[Duration] How long the task is expected to take to complete.';
comment on column qu2_callcard_hist.pos_id is '[Position_Id] Mandatory foreign key from [Position].[Id].';
comment on column qu2_callcard_hist.pos_id_lookup is '[Position_Id_Lookup] ';
comment on column qu2_callcard_hist.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu2_callcard_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu2_callcard_hist.cust_id_desc is '[Customer_ID_Description] name of the customer';
comment on column qu2_callcard_hist.full_name is '[FullName] Full name of the rep';
comment on column qu2_callcard_hist.auto_stocker_chk is '[AutostockerChk] indicates if the autostocker or store replenishment system was calibrated';

-- Synonyms
create or replace public synonym qu2_callcard_hist for ods.qu2_callcard_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_callcard_hist to ods_app;
grant select on ods.qu2_callcard_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
