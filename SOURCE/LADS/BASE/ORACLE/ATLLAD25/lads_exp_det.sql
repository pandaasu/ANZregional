/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_det
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_det
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
    detseq                                       number                              not null,
    posnr                                        number                              null,
    matnr                                        varchar2(18 char)                   null,
    matwa                                        varchar2(18 char)                   null,
    arktx                                        varchar2(40 char)                   null,
    orktx                                        varchar2(40 char)                   null,
    sugrd                                        varchar2(4 char)                    null,
    sudru                                        varchar2(1 char)                    null,
    matkl                                        varchar2(9 char)                    null,
    werks                                        varchar2(4 char)                    null,
    lgort                                        varchar2(4 char)                    null,
    charg                                        varchar2(10 char)                   null,
    kdmat                                        varchar2(22 char)                   null,
    lfimg                                        number                              null,
    vrkme                                        varchar2(3 char)                    null,
    lgmng                                        number                              null,
    meins                                        varchar2(3 char)                    null,
    ntgew                                        number                              null,
    brgew                                        number                              null,
    gewei                                        varchar2(3 char)                    null,
    volum                                        number                              null,
    voleh                                        varchar2(3 char)                    null,
    lgpbe                                        varchar2(10 char)                   null,
    hipos                                        varchar2(6 char)                    null,
    hievw                                        varchar2(1 char)                    null,
    ladgr                                        varchar2(4 char)                    null,
    tragr                                        varchar2(4 char)                    null,
    vkbur                                        varchar2(4 char)                    null,
    vkgrp                                        varchar2(3 char)                    null,
    vtweg                                        varchar2(2 char)                    null,
    spart                                        varchar2(2 char)                    null,
    grkor                                        varchar2(3 char)                    null,
    ean11                                        varchar2(18 char)                   null,
    sernr                                        varchar2(8 char)                    null,
    aeskd                                        varchar2(17 char)                   null,
    empst                                        varchar2(25 char)                   null,
    mfrgr                                        varchar2(8 char)                    null,
    vbrst                                        varchar2(14 char)                   null,
    labnk                                        varchar2(17 char)                   null,
    abrdt                                        varchar2(8 char)                    null,
    mfrpn                                        varchar2(40 char)                   null,
    mfrnr                                        varchar2(10 char)                   null,
    abrvw                                        varchar2(3 char)                    null,
    kdmat35                                      varchar2(35 char)                   null,
    kannr                                        varchar2(35 char)                   null,
    posex                                        varchar2(6 char)                    null,
    lieffz                                       number                              null,
    usr01                                        varchar2(35 char)                   null,
    usr02                                        varchar2(35 char)                   null,
    usr03                                        varchar2(35 char)                   null,
    usr04                                        varchar2(10 char)                   null,
    usr05                                        varchar2(10 char)                   null,
    matnr_external                               varchar2(40 char)                   null,
    matnr_version                                varchar2(10 char)                   null,
    matnr_guid                                   varchar2(32 char)                   null,
    matwa_external                               varchar2(40 char)                   null,
    matwa_version                                varchar2(10 char)                   null,
    matwa_guid                                   varchar2(32 char)                   null,
    zudat                                        varchar2(20 char)                   null,
    vfdat                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_exp_det is 'Generic ICB Document - Delivery data';
comment on column lads_exp_det.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_det.delseq is 'DEL - generated sequence number';
comment on column lads_exp_det.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_det.detseq is 'DET - generated sequence number';
comment on column lads_exp_det.posnr is 'Item number of the SD document';
comment on column lads_exp_det.matnr is 'Material Number';
comment on column lads_exp_det.matwa is 'Material entered';
comment on column lads_exp_det.arktx is 'Short Text for Sales Order Item';
comment on column lads_exp_det.orktx is 'Description of Material Entered';
comment on column lads_exp_det.sugrd is 'Reason for material substitution';
comment on column lads_exp_det.sudru is 'Original entry will be printed';
comment on column lads_exp_det.matkl is 'Material Group';
comment on column lads_exp_det.werks is 'Plant';
comment on column lads_exp_det.lgort is 'Storage Location';
comment on column lads_exp_det.charg is 'Batch Number';
comment on column lads_exp_det.kdmat is 'Material belonging to the customer';
comment on column lads_exp_det.lfimg is 'Actual quantity delivered (in sales units)';
comment on column lads_exp_det.vrkme is 'Sales unit';
comment on column lads_exp_det.lgmng is 'Actual quantity delivered in stockkeeping units';
comment on column lads_exp_det.meins is 'Base Unit of Measure';
comment on column lads_exp_det.ntgew is 'Net weight';
comment on column lads_exp_det.brgew is 'Gross weight';
comment on column lads_exp_det.gewei is 'Weight Unit';
comment on column lads_exp_det.volum is 'Volume';
comment on column lads_exp_det.voleh is 'Volume unit';
comment on column lads_exp_det.lgpbe is 'Storage bin';
comment on column lads_exp_det.hipos is 'Superior item in an item hierarchy';
comment on column lads_exp_det.hievw is 'Use of Hierarchy Item';
comment on column lads_exp_det.ladgr is 'Loading group';
comment on column lads_exp_det.tragr is 'Transportation group';
comment on column lads_exp_det.vkbur is 'Sales office';
comment on column lads_exp_det.vkgrp is 'Sales group';
comment on column lads_exp_det.vtweg is 'Distribution Channel';
comment on column lads_exp_det.spart is 'Division';
comment on column lads_exp_det.grkor is 'Delivery group (items are delivered together)';
comment on column lads_exp_det.ean11 is 'International Article Number (EAN/UPC)';
comment on column lads_exp_det.sernr is 'BOM explosion number';
comment on column lads_exp_det.aeskd is 'Customer Engineering Change Status';
comment on column lads_exp_det.empst is 'Receiving point';
comment on column lads_exp_det.mfrgr is 'Material freight group';
comment on column lads_exp_det.vbrst is 'Customer point of consumption';
comment on column lads_exp_det.labnk is 'Customer number for forecast / JIT dlv. sched.';
comment on column lads_exp_det.abrdt is 'Delivery Schedule Date';
comment on column lads_exp_det.mfrpn is 'Manufacturer part number';
comment on column lads_exp_det.mfrnr is 'Manufacturer number';
comment on column lads_exp_det.abrvw is 'Usage indicator';
comment on column lads_exp_det.kdmat35 is 'Material belonging to the customer';
comment on column lads_exp_det.kannr is 'KANBAN/sequence number';
comment on column lads_exp_det.posex is 'External item number';
comment on column lads_exp_det.lieffz is 'Cumulative qty for delivery/MAIS in base unit of measure';
comment on column lads_exp_det.usr01 is 'Additional data field 1 for delivery schedules';
comment on column lads_exp_det.usr02 is 'Additional data field 2 for delivery schedules';
comment on column lads_exp_det.usr03 is 'Additional data field 3 for delivery schedules';
comment on column lads_exp_det.usr04 is ' Additional data field 4 for delivery schedules';
comment on column lads_exp_det.usr05 is 'Additional data field 5 for delivery schedules';
comment on column lads_exp_det.matnr_external is 'Long material number (future development) for MATNR field';
comment on column lads_exp_det.matnr_version is 'Version number (future development) for MATNR field';
comment on column lads_exp_det.matnr_guid is 'External GUID (future development) for MATNR field';
comment on column lads_exp_det.matwa_external is 'Long material number (future development) for field MATWA';
comment on column lads_exp_det.matwa_version is 'Version number (future development) for field MATWA';
comment on column lads_exp_det.matwa_guid is 'External GUID (future development) for field MATWA';
comment on column lads_exp_det.zudat is 'Additional Data';
comment on column lads_exp_det.vfdat is 'Shelf Life Expiration Date';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_det
   add constraint lads_exp_det_pk primary key (zzgrpnr, delseq, hdeseq, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_det to lads_app;
grant select, insert, update, delete on lads_exp_det to ics_app;
grant select on lads_exp_det to ics_reader with grant option;
grant select on lads_exp_det to ics_executor;
grant select on lads_exp_det to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_det for lads.lads_exp_det;
