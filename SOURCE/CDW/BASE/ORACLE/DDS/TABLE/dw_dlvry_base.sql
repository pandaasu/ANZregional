/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : dw_dlvry_base
 Owner  : dds

 Description
 -----------
 Data Warehouse - Delivery Base Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/11   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dds.dw_dlvry_base
   (dlvry_doc_num                     varchar2(10 char)     not null,
    dlvry_doc_line_num                varchar2(10 char)     not null,
    dlvry_line_status                 varchar2(12 char)     not null,
    dlvry_trace_seqn                  number                not null,
    creatn_date                       date                  not null,
    creatn_yyyyppdd                   number(8,0)           not null,
    creatn_yyyyppw                    number(7,0)           not null,
    creatn_yyyypp                     number(6,0)           not null,
    creatn_yyyymm                     number(6,0)           not null,
    dlvry_eff_date                    date                  not null,
    dlvry_eff_yyyyppdd                number(8,0)           not null,
    dlvry_eff_yyyyppw                 number(7,0)           not null,
    dlvry_eff_yyyypp                  number(6,0)           not null,
    dlvry_eff_yyyymm                  number(6,0)           not null,
    goods_issue_date                  date                  null,
    goods_issue_yyyyppdd              number(8,0)           null,
    goods_issue_yyyyppw               number(7,0)           null,
    goods_issue_yyyypp                number(6,0)           null,
    goods_issue_yyyymm                number(6,0)           null,
    order_doc_num                     varchar2(10 char)     null,
    order_doc_line_num                varchar2(10 char)     null,
    purch_order_doc_num               varchar2(10 char)     null,
    purch_order_doc_line_num          varchar2(10 char)     null,
    company_code                      varchar2(10 char)     not null,
    sales_org_code                    varchar2(10 char)     not null,
    distbn_chnl_code                  varchar2(10 char)     null,
    division_code                     varchar2(10 char)     null,
    doc_currcy_code                   varchar2(10 char)     not null,
    company_currcy_code               varchar2(10 char)     not null,
    exch_rate                         number                not null,
    dlvry_type_code                   varchar2(10 char)     null,
    dlvry_procg_stage                 varchar2(10 char)     not null,
    sold_to_cust_code                 varchar2(10 char)     null,
    bill_to_cust_code                 varchar2(10 char)     null,
    payer_cust_code                   varchar2(10 char)     null,
    ship_to_cust_code                 varchar2(10 char)     null,
    matl_code                         varchar2(18 char)     not null,
    ods_matl_code                     varchar2(18 char)     not null,
    matl_entd                         varchar2(35 char)     null,
    plant_code                        varchar2(10 char)     null,
    storage_locn_code                 varchar2(10 char)     null,
    dlvry_weight_unit                 varchar2(10 char)     null,
    dlvry_gross_weight                number                not null,
    dlvry_net_weight                  number                not null,
    dlvry_uom_code                    varchar2(10 char)     null,
    dlvry_base_uom_code               varchar2(10 char)     null,
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
    mfanz_icb_flag                    varchar2(1 char)      not null,
    demand_plng_grp_division_code     varchar2(2 char)      null);

/**/
/* Comments
/**/
comment on table dds.dw_dlvry_base is 'Delivery Base Fact Table';
comment on column dds.dw_dlvry_base.dlvry_doc_num is 'Delivery document number';
comment on column dds.dw_dlvry_base.dlvry_doc_line_num is 'Delivery document line number';
comment on column dds.dw_dlvry_base.dlvry_line_status is 'Delivery document line status - *OPEN, *CLOSED';
comment on column dds.dw_dlvry_base.dlvry_trace_seqn is 'Delivery document ODS trace sequence';
comment on column dds.dw_dlvry_base.creatn_date is 'Creation date';
comment on column dds.dw_dlvry_base.creatn_yyyyppdd is 'Creation MARS day';
comment on column dds.dw_dlvry_base.creatn_yyyyppw is 'Creation MARS week';
comment on column dds.dw_dlvry_base.creatn_yyyypp is 'Creation MARS Period';
comment on column dds.dw_dlvry_base.creatn_yyyymm is 'Creation MARS month';
comment on column dds.dw_dlvry_base.dlvry_eff_date is 'Delivery effective date';
comment on column dds.dw_dlvry_base.dlvry_eff_yyyyppdd is 'Delivery effective MARS day';
comment on column dds.dw_dlvry_base.dlvry_eff_yyyyppw is 'Delivery effective MARS week';
comment on column dds.dw_dlvry_base.dlvry_eff_yyyypp is 'Delivery effective MARS period';
comment on column dds.dw_dlvry_base.dlvry_eff_yyyymm is 'Delivery effective MARS month';
comment on column dds.dw_dlvry_base.goods_issue_date is 'Goods issued date';
comment on column dds.dw_dlvry_base.goods_issue_yyyyppdd is 'Goods issued MARS day';
comment on column dds.dw_dlvry_base.goods_issue_yyyyppw is 'Goods issued MARS week';
comment on column dds.dw_dlvry_base.goods_issue_yyyypp is 'Goods issued MARS period';
comment on column dds.dw_dlvry_base.goods_issue_yyyymm is 'Goods issued MARS month';
comment on column dds.dw_dlvry_base.order_doc_num is 'Order document number';
comment on column dds.dw_dlvry_base.order_doc_line_num is 'Order document line number';
comment on column dds.dw_dlvry_base.purch_order_doc_num is 'Purchase order document number';
comment on column dds.dw_dlvry_base.purch_order_doc_line_num is 'Purchase order document line number';
comment on column dds.dw_dlvry_base.company_code is 'Company code';
comment on column dds.dw_dlvry_base.sales_org_code is 'Sales organisation code';
comment on column dds.dw_dlvry_base.distbn_chnl_code is 'Distribution channel code';
comment on column dds.dw_dlvry_base.division_code is 'Division code';
comment on column dds.dw_dlvry_base.doc_currcy_code is 'Document currency code';
comment on column dds.dw_dlvry_base.company_currcy_code is 'Company currency code';
comment on column dds.dw_dlvry_base.exch_rate is 'Exchange rate';
comment on column dds.dw_dlvry_base.dlvry_type_code is 'Delivery type code';
comment on column dds.dw_dlvry_base.dlvry_procg_stage is 'Delivery processing stage';
comment on column dds.dw_dlvry_base.sold_to_cust_code is 'Sold to customer code';
comment on column dds.dw_dlvry_base.bill_to_cust_code is 'Bill to customer code';
comment on column dds.dw_dlvry_base.payer_cust_code is 'Payer customer code';
comment on column dds.dw_dlvry_base.ship_to_cust_code is 'Ship to customer code';
comment on column dds.dw_dlvry_base.matl_code is 'Material code';
comment on column dds.dw_dlvry_base.ods_matl_code is 'ODS material code';
comment on column dds.dw_dlvry_base.matl_entd is 'Material code entered';
comment on column dds.dw_dlvry_base.plant_code is 'Plant code';
comment on column dds.dw_dlvry_base.storage_locn_code is 'Storage location code';
comment on column dds.dw_dlvry_base.dlvry_weight_unit is 'Delivery line weight unit code';
comment on column dds.dw_dlvry_base.dlvry_gross_weight is 'Delivery line gross weight';
comment on column dds.dw_dlvry_base.dlvry_net_weight is 'Delivery line nett weight';
comment on column dds.dw_dlvry_base.dlvry_uom_code is 'Delivery line unit of measure code';
comment on column dds.dw_dlvry_base.dlvry_base_uom_code is 'Delivery line base unit of measure code';
comment on column dds.dw_dlvry_base.del_qty is 'Delivered quantity';
comment on column dds.dw_dlvry_base.del_qty_base_uom is 'Delivered quantity in base unit of measure';
comment on column dds.dw_dlvry_base.del_qty_gross_tonnes is 'Delivered quantity in gross tonnes';
comment on column dds.dw_dlvry_base.del_qty_net_tonnes is 'Delivered quantity in nett tonnes';
comment on column dds.dw_dlvry_base.del_gsv is 'Delivered gross sales value';
comment on column dds.dw_dlvry_base.del_gsv_xactn is 'Delivered gross sales value on transaction';
comment on column dds.dw_dlvry_base.del_gsv_aud is 'Delivered gross sales value in AUD';
comment on column dds.dw_dlvry_base.del_gsv_usd is 'Delivered gross sales value in USD';
comment on column dds.dw_dlvry_base.del_gsv_eur is 'Delivered gross sales value in EUR';
comment on column dds.dw_dlvry_base.inv_qty is 'Invoiced quantity';
comment on column dds.dw_dlvry_base.inv_qty_base_uom is 'Invoiced quantity in base unit of measure';
comment on column dds.dw_dlvry_base.inv_qty_gross_tonnes is 'Invoiced quantity in gross tonnes';
comment on column dds.dw_dlvry_base.inv_qty_net_tonnes is 'Invoiced quantity in nett tonnes';
comment on column dds.dw_dlvry_base.inv_gsv is 'Invoiced gross sales value';
comment on column dds.dw_dlvry_base.inv_gsv_xactn is 'Invoiced gross sales value on transaction';
comment on column dds.dw_dlvry_base.inv_gsv_aud is 'Invoiced gross sales value in AUD';
comment on column dds.dw_dlvry_base.inv_gsv_usd is 'Invoiced gross sales value in USD';
comment on column dds.dw_dlvry_base.inv_gsv_eur is 'Invoiced gross sales value in EUR';
comment on column dds.dw_dlvry_base.mfanz_icb_flag is 'MFANZ ICB flag';
comment on column dds.dw_dlvry_base.demand_plng_grp_division_code is 'Demand planning group division code';

/**/
/* Primary Key Constraint
/**/
alter table dds.dw_dlvry_base
   add constraint dw_dlvry_base_pk primary key (dlvry_doc_num, dlvry_doc_line_num);

/**/
/* Indexes
/**/
create index dds.dw_dlvry_base_ix01 on dds.dw_dlvry_base (company_code, dlvry_doc_num, dlvry_doc_line_num);
create index dds.dw_dlvry_base_ix02 on dds.dw_dlvry_base (company_code, dlvry_trace_seqn);
create index dds.dw_dlvry_base_ix03 on dds.dw_dlvry_base (company_code, dlvry_line_status);
create index dds.dw_dlvry_base_ix04 on dds.dw_dlvry_base (company_code, order_doc_num, order_doc_line_num);
create index dds.dw_dlvry_base_ix05 on dds.dw_dlvry_base (company_code, purch_order_doc_num, purch_order_doc_line_num);

/**/
/* Authority
/**/
grant select, insert, update, delete on dds.dw_dlvry_base to dw_app;
grant select on dds.dw_dlvry_base to public;

/**/
/* Synonym
/**/
create or replace public synonym dw_dlvry_base for dds.dw_dlvry_base;