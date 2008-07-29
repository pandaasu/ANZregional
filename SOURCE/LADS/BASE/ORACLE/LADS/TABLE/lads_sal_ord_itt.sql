/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_itt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_itt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_itt
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    itxseq                                       number                              not null,
    ittseq                                       number                              not null,
    tdline                                       varchar2(70 char)                   null,
    tdformat                                     varchar2(2 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_itt is 'LADS Sales Order Item Text Detail';
comment on column lads_sal_ord_itt.belnr is 'Document number';
comment on column lads_sal_ord_itt.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_itt.itxseq is 'ITX - generated sequence number';
comment on column lads_sal_ord_itt.ittseq is 'ITT - generated sequence number';
comment on column lads_sal_ord_itt.tdline is 'Text line';
comment on column lads_sal_ord_itt.tdformat is 'Tag column';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_itt
   add constraint lads_sal_ord_itt_pk primary key (belnr, genseq, itxseq, ittseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_itt to lads_app;
grant select, insert, update, delete on lads_sal_ord_itt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_itt for lads.lads_sal_ord_itt;
