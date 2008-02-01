/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_drf
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_drf

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_drf
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    ditseq                                       number                              not null,
    drfseq                                       number                              not null,
    qualf                                        varchar2(1 char)                    null,
    belnr                                        varchar2(35 char)                   null,
    itmnr                                        varchar2(6 char)                    null,
    datum                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_shp_drf is 'LADS Shipment Reference';
comment on column lads_shp_drf.tknum is 'Shipment Number';
comment on column lads_shp_drf.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_drf.ditseq is 'DIT - generated sequence number';
comment on column lads_shp_drf.drfseq is 'DRF - generated sequence number';
comment on column lads_shp_drf.qualf is 'SD document category';
comment on column lads_shp_drf.belnr is 'IDOC document number';
comment on column lads_shp_drf.itmnr is 'Item number';
comment on column lads_shp_drf.datum is 'IDOC: Date';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_drf
   add constraint lads_shp_drf_pk primary key (tknum, dlvseq, ditseq, drfseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_drf to lads_app;
grant select, insert, update, delete on lads_shp_drf to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_drf for lads.lads_shp_drf;
