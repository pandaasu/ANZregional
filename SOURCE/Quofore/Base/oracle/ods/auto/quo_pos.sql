
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_pos
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_pos] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_pos cascade constraints;

create table ods.quo_pos (
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
  is_active                       number(1, 0)                    null,
  pos_name                        varchar2(50 char)               null,
  id_lookup                       varchar2(50 char)               null,
  role_name                       varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_pos add constraint quo_pos_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_pos_pk on ods.quo_pos (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_pos add constraint quo_pos_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_pos_uk on ods.quo_pos (q4x_source_id,id)) compress;

create index ods.quo_pos_ts on ods.quo_pos (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_pos is '[Position] Position master data. Various assignments are done at position level and then positions are assigned to reps.';
comment on column quo_pos.q4x_load_seq is '* Unique Load Id';
comment on column quo_pos.q4x_load_data_seq is '* Data Record Id';
comment on column quo_pos.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_pos.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_pos.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_pos.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_pos.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_pos.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_pos.q4x_timestamp is '* Timestamp';
comment on column quo_pos.id is '[id] Unique Internal ID for the row';
comment on column quo_pos.is_active is '[isactive] ';
comment on column quo_pos.pos_name is '[positionname] ';
comment on column quo_pos.id_lookup is '[id_lookup] ';
comment on column quo_pos.role_name is '[rolename] ';


-- Synonyms
create or replace public synonym quo_pos for ods.quo_pos;

-- Grants
grant select,update,delete,insert on ods.quo_pos to ods_app;
grant select on ods.quo_pos to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
