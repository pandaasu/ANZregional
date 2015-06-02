
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_cust_contact
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_cust_contact] table creation script _load and _hist

    Both tables are transactional, with records temporarily stored in _load till
    the batch is complete, at which time they are moved permanently to _hist

    YYYY-MM-DD  Author                Description
    ----------  --------------------  ------------------------------------------
    2013-02-19  Mal Chambeyron        Created
    2014-05-15  Mal Chambeyron        Make into a Template
    2014-05-15  Mal Chambeyron        Cleanup Source Id
    2014-05-15  Mal Chambeyron        Updated to Handle Special Case [digest]
    2015-03-18  Mal Chambeyron        Remove Source Id Completely
    2015-05-26  [Auto-Generate]       [Auto-Generated] Created

  *****************************************************************************/

-- _load -----------------------------------------------------------------------

-- Table
drop table ods.qu3_cust_contact_load cascade constraints;

create table ods.qu3_cust_contact_load (
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
  cansign                         number(1, 0)                    null,
  cust_id                         number(10, 0)                   null,
  dept_id                         number(10, 0)                   null,
  dept_id_desc                    varchar2(50 char)               null,
  email                           varchar2(60 char)               null,
  first_name                      varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  last_name                       varchar2(50 char)               null,
  middle_name                     varchar2(50 char)               null,
  mobile_no                       varchar2(30 char)               null,
  phone_no                        varchar2(30 char)               null,
  photo_file_name                 varchar2(50 char)               null,
  pos_id                          number(10, 0)                   null,
  pos_id_desc                     varchar2(50 char)               null,
  pref_contact_method_id          number(10, 0)                   null,
  pref_contact_method_id_desc     varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu3_cust_contact_load add constraint qu3_cust_contact_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_cust_contact_load_pk on ods.qu3_cust_contact_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_cust_contact_load add constraint qu3_cust_contact_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_cust_contact_load_uk on ods.qu3_cust_contact_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_cust_contact_load is '[CustomerContact][LOAD] Child file of customer. Contains multiple contacts for a customer.';
comment on column qu3_cust_contact_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_cust_contact_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_cust_contact_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_cust_contact_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_cust_contact_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_cust_contact_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_cust_contact_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_cust_contact_load.q4x_timestamp is '* Timestamp';
comment on column qu3_cust_contact_load.id is '[ID] Unique Internal ID for the row';
comment on column qu3_cust_contact_load.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu3_cust_contact_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu3_cust_contact_load.cansign is '[CanSign] Indicates whether the contact has authority to sign. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu3_cust_contact_load.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu3_cust_contact_load.dept_id is '[DepartmentId] To find the LookupList and LookupListItem for Department List';
comment on column qu3_cust_contact_load.dept_id_desc is '[DepartmentId_Description] Default language description of the node';
comment on column qu3_cust_contact_load.email is '[Email] The email address';
comment on column qu3_cust_contact_load.first_name is '[FirstName] The first name of the contact';
comment on column qu3_cust_contact_load.full_name is '[FullName] Computed column containing the Contact Full Name';
comment on column qu3_cust_contact_load.last_name is '[LastName] The last name of the contact';
comment on column qu3_cust_contact_load.middle_name is '[MiddleName] The middle name of the contact (if provided).';
comment on column qu3_cust_contact_load.mobile_no is '[MobileNumber] Mobile or cell phone number';
comment on column qu3_cust_contact_load.phone_no is '[PhoneNumber] Phone number';
comment on column qu3_cust_contact_load.photo_file_name is '[PhotoFileName] The name of the file containing the image.';
comment on column qu3_cust_contact_load.pos_id is '[PositionId] To find the LookupList and LookupListItem for Position List';
comment on column qu3_cust_contact_load.pos_id_desc is '[PositionId_Description] Default language description of the node';
comment on column qu3_cust_contact_load.pref_contact_method_id is '[PreferredContactMethodID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu3_cust_contact_load.pref_contact_method_id_desc is '[PreferredContactMethodID_Description] Default language description of the node';
comment on column qu3_cust_contact_load.cust_id_desc is '[customer_id_description] ';

-- Synonyms
create or replace public synonym qu3_cust_contact_load for ods.qu3_cust_contact_load;

-- Grants
grant select,insert,update,delete on ods.qu3_cust_contact_load to ods_app;
grant select on ods.qu3_cust_contact_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_cust_contact_hist cascade constraints;

create table ods.qu3_cust_contact_hist (
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
  cansign                         number(1, 0)                    null,
  cust_id                         number(10, 0)                   null,
  dept_id                         number(10, 0)                   null,
  dept_id_desc                    varchar2(50 char)               null,
  email                           varchar2(60 char)               null,
  first_name                      varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  last_name                       varchar2(50 char)               null,
  middle_name                     varchar2(50 char)               null,
  mobile_no                       varchar2(30 char)               null,
  phone_no                        varchar2(30 char)               null,
  photo_file_name                 varchar2(50 char)               null,
  pos_id                          number(10, 0)                   null,
  pos_id_desc                     varchar2(50 char)               null,
  pref_contact_method_id          number(10, 0)                   null,
  pref_contact_method_id_desc     varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu3_cust_contact_hist add constraint qu3_cust_contact_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_cust_contact_hist_pk on ods.qu3_cust_contact_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_cust_contact_hist add constraint qu3_cust_contact_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_cust_contact_hist_uk on ods.qu3_cust_contact_hist (id,q4x_batch_id)) compress;

create index ods.qu3_cust_contact_hist_ts on ods.qu3_cust_contact_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_cust_contact_hist is '[CustomerContact][HIST] Child file of customer. Contains multiple contacts for a customer.';
comment on column qu3_cust_contact_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_cust_contact_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_cust_contact_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_cust_contact_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_cust_contact_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_cust_contact_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_cust_contact_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_cust_contact_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_cust_contact_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu3_cust_contact_hist.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column qu3_cust_contact_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu3_cust_contact_hist.cansign is '[CanSign] Indicates whether the contact has authority to sign. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column qu3_cust_contact_hist.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu3_cust_contact_hist.dept_id is '[DepartmentId] To find the LookupList and LookupListItem for Department List';
comment on column qu3_cust_contact_hist.dept_id_desc is '[DepartmentId_Description] Default language description of the node';
comment on column qu3_cust_contact_hist.email is '[Email] The email address';
comment on column qu3_cust_contact_hist.first_name is '[FirstName] The first name of the contact';
comment on column qu3_cust_contact_hist.full_name is '[FullName] Computed column containing the Contact Full Name';
comment on column qu3_cust_contact_hist.last_name is '[LastName] The last name of the contact';
comment on column qu3_cust_contact_hist.middle_name is '[MiddleName] The middle name of the contact (if provided).';
comment on column qu3_cust_contact_hist.mobile_no is '[MobileNumber] Mobile or cell phone number';
comment on column qu3_cust_contact_hist.phone_no is '[PhoneNumber] Phone number';
comment on column qu3_cust_contact_hist.photo_file_name is '[PhotoFileName] The name of the file containing the image.';
comment on column qu3_cust_contact_hist.pos_id is '[PositionId] To find the LookupList and LookupListItem for Position List';
comment on column qu3_cust_contact_hist.pos_id_desc is '[PositionId_Description] Default language description of the node';
comment on column qu3_cust_contact_hist.pref_contact_method_id is '[PreferredContactMethodID] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu3_cust_contact_hist.pref_contact_method_id_desc is '[PreferredContactMethodID_Description] Default language description of the node';
comment on column qu3_cust_contact_hist.cust_id_desc is '[customer_id_description] ';

-- Synonyms
create or replace public synonym qu3_cust_contact_hist for ods.qu3_cust_contact_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_cust_contact_hist to ods_app;
grant select on ods.qu3_cust_contact_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
