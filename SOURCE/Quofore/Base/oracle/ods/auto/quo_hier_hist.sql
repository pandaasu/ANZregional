
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_hier_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_hier_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_hier_hist cascade constraints;

create table ods.quo_hier_hist (
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
  id_desc                         varchar2(50 char)               null,
  is_active                       number(1, 0)                    null,
  node                            varchar2(50 char)               null,
  hier_full_path                  varchar2(4000 char)             null,
  hier_root_is_active             number(1, 0)                    null,
  hier_root_id                    number(10, 0)                   null,
  hier_root_id_lookup             varchar2(50 char)               null,
  hier_root_id_desc               varchar2(50 char)               null,
  hier_root_node                  varchar2(50 char)               null,
  parent_id                       number(10, 0)                   null,
  parent_id_lookup                varchar2(50 char)               null,
  parent_id_desc                  varchar2(50 char)               null,
  parent_node                     varchar2(50 char)               null,
  parent_is_active                number(1, 0)                    null,
  hier_level                      number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_hier_hist add constraint quo_hier_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_hier_hist_pk on ods.quo_hier_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_hier_hist add constraint quo_hier_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_hier_hist_uk on ods.quo_hier_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_hier_hist_ts on ods.quo_hier_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_hier_hist is '[Hierarchy] File to specify various hierarchies used in system e.g. customer hierarchy, product hierarchy. Data is supplied in a structure similar to the way SQL Server handles hierarchyID columns.<\n>HierarchyRoot corresponds to the main hierarchy e.g. CustomerHierarchy, ProductHierarchy.<\n>Each hierarchy root can then have HierarchyNode with depth of N levels e.g. ProductHierarchy can have 3 levels i.e Category->Brand->PackGroup. Level 1 contains all categories, level 2 contains brands for each category and level 3 contains packgroup for each category and brand.<\n><\n>This is a denormalized file which contains HierarchyRoot (parent) and HierarchyNode (child) data combined';
comment on column quo_hier_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_hier_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_hier_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_hier_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_hier_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_hier_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_hier_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_hier_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_hier_hist.q4x_timestamp is '* Timestamp';
comment on column quo_hier_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_hier_hist.id_lookup is '[ID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_hier_hist.id_desc is '[ID_Description] Default language description of the node';
comment on column quo_hier_hist.is_active is '[IsActive] Indicates whether the hierarchy node is active. 0 = False, 1 = True.';
comment on column quo_hier_hist.node is '[Node] This encapsulates the organisation of multi-level entities in a single column. Full hierarchy node representation in hierarchy format e.g. /1/2/3/';
comment on column quo_hier_hist.hier_full_path is '[HierarchyFullPath] Full hierarchy node name e.g. Banner\\Group\\Coles';
comment on column quo_hier_hist.hier_root_is_active is '[HierarchyRootIsActive] Indicates whether the hierarchy root is active. 0 = False, 1 = True.';
comment on column quo_hier_hist.hier_root_id is '[HierarchyRoot_ID] Internal ID of hierarchy root';
comment on column quo_hier_hist.hier_root_id_lookup is '[HierarchyRoot_ID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_hier_hist.hier_root_id_desc is '[HierarchyRoot_ID_Description] Default language description of the node';
comment on column quo_hier_hist.hier_root_node is '[HierarchyRootNode] Hierarchy root representation in hierarchy format e.g. /1/';
comment on column quo_hier_hist.parent_id is '[Parent_ID] Internal ID of parent of current hierarchy node e.g. /2/';
comment on column quo_hier_hist.parent_id_lookup is '[Parent_ID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_hier_hist.parent_id_desc is '[Parent_ID_Description] Default language description of the node';
comment on column quo_hier_hist.parent_node is '[ParentNode] Parent of current node represented in hierarchy format e.g. Group';
comment on column quo_hier_hist.parent_is_active is '[ParentIsactive] ';
comment on column quo_hier_hist.hier_level is '[Level] ';


-- Synonyms
create or replace public synonym quo_hier_hist for ods.quo_hier_hist;

-- Grants
grant select,update,delete,insert on ods.quo_hier_hist to ods_app;
grant select on ods.quo_hier_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
