/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_sal_ord_trace
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operation Data Store - sap_sal_ord_trace

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/10   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_sal_ord_trace
   (trace_seqn                               number                 not null,
    trace_date                               date                   not null,
    trace_status                             varchar2(10 char)      not null,
    company_code                             varchar2(10 char)      null,
    order_doc_num                            varchar2(10 char)      null,
    currcy_code                              varchar2(10 char)      null,
    exch_rate                                number                 null,
    order_reasn_code                         varchar2(10 char)      null,
    creatn_date                              date                   null,
    creatn_yyyyppdd                          number(8,0)            null,
    creatn_yyyyppw                           number(7,0)            null,
    creatn_yyyypp                            number(6,0)            null,
    creatn_yyyymm                            number(6,0)            null,
    order_eff_date                           date                   null,
    order_eff_yyyyppdd                       number(8,0)            null,
    order_eff_yyyyppw                        number(7,0)            null,
    order_eff_yyyypp                         number(6,0)            null,
    order_eff_yyyymm                         number(6,0)            null,
    order_type_code                          varchar2(10 char)      null,
    sales_org_code                           varchar2(10 char)      null,
    distbn_chnl_code                         varchar2(10 char)      null,
    division_code                            varchar2(10 char)      null,
    hdr_sold_to_cust_code                    varchar2(10 char)      null,
    hdr_bill_to_cust_code                    varchar2(10 char)      null,
    hdr_payer_cust_code                      varchar2(10 char)      null,
    hdr_ship_to_cust_code                    varchar2(10 char)      null,
    order_doc_line_num                       varchar2(10 char)      null,
    order_uom_code                           varchar2(10 char)      null,
    plant_code                               varchar2(10 char)      null,
    storage_locn_code                        varchar2(10 char)      null,
    order_usage_code                         varchar2(10 char)      null,
    order_line_rejectn_code                  varchar2(10 char)      null,
    order_qty                                number                 null,
    order_gross_weight                       number                 null,
    order_net_weight                         number                 null,
    order_weight_unit                        varchar2(10 char)      null,
    cust_order_doc_num                       varchar2(35 char)      null,
    cust_order_doc_line_num                  varchar2(10 char)      null,
    cust_order_due_date                      date                   null,
    matl_code                                varchar2(18 char)      null,
    matl_entd                                varchar2(35 char)      null,
    confirmed_qty                            number                 null,
    confirmed_date                           date                   null,
    confirmed_yyyyppdd                       number(8,0)            null,
    confirmed_yyyyppw                        number(7,0)            null,
    confirmed_yyyypp                         number(6,0)            null,
    confirmed_yyyymm                         number(6,0)            null,
    gen_sold_to_cust_code                    varchar2(10 char)      null,
    gen_bill_to_cust_code                    varchar2(10 char)      null,
    gen_payer_cust_code                      varchar2(10 char)      null,
    gen_ship_to_cust_code                    varchar2(10 char)      null,
    order_gsv                                number                 null);

/**/
/* Indexes
/**/
create index sap_sal_ord_trace_ix01 on sap_sal_ord_trace
   (order_doc_num, order_doc_line_num, company_code, trace_seqn, trace_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_sal_ord_trace to ods_app;
grant select on sap_sal_ord_trace to public;

/**/
/* Synonym
/**/
create or replace public synonym sap_sal_ord_trace for ods.sap_sal_ord_trace;
