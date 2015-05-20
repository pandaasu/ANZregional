
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_cust_visitor_day
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_cust_visitor_day] table creation script _load and _hist

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
drop table ods.qu5_cust_visitor_day_load cascade constraints;

create table ods.qu5_cust_visitor_day_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  day_of_week                     number(3, 0)                    null,
  is_do_not_call                  number(1, 0)                    null,
  is_appoint_reqd                 number(1, 0)                    null,
  visit_from                      date                            null,
  visit_to                        date                            null,
  cust_visitor_id                 number(10, 0)                   null,
  cust_id                         number(10, 0)                   not null,
  days_between_visit              number(3, 0)                    null,
  visit_duration                  date                            null,
  notes                           varchar2(200 char)              null,
  role_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_cust_visitor_day_load add constraint qu5_cust_visitor_day_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_cust_visitor_day_load_pk on ods.qu5_cust_visitor_day_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_cust_visitor_day_load add constraint qu5_cust_visitor_day_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_cust_visitor_day_load_uk on ods.qu5_cust_visitor_day_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_cust_visitor_day_load is '[CustomerVisitorDay][LOAD] Child file of customer. Contains information on preferred call days / times for a customer.<\n><\n>This is a denormalized file which contains CustomerVisitor (parent) and CustomerVisitorDay (child) data combined.';
comment on column qu5_cust_visitor_day_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_cust_visitor_day_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_cust_visitor_day_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_cust_visitor_day_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_cust_visitor_day_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_cust_visitor_day_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_cust_visitor_day_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_cust_visitor_day_load.q4x_timestamp is '* Timestamp';
comment on column qu5_cust_visitor_day_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_cust_visitor_day_load.day_of_week is '[DayOfWeek] The day of the week. Sunday = 1, Saturday = 7.';
comment on column qu5_cust_visitor_day_load.is_do_not_call is '[IsDoNotCall] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu5_cust_visitor_day_load.is_appoint_reqd is '[IsAppointmentReqd] Is an appointment required to visit this customer in this role on this day';
comment on column qu5_cust_visitor_day_load.visit_from is '[VisitFrom] Earliest time of visit on this day. NULL means all day';
comment on column qu5_cust_visitor_day_load.visit_to is '[VisitTo] Latest time of visit on this day.';
comment on column qu5_cust_visitor_day_load.cust_visitor_id is '[CustomerVisitor_Id] Internal Id for Customer Visitor Header Record';
comment on column qu5_cust_visitor_day_load.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu5_cust_visitor_day_load.days_between_visit is '[DaysBetweenVisit] The number of days between visits to this customer by the person filling the role';
comment on column qu5_cust_visitor_day_load.visit_duration is '[VisitDuration] The expected duration of a visit.';
comment on column qu5_cust_visitor_day_load.notes is '[Notes] Notes of the CustomerVisitorDay';
comment on column qu5_cust_visitor_day_load.role_id is '[Role_Id] Foreign Key from [Role].[Id]';

-- Synonyms
create or replace public synonym qu5_cust_visitor_day_load for ods.qu5_cust_visitor_day_load;

-- Grants
grant select,insert,update,delete on ods.qu5_cust_visitor_day_load to ods_app;
grant select on ods.qu5_cust_visitor_day_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_cust_visitor_day_hist cascade constraints;

create table ods.qu5_cust_visitor_day_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  day_of_week                     number(3, 0)                    null,
  is_do_not_call                  number(1, 0)                    null,
  is_appoint_reqd                 number(1, 0)                    null,
  visit_from                      date                            null,
  visit_to                        date                            null,
  cust_visitor_id                 number(10, 0)                   null,
  cust_id                         number(10, 0)                   not null,
  days_between_visit              number(3, 0)                    null,
  visit_duration                  date                            null,
  notes                           varchar2(200 char)              null,
  role_id                         number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_cust_visitor_day_hist add constraint qu5_cust_visitor_day_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_cust_visitor_day_hist_pk on ods.qu5_cust_visitor_day_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_cust_visitor_day_hist add constraint qu5_cust_visitor_day_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_cust_visitor_day_hist_uk on ods.qu5_cust_visitor_day_hist (id,q4x_batch_id)) compress;

create index ods.qu5_cust_visitor_day_hist_ts on ods.qu5_cust_visitor_day_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_cust_visitor_day_hist is '[CustomerVisitorDay][HIST] Child file of customer. Contains information on preferred call days / times for a customer.<\n><\n>This is a denormalized file which contains CustomerVisitor (parent) and CustomerVisitorDay (child) data combined.';
comment on column qu5_cust_visitor_day_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_cust_visitor_day_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_cust_visitor_day_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_cust_visitor_day_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_cust_visitor_day_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_cust_visitor_day_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_cust_visitor_day_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_cust_visitor_day_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_cust_visitor_day_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_cust_visitor_day_hist.day_of_week is '[DayOfWeek] The day of the week. Sunday = 1, Saturday = 7.';
comment on column qu5_cust_visitor_day_hist.is_do_not_call is '[IsDoNotCall] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu5_cust_visitor_day_hist.is_appoint_reqd is '[IsAppointmentReqd] Is an appointment required to visit this customer in this role on this day';
comment on column qu5_cust_visitor_day_hist.visit_from is '[VisitFrom] Earliest time of visit on this day. NULL means all day';
comment on column qu5_cust_visitor_day_hist.visit_to is '[VisitTo] Latest time of visit on this day.';
comment on column qu5_cust_visitor_day_hist.cust_visitor_id is '[CustomerVisitor_Id] Internal Id for Customer Visitor Header Record';
comment on column qu5_cust_visitor_day_hist.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu5_cust_visitor_day_hist.days_between_visit is '[DaysBetweenVisit] The number of days between visits to this customer by the person filling the role';
comment on column qu5_cust_visitor_day_hist.visit_duration is '[VisitDuration] The expected duration of a visit.';
comment on column qu5_cust_visitor_day_hist.notes is '[Notes] Notes of the CustomerVisitorDay';
comment on column qu5_cust_visitor_day_hist.role_id is '[Role_Id] Foreign Key from [Role].[Id]';

-- Synonyms
create or replace public synonym qu5_cust_visitor_day_hist for ods.qu5_cust_visitor_day_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_cust_visitor_day_hist to ods_app;
grant select on ods.qu5_cust_visitor_day_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
