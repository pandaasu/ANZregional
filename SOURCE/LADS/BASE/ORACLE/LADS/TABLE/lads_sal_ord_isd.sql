/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isd
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isdseq                                       number                              not null,
    iddat                                        varchar2(3 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isd is 'LADS Sales Order Item Service Specification Date';
comment on column lads_sal_ord_isd.belnr is 'Document number';
comment on column lads_sal_ord_isd.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isd.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isd.isdseq is 'ISD - generated sequence number';
comment on column lads_sal_ord_isd.iddat is 'Qualifier for IDOC date segment';
comment on column lads_sal_ord_isd.datum is 'Date';
comment on column lads_sal_ord_isd.uzeit is 'Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isd
   add constraint lads_sal_ord_isd_pk primary key (belnr, genseq, issseq, isdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isd to lads_app;
grant select, insert, update, delete on lads_sal_ord_isd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isd for lads.lads_sal_ord_isd;
