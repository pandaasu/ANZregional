/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_ftd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_ftd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_ftd
   (belnr                                        varchar2(35 char)                   not null,
    ftdseq                                       number                              not null,
    exnum                                        varchar2(10 char)                   null,
    aland                                        varchar2(3 char)                    null,
    expvz                                        varchar2(1 char)                    null,
    zolla                                        varchar2(6 char)                    null,
    zollb                                        varchar2(6 char)                    null,
    zoll1                                        varchar2(6 char)                    null,
    zoll2                                        varchar2(6 char)                    null,
    zoll3                                        varchar2(6 char)                    null,
    zoll4                                        varchar2(6 char)                    null,
    zoll5                                        varchar2(6 char)                    null,
    zoll6                                        varchar2(6 char)                    null,
    kzgbe                                        varchar2(30 char)                   null,
    kzabe                                        varchar2(30 char)                   null,
    stgbe                                        varchar2(3 char)                    null,
    stabe                                        varchar2(3 char)                    null,
    conta                                        varchar2(1 char)                    null,
    grwcu                                        varchar2(5 char)                    null,
    grwrt                                        varchar2(18 char)                   null,
    land1                                        varchar2(3 char)                    null,
    landx                                        varchar2(15 char)                   null,
    landa                                        varchar2(3 char)                    null,
    xegld                                        varchar2(1 char)                    null,
    freih                                        varchar2(1 char)                    null,
    ewrco                                        varchar2(1 char)                    null,
    usc05                                        varchar2(5 char)                    null,
    jap05                                        varchar2(5 char)                    null,
    alanx                                        varchar2(15 char)                   null,
    alana                                        varchar2(3 char)                    null,
    lasta                                        varchar2(3 char)                    null,
    lastg                                        varchar2(3 char)                    null,
    alsch                                        varchar2(3 char)                    null,
    alsre                                        varchar2(5 char)                    null,
    ladeo                                        varchar2(15 char)                   null,
    iever                                        varchar2(1 char)                    null,
    banr01                                       varchar2(16 char)                   null,
    banr02                                       varchar2(3 char)                    null,
    banr03                                       varchar2(7 char)                    null,
    banr04                                       varchar2(7 char)                    null,
    banr05                                       varchar2(7 char)                    null,
    banr06                                       varchar2(7 char)                    null,
    banr07                                       varchar2(7 char)                    null,
    banr08                                       varchar2(7 char)                    null,
    banr09                                       varchar2(3 char)                    null,
    banr10                                       varchar2(8 char)                    null,
    wzocu                                        varchar2(5 char)                    null,
    expvztx                                      varchar2(20 char)                   null,
    zollatx                                      varchar2(30 char)                   null,
    zollbtx                                      varchar2(30 char)                   null,
    stgbetx                                      varchar2(15 char)                   null,
    stabetx                                      varchar2(15 char)                   null,
    freihtx                                      varchar2(20 char)                   null,
    ladel                                        varchar2(40 char)                   null,
    text1                                        varchar2(40 char)                   null,
    text2                                        varchar2(40 char)                   null,
    text3                                        varchar2(40 char)                   null,
    gbnum                                        varchar2(20 char)                   null,
    regnr                                        varchar2(20 char)                   null,
    ausfu                                        varchar2(10 char)                   null,
    iever_tx                                     varchar2(20 char)                   null,
    lazl1                                        varchar2(3 char)                    null,
    lazl2                                        varchar2(3 char)                    null,
    lazl3                                        varchar2(3 char)                    null,
    lazl4                                        varchar2(3 char)                    null,
    lazl5                                        varchar2(3 char)                    null,
    lazl6                                        varchar2(3 char)                    null,
    azoll                                        varchar2(6 char)                    null,
    azolltx                                      varchar2(30 char)                   null,
    bfmar                                        varchar2(6 char)                    null,
    ftvbd                                        varchar2(1 char)                    null,
    cudcl                                        varchar2(3 char)                    null,
    ftupd                                        varchar2(1 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_ftd is 'LADS Invoice Foreign Trade Data';
comment on column lads_inv_ftd.belnr is 'IDOC document number';
comment on column lads_inv_ftd.ftdseq is 'FTD - generated sequence number';
comment on column lads_inv_ftd.exnum is 'Number of foreign trade data in MM and SD documents';
comment on column lads_inv_ftd.aland is 'Departure country (country from which the goods are sent)';
comment on column lads_inv_ftd.expvz is 'Mode of Transport for Foreign Trade';
comment on column lads_inv_ftd.zolla is 'Customs office: Office of exit for foreign trade';
comment on column lads_inv_ftd.zollb is 'Customs office: Office of destination for foreign trade';
comment on column lads_inv_ftd.zoll1 is 'Customs office: Customs office 1 for foreign trade';
comment on column lads_inv_ftd.zoll2 is 'Customs office: Customs office 2 for foreign trade';
comment on column lads_inv_ftd.zoll3 is 'Customs office: Customs office 3 for foreign trade';
comment on column lads_inv_ftd.zoll4 is 'Customs office: Customs office 4 for foreign trade';
comment on column lads_inv_ftd.zoll5 is 'Customs office: Customs office 5 for foreign trade';
comment on column lads_inv_ftd.zoll6 is 'Customs office: Customs office 6 for foreign trade';
comment on column lads_inv_ftd.kzgbe is 'Indicator for means of transport crossing the border';
comment on column lads_inv_ftd.kzabe is 'Indicator for the means of transport at departure';
comment on column lads_inv_ftd.stgbe is 'Origin of Means of Transport when Crossing the Border';
comment on column lads_inv_ftd.stabe is 'Country of Origin of the Means of Transport at Departure';
comment on column lads_inv_ftd.conta is 'ID: Goods cross border in a container';
comment on column lads_inv_ftd.grwcu is 'Currency of statistical values for foreign trade';
comment on column lads_inv_ftd.grwrt is 'Total value of sum segment';
comment on column lads_inv_ftd.land1 is 'Country Key';
comment on column lads_inv_ftd.landx is 'Country Name';
comment on column lads_inv_ftd.landa is 'Alternative Country Key';
comment on column lads_inv_ftd.xegld is 'Indicator: European Union Member?';
comment on column lads_inv_ftd.freih is 'Indicator: Free Trade Area for Legal Control';
comment on column lads_inv_ftd.ewrco is 'ID: European Economic Area (rel. for export control)';
comment on column lads_inv_ftd.usc05 is 'USA: Five-Digit Country Code (SED: Schedule C Code)';
comment on column lads_inv_ftd.jap05 is 'Japan: Five digit country code (MITI customs declaration)';
comment on column lads_inv_ftd.alanx is 'Country of dispatch - Description';
comment on column lads_inv_ftd.alana is 'Alternative country key for country of dispatch/export';
comment on column lads_inv_ftd.lasta is 'Alt. key to nationality of means of transport (departarture)';
comment on column lads_inv_ftd.lastg is 'Alt. key for nationality of means of transport at border';
comment on column lads_inv_ftd.alsch is 'Alternative country key for sold-to party';
comment on column lads_inv_ftd.alsre is 'Currency code by country directory';
comment on column lads_inv_ftd.ladeo is 'Place of loading';
comment on column lads_inv_ftd.iever is 'Domestic Mode of Transport for Foreign Trade';
comment on column lads_inv_ftd.banr01 is 'FT-EDI: Declarations to the authorities - ID no. 01';
comment on column lads_inv_ftd.banr02 is 'FT-EDI: Declarations to the authorities: ID no.';
comment on column lads_inv_ftd.banr03 is 'Customs number of exporter';
comment on column lads_inv_ftd.banr04 is 'Customs number of exporter';
comment on column lads_inv_ftd.banr05 is 'Customs number of exporter';
comment on column lads_inv_ftd.banr06 is 'Customs number of exporter';
comment on column lads_inv_ftd.banr07 is 'Customs number of exporter';
comment on column lads_inv_ftd.banr08 is 'Customs number of exporter';
comment on column lads_inv_ftd.banr09 is 'FT-EDI: Declarations to the authorities: ID no.';
comment on column lads_inv_ftd.banr10 is 'FT-EDI: Declarations to the authorities - ID no. 10';
comment on column lads_inv_ftd.wzocu is 'Currency of customs values for import procg in foreign trade';
comment on column lads_inv_ftd.expvztx is 'Description';
comment on column lads_inv_ftd.zollatx is 'Customs Description 1';
comment on column lads_inv_ftd.zollbtx is 'Customs Description 2';
comment on column lads_inv_ftd.stgbetx is 'Country Name';
comment on column lads_inv_ftd.stabetx is 'Country Name';
comment on column lads_inv_ftd.freihtx is 'Free Trade Description';
comment on column lads_inv_ftd.ladel is 'Place of loading/unloading for foreign trade';
comment on column lads_inv_ftd.text1 is 'Comments: Text for foreign trade processing';
comment on column lads_inv_ftd.text2 is 'Comments: Text for foreign trade processing';
comment on column lads_inv_ftd.text3 is 'Comments: Text for foreign trade processing';
comment on column lads_inv_ftd.gbnum is 'Foreign Trade:Customs declaration list no. for Foreign Trade';
comment on column lads_inv_ftd.regnr is 'Registration number for import processing in foreign trade';
comment on column lads_inv_ftd.ausfu is 'Exporter for import processing in foreign trade';
comment on column lads_inv_ftd.iever_tx is 'Domestic Mode Of Transp Description';
comment on column lads_inv_ftd.lazl1 is 'Customs office: Country of customs office for foreign trade';
comment on column lads_inv_ftd.lazl2 is 'Customs office: Country of customs office for foreign trade';
comment on column lads_inv_ftd.lazl3 is 'Customs office: Country of customs office for foreign trade';
comment on column lads_inv_ftd.lazl4 is 'Customs office: Country of customs office for foreign trade';
comment on column lads_inv_ftd.lazl5 is 'Customs office: Country of customs office for foreign trade';
comment on column lads_inv_ftd.lazl6 is 'Customs office: Country of customs office for foreign trade';
comment on column lads_inv_ftd.azoll is 'Customs office: Export customs office for foreign trade';
comment on column lads_inv_ftd.azolltx is 'Description';
comment on column lads_inv_ftd.bfmar is 'Foreign Trade: Type of means of transport';
comment on column lads_inv_ftd.ftvbd is 'Association Indicator for Foreign Trade';
comment on column lads_inv_ftd.cudcl is 'Customs declaration type for customs processing in FT';
comment on column lads_inv_ftd.ftupd is 'Data service update indicator - Foreign Trade';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_ftd
   add constraint lads_inv_ftd_pk primary key (belnr, ftdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_ftd to lads_app;
grant select, insert, update, delete on lads_inv_ftd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_ftd for lads.lads_inv_ftd;
