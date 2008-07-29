/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isi
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isiseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    lkond                                        varchar2(3 char)                    null,
    lktext                                       varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isi is 'LADS Sales Order Item Service Specification Terms Of Delivery';
comment on column lads_sal_ord_isi.belnr is 'Document number';
comment on column lads_sal_ord_isi.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isi.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isi.isiseq is 'ISI - generated sequence number';
comment on column lads_sal_ord_isi.qualf is 'IDOC qualifier: Terms of delivery';
comment on column lads_sal_ord_isi.lkond is 'IDOC delivery condition code';
comment on column lads_sal_ord_isi.lktext is 'IDOC delivery condition text';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isi
   add constraint lads_sal_ord_isi_pk primary key (belnr, genseq, issseq, isiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isi to lads_app;
grant select, insert, update, delete on lads_sal_ord_isi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isi for lads.lads_sal_ord_isi;
