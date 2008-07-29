/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_ico
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_ico

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_ico
   (belnr                                        varchar2(35 char)                   not null,
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
comment on table lads_sal_ord_ico is 'LADS Sales Order Item Condition';
comment on column lads_sal_ord_ico.belnr is 'Document number';
comment on column lads_sal_ord_ico.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_ico.icoseq is 'ICO - generated sequence number';
comment on column lads_sal_ord_ico.alckz is 'Surcharge or discount indicator';
comment on column lads_sal_ord_ico.kschl is 'Condition type (coded)';
comment on column lads_sal_ord_ico.kotxt is 'Condition text';
comment on column lads_sal_ord_ico.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_sal_ord_ico.kperc is 'Condition percentage rate';
comment on column lads_sal_ord_ico.krate is 'Condition record per unit';
comment on column lads_sal_ord_ico.uprbs is 'Price unit';
comment on column lads_sal_ord_ico.meaun is 'Unit of measurement';
comment on column lads_sal_ord_ico.kobtr is 'IDoc condition end amount';
comment on column lads_sal_ord_ico.menge is 'Price scale quantity (SPEC2000)';
comment on column lads_sal_ord_ico.preis is 'Price by unit of measure (SPEC2000)';
comment on column lads_sal_ord_ico.mwskz is 'VAT indicator';
comment on column lads_sal_ord_ico.msatz is 'VAT rate';
comment on column lads_sal_ord_ico.koein is 'Currency';
comment on column lads_sal_ord_ico.curtp is 'Currency Type And Valuation View';
comment on column lads_sal_ord_ico.kobas is 'Base value to which condition refers';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_ico
   add constraint lads_sal_ord_ico_pk primary key (belnr, genseq, icoseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_ico to lads_app;
grant select, insert, update, delete on lads_sal_ord_ico to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_ico for lads.lads_sal_ord_ico;
