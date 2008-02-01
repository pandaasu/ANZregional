/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_period
 Owner  : od

 Description
 -----------
 Operational Data Store - Forecast Period Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table od.fcst_period
   (fcst_type_code                  number(8)              not null,
    fcst_price_type_code            number(8)              default null not null,
    casting_yyyypp                  number(6)              not null,
    fcst_yyyypp                     number(6)              not null,
    sap_sales_dtl_sales_org_code    varchar2(4 char)       not null,
    sap_sales_dtl_distbn_chnl_code  varchar2(2 char)       not null,
    sap_sales_dtl_division_code     varchar2(2 char)       not null,
    sap_sales_div_cust_code         varchar2(10 char),
    sap_sales_div_sales_org_code    varchar2(4 char),
    sap_sales_div_distbn_chnl_code  varchar2(2 char),
    sap_sales_div_division_code     varchar2(2 char),
    sap_material_code               varchar2(18 char)      not null,
    fcst_value                      number(16,2)           not null,
    fcst_qty                        number(12)             not null,
    fcst_period_lupdp               varchar2(8 char)       not null,
    fcst_period_lupdt               date                   not null);

/**/
/* Comments
/**/
comment on table od.fcst_period is 'Forecast Period Table';
comment on column od.fcst_period.fcst_price_type_code is 'Forecast Price Type Code e.g. Base Price, GSV';
comment on column od.fcst_period.casting_yyyypp is 'Period defining the forecast e.g. P2 = BR3 (P3-P2) in the format YYYYPP';
comment on column od.fcst_period.fcst_yyyypp is 'Forecast Period in the format YYYYPP';
comment on column od.fcst_period.sap_sales_dtl_sales_org_code is 'SAP Sales Detail Sales Organisation Code';
comment on column od.fcst_period.sap_sales_dtl_distbn_chnl_code is 'SAP Sales Detail Distribution Channel Code';
comment on column od.fcst_period.sap_sales_dtl_division_code is 'SAP Sales Detail Division Code';
comment on column od.fcst_period.sap_sales_div_cust_code is 'SAP Sales Division Customer Code from Geo Force Hierarchy';
comment on column od.fcst_period.sap_sales_div_sales_org_code is 'SAP Sales Division Sales Organisation Code from Geo Force Hierarchy';
comment on column od.fcst_period.sap_sales_div_distbn_chnl_code is 'SAP Sales Division Distribution Channel Code from Geo Force Hierarchy';
comment on column od.fcst_period.sap_sales_div_division_code is 'SAP Sales Division Division Code from Geo Force Hierarchy';
comment on column od.fcst_period.sap_material_code is 'SAP Material Code';
comment on column od.fcst_period.fcst_value is 'Forecast Value in Company''s default currency';
comment on column od.fcst_period.fcst_qty is 'Forecast Quantity in Base Unit of Measure';
comment on column od.fcst_period.fcst_period_lupdp is 'Last Updated Person';
comment on column od.fcst_period.fcst_period_lupdt is 'Last Updated Time';

/**/
/* Authority
/**/
grant select, insert, update, delete on od.fcst_period to dw_app;
grant select on od.fcst_period to od_app with grant option;
grant select on od.fcst_period to od_user;
grant select on od.fcst_period to pld_rep_app;

/**/
/* Synonym
/**/
create public synonym fcst_period for od.fcst_period;

