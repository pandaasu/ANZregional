/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isp
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isp

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isp
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    ispseq                                       number                              not null,
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
    pagru                                        varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isp is 'LADS Sales Order Item Service Specification Partner';
comment on column lads_sal_ord_isp.belnr is 'Document number';
comment on column lads_sal_ord_isp.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isp.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isp.ispseq is 'ISP - generated sequence number';
comment on column lads_sal_ord_isp.parvw is '"Partner function (e.g. sold-to party, ship-to party, ...)"';
comment on column lads_sal_ord_isp.partn is 'Partner number';
comment on column lads_sal_ord_isp.lifnr is 'Vendor number at customer location';
comment on column lads_sal_ord_isp.name1 is 'Name 1';
comment on column lads_sal_ord_isp.name2 is 'Name 2';
comment on column lads_sal_ord_isp.name3 is 'Name 3';
comment on column lads_sal_ord_isp.name4 is 'Name 4';
comment on column lads_sal_ord_isp.stras is 'Street and house number 1';
comment on column lads_sal_ord_isp.strs2 is 'Street and house number 2';
comment on column lads_sal_ord_isp.pfach is 'PO Box';
comment on column lads_sal_ord_isp.ort01 is 'City';
comment on column lads_sal_ord_isp.counc is 'County code';
comment on column lads_sal_ord_isp.pstlz is 'Postal code';
comment on column lads_sal_ord_isp.pstl2 is 'P.O. Box postal code';
comment on column lads_sal_ord_isp.land1 is 'Country key';
comment on column lads_sal_ord_isp.ablad is 'Unloading Point';
comment on column lads_sal_ord_isp.pernr is 'Contact persons personnel number';
comment on column lads_sal_ord_isp.parnr is 'Contact persons number (not personnel number)';
comment on column lads_sal_ord_isp.telf1 is '1st telephone number of contact person';
comment on column lads_sal_ord_isp.telf2 is '2nd telephone number of contact person';
comment on column lads_sal_ord_isp.telbx is 'Telebox number';
comment on column lads_sal_ord_isp.telfx is 'Fax number';
comment on column lads_sal_ord_isp.teltx is 'Teletex number';
comment on column lads_sal_ord_isp.telx1 is 'Telex number';
comment on column lads_sal_ord_isp.spras is 'Language key';
comment on column lads_sal_ord_isp.anred is 'Form of Address';
comment on column lads_sal_ord_isp.ort02 is 'District';
comment on column lads_sal_ord_isp.hausn is 'House number';
comment on column lads_sal_ord_isp.stock is 'Floor';
comment on column lads_sal_ord_isp.regio is 'Region';
comment on column lads_sal_ord_isp.parge is 'Partners gender';
comment on column lads_sal_ord_isp.isoal is 'Country ISO code';
comment on column lads_sal_ord_isp.isonu is 'Country ISO code';
comment on column lads_sal_ord_isp.fcode is 'Company key (France)';
comment on column lads_sal_ord_isp.ihrez is 'Your reference (Partner)';
comment on column lads_sal_ord_isp.bname is 'IDoc user name';
comment on column lads_sal_ord_isp.paorg is 'IDOC organization code';
comment on column lads_sal_ord_isp.orgtx is 'IDoc organization code text';
comment on column lads_sal_ord_isp.pagru is 'IDoc group code';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isp
   add constraint lads_sal_ord_isp_pk primary key (belnr, genseq, issseq, ispseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isp to lads_app;
grant select, insert, update, delete on lads_sal_ord_isp to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isp for lads.lads_sal_ord_isp;
