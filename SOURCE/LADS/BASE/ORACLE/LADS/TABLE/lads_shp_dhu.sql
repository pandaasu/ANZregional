/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_dhu
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_dhu

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_dhu
   (tknum                                        varchar2(10 char)                   not null,
    dlvseq                                       number                              not null,
    dhuseq                                       number                              not null,
    exidv                                        varchar2(20 char)                   null,
    brgew                                        number                              null,
    gweim                                        varchar2(3 char)                    null,
    btvol                                        number                              null,
    volem                                        varchar2(3 char)                    null,
    laeng                                        number                              null,
    breit                                        number                              null,
    hoehe                                        number                              null,
    meabm                                        varchar2(3 char)                    null,
    inhalt                                       varchar2(40 char)                   null,
    farzt                                        number                              null,
    fareh                                        varchar2(3 char)                    null,
    entfe                                        number                              null,
    ehent                                        varchar2(3 char)                    null,
    exidv2                                       varchar2(20 char)                   null,
    landt                                        varchar2(3 char)                    null,
    move_status                                  varchar2(4 char)                    null,
    packvorschr                                  varchar2(22 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_dhu is 'LADS Shipment Handling Unit';
comment on column lads_shp_dhu.tknum is 'Shipment Number';
comment on column lads_shp_dhu.dlvseq is 'DLV - generated sequence number';
comment on column lads_shp_dhu.dhuseq is 'DHU - generated sequence number';
comment on column lads_shp_dhu.exidv is 'External Handling Unit Identification';
comment on column lads_shp_dhu.brgew is 'Total Weight of Handling Unit';
comment on column lads_shp_dhu.gweim is 'Weight Unit';
comment on column lads_shp_dhu.btvol is 'Total Volume of Handling Unit';
comment on column lads_shp_dhu.volem is 'Volume unit';
comment on column lads_shp_dhu.laeng is 'Length';
comment on column lads_shp_dhu.breit is 'Width';
comment on column lads_shp_dhu.hoehe is 'Height';
comment on column lads_shp_dhu.meabm is 'Unit of dimension for length/width/height';
comment on column lads_shp_dhu.inhalt is 'Description of Handling Unit Content';
comment on column lads_shp_dhu.farzt is 'Travel Time';
comment on column lads_shp_dhu.fareh is 'Unit of travel time';
comment on column lads_shp_dhu.entfe is 'Distance Travelled';
comment on column lads_shp_dhu.ehent is 'Unit of distance';
comment on column lads_shp_dhu.exidv2 is 'Handling Units 2nd External Identification';
comment on column lads_shp_dhu.landt is 'Country providing means of transport';
comment on column lads_shp_dhu.move_status is 'Handling unit status';
comment on column lads_shp_dhu.packvorschr is 'Text string 22 characters';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_dhu
   add constraint lads_shp_dhu_pk primary key (tknum, dlvseq, dhuseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_dhu to lads_app;
grant select, insert, update, delete on lads_shp_dhu to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_dhu for lads.lads_shp_dhu;
