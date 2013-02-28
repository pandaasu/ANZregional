
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_cust_visit_day
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_cust_visit_day] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_cust_visit_day cascade constraints;

create table ods.quo_cust_visit_day (
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
  cust_visit_id                   number(10, 0)                   null,
  cust_visit_id_lookup            varchar2(50 char)               null,
  days_between_visit              number(3, 0)                    null,
  visit_duration                  date                            null,
  note                            varchar2(200 char)              null,
  day_of_week                     number(3, 0)                    null,
  is_donot_call                   number(1, 0)                    null,
  is_appoint_reqd                 number(1, 0)                    null,
  visit_from                      date                            null,
  visit_to                        date                            null,
  cust_id                         number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_cust_visit_day add constraint quo_cust_visit_day_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_cust_visit_day_pk on ods.quo_cust_visit_day (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_cust_visit_day add constraint quo_cust_visit_day_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_cust_visit_day_uk on ods.quo_cust_visit_day (q4x_source_id,id)) compress;

create index ods.quo_cust_visit_day_ts on ods.quo_cust_visit_day (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_cust_visit_day is '[CustomerVisitorDay] Child file of customer. Contains information on preferred call days / times for a customer<\n><\n>This is a denormalized file which contains CustomerVisitor (parent) and CustomerVisitorDay (child) data combined';
comment on column quo_cust_visit_day.q4x_load_seq is '* Unique Load Id';
comment on column quo_cust_visit_day.q4x_load_data_seq is '* Data Record Id';
comment on column quo_cust_visit_day.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_cust_visit_day.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_cust_visit_day.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_cust_visit_day.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_cust_visit_day.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_cust_visit_day.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_cust_visit_day.q4x_timestamp is '* Timestamp';
comment on column quo_cust_visit_day.id is '[ID] Unique Internal ID for the row';
comment on column quo_cust_visit_day.id_lookup is '[ID_Lookup] ';
comment on column quo_cust_visit_day.cust_visit_id is '[CustomerVisitor_ID] ';
comment on column quo_cust_visit_day.cust_visit_id_lookup is '[CustomerVisitor_ID_Lookup] ';
comment on column quo_cust_visit_day.days_between_visit is '[DaysBetweenVisit] The number of days between visits to this customer by the person filling the role';
comment on column quo_cust_visit_day.visit_duration is '[VisitDuration] The expected duration of a visit.';
comment on column quo_cust_visit_day.note is '[Notes] ';
comment on column quo_cust_visit_day.day_of_week is '[DayOfWeek] The day of the week. Sunday = 1, Saturday = 7.';
comment on column quo_cust_visit_day.is_donot_call is '[IsDonotCall] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_cust_visit_day.is_appoint_reqd is '[IsAppointmentReqd] Is an appointment required to visit this customer in this role on this day';
comment on column quo_cust_visit_day.visit_from is '[VisitFrom] Earliest time of visit on this day. NULL means all day';
comment on column quo_cust_visit_day.visit_to is '[VisitTo] Latest time of visit on this day.';
comment on column quo_cust_visit_day.cust_id is '[Customer_Id] Mandatory Foreign key to the Id of the Customer';


-- Synonyms
create or replace public synonym quo_cust_visit_day for ods.quo_cust_visit_day;

-- Grants
grant select,update,delete,insert on ods.quo_cust_visit_day to ods_app;
grant select on ods.quo_cust_visit_day to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
