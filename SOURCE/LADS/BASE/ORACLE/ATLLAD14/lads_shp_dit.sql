/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dit
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dit

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dit
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    ditseq                                       number                              not null,
    posnr                                        varchar2(6 char)                    null,
    matnr                                        varchar2(18 char)                   null,
    matwa                                        varchar2(18 char)                   null,
    orktx                                        varchar2(40 char)                   null,
    matkl                                        varchar2(9 char)                    null,
    werks                                        varchar2(4 char)                    null,
    lgort                                        varchar2(4 char)                    null,
    charg                                        varchar2(10 char)                   null,
    lgort_bez                                    varchar2(16 char)                   null,
    ladgr_bez                                    varchar2(20 char)                   null,
    tragr_bez                                    varchar2(20 char)                   null,
    vkbur_bez                                    varchar2(20 char)                   null,
    vkgrp_bez                                    varchar2(20 char)                   null,
    vtweg_bez                                    varchar2(20 char)                   null,
    spart_bez                                    varchar2(20 char)                   null,
    mfrgr_bez                                    varchar2(20 char)                   null,
    pstyv                                        varchar2(4 char)                    null,
    matkl_dup                                    varchar2(9 char)                    null,
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
    pstyv_bez                                    varchar2(20 char)                   null,
    matkl_bez                                    varchar2(20 char)                   null,
    prodh_bez                                    varchar2(20 char)                   null,
    werks_bez                                    varchar2(30 char)                   null,
    stawn                                        varchar2(17 char)                   null,
    exprf                                        varchar2(5 char)                    null,
    exart                                        varchar2(2 char)                    null,
    herkl                                        varchar2(3 char)                    null,
    herkr                                        varchar2(3 char)                    null,
    grwrt                                        number                              null,
    prefe                                        varchar2(1 char)                    null,
    stxt1                                        varchar2(40 char)                   null,
    stxt2                                        varchar2(40 char)                   null,
    stxt3                                        varchar2(40 char)                   null,
    stxt4                                        varchar2(40 char)                   null,
    stxt5                                        varchar2(40 char)                   null,
    stxt6                                        varchar2(40 char)                   null,
    stxt7                                        varchar2(40 char)                   null,
    exprf_bez                                    varchar2(30 char)                   null,
    exart_bez                                    varchar2(30 char)                   null,
    herkl_bez                                    varchar2(15 char)                   null,
    herkr_bez                                    varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_dit is 'LADS Shipment Delivery Item';
comment on column lads_shp_dit.tknum is 'Shipment Number';
comment on column lads_shp_dit.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dit.ditseq is 'DIT - generated sequence number';
comment on column lads_shp_dit.posnr is 'Item number of the SD document';
comment on column lads_shp_dit.matnr is 'Material Number';
comment on column lads_shp_dit.matwa is 'Material entered';
comment on column lads_shp_dit.orktx is 'Description of Material Entered';
comment on column lads_shp_dit.matkl is 'Material Group';
comment on column lads_shp_dit.werks is 'Plant';
comment on column lads_shp_dit.lgort is 'Storage Location';
comment on column lads_shp_dit.charg is 'Batch Number';
comment on column lads_shp_dit.lgort_bez is 'Description of storage location';
comment on column lads_shp_dit.ladgr_bez is 'Loading group description';
comment on column lads_shp_dit.tragr_bez is 'Description of transportation group';
comment on column lads_shp_dit.vkbur_bez is 'Description of sales office';
comment on column lads_shp_dit.vkgrp_bez is 'Description of sales group';
comment on column lads_shp_dit.vtweg_bez is 'Description of distribution channel';
comment on column lads_shp_dit.spart_bez is 'Description of division';
comment on column lads_shp_dit.mfrgr_bez is 'Description of material freight group';
comment on column lads_shp_dit.pstyv is 'Sales document item category';
comment on column lads_shp_dit.matkl_dup is 'Material Group';
comment on column lads_shp_dit.prodh is 'Product hierarchy';
comment on column lads_shp_dit.umvkz is 'Numerator (factor) for conversion of sales quantity into SKU';
comment on column lads_shp_dit.umvkn is 'Denominator (divisor) for conversion of sales qty. into SKU';
comment on column lads_shp_dit.kztlf is 'Partial delivery at item level';
comment on column lads_shp_dit.uebtk is 'Indicator: Unlimited overdelivery allowed';
comment on column lads_shp_dit.uebto is 'Overdelivery tolerance limit';
comment on column lads_shp_dit.untto is 'Underdelivery tolerance limit';
comment on column lads_shp_dit.chspl is 'Batch split allowed';
comment on column lads_shp_dit.xchbw is 'Indicator for Batches / Evaluation Types';
comment on column lads_shp_dit.posar is 'Item type';
comment on column lads_shp_dit.sobkz is 'Special Stock Indicator';
comment on column lads_shp_dit.pckpf is 'Packing control';
comment on column lads_shp_dit.magrv is 'Material Group: Packaging Materials';
comment on column lads_shp_dit.shkzg is 'Debit/Credit Indicator';
comment on column lads_shp_dit.koqui is 'Picking is subject to confirmation';
comment on column lads_shp_dit.aktnr is 'Promotion';
comment on column lads_shp_dit.kzumw is 'Indicator: Environmentally Relevant';
comment on column lads_shp_dit.pstyv_bez is 'Description of item category';
comment on column lads_shp_dit.matkl_bez is 'Description of material group';
comment on column lads_shp_dit.prodh_bez is 'Description of product hierarchy';
comment on column lads_shp_dit.werks_bez is 'Plant Descript.';
comment on column lads_shp_dit.stawn is 'Commodity code / Import code number for foreign trade';
comment on column lads_shp_dit.exprf is 'Export/Import procedure for foreign trade (5 digits)';
comment on column lads_shp_dit.exart is 'Business Transaction Type for Foreign Trade';
comment on column lads_shp_dit.herkl is 'Country of origin of the material';
comment on column lads_shp_dit.herkr is 'Region of origin of material (non-preferential origin)';
comment on column lads_shp_dit.grwrt is 'Statistical value for foreign trade';
comment on column lads_shp_dit.prefe is 'Preference indicator in export/import';
comment on column lads_shp_dit.stxt1 is 'Description of commodity code - First line';
comment on column lads_shp_dit.stxt2 is 'Description of commodity code - Second line';
comment on column lads_shp_dit.stxt3 is 'Description of commodity code - Third line';
comment on column lads_shp_dit.stxt4 is 'Description of commodity code - Fourth line';
comment on column lads_shp_dit.stxt5 is 'Description of commodity code - Fifth line';
comment on column lads_shp_dit.stxt6 is 'Description of commodity code - Sixth line';
comment on column lads_shp_dit.stxt7 is 'Description of commodity code - Seventh line';
comment on column lads_shp_dit.exprf_bez is 'Export/import procedure description';
comment on column lads_shp_dit.exart_bez is 'Description of business transaction type';
comment on column lads_shp_dit.herkl_bez is 'Description of country of origin';
comment on column lads_shp_dit.herkr_bez is 'Description of region of origin';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dit
   add constraint lads_shp_dit_pk primary key (tknum, dlvseq, ditseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dit to lads_app;
grant select, insert, update, delete on lads_shp_dit to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dit for lads.lads_shp_dit;
