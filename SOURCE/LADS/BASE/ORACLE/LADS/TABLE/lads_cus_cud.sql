/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_cud
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_cud

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_cud
   (kunnr                                        varchar2(10 char)                   not null,
    cudseq                                       number                              not null,
    bukrs                                        varchar2(6 char)                    null,
    sperr                                        varchar2(1 char)                    null,
    loevm                                        varchar2(1 char)                    null,
    zuawa                                        varchar2(3 char)                    null,
    busab                                        varchar2(2 char)                    null,
    akont                                        varchar2(10 char)                   null,
    begru                                        varchar2(4 char)                    null,
    knrze                                        varchar2(10 char)                   null,
    knrzb                                        varchar2(10 char)                   null,
    zamim                                        varchar2(1 char)                    null,
    zamiv                                        varchar2(1 char)                    null,
    zamir                                        varchar2(1 char)                    null,
    zamib                                        varchar2(1 char)                    null,
    zamio                                        varchar2(1 char)                    null,
    zwels                                        varchar2(10 char)                   null,
    xverr                                        varchar2(1 char)                    null,
    zahls                                        varchar2(1 char)                    null,
    zterm                                        varchar2(4 char)                    null,
    wakon                                        varchar2(4 char)                    null,
    vzskz                                        varchar2(2 char)                    null,
    zindt                                        varchar2(8 char)                    null,
    zinrt                                        number                              null,
    eikto                                        varchar2(12 char)                   null,
    zsabe                                        varchar2(15 char)                   null,
    kverm                                        varchar2(30 char)                   null,
    fdgrv                                        varchar2(10 char)                   null,
    vrbkz                                        varchar2(2 char)                    null,
    vlibb                                        number                              null,
    vrszl                                        number                              null,
    vrspr                                        number                              null,
    vrsnr                                        varchar2(10 char)                   null,
    verdt                                        varchar2(8 char)                    null,
    perkz                                        varchar2(1 char)                    null,
    xdezv                                        varchar2(1 char)                    null,
    xausz                                        varchar2(1 char)                    null,
    webtr                                        number                              null,
    remit                                        varchar2(10 char)                   null,
    datlz                                        varchar2(8 char)                    null,
    xzver                                        varchar2(1 char)                    null,
    togru                                        varchar2(4 char)                    null,
    kultg                                        number                              null,
    hbkid                                        varchar2(5 char)                    null,
    xpore                                        varchar2(1 char)                    null,
    blnkz                                        varchar2(2 char)                    null,
    altkn                                        varchar2(10 char)                   null,
    zgrup                                        varchar2(2 char)                    null,
    urlid                                        varchar2(4 char)                    null,
    mgrup                                        varchar2(2 char)                    null,
    lockb                                        varchar2(7 char)                    null,
    uzawe                                        varchar2(2 char)                    null,
    ekvbd                                        varchar2(10 char)                   null,
    sregl                                        varchar2(3 char)                    null,
    xedip                                        varchar2(1 char)                    null,
    frgrp                                        varchar2(4 char)                    null,
    vrsdg                                        varchar2(3 char)                    null,
    tlfxs                                        varchar2(31 char)                   null,
    pernr                                        number                              null,
    intad                                        varchar2(130 char)                  null,
    guzte                                        varchar2(4 char)                    null,
    gricd                                        varchar2(2 char)                    null,
    gridt                                        varchar2(2 char)                    null,
    wbrsl                                        varchar2(2 char)                    null,
    nodel                                        varchar2(1 char)                    null,
    tlfns                                        varchar2(30 char)                   null,
    cession_kz                                   varchar2(2 char)                    null,
    gmvkzd                                       varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_cus_cud is 'LADS Customer Company';
comment on column lads_cus_cud.kunnr is 'Customer Number';
comment on column lads_cus_cud.cudseq is 'CUD - generated sequence number';
comment on column lads_cus_cud.bukrs is 'Company Code';
comment on column lads_cus_cud.sperr is 'Posting block for company code';
comment on column lads_cus_cud.loevm is 'Deletion Flag for Master Record (Company Code Level)';
comment on column lads_cus_cud.zuawa is 'Key for sorting according to assignment numbers';
comment on column lads_cus_cud.busab is 'Accounting clerk';
comment on column lads_cus_cud.akont is 'Reconciliation Account in General Ledger';
comment on column lads_cus_cud.begru is 'Authorization Group';
comment on column lads_cus_cud.knrze is 'Head office account number (in branch accounts)';
comment on column lads_cus_cud.knrzb is 'Account number of an alternative payer';
comment on column lads_cus_cud.zamim is 'Indicator: Payment notice to customer (with cleared items)?';
comment on column lads_cus_cud.zamiv is 'Indicator: payment notice to sales department?';
comment on column lads_cus_cud.zamir is 'Indicator: payment notice to legal department?';
comment on column lads_cus_cud.zamib is 'Indicator: Payment notice to the accounting department ?';
comment on column lads_cus_cud.zamio is 'Indicator: payment notice to customer (w/o cleared items)?';
comment on column lads_cus_cud.zwels is 'List of the Payment Methods to be Considered';
comment on column lads_cus_cud.xverr is 'Indicator: Clearing between customer and vendor ?';
comment on column lads_cus_cud.zahls is 'Block key for payment';
comment on column lads_cus_cud.zterm is 'Terms of payment key';
comment on column lads_cus_cud.wakon is 'Terms of payment key for bill of exchange charges';
comment on column lads_cus_cud.vzskz is 'Interest calculation indicator';
comment on column lads_cus_cud.zindt is 'Key date of the last interest calculation';
comment on column lads_cus_cud.zinrt is 'Interest calculation frequency in months';
comment on column lads_cus_cud.eikto is 'Our account number at customer';
comment on column lads_cus_cud.zsabe is 'User at customer';
comment on column lads_cus_cud.kverm is 'Memo';
comment on column lads_cus_cud.fdgrv is 'Planning group';
comment on column lads_cus_cud.vrbkz is 'Export credit insurance institution number';
comment on column lads_cus_cud.vlibb is 'Amount Insured';
comment on column lads_cus_cud.vrszl is 'Insurance lead months';
comment on column lads_cus_cud.vrspr is 'Deductible percentage rate';
comment on column lads_cus_cud.vrsnr is 'Insurance number';
comment on column lads_cus_cud.verdt is 'Insurance validity date';
comment on column lads_cus_cud.perkz is 'Collective invoice variant';
comment on column lads_cus_cud.xdezv is 'Indicator: Local processing?';
comment on column lads_cus_cud.xausz is 'Indicator for periodic account statements';
comment on column lads_cus_cud.webtr is 'Bill of exchange limit (in local currency)';
comment on column lads_cus_cud.remit is 'Next payee';
comment on column lads_cus_cud.datlz is 'Date of the last interest calculation run';
comment on column lads_cus_cud.xzver is 'Indicator: Record Payment History ?';
comment on column lads_cus_cud.togru is 'Tolerance group for the business partner/G/L account';
comment on column lads_cus_cud.kultg is 'Probable time until check is paid';
comment on column lads_cus_cud.hbkid is 'Short key for a house bank';
comment on column lads_cus_cud.xpore is 'Indicator: Pay all items separately ?';
comment on column lads_cus_cud.blnkz is 'Subsidy indicator for determining the reduction rates';
comment on column lads_cus_cud.altkn is 'Previous Master Record Number';
comment on column lads_cus_cud.zgrup is 'Key for Payment Grouping';
comment on column lads_cus_cud.urlid is 'Short Key for Known/Negotiated Leave';
comment on column lads_cus_cud.mgrup is 'Key for dunning notice grouping';
comment on column lads_cus_cud.lockb is 'Key of the Lockbox to Which the Customer Is To Pay';
comment on column lads_cus_cud.uzawe is 'Payment method supplement';
comment on column lads_cus_cud.ekvbd is 'Account Number of Buying Group';
comment on column lads_cus_cud.sregl is 'Selection Rule for Payment Advices';
comment on column lads_cus_cud.xedip is 'Indicator: Send Payment Advices by EDI';
comment on column lads_cus_cud.frgrp is 'Release Approval Group';
comment on column lads_cus_cud.vrsdg is 'Reason Code Conversion Version';
comment on column lads_cus_cud.tlfxs is 'Accounting clerks fax number at the customer/vendor';
comment on column lads_cus_cud.pernr is 'Personnel Number';
comment on column lads_cus_cud.intad is 'Internet address of partner company clerk';
comment on column lads_cus_cud.guzte is 'Payment Terms Key for Credit Memos';
comment on column lads_cus_cud.gricd is 'Activity Code for Gross Income Tax';
comment on column lads_cus_cud.gridt is 'Distribution Type for Employment Tax';
comment on column lads_cus_cud.wbrsl is 'Value Adjustment Key';
comment on column lads_cus_cud.nodel is 'Deletion bock for master record (company code level)';
comment on column lads_cus_cud.tlfns is 'Accounting clerks telephone number at business partner';
comment on column lads_cus_cud.cession_kz is 'Accounts Receivable Pledging Indicator';
comment on column lads_cus_cud.gmvkzd is 'Indicates that a customer is in debt enforcement';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_cud
   add constraint lads_cus_cud_pk primary key (kunnr, cudseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_cud to lads_app;
grant select, insert, update, delete on lads_cus_cud to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_cus_cud for lads.lads_cus_cud;
