/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_pad
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_pad

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_pad
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itpseq                                       number                              not null,
    padseq                                       number                              not null,
    qualp                                        varchar2(3 char)                    null,
    stdpn                                        varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_pad is 'LADS Stock Transfer and Purchase Order Item Partner Additional';
comment on column lads_sto_po_pad.belnr is 'IDOC document number';
comment on column lads_sto_po_pad.genseq is 'GEN - generated sequence number';
comment on column lads_sto_po_pad.itpseq is 'ITP - generated sequence number';
comment on column lads_sto_po_pad.padseq is 'PAD - generated sequence number';
comment on column lads_sto_po_pad.qualp is 'IDOC Partner identification (e.g.Dun and Bradstreet number)';
comment on column lads_sto_po_pad.stdpn is '"Character field, length 70"';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_pad
   add constraint lads_sto_po_pad_pk primary key (belnr, genseq, itpseq, padseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_pad to lads_app;
grant select, insert, update, delete on lads_sto_po_pad to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_pad for lads.lads_sto_po_pad;
