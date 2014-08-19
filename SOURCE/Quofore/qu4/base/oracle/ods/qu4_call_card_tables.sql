
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_call_card
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_call_card] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu4_call_card_load cascade constraints;

create table ods.qu4_call_card_load (
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
  appointment_id                  number(10, 0)                   null,
  call_type_id                    number(10, 0)                   null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   not null,
  duration                        date                            null,
  pos_id                          number(10, 0)                   not null,
  pos_id_lookup                   varchar2(50 char)               null,
  rep_id                          number(10, 0)                   not null,
  start_date                      date                            null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  terr_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_call_card_load add constraint qu4_call_card_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_call_card_load_pk on ods.qu4_call_card_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_call_card_load add constraint qu4_call_card_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_call_card_load_uk on ods.qu4_call_card_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_call_card_load is '[CallCard][LOAD] Callcard transactional data.';
comment on column qu4_call_card_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_call_card_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_call_card_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_call_card_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_call_card_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_call_card_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_call_card_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_call_card_load.q4x_timestamp is '* Timestamp';
comment on column qu4_call_card_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_call_card_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_call_card_load.appointment_id is '[Appointment_Id] ';
comment on column qu4_call_card_load.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_call_card_load.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column qu4_call_card_load.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu4_call_card_load.duration is '[Duration] How long the task is expected to take to complete.';
comment on column qu4_call_card_load.pos_id is '[Position_Id] Mandatory foreign key from [Position].[Id].';
comment on column qu4_call_card_load.pos_id_lookup is '[Position_Id_Lookup] ';
comment on column qu4_call_card_load.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu4_call_card_load.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu4_call_card_load.cust_id_desc is '[Customer_ID_Description] name of the customer';
comment on column qu4_call_card_load.full_name is '[FullName] Full name of the rep';
comment on column qu4_call_card_load.terr_id is '[Territory_ID] ID of Territory';

-- Synonyms
create or replace public synonym qu4_call_card_load for ods.qu4_call_card_load;

-- Grants
grant select,insert,update,delete on ods.qu4_call_card_load to ods_app;
grant select on ods.qu4_call_card_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_call_card_hist cascade constraints;

create table ods.qu4_call_card_hist (
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
  appointment_id                  number(10, 0)                   null,
  call_type_id                    number(10, 0)                   null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   not null,
  duration                        date                            null,
  pos_id                          number(10, 0)                   not null,
  pos_id_lookup                   varchar2(50 char)               null,
  rep_id                          number(10, 0)                   not null,
  start_date                      date                            null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  terr_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_call_card_hist add constraint qu4_call_card_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_call_card_hist_pk on ods.qu4_call_card_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_call_card_hist add constraint qu4_call_card_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_call_card_hist_uk on ods.qu4_call_card_hist (id,q4x_batch_id)) compress;

create index ods.qu4_call_card_hist_ts on ods.qu4_call_card_hist (q4x_timestamp) compress;

create index ods.qu4_call_card_hist_sd on ods.qu4_call_card_hist (start_date) compress;

-- Comments
comment on table qu4_call_card_hist is '[CallCard][HIST] Callcard transactional data.';
comment on column qu4_call_card_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_call_card_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_call_card_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_call_card_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_call_card_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_call_card_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_call_card_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_call_card_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_call_card_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_call_card_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_call_card_hist.appointment_id is '[Appointment_Id] ';
comment on column qu4_call_card_hist.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_call_card_hist.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column qu4_call_card_hist.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu4_call_card_hist.duration is '[Duration] How long the task is expected to take to complete.';
comment on column qu4_call_card_hist.pos_id is '[Position_Id] Mandatory foreign key from [Position].[Id].';
comment on column qu4_call_card_hist.pos_id_lookup is '[Position_Id_Lookup] ';
comment on column qu4_call_card_hist.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu4_call_card_hist.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column qu4_call_card_hist.cust_id_desc is '[Customer_ID_Description] name of the customer';
comment on column qu4_call_card_hist.full_name is '[FullName] Full name of the rep';
comment on column qu4_call_card_hist.terr_id is '[Territory_ID] ID of Territory';

-- Synonyms
create or replace public synonym qu4_call_card_hist for ods.qu4_call_card_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_call_card_hist to ods_app;
grant select on ods.qu4_call_card_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
