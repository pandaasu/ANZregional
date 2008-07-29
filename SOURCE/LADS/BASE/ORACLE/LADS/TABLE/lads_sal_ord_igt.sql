/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_igt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_igt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_igt
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    igtseq                                       number                              not null,
    tdformat                                     varchar2(2 char)                    null,
    tdline                                       varchar2(132 char)                  null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_igt is 'LADS Sales Order Item Text';
comment on column lads_sal_ord_igt.belnr is 'Document number';
comment on column lads_sal_ord_igt.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_igt.igtseq is 'IGT - generated sequence number';
comment on column lads_sal_ord_igt.tdformat is 'Tag column';
comment on column lads_sal_ord_igt.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_igt
   add constraint lads_sal_ord_igt_pk primary key (belnr, genseq, igtseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_igt to lads_app;
grant select, insert, update, delete on lads_sal_ord_igt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_igt for lads.lads_sal_ord_igt;
