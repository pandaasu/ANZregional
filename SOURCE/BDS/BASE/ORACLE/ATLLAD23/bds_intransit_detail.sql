/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : bds
 Table   : bds_intransit_detail
 Owner   : bds
 Author  : Steve Gregan

 Description
 -----------
 Business Data Store - Intransit Stock Detail

 YYYY/MM   Author         Description
 -------   ------         -----------
 2007/03   Steve Gregan   Created

*******************************************************************************/

/*-*/
/* Table creation
/*-*/
create table bds_intransit_detail
   (plant_code                         varchar2(4 char)         not null,
    detseq                             number                   not null,
    company_code                       varchar2(4 char)         null,
    business_segment_code              number                   null,
    cnn_number                         varchar2(35 char)        null,
    purch_order_number                 varchar2(10 char)        null,
    vendor_code                        varchar2(10 char)        null,
    shipment_number                    varchar2(10 char)        null,
    inbound_delivery_number            varchar2(10 char)        null,
    source_plant_code                  varchar2(4 char)         null,
    source_storage_location_code       varchar2(4 char)         null,
    shipping_plant_code                varchar2(4 char)         null,
    target_storage_location_code       varchar2(4 char)         null,
    target_mrp_plant_code              varchar2(4 char)         null,
    shipping_date                      varchar2(8 char)         null,
    arrival_date                       varchar2(8 char)         null,
    maturation_date                    varchar2(8 char)         null,
    batch_number                       varchar2(10 char)        null,
    best_before_date                   varchar2(8 char)         null,
    transportation_model_code          varchar2(2 char)         null,
    forward_agent_code                 varchar2(10 char)        null,
    forward_agent_trailer_number       varchar2(10 char)        null,
    material_code                      varchar2(18 char)        null,
    quantity                           number                   null,
    uom_code                           varchar2(3 char)         null,
    stock_type_code                    varchar2(1 char)         null,
    order_type_code                    varchar2(4 char)         null,
    container_number                   varchar2(20 char)        null,
    seal_number                        varchar2(40 char)        null,
    vessel_name                        varchar2(20 char)        null,
    voyage                             varchar2(20 char)        null,
    record_sequence                    varchar2(15 char)        null,
    record_count                       varchar2(15 char)        null,
    record_timestamp                   varchar2(18 char)        null);

/*-*/
/* Comments
/*-*/
comment on table bds_intransit_detail is 'Business Data Store - Intransit Stock Detail';
comment on column bds_intransit_detail.plant_code is 'Plant - lads_int_stk_det.werks';
comment on column bds_intransit_detail.detseq is 'DET - generated sequence number - lads_int_stk_det.detseq';
comment on column bds_intransit_detail.company_code is 'Company Code - lads_int_stk_det.burks';
comment on column bds_intransit_detail.business_segment_code is 'Business Segment - lads_int_stk_det.clf01';
comment on column bds_intransit_detail.cnn_number is 'CNN Number - lads_int_stk_det.lifex';
comment on column bds_intransit_detail.purch_order_number is 'Purchase Order Number - lads_int_stk_det.vgbel';
comment on column bds_intransit_detail.vendor_code is 'Vendor Number - lads_int_stk_det.vend';
comment on column bds_intransit_detail.shipment_number is 'Shipment Number - lads_int_stk_det.tknum';
comment on column bds_intransit_detail.inbound_delivery_number is 'Inbound Delivery Number - lads_int_stk_det.vbeln';
comment on column bds_intransit_detail.source_plant_code is 'Source Plant - lads_int_stk_det.werks1';
comment on column bds_intransit_detail.source_storage_location_code is 'Source Storage Location - lads_int_stk_det.logort1';
comment on column bds_intransit_detail.shipping_plant_code is 'Shipping Point - lads_int_stk_det.werks2';
comment on column bds_intransit_detail.target_storage_location_code is 'Destination Storage Location - lads_int_stk_det.lgort';
comment on column bds_intransit_detail.target_mrp_plant_code is 'Target MRP Area - lads_int_stk_det.werks3';
comment on column bds_intransit_detail.shipping_date is 'Shipping (GI) Date - lads_int_stk_det.aedat';
comment on column bds_intransit_detail.arrival_date is 'Arrival Date - lads_int_stk_det.zardte';
comment on column bds_intransit_detail.maturation_date is 'Maturation Date - lads_int_stk_det.verab';
comment on column bds_intransit_detail.batch_number is 'Batch Number - lads_int_stk_det.charg';
comment on column bds_intransit_detail.best_before_date is 'Best Before Date - lads_int_stk_det.atwrt';
comment on column bds_intransit_detail.transportation_model_code is 'Transportation Model - lads_int_stk_det.vsbed';
comment on column bds_intransit_detail.forward_agent_code is 'Number of forwarding agent (Carrier) - lads_int_stk_det.tdlnr';
comment on column bds_intransit_detail.forward_agent_trailer_number is 'Forwarding agent (Trailer) Number - lads_int_stk_det.trail';
comment on column bds_intransit_detail.material_code is 'Material Number - lads_int_stk_det.matnr';
comment on column bds_intransit_detail.quantity is 'Actual quantity delivered (in sales units) - lads_int_stk_det.lfimg';
comment on column bds_intransit_detail.uom_code is 'UoM - lads_int_stk_det.meins';
comment on column bds_intransit_detail.stock_type_code is 'Stock Type - lads_int_stk_det.insmk';
comment on column bds_intransit_detail.order_type_code is 'Order Type (Purchasing) - lads_int_stk_det.bsart';
comment on column bds_intransit_detail.container_number is 'Container Number - lads_int_stk_det.exidv2';
comment on column bds_intransit_detail.seal_number is 'Seal Number - lads_int_stk_det.inhalt';
comment on column bds_intransit_detail.vessel_name is 'Vessel Name - lads_int_stk_det.exti1';
comment on column bds_intransit_detail.voyage is 'Voyage - lads_int_stk_det.signi';
comment on column bds_intransit_detail.record_sequence is 'Record Sequence number - lads_int_stk_det.record_nb';
comment on column bds_intransit_detail.record_count is 'Total Record number - lads_int_stk_det.record_cnt';
comment on column bds_intransit_detail.record_timestamp is 'Time Stamp - lads_int_stk_det.time';

/*-*/
/* Primary Key Constraint
/*-*/
alter table bds_intransit_detail
   add constraint bds_intransit_detail_pk primary key (plant_code, detseq);

/*-*/
/* Authority
/*-*/
grant select, insert, update, delete on bds_intransit_detail to lics_app;
grant select, insert, update, delete on bds_intransit_detail to lads_app;
grant select, insert, update, delete on bds_intransit_detail to bds_app;

/*-*/
/* Synonym
/*-*/
create public synonym bds_intransit_detail for bds.bds_intransit_detail;