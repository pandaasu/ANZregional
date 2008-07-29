/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_pom
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_pom

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_pom
   (lifnr                                        varchar2(10 char)                   not null,
    pohseq                                       number                              not null,
    pomseq                                       number                              not null,
    ltsnr                                        varchar2(6 char)                    null,
    werks                                        varchar2(6 char)                    null,
    erdat                                        varchar2(8 char)                    null,
    ernam                                        varchar2(12 char)                   null,
    sperm                                        varchar2(1 char)                    null,
    loevm                                        varchar2(1 char)                    null,
    lfabc                                        varchar2(1 char)                    null,
    waers                                        varchar2(13 char)                   null,
    verkf                                        varchar2(30 char)                   null,
    telf1                                        varchar2(16 char)                   null,
    minbw                                        number                              null,
    zterm                                        varchar2(4 char)                    null,
    inco1                                        varchar2(3 char)                    null,
    inco2                                        varchar2(28 char)                   null,
    webre                                        varchar2(1 char)                    null,
    kzabs                                        varchar2(1 char)                    null,
    kalsk                                        varchar2(2 char)                    null,
    kzaut                                        varchar2(1 char)                    null,
    expvz                                        varchar2(1 char)                    null,
    zolla                                        varchar2(6 char)                    null,
    meprf                                        varchar2(1 char)                    null,
    ekgrp                                        varchar2(3 char)                    null,
    bolre                                        varchar2(1 char)                    null,
    umsae                                        varchar2(1 char)                    null,
    xersy                                        varchar2(1 char)                    null,
    plifz                                        number                              null,
    mrppp                                        varchar2(3 char)                    null,
    lfrhy                                        varchar2(3 char)                    null,
    liefr                                        varchar2(4 char)                    null,
    libes                                        varchar2(1 char)                    null,
    lipre                                        varchar2(2 char)                    null,
    liser                                        varchar2(1 char)                    null,
    dispo                                        varchar2(3 char)                    null,
    bstae                                        varchar2(4 char)                    null,
    rdprf                                        varchar2(4 char)                    null,
    megru                                        varchar2(4 char)                    null,
    bopnr                                        varchar2(4 char)                    null,
    xersr                                        varchar2(1 char)                    null,
    abueb                                        varchar2(4 char)                    null,
    paprf                                        varchar2(4 char)                    null,
    xnbwy                                        varchar2(1 char)                    null,
    lebre                                        varchar2(1 char)                    null,
    minbw2                                       varchar2(16 char)                   null);

/**/
/* Comments
/**/
comment on table lads_ven_pom is 'LADS Vendor Purchasing MMS';
comment on column lads_ven_pom.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_pom.pohseq is 'POH - generated sequence number';
comment on column lads_ven_pom.pomseq is 'POM - generated sequence number';
comment on column lads_ven_pom.ltsnr is 'Vendor Sub-Range';
comment on column lads_ven_pom.werks is 'Plant';
comment on column lads_ven_pom.erdat is 'Date on which the record was created';
comment on column lads_ven_pom.ernam is 'Name of Person who Created the Object';
comment on column lads_ven_pom.sperm is 'Purchasing block at purchasing organization level';
comment on column lads_ven_pom.loevm is 'Deletion indicator';
comment on column lads_ven_pom.lfabc is 'ABC indicator';
comment on column lads_ven_pom.waers is 'Purchase order currency';
comment on column lads_ven_pom.verkf is 'Responsible salesperson at vendors office';
comment on column lads_ven_pom.telf1 is 'Vendors telephone number';
comment on column lads_ven_pom.minbw is 'Minimum order value';
comment on column lads_ven_pom.zterm is 'Terms of payment key';
comment on column lads_ven_pom.inco1 is 'Incoterms (part 1)';
comment on column lads_ven_pom.inco2 is 'Incoterms (part 2)';
comment on column lads_ven_pom.webre is 'Indicator: GR-based invoice verification';
comment on column lads_ven_pom.kzabs is 'Order acknowledgment requirement';
comment on column lads_ven_pom.kalsk is 'Group for calculation schema (vendor)';
comment on column lads_ven_pom.kzaut is 'Automatic generation of purchase order allowed';
comment on column lads_ven_pom.expvz is 'Mode of Transport for Foreign Trade';
comment on column lads_ven_pom.zolla is 'Customs office: Office of exit for foreign trade';
comment on column lads_ven_pom.meprf is 'Pricing date category (controls date of price determination)';
comment on column lads_ven_pom.ekgrp is 'Purchasing Group';
comment on column lads_ven_pom.bolre is 'Indicator: vendor subject to subseq. settlement accounting';
comment on column lads_ven_pom.umsae is 'Comparison/agreement of business volumes necessary';
comment on column lads_ven_pom.xersy is 'Evaluated Receipt Settlement (ERS)';
comment on column lads_ven_pom.plifz is 'Planned delivery time in days';
comment on column lads_ven_pom.mrppp is 'Planning calendar';
comment on column lads_ven_pom.lfrhy is 'Planning cycle';
comment on column lads_ven_pom.liefr is 'Delivery cycle';
comment on column lads_ven_pom.libes is 'Order entry by vendor';
comment on column lads_ven_pom.lipre is '"Price marking, vendor"';
comment on column lads_ven_pom.liser is 'Rack-jobbing: vendor';
comment on column lads_ven_pom.dispo is 'MRP Controller';
comment on column lads_ven_pom.bstae is 'Confirmation control key';
comment on column lads_ven_pom.rdprf is 'Rounding profile';
comment on column lads_ven_pom.megru is 'Unit of measure group';
comment on column lads_ven_pom.bopnr is 'Restriction Profile for PO-Based Load Building';
comment on column lads_ven_pom.xersr is 'Automatic evaluated receipt settlement for return items';
comment on column lads_ven_pom.abueb is 'Release creation profile';
comment on column lads_ven_pom.paprf is 'Profile for transferring material data via IDoc PROACT';
comment on column lads_ven_pom.xnbwy is 'Revaluation allowed';
comment on column lads_ven_pom.lebre is 'Indicator for service-based invoice verification';
comment on column lads_ven_pom.minbw2 is 'Minimum order value (batch input field)';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_pom
   add constraint lads_ven_pom_pk primary key (lifnr, pohseq, pomseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_pom to lads_app;
grant select, insert, update, delete on lads_ven_pom to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_pom for lads.lads_ven_pom;
