/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_pcd
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_pcd

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_pcd
   (belnr                                        varchar2(35 char)                   not null,
    pcdseq                                       number                              not null,
    ccins                                        varchar2(4 char)                    null,
    ccins_bezei                                  varchar2(20 char)                   null,
    ccnum                                        varchar2(25 char)                   null,
    exdatbi                                      varchar2(8 char)                    null,
    ccname                                       varchar2(40 char)                   null,
    fakwr                                        number                              null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_pcd is 'LADS Sales Order Payment Cards';
comment on column lads_sal_ord_pcd.belnr is 'Document number';
comment on column lads_sal_ord_pcd.pcdseq is 'PCD - generated sequence number';
comment on column lads_sal_ord_pcd.ccins is 'Payment cards: Card type';
comment on column lads_sal_ord_pcd.ccins_bezei is 'Description';
comment on column lads_sal_ord_pcd.ccnum is 'Payment cards: Card number';
comment on column lads_sal_ord_pcd.exdatbi is 'IDOC: Date';
comment on column lads_sal_ord_pcd.ccname is 'Payment cards: Name of cardholder';
comment on column lads_sal_ord_pcd.fakwr is 'Maximum amount';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_pcd
   add constraint lads_sal_ord_pcd_pk primary key (belnr, pcdseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_pcd to lads_app;
grant select, insert, update, delete on lads_sal_ord_pcd to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_pcd for lads.lads_sal_ord_pcd;
