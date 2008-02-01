/******************************************************************************/
/* Table Definition                                                           */
/******************************************************************************/
/**
 System  : lads
 Table   : lads_exp_ire
 Owner   : lads
 Author  : ISI Asia Pacific

 Description
 -----------
 Local Atlas Data Store - lads_exp_ire

 YYYY/MM   Author         Description
 -------   ------         -----------
 2005/11   ISI            Created

*******************************************************************************/

/**/
/* Table creation
/**/
create table lads_exp_ire
   (zzgrpnr                                      varchar2(40 char)                   not null,
    invseq                                       number                              not null,
    hinseq                                       number                              not null,
    ignseq                                       number                              not null,
    ireseq                                       number                              not null,
    qualf                                        varchar2(3 char)                    null,
    belnr                                        varchar2(35 char)                   null,
    zeile                                        varchar2(6 char)                    null,
    datum                                        varchar2(8 char)                    null,
    uzeit                                        varchar2(6 char)                    null,
    bsark                                        varchar2(35 char)                   null,
    ihrez                                        varchar2(30 char)                   null);

/**/
/* Comments
/**/
comment on table lads_exp_ire is 'Generic ICB Document - Invoice data';
comment on column lads_exp_ire.zzgrpnr is 'Shipment Grouping Number';
comment on column lads_exp_ire.invseq is 'INV - generated sequence number';
comment on column lads_exp_ire.hinseq is 'HIN - generated sequence number';
comment on column lads_exp_ire.ignseq is 'IGN - generated sequence number';
comment on column lads_exp_ire.ireseq is 'IRE - generated sequence number';
comment on column lads_exp_ire.qualf is 'IDOC qualifier reference document';
comment on column lads_exp_ire.belnr is 'IDOC document number';
comment on column lads_exp_ire.zeile is 'Item number';
comment on column lads_exp_ire.datum is 'IDOC: Date';
comment on column lads_exp_ire.uzeit is 'IDOC: Time';
comment on column lads_exp_ire.bsark is 'IDOC organization';
comment on column lads_exp_ire.ihrez is 'Your reference (Partner)';

/**/
/* Primary Key Constraint
/**/
alter table lads_exp_ire
   add constraint lads_exp_ire_pk primary key (zzgrpnr, invseq, hinseq, ignseq, ireseq);

/**/
/* Authority
/**/
grant select, insert, update, delete on lads_exp_ire to lads_app;
grant select, insert, update, delete on lads_exp_ire to ics_app;
grant select on lads_exp_ire to ics_reader with grant option;
grant select on lads_exp_ire to ics_executor;
grant select on lads_exp_ire to site_app;

/**/
/* Synonym
/**/
create or replace public synonym lads_exp_ire for lads.lads_exp_ire;
