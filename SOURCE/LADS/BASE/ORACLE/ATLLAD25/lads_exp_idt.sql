/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_idt
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_idt

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_idt
   (zzgrpnr                                      varchar2(40 char)                   not null,
    invseq                                       number                              not null,
    hinseq                                       number                              not null,
    idtseq                                       number                              not null,
    iddat                                        varchar2(3 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null);

/**/
/* Comments
/**/
comment on table lads_exp_idt is 'Generic ICB Document - Invoice data';
comment on column lads_exp_idt.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_idt.invseq is 'INV - generated sequence number';
comment on column lads_exp_idt.hinseq is 'HIN - generated sequence number';
comment on column lads_exp_idt.idtseq is 'IDT - generated sequence number';
comment on column lads_exp_idt.iddat is 'Qualifier for IDOC date segment';
comment on column lads_exp_idt.datum is 'IDOC: Date';
comment on column lads_exp_idt.uzeit is 'IDOC: Time';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_idt
   add constraint lads_exp_idt_pk primary key (zzgrpnr, invseq, hinseq, idtseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_idt to lads_app;
grant select, insert, update, delete on lads_exp_idt to ics_app;
grant select on lads_exp_idt to ics_reader with grant option;
grant select on lads_exp_idt to ics_executor;
grant select on lads_exp_idt to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_idt for lads.lads_exp_idt;
