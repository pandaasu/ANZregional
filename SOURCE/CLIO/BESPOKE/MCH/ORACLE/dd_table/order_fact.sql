/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 Object : order_fact
 Owner  : dd

 Description
 -----------
 Data Warehouse - Order Fact Table

 YYYY/MM   Author         Description
 -------   ------         -----------
 2006/03   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table dd.order_fact
   (ord_doc_num                       varchar2(10 char)     not null,
    ord_doc_line_num                  varchar2(6 char)      not null,
    ord_lin_status                    varchar2(4 char)      not null,
    del_doc_num                       varchar2(10 char)     null,
    del_doc_line_num                  varchar2(6 char)      null,
    ord_trn_date                      date                  null,
    del_trn_date                      date                  null,
    pod_trn_date                      date                  null,
    creation_date                     date                  null,
    creation_yyyyppdd                 number(8,0)           null,
    creation_yyyyppw                  number(7,0)           null,
    creation_yyyypp                   number(6,0)           null,
    creation_yyyymm                   number(6,0)           null,
    agr_date                          date                  null,
    agr_yyyyppdd                      number(8,0)           null,
    agr_yyyyppw                       number(7,0)           null,
    agr_yyyypp                        number(6,0)           null,
    agr_yyyymm                        number(6,0)           null,
    sch_date                          date                  null,
    sch_yyyyppdd                      number(8,0)           null,
    sch_yyyyppw                       number(7,0)           null,
    sch_yyyypp                        number(6,0)           null,
    sch_yyyymm                        number(6,0)           null,
    del_date                          date                  null,
    del_yyyyppdd                      number(8,0)           null,
    del_yyyyppw                       number(7,0)           null,
    del_yyyypp                        number(6,0)           null,
    del_yyyymm                        number(6,0)           null,
    pod_date                          date                  null,
    pod_yyyyppdd                      number(8,0)           null,
    pod_yyyyppw                       number(7,0)           null,
    pod_yyyypp                        number(6,0)           null,
    pod_yyyymm                        number(6,0)           null,
    pod_refusal                       varchar2(5 char)      null,
    sap_company_code                  varchar2(6 char)      not null,
    sap_order_type_code               varchar2(4 char)      null,
    sap_order_reasn_code              varchar2(3 char)      null,
    sap_order_usage_code              varchar2(3 char)      null,
    sap_doc_currcy_code               varchar2(5 char)      null,
    sap_sold_to_cust_code             varchar2(10 char)     null,
    sap_bill_to_cust_code             varchar2(10 char)     null,
    sap_payer_cust_code               varchar2(10 char)     null,
    sap_ship_to_cust_code             varchar2(10 char)     null,
    sap_sales_hdr_sales_org_code      varchar2(4 char)      null,
    sap_sales_hdr_distbn_chnl_code    varchar2(2 char)      null,
    sap_sales_hdr_division_code       varchar2(2 char)      null,
    sap_plant_code                    varchar2(4 char)      null,
    sap_storage_locn_code             varchar2(4 char)      null,
    sap_ord_qty_uom_code              varchar2(3 char)      null,
    sap_ord_qty_base_uom_code         varchar2(3 char)      null,
    sap_del_qty_uom_code              varchar2(3 char)      null,
    sap_del_qty_base_uom_code         varchar2(3 char)      null,
    sap_ord_material                  varchar2(18 char)     null,
    sap_del_material                  varchar2(18 char)     null,
    sap_material_code                 varchar2(18 char)     null,
    material_entd                     varchar2(35 char)     null,
    purch_order_num                   varchar2(35 char)     null,
    exch_rate                         number                null,
    ord_qty                           number                null,
    ord_base_uom_qty                  number                null,
    ord_pieces_qty                    number                null,
    ord_tonnes_qty                    number                null,
    ord_gsv                           number                null,
    ord_niv                           number                null,
    sch_qty                           number                null,
    sch_base_uom_qty                  number                null,
    sch_pieces_qty                    number                null,
    sch_tonnes_qty                    number                null,
    sch_gsv                           number                null,
    sch_niv                           number                null,
    del_qty                           number                null,
    del_base_uom_qty                  number                null,
    del_pieces_qty                    number                null,
    del_tonnes_qty                    number                null,
    del_gsv                           number                null,
    del_niv                           number                null,
    pod_qty                           number                null,
    pod_base_uom_qty                  number                null,
    pod_pieces_qty                    number                null,
    pod_tonnes_qty                    number                null,
    pod_gsv                           number                null,
    pod_niv                           number                null);

/**/
/* Comments
/**/
comment on table dd.order_fact is 'Order Fact Table';
comment on column dd.order_fact.ord_doc_num is 'Order Document Number';
comment on column dd.order_fact.ord_doc_line_num is 'Order Document Line Number';
comment on column dd.order_fact.ord_lin_status is 'Order line status - *UPD, *NVL, *ORD, *DEL, *POD, *INV';
comment on column dd.order_fact.del_doc_num is 'Delivery Document Number';
comment on column dd.order_fact.del_doc_line_num is 'Delivery Document Line Number';
comment on column dd.order_fact.ord_trn_date is 'Order Transaction Date';
comment on column dd.order_fact.del_trn_date is 'Delivery Transaction Date';
comment on column dd.order_fact.pod_trn_date is 'POD Transaction Date';
comment on column dd.order_fact.creation_date is 'Creation Date';
comment on column dd.order_fact.creation_yyyyppdd is 'Creation Date in the format YYYYPPDD';
comment on column dd.order_fact.creation_yyyyppw is 'Creation Date in the format YYYYPPW';
comment on column dd.order_fact.creation_yyyypp is 'Creation Date in the format YYYYPP';
comment on column dd.order_fact.creation_yyyymm is 'Creation Date in the format YYYYMM';
comment on column dd.order_fact.agr_date is 'Agreed delivery date';
comment on column dd.order_fact.agr_yyyyppdd is 'Agreed delivery date in the format YYYYPPDD';
comment on column dd.order_fact.agr_yyyyppw is 'Agreed delivery date in the format YYYYPPW';
comment on column dd.order_fact.agr_yyyypp is 'Agreed delivery date in the format YYYYPP';
comment on column dd.order_fact.agr_yyyymm is 'Agreed delivery date in the format YYYYMM';
comment on column dd.order_fact.sch_date is 'Scheduled delivery date';
comment on column dd.order_fact.sch_yyyyppdd is 'Scheduled delivery date in the format YYYYPPDD';
comment on column dd.order_fact.sch_yyyyppw is 'Scheduled delivery date in the format YYYYPPW';
comment on column dd.order_fact.sch_yyyypp is 'Scheduled delivery date in the format YYYYPP';
comment on column dd.order_fact.sch_yyyymm is 'Scheduled delivery date in the format YYYYMM';
comment on column dd.order_fact.del_date is 'Delivery date';
comment on column dd.order_fact.del_yyyyppdd is 'Delivery date in the format YYYYPPDD';
comment on column dd.order_fact.del_yyyyppw is 'Delivery date in the format YYYYPPW';
comment on column dd.order_fact.del_yyyypp is 'Delivery date in the format YYYYPP';
comment on column dd.order_fact.del_yyyymm is 'Delivery date in the format YYYYMM';
comment on column dd.order_fact.pod_date is 'POD date';
comment on column dd.order_fact.pod_yyyyppdd is 'POD date in the format YYYYPPDD';
comment on column dd.order_fact.pod_yyyyppw is 'POD date in the format YYYYPPW';
comment on column dd.order_fact.pod_yyyypp is 'POD date in the format YYYYPP';
comment on column dd.order_fact.pod_yyyymm is 'POD date in the format YYYYMM';
comment on column dd.order_fact.pod_refusal is 'POD refusal - *NONE, *MARS, *CUST';
comment on column dd.order_fact.sap_company_code is 'SAP Company Code';
comment on column dd.order_fact.sap_order_type_code is 'SAP Order Type Code';
comment on column dd.order_fact.sap_order_reasn_code is 'SAP Order Reason Code';
comment on column dd.order_fact.sap_order_usage_code is 'SAP Order Usage Code';
comment on column dd.order_fact.sap_doc_currcy_code is 'SAP Document Currency Code';
comment on column dd.order_fact.sap_sold_to_cust_code is 'SAP Sold-To Customer Code';
comment on column dd.order_fact.sap_bill_to_cust_code is 'SAP Bill-To Customer Code';
comment on column dd.order_fact.sap_payer_cust_code is 'SAP Payer Customer Code';
comment on column dd.order_fact.sap_ship_to_cust_code is 'SAP Ship-To Customer Code';
comment on column dd.order_fact.sap_sales_hdr_sales_org_code is 'SAP Sales Header Sales Organisation Code';
comment on column dd.order_fact.sap_sales_hdr_distbn_chnl_code is 'SAP Sales Header Distribution Channel Code';
comment on column dd.order_fact.sap_sales_hdr_division_code is 'SAP Sales Header Division Code';
comment on column dd.order_fact.sap_plant_code is 'SAP Plant Code';
comment on column dd.order_fact.sap_storage_locn_code is 'SAP Storage Location Code';
comment on column dd.order_fact.sap_ord_qty_uom_code is 'SAP Order Qty UOM Code';
comment on column dd.order_fact.sap_ord_qty_base_uom_code is 'SAP Order Qty Base UOM Code';
comment on column dd.order_fact.sap_del_qty_uom_code is 'SAP Delivery Qty UOM Code';
comment on column dd.order_fact.sap_del_qty_base_uom_code is 'SAP Delivery Qty Base UOM Code';
comment on column dd.order_fact.sap_ord_material is 'SAP Order Material Code';
comment on column dd.order_fact.sap_del_material is 'SAP Delivery Material Code';
comment on column dd.order_fact.sap_material_code is 'SAP Material Code';
comment on column dd.order_fact.material_entd is 'Representative Item or EAN-UPC Code, etc';
comment on column dd.order_fact.purch_order_num is 'Purchase Order Number';
comment on column dd.order_fact.exch_rate is 'Exchange Rate';
comment on column dd.order_fact.ord_qty is 'Order Qty';
comment on column dd.order_fact.ord_base_uom_qty is 'Order Base UOM Qty';
comment on column dd.order_fact.ord_pieces_qty is 'Order Pieces Qty';
comment on column dd.order_fact.ord_tonnes_qty is 'Order Tonnes Qty';
comment on column dd.order_fact.ord_gsv is 'Order GSV Value';
comment on column dd.order_fact.ord_niv is 'Order NIV Value';
comment on column dd.order_fact.sch_qty is 'Scheduled Qty';
comment on column dd.order_fact.sch_base_uom_qty is 'Scheduled Base UOM Qty';
comment on column dd.order_fact.sch_pieces_qty is 'Scheduled Pieces Qty';
comment on column dd.order_fact.sch_tonnes_qty is 'Scheduled Tonnes Qty';
comment on column dd.order_fact.sch_gsv is 'Scheduled GSV Value';
comment on column dd.order_fact.sch_niv is 'Scheduled NIV Value';
comment on column dd.order_fact.del_qty is 'Delivered Qty';
comment on column dd.order_fact.del_base_uom_qty is 'Delivered Base UOM Qty';
comment on column dd.order_fact.del_pieces_qty is 'Delivered Pieces Qty';
comment on column dd.order_fact.del_tonnes_qty is 'Delivered Tonnes Qty';
comment on column dd.order_fact.del_gsv is 'Delivered GSV Value';
comment on column dd.order_fact.del_niv is 'Delivered NIV Value';
comment on column dd.order_fact.pod_qty is 'POD Qty';
comment on column dd.order_fact.pod_base_uom_qty is 'POD Base UOM Qty';
comment on column dd.order_fact.pod_pieces_qty is 'POD Pieces Qty';
comment on column dd.order_fact.pod_tonnes_qty is 'POD Tonnes Qty';
comment on column dd.order_fact.pod_gsv is 'POD GSV Value';
comment on column dd.order_fact.pod_niv is 'POD NIV Value';

/**/
/* Primary Key Constraint
/**/
alter table dd.order_fact
   add constraint order_fact_pk primary key (ord_doc_num, ord_doc_line_num);

/**/
/* Indexes
/**/
create index dd.order_fact_ix01 on dd.order_fact (ord_doc_num, ord_doc_line_num, ord_lin_status);
create index dd.order_fact_ix02 on dd.order_fact (ord_doc_num, ord_doc_line_num, sap_company_code, ord_lin_status);

/**/
/* Authority
/**/
grant select, insert, update, delete on dd.order_fact to dw_app;
grant select on dd.order_fact to bo_user;
grant select on dd.order_fact to pld_rep_app;
grant select on dd.order_fact to hermes_app;

/**/
/* Synonym
/**/
create or replace public synonym order_fact for dd.order_fact;
