
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_ord_hdr_load
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_ord_hdr_load] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_ord_hdr_load cascade constraints;

create table ods.quo_ord_hdr_load (
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
  actual_delivery_date            date                            null,
  callcard_id                     number(10, 0)                   null,
  callcard_id_lookup              varchar2(50 char)               null,
  city                            varchar2(50 char)               null,
  country_id                      number(10, 0)                   null,
  country_id_lookup               varchar2(50 char)               null,
  country_id_desc                 varchar2(50 char)               null,
  created_date                    date                            null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  varchar2(50 char)               null,
  cust_contact_id                 number(10, 0)                   null,
  cust_contact_id_lookup          varchar2(50 char)               null,
  delivery_note                   varchar2(200 char)              null,
  latitude                        number(9, 6)                    null,
  longitude                       number(9, 6)                    null,
  note                            varchar2(200 char)              null,
  ord_date                        date                            null,
  ord_no                          varchar2(50 char)               null,
  ord_ref                         varchar2(50 char)               null,
  ord_status_id                   number(10, 0)                   null,
  ord_status_id_lookup            varchar2(50 char)               null,
  ord_status_id_desc              varchar2(50 char)               null,
  ord_sub_type_id                 number(10, 0)                   null,
  ord_sub_type_id_lookup          varchar2(50 char)               null,
  ord_sub_type_id_desc            varchar2(50 char)               null,
  ord_type_id                     number(10, 0)                   null,
  ord_type_id_lookup              varchar2(50 char)               null,
  ord_type_id_desc                varchar2(50 char)               null,
  orig_delivery_date              date                            null,
  post_code                       varchar2(10 char)               null,
  rep_id                          number(10, 0)                   null,
  rep_id_lookup                   varchar2(50 char)               null,
  signature_id                    number(10, 0)                   null,
  signature_id_lookup             varchar2(50 char)               null,
  state_id                        number(10, 0)                   null,
  state_id_lookup                 varchar2(50 char)               null,
  state_id_desc                   varchar2(50 char)               null,
  street_1                        varchar2(50 char)               null,
  street_2                        varchar2(50 char)               null,
  town                            varchar2(50 char)               null,
  cust_id_desc                    varchar2(50 char)               null,
  full_name                       varchar2(101 char)              null,
  cust_copy_email                 number(1, 0)                    null,
  purchase_ord_no                 varchar2(31 char)               null,
  wholesaler_id                   number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_ord_hdr_load add constraint quo_ord_hdr_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_ord_hdr_load_pk on ods.quo_ord_hdr_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_ord_hdr_load add constraint quo_ord_hdr_load_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_ord_hdr_load_uk on ods.quo_ord_hdr_load (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_ord_hdr_load_ts on ods.quo_ord_hdr_load (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_ord_hdr_load is '[OrderHeader] Order transactional data';
comment on column quo_ord_hdr_load.q4x_load_seq is '* Unique Load Id';
comment on column quo_ord_hdr_load.q4x_load_data_seq is '* Data Record Id';
comment on column quo_ord_hdr_load.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_ord_hdr_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_ord_hdr_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_ord_hdr_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_ord_hdr_load.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_ord_hdr_load.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_ord_hdr_load.q4x_timestamp is '* Timestamp';
comment on column quo_ord_hdr_load.id is '[ID] Unique Internal ID for the row';
comment on column quo_ord_hdr_load.id_lookup is '[ID_Lookup] ';
comment on column quo_ord_hdr_load.actual_delivery_date is '[ActualDeliveryDate] The date of the delivery.';
comment on column quo_ord_hdr_load.callcard_id is '[CallCard_Id] Foreign key to [CallCard].[Id].';
comment on column quo_ord_hdr_load.callcard_id_lookup is '[CallCard_Id_Lookup] ';
comment on column quo_ord_hdr_load.city is '[City] The city or suburb of the address.';
comment on column quo_ord_hdr_load.country_id is '[CountryID] To find the LookupList and LookupListItem for Country list.';
comment on column quo_ord_hdr_load.country_id_lookup is '[CountryId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_ord_hdr_load.country_id_desc is '[CountryId_Description] Default language description of the node';
comment on column quo_ord_hdr_load.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_ord_hdr_load.cust_id is '[Customer_Id] Mandatory Foreign key to the Id of the Customer';
comment on column quo_ord_hdr_load.cust_id_lookup is '[Customer_Id_Lookup] ';
comment on column quo_ord_hdr_load.cust_contact_id is '[CustomerContact_Id] Foreign key to [CustomerContact].[Id].';
comment on column quo_ord_hdr_load.cust_contact_id_lookup is '[CustomerContact_Id_Lookup] ';
comment on column quo_ord_hdr_load.delivery_note is '[DeliveryNotes] Delivery Notes about the order';
comment on column quo_ord_hdr_load.latitude is '[Latitude] The GPS latitude of this address.';
comment on column quo_ord_hdr_load.longitude is '[Longitude] The GPS longitude of this address.';
comment on column quo_ord_hdr_load.note is '[Notes] ';
comment on column quo_ord_hdr_load.ord_date is '[OrderDate] The date of the order.';
comment on column quo_ord_hdr_load.ord_no is '[OrderNumber] The Id of the order as given to the customer.';
comment on column quo_ord_hdr_load.ord_ref is '[OrderReference] The order reference number or code.';
comment on column quo_ord_hdr_load.ord_status_id is '[OrderStatusId] To find the LookupList and LookupListItem for OrderStatus list.';
comment on column quo_ord_hdr_load.ord_status_id_lookup is '[OrderStatusId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_ord_hdr_load.ord_status_id_desc is '[OrderStatusId_Description] Default language description of the node';
comment on column quo_ord_hdr_load.ord_sub_type_id is '[OrderSubTypeId] To find the LookupList and LookupListItem for OrderSubType list.';
comment on column quo_ord_hdr_load.ord_sub_type_id_lookup is '[OrderSubTypeId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_ord_hdr_load.ord_sub_type_id_desc is '[OrderSubTypeId_Description] Default language description of the node';
comment on column quo_ord_hdr_load.ord_type_id is '[OrderTypeId] To find the LookupList and LookupListItem for OrderType list.';
comment on column quo_ord_hdr_load.ord_type_id_lookup is '[OrderTypeId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_ord_hdr_load.ord_type_id_desc is '[OrderTypeId_Description] Default language description of the node';
comment on column quo_ord_hdr_load.orig_delivery_date is '[OriginalDeliveryDate] The proposed delivery date of the order.';
comment on column quo_ord_hdr_load.post_code is '[Postcode] PostCode or Zip code of the address.';
comment on column quo_ord_hdr_load.rep_id is '[Rep_Id] Mandatory foreign key to [Rep].[Id].';
comment on column quo_ord_hdr_load.rep_id_lookup is '[Rep_Id_Lookup] ';
comment on column quo_ord_hdr_load.signature_id is '[Signature_Id] Foreign key to [Signature].[Id].';
comment on column quo_ord_hdr_load.signature_id_lookup is '[Signature_Id_Lookup] ';
comment on column quo_ord_hdr_load.state_id is '[StateId] To find the LookupList and LookupListItem for State list.';
comment on column quo_ord_hdr_load.state_id_lookup is '[StateId_Lookup] Integration ID, should be unique for all hierarchy nodes and roots';
comment on column quo_ord_hdr_load.state_id_desc is '[StateId_Description] Default language description of the node';
comment on column quo_ord_hdr_load.street_1 is '[Street1] Line 1 of the address.';
comment on column quo_ord_hdr_load.street_2 is '[Street2] Line 2 of the address.';
comment on column quo_ord_hdr_load.town is '[Town] The town/suburb of the address.';
comment on column quo_ord_hdr_load.cust_id_desc is '[Customer_ID_Description] ';
comment on column quo_ord_hdr_load.full_name is '[Fullname] ';
comment on column quo_ord_hdr_load.cust_copy_email is '[CustomerCopyEmail] Extended attribute to specify whether customer should be copied in order emails.';
comment on column quo_ord_hdr_load.purchase_ord_no is '[PurchaseOrderNbr] Extended attribute to specify purchase order number.';
comment on column quo_ord_hdr_load.wholesaler_id is '[Wholesaler_ID] ';


-- Synonyms
create or replace public synonym quo_ord_hdr_load for ods.quo_ord_hdr_load;

-- Grants
grant select,update,delete,insert on ods.quo_ord_hdr_load to ods_app;
grant select on ods.quo_ord_hdr_load to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
