
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_task_cust
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_task_cust] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_task_cust cascade constraints;

create table ods.quo_task_cust (
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
  task_id                         number(10, 0)                   null,
  task_id_lookup                  varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  varchar2(50 char)               null,
  hier_node_id                    number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_task_cust add constraint quo_task_cust_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_task_cust_pk on ods.quo_task_cust (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_task_cust add constraint quo_task_cust_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_task_cust_uk on ods.quo_task_cust (q4x_source_id,id)) compress;

create index ods.quo_task_cust_ts on ods.quo_task_cust (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_task_cust is '[TaskCustomer] Assignment of tasks to individual customers or customer hierarchies';
comment on column quo_task_cust.q4x_load_seq is '* Unique Load Id';
comment on column quo_task_cust.q4x_load_data_seq is '* Data Record Id';
comment on column quo_task_cust.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_task_cust.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_task_cust.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_task_cust.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_task_cust.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_task_cust.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_task_cust.q4x_timestamp is '* Timestamp';
comment on column quo_task_cust.id is '[ID] Unique Internal ID for the row';
comment on column quo_task_cust.id_lookup is '[ID_Lookup] ';
comment on column quo_task_cust.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_task_cust.task_id is '[Task_ID] Mandatory foreign key to [Task].[Id].';
comment on column quo_task_cust.task_id_lookup is '[Task_ID_Lookup] ';
comment on column quo_task_cust.cust_id is '[Customer_ID] Either Customer_ID or HierarchyNode_ID is compulsory';
comment on column quo_task_cust.cust_id_lookup is '[Customer_ID_Lookup] ';
comment on column quo_task_cust.hier_node_id is '[HierarchyNode_ID] Either Customer_ID or HierarchyNode_ID is compulsory';


-- Synonyms
create or replace public synonym quo_task_cust for ods.quo_task_cust;

-- Grants
grant select,update,delete,insert on ods.quo_task_cust to ods_app;
grant select on ods.quo_task_cust to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
