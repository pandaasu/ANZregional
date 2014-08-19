
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_call_card_note
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_call_card_note] table creation script _load and _hist

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
drop table ods.qu4_call_card_note_load cascade constraints;

create table ods.qu4_call_card_note_load (
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
  call_card_id                    number(10, 0)                   not null,
  note_text                       varchar2(200 char)              null,
  rep_id                          number(10, 0)                   not null,
  full_name                       varchar2(101 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_call_card_note_load add constraint qu4_call_card_note_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_call_card_note_load_pk on ods.qu4_call_card_note_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_call_card_note_load add constraint qu4_call_card_note_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_call_card_note_load_uk on ods.qu4_call_card_note_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_call_card_note_load is '[CallcardNote][LOAD] Notes caputred during a callcard.';
comment on column qu4_call_card_note_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_call_card_note_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_call_card_note_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_call_card_note_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_call_card_note_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_call_card_note_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_call_card_note_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_call_card_note_load.q4x_timestamp is '* Timestamp';
comment on column qu4_call_card_note_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_call_card_note_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu4_call_card_note_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_call_card_note_load.call_card_id is '[Callcard_Id] Foreign key from [CallCard].[Id].';
comment on column qu4_call_card_note_load.note_text is '[NoteText] Text of the note.';
comment on column qu4_call_card_note_load.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu4_call_card_note_load.full_name is '[fullname] Full name of the rep';

-- Synonyms
create or replace public synonym qu4_call_card_note_load for ods.qu4_call_card_note_load;

-- Grants
grant select,insert,update,delete on ods.qu4_call_card_note_load to ods_app;
grant select on ods.qu4_call_card_note_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_call_card_note_hist cascade constraints;

create table ods.qu4_call_card_note_hist (
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
  call_card_id                    number(10, 0)                   not null,
  note_text                       varchar2(200 char)              null,
  rep_id                          number(10, 0)                   not null,
  full_name                       varchar2(101 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_call_card_note_hist add constraint qu4_call_card_note_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_call_card_note_hist_pk on ods.qu4_call_card_note_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_call_card_note_hist add constraint qu4_call_card_note_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_call_card_note_hist_uk on ods.qu4_call_card_note_hist (id,q4x_batch_id)) compress;

create index ods.qu4_call_card_note_hist_ts on ods.qu4_call_card_note_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_call_card_note_hist is '[CallcardNote][HIST] Notes caputred during a callcard.';
comment on column qu4_call_card_note_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_call_card_note_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_call_card_note_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_call_card_note_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_call_card_note_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_call_card_note_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_call_card_note_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_call_card_note_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_call_card_note_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_call_card_note_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu4_call_card_note_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu4_call_card_note_hist.call_card_id is '[Callcard_Id] Foreign key from [CallCard].[Id].';
comment on column qu4_call_card_note_hist.note_text is '[NoteText] Text of the note.';
comment on column qu4_call_card_note_hist.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu4_call_card_note_hist.full_name is '[fullname] Full name of the rep';

-- Synonyms
create or replace public synonym qu4_call_card_note_hist for ods.qu4_call_card_note_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_call_card_note_hist to ods_app;
grant select on ods.qu4_call_card_note_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
