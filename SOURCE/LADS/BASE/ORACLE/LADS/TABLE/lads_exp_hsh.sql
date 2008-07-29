/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_hsh
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_hsh

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created
 2006/01   Linden Glen    ADD: shpmnt_status field

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_hsh
   (zzgrpnr                                      varchar2(40 char)                   not null,
    shpseq                                       number                              not null,
    hshseq                                       number                              not null,
    tknum                                        varchar2(10 char)                   null,
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
    vbeln                                        varchar2(10 char)                   null,
    shpmnt_status                                varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_exp_hsh is 'Generic ICB Document - Shipment data';
comment on column lads_exp_hsh.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_hsh.shpseq is 'SHP - generated sequence number';
comment on column lads_exp_hsh.hshseq is 'HSH - generated sequence number';
comment on column lads_exp_hsh.tknum is 'Shipment Number';
comment on column lads_exp_hsh.shtyp is 'Shipment type';
comment on column lads_exp_hsh.abfer is 'Shipment completion type';
comment on column lads_exp_hsh.abwst is 'Processing control';
comment on column lads_exp_hsh.bfart is 'Service Level';
comment on column lads_exp_hsh.vsart is 'Shipping type';
comment on column lads_exp_hsh.laufk is 'Leg Indicator';
comment on column lads_exp_hsh.vsbed is 'Shipping conditions';
comment on column lads_exp_hsh.route is 'Shipment route';
comment on column lads_exp_hsh.signi is 'Container ID';
comment on column lads_exp_hsh.exti1 is 'External identification 1';
comment on column lads_exp_hsh.exti2 is 'External identification 2';
comment on column lads_exp_hsh.tpbez is 'Description of Shipment';
comment on column lads_exp_hsh.sttrg is 'Overall transportation status';
comment on column lads_exp_hsh.pkstk is 'Shipment Contains Handling Units';
comment on column lads_exp_hsh.dtmeg is 'Unit of Weight for Transportation Planning';
comment on column lads_exp_hsh.dtmev is 'Volume Unit for Transportation Planning';
comment on column lads_exp_hsh.distz is 'Distance';
comment on column lads_exp_hsh.medst is 'Unit of measure for distance';
comment on column lads_exp_hsh.fahzt is 'Travelling time only between two locations';
comment on column lads_exp_hsh.geszt is 'Total travelling time between two locations incl. breaks';
comment on column lads_exp_hsh.meizt is 'Unit of measure for travelling times';
comment on column lads_exp_hsh.fbsta is 'Status of shipment costs calculation';
comment on column lads_exp_hsh.fbgst is 'Overall status of calculation of shipment costs for shipment';
comment on column lads_exp_hsh.arsta is 'Status of shipment costs settlement';
comment on column lads_exp_hsh.argst is 'Total status of shipment costs settlement for shipment';
comment on column lads_exp_hsh.sterm_done is 'Leg determination complete';
comment on column lads_exp_hsh.vse_frk is 'Handling Unit Data are Referred in Shipment Cost Document';
comment on column lads_exp_hsh.kkalsm is 'Pricing procedure in shipment header';
comment on column lads_exp_hsh.sdabw is 'Special processing indicator';
comment on column lads_exp_hsh.frkrl is 'Shipment costs relevance';
comment on column lads_exp_hsh.gesztd is 'Planned total time of transportation (in days)';
comment on column lads_exp_hsh.fahztd is 'Planned duration of transportation (in hours:minutes)';
comment on column lads_exp_hsh.gesztda is 'Actual total time of shipment (in days)';
comment on column lads_exp_hsh.fahztda is 'Actual time needed for transporation (in hours:minutes)';
comment on column lads_exp_hsh.warztd is 'Planned waiting time of shipment (in hours:minutes)';
comment on column lads_exp_hsh.warztda is 'Current waiting time of shipment (in hours:minutes)';
comment on column lads_exp_hsh.shtyp_bez is 'Description';
comment on column lads_exp_hsh.bfart_bez is 'Description';
comment on column lads_exp_hsh.vsart_bez is 'Description of the Shipping Type';
comment on column lads_exp_hsh.laufk_bez is 'Description';
comment on column lads_exp_hsh.vsbed_bez is 'Description of the shipping conditions';
comment on column lads_exp_hsh.route_bez is 'Description';
comment on column lads_exp_hsh.sttrg_bez is 'Description';
comment on column lads_exp_hsh.fbsta_bez is 'Description of status for calculation of shipment costs';
comment on column lads_exp_hsh.fbgst_bez is 'Overall status of calculation of shipment costs for shipment';
comment on column lads_exp_hsh.arsta_bez is 'Description for status of shipment costs settlement';
comment on column lads_exp_hsh.argst_bez is 'Descr.for overall status of settlm. of shipping costs';
comment on column lads_exp_hsh.tndrst is 'Tender Status';
comment on column lads_exp_hsh.tndrrc is 'Acceptance Condition/Rejection Reason';
comment on column lads_exp_hsh.tndr_text is 'Tendering Text';
comment on column lads_exp_hsh.tndrdat is 'Date of tender status';
comment on column lads_exp_hsh.tndrzet is 'Time of tender status';
comment on column lads_exp_hsh.tndr_maxp is 'Maximum Price for Shipment';
comment on column lads_exp_hsh.tndr_maxc is 'Currency of Maximum Price';
comment on column lads_exp_hsh.tndr_actp is 'Actual Shipment Costs for Shipment';
comment on column lads_exp_hsh.tndr_actc is 'Currency of Actual Shipment Costs';
comment on column lads_exp_hsh.tndr_carr is 'Forwarding Agent Who Accepted the Shipment';
comment on column lads_exp_hsh.tndr_crnm is 'Name of Carrier Who Accepted the Shipment';
comment on column lads_exp_hsh.tndr_trkid is 'Forwarding Agent Tracking ID';
comment on column lads_exp_hsh.tndr_expd is 'Date on Which Offer Expires';
comment on column lads_exp_hsh.tndr_expt is 'Time at Which Quotation Expires';
comment on column lads_exp_hsh.tndr_erpd is 'Earliest Pickup Date';
comment on column lads_exp_hsh.tndr_erpt is 'Earliest Pickup Time';
comment on column lads_exp_hsh.tndr_ltpd is 'Latest Pickup Date';
comment on column lads_exp_hsh.tndr_ltpt is 'Latest Pickup Time';
comment on column lads_exp_hsh.tndr_erdd is 'Earliest Delivery Date';
comment on column lads_exp_hsh.tndr_erdt is 'Earliest Delivery Time';
comment on column lads_exp_hsh.tndr_ltdd is 'Latest Delivery Date';
comment on column lads_exp_hsh.tndr_ltdt is 'Latest Delivery Time';
comment on column lads_exp_hsh.tndr_ldlg is 'Length of Loading Platform';
comment on column lads_exp_hsh.tndr_ldlu is 'Unit of Measure for Load Length';
comment on column lads_exp_hsh.tndrst_bez is 'Description of Tender Status';
comment on column lads_exp_hsh.tndrrc_bez is 'Description of Acceptance Condition / Rejection Reason';
comment on column lads_exp_hsh.shpmnt_status is 'Status of Shipment (1=active, 2=inactive - shipment exists in newer group)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_hsh
   add constraint lads_exp_hsh_pk primary key (zzgrpnr, shpseq, hshseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_hsh to lads_app;
grant select, insert, update, delete on lads_exp_hsh to ics_app;
grant select on lads_exp_hsh to ics_reader with grant option;
grant select on lads_exp_hsh to ics_executor;
grant select on lads_exp_hsh to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_hsh for lads.lads_exp_hsh;
