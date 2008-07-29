/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_con
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_con

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_con
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
comment on table lads_sal_ord_con is 'LADS Sales Order Condition';
comment on column lads_sal_ord_con.belnr is 'Document number';
comment on column lads_sal_ord_con.conseq is 'CON - generated sequence number';
comment on column lads_sal_ord_con.alckz is 'Surcharge or discount indicator';
comment on column lads_sal_ord_con.kschl is 'Condition type (coded)';
comment on column lads_sal_ord_con.kotxt is 'Condition text';
comment on column lads_sal_ord_con.betrg is 'Fixed surcharge/discount on total gross';
comment on column lads_sal_ord_con.kperc is 'Condition percentage rate';
comment on column lads_sal_ord_con.krate is 'Condition record per unit';
comment on column lads_sal_ord_con.uprbs is 'Price unit';
comment on column lads_sal_ord_con.meaun is 'Unit of measurement';
comment on column lads_sal_ord_con.kobtr is 'IDoc condition end amount';
comment on column lads_sal_ord_con.mwskz is 'VAT indicator';
comment on column lads_sal_ord_con.msatz is 'VAT rate';
comment on column lads_sal_ord_con.koein is 'Currency';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_con
   add constraint lads_sal_ord_con_pk primary key (belnr, conseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_con to lads_app;
grant select, insert, update, delete on lads_sal_ord_con to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_con for lads.lads_sal_ord_con;
