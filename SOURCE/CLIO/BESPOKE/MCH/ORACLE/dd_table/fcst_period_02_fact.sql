/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : fcst_period_02_fact
 Owner  : dd

 Description
 -----------
 Data Warehouse - Forecast Period 02 Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.fcst_period_02_fact
   (billing_yyyypp                  number(6)              not null,
    sap_material_code               varchar2(18 char)      not null,
    sap_sales_dtl_sales_org_code    varchar2(4 char)       not null,
    sap_sales_dtl_distbn_chnl_code  varchar2(2 char)       not null,
    sap_sales_dtl_division_code     varchar2(2 char)       not null,
    br_base_price_value             number                 not null,
    br_gsv_value                    number                 not null,
    br_qty                          number                 not null,
    op_base_price_value             number                 not null,
    op_gsv_value                    number                 not null,
    op_qty                          number                 not null,
    rb_base_price_value             number                 not null,
    rb_gsv_value                    number                 not null,
    rb_qty                          number                 not null);

/**/
/* Comments
/**/
comment on table dd.fcst_period_02_fact is 'Forecast Period 02 Fact Table';
comment on column dd.fcst_period_02_fact.billing_yyyypp is 'Billing YYYYPP';
comment on column dd.fcst_period_02_fact.sap_material_code is 'SAP Material Code';
comment on column dd.fcst_period_02_fact.sap_sales_dtl_sales_org_code is 'SAP Sales Detail Sales Organisation Code';
comment on column dd.fcst_period_02_fact.sap_sales_dtl_distbn_chnl_code is 'SAP Sales Detail Distribution Channel Code';
comment on column dd.fcst_period_02_fact.sap_sales_dtl_division_code is 'SAP Sales Detail Division Code';
comment on column dd.fcst_period_02_fact.br_base_price_value is 'Business Review Base Price Value';
comment on column dd.fcst_period_02_fact.br_gsv_value is 'Business Review GSV Value';
comment on column dd.fcst_period_02_fact.br_qty is 'Business Review Quantity';
comment on column dd.fcst_period_02_fact.op_base_price_value is 'Operating Plan Base Price Value';
comment on column dd.fcst_period_02_fact.op_gsv_value is 'Operating Plan GSV Value';
comment on column dd.fcst_period_02_fact.op_qty is 'Operating Plan Quantity';
comment on column dd.fcst_period_02_fact.rb_base_price_value is 'Review Of Business Base Price Value';
comment on column dd.fcst_period_02_fact.rb_gsv_value is 'Review Of Business GSV Value';
comment on column dd.fcst_period_02_fact.rb_qty is 'Review Of Business Quantity';

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.fcst_period_02_fact to dw_app;
grant select on dd.fcst_period_02_fact to od_user;
grant select on dd.fcst_period_02_fact to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym fcst_period_02_fact for dd.fcst_period_02_fact;

