/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : ods 
 Table   : sales_adjustment 
 Owner   : ods 
 Author  : Trevor Keon 

 Description
 -----------
 Operation Data Store - sales_adjustment 

 YYYY/MM   Author         Description
 -------   ------         -----------
 2013/03   Trevor Keon    Created 

*******************************************************************************/

/**/
/* Table creation
/**/
create table ods.sales_adjustment
(
  adjustment_entry_date     date                not null,
  trace_seqn                number,
  trace_date                date ,
  trace_status              varchar2(10 char),  
  company_code              varchar2(10 char)   not null,
  billing_doc_num           varchar2(10 char)   not null,
  billing_doc_line_num      varchar2(10 char)   not null,
  doc_currcy_code           varchar2(10 char),
  exch_rate                 number,
  order_reasn_code          varchar2(10 char),
  creatn_date               date,
  creatn_yyyyppdd           number(8),
  creatn_yyyyppw            number(7),
  creatn_yyyypp             number(6),
  creatn_yyyymm             number(6),
  billing_eff_date          date,
  billing_eff_yyyyppdd      number(8),
  billing_eff_yyyyppw       number(7),
  billing_eff_yyyypp        number(6),
  billing_eff_yyyymm        number(6),
  order_type_code           varchar2(10 char),
  invc_type_code            varchar2(10 char),
  hdr_sales_org_code        varchar2(10 char),
  hdr_distbn_chnl_code      varchar2(10 char),
  hdr_division_code         varchar2(10 char),
  hdr_sold_to_cust_code     varchar2(10 char),
  hdr_bill_to_cust_code     varchar2(10 char),
  hdr_payer_cust_code       varchar2(10 char),
  hdr_ship_to_cust_code     varchar2(10 char),
  billed_uom_code           varchar2(10 char),
  billed_base_uom_code      varchar2(10 char),
  plant_code                varchar2(10 char),
  storage_locn_code         varchar2(10 char),
  gen_sales_org_code        varchar2(10 char),
  gen_distbn_chnl_code      varchar2(10 char),
  gen_division_code         varchar2(10 char),
  order_usage_code          varchar2(10 char),
  order_qty                 number,
  billed_qty                number,
  billed_qty_base_uom       number,
  billed_gross_weight       number,
  billed_net_weight         number,
  billed_weight_unit        varchar2(10 char),
  matl_code                 varchar2(18 char),
  matl_entd                 varchar2(18 char),
  gen_sold_to_cust_code     varchar2(10 char),
  gen_bill_to_cust_code     varchar2(10 char),
  gen_payer_cust_code       varchar2(10 char),
  gen_ship_to_cust_code     varchar2(10 char),
  purch_order_doc_num       varchar2(10 char),
  purch_order_doc_line_num  varchar2(10 char),
  order_doc_num             varchar2(10 char),
  order_doc_line_num        varchar2(10 char),
  dlvry_doc_num             varchar2(10 char),
  dlvry_doc_line_num        varchar2(10 char),
  billed_gsv                number
);

/**/
/* Indexes
/**/
create index sales_adjustment_ix01 on sales_adjustment (adjustment_entry_date);

/**/
/* Authority
/**/
grant select on sales_adjustment to public;

/**/
/* Synonym
/**/
create or replace public synonym sales_adjustment for ods.sales_adjustment;