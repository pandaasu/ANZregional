/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : sales_fact
 Owner  : dd

 Description
 -----------
 Data Warehouse - Sales Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.sales_fact
   (sap_order_type_code               varchar2(4 char)      null,
    sap_invc_type_code                varchar2(4 char)      not null,
    creatn_date                       date                  not null,
    billing_date                      date                  not null,
    billing_yyyyppdd                  number(8,0)           not null,
    billing_yyyyppw                   number(7,0)           not null,
    billing_yyyypp                    number(6,0)           not null,
    billing_yyyymm                    number(6,0)           not null,
    sap_billing_date                  date                  not null,
    sap_billing_yyyyppdd              number(8,0)           not null,
    sap_billing_yyyyppw               number(7,0)           not null,
    sap_billing_yyyypp                number(6,0)           not null,
    sap_billing_yyyymm                number(6,0)           not null,
    sap_company_code                  varchar2(6 char)      not null,
    sap_sales_hdr_sales_org_code      varchar2(4 char)      not null,
    sap_sales_hdr_distbn_chnl_code    varchar2(2 char)      not null,
    sap_sales_hdr_division_code       varchar2(2 char)      not null,
    invc_num                          varchar2(10 char)     not null,
    sap_doc_currcy_code               varchar2(5 char)      not null,
    exch_rate                         number(11,5)          not null,
    sap_order_reasn_code              varchar2(3 char)      null,
    sap_sold_to_cust_code             varchar2(10 char)     not null,
    sap_bill_to_cust_code             varchar2(10 char)     not null,
    sap_payer_cust_code               varchar2(10 char)     not null,
    sap_secondary_ws_cust_code        varchar2(10 char)     null,
    sap_tertiary_ws_cust_code         varchar2(10 char)     null,
    sap_pmt_path_pri_ws_cust_code     varchar2(10 char)     not null,
    sap_pmt_path_sec_ws_cust_code     varchar2(10 char)     null,
    sap_pmt_path_ter_ws_cust_code     varchar2(10 char)     null,
    sap_pmt_path_ret_cust_code        varchar2(10 char)     null,
    sap_sales_force_hier_cust_code    varchar2(10 char)     null,
    batch_num                         varchar2(35 char)     null,
    goods_issued_date                 date                  null,
    reqd_dlvry_date                   date                  null,
    order_qty                         number(15)            not null,
    billed_qty                        number(16,3)          not null,
    base_uom_billed_qty               number(13)            null,
    pieces_billed_qty                 number(13)            null,
    tonnes_billed_qty                 number(19,6)          null,
    sap_ship_to_cust_code             varchar2(10 char)     not null,
    sap_material_code                 varchar2(18 char)     not null,
    material_entd                     varchar2(35 char)     null,
    sap_shipg_type_code               varchar2(3 char)      null,
    crpc_price_band                   varchar2(3 char)      null,
    sap_billed_qty_uom_code           varchar2(3 char)      null,
    sap_billed_qty_base_uom_code      varchar2(3 char)      not null,
    sap_plant_code                    varchar2(4 char)      not null,
    sap_storage_locn_code             varchar2(4 char)      null,
    sap_material_division_code        varchar2(2 char)      not null,
    sales_doc_num                     varchar2(10 char)     not null,
    sales_doc_line_num                varchar2(6 char)      not null,
    ref_doc_num                       varchar2(10 char)     null,
    ref_doc_line_num                  varchar2(6 char)      null,
    sap_sales_dtl_sales_org_code      varchar2(4 char)      not null,
    sap_sales_dtl_distbn_chnl_code    varchar2(2 char)      not null,
    sap_sales_dtl_division_code       varchar2(2 char)      not null,
    sap_order_usage_code              varchar2(3 char)      null,
    purch_order_num                   varchar2(35 char)     null,
    purch_order_date                  date                  null,
    sales_dtl_price_value_1           number(18)            not null,
    sales_dtl_price_value_2           number(18)            not null,
    sales_dtl_price_value_3           number(18)            not null,
    sales_dtl_price_value_4           number(18)            not null,
    sales_dtl_price_value_5           number(18)            not null,
    sales_dtl_price_value_6           number(18)            not null,
    sales_dtl_price_value_7           number(18)            not null,
    sales_dtl_price_value_8           number(18)            not null,
    sales_dtl_price_value_9           number(18)            not null,
    sales_dtl_price_value_10          number(18)            not null,
    sales_dtl_price_value_11          number(18)            not null,
    sales_dtl_price_value_12          number(18)            not null,
    sales_dtl_price_value_13          number(18)            not null,
    sales_dtl_price_value_14          number(18)            not null,
    sales_dtl_price_value_15          number(18)            not null,
    sales_dtl_price_value_16          number(18)            not null,
    sales_dtl_price_value_17          number(18)            not null,
    sales_dtl_price_value_18          number(18)            not null,
    sales_dtl_price_value_19          number(18)            not null,
    sales_dtl_price_value_20          number(18)            not null,
    sales_dtl_price_value_21          number(18)            not null,
    sales_dtl_price_value_22          number(18)            not null,
    sales_dtl_price_value_23          number(18)            not null);

/**/
/* Comments
/**/
comment on table dd.sales_fact is 'Sales Fact Table';
comment on column dd.sales_fact.sap_order_type_code is 'SAP Order Type Code';
comment on column dd.sales_fact.sap_invc_type_code is 'SAP Invoice Type Code';
comment on column dd.sales_fact.creatn_date is 'Creation Date';
comment on column dd.sales_fact.billing_date is 'Billing Date';
comment on column dd.sales_fact.billing_yyyyppdd is 'Billing Date in the format YYYYPPDD';
comment on column dd.sales_fact.billing_yyyyppw is 'Billing Date in the format YYYYPPW';
comment on column dd.sales_fact.billing_yyyypp is 'Billing Date in the format YYYYPP';
comment on column dd.sales_fact.billing_yyyymm is 'Billing Date in the format YYYYMM';
comment on column dd.sales_fact.sap_billing_date is 'SAP Billing Date';
comment on column dd.sales_fact.sap_billing_yyyyppdd is 'SAP Billing Date in the format YYYYPPDD';
comment on column dd.sales_fact.sap_billing_yyyyppw is 'SAP Billing Date in the format YYYYPPW';
comment on column dd.sales_fact.sap_billing_yyyypp is 'SAP Billing Date in the format YYYYPP';
comment on column dd.sales_fact.sap_billing_yyyymm is 'SAP Billing Date in the format YYYYMM';
comment on column dd.sales_fact.sap_company_code is 'SAP Company Code';
comment on column dd.sales_fact.sap_sales_hdr_sales_org_code is 'SAP Sales Header Sales Organisation Code';
comment on column dd.sales_fact.sap_sales_hdr_distbn_chnl_code is 'SAP Sales Header Distribution Channel Code';
comment on column dd.sales_fact.sap_sales_hdr_division_code is 'SAP Sales Header Division Code';
comment on column dd.sales_fact.invc_num is 'Invoice Number';
comment on column dd.sales_fact.sap_doc_currcy_code is 'SAP Document Currency Code';
comment on column dd.sales_fact.exch_rate is 'Exchange Rate';
comment on column dd.sales_fact.sap_order_reasn_code is 'SAP Order Reason Code';
comment on column dd.sales_fact.sap_sold_to_cust_code is 'SAP Sold-To Customer Code';
comment on column dd.sales_fact.sap_bill_to_cust_code is 'SAP Bill-To Customer Code';
comment on column dd.sales_fact.sap_payer_cust_code is 'SAP Payer Customer Code';
comment on column dd.sales_fact.sap_secondary_ws_cust_code is 'SAP Secondary Wholesaler Customer Code';
comment on column dd.sales_fact.sap_tertiary_ws_cust_code is 'SAP Tertiary Wholesaler Customer Code';
comment on column dd.sales_fact.sap_pmt_path_pri_ws_cust_code is 'SAP Payment Path Primary Wholesaler Customer Code';
comment on column dd.sales_fact.sap_pmt_path_sec_ws_cust_code is 'SAP Payment Path Secondary Wholesaler Customer Code';
comment on column dd.sales_fact.sap_pmt_path_ter_ws_cust_code is 'SAP Payment Path Tertiary Wholesaler Customer Code';
comment on column dd.sales_fact.sap_pmt_path_ret_cust_code is 'SAP Payment Path Retailer Customer Code';
comment on column dd.sales_fact.sap_sales_force_hier_cust_code is 'SAP Sales Force Geography Hierarchy Customer Code';
comment on column dd.sales_fact.batch_num is 'Batch Number';
comment on column dd.sales_fact.goods_issued_date is 'Goods Issued Date';
comment on column dd.sales_fact.reqd_dlvry_date is 'Requested Delivery Date';
comment on column dd.sales_fact.order_qty is 'Order Qty';
comment on column dd.sales_fact.billed_qty is 'Billed Qty';
comment on column dd.sales_fact.base_uom_billed_qty is 'Base UOM Billed Qty';
comment on column dd.sales_fact.pieces_billed_qty is 'Pieces Billed Qty';
comment on column dd.sales_fact.tonnes_billed_qty is 'Tonnes Billed Qty';
comment on column dd.sales_fact.sap_ship_to_cust_code is 'SAP Ship-To Customer Code';
comment on column dd.sales_fact.sap_material_code is 'SAP Material Code';
comment on column dd.sales_fact.material_entd is '"Representative Item or EAN-UPC Code, etc"';
comment on column dd.sales_fact.sap_shipg_type_code is 'SAP Shipping Type Code';
comment on column dd.sales_fact.crpc_price_band is 'CRPC Price Band';
comment on column dd.sales_fact.sap_billed_qty_uom_code is 'SAP Billed Qty UOM Code';
comment on column dd.sales_fact.sap_billed_qty_base_uom_code is 'SAP Billed Qty Base UOM Code';
comment on column dd.sales_fact.sap_plant_code is 'SAP Plant Code';
comment on column dd.sales_fact.sap_storage_locn_code is 'SAP Storage Location Code';
comment on column dd.sales_fact.sap_material_division_code is 'SAP Material Division Code';
comment on column dd.sales_fact.sales_doc_num is 'Sales Document Number';
comment on column dd.sales_fact.sales_doc_line_num is 'Sales Document Line Number';
comment on column dd.sales_fact.ref_doc_num is 'Reference Document Number';
comment on column dd.sales_fact.ref_doc_line_num is 'Reference Document Line Number';
comment on column dd.sales_fact.sap_sales_dtl_sales_org_code is 'SAP Sales Detail Sales Organsation Code';
comment on column dd.sales_fact.sap_sales_dtl_distbn_chnl_code is 'SAP Sales Detail Distribution Channel Code';
comment on column dd.sales_fact.sap_sales_dtl_division_code is 'SAP Sales Detail Division Code';
comment on column dd.sales_fact.sap_order_usage_code is 'SAP Order Usage Code';
comment on column dd.sales_fact.purch_order_num is 'Purchase Order Number';
comment on column dd.sales_fact.purch_order_date is 'Purchase Order Date';
comment on column dd.sales_fact.sales_dtl_price_value_1 is 'Sales Detail Price Value 1';
comment on column dd.sales_fact.sales_dtl_price_value_2 is 'Sales Detail Price Value 2';
comment on column dd.sales_fact.sales_dtl_price_value_3 is 'Sales Detail Price Value 3';
comment on column dd.sales_fact.sales_dtl_price_value_4 is 'Sales Detail Price Value 4';
comment on column dd.sales_fact.sales_dtl_price_value_5 is 'Sales Detail Price Value 5';
comment on column dd.sales_fact.sales_dtl_price_value_6 is 'Sales Detail Price Value 6';
comment on column dd.sales_fact.sales_dtl_price_value_7 is 'Sales Detail Price Value 7';
comment on column dd.sales_fact.sales_dtl_price_value_8 is 'Sales Detail Price Value 8';
comment on column dd.sales_fact.sales_dtl_price_value_9 is 'Sales Detail Price Value 9';
comment on column dd.sales_fact.sales_dtl_price_value_10 is 'Sales Detail Price Value 10';
comment on column dd.sales_fact.sales_dtl_price_value_11 is 'Sales Detail Price Value 11';
comment on column dd.sales_fact.sales_dtl_price_value_12 is 'Sales Detail Price Value 12';
comment on column dd.sales_fact.sales_dtl_price_value_13 is 'Sales Detail Price Value 13';
comment on column dd.sales_fact.sales_dtl_price_value_14 is 'Sales Detail Price Value 14';
comment on column dd.sales_fact.sales_dtl_price_value_15 is 'Sales Detail Price Value 15';
comment on column dd.sales_fact.sales_dtl_price_value_16 is 'Sales Detail Price Value 16';
comment on column dd.sales_fact.sales_dtl_price_value_17 is 'Sales Detail Price Value 17';
comment on column dd.sales_fact.sales_dtl_price_value_18 is 'Sales Detail Price Value 18';
comment on column dd.sales_fact.sales_dtl_price_value_19 is 'Sales Detail Price Value 19';
comment on column dd.sales_fact.sales_dtl_price_value_20 is 'Sales Detail Price Value 20';
comment on column dd.sales_fact.sales_dtl_price_value_21 is 'Sales Detail Price Value 21';
comment on column dd.sales_fact.sales_dtl_price_value_22 is 'Sales Detail Price Value 22';
comment on column dd.sales_fact.sales_dtl_price_value_23 is 'Sales Detail Price Value 23';

/**/
/* Indexes
/**/
create index dd.sales_fact_ix01 on dd.sales_fact (sap_company_code, billing_date);
create index dd.sales_fact_ix02 on dd.sales_fact (sap_company_code, billing_yyyyppdd);
create index dd.sales_fact_ix03 on dd.sales_fact (sap_company_code, billing_yyyypp);
create index dd.sales_fact_ix04 on dd.sales_fact (sap_company_code, billing_yyyymm);
create index dd.sales_fact_ix05 on dd.sales_fact (sap_company_code, sap_billing_date);
create index dd.sales_fact_ix06 on dd.sales_fact (sap_company_code, sap_billing_yyyyppdd);
create index dd.sales_fact_ix07 on dd.sales_fact (sap_company_code, sap_billing_yyyypp);
create index dd.sales_fact_ix08 on dd.sales_fact (sap_company_code, sap_billing_yyyymm);
create index dd.sales_fact_ix09 on dd.sales_fact (sap_company_code, creatn_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.sales_fact to dw_app;
grant select on dd.sales_fact to pld_rep_app;

/**/
/* Synonym
/**/
create or replace public synonym sales_fact for dd.sales_fact;
