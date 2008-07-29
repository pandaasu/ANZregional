/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_iso
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_iso

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_iso
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isoseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    idtnr                                        varchar2(35 char)                   null,
    ktext                                        varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_iso is 'LADS Sales Order Item Service Specification Object Identification';
comment on column lads_sal_ord_iso.belnr is 'Document number';
comment on column lads_sal_ord_iso.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_iso.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_iso.isoseq is 'ISO - generated sequence number';
comment on column lads_sal_ord_iso.qualf is 'IDoc object identification for service specfns object';
comment on column lads_sal_ord_iso.idtnr is 'IDOC material ID';
comment on column lads_sal_ord_iso.ktext is 'IDOC short text';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_iso
   add constraint lads_sal_ord_iso_pk primary key (belnr, genseq, issseq, isoseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_iso to lads_app;
grant select, insert, update, delete on lads_sal_ord_iso to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_iso for lads.lads_sal_ord_iso;
