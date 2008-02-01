/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isr
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isr

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isr
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isrseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    refnr                                        varchar2(35 char)                   null,
    xline                                        number                              null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isr is 'LADS Sales Order Item Service Specification Reference';
comment on column lads_sal_ord_isr.belnr is 'Document number';
comment on column lads_sal_ord_isr.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isr.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isr.isrseq is 'ISR - generated sequence number';
comment on column lads_sal_ord_isr.qualf is 'IDoc qualifier reference document for service specifications';
comment on column lads_sal_ord_isr.refnr is 'IDOC reference number';
comment on column lads_sal_ord_isr.xline is 'Line number';
comment on column lads_sal_ord_isr.datum is 'IDOC: Date';
comment on column lads_sal_ord_isr.uzeit is 'IDOC: Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isr
   add constraint lads_sal_ord_isr_pk primary key (belnr, genseq, issseq, isrseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isr to lads_app;
grant select, insert, update, delete on lads_sal_ord_isr to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isr for lads.lads_sal_ord_isr;
