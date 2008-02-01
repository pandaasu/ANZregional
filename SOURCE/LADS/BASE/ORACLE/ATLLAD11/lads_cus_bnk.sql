/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_bnk
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_bnk

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_bnk
   (kunnr                                        varchar2(10 char)                   not null,
    bnkseq                                       number                              not null,
    banks                                        varchar2(3 char)                    null,
    bankl                                        varchar2(15 char)                   null,
    bankn                                        varchar2(18 char)                   null,
    bkont                                        varchar2(2 char)                    null,
    bvtyp                                        varchar2(4 char)                    null,
    xezer                                        varchar2(1 char)                    null,
    bkref                                        varchar2(20 char)                   null,
    banka                                        varchar2(60 char)                   null,
    stras                                        varchar2(35 char)                   null,
    ort01                                        varchar2(35 char)                   null,
    swift                                        varchar2(11 char)                   null,
    bgrup                                        varchar2(2 char)                    null,
    xpgro                                        varchar2(1 char)                    null,
    bnklz                                        varchar2(15 char)                   null,
    pskto                                        varchar2(16 char)                   null,
    brnch                                        varchar2(40 char)                   null,
    provz                                        varchar2(3 char)                    null,
    koinh                                        varchar2(35 char)                   null,
    koinh_n                                      varchar2(60 char)                   null,
    kovon                                        varchar2(8 char)                    null,
    kobis                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_bnk is 'LADS Customer Bank Detail';
comment on column lads_cus_bnk.kunnr is 'Customer Number';
comment on column lads_cus_bnk.bnkseq is 'BNK - generated sequence number';
comment on column lads_cus_bnk.banks is 'Bank country key';
comment on column lads_cus_bnk.bankl is 'Bank number';
comment on column lads_cus_bnk.bankn is 'Bank Account Number';
comment on column lads_cus_bnk.bkont is 'Bank Control Key';
comment on column lads_cus_bnk.bvtyp is 'Partner bank type';
comment on column lads_cus_bnk.xezer is 'Indicator: Is there collection authorization ?';
comment on column lads_cus_bnk.bkref is 'Reference Specifications for Bank Details';
comment on column lads_cus_bnk.banka is 'Name of bank';
comment on column lads_cus_bnk.stras is 'House number and street';
comment on column lads_cus_bnk.ort01 is 'City';
comment on column lads_cus_bnk.swift is 'SWIFT Code for International Payments';
comment on column lads_cus_bnk.bgrup is 'Bank group (bank network)';
comment on column lads_cus_bnk.xpgro is 'Post Office Bank Current Account';
comment on column lads_cus_bnk.bnklz is 'Bank number';
comment on column lads_cus_bnk.pskto is 'Post office bank current account number';
comment on column lads_cus_bnk.brnch is 'Bank Branch';
comment on column lads_cus_bnk.provz is '"Region (State, Province, County)"';
comment on column lads_cus_bnk.koinh is 'Account Holder Name';
comment on column lads_cus_bnk.koinh_n is 'Account Holder Name';
comment on column lads_cus_bnk.kovon is 'Date (batch input)';
comment on column lads_cus_bnk.kobis is 'Date (batch input)';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_bnk
   add constraint lads_cus_bnk_pk primary key (kunnr, bnkseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_bnk to lads_app;
grant select, insert, update, delete on lads_cus_bnk to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_bnk for lads.lads_cus_bnk;
