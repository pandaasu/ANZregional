/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_split
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Split Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/06   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_split
   (fcst_split_division             varchar2(5 char)       not null,
    fcst_split_brand                varchar2(5 char)       not null,
    fcst_split_sub_brand            varchar2(5 char)       not null,
    fcst_split_text                 varchar2(128 char)     not null,
    sap_sales_org_code              varchar2(4 char)       not null,
    sap_distbn_chnl_code            varchar2(2 char)       not null,
    sap_division_code               varchar2(2 char)       not null,
    sap_sales_div_cust_code         varchar2(10 char)      null,
    sap_sales_div_sales_org_code    varchar2(4 char)       null,
    sap_sales_div_distbn_chnl_code  varchar2(2 char)       null,
    sap_sales_div_division_code     varchar2(2 char)       null);

/**/
/* Comments
/**/
comment on table od.fcst_split is 'Forecast Split Table';
comment on column od.fcst_split.fcst_split_division is 'Forecast split SAP Material Division Code';
comment on column od.fcst_split.fcst_split_brand is 'Forecast split SAP Brand Flag Code or *ALL';
comment on column od.fcst_split.fcst_split_sub_brand is 'Forecast split SAP Brand Sub-Flag Code or *ALL';
comment on column od.fcst_split.fcst_split_text is 'Forecast split text';
comment on column od.fcst_split.sap_sales_org_code is 'Sales organisation code';
comment on column od.fcst_split.sap_distbn_chnl_code is 'Distribution channel code';
comment on column od.fcst_split.sap_division_code is 'Division code';
comment on column od.fcst_split.sap_sales_div_cust_code is 'Sales division customer code';
comment on column od.fcst_split.sap_sales_div_sales_org_code is 'Sales division sales organisation code';
comment on column od.fcst_split.sap_sales_div_distbn_chnl_code is 'Sales division distribution channel code';
comment on column od.fcst_split.sap_sales_div_division_code is 'Sales division division code';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_split
   add constraint fcst_split_pk primary key (fcst_split_division, fcst_split_brand, fcst_split_sub_brand);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_split to dw_app;
grant select on od.fcst_split to public;

/**/
/* Synonym
/**/
create or replace public synonym fcst_split for od.fcst_split;