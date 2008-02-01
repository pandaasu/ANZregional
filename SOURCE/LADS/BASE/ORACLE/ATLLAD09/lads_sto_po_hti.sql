/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sto_po_hti
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sto_po_hti

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sto_po_hti
   (belnr                                        varchar2(35 char)                   not null,
    htiseq                                       number                              not null,
    tdid                                         varchar2(4 char)                    null,
    tsspras                                      varchar2(3 char)                    null,
    tsspras_iso                                  varchar2(2 char)                    null,
    tdobject                                     varchar2(10 char)                   null,
    tdobname                                     varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sto_po_hti is 'LADS Stock Transfer and Purchase Order Text Header';
comment on column lads_sto_po_hti.belnr is 'IDOC document number';
comment on column lads_sto_po_hti.htiseq is 'HTI - generated sequence number';
comment on column lads_sto_po_hti.tdid is 'Text ID';
comment on column lads_sto_po_hti.tsspras is 'Language Key';
comment on column lads_sto_po_hti.tsspras_iso is 'Language according to ISO 639';
comment on column lads_sto_po_hti.tdobject is 'Texts: application object';
comment on column lads_sto_po_hti.tdobname is 'Name';

/**/
/* Primary Key Constraint
/**/
alter table lads_sto_po_hti
   add constraint lads_sto_po_hti_pk primary key (belnr, htiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sto_po_hti to lads_app;
grant select, insert, update, delete on lads_sto_po_hti to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sto_po_hti for lads.lads_sto_po_hti;
