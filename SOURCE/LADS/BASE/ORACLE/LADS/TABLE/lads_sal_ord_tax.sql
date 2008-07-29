/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_tax
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_tax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_tax
   (belnr                                        varchar2(35 char)                   not null,
    taxseq                                       number                              not null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    mwsbt                                        varchar2(18 char)                   null,
    txjcd                                        varchar2(15 char)                   null,
    ktext                                        varchar2(50 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_tax is 'LADS Sales Order Tax';
comment on column lads_sal_ord_tax.belnr is 'Document number';
comment on column lads_sal_ord_tax.taxseq is 'TAX - generated sequence number';
comment on column lads_sal_ord_tax.mwskz is 'VAT indicator';
comment on column lads_sal_ord_tax.msatz is 'VAT rate';
comment on column lads_sal_ord_tax.mwsbt is 'Value added tax amount';
comment on column lads_sal_ord_tax.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_sal_ord_tax.ktext is 'Text Field';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_tax
   add constraint lads_sal_ord_tax_pk primary key (belnr, taxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_tax to lads_app;
grant select, insert, update, delete on lads_sal_ord_tax to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_tax for lads.lads_sal_ord_tax;
