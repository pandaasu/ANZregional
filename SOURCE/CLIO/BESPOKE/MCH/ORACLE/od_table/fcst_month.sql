/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_month
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Month Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_month
   (fcst_month_code                 number(8)              not null,
    fcst_type_code                  number(8)              not null,
    fcst_price_type_code            number(8)              default null not null,
    casting_yyyymm                  number(6)              not null,
    fcst_yyyymm                     number(6)              not null,
    sap_sales_dtl_sales_org_code    varchar2(4 char)       not null,
    sap_sales_dtl_distbn_chnl_code  varchar2(2 char)       not null,
    sap_sales_dtl_division_code     varchar2(2 char)       not null,
    sap_sales_div_cust_code         varchar2(10 char),
    sap_sales_div_sales_org_code    varchar2(4 char),
    sap_sales_div_distbn_chnl_code  varchar2(2 char),
    sap_sales_div_division_code     varchar2(2 char),
    sap_material_code               varchar2(18 char)      not null,
    fcst_value                      number                 not null,
    fcst_qty                        number                 not null,
    fcst_month_lupdp                varchar2(8 char)       not null,
    fcst_month_lupdt                date                   not null);

/**/
/* Comments
/**/
comment on table od.fcst_month is 'Forecast Month Table';
comment on column od.fcst_month.fcst_type_code is 'Forecast Type Code';
comment on column od.fcst_month.fcst_price_type_code is 'Forecast Price Type Code e.g. Base Price, GSV';
comment on column od.fcst_month.casting_yyyymm is 'Month defining the forecast e.g. Feb = (Mar - Feb) in the format YYYYMM';
comment on column od.fcst_month.fcst_yyyymm is 'Forecast Month in the format YYYYMM';
comment on column od.fcst_month.sap_sales_dtl_sales_org_code is 'SAP Sales Detail Sales Organisation Code';
comment on column od.fcst_month.sap_sales_dtl_distbn_chnl_code is 'SAP Sales Detail Distribution Channel Code';
comment on column od.fcst_month.sap_sales_dtl_division_code is 'SAP Sales Detail Division Code';
comment on column od.fcst_month.sap_sales_div_cust_code is 'SAP Sales Division Customer Code from Local Hierarchy';
comment on column od.fcst_month.sap_sales_div_sales_org_code is 'SAP Sales Division Sales Organisation Code from Local Hierarchy';
comment on column od.fcst_month.sap_sales_div_distbn_chnl_code is 'SAP Sales Division Distribution Channel Code from Local Hierarchy';
comment on column od.fcst_month.sap_sales_div_division_code is 'SAP Sales Division Division Code from Local Hierarchy';
comment on column od.fcst_month.sap_material_code is 'SAP Material Code';
comment on column od.fcst_month.fcst_value is 'Forecast Value in Company default currency';
comment on column od.fcst_month.fcst_qty is 'Forecast Quantity in Base Unit of Measure';
comment on column od.fcst_month.fcst_month_lupdp is 'Last Updated Person';
comment on column od.fcst_month.fcst_month_lupdt is 'Last Updated Time';

/**/
/* Primary Key Constraint
/**/
alter table od.fcst_month
   add constraint fcst_month_pk primary key (fcst_month_code);

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_month to dw_app;
grant select, insert, update, delete on od.fcst_month to od_app with grant option;
grant select on od.fcst_month to od_user;
grant select on od.fcst_month to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym fcst_month for od.fcst_month;
