/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_hdr
   (vbeln                                        varchar2(10 char)                   not null,
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
    zztarif                                      varchar2(3 char)                    null,
    werks                                        varchar2(4 char)                    null,
    name1                                        varchar2(30 char)                   null,
    stras                                        varchar2(30 char)                   null,
    pstlz                                        varchar2(10 char)                   null,
    ort01                                        varchar2(25 char)                   null,
    land1                                        varchar2(3 char)                    null,
    zztarif1                                     varchar2(3 char)                    null,
    zzbrgew                                      number                              null,
    zzweightuom                                  varchar2(3 char)                    null,
    zzpalspace                                   number                              null,
    zzpalbas01                                   number                              null,
    zzmeins01                                    varchar2(3 char)                    null,
    zzpalbas02                                   number                              null,
    zzmeins02                                    varchar2(3 char)                    null,
    zzpalbas03                                   number                              null,
    zzmeins03                                    varchar2(3 char)                    null,
    zzpalbas04                                   number                              null,
    zzmeins04                                    varchar2(3 char)                    null,
    zzpalbas05                                   number                              null,
    zzmeins05                                    varchar2(3 char)                    null,
    zzpalspace_f                                 number                              null,
    zzpalbas01_f                                 number                              null,
    zzpalbas02_f                                 number                              null,
    zzpalbas03_f                                 number                              null,
    zzpalbas04_f                                 number                              null,
    zzpalbas05_f                                 number                              null,
    zztknum                                      varchar2(10 char)                   null,
    zzexpectpb                                   varchar2(3 char)                    null,
    zzgaranteedbpr                               varchar2(3 char)                    null,
    zzgroupbpr                                   varchar2(3 char)                    null,
    zzorbdpr                                     varchar2(3 char)                    null,
    zzmanbpr                                     varchar2(3 char)                    null,
    zzdelbpr                                     varchar2(3 char)                    null,
    zzpalspace_deliv                             number                              null,
    zzpalbase_del01                              number                              null,
    zzpalbase_del02                              number                              null,
    zzpalbase_del03                              number                              null,
    zzpalbase_del04                              number                              null,
    zzpalbase_del05                              number                              null,
    zzmeins_del01                                varchar2(3 char)                    null,
    zzmeins_del02                                varchar2(3 char)                    null,
    zzmeins_del03                                varchar2(3 char)                    null,
    zzmeins_del04                                varchar2(3 char)                    null,
    zzmeins_del05                                varchar2(3 char)                    null,
    atwrt1                                       varchar2(30 char)                   null,
    atwrt2                                       varchar2(30 char)                   null,
    mtimefrom                                    varchar2(16 char)                   null,
    mtimeto                                      varchar2(16 char)                   null,
    atimefrom                                    varchar2(16 char)                   null,
    atimeto                                      varchar2(16 char)                   null,
    werks2                                       varchar2(4 char)                    null,
    zzbrgew_f                                    number                              null,
    zzweightpal                                  number                              null,
    zzweightpal_f                                number                              null,
    mescod                                       varchar2(3 char)                    null,
    mesfct                                       varchar2(3 char)                    null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_del_hdr is 'LADS Delivery Header';
comment on column lads_del_hdr.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_hdr.vstel is 'Shipping Point/Receiving Point';
comment on column lads_del_hdr.vkorg is 'Sales Organization';
comment on column lads_del_hdr.lstel is 'Loading Point';
comment on column lads_del_hdr.vkbur is 'Sales office';
comment on column lads_del_hdr.lgnum is 'Warehouse Number / Warehouse Complex';
comment on column lads_del_hdr.ablad is 'Unloading Point';
comment on column lads_del_hdr.inco1 is 'Incoterms (part 1)';
comment on column lads_del_hdr.inco2 is 'Incoterms (part 2)';
comment on column lads_del_hdr.route is 'Route';
comment on column lads_del_hdr.vsbed is 'Shipping conditions';
comment on column lads_del_hdr.btgew is 'Total Weight';
comment on column lads_del_hdr.ntgew is 'Net weight';
comment on column lads_del_hdr.gewei is 'Weight Unit';
comment on column lads_del_hdr.volum is 'Volume';
comment on column lads_del_hdr.voleh is 'Volume unit';
comment on column lads_del_hdr.anzpk is 'Total number of packages in delivery';
comment on column lads_del_hdr.bolnr is 'Bill of lading';
comment on column lads_del_hdr.traty is 'Means-of-Transport Type';
comment on column lads_del_hdr.traid is 'Means of Transport ID';
comment on column lads_del_hdr.xabln is 'Goods Receipt/Issue Slip Number';
comment on column lads_del_hdr.lifex is 'External Identification of Delivery Note';
comment on column lads_del_hdr.parid is 'External partner number';
comment on column lads_del_hdr.podat is 'Date (proof of delivery)';
comment on column lads_del_hdr.potim is 'Confirmation time';
comment on column lads_del_hdr.vstel_bez is 'Description of shipping point';
comment on column lads_del_hdr.vkorg_bez is 'Description of sales organization';
comment on column lads_del_hdr.lstel_bez is 'Loading point description';
comment on column lads_del_hdr.vkbur_bez is 'Description of sales office';
comment on column lads_del_hdr.lgnum_bez is 'Warehouse number description';
comment on column lads_del_hdr.inco1_bez is 'Incoterm description';
comment on column lads_del_hdr.route_bez is 'Route description';
comment on column lads_del_hdr.vsbed_bez is 'Description of the shipping conditions';
comment on column lads_del_hdr.traty_bez is 'Description of shipping material type';
comment on column lads_del_hdr.lfart is 'Delivery Type';
comment on column lads_del_hdr.bzirk is 'Sales district';
comment on column lads_del_hdr.autlf is 'Complete delivery defined for each sales order?';
comment on column lads_del_hdr.lifsk is 'Delivery block (document header)';
comment on column lads_del_hdr.lprio is 'Delivery Priority';
comment on column lads_del_hdr.kdgrp is 'Customer group';
comment on column lads_del_hdr.berot is 'Picked items location';
comment on column lads_del_hdr.tragr is 'Transportation group';
comment on column lads_del_hdr.trspg is 'Shipment Blocking Reason';
comment on column lads_del_hdr.aulwe is 'Route schedule';
comment on column lads_del_hdr.lfart_bez is 'Delivery type description';
comment on column lads_del_hdr.lprio_bez is 'Description of delivery priorities';
comment on column lads_del_hdr.bzirk_bez is 'Name of the district';
comment on column lads_del_hdr.lifsk_bez is 'Description of reason for delivery block';
comment on column lads_del_hdr.kdgrp_bez is 'Description of customer group';
comment on column lads_del_hdr.tragr_bez is 'Description of transportation group';
comment on column lads_del_hdr.trspg_bez is 'Description of reason for shipment block';
comment on column lads_del_hdr.aulwe_bez is 'Description of route schedule';
comment on column lads_del_hdr.zztarif is 'Document Band Price';
comment on column lads_del_hdr.werks is 'Plant';
comment on column lads_del_hdr.name1 is 'Name';
comment on column lads_del_hdr.stras is 'House number and street';
comment on column lads_del_hdr.pstlz is 'Postal Code';
comment on column lads_del_hdr.ort01 is 'City';
comment on column lads_del_hdr.land1 is 'Country Key';
comment on column lads_del_hdr.zztarif1 is 'Document Band Price';
comment on column lads_del_hdr.zzbrgew is 'Gross weight';
comment on column lads_del_hdr.zzweightuom is 'Base Unit of Measure';
comment on column lads_del_hdr.zzpalspace is 'Number of pallet spaces';
comment on column lads_del_hdr.zzpalbas01 is 'Number of pallet Base';
comment on column lads_del_hdr.zzmeins01 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzpalbas02 is 'Number of pallet Base';
comment on column lads_del_hdr.zzmeins02 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzpalbas03 is 'Number of pallet Base';
comment on column lads_del_hdr.zzmeins03 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzpalbas04 is 'Number of pallet Base';
comment on column lads_del_hdr.zzmeins04 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzpalbas05 is 'Number of pallet Base';
comment on column lads_del_hdr.zzmeins05 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzpalspace_f is 'Number of pallet spaces';
comment on column lads_del_hdr.zzpalbas01_f is 'Number of pallet Base';
comment on column lads_del_hdr.zzpalbas02_f is 'Number of pallet Base';
comment on column lads_del_hdr.zzpalbas03_f is 'Number of pallet Base';
comment on column lads_del_hdr.zzpalbas04_f is 'Number of pallet Base';
comment on column lads_del_hdr.zzpalbas05_f is 'Number of pallet Base';
comment on column lads_del_hdr.zztknum is 'Shipment Number';
comment on column lads_del_hdr.zzexpectpb is 'Customer expected  Band Price';
comment on column lads_del_hdr.zzgaranteedbpr is 'CRPC Guaranteed  Price Band';
comment on column lads_del_hdr.zzgroupbpr is 'CRPC Group recalculated Band Price';
comment on column lads_del_hdr.zzorbdpr is 'Calculated Order Band Price';
comment on column lads_del_hdr.zzmanbpr is 'Manual overrided Band Price';
comment on column lads_del_hdr.zzdelbpr is 'CRPC  price band reallocated at delivery creation time';
comment on column lads_del_hdr.zzpalspace_deliv is 'Number of pallet spaces on delivery';
comment on column lads_del_hdr.zzpalbase_del01 is 'number of pallet bases on delivery';
comment on column lads_del_hdr.zzpalbase_del02 is 'number of pallet bases on delivery';
comment on column lads_del_hdr.zzpalbase_del03 is 'number of pallet bases on delivery';
comment on column lads_del_hdr.zzpalbase_del04 is 'number of pallet bases on delivery';
comment on column lads_del_hdr.zzpalbase_del05 is 'number of pallet bases on delivery';
comment on column lads_del_hdr.zzmeins_del01 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzmeins_del02 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzmeins_del03 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzmeins_del04 is 'Base Unit of Measure';
comment on column lads_del_hdr.zzmeins_del05 is 'Base Unit of Measure';
comment on column lads_del_hdr.atwrt1 is 'Characteristic Value';
comment on column lads_del_hdr.atwrt2 is 'Characteristic Value';
comment on column lads_del_hdr.mtimefrom is 'Character String - 8 User-Defined Characters';
comment on column lads_del_hdr.mtimeto is 'Character String - 8 User-Defined Characters';
comment on column lads_del_hdr.atimefrom is 'Character String - 8 User-Defined Characters';
comment on column lads_del_hdr.atimeto is 'Character String - 8 User-Defined Characters';
comment on column lads_del_hdr.werks2 is 'Plant';
comment on column lads_del_hdr.zzbrgew_f is 'Gross weight';
comment on column lads_del_hdr.zzweightpal is '"Total Weight, including pallet bases"';
comment on column lads_del_hdr.zzweightpal_f is '"Total Weight, including pallet bases"';
comment on column lads_del_hdr.mescod is 'IDOC message code';
comment on column lads_del_hdr.mesfct is 'IDOC message function';
comment on column lads_del_hdr.idoc_name is 'IDOC name';
comment on column lads_del_hdr.idoc_number is 'IDOC number';
comment on column lads_del_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_del_hdr.lads_date is 'LADS date loaded';
comment on column lads_del_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan, 4=deleted)';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_hdr
   add constraint lads_del_hdr_pk primary key (vbeln);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_hdr to lads_app;
grant select, insert, update, delete on lads_del_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_hdr for lads.lads_del_hdr;
