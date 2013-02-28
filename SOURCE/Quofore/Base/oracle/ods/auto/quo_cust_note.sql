
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_cust_note
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_cust_note] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_cust_note cascade constraints;

create table ods.quo_cust_note (
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
  created_date                    date                            null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  varchar2(50 char)               null,
  is_active                       number(1, 0)                    null,
  note_text                       varchar2(200 char)              null,
  rep_id                          number(10, 0)                   null,
  rep_id_lookup                   varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_cust_note add constraint quo_cust_note_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_cust_note_pk on ods.quo_cust_note (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_cust_note add constraint quo_cust_note_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_cust_note_uk on ods.quo_cust_note (q4x_source_id,id)) compress;

create index ods.quo_cust_note_ts on ods.quo_cust_note (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_cust_note is '[CustomerNote] Child file of customer. Contains multiple notes for a customer.';
comment on column quo_cust_note.q4x_load_seq is '* Unique Load Id';
comment on column quo_cust_note.q4x_load_data_seq is '* Data Record Id';
comment on column quo_cust_note.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_cust_note.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_cust_note.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_cust_note.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_cust_note.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_cust_note.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_cust_note.q4x_timestamp is '* Timestamp';
comment on column quo_cust_note.id is '[ID] Unique Internal ID for the row';
comment on column quo_cust_note.id_lookup is '[ID_Lookup] ';
comment on column quo_cust_note.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_cust_note.cust_id is '[Customer_Id] Mandatory Foreign key to the Id of the Customer';
comment on column quo_cust_note.cust_id_lookup is '[Customer_Id_Lookup] ';
comment on column quo_cust_note.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_cust_note.note_text is '[NoteText] Text of the note.';
comment on column quo_cust_note.rep_id is '[Rep_Id] Mandatory foreign key to [Rep].[Id].';
comment on column quo_cust_note.rep_id_lookup is '[Rep_Id_Lookup] ';
comment on column quo_cust_note.cust_id_desc is '[Customer_ID_Description] Name of customer';
comment on column quo_cust_note.full_name is '[Fullname] Name of Rep';


-- Synonyms
create or replace public synonym quo_cust_note for ods.quo_cust_note;

-- Grants
grant select,update,delete,insert on ods.quo_cust_note to ods_app;
grant select on ods.quo_cust_note to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
