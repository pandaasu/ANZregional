/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_ref
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_ref

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_ref
   (belnr                                        varchar2(35 char)                   not null,
    refseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    refnr                                        varchar2(35 char)                   null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null,
    posnr                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sto_po_ref is 'LADS Stock Transfer and Purchase Order Reference';
comment on column lads_sto_po_ref.belnr is 'IDOC document number';
comment on column lads_sto_po_ref.refseq is 'REF - generated sequence number';
comment on column lads_sto_po_ref.qualf is 'IDOC qualifier reference document';
comment on column lads_sto_po_ref.refnr is 'IDOC reference number';
comment on column lads_sto_po_ref.datum is 'IDOC: Date';
comment on column lads_sto_po_ref.uzeit is 'IDOC: Time';
comment on column lads_sto_po_ref.posnr is 'Item number';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_ref
   add constraint lads_sto_po_ref_pk primary key (belnr, refseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_ref to lads_app;
grant select, insert, update, delete on lads_sto_po_ref to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_ref for lads.lads_sto_po_ref;
