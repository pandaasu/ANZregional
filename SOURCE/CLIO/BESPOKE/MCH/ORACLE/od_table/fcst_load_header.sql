/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_load_header
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Load Header Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2008/02   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_load_header
   (load_identifier                 varchar2(64 char)      not null,
    load_description                varchar2(128 char)     not null,
    load_status                     varchar2(10 char)      not null,
    load_replace                    varchar2(10 char)      not null,
    fcst_split_division             varchar2(5 char)       not null,
    fcst_split_brand                varchar2(5 char)       not null,
    fcst_split_sub_brand            varchar2(5 char)       not null,
    fcst_material_list              varchar2(4000 char)    not null,
    fcst_time                       varchar2(4 char)       not null,
    fcst_type                       varchar2(4 char)       not null,
    fcst_source                     varchar2(4 char)       not null,
    fcst_cast_yyyynn                number(6,0)            not null,
    sap_sales_org_code              varchar2(4 char)       not null,
    sap_distbn_chnl_code            varchar2(2 char)       not null,
    sap_division_code               varchar2(2 char)       not null,
    sap_sales_div_cust_code         varchar2(10 char)      null,
    sap_sales_div_sales_org_code    varchar2(4 char)       null,
    sap_sales_div_distbn_chnl_code  varchar2(2 char)       null,
    sap_sales_div_division_code     varchar2(2 char)       null,
    crt_user                        varchar2(30 char)      not null,
    crt_date                        date                   not null,
    upd_user                        varchar2(30 char)      not null,
    upd_date                        date                   not null);

/**/
/* Comments
/**/
comment on table od.fcst_load_header is 'Forecast Load Header Table';
comment on column od.fcst_load_header.load_identifier is 'Load identifier';
comment on column od.fcst_load_header.load_description is 'Load description';
comment on column od.fcst_load_header.load_status is 'Load status *CREATING,*VALID,*ERROR,*LOADED';
comment on column od.fcst_load_header.load_replace is 'Load replace *SPLIT,*MATERIAL';
comment on column od.fcst_load_header.fcst_split_division is 'Forecast split SAP Material Division Code';
comment on column od.fcst_load_header.fcst_split_brand is 'Forecast split SAP Brand Flag Code or *ALL';
comment on column od.fcst_load_header.fcst_split_sub_brand is 'Forecast split SAP Brand Sub-Flag Code or *ALL';
comment on column od.fcst_load_header.fcst_material_list is 'Forecast material list or *ALL';
comment on column od.fcst_load_header.fcst_type is 'Forecast type (*BR, *OP1 or *OP2)';
comment on column od.fcst_load_header.fcst_source is 'Forecast source (*PLN, *TXQ or *TXV)';
comment on column od.fcst_load_header.fcst_cast_yyyypp is 'Forecast casting period';
comment on column od.fcst_load_header.fcst_cast_yyyyppw is 'Forecast casting period week';
comment on column od.fcst_load_header.fcst_cast_date is 'Forecast casting date';
comment on column od.fcst_load_header.sap_sales_org_code is 'Sales organisation code';
comment on column od.fcst_load_header.sap_distbn_chnl_code is 'Distribution channel code';
comment on column od.fcst_load_header.sap_division_code is 'Division code';
comment on column od.fcst_load_header.sap_sales_div_cust_code is 'Sales division customer code';
comment on column od.fcst_load_header.sap_sales_div_sales_org_code is 'Sales division sales organisation code';
comment on column od.fcst_load_header.sap_sales_div_distbn_chnl_code is 'Sales division distribution channel code';
comment on column od.fcst_load_header.sap_sales_div_division_code is 'Sales division division code';
comment on column od.fcst_load_header.crt_user is 'Creation user identifier';
comment on column od.fcst_load_header.crt_date is 'Creation timestamp';
comment on column od.fcst_load_header.upd_user is 'Update user identifier';
comment on column od.fcst_load_header.upd_date is 'Update timestamp';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_load_header
   add constraint fcst_load_header_pk primary key (load_identifier);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_load_header to od_app;
grant select, insert, update, delete on od.fcst_load_header to dw_app;
grant select on od.fcst_load_header to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_load_header for od.fcst_load_header;