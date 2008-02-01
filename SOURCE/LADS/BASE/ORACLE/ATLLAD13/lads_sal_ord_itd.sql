/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_itd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_itd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_itd
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itdseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    lkond                                        varchar2(3 char)                    null,
    lktext                                       varchar2(70 char)                   null,
    lprio                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_itd is 'LADS Sales Order Item Terms Of Delivery';
comment on column lads_sal_ord_itd.belnr is 'Document number';
comment on column lads_sal_ord_itd.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_itd.itdseq is 'ITD - generated sequence number';
comment on column lads_sal_ord_itd.qualf is 'IDOC qualifier: Terms of delivery';
comment on column lads_sal_ord_itd.lkond is 'IDOC delivery condition code';
comment on column lads_sal_ord_itd.lktext is 'IDOC delivery condition text';
comment on column lads_sal_ord_itd.lprio is 'Delivery Priority';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_itd
   add constraint lads_sal_ord_itd_pk primary key (belnr, genseq, itdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_itd to lads_app;
grant select, insert, update, delete on lads_sal_ord_itd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_itd for lads.lads_sal_ord_itd;
