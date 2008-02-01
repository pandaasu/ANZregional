/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_icn
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_icn

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_icn
   (zzgrpnr                                      varchar2(40 char)                   not null,
    invseq                                       number                              not null,
    hinseq                                       number                              not null,
    ignseq                                       number                              not null,
    icnseq                                       number                              not null,
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
comment on table lads_exp_icn is 'Generic ICB Document - Invoice data';
comment on column lads_exp_icn.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_icn.invseq is 'INV - generated sequence number';
comment on column lads_exp_icn.hinseq is 'HIN - generated sequence number';
comment on column lads_exp_icn.ignseq is 'IGN - generated sequence number';
comment on column lads_exp_icn.icnseq is 'ICN - generated sequence number';
comment on column lads_exp_icn.alckz is 'Surcharge or discount indicator';
comment on column lads_exp_icn.kschl is 'Condition type (coded)';
comment on column lads_exp_icn.kotxt is 'Condition text';
comment on column lads_exp_icn.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_exp_icn.kperc is 'Condition percentage rate';
comment on column lads_exp_icn.krate is 'Condition record per unit';
comment on column lads_exp_icn.uprbs is 'Price unit';
comment on column lads_exp_icn.meaun is 'Unit of measurement';
comment on column lads_exp_icn.kobtr is 'IDoc condition end amount';
comment on column lads_exp_icn.menge is 'Price scale quantity (SPEC2000)';
comment on column lads_exp_icn.preis is 'Price by unit of measure (SPEC2000)';
comment on column lads_exp_icn.mwskz is 'VAT indicator';
comment on column lads_exp_icn.msatz is 'VAT rate';
comment on column lads_exp_icn.koein is 'Currency';
comment on column lads_exp_icn.curtp is 'Currency Type And Valuation View';
comment on column lads_exp_icn.kobas is 'Base value to which condition refers';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_icn
   add constraint lads_exp_icn_pk primary key (zzgrpnr, invseq, hinseq, ignseq, icnseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_icn to lads_app;
grant select, insert, update, delete on lads_exp_icn to ics_app;
grant select on lads_exp_icn to ics_reader with grant option;
grant select on lads_exp_icn to ics_executor;
grant select on lads_exp_icn to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_icn for lads.lads_exp_icn;
