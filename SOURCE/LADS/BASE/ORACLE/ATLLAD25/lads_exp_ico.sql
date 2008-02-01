/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_ico
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_ico

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_ico
   (zzgrpnr                                      varchar2(40 char)                   not null,
    ordseq                                       number                              not null,
    horseq                                       number                              not null,
    genseq                                       number                              not null,
    icoseq                                       number                              not null,
    alckz                                        varchar2(3 char)                    null,
    kschl                                        varchar2(4 char)                    null,
    kotxt                                        varchar2(80 char)                   null,
    betrg                                        varchar2(18 char)                   null,
    kperc                                        varchar2(8 char)                    null,
    krate                                        varchar2(15 char)                   null,
    uprbs                                        varchar2(9 char)                    null,
    meaun                                        varchar2(3 char)                    null,
    kobtr                                        varchar2(18 char)                   null,
    menge                                        varchar2(15 char)                   null,
    preis                                        varchar2(15 char)                   null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    koein                                        varchar2(3 char)                    null,
    curtp                                        varchar2(2 char)                    null,
    kobas                                        varchar2(18 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_ico is 'Generic ICB Document - Order data';
comment on column lads_exp_ico.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_ico.ordseq is 'ORD - generated sequence number';
comment on column lads_exp_ico.horseq is 'HOR - generated sequence number';
comment on column lads_exp_ico.genseq is 'GEN - generated sequence number';
comment on column lads_exp_ico.icoseq is 'ICO - generated sequence number';
comment on column lads_exp_ico.alckz is 'Surcharge or discount indicator';
comment on column lads_exp_ico.kschl is 'Condition type (coded)';
comment on column lads_exp_ico.kotxt is 'Condition text';
comment on column lads_exp_ico.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_exp_ico.kperc is 'Condition percentage rate';
comment on column lads_exp_ico.krate is 'Condition record per unit';
comment on column lads_exp_ico.uprbs is 'Price unit';
comment on column lads_exp_ico.meaun is 'Unit of measurement';
comment on column lads_exp_ico.kobtr is 'IDoc condition end amount';
comment on column lads_exp_ico.menge is 'Price scale quantity (SPEC2000)';
comment on column lads_exp_ico.preis is 'Price by unit of measure (SPEC2000)';
comment on column lads_exp_ico.mwskz is 'VAT indicator';
comment on column lads_exp_ico.msatz is 'VAT rate';
comment on column lads_exp_ico.koein is 'Currency';
comment on column lads_exp_ico.curtp is 'Currency Type And Valuation View';
comment on column lads_exp_ico.kobas is 'Base value to which condition refers';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_ico
   add constraint lads_exp_ico_pk primary key (zzgrpnr, ordseq, horseq, genseq, icoseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_ico to lads_app;
grant select, insert, update, delete on lads_exp_ico to ics_app;
grant select on lads_exp_ico to ics_reader with grant option;
grant select on lads_exp_ico to ics_executor;
grant select on lads_exp_ico to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_ico for lads.lads_exp_ico;
