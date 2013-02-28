
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_act_dtl_soc_spc
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_act_dtl_soc_spc] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_act_dtl_soc_spc cascade constraints;

create table ods.quo_act_dtl_soc_spc (
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
  soc_eukanuba_pods               number(18, 4)                   null,
  soc_hills_pods                  number(18, 4)                   null,
  soc_royalcanine_pods            number(18, 4)                   null,
  soc_proplan_pods                number(18, 4)                   null,
  soc_other_natural_pods          number(18, 4)                   null,
  soc_other_pods                  number(18, 4)                   null,
  prod_hier_id                    number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_act_dtl_soc_spc add constraint quo_act_dtl_soc_spc_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_act_dtl_soc_spc_pk on ods.quo_act_dtl_soc_spc (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_act_dtl_soc_spc add constraint quo_act_dtl_soc_spc_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_act_dtl_soc_spc_uk on ods.quo_act_dtl_soc_spc (q4x_source_id,id)) compress;

create index ods.quo_act_dtl_soc_spc_ts on ods.quo_act_dtl_soc_spc (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_act_dtl_soc_spc is '[ActivityDetail_SoCSPC] Detail file for share of choice specialist task captured at product hierarchy level.';
comment on column quo_act_dtl_soc_spc.q4x_load_seq is '* Unique Load Id';
comment on column quo_act_dtl_soc_spc.q4x_load_data_seq is '* Data Record Id';
comment on column quo_act_dtl_soc_spc.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_act_dtl_soc_spc.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_act_dtl_soc_spc.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_act_dtl_soc_spc.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_act_dtl_soc_spc.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_act_dtl_soc_spc.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_act_dtl_soc_spc.q4x_timestamp is '* Timestamp';
comment on column quo_act_dtl_soc_spc.id is '[ID] Unique Internal ID for the row';
comment on column quo_act_dtl_soc_spc.id_lookup is '[ID_Lookup] ';
comment on column quo_act_dtl_soc_spc.act_id is '[Activity_ID] Mandatory foreign key to [ActivityHeader].[Id].';
comment on column quo_act_dtl_soc_spc.act_id_lookup is '[Activity_ID_Lookup] ';
comment on column quo_act_dtl_soc_spc.soc_eukanuba_pods is '[SOC_EukanubaPODs] ';
comment on column quo_act_dtl_soc_spc.soc_hills_pods is '[SOC_HillsPODs] ';
comment on column quo_act_dtl_soc_spc.soc_royalcanine_pods is '[SOC_RoyalCaninePODs] ';
comment on column quo_act_dtl_soc_spc.soc_proplan_pods is '[SOC_ProplanPODs] ';
comment on column quo_act_dtl_soc_spc.soc_other_natural_pods is '[SOC_OtherNaturalPODs] ';
comment on column quo_act_dtl_soc_spc.soc_other_pods is '[SOC_OtherPODs] ';
comment on column quo_act_dtl_soc_spc.prod_hier_id is '[ProductHierarchy_Hierarchy_ID] There''s only one product hierarchy i.e. ProductHierarchy. This is ID of a node of ProductHierarchy.';


-- Synonyms
create or replace public synonym quo_act_dtl_soc_spc for ods.quo_act_dtl_soc_spc;

-- Grants
grant select,update,delete,insert on ods.quo_act_dtl_soc_spc to ods_app;
grant select on ods.quo_act_dtl_soc_spc to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
