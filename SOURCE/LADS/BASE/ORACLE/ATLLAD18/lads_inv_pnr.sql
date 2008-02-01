/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_pnr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_pnr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_pnr
   (belnr                                        varchar2(35 char)                   not null,
    pnrseq                                       number                              not null,
    parvw                                        varchar2(3 char)                    null,
    partn                                        varchar2(17 char)                   null,
    lifnr                                        varchar2(17 char)                   null,
    name1                                        varchar2(35 char)                   null,
    name2                                        varchar2(35 char)                   null,
    name3                                        varchar2(35 char)                   null,
    name4                                        varchar2(35 char)                   null,
    stras                                        varchar2(35 char)                   null,
    strs2                                        varchar2(35 char)                   null,
    pfach                                        varchar2(35 char)                   null,
    ort01                                        varchar2(35 char)                   null,
    counc                                        varchar2(9 char)                    null,
    pstlz                                        varchar2(9 char)                    null,
    pstl2                                        varchar2(9 char)                    null,
    land1                                        varchar2(3 char)                    null,
    ablad                                        varchar2(35 char)                   null,
    pernr                                        varchar2(30 char)                   null,
    parnr                                        varchar2(30 char)                   null,
    telf1                                        varchar2(25 char)                   null,
    telf2                                        varchar2(25 char)                   null,
    telbx                                        varchar2(25 char)                   null,
    telfx                                        varchar2(25 char)                   null,
    teltx                                        varchar2(25 char)                   null,
    telx1                                        varchar2(25 char)                   null,
    spras                                        varchar2(1 char)                    null,
    anred                                        varchar2(15 char)                   null,
    ort02                                        varchar2(35 char)                   null,
    hausn                                        varchar2(6 char)                    null,
    stock                                        varchar2(6 char)                    null,
    regio                                        varchar2(3 char)                    null,
    parge                                        varchar2(1 char)                    null,
    isoal                                        varchar2(2 char)                    null,
    isonu                                        varchar2(2 char)                    null,
    fcode                                        varchar2(20 char)                   null,
    ihrez                                        varchar2(30 char)                   null,
    bname                                        varchar2(35 char)                   null,
    paorg                                        varchar2(30 char)                   null,
    orgtx                                        varchar2(35 char)                   null,
    pagru                                        varchar2(30 char)                   null,
    knref                                        varchar2(30 char)                   null,
    ilnnr                                        varchar2(70 char)                   null,
    pfort                                        varchar2(35 char)                   null,
    spras_iso                                    varchar2(2 char)                    null,
    title                                        varchar2(15 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_pnr is 'LADS Invoice Partner';
comment on column lads_inv_pnr.belnr is 'IDOC document number';
comment on column lads_inv_pnr.pnrseq is 'PNR - generated sequence number';
comment on column lads_inv_pnr.parvw is '"Partner function (e.g. sold-to party, ship-to party, ...)"';
comment on column lads_inv_pnr.partn is 'Partner number';
comment on column lads_inv_pnr.lifnr is 'Vendor number at customer location';
comment on column lads_inv_pnr.name1 is 'Name 1';
comment on column lads_inv_pnr.name2 is 'Name 2';
comment on column lads_inv_pnr.name3 is 'Name 3';
comment on column lads_inv_pnr.name4 is 'Name 4';
comment on column lads_inv_pnr.stras is 'Street and house number 1';
comment on column lads_inv_pnr.strs2 is 'Street and house number 2';
comment on column lads_inv_pnr.pfach is 'PO Box';
comment on column lads_inv_pnr.ort01 is 'City';
comment on column lads_inv_pnr.counc is 'County code';
comment on column lads_inv_pnr.pstlz is 'Postal code';
comment on column lads_inv_pnr.pstl2 is 'P.O. Box postal code';
comment on column lads_inv_pnr.land1 is 'Country key';
comment on column lads_inv_pnr.ablad is 'Unloading Point';
comment on column lads_inv_pnr.pernr is 'Contact persons personnel number';
comment on column lads_inv_pnr.parnr is 'Contact persons number (not personnel number)';
comment on column lads_inv_pnr.telf1 is '1st telephone number of contact person';
comment on column lads_inv_pnr.telf2 is '2nd telephone number of contact person';
comment on column lads_inv_pnr.telbx is 'Telebox number';
comment on column lads_inv_pnr.telfx is 'Fax number';
comment on column lads_inv_pnr.teltx is 'Teletex number';
comment on column lads_inv_pnr.telx1 is 'Telex number';
comment on column lads_inv_pnr.spras is 'Language key';
comment on column lads_inv_pnr.anred is 'Form of Address';
comment on column lads_inv_pnr.ort02 is 'District';
comment on column lads_inv_pnr.hausn is 'House number';
comment on column lads_inv_pnr.stock is 'Floor';
comment on column lads_inv_pnr.regio is 'Region';
comment on column lads_inv_pnr.parge is 'Partners gender';
comment on column lads_inv_pnr.isoal is 'Country ISO code';
comment on column lads_inv_pnr.isonu is 'Country ISO code';
comment on column lads_inv_pnr.fcode is 'Company key (France)';
comment on column lads_inv_pnr.ihrez is 'Your reference (Partner)';
comment on column lads_inv_pnr.bname is 'IDoc user name';
comment on column lads_inv_pnr.paorg is 'IDOC organization code';
comment on column lads_inv_pnr.orgtx is 'IDoc organization code text';
comment on column lads_inv_pnr.pagru is 'IDoc group code';
comment on column lads_inv_pnr.knref is '"Customer description of partner (plant, storage location)"';
comment on column lads_inv_pnr.ilnnr is '"Character field, length 70"';
comment on column lads_inv_pnr.pfort is 'PO Box city';
comment on column lads_inv_pnr.spras_iso is 'Language according to ISO 639';
comment on column lads_inv_pnr.title is 'Title';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_pnr
   add constraint lads_inv_pnr_pk primary key (belnr, pnrseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_pnr to lads_app;
grant select, insert, update, delete on lads_inv_pnr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_pnr for lads.lads_inv_pnr;
