/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_vend_purch_plant
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Vendor Purchasing Plant

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_vend_purch_plant
   (vendor_code                        varchar2(10 char)        not null,
    purch_org_code                     varchar2(6 char)         not null,
    purch_org_sub_code                 varchar2(6 char)         not null,
    plant_code                         varchar2(6 char)         not null,
    create_date                        date                     null,
    create_user                        varchar2(12 char)        null,
    purchase_block_flag                varchar2(1 char)         null,
    deletion_flag                      varchar2(1 char)         null,
    abc_flag                           varchar2(1 char)         null,
    purch_ord_currency                 varchar2(13 char)        null,
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
    mrp_controller                     varchar2(3 char)         null,
    confirm_control_key                varchar2(4 char)         null,
    rounding_profile                   varchar2(4 char)         null,
    uom_group                          varchar2(4 char)         null,
    restriction_profile                varchar2(4 char)         null,
    auto_eval_receipt_flag             varchar2(1 char)         null,
    release_creation_profile           varchar2(4 char)         null,
    idoc_profile                       varchar2(4 char)         null,
    revaluation_flag                   varchar2(1 char)         null,
    service_invoice_verify_flag        varchar2(1 char)         null,
    minimum_order_value                varchar2(16 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_vend_purch_plant is 'Business Data Store - Vendor Purchasing Plant';
comment on column bds_vend_purch_plant.vendor_code is 'Account Number of Vendor or Creditor - lads_ven_pom.lifnr';
comment on column bds_vend_purch_plant.purch_org_code is 'Purchasing Organization - lads_ven_poh.ekorg';
comment on column bds_vend_purch_plant.purch_org_sub_code is 'Vendor Sub-Range - lads_ven_pom.ltsnr';
comment on column bds_vend_purch_plant.plant_code is 'Plant - lads_ven_pom.werks';
comment on column bds_vend_purch_plant.create_date is 'Date on which the record was created - lads_ven_pom.erdat';
comment on column bds_vend_purch_plant.create_user is 'Name of Person who Created the Object - lads_ven_pom.ernam';
comment on column bds_vend_purch_plant.purchase_block_flag is 'Purchasing block at purchasing organization level - lads_ven_pom.sperm';
comment on column bds_vend_purch_plant.deletion_flag is 'Deletion indicator - lads_ven_pom.loevm';
comment on column bds_vend_purch_plant.abc_flag is 'ABC indicator - lads_ven_pom.lfabc';
comment on column bds_vend_purch_plant.purch_ord_currency is 'Purchase order currency - lads_ven_pom.waers';
comment on column bds_vend_purch_plant.vendor_salesperson is 'Responsible salesperson at vendors office - lads_ven_pom.verkf';
comment on column bds_vend_purch_plant.vendor_phone is 'Vendors telephone number - lads_ven_pom.telf1';
comment on column bds_vend_purch_plant.order_value_minimum is 'Minimum order value - lads_ven_pom.minbw';
comment on column bds_vend_purch_plant.payment_terms is 'Terms of payment key - lads_ven_pom.zterm';
comment on column bds_vend_purch_plant.inter_company_terms_01 is 'Incoterms (part 1) - lads_ven_pom.inco1';
comment on column bds_vend_purch_plant.inter_company_terms_02 is 'Incoterms (part 2) - lads_ven_pom.inco2';
comment on column bds_vend_purch_plant.invoice_verify_flag is 'Indicator: GR-based invoice verification - lads_ven_pom.webre';
comment on column bds_vend_purch_plant.order_acknowledgment_flag is 'Order acknowledgment requirement - lads_ven_pom.kzabs';
comment on column bds_vend_purch_plant.calc_schema_group is 'Group for calculation schema (vendor) - lads_ven_pom.kalsk';
comment on column bds_vend_purch_plant.purch_order_auto_gen_flag is 'Automatic generation of purchase order allowed - lads_ven_pom.kzaut';
comment on column bds_vend_purch_plant.foreign_transport_mode is 'Mode of Transport for Foreign Trade - lads_ven_pom.expvz';
comment on column bds_vend_purch_plant.foreign_custom_office is 'Customs office: Office of exit for foreign trade - lads_ven_pom.zolla';
comment on column bds_vend_purch_plant.price_date_category is 'Pricing date category (controls date of price determination) - lads_ven_pom.meprf';
comment on column bds_vend_purch_plant.purch_group_code is 'Purchasing Group - lads_ven_pom.ekgrp';
comment on column bds_vend_purch_plant.subsequent_settlement_flag is 'Indicator: vendor subject to subseq. settlement accounting - lads_ven_pom.bolre';
comment on column bds_vend_purch_plant.business_volumes_flag is 'Comparison/agreement of business volumes necessary - lads_ven_pom.umsae';
comment on column bds_vend_purch_plant.ers_flag is 'Evaluated Receipt Settlement (ERS) - lads_ven_pom.xersy';
comment on column bds_vend_purch_plant.planned_delivery_days is 'Planned delivery time in days - lads_ven_pom.plifz';
comment on column bds_vend_purch_plant.planning_calendar is 'Planning calendar - lads_ven_pom.mrppp';
comment on column bds_vend_purch_plant.planning_cyle is 'Planning cycle - lads_ven_pom.lfrhy';
comment on column bds_vend_purch_plant.delivery_cycle is 'Delivery cycle - lads_ven_pom.liefr';
comment on column bds_vend_purch_plant.vendor_order_entry_flag is 'Order entry by vendor - lads_ven_pom.libes';
comment on column bds_vend_purch_plant.vendor_price_marking is '''Price marking, vendor'' - lads_ven_pom.lipre';
comment on column bds_vend_purch_plant.rack_jobbing is 'Rack-jobbing: vendor - lads_ven_pom.liser';
comment on column bds_vend_purch_plant.mrp_controller is 'MRP Controller - lads_ven_pom.dispo';
comment on column bds_vend_purch_plant.confirm_control_key is 'Confirmation control key - lads_ven_pom.bstae';
comment on column bds_vend_purch_plant.rounding_profile is 'Rounding profile - lads_ven_pom.rdprf';
comment on column bds_vend_purch_plant.uom_group is 'Unit of measure group - lads_ven_pom.megru';
comment on column bds_vend_purch_plant.restriction_profile is 'Restriction Profile for PO-Based Load Building - lads_ven_pom.bopnr';
comment on column bds_vend_purch_plant.auto_eval_receipt_flag is 'Automatic evaluated receipt settlement for return items - lads_ven_pom.xersr';
comment on column bds_vend_purch_plant.release_creation_profile is 'Release creation profile - lads_ven_pom.abueb';
comment on column bds_vend_purch_plant.idoc_profile is 'Profile for transferring material data via IDoc PROACT - lads_ven_pom.paprf';
comment on column bds_vend_purch_plant.revaluation_flag is 'Revaluation allowed - lads_ven_pom.xnbwy';
comment on column bds_vend_purch_plant.service_invoice_verify_flag is 'Indicator for service-based invoice verification - lads_ven_pom.lebre';
comment on column bds_vend_purch_plant.minimum_order_value is 'Minimum order value (batch input field) - lads_ven_pom.minbw2';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_vend_purch_plant
   add constraint bds_vend_purch_plant_pk primary key (vendor_code, purch_org_code, purch_org_sub_code, plant_code);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_vend_purch_plant to lics_app;
grant select, insert, update, delete on bds_vend_purch_plant to lads_app;
grant select, insert, update, delete on bds_vend_purch_plant to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_vend_purch_plant for bds.bds_vend_purch_plant;