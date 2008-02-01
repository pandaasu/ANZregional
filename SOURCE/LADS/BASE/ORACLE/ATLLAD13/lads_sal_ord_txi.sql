/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_txi
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_txi

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_txi
   (belnr                                        varchar2(35 char)                   not null,
    txiseq                                       number                              not null,
    tdid                                         varchar2(4 char)                    null,
    tsspras                                      varchar2(3 char)                    null,
    tsspras_iso                                  varchar2(2 char)                    null,
    tdobject                                     varchar2(10 char)                   null,
    tdobname                                     varchar2(70 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_txi is 'LADS Sales Order Text Header';
comment on column lads_sal_ord_txi.belnr is 'Document number';
comment on column lads_sal_ord_txi.txiseq is 'TXI - generated sequence number';
comment on column lads_sal_ord_txi.tdid is 'Text ID';
comment on column lads_sal_ord_txi.tsspras is 'Language Key';
comment on column lads_sal_ord_txi.tsspras_iso is 'Language according to ISO 639';
comment on column lads_sal_ord_txi.tdobject is 'Texts: application object';
comment on column lads_sal_ord_txi.tdobname is 'Name';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_txi
   add constraint lads_sal_ord_txi_pk primary key (belnr, txiseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_txi to lads_app;
grant select, insert, update, delete on lads_sal_ord_txi to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_txi for lads.lads_sal_ord_txi;
