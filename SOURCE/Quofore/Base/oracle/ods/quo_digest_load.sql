/*******************************************************************************
/* Table Definition
/*******************************************************************************

 System : quo
 Table  : quo_digest_load
 Owner  : ods
 Author : Mal Chambeyron

 Description
 -------------------------------------------------------------------------------
 Digest

 YYYY-MM-DD   Author                 Description
 ----------   --------------------   -------------------------------------------
 2012-02-19   Mal Chambeyron         [Auto-Generated] Created

*******************************************************************************/

-- Table 
drop table ods.quo_digest_load cascade constraints;

create table ods.quo_digest_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_source_id                   number(4)                       not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  entity_name                     varchar2(32 char)               not null,
  file_name                       varchar2(512 char)              not null,
  row_count                       number(10)                      not null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys
alter table ods.quo_digest_load add constraint quo_digest_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_digest_load_pk on ods.quo_digest_load(q4x_load_seq,q4x_load_data_seq));

alter table ods.quo_digest_load add constraint quo_digest_load_uk unique (q4x_source_id,entity_name,q4x_batch_id)
  using index (create unique index ods.quo_digest_load_uk on ods.quo_digest_load(q4x_source_id,entity_name,q4x_batch_id));

-- Checks
alter table ods.quo_digest_load add constraint quo_digest_load_entity_ck check (entity_name = upper(entity_name));  

-- Comments
comment on table quo_digest_load is '[Digets] Batch Digest';
comment on column quo_digest_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_digest_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_digest_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_digest_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_digest_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_digest_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_digest_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_digest_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_digest_load.q4x_timestamp is '* Timestamp';
comment on column quo_digest_load.entity_name is 'Entity Name - MUST BE UPPERCASE';
comment on column quo_digest_load.file_name is 'File Name';
comment on column quo_digest_load.row_count is 'Row Count';

-- Synonyms
create or replace public synonym quo_digest_load for ods.quo_digest_load;

-- Grants
grant select,update,delete,insert on ods.quo_digest_load to ods_app;
grant select on ods.quo_digest_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
