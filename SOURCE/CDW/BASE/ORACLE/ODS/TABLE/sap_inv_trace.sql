/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_inv_trace
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operation Data Store - sap_inv_trace

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/10   Steve Gregan   Created
 2011/03   Steve Gregan   Added additional indexes

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_inv_trace
   (trace_seqn                               number                 not null,
    trace_date                               date                   not null,
    trace_status                             varchar2(10 char)      not null,
    company_code                             varchar2(10 char)      not null,
    billing_doc_num                          varchar2(10 char)      not null,
    doc_currcy_code                          varchar2(10 char)      null,
    exch_rate                                number                 null,
    order_reasn_code                         varchar2(10 char)      null,
    creatn_date                              date                   null,
    creatn_yyyyppdd                          number(8,0)            null,
    creatn_yyyyppw                           number(7,0)            null,
    creatn_yyyypp                            number(6,0)            null,
    creatn_yyyymm                            number(6,0)            null,
    billing_eff_date                         date                   null,
    billing_eff_yyyyppdd                     number(8,0)            null,
    billing_eff_yyyyppw                      number(7,0)            null,
    billing_eff_yyyypp                       number(6,0)            null,
    billing_eff_yyyymm                       number(6,0)            null,
    order_type_code                          varchar2(10 char)      null,
    invc_type_code                           varchar2(10 char)      null,
    hdr_sales_org_code                       varchar2(10 char)      null,
    hdr_distbn_chnl_code                     varchar2(10 char)      null,
    hdr_division_code                        varchar2(10 char)      null,
    hdr_sold_to_cust_code                    varchar2(10 char)      null,
    hdr_bill_to_cust_code                    varchar2(10 char)      null,
    hdr_payer_cust_code                      varchar2(10 char)      null,
    hdr_ship_to_cust_code                    varchar2(10 char)      null,
    billing_doc_line_num                     varchar2(10 char)      null,
    billed_uom_code                          varchar2(10 char)      null,
    billed_base_uom_code                     varchar2(10 char)      null,
    plant_code                               varchar2(10 char)      null,
    storage_locn_code                        varchar2(10 char)      null,
    gen_sales_org_code                       varchar2(10 char)      null,
    gen_distbn_chnl_code                     varchar2(10 char)      null,
    gen_division_code                        varchar2(10 char)      null,
    order_usage_code                         varchar2(10 char)      null,
    order_qty                                number                 null,
    billed_qty                               number                 null,
    billed_qty_base_uom                      number                 null,
    billed_gross_weight                      number                 null,
    billed_net_weight                        number                 null,
    billed_weight_unit                       varchar2(10 char)      null,
    matl_code                                varchar2(18 char)      null,
    matl_entd                                varchar2(18 char)      null,
    gen_sold_to_cust_code                    varchar2(10 char)      null,
    gen_bill_to_cust_code                    varchar2(10 char)      null,
    gen_payer_cust_code                      varchar2(10 char)      null,
    gen_ship_to_cust_code                    varchar2(10 char)      null,
    purch_order_doc_num                      varchar2(10 char)      null,
    purch_order_doc_line_num                 varchar2(10 char)      null,
    order_doc_num                            varchar2(10 char)      null,
    order_doc_line_num                       varchar2(10 char)      null,
    dlvry_doc_num                            varchar2(10 char)      null,
    dlvry_doc_line_num                       varchar2(10 char)      null,
    billed_gsv                               number                 null);

/**/
/* Indexes
/**/
create index sap_inv_trace_ix01 on sap_inv_trace
   (company_code, billing_doc_num, billing_doc_line_num);
create index sap_inv_trace_ix02 on sap_inv_trace
   (company_code, creatn_date);
create index sap_inv_trace_ix03 on sap_inv_trace
   (company_code, purch_order_doc_num, purch_order_doc_line_num);
create index sap_inv_trace_ix04 on sap_inv_trace
   (company_code, order_doc_num, order_doc_line_num);
create index sap_inv_trace_ix05 on sap_inv_trace
   (company_code, dlvry_doc_num, dlvry_doc_line_num);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_inv_trace to ods_app;
grant select on sap_inv_trace to public;

/**/
/* Synonym
/**/
create or replace public synonym sap_inv_trace for ods.sap_inv_trace;
