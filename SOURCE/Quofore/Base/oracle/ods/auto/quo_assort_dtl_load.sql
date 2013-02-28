
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_assort_dtl_load
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_assort_dtl_load] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_assort_dtl_load cascade constraints;

create table ods.quo_assort_dtl_load (
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
  assort_created_date             date                            null,
  name                            varchar2(50 char)               null,
  assort_dtl_type_id              number(10, 0)                   null,
  assort_dtl_type_id_lookup       varchar2(50 char)               null,
  assort_dtl_type_id_desc         varchar2(100 char)              null,
  assort_dtl_name                 varchar2(50 char)               null,
  hier_level                      number(10, 0)                   null,
  cust_hier_node_id               number(10, 0)                   null,
  cust_hier_node_id_lookup        varchar2(50 char)               null,
  parent_id                       number(10, 0)                   null,
  parent_id_lookup                varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_assort_dtl_load add constraint quo_assort_dtl_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_assort_dtl_load_pk on ods.quo_assort_dtl_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_assort_dtl_load add constraint quo_assort_dtl_load_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_assort_dtl_load_uk on ods.quo_assort_dtl_load (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_assort_dtl_load_ts on ods.quo_assort_dtl_load (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_assort_dtl_load is '[AssortmentDetail] Main assortment details<\n><\n>This is a denormalized file which contains Assortment (parent) and AssortmentDetail (child) data combined';
comment on column quo_assort_dtl_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_assort_dtl_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_assort_dtl_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_assort_dtl_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_assort_dtl_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_assort_dtl_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_assort_dtl_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_assort_dtl_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_assort_dtl_load.q4x_timestamp is '* Timestamp';
comment on column quo_assort_dtl_load.id is '[id] Unique Internal ID for the row';
comment on column quo_assort_dtl_load.id_lookup is '[id_lookup] ';
comment on column quo_assort_dtl_load.created_date is '[createddate] The timestamp for the creation of the record.';
comment on column quo_assort_dtl_load.assort_id is '[assortment_id] ';
comment on column quo_assort_dtl_load.assort_id_lookup is '[assortment_id_lookup] ';
comment on column quo_assort_dtl_load.assort_created_date is '[assortmentcreateddate] The timestamp for the creation of the record.';
comment on column quo_assort_dtl_load.name is '[name] ';
comment on column quo_assort_dtl_load.assort_dtl_type_id is '[assortmentdetailtypeid] ';
comment on column quo_assort_dtl_load.assort_dtl_type_id_lookup is '[assortmentdetailtype_id_lookup] ';
comment on column quo_assort_dtl_load.assort_dtl_type_id_desc is '[assortmentdetailtype_id_description] ';
comment on column quo_assort_dtl_load.assort_dtl_name is '[assortmentdetailname] ';
comment on column quo_assort_dtl_load.hier_level is '[level] ';
comment on column quo_assort_dtl_load.cust_hier_node_id is '[customer_hierarchynode_id] ';
comment on column quo_assort_dtl_load.cust_hier_node_id_lookup is '[customer_hierarchynode_id_lookup] ';
comment on column quo_assort_dtl_load.parent_id is '[parent_id] ';
comment on column quo_assort_dtl_load.parent_id_lookup is '[parent_id_lookup] ';


-- Synonyms
create or replace public synonym quo_assort_dtl_load for ods.quo_assort_dtl_load;

-- Grants
grant select,update,delete,insert on ods.quo_assort_dtl_load to ods_app;
grant select on ods.quo_assort_dtl_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
