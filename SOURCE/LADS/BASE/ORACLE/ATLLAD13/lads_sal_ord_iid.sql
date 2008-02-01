/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_iid
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_iid

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_iid
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    iidseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    idtnr                                        varchar2(35 char)                   null,
    ktext                                        varchar2(70 char)                   null,
    mfrpn                                        varchar2(42 char)                   null,
    mfrnr                                        varchar2(10 char)                   null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_iid is 'LADS Sales Order Item Object Identification';
comment on column lads_sal_ord_iid.belnr is 'Document number';
comment on column lads_sal_ord_iid.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_iid.iidseq is 'IID - generated sequence number';
comment on column lads_sal_ord_iid.qualf is '"IDOC object identification such as material no.,customer"';
comment on column lads_sal_ord_iid.idtnr is 'IDOC material ID';
comment on column lads_sal_ord_iid.ktext is 'IDOC short text';
comment on column lads_sal_ord_iid.mfrpn is 'Manufacturer part number';
comment on column lads_sal_ord_iid.mfrnr is 'Manufacturer number';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_iid
   add constraint lads_sal_ord_iid_pk primary key (belnr, genseq, iidseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_iid to lads_app;
grant select, insert, update, delete on lads_sal_ord_iid to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_iid for lads.lads_sal_ord_iid;
