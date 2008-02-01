/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_inv_idt
 Owner   : lads
 Author  : Steve Gregan

 Description
 -----------
 Local Atlas Data Store - lads_inv_idt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2004/01   Steve Gregan   Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_inv_idt
   (belnr                                        varchar2(35 char)                   not null,
    genseq                                       number                              not null,
    idtseq                                       number                              not null,
    iddat                                        varchar2(3 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_inv_idt is 'LADS Invoice Item Date';
comment on column lads_inv_idt.belnr is 'IDOC document number';
comment on column lads_inv_idt.genseq is 'GEN - generated sequence number';
comment on column lads_inv_idt.idtseq is 'IDT - generated sequence number';
comment on column lads_inv_idt.iddat is 'Qualifier for IDOC date segment';
comment on column lads_inv_idt.datum is 'Date';
comment on column lads_inv_idt.uzeit is 'Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_inv_idt
   add constraint lads_inv_idt_pk primary key (belnr, genseq, idtseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_inv_idt to lads_app;
grant select, insert, update, delete on lads_inv_idt to ics_app;

/**/
/* Synonym
/**/
create public synonym lads_inv_idt for lads.lads_inv_idt;
