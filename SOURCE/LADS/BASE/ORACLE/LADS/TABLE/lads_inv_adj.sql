/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_adj
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_adj

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_adj
   (belnr                                        varchar2(35 char)                   not null,
    pnrseq                                       number                              not null,
    adjseq                                       number                              not null,
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
comment on table lads_inv_adj is 'LADS Invoice Partner Japan Address';
comment on column lads_inv_adj.belnr is 'IDOC document number';
comment on column lads_inv_adj.pnrseq is 'PNR - generated sequence number';
comment on column lads_inv_adj.adjseq is 'ADJ - generated sequence number';
comment on column lads_inv_adj.langu is 'Language according to ISO 639';
comment on column lads_inv_adj.nation is 'International address version ID';
comment on column lads_inv_adj.name1 is 'Name 1';
comment on column lads_inv_adj.name2 is 'Name 2';
comment on column lads_inv_adj.name3 is 'Name 3';
comment on column lads_inv_adj.street is 'Street';
comment on column lads_inv_adj.str_suppl1 is 'Street 2';
comment on column lads_inv_adj.str_suppl2 is 'Street 3';
comment on column lads_inv_adj.city1 is 'City';
comment on column lads_inv_adj.city2 is 'District';
comment on column lads_inv_adj.po_box is 'PO Box';
comment on column lads_inv_adj.country is 'Country Key';
comment on column lads_inv_adj.fax_number is 'Fax number: dialling code+number';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_adj
   add constraint lads_inv_adj_pk primary key (belnr, pnrseq, adjseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_adj to lads_app;
grant select, insert, update, delete on lads_inv_adj to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_adj for lads.lads_inv_adj;
