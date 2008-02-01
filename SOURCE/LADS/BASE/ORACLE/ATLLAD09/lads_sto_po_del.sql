/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_del
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_del

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_del
   (belnr                                        varchar2(35 char)                   not null,
    delseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    lkond                                        varchar2(3 char)                    null,
    lktext                                       varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_del is 'LADS Stock Transfer and Purchase Order Delivery';
comment on column lads_sto_po_del.belnr is 'IDOC document number';
comment on column lads_sto_po_del.delseq is 'DEL - generated sequence number';
comment on column lads_sto_po_del.qualf is 'IDOC qualifier reference document';
comment on column lads_sto_po_del.lkond is 'IDOC delivery condition code';
comment on column lads_sto_po_del.lktext is 'IDOC delivery condition text';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_del
   add constraint lads_sto_po_del_pk primary key (belnr, delseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_del to lads_app;
grant select, insert, update, delete on lads_sto_po_del to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_del for lads.lads_sto_po_del;
