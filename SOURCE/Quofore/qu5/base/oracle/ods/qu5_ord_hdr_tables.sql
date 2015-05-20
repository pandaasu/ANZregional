
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_ord_hdr
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_ord_hdr] table creation script _load and _hist

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
drop table ods.qu5_ord_hdr_load cascade constraints;

create table ods.qu5_ord_hdr_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  actual_delivery_date            date                            null,
  callcard_id                     number(10, 0)                   null,
  city                            varchar2(50 char)               null,
  country_id                      number(10, 0)                   null,
  country_id_desc                 varchar2(50 char)               null,
  created_date                    date                            null,
  cust_id                         number(10, 0)                   not null,
  cust_contact_id                 number(10, 0)                   null,
  delivery_notes                  varchar2(200 char)              null,
  latitude                        number(9, 6)                    null,
  longitude                       number(9, 6)                    null,
  notes                           varchar2(200 char)              null,
  ord_date                        date                            null,
  ord_no                          varchar2(50 char)               null,
  ord_ref                         varchar2(50 char)               null,
  ord_status_id                   number(10, 0)                   null,
  ord_status_id_desc              varchar2(50 char)               null,
  ord_sub_type_id                 number(10, 0)                   null,
  ord_sub_type_id_desc            varchar2(50 char)               null,
  ord_type_id                     number(10, 0)                   null,
  ord_type_id_desc                varchar2(50 char)               null,
  original_delivery_date          date                            null,
  postcode                        varchar2(10 char)               null,
  rep_id                          number(10, 0)                   not null,
  state_id                        number(10, 0)                   null,
  state_id_desc                   varchar2(50 char)               null,
  street_1                        varchar2(50 char)               null,
  street_2                        varchar2(50 char)               null,
  town                            varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  wholesaler_id                   number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_ord_hdr_load add constraint qu5_ord_hdr_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_ord_hdr_load_pk on ods.qu5_ord_hdr_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_ord_hdr_load add constraint qu5_ord_hdr_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_ord_hdr_load_uk on ods.qu5_ord_hdr_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_ord_hdr_load is '[OrderHeader][LOAD] Order transactional data.';
comment on column qu5_ord_hdr_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_ord_hdr_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_ord_hdr_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_ord_hdr_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_ord_hdr_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_ord_hdr_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_ord_hdr_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_ord_hdr_load.q4x_timestamp is '* Timestamp';
comment on column qu5_ord_hdr_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_ord_hdr_load.actual_delivery_date is '[ActualDeliveryDate] The date of the delivery.';
comment on column qu5_ord_hdr_load.callcard_id is '[CallCard_Id] Foreign key from [CallCard].[Id].';
comment on column qu5_ord_hdr_load.city is '[City] The city or suburb of the address.';
comment on column qu5_ord_hdr_load.country_id is '[CountryId] To find the LookupList and LookupListItem for Country list.';
comment on column qu5_ord_hdr_load.country_id_desc is '[CountryId_Description] Default language description of the node';
comment on column qu5_ord_hdr_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_ord_hdr_load.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu5_ord_hdr_load.cust_contact_id is '[CustomerContact_Id] Foreign key from [CustomerContact].[Id].';
comment on column qu5_ord_hdr_load.delivery_notes is '[DeliveryNotes] Delivery Notes about the order';
comment on column qu5_ord_hdr_load.latitude is '[Latitude] The GPS latitude of this address.';
comment on column qu5_ord_hdr_load.longitude is '[Longitude] The GPS longitude of this address.';
comment on column qu5_ord_hdr_load.notes is '[Notes] Notes of the OrderHeader';
comment on column qu5_ord_hdr_load.ord_date is '[OrderDate] The date of the order.';
comment on column qu5_ord_hdr_load.ord_no is '[OrderNumber] The Id of the order as given to the customer.';
comment on column qu5_ord_hdr_load.ord_ref is '[OrderReference] The order reference number or code.';
comment on column qu5_ord_hdr_load.ord_status_id is '[OrderStatusId] To find the LookupList and LookupListItem for OrderStatus list.';
comment on column qu5_ord_hdr_load.ord_status_id_desc is '[OrderStatusId_Description] Default language description of the node';
comment on column qu5_ord_hdr_load.ord_sub_type_id is '[OrderSubTypeId] To find the LookupList and LookupListItem for OrderSubType list.';
comment on column qu5_ord_hdr_load.ord_sub_type_id_desc is '[OrderSubTypeId_Description] Default language description of the node';
comment on column qu5_ord_hdr_load.ord_type_id is '[OrderTypeId] To find the LookupList and LookupListItem for OrderType list.';
comment on column qu5_ord_hdr_load.ord_type_id_desc is '[OrderTypeId_Description] Default language description of the node';
comment on column qu5_ord_hdr_load.original_delivery_date is '[OriginalDeliveryDate] The proposed delivery date of the order.';
comment on column qu5_ord_hdr_load.postcode is '[Postcode] PostCode or Zip code of the address.';
comment on column qu5_ord_hdr_load.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu5_ord_hdr_load.state_id is '[StateId] To find the LookupList and LookupListItem for State list.';
comment on column qu5_ord_hdr_load.state_id_desc is '[StateId_Description] Default language description of the node';
comment on column qu5_ord_hdr_load.street_1 is '[Street1] Line 1 of the address.';
comment on column qu5_ord_hdr_load.street_2 is '[Street2] Line 2 of the address.';
comment on column qu5_ord_hdr_load.town is '[Town] The town/suburb of the address.';
comment on column qu5_ord_hdr_load.cust_id_desc is '[Customer_Id_Description] Customer Id Description of the OrderHeader';
comment on column qu5_ord_hdr_load.full_name is '[Fullname] Fullname of the OrderHeader';
comment on column qu5_ord_hdr_load.wholesaler_id is '[Wholesaler_Id] Whether the Customer is a Wholesaler or Not.';

-- Synonyms
create or replace public synonym qu5_ord_hdr_load for ods.qu5_ord_hdr_load;

-- Grants
grant select,insert,update,delete on ods.qu5_ord_hdr_load to ods_app;
grant select on ods.qu5_ord_hdr_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_ord_hdr_hist cascade constraints;

create table ods.qu5_ord_hdr_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  actual_delivery_date            date                            null,
  callcard_id                     number(10, 0)                   null,
  city                            varchar2(50 char)               null,
  country_id                      number(10, 0)                   null,
  country_id_desc                 varchar2(50 char)               null,
  created_date                    date                            null,
  cust_id                         number(10, 0)                   not null,
  cust_contact_id                 number(10, 0)                   null,
  delivery_notes                  varchar2(200 char)              null,
  latitude                        number(9, 6)                    null,
  longitude                       number(9, 6)                    null,
  notes                           varchar2(200 char)              null,
  ord_date                        date                            null,
  ord_no                          varchar2(50 char)               null,
  ord_ref                         varchar2(50 char)               null,
  ord_status_id                   number(10, 0)                   null,
  ord_status_id_desc              varchar2(50 char)               null,
  ord_sub_type_id                 number(10, 0)                   null,
  ord_sub_type_id_desc            varchar2(50 char)               null,
  ord_type_id                     number(10, 0)                   null,
  ord_type_id_desc                varchar2(50 char)               null,
  original_delivery_date          date                            null,
  postcode                        varchar2(10 char)               null,
  rep_id                          number(10, 0)                   not null,
  state_id                        number(10, 0)                   null,
  state_id_desc                   varchar2(50 char)               null,
  street_1                        varchar2(50 char)               null,
  street_2                        varchar2(50 char)               null,
  town                            varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  wholesaler_id                   number(10, 0)                   null
)
compress;

-- Keys / Indexes
alter table ods.qu5_ord_hdr_hist add constraint qu5_ord_hdr_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_ord_hdr_hist_pk on ods.qu5_ord_hdr_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_ord_hdr_hist add constraint qu5_ord_hdr_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_ord_hdr_hist_uk on ods.qu5_ord_hdr_hist (id,q4x_batch_id)) compress;

create index ods.qu5_ord_hdr_hist_ts on ods.qu5_ord_hdr_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_ord_hdr_hist is '[OrderHeader][HIST] Order transactional data.';
comment on column qu5_ord_hdr_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_ord_hdr_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_ord_hdr_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_ord_hdr_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_ord_hdr_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_ord_hdr_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_ord_hdr_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_ord_hdr_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_ord_hdr_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_ord_hdr_hist.actual_delivery_date is '[ActualDeliveryDate] The date of the delivery.';
comment on column qu5_ord_hdr_hist.callcard_id is '[CallCard_Id] Foreign key from [CallCard].[Id].';
comment on column qu5_ord_hdr_hist.city is '[City] The city or suburb of the address.';
comment on column qu5_ord_hdr_hist.country_id is '[CountryId] To find the LookupList and LookupListItem for Country list.';
comment on column qu5_ord_hdr_hist.country_id_desc is '[CountryId_Description] Default language description of the node';
comment on column qu5_ord_hdr_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column qu5_ord_hdr_hist.cust_id is '[Customer_Id] Mandatory Foreign key from [Customer].[Id]';
comment on column qu5_ord_hdr_hist.cust_contact_id is '[CustomerContact_Id] Foreign key from [CustomerContact].[Id].';
comment on column qu5_ord_hdr_hist.delivery_notes is '[DeliveryNotes] Delivery Notes about the order';
comment on column qu5_ord_hdr_hist.latitude is '[Latitude] The GPS latitude of this address.';
comment on column qu5_ord_hdr_hist.longitude is '[Longitude] The GPS longitude of this address.';
comment on column qu5_ord_hdr_hist.notes is '[Notes] Notes of the OrderHeader';
comment on column qu5_ord_hdr_hist.ord_date is '[OrderDate] The date of the order.';
comment on column qu5_ord_hdr_hist.ord_no is '[OrderNumber] The Id of the order as given to the customer.';
comment on column qu5_ord_hdr_hist.ord_ref is '[OrderReference] The order reference number or code.';
comment on column qu5_ord_hdr_hist.ord_status_id is '[OrderStatusId] To find the LookupList and LookupListItem for OrderStatus list.';
comment on column qu5_ord_hdr_hist.ord_status_id_desc is '[OrderStatusId_Description] Default language description of the node';
comment on column qu5_ord_hdr_hist.ord_sub_type_id is '[OrderSubTypeId] To find the LookupList and LookupListItem for OrderSubType list.';
comment on column qu5_ord_hdr_hist.ord_sub_type_id_desc is '[OrderSubTypeId_Description] Default language description of the node';
comment on column qu5_ord_hdr_hist.ord_type_id is '[OrderTypeId] To find the LookupList and LookupListItem for OrderType list.';
comment on column qu5_ord_hdr_hist.ord_type_id_desc is '[OrderTypeId_Description] Default language description of the node';
comment on column qu5_ord_hdr_hist.original_delivery_date is '[OriginalDeliveryDate] The proposed delivery date of the order.';
comment on column qu5_ord_hdr_hist.postcode is '[Postcode] PostCode or Zip code of the address.';
comment on column qu5_ord_hdr_hist.rep_id is '[Rep_Id] Mandatory foreign key from [Rep].[Id].';
comment on column qu5_ord_hdr_hist.state_id is '[StateId] To find the LookupList and LookupListItem for State list.';
comment on column qu5_ord_hdr_hist.state_id_desc is '[StateId_Description] Default language description of the node';
comment on column qu5_ord_hdr_hist.street_1 is '[Street1] Line 1 of the address.';
comment on column qu5_ord_hdr_hist.street_2 is '[Street2] Line 2 of the address.';
comment on column qu5_ord_hdr_hist.town is '[Town] The town/suburb of the address.';
comment on column qu5_ord_hdr_hist.cust_id_desc is '[Customer_Id_Description] Customer Id Description of the OrderHeader';
comment on column qu5_ord_hdr_hist.full_name is '[Fullname] Fullname of the OrderHeader';
comment on column qu5_ord_hdr_hist.wholesaler_id is '[Wholesaler_Id] Whether the Customer is a Wholesaler or Not.';

-- Synonyms
create or replace public synonym qu5_ord_hdr_hist for ods.qu5_ord_hdr_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_ord_hdr_hist to ods_app;
grant select on ods.qu5_ord_hdr_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
