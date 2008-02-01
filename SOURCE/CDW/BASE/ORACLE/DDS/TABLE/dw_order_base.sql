/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : dw_order_base
 Owner  : dds

 Description
 -----------
 Data Warehouse - Order Base Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dds.dw_order_base
   (order_doc_num                     varchar2(10 char)     not null,
    order_doc_line_num                varchar2(10 char)     not null,
    order_line_status                 varchar2(12 char)     not null,
    order_trace_seqn                  number                not null,
    creatn_date                       date                  not null,
    creatn_yyyyppdd                   number(8,0)           not null,
    creatn_yyyyppw                    number(7,0)           not null,
    creatn_yyyypp                     number(6,0)           not null,
    creatn_yyyymm                     number(6,0)           not null,
    order_eff_date                    date                  not null,
    order_eff_yyyyppdd                number(8,0)           not null,
    order_eff_yyyyppw                 number(7,0)           not null,
    order_eff_yyyypp                  number(6,0)           not null,
    order_eff_yyyymm                  number(6,0)           not null,
    confirmed_date                    date                  not null,
    confirmed_yyyyppdd                number(8,0)           not null,
    confirmed_yyyyppw                 number(7,0)           not null,
    confirmed_yyyypp                  number(6,0)           not null,
    confirmed_yyyymm                  number(6,0)           not null,
    company_code                      varchar2(10 char)     not null,
    cust_order_doc_num                varchar2(35 char)     null,
    cust_order_doc_line_num           varchar2(10 char)     null,
    cust_order_due_date               date                  null,
    sales_org_code                    varchar2(10 char)     not null,
    distbn_chnl_code                  varchar2(10 char)     null,
    division_code                     varchar2(10 char)     null,
    doc_currcy_code                   varchar2(10 char)     not null,
    company_currcy_code               varchar2(10 char)     not null,
    exch_rate                         number                not null,
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
    order_line_rejectn_code           varchar2(10 char)     null,
    order_weight_unit                 varchar2(10 char)     null,
    order_gross_weight                number                not null,
    order_net_weight                  number                not null,
    order_uom_code                    varchar2(10 char)     null,
    order_base_uom_code               varchar2(10 char)     null,
    ord_qty                           number                not null,
    ord_qty_base_uom                  number                not null,
    ord_qty_gross_tonnes              number                not null,
    ord_qty_net_tonnes                number                not null,
    ord_gsv                           number                not null,
    ord_gsv_xactn                     number                not null,
    ord_gsv_aud                       number                not null,
    ord_gsv_usd                       number                not null,
    ord_gsv_eur                       number                not null,
    con_qty                           number                not null,
    con_qty_base_uom                  number                not null,
    con_qty_gross_tonnes              number                not null,
    con_qty_net_tonnes                number                not null,
    con_gsv                           number                not null,
    con_gsv_xactn                     number                not null,
    con_gsv_aud                       number                not null,
    con_gsv_usd                       number                not null,
    con_gsv_eur                       number                not null,
    req_qty                           number                not null,
    req_qty_base_uom                  number                not null,
    req_qty_gross_tonnes              number                not null,
    req_qty_net_tonnes                number                not null,
    req_gsv                           number                not null,
    req_gsv_xactn                     number                not null,
    req_gsv_aud                       number                not null,
    req_gsv_usd                       number                not null,
    req_gsv_eur                       number                not null,
    del_qty                           number                not null,
    del_qty_base_uom                  number                not null,
    del_qty_gross_tonnes              number                not null,
    del_qty_net_tonnes                number                not null,
    del_gsv                           number                not null,
    del_gsv_xactn                     number                not null,
    del_gsv_aud                       number                not null,
    del_gsv_usd                       number                not null,
    del_gsv_eur                       number                not null,
    inv_qty                           number                not null,
    inv_qty_base_uom                  number                not null,
    inv_qty_gross_tonnes              number                not null,
    inv_qty_net_tonnes                number                not null,
    inv_gsv                           number                not null,
    inv_gsv_xactn                     number                not null,
    inv_gsv_aud                       number                not null,
    inv_gsv_usd                       number                not null,
    inv_gsv_eur                       number                not null,
    out_qty                           number                not null,
    out_qty_base_uom                  number                not null,
    out_qty_gross_tonnes              number                not null,
    out_qty_net_tonnes                number                not null,
    out_gsv                           number                not null,
    out_gsv_xactn                     number                not null,
    out_gsv_aud                       number                not null,
    out_gsv_usd                       number                not null,
    out_gsv_eur                       number                not null,
    mfanz_icb_flag                    varchar2(1 char)      not null,
    demand_plng_grp_division_code     varchar2(2 char)      null);

/**/
/* Comments
/**/
comment on table dds.dw_order_base is 'Order Base Fact Table';
comment on column dds.dw_order_base.order_doc_num is 'Order document number';
comment on column dds.dw_order_base.order_doc_line_num is 'Order document line number';
comment on column dds.dw_order_base.order_line_status is 'Order document line status - *OUTSTANDING, *UNALLOCATED, *DELIVERED, *INVOICED';
comment on column dds.dw_order_base.order_trace_seqn is 'Order document ODS trace sequence';
comment on column dds.dw_order_base.creatn_date is 'Creation date';
comment on column dds.dw_order_base.creatn_yyyyppdd is 'Creation MARS day';
comment on column dds.dw_order_base.creatn_yyyyppw is 'Creation MARS week';
comment on column dds.dw_order_base.creatn_yyyypp is 'Creation MARS period';
comment on column dds.dw_order_base.creatn_yyyymm is 'Creation MARS month';
comment on column dds.dw_order_base.order_eff_date is 'Order effective date';
comment on column dds.dw_order_base.order_eff_yyyyppdd is 'Order effective MARS day';
comment on column dds.dw_order_base.order_eff_yyyyppw is 'Order effective MARS week';
comment on column dds.dw_order_base.order_eff_yyyypp is 'Order effective MARS period';
comment on column dds.dw_order_base.order_eff_yyyymm is 'Order effective MARS month';
comment on column dds.dw_order_base.confirmed_date is 'Order confirmed date';
comment on column dds.dw_order_base.confirmed_yyyyppdd is 'Order confirmed MARS day';
comment on column dds.dw_order_base.confirmed_yyyyppw is 'Order confirmed MARS week';
comment on column dds.dw_order_base.confirmed_yyyypp is 'Order confirmed MARS period';
comment on column dds.dw_order_base.confirmed_yyyymm is 'Order confirmed MARS month';
comment on column dds.dw_order_base.company_code is 'Company code';
comment on column dds.dw_order_base.cust_order_doc_num is 'Customer order document number';
comment on column dds.dw_order_base.cust_order_doc_line_num is 'Customer order document line number';
comment on column dds.dw_order_base.cust_order_due_date is 'Customer order due date';
comment on column dds.dw_order_base.sales_org_code is 'Sales organisation code';
comment on column dds.dw_order_base.distbn_chnl_code is 'Distribution channel code';
comment on column dds.dw_order_base.division_code is 'Division code';
comment on column dds.dw_order_base.doc_currcy_code is 'Document currency code';
comment on column dds.dw_order_base.company_currcy_code is 'Company currency code';
comment on column dds.dw_order_base.exch_rate is 'Exchange rate';
comment on column dds.dw_order_base.order_type_code is 'Order type code';
comment on column dds.dw_order_base.order_reasn_code is 'Order reason code';
comment on column dds.dw_order_base.order_usage_code is 'Order usage code';
comment on column dds.dw_order_base.sold_to_cust_code is 'Sold to customer code';
comment on column dds.dw_order_base.bill_to_cust_code is 'Bill to customer code';
comment on column dds.dw_order_base.payer_cust_code is 'Payer customer code';
comment on column dds.dw_order_base.ship_to_cust_code is 'Ship to customer code';
comment on column dds.dw_order_base.matl_code is 'Material code';
comment on column dds.dw_order_base.ods_matl_code is 'ODS material code';
comment on column dds.dw_order_base.matl_entd is 'Material code entered';
comment on column dds.dw_order_base.plant_code is 'Plant code';
comment on column dds.dw_order_base.storage_locn_code is 'Storage location code';
comment on column dds.dw_order_base.order_line_rejectn_code is 'Order line rejection code';
comment on column dds.dw_order_base.order_weight_unit is 'Order line weight unit code';
comment on column dds.dw_order_base.order_gross_weight is 'Order line gross weight';
comment on column dds.dw_order_base.order_net_weight is 'Order line nett weight';
comment on column dds.dw_order_base.order_uom_code is 'Order line unit of measure code';
comment on column dds.dw_order_base.order_base_uom_code is 'Order line base unit of measure code';
comment on column dds.dw_order_base.ord_qty is 'Ordered quantity';
comment on column dds.dw_order_base.ord_qty_base_uom is 'Ordered quantity in base unit of measure';
comment on column dds.dw_order_base.ord_qty_gross_tonnes is 'Ordered quantity in gross tonnes';
comment on column dds.dw_order_base.ord_qty_net_tonnes is 'Ordered quantity in nett tonnes';
comment on column dds.dw_order_base.ord_gsv is 'Ordered gross sales value';
comment on column dds.dw_order_base.ord_gsv_xactn is 'Ordered gross sales value on transaction';
comment on column dds.dw_order_base.ord_gsv_aud is 'Ordered gross sales value in AUD';
comment on column dds.dw_order_base.ord_gsv_usd is 'Ordered gross sales value in USD';
comment on column dds.dw_order_base.ord_gsv_eur is 'Ordered gross sales value in EUR';
comment on column dds.dw_order_base.con_qty is 'Confirmed quantity';
comment on column dds.dw_order_base.con_qty_base_uom is 'Confirmed quantity in base unit of measure';
comment on column dds.dw_order_base.con_qty_gross_tonnes is 'Confirmed quantity in gross tonnes';
comment on column dds.dw_order_base.con_qty_net_tonnes is 'Confirmed quantity in nett tonnes';
comment on column dds.dw_order_base.con_gsv is 'Confirmed gross sales value';
comment on column dds.dw_order_base.con_gsv_xactn is 'Confirmed gross sales value on transaction';
comment on column dds.dw_order_base.con_gsv_aud is 'Confirmed gross sales value in AUD';
comment on column dds.dw_order_base.con_gsv_usd is 'Confirmed gross sales value in USD';
comment on column dds.dw_order_base.con_gsv_eur is 'Confirmed gross sales value in EUR';
comment on column dds.dw_order_base.req_qty is 'Delivery requested quantity';
comment on column dds.dw_order_base.req_qty_base_uom is 'Delivery requested quantity in base unit of measure';
comment on column dds.dw_order_base.req_qty_gross_tonnes is 'Delivery requested quantity in gross tonnes';
comment on column dds.dw_order_base.req_qty_net_tonnes is 'Delivery requested quantity in nett tonnes';
comment on column dds.dw_order_base.req_gsv is 'Delivery requested gross sales value';
comment on column dds.dw_order_base.req_gsv_xactn is 'Delivery requested gross sales value on transaction';
comment on column dds.dw_order_base.req_gsv_aud is 'Delivery requested gross sales value in AUD';
comment on column dds.dw_order_base.req_gsv_usd is 'Delivery requested gross sales value in USD';
comment on column dds.dw_order_base.req_gsv_eur is 'Delivery requested gross sales value in EUR';
comment on column dds.dw_order_base.del_qty is 'Delivery confirmed quantity';
comment on column dds.dw_order_base.del_qty_base_uom is 'Delivery confirmed quantity in base unit of measure';
comment on column dds.dw_order_base.del_qty_gross_tonnes is 'Delivery confirmed quantity in gross tonnes';
comment on column dds.dw_order_base.del_qty_net_tonnes is 'Delivery confirmed quantity in nett tonnes';
comment on column dds.dw_order_base.del_gsv is 'Delivery confirmed gross sales value';
comment on column dds.dw_order_base.del_gsv_xactn is 'Delivery confirmed gross sales value on transaction';
comment on column dds.dw_order_base.del_gsv_aud is 'Delivery confirmed gross sales value in AUD';
comment on column dds.dw_order_base.del_gsv_usd is 'Delivery confirmed gross sales value in USD';
comment on column dds.dw_order_base.del_gsv_eur is 'Delivery confirmed gross sales value in EUR';
comment on column dds.dw_order_base.inv_qty is 'Invoiced quantity';
comment on column dds.dw_order_base.inv_qty_base_uom is 'Invoiced quantity in base unit of measure';
comment on column dds.dw_order_base.inv_qty_gross_tonnes is 'Invoiced quantity in gross tonnes';
comment on column dds.dw_order_base.inv_qty_net_tonnes is 'Invoiced quantity in nett tonnes';
comment on column dds.dw_order_base.inv_gsv is 'Invoiced gross sales value';
comment on column dds.dw_order_base.inv_gsv_xactn is 'Invoiced gross sales value on transaction';
comment on column dds.dw_order_base.inv_gsv_aud is 'Invoiced gross sales value in AUD';
comment on column dds.dw_order_base.inv_gsv_usd is 'Invoiced gross sales value in USD';
comment on column dds.dw_order_base.inv_gsv_eur is 'Invoiced gross sales value in EUR';
comment on column dds.dw_order_base.out_qty is 'Outstanding quantity';
comment on column dds.dw_order_base.out_qty_base_uom is 'Outstanding quantity in base unit of measure';
comment on column dds.dw_order_base.out_qty_gross_tonnes is 'Outstanding quantity in gross tonnes';
comment on column dds.dw_order_base.out_qty_net_tonnes is 'Outstanding quantity in nett tonnes';
comment on column dds.dw_order_base.out_gsv is 'Outstanding gross sales value';
comment on column dds.dw_order_base.out_gsv_xactn is 'Outstanding gross sales value on transaction';
comment on column dds.dw_order_base.out_gsv_aud is 'Outstanding gross sales value in AUD';
comment on column dds.dw_order_base.out_gsv_usd is 'Outstanding gross sales value in USD';
comment on column dds.dw_order_base.out_gsv_eur is 'Outstanding gross sales value in EUR';
comment on column dds.dw_order_base.mfanz_icb_flag is 'MFANZ ICB flag';
comment on column dds.dw_order_base.demand_plng_grp_division_code is 'Demand planning group division code';

/**/
/* Primary Key Constraint
/**/
alter table dds.dw_order_base
   add constraint dw_order_base_pk primary key (order_doc_num, order_doc_line_num);

/**/
/* Indexes
/**/
create index dds.dw_order_base_ix01 on dds.dw_order_base (company_code, order_trace_seqn);

/**/
/* Authority
/**/
grant select, insert, update, delete on dds.dw_order_base to dw_app;
grant select on dds.dw_order_base to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_order_base for dds.dw_order_base;
