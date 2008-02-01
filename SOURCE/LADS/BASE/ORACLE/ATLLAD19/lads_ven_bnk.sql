/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_bnk
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_bnk

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_bnk
   (lifnr                                        varchar2(10 char)                   not null,
    bnkseq                                       number                              not null,
    banks                                        varchar2(3 char)                    null,
    bankl                                        varchar2(15 char)                   null,
    bankn                                        varchar2(18 char)                   null,
    bkont                                        varchar2(2 char)                    null,
    bvtyp                                        varchar2(4 char)                    null,
    xezer                                        varchar2(1 char)                    null,
    banka                                        varchar2(60 char)                   null,
    ort01                                        varchar2(25 char)                   null,
    swift                                        varchar2(11 char)                   null,
    bgrup                                        varchar2(2 char)                    null,
    xpgro                                        varchar2(1 char)                    null,
    bnklz                                        varchar2(15 char)                   null,
    pskto                                        varchar2(16 char)                   null,
    bkref                                        varchar2(20 char)                   null,
    brnch                                        varchar2(40 char)                   null,
    prov2                                        varchar2(3 char)                    null,
    stra2                                        varchar2(35 char)                   null,
    ort02                                        varchar2(35 char)                   null,
    koinh                                        varchar2(60 char)                   null,
    kovon                                        varchar2(8 char)                    null,
    kobis                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ven_bnk is 'LADS Vendor Bank';
comment on column lads_ven_bnk.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_bnk.bnkseq is 'BNK - generated sequence number';
comment on column lads_ven_bnk.banks is 'Bank country key';
comment on column lads_ven_bnk.bankl is 'Bank Key';
comment on column lads_ven_bnk.bankn is 'Bank Account Number';
comment on column lads_ven_bnk.bkont is 'Bank Control Key';
comment on column lads_ven_bnk.bvtyp is 'Partner bank type';
comment on column lads_ven_bnk.xezer is 'Indicator: Is there collection authorization ?';
comment on column lads_ven_bnk.banka is 'Name of bank';
comment on column lads_ven_bnk.ort01 is 'Location';
comment on column lads_ven_bnk.swift is 'SWIFT Code for International Payments';
comment on column lads_ven_bnk.bgrup is 'Bank group (bank network)';
comment on column lads_ven_bnk.xpgro is 'Checkbox';
comment on column lads_ven_bnk.bnklz is 'Bank number';
comment on column lads_ven_bnk.pskto is 'Post office bank current account number';
comment on column lads_ven_bnk.bkref is 'Reference Specifications for Bank Details';
comment on column lads_ven_bnk.brnch is 'Bank Branch';
comment on column lads_ven_bnk.prov2 is '"Region (State, Province, County)"';
comment on column lads_ven_bnk.stra2 is 'House number and street';
comment on column lads_ven_bnk.ort02 is 'City';
comment on column lads_ven_bnk.koinh is 'Account Holder Name';
comment on column lads_ven_bnk.kovon is 'Date (batch input)';
comment on column lads_ven_bnk.kobis is 'Date (batch input)';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_bnk
   add constraint lads_ven_bnk_pk primary key (lifnr, bnkseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_bnk to lads_app;
grant select, insert, update, delete on lads_ven_bnk to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_bnk for lads.lads_ven_bnk;
