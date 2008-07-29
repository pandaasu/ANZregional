/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hde
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hde

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hde
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
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
    anzpk                                        number                              null,
    bolnr                                        varchar2(35 char)                   null,
    traty                                        varchar2(4 char)                    null,
    traid                                        varchar2(20 char)                   null,
    xabln                                        varchar2(10 char)                   null,
    lifex                                        varchar2(35 char)                   null,
    parid                                        varchar2(35 char)                   null,
    podat                                        varchar2(8 char)                    null,
    potim                                        varchar2(6 char)                    null,
    vstel_bez                                    varchar2(30 char)                   null,
    vkorg_bez                                    varchar2(20 char)                   null,
    lstel_bez                                    varchar2(20 char)                   null,
    vkbur_bez                                    varchar2(20 char)                   null,
    lgnum_bez                                    varchar2(25 char)                   null,
    inco1_bez                                    varchar2(30 char)                   null,
    route_bez                                    varchar2(40 char)                   null,
    vsbed_bez                                    varchar2(20 char)                   null,
    traty_bez                                    varchar2(20 char)                   null,
    lfart                                        varchar2(4 char)                    null,
    bzirk                                        varchar2(6 char)                    null,
    autlf                                        varchar2(1 char)                    null,
    lifsk                                        varchar2(2 char)                    null,
    lprio                                        number                              null,
    kdgrp                                        varchar2(2 char)                    null,
    berot                                        varchar2(20 char)                   null,
    tragr                                        varchar2(4 char)                    null,
    trspg                                        varchar2(2 char)                    null,
    aulwe                                        varchar2(10 char)                   null,
    lfart_bez                                    varchar2(20 char)                   null,
    lprio_bez                                    varchar2(20 char)                   null,
    bzirk_bez                                    varchar2(20 char)                   null,
    lifsk_bez                                    varchar2(20 char)                   null,
    kdgrp_bez                                    varchar2(20 char)                   null,
    tragr_bez                                    varchar2(20 char)                   null,
    trspg_bez                                    varchar2(20 char)                   null,
    aulwe_bez                                    varchar2(40 char)                   null,
    zzcontseal                                   varchar2(40 char)                   null,
    zztarif                                      varchar2(3 char)                    null,
    zztotpikqty                                  number                              null,
    belnr                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_hde is 'Generic ICB Document - Delivery data';
comment on column lads_exp_hde.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hde.delseq is 'DEL - generated sequence number';
comment on column lads_exp_hde.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_hde.vbeln is 'Sales and Distribution Document Number';
comment on column lads_exp_hde.vstel is 'Shipping Point/Receiving Point';
comment on column lads_exp_hde.vkorg is 'Sales Organization';
comment on column lads_exp_hde.lstel is 'Loading Point';
comment on column lads_exp_hde.vkbur is 'Sales office';
comment on column lads_exp_hde.lgnum is 'Warehouse Number / Warehouse Complex';
comment on column lads_exp_hde.ablad is 'Unloading Point';
comment on column lads_exp_hde.inco1 is 'Incoterms (part 1)';
comment on column lads_exp_hde.inco2 is 'Incoterms (part 2)';
comment on column lads_exp_hde.route is 'Route';
comment on column lads_exp_hde.vsbed is 'Shipping conditions';
comment on column lads_exp_hde.btgew is 'Total Weight';
comment on column lads_exp_hde.ntgew is 'Net weight';
comment on column lads_exp_hde.gewei is 'Weight Unit';
comment on column lads_exp_hde.volum is 'Volume';
comment on column lads_exp_hde.voleh is 'Volume unit';
comment on column lads_exp_hde.anzpk is 'Total number of packages in delivery';
comment on column lads_exp_hde.bolnr is 'Bill of lading';
comment on column lads_exp_hde.traty is 'Means-of-Transport Type';
comment on column lads_exp_hde.traid is 'Means of Transport ID';
comment on column lads_exp_hde.xabln is 'Goods Receipt/Issue Slip Number';
comment on column lads_exp_hde.lifex is 'External Identification of Delivery Note';
comment on column lads_exp_hde.parid is 'External partner number';
comment on column lads_exp_hde.podat is 'Date (proof of delivery)';
comment on column lads_exp_hde.potim is 'Confirmation time';
comment on column lads_exp_hde.vstel_bez is 'Description of shipping point';
comment on column lads_exp_hde.vkorg_bez is 'Description of sales organization';
comment on column lads_exp_hde.lstel_bez is 'Loading point description';
comment on column lads_exp_hde.vkbur_bez is 'Description of sales office';
comment on column lads_exp_hde.lgnum_bez is 'Warehouse number description';
comment on column lads_exp_hde.inco1_bez is 'Incoterm description';
comment on column lads_exp_hde.route_bez is 'Route description';
comment on column lads_exp_hde.vsbed_bez is 'Description of the shipping conditions';
comment on column lads_exp_hde.traty_bez is 'Description of shipping material type';
comment on column lads_exp_hde.lfart is 'Delivery Type';
comment on column lads_exp_hde.bzirk is 'Sales district';
comment on column lads_exp_hde.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_exp_hde.lifsk is 'Delivery block (document header)';
comment on column lads_exp_hde.lprio is 'Delivery Priority';
comment on column lads_exp_hde.kdgrp is 'Customer group';
comment on column lads_exp_hde.berot is 'Picked items location';
comment on column lads_exp_hde.tragr is 'Transportation group';
comment on column lads_exp_hde.trspg is 'Shipment Blocking Reason';
comment on column lads_exp_hde.aulwe is 'Route schedule';
comment on column lads_exp_hde.lfart_bez is 'Delivery type description';
comment on column lads_exp_hde.lprio_bez is 'Description of delivery priorities';
comment on column lads_exp_hde.bzirk_bez is 'Name of the district';
comment on column lads_exp_hde.lifsk_bez is 'Description of reason for delivery block';
comment on column lads_exp_hde.kdgrp_bez is 'Description of customer group';
comment on column lads_exp_hde.tragr_bez is 'Description of transportation group';
comment on column lads_exp_hde.trspg_bez is 'Description of reason for shipment block';
comment on column lads_exp_hde.aulwe_bez is 'Description of route schedule';
comment on column lads_exp_hde.zzcontseal is 'Container Seal Number';
comment on column lads_exp_hde.zztarif is 'Document Band Price';
comment on column lads_exp_hde.zztotpikqty is 'Referenced quantity in base unit of measure';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hde
   add constraint lads_exp_hde_pk primary key (zzgrpnr, delseq, hdeseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hde to lads_app;
grant select, insert, update, delete on lads_exp_hde to ics_app;
grant select on lads_exp_hde to ics_reader with grant option;
grant select on lads_exp_hde to ics_executor;
grant select on lads_exp_hde to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hde for lads.lads_exp_hde;
