
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu3
    Owner    : ods
    Table    : qu3_auth_list_prod
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu3] Quofore - Wrigley New Zealand
    [qu3_auth_list_prod] table creation script _load and _hist

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
drop table ods.qu3_auth_list_prod_load cascade constraints;

create table ods.qu3_auth_list_prod_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  auth_list_id                    number(10, 0)                   null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  number(10, 0)                   null,
  is_include                      number(1, 0)                    null,
  effective_from                  date                            null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  number(10, 0)                   null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu3_auth_list_prod_load add constraint qu3_auth_list_prod_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_auth_list_prod_load_pk on ods.qu3_auth_list_prod_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_auth_list_prod_load add constraint qu3_auth_list_prod_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_auth_list_prod_load_uk on ods.qu3_auth_list_prod_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu3_auth_list_prod_load is '[AuthorisedListProduct][LOAD] Which products are authorised to which customers.<\n><\n>This is a denormalized file which contains AuthorisedList (parent) and AuthorisedListProduct (child) data combined.';
comment on column qu3_auth_list_prod_load.q4x_load_seq is '* Unique Load Id';
comment on column qu3_auth_list_prod_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_auth_list_prod_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_auth_list_prod_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_auth_list_prod_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_auth_list_prod_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_auth_list_prod_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_auth_list_prod_load.q4x_timestamp is '* Timestamp';
comment on column qu3_auth_list_prod_load.id is '[ID] Unique Internal ID for the row';
comment on column qu3_auth_list_prod_load.auth_list_id is '[AuthorisedList_ID] ';
comment on column qu3_auth_list_prod_load.cust_id is '[Customer_ID] Foreign key to the Id of the Customer. AuthorisedList can be assigned to individual customers or customer hierarchies.';
comment on column qu3_auth_list_prod_load.cust_id_lookup is '[customer_id_lookup] ';
comment on column qu3_auth_list_prod_load.is_include is '[IsInclude] Indicates whether this product is on the list as an exclusion or inclusion. 0 indicates Exclusion, 1 indicates Inclusion. Null is not allowed';
comment on column qu3_auth_list_prod_load.effective_from is '[EffectiveFrom] The date on which the product or group of products becomes part of this assortment detail.';
comment on column qu3_auth_list_prod_load.prod_id is '[Product_ID] Foreign key to the Id of the Product. AuthorisedList can be assigned to individual products or product hierarchies.';
comment on column qu3_auth_list_prod_load.prod_id_lookup is '[product_id_lookup] ';
comment on column qu3_auth_list_prod_load.prod_id_desc is '[product_id_description] Name of product';

-- Synonyms
create or replace public synonym qu3_auth_list_prod_load for ods.qu3_auth_list_prod_load;

-- Grants
grant select,insert,update,delete on ods.qu3_auth_list_prod_load to ods_app;
grant select on ods.qu3_auth_list_prod_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu3_auth_list_prod_hist cascade constraints;

create table ods.qu3_auth_list_prod_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  auth_list_id                    number(10, 0)                   null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  number(10, 0)                   null,
  is_include                      number(1, 0)                    null,
  effective_from                  date                            null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  number(10, 0)                   null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu3_auth_list_prod_hist add constraint qu3_auth_list_prod_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu3_auth_list_prod_hist_pk on ods.qu3_auth_list_prod_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu3_auth_list_prod_hist add constraint qu3_auth_list_prod_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu3_auth_list_prod_hist_uk on ods.qu3_auth_list_prod_hist (id,q4x_batch_id)) compress;

create index ods.qu3_auth_list_prod_hist_ts on ods.qu3_auth_list_prod_hist (q4x_timestamp) compress;

-- Comments
comment on table qu3_auth_list_prod_hist is '[AuthorisedListProduct][HIST] Which products are authorised to which customers.<\n><\n>This is a denormalized file which contains AuthorisedList (parent) and AuthorisedListProduct (child) data combined.';
comment on column qu3_auth_list_prod_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu3_auth_list_prod_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu3_auth_list_prod_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu3_auth_list_prod_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu3_auth_list_prod_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu3_auth_list_prod_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu3_auth_list_prod_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu3_auth_list_prod_hist.q4x_timestamp is '* Timestamp';
comment on column qu3_auth_list_prod_hist.id is '[ID] Unique Internal ID for the row';
comment on column qu3_auth_list_prod_hist.auth_list_id is '[AuthorisedList_ID] ';
comment on column qu3_auth_list_prod_hist.cust_id is '[Customer_ID] Foreign key to the Id of the Customer. AuthorisedList can be assigned to individual customers or customer hierarchies.';
comment on column qu3_auth_list_prod_hist.cust_id_lookup is '[customer_id_lookup] ';
comment on column qu3_auth_list_prod_hist.is_include is '[IsInclude] Indicates whether this product is on the list as an exclusion or inclusion. 0 indicates Exclusion, 1 indicates Inclusion. Null is not allowed';
comment on column qu3_auth_list_prod_hist.effective_from is '[EffectiveFrom] The date on which the product or group of products becomes part of this assortment detail.';
comment on column qu3_auth_list_prod_hist.prod_id is '[Product_ID] Foreign key to the Id of the Product. AuthorisedList can be assigned to individual products or product hierarchies.';
comment on column qu3_auth_list_prod_hist.prod_id_lookup is '[product_id_lookup] ';
comment on column qu3_auth_list_prod_hist.prod_id_desc is '[product_id_description] Name of product';

-- Synonyms
create or replace public synonym qu3_auth_list_prod_hist for ods.qu3_auth_list_prod_hist;

-- Grants
grant select,insert,update,delete on ods.qu3_auth_list_prod_hist to ods_app;
grant select on ods.qu3_auth_list_prod_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
