/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : cust_dim
 Owner  : dd

 Description
 -----------
 Data Warehouse - Customer Dimension Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created
 2006/04   Steve Gregan   Removed Japanese descriptions

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.cust_dim
   (sap_cust_code                varchar2(10 char)        not null,
    cust_name_en                 varchar2(120 char)       null,
    addr_sort_en                 varchar2(20 char)        null,
    addr_street_en               varchar2(60 char)        null,
    addr_city_en                 varchar2(40 char)        null,
    addr_postl_code_en           varchar2(10 char)        null,
    sap_addr_regn_code_en        varchar2(3 char)         null,
    addr_regn_desc_en            varchar2(40 char)        null,
    addr_time_zone_en            varchar2(6 char)         null,
    sap_lang_code_en             varchar2(2 char)         null,
    lang_desc_en                 varchar2(40 char)        null,
    sap_cntry_code_en            varchar2(3 char)         null,
    cntry_desc_en                varchar2(60 char)        null,
    sap_cust_distbn_role_code    varchar2(3 char)         null,
    cust_distbn_role_abbrd_desc  varchar2(12 char)        null,
    cust_distbn_role_desc        varchar2(30 char)        null,
    sap_cust_acct_grp_code       varchar2(4 char)         not null,
    cust_acct_grp_desc           varchar2(40 char)        not null,
    grp_key                      varchar2(10 char)        null);

/**/
/* Comments
/**/
comment on table dd.cust_dim is 'Customer Dimension Table';
comment on column dd.cust_dim.sap_cust_code is 'SAP Customer Code';
comment on column dd.cust_dim.cust_name_en is 'Customer Name EN';
comment on column dd.cust_dim.addr_sort_en is 'Address Sort EN';
comment on column dd.cust_dim.addr_street_en is 'Address Street EN';
comment on column dd.cust_dim.addr_city_en is 'Address City EN';
comment on column dd.cust_dim.addr_postl_code_en is 'Address Postal Code EN';
comment on column dd.cust_dim.sap_addr_regn_code_en is 'SAP Address Region Code';
comment on column dd.cust_dim.addr_regn_desc_en is 'Address Region Description EN';
comment on column dd.cust_dim.addr_time_zone_en is 'Address Time Zone EN';
comment on column dd.cust_dim.sap_lang_code_en is 'SAP Address Language Code';
comment on column dd.cust_dim.lang_desc_en is 'Address Language Description EN';
comment on column dd.cust_dim.sap_cntry_code_en is 'SAP Address Country Code';
comment on column dd.cust_dim.cntry_desc_en is 'Address Country Description EN';
comment on column dd.cust_dim.sap_cust_distbn_role_code is 'SAP Customer Distribution Role Code';
comment on column dd.cust_dim.cust_distbn_role_abbrd_desc is 'Customer Distribution Role Abbreviated Description';
comment on column dd.cust_dim.cust_distbn_role_desc is 'Customer Distribution Role Description';
comment on column dd.cust_dim.sap_cust_acct_grp_code is 'SAP Customer Account Group Code';
comment on column dd.cust_dim.cust_acct_grp_desc is 'Customer Account Group Description';
comment on column dd.cust_dim.grp_key is 'Group Key';

/**/
/* Primary Key Constraint
/**/
alter table dd.cust_dim
   add constraint cust_dim_pk primary key (sap_cust_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.cust_dim to dw_app;
grant select on dd.cust_dim to pld_rep_app;
grant select on dd.cust_dim to hermes_app;

/**/
/* Synonym
/**/
create or replace public synonym cust_dim for dd.cust_dim;


