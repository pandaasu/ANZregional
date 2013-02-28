
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_act_dtl_sos_spc_load
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_act_dtl_sos_spc_load] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_act_dtl_sos_spc_load cascade constraints;

create table ods.quo_act_dtl_sos_spc_load (
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
  act_id                          number(10, 0)                   null,
  act_id_lookup                   varchar2(50 char)               null,
  sos_advance_modules             number(18, 4)                   null,
  sos_eukanuba_modules            number(18, 4)                   null,
  sos_hills_modules               number(18, 4)                   null,
  sos_royalcanine_modules         number(18, 4)                   null,
  sos_proplan_modules             number(18, 4)                   null,
  sos_nutro_modules               number(18, 4)                   null,
  sos_other_natural_modules       number(18, 4)                   null,
  sos_mars_core_modules           number(18, 4)                   null,
  sos_other_modules               number(18, 4)                   null,
  prod_hier_id                    number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_act_dtl_sos_spc_load add constraint quo_act_dtl_sos_spc_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_act_dtl_sos_spc_load_pk on ods.quo_act_dtl_sos_spc_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_act_dtl_sos_spc_load add constraint quo_act_dtl_sos_spc_load_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_act_dtl_sos_spc_load_uk on ods.quo_act_dtl_sos_spc_load (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_act_dtl_sos_spc_load_ts on ods.quo_act_dtl_sos_spc_load (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_act_dtl_sos_spc_load is '[ActivityDetail_SoSSPC] Detail file for share of shelf specialst task captured at product hierarchy level.';
comment on column quo_act_dtl_sos_spc_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_act_dtl_sos_spc_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_act_dtl_sos_spc_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_act_dtl_sos_spc_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_act_dtl_sos_spc_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_act_dtl_sos_spc_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_act_dtl_sos_spc_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_act_dtl_sos_spc_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_act_dtl_sos_spc_load.q4x_timestamp is '* Timestamp';
comment on column quo_act_dtl_sos_spc_load.id is '[ID] Unique Internal ID for the row';
comment on column quo_act_dtl_sos_spc_load.id_lookup is '[ID_Lookup] ';
comment on column quo_act_dtl_sos_spc_load.act_id is '[Activity_ID] Mandatory foreign key to [ActivityHeader].[Id].';
comment on column quo_act_dtl_sos_spc_load.act_id_lookup is '[Activity_ID_Lookup] ';
comment on column quo_act_dtl_sos_spc_load.sos_advance_modules is '[SOS_AdvanceModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_eukanuba_modules is '[SOS_EukanubaModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_hills_modules is '[SOS_HillsModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_royalcanine_modules is '[SOS_RoyalCanineModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_proplan_modules is '[SOS_ProplanModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_nutro_modules is '[SOS_NutroModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_other_natural_modules is '[SOS_OtherNaturalModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_mars_core_modules is '[SOS_MarsCoreModules] ';
comment on column quo_act_dtl_sos_spc_load.sos_other_modules is '[SOS_OtherModules] ';
comment on column quo_act_dtl_sos_spc_load.prod_hier_id is '[ProductHierarchy_Hierarchy_ID] There''s only one product hierarchy i.e. ProductHierarchy. This is ID of a node of ProductHierarchy.';


-- Synonyms
create or replace public synonym quo_act_dtl_sos_spc_load for ods.quo_act_dtl_sos_spc_load;

-- Grants
grant select,update,delete,insert on ods.quo_act_dtl_sos_spc_load to ods_app;
grant select on ods.quo_act_dtl_sos_spc_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
