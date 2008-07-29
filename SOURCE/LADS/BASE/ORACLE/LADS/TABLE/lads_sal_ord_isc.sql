/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isc
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isc

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isc
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    iscseq                                       number                              not null,
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
comment on table lads_sal_ord_isc is 'LADS Sales Order Item Schedule';
comment on column lads_sal_ord_isc.belnr is 'Document number';
comment on column lads_sal_ord_isc.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isc.iscseq is 'ISC - generated sequence number';
comment on column lads_sal_ord_isc.wmeng is 'Scheduled quantity';
comment on column lads_sal_ord_isc.ameng is 'Previous scheduled quantity';
comment on column lads_sal_ord_isc.edatu is 'IDOC: Date';
comment on column lads_sal_ord_isc.ezeit is 'IDOC: Time';
comment on column lads_sal_ord_isc.edatu_old is 'IDOC: Date';
comment on column lads_sal_ord_isc.ezeit_old is 'IDOC: Time';
comment on column lads_sal_ord_isc.action is 'Action code for the item';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isc
   add constraint lads_sal_ord_isc_pk primary key (belnr, genseq, iscseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isc to lads_app;
grant select, insert, update, delete on lads_sal_ord_isc to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isc for lads.lads_sal_ord_isc;
