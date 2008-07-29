/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_isx
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_isx

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_isx
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    issseq                                       number                              not null,
    isxseq                                       number                              not null,
    tdid                                         varchar2(4 char)                    null,
    tsspras                                      varchar2(3 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_isx is 'LADS Sales Order Item Service Specification Text Header';
comment on column lads_sal_ord_isx.belnr is 'Document number';
comment on column lads_sal_ord_isx.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_isx.issseq is 'ISS - generated sequence number';
comment on column lads_sal_ord_isx.isxseq is 'ISX - generated sequence number';
comment on column lads_sal_ord_isx.tdid is 'Text ID';
comment on column lads_sal_ord_isx.tsspras is 'Language Key';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_isx
   add constraint lads_sal_ord_isx_pk primary key (belnr, genseq, issseq, isxseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_isx to lads_app;
grant select, insert, update, delete on lads_sal_ord_isx to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_isx for lads.lads_sal_ord_isx;
