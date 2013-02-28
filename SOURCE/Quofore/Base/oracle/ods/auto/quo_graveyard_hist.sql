
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_graveyard_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_graveyard_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_graveyard_hist cascade constraints;

create table ods.quo_graveyard_hist (
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
  entity                          varchar2(50 char)               not null,
  unique_id                       varchar2(100 char)              null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_graveyard_hist add constraint quo_graveyard_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_graveyard_hist_pk on ods.quo_graveyard_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_graveyard_hist add constraint quo_graveyard_hist_uk unique (q4x_source_id,id,entity,q4x_batch_id)
  using index (create unique index ods.quo_graveyard_hist_uk on ods.quo_graveyard_hist (q4x_source_id,id,entity,q4x_batch_id)) compress;

create index ods.quo_graveyard_hist_ts on ods.quo_graveyard_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_graveyard_hist is '[Graveyard] File that contains information on the records to delete for each entity.<\n>Deletion can be specified for entities which have primary key comprising of up to 2 columns.';
comment on column quo_graveyard_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_graveyard_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_graveyard_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_graveyard_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_graveyard_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_graveyard_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_graveyard_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_graveyard_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_graveyard_hist.q4x_timestamp is '* Timestamp';
comment on column quo_graveyard_hist.id is '[ID] Internal ID for the row of entity. Unique within an entity but can be repeated for different entities.';
comment on column quo_graveyard_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_graveyard_hist.entity is '[Entity] Name of the entity where deletion needs to be done e.g. CustomerTerritory';
comment on column quo_graveyard_hist.unique_id is '[UniqueID] Computed field for internal use only (it''s just a concatenation of Entity and ID fields). You may also use this as Primary Key';


-- Synonyms
create or replace public synonym quo_graveyard_hist for ods.quo_graveyard_hist;

-- Grants
grant select,update,delete,insert on ods.quo_graveyard_hist to ods_app;
grant select on ods.quo_graveyard_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
