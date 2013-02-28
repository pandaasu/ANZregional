
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_cust_contact
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_cust_contact] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_cust_contact cascade constraints;

create table ods.quo_cust_contact (
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
  is_active                       number(1, 0)                    null,
  created_date                    date                            null,
  cansign                         number(1, 0)                    null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  varchar2(50 char)               null,
  dept_id                         number(10, 0)                   null,
  dept_id_lookup                  varchar2(50 char)               null,
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
  pos_id_lookup                   varchar2(50 char)               null,
  pos_id_desc                     varchar2(50 char)               null,
  pref_contact_method_id          number(10, 0)                   null,
  pref_contact_method_id_lookup   varchar2(50 char)               null,
  pref_contact_method_id_desc     varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_cust_contact add constraint quo_cust_contact_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_cust_contact_pk on ods.quo_cust_contact (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_cust_contact add constraint quo_cust_contact_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_cust_contact_uk on ods.quo_cust_contact (q4x_source_id,id)) compress;

create index ods.quo_cust_contact_ts on ods.quo_cust_contact (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_cust_contact is '[CustomerContact] Child file of customer. Contains multiple contacts for a customer.';
comment on column quo_cust_contact.q4x_load_seq is '* Unique Load Id';
comment on column quo_cust_contact.q4x_load_data_seq is '* Data Record Id';
comment on column quo_cust_contact.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_cust_contact.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_cust_contact.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_cust_contact.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_cust_contact.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_cust_contact.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_cust_contact.q4x_timestamp is '* Timestamp';
comment on column quo_cust_contact.id is '[ID] Unique Internal ID for the row';
comment on column quo_cust_contact.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_cust_contact.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_cust_contact.cansign is '[CanSign] Indicates whether the contact has authority to sign. 0 indicates False, 1 indicates True. Null is not allowed';
comment on column quo_cust_contact.cust_id is '[Customer_Id] Mandatory Foreign key to the Id of the Customer';
comment on column quo_cust_contact.cust_id_lookup is '[Customer_Id_Lookup] ';
comment on column quo_cust_contact.dept_id is '[DepartmentId] To find the LookupList and LookupListItem for Department List';
comment on column quo_cust_contact.dept_id_lookup is '[DepartmentId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_cust_contact.dept_id_desc is '[DepartmentId_Description] Default language description of the node';
comment on column quo_cust_contact.email is '[Email] The email address';
comment on column quo_cust_contact.first_name is '[FirstName] The first name of the contact';
comment on column quo_cust_contact.full_name is '[FullName] Computed column containing the Contact Full Name';
comment on column quo_cust_contact.last_name is '[LastName] The last name of the contact';
comment on column quo_cust_contact.middle_name is '[MiddleName] The middle name of the contact (if provided).';
comment on column quo_cust_contact.mobile_no is '[MobileNumber] Mobile or cell phone number';
comment on column quo_cust_contact.phone_no is '[PhoneNumber] Phone number';
comment on column quo_cust_contact.photo_file_name is '[PhotoFileName] The name of the file containing the image.';
comment on column quo_cust_contact.pos_id is '[PositionId] To find the LookupList and LookupListItem for Position List';
comment on column quo_cust_contact.pos_id_lookup is '[PositionId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_cust_contact.pos_id_desc is '[PositionId_Description] Default language description of the node';
comment on column quo_cust_contact.pref_contact_method_id is '[PreferredContactMethodID] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_cust_contact.pref_contact_method_id_lookup is '[PreferredContactMethodID_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_cust_contact.pref_contact_method_id_desc is '[PreferredContactMethodID_Description] Default language description of the node';
comment on column quo_cust_contact.cust_id_desc is '[customer_id_description] ';


-- Synonyms
create or replace public synonym quo_cust_contact for ods.quo_cust_contact;

-- Grants
grant select,update,delete,insert on ods.quo_cust_contact to ods_app;
grant select on ods.quo_cust_contact to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
