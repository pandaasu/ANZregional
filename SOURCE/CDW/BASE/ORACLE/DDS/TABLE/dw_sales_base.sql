/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : dw_sales_base
 Owner  : dds

 Description
 -----------
 Data Warehouse - Sales Base Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dds.dw_sales_base
   (billing_doc_num                   varchar2(10 char)     not null,
    billing_doc_line_num              varchar2(10 char)     not null,
    billing_trace_seqn                number                not null,
    creatn_date                       date                  not null,
    creatn_yyyyppdd                   number(8,0)           not null,
    creatn_yyyyppw                    number(7,0)           not null,
    creatn_yyyypp                     number(6,0)           not null,
    creatn_yyyymm                     number(6,0)           not null,
    billing_eff_date                  date                  not null,
    billing_eff_yyyyppdd              number(8,0)           not null,
    billing_eff_yyyyppw               number(7,0)           not null,
    billing_eff_yyyypp                number(6,0)           not null,
    billing_eff_yyyymm                number(6,0)           not null,
    order_doc_num                     varchar2(10 char)     null,
    order_doc_line_num                varchar2(10 char)     null,
    purch_order_doc_num               varchar2(10 char)     null,
    purch_order_doc_line_num          varchar2(10 char)     null,
    dlvry_doc_num                     varchar2(10 char)     null,
    dlvry_doc_line_num                varchar2(10 char)     null,
    company_code                      varchar2(35 char)     not null,
    hdr_sales_org_code                varchar2(10 char)     not null,
    hdr_distbn_chnl_code              varchar2(10 char)     not null,
    hdr_division_code                 varchar2(10 char)     not null,
    gen_sales_org_code                varchar2(10 char)     null,
    gen_distbn_chnl_code              varchar2(10 char)     null,
    gen_division_code                 varchar2(10 char)     null,
    doc_currcy_code                   varchar2(10 char)     not null,
    company_currcy_code               varchar2(10 char)     not null,
    exch_rate                         number                not null,
    invc_type_code                    varchar2(10 char)     not null,
    order_type_code                   varchar2(10 char)     null,
    order_reasn_code                  varchar2(10 char)     null,
    order_usage_code                  varchar2(10 char)     null,
    sold_to_cust_code                 varchar2(10 char)     null,
    bill_to_cust_code                 varchar2(10 char)     null,
    payer_cust_code                   varchar2(10 char)     null,
    ship_to_cust_code                 varchar2(10 char)     null,
    matl_code                         varchar2(18 char)     not null,
    ods_matl_code                     varchar2(18 char)     not null,
    matl_entd                         varchar2(35 char)     null,
    plant_code                        varchar2(10 char)     null,
    storage_locn_code                 varchar2(10 char)     null,
    order_qty                         number                not null,
    billed_weight_unit                varchar2(10 char)     null,
    billed_gross_weight               number                not null,
    billed_net_weight                 number                not null,
    billed_uom_code                   varchar2(10 char)     null,
    billed_base_uom_code              varchar2(10 char)     null,
    billed_qty                        number                not null,
    billed_qty_base_uom               number                not null,
    billed_qty_gross_tonnes           number                not null,
    billed_qty_net_tonnes             number                not null,
    billed_gsv                        number                not null,
    billed_gsv_xactn                  number                not null,
    billed_gsv_aud                    number                not null,
    billed_gsv_usd                    number                not null,
    billed_gsv_eur                    number                not null,
    mfanz_icb_flag                    varchar2(1 char)      not null,
    demand_plng_grp_division_code     varchar2(2 char)      null);

/**/
/* Comments
/**/
comment on table dds.dw_sales_base is 'Sales Base Fact Table';
comment on column dds.dw_sales_base.billing_doc_num is 'Invoice document number';
comment on column dds.dw_sales_base.billing_doc_line_num is 'Invoice document line number';
comment on column dds.dw_sales_base.billing_trace_seqn is 'Invoice document ODS trace sequence';
comment on column dds.dw_sales_base.creatn_date is 'Creation date';
comment on column dds.dw_sales_base.creatn_yyyyppdd is 'Creation MARS day';
comment on column dds.dw_sales_base.creatn_yyyyppw is 'Creation MARS week';
comment on column dds.dw_sales_base.creatn_yyyypp is 'Creation MARS month';
comment on column dds.dw_sales_base.creatn_yyyymm is 'Creation MARS period';
comment on column dds.dw_sales_base.billing_eff_date is 'Invoice effective date';
comment on column dds.dw_sales_base.billing_eff_yyyyppdd is 'Invoice effective MARS day';
comment on column dds.dw_sales_base.billing_eff_yyyyppw is 'Invoice effective MARS week';
comment on column dds.dw_sales_base.billing_eff_yyyypp is 'Invoice effective MARS period';
comment on column dds.dw_sales_base.billing_eff_yyyymm is 'Invoice effective MARS month';
comment on column dds.dw_sales_base.order_doc_num is 'Order document number';
comment on column dds.dw_sales_base.order_doc_line_num is 'Order document line number';
comment on column dds.dw_sales_base.purch_order_doc_num is 'Purchase order document number';
comment on column dds.dw_sales_base.purch_order_doc_line_num is 'Purchase order document line number';
comment on column dds.dw_sales_base.dlvry_doc_num is 'Delivery document number';
comment on column dds.dw_sales_base.dlvry_doc_line_num is 'Delivery document line number';
comment on column dds.dw_sales_base.company_code is 'Company code';
comment on column dds.dw_sales_base.hdr_sales_org_code is 'Invoice sales organisation code';
comment on column dds.dw_sales_base.hdr_distbn_chnl_code is 'Invoice distribution channel code';
comment on column dds.dw_sales_base.hdr_division_code is 'Invoice division code';
comment on column dds.dw_sales_base.gen_sales_org_code is 'Invoice line sales organisaion code';
comment on column dds.dw_sales_base.gen_distbn_chnl_code is 'Invoice line distribution channel code';
comment on column dds.dw_sales_base.gen_division_code is 'Invoice line division code';
comment on column dds.dw_sales_base.doc_currcy_code is 'Document currency code';
comment on column dds.dw_sales_base.company_currcy_code is 'Company currency code';
comment on column dds.dw_sales_base.exch_rate is 'Exchange rate';
comment on column dds.dw_sales_base.invc_type_code is 'Invoice type code';
comment on column dds.dw_sales_base.order_type_code is 'Order type code';
comment on column dds.dw_sales_base.order_reasn_code is 'Order reason code';
comment on column dds.dw_sales_base.order_usage_code is 'Order usage code';
comment on column dds.dw_sales_base.sold_to_cust_code is 'Sold to customer code';
comment on column dds.dw_sales_base.bill_to_cust_code is 'Bill to customer code';
comment on column dds.dw_sales_base.payer_cust_code is 'Payer customer code';
comment on column dds.dw_sales_base.ship_to_cust_code is 'Ship to customer code';
comment on column dds.dw_sales_base.matl_code  is 'Material code';
comment on column dds.dw_sales_base.ods_matl_code is 'ODS material code';
comment on column dds.dw_sales_base.matl_entd is 'Material code entered';
comment on column dds.dw_sales_base.plant_code is 'Plant code';
comment on column dds.dw_sales_base.storage_locn_code is 'Storage location code';
comment on column dds.dw_sales_base.order_qty is 'Ordered quantity';
comment on column dds.dw_sales_base.billed_weight_unit is 'Invoice line weight unit code';
comment on column dds.dw_sales_base.billed_gross_weight is 'Invoice line gross weight';
comment on column dds.dw_sales_base.billed_net_weight is 'Invoice line nett weight';
comment on column dds.dw_sales_base.billed_uom_code is 'Invoice line unit of measure code';
comment on column dds.dw_sales_base.billed_base_uom_code is 'Invoice line base unit of measure code';
comment on column dds.dw_sales_base.billed_qty is 'Invoiced quantity';
comment on column dds.dw_sales_base.billed_qty_base_uom is 'Invoiced quantity in base unit of measure';
comment on column dds.dw_sales_base.billed_qty_gross_tonnes is 'Invoiced quantity in gross tonnes';
comment on column dds.dw_sales_base.billed_qty_net_tonnes is 'Invoiced quantity in nett tonnes';
comment on column dds.dw_sales_base.billed_gsv is 'Invoiced gross sales value';
comment on column dds.dw_sales_base.billed_gsv_xactn is 'Invoiced gross sales value on transaction';
comment on column dds.dw_sales_base.billed_gsv_aud is 'Invoiced gross sales value in AUD';
comment on column dds.dw_sales_base.billed_gsv_usd is 'Invoiced gross sales value in USD';
comment on column dds.dw_sales_base.billed_gsv_eur is 'Invoiced gross sales value in EUR';
comment on column dds.dw_sales_base.mfanz_icb_flag is 'MFANZ ICB flag';
comment on column dds.dw_sales_base.demand_plng_grp_division_code is 'Demand planning group division code';

/**/
/* Primary Key Constraint
/**/
alter table dds.dw_sales_base
   add constraint dw_sales_base_pk primary key (billing_doc_num, billing_doc_line_num);

/**/
/* Indexes
/**/
create index dds.dw_sales_base_ix01 on dds.dw_sales_base (company_code, creatn_date);
create index dds.dw_sales_base_ix02 on dds.dw_sales_base (company_code, billing_eff_yyyypp);
create index dds.dw_sales_base_ix03 on dds.dw_sales_base (company_code, billing_eff_yyyymm);
create index dds.dw_sales_base_ix04 on dds.dw_sales_base (company_code, billing_doc_num, billing_doc_line_num);
create index dds.dw_sales_base_ix05 on dds.dw_sales_base (company_code, order_doc_num, order_doc_line_num);
create index dds.dw_sales_base_ix06 on dds.dw_sales_base (company_code, purch_order_doc_num, purch_order_doc_line_num);
create index dds.dw_sales_base_ix07 on dds.dw_sales_base (company_code, dlvry_doc_num, dlvry_doc_line_num);
create index dds.dw_sales_base_ix08 on dds.dw_sales_base (company_code, order_doc_num, dlvry_doc_num, billing_doc_num, billing_doc_line_num);

/**/
/* Authority
/**/
grant select, insert, update, delete on dds.dw_sales_base to dw_app;
grant select on dds.dw_sales_base to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_sales_base for dds.dw_sales_base;