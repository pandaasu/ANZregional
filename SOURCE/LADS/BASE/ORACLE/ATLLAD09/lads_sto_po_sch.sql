/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_sch
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_sch

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_sch
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    schseq                                       number                              not null,
    wmeng                                        varchar2(15 char)                   null,
    ameng                                        varchar2(15 char)                   null,
    edatu                                        varchar2(8 char)                    null,
    ezeit                                        varchar2(6 char)                    null,
    edatu_old                                    varchar2(8 char)                    null,
    ezeit_old                                    varchar2(6 char)                    null,
    action                                       varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sto_po_sch is 'LADS Stock Transfer and Purchase Order Item Schedule';
comment on column lads_sto_po_sch.belnr is 'IDOC document number';
comment on column lads_sto_po_sch.genseq is 'GEN - generated sequence number';
comment on column lads_sto_po_sch.schseq is 'SCH - generated sequence number';
comment on column lads_sto_po_sch.wmeng is 'Scheduled quantity';
comment on column lads_sto_po_sch.ameng is 'Previous scheduled quantity';
comment on column lads_sto_po_sch.edatu is 'IDOC: Date';
comment on column lads_sto_po_sch.ezeit is 'IDOC: Time';
comment on column lads_sto_po_sch.edatu_old is 'IDOC: Date';
comment on column lads_sto_po_sch.ezeit_old is 'IDOC: Time';
comment on column lads_sto_po_sch.action is 'Action code for the item';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_sch
   add constraint lads_sto_po_sch_pk primary key (belnr, genseq, schseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_sch to lads_app;
grant select, insert, update, delete on lads_sto_po_sch to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_sch for lads.lads_sto_po_sch;
