
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_rep_addrs_load
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_rep_addrs_load] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_rep_addrs_load cascade constraints;

create table ods.quo_rep_addrs_load (
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
  rep_id                          number(10, 0)                   null,
  rep_id_lookup                   varchar2(50 char)               null,
  addrs_type_id                   number(10, 0)                   null,
  addrs_type_id_lookup            varchar2(50 char)               null,
  addrs_type_id_desc              varchar2(50 char)               null,
  street_1                        varchar2(50 char)               null,
  street_2                        varchar2(50 char)               null,
  town                            varchar2(50 char)               null,
  city                            varchar2(50 char)               null,
  post_code                       varchar2(10 char)               null,
  state_id                        number(10, 0)                   null,
  state_id_lookup                 varchar2(50 char)               null,
  state_id_desc                   varchar2(50 char)               null,
  country_id                      number(10, 0)                   null,
  country_id_lookup               varchar2(50 char)               null,
  country_id_desc                 varchar2(50 char)               null,
  latitude                        number(9, 6)                    null,
  longitude                       number(9, 6)                    null,
  full_name                       varchar2(101 char)              null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_rep_addrs_load add constraint quo_rep_addrs_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_rep_addrs_load_pk on ods.quo_rep_addrs_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_rep_addrs_load add constraint quo_rep_addrs_load_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_rep_addrs_load_uk on ods.quo_rep_addrs_load (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_rep_addrs_load_ts on ods.quo_rep_addrs_load (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_rep_addrs_load is '[RepAddress] Child table of rep';
comment on column quo_rep_addrs_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_rep_addrs_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_rep_addrs_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_rep_addrs_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_rep_addrs_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_rep_addrs_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_rep_addrs_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_rep_addrs_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_rep_addrs_load.q4x_timestamp is '* Timestamp';
comment on column quo_rep_addrs_load.id is '[ID] Unique Internal ID for the row';
comment on column quo_rep_addrs_load.id_lookup is '[ID_Lookup] ';
comment on column quo_rep_addrs_load.is_active is '[IsActive] Indicates whether the rep address is active. 0 = False, 1 = True.';
comment on column quo_rep_addrs_load.rep_id is '[Rep_ID] Mandatory foreign key. ID of the rep this address belongs to.';
comment on column quo_rep_addrs_load.rep_id_lookup is '[Rep_ID_Lookup] ';
comment on column quo_rep_addrs_load.addrs_type_id is '[AddressTypeID] To find the LookupList and LookupListItem this field is mapped to.<\n>Different address types can be assigned to a rep but same address type should not repeat.';
comment on column quo_rep_addrs_load.addrs_type_id_lookup is '[AddressTypeID_Lookup] Integration Id, Should be unique for all Lookup List Items';
comment on column quo_rep_addrs_load.addrs_type_id_desc is '[AddressTypeID_Description] Language Description in default system language';
comment on column quo_rep_addrs_load.street_1 is '[Street1] ';
comment on column quo_rep_addrs_load.street_2 is '[Street2] ';
comment on column quo_rep_addrs_load.town is '[Town] ';
comment on column quo_rep_addrs_load.city is '[City] ';
comment on column quo_rep_addrs_load.post_code is '[PostCode] ';
comment on column quo_rep_addrs_load.state_id is '[StateId] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_rep_addrs_load.state_id_lookup is '[StateId_Lookup] Integration Id, Should be unique for all Lookup List Items';
comment on column quo_rep_addrs_load.state_id_desc is '[StateId_Description] Language Description in default system language';
comment on column quo_rep_addrs_load.country_id is '[CountryId] To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_rep_addrs_load.country_id_lookup is '[CountryId_Lookup] Integration Id, Should be unique for all Lookup List Items';
comment on column quo_rep_addrs_load.country_id_desc is '[CountryId_Description] Language Description in default system language';
comment on column quo_rep_addrs_load.latitude is '[Latitude] The GPS latitude of this address.';
comment on column quo_rep_addrs_load.longitude is '[Longitude] The GPS longitude of this address.';
comment on column quo_rep_addrs_load.full_name is '[FullName] Computed column containing the Rep Full Name';


-- Synonyms
create or replace public synonym quo_rep_addrs_load for ods.quo_rep_addrs_load;

-- Grants
grant select,update,delete,insert on ods.quo_rep_addrs_load to ods_app;
grant select on ods.quo_rep_addrs_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
