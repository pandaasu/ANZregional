/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_ift
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_ift

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_ift
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    iftseq                                       number                              not null,
    exnum                                        varchar2(10 char)                   null,
    expos                                        number                              null,
    stawn                                        varchar2(17 char)                   null,
    exprf                                        varchar2(5 char)                    null,
    exart                                        varchar2(2 char)                    null,
    herkl                                        varchar2(3 char)                    null,
    herkr                                        varchar2(3 char)                    null,
    herta                                        varchar2(3 char)                    null,
    herti                                        varchar2(15 char)                   null,
    stxt1                                        varchar2(40 char)                   null,
    stxt2                                        varchar2(40 char)                   null,
    stxt3                                        varchar2(40 char)                   null,
    stxt4                                        varchar2(40 char)                   null,
    stxt5                                        varchar2(40 char)                   null,
    stxt6                                        varchar2(40 char)                   null,
    stxt7                                        varchar2(40 char)                   null,
    bemas                                        varchar2(5 char)                    null,
    prefe                                        varchar2(1 char)                    null,
    bolnr                                        varchar2(35 char)                   null,
    traty                                        varchar2(4 char)                    null,
    traid                                        varchar2(20 char)                   null,
    brulo                                        varchar2(18 char)                   null,
    netlo                                        varchar2(18 char)                   null,
    vemeh                                        varchar2(3 char)                    null,
    herbl                                        varchar2(2 char)                    null,
    bmgew                                        varchar2(18 char)                   null,
    text1                                        varchar2(40 char)                   null,
    text2                                        varchar2(40 char)                   null,
    text3                                        varchar2(40 char)                   null,
    coimp                                        varchar2(17 char)                   null,
    coadi                                        varchar2(6 char)                    null,
    cokon                                        varchar2(6 char)                    null,
    copha                                        varchar2(6 char)                    null,
    casnr                                        varchar2(15 char)                   null,
    verld                                        varchar2(3 char)                    null,
    verld_tx                                     varchar2(15 char)                   null,
    hanld                                        varchar2(3 char)                    null,
    hanld_tx                                     varchar2(15 char)                   null,
    exprf_tx                                     varchar2(30 char)                   null,
    exart_tx                                     varchar2(30 char)                   null,
    gbnum                                        varchar2(20 char)                   null,
    regnr                                        varchar2(20 char)                   null,
    herse                                        varchar2(10 char)                   null,
    herkr_tx                                     varchar2(20 char)                   null,
    cobld                                        varchar2(17 char)                   null,
    eioka                                        varchar2(1 char)                    null,
    verfa                                        varchar2(8 char)                    null,
    prenc                                        varchar2(1 char)                    null,
    preno                                        varchar2(8 char)                    null,
    prend                                        varchar2(8 char)                    null,
    besma                                        varchar2(3 char)                    null,
    impma                                        varchar2(3 char)                    null,
    ktnum                                        varchar2(10 char)                   null,
    plnum                                        varchar2(10 char)                   null,
    wkreg                                        varchar2(3 char)                    null,
    imgew                                        varchar2(18 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_ift is 'LADS Invoice Item Foreign Trade Data';
comment on column lads_inv_ift.belnr is 'IDOC document number';
comment on column lads_inv_ift.genseq is 'GEN - generated sequence number';
comment on column lads_inv_ift.iftseq is 'IFT - generated sequence number';
comment on column lads_inv_ift.exnum is 'Number of foreign trade data in MM and SD documents';
comment on column lads_inv_ift.expos is 'Internal item number for foreign trade data in MM and SD';
comment on column lads_inv_ift.stawn is 'Commodity code / Import code number for foreign trade';
comment on column lads_inv_ift.exprf is 'Export/Import procedure for foreign trade (5 digits)';
comment on column lads_inv_ift.exart is 'Business Transaction Type for Foreign Trade';
comment on column lads_inv_ift.herkl is 'Country of origin of the material';
comment on column lads_inv_ift.herkr is 'Region of origin of material (non-preferential origin)';
comment on column lads_inv_ift.herta is 'Alternative country key for country of origin';
comment on column lads_inv_ift.herti is 'Description of country of export/dispatch';
comment on column lads_inv_ift.stxt1 is 'Description of commodity code - First line';
comment on column lads_inv_ift.stxt2 is 'Description of commodity code - Second line';
comment on column lads_inv_ift.stxt3 is 'Description of commodity code - Third line';
comment on column lads_inv_ift.stxt4 is 'Description of commodity code - Fourth line';
comment on column lads_inv_ift.stxt5 is 'Description of commodity code - Fifth line';
comment on column lads_inv_ift.stxt6 is 'Description of commodity code - Sixth line';
comment on column lads_inv_ift.stxt7 is 'Description of commodity code - Seventh line';
comment on column lads_inv_ift.bemas is 'Supplementary unit';
comment on column lads_inv_ift.prefe is 'Preference indicator in export/import';
comment on column lads_inv_ift.bolnr is 'Bill of lading';
comment on column lads_inv_ift.traty is 'Means-of-Transport Type';
comment on column lads_inv_ift.traid is 'Means of Transport ID';
comment on column lads_inv_ift.brulo is 'Total weight';
comment on column lads_inv_ift.netlo is 'Net weight';
comment on column lads_inv_ift.vemeh is 'Base Unit of Measure of the Quantity to be Packed (VEMNG)';
comment on column lads_inv_ift.herbl is 'State of manufacture';
comment on column lads_inv_ift.bmgew is 'Total weight';
comment on column lads_inv_ift.text1 is 'Comments: Text for foreign trade processing';
comment on column lads_inv_ift.text2 is 'Comments: Text for foreign trade processing';
comment on column lads_inv_ift.text3 is 'Comments: Text for foreign trade processing';
comment on column lads_inv_ift.coimp is 'Code number for import processing in foreign trade';
comment on column lads_inv_ift.coadi is 'Anti-dumping code for import processing in foreign trade';
comment on column lads_inv_ift.cokon is 'Customs quota code for import processing in foreign trade';
comment on column lads_inv_ift.copha is 'Pharmaceutical products code (Foreign Trade)';
comment on column lads_inv_ift.casnr is 'CAS number for pharmaceutical products in foreign trade';
comment on column lads_inv_ift.verld is 'Country of dispatch for Foreign Trade';
comment on column lads_inv_ift.verld_tx is 'Country Name';
comment on column lads_inv_ift.hanld is 'Trading country for foreign trade';
comment on column lads_inv_ift.hanld_tx is 'Country Name';
comment on column lads_inv_ift.exprf_tx is 'Export/Import Procedure Description';
comment on column lads_inv_ift.exart_tx is 'Business Transaction Type Description';
comment on column lads_inv_ift.gbnum is 'Foreign Trade:Customs declaration list no. for Foreign Trade';
comment on column lads_inv_ift.regnr is 'Registration number for import processing in foreign trade';
comment on column lads_inv_ift.herse is 'Manufacturer number for import processing in foreign trade';
comment on column lads_inv_ift.herkr_tx is 'Regoin Of Origin Description';
comment on column lads_inv_ift.cobld is 'Import code no. in destination country for foreign trade';
comment on column lads_inv_ift.eioka is 'EDI: Export/Import customs tariff number for foreign trade';
comment on column lads_inv_ift.verfa is 'Export/Import Procedure for Foreign Trade';
comment on column lads_inv_ift.prenc is 'Exemption certificate: Indicator for legal control';
comment on column lads_inv_ift.preno is 'Exemption certificate number for legal control';
comment on column lads_inv_ift.prend is 'Exemption certificate: Issue date of exemption certificate';
comment on column lads_inv_ift.besma is 'Supplementary unit';
comment on column lads_inv_ift.impma is 'Second unit of measurement';
comment on column lads_inv_ift.ktnum is 'Quota or Ceiling Number for Import Processing';
comment on column lads_inv_ift.plnum is 'Quota or Ceiling Number for Import Processing';
comment on column lads_inv_ift.wkreg is 'Region in which plant is located';
comment on column lads_inv_ift.imgew is 'Net weight';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_ift
   add constraint lads_inv_ift_pk primary key (belnr, genseq, iftseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_ift to lads_app;
grant select, insert, update, delete on lads_inv_ift to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_ift for lads.lads_inv_ift;
