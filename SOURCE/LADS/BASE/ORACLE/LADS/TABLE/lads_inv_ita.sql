/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_ita
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_ita

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_ita
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itaseq                                       number                              not null,
    mwskz                                        varchar2(7 char)                    null,
    msatz                                        varchar2(17 char)                   null,
    mwsbt                                        varchar2(18 char)                   null,
    txjcd                                        varchar2(15 char)                   null,
    ktext                                        varchar2(50 char)                   null,
    ltx01                                        varchar2(72 char)                   null,
    ltx02                                        varchar2(72 char)                   null,
    ltx03                                        varchar2(72 char)                   null,
    ltx04                                        varchar2(72 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_ita is 'LADS Invoice Item Tax';
comment on column lads_inv_ita.belnr is 'IDOC document number';
comment on column lads_inv_ita.genseq is 'GEN - generated sequence number';
comment on column lads_inv_ita.itaseq is 'ITA - generated sequence number';
comment on column lads_inv_ita.mwskz is 'VAT indicator';
comment on column lads_inv_ita.msatz is 'VAT rate';
comment on column lads_inv_ita.mwsbt is 'Value added tax amount';
comment on column lads_inv_ita.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_inv_ita.ktext is 'Text Field';
comment on column lads_inv_ita.ltx01 is 'Long text line';
comment on column lads_inv_ita.ltx02 is 'Long text line';
comment on column lads_inv_ita.ltx03 is 'Long text line';
comment on column lads_inv_ita.ltx04 is 'Long text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_ita
   add constraint lads_inv_ita_pk primary key (belnr, genseq, itaseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_ita to lads_app;
grant select, insert, update, delete on lads_inv_ita to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_ita for lads.lads_inv_ita;
