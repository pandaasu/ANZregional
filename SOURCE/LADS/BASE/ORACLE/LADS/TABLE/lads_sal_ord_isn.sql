/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isn
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isn

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isn
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isnseq                                       number                              not null,
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
    msatz                                        varchar2(17 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isn is 'LADS Sales Order Item Service Specification Condition';
comment on column lads_sal_ord_isn.belnr is 'Document number';
comment on column lads_sal_ord_isn.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isn.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isn.isnseq is 'ISN - generated sequence number';
comment on column lads_sal_ord_isn.alckz is 'Surcharge or discount indicator';
comment on column lads_sal_ord_isn.kschl is 'Condition type (coded)';
comment on column lads_sal_ord_isn.kotxt is 'Condition text';
comment on column lads_sal_ord_isn.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_sal_ord_isn.kperc is 'Condition percentage rate';
comment on column lads_sal_ord_isn.krate is 'Condition record per unit';
comment on column lads_sal_ord_isn.uprbs is 'Price unit';
comment on column lads_sal_ord_isn.meaun is 'Unit of measurement';
comment on column lads_sal_ord_isn.kobtr is 'IDoc condition end amount';
comment on column lads_sal_ord_isn.menge is 'Price scale quantity (SPEC2000)';
comment on column lads_sal_ord_isn.preis is 'Price by unit of measure (SPEC2000)';
comment on column lads_sal_ord_isn.mwskz is 'VAT indicator';
comment on column lads_sal_ord_isn.msatz is 'VAT rate';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isn
   add constraint lads_sal_ord_isn_pk primary key (belnr, genseq, issseq, isnseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isn to lads_app;
grant select, insert, update, delete on lads_sal_ord_isn to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isn for lads.lads_sal_ord_isn;
