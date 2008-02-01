/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_add
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_add

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_add
   (belnr                                        varchar2(35 char)                   not null,
    addseq                                       number                              not null,
    qualz                                        varchar2(3 char)                    null,
    cusadd                                       varchar2(35 char)                   null,
    cusadd_bez                                   varchar2(40 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_add is 'LADS Sales Order Additional';
comment on column lads_sal_ord_add.belnr is 'Document number';
comment on column lads_sal_ord_add.addseq is 'ADD - generated sequence number';
comment on column lads_sal_ord_add.qualz is 'Qualifier for IDoc additional data';
comment on column lads_sal_ord_add.cusadd is 'Data Element Type CHAR Length 35';
comment on column lads_sal_ord_add.cusadd_bez is 'Character field of length 40';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_add
   add constraint lads_sal_ord_add_pk primary key (belnr, addseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_add to lads_app;
grant select, insert, update, delete on lads_sal_ord_add to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_add for lads.lads_sal_ord_add;
