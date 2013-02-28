
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_cust
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_cust] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_cust cascade constraints;

create table ods.quo_cust (
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
  cust_name                       varchar2(50 char)               null,
  cust_ref_id                     varchar2(10 char)               null,
  email                           varchar2(60 char)               null,
  fax_no                          varchar2(30 char)               null,
  group_edi_code                  varchar2(50 char)               null,
  outlet_ref_id                   varchar2(10 char)               null,
  phone_no                        varchar2(30 char)               null,
  store_edi_code                  varchar2(50 char)               null,
  web_addrs                       varchar2(60 char)               null,
  cust_hier_id                    number(10, 0)                   null,
  grade_hier_id                   number(10, 0)                   null,
  grd_code                        varchar2(50 char)               null,
  lead_time                       number(3, 0)                    null,
  xml_attach                      number(1, 0)                    null,
  is_wholesaler                   number(1, 0)                    null,
  call_frequency                  number(10, 0)                   null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_cust add constraint quo_cust_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_cust_pk on ods.quo_cust (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_cust add constraint quo_cust_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_cust_uk on ods.quo_cust (q4x_source_id,id)) compress;

create index ods.quo_cust_ts on ods.quo_cust (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_cust is '[Customer] Customer master data';
comment on column quo_cust.q4x_load_seq is '* Unique Load Id';
comment on column quo_cust.q4x_load_data_seq is '* Data Record Id';
comment on column quo_cust.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_cust.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_cust.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_cust.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_cust.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_cust.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_cust.q4x_timestamp is '* Timestamp';
comment on column quo_cust.id is '[Id] Unique Internal ID for the row';
comment on column quo_cust.id_lookup is '[Id_Lookup] ';
comment on column quo_cust.is_active is '[IsActive] Not null. Indicates whether the record is active. 0 = False, 1 = True.';
comment on column quo_cust.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_cust.cust_name is '[CustomerName] The name of the Customer';
comment on column quo_cust.cust_ref_id is '[CustomerRefID] The customer reference code.';
comment on column quo_cust.email is '[Email] The email address';
comment on column quo_cust.fax_no is '[FaxNumber] Fax number';
comment on column quo_cust.group_edi_code is '[GroupEDICode] The EDI code for the Group of stores';
comment on column quo_cust.outlet_ref_id is '[OutletRefID] The Id the customer refers to itself by';
comment on column quo_cust.phone_no is '[PhoneNumber] Phone number';
comment on column quo_cust.store_edi_code is '[StoreEDICode] The Store EDI code.';
comment on column quo_cust.web_addrs is '[WebAddress] The customer''s web address';
comment on column quo_cust.cust_hier_id is '[CustomerHierarchy_Hierarchy_ID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column quo_cust.grade_hier_id is '[GradeHierarchy_Hierarchy_ID] Customer can have N hierarchies so this column may repeat N times.<\n>It contains the ID from Hierarchy file to find the root and node for this customer.';
comment on column quo_cust.grd_code is '[GRDCode] Extended attribute to specify GRD code for direct customers.';
comment on column quo_cust.lead_time is '[LeadTime] Extended attribute to lead time in days for ordering.';
comment on column quo_cust.xml_attach is '[XMLAttachment] Wholesalers are internally stored as customer. This flag tells whether wholesaler needs XML attachment for turn-in-orders.';
comment on column quo_cust.is_wholesaler is '[IsWholesaler] Whether this customer is actually a wholesaler';
comment on column quo_cust.call_frequency is '[CallFrequency] ';


-- Synonyms
create or replace public synonym quo_cust for ods.quo_cust;

-- Grants
grant select,update,delete,insert on ods.quo_cust to ods_app;
grant select on ods.quo_cust to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
