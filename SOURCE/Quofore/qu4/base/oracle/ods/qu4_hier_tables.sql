
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_hier
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_hier] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup source_id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2014-06-03  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu4_hier_load cascade constraints;

create table ods.qu4_hier_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  id_desc                         varchar2(50 char)               null,
  is_active                       number(1, 0)                    null,
  node                            varchar2(50 char)               null,
  hier_full_path                  varchar2(4000 char)             null,
  hier_root_is_active             number(1, 0)                    null,
  hier_root_id                    number(10, 0)                   null,
  hier_root_id_desc               varchar2(50 char)               null,
  parent_id                       number(10, 0)                   null,
  parent_id_desc                  varchar2(50 char)               null,
  parent_node                     varchar2(50 char)               null,
  parent_is_active                number(1, 0)                    null,
  hier_level                      number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_hier_load add constraint qu4_hier_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_hier_load_pk on ods.qu4_hier_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_hier_load add constraint qu4_hier_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_hier_load_uk on ods.qu4_hier_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_hier_load is '[Hierarchy][LOAD] File to specify various hierarchies used in system e.g. customer hierarchy, product hierarchy. Data is supplied in a structure similar to the way SQL Server handles hierarchyID columns.<\n>HierarchyRoot corresponds to the main hierarchy e.g. CustomerHierarchy, ProductHierarchy.<\n>Each hierarchy root can then have HierarchyNode with depth of N levels e.g. ProductHierarchy can have 3 levels i.e Category->Brand->PackGroup. Level 1 contains all categories, level 2 contains brands for each category and level 3 contains packgroup for each category and brand.<\n><\n>This is a denormalized file which contains HierarchyRoot (parent) and HierarchyNode (child) data combined.';
comment on column qu4_hier_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_hier_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_hier_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_hier_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_hier_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_hier_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_hier_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_hier_load.q4x_timestamp is '* Timestamp';
comment on column qu4_hier_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_hier_load.id_desc is '[ID_Description] Default language description of the node';
comment on column qu4_hier_load.is_active is '[IsActive] Indicates whether the hierarchy node is active. 0 = False, 1 = True.';
comment on column qu4_hier_load.node is '[Node] This encapsulates the organisation of multi-level entities in a single column. Full hierarchy node representation in hierarchy format e.g. /1/2/3/';
comment on column qu4_hier_load.hier_full_path is '[HierarchyFullPath] Full hierarchy node name e.g. MustWin\\MustWin\\Top 500';
comment on column qu4_hier_load.hier_root_is_active is '[HierarchyRootIsActive] Indicates whether the hierarchy root is active. 0 = False, 1 = True.';
comment on column qu4_hier_load.hier_root_id is '[HierarchyRoot_ID] Internal ID of hierarchy root';
comment on column qu4_hier_load.hier_root_id_desc is '[HierarchyRoot_ID_Description] Default language description of the node';
comment on column qu4_hier_load.parent_id is '[Parent_ID] Internal ID of parent of current hierarchy node e.g. /2/';
comment on column qu4_hier_load.parent_id_desc is '[Parent_ID_Description] Default language description of the node';
comment on column qu4_hier_load.parent_node is '[ParentNode] Parent node representation in hierarchy format e.g. /1/2/3/';
comment on column qu4_hier_load.parent_is_active is '[ParentIsactive] Parent node is active or not';
comment on column qu4_hier_load.hier_level is '[Level] If it''s a child, what level is it on';

-- Synonyms
create or replace public synonym qu4_hier_load for ods.qu4_hier_load;

-- Grants
grant select,insert,update,delete on ods.qu4_hier_load to ods_app;
grant select on ods.qu4_hier_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_hier_hist cascade constraints;

create table ods.qu4_hier_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  id_desc                         varchar2(50 char)               null,
  is_active                       number(1, 0)                    null,
  node                            varchar2(50 char)               null,
  hier_full_path                  varchar2(4000 char)             null,
  hier_root_is_active             number(1, 0)                    null,
  hier_root_id                    number(10, 0)                   null,
  hier_root_id_desc               varchar2(50 char)               null,
  parent_id                       number(10, 0)                   null,
  parent_id_desc                  varchar2(50 char)               null,
  parent_node                     varchar2(50 char)               null,
  parent_is_active                number(1, 0)                    null,
  hier_level                      number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_hier_hist add constraint qu4_hier_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_hier_hist_pk on ods.qu4_hier_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_hier_hist add constraint qu4_hier_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_hier_hist_uk on ods.qu4_hier_hist (id,q4x_batch_id)) compress;

create index ods.qu4_hier_hist_ts on ods.qu4_hier_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_hier_hist is '[Hierarchy][HIST] File to specify various hierarchies used in system e.g. customer hierarchy, product hierarchy. Data is supplied in a structure similar to the way SQL Server handles hierarchyID columns.<\n>HierarchyRoot corresponds to the main hierarchy e.g. CustomerHierarchy, ProductHierarchy.<\n>Each hierarchy root can then have HierarchyNode with depth of N levels e.g. ProductHierarchy can have 3 levels i.e Category->Brand->PackGroup. Level 1 contains all categories, level 2 contains brands for each category and level 3 contains packgroup for each category and brand.<\n><\n>This is a denormalized file which contains HierarchyRoot (parent) and HierarchyNode (child) data combined.';
comment on column qu4_hier_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_hier_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_hier_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_hier_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_hier_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_hier_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_hier_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_hier_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_hier_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_hier_hist.id_desc is '[ID_Description] Default language description of the node';
comment on column qu4_hier_hist.is_active is '[IsActive] Indicates whether the hierarchy node is active. 0 = False, 1 = True.';
comment on column qu4_hier_hist.node is '[Node] This encapsulates the organisation of multi-level entities in a single column. Full hierarchy node representation in hierarchy format e.g. /1/2/3/';
comment on column qu4_hier_hist.hier_full_path is '[HierarchyFullPath] Full hierarchy node name e.g. MustWin\\MustWin\\Top 500';
comment on column qu4_hier_hist.hier_root_is_active is '[HierarchyRootIsActive] Indicates whether the hierarchy root is active. 0 = False, 1 = True.';
comment on column qu4_hier_hist.hier_root_id is '[HierarchyRoot_ID] Internal ID of hierarchy root';
comment on column qu4_hier_hist.hier_root_id_desc is '[HierarchyRoot_ID_Description] Default language description of the node';
comment on column qu4_hier_hist.parent_id is '[Parent_ID] Internal ID of parent of current hierarchy node e.g. /2/';
comment on column qu4_hier_hist.parent_id_desc is '[Parent_ID_Description] Default language description of the node';
comment on column qu4_hier_hist.parent_node is '[ParentNode] Parent node representation in hierarchy format e.g. /1/2/3/';
comment on column qu4_hier_hist.parent_is_active is '[ParentIsactive] Parent node is active or not';
comment on column qu4_hier_hist.hier_level is '[Level] If it''s a child, what level is it on';

-- Synonyms
create or replace public synonym qu4_hier_hist for ods.qu4_hier_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_hier_hist to ods_app;
grant select on ods.qu4_hier_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
