
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_prod_barcode_hist
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_prod_barcode_hist] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_prod_barcode_hist cascade constraints;

create table ods.quo_prod_barcode_hist (
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
  created_date                    date                            null,
  barcode_desc                    varchar2(50 char)               null,
  barcode_type_id                 number(10, 0)                   null,
  barcode_type_id_lookup          varchar2(50 char)               null,
  barcode_type_id_desc            varchar2(50 char)               null,
  code                            varchar2(35 char)               null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  varchar2(50 char)               null,
  prod_id_desc                    varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_prod_barcode_hist add constraint quo_prod_barcode_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_prod_barcode_hist_pk on ods.quo_prod_barcode_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_prod_barcode_hist add constraint quo_prod_barcode_hist_uk unique (q4x_source_id,id,q4x_batch_id)
  using index (create unique index ods.quo_prod_barcode_hist_uk on ods.quo_prod_barcode_hist (q4x_source_id,id,q4x_batch_id)) compress;

create index ods.quo_prod_barcode_hist_ts on ods.quo_prod_barcode_hist (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_prod_barcode_hist is '[ProductBarcode] Child table of product. Each barcode has a type assigned (e.g. RSU_Barcode, MSU_Barcode). Then products are assigned a barcode type and actual barcode value in this table.';
comment on column quo_prod_barcode_hist.q4x_load_seq is '* Unique Load Id';
comment on column quo_prod_barcode_hist.q4x_load_data_seq is '* Data Record Id';
comment on column quo_prod_barcode_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_prod_barcode_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_prod_barcode_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_prod_barcode_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_prod_barcode_hist.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_prod_barcode_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_prod_barcode_hist.q4x_timestamp is '* Timestamp';
comment on column quo_prod_barcode_hist.id is '[ID] Unique Internal ID for the row';
comment on column quo_prod_barcode_hist.id_lookup is '[ID_Lookup] ';
comment on column quo_prod_barcode_hist.created_date is '[CreatedDate] The timestamp for the creation of the record.';
comment on column quo_prod_barcode_hist.barcode_desc is '[BarcodeDescription] Describes the package this barcode is on. E.g. Case Barcode, Inner Barcode.';
comment on column quo_prod_barcode_hist.barcode_type_id is '[BarcodeTypeId] Mandatory foreign key. To find the LookupList and LookupListItem this field is mapped to';
comment on column quo_prod_barcode_hist.barcode_type_id_lookup is '[BarcodeTypeId_Lookup] Integration Id, Should be unique for all Lookup List Items';
comment on column quo_prod_barcode_hist.barcode_type_id_desc is '[BarcodeTypeId_Description] Language Description in default system language';
comment on column quo_prod_barcode_hist.code is '[Code] The code represented by the barcode.';
comment on column quo_prod_barcode_hist.prod_id is '[Product_Id] Foreign key to [Product].[Id]. Links a specific product to a task.';
comment on column quo_prod_barcode_hist.prod_id_lookup is '[Product_Id_Lookup] ';
comment on column quo_prod_barcode_hist.prod_id_desc is '[Product_Id_Description] ';


-- Synonyms
create or replace public synonym quo_prod_barcode_hist for ods.quo_prod_barcode_hist;

-- Grants
grant select,update,delete,insert on ods.quo_prod_barcode_hist to ods_app;
grant select on ods.quo_prod_barcode_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
