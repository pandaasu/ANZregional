/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_prc_lst_hdr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_prc_lst_hdr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created 
 2005/04   Linden Glen    Flattened LADS_PRC_LST_DAT into this table
                          Fields added (DATAB, DATBI, KNUMH, KOSRT,
                          KZUST, KNUMA_SD)
                          Primary key now includes KNUMH
 2005/05   Linden Glen    Primary key now includes DATAB
                         

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_prc_lst_hdr
   (vakey                                        varchar2(50 char)                   not null,
    anzsn                                        number                              null,
    vkorg                                        varchar2(4 char)                    null,
    evrtp                                        number                              null,
    kappl                                        varchar2(2 char)                    null,
    kotabnr                                      number                              null,
    kschl                                        varchar2(4 char)                    not null,
    kvewe                                        varchar2(1 char)                    null,
    matnr                                        varchar2(18 char)                   null,
    posnr                                        number                              null,
    vtweg                                        varchar2(2 char)                    null,
    spart                                        varchar2(2 char)                    null,
    kunnr                                        varchar2(10 char)                   null,
    kdgrp                                        varchar2(2 char)                    null,
    pltyp                                        varchar2(2 char)                    null,
    konda                                        varchar2(2 char)                    null,
    kondm                                        varchar2(2 char)                    null,
    waerk                                        varchar2(5 char)                    null,
    bwtar                                        varchar2(10 char)                   null,
    charg                                        varchar2(10 char)                   null,
    prodh                                        varchar2(18 char)                   null,
    meins                                        varchar2(3 char)                    null,
    bonus                                        varchar2(2 char)                    null,
    ebonu                                        varchar2(2 char)                    null,
    provg                                        varchar2(2 char)                    null,
    aland                                        varchar2(3 char)                    null,
    wkreg                                        varchar2(3 char)                    null,
    wkcou                                        varchar2(3 char)                    null,
    wkcty                                        varchar2(4 char)                    null,
    lland                                        varchar2(3 char)                    null,
    regio                                        varchar2(3 char)                    null,
    counc                                        varchar2(3 char)                    null,
    cityc                                        varchar2(4 char)                    null,
    taxm1                                        varchar2(1 char)                    null,
    taxm2                                        varchar2(1 char)                    null,
    taxm3                                        varchar2(1 char)                    null,
    taxm4                                        varchar2(1 char)                    null,
    taxm5                                        varchar2(1 char)                    null,
    taxm6                                        varchar2(1 char)                    null,
    taxm7                                        varchar2(1 char)                    null,
    taxm8                                        varchar2(1 char)                    null,
    taxm9                                        varchar2(1 char)                    null,
    taxk1                                        varchar2(1 char)                    null,
    taxk2                                        varchar2(1 char)                    null,
    taxk3                                        varchar2(1 char)                    null,
    taxk4                                        varchar2(1 char)                    null,
    taxk5                                        varchar2(1 char)                    null,
    taxk6                                        varchar2(1 char)                    null,
    taxk7                                        varchar2(1 char)                    null,
    taxk8                                        varchar2(1 char)                    null,
    taxk9                                        varchar2(1 char)                    null,
    lifnr                                        varchar2(10 char)                   null,
    matkl                                        varchar2(9 char)                    null,
    ekorg                                        varchar2(4 char)                    null,
    esokz                                        varchar2(1 char)                    null,
    werks                                        varchar2(4 char)                    null,
    reswk                                        varchar2(4 char)                    null,
    kolif                                        varchar2(10 char)                   null,
    ltsnr                                        varchar2(6 char)                    null,
    wglif                                        varchar2(18 char)                   null,
    mwskz                                        varchar2(2 char)                    null,
    werkv                                        varchar2(4 char)                    null,
    wagrp                                        varchar2(9 char)                    null,
    vrkme                                        varchar2(3 char)                    null,
    ean11                                        varchar2(18 char)                   null,
    eannr                                        varchar2(13 char)                   null,
    auart                                        varchar2(4 char)                    null,
    meein                                        varchar2(3 char)                    null,
    infnr                                        varchar2(10 char)                   null,
    evrtn                                        varchar2(10 char)                   null,
    inco1                                        varchar2(3 char)                    null,
    inco2                                        varchar2(28 char)                   null,
    bukrs                                        varchar2(4 char)                    null,
    mtart                                        varchar2(4 char)                    null,
    lifre                                        varchar2(10 char)                   null,
    ekkol                                        varchar2(4 char)                    null,
    ekkoa                                        varchar2(4 char)                    null,
    bstme                                        varchar2(3 char)                    null,
    wghie                                        varchar2(18 char)                   null,
    taxim                                        varchar2(1 char)                    null,
    taxik                                        varchar2(1 char)                    null,
    taxiw                                        varchar2(1 char)                    null,
    taxil                                        varchar2(1 char)                    null,
    taxir                                        varchar2(1 char)                    null,
    txjcd                                        varchar2(15 char)                   null,
    fkart                                        varchar2(4 char)                    null,
    vkorgau                                      varchar2(4 char)                    null,
    hienr                                        varchar2(10 char)                   null,
    varcond                                      varchar2(26 char)                   null,
    land1                                        varchar2(3 char)                    null,
    zterm                                        varchar2(4 char)                    null,
    gzolx                                        varchar2(4 char)                    null,
    vbeln                                        varchar2(10 char)                   null,
    upmat                                        varchar2(18 char)                   null,
    ukonm                                        varchar2(2 char)                    null,
    auart_sd                                     varchar2(4 char)                    null,
    prodh1                                       varchar2(5 char)                    null,
    prodh2                                       varchar2(5 char)                    null,
    prodh3                                       varchar2(8 char)                    null,
    bzirk                                        varchar2(6 char)                    null,
    vkgrp                                        varchar2(3 char)                    null,
    brsch                                        varchar2(4 char)                    null,
    vkbur                                        varchar2(4 char)                    null,
    prctr                                        varchar2(10 char)                   null,
    lhienr                                       varchar2(10 char)                   null,
    kdkgr                                        varchar2(2 char)                    null,
    bstyp                                        varchar2(1 char)                    null,
    bsart                                        varchar2(4 char)                    null,
    ekgrp                                        varchar2(3 char)                    null,
    aktnr                                        varchar2(10 char)                   null,
    srvpos                                       varchar2(18 char)                   null,
    pstyp                                        varchar2(1 char)                    null,
    hland                                        varchar2(3 char)                    null,
    ausfu                                        varchar2(10 char)                   null,
    herkl                                        varchar2(3 char)                    null,
    verld                                        varchar2(3 char)                    null,
    coimp                                        varchar2(17 char)                   null,
    stawn                                        varchar2(17 char)                   null,
    casnr                                        varchar2(15 char)                   null,
    exprf                                        varchar2(8 char)                    null,
    cokon                                        varchar2(6 char)                    null,
    copha                                        varchar2(6 char)                    null,
    coadi                                        varchar2(6 char)                    null,
    herse                                        varchar2(10 char)                   null,
    ktnum                                        varchar2(10 char)                   null,
    plnum                                        varchar2(10 char)                   null,
    prefa                                        varchar2(10 char)                   null,
    eilgr                                        varchar2(10 char)                   null,
    upsnam                                       varchar2(20 char)                   null,
    orgnam                                       varchar2(20 char)                   null,
    mestyp                                       varchar2(30 char)                   null,
    objid                                        varchar2(120 char)                  null,
    objval                                       varchar2(20 char)                   null,
    datab                                        varchar2(8 char)                    not null,
    datbi                                        varchar2(8 char)                    null,
    knumh                                        varchar2(10 char)                   not null,
    kosrt                                        varchar2(10 char)                   null,
    kzust                                        varchar2(3 char)                    null,
    knuma_sd                                     varchar2(10 char)                   null,
    idoc_name                                    varchar2(30 char)                   not null,
    idoc_number                                  number(16,0)                        not null,
    idoc_timestamp                               varchar2(14 char)                   not null,
    lads_date                                    date                                not null,
    lads_status                                  varchar2(2 char)                    not null);

/**/
/* Comments
/**/
comment on table lads_prc_lst_hdr is 'LADS Price List Header';
comment on column lads_prc_lst_hdr.vakey is 'Variable key 50 bytes';
comment on column lads_prc_lst_hdr.anzsn is 'Number of serial numbers';
comment on column lads_prc_lst_hdr.vkorg is 'Sales Organization';
comment on column lads_prc_lst_hdr.evrtp is 'Item Number of Purchasing Document';
comment on column lads_prc_lst_hdr.kappl is 'Application';
comment on column lads_prc_lst_hdr.kotabnr is 'Condition table';
comment on column lads_prc_lst_hdr.kschl is 'Condition type';
comment on column lads_prc_lst_hdr.kvewe is 'Usage of the condition table';
comment on column lads_prc_lst_hdr.matnr is 'Material Number';
comment on column lads_prc_lst_hdr.posnr is 'Item number of the SD document';
comment on column lads_prc_lst_hdr.vtweg is 'Distribution Channel';
comment on column lads_prc_lst_hdr.spart is 'Division';
comment on column lads_prc_lst_hdr.kunnr is 'Customer number';
comment on column lads_prc_lst_hdr.kdgrp is 'Customer group';
comment on column lads_prc_lst_hdr.pltyp is 'Price list type';
comment on column lads_prc_lst_hdr.konda is 'Price group (customer)';
comment on column lads_prc_lst_hdr.kondm is 'Material pricing group';
comment on column lads_prc_lst_hdr.waerk is 'SD document currency';
comment on column lads_prc_lst_hdr.bwtar is 'Valuation Type';
comment on column lads_prc_lst_hdr.charg is 'Batch Number';
comment on column lads_prc_lst_hdr.prodh is 'Product hierarchy';
comment on column lads_prc_lst_hdr.meins is 'Base Unit of Measure';
comment on column lads_prc_lst_hdr.bonus is 'Volume rebate group';
comment on column lads_prc_lst_hdr.ebonu is 'Settlement group 1 (Purchasing)';
comment on column lads_prc_lst_hdr.provg is 'Commission group';
comment on column lads_prc_lst_hdr.aland is 'Departure country (country from which the goods are sent)';
comment on column lads_prc_lst_hdr.wkreg is 'Region in which plant is located';
comment on column lads_prc_lst_hdr.wkcou is 'County in which plant is located';
comment on column lads_prc_lst_hdr.wkcty is 'City in which plant is located';
comment on column lads_prc_lst_hdr.lland is 'Destination country';
comment on column lads_prc_lst_hdr.regio is '"Region (State, Province, County)"';
comment on column lads_prc_lst_hdr.counc is 'County Code';
comment on column lads_prc_lst_hdr.cityc is 'City Code';
comment on column lads_prc_lst_hdr.taxm1 is 'Tax classification material';
comment on column lads_prc_lst_hdr.taxm2 is 'Tax classification 2 for material';
comment on column lads_prc_lst_hdr.taxm3 is 'Tax classification 3 for material';
comment on column lads_prc_lst_hdr.taxm4 is 'Tax classification 4 for material';
comment on column lads_prc_lst_hdr.taxm5 is 'Tax classification 5 for material';
comment on column lads_prc_lst_hdr.taxm6 is 'Tax classification 6 for material';
comment on column lads_prc_lst_hdr.taxm7 is 'Tax classification 7 for material';
comment on column lads_prc_lst_hdr.taxm8 is 'Tax classification 8 for material';
comment on column lads_prc_lst_hdr.taxm9 is 'Tax classification 9 for material';
comment on column lads_prc_lst_hdr.taxk1 is 'Tax classification 1 for customer';
comment on column lads_prc_lst_hdr.taxk2 is 'Tax classification 2 for customer';
comment on column lads_prc_lst_hdr.taxk3 is 'Tax classification 3 for customer';
comment on column lads_prc_lst_hdr.taxk4 is 'Tax classification 4 for customer';
comment on column lads_prc_lst_hdr.taxk5 is 'Tax classification 5 for customer';
comment on column lads_prc_lst_hdr.taxk6 is 'Tax classification 6 for customer';
comment on column lads_prc_lst_hdr.taxk7 is 'Tax classification 7 for customer';
comment on column lads_prc_lst_hdr.taxk8 is 'Tax classification 8 for customer';
comment on column lads_prc_lst_hdr.taxk9 is 'Tax classification 9 for customer';
comment on column lads_prc_lst_hdr.lifnr is 'Account Number of Vendor or Creditor';
comment on column lads_prc_lst_hdr.matkl is 'Material Group';
comment on column lads_prc_lst_hdr.ekorg is 'Purchasing Organization';
comment on column lads_prc_lst_hdr.esokz is 'Purchasing info record category';
comment on column lads_prc_lst_hdr.werks is 'Plant';
comment on column lads_prc_lst_hdr.reswk is 'Supplying (issuing) plant in case of stock transport order';
comment on column lads_prc_lst_hdr.kolif is 'Prior vendor';
comment on column lads_prc_lst_hdr.ltsnr is 'Vendor Sub-Range';
comment on column lads_prc_lst_hdr.wglif is 'Vendor material group';
comment on column lads_prc_lst_hdr.mwskz is 'Tax on sales/purchases code';
comment on column lads_prc_lst_hdr.werkv is 'Resale plant';
comment on column lads_prc_lst_hdr.wagrp is 'Material group';
comment on column lads_prc_lst_hdr.vrkme is 'Sales unit';
comment on column lads_prc_lst_hdr.ean11 is 'International Article Number (EAN/UPC)';
comment on column lads_prc_lst_hdr.eannr is 'European Article Number (EAN) - obsolete!!!!!';
comment on column lads_prc_lst_hdr.auart is 'Order Type';
comment on column lads_prc_lst_hdr.meein is 'Unit of measure of a purchased material';
comment on column lads_prc_lst_hdr.infnr is 'Number of purchasing info record';
comment on column lads_prc_lst_hdr.evrtn is 'Purchasing Document Number';
comment on column lads_prc_lst_hdr.inco1 is 'Incoterms (part 1)';
comment on column lads_prc_lst_hdr.inco2 is 'Incoterms (part 2)';
comment on column lads_prc_lst_hdr.bukrs is 'Company Code';
comment on column lads_prc_lst_hdr.mtart is 'Material Type';
comment on column lads_prc_lst_hdr.lifre is 'Different invoicing party';
comment on column lads_prc_lst_hdr.ekkol is 'Condition group with vendor';
comment on column lads_prc_lst_hdr.ekkoa is 'Condition group in case of different vendor';
comment on column lads_prc_lst_hdr.bstme is 'Order unit';
comment on column lads_prc_lst_hdr.wghie is 'Material group hierarchy';
comment on column lads_prc_lst_hdr.taxim is 'Tax indicator for material (Purchasing)';
comment on column lads_prc_lst_hdr.taxik is 'Tax indicator: Account assignment (Purchasing)';
comment on column lads_prc_lst_hdr.taxiw is 'Tax indicator: Plant (Purchasing)';
comment on column lads_prc_lst_hdr.taxil is 'Tax indicator: Import';
comment on column lads_prc_lst_hdr.taxir is 'Tax indicator: Region (Intrastat)';
comment on column lads_prc_lst_hdr.txjcd is 'Jurisdiction for Tax Calculation - Tax Jurisdiction Code';
comment on column lads_prc_lst_hdr.fkart is 'Billing Type';
comment on column lads_prc_lst_hdr.vkorgau is 'Sales organization of sales order';
comment on column lads_prc_lst_hdr.hienr is 'Customer';
comment on column lads_prc_lst_hdr.varcond is 'Variant condition';
comment on column lads_prc_lst_hdr.land1 is 'Country Key';
comment on column lads_prc_lst_hdr.zterm is 'Terms of payment key';
comment on column lads_prc_lst_hdr.gzolx is 'Preference zone';
comment on column lads_prc_lst_hdr.vbeln is 'Sales and Distribution Document Number';
comment on column lads_prc_lst_hdr.upmat is 'Pricing reference material of main item';
comment on column lads_prc_lst_hdr.ukonm is 'Material pricing group of main item';
comment on column lads_prc_lst_hdr.auart_sd is 'Sales Document Type';
comment on column lads_prc_lst_hdr.prodh1 is 'Data Element ID_PRODH1';
comment on column lads_prc_lst_hdr.prodh2 is 'Data Element ID_PRODH2';
comment on column lads_prc_lst_hdr.prodh3 is 'Data Element ID_PRODH3';
comment on column lads_prc_lst_hdr.bzirk is 'Sales district';
comment on column lads_prc_lst_hdr.vkgrp is 'Sales group';
comment on column lads_prc_lst_hdr.brsch is 'Industry key';
comment on column lads_prc_lst_hdr.vkbur is 'Sales office';
comment on column lads_prc_lst_hdr.prctr is 'Profit Center';
comment on column lads_prc_lst_hdr.lhienr is 'Vendor number of vendor hierarchy';
comment on column lads_prc_lst_hdr.kdkgr is 'Customer attribute for condition group';
comment on column lads_prc_lst_hdr.bstyp is 'Purchasing document category';
comment on column lads_prc_lst_hdr.bsart is 'Order type (Purchasing)';
comment on column lads_prc_lst_hdr.ekgrp is 'Purchasing Group';
comment on column lads_prc_lst_hdr.aktnr is 'Promotion';
comment on column lads_prc_lst_hdr.srvpos is 'Service Number';
comment on column lads_prc_lst_hdr.pstyp is 'Item Category';
comment on column lads_prc_lst_hdr.hland is 'Delivering country';
comment on column lads_prc_lst_hdr.ausfu is 'Exporter for import processing in foreign trade';
comment on column lads_prc_lst_hdr.herkl is 'Country of origin of the material';
comment on column lads_prc_lst_hdr.verld is 'Country of dispatch for Foreign Trade';
comment on column lads_prc_lst_hdr.coimp is 'Code number for import processing in foreign trade';
comment on column lads_prc_lst_hdr.stawn is 'Commodity code / Import code number for foreign trade';
comment on column lads_prc_lst_hdr.casnr is 'CAS number for pharmaceutical products in foreign trade';
comment on column lads_prc_lst_hdr.exprf is 'Export/Import Procedure for Foreign Trade';
comment on column lads_prc_lst_hdr.cokon is 'Customs quota code for import processing in foreign trade';
comment on column lads_prc_lst_hdr.copha is 'Pharmaceutical products code (Foreign Trade)';
comment on column lads_prc_lst_hdr.coadi is 'Anti-dumping code for import processing in foreign trade';
comment on column lads_prc_lst_hdr.herse is 'Manufacturer number for import processing in foreign trade';
comment on column lads_prc_lst_hdr.ktnum is 'Quota or Ceiling Number for Import Processing';
comment on column lads_prc_lst_hdr.plnum is 'Quota or Ceiling Number for Import Processing';
comment on column lads_prc_lst_hdr.prefa is 'Preference: Preference type for foreign trade';
comment on column lads_prc_lst_hdr.eilgr is 'Country Groups for Import Processing in Foreign Trade';
comment on column lads_prc_lst_hdr.upsnam is 'ALE Distribution Package: Name';
comment on column lads_prc_lst_hdr.orgnam is 'ALE Distribution Packet : Original Packet Name';
comment on column lads_prc_lst_hdr.mestyp is 'Message type';
comment on column lads_prc_lst_hdr.objid is 'ALE Distribution Package: Object Key';
comment on column lads_prc_lst_hdr.objval is 'ALE Distribution Package: Object Validity';
comment on column lads_prc_lst_hdr.datab is 'Valid-From Date';
comment on column lads_prc_lst_hdr.datbi is 'Valid To Date';
comment on column lads_prc_lst_hdr.knumh is 'Condition record number';
comment on column lads_prc_lst_hdr.kosrt is 'Search term for conditions';
comment on column lads_prc_lst_hdr.kzust is 'Responsibility in SD for condition/material';
comment on column lads_prc_lst_hdr.knuma_sd is 'Standard agreement';
comment on column lads_prc_lst_hdr.idoc_name is 'IDOC name';
comment on column lads_prc_lst_hdr.idoc_number is 'IDOC number';
comment on column lads_prc_lst_hdr.idoc_timestamp is 'IDOC timestamp';
comment on column lads_prc_lst_hdr.lads_date is 'LADS date loaded';
comment on column lads_prc_lst_hdr.lads_status is 'LADS status (1=valid, 2=error, 3=orphan)';

/**/
/* Primary Key Constraint
/**/
alter table lads_prc_lst_hdr
   add constraint lads_prc_lst_hdr_pk primary key (vakey, kschl, datab, knumh);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_prc_lst_hdr to lads_app;
grant select, insert, update, delete on lads_prc_lst_hdr to ics_app;
grant select on lads_prc_lst_hdr to site_app;
grant select on lads_prc_lst_hdr to ics_reader;

/**/
/* Synonym
/**/
create or replace public synonym lads_prc_lst_hdr for lads.lads_prc_lst_hdr;
