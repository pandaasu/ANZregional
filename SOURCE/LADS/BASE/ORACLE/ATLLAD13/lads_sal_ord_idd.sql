/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_idd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_idd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_idd
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    iddseq                                       number                              not null,
    qualz                                        varchar2(3 char)                    null,
    cusadd                                       varchar2(35 char)                   null,
    cusadd_bez                                   varchar2(40 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_idd is 'LADS Sales Order Item Additional';
comment on column lads_sal_ord_idd.belnr is 'Document number';
comment on column lads_sal_ord_idd.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_idd.iddseq is 'IDD - generated sequence number';
comment on column lads_sal_ord_idd.qualz is 'Qualifier for IDoc additional data';
comment on column lads_sal_ord_idd.cusadd is 'Data Element Type CHAR Length 35';
comment on column lads_sal_ord_idd.cusadd_bez is 'Character field of length 40';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_idd
   add constraint lads_sal_ord_idd_pk primary key (belnr, genseq, iddseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_idd to lads_app;
grant select, insert, update, delete on lads_sal_ord_idd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_idd for lads.lads_sal_ord_idd;
