
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_appoint_load
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_appoint_load] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_appoint_load cascade constraints;

create table ods.quo_appoint_load (
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
  call_type_id                    number(10, 0)                   null,
  call_type_id_lookup             varchar2(50 char)               null,
  call_type_id_desc               varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  varchar2(50 char)               null,
  pos_id                          number(10, 0)                   null,
  pos_id_lookup                   varchar2(50 char)               null,
  scheduled_date                  date                            null,
  seq                             number(3, 0)                    null,
  start_time                      date                            null,
  work_with_day_id                number(10, 0)                   null,
  work_with_day_id_lookup         varchar2(50 char)               null,
  work_with_day_id_desc           varchar2(50 char)               null,
  id_lookup                       varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_appoint_load add constraint quo_appoint_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_appoint_load_pk on ods.quo_appoint_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_appoint_load add constraint quo_appoint_load_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_appoint_load_uk on ods.quo_appoint_load (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_appoint_load_ts on ods.quo_appoint_load (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_appoint_load is '[Appointment] Appointments created before actually making calls';
comment on column quo_appoint_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_appoint_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_appoint_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_appoint_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_appoint_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_appoint_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_appoint_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_appoint_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_appoint_load.q4x_timestamp is '* Timestamp';
comment on column quo_appoint_load.id is '[ID] Unique Internal ID for the row';
comment on column quo_appoint_load.call_type_id is '[CallTypeId] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_appoint_load.call_type_id_lookup is '[CallTypeId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_appoint_load.call_type_id_desc is '[CallTypeId_Description] Default language description of the node';
comment on column quo_appoint_load.cust_id is '[Customer_Id] Mandatory Foreign key to the Id of the Customer';
comment on column quo_appoint_load.cust_id_lookup is '[Customer_Id_Lookup] ';
comment on column quo_appoint_load.pos_id is '[Position_Id] Mandatory foreign key to [Position].[Id].';
comment on column quo_appoint_load.pos_id_lookup is '[Position_Id_Lookup] ';
comment on column quo_appoint_load.scheduled_date is '[ScheduledDate] The Date and time of the appointment';
comment on column quo_appoint_load.seq is '[Sequence] The sequence number of the appointment for this position and date combination.';
comment on column quo_appoint_load.start_time is '[StartTime] The start time of the appointment if provided.';
comment on column quo_appoint_load.work_with_day_id is '[WorkWithDayID] To find the LookupList and LookupListItem for WorkWithDay List.';
comment on column quo_appoint_load.work_with_day_id_lookup is '[WorkWithDayID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_appoint_load.work_with_day_id_desc is '[WorkWithDayID_Description] Default language description of the node';
comment on column quo_appoint_load.id_lookup is '[Id_Lookup] ';
comment on column quo_appoint_load.cust_id_desc is '[Customer_ID_Description] name of the customer';


-- Synonyms
create or replace public synonym quo_appoint_load for ods.quo_appoint_load;

-- Grants
grant select,update,delete,insert on ods.quo_appoint_load to ods_app;
grant select on ods.quo_appoint_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
