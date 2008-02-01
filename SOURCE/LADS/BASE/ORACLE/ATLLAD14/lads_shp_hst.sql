/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_hst
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_hst

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_hst
   (tknum                                        varchar2(10 char)                   not null,
    hstseq                                       number                              not null,
    tsnum                                        number                              null,
    tsrfo                                        number                              null,
    tstyp                                        varchar2(1 char)                    null,
    vsart                                        varchar2(2 char)                    null,
    inco1                                        varchar2(3 char)                    null,
    laufk                                        varchar2(1 char)                    null,
    distz                                        number                              null,
    medst                                        varchar2(3 char)                    null,
    fahzt                                        number                              null,
    geszt                                        number                              null,
    meizt                                        varchar2(3 char)                    null,
    gesztd                                       number                              null,
    fahztd                                       number                              null,
    gesztda                                      number                              null,
    fahztda                                      number                              null,
    sdabw                                        varchar2(4 char)                    null,
    frkrl                                        varchar2(1 char)                    null,
    skalsm                                       varchar2(6 char)                    null,
    fbsta                                        varchar2(1 char)                    null,
    arsta                                        varchar2(1 char)                    null,
    warztd                                       number                              null,
    warztda                                      number                              null,
    cont_dg                                      varchar2(1 char)                    null,
    tstyp_bez                                    varchar2(20 char)                   null,
    vsart_bez                                    varchar2(20 char)                   null,
    inco1_bez                                    varchar2(30 char)                   null,
    laufk_bez                                    varchar2(20 char)                   null,
    fbsta_bez                                    varchar2(25 char)                   null,
    arsta_bez                                    varchar2(25 char)                   null);

/**/
/* Comments
/**/
comment on table lads_shp_hst is 'LADS Shipment Stage';
comment on column lads_shp_hst.tknum is 'Shipment Number';
comment on column lads_shp_hst.hstseq is 'HST - generated sequence number';
comment on column lads_shp_hst.tsnum is 'Stage of transport number';
comment on column lads_shp_hst.tsrfo is 'Stage of transport sequence';
comment on column lads_shp_hst.tstyp is 'Stage category';
comment on column lads_shp_hst.vsart is 'Shipping type for shipment stage';
comment on column lads_shp_hst.inco1 is 'Incoterms for printout';
comment on column lads_shp_hst.laufk is 'Leg indicator for shipment stage';
comment on column lads_shp_hst.distz is 'Distance';
comment on column lads_shp_hst.medst is 'Unit of measure for distance';
comment on column lads_shp_hst.fahzt is 'Travelling time only between two locations';
comment on column lads_shp_hst.geszt is 'Total travelling time between two locations incl. breaks';
comment on column lads_shp_hst.meizt is 'Unit of measure for travelling times';
comment on column lads_shp_hst.gesztd is 'Planned total time at stage level (in days)';
comment on column lads_shp_hst.fahztd is 'Plan: Actual duration at stage level (in hours:minutes)';
comment on column lads_shp_hst.gesztda is 'Actual total time at stage of shipment (in days)';
comment on column lads_shp_hst.fahztda is 'Actual duration of shipment stage (in hours:minutes)';
comment on column lads_shp_hst.sdabw is 'Special processing indicator';
comment on column lads_shp_hst.frkrl is 'Shipment costs relevance';
comment on column lads_shp_hst.skalsm is 'Pricing procedure in stage of shipment';
comment on column lads_shp_hst.fbsta is 'Status of shipment costs calculation';
comment on column lads_shp_hst.arsta is 'Status of shipment costs settlement';
comment on column lads_shp_hst.warztd is 'Planned waiting time in shipment stage (in hrs:min)';
comment on column lads_shp_hst.warztda is 'Current waiting time in shipment stage (in hrs:min)';
comment on column lads_shp_hst.cont_dg is 'Indicator: Section contains dangerous goods';
comment on column lads_shp_hst.tstyp_bez is 'Description';
comment on column lads_shp_hst.vsart_bez is 'Description of the Shipping Type';
comment on column lads_shp_hst.inco1_bez is 'Description';
comment on column lads_shp_hst.laufk_bez is 'Description';
comment on column lads_shp_hst.fbsta_bez is 'Description of status for calculation of shipment costs';
comment on column lads_shp_hst.arsta_bez is 'Description for status of shipment costs settlement';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_hst
   add constraint lads_shp_hst_pk primary key (tknum, hstseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_hst to lads_app;
grant select, insert, update, delete on lads_shp_hst to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_hst for lads.lads_shp_hst;
