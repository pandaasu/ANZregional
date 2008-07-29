/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dlv
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dlv

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dlv
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    vbeln                                        varchar2(10 char)                   null,
    vstel                                        varchar2(4 char)                    null,
    vkorg                                        varchar2(4 char)                    null,
    lstel                                        varchar2(2 char)                    null,
    vkbur                                        varchar2(4 char)                    null,
    lgnum                                        varchar2(3 char)                    null,
    ablad                                        varchar2(25 char)                   null,
    inco1                                        varchar2(3 char)                    null,
    inco2                                        varchar2(28 char)                   null,
    route                                        varchar2(6 char)                    null,
    vsbed                                        varchar2(2 char)                    null,
    btgew                                        number                              null,
    ntgew                                        number                              null,
    gewei                                        varchar2(3 char)                    null,
    volum                                        number                              null,
    voleh                                        varchar2(3 char)                    null,
    anzpk                                        varchar2(5 char)                    null,
    bolnr                                        varchar2(35 char)                   null,
    traty                                        varchar2(4 char)                    null,
    traid                                        varchar2(20 char)                   null,
    xabln                                        varchar2(10 char)                   null,
    lifex                                        varchar2(35 char)                   null,
    parid                                        varchar2(35 char)                   null,
    podat                                        varchar2(8 char)                    null,
    potim                                        varchar2(6 char)                    null,
    lfart                                        varchar2(4 char)                    null,
    bzirk                                        varchar2(6 char)                    null,
    autlf                                        varchar2(1 char)                    null,
    expkz                                        varchar2(1 char)                    null,
    lifsk                                        varchar2(2 char)                    null,
    lprio                                        number                              null,
    kdgrp                                        varchar2(2 char)                    null,
    berot                                        varchar2(20 char)                   null,
    tragr                                        varchar2(4 char)                    null,
    trspg                                        varchar2(2 char)                    null,
    aulwe                                        varchar2(10 char)                   null,
    vstel_bez                                    varchar2(30 char)                   null,
    vkorg_bez                                    varchar2(20 char)                   null,
    lstel_bez                                    varchar2(20 char)                   null,
    vkbur_bez                                    varchar2(20 char)                   null,
    lgnum_bez                                    varchar2(25 char)                   null,
    inco1_bez                                    varchar2(30 char)                   null,
    route_bez                                    varchar2(40 char)                   null,
    vsbed_bez                                    varchar2(20 char)                   null,
    traty_bez                                    varchar2(20 char)                   null,
    lfart_bez                                    varchar2(20 char)                   null,
    lprio_bez                                    varchar2(20 char)                   null,
    bzirk_bez                                    varchar2(20 char)                   null,
    lifsk_bez                                    varchar2(20 char)                   null,
    kdgrp_bez                                    varchar2(20 char)                   null,
    tragr_bez                                    varchar2(20 char)                   null,
    trspg_bez                                    varchar2(20 char)                   null,
    aulwe_bez                                    varchar2(40 char)                   null,
    aland                                        varchar2(3 char)                    null,
    expvz                                        varchar2(1 char)                    null,
    zolla                                        varchar2(6 char)                    null,
    zollb                                        varchar2(6 char)                    null,
    kzgbe                                        varchar2(30 char)                   null,
    kzabe                                        varchar2(30 char)                   null,
    stgbe                                        varchar2(3 char)                    null,
    stabe                                        varchar2(3 char)                    null,
    conta                                        varchar2(1 char)                    null,
    grwcu                                        varchar2(5 char)                    null,
    iever                                        varchar2(1 char)                    null,
    expvz_bez                                    varchar2(20 char)                   null,
    zolla_bez                                    varchar2(30 char)                   null,
    zollb_bez                                    varchar2(30 char)                   null,
    iever_bez                                    varchar2(20 char)                   null,
    stgbe_bez                                    varchar2(15 char)                   null,
    stabe_bez                                    varchar2(15 char)                   null,
    vsart                                        varchar2(2 char)                    null,
    vsavl                                        varchar2(2 char)                    null,
    vsanl                                        varchar2(2 char)                    null,
    rouid                                        varchar2(100 char)                  null,
    distz                                        number                              null,
    medst                                        varchar2(3 char)                    null,
    vsart_bez                                    varchar2(20 char)                   null,
    vsavl_bez                                    varchar2(20 char)                   null,
    vsanl_bez                                    varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_dlv is 'LADS Shipment Delivery';
comment on column lads_shp_dlv.tknum is 'Shipment Number';
comment on column lads_shp_dlv.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dlv.vbeln is 'Sales and Distribution Document Number';
comment on column lads_shp_dlv.vstel is 'Shipping Point/Receiving Point';
comment on column lads_shp_dlv.vkorg is 'Sales Organization';
comment on column lads_shp_dlv.lstel is 'Loading Point';
comment on column lads_shp_dlv.vkbur is 'Sales office';
comment on column lads_shp_dlv.lgnum is 'Warehouse Number / Warehouse Complex';
comment on column lads_shp_dlv.ablad is 'Unloading Point';
comment on column lads_shp_dlv.inco1 is 'Incoterms (part 1)';
comment on column lads_shp_dlv.inco2 is 'Incoterms (part 2)';
comment on column lads_shp_dlv.route is 'Route';
comment on column lads_shp_dlv.vsbed is 'Shipping conditions';
comment on column lads_shp_dlv.btgew is 'Total Weight';
comment on column lads_shp_dlv.ntgew is 'Net weight';
comment on column lads_shp_dlv.gewei is 'Weight Unit';
comment on column lads_shp_dlv.volum is 'Volume';
comment on column lads_shp_dlv.voleh is 'Volume unit';
comment on column lads_shp_dlv.anzpk is 'Total number of packages in delivery';
comment on column lads_shp_dlv.bolnr is 'Bill of lading';
comment on column lads_shp_dlv.traty is 'Means-of-Transport Type';
comment on column lads_shp_dlv.traid is 'Means of Transport ID';
comment on column lads_shp_dlv.xabln is 'Goods Receipt/Issue Slip Number';
comment on column lads_shp_dlv.lifex is 'External Identification of Delivery Note';
comment on column lads_shp_dlv.parid is 'External partner number';
comment on column lads_shp_dlv.podat is 'Date (proof of delivery)';
comment on column lads_shp_dlv.potim is 'Confirmation time';
comment on column lads_shp_dlv.lfart is 'Delivery Type';
comment on column lads_shp_dlv.bzirk is 'Sales district';
comment on column lads_shp_dlv.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_shp_dlv.expkz is 'Export indicator';
comment on column lads_shp_dlv.lifsk is 'Delivery block (document header)';
comment on column lads_shp_dlv.lprio is 'Delivery Priority';
comment on column lads_shp_dlv.kdgrp is 'Customer group';
comment on column lads_shp_dlv.berot is 'Picked items location';
comment on column lads_shp_dlv.tragr is 'Transportation group';
comment on column lads_shp_dlv.trspg is 'Shipment Blocking Reason';
comment on column lads_shp_dlv.aulwe is 'Route schedule';
comment on column lads_shp_dlv.vstel_bez is 'Description of shipping point';
comment on column lads_shp_dlv.vkorg_bez is 'Description of sales organization';
comment on column lads_shp_dlv.lstel_bez is 'Loading point description';
comment on column lads_shp_dlv.vkbur_bez is 'Description of sales office';
comment on column lads_shp_dlv.lgnum_bez is 'Warehouse number description';
comment on column lads_shp_dlv.inco1_bez is 'Incoterm description';
comment on column lads_shp_dlv.route_bez is 'Route description';
comment on column lads_shp_dlv.vsbed_bez is 'Description of the shipping conditions';
comment on column lads_shp_dlv.traty_bez is 'Description of shipping material type';
comment on column lads_shp_dlv.lfart_bez is 'Delivery type description';
comment on column lads_shp_dlv.lprio_bez is 'Description of delivery priorities';
comment on column lads_shp_dlv.bzirk_bez is 'Name of the district';
comment on column lads_shp_dlv.lifsk_bez is 'Description of reason for delivery block';
comment on column lads_shp_dlv.kdgrp_bez is 'Description of customer group';
comment on column lads_shp_dlv.tragr_bez is 'Description of transportation group';
comment on column lads_shp_dlv.trspg_bez is 'Description of reason for shipment block';
comment on column lads_shp_dlv.aulwe_bez is 'Description of route schedule';
comment on column lads_shp_dlv.aland is 'Destination country';
comment on column lads_shp_dlv.expvz is 'Mode of Transport for Foreign Trade';
comment on column lads_shp_dlv.zolla is 'Customs office: Office of exit for foreign trade';
comment on column lads_shp_dlv.zollb is 'Customs office: Office of destination for foreign trade';
comment on column lads_shp_dlv.kzgbe is 'Indicator for means of transport crossing the border';
comment on column lads_shp_dlv.kzabe is 'Indicator for the means of transport at departure';
comment on column lads_shp_dlv.stgbe is 'Origin of Means of Transport when Crossing the Border';
comment on column lads_shp_dlv.stabe is 'Country of Origin of the Means of Transport at Departure';
comment on column lads_shp_dlv.conta is 'ID: Goods cross border in a container';
comment on column lads_shp_dlv.grwcu is 'Currency of statistical values for foreign trade';
comment on column lads_shp_dlv.iever is 'Domestic Mode of Transport for Foreign Trade';
comment on column lads_shp_dlv.expvz_bez is 'Description of mode of transport';
comment on column lads_shp_dlv.zolla_bez is 'Customs office description';
comment on column lads_shp_dlv.zollb_bez is 'Description of office of destination';
comment on column lads_shp_dlv.iever_bez is 'Description of inland mode of transport';
comment on column lads_shp_dlv.stgbe_bez is 'Description of country of affiliation of means of transport';
comment on column lads_shp_dlv.stabe_bez is 'Cntry of affil. of means of transport at departure of goods';
comment on column lads_shp_dlv.vsart is 'Shipping type';
comment on column lads_shp_dlv.vsavl is 'Shipping type of preliminary leg';
comment on column lads_shp_dlv.vsanl is 'Shipping type of subsequent leg';
comment on column lads_shp_dlv.rouid is 'Route identification';
comment on column lads_shp_dlv.distz is 'Distance';
comment on column lads_shp_dlv.medst is 'Unit of measure for distance';
comment on column lads_shp_dlv.vsart_bez is 'Description of the Shipping Type';
comment on column lads_shp_dlv.vsavl_bez is 'Description of shipping type of preliminary leg';
comment on column lads_shp_dlv.vsanl_bez is 'Description of shipping type of subsequent leg';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dlv
   add constraint lads_shp_dlv_pk primary key (tknum, dlvseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dlv to lads_app;
grant select, insert, update, delete on lads_shp_dlv to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dlv for lads.lads_shp_dlv;
