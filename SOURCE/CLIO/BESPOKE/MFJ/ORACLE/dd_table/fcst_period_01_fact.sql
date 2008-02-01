/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_period_01_fact
 Owner  : dd

 Description
 -----------
 Data Warehouse - Forecast Period 01 Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.fcst_period_01_fact
   (billing_yyyypp                  number(6)              not null,
    sap_material_code               varchar2(18 char)      not null,
    sap_sales_dtl_sales_org_code    varchar2(4 char)       not null,
    sap_sales_dtl_distbn_chnl_code  varchar2(2 char)       not null,
    sap_sales_dtl_division_code     varchar2(2 char)       not null,
    sap_sales_div_cust_code         varchar2(10 char)      not null,
    sap_sales_div_sales_org_code    varchar2(4 char)       not null,
    sap_sales_div_distbn_chnl_code  varchar2(2 char)       not null,
    sap_sales_div_division_code     varchar2(2 char)       not null,
    br_base_price_value             number(16,2)           not null,
    br_gsv_value                    number(16,2)           not null,
    br_qty                          number(12)             not null,
    op_base_price_value             number(16,2)           not null,
    op_gsv_value                    number(16,2)           not null,
    op_qty                          number(12)             not null,
    le_base_price_value             number(16,2)           not null,
    le_gsv_value                    number(16,2)           not null,
    le_qty                          number(12)             not null);

/**/
/* Comments
/**/
comment on table dd.fcst_period_01_fact is 'Forecast Period 01 Fact Table';
comment on column dd.fcst_period_01_fact.billing_yyyypp is 'Billing YYYYPP';
comment on column dd.fcst_period_01_fact.sap_material_code is 'SAP Material Code';
comment on column dd.fcst_period_01_fact.sap_sales_dtl_sales_org_code is 'SAP Sales Detail Sales Organisation Code';
comment on column dd.fcst_period_01_fact.sap_sales_dtl_distbn_chnl_code is 'SAP Sales Detail Distribution Channel Code';
comment on column dd.fcst_period_01_fact.sap_sales_dtl_division_code is 'SAP Sales Detail Division Code';
comment on column dd.fcst_period_01_fact.sap_sales_div_cust_code is 'SAP Sales Division Customer Code from Geo Force Hierarchy';
comment on column dd.fcst_period_01_fact.sap_sales_div_sales_org_code is 'SAP Sales Division Sales Organisation Code from Geo Force Hierarchy';
comment on column dd.fcst_period_01_fact.sap_sales_div_distbn_chnl_code is 'SAP Sales Division Distribution Channel Code from Geo Force Hierarchy';
comment on column dd.fcst_period_01_fact.sap_sales_div_division_code is 'SAP Sales Division Division Code from Geo Force Hierarchy';
comment on column dd.fcst_period_01_fact.br_base_price_value is 'Business Objects Base Price Value';
comment on column dd.fcst_period_01_fact.br_gsv_value is 'Business Objects GSV Value';
comment on column dd.fcst_period_01_fact.br_qty is 'Business Objects Quantity';
comment on column dd.fcst_period_01_fact.op_base_price_value is 'Operating Plan Base Price Value';
comment on column dd.fcst_period_01_fact.op_gsv_value is 'Operating Plan GSV Value';
comment on column dd.fcst_period_01_fact.op_qty is 'Operating Plan Quantity';
comment on column dd.fcst_period_01_fact.le_base_price_value is 'Latest Estimate Base Price Value';
comment on column dd.fcst_period_01_fact.le_gsv_value is 'Latest Estimate GSV Value';
comment on column dd.fcst_period_01_fact.le_qty is 'Latest Estimate Quantity';

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.fcst_period_01_fact to dw_app;
grant select on dd.fcst_period_01_fact to od_user;
grant select on dd.fcst_period_01_fact to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym fcst_period_01_fact for dd.fcst_period_01_fact;
