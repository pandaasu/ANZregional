/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_irf
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_irf

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_irf
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    irfseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    refnr                                        varchar2(35 char)                   null,
    zeile                                        varchar2(6 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null,
    bsark                                        varchar2(35 char)                   null,
    ihrez                                        varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_irf is 'LADS Sales Order Item Reference';
comment on column lads_sal_ord_irf.belnr is 'Document number';
comment on column lads_sal_ord_irf.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_irf.irfseq is 'IRF - generated sequence number';
comment on column lads_sal_ord_irf.qualf is 'IDOC qualifier reference document';
comment on column lads_sal_ord_irf.refnr is 'IDOC reference number';
comment on column lads_sal_ord_irf.zeile is 'Item number';
comment on column lads_sal_ord_irf.datum is 'IDOC: Date';
comment on column lads_sal_ord_irf.uzeit is 'IDOC: Time';
comment on column lads_sal_ord_irf.bsark is 'IDOC organization';
comment on column lads_sal_ord_irf.ihrez is 'Your reference (Partner)';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_irf
   add constraint lads_sal_ord_irf_pk primary key (belnr, genseq, irfseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_irf to lads_app;
grant select, insert, update, delete on lads_sal_ord_irf to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_irf for lads.lads_sal_ord_irf;
