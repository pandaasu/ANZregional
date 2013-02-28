
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_general_list_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_general_list_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_general_list_hist cascade constraints;

create table ods.quo_general_list_hist (
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
  lookup_list_item_is_active      number(1, 0)                    null,
  lookup_list_item_created_date   date                            null,
  lookup_list_item_name           varchar2(50 char)               null,
  lookup_list_is_active           number(1, 0)                    null,
  lookup_list_id                  number(10, 0)                   null,
  lookup_list_id_lookup           varchar2(50 char)               null,
  lookup_list_name                varchar2(50 char)               null,
  lookup_list_created_date        date                            null,
  lookup_list_sort_ord            number(5, 0)                    null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_general_list_hist add constraint quo_general_list_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_general_list_hist_pk on ods.quo_general_list_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_general_list_hist add constraint quo_general_list_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_general_list_hist_uk on ods.quo_general_list_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_general_list_hist_ts on ods.quo_general_list_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_general_list_hist is '[GeneralList] Contains the general list data. It includes list header as well as list details.<\n>LookupList corresponds to the main list name e.g. "Order Status List"<\n>LookupListItem corresponds to the actual list item e.g. Order status list contains "Draft", "Inprogress", "Submitted" etc.';
comment on column quo_general_list_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_general_list_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_general_list_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_general_list_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_general_list_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_general_list_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_general_list_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_general_list_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_general_list_hist.q4x_timestamp is '* Timestamp';
comment on column quo_general_list_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_general_list_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_general_list_hist.lookup_list_item_is_active is '[LookupListItemIsActive] Indicates whether the lookuplistitem is active. 0 = False, 1 = True.';
comment on column quo_general_list_hist.lookup_list_item_created_date is '[LookupListItemCreatedDate] ';
comment on column quo_general_list_hist.lookup_list_item_name is '[LookupListItemName] Description of LookupListItem e.g. Submitted.';
comment on column quo_general_list_hist.lookup_list_is_active is '[LookupListIsActive] Indicates whether the lookuplist is active. 0 = False, 1 = True.';
comment on column quo_general_list_hist.lookup_list_id is '[LookupList_ID] ID of LookupList';
comment on column quo_general_list_hist.lookup_list_id_lookup is '[LookupList_ID_Lookup] ';
comment on column quo_general_list_hist.lookup_list_name is '[LookupListName] Name of LookupList e.g. Order Status';
comment on column quo_general_list_hist.lookup_list_created_date is '[LookupListCreatedDate] ';
comment on column quo_general_list_hist.lookup_list_sort_ord is '[LookupListSortOrder] ';


-- Synonyms
create or replace public synonym quo_general_list_hist for ods.quo_general_list_hist;

-- Grants
grant select,update,delete,insert on ods.quo_general_list_hist to ods_app;
grant select on ods.quo_general_list_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
