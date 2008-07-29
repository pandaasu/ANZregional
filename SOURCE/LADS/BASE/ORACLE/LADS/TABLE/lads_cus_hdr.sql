/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_cus_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_cus_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created
 2005/04   Linden Glen    Removed columns : ZZKATR11, ZZKATR12, ,ZZKATR15, 
                                            ZZKATR16, ZZKATR17,  ZZKATR18, 
                                            ZZKATR19, ZZKATR20
                          Added columns   : ZZCUSTSTAT, ZZRETSTORE
 2006/01   Linden Glen    Added column    : LOCCO
 2006/11   Steve Gregan   Added column    : ZZDEMPLAN
*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_cus_hdr
   (kunnr                                        varchar2(10 char)                   not null,
    aufsd                                        varchar2(2 char)                    null,
    begru                                        varchar2(4 char)                    null,
    brsch                                        varchar2(4 char)                    null,
    faksd                                        varchar2(2 char)                    null,
    fiskn                                        varchar2(10 char)                   null,
    knrza                                        varchar2(10 char)                   null,
    konzs                                        varchar2(10 char)                   null,
    ktokd                                        varchar2(4 char)                    null,
    kukla                                        varchar2(2 char)                    null,
    lifnr                                        varchar2(10 char)                   null,
    lifsd                                        varchar2(2 char)                    null,
    loevm                                        varchar2(1 char)                    null,
    sperr                                        varchar2(1 char)                    null,
    stcd1                                        varchar2(16 char)                   null,
    stcd2                                        varchar2(11 char)                   null,
    stkza                                        varchar2(1 char)                    null,
    stkzu                                        varchar2(1 char)                    null,
    xzemp                                        varchar2(1 char)                    null,
    vbund                                        varchar2(6 char)                    null,
    stceg                                        varchar2(20 char)                   null,
    gform                                        varchar2(2 char)                    null,
    umjah                                        number                              null,
    uwaer                                        varchar2(5 char)                    null,
    katr2                                        varchar2(2 char)                    null,
    katr3                                        varchar2(2 char)                    null,
    katr4                                        varchar2(2 char)                    null,
    katr5                                        varchar2(2 char)                    null,
    katr6                                        varchar2(3 char)                    null,
    katr7                                        varchar2(3 char)                    null,
    katr8                                        varchar2(3 char)                    null,
    katr9                                        varchar2(3 char)                    null,
    katr10                                       varchar2(3 char)                    null,
    stkzn                                        varchar2(1 char)                    null,
    umsa1                                        varchar2(16 char)                   null,
    periv                                        varchar2(2 char)                    null,
    ktocd                                        varchar2(4 char)                    null,
    fityp                                        varchar2(2 char)                    null,
    stcdt                                        varchar2(2 char)                    null,
    stcd3                                        varchar2(18 char)                   null,
    stcd4                                        varchar2(18 char)                   null,
    cassd                                        varchar2(2 char)                    null,
    kdkg1                                        varchar2(2 char)                    null,
    kdkg2                                        varchar2(2 char)                    null,
    kdkg3                                        varchar2(2 char)                    null,
    kdkg4                                        varchar2(2 char)                    null,
    kdkg5                                        varchar2(2 char)                    null,
    nodel                                        varchar2(1 char)                    null,
    xsub2                                        varchar2(3 char)                    null,
    werks                                        varchar2(4 char)                    null,
    zzcustom01                                   varchar2(1 char)                    null,
    zzkatr13                                     varchar2(3 char)                    null,
    zzkatr14                                     varchar2(3 char)                    null,
    j_1kfrepre                                   varchar2(10 char)                   null,
    j_1kftbus                                    varchar2(30 char)                   null,
    j_1kftind                                    varchar2(30 char)                   null,
    psois                                        varchar2(20 char)                   null,
    katr1                                        varchar2(2 char)                    null,
    zzcuststat                                   varchar2(2 char)                    null, 
    zzretstore                                   varchar2(8 char)                    null,
    locco                                        varchar2(10 char)                   null,
    zzdemplan                                    varchar2(10 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_cus_hdr is 'LADS Customer Header';
comment on column lads_cus_hdr.kunnr is 'Customer Number';
comment on column lads_cus_hdr.aufsd is 'Central order block for customer';
comment on column lads_cus_hdr.begru is 'Authorization Group';
comment on column lads_cus_hdr.brsch is 'Industry key';
comment on column lads_cus_hdr.faksd is 'Central billing block for customer';
comment on column lads_cus_hdr.fiskn is 'Account number of the master record with the fiscal address';
comment on column lads_cus_hdr.knrza is 'Account number of an alternative payer';
comment on column lads_cus_hdr.konzs is 'Group key';
comment on column lads_cus_hdr.ktokd is 'Customer Account Group';
comment on column lads_cus_hdr.kukla is 'Customer classification';
comment on column lads_cus_hdr.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_cus_hdr.lifsd is 'Central delivery block for the customer';
comment on column lads_cus_hdr.loevm is 'Central Deletion Flag for Master Record';
comment on column lads_cus_hdr.sperr is 'Central posting block';
comment on column lads_cus_hdr.stcd1 is 'Tax Number 1';
comment on column lads_cus_hdr.stcd2 is 'Tax Number 2';
comment on column lads_cus_hdr.stkza is 'Indicator: Business Partner Subject to Equalization Tax?';
comment on column lads_cus_hdr.stkzu is 'Liable for VAT';
comment on column lads_cus_hdr.xzemp is 'Indicator: Alternative payee in document allowed ?';
comment on column lads_cus_hdr.vbund is 'Company ID of Trading Partner';
comment on column lads_cus_hdr.stceg is 'VAT registration number';
comment on column lads_cus_hdr.gform is 'Legal status';
comment on column lads_cus_hdr.umjah is 'Year For Which Sales are Given';
comment on column lads_cus_hdr.uwaer is 'Currency of sales figure';
comment on column lads_cus_hdr.katr2 is 'Sales Point Type';
comment on column lads_cus_hdr.katr3 is 'Combine Invoice List';
comment on column lads_cus_hdr.katr4 is 'Attribute 4';
comment on column lads_cus_hdr.katr5 is 'Attribute 5';
comment on column lads_cus_hdr.katr6 is 'Attribute 6';
comment on column lads_cus_hdr.katr7 is 'Attribute 7';
comment on column lads_cus_hdr.katr8 is 'Attribute 8';
comment on column lads_cus_hdr.katr9 is 'Attribute 9';
comment on column lads_cus_hdr.katr10 is 'Attribute 10';
comment on column lads_cus_hdr.stkzn is 'Natural Person';
comment on column lads_cus_hdr.umsa1 is 'Field of length 16';
comment on column lads_cus_hdr.periv is 'Fiscal Year Variant';
comment on column lads_cus_hdr.ktocd is 'Reference Account Group for One-Time Account (Customer)';
comment on column lads_cus_hdr.fityp is 'Tax type';
comment on column lads_cus_hdr.stcdt is 'Tax Number Type';
comment on column lads_cus_hdr.stcd3 is 'Tax Number 3';
comment on column lads_cus_hdr.stcd4 is 'Tax Number 4';
comment on column lads_cus_hdr.cassd is 'Central sales block for customer';
comment on column lads_cus_hdr.kdkg1 is 'Customer condition group 1';
comment on column lads_cus_hdr.kdkg2 is 'Customer condition group 2';
comment on column lads_cus_hdr.kdkg3 is 'Customer condition group 3';
comment on column lads_cus_hdr.kdkg4 is 'Customer condition group 4';
comment on column lads_cus_hdr.kdkg5 is 'Customer condition group 5';
comment on column lads_cus_hdr.nodel is 'Central deletion block for master record';
comment on column lads_cus_hdr.xsub2 is 'Customer group for Substituiçao Tributária calculation';
comment on column lads_cus_hdr.werks is 'Plant';
comment on column lads_cus_hdr.zzcustom01 is 'Character field length 1';
comment on column lads_cus_hdr.zzkatr13 is 'Customer Master Custom Additional Attribute  13 POS Place';
comment on column lads_cus_hdr.zzkatr14 is 'Customer Master Custom Additional Attribute   14 POS Format';
comment on column lads_cus_hdr.j_1kfrepre is 'Name of Representative';
comment on column lads_cus_hdr.j_1kftbus is 'Type of Business';
comment on column lads_cus_hdr.j_1kftind is 'Type of Industry';
comment on column lads_cus_hdr.psois is 'Subledger acct preprocessing procedure';
comment on column lads_cus_hdr.katr1 is 'Country Region';
comment on column lads_cus_hdr.zzcuststat is 'Customer status code';
comment on column lads_cus_hdr.zzretstore is 'Retail Store Number';
comment on column lads_cus_hdr.locco is 'Location Code';
comment on column lads_cus_hdr.zzdemplan is 'Demand Planning Group Name';
comment on column lads_cus_hdr.idoc_name is 'IDOC name';
comment on column lads_cus_hdr.idoc_number is 'IDOC number';
comment on column lads_cus_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_cus_hdr.lads_date is 'LADS date loaded';
comment on column lads_cus_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_cus_hdr
   add constraint lads_cus_hdr_pk primary key (kunnr);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_cus_hdr to lads_app;
grant select, insert, update, delete on lads_cus_hdr to ics_app;
grant select on lads_cus_hdr to ics_reader;
grant select on lads_cus_hdr to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_cus_hdr for lads.lads_cus_hdr;
