/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_con
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_con

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_con
   (belnr                                        varchar2(35 char)                   not null,
    conseq                                       number                              not null,
    alckz                                        varchar2(3 char)                    null,
    kschl                                        varchar2(4 char)                    null,
    kotxt                                        varchar2(80 char)                   null,
    betrg                                        varchar2(18 char)                   null,
    kperc                                        varchar2(8 char)                    null,
    krate                                        varchar2(15 char)                   null,
    uprbs                                        varchar2(9 char)                    null,
    meaun                                        varchar2(3 char)                    null,
    kobtr                                        varchar2(18 char)                   null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    koein                                        varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sto_po_con is 'LADS Stock Transfer and Purchase Order Condition';
comment on column lads_sto_po_con.belnr is 'IDOC document number';
comment on column lads_sto_po_con.conseq is 'CON - generated sequence number';
comment on column lads_sto_po_con.alckz is 'Surcharge or discount indicator';
comment on column lads_sto_po_con.kschl is 'Condition type (coded)';
comment on column lads_sto_po_con.kotxt is 'Condition text';
comment on column lads_sto_po_con.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_sto_po_con.kperc is 'Condition percentage rate';
comment on column lads_sto_po_con.krate is 'Condition record per unit';
comment on column lads_sto_po_con.uprbs is 'Price unit';
comment on column lads_sto_po_con.meaun is 'Unit of measurement';
comment on column lads_sto_po_con.kobtr is 'IDoc condition end amount';
comment on column lads_sto_po_con.mwskz is 'VAT indicator';
comment on column lads_sto_po_con.msatz is 'VAT rate';
comment on column lads_sto_po_con.koein is 'Currency';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_con
   add constraint lads_sto_po_con_pk primary key (belnr, conseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_con to lads_app;
grant select, insert, update, delete on lads_sto_po_con to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_con for lads.lads_sto_po_con;
