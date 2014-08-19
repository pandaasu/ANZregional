
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_rep
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_rep] table creation script _load and _hist

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
drop table ods.qu4_rep_load cascade constraints;

create table ods.qu4_rep_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  emp_no                          varchar2(50 char)               null,
  first_name                      varchar2(50 char)               null,
  last_name                       varchar2(50 char)               null,
  middle_name                     varchar2(50 char)               null,
  home_no                         varchar2(30 char)               null,
  mobile_no                       varchar2(30 char)               null,
  fax_no                          varchar2(30 char)               null,
  email                           varchar2(60 char)               null,
  pos_id                          number(10, 0)                   null,
  full_name                       varchar2(101 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_rep_load add constraint qu4_rep_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_rep_load_pk on ods.qu4_rep_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_rep_load add constraint qu4_rep_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_rep_load_uk on ods.qu4_rep_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_rep_load is '[Rep][LOAD] Rep main information along with position attached.';
comment on column qu4_rep_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_rep_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_rep_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_rep_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_rep_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_rep_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_rep_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_rep_load.q4x_timestamp is '* Timestamp';
comment on column qu4_rep_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_rep_load.is_active is '[IsActive] Indicates whether the rep is active. 0 = False, 1 = True.';
comment on column qu4_rep_load.created_date is '[CreatedDate] ';
comment on column qu4_rep_load.emp_no is '[EmployeeNumber] ';
comment on column qu4_rep_load.first_name is '[FirstName] ';
comment on column qu4_rep_load.last_name is '[LastName] ';
comment on column qu4_rep_load.middle_name is '[MiddleName] ';
comment on column qu4_rep_load.home_no is '[HomeNumber] ';
comment on column qu4_rep_load.mobile_no is '[MobileNumber] ';
comment on column qu4_rep_load.fax_no is '[FaxNumber] ';
comment on column qu4_rep_load.email is '[Email] ';
comment on column qu4_rep_load.pos_id is '[Position_ID] Position assigned to this rep.';
comment on column qu4_rep_load.full_name is '[FullName] Computed column containing the Contact Full Name';

-- Synonyms
create or replace public synonym qu4_rep_load for ods.qu4_rep_load;

-- Grants
grant select,insert,update,delete on ods.qu4_rep_load to ods_app;
grant select on ods.qu4_rep_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_rep_hist cascade constraints;

create table ods.qu4_rep_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  emp_no                          varchar2(50 char)               null,
  first_name                      varchar2(50 char)               null,
  last_name                       varchar2(50 char)               null,
  middle_name                     varchar2(50 char)               null,
  home_no                         varchar2(30 char)               null,
  mobile_no                       varchar2(30 char)               null,
  fax_no                          varchar2(30 char)               null,
  email                           varchar2(60 char)               null,
  pos_id                          number(10, 0)                   null,
  full_name                       varchar2(101 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_rep_hist add constraint qu4_rep_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_rep_hist_pk on ods.qu4_rep_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_rep_hist add constraint qu4_rep_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_rep_hist_uk on ods.qu4_rep_hist (id,q4x_batch_id)) compress;

create index ods.qu4_rep_hist_ts on ods.qu4_rep_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_rep_hist is '[Rep][HIST] Rep main information along with position attached.';
comment on column qu4_rep_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_rep_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_rep_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_rep_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_rep_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_rep_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_rep_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_rep_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_rep_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_rep_hist.is_active is '[IsActive] Indicates whether the rep is active. 0 = False, 1 = True.';
comment on column qu4_rep_hist.created_date is '[CreatedDate] ';
comment on column qu4_rep_hist.emp_no is '[EmployeeNumber] ';
comment on column qu4_rep_hist.first_name is '[FirstName] ';
comment on column qu4_rep_hist.last_name is '[LastName] ';
comment on column qu4_rep_hist.middle_name is '[MiddleName] ';
comment on column qu4_rep_hist.home_no is '[HomeNumber] ';
comment on column qu4_rep_hist.mobile_no is '[MobileNumber] ';
comment on column qu4_rep_hist.fax_no is '[FaxNumber] ';
comment on column qu4_rep_hist.email is '[Email] ';
comment on column qu4_rep_hist.pos_id is '[Position_ID] Position assigned to this rep.';
comment on column qu4_rep_hist.full_name is '[FullName] Computed column containing the Contact Full Name';

-- Synonyms
create or replace public synonym qu4_rep_hist for ods.qu4_rep_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_rep_hist to ods_app;
grant select on ods.qu4_rep_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
