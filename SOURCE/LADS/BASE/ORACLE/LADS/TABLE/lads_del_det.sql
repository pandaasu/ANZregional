/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_det
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_det

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_det
   (vbeln                                        varchar2(10 char)                   not null,
    detseq                                       number                              not null,
    posnr                                        varchar2(6 char)                    null,
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
    vfdat                                        varchar2(8 char)                    null,
    zzmeins01                                    varchar2(3 char)                    null,
    zzpalbas01_f                                 number                              null,
    vbelv                                        varchar2(10 char)                   null,
    posnv                                        varchar2(6 char)                    null,
    zzhalfpal                                    varchar2(1 char)                    null,
    zzstackable                                  varchar2(1 char)                    null,
    zznbrhompal                                  number                              null,
    zzpalbase_deliv                              number                              null,
    zzpalspace_deliv                             number                              null,
    zzmeins_deliv                                varchar2(3 char)                    null,
    value1                                       number                              null,
    zrsp                                         number                              null,
    rate                                         number                              null,
    kostl                                        varchar2(10 char)                   null,
    vfdat1                                       varchar2(8 char)                    null,
    value                                        number                              null,
    zzbb4                                        varchar2(8 char)                    null,
    zzpi_id                                      varchar2(20 char)                   null,
    insmk                                        varchar2(1 char)                    null,
    spart1                                       varchar2(2 char)                    null,
    lgort_bez                                    varchar2(16 char)                   null,
    ladgr_bez                                    varchar2(20 char)                   null,
    tragr_bez                                    varchar2(20 char)                   null,
    vkbur_bez                                    varchar2(20 char)                   null,
    vkgrp_bez                                    varchar2(20 char)                   null,
    vtweg_bez                                    varchar2(20 char)                   null,
    spart_bez                                    varchar2(20 char)                   null,
    mfrgr_bez                                    varchar2(20 char)                   null,
    pstyv                                        varchar2(4 char)                    null,
    matkl1                                       varchar2(9 char)                    null,
    prodh                                        varchar2(18 char)                   null,
    umvkz                                        number                              null,
    umvkn                                        number                              null,
    kztlf                                        varchar2(1 char)                    null,
    uebtk                                        varchar2(1 char)                    null,
    uebto                                        number                              null,
    untto                                        number                              null,
    chspl                                        varchar2(1 char)                    null,
    xchbw                                        varchar2(1 char)                    null,
    posar                                        varchar2(1 char)                    null,
    sobkz                                        varchar2(1 char)                    null,
    pckpf                                        varchar2(1 char)                    null,
    magrv                                        varchar2(4 char)                    null,
    shkzg                                        varchar2(1 char)                    null,
    koqui                                        varchar2(1 char)                    null,
    aktnr                                        varchar2(10 char)                   null,
    kzumw                                        varchar2(1 char)                    null,
    kvgr1                                        varchar2(3 char)                    null,
    kvgr2                                        varchar2(3 char)                    null,
    kvgr3                                        varchar2(3 char)                    null,
    kvgr4                                        varchar2(3 char)                    null,
    kvgr5                                        varchar2(3 char)                    null,
    mvgr1                                        varchar2(3 char)                    null,
    mvgr2                                        varchar2(3 char)                    null,
    mvgr3                                        varchar2(3 char)                    null,
    mvgr4                                        varchar2(3 char)                    null,
    mvgr5                                        varchar2(3 char)                    null,
    pstyv_bez                                    varchar2(20 char)                   null,
    matkl_bez                                    varchar2(20 char)                   null,
    prodh_bez                                    varchar2(20 char)                   null,
    werks_bez                                    varchar2(30 char)                   null,
    kvgr1_bez                                    varchar2(20 char)                   null,
    kvgr2_bez                                    varchar2(20 char)                   null,
    kvgr3_bez                                    varchar2(20 char)                   null,
    kvgr4_bez                                    varchar2(20 char)                   null,
    kvgr5_bez                                    varchar2(20 char)                   null,
    mvgr1_bez                                    varchar2(40 char)                   null,
    mvgr2_bez                                    varchar2(40 char)                   null,
    mvgr3_bez                                    varchar2(40 char)                   null,
    mvgr4_bez                                    varchar2(40 char)                   null,
    mvgr5_bez                                    varchar2(40 char)                   null);

/**/
/* Comments
/**/
comment on table lads_del_det is 'LADS Delivery Detail';
comment on column lads_del_det.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_det.detseq is 'DET - generated sequence number';
comment on column lads_del_det.posnr is 'Item number of the SD document';
comment on column lads_del_det.matnr is 'Material Number';
comment on column lads_del_det.matwa is 'Material entered';
comment on column lads_del_det.arktx is 'Short Text for Sales Order Item';
comment on column lads_del_det.orktx is 'Description of Material Entered';
comment on column lads_del_det.sugrd is 'Reason for material substitution';
comment on column lads_del_det.sudru is 'Original entry will be printed';
comment on column lads_del_det.matkl is 'Material Group';
comment on column lads_del_det.werks is 'Plant';
comment on column lads_del_det.lgort is 'Storage Location';
comment on column lads_del_det.charg is 'Batch Number';
comment on column lads_del_det.kdmat is 'Material belonging to the customer';
comment on column lads_del_det.lfimg is 'Actual quantity delivered (in sales units)';
comment on column lads_del_det.vrkme is 'Sales unit';
comment on column lads_del_det.lgmng is 'Actual quantity delivered in stockkeeping units';
comment on column lads_del_det.meins is 'Base Unit of Measure';
comment on column lads_del_det.ntgew is 'Net weight';
comment on column lads_del_det.brgew is 'Gross weight';
comment on column lads_del_det.gewei is 'Weight Unit';
comment on column lads_del_det.volum is 'Volume';
comment on column lads_del_det.voleh is 'Volume unit';
comment on column lads_del_det.lgpbe is 'Storage bin';
comment on column lads_del_det.hipos is 'Superior item in an item hierarchy';
comment on column lads_del_det.hievw is 'Use of Hierarchy Item';
comment on column lads_del_det.ladgr is 'Loading group';
comment on column lads_del_det.tragr is 'Transportation group';
comment on column lads_del_det.vkbur is 'Sales office';
comment on column lads_del_det.vkgrp is 'Sales group';
comment on column lads_del_det.vtweg is 'Distribution Channel';
comment on column lads_del_det.spart is 'Division';
comment on column lads_del_det.grkor is 'Delivery group (items are delivered together)';
comment on column lads_del_det.ean11 is 'International Article Number (EAN/UPC)';
comment on column lads_del_det.sernr is 'BOM explosion number';
comment on column lads_del_det.aeskd is 'Customer Engineering Change Status';
comment on column lads_del_det.empst is 'Receiving point';
comment on column lads_del_det.mfrgr is 'Material freight group';
comment on column lads_del_det.vbrst is 'Customer point of consumption';
comment on column lads_del_det.labnk is 'Customer number for forecast / JIT dlv. sched.';
comment on column lads_del_det.abrdt is 'Delivery Schedule Date';
comment on column lads_del_det.mfrpn is 'Manufacturer part number';
comment on column lads_del_det.mfrnr is 'Manufacturer number';
comment on column lads_del_det.abrvw is 'Usage indicator';
comment on column lads_del_det.kdmat35 is 'Material belonging to the customer';
comment on column lads_del_det.kannr is 'KANBAN/sequence number';
comment on column lads_del_det.posex is 'External item number';
comment on column lads_del_det.lieffz is 'Cumulative qty for delivery/MAIS in base unit of measure';
comment on column lads_del_det.usr01 is 'Additional data field 1 for delivery schedules';
comment on column lads_del_det.usr02 is 'Additional data field 2 for delivery schedules';
comment on column lads_del_det.usr03 is 'Additional data field 3 for delivery schedules';
comment on column lads_del_det.usr04 is ' Additional data field 4 for delivery schedules';
comment on column lads_del_det.usr05 is 'Additional data field 5 for delivery schedules';
comment on column lads_del_det.matnr_external is 'Long material number (future development) for MATNR field';
comment on column lads_del_det.matnr_version is 'Version number (future development) for MATNR field';
comment on column lads_del_det.matnr_guid is 'External GUID (future development) for MATNR field';
comment on column lads_del_det.matwa_external is 'Long material number (future development) for field MATWA';
comment on column lads_del_det.matwa_version is 'Version number (future development) for field MATWA';
comment on column lads_del_det.matwa_guid is 'External GUID (future development) for field MATWA';
comment on column lads_del_det.zudat is 'Additional Data';
comment on column lads_del_det.vfdat is 'Shelf Life Expiration Date';
comment on column lads_del_det.zzmeins01 is 'Pallet Base UoM';
comment on column lads_del_det.zzpalbas01_f is 'Number of pallet Base';
comment on column lads_del_det.vbelv is 'Originating document';
comment on column lads_del_det.posnv is 'Originating item';
comment on column lads_del_det.zzhalfpal is 'flag indicator for 1/2 pallet (Height)';
comment on column lads_del_det.zzstackable is 'Stackable Pallet Flag for Order Optimisation';
comment on column lads_del_det.zznbrhompal is 'Number of homogeneous pallet';
comment on column lads_del_det.zzpalbase_deliv is 'number of pallet bases on delivery';
comment on column lads_del_det.zzpalspace_deliv is 'Number of pallet spaces on delivery';
comment on column lads_del_det.zzmeins_deliv is 'Base Unit of Measure';
comment on column lads_del_det.value1 is 'Condition subtotal';
comment on column lads_del_det.zrsp is 'Condition subtotal';
comment on column lads_del_det.rate is 'Condition subtotal';
comment on column lads_del_det.kostl is 'Cost Center';
comment on column lads_del_det.vfdat1 is 'Shelf Life Expiration Date';
comment on column lads_del_det.value is 'Condition subtotal';
comment on column lads_del_det.zzbb4 is 'Calculated Batch Expiry Date';
comment on column lads_del_det.zzpi_id is 'Identification number of packing instruction';
comment on column lads_del_det.insmk is 'Stock type';
comment on column lads_del_det.spart1 is 'Division';
comment on column lads_del_det.lgort_bez is 'Description of storage location';
comment on column lads_del_det.ladgr_bez is 'Loading group description';
comment on column lads_del_det.tragr_bez is 'Description of transportation group';
comment on column lads_del_det.vkbur_bez is 'Description of sales office';
comment on column lads_del_det.vkgrp_bez is 'Description of sales group';
comment on column lads_del_det.vtweg_bez is 'Description of distribution channel';
comment on column lads_del_det.spart_bez is 'Description of division';
comment on column lads_del_det.mfrgr_bez is 'Description of material freight group';
comment on column lads_del_det.pstyv is 'Sales document item category';
comment on column lads_del_det.matkl1 is 'Material Group';
comment on column lads_del_det.prodh is 'Product hierarchy';
comment on column lads_del_det.umvkz is 'Numerator (factor) for conversion of sales quantity into SKU';
comment on column lads_del_det.umvkn is 'Denominator (divisor) for conversion of sales qty. into SKU';
comment on column lads_del_det.kztlf is 'Partial delivery at item level';
comment on column lads_del_det.uebtk is 'Indicator: Unlimited overdelivery allowed';
comment on column lads_del_det.uebto is 'Overdelivery tolerance limit';
comment on column lads_del_det.untto is 'Underdelivery tolerance limit';
comment on column lads_del_det.chspl is 'Batch split allowed';
comment on column lads_del_det.xchbw is 'Indicator for Batches / Evaluation Types';
comment on column lads_del_det.posar is 'Item type';
comment on column lads_del_det.sobkz is 'Special Stock Indicator';
comment on column lads_del_det.pckpf is 'Packing control';
comment on column lads_del_det.magrv is 'Material Group: Packaging Materials';
comment on column lads_del_det.shkzg is 'Debit/Credit Indicator';
comment on column lads_del_det.koqui is 'Picking is subject to confirmation';
comment on column lads_del_det.aktnr is 'Promotion';
comment on column lads_del_det.kzumw is 'Indicator: Environmentally Relevant';
comment on column lads_del_det.kvgr1 is 'Invoice Combina';
comment on column lads_del_det.kvgr2 is 'Expected Band Price';
comment on column lads_del_det.kvgr3 is 'Cust. Accept Int. Pallet';
comment on column lads_del_det.kvgr4 is 'Guaranteed Band Price';
comment on column lads_del_det.kvgr5 is 'Back Order Accepted';
comment on column lads_del_det.mvgr1 is 'CRPC Material Category';
comment on column lads_del_det.mvgr2 is 'Material group 2';
comment on column lads_del_det.mvgr3 is 'Material group 3';
comment on column lads_del_det.mvgr4 is 'Shelf Life Group';
comment on column lads_del_det.mvgr5 is 'Mode of Transport Type';
comment on column lads_del_det.pstyv_bez is 'Description of item category';
comment on column lads_del_det.matkl_bez is 'Description of material group';
comment on column lads_del_det.prodh_bez is 'Description of product hierarchy';
comment on column lads_del_det.werks_bez is 'Plant Descript.';
comment on column lads_del_det.kvgr1_bez is 'Description cust. group 1';
comment on column lads_del_det.kvgr2_bez is 'Description cust. group 2';
comment on column lads_del_det.kvgr3_bez is 'Description cust. group 3';
comment on column lads_del_det.kvgr4_bez is 'Description cust. group 4';
comment on column lads_del_det.kvgr5_bez is 'Description cust. group 5';
comment on column lads_del_det.mvgr1_bez is 'Description material group 1';
comment on column lads_del_det.mvgr2_bez is 'Description material group 2';
comment on column lads_del_det.mvgr3_bez is 'Description material group 3';
comment on column lads_del_det.mvgr4_bez is 'Description material group 4';
comment on column lads_del_det.mvgr5_bez is 'Description material group 5';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_det
   add constraint lads_del_det_pk primary key (vbeln, detseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_det to lads_app;
grant select, insert, update, delete on lads_del_det to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_det for lads.lads_del_det;
