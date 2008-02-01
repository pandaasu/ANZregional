/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_ref
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_ref

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_ref
   (belnr                                        varchar2(35 char)                   not null,
    refseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    refnr                                        varchar2(35 char)                   null,
    posnr                                        varchar2(6 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_ref is 'LADS Sales Order Reference';
comment on column lads_sal_ord_ref.belnr is 'Document number';
comment on column lads_sal_ord_ref.refseq is 'REF - generated sequence number';
comment on column lads_sal_ord_ref.qualf is 'IDOC qualifier reference document';
comment on column lads_sal_ord_ref.refnr is 'IDOC reference number';
comment on column lads_sal_ord_ref.posnr is 'Item number';
comment on column lads_sal_ord_ref.datum is 'IDOC: Date';
comment on column lads_sal_ord_ref.uzeit is 'IDOC: Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_ref
   add constraint lads_sal_ord_ref_pk primary key (belnr, refseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_ref to lads_app;
grant select, insert, update, delete on lads_sal_ord_ref to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_ref for lads.lads_sal_ord_ref;
