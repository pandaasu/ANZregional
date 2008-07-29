/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_mat_uom
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_mat_uom

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_mat_uom
   (matnr                                        varchar2(18 char)                   not null,
    uomseq                                       number                              not null,
    msgfn                                        varchar2(3 char)                    null,
    meinh                                        varchar2(3 char)                    null,
    umrez                                        number                              null,
    umren                                        number                              null,
    ean11                                        varchar2(18 char)                   null,
    numtp                                        varchar2(2 char)                    null,
    laeng                                        number                              null,
    breit                                        number                              null,
    hoehe                                        number                              null,
    meabm                                        varchar2(3 char)                    null,
    volum                                        number                              null,
    voleh                                        varchar2(3 char)                    null,
    brgew                                        number                              null,
    gewei                                        varchar2(3 char)                    null,
    mesub                                        varchar2(3 char)                    null,
    gtin_variant                                 varchar2(2 char)                    null,
    zzmultitdu                                   varchar2(1 char)                    null,
    zzpcitem                                     varchar2(18 char)                   null,
    zzpclevel                                    number                              null,
    zzpreforder                                  varchar2(1 char)                    null,
    zzprefsales                                  varchar2(1 char)                    null,
    zzprefissue                                  varchar2(1 char)                    null,
    zzprefwm                                     varchar2(1 char)                    null,
    zzrefmatnr                                   varchar2(18 char)                   null);

/**/
/* Comments
/**/
comment on table lads_mat_uom is 'LADS Material Alternative Units Of Measure';
comment on column lads_mat_uom.matnr is 'Material Number';
comment on column lads_mat_uom.uomseq is 'UOM - generated sequence number';
comment on column lads_mat_uom.msgfn is 'Function';
comment on column lads_mat_uom.meinh is 'Alternative Unit of Measure for Stockkeeping Unit';
comment on column lads_mat_uom.umrez is 'Numerator for Conversion to Base Units of Measure';
comment on column lads_mat_uom.umren is 'Denominator for Conversion to Base Units of Measure';
comment on column lads_mat_uom.ean11 is 'International Article Number (EAN/UPC)';
comment on column lads_mat_uom.numtp is 'Category of International Article Number (EAN)';
comment on column lads_mat_uom.laeng is 'Length';
comment on column lads_mat_uom.breit is 'Width';
comment on column lads_mat_uom.hoehe is 'Height';
comment on column lads_mat_uom.meabm is 'Unit of dimension for length/width/height';
comment on column lads_mat_uom.volum is 'Volume';
comment on column lads_mat_uom.voleh is 'Volume unit';
comment on column lads_mat_uom.brgew is 'Gross weight';
comment on column lads_mat_uom.gewei is 'Weight Unit';
comment on column lads_mat_uom.mesub is 'Lower-Level Unit of Measure in a Packing Hierarchy';
comment on column lads_mat_uom.gtin_variant is 'Global Trade Item Number Variant';
comment on column lads_mat_uom.zzmultitdu is 'Indicator: Unit of measure with multiple Conversion factors';
comment on column lads_mat_uom.zzpcitem is 'PC Item Code.';
comment on column lads_mat_uom.zzpclevel is 'Level in PC.';
comment on column lads_mat_uom.zzpreforder is 'Indicator of preference for Unit Measure (Order)';
comment on column lads_mat_uom.zzprefsales is 'Indicator of preference for Unit Measure (Sales)';
comment on column lads_mat_uom.zzprefissue is 'Indicator of preference for Unit Measure (Issue)';
comment on column lads_mat_uom.zzprefwm is 'Indicator of preference for Unit Measure (WM)';
comment on column lads_mat_uom.zzrefmatnr is 'Rep. Material Number';

/**/
/* Primary Key Constraint
/**/
alter table lads_mat_uom
   add constraint lads_mat_uom_pk primary key (matnr, uomseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_mat_uom to lads_app;
grant select, insert, update, delete on lads_mat_uom to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_mat_uom for lads.lads_mat_uom;
