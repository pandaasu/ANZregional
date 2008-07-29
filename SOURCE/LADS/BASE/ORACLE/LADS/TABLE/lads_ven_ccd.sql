/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_ven_ccd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_ven_ccd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_ven_ccd
   (lifnr                                        varchar2(10 char)                   not null,
    ccdseq                                       number                              not null,
    bukrs                                        varchar2(6 char)                    null,
    erdat                                        varchar2(8 char)                    null,
    ernam                                        varchar2(12 char)                   null,
    sperr                                        varchar2(1 char)                    null,
    loevm                                        varchar2(1 char)                    null,
    zuawa                                        varchar2(3 char)                    null,
    akont                                        varchar2(10 char)                   null,
    begru                                        varchar2(4 char)                    null,
    vzskz                                        varchar2(2 char)                    null,
    zwels                                        varchar2(10 char)                   null,
    xverr                                        varchar2(1 char)                    null,
    zahls                                        varchar2(1 char)                    null,
    zterm                                        varchar2(4 char)                    null,
    eikto                                        varchar2(12 char)                   null,
    zsabe                                        varchar2(15 char)                   null,
    fdgrv                                        varchar2(10 char)                   null,
    busab                                        varchar2(2 char)                    null,
    lnrze                                        varchar2(10 char)                   null,
    lnrzb                                        varchar2(10 char)                   null,
    zindt                                        varchar2(8 char)                    null,
    zinrt                                        number                              null,
    datlz                                        varchar2(8 char)                    null,
    xdezv                                        varchar2(1 char)                    null,
    webtr                                        number                              null,
    kultg                                        number                              null,
    reprf                                        varchar2(1 char)                    null,
    togru                                        varchar2(4 char)                    null,
    hbkid                                        varchar2(5 char)                    null,
    xpore                                        varchar2(1 char)                    null,
    qsznr                                        varchar2(10 char)                   null,
    qszdt                                        varchar2(8 char)                    null,
    qsskz                                        varchar2(2 char)                    null,
    blnkz                                        varchar2(2 char)                    null,
    mindk                                        varchar2(3 char)                    null,
    altkn                                        varchar2(10 char)                   null,
    zgrup                                        varchar2(2 char)                    null,
    mgrup                                        varchar2(2 char)                    null,
    qsrec                                        varchar2(2 char)                    null,
    qsbgr                                        varchar2(1 char)                    null,
    qland                                        varchar2(3 char)                    null,
    xedip                                        varchar2(1 char)                    null,
    frgrp                                        varchar2(4 char)                    null,
    tlfxs                                        varchar2(31 char)                   null,
    intad                                        varchar2(130 char)                  null,
    guzte                                        varchar2(4 char)                    null,
    gricd                                        varchar2(2 char)                    null,
    gridt                                        varchar2(2 char)                    null,
    xausz                                        varchar2(1 char)                    null,
    cerdt                                        varchar2(8 char)                    null,
    togrr                                        varchar2(4 char)                    null,
    pernr                                        number                              null,
    nodel                                        varchar2(1 char)                    null,
    tlfns                                        varchar2(30 char)                   null,
    gmvkzk                                       varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_ven_ccd is 'LADS Vendor Company';
comment on column lads_ven_ccd.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_ven_ccd.ccdseq is 'CCD - generated sequence number';
comment on column lads_ven_ccd.bukrs is 'Company Code';
comment on column lads_ven_ccd.erdat is 'Date on which the Record Was Created';
comment on column lads_ven_ccd.ernam is 'Name of Person who Created the Object';
comment on column lads_ven_ccd.sperr is 'Posting block for company code';
comment on column lads_ven_ccd.loevm is 'Deletion Flag for Master Record (Company Code Level)';
comment on column lads_ven_ccd.zuawa is 'Key for sorting according to assignment numbers';
comment on column lads_ven_ccd.akont is 'Reconciliation Account in General Ledger';
comment on column lads_ven_ccd.begru is 'Authorization Group';
comment on column lads_ven_ccd.vzskz is 'Interest calculation indicator';
comment on column lads_ven_ccd.zwels is 'List of the Payment Methods to be Considered';
comment on column lads_ven_ccd.xverr is 'Indicator: Clearing between customer and vendor?';
comment on column lads_ven_ccd.zahls is 'Block key for payment';
comment on column lads_ven_ccd.zterm is 'Terms of payment key';
comment on column lads_ven_ccd.eikto is 'Shippers (Our) Account Number at the Customer or Vendor';
comment on column lads_ven_ccd.zsabe is 'Clerk at vendor';
comment on column lads_ven_ccd.fdgrv is 'Planning group';
comment on column lads_ven_ccd.busab is 'Accounting clerk';
comment on column lads_ven_ccd.lnrze is 'Head office account number';
comment on column lads_ven_ccd.lnrzb is 'Account number of the alternative payee';
comment on column lads_ven_ccd.zindt is 'Key date of the last interest calculation';
comment on column lads_ven_ccd.zinrt is 'Interest calculation frequency in months';
comment on column lads_ven_ccd.datlz is 'Date of the last interest calculation run';
comment on column lads_ven_ccd.xdezv is 'Indicator: Local processing?';
comment on column lads_ven_ccd.webtr is 'Bill of exchange limit (in local currency)';
comment on column lads_ven_ccd.kultg is 'Probable time until check is paid';
comment on column lads_ven_ccd.reprf is 'Check Flag for Double Invoices or Credit Memos';
comment on column lads_ven_ccd.togru is 'Tolerance group for the business partner/G/L account';
comment on column lads_ven_ccd.hbkid is 'Short key for a house bank';
comment on column lads_ven_ccd.xpore is 'Indicator: Pay all items separately ?';
comment on column lads_ven_ccd.qsznr is 'Certificate Number of the Withholding Tax Exemption';
comment on column lads_ven_ccd.qszdt is 'Validity Date for Withholding Tax Exemption Certificate';
comment on column lads_ven_ccd.qsskz is 'Withholding Tax Code';
comment on column lads_ven_ccd.blnkz is 'Subsidy indicator for determining the reduction rates';
comment on column lads_ven_ccd.mindk is 'Minority Indicators';
comment on column lads_ven_ccd.altkn is 'Previous Master Record Number';
comment on column lads_ven_ccd.zgrup is 'Key for Payment Grouping';
comment on column lads_ven_ccd.mgrup is 'Key for dunning notice grouping';
comment on column lads_ven_ccd.qsrec is 'Vendor Recipient Type';
comment on column lads_ven_ccd.qsbgr is 'Authority for Exemption from Withholding Tax';
comment on column lads_ven_ccd.qland is 'Withholding Tax Country Key';
comment on column lads_ven_ccd.xedip is 'Indicator: Send Payment Advices by EDI';
comment on column lads_ven_ccd.frgrp is 'Release Approval Group';
comment on column lads_ven_ccd.tlfxs is 'Accounting clerks fax number at the customer/vendor';
comment on column lads_ven_ccd.intad is 'Internet address of partner company clerk';
comment on column lads_ven_ccd.guzte is 'Payment Terms Key for Credit Memos';
comment on column lads_ven_ccd.gricd is 'Activity Code for Gross Income Tax';
comment on column lads_ven_ccd.gridt is 'Distribution Type for Employment Tax';
comment on column lads_ven_ccd.xausz is 'Indicator for periodic account statements';
comment on column lads_ven_ccd.cerdt is 'Certification date';
comment on column lads_ven_ccd.togrr is 'Tolerance group; Invoice Verification';
comment on column lads_ven_ccd.pernr is 'Personnel Number';
comment on column lads_ven_ccd.nodel is 'Deletion bock for master record (company code level)';
comment on column lads_ven_ccd.tlfns is 'Accounting clerks telephone number at business partner';
comment on column lads_ven_ccd.gmvkzk is 'Indicator means that the vendor is in execution';

/**/
/* Primary Key Constraint
/**/
alter table lads_ven_ccd
   add constraint lads_ven_ccd_pk primary key (lifnr, ccdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_ven_ccd to lads_app;
grant select, insert, update, delete on lads_ven_ccd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_ven_ccd for lads.lads_ven_ccd;
