/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_cust_sales_area
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Customer Sales Area

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_cust_sales_area
   (customer_code                      varchar2(10 char)        not null,
    sales_org_code                     varchar2(5 char)         not null,
    distbn_chnl_code                   varchar2(5 char)         not null,
    division_code                      varchar2(5 char)         not null,
    auth_group_code                    varchar2(4 char)         null,
    deletion_flag                      varchar2(1 char)         null,
    statistics_group                   varchar2(1 char)         null,
    order_block_flag                   varchar2(2 char)         null,
    pricing_procedure                  varchar2(1 char)         null,
    group_code                         varchar2(2 char)         null,
    sales_district                     varchar2(6 char)         null,
    price_group                        varchar2(2 char)         null,
    price_list_type                    varchar2(2 char)         null,
    order_probability                  number                   null,
    inter_company_terms_01             varchar2(3 char)         null,
    inter_company_terms_02             varchar2(28 char)        null,
    delivery_block_flag                varchar2(2 char)         null,
    order_complete_delivery_flag       varchar2(1 char)         null,
    partial_item_delivery_max          number                   null,
    partial_item_delivery_flag         varchar2(1 char)         null,
    order_combination_flag             varchar2(1 char)         null,
    split_batch_flag                   varchar2(1 char)         null,
    delivery_priority                  number                   null,
    shipper_account_number             varchar2(12 char)        null,
    ship_conditions                    varchar2(2 char)         null,
    billing_block_flag                 varchar2(2 char)         null,
    manual_invoice_flag                varchar2(1 char)         null,
    invoice_dates                      varchar2(2 char)         null,
    invoice_list_schedule              varchar2(2 char)         null,
    currency_code                      varchar2(5 char)         null,
    account_assign_group               varchar2(2 char)         null,
    payment_terms_key                  varchar2(4 char)         null,
    delivery_plant_code                varchar2(4 char)         null,
    sales_group_code                   varchar2(3 char)         null,
    sales_office_code                  varchar2(4 char)         null,
    item_proposal                      varchar2(10 char)        null,
    invoice_combination                varchar2(3 char)         null,
    price_band_expected                varchar2(3 char)         null,
    accept_int_pallet                  varchar2(3 char)         null,
    price_band_guaranteed              varchar2(3 char)         null,
    back_order_flag                    varchar2(3 char)         null,
    rebate_flag                        varchar2(1 char)         null,
    exchange_rate_type                 varchar2(4 char)         null,
    price_determination_id             varchar2(1 char)         null,
    abc_classification                 varchar2(2 char)         null,
    payment_guarantee_proc             varchar2(4 char)         null,
    credit_control_area                varchar2(4 char)         null,
    sales_block_flag                   varchar2(2 char)         null,
    rounding_off                       varchar2(1 char)         null,
    agency_business_flag               varchar2(1 char)         null,
    uom_group                          varchar2(4 char)         null,
    over_delivery_tolerance            varchar2(4 char)         null,
    under_delivery_tolerance           varchar2(4 char)         null,
    unlimited_over_delivery            varchar2(1 char)         null,
    product_proposal_proc              varchar2(2 char)         null,
    pod_processing                     varchar2(1 char)         null,
    pod_confirm_timeframe              varchar2(11 char)        null,
    po_index_compilation               varchar2(1 char)         null,
    batch_search_strategy              number                   null,
    vmi_input_method                   number                   null,
    current_planning_flag              varchar2(1 char)         null,
    future_planning_flag               varchar2(1 char)         null,
    market_account_flag                varchar2(1 char)         null,
    cust_pack_instr_validation         varchar2(1 char)         null,
    cust_pallet_max_height             number                   null,
    cust_pallet_max_height_uom         varchar2(3 char)         null,
    layer_homogeneous_pick_pallet      varchar2(1 char)         null,
    case_homogeneous_pick_pallet       varchar2(1 char)         null,
    transport_modules_flag             varchar2(1 char)         null,
    pick_pallet_pack_material          varchar2(18 char)        null,
    pick_pallet_max_height             number                   null,
    pick_pallet_max_height_uom         varchar2(3 char)         null);

/*-*/
/* Comments
/*-*/
comment on table bds_cust_sales_area is 'Business Data Store - Customer Sales Area';
comment on column bds_cust_sales_area.customer_code is 'Customer Number - lads_cus_sad.kunnr';
comment on column bds_cust_sales_area.sales_org_code is 'Sales Organization - lads_cus_sad.vkorg';
comment on column bds_cust_sales_area.distbn_chnl_code is 'Distribution Channel - lads_cus_sad.vtweg';
comment on column bds_cust_sales_area.division_code is 'Division - lads_cus_sad.spart';
comment on column bds_cust_sales_area.auth_group_code is 'Authorization Group - lads_cus_sad.begru';
comment on column bds_cust_sales_area.deletion_flag is 'Deletion flag for customer (sales level) - lads_cus_sad.loevm';
comment on column bds_cust_sales_area.statistics_group is 'Customer statistics group - lads_cus_sad.versg';
comment on column bds_cust_sales_area.order_block_flag is 'Customer order block (sales area) - lads_cus_sad.aufsd';
comment on column bds_cust_sales_area.pricing_procedure is 'Pricing procedure assigned to this customer - lads_cus_sad.kalks';
comment on column bds_cust_sales_area.group_code is 'Customer group - lads_cus_sad.kdgrp';
comment on column bds_cust_sales_area.sales_district is 'Sales district - lads_cus_sad.bzirk';
comment on column bds_cust_sales_area.price_group is 'Price group (customer) - lads_cus_sad.konda';
comment on column bds_cust_sales_area.price_list_type is 'Price list type - lads_cus_sad.pltyp';
comment on column bds_cust_sales_area.order_probability is 'Order probability of the item - lads_cus_sad.awahr';
comment on column bds_cust_sales_area.inter_company_terms_01 is 'Incoterms (part 1) - lads_cus_sad.inco1';
comment on column bds_cust_sales_area.inter_company_terms_02 is 'Incoterms (part 2) - lads_cus_sad.inco2';
comment on column bds_cust_sales_area.delivery_block_flag is 'Customer delivery block (sales area) - lads_cus_sad.lifsd';
comment on column bds_cust_sales_area.order_complete_delivery_flag is 'Complete delivery defined for each sales order? - lads_cus_sad.autlf';
comment on column bds_cust_sales_area.partial_item_delivery_max is 'Maximum Number of Partial Deliveries Allowed Per Item - lads_cus_sad.antlf';
comment on column bds_cust_sales_area.partial_item_delivery_flag is 'Partial delivery at item level - lads_cus_sad.kztlf';
comment on column bds_cust_sales_area.order_combination_flag is 'Order combination indicator - lads_cus_sad.kzazu';
comment on column bds_cust_sales_area.split_batch_flag is 'Batch split allowed - lads_cus_sad.chspl';
comment on column bds_cust_sales_area.delivery_priority is 'Delivery Priority - lads_cus_sad.lprio';
comment on column bds_cust_sales_area.shipper_account_number is 'Shippers (Our) Account Number at the Customer or Vendor - lads_cus_sad.eikto';
comment on column bds_cust_sales_area.ship_conditions is 'Shipping conditions - lads_cus_sad.vsbed';
comment on column bds_cust_sales_area.billing_block_flag is 'Billing block for customer (sales and distribution) - lads_cus_sad.faksd';
comment on column bds_cust_sales_area.manual_invoice_flag is 'Manual invoice maintenance - lads_cus_sad.mrnkz';
comment on column bds_cust_sales_area.invoice_dates is 'Invoice dates (calendar identification) - lads_cus_sad.perfk';
comment on column bds_cust_sales_area.invoice_list_schedule is 'Invoice list schedule (calendar identification) - lads_cus_sad.perrl';
comment on column bds_cust_sales_area.currency_code is 'Currency - lads_cus_sad.waers';
comment on column bds_cust_sales_area.account_assign_group is 'Account assignment group for this customer - lads_cus_sad.ktgrd';
comment on column bds_cust_sales_area.payment_terms_key is 'Terms of payment key - lads_cus_sad.zterm';
comment on column bds_cust_sales_area.delivery_plant_code is 'Delivering Plant - lads_cus_sad.vwerk';
comment on column bds_cust_sales_area.sales_group_code is 'Sales group - lads_cus_sad.vkgrp';
comment on column bds_cust_sales_area.sales_office_code is 'Sales office - lads_cus_sad.vkbur';
comment on column bds_cust_sales_area.item_proposal is 'Item proposal - lads_cus_sad.vsort';
comment on column bds_cust_sales_area.invoice_combination is 'Invoice Combina - lads_cus_sad.kvgr1';
comment on column bds_cust_sales_area.price_band_expected is 'Expected Band Price - lads_cus_sad.kvgr2';
comment on column bds_cust_sales_area.accept_int_pallet is 'Cust. Accept Int. Pallet - lads_cus_sad.kvgr3';
comment on column bds_cust_sales_area.price_band_guaranteed is 'Guaranteed Band Price - lads_cus_sad.kvgr4';
comment on column bds_cust_sales_area.back_order_flag is 'Back Order Accepted - lads_cus_sad.kvgr5';
comment on column bds_cust_sales_area.rebate_flag is 'ID: Customer is to receive rebates - lads_cus_sad.bokre';
comment on column bds_cust_sales_area.exchange_rate_type is 'Exchange Rate Type - lads_cus_sad.kurst';
comment on column bds_cust_sales_area.price_determination_id is 'Relevant for price determination ID - lads_cus_sad.prfre';
comment on column bds_cust_sales_area.abc_classification is 'Customer classification (ABC analysis) - lads_cus_sad.klabc';
comment on column bds_cust_sales_area.payment_guarantee_proc is 'Customer payment guarantee procedure - lads_cus_sad.kabss';
comment on column bds_cust_sales_area.credit_control_area is 'Credit control area - lads_cus_sad.kkber';
comment on column bds_cust_sales_area.sales_block_flag is 'Sales block for customer (sales area) - lads_cus_sad.cassd';
comment on column bds_cust_sales_area.rounding_off is 'Switch off rounding? - lads_cus_sad.rdoff';
comment on column bds_cust_sales_area.agency_business_flag is 'Indicator: Relevant for agency business - lads_cus_sad.agrel';
comment on column bds_cust_sales_area.uom_group is 'Unit of measure group - lads_cus_sad.megru';
comment on column bds_cust_sales_area.over_delivery_tolerance is 'Overdelivery tolerance limit (BTCI) - lads_cus_sad.uebto';
comment on column bds_cust_sales_area.under_delivery_tolerance is 'Underdelivery tolerance (BTCI) - lads_cus_sad.untto';
comment on column bds_cust_sales_area.unlimited_over_delivery is 'Unlimited overdelivery allowed - lads_cus_sad.uebtk';
comment on column bds_cust_sales_area.product_proposal_proc is 'Customer procedure for product proposal - lads_cus_sad.pvksm';
comment on column bds_cust_sales_area.pod_processing is 'Relevant for POD processing - lads_cus_sad.podkz';
comment on column bds_cust_sales_area.pod_confirm_timeframe is 'Timeframe for Confirmation of POD (BI) - lads_cus_sad.podtg';
comment on column bds_cust_sales_area.po_index_compilation is 'Indicator: Doc. index compilation active for purchase orders - lads_cus_sad.blind';
comment on column bds_cust_sales_area.batch_search_strategy is 'Customer Group for Batch Search Strategy - lads_cus_sad.zzshelfgrp';
comment on column bds_cust_sales_area.vmi_input_method is 'VMI Customer Data Input Method - lads_cus_sad.zzvmicdim';
comment on column bds_cust_sales_area.current_planning_flag is 'Current Planning Flag - lads_cus_sad.zzcurrentflag';
comment on column bds_cust_sales_area.future_planning_flag is 'Future Planning Flag - lads_cus_sad.zzfutureflag';
comment on column bds_cust_sales_area.market_account_flag is 'Market Headquarter Account Flag - lads_cus_sad.zzmarketacctflag';
comment on column bds_cust_sales_area.cust_pack_instr_validation is 'Customer Specific Packing Instruction Validation';
comment on column bds_cust_sales_area.cust_pallet_max_height is 'Customer Maximum Pallet Height';
comment on column bds_cust_sales_area.cust_pallet_max_height_uom is 'Customer Maximum Pallet Height UoM';
comment on column bds_cust_sales_area.layer_homogeneous_pick_pallet is 'Homogeneous pick pallet for layers';
comment on column bds_cust_sales_area.case_homogeneous_pick_pallet is 'Homogenous pick pallet for cases';
comment on column bds_cust_sales_area.transport_modules_flag is 'Transport modules required';
comment on column bds_cust_sales_area.pick_pallet_pack_material is 'Pick Pallet packaging material';
comment on column bds_cust_sales_area.pick_pallet_max_height is 'Pick pallet maximum Height';
comment on column bds_cust_sales_area.pick_pallet_max_height_uom is 'Pick pallet maximum Height UoM';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_cust_sales_area
   add constraint bds_cust_sales_area_pk primary key (customer_code, sales_org_code, distbn_chnl_code, division_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_cust_sales_area to lics_app;
grant select, insert, update, delete on bds_cust_sales_area to lads_app;
grant select, insert, update, delete on bds_cust_sales_area to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_cust_sales_area for bds.bds_cust_sales_area;