
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_rep
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_rep] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_rep cascade constraints;

create table ods.quo_rep (
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
  pos_id_lookup                   varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_rep add constraint quo_rep_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_rep_pk on ods.quo_rep (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_rep add constraint quo_rep_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_rep_uk on ods.quo_rep (q4x_source_id,id)) compress;

create index ods.quo_rep_ts on ods.quo_rep (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_rep is '[Rep] Rep main information along with position attached';
comment on column quo_rep.q4x_load_seq is '* Unique Load Id';
comment on column quo_rep.q4x_load_data_seq is '* Data Record Id';
comment on column quo_rep.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_rep.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_rep.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_rep.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_rep.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_rep.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_rep.q4x_timestamp is '* Timestamp';
comment on column quo_rep.id is '[ID] Unique Internal ID for the row';
comment on column quo_rep.id_lookup is '[ID_Lookup] ';
comment on column quo_rep.is_active is '[IsActive] Indicates whether the rep is active. 0 = False, 1 = True.';
comment on column quo_rep.created_date is '[CreatedDate] ';
comment on column quo_rep.emp_no is '[EmployeeNumber] ';
comment on column quo_rep.first_name is '[FirstName] ';
comment on column quo_rep.last_name is '[LastName] ';
comment on column quo_rep.middle_name is '[MiddleName] ';
comment on column quo_rep.home_no is '[HomeNumber] ';
comment on column quo_rep.mobile_no is '[MobileNumber] ';
comment on column quo_rep.fax_no is '[FaxNumber] ';
comment on column quo_rep.email is '[Email] ';
comment on column quo_rep.pos_id is '[Position_ID] Position assigned to this rep.';
comment on column quo_rep.pos_id_lookup is '[Position_ID_Lookup] ';
comment on column quo_rep.full_name is '[FullName] Computed column containing the Contact Full Name';


-- Synonyms
create or replace public synonym quo_rep for ods.quo_rep;

-- Grants
grant select,update,delete,insert on ods.quo_rep to ods_app;
grant select on ods.quo_rep to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
