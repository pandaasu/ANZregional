/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_tod
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_tod

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_tod
   (belnr                                        varchar2(35 char)                   not null,
    todseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    lkond                                        varchar2(3 char)                    null,
    lktext                                       varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_tod is 'LADS Sales Order Terms Of Delivery';
comment on column lads_sal_ord_tod.belnr is 'Document number';
comment on column lads_sal_ord_tod.todseq is 'TOD - generated sequence number';
comment on column lads_sal_ord_tod.qualf is 'IDOC qualifier: Terms of delivery';
comment on column lads_sal_ord_tod.lkond is 'IDOC delivery condition code';
comment on column lads_sal_ord_tod.lktext is 'IDOC delivery condition text';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_tod
   add constraint lads_sal_ord_tod_pk primary key (belnr, todseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_tod to lads_app;
grant select, insert, update, delete on lads_sal_ord_tod to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_tod for lads.lads_sal_ord_tod;
