/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_ipn
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_ipn

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_ipn
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    ipnseq                                       number                              not null,
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
comment on table lads_inv_ipn is 'LADS Invoice Item Partner';
comment on column lads_inv_ipn.belnr is 'IDOC document number';
comment on column lads_inv_ipn.genseq is 'GEN - generated sequence number';
comment on column lads_inv_ipn.ipnseq is 'IPN - generated sequence number';
comment on column lads_inv_ipn.parvw is '"Partner function (e.g. sold-to party, ship-to party, ...)"';
comment on column lads_inv_ipn.partn is 'Partner number';
comment on column lads_inv_ipn.lifnr is 'Vendor number at customer location';
comment on column lads_inv_ipn.name1 is 'Name 1';
comment on column lads_inv_ipn.name2 is 'Name 2';
comment on column lads_inv_ipn.name3 is 'Name 3';
comment on column lads_inv_ipn.name4 is 'Name 4';
comment on column lads_inv_ipn.stras is 'Street and house number 1';
comment on column lads_inv_ipn.strs2 is 'Street and house number 2';
comment on column lads_inv_ipn.pfach is 'PO Box';
comment on column lads_inv_ipn.ort01 is 'City';
comment on column lads_inv_ipn.counc is 'County code';
comment on column lads_inv_ipn.pstlz is 'Postal code';
comment on column lads_inv_ipn.pstl2 is 'P.O. Box postal code';
comment on column lads_inv_ipn.land1 is 'Country key';
comment on column lads_inv_ipn.ablad is 'Unloading Point';
comment on column lads_inv_ipn.pernr is 'Contact persons personnel number';
comment on column lads_inv_ipn.parnr is 'Contact persons number (not personnel number)';
comment on column lads_inv_ipn.telf1 is '1st telephone number of contact person';
comment on column lads_inv_ipn.telf2 is '2nd telephone number of contact person';
comment on column lads_inv_ipn.telbx is 'Telebox number';
comment on column lads_inv_ipn.telfx is 'Fax number';
comment on column lads_inv_ipn.teltx is 'Teletex number';
comment on column lads_inv_ipn.telx1 is 'Telex number';
comment on column lads_inv_ipn.spras is 'Language key';
comment on column lads_inv_ipn.anred is 'Form of Address';
comment on column lads_inv_ipn.ort02 is 'District';
comment on column lads_inv_ipn.hausn is 'House number';
comment on column lads_inv_ipn.stock is 'Floor';
comment on column lads_inv_ipn.regio is 'Region';
comment on column lads_inv_ipn.parge is 'Partners gender';
comment on column lads_inv_ipn.isoal is 'Country ISO code';
comment on column lads_inv_ipn.isonu is 'Country ISO code';
comment on column lads_inv_ipn.fcode is 'Company key (France)';
comment on column lads_inv_ipn.ihrez is 'Your reference (Partner)';
comment on column lads_inv_ipn.bname is 'IDoc user name';
comment on column lads_inv_ipn.paorg is 'IDOC organization code';
comment on column lads_inv_ipn.orgtx is 'IDoc organization code text';
comment on column lads_inv_ipn.pagru is 'IDoc group code';
comment on column lads_inv_ipn.knref is '"Customer description of partner (plant, storage location)"';
comment on column lads_inv_ipn.ilnnr is '"Character field, length 70"';
comment on column lads_inv_ipn.pfort is 'PO Box city';
comment on column lads_inv_ipn.spras_iso is 'Language according to ISO 639';
comment on column lads_inv_ipn.title is 'Title';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_ipn
   add constraint lads_inv_ipn_pk primary key (belnr, genseq, ipnseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_ipn to lads_app;
grant select, insert, update, delete on lads_inv_ipn to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_ipn for lads.lads_inv_ipn;
