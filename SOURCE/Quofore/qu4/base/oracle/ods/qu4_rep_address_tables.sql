
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu4
    Owner    : ods
    Table    : qu4_rep_address
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu4] Quofore - Australia Chocolate
    [qu4_rep_address] table creation script _load and _hist

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
drop table ods.qu4_rep_address_load cascade constraints;

create table ods.qu4_rep_address_load (
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
  rep_id                          number(10, 0)                   not null,
  addrs_type_id                   number(10, 0)                   null,
  addrs_type_id_desc              varchar2(50 char)               null,
  street_1                        varchar2(50 char)               null,
  street_2                        varchar2(50 char)               null,
  town                            varchar2(50 char)               null,
  city                            varchar2(50 char)               null,
  post_code                       varchar2(10 char)               null,
  state_id                        number(10, 0)                   null,
  state_id_desc                   varchar2(50 char)               null,
  country_id                      number(10, 0)                   null,
  country_id_desc                 varchar2(50 char)               null,
  latitude                        number(9, 6)                    null,
  longitude                       number(9, 6)                    null,
  full_name                       varchar2(101 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_rep_address_load add constraint qu4_rep_address_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_rep_address_load_pk on ods.qu4_rep_address_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_rep_address_load add constraint qu4_rep_address_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_rep_address_load_uk on ods.qu4_rep_address_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu4_rep_address_load is '[RepAddress][LOAD] Child table of rep.';
comment on column qu4_rep_address_load.q4x_load_seq is '* Unique Load Id';
comment on column qu4_rep_address_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_rep_address_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_rep_address_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_rep_address_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_rep_address_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_rep_address_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_rep_address_load.q4x_timestamp is '* Timestamp';
comment on column qu4_rep_address_load.id is '[ID] Unique Internal ID for the row';
comment on column qu4_rep_address_load.is_active is '[IsActive] Indicates whether the rep address is active. 0 = False, 1 = True.';
comment on column qu4_rep_address_load.rep_id is '[Rep_ID] Mandatory foreign key. ID of the rep this address belongs to.';
comment on column qu4_rep_address_load.addrs_type_id is '[AddressTypeID] To find the LookupList and LookupListItem this field is mapped to.<\n>Different address types can be assigned to a rep but same address type should not repeat.';
comment on column qu4_rep_address_load.addrs_type_id_desc is '[AddressTypeID_Description] Language Description in default system language';
comment on column qu4_rep_address_load.street_1 is '[Street1] ';
comment on column qu4_rep_address_load.street_2 is '[Street2] ';
comment on column qu4_rep_address_load.town is '[Town] ';
comment on column qu4_rep_address_load.city is '[City] ';
comment on column qu4_rep_address_load.post_code is '[PostCode] ';
comment on column qu4_rep_address_load.state_id is '[StateId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_rep_address_load.state_id_desc is '[StateId_Description] Language Description in default system language';
comment on column qu4_rep_address_load.country_id is '[CountryId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_rep_address_load.country_id_desc is '[CountryId_Description] Language Description in default system language';
comment on column qu4_rep_address_load.latitude is '[Latitude] The GPS latitude of this address.';
comment on column qu4_rep_address_load.longitude is '[Longitude] The GPS longitude of this address.';
comment on column qu4_rep_address_load.full_name is '[FullName] Computed column containing the Rep Full Name';

-- Synonyms
create or replace public synonym qu4_rep_address_load for ods.qu4_rep_address_load;

-- Grants
grant select,insert,update,delete on ods.qu4_rep_address_load to ods_app;
grant select on ods.qu4_rep_address_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu4_rep_address_hist cascade constraints;

create table ods.qu4_rep_address_hist (
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
  rep_id                          number(10, 0)                   not null,
  addrs_type_id                   number(10, 0)                   null,
  addrs_type_id_desc              varchar2(50 char)               null,
  street_1                        varchar2(50 char)               null,
  street_2                        varchar2(50 char)               null,
  town                            varchar2(50 char)               null,
  city                            varchar2(50 char)               null,
  post_code                       varchar2(10 char)               null,
  state_id                        number(10, 0)                   null,
  state_id_desc                   varchar2(50 char)               null,
  country_id                      number(10, 0)                   null,
  country_id_desc                 varchar2(50 char)               null,
  latitude                        number(9, 6)                    null,
  longitude                       number(9, 6)                    null,
  full_name                       varchar2(101 char)              null
)
compress;

-- Keys / Indexes
alter table ods.qu4_rep_address_hist add constraint qu4_rep_address_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu4_rep_address_hist_pk on ods.qu4_rep_address_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu4_rep_address_hist add constraint qu4_rep_address_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu4_rep_address_hist_uk on ods.qu4_rep_address_hist (id,q4x_batch_id)) compress;

create index ods.qu4_rep_address_hist_ts on ods.qu4_rep_address_hist (q4x_timestamp) compress;

-- Comments
comment on table qu4_rep_address_hist is '[RepAddress][HIST] Child table of rep.';
comment on column qu4_rep_address_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu4_rep_address_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu4_rep_address_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu4_rep_address_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu4_rep_address_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu4_rep_address_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu4_rep_address_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu4_rep_address_hist.q4x_timestamp is '* Timestamp';
comment on column qu4_rep_address_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu4_rep_address_hist.is_active is '[IsActive] Indicates whether the rep address is active. 0 = False, 1 = True.';
comment on column qu4_rep_address_hist.rep_id is '[Rep_ID] Mandatory foreign key. ID of the rep this address belongs to.';
comment on column qu4_rep_address_hist.addrs_type_id is '[AddressTypeID] To find the LookupList and LookupListItem this field is mapped to.<\n>Different address types can be assigned to a rep but same address type should not repeat.';
comment on column qu4_rep_address_hist.addrs_type_id_desc is '[AddressTypeID_Description] Language Description in default system language';
comment on column qu4_rep_address_hist.street_1 is '[Street1] ';
comment on column qu4_rep_address_hist.street_2 is '[Street2] ';
comment on column qu4_rep_address_hist.town is '[Town] ';
comment on column qu4_rep_address_hist.city is '[City] ';
comment on column qu4_rep_address_hist.post_code is '[PostCode] ';
comment on column qu4_rep_address_hist.state_id is '[StateId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_rep_address_hist.state_id_desc is '[StateId_Description] Language Description in default system language';
comment on column qu4_rep_address_hist.country_id is '[CountryId] To find the LookupList and LookupListItem this field is mapped to';
comment on column qu4_rep_address_hist.country_id_desc is '[CountryId_Description] Language Description in default system language';
comment on column qu4_rep_address_hist.latitude is '[Latitude] The GPS latitude of this address.';
comment on column qu4_rep_address_hist.longitude is '[Longitude] The GPS longitude of this address.';
comment on column qu4_rep_address_hist.full_name is '[FullName] Computed column containing the Rep Full Name';

-- Synonyms
create or replace public synonym qu4_rep_address_hist for ods.qu4_rep_address_hist;

-- Grants
grant select,insert,update,delete on ods.qu4_rep_address_hist to ods_app;
grant select on ods.qu4_rep_address_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
