/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_shp_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_shp_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_shp_hdr
   (tknum                                        varchar2(10 char)                   not null,
    shtyp                                        varchar2(4 char)                    null,
    abfer                                        varchar2(1 char)                    null,
    abwst                                        varchar2(1 char)                    null,
    bfart                                        varchar2(1 char)                    null,
    vsart                                        varchar2(2 char)                    null,
    laufk                                        varchar2(1 char)                    null,
    vsbed                                        varchar2(2 char)                    null,
    route                                        varchar2(6 char)                    null,
    signi                                        varchar2(20 char)                   null,
    exti1                                        varchar2(20 char)                   null,
    exti2                                        varchar2(20 char)                   null,
    tpbez                                        varchar2(20 char)                   null,
    sttrg                                        varchar2(1 char)                    null,
    pkstk                                        varchar2(1 char)                    null,
    dtmeg                                        varchar2(3 char)                    null,
    dtmev                                        varchar2(3 char)                    null,
    distz                                        number                              null,
    medst                                        varchar2(3 char)                    null,
    fahzt                                        number                              null,
    geszt                                        number                              null,
    meizt                                        varchar2(3 char)                    null,
    fbsta                                        varchar2(1 char)                    null,
    fbgst                                        varchar2(1 char)                    null,
    arsta                                        varchar2(1 char)                    null,
    argst                                        varchar2(1 char)                    null,
    sterm_done                                   varchar2(1 char)                    null,
    vse_frk                                      varchar2(1 char)                    null,
    kkalsm                                       varchar2(6 char)                    null,
    sdabw                                        varchar2(4 char)                    null,
    frkrl                                        varchar2(1 char)                    null,
    gesztd                                       number                              null,
    fahztd                                       number                              null,
    gesztda                                      number                              null,
    fahztda                                      number                              null,
    warztd                                       number                              null,
    warztda                                      number                              null,
    shtyp_bez                                    varchar2(20 char)                   null,
    bfart_bez                                    varchar2(20 char)                   null,
    vsart_bez                                    varchar2(20 char)                   null,
    laufk_bez                                    varchar2(20 char)                   null,
    vsbed_bez                                    varchar2(20 char)                   null,
    route_bez                                    varchar2(40 char)                   null,
    sttrg_bez                                    varchar2(20 char)                   null,
    fbsta_bez                                    varchar2(25 char)                   null,
    fbgst_bez                                    varchar2(25 char)                   null,
    arsta_bez                                    varchar2(25 char)                   null,
    argst_bez                                    varchar2(25 char)                   null,
    tndrst                                       varchar2(2 char)                    null,
    tndrrc                                       varchar2(2 char)                    null,
    tndr_text                                    varchar2(80 char)                   null,
    tndrdat                                      varchar2(8 char)                    null,
    tndrzet                                      varchar2(6 char)                    null,
    tndr_maxp                                    number                              null,
    tndr_maxc                                    varchar2(5 char)                    null,
    tndr_actp                                    number                              null,
    tndr_actc                                    varchar2(5 char)                    null,
    tndr_carr                                    varchar2(10 char)                   null,
    tndr_crnm                                    varchar2(35 char)                   null,
    tndr_trkid                                   varchar2(35 char)                   null,
    tndr_expd                                    varchar2(8 char)                    null,
    tndr_expt                                    varchar2(6 char)                    null,
    tndr_erpd                                    varchar2(8 char)                    null,
    tndr_erpt                                    varchar2(6 char)                    null,
    tndr_ltpd                                    varchar2(8 char)                    null,
    tndr_ltpt                                    varchar2(6 char)                    null,
    tndr_erdd                                    varchar2(8 char)                    null,
    tndr_erdt                                    varchar2(6 char)                    null,
    tndr_ltdd                                    varchar2(8 char)                    null,
    tndr_ltdt                                    varchar2(6 char)                    null,
    tndr_ldlg                                    number                              null,
    tndr_ldlu                                    varchar2(3 char)                    null,
    tndrst_bez                                   varchar2(60 char)                   null,
    tndrrc_bez                                   varchar2(60 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_shp_hdr is 'LADS Shipment Header';
comment on column lads_shp_hdr.tknum is 'Shipment Number';
comment on column lads_shp_hdr.shtyp is 'Shipment type';
comment on column lads_shp_hdr.abfer is 'Shipment completion type';
comment on column lads_shp_hdr.abwst is 'Processing control';
comment on column lads_shp_hdr.bfart is 'Service Level';
comment on column lads_shp_hdr.vsart is 'Shipping type';
comment on column lads_shp_hdr.laufk is 'Leg Indicator';
comment on column lads_shp_hdr.vsbed is 'Shipping conditions';
comment on column lads_shp_hdr.route is 'Shipment route';
comment on column lads_shp_hdr.signi is 'Voyage number';
comment on column lads_shp_hdr.exti1 is 'Vessel number';
comment on column lads_shp_hdr.exti2 is 'Container number';
comment on column lads_shp_hdr.tpbez is 'Description of Shipment';
comment on column lads_shp_hdr.sttrg is 'Overall transportation status';
comment on column lads_shp_hdr.pkstk is 'Shipment Contains Handling Units';
comment on column lads_shp_hdr.dtmeg is 'Unit of Weight for Transportation Planning';
comment on column lads_shp_hdr.dtmev is 'Volume Unit for Transportation Planning';
comment on column lads_shp_hdr.distz is 'Distance';
comment on column lads_shp_hdr.medst is 'Unit of measure for distance';
comment on column lads_shp_hdr.fahzt is 'Travelling time only between two locations';
comment on column lads_shp_hdr.geszt is 'Total travelling time between two locations incl. breaks';
comment on column lads_shp_hdr.meizt is 'Unit of measure for travelling times';
comment on column lads_shp_hdr.fbsta is 'Status of shipment costs calculation';
comment on column lads_shp_hdr.fbgst is 'Overall status of calculation of shipment costs for shipment';
comment on column lads_shp_hdr.arsta is 'Status of shipment costs settlement';
comment on column lads_shp_hdr.argst is 'Total status of shipment costs settlement for shipment';
comment on column lads_shp_hdr.sterm_done is 'Leg determination complete';
comment on column lads_shp_hdr.vse_frk is 'Handling Unit Data are Referred in Shipment Cost Document';
comment on column lads_shp_hdr.kkalsm is 'Pricing procedure in shipment header';
comment on column lads_shp_hdr.sdabw is 'Special processing indicator';
comment on column lads_shp_hdr.frkrl is 'Shipment costs relevance';
comment on column lads_shp_hdr.gesztd is 'Planned total time of transportation (in days)';
comment on column lads_shp_hdr.fahztd is 'Planned duration of transportation (in hours:minutes)';
comment on column lads_shp_hdr.gesztda is 'Actual total time of shipment (in days)';
comment on column lads_shp_hdr.fahztda is 'Actual time needed for transporation (in hours:minutes)';
comment on column lads_shp_hdr.warztd is 'Planned waiting time of shipment (in hours:minutes)';
comment on column lads_shp_hdr.warztda is 'Current waiting time of shipment (in hours:minutes)';
comment on column lads_shp_hdr.shtyp_bez is 'Description';
comment on column lads_shp_hdr.bfart_bez is 'Description';
comment on column lads_shp_hdr.vsart_bez is 'Description of the Shipping Type';
comment on column lads_shp_hdr.laufk_bez is 'Description';
comment on column lads_shp_hdr.vsbed_bez is 'Description of the shipping conditions';
comment on column lads_shp_hdr.route_bez is 'Description';
comment on column lads_shp_hdr.sttrg_bez is 'Description';
comment on column lads_shp_hdr.fbsta_bez is 'Description of status for calculation of shipment costs';
comment on column lads_shp_hdr.fbgst_bez is 'Overall status of calculation of shipment costs for shipment';
comment on column lads_shp_hdr.arsta_bez is 'Description for status of shipment costs settlement';
comment on column lads_shp_hdr.argst_bez is 'Descr.for overall status of settlm. of shipping costs';
comment on column lads_shp_hdr.tndrst is 'Tender Status';
comment on column lads_shp_hdr.tndrrc is 'Acceptance Condition/Rejection Reason';
comment on column lads_shp_hdr.tndr_text is 'Tendering Text';
comment on column lads_shp_hdr.tndrdat is 'Date of tender status';
comment on column lads_shp_hdr.tndrzet is 'Time of tender status';
comment on column lads_shp_hdr.tndr_maxp is 'Maximum Price for Shipment';
comment on column lads_shp_hdr.tndr_maxc is 'Currency of Maximum Price';
comment on column lads_shp_hdr.tndr_actp is 'Actual Shipment Costs for Shipment';
comment on column lads_shp_hdr.tndr_actc is 'Currency of Actual Shipment Costs';
comment on column lads_shp_hdr.tndr_carr is 'Forwarding Agent Who Accepted the Shipment';
comment on column lads_shp_hdr.tndr_crnm is 'Name of Carrier Who Accepted the Shipment';
comment on column lads_shp_hdr.tndr_trkid is 'Forwarding Agent Tracking ID';
comment on column lads_shp_hdr.tndr_expd is 'Date on Which Offer Expires';
comment on column lads_shp_hdr.tndr_expt is 'Time at Which Quotation Expires';
comment on column lads_shp_hdr.tndr_erpd is 'Earliest Pickup Date';
comment on column lads_shp_hdr.tndr_erpt is 'Earliest Pickup Time';
comment on column lads_shp_hdr.tndr_ltpd is 'Latest Pickup Date';
comment on column lads_shp_hdr.tndr_ltpt is 'Latest Pickup Time';
comment on column lads_shp_hdr.tndr_erdd is 'Earliest Delivery Date';
comment on column lads_shp_hdr.tndr_erdt is 'Earliest Delivery Time';
comment on column lads_shp_hdr.tndr_ltdd is 'Latest Delivery Date';
comment on column lads_shp_hdr.tndr_ltdt is 'Latest Delivery Time';
comment on column lads_shp_hdr.tndr_ldlg is 'Length of Loading Platform';
comment on column lads_shp_hdr.tndr_ldlu is 'Unit of Measure for Load Length';
comment on column lads_shp_hdr.tndrst_bez is 'Description of Tender Status';
comment on column lads_shp_hdr.tndrrc_bez is 'Description of Acceptance Condition / Rejection Reason';
comment on column lads_shp_hdr.idoc_name is 'IDOC name';
comment on column lads_shp_hdr.idoc_number is 'IDOC number';
comment on column lads_shp_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_shp_hdr.lads_date is 'LADS date loaded';
comment on column lads_shp_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_shp_hdr
   add constraint lads_shp_hdr_pk primary key (tknum);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_shp_hdr to lads_app;
grant select, insert, update, delete on lads_shp_hdr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_shp_hdr for lads.lads_shp_hdr;
