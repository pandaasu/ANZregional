/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sales_day_month_02_fact
 Owner  : dd

 Description
 -----------
 Data Warehouse - Sales Day Month 02 Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/10   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.sales_day_month_02_fact
   (sap_order_type_code              varchar2(4 char),
    sap_invc_type_code               varchar2(4 char)      not null,
    sap_billing_date                 date                  not null,
    sap_billing_yyyyppdd             number(8,0)           not null,
    sap_company_code                 varchar2(6 char)      not null,
    sap_sales_hdr_sales_org_code     varchar2(4 char)      not null,
    sap_sales_hdr_distbn_chnl_code   varchar2(2 char)      not null,
    sap_sales_hdr_division_code      varchar2(2 char)      not null,
    sap_doc_currcy_code              varchar2(5 char)      not null,
    sap_order_reasn_code             varchar2(3 char),
    sap_sold_to_cust_code            varchar2(10 char)     not null,
    sap_bill_to_cust_code            varchar2(10 char)     not null,
    sap_payer_cust_code              varchar2(10 char)     not null,
    sap_secondary_ws_cust_code       varchar2(10 char),
    sap_tertiary_ws_cust_code        varchar2(10 char),
    sap_pmt_path_pri_ws_cust_code    varchar2(10 char)     not null,
    sap_pmt_path_sec_ws_cust_code    varchar2(10 char),
    sap_pmt_path_ter_ws_cust_code    varchar2(10 char),
    sap_pmt_path_ret_cust_code       varchar2(10 char),
    sap_sales_force_hier_cust_code   varchar2(10 char),
    base_uom_billed_qty              number(13),
    pieces_billed_qty                number(13),
    tonnes_billed_qty                number(19,6),
    sap_ship_to_cust_code            varchar2(10 char)     not null,
    sap_plant_code                   varchar2(4 char)      not null,
    sap_storage_locn_code            varchar2(4 char),
    sap_material_division_code       varchar2(2 char)      not null,
    sap_sales_dtl_sales_org_code     varchar2(4 char)      not null,
    sap_sales_dtl_distbn_chnl_code   varchar2(2 char)      not null,
    sap_sales_dtl_division_code      varchar2(2 char)      not null,
    sap_order_usage_code             varchar2(3 char),
    sales_dtl_price_value_1          number(18)            not null,
    sales_dtl_price_value_2          number(18)            not null,
    sales_dtl_price_value_3          number(18)            not null,
    sales_dtl_price_value_4          number(18)            not null,
    sales_dtl_price_value_5          number(18)            not null,
    sales_dtl_price_value_6          number(18)            not null,
    sales_dtl_price_value_7          number(18)            not null,
    sales_dtl_price_value_8          number(18)            not null,
    sales_dtl_price_value_9          number(18)            not null,
    sales_dtl_price_value_10         number(18)            not null,
    sales_dtl_price_value_11         number(18)            not null,
    sales_dtl_price_value_12         number(18)            not null,
    sales_dtl_price_value_13         number(18)            not null,
    sales_dtl_price_value_14         number(18)            not null,
    sales_dtl_price_value_15         number(18)            not null,
    sales_dtl_price_value_16         number(18)            not null,
    sales_dtl_price_value_17         number(18)            not null,
    sales_dtl_price_value_18         number(18)            not null,
    sales_dtl_price_value_19         number(18)            not null,
    sales_dtl_price_value_20         number(18)            not null,
    sales_dtl_price_value_21         number(18)            not null,
    sales_dtl_price_value_22         number(18)            not null,
    sales_dtl_price_value_23         number(18)            not null);

/**/
/* Comments
/**/
comment on table dd.sales_day_month_02_fact is 'Sales Day Month 02 Fact Table';
comment on column dd.sales_day_month_02_fact.sap_order_type_code is 'SAP Order Type Code';
comment on column dd.sales_day_month_02_fact.sap_invc_type_code is 'SAP Invoice Type Code';
comment on column dd.sales_day_month_02_fact.sap_billing_date is 'SAP Billing Date';
comment on column dd.sales_day_month_02_fact.sap_billing_yyyyppdd is 'SAP Billing Date in the format YYYYPPDD';
comment on column dd.sales_day_month_02_fact.sap_company_code is 'SAP Company Code';
comment on column dd.sales_day_month_02_fact.sap_sales_hdr_sales_org_code is 'SAP Sales Header Sales Organisation Code';
comment on column dd.sales_day_month_02_fact.sap_sales_hdr_distbn_chnl_code is 'SAP Sales Header Distribution Channel Code';
comment on column dd.sales_day_month_02_fact.sap_sales_hdr_division_code is 'SAP Sales Header Division Code';
comment on column dd.sales_day_month_02_fact.sap_doc_currcy_code is 'SAP Document Currency Code';
comment on column dd.sales_day_month_02_fact.sap_order_reasn_code is 'SAP Order Reason Code';
comment on column dd.sales_day_month_02_fact.sap_sold_to_cust_code is 'SAP Sold-To Customer Code';
comment on column dd.sales_day_month_02_fact.sap_bill_to_cust_code is 'SAP Bill-To Customer Code';
comment on column dd.sales_day_month_02_fact.sap_payer_cust_code is 'SAP Payer Customer Code';
comment on column dd.sales_day_month_02_fact.sap_secondary_ws_cust_code is 'SAP Secondary Wholesaler Customer Code';
comment on column dd.sales_day_month_02_fact.sap_tertiary_ws_cust_code is 'SAP Tertiary Wholesaler Customer Code';
comment on column dd.sales_day_month_02_fact.sap_pmt_path_pri_ws_cust_code is 'SAP Payment Path Primary Wholesaler Customer Code';
comment on column dd.sales_day_month_02_fact.sap_pmt_path_sec_ws_cust_code is 'SAP Payment Path Secondary Wholesaler Customer Code';
comment on column dd.sales_day_month_02_fact.sap_pmt_path_ter_ws_cust_code is 'SAP Payment Path Tertiary Wholesaler Customer Code';
comment on column dd.sales_day_month_02_fact.sap_pmt_path_ret_cust_code is 'SAP Payment Path Retailer Customer Code';
comment on column dd.sales_day_month_02_fact.sap_sales_force_hier_cust_code is 'SAP Sales Force Geography Hieararchy Customer Code';
comment on column dd.sales_day_month_02_fact.base_uom_billed_qty is 'Base UOM Billed Qty';
comment on column dd.sales_day_month_02_fact.pieces_billed_qty is 'Pieces Billed Qty';
comment on column dd.sales_day_month_02_fact.tonnes_billed_qty is 'Tonnes Billed Qty';
comment on column dd.sales_day_month_02_fact.sap_ship_to_cust_code is 'SAP Ship-To Customer Code';
comment on column dd.sales_day_month_02_fact.sap_plant_code is 'SAP Plant Code';
comment on column dd.sales_day_month_02_fact.sap_storage_locn_code is 'SAP Storage Location Code';
comment on column dd.sales_day_month_02_fact.sap_material_division_code is 'SAP Material Division Code';
comment on column dd.sales_day_month_02_fact.sap_sales_dtl_sales_org_code is 'SAP Sales Detail Sales Organsation Code';
comment on column dd.sales_day_month_02_fact.sap_sales_dtl_distbn_chnl_code is 'SAP Sales Detail Distribution Channel Code';
comment on column dd.sales_day_month_02_fact.sap_sales_dtl_division_code is 'SAP Sales Detail Division Code';
comment on column dd.sales_day_month_02_fact.sap_order_usage_code is 'SAP Order Usage Code';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_1 is 'Sales Detail Price Value 1';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_2 is 'Sales Detail Price Value 2';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_3 is 'Sales Detail Price Value 3';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_4 is 'Sales Detail Price Value 4';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_5 is 'Sales Detail Price Value 5';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_6 is 'Sales Detail Price Value 6';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_7 is 'Sales Detail Price Value 7';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_8 is 'Sales Detail Price Value 8';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_9 is 'Sales Detail Price Value 9';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_10 is 'Sales Detail Price Value 10';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_11 is 'Sales Detail Price Value 11';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_12 is 'Sales Detail Price Value 12';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_13 is 'Sales Detail Price Value 13';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_14 is 'Sales Detail Price Value 14';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_15 is 'Sales Detail Price Value 15';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_16 is 'Sales Detail Price Value 16';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_17 is 'Sales Detail Price Value 17';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_18 is 'Sales Detail Price Value 18';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_19 is 'Sales Detail Price Value 19';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_20 is 'Sales Detail Price Value 20';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_21 is 'Sales Detail Price Value 21';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_22 is 'Sales Detail Price Value 22';
comment on column dd.sales_day_month_02_fact.sales_dtl_price_value_23 is 'Sales Detail Price Value 23';

/**/
/* Indexes
/**/
create index dd.sales_day_month_02_fact_ix01 on dd.sales_day_month_02_fact (sap_billing_date);
create index dd.sales_day_month_02_fact_ix02 on dd.sales_day_month_02_fact (sap_billing_yyyyppdd);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.sales_day_month_02_fact to dw_app;
grant select on dd.sales_day_month_02_fact to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym sales_day_month_02_fact for dd.sales_day_month_02_fact;

