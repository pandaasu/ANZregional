/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isy
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isy

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isy
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isxseq                                       number                              not null,
    isyseq                                       number                              not null,
    tdline                                       varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isy is 'LADS Sales Order Item Service Specification Text Detail';
comment on column lads_sal_ord_isy.belnr is 'Document number';
comment on column lads_sal_ord_isy.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isy.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isy.isxseq is 'ISX - generated sequence number';
comment on column lads_sal_ord_isy.isyseq is 'ISY - generated sequence number';
comment on column lads_sal_ord_isy.tdline is 'Text line';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isy
   add constraint lads_sal_ord_isy_pk primary key (belnr, genseq, issseq, isxseq, isyseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isy to lads_app;
grant select, insert, update, delete on lads_sal_ord_isy to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isy for lads.lads_sal_ord_isy;
