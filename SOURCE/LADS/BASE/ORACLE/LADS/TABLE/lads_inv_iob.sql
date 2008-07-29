/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_iob
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_iob

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_iob
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    iobseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    idtnr                                        varchar2(35 char)                   null,
    ktext                                        varchar2(70 char)                   null,
    mfrpn                                        varchar2(42 char)                   null,
    mfrnr                                        varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_inv_iob is 'LADS Invoice Item Object Identification';
comment on column lads_inv_iob.belnr is 'IDOC document number';
comment on column lads_inv_iob.genseq is 'GEN - generated sequence number';
comment on column lads_inv_iob.iobseq is 'IOB - generated sequence number';
comment on column lads_inv_iob.qualf is '"IDOC object identification such as material no.,customer"';
comment on column lads_inv_iob.idtnr is 'IDOC material ID';
comment on column lads_inv_iob.ktext is 'IDOC short text';
comment on column lads_inv_iob.mfrpn is 'Manufacturer part number';
comment on column lads_inv_iob.mfrnr is 'Manufacturer number';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_iob
   add constraint lads_inv_iob_pk primary key (belnr, genseq, iobseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_iob to lads_app;
grant select, insert, update, delete on lads_inv_iob to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_iob for lads.lads_inv_iob;
