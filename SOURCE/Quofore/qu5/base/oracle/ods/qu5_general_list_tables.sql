
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_general_list
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_general_list] table creation script _load and _hist

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
drop table ods.qu5_general_list_load cascade constraints;

create table ods.qu5_general_list_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  lookup_list_item_is_active      number(1, 0)                    null,
  lookup_list_item_created_date   date                            null,
  lookup_list_item_name           varchar2(50 char)               null,
  lookup_list_is_active           number(1, 0)                    null,
  lookup_list_id                  number(10, 0)                   null,
  lookup_list_name                varchar2(50 char)               null,
  lookup_list_created_date        date                            null,
  lookup_list_sort_order          number(5, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu5_general_list_load add constraint qu5_general_list_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_general_list_load_pk on ods.qu5_general_list_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_general_list_load add constraint qu5_general_list_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_general_list_load_uk on ods.qu5_general_list_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_general_list_load is '[GeneralList][LOAD] Contains the general list data. It includes list header as well as list details.<\n>LookupList corresponds to the main list name e.g. ''Order Status List''<\n>LookupListItem corresponds to the actual list item e.g. Order status list contains ''Draft'', ''Inprogress'', ''Submitted'' etc.';
comment on column qu5_general_list_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_general_list_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_general_list_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_general_list_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_general_list_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_general_list_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_general_list_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_general_list_load.q4x_timestamp is '* Timestamp';
comment on column qu5_general_list_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_general_list_load.lookup_list_item_is_active is '[LookupListItemIsActive] Indicates whether the lookuplistitem is active. 0 = False, 1 = True.';
comment on column qu5_general_list_load.lookup_list_item_created_date is '[LookupListItemCreatedDate] ';
comment on column qu5_general_list_load.lookup_list_item_name is '[LookupListItemName] Description of LookupListItem e.g. Submitted.';
comment on column qu5_general_list_load.lookup_list_is_active is '[LookupListIsActive] Indicates whether the lookuplist is active. 0 = False, 1 = True.';
comment on column qu5_general_list_load.lookup_list_id is '[LookupList_Id] ID of LookupList';
comment on column qu5_general_list_load.lookup_list_name is '[LookupListName] Name of LookupList e.g. Order Status';
comment on column qu5_general_list_load.lookup_list_created_date is '[LookupListCreatedDate] ';
comment on column qu5_general_list_load.lookup_list_sort_order is '[LookupListSortOrder] ';

-- Synonyms
create or replace public synonym qu5_general_list_load for ods.qu5_general_list_load;

-- Grants
grant select,insert,update,delete on ods.qu5_general_list_load to ods_app;
grant select on ods.qu5_general_list_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_general_list_hist cascade constraints;

create table ods.qu5_general_list_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  lookup_list_item_is_active      number(1, 0)                    null,
  lookup_list_item_created_date   date                            null,
  lookup_list_item_name           varchar2(50 char)               null,
  lookup_list_is_active           number(1, 0)                    null,
  lookup_list_id                  number(10, 0)                   null,
  lookup_list_name                varchar2(50 char)               null,
  lookup_list_created_date        date                            null,
  lookup_list_sort_order          number(5, 0)                    null
)
compress;

-- Keys / Indexes
alter table ods.qu5_general_list_hist add constraint qu5_general_list_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_general_list_hist_pk on ods.qu5_general_list_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_general_list_hist add constraint qu5_general_list_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_general_list_hist_uk on ods.qu5_general_list_hist (id,q4x_batch_id)) compress;

create index ods.qu5_general_list_hist_ts on ods.qu5_general_list_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_general_list_hist is '[GeneralList][HIST] Contains the general list data. It includes list header as well as list details.<\n>LookupList corresponds to the main list name e.g. ''Order Status List''<\n>LookupListItem corresponds to the actual list item e.g. Order status list contains ''Draft'', ''Inprogress'', ''Submitted'' etc.';
comment on column qu5_general_list_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_general_list_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_general_list_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_general_list_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_general_list_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_general_list_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_general_list_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_general_list_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_general_list_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_general_list_hist.lookup_list_item_is_active is '[LookupListItemIsActive] Indicates whether the lookuplistitem is active. 0 = False, 1 = True.';
comment on column qu5_general_list_hist.lookup_list_item_created_date is '[LookupListItemCreatedDate] ';
comment on column qu5_general_list_hist.lookup_list_item_name is '[LookupListItemName] Description of LookupListItem e.g. Submitted.';
comment on column qu5_general_list_hist.lookup_list_is_active is '[LookupListIsActive] Indicates whether the lookuplist is active. 0 = False, 1 = True.';
comment on column qu5_general_list_hist.lookup_list_id is '[LookupList_Id] ID of LookupList';
comment on column qu5_general_list_hist.lookup_list_name is '[LookupListName] Name of LookupList e.g. Order Status';
comment on column qu5_general_list_hist.lookup_list_created_date is '[LookupListCreatedDate] ';
comment on column qu5_general_list_hist.lookup_list_sort_order is '[LookupListSortOrder] ';

-- Synonyms
create or replace public synonym qu5_general_list_hist for ods.qu5_general_list_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_general_list_hist to ods_app;
grant select on ods.qu5_general_list_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
