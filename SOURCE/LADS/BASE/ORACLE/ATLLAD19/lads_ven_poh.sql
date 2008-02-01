/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_poh
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_poh

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_poh
   (lifnr                                        varchar2(10 char)                   not null,
    pohseq                                       number                              not null,
    ekorg                                        varchar2(6 char)                    null,
    erdat                                        varchar2(8 char)                    null,
    ernam                                        varchar2(12 char)                   null,
    sperm                                        varchar2(1 char)                    null,
    loevm                                        varchar2(1 char)                    null,
    lfabc                                        varchar2(1 char)                    null,
    waers                                        varchar2(5 char)                    null,
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
    boind                                        varchar2(1 char)                    null,
    prfre                                        varchar2(1 char)                    null,
    nrgew                                        varchar2(1 char)                    null,
    blind                                        varchar2(1 char)                    null,
    kzret                                        varchar2(1 char)                    null,
    skrit                                        varchar2(1 char)                    null,
    bstae                                        varchar2(4 char)                    null,
    rdprf                                        varchar2(4 char)                    null,
    megru                                        varchar2(4 char)                    null,
    vensl                                        number                              null,
    bopnr                                        varchar2(4 char)                    null,
    xersr                                        varchar2(1 char)                    null,
    eikto                                        varchar2(12 char)                   null,
    paprf                                        varchar2(4 char)                    null,
    agrel                                        varchar2(1 char)                    null,
    xnbwy                                        varchar2(1 char)                    null,
    vsbed                                        varchar2(2 char)                    null,
    lebre                                        varchar2(1 char)                    null,
    minbw2                                       varchar2(16 char)                   null);

/**/
/* Comments
/**/
comment on table lads_ven_poh is 'LADS Vendor Purchasing';
comment on column lads_ven_poh.lifnr is 'Account Number of the Vendor';
comment on column lads_ven_poh.pohseq is 'POH - generated sequence number';
comment on column lads_ven_poh.ekorg is 'Purchasing Organization';
comment on column lads_ven_poh.erdat is 'Date on which the record was created';
comment on column lads_ven_poh.ernam is 'Name of Person who Created the Object';
comment on column lads_ven_poh.sperm is 'Purchasing block at purchasing organization level';
comment on column lads_ven_poh.loevm is 'Delete flag for vendor at purchasing level';
comment on column lads_ven_poh.lfabc is 'ABC indicator';
comment on column lads_ven_poh.waers is 'Purchase order currency';
comment on column lads_ven_poh.verkf is 'Responsible salesperson at vendors office';
comment on column lads_ven_poh.telf1 is 'Vendors telephone number';
comment on column lads_ven_poh.minbw is 'Minimum order value';
comment on column lads_ven_poh.zterm is 'Terms of payment key';
comment on column lads_ven_poh.inco1 is 'Incoterms (part 1)';
comment on column lads_ven_poh.inco2 is 'Incoterms (part 2)';
comment on column lads_ven_poh.webre is 'Indicator: GR-based invoice verification';
comment on column lads_ven_poh.kzabs is 'Order acknowledgment requirement';
comment on column lads_ven_poh.kalsk is 'Group for calculation schema (vendor)';
comment on column lads_ven_poh.kzaut is 'Automatic generation of purchase order allowed';
comment on column lads_ven_poh.expvz is 'Mode of Transport for Foreign Trade';
comment on column lads_ven_poh.zolla is 'Customs office: Office of exit for foreign trade';
comment on column lads_ven_poh.meprf is 'Pricing date category (controls date of price determination)';
comment on column lads_ven_poh.ekgrp is 'Purchasing Group';
comment on column lads_ven_poh.bolre is 'Indicator: vendor subject to subseq. settlement accounting';
comment on column lads_ven_poh.umsae is 'Comparison/agreement of business volumes necessary';
comment on column lads_ven_poh.xersy is 'Evaluated Receipt Settlement (ERS)';
comment on column lads_ven_poh.plifz is 'Planned delivery time in days';
comment on column lads_ven_poh.mrppp is 'Planning calendar';
comment on column lads_ven_poh.lfrhy is 'Planning cycle';
comment on column lads_ven_poh.liefr is 'Delivery cycle';
comment on column lads_ven_poh.libes is 'Order entry by vendor';
comment on column lads_ven_poh.lipre is '"Price marking, vendor"';
comment on column lads_ven_poh.liser is 'Rack-jobbing: vendor';
comment on column lads_ven_poh.boind is 'Indicator: index compilation for subseq. settlement active';
comment on column lads_ven_poh.prfre is '"Indicator: ""relev. to price determination (vend. hierarchy)"';
comment on column lads_ven_poh.nrgew is 'Indicator whether discount in kind granted';
comment on column lads_ven_poh.blind is 'Indicator: Doc. index compilation active for purchase orders';
comment on column lads_ven_poh.kzret is 'Indicates whether vendor is returns vendor';
comment on column lads_ven_poh.skrit is 'Vendor sort criterion for materials';
comment on column lads_ven_poh.bstae is 'Confirmation control key';
comment on column lads_ven_poh.rdprf is 'Rounding profile';
comment on column lads_ven_poh.megru is 'Unit of measure group';
comment on column lads_ven_poh.vensl is 'Vendor service level';
comment on column lads_ven_poh.bopnr is 'Restriction Profile for PO-Based Load Building';
comment on column lads_ven_poh.xersr is 'Automatic evaluated receipt settlement for return items';
comment on column lads_ven_poh.eikto is 'Our account number with the vendor';
comment on column lads_ven_poh.paprf is 'Profile for transferring material data via IDoc PROACT';
comment on column lads_ven_poh.agrel is 'Indicator: Relevant for agency business';
comment on column lads_ven_poh.xnbwy is 'Revaluation allowed';
comment on column lads_ven_poh.vsbed is 'Shipping conditions';
comment on column lads_ven_poh.lebre is 'Indicator for service-based invoice verification';
comment on column lads_ven_poh.minbw2 is 'Minimum order value (batch input field)';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_poh
   add constraint lads_ven_poh_pk primary key (lifnr, pohseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_poh to lads_app;
grant select, insert, update, delete on lads_ven_poh to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_poh for lads.lads_ven_poh;
