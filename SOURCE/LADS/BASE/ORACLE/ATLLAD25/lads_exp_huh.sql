/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_huh
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_huh

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_huh
   (zzgrpnr                                      varchar2(40 char)                   not null,
    delseq                                       number                              not null,
    hdeseq                                       number                              not null,
    huhseq                                       number                              not null,
    exidv                                        varchar2(20 char)                   null,
    tarag                                        number                              null,
    gweit                                        varchar2(3 char)                    null,
    brgew                                        number                              null,
    ntgew                                        number                              null,
    magew                                        number                              null,
    gweim                                        varchar2(3 char)                    null,
    btvol                                        number                              null,
    ntvol                                        number                              null,
    mavol                                        number                              null,
    volem                                        varchar2(3 char)                    null,
    tavol                                        number                              null,
    volet                                        varchar2(3 char)                    null,
    vegr2                                        varchar2(5 char)                    null,
    vegr1                                        varchar2(5 char)                    null,
    vegr3                                        varchar2(5 char)                    null,
    vhilm                                        varchar2(18 char)                   null,
    vegr4                                        varchar2(5 char)                    null,
    laeng                                        number                              null,
    vegr5                                        varchar2(5 char)                    null,
    breit                                        number                              null,
    hoehe                                        number                              null,
    meabm                                        varchar2(3 char)                    null,
    inhalt                                       varchar2(40 char)                   null,
    vhart                                        varchar2(4 char)                    null,
    magrv                                        varchar2(4 char)                    null,
    ladlg                                        number                              null,
    ladeh                                        varchar2(3 char)                    null,
    farzt                                        number                              null,
    fareh                                        varchar2(3 char)                    null,
    entfe                                        number                              null,
    ehent                                        varchar2(3 char)                    null,
    veltp                                        varchar2(1 char)                    null,
    exidv2                                       varchar2(20 char)                   null,
    landt                                        varchar2(3 char)                    null,
    landf                                        varchar2(3 char)                    null,
    namef                                        varchar2(35 char)                   null,
    nambe                                        varchar2(35 char)                   null,
    vhilm_ku                                     varchar2(22 char)                   null,
    vebez                                        varchar2(40 char)                   null,
    smgkn                                        varchar2(1 char)                    null,
    kdmat35                                      varchar2(35 char)                   null,
    sortl                                        varchar2(10 char)                   null,
    ernam                                        varchar2(12 char)                   null,
    gewfx                                        varchar2(1 char)                    null,
    erlkz                                        varchar2(1 char)                    null,
    exida                                        varchar2(1 char)                    null,
    move_status                                  varchar2(4 char)                    null,
    packvorschr                                  varchar2(22 char)                   null,
    packvorschr_st                               varchar2(1 char)                    null,
    labeltyp                                     varchar2(1 char)                    null,
    zul_aufl                                     varchar2(17 char)                   null,
    vhilm_external                               varchar2(40 char)                   null,
    vhilm_version                                varchar2(10 char)                   null,
    vhilm_guid                                   varchar2(32 char)                   null,
    vegr1_bez                                    varchar2(20 char)                   null,
    vegr2_bez                                    varchar2(20 char)                   null,
    vegr3_bez                                    varchar2(20 char)                   null,
    vegr4_bez                                    varchar2(20 char)                   null,
    vegr5_bez                                    varchar2(20 char)                   null,
    vhart_bez                                    varchar2(20 char)                   null,
    magrv_bez                                    varchar2(20 char)                   null,
    vebez1                                       varchar2(40 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_huh is 'Generic ICB Document - Delivery data';
comment on column lads_exp_huh.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_huh.delseq is 'DEL - generated sequence number';
comment on column lads_exp_huh.hdeseq is 'HDE - generated sequence number';
comment on column lads_exp_huh.huhseq is 'HUH - generated sequence number';
comment on column lads_exp_huh.exidv is 'External Handling Unit Identification';
comment on column lads_exp_huh.tarag is 'Tare weight of handling unit';
comment on column lads_exp_huh.gweit is 'Weight Unit Tare';
comment on column lads_exp_huh.brgew is 'Total Weight of Handling Unit';
comment on column lads_exp_huh.ntgew is 'Loading Weight of Handling Unit';
comment on column lads_exp_huh.magew is 'Allowed Loading Weight of a Handling Unit';
comment on column lads_exp_huh.gweim is 'Weight Unit';
comment on column lads_exp_huh.btvol is 'Total Volume of Handling Unit';
comment on column lads_exp_huh.ntvol is 'Loading Volume of Handling Unit';
comment on column lads_exp_huh.mavol is 'Allowed Loading Volume for Handling Unit';
comment on column lads_exp_huh.volem is 'Volume unit';
comment on column lads_exp_huh.tavol is 'Tare volume of handling unit';
comment on column lads_exp_huh.volet is 'Volume Unit Tare';
comment on column lads_exp_huh.vegr2 is 'Handling Unit Group 2                     (Freely Definable)';
comment on column lads_exp_huh.vegr1 is 'Handling Unit Group 1                     (Freely Definable)';
comment on column lads_exp_huh.vegr3 is 'Handling Unit Group 3                     (Freely Definable)';
comment on column lads_exp_huh.vhilm is 'Packaging Materials';
comment on column lads_exp_huh.vegr4 is 'Handling Unit Group 4                     (Freely Definable)';
comment on column lads_exp_huh.laeng is 'Length';
comment on column lads_exp_huh.vegr5 is 'Handling Unit Group 5                     (Freely Definable)';
comment on column lads_exp_huh.breit is 'Width';
comment on column lads_exp_huh.hoehe is 'Height';
comment on column lads_exp_huh.meabm is 'Unit of dimension for length/width/height';
comment on column lads_exp_huh.inhalt is 'Description of Handling Unit Content';
comment on column lads_exp_huh.vhart is 'Packaging Material Type';
comment on column lads_exp_huh.magrv is 'Material Group: Packaging Materials';
comment on column lads_exp_huh.ladlg is 'Lgth of loading platform in lgth of LdPlat measurement units';
comment on column lads_exp_huh.ladeh is 'Unit of measure to measure the length of loading platform';
comment on column lads_exp_huh.farzt is 'Travel Time';
comment on column lads_exp_huh.fareh is 'Unit of travel time';
comment on column lads_exp_huh.entfe is 'Distance Travelled';
comment on column lads_exp_huh.ehent is 'Unit of distance';
comment on column lads_exp_huh.veltp is 'Packaging Material Category';
comment on column lads_exp_huh.exidv2 is 'Handling Unit''s 2nd External Identification';
comment on column lads_exp_huh.landt is 'Country providing means of transport';
comment on column lads_exp_huh.landf is 'Driver''s Nationality';
comment on column lads_exp_huh.namef is 'Driver name';
comment on column lads_exp_huh.nambe is 'Alternate Driver''s Name';
comment on column lads_exp_huh.vhilm_ku is 'Material belonging to the customer';
comment on column lads_exp_huh.vebez is 'Description of Packaging Material';
comment on column lads_exp_huh.smgkn is 'SMG identification for material tag';
comment on column lads_exp_huh.kdmat35 is 'Partner''s (Customer's or Vendor's) Packaging Material';
comment on column lads_exp_huh.sortl is 'Sort field';
comment on column lads_exp_huh.ernam is 'Name of Person who Created the Object';
comment on column lads_exp_huh.gewfx is 'Weight and Volume Fixed';
comment on column lads_exp_huh.erlkz is 'Status (at this time without functionality)';
comment on column lads_exp_huh.exida is 'Type of External Handling Unit Identifier';
comment on column lads_exp_huh.move_status is 'Handling unit status';
comment on column lads_exp_huh.packvorschr is 'Text string 22 characters';
comment on column lads_exp_huh.packvorschr_st is 'Single-character flag';
comment on column lads_exp_huh.labeltyp is 'Indicator: do not print external shipping label';
comment on column lads_exp_huh.zul_aufl is 'Field length 17';
comment on column lads_exp_huh.vhilm_external is 'Long material number (future development) for field VHILM';
comment on column lads_exp_huh.vhilm_version is 'Version number (future development) for field VHILM';
comment on column lads_exp_huh.vhilm_guid is 'External GUID (future development) for field VHILM';
comment on column lads_exp_huh.vegr1_bez is 'Description of shipping unit 1';
comment on column lads_exp_huh.vegr2_bez is 'Description of shipping unit 2';
comment on column lads_exp_huh.vegr3_bez is 'Description of shipping unit 3';
comment on column lads_exp_huh.vegr4_bez is 'Description of shipping unit 4';
comment on column lads_exp_huh.vegr5_bez is 'Description of shipping unit 5';
comment on column lads_exp_huh.vhart_bez is 'Description of shipping material type';
comment on column lads_exp_huh.magrv_bez is 'Description of material grouping shipping material';
comment on column lads_exp_huh.vebez1 is 'Description of Packaging Material';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_huh
   add constraint lads_exp_huh_pk primary key (zzgrpnr, delseq, hdeseq, huhseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_huh to lads_app;
grant select, insert, update, delete on lads_exp_huh to ics_app;
grant select on lads_exp_huh to ics_reader with grant option;
grant select on lads_exp_huh to ics_executor;
grant select on lads_exp_huh to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_huh for lads.lads_exp_huh;
