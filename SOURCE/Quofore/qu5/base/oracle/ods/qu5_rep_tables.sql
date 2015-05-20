
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_rep
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_rep] table creation script _load and _hist

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
drop table ods.qu5_rep_load cascade constraints;

create table ods.qu5_rep_load (
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
alter table ods.qu5_rep_load add constraint qu5_rep_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_rep_load_pk on ods.qu5_rep_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_rep_load add constraint qu5_rep_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_rep_load_uk on ods.qu5_rep_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_rep_load is '[Rep][LOAD] Rep main information along with position attached.';
comment on column qu5_rep_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_rep_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_rep_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_rep_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_rep_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_rep_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_rep_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_rep_load.q4x_timestamp is '* Timestamp';
comment on column qu5_rep_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_rep_load.is_active is '[IsActive] Indicates whether the rep is active. 0 = False, 1 = True.';
comment on column qu5_rep_load.created_date is '[CreatedDate] When the Rep was Created in the System';
comment on column qu5_rep_load.emp_no is '[EmployeeNumber] Employee Number of the Rep';
comment on column qu5_rep_load.first_name is '[FirstName] First Name of the Rep';
comment on column qu5_rep_load.last_name is '[LastName] Last Name of the Rep';
comment on column qu5_rep_load.middle_name is '[MiddleName] Middle Name of the Rep';
comment on column qu5_rep_load.home_no is '[HomeNumber] Home Number of the Rep';
comment on column qu5_rep_load.mobile_no is '[MobileNumber] Mobile Number of the Rep';
comment on column qu5_rep_load.fax_no is '[FaxNumber] Fax Number of the Rep';
comment on column qu5_rep_load.email is '[Email] Email of the Rep';
comment on column qu5_rep_load.pos_id is '[Position_Id] Foreign Key from [Position].[Id]';
comment on column qu5_rep_load.full_name is '[FullName] Computed column containing the Contact Full Name';

-- Synonyms
create or replace public synonym qu5_rep_load for ods.qu5_rep_load;

-- Grants
grant select,insert,update,delete on ods.qu5_rep_load to ods_app;
grant select on ods.qu5_rep_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_rep_hist cascade constraints;

create table ods.qu5_rep_hist (
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
alter table ods.qu5_rep_hist add constraint qu5_rep_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_rep_hist_pk on ods.qu5_rep_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_rep_hist add constraint qu5_rep_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_rep_hist_uk on ods.qu5_rep_hist (id,q4x_batch_id)) compress;

create index ods.qu5_rep_hist_ts on ods.qu5_rep_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_rep_hist is '[Rep][HIST] Rep main information along with position attached.';
comment on column qu5_rep_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_rep_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_rep_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_rep_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_rep_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_rep_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_rep_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_rep_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_rep_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_rep_hist.is_active is '[IsActive] Indicates whether the rep is active. 0 = False, 1 = True.';
comment on column qu5_rep_hist.created_date is '[CreatedDate] When the Rep was Created in the System';
comment on column qu5_rep_hist.emp_no is '[EmployeeNumber] Employee Number of the Rep';
comment on column qu5_rep_hist.first_name is '[FirstName] First Name of the Rep';
comment on column qu5_rep_hist.last_name is '[LastName] Last Name of the Rep';
comment on column qu5_rep_hist.middle_name is '[MiddleName] Middle Name of the Rep';
comment on column qu5_rep_hist.home_no is '[HomeNumber] Home Number of the Rep';
comment on column qu5_rep_hist.mobile_no is '[MobileNumber] Mobile Number of the Rep';
comment on column qu5_rep_hist.fax_no is '[FaxNumber] Fax Number of the Rep';
comment on column qu5_rep_hist.email is '[Email] Email of the Rep';
comment on column qu5_rep_hist.pos_id is '[Position_Id] Foreign Key from [Position].[Id]';
comment on column qu5_rep_hist.full_name is '[FullName] Computed column containing the Contact Full Name';

-- Synonyms
create or replace public synonym qu5_rep_hist for ods.qu5_rep_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_rep_hist to ods_app;
grant select on ods.qu5_rep_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
