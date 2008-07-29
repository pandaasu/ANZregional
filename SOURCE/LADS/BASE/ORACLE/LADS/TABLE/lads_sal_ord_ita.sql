/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_ita
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_ita

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_ita
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itaseq                                       number                              not null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    mwsbt                                        varchar2(18 char)                   null,
    txjcd                                        varchar2(15 char)                   null,
    ktext                                        varchar2(50 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_ita is 'LADS Sales Order Item Tax';
comment on column lads_sal_ord_ita.belnr is 'Document number';
comment on column lads_sal_ord_ita.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_ita.itaseq is 'ITA - generated sequence number';
comment on column lads_sal_ord_ita.mwskz is 'VAT indicator';
comment on column lads_sal_ord_ita.msatz is 'VAT rate';
comment on column lads_sal_ord_ita.mwsbt is 'Value added tax amount';
comment on column lads_sal_ord_ita.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_sal_ord_ita.ktext is 'Text Field';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_ita
   add constraint lads_sal_ord_ita_pk primary key (belnr, genseq, itaseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_ita to lads_app;
grant select, insert, update, delete on lads_sal_ord_ita to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_ita for lads.lads_sal_ord_ita;
