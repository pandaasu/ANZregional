
  /*****************************************************************************
  /* Table Definition
  /*****************************************************************************

    System   : qu5
    Owner    : ods
    Table    : qu5_auth_list_prod
    Author   : [Auto-Generate]

    Description
    ----------------------------------------------------------------------------
    [qu5] Quofore - Mars New Zealand
    [qu5_auth_list_prod] table creation script _load and _hist

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
drop table ods.qu5_auth_list_prod_load cascade constraints;

create table ods.qu5_auth_list_prod_load (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  authorised_list_id              number(10, 0)                   null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  number(10, 0)                   null,
  is_include                      number(1, 0)                    null,
  effective_from                  date                            null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  varchar2(50 char)               null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_auth_list_prod_load add constraint qu5_auth_list_prod_load_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_auth_list_prod_load_pk on ods.qu5_auth_list_prod_load (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_auth_list_prod_load add constraint qu5_auth_list_prod_load_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_auth_list_prod_load_uk on ods.qu5_auth_list_prod_load (id,q4x_batch_id)) compress;

-- Comments
comment on table qu5_auth_list_prod_load is '[AuthorisedListProduct][LOAD] Which products are authorised to which customers.<\n><\n>This is a denormalized file which contains AuthorisedList (parent) and AuthorisedListProduct (child) data combined.';
comment on column qu5_auth_list_prod_load.q4x_load_seq is '* Unique Load Id';
comment on column qu5_auth_list_prod_load.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_auth_list_prod_load.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_auth_list_prod_load.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_auth_list_prod_load.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_auth_list_prod_load.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_auth_list_prod_load.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_auth_list_prod_load.q4x_timestamp is '* Timestamp';
comment on column qu5_auth_list_prod_load.id is '[Id] Unique Internal ID for the row';
comment on column qu5_auth_list_prod_load.authorised_list_id is '[AuthorisedList_Id] Extended Attribute - Whether the AuthorisedListProduct authorised available for List Orders _i not';
comment on column qu5_auth_list_prod_load.cust_id is '[Customer_Id] Foreign Key to [Customer].[Id]';
comment on column qu5_auth_list_prod_load.cust_id_lookup is '[Customer_Id_Lookup] Extended Attribute - Whether the AuthorisedListProduct customer available for Id Orders _l not';
comment on column qu5_auth_list_prod_load.is_include is '[IsInclude] Indicates whether this product is on the list as an exclusion or inclusion. 0 indicates Exclusion, 1 indicates Inclusion. Null is not allowed';
comment on column qu5_auth_list_prod_load.effective_from is '[EffectiveFrom] The date on which the product or group of products becomes part of this assortment detail.';
comment on column qu5_auth_list_prod_load.prod_id is '[Product_Id] Foreign key to [Product].[Id]';
comment on column qu5_auth_list_prod_load.prod_id_lookup is '[Product_Id_Lookup] Product Id Lookup of the AuthorisedListProduct';
comment on column qu5_auth_list_prod_load.prod_id_desc is '[Product_Id_Description] Name of product';

-- Synonyms
create or replace public synonym qu5_auth_list_prod_load for ods.qu5_auth_list_prod_load;

-- Grants
grant select,insert,update,delete on ods.qu5_auth_list_prod_load to ods_app;
grant select on ods.qu5_auth_list_prod_load to dds_app, qv_user, bo_user;

-- _hist -----------------------------------------------------------------------

-- Table
drop table ods.qu5_auth_list_prod_hist cascade constraints;

create table ods.qu5_auth_list_prod_hist (
  q4x_load_seq                    number(15)                      not null,
  q4x_load_data_seq               number(10)                      not null,
  q4x_create_user                 varchar2(32 char)               not null,
  q4x_create_time                 date                            not null,
  q4x_modify_user                 varchar2(32 char)               not null,
  q4x_modify_time                 date                            not null,
  q4x_batch_id                    number(15)                      not null,
  q4x_timestamp                   date                            not null,
  id                              number(10, 0)                   not null,
  authorised_list_id              number(10, 0)                   null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  number(10, 0)                   null,
  is_include                      number(1, 0)                    null,
  effective_from                  date                            null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  varchar2(50 char)               null,
  prod_id_desc                    varchar2(50 char)               null
)
compress;

-- Keys / Indexes
alter table ods.qu5_auth_list_prod_hist add constraint qu5_auth_list_prod_hist_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.qu5_auth_list_prod_hist_pk on ods.qu5_auth_list_prod_hist (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.qu5_auth_list_prod_hist add constraint qu5_auth_list_prod_hist_uk unique (id,q4x_batch_id)
  using index (create unique index ods.qu5_auth_list_prod_hist_uk on ods.qu5_auth_list_prod_hist (id,q4x_batch_id)) compress;

create index ods.qu5_auth_list_prod_hist_ts on ods.qu5_auth_list_prod_hist (q4x_timestamp) compress;

-- Comments
comment on table qu5_auth_list_prod_hist is '[AuthorisedListProduct][HIST] Which products are authorised to which customers.<\n><\n>This is a denormalized file which contains AuthorisedList (parent) and AuthorisedListProduct (child) data combined.';
comment on column qu5_auth_list_prod_hist.q4x_load_seq is '* Unique Load Id';
comment on column qu5_auth_list_prod_hist.q4x_load_data_seq is '* Data Record Id';
comment on column qu5_auth_list_prod_hist.q4x_create_user is '* Create User - Set on Creation';
comment on column qu5_auth_list_prod_hist.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column qu5_auth_list_prod_hist.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column qu5_auth_list_prod_hist.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column qu5_auth_list_prod_hist.q4x_batch_id is '* Quofore Batch Id';
comment on column qu5_auth_list_prod_hist.q4x_timestamp is '* Timestamp';
comment on column qu5_auth_list_prod_hist.id is '[Id] Unique Internal ID for the row';
comment on column qu5_auth_list_prod_hist.authorised_list_id is '[AuthorisedList_Id] Extended Attribute - Whether the AuthorisedListProduct authorised available for List Orders _i not';
comment on column qu5_auth_list_prod_hist.cust_id is '[Customer_Id] Foreign Key to [Customer].[Id]';
comment on column qu5_auth_list_prod_hist.cust_id_lookup is '[Customer_Id_Lookup] Extended Attribute - Whether the AuthorisedListProduct customer available for Id Orders _l not';
comment on column qu5_auth_list_prod_hist.is_include is '[IsInclude] Indicates whether this product is on the list as an exclusion or inclusion. 0 indicates Exclusion, 1 indicates Inclusion. Null is not allowed';
comment on column qu5_auth_list_prod_hist.effective_from is '[EffectiveFrom] The date on which the product or group of products becomes part of this assortment detail.';
comment on column qu5_auth_list_prod_hist.prod_id is '[Product_Id] Foreign key to [Product].[Id]';
comment on column qu5_auth_list_prod_hist.prod_id_lookup is '[Product_Id_Lookup] Product Id Lookup of the AuthorisedListProduct';
comment on column qu5_auth_list_prod_hist.prod_id_desc is '[Product_Id_Description] Name of product';

-- Synonyms
create or replace public synonym qu5_auth_list_prod_hist for ods.qu5_auth_list_prod_hist;

-- Grants
grant select,insert,update,delete on ods.qu5_auth_list_prod_hist to ods_app;
grant select on ods.qu5_auth_list_prod_hist to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
