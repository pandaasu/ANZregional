/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_oid
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_oid

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_oid
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    oidseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    idtnr                                        varchar2(35 char)                   null,
    ktext                                        varchar2(70 char)                   null,
    mfrnr                                        varchar2(10 char)                   null,
    mfrpn                                        varchar2(42 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_oid is 'LADS Stock Transfer and Purchase Order Item Object Identification';
comment on column lads_sto_po_oid.belnr is 'IDOC document number';
comment on column lads_sto_po_oid.genseq is 'GEN - generated sequence number';
comment on column lads_sto_po_oid.oidseq is 'OID - generated sequence number';
comment on column lads_sto_po_oid.qualf is 'IDOC qualifier reference document';
comment on column lads_sto_po_oid.idtnr is 'IDOC material ID';
comment on column lads_sto_po_oid.ktext is 'IDOC short text';
comment on column lads_sto_po_oid.mfrnr is 'Manufacturer number';
comment on column lads_sto_po_oid.mfrpn is 'Manufacturer part number';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_oid
   add constraint lads_sto_po_oid_pk primary key (belnr, genseq, oidseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_oid to lads_app;
grant select, insert, update, delete on lads_sto_po_oid to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_oid for lads.lads_sto_po_oid;
