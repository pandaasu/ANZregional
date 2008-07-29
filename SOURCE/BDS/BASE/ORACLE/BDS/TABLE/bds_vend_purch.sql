/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_purch
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Purchasing

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_purch
   (vendor_code                        varchar2(10 char)        not null,
    purch_org_code                     varchar2(6 char)         not null,
    create_date                        date                     null,
    create_user                        varchar2(12 char)        null,
    purchase_block_flag                varchar2(1 char)         null,
    deletion_flag                      varchar2(1 char)         null,
    abc_flag                           varchar2(1 char)         null,
    purch_ord_currency                 varchar2(5 char)         null,
    vendor_salesperson                 varchar2(30 char)        null,
    vendor_phone                       varchar2(16 char)        null,
    order_value_minimum                number                   null,
    payment_terms                      varchar2(4 char)         null,
    inter_company_terms_01             varchar2(3 char)         null,
    inter_company_terms_02             varchar2(28 char)        null,
    invoice_verify_flag                varchar2(1 char)         null,
    order_acknowledgment_flag          varchar2(1 char)         null,
    calc_schema_group                  varchar2(2 char)         null,
    purch_order_auto_gen_flag          varchar2(1 char)         null,
    foreign_transport_mode             varchar2(1 char)         null,
    foreign_custom_office              varchar2(6 char)         null,
    price_date_category                varchar2(1 char)         null,
    purch_group_code                   varchar2(3 char)         null,
    subsequent_settlement_flag         varchar2(1 char)         null,
    business_volumes_flag              varchar2(1 char)         null,
    ers_flag                           varchar2(1 char)         null,
    planned_delivery_days              number                   null,
    planning_calendar                  varchar2(3 char)         null,
    planning_cyle                      varchar2(3 char)         null,
    delivery_cycle                     varchar2(4 char)         null,
    vendor_order_entry_flag            varchar2(1 char)         null,
    vendor_price_marking               varchar2(2 char)         null,
    rack_jobbing                       varchar2(1 char)         null,
    ssindex_compilation_flag           varchar2(1 char)         null,
    vendor_hierarchy_flag              varchar2(1 char)         null,
    discount_in_kind_flag              varchar2(1 char)         null,
    poindex_compilation_flag           varchar2(1 char)         null,
    returns_flag                       varchar2(1 char)         null,
    material_sort_criteria             varchar2(1 char)         null,
    confirm_control_key                varchar2(4 char)         null,
    rounding_profile                   varchar2(4 char)         null,
    uom_group                          varchar2(4 char)         null,
    vendor_service_level               number                   null,
    restriction_profile                varchar2(4 char)         null,
    auto_eval_receipt_flag             varchar2(1 char)         null,
    vendor_mars_account                varchar2(12 char)        null,
    idoc_profile                       varchar2(4 char)         null,
    agency_business_flag               varchar2(1 char)         null,
    revaluation_flag                   varchar2(1 char)         null,
    ship_conditions                    varchar2(2 char)         null,
    service_invoice_verify_flag        varchar2(1 char)         null,
    minimum_order_value                varchar2(16 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_vend_purch is 'Business Data Store - Vendor Purchasing';
comment on column bds_vend_purch.vendor_code is 'Account Number of the Vendor - lads_ven_poh.lifnr';
comment on column bds_vend_purch.purch_org_code is 'Purchasing Organization - lads_ven_poh.ekorg';
comment on column bds_vend_purch.create_date is 'Date on which the record was created - lads_ven_poh.erdat';
comment on column bds_vend_purch.create_user is 'Name of Person who Created the Object - lads_ven_poh.ernam';
comment on column bds_vend_purch.purchase_block_flag is 'Purchasing block at purchasing organization level - lads_ven_poh.sperm';
comment on column bds_vend_purch.deletion_flag is 'Delete flag for vendor at purchasing level - lads_ven_poh.loevm';
comment on column bds_vend_purch.abc_flag is 'ABC indicator - lads_ven_poh.lfabc';
comment on column bds_vend_purch.purch_ord_currency is 'Purchase order currency - lads_ven_poh.waers';
comment on column bds_vend_purch.vendor_salesperson is 'Responsible salesperson at vendors office - lads_ven_poh.verkf';
comment on column bds_vend_purch.vendor_phone is 'Vendors telephone number - lads_ven_poh.telf1';
comment on column bds_vend_purch.order_value_minimum is 'Minimum order value - lads_ven_poh.minbw';
comment on column bds_vend_purch.payment_terms is 'Terms of payment key - lads_ven_poh.zterm';
comment on column bds_vend_purch.inter_company_terms_01 is 'Incoterms (part 1) - lads_ven_poh.inco1';
comment on column bds_vend_purch.inter_company_terms_02 is 'Incoterms (part 2) - lads_ven_poh.inco2';
comment on column bds_vend_purch.invoice_verify_flag is 'Indicator: GR-based invoice verification - lads_ven_poh.webre';
comment on column bds_vend_purch.order_acknowledgment_flag is 'Order acknowledgment requirement - lads_ven_poh.kzabs';
comment on column bds_vend_purch.calc_schema_group is 'Group for calculation schema (vendor) - lads_ven_poh.kalsk';
comment on column bds_vend_purch.purch_order_auto_gen_flag is 'Automatic generation of purchase order allowed - lads_ven_poh.kzaut';
comment on column bds_vend_purch.foreign_transport_mode is 'Mode of Transport for Foreign Trade - lads_ven_poh.expvz';
comment on column bds_vend_purch.foreign_custom_office is 'Customs office: Office of exit for foreign trade - lads_ven_poh.zolla';
comment on column bds_vend_purch.price_date_category is 'Pricing date category (controls date of price determination) - lads_ven_poh.meprf';
comment on column bds_vend_purch.purch_group_code is 'Purchasing Group - lads_ven_poh.ekgrp';
comment on column bds_vend_purch.subsequent_settlement_flag is 'Indicator: vendor subject to subseq. settlement accounting - lads_ven_poh.bolre';
comment on column bds_vend_purch.business_volumes_flag is 'Comparison/agreement of business volumes necessary - lads_ven_poh.umsae';
comment on column bds_vend_purch.ers_flag is 'Evaluated Receipt Settlement (ERS) - lads_ven_poh.xersy';
comment on column bds_vend_purch.planned_delivery_days is 'Planned delivery time in days - lads_ven_poh.plifz';
comment on column bds_vend_purch.planning_calendar is 'Planning calendar - lads_ven_poh.mrppp';
comment on column bds_vend_purch.planning_cyle is 'Planning cycle - lads_ven_poh.lfrhy';
comment on column bds_vend_purch.delivery_cycle is 'Delivery cycle - lads_ven_poh.liefr';
comment on column bds_vend_purch.vendor_order_entry_flag is 'Order entry by vendor - lads_ven_poh.libes';
comment on column bds_vend_purch.vendor_price_marking is '''Price marking, vendor'' - lads_ven_poh.lipre';
comment on column bds_vend_purch.rack_jobbing is 'Rack-jobbing: vendor - lads_ven_poh.liser';
comment on column bds_vend_purch.ssindex_compilation_flag is 'Indicator: index compilation for subseq. settlement active - lads_ven_poh.boind';
comment on column bds_vend_purch.vendor_hierarchy_flag is '''Indicator: ''''relev. to price determination (vend. hierarchy)'' - lads_ven_poh.prfre';
comment on column bds_vend_purch.discount_in_kind_flag is 'Indicator whether discount in kind granted - lads_ven_poh.nrgew';
comment on column bds_vend_purch.poindex_compilation_flag is 'Indicator: Doc. index compilation active for purchase orders - lads_ven_poh.blind';
comment on column bds_vend_purch.returns_flag is 'Indicates whether vendor is returns vendor - lads_ven_poh.kzret';
comment on column bds_vend_purch.material_sort_criteria is 'Vendor sort criterion for materials - lads_ven_poh.skrit';
comment on column bds_vend_purch.confirm_control_key is 'Confirmation control key - lads_ven_poh.bstae';
comment on column bds_vend_purch.rounding_profile is 'Rounding profile - lads_ven_poh.rdprf';
comment on column bds_vend_purch.uom_group is 'Unit of measure group - lads_ven_poh.megru';
comment on column bds_vend_purch.vendor_service_level is 'Vendor service level - lads_ven_poh.vensl';
comment on column bds_vend_purch.restriction_profile is 'Restriction Profile for PO-Based Load Building - lads_ven_poh.bopnr';
comment on column bds_vend_purch.auto_eval_receipt_flag is 'Automatic evaluated receipt settlement for return items - lads_ven_poh.xersr';
comment on column bds_vend_purch.vendor_mars_account is 'Our account number with the vendor - lads_ven_poh.eikto';
comment on column bds_vend_purch.idoc_profile is 'Profile for transferring material data via IDoc PROACT - lads_ven_poh.paprf';
comment on column bds_vend_purch.agency_business_flag is 'Indicator: Relevant for agency business - lads_ven_poh.agrel';
comment on column bds_vend_purch.revaluation_flag is 'Revaluation allowed - lads_ven_poh.xnbwy';
comment on column bds_vend_purch.ship_conditions is 'Shipping conditions - lads_ven_poh.vsbed';
comment on column bds_vend_purch.service_invoice_verify_flag is 'Indicator for service-based invoice verification - lads_ven_poh.lebre';
comment on column bds_vend_purch.minimum_order_value is 'Minimum order value (batch input field) - lads_ven_poh.minbw2';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_purch
   add constraint bds_vend_purch_pk primary key (vendor_code, purch_org_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_purch to lics_app;
grant select, insert, update, delete on bds_vend_purch to lads_app;
grant select, insert, update, delete on bds_vend_purch to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_purch for bds.bds_vend_purch;