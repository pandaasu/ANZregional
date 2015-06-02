
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_assort_dtl
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_assort_dtl] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu3_assort_dtl_load cascade constraints;

create table ods.qu3_assort_dtl_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  created_date                    date                            null,
  assort_id                       number(10, 0)                   null,
  assort_created_date             date                            null,
  name                            varchar2(50 char)               null,
  assort_dtl_type_id              number(10, 0)                   null,
  assort_dtl_type_id_desc         varchar2(100 char)              null,
  assort_dtl_name                 varchar2(50 char)               null,
  hier_level                      number(10, 0)                   null,
  cust_hier_node_id               number(10, 0)                   null,
  parent_id                       number(10, 0)                   null,
  cust_hier_node_id_lookup        varchar2(50 char)               null,
  parent_id_lookup                varchar2(50 char)               null,
  assort_dtl_type_id_lookup       varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu3_assort_dtl_load add constraint qu3_assort_dtl_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_assort_dtl_load_pk on ods.qu3_assort_dtl_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_assort_dtl_load add constraint qu3_assort_dtl_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_assort_dtl_load_uk on ods.qu3_assort_dtl_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_assort_dtl_load is '[AssortmentDetail][LOAD] Main assortment details.<\n><\n>This is a denormalized file which contains Assortment (parent) and AssortmentDetail (child) data combined.';
comment on column qu3_assort_dtl_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_assort_dtl_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_assort_dtl_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_assort_dtl_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_assort_dtl_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_assort_dtl_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_assort_dtl_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_assort_dtl_load.q4x_timestamp is '* Timestamp';
comment on column qu3_assort_dtl_load.id is '[id] Unique Internal ID for the row';
comment on column qu3_assort_dtl_load.created_date is '[createddate] The timestamp for the creation of the record.';
comment on column qu3_assort_dtl_load.assort_id is '[assortment_id] ';
comment on column qu3_assort_dtl_load.assort_created_date is '[assortmentcreateddate] The timestamp for the creation of the record.';
comment on column qu3_assort_dtl_load.name is '[name] ';
comment on column qu3_assort_dtl_load.assort_dtl_type_id is '[assortmentdetailtypeid] ';
comment on column qu3_assort_dtl_load.assort_dtl_type_id_desc is '[assortmentdetailtype_id_description] ';
comment on column qu3_assort_dtl_load.assort_dtl_name is '[assortmentdetailname] ';
comment on column qu3_assort_dtl_load.hier_level is '[level] ';
comment on column qu3_assort_dtl_load.cust_hier_node_id is '[customer_hierarchynode_id] ';
comment on column qu3_assort_dtl_load.parent_id is '[parent_id] ';
comment on column qu3_assort_dtl_load.cust_hier_node_id_lookup is '[customer_hierarchynode_id_lookup] ';
comment on column qu3_assort_dtl_load.parent_id_lookup is '[parent_id_lookup] ';
comment on column qu3_assort_dtl_load.assort_dtl_type_id_lookup is '[assortmentdetailtype_id_lookup] ';

-- Synonyms
create or replace public synonym qu3_assort_dtl_load for ods.qu3_assort_dtl_load;

-- Grants
grant select,insert,update,delete on ods.qu3_assort_dtl_load to ods_app;
grant select on ods.qu3_assort_dtl_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_assort_dtl_hist cascade constraints;

create table ods.qu3_assort_dtl_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  created_date                    date                            null,
  assort_id                       number(10, 0)                   null,
  assort_created_date             date                            null,
  name                            varchar2(50 char)               null,
  assort_dtl_type_id              number(10, 0)                   null,
  assort_dtl_type_id_desc         varchar2(100 char)              null,
  assort_dtl_name                 varchar2(50 char)               null,
  hier_level                      number(10, 0)                   null,
  cust_hier_node_id               number(10, 0)                   null,
  parent_id                       number(10, 0)                   null,
  cust_hier_node_id_lookup        varchar2(50 char)               null,
  parent_id_lookup                varchar2(50 char)               null,
  assort_dtl_type_id_lookup       varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu3_assort_dtl_hist add constraint qu3_assort_dtl_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_assort_dtl_hist_pk on ods.qu3_assort_dtl_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_assort_dtl_hist add constraint qu3_assort_dtl_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_assort_dtl_hist_uk on ods.qu3_assort_dtl_hist (id,q4x_batch_id)) compress;

create index ods.qu3_assort_dtl_hist_ts on ods.qu3_assort_dtl_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_assort_dtl_hist is '[AssortmentDetail][HIST] Main assortment details.<\n><\n>This is a denormalized file which contains Assortment (parent) and AssortmentDetail (child) data combined.';
comment on column qu3_assort_dtl_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_assort_dtl_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_assort_dtl_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_assort_dtl_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_assort_dtl_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_assort_dtl_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_assort_dtl_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_assort_dtl_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_assort_dtl_hist.id is '[id] Unique Internal ID for the row';
comment on column qu3_assort_dtl_hist.created_date is '[createddate] The timestamp for the creation of the record.';
comment on column qu3_assort_dtl_hist.assort_id is '[assortment_id] ';
comment on column qu3_assort_dtl_hist.assort_created_date is '[assortmentcreateddate] The timestamp for the creation of the record.';
comment on column qu3_assort_dtl_hist.name is '[name] ';
comment on column qu3_assort_dtl_hist.assort_dtl_type_id is '[assortmentdetailtypeid] ';
comment on column qu3_assort_dtl_hist.assort_dtl_type_id_desc is '[assortmentdetailtype_id_description] ';
comment on column qu3_assort_dtl_hist.assort_dtl_name is '[assortmentdetailname] ';
comment on column qu3_assort_dtl_hist.hier_level is '[level] ';
comment on column qu3_assort_dtl_hist.cust_hier_node_id is '[customer_hierarchynode_id] ';
comment on column qu3_assort_dtl_hist.parent_id is '[parent_id] ';
comment on column qu3_assort_dtl_hist.cust_hier_node_id_lookup is '[customer_hierarchynode_id_lookup] ';
comment on column qu3_assort_dtl_hist.parent_id_lookup is '[parent_id_lookup] ';
comment on column qu3_assort_dtl_hist.assort_dtl_type_id_lookup is '[assortmentdetailtype_id_lookup] ';

-- Synonyms
create or replace public synonym qu3_assort_dtl_hist for ods.qu3_assort_dtl_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_assort_dtl_hist to ods_app;
grant select on ods.qu3_assort_dtl_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
