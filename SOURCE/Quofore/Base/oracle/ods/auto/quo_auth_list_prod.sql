
/*******************************************************************************
/* Table Definition
/*******************************************************************************

  System : quo
  Owner  : ods
  Table  : quo_auth_list_prod
  Author : Mal Chambeyron
  
  Description
  ------------------------------------------------------------------------------
  Quofore Loader [quo_auth_list_prod] table creation script
  
  YYYY-MM-DD  Author                Description
  ----------  --------------------  --------------------------------------------
  2013-02-19  Mal Chambeyron        [Auto-Generated] Created

*******************************************************************************/

-- Table
drop table ods.quo_auth_list_prod cascade constraints;

create table ods.quo_auth_list_prod (
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
  auth_list_id                    number(10, 0)                   null,
  auth_list_id_lookup             varchar2(50 char)               null,
  cust_id                         number(10, 0)                   null,
  cust_id_lookup                  varchar2(50 char)               null,
  cust_hier_id                    number(10, 0)                   null,
  is_include                      number(1, 0)                    null,
  effective_from                  date                            null,
  effective_to                    date                            null,
  prod_id                         number(10, 0)                   null,
  prod_id_lookup                  varchar2(50 char)               null,
  prod_hier_id                    number(10, 0)                   null,
  prod_id_desc                    varchar2(50 char)               null
) partition by range (q4x_source_id) interval (1) ( partition initial_partition values less than (1) )
enable row movement
compress;

-- Keys / Indexes
alter table ods.quo_auth_list_prod add constraint quo_auth_list_prod_pk primary key (q4x_load_seq,q4x_load_data_seq)
  using index (create unique index ods.quo_auth_list_prod_pk on ods.quo_auth_list_prod (q4x_load_seq,q4x_load_data_seq) compress);

alter table ods.quo_auth_list_prod add constraint quo_auth_list_prod_uk unique (q4x_source_id,id)
  using index (create unique index ods.quo_auth_list_prod_uk on ods.quo_auth_list_prod (q4x_source_id,id)) compress;

create index ods.quo_auth_list_prod_ts on ods.quo_auth_list_prod (q4x_source_id,q4x_timestamp) compress;

-- Comments
comment on table quo_auth_list_prod is '[AuthorisedListProduct] Which products are authorised to which customers<\n><\n>This is a denormalized file which contains AuthorisedList (parent) and AuthorisedListProduct (child) data combined';
comment on column quo_auth_list_prod.q4x_load_seq is '* Unique Load Id';
comment on column quo_auth_list_prod.q4x_load_data_seq is '* Data Record Id';
comment on column quo_auth_list_prod.q4x_create_user is '* Create User - Set on Creation';
comment on column quo_auth_list_prod.q4x_create_time is '* Create Date/Time - Set on Creation';
comment on column quo_auth_list_prod.q4x_modify_user is '* Modify User - Updated on Each Modification';
comment on column quo_auth_list_prod.q4x_modify_time is '* Modify Date/Time - Updated on Each Modification';
comment on column quo_auth_list_prod.q4x_source_id is '* Source Quofore Instance Id {Source Id} .. 1 {Petcare Australia}';
comment on column quo_auth_list_prod.q4x_batch_id is '* Quofore Batch Id';
comment on column quo_auth_list_prod.q4x_timestamp is '* Timestamp';
comment on column quo_auth_list_prod.id is '[ID] Unique Internal ID for the row';
comment on column quo_auth_list_prod.id_lookup is '[ID_Lookup] ';
comment on column quo_auth_list_prod.auth_list_id is '[AuthorisedList_ID] ';
comment on column quo_auth_list_prod.auth_list_id_lookup is '[AuthorisedList_ID_Lookup] ';
comment on column quo_auth_list_prod.cust_id is '[Customer_ID] Foreign key to the Id of the Customer. AuthorisedList can be assigned to individual customers or customer hierarchies.';
comment on column quo_auth_list_prod.cust_id_lookup is '[Customer_ID_Lookup] ';
comment on column quo_auth_list_prod.cust_hier_id is '[Customer_Hierarchy_ID] There''re two hierarchies for customer. CustomerHierarchy and Grade. This is ID of a node of one of these hierarchies.';
comment on column quo_auth_list_prod.is_include is '[IsInclude] Indicates whether this product is on the list as an exclusion or inclusion. 0 indicates Exclusion, 1 indicates Inclusion. Null is not allowed';
comment on column quo_auth_list_prod.effective_from is '[EffectiveFrom] The date on which the product or group of products becomes part of this assortment detail.';
comment on column quo_auth_list_prod.effective_to is '[EffectiveTo] The date on which the product or group of products ceases to be part of this assortment detail.';
comment on column quo_auth_list_prod.prod_id is '[Product_ID] Foreign key to the Id of the Product. AuthorisedList can be assigned to individual products or product hierarchies.';
comment on column quo_auth_list_prod.prod_id_lookup is '[Product_ID_Lookup] ';
comment on column quo_auth_list_prod.prod_hier_id is '[ProductHierarchy_Hierarchy_ID] There''s only one product hierarchy i.e. ProductHierarchy. This is ID of a node of ProductHierarchy.';
comment on column quo_auth_list_prod.prod_id_desc is '[product_id_description] ';


-- Synonyms
create or replace public synonym quo_auth_list_prod for ods.quo_auth_list_prod;

-- Grants
grant select,update,delete,insert on ods.quo_auth_list_prod to ods_app;
grant select on ods.quo_auth_list_prod to dds_app, qv_user, bo_user;

/*******************************************************************************
** END-OF-FILE
*******************************************************************************/
