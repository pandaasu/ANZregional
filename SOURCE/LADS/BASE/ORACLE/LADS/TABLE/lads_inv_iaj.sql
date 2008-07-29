/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_iaj
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_iaj

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_iaj
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    ipnseq                                       number                              not null,
    iajseq                                       number                              not null,
    langu                                        varchar2(2 char)                    null,
    nation                                       varchar2(1 char)                    null,
    name1                                        varchar2(40 char)                   null,
    name2                                        varchar2(40 char)                   null,
    name3                                        varchar2(40 char)                   null,
    street                                       varchar2(60 char)                   null,
    str_suppl1                                   varchar2(40 char)                   null,
    str_suppl2                                   varchar2(40 char)                   null,
    city1                                        varchar2(40 char)                   null,
    city2                                        varchar2(40 char)                   null,
    po_box                                       varchar2(10 char)                   null,
    country                                      varchar2(3 char)                    null,
    fax_number                                   varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_iaj is 'LADS Invoice Item Partner Japan Address';
comment on column lads_inv_iaj.belnr is 'IDOC document number';
comment on column lads_inv_iaj.genseq is 'GEN - generated sequence number';
comment on column lads_inv_iaj.ipnseq is 'IPN - generated sequence number';
comment on column lads_inv_iaj.iajseq is 'IAJ - generated sequence number';
comment on column lads_inv_iaj.langu is 'Language according to ISO 639';
comment on column lads_inv_iaj.nation is 'International address version ID';
comment on column lads_inv_iaj.name1 is 'Name 1';
comment on column lads_inv_iaj.name2 is 'Name 2';
comment on column lads_inv_iaj.name3 is 'Name 3';
comment on column lads_inv_iaj.street is 'Street';
comment on column lads_inv_iaj.str_suppl1 is 'Street 2';
comment on column lads_inv_iaj.str_suppl2 is 'Street 3';
comment on column lads_inv_iaj.city1 is 'City';
comment on column lads_inv_iaj.city2 is 'District';
comment on column lads_inv_iaj.po_box is 'PO Box';
comment on column lads_inv_iaj.country is 'Country Key';
comment on column lads_inv_iaj.fax_number is 'Fax number: dialling code+number';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_iaj
   add constraint lads_inv_iaj_pk primary key (belnr, genseq, ipnseq, iajseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_iaj to lads_app;
grant select, insert, update, delete on lads_inv_iaj to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_iaj for lads.lads_inv_iaj;
