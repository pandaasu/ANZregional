
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_prod_assort_dtl
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_prod_assort_dtl] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_prod_assort_dtl cascade constraints;

create table ods.quo_prod_assort_dtl (
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
  created_date                    date                            null,
  assort_id                       number(10, 0)                   null,
  assort_id_lookup                varchar2(50 char)               null,
  assort_dtl_id                   number(10, 0)                   null,
  assort_dtl_id_lookup            varchar2(50 char)               null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  varchar2(50 char)               null,
  prod_hier_node_id               number(10, 0)                   null,
  prod_hier_node_id_lookup        varchar2(50 char)               null,
  priority_assort_dtl_id          number(10, 0)                   null,
  priority_assort_dtl_id_lookup   varchar2(50 char)               null,
  effective_from                  date                            null,
  effective_to                    date                            null,
  priority_from                   date                            null,
  priority_to                     date                            null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_prod_assort_dtl add constraint quo_prod_assort_dtl_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_prod_assort_dtl_pk on ods.quo_prod_assort_dtl (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_prod_assort_dtl add constraint quo_prod_assort_dtl_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_prod_assort_dtl_uk on ods.quo_prod_assort_dtl (q4x_source_id,id)) compress;

create index ods.quo_prod_assort_dtl_ts on ods.quo_prod_assort_dtl (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_prod_assort_dtl is '[ProductAssortmentDetail] Assignment of assortment to individual products or product hierarchies';
comment on column quo_prod_assort_dtl.q4x_load_seq is '* Unique Load Id';
comment on column quo_prod_assort_dtl.q4x_load_data_seq is '* Data Record Id';
comment on column quo_prod_assort_dtl.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_prod_assort_dtl.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_prod_assort_dtl.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_prod_assort_dtl.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_prod_assort_dtl.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_prod_assort_dtl.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_prod_assort_dtl.q4x_timestamp is '* Timestamp';
comment on column quo_prod_assort_dtl.id is '[id] Unique Internal ID for the row';
comment on column quo_prod_assort_dtl.id_lookup is '[id_lookup] ';
comment on column quo_prod_assort_dtl.created_date is '[createddate] The timestamp for the creation of the record.';
comment on column quo_prod_assort_dtl.assort_id is '[assortment_id] ';
comment on column quo_prod_assort_dtl.assort_id_lookup is '[assortment_id_lookup] ';
comment on column quo_prod_assort_dtl.assort_dtl_id is '[assortmentdetail_id] ';
comment on column quo_prod_assort_dtl.assort_dtl_id_lookup is '[assortmentdetail_id_lookup] ';
comment on column quo_prod_assort_dtl.prod_id is '[product_id] ';
comment on column quo_prod_assort_dtl.prod_id_lookup is '[product_id_lookup] ';
comment on column quo_prod_assort_dtl.prod_hier_node_id is '[product_hierarchynode_id] ';
comment on column quo_prod_assort_dtl.prod_hier_node_id_lookup is '[product_hierarchynode_id_lookup] ';
comment on column quo_prod_assort_dtl.priority_assort_dtl_id is '[priorityassortmentdetail_id] ';
comment on column quo_prod_assort_dtl.priority_assort_dtl_id_lookup is '[priorityassortmentdetail_id_lookup] ';
comment on column quo_prod_assort_dtl.effective_from is '[effectivefrom] ';
comment on column quo_prod_assort_dtl.effective_to is '[effectiveto] ';
comment on column quo_prod_assort_dtl.priority_from is '[priorityfrom] ';
comment on column quo_prod_assort_dtl.priority_to is '[priorityto] ';


-- Synonyms
create or replace public synonym quo_prod_assort_dtl for ods.quo_prod_assort_dtl;

-- Grants
grant select,update,delete,insert on ods.quo_prod_assort_dtl to ods_app;
grant select on ods.quo_prod_assort_dtl to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
