
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_terr_load
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_terr_load] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_terr_load cascade constraints;

create table ods.quo_terr_load (
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
  note                            varchar2(200 char)              null,
  terr_name                       varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_terr_load add constraint quo_terr_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_terr_load_pk on ods.quo_terr_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_terr_load add constraint quo_terr_load_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_terr_load_uk on ods.quo_terr_load (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_terr_load_ts on ods.quo_terr_load (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_terr_load is '[Territory] Territory master data';
comment on column quo_terr_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_terr_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_terr_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_terr_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_terr_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_terr_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_terr_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_terr_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_terr_load.q4x_timestamp is '* Timestamp';
comment on column quo_terr_load.id is '[ID] Unique Internal ID for the row';
comment on column quo_terr_load.id_lookup is '[ID_Lookup] ';
comment on column quo_terr_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_terr_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_terr_load.note is '[Notes] ';
comment on column quo_terr_load.terr_name is '[TerritoryName] The name of the Territory.';


-- Synonyms
create or replace public synonym quo_terr_load for ods.quo_terr_load;

-- Grants
grant select,update,delete,insert on ods.quo_terr_load to ods_app;
grant select on ods.quo_terr_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
