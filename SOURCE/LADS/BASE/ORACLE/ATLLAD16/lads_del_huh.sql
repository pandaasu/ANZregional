/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_del_huh
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_del_huh

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_del_huh
   (vbeln                                        varchar2(10 char)                   not null,
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
comment on table lads_del_huh is 'LADS Delivery Handling Unit Header';
comment on column lads_del_huh.vbeln is 'Sales and Distribution Document Number';
comment on column lads_del_huh.huhseq is 'HUH - generated sequence number';
comment on column lads_del_huh.exidv is 'External Handling Unit Identification';
comment on column lads_del_huh.tarag is 'Tare weight of handling unit';
comment on column lads_del_huh.gweit is 'Weight Unit Tare';
comment on column lads_del_huh.brgew is 'Total Weight of Handling Unit';
comment on column lads_del_huh.ntgew is 'Loading Weight of Handling Unit';
comment on column lads_del_huh.magew is 'Allowed Loading Weight of a Handling Unit';
comment on column lads_del_huh.gweim is 'Weight Unit';
comment on column lads_del_huh.btvol is 'Total Volume of Handling Unit';
comment on column lads_del_huh.ntvol is 'Loading Volume of Handling Unit';
comment on column lads_del_huh.mavol is 'Allowed Loading Volume for Handling Unit';
comment on column lads_del_huh.volem is 'Volume unit';
comment on column lads_del_huh.tavol is 'Tare volume of handling unit';
comment on column lads_del_huh.volet is 'Volume Unit Tare';
comment on column lads_del_huh.vegr2 is 'Handling Unit Group 2                     (Freely Definable)';
comment on column lads_del_huh.vegr1 is 'Handling Unit Group 1                     (Freely Definable)';
comment on column lads_del_huh.vegr3 is 'Handling Unit Group 3                     (Freely Definable)';
comment on column lads_del_huh.vhilm is 'Packaging Materials';
comment on column lads_del_huh.vegr4 is 'Handling Unit Group 4                     (Freely Definable)';
comment on column lads_del_huh.laeng is 'Length';
comment on column lads_del_huh.vegr5 is 'Handling Unit Group 5                     (Freely Definable)';
comment on column lads_del_huh.breit is 'Width';
comment on column lads_del_huh.hoehe is 'Height';
comment on column lads_del_huh.meabm is 'Unit of dimension for length/width/height';
comment on column lads_del_huh.inhalt is 'Seal number';
comment on column lads_del_huh.vhart is 'Packaging Material Type';
comment on column lads_del_huh.magrv is 'Material Group: Packaging Materials';
comment on column lads_del_huh.ladlg is 'Lgth of loading platform in lgth of LdPlat measurement units';
comment on column lads_del_huh.ladeh is 'Unit of measure to measure the length of loading platform';
comment on column lads_del_huh.farzt is 'Travel Time';
comment on column lads_del_huh.fareh is 'Unit of travel time';
comment on column lads_del_huh.entfe is 'Distance Travelled';
comment on column lads_del_huh.ehent is 'Unit of distance';
comment on column lads_del_huh.veltp is 'Packaging Material Category';
comment on column lads_del_huh.exidv2 is 'Handling Units 2nd External Identification';
comment on column lads_del_huh.landt is 'Country providing means of transport';
comment on column lads_del_huh.landf is 'Drivers Nationality';
comment on column lads_del_huh.namef is 'Driver name';
comment on column lads_del_huh.nambe is 'Alternate Drivers Name';
comment on column lads_del_huh.vhilm_ku is 'Material belonging to the customer';
comment on column lads_del_huh.vebez is 'Description of Packaging Material';
comment on column lads_del_huh.smgkn is 'SMG identification for material tag';
comment on column lads_del_huh.kdmat35 is 'Partners (Customers or Vendors) Packaging Material';
comment on column lads_del_huh.sortl is 'Sort field';
comment on column lads_del_huh.ernam is 'Name of Person who Created the Object';
comment on column lads_del_huh.gewfx is 'Weight and Volume Fixed';
comment on column lads_del_huh.erlkz is 'Status (at this time without functionality)';
comment on column lads_del_huh.exida is 'Type of External Handling Unit Identifier';
comment on column lads_del_huh.move_status is 'Handling unit status';
comment on column lads_del_huh.packvorschr is 'Text string 22 characters';
comment on column lads_del_huh.packvorschr_st is 'Single-character flag';
comment on column lads_del_huh.labeltyp is 'Indicator: do not print external shipping label';
comment on column lads_del_huh.zul_aufl is 'Field length 17';
comment on column lads_del_huh.vhilm_external is 'Long material number (future development) for field VHILM';
comment on column lads_del_huh.vhilm_version is 'Version number (future development) for field VHILM';
comment on column lads_del_huh.vhilm_guid is 'External GUID (future development) for field VHILM';
comment on column lads_del_huh.vegr1_bez is 'Description of shipping unit 1';
comment on column lads_del_huh.vegr2_bez is 'Description of shipping unit 2';
comment on column lads_del_huh.vegr3_bez is 'Description of shipping unit 3';
comment on column lads_del_huh.vegr4_bez is 'Description of shipping unit 4';
comment on column lads_del_huh.vegr5_bez is 'Description of shipping unit 5';
comment on column lads_del_huh.vhart_bez is 'Description of shipping material type';
comment on column lads_del_huh.magrv_bez is 'Description of material grouping shipping material';
comment on column lads_del_huh.vebez1 is 'Description of Packaging Material';

/**/
/* Primary Key Constraint
/**/
alter table lads_del_huh
   add constraint lads_del_huh_pk primary key (vbeln, huhseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_del_huh to lads_app;
grant select, insert, update, delete on lads_del_huh to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_del_huh for lads.lads_del_huh;
