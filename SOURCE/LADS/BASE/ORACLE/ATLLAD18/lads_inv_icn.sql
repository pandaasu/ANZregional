/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_icn
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_icn

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_icn
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
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
comment on table lads_inv_icn is 'LADS Invoice Item Condition';
comment on column lads_inv_icn.belnr is 'IDOC document number';
comment on column lads_inv_icn.genseq is 'GEN - generated sequence number';
comment on column lads_inv_icn.icnseq is 'ICN - generated sequence number';
comment on column lads_inv_icn.alckz is 'Surcharge or discount indicator';
comment on column lads_inv_icn.kschl is 'Condition type (coded)';
comment on column lads_inv_icn.kotxt is 'Condition text';
comment on column lads_inv_icn.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_inv_icn.kperc is 'Condition percentage rate';
comment on column lads_inv_icn.krate is 'Condition record per unit';
comment on column lads_inv_icn.uprbs is 'Price unit';
comment on column lads_inv_icn.meaun is 'Unit of measurement';
comment on column lads_inv_icn.kobtr is 'IDoc condition end amount';
comment on column lads_inv_icn.menge is 'Price scale quantity (SPEC2000)';
comment on column lads_inv_icn.preis is 'Price by unit of measure (SPEC2000)';
comment on column lads_inv_icn.mwskz is 'VAT indicator';
comment on column lads_inv_icn.msatz is 'VAT rate';
comment on column lads_inv_icn.koein is 'Currency';
comment on column lads_inv_icn.curtp is 'Currency Type And Valuation View';
comment on column lads_inv_icn.kobas is 'Base value to which condition refers';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_icn
   add constraint lads_inv_icn_pk primary key (belnr, genseq, icnseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_icn to lads_app;
grant select, insert, update, delete on lads_inv_icn to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_icn for lads.lads_inv_icn;
