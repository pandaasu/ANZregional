/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dib
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dib

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dib
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    ditseq                                       number                              not null,
    dibseq                                       number                              not null,
    zzmeins01                                    varchar2(3 char)                    null,
    zzpalbas01_f                                 number                              null,
    vbelv                                        varchar2(10 char)                   null,
    posnv                                        number                              null,
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
    vfdat                                        varchar2(8 char)                    null,
    value                                        number                              null,
    zzbb4                                        varchar2(8 char)                    null,
    zzpi_id                                      varchar2(20 char)                   null,
    insmk                                        varchar2(1 char)                    null,
    spart                                        varchar2(2 char)                    null,
    kwmeng                                       number                              null);

/**/
/* Comments
/**/
comment on table lads_shp_dib is 'LADS Shipment Delivery Item Bespoke Data';
comment on column lads_shp_dib.tknum is 'Shipment Number';
comment on column lads_shp_dib.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dib.ditseq is 'DIT - generated sequence number';
comment on column lads_shp_dib.dibseq is 'DIB - generated sequence number';
comment on column lads_shp_dib.zzmeins01 is 'Pallet Base UoM';
comment on column lads_shp_dib.zzpalbas01_f is 'Number of pallet Base';
comment on column lads_shp_dib.vbelv is 'Originating document';
comment on column lads_shp_dib.posnv is 'Originating item';
comment on column lads_shp_dib.zzhalfpal is 'flag indicator for 1/2 pallet (Height)';
comment on column lads_shp_dib.zzstackable is 'Stackable Pallet Flag for Order Optimisation';
comment on column lads_shp_dib.zznbrhompal is 'Number of homogeneous pallet';
comment on column lads_shp_dib.zzpalbase_deliv is 'number of pallet bases on delivery';
comment on column lads_shp_dib.zzpalspace_deliv is 'Number of pallet spaces on delivery';
comment on column lads_shp_dib.zzmeins_deliv is 'Base Unit of Measure';
comment on column lads_shp_dib.value1 is 'Condition subtotal';
comment on column lads_shp_dib.zrsp is 'Condition subtotal';
comment on column lads_shp_dib.rate is 'Condition subtotal';
comment on column lads_shp_dib.kostl is 'Cost Center';
comment on column lads_shp_dib.vfdat is 'Shelf Life Expiration Date';
comment on column lads_shp_dib.value is 'Condition subtotal';
comment on column lads_shp_dib.zzbb4 is 'Calculated Batch Expiry Date';
comment on column lads_shp_dib.zzpi_id is 'Identification number of packing instruction';
comment on column lads_shp_dib.insmk is 'Stock type';
comment on column lads_shp_dib.spart is 'Division';
comment on column lads_shp_dib.kwmeng is 'Cumulative order quantity in sales units';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dib
   add constraint lads_shp_dib_pk primary key (tknum, dlvseq, ditseq, dibseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dib to lads_app;
grant select, insert, update, delete on lads_shp_dib to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dib for lads.lads_shp_dib;
