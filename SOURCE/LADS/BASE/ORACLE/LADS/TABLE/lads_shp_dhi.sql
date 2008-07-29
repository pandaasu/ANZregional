/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dhi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dhi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dhi
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    dhuseq                                       number                              not null,
    dhiseq                                       number                              not null,
    velin                                        varchar2(1 char)                    null,
    vbeln                                        varchar2(10 char)                   null,
    posnr                                        varchar2(6 char)                    null,
    exidv                                        varchar2(20 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_dhi is 'LADS Shipment Handling Unit Item';
comment on column lads_shp_dhi.tknum is 'Shipment Number';
comment on column lads_shp_dhi.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dhi.dhuseq is 'DHU - generated sequence number';
comment on column lads_shp_dhi.dhiseq is 'DHI - generated sequence number';
comment on column lads_shp_dhi.velin is 'Type of Handling-unit Item Content';
comment on column lads_shp_dhi.vbeln is 'Sales and Distribution Document Number';
comment on column lads_shp_dhi.posnr is 'Item number of the SD document';
comment on column lads_shp_dhi.exidv is 'External Handling Unit Identification';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dhi
   add constraint lads_shp_dhi_pk primary key (tknum, dlvseq, dhuseq, dhiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dhi to lads_app;
grant select, insert, update, delete on lads_shp_dhi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dhi for lads.lads_shp_dhi;
