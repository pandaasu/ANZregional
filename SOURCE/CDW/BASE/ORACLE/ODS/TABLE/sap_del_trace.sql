/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods
 Table   : sap_del_trace
 Owner   : ods
 Author  : Steve Gregan

 Description
 -----------
 Operation Data Store - sap_del_trace

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/10   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table sap_del_trace
   (trace_seqn                               number                 not null,
    trace_date                               date                   not null,
    trace_status                             varchar2(10 char)      not null,
    company_code                             varchar2(10 char)      null,
    dlvry_doc_num                            varchar2(10 char)      null,
    dlvry_type_code                          varchar2(10 char)      null,
    dlvry_procg_stage                        varchar2(10 char)      null,
    sales_org_code                           varchar2(10 char)      null,
    creatn_date                              date                   null,
    creatn_yyyyppdd                          number(8,0)            null,
    creatn_yyyyppw                           number(7,0)            null,
    creatn_yyyypp                            number(6,0)            null,
    creatn_yyyymm                            number(6,0)            null,
    dlvry_eff_date                           date                   null,
    dlvry_eff_yyyyppdd                       number(8,0)            null,
    dlvry_eff_yyyyppw                        number(7,0)            null,
    dlvry_eff_yyyypp                         number(6,0)            null,
    dlvry_eff_yyyymm                         number(6,0)            null,
    goods_issue_date                         date                   null,
    goods_issue_yyyyppdd                     number(8,0)            null,
    goods_issue_yyyyppw                      number(7,0)            null,
    goods_issue_yyyypp                       number(6,0)            null,
    goods_issue_yyyymm                       number(6,0)            null,
    sold_to_cust_code                        varchar2(10 char)      null,
    bill_to_cust_code                        varchar2(10 char)      null,
    payer_cust_code                          varchar2(10 char)      null,
    ship_to_cust_code                        varchar2(10 char)      null,
    dlvry_doc_line_num                       varchar2(10 char)      null,
    matl_code                                varchar2(18 char)      null,
    matl_entd                                varchar2(35 char)      null,
    dlvry_uom_code                           varchar2(10 char)      null,
    dlvry_base_uom_code                      varchar2(10 char)      null,
    plant_code                               varchar2(10 char)      null,
    storage_locn_code                        varchar2(10 char)      null,
    distbn_chnl_code                         varchar2(10 char)      null,
    dlvry_qty                                number                 null,
    allocated_qty                            number                 null,
    ordered_qty                              number                 null,
    dlvry_gross_weight                       number                 null,
    dlvry_net_weight                         number                 null,
    dlvry_weight_unit                        varchar2(10 char)      null,
    order_doc_num                            varchar2(10 char)      null,
    order_doc_line_num                       varchar2(10 char)      null,
    purch_order_doc_num                      varchar2(10 char)      null,
    purch_order_doc_line_num                 varchar2(10 char)      null);

/**/
/* Indexes
/**/
create index sap_del_trace_ix01 on sap_del_trace
   (dlvry_doc_num, dlvry_doc_line_num, company_code, trace_seqn, trace_date);
create index sap_del_trace_ix02 on sap_del_trace
   (trace_seqn, trace_date, company_code, purch_order_doc_num);
create index sap_del_trace_ix03 on sap_del_trace
   (trace_seqn, trace_date, company_code, order_doc_num);

/**/
/* Authority
/**/
grant select, insert, update, delete on sap_del_trace to ods_app;
grant select on sap_del_trace to public;

/**/
/* Synonym
/**/
create or replace public synonym sap_del_trace for ods.sap_del_trace;
