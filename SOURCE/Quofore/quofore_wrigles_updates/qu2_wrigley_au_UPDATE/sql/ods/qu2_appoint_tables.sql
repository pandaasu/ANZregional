
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu2
    Owner    : ods
    Table    : qu2_appoint
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu2] Quofore - Wrigley Australia
    [qu2_appoint] table creation script _load and _hist

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
drop table ods.qu2_appoint_load cascade constraints;

create table ods.qu2_appoint_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  call_type_id                    number(10, 0)                   null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  pos_id                          number(10, 0)                   null,
  scheduled_date                  date                            null,
  seq                             number(3, 0)                    null,
  start_time                      date                            null,
  cust_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu2_appoint_load add constraint qu2_appoint_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_appoint_load_pk on ods.qu2_appoint_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_appoint_load add constraint qu2_appoint_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_appoint_load_uk on ods.qu2_appoint_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu2_appoint_load is '[Appointment][LOAD] Appointments created before actually making calls.';
comment on column qu2_appoint_load.q4x_load_seq is '* Unique Load Id';
comment on column qu2_appoint_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_appoint_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_appoint_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_appoint_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_appoint_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_appoint_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_appoint_load.q4x_timestamp is '* Timestamp';
comment on column qu2_appoint_load.id is '[ID] Unique Internal ID for the row';
comment on column qu2_appoint_load.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_appoint_load.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column qu2_appoint_load.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu2_appoint_load.pos_id is '[Position_Id] Mandatory foreign key from [Position].[Id].';
comment on column qu2_appoint_load.scheduled_date is '[ScheduledDate] The Date and time of the appointment';
comment on column qu2_appoint_load.seq is '[Sequence] The sequence number of the appointment for this position and date combination.';
comment on column qu2_appoint_load.start_time is '[StartTime] The start time of the appointment if provided.';
comment on column qu2_appoint_load.cust_id_desc is '[Customer_ID_Description] name of the customer';

-- Synonyms
create or replace public synonym qu2_appoint_load for ods.qu2_appoint_load;

-- Grants
grant select,insert,update,delete on ods.qu2_appoint_load to ods_app;
grant select on ods.qu2_appoint_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu2_appoint_hist cascade constraints;

create table ods.qu2_appoint_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  call_type_id                    number(10, 0)                   null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  pos_id                          number(10, 0)                   null,
  scheduled_date                  date                            null,
  seq                             number(3, 0)                    null,
  start_time                      date                            null,
  cust_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu2_appoint_hist add constraint qu2_appoint_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu2_appoint_hist_pk on ods.qu2_appoint_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu2_appoint_hist add constraint qu2_appoint_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu2_appoint_hist_uk on ods.qu2_appoint_hist (id,q4x_batch_id)) compress;

create index ods.qu2_appoint_hist_ts on ods.qu2_appoint_hist (q4x_timestamp) compress;

-- Comments
comment on table qu2_appoint_hist is '[Appointment][HIST] Appointments created before actually making calls.';
comment on column qu2_appoint_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu2_appoint_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu2_appoint_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu2_appoint_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu2_appoint_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu2_appoint_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu2_appoint_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu2_appoint_hist.q4x_timestamp is '* Timestamp';
comment on column qu2_appoint_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu2_appoint_hist.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu2_appoint_hist.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column qu2_appoint_hist.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu2_appoint_hist.pos_id is '[Position_Id] Mandatory foreign key from [Position].[Id].';
comment on column qu2_appoint_hist.scheduled_date is '[ScheduledDate] The Date and time of the appointment';
comment on column qu2_appoint_hist.seq is '[Sequence] The sequence number of the appointment for this position and date combination.';
comment on column qu2_appoint_hist.start_time is '[StartTime] The start time of the appointment if provided.';
comment on column qu2_appoint_hist.cust_id_desc is '[Customer_ID_Description] name of the customer';

-- Synonyms
create or replace public synonym qu2_appoint_hist for ods.qu2_appoint_hist;

-- Grants
grant select,insert,update,delete on ods.qu2_appoint_hist to ods_app;
grant select on ods.qu2_appoint_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
