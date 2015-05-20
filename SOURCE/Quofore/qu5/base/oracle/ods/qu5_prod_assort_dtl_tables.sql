
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_prod_assort_dtl
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_prod_assort_dtl] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-13  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu5_prod_assort_dtl_load cascade constraints;

create table ods.qu5_prod_assort_dtl_load (
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
  assort_dtl_id                   number(10, 0)                   null,
  prod_id                         number(10, 0)                   null,
  prod_hier_node_id               number(10, 0)                   null,
  priority_assort_dtl_id          number(10, 0)                   null,
  effective_from                  date                            null,
  effective_to                    date                            null,
  priority_from                   date                            null,
  priotity_to                     date                            null,
  assort_dtl_id_lookup            varchar2(50 char)               null,
  id_lookup                       varchar2(50 char)               null,
  prod_id_lookup                  varchar2(50 char)               null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_prod_assort_dtl_load add constraint qu5_prod_assort_dtl_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_prod_assort_dtl_load_pk on ods.qu5_prod_assort_dtl_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_prod_assort_dtl_load add constraint qu5_prod_assort_dtl_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_prod_assort_dtl_load_uk on ods.qu5_prod_assort_dtl_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_prod_assort_dtl_load is '[ProductAssortmentDetail][LOAD] Assignment of assortment to individual products or product hierarchies.';
comment on column qu5_prod_assort_dtl_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_prod_assort_dtl_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_prod_assort_dtl_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_prod_assort_dtl_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_prod_assort_dtl_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_prod_assort_dtl_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_prod_assort_dtl_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_prod_assort_dtl_load.q4x_timestamp is '* Timestamp';
comment on column qu5_prod_assort_dtl_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_prod_assort_dtl_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_prod_assort_dtl_load.assort_dtl_id is '[AssortmentDetail_Id] Extended Attribute - Whether the ProductAssortmentDetail assortment available for Detail Orders _i not';
comment on column qu5_prod_assort_dtl_load.prod_id is '[Product_Id] Extended Attribute - Whether the ProductAssortmentDetail product available for Product Orders _i not';
comment on column qu5_prod_assort_dtl_load.prod_hier_node_id is '[Product_HierarchyNode_Id] Extended Attribute - Whether the ProductAssortmentDetail product available for Node Orders _i not';
comment on column qu5_prod_assort_dtl_load.priority_assort_dtl_id is '[PriorityAssortmentDetail_Id] Extended Attribute - Whether the ProductAssortmentDetail priority available for Detail Orders _i not';
comment on column qu5_prod_assort_dtl_load.effective_from is '[EffectiveFrom] ';
comment on column qu5_prod_assort_dtl_load.effective_to is '[EffectiveTo] ';
comment on column qu5_prod_assort_dtl_load.priority_from is '[PriorityFrom] ';
comment on column qu5_prod_assort_dtl_load.priotity_to is '[PriorityTo] ';
comment on column qu5_prod_assort_dtl_load.assort_dtl_id_lookup is '[AssortmentDetail_Id_Lookup] Assortment Detail Id Lookup of the ProductAssortmentDetail';
comment on column qu5_prod_assort_dtl_load.id_lookup is '[Id_Lookup] Id Lookup of the ProductAssortmentDetail';
comment on column qu5_prod_assort_dtl_load.prod_id_lookup is '[Product_Id_Lookup] Product Id Lookup of the ProductAssortmentDetail';
comment on column qu5_prod_assort_dtl_load.prod_id_desc is '[Product_Id_Description] Product Id Description of the ProductAssortmentDetail';

-- Synonyms
create or replace public synonym qu5_prod_assort_dtl_load for ods.qu5_prod_assort_dtl_load;

-- Grants
grant select,insert,update,delete on ods.qu5_prod_assort_dtl_load to ods_app;
grant select on ods.qu5_prod_assort_dtl_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_prod_assort_dtl_hist cascade constraints;

create table ods.qu5_prod_assort_dtl_hist (
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
  assort_dtl_id                   number(10, 0)                   null,
  prod_id                         number(10, 0)                   null,
  prod_hier_node_id               number(10, 0)                   null,
  priority_assort_dtl_id          number(10, 0)                   null,
  effective_from                  date                            null,
  effective_to                    date                            null,
  priority_from                   date                            null,
  priotity_to                     date                            null,
  assort_dtl_id_lookup            varchar2(50 char)               null,
  id_lookup                       varchar2(50 char)               null,
  prod_id_lookup                  varchar2(50 char)               null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_prod_assort_dtl_hist add constraint qu5_prod_assort_dtl_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_prod_assort_dtl_hist_pk on ods.qu5_prod_assort_dtl_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_prod_assort_dtl_hist add constraint qu5_prod_assort_dtl_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_prod_assort_dtl_hist_uk on ods.qu5_prod_assort_dtl_hist (id,q4x_batch_id)) compress;

create index ods.qu5_prod_assort_dtl_hist_ts on ods.qu5_prod_assort_dtl_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_prod_assort_dtl_hist is '[ProductAssortmentDetail][HIST] Assignment of assortment to individual products or product hierarchies.';
comment on column qu5_prod_assort_dtl_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_prod_assort_dtl_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_prod_assort_dtl_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_prod_assort_dtl_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_prod_assort_dtl_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_prod_assort_dtl_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_prod_assort_dtl_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_prod_assort_dtl_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_prod_assort_dtl_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_prod_assort_dtl_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_prod_assort_dtl_hist.assort_dtl_id is '[AssortmentDetail_Id] Extended Attribute - Whether the ProductAssortmentDetail assortment available for Detail Orders _i not';
comment on column qu5_prod_assort_dtl_hist.prod_id is '[Product_Id] Extended Attribute - Whether the ProductAssortmentDetail product available for Product Orders _i not';
comment on column qu5_prod_assort_dtl_hist.prod_hier_node_id is '[Product_HierarchyNode_Id] Extended Attribute - Whether the ProductAssortmentDetail product available for Node Orders _i not';
comment on column qu5_prod_assort_dtl_hist.priority_assort_dtl_id is '[PriorityAssortmentDetail_Id] Extended Attribute - Whether the ProductAssortmentDetail priority available for Detail Orders _i not';
comment on column qu5_prod_assort_dtl_hist.effective_from is '[EffectiveFrom] ';
comment on column qu5_prod_assort_dtl_hist.effective_to is '[EffectiveTo] ';
comment on column qu5_prod_assort_dtl_hist.priority_from is '[PriorityFrom] ';
comment on column qu5_prod_assort_dtl_hist.priotity_to is '[PriorityTo] ';
comment on column qu5_prod_assort_dtl_hist.assort_dtl_id_lookup is '[AssortmentDetail_Id_Lookup] Assortment Detail Id Lookup of the ProductAssortmentDetail';
comment on column qu5_prod_assort_dtl_hist.id_lookup is '[Id_Lookup] Id Lookup of the ProductAssortmentDetail';
comment on column qu5_prod_assort_dtl_hist.prod_id_lookup is '[Product_Id_Lookup] Product Id Lookup of the ProductAssortmentDetail';
comment on column qu5_prod_assort_dtl_hist.prod_id_desc is '[Product_Id_Description] Product Id Description of the ProductAssortmentDetail';

-- Synonyms
create or replace public synonym qu5_prod_assort_dtl_hist for ods.qu5_prod_assort_dtl_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_prod_assort_dtl_hist to ods_app;
grant select on ods.qu5_prod_assort_dtl_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
