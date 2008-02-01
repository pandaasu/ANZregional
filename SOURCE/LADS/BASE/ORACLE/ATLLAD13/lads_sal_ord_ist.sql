/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_ist
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_ist

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_ist
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    istseq                                       number                              not null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    mwsbt                                        varchar2(18 char)                   null,
    txjcd                                        varchar2(15 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_ist is 'LADS Sales Order Item Service Specification Tax';
comment on column lads_sal_ord_ist.belnr is 'Document number';
comment on column lads_sal_ord_ist.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_ist.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_ist.istseq is 'IST - generated sequence number';
comment on column lads_sal_ord_ist.mwskz is 'VAT indicator';
comment on column lads_sal_ord_ist.msatz is 'VAT rate';
comment on column lads_sal_ord_ist.mwsbt is 'Value added tax amount';
comment on column lads_sal_ord_ist.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_ist
   add constraint lads_sal_ord_ist_pk primary key (belnr, genseq, issseq, istseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_ist to lads_app;
grant select, insert, update, delete on lads_sal_ord_ist to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_ist for lads.lads_sal_ord_ist;
