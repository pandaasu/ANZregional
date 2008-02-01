/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_sal_ord_idt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_sal_ord_idt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_sal_ord_idt
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    idtseq                                       number                              not null,
    iddat                                        varchar2(3 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_sal_ord_idt is 'LADS Sales Order Item Date';
comment on column lads_sal_ord_idt.belnr is 'Document number';
comment on column lads_sal_ord_idt.genseq is 'GEN - generated sequence number';
comment on column lads_sal_ord_idt.idtseq is 'IDT - generated sequence number';
comment on column lads_sal_ord_idt.iddat is 'Qualifier for IDOC date segment';
comment on column lads_sal_ord_idt.datum is 'Date';
comment on column lads_sal_ord_idt.uzeit is 'Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_sal_ord_idt
   add constraint lads_sal_ord_idt_pk primary key (belnr, genseq, idtseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_sal_ord_idt to lads_app;
grant select, insert, update, delete on lads_sal_ord_idt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_sal_ord_idt for lads.lads_sal_ord_idt;
