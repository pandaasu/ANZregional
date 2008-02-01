/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_tax
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_tax

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_tax
   (belnr                                        varchar2(35 char)                   not null,
    taxseq                                       number                              not null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    mwsbt                                        varchar2(18 char)                   null,
    txjcd                                        varchar2(15 char)                   null,
    ktext                                        varchar2(50 char)                   null,
    zntvat                                       varchar2(18 char)                   null,
    zgramount                                    number                              null,
    vatdesc                                      varchar2(50 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_tax is 'LADS Invoice  Tax';
comment on column lads_inv_tax.belnr is 'IDOC document number';
comment on column lads_inv_tax.taxseq is 'TAX - generated sequence number';
comment on column lads_inv_tax.mwskz is 'VAT indicator';
comment on column lads_inv_tax.msatz is 'VAT rate';
comment on column lads_inv_tax.mwsbt is 'Value added tax amount';
comment on column lads_inv_tax.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_inv_tax.ktext is 'Text Field';
comment on column lads_inv_tax.zntvat is 'Value added tax amount';
comment on column lads_inv_tax.zgramount is 'Gross value of the billing item in document currency';
comment on column lads_inv_tax.vatdesc is 'Name for value-added tax';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_tax
   add constraint lads_inv_tax_pk primary key (belnr, taxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_tax to lads_app;
grant select, insert, update, delete on lads_inv_tax to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_tax for lads.lads_inv_tax;
