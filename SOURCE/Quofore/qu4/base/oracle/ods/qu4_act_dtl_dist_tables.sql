
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_act_dtl_dist
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_act_dtl_dist] table creation script _load and _hist

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
drop table ods.qu4_act_dtl_dist_load cascade constraints;

create table ods.qu4_act_dtl_dist_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  act_id                          number(10, 0)                   not null,
  no_of_facings                   number(10, 0)                   null,
  is_in_distribution              number(1, 0)                    null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_act_dtl_dist_load add constraint qu4_act_dtl_dist_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_act_dtl_dist_load_pk on ods.qu4_act_dtl_dist_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_act_dtl_dist_load add constraint qu4_act_dtl_dist_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_act_dtl_dist_load_uk on ods.qu4_act_dtl_dist_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_act_dtl_dist_load is '[ActivityDetail_Distribution][LOAD] ';
comment on column qu4_act_dtl_dist_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_act_dtl_dist_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_act_dtl_dist_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_act_dtl_dist_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_act_dtl_dist_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_act_dtl_dist_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_act_dtl_dist_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_act_dtl_dist_load.q4x_timestamp is '* Timestamp';
comment on column qu4_act_dtl_dist_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_act_dtl_dist_load.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu4_act_dtl_dist_load.no_of_facings is '[NoOfFacings] Number of Facings';
comment on column qu4_act_dtl_dist_load.is_in_distribution is '[IsInDistribution] Whehter the Product is in Distribution.   Values = 1 or 0';
comment on column qu4_act_dtl_dist_load.prod_id is '[Product_ID] Foreign key from [Product].[Id].';

-- Synonyms
create or replace public synonym qu4_act_dtl_dist_load for ods.qu4_act_dtl_dist_load;

-- Grants
grant select,insert,update,delete on ods.qu4_act_dtl_dist_load to ods_app;
grant select on ods.qu4_act_dtl_dist_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_act_dtl_dist_hist cascade constraints;

create table ods.qu4_act_dtl_dist_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  act_id                          number(10, 0)                   not null,
  no_of_facings                   number(10, 0)                   null,
  is_in_distribution              number(1, 0)                    null,
  prod_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu4_act_dtl_dist_hist add constraint qu4_act_dtl_dist_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_act_dtl_dist_hist_pk on ods.qu4_act_dtl_dist_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_act_dtl_dist_hist add constraint qu4_act_dtl_dist_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_act_dtl_dist_hist_uk on ods.qu4_act_dtl_dist_hist (id,q4x_batch_id)) compress;

create index ods.qu4_act_dtl_dist_hist_ts on ods.qu4_act_dtl_dist_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_act_dtl_dist_hist is '[ActivityDetail_Distribution][HIST] ';
comment on column qu4_act_dtl_dist_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_act_dtl_dist_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_act_dtl_dist_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_act_dtl_dist_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_act_dtl_dist_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_act_dtl_dist_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_act_dtl_dist_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_act_dtl_dist_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_act_dtl_dist_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_act_dtl_dist_hist.act_id is '[Activity_ID] Mandatory foreign key from [ActivityHeader].[Id].';
comment on column qu4_act_dtl_dist_hist.no_of_facings is '[NoOfFacings] Number of Facings';
comment on column qu4_act_dtl_dist_hist.is_in_distribution is '[IsInDistribution] Whehter the Product is in Distribution.   Values = 1 or 0';
comment on column qu4_act_dtl_dist_hist.prod_id is '[Product_ID] Foreign key from [Product].[Id].';

-- Synonyms
create or replace public synonym qu4_act_dtl_dist_hist for ods.qu4_act_dtl_dist_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_act_dtl_dist_hist to ods_app;
grant select on ods.qu4_act_dtl_dist_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
