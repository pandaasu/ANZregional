/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isj
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isj

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isj
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isjseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    tage                                         varchar2(8 char)                    null,
    prznt                                        varchar2(8 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isj is 'LADS Sales Order Item Service Specification Terms Of Payment';
comment on column lads_sal_ord_isj.belnr is 'Document number';
comment on column lads_sal_ord_isj.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isj.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isj.isjseq is 'ISJ - generated sequence number';
comment on column lads_sal_ord_isj.qualf is 'IDOC qualifier: Terms of payment';
comment on column lads_sal_ord_isj.tage is 'IDOC Number of days';
comment on column lads_sal_ord_isj.prznt is 'IDOC percentage for terms of payment';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isj
   add constraint lads_sal_ord_isj_pk primary key (belnr, genseq, issseq, isjseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isj to lads_app;
grant select, insert, update, delete on lads_sal_ord_isj to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isj for lads.lads_sal_ord_isj;
