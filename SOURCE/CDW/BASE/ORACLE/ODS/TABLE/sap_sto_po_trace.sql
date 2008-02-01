/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_sto_po_trace
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operation Data Store - sap_sto_po_trace

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/10   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_sto_po_trace
   (trace_seqn                               number                 not null,
    trace_date                               date                   not null,
    trace_status                             varchar2(10 char)      not null,
    company_code                             varchar2(10 char)      null,
    purch_order_doc_num                      varchar2(35 char)      null,
    currcy_code                              varchar2(10 char)      null,
    exch_rate                                number                 null,
    purch_order_reasn_code                   varchar2(10 char)      null,
    creatn_date                              date                   null,
    creatn_yyyyppdd                          number(8,0)            null,
    creatn_yyyyppw                           number(7,0)            null,
    creatn_yyyypp                            number(6,0)            null,
    creatn_yyyymm                            number(6,0)            null,
    purch_order_eff_date                     date                   null,
    purch_order_eff_yyyyppdd                 number(8,0)            null,
    purch_order_eff_yyyyppw                  number(7,0)            null,
    purch_order_eff_yyyypp                   number(6,0)            null,
    purch_order_eff_yyyymm                   number(6,0)            null,
    purch_order_type_code                    varchar2(10 char)      null,
    purchg_company_code                      varchar2(10 char)      null,
    vendor_code                              varchar2(10 char)      null,
    sales_org_code                           varchar2(10 char)      null,
    distbn_chnl_code                         varchar2(10 char)      null,
    division_code                            varchar2(10 char)      null,
    purch_order_doc_line_num                 varchar2(10 char)      null,
    purch_order_uom_code                     varchar2(10 char)      null,
    plant_code                               varchar2(10 char)      null,
    storage_locn_code                        varchar2(10 char)      null,
    purch_order_usage_code                   varchar2(10 char)      null,
    purch_order_qty                          number                 null,
    purch_order_gsv                          number                 null,
    purch_order_gross_weight                 number                 null,
    purch_order_net_weight                   number                 null,
    purch_order_weight_unit                  varchar2(10 char)      null,
    cust_code                                varchar2(10 char)      null,
    matl_code                                varchar2(18 char)      null,
    confirmed_qty                            number                 null,
    confirmed_date                           date                   null,
    confirmed_yyyyppdd                       number(8,0)            null,
    confirmed_yyyyppw                        number(7,0)            null,
    confirmed_yyyypp                         number(6,0)            null,
    confirmed_yyyymm                         number(6,0)            null);

/**/
/* Indexes
/**/
create index sap_sto_po_trace_ix01 on sap_sto_po_trace
   (purch_order_doc_num, purch_order_doc_line_num, company_code, trace_seqn, trace_date);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_sto_po_trace to ods_app;
grant select on sap_sto_po_trace to public;

/**/
/* Synonym
/**/
create or replace public synonym sap_sto_po_trace for ods.sap_sto_po_trace;
