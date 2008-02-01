/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dng
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dng

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dng
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    ditseq                                       number                              not null,
    dngseq                                       number                              not null,
    mot                                          number                              null,
    valdat                                       varchar2(8 char)                    null,
    dgcao                                        varchar2(1 char)                    null,
    dgnhm                                        varchar2(1 char)                    null,
    tkui                                         varchar2(3 char)                    null,
    dgnu                                         varchar2(4 char)                    null);

/**/
/* Comments
/**/
comment on table lads_shp_dng is 'LADS Shipment Dangerous Goods';
comment on column lads_shp_dng.tknum is 'Shipment Number';
comment on column lads_shp_dng.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dng.ditseq is 'DIT - generated sequence number';
comment on column lads_shp_dng.dngseq is 'DNG - generated sequence number';
comment on column lads_shp_dng.mot is 'Dangerous Goods - Mode of Transport Category';
comment on column lads_shp_dng.valdat is 'Selection date dangerous goods master data';
comment on column lads_shp_dng.dgcao is 'Indicator: Only cargo air transport permitted';
comment on column lads_shp_dng.dgnhm is 'Indicator: Not a dangerous good';
comment on column lads_shp_dng.tkui is 'UN number category';
comment on column lads_shp_dng.dgnu is 'Identification number';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dng
   add constraint lads_shp_dng_pk primary key (tknum, dlvseq, ditseq, dngseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dng to lads_app;
grant select, insert, update, delete on lads_shp_dng to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dng for lads.lads_shp_dng;
