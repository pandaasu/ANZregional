/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_hsi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_hsi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_hsi
   (tknum                                        varchar2(10 char)                   not null,
    hstseq                                       number                              not null,
    hsiseq                                       number                              not null,
    vbeln                                        varchar2(10 char)                   null,
    parid                                        varchar2(35 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_hsi is 'LADS Shipment Stage Assignment';
comment on column lads_shp_hsi.tknum is 'Shipment Number';
comment on column lads_shp_hsi.hstseq is 'HST - generated sequence number';
comment on column lads_shp_hsi.hsiseq is 'HSI - generated sequence number';
comment on column lads_shp_hsi.vbeln is 'Delivery';
comment on column lads_shp_hsi.parid is 'External partner number';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_hsi
   add constraint lads_shp_hsi_pk primary key (tknum, hstseq, hsiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_hsi to lads_app;
grant select, insert, update, delete on lads_shp_hsi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_hsi for lads.lads_shp_hsi;
