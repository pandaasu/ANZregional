
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_callcard
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_callcard] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_callcard cascade constraints;

create table ods.quo_callcard (
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
  created_date                    date                            null,
  appoint_id                      number(10, 0)                   null,
  appoint_id_lookup               varchar2(50 char)               null,
  call_type_id                    number(10, 0)                   null,
  call_type_id_lookup             varchar2(50 char)               null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  varchar2(50 char)               null,
  duration                        date                            null,
  pos_id                          number(10, 0)                   null,
  pos_id_lookup                   varchar2(50 char)               null,
  rep_id                          number(10, 0)                   null,
  rep_id_lookup                   varchar2(50 char)               null,
  signature_id                    number(10, 0)                   null,
  signature_id_lookup             varchar2(50 char)               null,
  start_date                      date                            null,
  id_lookup                       number(10, 0)                   null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  work_with_day_id                number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_callcard add constraint quo_callcard_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_callcard_pk on ods.quo_callcard (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_callcard add constraint quo_callcard_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_callcard_uk on ods.quo_callcard (q4x_source_id,id)) compress;

create index ods.quo_callcard_ts on ods.quo_callcard (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_callcard is '[CallCard] Callcard transactional data';
comment on column quo_callcard.q4x_load_seq is '* Unique Load Id';
comment on column quo_callcard.q4x_load_data_seq is '* Data Record Id';
comment on column quo_callcard.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_callcard.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_callcard.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_callcard.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_callcard.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_callcard.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_callcard.q4x_timestamp is '* Timestamp';
comment on column quo_callcard.id is '[ID] Unique Internal ID for the row';
comment on column quo_callcard.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_callcard.appoint_id is '[Appointment_Id] ';
comment on column quo_callcard.appoint_id_lookup is '[Appointment_Id_Lookup] ';
comment on column quo_callcard.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_callcard.call_type_id_lookup is '[CallTypeId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_callcard.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column quo_callcard.cust_id is '[Customer_Id] Mandatory Foreign key to the Id of the Customer';
comment on column quo_callcard.cust_id_lookup is '[Customer_Id_Lookup] ';
comment on column quo_callcard.duration is '[Duration] How long the task is expected to take to complete.';
comment on column quo_callcard.pos_id is '[Position_Id] Mandatory foreign key to [Position].[Id].';
comment on column quo_callcard.pos_id_lookup is '[Position_Id_Lookup] ';
comment on column quo_callcard.rep_id is '[Rep_Id] Mandatory foreign key to [Rep].[Id].';
comment on column quo_callcard.rep_id_lookup is '[Rep_Id_Lookup] ';
comment on column quo_callcard.signature_id is '[Signature_Id] ';
comment on column quo_callcard.signature_id_lookup is '[Signature_Id_Lookup] ';
comment on column quo_callcard.start_date is '[StartDate] The date the Task should start to be executed.';
comment on column quo_callcard.id_lookup is '[ID_Lookup] ';
comment on column quo_callcard.cust_id_desc is '[customer_id_description] name of the customer';
comment on column quo_callcard.full_name is '[fullname] Full name of the rep';
comment on column quo_callcard.work_with_day_id is '[WorkWithDayID] To find the LookupList and LookupListItem for WorkWithDay List.<\n>This is a list based extended attribute of Callcard.';


-- Synonyms
create or replace public synonym quo_callcard for ods.quo_callcard;

-- Grants
grant select,update,delete,insert on ods.quo_callcard to ods_app;
grant select on ods.quo_callcard to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
